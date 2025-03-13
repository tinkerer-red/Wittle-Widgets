function log(_message, _depth=-1) {
	static __depth = 0;
				
	if (_depth >= 0) {
		__depth = _depth;
	}
	else {
		_depth = __depth;
	}
				
	var _indent = (_depth > 1) ? string_repeat("│   ", _depth-1) : "";
	if (_depth) _indent += "├── ";
	show_debug_message(_indent + string(_message));
	return;
}

#macro log_func static __run_once__ = show_debug_message([_GMFUNCTION_, asset_get_index(_GMFUNCTION_)])

//define
#region jsDoc
/// @func    trace()
/// @desc    Define
///          continue...
/// @self    constructor_name
/// @param   {type} name : desc
/// @returns {type}
#endregion
#macro trace  __trace(_GMFILE_+" / "+_GMFUNCTION_+" : "+string(_GMLINE_)+" :")
function __trace(_location) {
	static __struct = {};
	__struct.__location = _location;
	return method(__struct, function(_str) {
		show_debug_message(__location + ": " + string(_str));
	});
}

