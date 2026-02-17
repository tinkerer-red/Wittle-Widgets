#region jsDoc
/// @func    struct_get_chained(_struct, key1)
/// @desc    Safely retrieves a nested value from a struct by following a chain of keys.
///          The key chain is provided as repeated arguments (not an array).
///          Returns undefined if any key in the chain is missing.
/// @param   {Struct} struct : The struct to traverse.
/// @param   {String} key1   : The first key to follow. Additional keys can be provided as more arguments.
/// @returns {Any} The value at the end of the chain, or undefined if not found.
#endregion
function struct_get_chained(_struct) {
	var _current = _struct;
	for(var i = 1; i < argument_count; i++) {
        if (_current == undefined) return undefined;
        _current = _current[$ argument[i]];
    }
    return _current;
}

#region jsDoc
/// @func    struct_get_ext(_struct, array_of_keys)
/// @desc    Safely retrieves a nested value from a struct by following a chain of keys.
///          Returns undefined if any key in the chain is missing.
/// @param   {Struct} struct : The struct to traverse.
/// @param   {Array.String} keys : The array of keys to follow, in order.
/// @returns {Any} The value at the end of the chain, or undefined if not found.
#endregion
function struct_get_ext(_struct, _keys) {
	var _current = _struct;
	var _length = array_length(_keys);
	for(var i = 0; i < _length; i++) {
        if (_current == undefined) return undefined;
        _current = _current[$ _keys[i]];
    }
    return _current;
}