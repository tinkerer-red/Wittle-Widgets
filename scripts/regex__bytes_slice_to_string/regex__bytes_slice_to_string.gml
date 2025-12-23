/// @func regex__buffer_read_text_range()
/// @desc Byte-safe slice extraction using temp buffer copy.
/// @param {Real} _buff
/// @param {Real} _start
/// @param {Real} _endd
/// @returns {String}
function regex__buffer_read_text_range(_buff, _start, _endd) {
    static _slice_buff = buffer_create(0, buffer_grow, 1);

    var _size = _endd - _start;
    if (_size <= 0) return "";

    buffer_resize(_slice_buff, _size);
    buffer_copy(_buff, _start, _size, _slice_buff, 0);

    buffer_seek(_slice_buff, buffer_seek_start, 0);
    var _text = buffer_read(_slice_buff, buffer_text);

    buffer_resize(_slice_buff, 0);
    return _text;
}

