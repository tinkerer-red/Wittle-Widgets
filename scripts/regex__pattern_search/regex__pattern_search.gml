#region jsDoc
/// @func   regex__pattern_search()
/// @desc   Find first match anywhere starting from _start_byte.
/// @param  {Struct} _program
/// @param  {String} _input
/// @param  {Real} _start_byte
/// @returns {Struct} { found: Bool, start: Real, end: Real }
#endregion
function regex__pattern_search(_program, _input, _start_byte) {
    static _temp_buff = buffer_create(0, buffer_grow, 1);
    static _input_buff = buffer_create(0, buffer_fast, 1);

    var _byte_len = string_byte_length(_input);
    if (_start_byte < 0) _start_byte = 0;
    if (_start_byte > _byte_len) _start_byte = _byte_len;

    buffer_resize(_input_buff, _byte_len);

    buffer_write(_temp_buff, buffer_text, _input);
    buffer_copy(_temp_buff, 0, _byte_len, _input_buff, 0);
    buffer_resize(_temp_buff, 0);

    var _pos = _start_byte;

    while (_pos <= _byte_len) {
        var _end_pos = regex__run_from(_program, _input_buff, _byte_len, _pos);
        if (_end_pos >= 0) {
            return { "found": true, "start": _pos, "end": _end_pos };
        }
        _pos += 1;
    }

    return { "found": false, "start": -1, "end": -1 };
}