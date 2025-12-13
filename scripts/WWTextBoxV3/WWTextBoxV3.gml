#region jsDoc
/// @func    WWTextBoxV3()
/// @desc    Base text component providing common functionality: text storage, rendering hook, and selection support.
///         By default, it is read-only.
/// @returns {Struct.WWTextBoxV3}
#endregion
function WWTextBoxV3() : WWCore() constructor {
    debug_name = "WWTextBase";
    
	#region Components
		
		hotkeys  = new WWHotkeyManager(); //doesnt need to be added as a child
		cursor   = new WWTextCursor();
		buffer   = new WWTextBuffer();
		renderer = new WWTextRendererBase();
		
		cursor  .__set_textbox__(self);
		buffer  .__set_textbox__(self);
		renderer.__set_textbox__(self);
		
		cursor.add([renderer]);
		
		add([buffer, cursor]);
		
	#endregion
	
    #region Public
		
        #region Builder Functions
			
			#region Text
				
				#region jsDoc
				/// @func	set_text()
				/// @desc	Sets the main text content to display in the component. This text is selectable by the user.
				/// @self	WWTextBase
				/// @param   {String} _text : The text to display.
				/// @returns {Struct.WWTextBase}
				#endregion
				static set_text = function(_text = "") {
					if (buffer.get_text() == _text) return self;
					buffer.set_text(_text);
					__force_rebuild__();
					__history_add_record__();
					return self;
				}
				#region jsDoc
				/// @func	set_caption()
				/// @desc	Sets the text displayed when the text feild is empty. This text is not selectable or editable by the user. Will also effect how consoles display a header for the on screen keyboard
				/// @self	WWTextBase
				/// @param   {String} _text : The caption text to display.
				/// @returns {Struct.WWTextBase}
				#endregion
				static set_caption = function(_text = "") {
					renderer.set_caption(_text);
					return self;
				}
				#region jsDoc
				/// @func	set_text_font()
				/// @desc	Sets the font used for rendering text.
				/// @self	WWTextBase
				/// @param   {Asset.GMFont} _font : The font asset to use.
				/// @returns {Struct.WWTextBase}
				#endregion
				static set_text_font = function(_font = fGUIDefault) {
					renderer.set_font(_font);
					return self;
				}
				#region jsDoc
				/// @func	set_text_color()
				/// @desc	Sets the font color used for rendering the text.
				/// @self	WWTextBase
				/// @param   {Constant.Color} _color : The color to use.
				/// @returns {Struct.WWTextBase}
				#endregion
				static set_text_color = function(_color = #D9D9D9) {
					renderer.set_text_color(_color);
					return self;
				}
				#region jsDoc
				/// @func    set_text_alpha()
				/// @desc    Sets the text alpha used for rendering the text.
				/// @self    WWTextBase
				/// @param   {Real} alpha : The alpha to use.
				/// @returns {Struct.WWTextBase}
				#endregion
				static set_text_alpha = function(_alpha = 1) {
					renderer.set_text_alpha(_alpha)
					return self;
				}
				
				#region jsDoc
                /// @func   set_wrap_width()
                /// @desc   Sets if word wrapping is enabled, true will wrap words to next line.
                /// @param  {Bool} should_wrap
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_wrap_enabled = function(_should_wrap) {
                    renderer.set_wrap_enabled(_should_wrap);
                    return self;
                };
                
                #region jsDoc
                /// @func   set_line_sep()
                /// @desc   Sets the extra spacing between wrapped lines (in pixels).
                /// @param  {Real} _line_sep_pixels
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_line_sep = function(_line_sep_pixels) {
                    renderer.set_line_sep(_line_sep_pixels);
                    return self;
                };
				
			#endregion
			
			#region Controller Options
			
			#region jsDoc
			/// @func    set_read_only()
			/// @desc    Sets textbox to be read only, this will still allow for selecting and copying
			///          like one would from a console or webpage, but modifying the text is prohibited.
			/// @self    WWTextBase
			/// @param   {Bool} is_read_only : If the text is read only.
			/// @returns {Struct.WWTextBase}
			#endregion
			static set_read_only = function(_bool = false) {
				is_read_only = _bool;
				cursor.set_cursor_visibility(_bool);
				return self;
			}
			
			#region jsDoc
			/// @func   set_allowed_char()
			/// @desc   Sets the allowed characters to be used in this textbox. 
			///         If undefined, the allowed characters are generated from the current font.
			///         Will also infer and set keyboard type if not already user-defined.
			/// @self   WWTextBase
			/// @param  {String} _allowed_char : A string of allowed characters (optional).
			/// @returns {Struct.WWTextBase}
			#endregion
			static set_allowed_char = function(_allowed_char = undefined) {
			    if (is_undefined(_allowed_char)) {
			        var _allowed = __build_allowed_char__(renderer.get_font());
					buffer.set_allowed_char(_allowed);
			    }
			    else {
			        var _allowed = {};
			        __allowed_char_set__ = true;
			        string_foreach(_allowed_char, method(_allowed, function(_char, _pos) {
			            self[$ _char] = true;
			        }));
					
					buffer.set_allowed_char(_allowed);
			    }
				
				// Infer keyboard type if none has been set by user
			    if (!__keyboard_type_set__) {
			        __keyboard_type__ = __infer_keyboard_type__(_allowed_char);
			    }
				
			    return self;
			}
			
			#region jsDoc
			/// @func   set_keyboard_type()
			/// @desc   Sets the keyboard type used in this textbox. 
			///         If undefined, the keyboard type is generated from the allowed char.
			/// @self   WWTextBase
			/// @param  {Constant.VirtualKeyboardType} _keyboard_type : Which keyset will be available on the virtual keyboard (optional).
			/// @returns {Struct.WWTextBase}
			#endregion
			static set_keyboard_type = function(_keyboard_type = undefined) {
				if (is_undefined(_keyboard_type)) {
			        if (__allowed_char_set__) {
						__keyboard_type__ = __infer_keyboard_type__(buffer.get_allowed_char());
					}
					else {
						__keyboard_type__ = kbv_type_default;
					}
			    }
			    else {
					__keyboard_type_set__ = true;
			        __keyboard_type__ = kbv_type_default;
			    }
				
			    return self;
			}
			
			#region jsDoc
			/// @func   set_enter_submits_text()
			/// @desc   Sets if pressing enter will submit and exit editing text,
			///         false will result in attempting to insert the newline glyph `\n`
			/// @self   WWTextBase
			/// @param  {Bool} _enabled : Wheather pressing enter will submit the text.
			/// @returns {Struct.WWTextBase}
			#endregion
			static set_enter_submits_text = function(_enabled = false) {
				enter_submits_text = _enabled;
				return self;
			}
			
			#region jsDoc
			/// @func   set_tab_exits_text()
			/// @desc   Sets if pressing tab will exit editing text,
			///         false will result in attempting to insert the tab glyph `\t`
			/// @self   WWTextBase
			/// @param  {Bool} _enabled : Wheather pressing tab will exit the editing of text.
			/// @returns {Struct.WWTextBase}
			#endregion
			static set_tab_exits_text = function(_enabled) {
				tab_exits_text = _enabled;
				return self;
			}
			
			#endregion
			
			#region Cursor
				
				#region jsDoc
				/// @func	set_cursor_color()
				/// @desc	Sets the color for the selection highlight.
				/// @self	WWTextBase
				/// @param   {Constant.Color} _color : The highlight color.
				/// @returns {Struct.WWTextBase}
				#endregion
				static set_cursor_color = function(_color = #FFFFFF) {
					cursor.set_cursor_color(_color);
					return self;
				}
				#region jsDoc
				/// @func	set_highlight_color()
				/// @desc	Sets the color for the selection highlight.
				/// @self	WWTextBase
				/// @param   {Constant.Color} _color : The highlight color.
				/// @returns {Struct.WWTextBase}
				#endregion
				static set_highlight_color = function(_color = #0A68D8) {
					cursor.set_highlight_color(_color);
					return self;
				}
				
				#region jsDoc
				/// @func    set_cursor_index()
				/// @desc    Get cursor's x position in the GUI
				/// @self    GUICompTextbox
				/// @param  {String} _allowed_char : A string of allowed characters (optional).
				/// @returns {Real}
				#endregion
				static set_cursor_index = function(_index) {
					return __cursor_set_index_synced__(_index);
				}
				#region jsDoc
				/// @func    set_cursor_highlight_start_index()
				/// @desc    Get cursor's x position in the GUI
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static set_cursor_highlight_start_index = function() {
					return cursor.set_highlight_start_index();
				}
				#region jsDoc
				/// @func    set_cursor_highlight_end_index()
				/// @desc    Get cursor's x position in the GUI
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static set_cursor_highlight_end_index = function() {
					return cursor.set_highlight_end_index();
				}
				
				//Renderer
				#region jsDoc
				/// @func    set_cursor_col()
				/// @desc    Get cursor's x position in the GUI
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static set_cursor_col = function() {
					return cursor.set_col();
				}
				#region jsDoc
				/// @func    set_cursor_line()
				/// @desc    Get cursor's y position in the GUI
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static set_cursor_line = function() {
					return cursor.set_line();
				}
				#region jsDoc
				/// @func    set_cursor_highlight_start_line()
				/// @desc    Get cursor's x position in the GUI
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static set_cursor_highlight_start_line = function() {
					return cursor.set_highlight_start_line();
				}
				#region jsDoc
				/// @func    set_cursor_highlight_start_col()
				/// @desc    Get cursor's x position in the GUI
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static set_cursor_highlight_start_col = function() {
					return cursor.set_highlight_start_col();
				}
				#region jsDoc
				/// @func    set_cursor_highlight_end_line()
				/// @desc    Get cursor's x position in the GUI
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static set_cursor_highlight_end_line = function() {
					return cursor.set_highlight_end_line();
				}
				#region jsDoc
				/// @func    set_cursor_highlight_end_col()
				/// @desc    Get cursor's x position in the GUI
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static set_cursor_highlight_end_col = function() {
					return cursor.set_highlight_end_col();
				}
				
				//GUI
				#region jsDoc
				/// @func    set_cursor_xy()
				/// @desc    Get cursor's xy position in the GUI
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static set_cursor_xy = function(_x, _y) {
					var _index = renderer.get_index_from_xy(_x, _y);
					return __cursor_set_index_synced__(_index);
				}
				
			#endregion
			
		#endregion
		
        #region Events
			
            events.select    = variable_get_hash("select"); //triggered when the component gets focus, this commonly occurs when the mouse is clicked down on it.
			static on_select = function(_func) {
				add_event_listener(events.select, _func);
				return self;
			}
			events.copy    = variable_get_hash("copy"); //triggered when the component gets focus, this commonly occurs when the mouse is clicked down on it.
			static on_copy = function(_func) {
				add_event_listener(events.copy, _func);
				return self;
			}
			events.paste    = variable_get_hash("paste"); //triggered when the component gets focus, this commonly occurs when the mouse is clicked down on it.
			static on_paste = function(_func) {
				add_event_listener(events.paste, _func);
				return self;
			}
			events.change    = variable_get_hash("change"); //triggered when the component gets focus, this commonly occurs when the mouse is clicked down on it.
			static on_change = function(_func) {
				add_event_listener(events.change, _func);
				return self;
			}
			events.submit    = variable_get_hash("submit"); //triggered when the component gets focus, this commonly occurs when the mouse is clicked down on it.
			static on_submit = function(_func) {
				add_event_listener(events.submit, _func);
				return self;
			}
			events.cursor_move = variable_get_hash("cursor_move"); //triggered when the component gets focus, this commonly occurs when the mouse is clicked down on it.
			static on_cursor_move = function(_func) {
				add_event_listener(events.cursor_move, _func);
				return self;
			}
			
			on_pressed(function(_data) {
				// get focus
				__check_minput__(false);
			})
			on_interact(function(_data) {
				var mx = device_mouse_x_to_gui(0);
				var my = device_mouse_y_to_gui(0);
				
				// stay focused if mouse is on component
				if (__word_selection_mode__) {
			        __update_word_selection_drag__();
			    }
				else {
			        __check_minput__(true);
			    }
			})
			on_long_press(function(_data) {
				// Phone support for selecting text
			})
			on_released(function(_data) {
				// stay focused if mouse is on component
				__word_selection_mode__ = false;
			})
			on_double_click(function(_data) {
			    var _loc = __compute_word_boundaries__(cursor.get_index());
				
				// Activate the selection.
				cursor.set_highlight_active(true);
				
				// Set selection: highlight from startPos to endPos in the current line.
				cursor.set_highlight_start_index(_loc.index_start);
				cursor.set_highlight_end_index(_loc.index_end);
				__cursor_set_index_synced__(_loc.index_end, true);
			    
				__word_anchor_start__ = _loc.index_start;
			    __word_anchor_end__   = _loc.index_end;
				__word_selection_mode__ = true;
			});
			
			on_focus(function(_input) {
				var _return = hotkeys.step();
				if (_return == undefined) {
					if (keyboard_string != "") {
						__insert_string_at_cursor__(keyboard_string);
						keyboard_string = "";
					}
				}
				else {
					//empy the keyboard string after the hotkeys are handled to act as a "consume"
					keyboard_string = "";
				}
			});
			on_mouse_off(function(){
				if (mouse_check_button_pressed(mb_left)) {
					trigger_event(self.events.focus_exit);
					__is_focused__ = false;
				}
			})
			on_focus_exit(function(_input) {
				cursor.set_index(0);
				cursor.set_highlight_start_index(0);
				cursor.set_highlight_end_index(0);
				cursor.set_highlight_active(false);
				cursor_last_width = 0;
			})
			//// Pre-draw event handler.
			//on_pre_draw(function(_input) {
			//    
			//});
			
		#endregion
        
		#region Hotkeys
			//TODO: ADD THESE
			//Ctrl+Insert = Copy = Ctrl+C (currently works as fas as i can tell)
			//Shift+Delete = Cut = Ctrl+X (currently cuts the text but not to the clipboard)
			//Shift+Insert = Paste = Ctrl+V (currently crashes GameMaker)
			
			
			// Register various key sequences
			#region Navigation — Arrows, Home/End, Page Up/Down
			
			#region No modifier
			hotkeys.register([vk_left], function() {
				__move_cursor_offset__(-1, false, false, false);
			});
			hotkeys.register([vk_right], function() {
				__move_cursor_offset__(1, false, false, false);
			});
			hotkeys.register([vk_up], function() {
				__move_cursor_offset__(-1, false, true, false);
			});
			hotkeys.register([vk_down], function() {
				__move_cursor_offset__(1, false, true, false);
			});
			
			hotkeys.register([vk_home], function() {
				var _index = cursor.get_index();
				var _line = renderer.get_line_from_index(_index);
				var _new_index = renderer.get_line_index_start(_line);
				__cursor_set_index_synced__(_new_index, false);
			});
			hotkeys.register([vk_end], function() {
				var _index = cursor.get_index();
				var _line = renderer.get_line_from_index(_index);
				var _new_index = renderer.get_line_index_end(_line);
				
				//if literal `\n` ignore it
				if not (renderer.get_line_forced_wrapped(_line)) {
					_new_index -= 1;
				}
				
				__cursor_set_index_synced__(_new_index, false);
			});
			hotkeys.register([vk_pageup], function() {
				__move_cursor_paged_offset__(-1, false);
			});
			hotkeys.register([vk_pagedown], function() {
				__move_cursor_paged_offset__(1, false);
			});
			#endregion
			
			#region Ctrl Modifier
			hotkeys.register([vk_control, vk_left], function() {
				__move_cursor_offset__(-1, false, false, true);
			});
			hotkeys.register([vk_control, vk_right], function() {
				__move_cursor_offset__(1, false, false, true);
			});
			hotkeys.register([vk_control, vk_up], function() {
				__move_cursor_offset__(-1, false, true, true);
			});
			hotkeys.register([vk_control, vk_down], function() {
				__move_cursor_offset__(1, false, true, true);
			});
			
			hotkeys.register([vk_control, vk_home], function() {
				var _new_index = 0;
				__cursor_set_index_synced__(_new_index, false);
			});
			hotkeys.register([vk_control, vk_end], function() {
				var _new_index = renderer.get_glyph_count()-1;
				__cursor_set_index_synced__(_new_index, false);
			});
			
			//These are often used for page/tab switching
			//hotkeys.register([vk_control, vk_pageup], function() {});
			//hotkeys.register([vk_control, vk_pagedown], function() {});
			
			#endregion
			
			#region Shift Modifier
			hotkeys.register([vk_shift, vk_left], function() {
				__move_cursor_offset__(-1, true, false, false);
			});
			hotkeys.register([vk_shift, vk_right], function() {
				__move_cursor_offset__(1, true, false, false);
			});
			hotkeys.register([vk_shift, vk_up], function() {
				__move_cursor_offset__(-1, true, true, false);
			});
			hotkeys.register([vk_shift, vk_down], function() {
				__move_cursor_offset__(1, true, true, false);
			});

			hotkeys.register([vk_shift, vk_home], function() {
				var _index = cursor.get_index();
				var _line = renderer.get_line_from_index(_index)
				var _new_index = renderer.get_line_index_start(_line);
				
				__cursor_set_index_synced__(_new_index, true);
				cursor.set_highlight_end_index(_new_index);
			});
			hotkeys.register([vk_shift, vk_end], function() {
				var _index = cursor.get_index();
				var _line = renderer.get_line_from_index(_index)
				var _new_index = renderer.get_line_index_end(_line);
				
				//if literal `\n` ignore it
				if not (renderer.get_line_forced_wrapped(_line)) {
					_new_index -= 1;
				}
				
				__cursor_set_index_synced__(_new_index, true);
				cursor.set_highlight_end_index(_new_index);
			});
			hotkeys.register([vk_shift, vk_pageup], function() {
				__move_cursor_paged_offset__(-1, true);
			});
			hotkeys.register([vk_shift, vk_pagedown], function() {
				__move_cursor_paged_offset__(1, true);
			});
			#endregion
			
			#region Ctrl + Shift Modifier
			hotkeys.register([vk_control, vk_shift, vk_left], function() {
				__move_cursor_offset__(-1, true, false, true);
			});
			hotkeys.register([vk_control, vk_shift, vk_right], function() {
				__move_cursor_offset__(1, true, false, true);
			});
			hotkeys.register([vk_control, vk_shift, vk_up], function() {
				__move_cursor_offset__(-1, true, true, true);
			});
			hotkeys.register([vk_control, vk_shift, vk_down], function() {
				__move_cursor_offset__(1, true, true, true);
			});
			
			hotkeys.register([vk_control, vk_shift, vk_home], function() {
				var _index = cursor.get_index();
				var _new_index = 0;
				__cursor_set_index_synced__(_new_index, true);
			});
			hotkeys.register([vk_control, vk_shift, vk_end], function() {
				var _index = cursor.get_index();
				var _new_index = renderer.get_glyph_count()-1;
				__cursor_set_index_synced__(_new_index, true);
			});
			hotkeys.register([vk_control, vk_shift, vk_pageup], function() {
				//Consumed, and is intended to do nothing
			});
			hotkeys.register([vk_control, vk_shift, vk_pagedown], function() {
				//Consumed, and is intended to do nothing
			});
			#endregion
			
			#endregion
			
			#region Deletion — Backspace, Delete, Ctrl+Delete
			#region No modifier
			hotkeys.register([vk_backspace], function() {
			    if (is_read_only) return;
				
			    // If selection exists: delete selection
			    if (__delete_selection_if_any__(true, true)) return;
				
			    // No selection: delete character before cursor
			    var _index = cursor.get_index();
			    if (_index <= 0) return;
				
			    var _prev_index = _index - 1;
			    var _buf_start  = renderer.get_buffer_index_from_index(_prev_index);
			    var _buf_end    = renderer.get_buffer_index_from_index(_index);
				
				buffer.erase(_buf_start, _buf_end);
				__force_rebuild__();
			    __cursor_set_index_synced__(_prev_index);
			});

			hotkeys.register([vk_delete], function() {
				if (is_read_only) return;
				
				// If selection exists: delete selection
				if (__delete_selection_if_any__(true, true)) return;
				
				// No selection: delete character at cursor
				var _index = cursor.get_index();
				var _next  = _index + 1;
				
				// If at end of text, nothing to delete
				if (_index >= renderer.get_glyph_count()) return;
				
				var _buf_start = renderer.get_buffer_index_from_index(_index);
				var _buf_end   = renderer.get_buffer_index_from_index(_next);
				
				buffer.erase(_buf_start, _buf_end);
				
				__force_rebuild__();
				__history_add_record__();
			});

			#endregion
			
			#region Ctrl Modifier
			hotkeys.register([vk_control, vk_backspace], function() {
				if (is_read_only) return;
				
				// If selection exists; normal delete
				if (__delete_selection_if_any__(true, true)) return;
				
				// Compute previous word boundary
				var _index = cursor.get_index();
				var _pointed_index = max(0, _index-1);
				
				var _bounds = __compute_word_boundaries__(_pointed_index, false);
				var _start = _bounds.index_start;
				
				var _buffer_start = renderer.get_buffer_index_from_index(_start);
				var _buffer_end   = renderer.get_buffer_index_from_index(_index);
				
				buffer.erase(_buffer_start, _buffer_end);
				__force_rebuild__();
				__cursor_set_index_synced__(_start);
			});
			hotkeys.register([vk_control, vk_delete], function() {
			    if (is_read_only) return;
				
			    // Selection; normal delete
			    if (__delete_selection_if_any__(true, true)) return;
				
			    // Compute next word boundary
			    var _index = cursor.get_index();
				var _pointed_index = min(_index+1, renderer.get_glyph_count());
				
				var _bounds = __compute_word_boundaries__(_pointed_index, false);
			    var _end = _bounds.index_end;
				
			    var _buffer_start = renderer.get_buffer_index_from_index(_index);
			    var _buffer_end   = renderer.get_buffer_index_from_index(_end);
				
			    buffer.erase(_buffer_start, _buffer_end);
				__force_rebuild__();
				__cursor_set_index_synced__(_index);
			});

			#endregion
			
			#region Ctrl + Shift Modifier
			////////////////////////////////////////////////////////////////
			// NOTE::
			// Technically these are only used in rich text editors and not
			// in code editors but it hurts nothing to include them in both.
			////////////////////////////////////////////////////////////////
			
			hotkeys.register([vk_control, vk_shift, vk_backspace], function() {
				if (is_read_only) return;
				
				// If selection exists; normal delete
				if (__delete_selection_if_any__(true, true)) return;
				
				// Delete until begining of line
				var _end = cursor.get_index();
				var _line = renderer.get_line_from_index(_end)
				var _start = renderer.get_line_index_start(_line);
				
				var _buffer_start = renderer.get_buffer_index_from_index(_start);
				var _buffer_end   = renderer.get_buffer_index_from_index(_end);
				buffer.erase(_buffer_start, _buffer_end);
				cursor.set_index(_start);
				__force_rebuild__();
				cursor.set_highlight_active(false);
				__history_add_record__();
			});
			hotkeys.register([vk_control, vk_shift, vk_delete],    function() {
				if (is_read_only) return;
				
				// If selection exists; normal delete
				if (__delete_selection_if_any__(true, true)) return;
				
				// Delete until end of line, preserve `\n` line breaks, and stop on force wrapped
				var _start = cursor.get_index();
				var _line = renderer.get_line_from_index(_start)
				var _end = renderer.get_line_index_end(_line);
				
				//if literal `\n` preserve it
				if not (renderer.get_line_forced_wrapped(_line)) {
					_end -= 1;
				}
				
				var _buffer_start = renderer.get_buffer_index_from_index(_start);
				var _buffer_end   = renderer.get_buffer_index_from_index(_end);
				buffer.erase(_buffer_start, _buffer_end);
				cursor.set_index(_start);
				cursor.set_highlight_active(false);
				__force_rebuild__();
				__history_add_record__();
			});
			#endregion
			#endregion
			
			#region Clipboard & Edit Commands — Ctrl Combos
			hotkeys.register([vk_control, ord("A")], function() {
				select_all_text();
			});
			hotkeys.register([vk_control, ord("C")], function() {
				var _start = cursor.get_highlight_start_index();
				var _end   = cursor.get_highlight_end_index();
				var _buffer_start = renderer.get_glyph_buffer_index(_start);
				var _buffer_end   = renderer.get_glyph_buffer_index(_end);
				var _string = buffer.get_substring(_buffer_start, _buffer_end);
				__clipboard_set_text__(_string);
			});
			hotkeys.register([vk_control, ord("V")], function() {
				if (is_read_only) return;
				// Paste
				var _str = __clipboard_get_text__();
				__insert_string_at_cursor__(_str);
			});
			hotkeys.register([vk_control, ord("X")], function() {
				if (is_read_only) return;
				
				if (cursor.get_highlight_active()) {
					var _start = cursor.get_highlight_start_index();
					var _end   = cursor.get_highlight_end_index();
				}
				else {
					//if no selection made cut the entire line including the `\n`
					var _index = cursor.get_index();
					var _line = renderer.get_line_from_index(_index)
					var _start = renderer.get_line_index_start(_line);
					var _end = renderer.get_line_index_end(_line);
				}
				
				// Cut
				var _buffer_start = renderer.get_glyph_buffer_index(_start);
				var _buffer_end   = renderer.get_glyph_buffer_index(_end);
				var _string = buffer.get_substring(_buffer_start, _buffer_end);
				__clipboard_set_text__(_string);
				buffer.erase(_buffer_start, _buffer_end);
				
				cursor.set_highlight_active(false);
				
				var _new_index = min(_start, _end)
				cursor.set_index(_new_index);
				
				__force_rebuild__();
				
				__history_add_record__();
			});
			
			hotkeys.register([vk_control, ord("Z")], function() {
				if (is_read_only) return;
				// Undo
				__history_jump__(-1);
				__force_rebuild__();
			});
			hotkeys.register([vk_control, ord("Y")], function() {
				if (is_read_only) return;
				// Redo
				__history_jump__(1);
				__force_rebuild__();
			});
			hotkeys.register([vk_control, vk_shift, ord("Z")], function() {
				if (is_read_only) return;
				// Redo (alternate)
				__history_jump__(1);
				__force_rebuild__();
			});
			#endregion
			
			#region Control & Submission
			hotkeys.register([vk_enter], function() {
				if (is_read_only) return;
				//Submit or insert new line
				if (enter_submits_text) {
					//TODO::
				}
				else {
					__insert_string_at_cursor__("\n");
				}
			});
			hotkeys.register([vk_shift, vk_enter], function() {
				if (is_read_only) return;
				// Insert new line (force multiline)
				__insert_string_at_cursor__("\n");
			});
			hotkeys.register([vk_control, vk_enter], function() {
				if (is_read_only) return;
				// Optional: Submit (e.g., Ctrl+Enter)
				// I have no idea if this does anything
			});
			hotkeys.register([vk_control, vk_shift, vk_enter], function() {
				if (is_read_only) return;
				// Optional: Multiline submit override
				// I have no idea if this does anything
			});
			
			hotkeys.register([vk_escape], function() {
				if (is_read_only) return;
				// Cancel or unfocus
			});
			#endregion
			
			#region Tab / Focus & Indent Control
			hotkeys.register([vk_tab], function() {
				if (is_read_only) return;
				// Indent or move to next focus
				if (tab_exits_text) {
					//TODO::
				}
				else {
					__insert_string_at_cursor__("\t");
				}
			});
			hotkeys.register([vk_shift, vk_tab], function() {
				if (is_read_only) return;
				// Unindent or move to previous focus
			});
			hotkeys.register([vk_control, vk_tab], function() {
				if (is_read_only) return;
				// Optional: Switch next panel/focus group
			});
			hotkeys.register([vk_control, vk_shift, vk_tab], function() {
				if (is_read_only) return;
				// Optional: Switch previous panel/focus group
			});
			#endregion
			
			hotkeys.build();
			
		#endregion
		
        #region Variables
			
			is_focusable = true;
			is_read_only = false;
			enter_submits_text = false;
			tab_exits_text = false;
			
		#endregion
        
        #region Functions
            
			#region jsDoc
			/// @func    get_text()
			/// @desc    Returns the text from the textbox
			/// @self    GUICompTextbox
			/// @returns {String}
			#endregion
			static get_text = function() {
				return buffer.get_text();
			}
			
			#region jsDoc
			/// @func    clear_text()
			/// @desc    Clear the text from the text box.
			/// @self    GUICompTextbox
			/// @returns {Undefined}
			#endregion
			static clear_text = function() {
				buffer.clear_text();
				cursor.set_index(0);
				__history_update_latest_cursor__();
				cursor.set_highlight_active(false);
			}
			#region jsDoc
			/// @func    select_all_text()
			/// @desc    Select all the text from the text box.
			/// @self    GUICompTextbox
			/// @returns {Undefined}
			#endregion
			static select_all_text = function() {
				var _glyph_count = renderer.get_glyph_count();
				cursor.set_highlight_active(true);
				cursor.set_highlight_start_index(0);
				cursor.set_highlight_end_index(_glyph_count-1);
				cursor.set_index(_glyph_count-1);
				__history_update_latest_cursor__();
			}
			
			#region Sizing
				
				#region jsDoc
				/// @func    get_content_width()
				/// @desc    Get the canvas width of the textbox. This is the width of the underlying region where text can be drawn.
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static get_content_width = function() {
					return renderer.get_width();
				}
				#region jsDoc
				/// @func    get_content_height()
				/// @desc    Get the canvas height of the textbox. This is the height of the underlying region where text can be drawn.
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static get_content_height = function() {
					return renderer.get_height();
				}
				
			#endregion
			
			#region Cursor
				
				//Buffer
				#region jsDoc
				/// @func    get_cursor_index()
				/// @desc    Get cursor's x position in the GUI
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static get_cursor_index = function() {
					return cursor.get_index();
				}
				#region jsDoc
				/// @func    get_cursor_highlight_start_index()
				/// @desc    Get cursor's x position in the GUI
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static get_cursor_highlight_start_index = function() {
					return cursor.get_highlight_start_index();
				}
				#region jsDoc
				/// @func    get_cursor_highlight_end_index()
				/// @desc    Get cursor's x position in the GUI
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static get_cursor_highlight_end_index = function() {
					return cursor.get_highlight_end_index();
				}
				
				//Renderer
				#region jsDoc
				/// @func    get_cursor_col()
				/// @desc    Get cursor's x position in the GUI
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static get_cursor_col = function() {
					return cursor.get_col();
				}
				#region jsDoc
				/// @func    get_cursor_line()
				/// @desc    Get cursor's y position in the GUI
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static get_cursor_line = function() {
					return cursor.get_line();
				}
				#region jsDoc
				/// @func    get_cursor_highlight_start_line()
				/// @desc    Get cursor's x position in the GUI
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static get_cursor_highlight_start_line = function() {
					return cursor.get_highlight_start_line();
				}
				#region jsDoc
				/// @func    get_cursor_highlight_start_col()
				/// @desc    Get cursor's x position in the GUI
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static get_cursor_highlight_start_col = function() {
					return cursor.get_highlight_start_col();
				}
				#region jsDoc
				/// @func    get_cursor_highlight_end_line()
				/// @desc    Get cursor's x position in the GUI
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static get_cursor_highlight_end_line = function() {
					return cursor.get_highlight_end_line();
				}
				#region jsDoc
				/// @func    get_cursor_highlight_end_col()
				/// @desc    Get cursor's x position in the GUI
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static get_cursor_highlight_end_col = function() {
					return cursor.get_highlight_end_col();
				}
				
				//Relative GUI
				#region jsDoc
				/// @func    get_cursor_x()
				/// @desc    Get cursor's x position in the GUI
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static get_cursor_x = function() {
					return cursor.get_x();
				}
				#region jsDoc
				/// @func    get_cursor_y()
				/// @desc    Get cursor's y position in the GUI
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static get_cursor_y = function() {
					return cursor.get_y();;
				}
				
			#endregion
			
			#region Renderer Geometry
				
				#region jsDoc
				/// @func    index_to_x()
				/// @desc    Convert a buffer index into gui x coordinate
				/// @param   {Real} _index
				/// @returns {Real} x
				#endregion
				static index_to_x = function(_index) {
				    return renderer.index_to_x(_index);
				};
				#region jsDoc
				/// @func    index_to_y()
				/// @desc    Convert a buffer index into gui y coordinate
				/// @param   {Real} _index
				/// @returns {Real} y
				#endregion
				static index_to_y = function(_index) {
				    return renderer.index_to_y(_index);
				};
				#region jsDoc
				/// @func    xy_to_index()
				/// @desc    Convert gui x,y coordinates into the nearest buffer index.
				/// @param   {Real} _x
				/// @param   {Real} _y
				/// @returns {Real}
				#endregion
				static xy_to_index = function(_x, _y) {
				    return renderer.xy_to_index(_x, _y);
				};
			
				#region jsDoc
				/// @func    index_to_line()
				/// @desc    Convert a buffer index into a line number. Lines and columns are 0-based.
				/// @param   {Real} _index
				/// @returns {Real} line
				#endregion
				static index_to_line = function(_index) {
				    return renderer.index_to_line(_index);
				}
				#region jsDoc
				/// @func    index_to_col()
				/// @desc    Convert a buffer index into a column number. Lines and columns are 0-based.
				/// @param   {Real} _index
				/// @returns {Real} line
				#endregion
				static index_to_col = function(_index) {
				    return renderer.index_to_col(_index);
				};
				#region jsDoc
				/// @func    line_col_to_index()
				/// @desc    Convert a line and column (0-based) into a buffer index.
				/// @param   {Real} _line
				/// @param   {Real} _col
				/// @returns {Real}
				#endregion
				static line_col_to_index = function(_line, _col) {
				    return renderer.line_col_to_index(_line, _col);
				};
			
			#endregion
			
        #endregion
		
    #endregion
    
    #region Private
        
		#region Variables
			
			__allowed_char_set__ = false; // Indicates whether allowed characters have been explicitly set.
			__keyboard_type_set__ = false; // Indicates whether keyboard type has been explicitly set.
			
			__keyboard_type__ = kbv_type_default; //Used for on screen keyboards.
			
			__word_selection_mode__ = false;
			
			cursor_last_width = undefined; //The last known x position in pixels, to ensure pressing up or down multiple times doesnt deviate the cursor off from its intended "center"
			
			__historic_records_loc__ = -1;
			__historic_records__ = [];
			__history_records_limit__ = 65536; // power(2, 16); // we'll simply allow for a lot to start with, memory shouldnt be an issue but for low end devices this is here as an option
			
			static __clipboard_layout_cache__ = {}; //globally used in all textboxes to carry leyout information from one textbox to another, commonly used for rich text rendering, or syntax highlighting
			
		#endregion
		
		#region Functions
			
			#region Allowing Char
			
				#region jsDoc
			    /// @func    __build_allowed_char__()
			    /// @desc    Returns a struct of allowed characters from the supplied font.
			    /// @self    WWTextBase
			    /// @param   {Asset.GMFont} _font : The font to build the allowed character list.
			    /// @returns {Struct} Allowed Characters Struct
			    #endregion
				static __build_allowed_char__ = function(_font, _include_nl=true) {
			        var _info = font_get_info(_font);
			        var _output = {};
					struct_foreach(_info.glyphs, method(_output, function(_key, _value){
						self[$ _key] = true;
					}));
			        
					if (_include_nl) _output[$ "\n"] = true;
					
			        return _output;
			    }
				
				#region jsDoc
				/// @func    __infer_keyboard_type__
				/// @desc    Choose a best-fit virtual keyboard type from an allowed-character palette.
				///         Heuristics are ordered from most-specific to most-generic and are conservative:
				///         - Pure digits -> numbers
				///         - Digits with phone punctuation -> phone
				///         - E-mail shape (needs '@' and '.') and no spaces -> email
				///         - URL shape (needs ':' or '/' and often '.') and no spaces -> url
				///         - ASCII-only palette (no non-ascii) -> ascii
				///         - Name-like (letters, spaces, dash, apostrophe; no digits) -> phone_name
				///         - Otherwise -> default
				/// @param   {String|Undefined} _allowed
				/// @returns {Real} kbv_type_* constant
				#endregion
				static __infer_keyboard_type__ = function(_allowed) {
				    // Defensive defaults
				    if (is_undefined(_allowed) || _allowed == "") {
				        return kbv_type_default;
				    }
					
				    // Local helpers (all ASCII-safe)
				    static __has__ = function(_pool, _ch) {
				        return string_pos(_ch, _pool) > 0;
				    };
				    static __all_in__ = function(_pool, _set) {
				        var idx = 1, len = string_length(_pool);
				        while (idx <= len) {
				            var ch = string_char_at(_pool, idx);
				            if (string_pos(ch, _set) == 0) return false;
				            idx += 1;
				        }
				        return true;
				    };
				    static __is_subset_of__ = __all_in__;
				    static __is_ascii_only__ = function(_pool) {
				        var idx = 1, len = string_length(_pool);
				        while (idx <= len) {
				            var ch = string_char_at(_pool, idx);
				            if (ord(ch) < 0 || ord(ch) > 127) return false;
				            idx += 1;
				        }
				        return true;
				    };

				    var pool = _allowed;

				    // Canonical class sets
				    var digits         = "0123456789";
				    var phone_punct    = "+-() #*";
				    var decimal_punct  = "+-.";
				    var ascii_letters  = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
				    var letters_spaces = ascii_letters + " -'";
				    var url_marks      = ":/.?&#%=_~-";
				    var email_marks    = "@._-+";

				    // 1) Strict numbers: palette contains only digits
				    if (__is_subset_of__(pool, digits)) {
				        return kbv_type_numbers;
				    }

				    // 2) Phone: digits plus common phone punctuation, and no letters
				    if (__is_subset_of__(pool, digits + phone_punct)) {
				        return kbv_type_phone;
				    }

				    // 3) E-mail: must allow '@' and '.', forbid spaces, and be subset of a sane email set
				    if (__has__(pool, "@") && __has__(pool, ".")
				    && !__has__(pool, " ")
				    && __is_subset_of__(pool, ascii_letters + digits + email_marks)) {
				        return kbv_type_email;
				    }

				    // 4) URL: must allow ':' or '/', forbid spaces, and be subset of a sane url set
				    if ((__has__(pool, ":") || __has__(pool, "/"))
				    && !__has__(pool, " ")
				    && __is_subset_of__(pool, ascii_letters + digits + url_marks)) {
				        return kbv_type_url;
				    }

				    // 5) Decimal-ish numeric input: digits plus "+-." (still best served by numbers pad)
				    if (__is_subset_of__(pool, digits + decimal_punct)) {
				        // GM does not have a dedicated "decimal" keyboard, numbers is the closest
				        return kbv_type_numbers;
				    }

				    // 6) ASCII-only palette (no non-ascii glyphs)
				    if (__is_ascii_only__(pool)) {
				        // If it looks like a name field (letters, spaces, dash, apostrophe, no digits), prefer phone_name
				        if (__is_subset_of__(pool, letters_spaces)) {
				            // Android will fall back to ASCII automatically if phone_name is not supported
				            return kbv_type_phone_name;
				        }
				        return kbv_type_ascii;
				    }

				    // 7) Default catch-all
				    return kbv_type_default;
				};

			#endregion
			
			#region Cursor Navigation
				
				#region jsDoc
				/// @func    __check_minput__()
				/// @desc    Updates the cursor position based on mouse input. When selection mode is enabled,
				///          if no selection anchor exists, it sets the anchor to the current cursor position.
				///          Then it updates the cursor position from the mouse coordinates. If the new cursor
				///          equals the anchor, selection is cleared; otherwise, selection remains active.
				/// @self    WWTextInputSingle
				/// @param   {Bool} _select : Whether selection mode is enabled.
				/// @returns {undefined}
				#endregion
				static __check_minput__ = function(_select) {
					// Get mouse coordinates in GUI space.
					var mx = device_mouse_x_to_gui(0);
					var my = device_mouse_y_to_gui(0);
					var _index = renderer.get_index_from_xy(mx, my);
					__cursor_set_index_synced__(_index, _select);
				}
				
				#region jsDoc
				/// @func    __move_cursor_offset__()
				/// @desc    Moves the cursor based on input and optionally extends selection. When shift is
				///          held, it preserves the selection anchor; otherwise, any active selection is cleared.
				/// @self    WWTextInputSingle
				/// @param   {Real} _change : The amount to move the cursor.
				/// @param   {Bool} _shift  : Whether to extend the selection (shift key held).
				/// @param   {Bool} _vertical : Whether the movement is vertical (if false, horizontal).
				/// @returns {undefined}
				#endregion
				static __move_cursor_offset__ = function(_vector, _shift, _vertical, _word_mode=false) {
					static __word_breakers = "\n"+chr(9)+chr(34)+" ,.;:?!><#$%&'()*+-/=@[\]^`{|}~¡¢£¤¥¦§¨©«¬­®¯°±´¶·¸»¿×÷";
					
					if (_vector == 0) return;
					
					var _index = cursor.get_index();
					var _new_index = _index; //will be overwritten
					
					// move cursor
					if (_vertical) {
						var _line = renderer.get_line_from_index(_index);
						var _line_count = renderer.get_line_count();
						
						//early out
						if (_line == 0) && (_vector < 0) {
							var _new_index = renderer.get_line_index_start(_line);
							cursor.set_index(_new_index)
							__history_update_latest_cursor__();
							return;
						}
						if (_line == _line_count-1) && (_vector > 0) {
							var _new_index = renderer.get_line_index_end(_line);
							cursor.set_index(_new_index)
							__history_update_latest_cursor__();
							return;
						}
						
						var _new_line = _line + _vector;
						var _yoff = renderer.get_line_y_offset(_new_line);
						var _new_index = renderer.get_index_from_xy(x+cursor_last_width, y+_yoff);
						__cursor_set_index_synced__(_new_index, _shift, true, false);
					}
					else {
						if (_word_mode) {
							var _index = cursor.get_index()+_vector;
							var _line = renderer.get_line_from_index(_index);
							var _start = renderer.get_line_index_start(_line);
							var _end   = renderer.get_line_index_end(_line);
							_vector = sign(_vector);
							
							var _word_breakers = __word_breakers;
							
							var _new_index = _index;
							
							var _i = _index+_vector;
							var _length = (_vector) ? _end-_i : _i-_start+1;
							repeat(_length) {
								var _char = renderer.get_glyph_char(_i);
								if (string_pos(_char, _word_breakers)) {
									if (_vector) {
										_new_index = _i;
									}
									break;
								}
								_new_index = _i;
							_i+=_vector}
						}
						else {
							var _new_index = cursor.get_index() + _vector;
							_new_index = clamp(_new_index, 0, renderer.get_glyph_count())
						}
						
						__cursor_set_index_synced__(_new_index, _shift);
					}
					
				}
				
				#region jsDoc
				/// @func    __move_cursor_paged_offset__()
				/// @desc    Moves the cursor based on page up and down, keepnig relation to the cursor width offset
				/// @self    WWTextInputSingle
				/// @param   {Real} _vector : The direction to move the cursor.
				/// @param   {Bool} _shift  : Whether to extend the selection (shift key held).
				/// @returns {undefined}
				#endregion
				static __move_cursor_paged_offset__ = function(_vector, _shift) {
					if (_vector == 0) return;
					
					// Current cursor position and line
					var _cursor_index = cursor.get_index();
					var _current_line = renderer.get_line_from_index(_cursor_index);
					var _line_count = renderer.get_line_count();
					
					// Compute target y offset based on page height and direction
					var _current_y_offset = renderer.get_line_y_offset(_current_line);
					var _page_height = self.height * 0.75 * abs(_vector);
					var _target_y_offset = _current_y_offset + (_page_height * _vector);

					var _target_line = _current_line;
					
					if (_vector > 0) {
						// Page down: walk forward until we reach or pass target y
						var _line_index = _current_line + 1;
						while (_line_index < _line_count) {
							var _line_y_offset = renderer.get_line_y_offset(_line_index);
							_target_line = _line_index;
							
							if (_line_y_offset >= _target_y_offset) {
								break;
							}
							
							_line_index++;
						}
					}
					else {
						// Page up: walk backward until we reach or pass target y
						var _line_index = _current_line - 1;
						while (_line_index >= 0) {
							var _line_y_offset = renderer.get_line_y_offset(_line_index);
							_target_line = _line_index;

							if (_line_y_offset <= _target_y_offset) {
								break;
							}
							
							_line_index--;
						}
					}
					
					// Snap to the chosen line, keep the horizontal offset from cursor_last_width
					var _final_y_offset = renderer.get_line_y_offset(_target_line);
					var _new_index = renderer.get_index_from_xy(x + cursor_last_width, y + _final_y_offset);
					__cursor_set_index_synced__(_new_index, _shift, true, false);
				}
				
			#endregion
			
			#region Input Handling
				
				#region jsDoc
				/// @func    __compute_word_boundaries__
				/// @desc    Given a line of text and a cursor index (1-indexed), computes the word boundaries
				///          based on a shared list of word breakers. Returns a struct containing:
				///              { x_start, x_end }
				///          where x_start is the start index and x_end is the end index of the word.
				/// @param   {Real} index : The glyph index.
				/// @param   {Bool} include_whitespaces : (Optional) If true, adjust boundaries to exclude adjacent whitespace. Default is false.
				/// @returns {Struct} A struct with properties index_start and index_end.
				/// @self    WWTextBase
				#endregion
				static __compute_word_boundaries__ = function(_index, _include_whitespace = false) {
					// Reusable return struct: global buffer indices (inclusive).
					static __struct = { index_start: 0, index_end: 0 };
					
					// Shared word breakers constant.
				    static __word_breakers = "\n\r\t ,.;:?!><#$%&'()*+-/=@[\]^`{|}~¡¢£¤¥¦§¨©«¬­®¯°±´¶·¸»¿×÷";
					static __white_spaces = "\n\r\t ";
					
					// Basic safety: if renderer has no lines, just collapse.
					var _line_count = renderer.get_line_count();
					if (_line_count <= 0) {
						__struct.index_start = _index;
						__struct.index_end   = _index;
						return __struct;
					}
					
					// Map global index -> line index.
					var _line_index = renderer.get_line_from_index(_index);
					if (_line_index < 0) {
						_line_index = 0;
					}
					if (_line_index >= _line_count) {
						_line_index = _line_count - 1;
					}
					
					// Get the text for this line.
					var _line_text = renderer.get_line_text(_line_index);
					if (is_undefined(_line_text)) {
						__struct.index_start = _index;
						__struct.index_end   = _index;
						return __struct;
					}
					
					var _text_length = string_length(_line_text);
					
					// Empty line: the word span collapses to the given index.
					if (_text_length <= 0) {
						__struct.index_start = _index;
						__struct.index_end   = _index;
						return __struct;
					}
					
					// Convert global buffer index to a 1-based character position on this line.
					// Assumption: get_line_index_start returns the global index of the first char on the line.
					var _line_start_index = renderer.get_line_index_start(_line_index);
					if (is_undefined(_line_start_index)) {
						_line_start_index = 0;
					}
					
					var _local_char_pos = (_index - _line_start_index) + 1;
					
					// Clamp into [1, _text_length] so string_char_at is safe.
					if (_local_char_pos < 1) {
						_local_char_pos = 1;
					}
					if (_local_char_pos > _text_length) {
						_local_char_pos = _text_length;
					}
					
					// Character under the cursor on this line.
					var _current_char = string_char_at(_line_text, _local_char_pos);
					
					// Decide which class of characters we are spanning.
					var _allowed_set;
					if (string_pos(_current_char, __word_breakers) == 0) {
						// Normal word: span characters that are NOT in __word_breakers.
						_allowed_set = undefined;
					}
					else {
						// Current char is a breaker.
						if (_current_char == " " || _current_char == chr(9)) {
							// Space or tab: span only spaces and tabs.
							_allowed_set = " " + chr(9);
						}
						else {
							// Other breaker: span any character that is in __word_breakers.
							_allowed_set = __word_breakers;
						}
					}
					
					// Start and end character positions (1-based, inclusive).
					var _start_pos = _local_char_pos;
					var _end_pos   = _local_char_pos;
					
					if (is_undefined(_allowed_set)) {
						// Normal word: expand until we hit a breaker.
						
						// Scan left: include characters while the previous char is NOT a breaker.
						while (_start_pos > 1) {
							var _char_prev = string_char_at(_line_text, _start_pos - 1);
							if (string_pos(_char_prev, __word_breakers) > 0) {
								break;
							}
							_start_pos -= 1;
						}
						
						// Scan right: include characters while the next char is NOT a breaker.
						while (_end_pos < _text_length) {
							var _char_next = string_char_at(_line_text, _end_pos + 1);
							if (string_pos(_char_next, __word_breakers) > 0) {
								break;
							}
							_end_pos += 1;
						}
					}
					else {
						// Breaker or whitespace run: expand across characters that ARE in _allowed_set.
						
						// Scan left.
						while (_start_pos > 1) {
							var _char_prev_allowed = string_char_at(_line_text, _start_pos - 1);
							if (string_pos(_char_prev_allowed, _allowed_set) == 0) {
								break;
							}
							_start_pos -= 1;
						}
						
						// Scan right.
						while (_end_pos < _text_length) {
							var _char_next_allowed = string_char_at(_line_text, _end_pos + 1);
							if (string_pos(_char_next_allowed, _allowed_set) == 0) {
								break;
							}
							_end_pos += 1;
						}
					}
					
					// Optional extension: include adjacent whitespace around the span.
					if (_include_whitespace) {
						
						// Extend left while previous characters are whitespace.
						while (_start_pos > 1) {
							var _char_prev_white = string_char_at(_line_text, _start_pos - 1);
							if (string_pos(_char_prev_white, __white_spaces) == 0) {
								break;
							}
							_start_pos -= 1;
						}
						
						// Extend right while next characters are whitespace.
						while (_end_pos < _text_length) {
							var _char_next_white = string_char_at(_line_text, _end_pos + 1);
							if (string_pos(_char_next_white, __white_spaces) == 0) {
								break;
							}
							_end_pos += 1;
						}
					}
					
					// Map line-local character positions back to global buffer indices.
					var _index_start = _line_start_index + (_start_pos - 1);
					var _index_end   = _line_start_index + _end_pos;
					
					__struct.index_start = _index_start;
					__struct.index_end   = _index_end;
					return __struct;
				};
				
				#region jsDoc
			    /// @func    __insert_string_at_cursor__()
			    /// @desc    Inserts a new string at the cursor position, respecting allowed characters.
			    /// @self    WWTextInputSingle
			    /// @param   {String} _str : The string to insert.
			    /// @returns {undefined}
			    #endregion
				static __insert_string_at_cursor__ = function(_str) {
				    // sanitize input
				    var _new_str = buffer.__filter_allowed__(_str);
				    
					var _str_byte_len = string_byte_length(_new_str);
					
					__delete_selection_if_any__(true, true);
					
					var _index = cursor.get_index();
					var _buffer_index = renderer.get_glyph_buffer_index(_index);
					
					// insert the text
					buffer.insert(_buffer_index, _new_str);
					
					__force_rebuild__();
					
					var _new_index = renderer.get_index_from_buffer_index(_buffer_index + _str_byte_len)
					__cursor_set_index_synced__(_new_index);
				}
				
				#region jsDoc
				/// @func    __update_word_selection_drag__
				/// @desc    Updates the word selection during a mouse drag after a double-click.
				///          Uses the renderer to convert GUI coordinates into a buffer index,
				///          then expands that index to full word boundaries using
				///          __compute_word_boundaries__. The selection is extended from the
				///          original anchor word to the current word span, including intermediate
				///          whitespace.
				/// @self    WWTextBase
				/// @returns {undefined}
				#endregion
				static __update_word_selection_drag__ = function() {
	
					// Get current mouse coordinates in GUI space.
					var _mouse_x_gui = device_mouse_x_to_gui(0);
					var _mouse_y_gui = device_mouse_y_to_gui(0);
	
					// Convert GUI coordinates to a global buffer index.
					var _index = renderer.get_index_from_xy(_mouse_x_gui, _mouse_y_gui);
	
					// Compute word bounds around the current index.
					// We include whitespace so dragging between words selects continuous spans.
					var _bounds = __compute_word_boundaries__(_index, false);
					var _word_start_index = _bounds.index_start;
					var _word_end_index   = _bounds.index_end; // exclusive
	
					// Anchor data set on double-click.
					var _selection_start_index = min(__word_anchor_start__, _word_start_index);
					var _selection_end_index   = max(__word_anchor_end__, _word_end_index);
					
					
					var _cursor_index = _selection_end_index;
					if (_index < __word_anchor_start__) {
						_cursor_index = _selection_start_index;
					}
					
					
					// Update cursor and highlight using the new indices.
					cursor.set_index(_cursor_index);
					cursor.set_highlight_active(true);
					cursor.set_highlight_start_index(_selection_start_index);
					cursor.set_highlight_end_index(_selection_end_index);
					cursor_last_width = renderer.get_x_from_index(_cursor_index);
					__history_update_latest_cursor__();
				};
				
				#region jsDoc
			    /// @func    __clipboard_get_text__()
			    /// @desc    Retrieves text from the clipboard for pasting into the input field.
			    /// @self    WWTextInputSingle
			    /// @returns {String}
			    #endregion
			    static __clipboard_get_text__ = function() {
					var _pasted_string = "";
					
			        if (os_browser == browser_not_a_browser)
					&& (os_type != os_operagx) {
			            if (clipboard_has_text()) {
			                _pasted_string = clipboard_get_text();
			            }
			        }
					else {
			            if (js_clipboard_has_text_()) {
			                _pasted_string = js_clipboard_get_text();
			            }
			        }
					
			        return _pasted_string;
			    }
				
				#region jsDoc
			    /// @func    __clipboard_set_text__()
			    /// @desc    Sets the clipboard text.
			    /// @self    WWTextInputSingle
			    /// @returns {String}
			    #endregion
			    static __clipboard_set_text__ = function(_str) {
			        if (os_browser == browser_not_a_browser)
					&& (os_type != os_operagx) {
			            clipboard_set_text(_str);
			        }
					else {
			            if (js_clipboard_has_text_()) {
			                js_clipboard_set_text(_str);
			            }
			        }
			    }
				
			#endregion
			
			#region Undo / Redo
				
				#region jsDoc
				/// @func    __history_record_create__()
				/// @desc    Constructor for an undo/redo snapshot.
				/// @param   {String} _content       : Full text content.
				/// @param   {Real}   _cursor_index  : Global cursor index.
				/// @returns {Struct} A history snapshot.
				#endregion
				static __history_record_create__ = function(_content, _cursor_index) constructor {
				    content = _content;
				    cursor  = _cursor_index;
				};
				
				#region jsDoc
				/// @func    __history_add_record__()
				/// @desc    Captures a new snapshot and pushes it to the undo history.
				/// @returns {undefined}
				#endregion
				static __history_add_record__ = function() {

				    var _next_index = __historic_records_loc__ + 1;

				    // If not at end of history, truncate forward history
				    if (_next_index < array_length(__historic_records__)) {
				        array_resize(__historic_records__, _next_index);
				    }

				    // Create new snapshot
				    var _record = new __history_record_create__(
				        buffer.get_text(),
				        cursor.get_index()
				    );

				    array_push(__historic_records__, _record);

				    // Enforce max history limit
				    if (array_length(__historic_records__) > __history_records_limit__) {
				        array_delete(__historic_records__, 0, 1);
				        _next_index -= 1;
				    }

				    __historic_records_loc__ = _next_index;
				};
				
				#region jsDoc
				/// @func    __history_update_latest_cursor__()
				/// @desc    Updates the most recent snapshot’s cursor field.
				/// @returns {undefined}
				#endregion
				static __history_update_latest_cursor__ = function() {
				    __historic_records__[__historic_records_loc__].cursor = cursor.get_index();
				};
				
				#region jsDoc
				/// @func    __history_jump__()
				/// @desc    Moves through undo/redo history by a signed offset
				///          and restores the corresponding snapshot.
				/// @param   {Real} _change : Negative=undo, Positive=redo.
				/// @returns {undefined}
				#endregion
				static __history_jump__ = function(_change) {

				    var _target = __historic_records_loc__ + _change;

				    // Bounds check
				    if (_target < 0 || _target >= array_length(__historic_records__)) {
				        return;
				    }

				    var _record = __historic_records__[_target];

				    buffer.set_text(_record.content);
				    cursor.set_index(_record.cursor);
				    cursor.set_highlight_start_index(_record.cursor);
				    cursor.set_highlight_end_index(_record.cursor);
					
				    __historic_records_loc__ = _target;

				    cursor.set_highlight_active(false);
				};
				
			#endregion
			
			static __force_rebuild__ = function(){
				buffer.__mark_dirty__();
				cursor.__mark_dirty__();
				renderer.__mark_dirty__();
				renderer.__ensure_layout__();
				cursor.__update_gui_position__()
			}
			
			static __get_renderer__ = function(){
				return renderer;
			}
			
			#region jsDoc
			/// @func    __cursor_set_index_synced__
			/// @desc    Sets cursor index, syncs selection rules, and optionally updates sticky x (cursor_last_width).
			/// @param   {Real} _new_index
			/// @param   {Bool} _shift_select
			/// @param   {Bool} _update_history
			/// @param   {Bool} _update_width
			/// @returns {Real}
			#endregion
			static __cursor_set_index_synced__ = function(_new_index, _shift_select = false, _update_history = true, _update_width = true) {
				
				var _old_index = cursor.get_index();
			    cursor.set_index(_new_index);

			    if (_shift_select) {
			        if (!cursor.get_highlight_active()) {
			            cursor.set_highlight_start_index(_old_index);
			            cursor.set_highlight_end_index(_new_index);
			            cursor.set_highlight_active(true);
			        }
			        cursor.set_highlight_end_index(_new_index);
			        cursor.set_highlight_active(true);
			    }
			    else {
			        cursor.set_highlight_active(false);
			        cursor.set_highlight_start_index(_new_index);
			        cursor.set_highlight_end_index(_new_index);
			    }

			    if (_update_width) {
			        cursor_last_width = renderer.get_x_from_index(_new_index);
			    }

			    if (_update_history) {
			        __history_update_latest_cursor__();
			    }
				
			};

			
			#region jsDoc
			/// @func    __delete_selection_if_any__
			/// @desc    If a highlight selection exists, erase it from the buffer and place the cursor.
			/// @param   {Bool} _force_rebuild
			/// @param   {Bool} _push_history
			/// @returns {Bool} True if something was deleted, false otherwise
			#endregion
			static __delete_selection_if_any__ = function(_force_rebuild = true, _push_history = true) {
			    if (!cursor.get_highlight_active()) return false;

			    var _start_index = cursor.get_highlight_start_index();
			    var _end_index = cursor.get_highlight_end_index();

			    var _buffer_start = renderer.get_buffer_index_from_index(_start_index);
			    var _buffer_end = renderer.get_buffer_index_from_index(_end_index);

			    buffer.erase(_buffer_start, _buffer_end);

			    cursor.set_highlight_active(false);

			    var _new_index = min(_start_index, _end_index);
			    __cursor_set_index_synced__(_new_index);

			    if (_force_rebuild) {
			        __force_rebuild__();
			    }
			    if (_push_history) {
			        __history_add_record__();
			    }

			    return true;
			};

		#endregion
		
    #endregion
	
}
