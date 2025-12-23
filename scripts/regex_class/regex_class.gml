/// @func regex__class_matches()
/// @desc Test class id against a byte. Uses program.cls pairs and program.neg flag.
/// @param {Struct} _program
/// @param {Real} _class_id
/// @param {Real} _byte
/// @returns {Bool}
function regex__class_matches(_program, _class_id, _byte) {
    var _pairs = _program.cls[_class_id];
    var _negate = _program.neg[_class_id];

    var _hit = false;

    var _pair_len = array_length(_pairs);
    var _pair_pos = 0;
    while (_pair_pos < _pair_len) {
        var _start = _pairs[_pair_pos];
        var _endd = _pairs[_pair_pos + 1];

        if (_byte >= _start && _byte <= _endd) { _hit = true; break; }
        _pair_pos += 2;
    }

    if (_negate) return !_hit;
    return _hit;
}