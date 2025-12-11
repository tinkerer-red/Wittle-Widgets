#region jsDoc
/// @func	WWTextCursor()
/// @desc	Cursor component for Wittle Widgets text input. Responsible for:
///		  - Tracking caret index, line, and column
///		  - Tracking highlight start and end
///		  - Computing GUI position through the renderer
///		  - Drawing highlight selection
///		  This component does not modify the renderer or buffer; it only
///		  queries them.
/// @returns {Struct.WWTextCursor}
#endregion
function WWTextCursor() : WWCore() constructor {

	debug_name = "WWTextCursor";

	#region Public

		#region Builder Functions
			
			#region jsDoc
			/// @func   set_cursor_color()
			/// @desc   Sets the cursor color.
			/// @param  {Constant.Color} _new_color
			/// @returns {Struct.WWTextCursor}
			#endregion
			static set_cursor_color = function(_new_color) {
				cursor_color = _new_color;
				return self;
			};
			
			#region jsDoc
			/// @func   set_highlight_color()
			/// @desc   Sets the highlight color drawn behind selected text.
			/// @param  {Constant.Color} _new_color
			/// @returns {Struct.WWTextCursor}
			#endregion
			static set_highlight_color = function(_new_color) {
				highlight_color = _new_color;
				return self;
			};
			
			#region jsDoc
			/// @func   set_cursor_visibility()
			/// @desc   Sets caret index and updates line, col, and GUI position.
			/// @param  {Bool} read_only
			/// @returns {Struct.WWTextCursor}
			#endregion
			static set_cursor_visibility = function(_bool) {
				cursor_visible = _bool;
				return self;
			};
			
			#region jsDoc
			/// @func   set_index()
			/// @desc   Sets caret index and updates line, col, and GUI position.
			/// @param  {Real} _index_new
			/// @returns {Struct.WWTextCursor}
			#endregion
			static set_index = function(_index_new) {
				if (index != _index_new) {
					__is_dirty__ = true;
				}
				index = _index_new;
				return self;
			};
			
			#region jsDoc
			/// @func   set_highlight_active()
			/// @desc   Sets highlight as active.
			/// @param  {Bool} bool
			/// @returns {Struct.WWTextCursor}
			#endregion
			static set_highlight_active = function(_bool) {
				highlight_active = _bool;
				return self;
			};
			
			#region jsDoc
			/// @func   set_highlight_start_index()
			/// @desc   Sets highlight start and resolves its line/col.
			/// @param  {Real} _ind
			/// @returns {Struct.WWTextCursor}
			#endregion
			static set_highlight_start_index = function(_ind) {
				if (highlight_start_index != _ind) {
					__is_dirty__ = true;
				}
				highlight_start_index = _ind;
				return self;
			};
				
			#region jsDoc
			/// @func   set_highlight_end_index()
			/// @desc   Sets highlight end and resolves its line/col.
			/// @param  {Real} _ind
			/// @returns {Struct.WWTextCursor}
			#endregion
			static set_highlight_end_index = function(_ind) {
				if (highlight_end_index != _ind) {
					__is_dirty__ = true;
				}
				highlight_end_index = _ind;
				return self;
			};
			
		#endregion
		
		#region Events
			
			on_pre_draw(function(){
				//Update GUI locations
				__update_gui_position__();
				
				//Fetch renderer
				var _renderer = __textbox_parent__.__get_renderer__();
				
				var _pre_color = draw_get_color();
				
				//Draw highlight
				if (highlight_active) {
					draw_set_color(highlight_color);
					
					var _start = min(highlight_start_index, highlight_end_index);
					var _end   = max(highlight_start_index, highlight_end_index);

					var _start_line = _renderer.get_line_from_index(_start);
					var _end_line   = _renderer.get_line_from_index(_end);

					var _line = _start_line;
					repeat((_end_line - _start_line) + 1) {

						var _y  = _renderer.get_line_y_offset(_line);
						var _h  = _renderer.get_line_height(_line);
						var _w  = _renderer.get_line_width(_line);

						var _range_start = 0;
						var _range_end   = _w;

						if (_line == _start_line) {
							_range_start = _renderer.get_x_from_index(_start);
						}

						if (_line == _end_line) {
							_range_end = _renderer.get_x_from_index(_end);
						}
						
						draw_rectangle(x+_range_start, y+_y, x+_range_end, y+_y + _h, false);

						_line++;
					}
					
					draw_set_color(_pre_color);
				}
				
				//Draw cursor
				if (cursor_visible) {
					draw_set_color(cursor_color);
					var _line_index = _renderer.get_line_from_index(index)
					var _glyph_height = _renderer.get_line_height(_line_index);
					draw_rectangle(x+cursor_x, y+cursor_y, x+cursor_x+1, y+cursor_y+_glyph_height, false);
				}
				
				draw_set_color(_pre_color);
			})
			
		#endregion
		
		#region Functions
				
			#region jsDoc
			/// @func   get_index()
			/// @desc   Returns the caret index within the buffer.
			/// @returns {Real}
			#endregion
			static get_index = function() {
				return index;
			};
			
			#region jsDoc
			/// @func   get_highlight_active()
			/// @desc   Returns if the highlight is active.
			/// @returns {Real}
			#endregion
			static get_highlight_active = function() {
				return highlight_active;
			};
			
			#region jsDoc
			/// @func   get_highlight_start_index()
			/// @desc   Returns highlight start index.
			/// @returns {Real}
			#endregion
			static get_highlight_start_index = function() {
				return highlight_start_index;
			};
			
			#region jsDoc
			/// @func   get_highlight_end_index()
			/// @desc   Returns highlight end index.
			/// @returns {Real}
			#endregion
			static get_highlight_end_index = function() {
				return highlight_end_index;
			};
			
		#endregion
		
	#endregion
	
	#region Private
		
		#region Variables
			
			// Position
			index = 0;
			cursor_x = 0;
			cursor_y = 0;
			cursor_visible = true;
			
			// Highlight state
			highlight_active = false;
			highlight_start_index = 0;
			highlight_end_index   = 0;
			
			highlight_start_line = 0;
			highlight_start_col  = 0;
			highlight_end_line   = 0;
			highlight_end_col    = 0;
			
			cursor_color = c_white;
			highlight_color = c_aqua;
			
			__is_dirty__ = true;
			__textbox_parent__ = undefined;
			
		#endregion
		
		#region Functions
			
			#region jsDoc
            /// @func   __mark_dirty__()
            /// @desc   Marks the cursor as needing recomputation.
            #endregion
            static __mark_dirty__ = function() {
                __is_dirty__ = true;
            };
            
			#region jsDoc
			/// @func   __update_gui_position__()
			/// @desc   Resolves GUI x,y from the renderer based on caret index.
			#endregion
			static __update_gui_position__ = function() {
				if (!__is_dirty__) return;
				__is_dirty__ = false;
				
				var _renderer = __textbox_parent__.__get_renderer__();
				cursor_x = _renderer.get_x_from_index(index);
				cursor_y = _renderer.get_y_from_index(index);
				
				if (highlight_start_index != highlight_end_index) {
					highlight_start_line = _renderer.get_line_from_index(highlight_start_index);
					highlight_start_col  = _renderer.get_col_from_index (highlight_start_index);
					highlight_end_line   = _renderer.get_line_from_index(highlight_end_index);
					highlight_end_col    = _renderer.get_col_from_index (highlight_end_index);
				}
				
				
			};
			
			static __set_textbox__ = function(_comp) {
				__textbox_parent__ = _comp;
				return self;
			}
			
		#endregion
		
	#endregion

}
