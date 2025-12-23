/// @func regex__is_word_byte()
/// @desc ASCII word test used by \b and \B. Word is [A-Za-z0-9_].
/// @param {Real} _byte
/// @returns {Bool}
function regex__is_word_byte(_byte) {
    if (_byte < 0) return false;

    // 0-9
    if (_byte >= 48 && _byte <= 57) return true;

    // A-Z
    if (_byte >= 65 && _byte <= 90) return true;

    // a-z
    if (_byte >= 97 && _byte <= 122) return true;

    // underscore
    if (_byte == 95) return true;

    return false;
}