#region jsDoc
/// @func	WWTextBuffer()
/// @desc	Text storage component backed by a GML buffer. Stores the canonical
///		  text as both a buffer_string and a cached string. Provides simple
///		  editing and query operations using 0-based indices and [start,end)
///		  semantics. Does not know about layout, cursors, or rendering.
/// @returns {Struct.WWTextBuffer}
#endregion
function WWTextBuffer() constructor {
	debug_name = "WWTextBuffer";
	
	#region Public
	
		#region Builder Functions
		
			#region jsDoc
			/// @func	set_text()
			/// @desc	Replace the entire text stored in the buffer.
			/// @param   {String} _text : New text to store.
			/// @returns {Struct.WWTextBuffer}
			#endregion
			static set_text = function(_text) {
				_text = __filter_allowed__(_text);
				__set_text__(_text);
				return self;
			};
			
			#region jsDoc
			/// @func	set_allowed_char()
			/// @desc	Set the allowed character map. Any future set/insert will be
			///		  filtered to only include characters present in the map.
			///		  Accepts either:
			///		  - A string of allowed characters, or
			///		  - A struct where each key is a character.
			/// @param   {Struct} _allowed : Struct defining allowed characters.
			/// @returns {Struct.WWTextBuffer}
			#endregion
			static set_allowed_char = function(_allowed) {
				__allowed_char_map__ = variable_clone(_allowed);
				
				// Re-filter existing __content__ to obey new allowed set.
				var _text = get_text();
				if (_text != "") {
					var _filtered = __filter_allowed__(_text);
					if (_filtered != _text) {
						clear_text();
						__set_text__(_filtered);
					}
				}
				
				return self;
			};
	
		#endregion
		
		#region Events
			
			
		#endregion
		
		#region Functions
			
			#region jsDoc
			/// @func	destroy()
			/// @desc	Delete the underlying buffer. Do not use this instance after.
			/// @returns {Struct.WWTextBuffer}
			#endregion
			static destroy = function() {
				if (buffer_exists(__buffer__)) {
					buffer_delete(__buffer__);
				}
				if (buffer_exists(__temp_buffer__)) {
					buffer_delete(__temp_buffer__);
				}
				__buffer__ = -1;
				__content__ = "";
				__length__ = 0;
				__allowed_char_map__ = undefined;
				return self;
			};
			
			#region jsDoc
			/// @func	get_text()
			/// @desc	Get the entire text stored in the buffer.
			/// @returns {String}
			#endregion
			static get_text = function() {
				if (__is_dirty__) {
					if (buffer_exists(__buffer__)) {
						buffer_seek(__buffer__, buffer_seek_start, 0);
						var _text = buffer_read(__buffer__, buffer_text);
						__content__  = _text;
						__length__   = string_length(_text);
					} else {
						__content__  = "";
						__length__   = 0;
					}
					__is_dirty__ = false;
				}
				return __content__;
			};
			
			#region jsDoc
			/// @func	clear_text()
			/// @desc	Clear the buffer to an empty string.
			/// @returns {Struct.WWTextBuffer}
			#endregion
			static clear_text = function() {
				if (buffer_exists(__buffer__)) {
					buffer_resize(__buffer__, 0);
					buffer_resize(__buffer__, 65536);
					buffer_seek(__buffer__, buffer_seek_start, 0);
				}
	
				__content__   = "";
				__length__	= 0;
				__is_dirty__  = false;
	
				return self;
			};
			
			#region jsDoc
			/// @func	get_size()
			/// @desc	Get the number of characters stored in the buffer.
			///		  (Used by select_all in WWTextBoxV3.)
			/// @returns {Real}
			#endregion
			static get_size = function() {
				if (__is_dirty__) {
					if (buffer_exists(__buffer__)) {
						buffer_seek(__buffer__, buffer_seek_start, 0);
						var _text = buffer_read(__buffer__, buffer_text);
						__content__  = _text;
						__length__   = string_length(_text);
					} else {
						__content__  = "";
						__length__   = 0;
					}
					__is_dirty__ = false;
				}
				return __length__;
			};
			
			#region jsDoc
			/// @func	get_substring()
			/// @desc	Get a substring using 0-based indices and [start,end) range.
			/// @param   {Real} _start_index : Inclusive start index (0-based).
			/// @param   {Real} _end_index   : Exclusive end index (0-based).
			/// @returns {String}
			#endregion
			static get_substring = function(_start_index, _end_index) {
				var _start_clamp = clamp(_start_index, 0, get_size());
				var _end_clamp   = clamp(_end_index, 0, get_size());
		
				if (_end_clamp < _start_clamp) {
					var _swap_temp = _start_clamp;
					_start_clamp   = _end_clamp;
					_end_clamp	 = _swap_temp;
				}
		
				var _count = _end_clamp - _start_clamp;
				if (_count <= 0) {
					return "";
				}
		
				// GameMaker strings are 1-based.
				var _gm_start = _start_clamp + 1;
				return string_copy(get_text(), _gm_start, _count);
			};
			
			#region jsDoc
			/// @func	insert()
			/// @desc	Insert text at the given 0-based index. Existing text at and
			///		  after that index is shifted to the right.
			/// @param   {Real} _index  : Insertion index (0-based).
			/// @param   {String} _text : Text to insert.
			/// @returns {Struct.WWTextBuffer}
			#endregion
			static insert = function(_index, _text) {
				//early out
				if (_text == "") { return self; }
				_text = __filter_allowed__(_text);
				if (_text == "") { return self; }
				
				// Ensure backing buffers exist
				if (!buffer_exists(__buffer__)) {
					__buffer__ = buffer_create(65536, buffer_grow, 1);
				}
				if (!buffer_exists(__temp_buffer__)) {
					__temp_buffer__ = buffer_create(65536, buffer_grow, 1);
				}
				
				var _insert_byte_length = string_byte_length(_text);
				
				// Clamp index to [0, get_size()]
				var _current_text = get_text();
				var _pre_str = string_copy(_text, 0, _index);
				var _byte_index = string_byte_length(_pre_str);
				
				var _current_byte_length = string_byte_length(_current_text);
				
				// Number of bytes from the right side to preserve:
				// everything from [_byte_index, _byte_index)
				var _right_bytes = _current_byte_length - _byte_index;
				
				// Copy right side out of the main buffer into the temp buffer
				if (_right_bytes > 0) {
					buffer_copy(__buffer__, _byte_index, _right_bytes, __temp_buffer__, 0);
				}
				
				// Write the new text into the main buffer at _byte_index
				buffer_seek(__buffer__, buffer_seek_start, _byte_index);
				buffer_write(__buffer__, buffer_text, _text);
				
				// Copy the preserved right side back into the main buffer after the insert
				if (_right_bytes > 0) {
					var _dest_offset = _byte_index + _insert_byte_length;
					buffer_copy(__temp_buffer__, 0, _right_bytes, __buffer__, _dest_offset);
				}
	
				__is_dirty__ = true;
				
				return self;
			};
			
		#endregion
		
	
	#endregion
	
	#region Private
		
		#region Variables
			
			// Underlying GML buffer. Always contains the full string written as
			// buffer_string starting at offset 0.
			__buffer__ = buffer_create(65536, buffer_grow, 1);
			__temp_buffer__ = buffer_create(65536, buffer_grow, 1);
			
			// Cached string __content__ (your textbox currently reads this directly).
			__content__ = "";
			
			// Cached character length.
			__length__ = 0;
			
			// Optional allowed character map: struct where each key is a character.
			// If undefined, no filtering is applied.
			__allowed_char_map__ = undefined;
			
			// Denote if __content__ needs to be updated on next call to `.get_text()`
			__is_dirty__ = true;
			
			__textbox_parent__ = undefined;
			
		#endregion
		
		#region Functions
			
			static __set_text__ = function(_text) {
				if (!buffer_exists(__buffer__)) {
					__buffer__ = buffer_create(0, buffer_grow, 1);
				}
				
				buffer_resize(__buffer__, 0);
				buffer_resize(__buffer__, 65536);
				buffer_seek(__buffer__, buffer_seek_start, 0);
				buffer_write(__buffer__, buffer_text, _text);
				
				__content__ = _text;
				__length__  = string_length(_text);
			};
			
			static __filter_allowed__ = function(_text) {
				if (is_undefined(__allowed_char_map__)) {
					return _text;
				}
				
				static __args = {
					buff : buffer_create(1, buffer_grow, 1),
				}
				__args.__allowed_char__ = __allowed_char__;
				
				buffer_resize(__args.buff, string_byte_length(_text));
				buffer_seek(__args.buff, buffer_seek_start, 0);
				
				string_foreach(_text, method(__args, function(_char, _index) {
					if (__allowed_char__[$ _char]) {
						buffer_write(buff, buffer_text, _char);
					}
				}));
					
				// Write a null terminator so the resulting string ends correctly.
				buffer_write(__args.buff, buffer_u8, 0);
					
				buffer_seek(__args.buff, buffer_seek_start, 0);
				var _new_text = buffer_read(__args.buff, buffer_string);
				
				buffer_resize(__args.buff, 0);
				
				return _new_text;
			};
			
			static __set_textbox__ = function(_comp) {
				__textbox_parent__ = _comp;
				return self;
			}
			
		#endregion
		
	#endregion
	
}
