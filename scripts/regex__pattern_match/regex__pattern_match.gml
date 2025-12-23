#region jsDoc
/// @func   regex__pattern_match()
/// @desc   Match only at byte 0.
/// @param  {Struct} _program
/// @param  {String} _input
/// @returns {Struct} { found: Bool, start: Real, end: Real }
#endregion
function regex__pattern_match(_program, _input) {
    static _temp_buff = buffer_create(0, buffer_grow, 1);
    static _input_buff = buffer_create(0, buffer_fast, 1);

    var _byte_len = string_byte_length(_input);
    buffer_resize(_input_buff, _byte_len);

    buffer_write(_temp_buff, buffer_text, _input);
    buffer_copy(_temp_buff, 0, _byte_len, _input_buff, 0);
    buffer_resize(_temp_buff, 0);

    var _end_pos = regex__run_from(_program, _input_buff, _byte_len, 0);

    if (_end_pos >= 0) {
        return { "found": true, "start": 0, "end": _end_pos };
    }

    return { "found": false, "start": -1, "end": -1 };
}