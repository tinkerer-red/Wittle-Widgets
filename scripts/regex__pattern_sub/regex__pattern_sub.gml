#region jsDoc
/// @func   regex__pattern_sub()
/// @desc   Replace all matches with replacement string.
/// @param  {Struct} _program
/// @param  {String} _input
/// @param  {String} _replacement
/// @param  {Real} _start_byte
/// @returns {String}
#endregion
function regex__pattern_sub(_program, _input, _replacement, _start_byte) {
    static _temp_buff = buffer_create(0, buffer_grow, 1);
    static _input_buff = buffer_create(0, buffer_fast, 1);
    static _output_buff = buffer_create(0, buffer_grow, 1);

    var _byte_len = string_byte_length(_input);
    if (_start_byte < 0) _start_byte = 0;
    if (_start_byte > _byte_len) _start_byte = _byte_len;

    buffer_resize(_input_buff, _byte_len);
    buffer_resize(_output_buff, 0);

    buffer_write(_temp_buff, buffer_text, _input);
    buffer_copy(_temp_buff, 0, _byte_len, _input_buff, 0);
    buffer_resize(_temp_buff, 0);

    var _scan_pos = _start_byte;
    var _copy_pos = 0;

    while (_scan_pos <= _byte_len) {
        var _end_pos = regex__run_from(_program, _input_buff, _byte_len, _scan_pos);
        if (_end_pos < 0) {
            _scan_pos += 1;
            continue;
        }

        var _match_len = _end_pos - _scan_pos;
        if (_match_len <= 0) {
            // Safety: avoid infinite loops on zero-length matches
            _scan_pos += 1;
            continue;
        }

        // Copy bytes between last copy and this match start
        var _gap_len = _scan_pos - _copy_pos;
        if (_gap_len > 0) {
            buffer_copy(_input_buff, _copy_pos, _gap_len, _output_buff, buffer_tell(_output_buff));
            buffer_seek(_output_buff, buffer_seek_relative, _gap_len);
        }

        // Write replacement
        buffer_write(_output_buff, buffer_text, _replacement);

        // Advance
        _copy_pos = _end_pos;
        _scan_pos = _end_pos;
    }

    // Copy tail
    var _tail_len = _byte_len - _copy_pos;
    if (_tail_len > 0) {
        buffer_copy(_input_buff, _copy_pos, _tail_len, _output_buff, buffer_tell(_output_buff));
        buffer_seek(_output_buff, buffer_seek_relative, _tail_len);
    }

    buffer_seek(_output_buff, buffer_seek_start, 0);
    var _result = buffer_read(_output_buff, buffer_text);

    buffer_resize(_input_buff, 0);
    buffer_resize(_output_buff, 0);

    return _result;
}