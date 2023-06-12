function log(_str) {
	show_debug_message(_str);
}

function log_func() {
	
	#region grab the callstack
		var _str
		var _callback = debug_get_callstack(2)[1];
		var _pos = string_pos(":", _callback);
		if (_pos != 0) {
			_str = string_copy(_callback, 1, _pos-1);
		}
		else {
			//support for when the compiled code doesnt return the line number ":40" on the suffix
			_str = _callback;
		}
	#endregion
	
	//the anon name of the function usually something similar to `function gml_Script_anon_GUICompRegion_gml_GlobalScript_GUICompRegion_11017_GUICompRegion_gml_GlobalScript_GUICompRegion`
	var _func_name = _str;
	
	#region find the owner struct
		//it may already be the owner struct, but it could be a function inside the struct's function
		
		//if it's a function
		static _anon_func_str_header = "gml_Script_anon_"
		_pos = string_pos(_anon_func_str_header, _str)
		
		//anon function declaired inside a constructor
		if (_pos == 1) {
		  static _anon_func_str_tail = "_gml_GlobalScript_";
		  static _anon_func_header_end = string_length(_anon_func_str_header)+1;
		  var _tail_pos = string_pos(_anon_func_str_tail, _str);
		  _str = string_copy(_str, _anon_func_header_end, _tail_pos-_anon_func_header_end);
		}
		else {
			//calling from constructor it's self
			static _constructor_func_str_header = "gml_Script_"
			_pos = string_pos(_constructor_func_str_header, _str)
			if (_pos == 1) {
				static _constructor_header_end = string_length(_constructor_func_str_header);
		    _str = string_delete(_str, 1, _constructor_header_end);
			}
		}
		
		//there are probably a lot more i could add but they are either really bad practice or not currently possible
		
	#endregion
	
	var _methodID = asset_get_index(_str);
	var _parent_statics = static_get(_methodID)
	
	var _names = variable_struct_get_names(_parent_statics);
	
	var _key, _val, _struct_func_name;
	var _size = array_length(_names);
	var _i=0; repeat(_size) {
		_key = _names[_i]
		
		if (_key == "<unknown built-in variable>")
		|| (is_undefined(_parent_statics[$ _key])) {
			_i+=1;
			continue;
		}
		
		_struct_func_name = script_get_name(_parent_statics[$ _key])
		
		if (_struct_func_name == _func_name) {
			show_debug_message([_key, _func_name, _methodID])
		}
		
	_i+=1;}//end repeat loop
	
}
debug_event()

//define
#region jsDoc
/// @func    trace()
/// @desc    Define
///          continue...
/// @self    constructor_name
/// @param   {type} name : desc
/// @returns {type}
#endregion
#macro trace  __trace(_GMFILE_+"/"+_GMFUNCTION_+":"+string(_GMLINE_)+": ")
function __trace(_location) {
        static __struct = {};
        __struct.__location = _location;
        return method(__struct, function(_str)
    {
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
