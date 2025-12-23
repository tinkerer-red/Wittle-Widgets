#region jsDoc
/// @func   RegexIterator()
/// @desc   Simple iterator for regex matches.
///         Call next() repeatedly until found==false.
/// @param  {Struct} _program
/// @param  {String} _input
/// @param  {Real} _start_byte
/// @returns {Struct} iterator
#endregion
function RegexIterator(_program, _input, _start_byte) constructor {
    static _temp_buff = buffer_create(0, buffer_grow, 1);

    program = _program;

    input_buff = buffer_create(0, buffer_fast, 1);
    input_len = string_byte_length(_input);

    if (_start_byte < 0) _start_byte = 0;
    if (_start_byte > input_len) _start_byte = input_len;

    scan_pos = _start_byte;

    buffer_resize(input_buff, input_len);
    buffer_write(_temp_buff, buffer_text, _input);
    buffer_copy(_temp_buff, 0, input_len, input_buff, 0);
    buffer_resize(_temp_buff, 0);

    #region jsDoc
    /// @func   next()
    /// @desc   Get next match.
    /// @returns {Struct} { found: Bool, start: Real, end: Real }
    #endregion
    static next = function() {
        while (scan_pos <= input_len) {
            var _end_pos = regex__run_from(program, input_buff, input_len, scan_pos);
            if (_end_pos < 0) {
                scan_pos += 1;
                continue;
            }

            var _match_len = _end_pos - scan_pos;
            if (_match_len <= 0) {
                scan_pos += 1;
                continue;
            }

            var _start_pos = scan_pos;
            scan_pos = _end_pos;
            return { "found": true, "start": _start_pos, "end": _end_pos };
        }

        return { "found": false, "start": -1, "end": -1 };
    };

    #region jsDoc
    /// @func   destroy()
    /// @desc   Free owned buffer.
    #endregion
    static destroy = function() {
        if (input_buff != -1) {
            buffer_delete(input_buff);
            input_buff = -1;
        }
    };
}