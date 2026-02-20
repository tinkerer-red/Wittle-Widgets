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
			/// @self   WWTextCursor
			/// @param  {Constant.Color} new_color
			/// @returns {Struct.WWTextCursor}
			#endregion
			static set_cursor_color = function(_new_color) {
				cursor_color = _new_color;
				return self;
			};
			
			#region jsDoc
			/// @func   set_highlight_color()
			/// @desc   Sets the highlight color drawn behind selected text.
			/// @self   WWTextCursor
			/// @param  {Constant.Color} new_color
			/// @returns {Struct.WWTextCursor}
			#endregion
			static set_highlight_color = function(_new_color) {
				highlight_color = _new_color;
				return self;
			};
			
			#region jsDoc
			/// @func   set_cursor_visibility()
			/// @desc   Sets caret index and updates line, col, and GUI position.
			/// @self   WWTextCursor
			/// @param  {Bool} bool
			/// @returns {Struct.WWTextCursor}
			#endregion
			static set_cursor_visibility = function(_bool) {
				cursor_visible = _bool;
				if (_bool) {
					__blink_reset__();
				}
				return self;
			};
			
			#region jsDoc
			/// @func   set_index()
			/// @desc   Sets caret index and updates line, col, and GUI position.
			/// @self   WWTextCursor
			/// @param  {Real} index_new
			/// @returns {Struct.WWTextCursor}
			#endregion
			static set_index = function(_index_new) {
				if (index != _index_new) {
					__is_dirty__ = true;
					index = _index_new;
					__blink_reset__();
				}
				return self;
			};
			
			#region jsDoc
			/// @func   set_highlight_active()
			/// @desc   Sets highlight as active.
			/// @self   WWTextCursor
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
			/// @self   WWTextCursor
			/// @param  {Real} ind
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
			/// @self   WWTextCursor
			/// @param  {Real} ind
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
				// Update GUI locations
				__update_gui_position__();

				var _is_focused = true;
				if (__textbox_parent__ != undefined) {
					_is_focused = true;
					if (__textbox_parent__.__is_input_consumer__ != undefined) {
						_is_focused = __textbox_parent__.__is_input_consumer__;
					}
					else if (__textbox_parent__.__is_focused__ != undefined) {
						_is_focused = __textbox_parent__.__is_focused__;
					}
					else if (__textbox_parent__.is_focused != undefined) {
						_is_focused = __textbox_parent__.is_focused;
					}
				}
				else {
					_is_focused = false;
				}

				// Draw caret
				if (_is_focused && cursor_visible) {
					var _blink_visible = __blink_is_visible__();
					if (_blink_visible) {
						// Fetch renderer
						var _renderer = __textbox_parent__.__get_renderer__();
						var _line_index = _renderer.get_line_from_index(index);
						var _glyph_height = _renderer.get_line_height(_line_index);

						var _pre_color = draw_get_color();
						var _pre_alpha = draw_get_alpha();
						draw_set_color(cursor_color);
						draw_set_alpha(1);

						// Use a real sprite draw for consistency (HTML5 off-by-one friendliness)
						draw_sprite_stretched_ext(spr_ww_pixel, 0, x + cursor_x, y + cursor_y, 1, _glyph_height, cursor_color, 1);

						draw_set_alpha(_pre_alpha);
						draw_set_color(_pre_color);
					}
				}
			})
			
		#endregion
		
		#region Functions
				
			#region jsDoc
			/// @func   get_index()
			/// @desc   Returns the caret index within the buffer.
			/// @self   WWTextCursor
			/// @returns {Real}
			#endregion
			static get_index = function() {
				return index;
			};
			
			#region jsDoc
			/// @func   get_highlight_active()
			/// @desc   Returns if the highlight is active.
			/// @self   WWTextCursor
			/// @returns {Real}
			#endregion
			static get_highlight_active = function() {
				return highlight_active;
			};
			
			#region jsDoc
			/// @func   get_highlight_start_index()
			/// @desc   Returns highlight start index.
			/// @self   WWTextCursor
			/// @returns {Real}
			#endregion
			static get_highlight_start_index = function() {
				return highlight_start_index;
			};
			
			#region jsDoc
			/// @func   get_highlight_end_index()
			/// @desc   Returns highlight end index.
			/// @self   WWTextCursor
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
			
			// Blink
			__blink_period_ms__ = 1000;
			__blink_start_ms__ = current_time;
			__blink_show_ms__ = 500;
			
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
			/// @ignore
            /// @desc   Marks the cursor as needing recomputation.
			/// @self   WWTextCursor
			/// @returns {Undefined}
            #endregion
            static __mark_dirty__ = function() {
                __is_dirty__ = true;
            };
            
						
			#region jsDoc
			/// @func   __blink_reset__()
			/// @ignore
			/// @desc   Resets the caret blink timer so the caret is immediately visible.
			/// @self   WWTextCursor
			/// @returns {Undefined}
			#endregion
			static __blink_reset__ = function() {
				__blink_start_ms__ = current_time;
			};
			
			#region jsDoc
			/// @func   __blink_is_visible__()
			/// @ignore
			/// @desc   Returns true if the caret should be visible for the current time.
			/// @self   WWTextCursor
			/// @returns {Bool}
			#endregion
			static __blink_is_visible__ = function() {
				var _elapsed = current_time - __blink_start_ms__;
				if (_elapsed < 0) {
					__blink_start_ms__ = current_time;
					_elapsed = 0;
				}
				var _period = __blink_period_ms__;
				if (_period <= 0) {
					return true;
				}
				var _phase = _elapsed mod _period;
				return (_phase < __blink_show_ms__);
			};
			
			#region jsDoc
			/// @func   __update_gui_position__()
			/// @ignore
			/// @desc   Resolves GUI x,y from the renderer based on caret index.
			/// @self   WWTextCursor
			/// @returns {Undefined}
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
			
			#region jsDoc
			/// @func   __set_textbox__()
			/// @ignore
			/// @desc   Associates a textbox component with this cursor.
			/// @self   WWTextCursor
			/// @param  {Any} comp : Textbox component.
			/// @returns {Struct.WWTextCursor}
			#endregion
			static __set_textbox__ = function(_comp) {
				__textbox_parent__ = _comp;
				__blink_reset__();
				return self;
			}
			
		#endregion
		
	#endregion

}
