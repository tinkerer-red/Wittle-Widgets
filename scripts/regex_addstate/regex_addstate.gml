/// @func regex__addstate()
/// @desc Add state with epsilon-closure into list, using mark array to avoid duplicates.
///       Pushes consuming states and MATCH into _list_arr.
/// @param {Struct} _program
/// @param {Array}  _list_arr
/// @param {Real}   _state
/// @param {Real}   _pos
/// @param {Real}   _len
/// @param {Real}   _buff
/// @param {Array}  _mark_arr
/// @param {Real}   _mark_id
/// @returns {Undefined}
function regex__addstate(_program, _list_arr, _state, _pos, _len, _buff, _mark_arr, _mark_id) {
    var _stack = [];
    array_push(_stack, _state);

    while (array_length(_stack) > 0) {
        var _curr = _stack[array_length(_stack) - 1];
        array_pop(_stack);

        if (_curr < 0) continue;

        if (_mark_arr[_curr] == _mark_id) continue;
        _mark_arr[_curr] = _mark_id;

        var _op = _program.op[_curr];

        // OP_JUMP = 4
        if (_op == 4) {
            array_push(_stack, _program.a[_curr]);
            continue;
        }

        // OP_SPLIT = 5
        if (_op == 5) {
            array_push(_stack, _program.a[_curr]);
            array_push(_stack, _program.b[_curr]);
            continue;
        }

        // OP_BOL = 6
        if (_op == 6) {
            if (_pos == 0) array_push(_stack, _program.a[_curr]);
            continue;
        }

        // OP_EOL = 7
        if (_op == 7) {
            if (_pos == _len) array_push(_stack, _program.a[_curr]);
            continue;
        }

        // OP_WB = 8, OP_NWB = 9
        if (_op == 8 || _op == 9) {
            var _prev_word = false;
            if (_pos > 0) {
                var _prev_byte = buffer_peek(_buff, _pos - 1, buffer_u8);
                _prev_word = regex__is_word_byte(_prev_byte);
            }

            var _curr_word = false;
            if (_pos < _len) {
                var _curr_byte = buffer_peek(_buff, _pos, buffer_u8);
                _curr_word = regex__is_word_byte(_curr_byte);
            }

            var _is_boundary = (_prev_word != _curr_word);

            if (_op == 8) {
                if (_is_boundary) array_push(_stack, _program.a[_curr]);
            } else {
                if (!_is_boundary) array_push(_stack, _program.a[_curr]);
            }
            continue;
        }

        // Consuming or match states get queued
        array_push(_list_arr, _curr);
    }
}