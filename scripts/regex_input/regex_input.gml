/// @func regex__input_prepare()
/// @desc Convert string to a byte buffer using buffer_text. Returns { buff, len }.
/// @param {String} _input_string
/// @returns {Struct} { buff: Real, len: Real }
function regex__input_prepare(_input_string) {
    static _temp_buff = buffer_create(0, buffer_grow, 1);
    static _input_buff = buffer_create(0, buffer_fast, 1);

    var _byte_len = string_byte_length(_input_string);
    buffer_resize(_input_buff, _byte_len);

    buffer_write(_temp_buff, buffer_text, _input_string);
    buffer_copy(_temp_buff, 0, _byte_len, _input_buff, 0);
    buffer_resize(_temp_buff, 0);
	
    return { buff: _input_buff, len: _byte_len };
}
