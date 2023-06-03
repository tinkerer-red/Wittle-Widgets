//explanation:

// This line builds a struct which contains methods storing the function index of the parent statics
//		static __super__ = new __super();

// Because we want to avoid string manipulation every frame, we want to make that struct static
// Because that struct is static we need some way of refering to the object which should be running the method.
// So this line is used as essentially a "other.other.other" 
//		global.__super_self__ = self;

// Last we leave it with this line so it makes it easier to read in the sense of doing `__SUPER__.get_value()`
//		__super__

#macro __SUPER__ static __super__ = new __super(); global.__super_self__ = self; __super__
function __super(_super) constructor {
	
	#region grab the callstack
		var _str;
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
	
	#region find the owner struct
		//it may already be the owner struct, but it could be a function inside the struct's function
		
		//if it's a function
		static _anon_func_str_header = "gml_Script_anon_"
		var _pos = string_pos(_anon_func_str_header, _str)
		
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
	var _parent_statics = static_get(static_get(_methodID))
	
	var _key, _val;
	var _names = variable_struct_get_names(_parent_statics);
	var _size = array_length(_names);
	var _i=0; repeat(_size) {
		_key = _names[_i]
		
		if (_key == "<unknown built-in variable>") {
			_i+=1;
			continue;
		}
		
		_val = _parent_statics[$ _key]
		
		//scope the function to the calling instance using a wrapper method which runs the function on the last assigned __super_self__
		self[$ _key] = method({func: _val}, function() {
			switch(argument_count) {
				case  0: return method(global.__super_self__, func)(); break;
				case  1: return method(global.__super_self__, func)(argument[0]); break;
				case  2: return method(global.__super_self__, func)(argument[0], argument[1]); break;
				case  3: return method(global.__super_self__, func)(argument[0], argument[1], argument[2]); break;
				case  4: return method(global.__super_self__, func)(argument[0], argument[1], argument[2], argument[3]); break;
				case  5: return method(global.__super_self__, func)(argument[0], argument[1], argument[2], argument[3], argument[4]); break;
				case  6: return method(global.__super_self__, func)(argument[0], argument[1], argument[2], argument[3], argument[4], argument[5]); break;
				case  7: return method(global.__super_self__, func)(argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], argument[6]); break;
				case  8: return method(global.__super_self__, func)(argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], argument[6], argument[7]); break;
				case  9: return method(global.__super_self__, func)(argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], argument[6], argument[7], argument[8]); break;
				case 10: return method(global.__super_self__, func)(argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], argument[6], argument[7], argument[8], argument[9]); break;
				case 11: return method(global.__super_self__, func)(argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], argument[6], argument[7], argument[8], argument[9], argument[10]); break;
				case 12: return method(global.__super_self__, func)(argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], argument[6], argument[7], argument[8], argument[9], argument[10], argument[11]); break;
				case 13: return method(global.__super_self__, func)(argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], argument[6], argument[7], argument[8], argument[9], argument[10], argument[11], argument[12]); break;
				case 14: return method(global.__super_self__, func)(argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], argument[6], argument[7], argument[8], argument[9], argument[10], argument[11], argument[12], argument[13]); break;
				case 15: return method(global.__super_self__, func)(argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], argument[6], argument[7], argument[8], argument[9], argument[10], argument[11], argument[12], argument[13], argument[14]); break;
				case 16: return method(global.__super_self__, func)(argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], argument[6], argument[7], argument[8], argument[9], argument[10], argument[11], argument[12], argument[13], argument[14], argument[15]); break;
			}
		})
		
	_i+=1;}//end repeat loop
}
