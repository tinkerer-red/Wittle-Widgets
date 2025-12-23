#region jsDoc
/// @func   regex__pattern_findall()
/// @desc   Return array of match strings (non-capturing).
/// @param  {Struct} _program
/// @param  {String} _input
/// @param  {Real} _start_byte
/// @returns {Array<String>}
#endregion
function regex__pattern_findall(_program, _input, _start_byte) {
    static _temp_buff = buffer_create(0, buffer_grow, 1);
    static _input_buff = buffer_create(0, buffer_fast, 1);
    static _slice_buff = buffer_create(0, buffer_grow, 1);

    var _byte_len = string_byte_length(_input);
    if (_start_byte < 0) _start_byte = 0;
    if (_start_byte > _byte_len) _start_byte = _byte_len;

    buffer_resize(_input_buff, _byte_len);

    buffer_write(_temp_buff, buffer_text, _input);
    buffer_copy(_temp_buff, 0, _byte_len, _input_buff, 0);
    buffer_resize(_temp_buff, 0);

    var _results = [];
    var _pos = _start_byte;

    while (_pos <= _byte_len) {
        var _end_pos = regex__run_from(_program, _input_buff, _byte_len, _pos);
        if (_end_pos < 0) {
            _pos += 1;
            continue;
        }

        var _match_len = _end_pos - _pos;
        if (_match_len <= 0) {
            // Safety: never get stuck on zero-length matches
            _pos += 1;
            continue;
        }

        buffer_resize(_slice_buff, _match_len);
        buffer_copy(_input_buff, _pos, _match_len, _slice_buff, 0);
        buffer_seek(_slice_buff, buffer_seek_start, 0);

        var _match_str = buffer_read(_slice_buff, buffer_text);
        array_push(_results, _match_str);

        // Critical: advance by the end of the match (prevents overlapping explosions)
        _pos = _end_pos;
    }

    buffer_resize(_input_buff, 0);
    buffer_resize(_slice_buff, 0);

    return _results;
}