function log(_str) { log_func
	show_debug_message(_str);
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

/*
function A() constructor {
	static print_name = function() {
		show_debug_message("A")
	}
}

function B() : A() constructor {
	static print_name = function() {
		__SUPER__.print_name()
		show_debug_message("B")
	}
}

function C() : B() constructor {
	static print_name = function() {
		__SUPER__.print_name()
		show_debug_message("C")
	}
}

function D() : C() constructor {
	static print_name = function() {
		__SUPER__.print_name()
		show_debug_message("D")
	}
}

function E() : D() constructor {
	static print_name = function() {
		__SUPER__.print_name()
		show_debug_message("E")
	}
}
