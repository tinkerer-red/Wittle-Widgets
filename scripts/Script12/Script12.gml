/*
	Note:
	This code was created by TabularElf (https://tabelf.link/) for non-commercial and commercial purposes.
	While this snippet of code is free to use for both non-commercial and commercial purposes,
	I would really appreciate it if you could include credits to me along with my links site in any given release!
	Thank you!
	
	The purpose of this script is to allow you to inherit overriden static methods. In the event that the static method does not 
	exist, a dummy method will be used in it's place to prevent GameMaker from outright crashing.
	This may change in the future to alert users of potential issues.
	To use it: Just add this gist to a script, and call struct_inherited() in any static methods you wish to override.
	You may pass any arguments as required in order for your static method to work correctly. struct_inherited(_arg1, _arg2, ...)
	Proven to be working as of IDE v2023.100.0.259  Runtime v2023.100.0.273
*/
#macro struct_inherited static __inherited = __struct_inherited(); __inherited

/// @ignore
function __struct_inherited() {
	static _dummy = function() {};
	var _value, _callback, _i, _keys, _pos, _str, _methodID, _statics, _func, _scope;
	_callback = debug_get_callstack(2)[1]; 
	_pos = string_pos(":", _callback); 
	_str = string_copy(_callback, 1, _pos-1);
	_methodID = asset_get_index(_str);
	// Feather disable once GM1041
	_statics = static_get(self); 
	if (_statics != undefined) {
		_i = 0;
		// Feather disable once GM1041
		_keys = variable_struct_get_names(self);
		repeat(array_length(_keys)) {
			_value = self[$ _keys[_i]];
			if (is_method(_value)) {
				if (method_get_index(_value) == _methodID) {
					while (_statics != undefined) {
					    if (variable_struct_exists(_statics, _keys[_i])) {
							return _statics[$ _keys[_i]];	
						}
					   _statics = static_get(_statics);
					}
				} 
			}
			_i+=1;
		}
		
		while (_statics != undefined) {
			_i = 0;
			_keys = variable_struct_get_names(_statics);
			repeat(array_length(_keys)) {
				_value = _statics[$ _keys[_i]];
				if (is_method(_value)) {
					if (method_get_index(_value) == _methodID) {
						_statics = static_get(_statics);
						_func = _statics[$ _keys[_i]];
						return (_func != undefined) ? _func : _dummy;
					}
				}
				_i+=1;
			}
			_statics = static_get(_statics);
		}
	}
	return _dummy;
}