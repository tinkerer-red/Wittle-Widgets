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
	
	#region Find the original parent struct
		
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
		
		_parent_struct_name = _str;
		
	#endregion
	
	var _parent_methodID = asset_get_index(_parent_struct_name);
	var _parent_statics = static_get(_parent_methodID)
	var _parent_struct_name = instanceof(_parent_statics)
	
	#region Find all parent structs
		
		while (_parent_struct_name != "Object") {
			
			var _parent_methodID = asset_get_index(_parent_struct_name);
			var _parent_statics = static_get(_parent_methodID)
			
			
			
			var _key, _val;
			var _names = variable_struct_get_names(_parent_statics);
			var _size = array_length(_names);
			var _i=0; repeat(_size) {
				_key = _names[_i]
				
				//skip internal keys and already included keys
				if (_key == "<unknown built-in variable>")
				|| (variable_struct_exists(self, _key)) {
					_i+=1;
					continue;
				}
				
				_val = _parent_statics[$ _key]
				
				self[$ _key] = method({func: _val}, function(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15) {
					return method(global.__super_self__, func)(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15)
				})
				
			_i+=1;}//end repeat loop
			
			
			//continue to the next struct
			var _parent_struct_name = instanceof(_parent_statics)
		}
		
	#endregion
	
}
