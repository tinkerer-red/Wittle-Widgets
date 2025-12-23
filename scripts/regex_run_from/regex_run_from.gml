/// @func regex__run_from()
/// @desc Run NFA from exact start position. Returns end position or -1.
///       This variant is greedy-aware: it records the best (furthest) MATCH
///       position seen and continues until the state list dies.
/// @param {Struct} _program
/// @param {Real}   _buff
/// @param {Real}   _len
/// @param {Real}   _start_pos
/// @returns {Real} end position or -1
function regex__run_from(_program, _buff, _len, _start_pos) {
    var _list_curr = [];
    var _list_next = [];

    var _prog_len = array_length(_program.op);

    var _mark_curr = array_create(_prog_len, 0);
    var _mark_next = array_create(_prog_len, 0);

    var _mark_id_curr = 1;
    var _mark_id_next = 1;

    var _best_end = -1;

    regex__addstate(_program, _list_curr, _program.start, _start_pos, _len, _buff, _mark_curr, _mark_id_curr);

    // If MATCH is reachable via epsilon at the start, record it (empty match).
    var _curr_count0 = array_length(_list_curr);
    var _curr_index0 = 0;
    repeat (_curr_count0) {
        var _state0 = _list_curr[_curr_index0];
        if (_program.op[_state0] == 0) _best_end = _start_pos; // OP_MATCH
        _curr_index0 += 1;
    }

    var _pos = _start_pos;

    while (_pos < _len) {
        var _byte = buffer_peek(_buff, _pos, buffer_u8);

        _list_next = [];

        _mark_id_next += 1;
        if (_mark_id_next > 2147483000) {
            _mark_next = array_create(_prog_len, 0);
            _mark_id_next = 1;
        }

        var _curr_count = array_length(_list_curr);
        var _curr_index = 0;
        repeat (_curr_count) {
            var _state = _list_curr[_curr_index];
            _curr_index += 1;

            var _op_code = _program.op[_state];

            // OP_CHAR = 1
            if (_op_code == 1) {
                if (_byte == _program.data[_state]) {
                    regex__addstate(_program, _list_next, _program.a[_state], _pos + 1, _len, _buff, _mark_next, _mark_id_next);
                }
                continue;
            }

            // OP_CLASS = 2
            if (_op_code == 2) {
                var _class_id = _program.data[_state];
                if (regex__class_matches(_program, _class_id, _byte)) {
                    regex__addstate(_program, _list_next, _program.a[_state], _pos + 1, _len, _buff, _mark_next, _mark_id_next);
                }
                continue;
            }

            // OP_ANY = 3
            if (_op_code == 3) {
                regex__addstate(_program, _list_next, _program.a[_state], _pos + 1, _len, _buff, _mark_next, _mark_id_next);
                continue;
            }

            // OP_MATCH = 0 should not appear in the consuming loop for correct Thompson lists,
            // but if it does, record it and keep going (do NOT return early).
            if (_op_code == 0) {
                if (_pos > _best_end) _best_end = _pos;
                continue;
            }
        }

        _pos += 1;

        _list_curr = _list_next;
        _mark_curr = _mark_next;
        _mark_id_curr = _mark_id_next;

        var _curr_countm = array_length(_list_curr);
        if (_curr_countm == 0) break;

        // After consuming a byte, if MATCH is reachable now, record this end position.
        var _curr_indexm = 0;
        repeat (_curr_countm) {
            var _statem = _list_curr[_curr_indexm];
            if (_program.op[_statem] == 0) {
                if (_pos > _best_end) _best_end = _pos;
            }
            _curr_indexm += 1;
        }
    }

    // Also allow a final epsilon-reachable MATCH after the loop ends (already covered by scan),
    // but keep this for clarity in case loop ended due to _pos == _len.
    if (_best_end >= 0) return _best_end;

    return -1;
}
