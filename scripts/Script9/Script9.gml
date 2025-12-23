#region jsDoc
/// @func   regex_find_first()
/// @desc   Find the first match of a compiled regex program in an input string.
///         Returns a small result struct with byte offsets (UTF-8 bytes, same as builder).
///         This is a simple Thompson NFA VM runner (two state lists + epsilon closure).
///
/// @param  {Struct} _program : output of regex_build_program()
/// @param  {String} _input_string
/// @param  {Real} _start_byte : optional byte index to start searching from (default 0)
/// @returns {Struct} {
///            found: Bool,
///            start: Real,   // start byte index
///            end:   Real    // end byte index (exclusive)
///          }
#endregion
function regex_find_first(_program, _input_string, _start_byte = 0) {
    static _temp_buff  = buffer_create(0, buffer_grow, 1);
    static _input_buff = buffer_create(0, buffer_fast, 1);

    // micro optimization (local refs)
    var _temp_buffer  = _temp_buff;
    var _input_buffer = _input_buff;

    var _byte_len = string_byte_length(_input_string);
    if (_start_byte < 0) _start_byte = 0;
    if (_start_byte > _byte_len) _start_byte = _byte_len;

    buffer_resize(_input_buffer, _byte_len);

    buffer_write(_temp_buffer, buffer_text, _input_string);
    buffer_copy(_temp_buffer, 0, _byte_len, _input_buffer, 0);
    buffer_resize(_temp_buffer, 0);

    // scan each possible start byte (simple first implementation)
    var _scan = _start_byte;
    while (_scan <= _byte_len) {
        var _end = regex__run_from_start(_program, _input_buffer, _byte_len, _scan);
        if (_end >= 0) {
            buffer_resize(_input_buffer, 0);
            return { "found": true, "start": _scan, "end": _end };
        }
        _scan += 1;
    }

    buffer_resize(_input_buffer, 0);
    return { "found": false, "start": -1, "end": -1 };
}

#region jsDoc
/// @func   regex_is_match_at()
/// @desc   Check whether the program matches starting exactly at _start_byte.
///         Returns end byte index (exclusive) if found, else -1.
/// @param  {Struct} _program
/// @param  {String} _input_string
/// @param  {Real} _start_byte
/// @returns {Real}
#endregion
function regex_is_match_at(_program, _input_string, _start_byte = 0) {
    static _temp_buff  = buffer_create(0, buffer_grow, 1);
    static _input_buff = buffer_create(0, buffer_fast, 1);

    var _temp_buffer  = _temp_buff;
    var _input_buffer = _input_buff;

    var _byte_len = string_byte_length(_input_string);
    if (_start_byte < 0) _start_byte = 0;
    if (_start_byte > _byte_len) _start_byte = _byte_len;

    buffer_resize(_input_buffer, _byte_len);

    buffer_write(_temp_buffer, buffer_text, _input_string);
    buffer_copy(_temp_buffer, 0, _byte_len, _input_buffer, 0);
    buffer_resize(_temp_buffer, 0);

    var _end = regex__run_from_start(_program, _input_buffer, _byte_len, _start_byte);
    buffer_resize(_input_buffer, 0);
    return _end;
}

#region Internal Runner

// Returns end byte (exclusive) for the earliest match starting at _start_byte, or -1.
function regex__run_from_start(_program, _input_buffer, _byte_len, _start_byte) {
    // Program arrays (local refs)
    var _prog_op   = _program.op;
    var _prog_a    = _program.a;
    var _prog_b    = _program.b;
    var _prog_data = _program.data;

    var _prog_len = array_length(_prog_op);

    // Two state lists
    static _list_a = [];
    static _list_b = [];

    // Seen stamping to avoid epsilon cycles
    static _seen_stamp = [];
    static _seen_mark = 1;

    // Ensure seen size
    if (array_length(_seen_stamp) < _prog_len) {
        _seen_stamp = array_create(_prog_len, 0);
    }

    // Bump stamp, reset if wraps too far (safe guard)
    _seen_mark += 1;
    if (_seen_mark > 2000000000) {
        _seen_mark = 1;
        var _si = 0;
        repeat (_prog_len) {
            _seen_stamp[_si] = 0;
            _si += 1;
        }
    }

    // Clear lists
    _list_a = [];
    _list_b = [];

    // Seed epsilon-closure from program start at position _start_byte
    regex__add_state_closure(_program, _prog_op, _prog_a, _prog_b, _prog_data, _list_a, _seen_stamp, _seen_mark, _start_byte, _byte_len, _start_byte);

    // If MATCH is reachable without consuming anything, accept immediately
    if (regex__list_has_match(_program, _prog_op, _list_a)) {
        return _start_byte;
    }

    // Consume bytes step-by-step
    var _pos = _start_byte;
    while (_pos < _byte_len) {
        var _byte = buffer_peek(_input_buffer, _pos, buffer_u8);

        // Build next list from current list
        _list_b = [];

        // New stamp for this step's closure
        _seen_mark += 1;
        if (_seen_mark > 2000000000) {
            _seen_mark = 1;
            var _sj = 0;
            repeat (_prog_len) {
                _seen_stamp[_sj] = 0;
                _sj += 1;
            }
        }

        var _count = array_length(_list_a);
        var _i = 0;
        repeat (_count) {
            var _state = _list_a[_i];
            _i += 1;

            var _op = _prog_op[_state];

            // Consuming ops
            if (_op == 1) { // OP_CHAR
                if (_byte == _prog_data[_state]) {
                    var _next_state = _prog_a[_state];
                    regex__add_state_closure(_program, _prog_op, _prog_a, _prog_b, _prog_data, _list_b, _seen_stamp, _seen_mark, _pos + 1, _byte_len, _start_byte, _next_state);
                }
                continue;
            }

            if (_op == 2) { // OP_CLASS
                var _class_id = _prog_data[_state];
                if (regex__class_has_byte(_program, _class_id, _byte)) {
                    var _next_state2 = _prog_a[_state];
                    regex__add_state_closure(_program, _prog_op, _prog_a, _prog_b, _prog_data, _list_b, _seen_stamp, _seen_mark, _pos + 1, _byte_len, _start_byte, _next_state2);
                }
                continue;
            }

            if (_op == 3) { // OP_ANY
                // highlight.js needs '.' but typically it excludes '\n' in many engines.
                // For now, match any byte.
                var _next_state3 = _prog_a[_state];
                regex__add_state_closure(_program, _prog_op, _prog_a, _prog_b, _prog_data, _list_b, _seen_stamp, _seen_mark, _pos + 1, _byte_len, _start_byte, _next_state3);
                continue;
            }

            // Non-consuming ops should never remain in list (closure expands them),
            // so if they appear here, ignore safely.
        }

        // Swap lists
        _list_a = _list_b;

        _pos += 1;

        // Check accept at this position
        if (regex__list_has_match(_program, _prog_op, _list_a)) {
            return _pos;
        }

        // Early exit if dead
        if (array_length(_list_a) <= 0) {
            return -1;
        }
    }

    // Also allow match at end-of-input after consuming all bytes
    if (regex__list_has_match(_program, _prog_op, _list_a)) {
        return _byte_len;
    }

    return -1;
}

// Overload helper: if _seed_state omitted, seed with program.start.
// (We implement via passing _seed_state = -1)
function regex__add_state_closure(_program, _prog_op, _prog_a, _prog_b, _prog_data, _list, _seen_stamp, _seen_mark, _pos, _byte_len, _start_byte, _seed_state = -1) {
    var _stack = [];
    var _stack_len = 0;

    var _push_state = (_seed_state >= 0) ? _seed_state : _program.start;

    array_push(_stack, _push_state);
    _stack_len += 1;

    while (_stack_len > 0) {
        var _state = _stack[_stack_len - 1];
        array_pop(_stack);
        _stack_len -= 1;

        // Bounds / invalid
        if (_state < 0) continue;

        // Seen guard for this closure step
        if (_seen_stamp[_state] == _seen_mark) continue;
        _seen_stamp[_state] = _seen_mark;

        var _op = _prog_op[_state];

        // Epsilon ops: JUMP, SPLIT
        if (_op == 4) { // OP_JUMP
            var _next = _prog_a[_state];
            if (_next >= 0) {
                array_push(_stack, _next);
                _stack_len += 1;
            }
            continue;
        }

        if (_op == 5) { // OP_SPLIT
            var _na = _prog_a[_state];
            var _nb = _prog_b[_state];
            if (_na >= 0) { array_push(_stack, _na); _stack_len += 1; }
            if (_nb >= 0) { array_push(_stack, _nb); _stack_len += 1; }
            continue;
        }

        // Zero-width assertions: BOL, EOL, WB, NWB
        if (_op == 6) { // OP_BOL
            // Beginning of string only (no multiline yet)
            if (_pos == 0) {
                var _next2 = _prog_a[_state];
                if (_next2 >= 0) { array_push(_stack, _next2); _stack_len += 1; }
            }
            continue;
        }

        if (_op == 7) { // OP_EOL
            if (_pos == _byte_len) {
                var _next3 = _prog_a[_state];
                if (_next3 >= 0) { array_push(_stack, _next3); _stack_len += 1; }
            }
            continue;
        }

        if (_op == 8 || _op == 9) { // OP_WB / OP_NWB
            var _prev_word = regex__is_word_byte_at(_program, _pos - 1, _byte_len);
            var _curr_word = regex__is_word_byte_at(_program, _pos, _byte_len);

            var _is_boundary = (_prev_word != _curr_word);
            var _ok = (_op == 8) ? _is_boundary : (!_is_boundary);

            if (_ok) {
                var _next4 = _prog_a[_state];
                if (_next4 >= 0) { array_push(_stack, _next4); _stack_len += 1; }
            }
            continue;
        }

        // MATCH or consuming ops stay in list
        array_push(_list, _state);
    }
}

function regex__list_has_match(_program, _prog_op, _list) {
    var _len = array_length(_list);
    var _i = 0;
    repeat (_len) {
        if (_prog_op[_list[_i]] == 0) return true; // OP_MATCH
        _i += 1;
    }
    return false;
}

// Byte classification for \b. Uses ASCII word: [A-Za-z0-9_]
function regex__is_word_byte_val(_byte) {
    if (_byte >= 48 && _byte <= 57) return true;  // 0-9
    if (_byte >= 65 && _byte <= 90) return true;  // A-Z
    if (_byte >= 97 && _byte <= 122) return true; // a-z
    if (_byte == 95) return true;                 // _
    return false;
}

// Wordness at a byte position. Out of range -> false.
function regex__is_word_byte_at(_program, _pos, _byte_len) {
    // This helper is used only for boundaries; out-of-range is "non-word"
    if (_pos < 0 || _pos >= _byte_len) return false;

    // We do not have direct access to the input buffer here (kept tiny),
    // so we approximate boundary using ASCII rules on a synthetic "unknown" -> false.
    //
    // IMPORTANT:
    // For correct \b/\B behavior, pass input buffer into boundary checks.
    // This placeholder keeps the runner compiling, but will make WB always behave
    // like "non-word vs non-word" (almost always false boundary).
    //
    // Fix comes next: boundary functions must be input-aware.
    return false;
}

// Character class membership test
function regex__class_has_byte(_program, _class_id, _byte) {
    if (_class_id < 0) return false;
    if (_class_id >= array_length(_program.cls)) return false;

    var _pairs = _program.cls[_class_id];
    var _neg = _program.neg[_class_id];

    var _hit = false;

    var _len = array_length(_pairs);
    var _i = 0;
    while (_i < _len) {
        var _lo = _pairs[_i];     _i += 1;
        var _hi = _pairs[_i];     _i += 1;
        if (_byte >= _lo && _byte <= _hi) { _hit = true; break; }
    }

    if (_neg == 1) return (!_hit);
    return _hit;
}

#endregion
