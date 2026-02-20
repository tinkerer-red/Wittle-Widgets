#region jsDoc
/// @func    WWTextField()
/// @desc    Base text field component providing common functionality: text storage, layout/render hook, and
///         cursor + selection state.
///         By default, it is read-only.
/// @returns {Struct.WWTextField}
#endregion
function WWTextField() : WWCore() constructor {
	debug_name = "WWTextBase";
	
	#region Components
		
		hotkeys  = new WWHotkeyManager(); //doesnt need to be added as a child
		buffer   = new WWTextBuffer();
		renderer = new WWTextRenderer();
		
		buffer  .__set_textbox__(self);
		renderer.__set_textbox__(self);
		
		add([buffer, renderer]);
		
		// Multi-cursor state (data-only records)
		__cursors__ = [ __cursor_record_create__(0) ];
		__cursor_active__ = 0;
		// Multi-cursor mode toggle: when false, navigation/editing behaves like a single-cursor field.
		multi_cursor_enabled = true;
		// Per-cursor sticky x (for up/down + page up/down) lives on each cursor record as `.sticky_px`.
		
		// Cursor visuals are owned by the textfield, not a cursor object.
		__cursor_visible__ = true;
		__cursor_color__ = #FFFFFF;
		__highlight_color__ = #0A68D8;
		
		// Multi-selection undo (Ctrl+U): stores prior cursor/selection states.
		// Selection history behaves like a standard undo/redo list: an array of snapshots + a cursor position.
		__selection_records__ = [];
		__selection_records_loc__ = -1;
		// Multi-click grouping: double/triple-click should undo as ONE step (back to state before first click).
		__selection_multiclick_anchor__ = undefined;
		__selection_multiclick_anchor_valid__ = false;
		__selection_multiclick_anchor_time__ = -1;
		__selection_multiclick_anchor_records_len__ = 0;
		__selection_multiclick_anchor_records_loc__ = -1;
		__selection_records_limit__ = 32;
		
		__cursor_blink_start_ms__ = current_time;
		__cursor_blink_period_ms__ = 500;
		__cursor_blink_show_ms__ = 250;
		
	#endregion
	
	#region Public
		
		#region Builder Functions
			
			#region jsDoc
			/// @func    set_size()
			/// @desc    Sets the text field size. This updates the renderer size and marks the size as user-preferred
			///          so future internal layout updates won't override it.
			/// @self    WWTextField
			/// @param   {Real} width : Width in GUI pixels.
			/// @param   {Real} height : Height in GUI pixels.
			/// @returns {Struct.WWTextField}
			#endregion
			static set_size = function(_width, _height) {
				renderer.set_size(_width, _height);
				__size_set__ = true;
				__set_size__(_width, _height);
				return self;
			}
			
			#region Text
				
				#region jsDoc
				/// @func	set_text()
				/// @desc	Sets the main text content to display in the component. This text is selectable by the user.
				/// @self	WWTextField
				/// @param   {String} text : The text to display.
				/// @returns {Struct.WWTextField}
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
				/// @desc	Sets the placeholder/caption text displayed when the text field is empty.
				///         This text is not selectable or editable by the user. Also affects how consoles display a header for the on-screen keyboard.
				/// @self	WWTextField
				/// @param   {String} text : The caption text to display.
				/// @returns {Struct.WWTextField}
				#endregion
				static set_caption = function(_text = "") {
					renderer.set_caption(_text);
					return self;
				}
				#region jsDoc
				/// @func	set_text_font()
				/// @desc	Sets the font used for rendering text.
				/// @self	WWTextField
				/// @param   {Asset.GMFont} font : The font asset to use.
				/// @returns {Struct.WWTextField}
				#endregion
				static set_text_font = function(_font = fGUIDefault) {
					renderer.set_font(_font);
					return self;
				}
				#region jsDoc
				/// @func	set_text_color()
				/// @desc	Sets the font color used for rendering the text.
				/// @self	WWTextField
				/// @param   {Constant.Color} color : The color to use.
				/// @returns {Struct.WWTextField}
				#endregion
				static set_text_color = function(_color = #D9D9D9) {
					renderer.set_text_color(_color);
					return self;
				}
				#region jsDoc
				/// @func    set_text_alpha()
				/// @desc    Sets the text alpha used for rendering the text.
				/// @self    WWTextField
				/// @param   {Real} alpha : The alpha to use.
				/// @returns {Struct.WWTextField}
				#endregion
				static set_text_alpha = function(_alpha = 1) {
					renderer.set_text_alpha(_alpha)
					return self;
				}
				
				#region jsDoc
				/// @func   set_wrap_enabled()
				/// @desc   Sets whether word wrapping is enabled. When enabled, words will wrap to the next line.
				/// @self   WWTextField
				/// @param  {Bool} should_wrap
				/// @returns {Struct.WWTextField}
				#endregion
				static set_wrap_enabled = function(_should_wrap) {
					renderer.set_wrap_enabled(_should_wrap);
					return self;
				};
				
				#region jsDoc
				/// @func   set_line_sep()
				/// @desc   Sets the extra spacing between wrapped lines (in pixels).
				/// @self   WWTextField
				/// @param  {Real} line_sep_pixels
				/// @returns {Struct.WWTextField}
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
			/// @self    WWTextField
			/// @param   {Bool} bool : If the text is read only.
			/// @returns {Struct.WWTextField}
			#endregion
			static set_read_only = function(_bool = false) {
				is_read_only = _bool;
				__cursor_visible__ = !_bool;
				return self;
			}
			
			#region jsDoc
			/// @func   set_allowed_char()
			/// @desc   Sets the allowed characters to be used in this textbox. 
			///         If undefined, the allowed characters are generated from the current font.
			///         Will also infer and set keyboard type if not already user-defined.
			/// @self   WWTextField
			/// @param  {String} allowed_char : A string of allowed characters (optional).
			/// @returns {Struct.WWTextField}
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
			/// @self   WWTextField
			/// @param  {Constant.VirtualKeyboardType} keyboard_type : Which keyset will be available on the virtual keyboard (optional).
			/// @returns {Struct.WWTextField}
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
			/// @self   WWTextField
			/// @param  {Bool} enabled : Wheather pressing enter will submit the text.
			/// @returns {Struct.WWTextField}
			#endregion
			static set_enter_submits_text = function(_enabled = false) {
				enter_submits_text = _enabled;
				return self;
			}
			
			#region jsDoc
			/// @func   set_tab_exits_text()
			/// @desc   Sets if pressing tab will exit editing text,
			///         false will result in attempting to insert the tab glyph `\t`
			/// @self   WWTextField
			/// @param  {Bool} enabled : Wheather pressing tab will exit the editing of text.
			/// @returns {Struct.WWTextField}
			#endregion
			static set_tab_exits_text = function(_enabled) {
				tab_exits_text = _enabled;
				return self;
			}
			
			#endregion
			
			#region Cursor
				
				#region jsDoc
				/// @func	set_cursor_color()
				/// @desc	Sets the caret (cursor) color.
				/// @self	WWTextField
				/// @param   {Constant.Color} color : The caret color.
				/// @returns {Struct.WWTextField}
				#endregion
				static set_cursor_color = function(_color = #FFFFFF) {
					__cursor_color__ = _color;
					return self;
				}
				#region jsDoc
				/// @func	set_highlight_color()
				/// @desc	Sets the color for the selection highlight.
				/// @self	WWTextField
				/// @param   {Constant.Color} color : The highlight color.
				/// @returns {Struct.WWTextField}
				#endregion
				static set_highlight_color = function(_color = #0A68D8) {
					__highlight_color__ = _color;
					return self;
				}
			
				#region jsDoc
				/// @func	set_multi_cursor_enabled()
				/// @desc	Enables/disables multi-cursor behavior. When disabled, any existing multi-cursor state is collapsed to a single cursor.
				/// @self	WWTextField
				/// @param	{Bool} enabled : Whether multi-cursor behavior is enabled.
				/// @returns {Struct.WWTextField}
				#endregion
				static set_multi_cursor_enabled = function(_enabled = true) {
					multi_cursor_enabled = _enabled;
					if (!multi_cursor_enabled && array_length(__cursors__) > 1) {
						__cursors_clear_to_single__(__cursor_get_index__());
					}
					return self;
				}
				
				#region jsDoc
				/// @func    set_cursor_index()
				/// @desc    Sets the active cursor index (0-based character index into the text buffer).
				/// @self    WWTextField
				/// @param   {Real} index
				/// @returns {Undefined}
				#endregion
				static set_cursor_index = function(_index) {
					return __cursor_set_index_synced__(_index);
				}
				#region jsDoc
				/// @func    set_cursor_highlight_start_index()
				/// @desc    Sets the selection start index for the active cursor.
				/// @self    WWTextField
				/// @param   {Real} index
				/// @returns {Struct.WWTextField}
				#endregion
				static set_cursor_highlight_start_index = function(_index) {
					__cursor_set_highlight_start_index__(_index);
					return self;
				}
				#region jsDoc
				/// @func    set_cursor_highlight_end_index()
				/// @desc    Sets the selection end index for the active cursor.
				/// @self    WWTextField
				/// @param   {Real} index
				/// @returns {Struct.WWTextField}
				#endregion
				static set_cursor_highlight_end_index = function(_index) {
					__cursor_set_highlight_end_index__(_index);
					return self;
				}
				
				//Renderer
				#region jsDoc
				/// @func    set_cursor_col()
				/// @desc    Sets the active cursor column (0-based) on the current renderer layout.
				/// @self    WWTextField
				/// @param   {Real|Undefined} col
				/// @returns {Struct.WWTextField}
				#endregion
				static set_cursor_col = function(_col = undefined) {
					__cursor_set_col__(_col);
					return self;
				}
				#region jsDoc
				/// @func    set_cursor_line()
				/// @desc    Sets the active cursor line (0-based) on the current renderer layout.
				/// @self    WWTextField
				/// @param   {Real|Undefined} line
				/// @returns {Struct.WWTextField}
				#endregion
				static set_cursor_line = function(_line = undefined) {
					__cursor_set_line__(_line);
					return self;
				}
				#region jsDoc
				/// @func    set_cursor_highlight_start_line()
				/// @desc    Sets the selection start line (0-based) for the active cursor.
				/// @self    WWTextField
				/// @param   {Real|Undefined} line
				/// @returns {Struct.WWTextField}
				#endregion
				static set_cursor_highlight_start_line = function(_line = undefined) {
					__cursor_set_highlight_start_line__(_line);
					return self;
				}
				#region jsDoc
				/// @func    set_cursor_highlight_start_col()
				/// @desc    Sets the selection start column (0-based) for the active cursor.
				/// @self    WWTextField
				/// @param   {Real|Undefined} col
				/// @returns {Struct.WWTextField}
				#endregion
				static set_cursor_highlight_start_col = function(_col = undefined) {
					__cursor_set_highlight_start_col__(_col);
					return self;
				}
				#region jsDoc
				/// @func    set_cursor_highlight_end_line()
				/// @desc    Sets the selection end line (0-based) for the active cursor.
				/// @self    WWTextField
				/// @param   {Real|Undefined} line
				/// @returns {Struct.WWTextField}
				#endregion
				static set_cursor_highlight_end_line = function(_line = undefined) {
					__cursor_set_highlight_end_line__(_line);
					return self;
				}
				#region jsDoc
				/// @func    set_cursor_highlight_end_col()
				/// @desc    Sets the selection end column (0-based) for the active cursor.
				/// @self    WWTextField
				/// @param   {Real|Undefined} col
				/// @returns {Struct.WWTextField}
				#endregion
				static set_cursor_highlight_end_col = function(_col = undefined) {
					__cursor_set_highlight_end_col__(_col);
					return self;
				}
				
				//GUI
				#region jsDoc
				/// @func    set_cursor_xy()
				/// @desc    Sets the active cursor index to the nearest glyph to the provided GUI coordinates.
				/// @self    WWTextField
				/// @param   {Real} x
				/// @param   {Real} y
				/// @returns {Undefined}
				#endregion
				static set_cursor_xy = function(_x, _y) {
					var _index = renderer.get_index_from_xy(_x, _y);
					return __cursor_set_index_synced__(_index);
				}
				
			#endregion
			
			#region Syntax Highlight
				
				#region jsDoc
                /// @func   set_text_processor()
                /// @desc   Sets an optional text processor callback. The processor receives
                ///         a raw input string and may return a processed output string and
                ///         span array for layout/rendering.
                ///
                ///         Expected return values:
                ///         - { text: String, spans: Array }
                ///         - [String, Array]
                ///         - String (text only, spans will be defaulted)
                ///
                ///         Returning undefined disables processing for this build.
				/// @self   WWTextField
				/// @param  {Function} processor_fn
				/// @returns {Struct.WWTextField}
                #endregion
                static set_text_processor = function(_processor_fn) {
					renderer.set_text_processor(_processor_fn);
					return self;
				}
				
			#endregion
			
			#region jsDoc
			/// @func    set_renderer()
			/// @desc    Assign a text renderer to this textbox.
			///          Provide a renderer constructor (called with no args).
			///          When swapped:
			///          - old renderer is detached (set_active(false), removed from children if supported)
			///          - new renderer is attached, positioned to (0,0) within textbox content area
			/// @self    WWTextField
			/// @param   {Function} renderer_constructor
			/// @returns {Struct.WWTextField}
			#endregion
			static set_renderer = function(_renderer_constructor) {
				var _old_renderer = renderer;
				
				//if same instance early out
				if (instanceof(_old_renderer) == script_get_name(_renderer_constructor)) {
					return self
				}
				
				_old_renderer.__cleanup__();
				
				
				// Create or assign new
			    var _new_renderer = new _renderer_constructor();
				renderer = _new_renderer;
				
			    // Attach
			    _new_renderer.__set_textbox__(self);
				_new_renderer.set_offset(0, 0);
			    _new_renderer.set_size(width, height);
			    _new_renderer.set_active(__is_active__);
			    
				// Add as child so it receives WW events/draw
				remove(_old_renderer);
			    add(_new_renderer);
			    
			    return self;
			};

		#endregion
		
		#region Events
			
			events.select    = variable_get_hash("select"); //triggered when the component gets focus, this commonly occurs when the mouse is clicked down on it.
			#region jsDoc
			/// @func    on_select()
			/// @desc    Registers a listener for when the text field is selected/focused.
			/// @self    WWTextField
			/// @param   {Function} func : Callback invoked with event data.
			/// @returns {Struct.WWTextField}
			#endregion
			static on_select = function(_func) {
				add_event_listener(events.select, _func);
				return self;
			}
			events.copy    = variable_get_hash("copy"); //triggered when the component gets focus, this commonly occurs when the mouse is clicked down on it.
			#region jsDoc
			/// @func    on_copy()
			/// @desc    Registers a listener for when the text field performs a copy operation.
			/// @self    WWTextField
			/// @param   {Function} func : Callback invoked with event data.
			/// @returns {Struct.WWTextField}
			#endregion
			static on_copy = function(_func) {
				add_event_listener(events.copy, _func);
				return self;
			}
			events.paste    = variable_get_hash("paste"); //triggered when the component gets focus, this commonly occurs when the mouse is clicked down on it.
			#region jsDoc
			/// @func    on_paste()
			/// @desc    Registers a listener for when the text field performs a paste operation.
			/// @self    WWTextField
			/// @param   {Function} func : Callback invoked with event data.
			/// @returns {Struct.WWTextField}
			#endregion
			static on_paste = function(_func) {
				add_event_listener(events.paste, _func);
				return self;
			}
			events.change    = variable_get_hash("change"); //triggered when the component gets focus, this commonly occurs when the mouse is clicked down on it.
			#region jsDoc
			/// @func    on_change()
			/// @desc    Registers a listener for when the text content changes.
			/// @self    WWTextField
			/// @param   {Function} func : Callback invoked with event data.
			/// @returns {Struct.WWTextField}
			#endregion
			static on_change = function(_func) {
				add_event_listener(events.change, _func);
				return self;
			}
			events.submit    = variable_get_hash("submit"); //triggered when the component gets focus, this commonly occurs when the mouse is clicked down on it.
			#region jsDoc
			/// @func    on_submit()
			/// @desc    Registers a listener for when the text field submits (typically Enter when `enter_submits_text` is enabled).
			/// @self    WWTextField
			/// @param   {Function} func : Callback invoked with event data.
			/// @returns {Struct.WWTextField}
			#endregion
			static on_submit = function(_func) {
				add_event_listener(events.submit, _func);
				return self;
			}
			events.cursor_move = variable_get_hash("cursor_move"); //triggered when the component gets focus, this commonly occurs when the mouse is clicked down on it.
			#region jsDoc
			/// @func    on_cursor_move()
			/// @desc    Registers a listener for when the caret/selection changes due to cursor movement.
			/// @self    WWTextField
			/// @param   {Function} func : Callback invoked with event data.
			/// @returns {Struct.WWTextField}
			#endregion
			static on_cursor_move = function(_func) {
				add_event_listener(events.cursor_move, _func);
				return self;
			}
			
			on_pressed(function(_data) {
				// Capture a pre-click selection snapshot so single/double/triple-click can undo as ONE step.
				// Important: do NOT re-capture on follow-up clicks in a multi-click sequence.
				if (multi_cursor_enabled) {
					var _window = 1_000/3;
					var _is_followup_click = (__selection_multiclick_anchor_valid__ && (current_time - __selection_multiclick_anchor_time__ < _window));
					if (!_is_followup_click) {
						__selection_multiclick_anchor__ = __cursors_clone_state__();
						__selection_multiclick_anchor_valid__ = true;
						__selection_multiclick_anchor_time__ = current_time;
						__selection_multiclick_anchor_records_len__ = array_length(__selection_records__);
						__selection_multiclick_anchor_records_loc__ = __selection_records_loc__;
					}
				}

				// get focus
				if (current_time - __last_click_time_double__ < 1_000/3)
				//|| (current_time - __last_click_time_single__ < 1_000/3) //leave this here as it's actively preventing us from producing a new cursor on multi click events.
				{
					if (multi_cursor_enabled && keyboard_check(vk_control)) {
						return;
					}
				}
				
				__check_minput__(false);
			})
			on_interact(function(_data) {
				// stay focused if mouse is on component
				if (__selection_mode__ != __WW_Text_Field_Selection_Mode.Regular) {
					__update_word_selection_drag__();
				}
				else {
					if (multi_cursor_enabled && keyboard_check(vk_control)) {
						// Prevent the immediate post-double/triple-click "next frame drag" while the mouse is still down.
						if (current_time - __last_click_time_double__ < 1_000/3) {
							return;
						}
					}
				
					__check_minput__(true);
				}
			})
			on_long_press(function(_data) {
				// Phone support for selecting text
			})
			on_released(function(_data) {
				// stay focused if mouse is on component
				__selection_mode__ = __WW_Text_Field_Selection_Mode.Regular;
				__drag_mode__ = 0;
				__drag_started__ = false;
			})
			on_double_click(function(_data) {
				var _ctrl = keyboard_check(vk_control);
				var _mx = device_mouse_x_to_gui(0);
				var _my = device_mouse_y_to_gui(0);
				var _clicked_index = renderer.get_index_from_xy(_mx, _my);
				
				// Multi-click grouping: roll back any intermediate click-records and ensure anchor is the last history state.
				if (multi_cursor_enabled) {
					__selection_records_rollback_to_multiclick_anchor__();
				}
				
				//if the line contains only a line break just put the cursor at start of line
				var _line = renderer.get_line_from_index(_clicked_index);
				if (renderer.get_line_width(_line) == 0) {
					_clicked_index = renderer.get_line_index_start(_line);
				}
				
				var _loc = __compute_word_boundaries__(_clicked_index);
				
				// Ctrl+double-click should not enter word-drag selection mode.
				if (!_ctrl) {
					if (multi_cursor_enabled) {
						__cursors_clear_to_single__(_clicked_index);
					}
					__selection_anchor_start__ = _loc.index_start;
					__selection_anchor_end__   = _loc.index_end;
					__drag_start_x__ = _mx;
					__drag_start_y__ = _my;
					__selection_mode__ = __WW_Text_Field_Selection_Mode.Word;
				}
				else {
					if (multi_cursor_enabled) {
						// Ctrl+double-click modifies the most recently appended cursor.
						__cursor_active__ = max(0, array_length(__cursors__) - 1);
					}
					__selection_mode__ = __WW_Text_Field_Selection_Mode.Regular;
				}
				
				var _target_cursor = __cursors__[__cursor_active__];
				
				_target_cursor.highlight_active = true;
				_target_cursor.highlight_start_index = _loc.index_start;
				_target_cursor.highlight_end_index = _loc.index_end;
				_target_cursor.index = _loc.index_end;
				_target_cursor.sticky_px = renderer.get_x_from_index(_loc.index_end);
				cursor_last_width = _target_cursor.sticky_px;
				
				__cursor_blink_reset__();
				__history_update_latest_cursor__();
				
				// Commit final snapshot (single undo step).
				if (multi_cursor_enabled) {
					__selection_add_record__();
					__selection_multiclick_anchor_time__ = current_time;
				}
				
			});
			on_triple_click(function(_data) {
				var _ctrl = keyboard_check(vk_control);
				var _mx = device_mouse_x_to_gui(0);
				var _my = device_mouse_y_to_gui(0);
				var _clicked_index = renderer.get_index_from_xy(_mx, _my);
				
				// Multi-click grouping: roll back any intermediate click-records and ensure anchor is the last history state.
				if (multi_cursor_enabled) {
					__selection_records_rollback_to_multiclick_anchor__();
				}
			
				// Determine which cursor/line we are expanding.
				var _index_for_line = _clicked_index;
				if (multi_cursor_enabled && _ctrl) {
					__cursor_active__ = max(0, array_length(__cursors__) - 1);
					_index_for_line = __cursor_get_index__();
				}
			
				var _line = renderer.get_line_from_index(_index_for_line);
				var _start = renderer.get_line_index_start(_line);
				var _end = renderer.get_line_index_end(_line);
			
				// Empty line: just place the caret at the line start.
				if (renderer.get_line_width(_line) == 0) {
					if (multi_cursor_enabled && _ctrl) {
						var _tc = __cursors__[__cursor_active__];
						_tc.index = _start;
						_tc.highlight_active = false;
						_tc.highlight_start_index = _start;
						_tc.highlight_end_index = _start;
						_tc.sticky_px = renderer.get_x_from_index(_start);
						cursor_last_width = _tc.sticky_px;
						__cursor_blink_reset__();
						__history_update_latest_cursor__();
						__selection_add_record__();
						__selection_multiclick_anchor_time__ = current_time;
						return;
					}
					__cursor_set_index_synced__(_start, false);
					__selection_add_record__();
					__selection_multiclick_anchor_time__ = current_time;
					return;
				}
			
				// Ctrl+triple-click should not enter word/line-drag selection mode.
				if (!_ctrl) {
					if (multi_cursor_enabled) {
						__cursors_clear_to_single__(_clicked_index);
					}
					__selection_anchor_start__ = _start;
					__selection_anchor_end__   = _end;
					__drag_start_x__ = _mx;
					__drag_start_y__ = _my;
					__selection_mode__ = __WW_Text_Field_Selection_Mode.Line;
				}
				else {
					if (multi_cursor_enabled) {
						// Ctrl+triple-click modifies the most recently appended cursor.
						__cursor_active__ = max(0, array_length(__cursors__) - 1);
					}
					__selection_mode__ = __WW_Text_Field_Selection_Mode.Regular;
				}
				
				//if it anything except the last line avoid including the line break glyph
				if (!renderer.get_line_forced_wrapped(_line) && (_line + 1 < renderer.get_line_count())) {
					_end -= 1;
				}
				
				
				// Apply selection to the active cursor record.
				var _target_cursor = __cursors__[__cursor_active__];
				_target_cursor.index = _end;
				_target_cursor.highlight_active = true;
				_target_cursor.highlight_start_index = _start;
				_target_cursor.highlight_end_index = _end;
				_target_cursor.sticky_px = renderer.get_x_from_index(_target_cursor.index);
				cursor_last_width = _target_cursor.sticky_px;
				__cursor_blink_reset__();
				__history_update_latest_cursor__();
				
				// Commit final snapshot (single undo step).
				if (multi_cursor_enabled) {
					__selection_add_record__();
					__selection_multiclick_anchor_time__ = current_time;
				}
				
			});
			
			on_focus(function(_input) {
				// If a Shift+RMB box-select drag leaves the component, on_mouse_over will stop firing.
				// Keep the gesture alive (and end it on release) while focused.
				if (multi_cursor_enabled && __box_select_active__) {
					if (mouse_check_button(mb_right)) {
						var _mxu = device_mouse_x_to_gui(0);
						var _myu = device_mouse_y_to_gui(0);
						__box_select_update__(_mxu, _myu);
					}
					else {
						__box_select_end__();
					}
				}

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
			on_mouse_over(function(_input) {
				// Shift+RMB box-like selection (RMB does not trigger on_pressed in this system).
				if (!multi_cursor_enabled) return;
				if (__box_select_active__) {
					if (mouse_check_button(mb_right)) {
						var _mxu = device_mouse_x_to_gui(0);
						var _myu = device_mouse_y_to_gui(0);
						__box_select_update__(_mxu, _myu);
					}
					else {
						__box_select_end__();
					}
					return;
				}
				if (mouse_check_button_pressed(mb_right) && keyboard_check(vk_shift)) {
					var _mxr = device_mouse_x_to_gui(0);
					var _myr = device_mouse_y_to_gui(0);
					var _mode = 0;
					if (keyboard_check(vk_control)) _mode = 1;
					else if (keyboard_check(vk_alt)) _mode = 2;
					// Also grab focus when box-select begins.
					if (!__is_input_consumer__) {
						trigger_event(events.select);
						set_focus(true);
					}
					__box_select_begin__(_mode, _mxr, _myr);
				}
			});
			on_mouse_off(function(){
				if (mouse_check_button_pressed(mb_left)) {
					set_focus(false);
				}
			})
			on_focus_exit(function(_input) {
				__cursors__ = [ __cursor_record_create__(0) ];
				__cursor_active__ = 0;
				cursor_last_width = 0;
			})
			//// Pre-draw event handler.
			//on_pre_draw(function(_input) {
			//    
			//});
			
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
				if (multi_cursor_enabled && array_length(__cursors__) > 1) {
					var _n = array_length(__cursors__);
					var _i = 0;
					repeat (_n) {
						var _c = __cursors__[_i];
						var _line = renderer.get_line_from_index(_c.index);
						var _new_index = renderer.get_line_index_start(_line);
						__cursor_set_index_synced_for__(_i, _new_index, false, true);
						_i += 1;
					}
					__history_update_latest_cursor__();
					return;
				}
				var _index = __cursor_get_index__();
				var _line = renderer.get_line_from_index(_index);
				var _new_index = renderer.get_line_index_start(_line);
				__cursor_set_index_synced__(_new_index, false);
			});
			hotkeys.register([vk_end], function() {
				if (multi_cursor_enabled && array_length(__cursors__) > 1) {
					var _last_line_index = renderer.get_line_count() - 1;
					var _n = array_length(__cursors__);
					var _i = 0;
					repeat (_n) {
						var _c = __cursors__[_i];
						var _line = renderer.get_line_from_index(_c.index);
						var _new_index = renderer.get_line_index_end(_line);
						if not (renderer.get_line_forced_wrapped(_line))
						&& (_line != _last_line_index) {
							_new_index -= 1;
						}
						__cursor_set_index_synced_for__(_i, _new_index, false, true);
						_i += 1;
					}
					__history_update_latest_cursor__();
					return;
				}
				var _index = __cursor_get_index__();
				var _line = renderer.get_line_from_index(_index);
				var _new_index = renderer.get_line_index_end(_line);
				
				var _last_line_index = renderer.get_line_count() - 1;
				
				//if literal `\n` ignore it
				if not (renderer.get_line_forced_wrapped(_line))
				&& (_line != _last_line_index) {
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
				if (multi_cursor_enabled && array_length(__cursors__) > 1) {
					var _n = array_length(__cursors__);
					var _i = 0;
					repeat (_n) {
						__cursor_set_index_synced_for__(_i, 0, false, true);
						_i += 1;
					}
					__history_update_latest_cursor__();
					return;
				}
				var _new_index = 0;
				__cursor_set_index_synced__(_new_index, false);
			});
			hotkeys.register([vk_control, vk_end], function() {
				if (multi_cursor_enabled && array_length(__cursors__) > 1) {
					var _new_index = renderer.get_glyph_count();
					var _n = array_length(__cursors__);
					var _i = 0;
					repeat (_n) {
						__cursor_set_index_synced_for__(_i, _new_index, false, true);
						_i += 1;
					}
					__history_update_latest_cursor__();
					return;
				}
				var _new_index = renderer.get_glyph_count();
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
				if (multi_cursor_enabled && array_length(__cursors__) > 1) {
					var _n = array_length(__cursors__);
					var _i = 0;
					repeat (_n) {
						var _c = __cursors__[_i];
						var _line = renderer.get_line_from_index(_c.index);
						var _new_index = renderer.get_line_index_start(_line);
						__cursor_set_index_synced_for__(_i, _new_index, true, true);
						_i += 1;
					}
					__history_update_latest_cursor__();
					return;
				}
				var _index = __cursor_get_index__();
				var _line = renderer.get_line_from_index(_index)
				var _new_index = renderer.get_line_index_start(_line);
				
				__cursor_set_index_synced__(_new_index, true);
				__cursor_set_highlight_end_index__(_new_index);
			});
			hotkeys.register([vk_shift, vk_end], function() {
				if (multi_cursor_enabled && array_length(__cursors__) > 1) {
					var _last_line_index = renderer.get_line_count() - 1;
					var _n = array_length(__cursors__);
					var _i = 0;
					repeat (_n) {
						var _c = __cursors__[_i];
						var _line = renderer.get_line_from_index(_c.index);
						var _new_index = renderer.get_line_index_end(_line);
						if not (renderer.get_line_forced_wrapped(_line))
						&& (_line != _last_line_index) {
							_new_index -= 1;
						}
						__cursor_set_index_synced_for__(_i, _new_index, true, true);
						_i += 1;
					}
					__history_update_latest_cursor__();
					return;
				}
				var _index = __cursor_get_index__();
				var _line = renderer.get_line_from_index(_index)
				var _new_index = renderer.get_line_index_end(_line);
				
				var _last_line_index = renderer.get_line_count() - 1;
				
				//if literal `\n` ignore it
				if not (renderer.get_line_forced_wrapped(_line))
				&& (_line != _last_line_index) {
					_new_index -= 1;
				}
				
				__cursor_set_index_synced__(_new_index, true);
				__cursor_set_highlight_end_index__(_new_index);
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
				if (multi_cursor_enabled && array_length(__cursors__) > 1) {
					var _n = array_length(__cursors__);
					var _i = 0;
					repeat (_n) {
						__cursor_set_index_synced_for__(_i, 0, true, true);
						_i += 1;
					}
					__history_update_latest_cursor__();
					return;
				}
				var _new_index = 0;
				__cursor_set_index_synced__(_new_index, true);
			});
			hotkeys.register([vk_control, vk_shift, vk_end], function() {
				if (multi_cursor_enabled && array_length(__cursors__) > 1) {
					var _new_index = renderer.get_glyph_count();
					var _n = array_length(__cursors__);
					var _i = 0;
					repeat (_n) {
						__cursor_set_index_synced_for__(_i, _new_index, true, true);
						_i += 1;
					}
					__history_update_latest_cursor__();
					return;
				}
				var _new_index = renderer.get_glyph_count();
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
			
			#region Multi-selection (Sublime-style)
			// Extend selection upward/downward at all carets: Ctrl+Alt+Up/Down
			hotkeys.register([vk_control, vk_alt, vk_up], function() {
				if (!multi_cursor_enabled) return;
				__selection_add_record__();
				if (__cursors_add_cursor_vertical__(-1)) {
					__selection_add_record__();
				}
			});
			hotkeys.register([vk_control, vk_alt, vk_down], function() {
				if (!multi_cursor_enabled) return;
				__selection_add_record__();
				if (__cursors_add_cursor_vertical__(1)) {
					__selection_add_record__();
				}
			});
			
			// Undo the last selection motion: Ctrl+U
			// Redo the last selection undo (if any): Ctrl+Shift+U
			hotkeys.register([vk_control, vk_shift, ord("U")], function() {
				if (!multi_cursor_enabled) return;
				__selection_jump__(1);
			});
			hotkeys.register([vk_control, ord("U")], function() {
				if (!multi_cursor_enabled) return;
				__selection_jump__(-1);
			});
			
			// Add next occurrence of selected text to selection: Ctrl+D
			hotkeys.register([vk_control, ord("D")], function() {
				if (!multi_cursor_enabled) return;
				__selection_add_record__();
				if (__cursors_add_next_occurrence__()) {
					__selection_add_record__();
				}
			});
			
			// Add all occurrences of the selected text to the selection: Alt+F3
			hotkeys.register([vk_alt, vk_f3], function() {
				if (!multi_cursor_enabled) return;
				__selection_add_record__();
				if (__cursors_add_all_occurrences__()) {
					__selection_add_record__();
				}
			});
			
			// Rotate between occurrences of selected text (single selection): Ctrl+F3
			hotkeys.register([vk_control, vk_f3], function() {
				if (!multi_cursor_enabled) return;
				__selection_add_record__();
				if (__cursor_rotate_next_occurrence__()) {
					__selection_add_record__();
				}
			});
			
			// Turn a single linear selection into a block selection (split into lines): Ctrl+Shift+L
			hotkeys.register([vk_control, vk_shift, ord("L")], function() {
				if (!multi_cursor_enabled) return;
				__selection_add_record__();
				if (__cursors_split_selection_into_lines__()) {
					__selection_add_record__();
				}
			});
			#endregion
			
			#region Deletion — Backspace, Delete, Ctrl+Delete
			#region No modifier
			hotkeys.register([vk_backspace], function() {
				if (is_read_only) return;

				// If selection exists: delete selection (this now snapshots correctly)
				if (__delete_selection_if_any__(true, true)) {
					trigger_event(events.change);
					return;
				}

				__delete_backspace_all_cursors__();
				trigger_event(events.change);
			});


			hotkeys.register([vk_delete], function() {
				if (is_read_only) return;
				
				// If selection exists: delete selection
				if (__delete_selection_if_any__(true, true)) {
					trigger_event(events.change);
					return;
				}
				
				__delete_forward_all_cursors__();
				trigger_event(events.change);
			});

			#endregion
			
			#region Ctrl Modifier
			hotkeys.register([vk_control, vk_backspace], function() {
				if (is_read_only) return;
				
				// If selection exists; normal delete
				if (__delete_selection_if_any__(true, true)) {
					trigger_event(events.change);
					return;
				}
				
				if (multi_cursor_enabled && array_length(__cursors__) > 1) {
					__delete_word_left_all_cursors__();
					trigger_event(events.change);
					return;
				}
				
				// Compute previous word boundary
				var _index = __cursor_get_index__();
				var _pointed_index = max(0, _index-1);
				
				var _bounds = __compute_word_boundaries__(_pointed_index, false);
				var _start = _bounds.index_start;
				
				var _buffer_start = buffer.get_byte_index_from_index(_start);
				var _buffer_end = buffer.get_byte_index_from_index(_index);

				buffer.erase(_buffer_start, _buffer_end);

				__cursor_set_index_synced__(_start, false, false);

				__force_rebuild__();
				__history_add_record__();
				trigger_event(events.change);
			});
			hotkeys.register([vk_control, vk_delete], function() {
				if (is_read_only) return;
				
				// Selection; normal delete
				if (__delete_selection_if_any__(true, true)) {
					trigger_event(events.change);
					return;
				}
				
				if (multi_cursor_enabled && array_length(__cursors__) > 1) {
					__delete_word_right_all_cursors__();
					trigger_event(events.change);
					return;
				}
				
				// Compute next word boundary
				var _index = __cursor_get_index__();
				var _pointed_index = min(_index+1, renderer.get_glyph_count());
				
				var _bounds = __compute_word_boundaries__(_pointed_index, false);
				var _end = _bounds.index_end;
				
				var _buffer_start = buffer.get_byte_index_from_index(_index);
				var _buffer_end   = buffer.get_byte_index_from_index(_end);
				
				buffer.erase(_buffer_start, _buffer_end);
				__force_rebuild__();
				__history_add_record__();
				__cursor_set_index_synced__(_index);
				trigger_event(events.change);
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
				///////////////////////////////////////////////////////////////////////
				// NOTE! This actually shouldnt delete anything normally and should
				// early out, at least this is the results from a few text boxes tested
				// like discord. however it makes more sense to just delete delection
				if (__delete_selection_if_any__(true, true)) {
					trigger_event(events.change);
					return;
				}
				///////////////////////////////////////////////////////////////////////
				
				if (multi_cursor_enabled && array_length(__cursors__) > 1) {
					__delete_to_line_start_all_cursors__();
					trigger_event(events.change);
					return;
				}
				
				
				// Delete until begining of line
				var _end = __cursor_get_index__();
				var _line = renderer.get_line_from_index(_end)
				var _start = renderer.get_line_index_start(_line);
				
				var _buffer_start = buffer.get_byte_index_from_index(_start);
				var _buffer_end   = buffer.get_byte_index_from_index(_end);
				buffer.erase(_buffer_start, _buffer_end);
				__cursor_set_index_synced__(_start, false, false);
				__force_rebuild__();
				__cursor_set_highlight_active__(false);
				__history_add_record__();
				trigger_event(events.change);
			});
			hotkeys.register([vk_control, vk_shift, vk_delete],    function() {
				if (is_read_only) return;
				
				// If selection exists; normal delete
				///////////////////////////////////////////////////////////////////////
				// NOTE! This actually shouldnt delete anything normally and should
				// early out, at least this is the results from a few text boxes tested
				// like discord. however it makes more sense to just delete delection
				if (__delete_selection_if_any__(true, true)) {
					trigger_event(events.change);
					return;
				}
				///////////////////////////////////////////////////////////////////////
				
				if (multi_cursor_enabled && array_length(__cursors__) > 1) {
					__delete_to_line_end_all_cursors__();
					trigger_event(events.change);
					return;
				}
				
				// Delete until end of line, preserve `\n` line breaks, and stop on force wrapped
				var _start = __cursor_get_index__();
				var _line = renderer.get_line_from_index(_start)
				var _end = renderer.get_line_index_end(_line);
				
				//if literal `\n` preserve it
				if not (renderer.get_line_forced_wrapped(_line)) {
					_end -= 1;
				}
				
				var _buffer_start = buffer.get_byte_index_from_index(_start);
				var _buffer_end   = buffer.get_byte_index_from_index(_end);
				buffer.erase(_buffer_start, _buffer_end);
				__cursor_set_index_synced__(_start, false, false);
				__cursor_set_highlight_active__(false);
				__force_rebuild__();
				__history_add_record__();
				trigger_event(events.change);
			});
			#endregion
			#endregion
			
			#region Clipboard & Edit Commands — Ctrl Combos
			hotkeys.register([vk_control, ord("A")], function() {
				var _glyph_count = renderer.get_glyph_count();
				__cursors__ = [ __cursor_record_create__(_glyph_count) ];
				__cursor_active__ = 0;
				__cursor_set_highlight_active__(true);
				__cursor_set_highlight_start_index__(0);
				__cursor_set_highlight_end_index__(_glyph_count);
				__history_update_latest_cursor__();
			});
			hotkeys.register([vk_control, ord("C")], function() {
				if (multi_cursor_enabled && array_length(__cursors__) > 1) {
					if (__cursors_copy_selections_to_clipboard__()) {
						return;
					}
				}
				var _start = __cursor_get_highlight_start_index__();
				var _end   = __cursor_get_highlight_end_index__();
				var _buffer_start = buffer.get_byte_index_from_index(_start);
				var _buffer_end   = buffer.get_byte_index_from_index(_end);
				var _string = buffer.get_substring(_buffer_start, _buffer_end);
				__clipboard_set_text__(_string);
			});
			hotkeys.register([vk_control, ord("V")], function() {
				if (is_read_only) return;
				// Paste
				var _str = __clipboard_get_text__();
				if (multi_cursor_enabled && array_length(__cursors__) > 1) {
					var _lines = __clipboard_split_lines__(_str);
					if (array_length(_lines) == array_length(__cursors__)) {
						if (__insert_lines_at_cursors__(_lines)) {
							return;
						}
					}
				}
				__insert_string_at_cursor__(_str);
			});
			hotkeys.register([vk_control, ord("X")], function() {
				if (is_read_only) return;
				
				// Multi-cursor cut: if we can multi-copy selections, cut = copy + delete selections.
				if (multi_cursor_enabled && array_length(__cursors__) > 1) {
					if (__cursors_copy_selections_to_clipboard__()) {
						if (__delete_selection_if_any__(true, true)) {
							trigger_event(events.change);
							return;
						}
						return;
					}
				}
				
				if (__cursor_get_highlight_active__()) {
					var _start = __cursor_get_highlight_start_index__();
					var _end   = __cursor_get_highlight_end_index__();
				}
				else {
					//if no selection made cut the entire line including the `\n`
					var _index = __cursor_get_index__();
					var _line = renderer.get_line_from_index(_index)
					var _start = renderer.get_line_index_start(_line);
					var _end = renderer.get_line_index_end(_line);
				}
				
				// Cut
				var _buffer_start = buffer.get_byte_index_from_index(_start);
				var _buffer_end   = buffer.get_byte_index_from_index(_end);
				var _string = buffer.get_substring(_buffer_start, _buffer_end);
				__clipboard_set_text__(_string);
				buffer.erase(_buffer_start, _buffer_end);
				
				__cursor_set_highlight_active__(false);
				
				var _new_index = min(_start, _end)
				__cursor_set_index_synced__(_new_index, false, false);
				
				__force_rebuild__();
				
				__history_add_record__();
				trigger_event(events.change);
			});
			
			hotkeys.register([vk_control, ord("Z")], function() {
				if (is_read_only) return;
				// Undo
				__history_jump__(-1);
			});
			hotkeys.register([vk_control, ord("Y")], function() {
				if (is_read_only) return;
				// Redo
				__history_jump__(1);
			});
			hotkeys.register([vk_control, vk_shift, ord("Z")], function() {
				if (is_read_only) return;
				// Redo (alternate)
				__history_jump__(1);
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
				// dialog boxes which support enter should allow for ctrl+enter toi force submit, this sh
			});
			hotkeys.register([vk_control, vk_shift, vk_enter], function() {
				if (is_read_only) return;
				// Optional: Multiline submit override
				// I have no idea if this does anything
			});
			
			hotkeys.register([vk_escape], function() {
				// Escape behavior:
				// - If we have multiple cursors (or any selection state in multi-cursor mode), collapse back to a single caret.
				// - If we're already a single caret, treat Escape as "submit + exit focus".
				if (multi_cursor_enabled && (array_length(__cursors__) > 1 || __cursor_get_highlight_active__())) {
					__selection_add_record__();
					__cursors_clear_to_single__(__cursor_get_index__());
					__selection_add_record__();
					return;
				}
				trigger_event(events.submit);
				set_focus(false);
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
			
			__is_focusable__ = true;
			is_read_only = true;
			enter_submits_text = false;
			tab_exits_text = false;
			
		#endregion
		
		#region Functions
			
			#region jsDoc
			/// @func    get_text()
			/// @desc    Returns the current text content.
			/// @self    WWTextField
			/// @returns {String}
			#endregion
			static get_text = function() {
				return buffer.get_text();
			}
			
			#region jsDoc
			/// @func    get_substring()
			/// @desc    Returns a substring from the internal text buffer.
			/// @self    WWTextField
			/// @param   {Real} start_index
			/// @param   {Real} end_index
			/// @returns {String}
			#endregion
			static get_substring = function(_start_index, _end_index) {
				return buffer.get_substring(_start_index, _end_index);
			};
			
			#region jsDoc
			/// @func    get_byte_index_from_index()
			/// @desc    Converts a character index to a byte index (UTF-8).
			/// @self    WWTextField
			/// @param   {Real} index
			/// @returns {Real}
			#endregion
			static get_byte_index_from_index = function(_index) {
				return buffer.get_byte_index_from_index(_index);
			};
			
			#region jsDoc
			/// @func    get_index_from_byte_index()
			/// @desc    Converts a byte index (UTF-8) back to a character index.
			/// @self    WWTextField
			/// @param   {Real} byte_index
			/// @returns {Real}
			#endregion
			static get_index_from_byte_index = function(_byte_index) {
				return buffer.get_index_from_byte_index(_byte_index);
			};
			
			#region jsDoc
			/// @func    get_allowed_char()
			/// @desc    Returns the current allowed character map/structure.
			/// @self    WWTextField
			/// @returns {Any}
			#endregion
			static get_allowed_char = function() {
				return buffer.get_allowed_char();
			};
			
			// --- Public API symmetry getters (demo library validation) ---
			#region jsDoc
			/// @func    get_caption()
			/// @desc    Returns the renderer caption.
			/// @self    WWTextField
			/// @returns {String}
			#endregion
			static get_caption = function() {
				return renderer.get_caption();
			};
			#region jsDoc
			/// @func    get_text_font()
			/// @desc    Returns the renderer font.
			/// @self    WWTextField
			/// @returns {Asset.GMFont}
			#endregion
			static get_text_font = function() {
				// WWTextRenderer exposes this as get_font()
				return renderer.get_font();
			};
			#region jsDoc
			/// @func    get_text_color()
			/// @desc    Returns the renderer text color.
			/// @self    WWTextField
			/// @returns {Constant.Color}
			#endregion
			static get_text_color = function() {
				return renderer.get_text_color();
			};
			#region jsDoc
			/// @func    get_text_alpha()
			/// @desc    Returns the renderer text alpha.
			/// @self    WWTextField
			/// @returns {Real}
			#endregion
			static get_text_alpha = function() {
				return renderer.get_text_alpha();
			};
			#region jsDoc
			/// @func    get_wrap_enabled()
			/// @desc    Returns whether word-wrapping is enabled.
			/// @self    WWTextField
			/// @returns {Bool}
			#endregion
			static get_wrap_enabled = function() {
				return renderer.get_wrap_enabled();
			};
			#region jsDoc
			/// @func    get_line_sep()
			/// @desc    Returns the current line separator string.
			/// @self    WWTextField
			/// @returns {String}
			#endregion
			static get_line_sep = function() {
				return renderer.get_line_sep();
			};
			#region jsDoc
			/// @func    get_read_only()
			/// @desc    Returns whether the field is read-only.
			/// @self    WWTextField
			/// @returns {Bool}
			#endregion
			static get_read_only = function() {
				return is_read_only;
			};
			#region jsDoc
			/// @func    get_keyboard_type()
			/// @desc    Returns the configured virtual keyboard type (kbv_type_*).
			/// @self    WWTextField
			/// @returns {Real}
			#endregion
			static get_keyboard_type = function() {
				return __keyboard_type__;
			};
			#region jsDoc
			/// @func    get_enter_submits_text()
			/// @desc    Returns whether Enter submits text.
			/// @self    WWTextField
			/// @returns {Bool}
			#endregion
			static get_enter_submits_text = function() {
				return enter_submits_text;
			};
			#region jsDoc
			/// @func    get_tab_exits_text()
			/// @desc    Returns whether Tab exits text editing.
			/// @self    WWTextField
			/// @returns {Bool}
			#endregion
			static get_tab_exits_text = function() {
				return tab_exits_text;
			};
			#region jsDoc
			/// @func    get_cursor_color()
			/// @desc    Returns the cursor color.
			/// @self    WWTextField
			/// @returns {Constant.Color}
			#endregion
			static get_cursor_color = function() {
				return __cursor_color__;
			};
			#region jsDoc
			/// @func    get_highlight_color()
			/// @desc    Returns the selection highlight color.
			/// @self    WWTextField
			/// @returns {Constant.Color}
			#endregion
			static get_highlight_color = function() {
				return __highlight_color__;
			};
			#region jsDoc
			/// @func    get_multi_cursor_enabled()
			/// @desc    Returns whether multi-cursor is enabled.
			/// @self    WWTextField
			/// @returns {Bool}
			#endregion
			static get_multi_cursor_enabled = function() {
				return multi_cursor_enabled;
			};
			#region jsDoc
			/// @func    get_cursor_xy()
			/// @desc    Returns the cursor position in local renderer coordinates.
			/// @self    WWTextField
			/// @returns {Struct} struct_with_x_y
			#endregion
			static get_cursor_xy = function() {
				var _idx = __cursor_get_index__();
				var _line = renderer.get_line_from_index(_idx);
				return {
					x: renderer.get_x_from_index(_idx),
					y: renderer.get_line_y_offset(_line),
				};
			};
			#region jsDoc
			/// @func    get_text_processor()
			/// @desc    Returns the active text processor used by the renderer.
			/// @self    WWTextField
			/// @returns {Any}
			#endregion
			static get_text_processor = function() {
				return renderer.get_text_processor();
			};
			
			#region Syntax Highlight (non-builder actions)
			
			#region jsDoc
			/// @func   apply_format_range()
			/// @desc   Applies formatting directly into glyph records for the logical index range.
			///         Range is [start_index, end_index) 0-based.
			///         Pass undefined for any field you do not want to change.
			/// @self   WWTextField
			/// @param  {Real} start_index
			/// @param  {Real} end_index
			/// @param  {Constant.Color|Undefined} color_value
			/// @param  {Real|Undefined} alpha_value
			/// @param  {Asset.GMFont|Undefined} font_asset
			/// @param  {Real|Undefined} style
			/// @param  {Real|Undefined} size_mul
			/// @param  {Real|Undefined} underline_value
			/// @returns {Struct.WWTextField}
			#endregion
			static apply_format_range = function(
				_start_index,
				_end_index,
				_color_value,
				_alpha_value,
				_font_asset,
				_style,
				_size_mul,
				_underline_value
			) {
				renderer.set_format_range(
					_start_index,
					_end_index,
					_color_value,
					_alpha_value,
					_font_asset,
					_style,
					_size_mul,
					_underline_value
				);
				return self;
			};
			
			#region jsDoc
			/// @func   clear_format_range()
			/// @desc   Resets glyph formatting back to renderer defaults for [start,end).
			/// @self   WWTextField
			/// @param  {Real} start_index
			/// @param  {Real} end_index
			/// @returns {Struct.WWTextField}
			#endregion
			static clear_format_range = function(_start_index, _end_index) {
				renderer.set_format_range(_start_index, _end_index);
				return self;
			};
			
			#region jsDoc
			/// @func   apply_glyph_color_range()
			/// @desc   Sets per-glyph color for the logical index range [start,end).
			/// @self   WWTextField
			/// @param  {Real} start_index
			/// @param  {Real} end_index
			/// @param  {Constant.Color} color_value
			/// @returns {Struct.WWTextField}
			#endregion
			static apply_glyph_color_range = function(_start_index, _end_index, _color_value) {
				renderer.set_format_range(_start_index, _end_index, _color_value, undefined, undefined, undefined, undefined, undefined);
				return self;
			};
			
			#region jsDoc
			/// @func   apply_glyph_alpha_range()
			/// @desc   Sets per-glyph alpha for the logical index range [start,end).
			/// @self   WWTextField
			/// @param  {Real} start_index
			/// @param  {Real} end_index
			/// @param  {Real} alpha_value
			/// @returns {Struct.WWTextField}
			#endregion
			static apply_glyph_alpha_range = function(_start_index, _end_index, _alpha_value) {
				renderer.set_format_range(_start_index, _end_index, undefined, _alpha_value, undefined, undefined, undefined, undefined);
				return self;
			};
			
			#region jsDoc
			/// @func   apply_glyph_font_range()
			/// @desc   Sets per-glyph font override for [start,end). Use -1 to clear override.
			/// @self   WWTextField
			/// @param  {Real} start_index
			/// @param  {Real} end_index
			/// @param  {Asset.GMFont|Real} font_asset_or_minus1
			/// @returns {Struct.WWTextField}
			#endregion
			static apply_glyph_font_range = function(_start_index, _end_index, _font_asset_or_minus1) {
				renderer.set_format_range(_start_index, _end_index, undefined, undefined, _font_asset_or_minus1, undefined, undefined, undefined);
				return self;
			};
			
			#region jsDoc
			/// @func   apply_glyph_style_range()
			/// @desc   Sets per-glyph style enum for [start,end).
			/// @self   WWTextField
			/// @param  {Real} start_index
			/// @param  {Real} end_index
			/// @param  {Real} style
			/// @returns {Struct.WWTextField}
			#endregion
			static apply_glyph_style_range = function(_start_index, _end_index, _style) {
				renderer.set_format_range(_start_index, _end_index, undefined, undefined, undefined, _style, undefined, undefined);
				return self;
			};
			
			#region jsDoc
			/// @func   apply_glyph_size_range()
			/// @desc   Sets per-glyph size multiplier for [start,end). Values <= 0 clamp to 1.
			/// @self   WWTextField
			/// @param  {Real} start_index
			/// @param  {Real} end_index
			/// @param  {Real} size_mul
			/// @returns {Struct.WWTextField}
			#endregion
			static apply_glyph_size_range = function(_start_index, _end_index, _size_mul) {
				renderer.set_format_range(_start_index, _end_index, undefined, undefined, undefined, undefined, _size_mul, undefined);
				return self;
			};
			
			#region jsDoc
			/// @func   apply_glyph_underline_range()
			/// @desc   Sets per-glyph underline enum for [start,end).
			/// @self   WWTextField
			/// @param  {Real} start_index
			/// @param  {Real} end_index
			/// @param  {Real} underline_value
			/// @returns {Struct.WWTextField}
			#endregion
			static apply_glyph_underline_range = function(_start_index, _end_index, _underline_value) {
				renderer.set_format_range(_start_index, _end_index, undefined, undefined, undefined, undefined, undefined, _underline_value);
				return self;
			};
			
			#endregion
			
			#region jsDoc
			/// @func    clear_text()
			/// @desc    Clears the text content and resets cursor/selection state.
			///         No-op when the field is read-only.
			/// @self    WWTextField
			/// @returns {Undefined}
			#endregion
			static clear_text = function() {
				if (is_read_only) return;

				// Nothing to do
				if (buffer.get_text() == "") {
					__cursors__ = [ __cursor_record_create__(0) ];
					__cursor_active__ = 0;
					__history_update_latest_cursor__();
					return;
				}

				buffer.clear_text();

				__cursors__ = [ __cursor_record_create__(0) ];
				__cursor_active__ = 0;

				__force_rebuild__();
				__history_add_record__();
				trigger_event(events.change);
			}
			
			#region Sizing
				
				#region jsDoc
				/// @func    get_content_width()
				/// @desc    Get the canvas width of the textbox. This is the width of the underlying region where text can be drawn.
				/// @self    WWTextField
				/// @returns {Real}
				#endregion
				static get_content_width = function() {
					return renderer.get_content_width();
				}
				#region jsDoc
				/// @func    get_content_height()
				/// @desc    Get the canvas height of the textbox. This is the height of the underlying region where text can be drawn.
				/// @self    WWTextField
				/// @returns {Real}
				#endregion
				static get_content_height = function() {
					return renderer.get_content_height();
				}
				
			#endregion
			
			#region Cursor
				
				//Buffer
				#region jsDoc
				/// @func    get_cursor_index()
				/// @desc    Returns the active cursor index (0-based character index).
				/// @self    WWTextField
				/// @returns {Real}
				#endregion
				static get_cursor_index = function() {
					return __cursor_get_index__();
				}
				#region jsDoc
				/// @func    get_cursor_highlight_start_index()
				/// @desc    Returns the selection start index for the active cursor.
				/// @self    WWTextField
				/// @returns {Real}
				#endregion
				static get_cursor_highlight_start_index = function() {
					return __cursor_get_highlight_start_index__();
				}
				#region jsDoc
				/// @func    get_cursor_highlight_end_index()
				/// @desc    Returns the selection end index for the active cursor.
				/// @self    WWTextField
				/// @returns {Real}
				#endregion
				static get_cursor_highlight_end_index = function() {
					return __cursor_get_highlight_end_index__();
				}
				
				//Renderer
				#region jsDoc
				/// @func    get_cursor_col()
				/// @desc    Returns the active cursor column (0-based) on the current renderer layout.
				/// @self    WWTextField
				/// @returns {Real}
				#endregion
				static get_cursor_col = function() {
					return renderer.get_col_from_index(__cursor_get_index__());
				}
				#region jsDoc
				/// @func    get_cursor_line()
				/// @desc    Returns the active cursor line (0-based) on the current renderer layout.
				/// @self    WWTextField
				/// @returns {Real}
				#endregion
				static get_cursor_line = function() {
					return renderer.get_line_from_index(__cursor_get_index__());
				}
				#region jsDoc
				/// @func    get_cursor_highlight_start_line()
				/// @desc    Returns the selection start line (0-based) for the active cursor.
				/// @self    WWTextField
				/// @returns {Real}
				#endregion
				static get_cursor_highlight_start_line = function() {
					return renderer.get_line_from_index(__cursor_get_highlight_start_index__());
				}
				#region jsDoc
				/// @func    get_cursor_highlight_start_col()
				/// @desc    Returns the selection start column (0-based) for the active cursor.
				/// @self    WWTextField
				/// @returns {Real}
				#endregion
				static get_cursor_highlight_start_col = function() {
					return renderer.get_col_from_index(__cursor_get_highlight_start_index__());
				}
				#region jsDoc
				/// @func    get_cursor_highlight_end_line()
				/// @desc    Returns the selection end line (0-based) for the active cursor.
				/// @self    WWTextField
				/// @returns {Real}
				#endregion
				static get_cursor_highlight_end_line = function() {
					return renderer.get_line_from_index(__cursor_get_highlight_end_index__());
				}
				#region jsDoc
				/// @func    get_cursor_highlight_end_col()
				/// @desc    Returns the selection end column (0-based) for the active cursor.
				/// @self    WWTextField
				/// @returns {Real}
				#endregion
				static get_cursor_highlight_end_col = function() {
					return renderer.get_col_from_index(__cursor_get_highlight_end_index__());
				}
				
				//Relative GUI
				#region jsDoc
				/// @func    get_cursor_x()
				/// @desc    Returns the caret x position in renderer-local GUI coordinates.
				/// @self    WWTextField
				/// @returns {Real}
				#endregion
				static get_cursor_x = function() {
					return renderer.get_x_from_index(__cursor_get_index__());
				}
				#region jsDoc
				/// @func    get_cursor_y()
				/// @desc    Returns the caret y position (line y-offset) in renderer-local GUI coordinates.
				/// @self    WWTextField
				/// @returns {Real}
				#endregion
				static get_cursor_y = function() {
					var _line = renderer.get_line_from_index(__cursor_get_index__());
					return renderer.get_line_y_offset(_line);
				}
				
			#endregion
			
			#region Renderer Geometry
				
				#region jsDoc
				/// @func    get_renderer()
				/// @desc    Returns the active renderer instance.
				/// @self    WWTextField
				/// @returns {Struct|Undefined}
				#endregion
				static get_renderer = function() {
					return renderer;
				};

				#region jsDoc
				/// @func    index_to_x()
				/// @desc    Convert a buffer index into gui x coordinate
				/// @self    WWTextField
				/// @param   {Real} index
				/// @returns {Real} x
				#endregion
				static index_to_x = function(_index) {
					return renderer.index_to_x(_index);
				};
				#region jsDoc
				/// @func    index_to_y()
				/// @desc    Convert a buffer index into gui y coordinate
				/// @self    WWTextField
				/// @param   {Real} index
				/// @returns {Real} y
				#endregion
				static index_to_y = function(_index) {
					return renderer.index_to_y(_index);
				};
				#region jsDoc
				/// @func    xy_to_index()
				/// @desc    Convert gui x,y coordinates into the nearest buffer index.
				/// @self    WWTextField
				/// @param   {Real} x
				/// @param   {Real} y
				/// @returns {Real}
				#endregion
				static xy_to_index = function(_x, _y) {
					return renderer.xy_to_index(_x, _y);
				};
			
				#region jsDoc
				/// @func    index_to_line()
				/// @desc    Convert a buffer index into a line number. Lines and columns are 0-based.
				/// @self    WWTextField
				/// @param   {Real} index
				/// @returns {Real} line
				#endregion
				static index_to_line = function(_index) {
					return renderer.index_to_line(_index);
				}
				#region jsDoc
				/// @func    index_to_col()
				/// @desc    Convert a buffer index into a column number. Lines and columns are 0-based.
				/// @self    WWTextField
				/// @param   {Real} index
				/// @returns {Real} line
				#endregion
				static index_to_col = function(_index) {
					return renderer.index_to_col(_index);
				};
				#region jsDoc
				/// @func    line_col_to_index()
				/// @desc    Convert a line and column (0-based) into a buffer index.
				/// @self    WWTextField
				/// @param   {Real} line
				/// @param   {Real} col
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
			
			__selection_mode__ = __WW_Text_Field_Selection_Mode.Regular; // regular, word, line (multi-click drag)
			__selection_anchor_start__ = 0;
			__selection_anchor_end__ = 0;
			__drag_start_x__ = 0;
			__drag_start_y__ = 0;
			__drag_deadzone_px__ = 3;
			__drag_started__ = false;
			__drag_mode__ = 0; // 0 = normal, 1 = ctrl-drag (extend selection for one cursor)
			__drag_select_cursor_index__ = 0; // cursor index used by ctrl-drag and box-select additive
			
			// Shift+Right Click box-like selection (not true monospaced box select; line-based approximation)
			__box_select_active__ = false;
			__box_select_mode__ = 0; // 0=override, 1=additive, 2=subtractive
			// Anchor lives in __drag_start_x__/__drag_start_y__. End comes from current mouse position when polled.
			__box_select_base_cursors__ = undefined; // subtractive uses a stable baseline for live cutting
			__box_select_base_cursor_active__ = 0;
			
			cursor_last_width = undefined; //The last known x position in pixels, to ensure pressing up or down multiple times doesnt deviate the cursor off from its intended "center"
			
			__historic_records_loc__ = -1;
			__historic_records__ = [];
			__history_records_limit__ = 65536; // power(2, 16); // we'll simply allow for a lot to start with, memory shouldnt be an issue but for low end devices this is here as an option
			
			//globally used in all textboxes to carry leyout information from one textbox to another, commonly used for rich text rendering, or syntax highlighting
			static __global_clipboard_container__ = {
				text: "",
			};
			
		#endregion
		
		#region Functions
			
			#region Allowing Char
			
				#region jsDoc
				/// @func    __build_allowed_char__()
				/// @ignore
				/// @desc    Returns a struct of allowed characters from the supplied font.
				/// @self    WWTextField
				/// @param   {Asset.GMFont} font : The font to build the allowed character list.
				/// @param   {Bool} include_nl : Whether to include '\n' in the allowed set.
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
				/// @func    __infer_keyboard_type__()
				/// @ignore
				/// @desc    Choose a best-fit virtual keyboard type from an allowed-character palette.
				///         Heuristics are ordered from most-specific to most-generic and are conservative:
				///         - Pure digits -> numbers
				///         - Digits with phone punctuation -> phone
				///         - E-mail shape (needs '@' and '.') and no spaces -> email
				///         - URL shape (needs ':' or '/' and often '.') and no spaces -> url
				///         - ASCII-only palette (no non-ascii) -> ascii
				///         - Name-like (letters, spaces, dash, apostrophe; no digits) -> phone_name
				///         - Otherwise -> default
				/// @self    WWTextField
				/// @param   {String|Undefined} allowed
				/// @returns {Real} kbv_type_* constant
				#endregion
				static __infer_keyboard_type__ = function(_allowed) {
					// Defensive defaults
					if (is_undefined(_allowed) || _allowed == "") {
						return kbv_type_default;
					}
					
					// Local helpers (all ASCII-safe)
					#region jsDoc
					/// @func    __has__()
					/// @ignore
					/// @desc    Returns true if the single-character string exists within the pool.
					/// @self    WWTextField
					/// @param   {String} pool
					/// @param   {String} ch
					/// @returns {Bool}
					#endregion
					static __has__ = function(_pool, _ch) {
						return string_pos(_ch, _pool) > 0;
					};
					#region jsDoc
					/// @func    __all_in__()
					/// @ignore
					/// @desc    Returns true if every character in the pool exists within the allowed set.
					/// @self    WWTextField
					/// @param   {String} pool
					/// @param   {String} set
					/// @returns {Bool}
					#endregion
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
					#region jsDoc
					/// @func    __is_ascii_only__()
					/// @ignore
					/// @desc    Returns true if the pool contains only ASCII characters (ord 0..127).
					/// @self    WWTextField
					/// @param   {String} pool
					/// @returns {Bool}
					#endregion
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
				/// @ignore
				/// @desc    Updates the cursor position based on mouse input. When selection mode is enabled,
				///          if no selection anchor exists, it sets the anchor to the current cursor position.
				///          Then it updates the cursor position from the mouse coordinates. If the new cursor
				///          equals the anchor, selection is cleared; otherwise, selection remains active.
				/// @self    WWTextField
				/// @param   {Bool} select : Whether selection mode is enabled.
				/// @returns {Undefined}
				#endregion
				static __check_minput__ = function(_select) {
					// Get mouse coordinates in GUI space.
					var mx = device_mouse_x_to_gui(0);
					var my = device_mouse_y_to_gui(0);
					var _index = renderer.get_index_from_xy(mx, my);
				
					// New press: reset normal drag tracking.
					if (!_select) {
						__drag_started__ = false;
						__drag_start_x__ = mx;
						__drag_start_y__ = my;
					}
				
					// Drag/update tick: route to the correct drag mode.
					if (_select) {
						// Alt is reserved for subtracting a selection/caret (Sublime-style). No Alt-drag selection.
						if (keyboard_check(vk_alt)) {
							return;
						}
						// Ctrl-drag extends selection for ONLY the cursor created/targeted by Ctrl+click.
						if (__drag_mode__ == 1) {
							// If Ctrl is no longer held, cancel ctrl-drag and fall back to normal drag logic.
							if (!keyboard_check(vk_control)) {
								__drag_mode__ = 0;
							} else {
								// Don't start extending until the mouse actually moves.
								if (!__drag_started__) {
									var _dzc = __drag_deadzone_px__;
									var _dxc = mx - __drag_start_x__;
									var _dyc = my - __drag_start_y__;
									if ((_dxc * _dxc) + (_dyc * _dyc) < (_dzc * _dzc)) {
										return;
									}
									__drag_started__ = true;
								}
							var _cid = clamp(__drag_select_cursor_index__, 0, max(0, array_length(__cursors__) - 1));
							var _new_index = renderer.get_index_from_xy(mx, my);
							__cursor_active__ = _cid;
							__cursor_set_index_synced_for__(_cid, _new_index, true, true);
							__history_update_latest_cursor__();
							trigger_event(events.cursor_move);
							return;
							}
						}
					
						// Normal drag: do not begin extending selection until the mouse actually moves.
						if (!__drag_started__) {
							var _dz = __drag_deadzone_px__;
							var _dx = mx - __drag_start_x__;
							var _dy = my - __drag_start_y__;
							if ((_dx * _dx) + (_dy * _dy) < (_dz * _dz)) {
								return;
							}
							__drag_started__ = true;
						}
					}
				
					if (!_select) {
						var _ctrl = keyboard_check(vk_control);
						var _alt = keyboard_check(vk_alt);
						// If we're in double-click word selection drag mode, modifier clicks should not extend that selection.
						// (Ctrl/Alt are used for multi-cursor actions, not word-drag extension.)
						if (__selection_mode__ != __WW_Text_Field_Selection_Mode.Regular && (_ctrl || _alt)) {
							__selection_mode__ = __WW_Text_Field_Selection_Mode.Regular;
						}
						if (multi_cursor_enabled) {
							var _c0 = __cursors__[__cursor_active__];
							if (_ctrl || _alt || array_length(__cursors__) > 1 || (_c0.highlight_active && _c0.highlight_start_index != _c0.highlight_end_index)) {
								__selection_add_record__();
							}
						}
						if (!multi_cursor_enabled) {
							_ctrl = false;
							_alt = false;
							if (array_length(__cursors__) > 1) {
								__cursors_clear_to_single__(__cursor_get_index__());
							}
						}
					
						if (_ctrl) {
							__cursors_add_at_index__(_index);
							__selection_add_record__();
							__drag_mode__ = 1;
							__drag_select_cursor_index__ = __cursor_active__;
							__cursor_blink_reset__();
							trigger_event(events.cursor_move);
							return;
						}
					
						if (_alt) {
							// Only subtract a caret if there's actually more than one.
							if (array_length(__cursors__) > 1) {
								var _before_remove = array_length(__cursors__);
								var _line = renderer.get_line_from_index(_index);
								var _thresh = renderer.get_line_height(_line) * 1.25;
								__cursors_remove_nearest_to_xy__(mx, my, _thresh);
								if (array_length(__cursors__) != _before_remove) {
									__selection_add_record__();
								}
								__drag_mode__ = 0;
								return;
							}
							_alt = false;
						}
					}
				
					if (!_select) {
						__drag_mode__ = 0;
						// Normal click collapses to a single cursor
						__cursors_clear_to_single__(_index);
					}
					__cursor_set_index_synced__(_index, _select);
				}
				
				#region Box-like selection (Shift+RMB)
					
					#region jsDoc
					/// @func    __box_select_line_interval__()
					/// @ignore
					/// @desc    Computes the index interval [a,b] on a single visual line for box selection.
					///          Returned fields are inclusive indices in buffer-index space, clamped to the line.
					/// @self    WWTextField
					/// @param   {Real} line
					/// @param   {Real} x0
					/// @param   {Real} x1
					/// @returns {Struct} { a, b }
					#endregion
					static __box_select_line_interval__ = function(_line, _x0, _x1) {
						var _y_mid = y + renderer.get_line_y_offset(_line) + (renderer.get_line_height(_line) * 0.5);
						var _i0 = renderer.get_index_from_xy(_x0, _y_mid);
						var _i1 = renderer.get_index_from_xy(_x1, _y_mid);
						var _ls = renderer.get_line_index_start(_line);
						var _le = renderer.get_line_index_end(_line);
						var _a = clamp(min(_i0, _i1), _ls, _le);
						var _b = clamp(max(_i0, _i1), _ls, _le);
						// Avoid selecting the literal line break when selecting to EOL on non-wrapped lines.
						if (_a != _b) {
							var _last_line_index = renderer.get_line_count() - 1;
							if (!renderer.get_line_forced_wrapped(_line) && _line != _last_line_index) {
								if (_b == _le) {
									_b = max(_a, _b - 1);
								}
							}
						}
						return { a: _a, b: _b };
					};
					#region jsDoc
					/// @func    __box_select_build_ranges__()
					/// @ignore
					/// @desc    Builds an array of per-line box-selection ranges from two drag points.
					/// @self    WWTextField
					/// @param   {Real} x0
					/// @param   {Real} y0
					/// @param   {Real} x1
					/// @param   {Real} y1
					/// @returns {Array} Array of { a, b } ranges.
					#endregion
					static __box_select_build_ranges__ = function(_x0, _y0, _x1, _y1) {
						var _line_count = renderer.get_line_count();
						if (_line_count <= 0) return [];
						var _last_line = _line_count - 1;
						var _i0 = renderer.get_index_from_xy(_x0, _y0);
						var _i1 = renderer.get_index_from_xy(_x1, _y1);
						var _l0 = clamp(renderer.get_line_from_index(_i0), 0, _last_line);
						var _l1 = clamp(renderer.get_line_from_index(_i1), 0, _last_line);
						var _la = min(_l0, _l1);
						var _lb = max(_l0, _l1);
						var _out = [];
						var _line = _la;
						while (_line <= _lb) {
							array_push(_out, __box_select_line_interval__(_line, _x0, _x1));
							_line += 1;
						}
						return _out;
					};
					#region jsDoc
					/// @func    __box_select_build_cursors__()
					/// @ignore
					/// @desc    Converts box-selection ranges into cursor records (one cursor per line).
					/// @self    WWTextField
					/// @param   {Array} ranges : Array of { a, b } ranges.
					/// @returns {Array} Cursor record array.
					#endregion
					static __box_select_build_cursors__ = function(_ranges) {
						var _n = array_length(_ranges);
						if (_n <= 0) return [];
						var _out = [];
						array_resize(_out, _n);
						var _i = 0;
						repeat (_n) {
							var _r = _ranges[_i];
							var _a = _r.a;
							var _b = _r.b;
							var _idx = _b;
							var _c = __cursor_record_create__(_idx);
							if (_a != _b) {
								_c.highlight_active = true;
								_c.highlight_start_index = _a;
								_c.highlight_end_index = _b;
							}
							else {
								_c.highlight_active = false;
								_c.highlight_start_index = _idx;
								_c.highlight_end_index = _idx;
							}
							_c.index = _idx;
							_c.sticky_px = renderer.get_x_from_index(_idx);
							_out[_i] = _c;
							_i += 1;
						}
						return _out;
					};
					#region jsDoc
					/// @func    __ranges_merge__()
					/// @ignore
					/// @desc    Sorts and merges an array of ranges in-place (touching/overlapping ranges merge).
					/// @self    WWTextField
					/// @param   {Array} ranges : Array of { a, b } ranges.
					/// @returns {Array} Merged range array.
					#endregion
					static __ranges_merge__ = function(_ranges) {
						var _n = array_length(_ranges);
						if (_n <= 1) return _ranges;
						// insertion sort by a
						var _j = 1;
						while (_j < _n) {
							var _key = _ranges[_j];
							var _k = _j - 1;
							while (_k >= 0 && _ranges[_k].a > _key.a) {
								_ranges[_k + 1] = _ranges[_k];
								_k -= 1;
							}
							_ranges[_k + 1] = _key;
							_j += 1;
						}
						var _merged = [];
						array_push(_merged, _ranges[0]);
						var _i = 1;
						repeat (_n - 1) {
							var _cur = _ranges[_i];
							var _last = _merged[array_length(_merged) - 1];
							if (_cur.a <= _last.b) {
								_last.b = max(_last.b, _cur.b);
								_merged[array_length(_merged) - 1] = _last;
							}
							else {
								array_push(_merged, _cur);
							}
							_i += 1;
						}
						return _merged;
					};
					#region jsDoc
					/// @func    __cursors_merge_overlaps_all__()
					/// @ignore
					/// @desc    Merges overlapping cursor selections/carets into a minimal non-overlapping set.
					/// @self    WWTextField
					/// @returns {Undefined}
					#endregion
					static __cursors_merge_overlaps_all__ = function() {
						var _n = array_length(__cursors__);
						if (_n <= 1) return;
						var _ranges = [];
						array_resize(_ranges, _n);
						var _i = 0;
						repeat (_n) {
							var _c = __cursors__[_i];
							var _a;
							var _b;
							if (_c.highlight_active && _c.highlight_start_index != _c.highlight_end_index) {
								_a = min(_c.highlight_start_index, _c.highlight_end_index);
								_b = max(_c.highlight_start_index, _c.highlight_end_index);
							}
							else {
								_a = _c.index;
								_b = _c.index;
							}
							_ranges[_i] = { a: _a, b: _b };
							_i += 1;
						}
						_ranges = __ranges_merge__(_ranges);
						var _m = array_length(_ranges);
						var _out = [];
						array_resize(_out, _m);
						_i = 0;
						repeat (_m) {
							var _r = _ranges[_i];
							var _a2 = _r.a;
							var _b2 = _r.b;
							var _idx2 = _b2;
							var _nc = __cursor_record_create__(_idx2);
							if (_a2 != _b2) {
								_nc.highlight_active = true;
								_nc.highlight_start_index = _a2;
								_nc.highlight_end_index = _b2;
							}
							else {
								_nc.highlight_active = false;
								_nc.highlight_start_index = _idx2;
								_nc.highlight_end_index = _idx2;
							}
							_nc.index = _idx2;
							_nc.sticky_px = renderer.get_x_from_index(_idx2);
							_out[_i] = _nc;
							_i += 1;
						}
						__cursors__ = _out;
						__cursor_active__ = max(0, array_length(__cursors__) - 1);
					};
					#region jsDoc
					/// @func    __ranges_point_in_any__()
					/// @ignore
					/// @desc    Returns true if a point index lies within any range (half-open) or equals a caret.
					/// @self    WWTextField
					/// @param   {Array} ranges : Array of { a, b } ranges.
					/// @param   {Real} idx
					/// @returns {Bool}
					#endregion
					static __ranges_point_in_any__ = function(_ranges, _idx) {
						var _n = array_length(_ranges);
						var _i = 0;
						repeat (_n) {
							var _r = _ranges[_i];
							// Treat selection ranges as half-open [a,b). For degenerate ranges (a==b), treat it as a single caret-position.
							if (_r.a == _r.b) {
								if (_idx == _r.a) return true;
							}
							else if (_idx >= _r.a && _idx < _r.b) {
								return true;
							}
							_i += 1;
						}
						return false;
					};
					#region jsDoc
					/// @func    __ranges_subtract__()
					/// @ignore
					/// @desc    Subtracts an array of ranges from an input interval, returning remaining segments.
					/// @self    WWTextField
					/// @param   {Real} a
					/// @param   {Real} b
					/// @param   {Array} subs : Array of { a, b } ranges.
					/// @returns {Array} Array of remaining { a, b } segments.
					#endregion
					static __ranges_subtract__ = function(_a, _b, _subs) {
						var _out = [];
						if (_a >= _b) return _out;
						var _cur = _a;
						var _n = array_length(_subs);
						var _i = 0;
						repeat (_n) {
							var _s = _subs[_i];
							if (_s.b <= _cur) { _i += 1; continue; }
							if (_s.a >= _b) break;
							if (_s.a > _cur) {
								array_push(_out, { a: _cur, b: min(_s.a, _b) });
							}
							_cur = max(_cur, _s.b);
							if (_cur >= _b) break;
							_i += 1;
						}
						if (_cur < _b) {
							array_push(_out, { a: _cur, b: _b });
						}
						return _out;
					};
					#region jsDoc
					/// @func    __box_select_apply_override_or_add__()
					/// @ignore
					/// @desc    Applies the current box selection as override (mode 0) or additive (mode 1).
					/// @self    WWTextField
					/// @param   {Real} mx
					/// @param   {Real} my
					/// @returns {Undefined}
					#endregion
					static __box_select_apply_override_or_add__ = function(_mx, _my) {
						var _ranges = __box_select_build_ranges__(__drag_start_x__, __drag_start_y__, _mx, _my);
						var _box_cursors = __box_select_build_cursors__(_ranges);
						if (__box_select_mode__ == 0) {
							__cursors__ = _box_cursors;
							__drag_select_cursor_index__ = 0;
						}
						else {
							// Additive: always rebuild from the stable baseline snapshot + current box cursors.
							// (We cannot rely on truncation using __drag_select_cursor_index__ because we sort/dedupe each frame.)
							__cursors__ = __cursors_clone_from__(__box_select_base_cursors__);
							var _n = array_length(_box_cursors);
							var _i = 0;
							repeat (_n) {
								array_push(__cursors__, _box_cursors[_i]);
								_i += 1;
							}
						}
						if (array_length(__cursors__) <= 0) {
							__cursors__ = [ __cursor_record_create__(0) ];
							__cursor_active__ = 0;
						}
						else {
							__cursor_active__ = max(0, array_length(__cursors__) - 1);
						}
						__cursors_sort_and_dedupe_by_index__();
						__cursors_sync_sticky_x__();
						__history_update_latest_cursor__();
						__cursor_blink_reset__();
						trigger_event(events.cursor_move);
					};
					#region jsDoc
					/// @func    __box_select_apply_subtractive__()
					/// @ignore
					/// @desc    Applies the current box selection subtractively (mode 2), cutting ranges/carets.
					/// @self    WWTextField
					/// @param   {Real} mx
					/// @param   {Real} my
					/// @returns {Undefined}
					#endregion
					static __box_select_apply_subtractive__ = function(_mx, _my) {
						// Always re-apply cutting from a stable baseline so dragging doesn't accumulate rounding artifacts.
						__cursors__ = __cursors_clone_from__(__box_select_base_cursors__);
						__cursor_active__ = clamp(__box_select_base_cursor_active__, 0, max(0, array_length(__cursors__) - 1));
						var _ranges = __box_select_build_ranges__(__drag_start_x__, __drag_start_y__, _mx, _my);
						_ranges = __ranges_merge__(_ranges);
						var _out = [];
						var _n = array_length(__cursors__);
						var _i = 0;
						repeat (_n) {
							var _c = __cursors__[_i];
							var _a;
							var _b;
							if (_c.highlight_active && _c.highlight_start_index != _c.highlight_end_index) {
								_a = min(_c.highlight_start_index, _c.highlight_end_index);
								_b = max(_c.highlight_start_index, _c.highlight_end_index);
								var _pieces = __ranges_subtract__(_a, _b, _ranges);
								var _p = 0;
								repeat (array_length(_pieces)) {
									var _seg = _pieces[_p];
									if (_seg.a < _seg.b) {
										var _nc = __cursor_record_create__(_seg.b);
										_nc.highlight_active = true;
										_nc.highlight_start_index = _seg.a;
										_nc.highlight_end_index = _seg.b;
										_nc.index = _seg.b;
										_nc.sticky_px = renderer.get_x_from_index(_seg.b);
										array_push(_out, _nc);
									}
									_p += 1;
								}
							}
							else {
								// Caret-only: remove the caret if it lies within the box region.
								if (!__ranges_point_in_any__(_ranges, _c.index)) {
									var _nc2 = __cursor_record_create__(_c.index);
									_nc2.highlight_active = false;
									_nc2.highlight_start_index = _c.index;
									_nc2.highlight_end_index = _c.index;
									_nc2.index = _c.index;
									_nc2.sticky_px = renderer.get_x_from_index(_c.index);
									array_push(_out, _nc2);
								}
							}
							_i += 1;
						}
						if (array_length(_out) <= 0) {
							// Never allow zero cursors.
							var _idx0 = renderer.get_index_from_xy(__drag_start_x__, __drag_start_y__);
							_out = [ __cursor_record_create__(_idx0) ];
							_out[0].sticky_px = renderer.get_x_from_index(_idx0);
						}
						__cursors__ = _out;
						__cursor_active__ = max(0, array_length(__cursors__) - 1);
						__cursors_sort_and_dedupe_by_index__();
						__cursors_sync_sticky_x__();
						__history_update_latest_cursor__();
						__cursor_blink_reset__();
						trigger_event(events.cursor_move);
					};
					#region jsDoc
					/// @func    __box_select_begin__()
					/// @ignore
					/// @desc    Starts a box-selection drag gesture.
					/// @self    WWTextField
					/// @param   {Real} mode : 0 override, 1 additive, 2 subtractive.
					/// @param   {Real} mx
					/// @param   {Real} my
					/// @returns {Undefined}
					#endregion
					static __box_select_begin__ = function(_mode, _mx, _my) {
						if (!multi_cursor_enabled) return;
						__box_select_active__ = true;
						__box_select_mode__ = _mode;
						__drag_start_x__ = _mx;
						__drag_start_y__ = _my;
						__selection_add_record__();
						__box_select_base_cursors__ = __cursors_clone__();
						__box_select_base_cursor_active__ = __cursor_active__;
						if (_mode == 0) {
							__cursors__ = [];
							__cursor_active__ = 0;
							__drag_select_cursor_index__ = 0;
						}
						else if (_mode == 1) {
							__drag_select_cursor_index__ = array_length(__cursors__);
						}
						else {
							// subtractive maintains its own baseline
							__drag_select_cursor_index__ = 0;
						}
						// Apply once immediately.
						if (_mode == 2) {
							__box_select_apply_subtractive__(_mx, _my);
						}
						else {
							__box_select_apply_override_or_add__(_mx, _my);
						}
					};
					#region jsDoc
					/// @func    __box_select_update__()
					/// @ignore
					/// @desc    Updates the active box-selection drag with the current mouse position.
					/// @self    WWTextField
					/// @param   {Real} mx
					/// @param   {Real} my
					/// @returns {Undefined}
					#endregion
					static __box_select_update__ = function(_mx, _my) {
						if (!__box_select_active__) return;
						if (__box_select_mode__ == 2) {
							__box_select_apply_subtractive__(_mx, _my);
						}
						else {
							__box_select_apply_override_or_add__(_mx, _my);
						}
					};
					#region jsDoc
					/// @func    __box_select_end__()
					/// @ignore
					/// @desc    Ends a box-selection drag gesture and records the resulting selection state.
					/// @self    WWTextField
					/// @returns {Undefined}
					#endregion
					static __box_select_end__ = function() {
						if (!__box_select_active__) return;
						__box_select_active__ = false;
						// Additive: merge overlapping/touching highlights/carets globally on completion.
						if (__box_select_mode__ == 1) {
							__cursors_merge_overlaps_all__();
							__cursors_sort_and_dedupe_by_index__();
							__cursors_sync_sticky_x__();
							__history_update_latest_cursor__();
						}
						__selection_add_record__();
					};
					
				#endregion
				
				#region jsDoc
				/// @func    __move_cursor_offset__()
				/// @ignore
				/// @desc    Moves the cursor based on input and optionally extends selection. When shift is
				///          held, it preserves the selection anchor; otherwise, any active selection is cleared.
				/// @self    WWTextField
				/// @param   {Real} vector : The amount/direction to move the cursor.
				/// @param   {Bool} shift  : Whether to extend the selection (shift key held).
				/// @param   {Bool} vertical : Whether the movement is vertical (if false, horizontal).
				/// @param   {Bool} word_mode : If true, movement is word-based.
				/// @returns {Undefined}
				#endregion
				static __move_cursor_offset__ = function(_vector, _shift, _vertical, _word_mode=false) {
					static __word_breakers = "\n"+chr(9)+chr(34)+" ,.;:?!><#$%&'()*+-/=@[\]^`{|}~¡¢£¤¥¦§¨©«¬­®¯°±´¶·¸»¿×÷";
					
					if (_vector == 0) return;
				
					if (multi_cursor_enabled && array_length(__cursors__) > 1) {
						__cursors_move_offset__(_vector, _shift, _vertical, _word_mode);
						return;
					}
					
					var _index = __cursor_get_index__();
					var _new_index = _index; //will be overwritten
					
					// move cursor
					if (_vertical) {
						var _line = renderer.get_line_from_index(_index);
						var _line_count = renderer.get_line_count();
						
						//early out
						if (_line == 0) && (_vector < 0) {
							var _new_index = renderer.get_line_index_start(_line);
							__cursor_set_index_synced__(_new_index, false, false);
							__history_update_latest_cursor__();
							return;
						}
						if (_line == _line_count-1) && (_vector > 0) {
							var _new_index = renderer.get_line_index_end(_line);
							__cursor_set_index_synced__(_new_index, false, false);
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
							var _index = __cursor_get_index__()+_vector;
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
							var _new_index = __cursor_get_index__() + _vector;
							_new_index = clamp(_new_index, 0, renderer.get_glyph_count())
						}
						
						__cursor_set_index_synced__(_new_index, _shift);
					}
					
				}
				
				#region jsDoc
				/// @func    __move_cursor_paged_offset__()
				/// @ignore
				/// @desc    Moves the cursor based on page up and down, keepnig relation to the cursor width offset
				/// @self    WWTextField
				/// @param   {Real} vector : The direction to move the cursor.
				/// @param   {Bool} shift  : Whether to extend the selection (shift key held).
				/// @returns {Undefined}
				#endregion
				static __move_cursor_paged_offset__ = function(_vector, _shift) {
					if (_vector == 0) return;
				
					if (multi_cursor_enabled && array_length(__cursors__) > 1) {
						__cursors_move_paged_offset__(_vector, _shift);
						return;
					}
					
					// Current cursor position and line
					var _cursor_index = __cursor_get_index__();
					var _current_line = renderer.get_line_from_index(_cursor_index);
					var _line_count = renderer.get_line_count();
					
					// Compute target y offset based on page height and direction
					var _current_y_offset = renderer.get_line_y_offset(_current_line);
					var _page_height = height * 0.75 * abs(_vector);
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
				
				#region jsDoc
				/// @func    __cursor_record_create__()
				/// @ignore
				/// @desc    Creates a data-only cursor record used by WWTextField multi-cursor logic.
				/// @self    WWTextField
				/// @param   {Real} index : Initial buffer index.
				/// @returns {Struct} Cursor record { index, highlight_active, highlight_start_index, highlight_end_index, sticky_px }
				#endregion
				static __cursor_record_create__ = function(_index) {
					return {
						index: _index,
						highlight_active: false,
						highlight_start_index: _index,
						highlight_end_index: _index,
						sticky_px: 0,
					};
				};
				
			#endregion
			
			#region Input Handling
				
				#region jsDoc
				/// @func    __compute_word_boundaries__()
				/// @ignore
				/// @desc    Computes word boundaries around a global buffer index using a shared list of word breakers.
				///          Returns a struct containing: { index_start, index_end } where:
				///          - index_start is inclusive
				///          - index_end is exclusive
				/// @self    WWTextField
				/// @param   {Real} index : Global 0-based glyph index.
				/// @param   {Bool} include_whitespace : If true, expands the span to include adjacent whitespace.
				/// @returns {Struct} A struct with properties index_start and index_end.
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
				/// @ignore
				/// @desc    Inserts a string at all active cursors, respecting allowed characters.
				/// @self    WWTextField
				/// @param   {String} str : The string to insert.
				/// @returns {Bool} True if any text was inserted, false otherwise.
				#endregion
				static __insert_string_at_cursor__ = function(_str) {

					// sanitize input
					var _new_str = buffer.__filter_allowed__(_str);
					if (_new_str == "") return false;

					var _str_byte_len = string_byte_length(_new_str);

					// If replacing selections, delete them WITHOUT pushing history.
					// We want a single atomic record for "replace selection(s) with text".
					__delete_selection_if_any__(false, false);
				
					// Insert at all cursors (process from right-to-left, then keep indices consistent).
					var _insert_len = string_length(_new_str);
					var _cursor_ids = __cursors_sorted_ids_by_index__(true);
					var _count = array_length(_cursor_ids);
					var _i = 0;
					repeat (_count) {
						var _cid = _cursor_ids[_i];
						var _c = __cursors__[_cid];
						var _insert_at = clamp(_c.index, 0, renderer.get_glyph_count());
						var _buffer_index = buffer.get_byte_index_from_index(_insert_at);
						buffer.insert(_buffer_index, _new_str);
					
						// Shift all cursors strictly to the right of the insertion point.
						__cursors_shift_right_of__(_insert_at, _insert_len);
					
						// Advance this cursor and clear selection.
						_c.index = _insert_at + _insert_len;
						_c.highlight_active = false;
						_c.highlight_start_index = _c.index;
						_c.highlight_end_index = _c.index;
					
						_i += 1;
					}
				
					__force_rebuild__();
					__cursors_sync_sticky_x__();
					__history_add_record__();
					trigger_event(events.change);
					return true;
				}
				
				#region jsDoc
				/// @func    __update_word_selection_drag__()
				/// @ignore
				/// @desc    Updates word/line selection during a mouse drag after a multi-click.
				///          Uses the renderer to convert GUI coordinates into a buffer index,
				///          then expands that index to full word boundaries using
				///          __compute_word_boundaries__. The selection is extended from the
				///          original anchor span to the current word span.
				/// @self    WWTextField
				/// @returns {Undefined}
				#endregion
				static __update_word_selection_drag__ = function() {
					// Get current mouse coordinates in GUI space.
					var _mouse_x_gui = device_mouse_x_to_gui(0);
					var _mouse_y_gui = device_mouse_y_to_gui(0);
					var _dz = __drag_deadzone_px__;
					var _dx = _mouse_x_gui - __drag_start_x__;
					var _dy = _mouse_y_gui - __drag_start_y__;
					if ((_dx * _dx) + (_dy * _dy) < (_dz * _dz)) {
						return;
					}
	
					// Convert GUI coordinates to a global buffer index.
					var _index = renderer.get_index_from_xy(_mouse_x_gui, _mouse_y_gui);

					var _span_start;
					var _span_end;
					if (__selection_mode__ == __WW_Text_Field_Selection_Mode.Word) {
						// Compute word bounds around the current index.
						// We include whitespace so dragging between words selects continuous spans.
						var _bounds = __compute_word_boundaries__(_index, false);
						_span_start = _bounds.index_start;
						_span_end   = _bounds.index_end; // exclusive
					}
					else if (__selection_mode__ == __WW_Text_Field_Selection_Mode.Line) {
						var _line = renderer.get_line_from_index(_index);
						_span_start = renderer.get_line_index_start(_line);
						_span_end = renderer.get_line_index_end(_line);
						// Avoid selecting the literal line break when selecting to EOL on non-wrapped lines.
						if (!renderer.get_line_forced_wrapped(_line) && (_line + 1 < renderer.get_line_count())) {
							_span_end = max(_span_start, _span_end - 1);
						}
					}
					else {
						return;
					}
	
					// Anchor data set on double/triple-click.
					var _selection_start_index = min(__selection_anchor_start__, _span_start);
					var _selection_end_index   = max(__selection_anchor_end__, _span_end);
					
					
					var _cursor_index = _selection_end_index;
					if (_index < __selection_anchor_start__) {
						_cursor_index = _selection_start_index;
					}
					
					
					// Update cursor and highlight using the new indices.
					__cursor_set_index_synced__(_cursor_index, false, false);
					__cursor_set_highlight_active__(true);
					__cursor_set_highlight_start_index__(_selection_start_index);
					__cursor_set_highlight_end_index__(_selection_end_index);
					cursor_last_width = renderer.get_x_from_index(_cursor_index);
					__history_update_latest_cursor__();
				};
				
				#region jsDoc
				/// @func    __clipboard_get_text__()
				/// @ignore
				/// @desc    Retrieves text from the clipboard for pasting into the input field.
				/// @self    WWTextField
				/// @returns {String}
				#endregion
				static __clipboard_get_text__ = function() {
					if (clipboard_has_text()) {
						var _pasted_string = clipboard_get_text();
						//text was coppied from outside the program clear layout data
						if (_pasted_string != __global_clipboard_container__.text) {
							//clear layout data
						}
						__global_clipboard_container__.text = _pasted_string;
					}
					else if (__global_clipboard_container__.text != "") {
						var _pasted_string = __global_clipboard_container__.text;
					}
					else {
						//nothing has been coppied.... maybe print a warning?
					}
					
					return _pasted_string;
				}
				
				#region jsDoc
				/// @func    __clipboard_set_text__()
				/// @ignore
				/// @desc    Sets the clipboard text.
				/// @self    WWTextField
				/// @param   {String} str
				/// @returns {Undefined}
				#endregion
				static __clipboard_set_text__ = function(_str) {
					__global_clipboard_container__.text = _str;
					//TODO: update or clear layout data aswell
					clipboard_set_text(_str);
				}
			
				#region Multi-cursor clipboard helpers
					
					#region jsDoc
					/// @func    __clipboard_strip_trailing_cr__()
					/// @ignore
					/// @desc    Removes a single trailing '\r' from a line (Windows-style split cleanup).
					/// @self    WWTextField
					/// @param   {String|Undefined} s
					/// @returns {String}
					#endregion
					static __clipboard_strip_trailing_cr__ = function(_s) {
						if (is_undefined(_s)) return "";
						var _len = string_length(_s);
						if (_len <= 0) return _s;
						if (string_char_at(_s, _len) == "\r") {
							return string_delete(_s, _len, 1);
						}
						return _s;
					};
					#region jsDoc
					/// @func    __clipboard_split_lines__()
					/// @ignore
					/// @desc    Splits text by '\n' into lines and strips trailing '\r' per line.
					/// @self    WWTextField
					/// @param   {String|Undefined} s
					/// @returns {Array} String array.
					#endregion
					static __clipboard_split_lines__ = function(_s) {
						if (is_undefined(_s)) return [""];
						var _arr = string_split(_s, "\n");
						var _n = array_length(_arr);
						var _i = 0;
						repeat (_n) {
							_arr[_i] = __clipboard_strip_trailing_cr__(_arr[_i]);
							_i += 1;
						}
						return _arr;
					};
					
				#endregion
				
				#region Multi-cursor selection helpers (Sublime-style)
				
					#region jsDoc
					/// @func    __cursors_clone_state__()
					/// @ignore
					/// @desc    Captures a snapshot of cursor + selection state for selection-undo.
					///          Returns a 2-element array: [cursors_snapshot_array, active_cursor_index].
					/// @self    WWTextField
					/// @returns {Array}
					#endregion
					static __cursors_clone_state__ = function() {
						var _n = array_length(__cursors__);
						var _out = [];
						array_resize(_out, _n);
						var _i = 0;
						repeat (_n) {
							var _c = __cursors__[_i];
							_out[_i] = {
								index: _c.index,
								highlight_active: _c.highlight_active,
								highlight_start_index: _c.highlight_start_index,
								highlight_end_index: _c.highlight_end_index,
								sticky_px: _c.sticky_px
							};
							_i += 1;
						}
						// [cursors_array, active_cursor_index]
						return [_out, __cursor_active__];
					};
					#region jsDoc
					/// @func    __selection_record_signature__()
					/// @ignore
					/// @desc    Creates a lightweight signature string for a cursor/selection snapshot.
					///          Used to de-dupe consecutive identical history states.
					/// @self    WWTextField
					/// @param   {Array} st : Snapshot as returned by __cursors_clone_state__.
					/// @returns {String}
					#endregion
					static __selection_record_signature__ = function(_st) {
						if (is_undefined(_st) || !is_array(_st) || array_length(_st) < 2) return "";
						var _curs = _st[0];
						var _sig = string(_st[1]) + ":" + string(array_length(_curs));
						var _n = array_length(_curs);
						var _i = 0;
						repeat (_n) {
							var _c = _curs[_i];
							_sig += ";" + string(_c.index) + "," + string(_c.highlight_active) + "," + string(_c.highlight_start_index) + "," + string(_c.highlight_end_index);
							_i += 1;
						}
						return _sig;
					};
					#region jsDoc
					/// @func    __selection_add_record_state__()
					/// @ignore
					/// @desc    Appends a snapshot to selection history, truncating any redo states and enforcing max history length.
					/// @self    WWTextField
					/// @param   {Array} st : Snapshot as returned by __cursors_clone_state__.
					/// @returns {Bool} True if a new state was recorded, false if it was de-duped/ignored.
					#endregion
					static __selection_add_record_state__ = function(_st) {
						if (!multi_cursor_enabled) return false;
						var _sig = __selection_record_signature__(_st);
						if (_sig == "") return false;
						var _len = array_length(__selection_records__);
						var _pos = __selection_records_loc__;
						// Drop any redo states when recording a new snapshot.
						if (_pos < _len - 1) {
							array_delete(__selection_records__, _pos + 1, _len - (_pos + 1));
							_len = array_length(__selection_records__);
						}
						_pos = clamp(_pos, -1, _len - 1);
						// De-dupe against the current history state.
						if (_len > 0 && _pos >= 0) {
							var _e = __selection_records__[_pos];
							if (is_struct(_e) && _e.sig == _sig) {
								__selection_records_loc__ = _pos;
								return false;
							}
						}
						array_push(__selection_records__, { st: _st, sig: _sig });
						_len = array_length(__selection_records__);
						// Trim oldest.
						if (_len > __selection_records_limit__) {
							var _drop = _len - __selection_records_limit__;
							array_delete(__selection_records__, 0, _drop);
							_len = array_length(__selection_records__);
						}
						__selection_records_loc__ = _len - 1;
						return true;
					};
					#region jsDoc
					/// @func    __selection_records_rollback_to_multiclick_anchor__()
					/// @ignore
					/// @desc    Helper for double/triple click: removes intermediate click-created history entries and ensures
					///          the history tail is the selection state from just before the multi-click gesture started.
					/// @self    WWTextField
					/// @returns {Bool}
					#endregion
					static __selection_records_rollback_to_multiclick_anchor__ = function() {
						if (!multi_cursor_enabled) return false;
						if (!__selection_multiclick_anchor_valid__) return false;
						var _window = 1_000/3;
						if (current_time - __selection_multiclick_anchor_time__ > _window) return false;
						// Delete any snapshots created by intermediate clicks in the sequence.
						var _len0 = array_length(__selection_records__);
						var _keep_len = clamp(__selection_multiclick_anchor_records_len__, 0, _len0);
						if (_len0 > _keep_len) {
							array_delete(__selection_records__, _keep_len, _len0 - _keep_len);
						}
						var _len = array_length(__selection_records__);
						__selection_records_loc__ = clamp(__selection_multiclick_anchor_records_loc__, -1, _len - 1);
						// Ensure the anchor itself is the current tail state.
						return __selection_add_record_state__(__selection_multiclick_anchor__);
					};
					#region jsDoc
					/// @func    __selection_add_record__()
					/// @ignore
					/// @desc    Records the current cursor/selection state into the selection history.
					///          Uses a single history array + position cursor (undo/redo style) and de-duplicates
					///          consecutive identical states. This is used by Ctrl+U / Ctrl+Shift+U.
					/// @self    WWTextField
					/// @returns {Undefined}
					#endregion
					static __selection_add_record__ = function() {
						if (!multi_cursor_enabled) return;
						__selection_add_record_state__(__cursors_clone_state__());
					};
					#region jsDoc
					/// @func    __selection_jump__()
					/// @ignore
					/// @desc    Moves through selection undo/redo history by a signed offset and restores that snapshot.
					/// @self    WWTextField
					/// @param   {Real} change : Negative=undo, Positive=redo.
					/// @returns {Bool} True if a snapshot was restored.
					#endregion
					static __selection_jump__ = function(_change) {
						if (!multi_cursor_enabled) return false;
						if (_change == 0) return false;
						var _len = array_length(__selection_records__);
						// If history is empty, record the current state as the initial entry (undo-only).
						if (_len <= 0) {
							if (_change < 0) {
								__selection_add_record__();
							}
							return false;
						}
						var _pos = clamp(__selection_records_loc__, 0, _len - 1);
						var _target = _pos + _change;
						if (_target < 0 || _target >= _len) return false;
						var _e = __selection_records__[_target];
						if (is_undefined(_e) || !is_struct(_e) || !variable_struct_exists(_e, "st")) return false;
						var _st = _e.st;
						if (is_undefined(_st) || !is_array(_st) || array_length(_st) < 2) return false;
						__cursors__ = _st[0];
						__cursor_active__ = clamp(_st[1], 0, max(0, array_length(__cursors__) - 1));
						__cursors_sync_sticky_x__();
						__history_update_latest_cursor__();
						__cursor_blink_reset__();
						__selection_records_loc__ = _target;
						return true;
					};
					#region jsDoc
					/// @func    __selection_undo_snapshot_push__()
					/// @ignore
					/// @desc    Backwards-compatible alias for __selection_add_record__.
					/// @self    WWTextField
					/// @returns {Undefined}
					/// @deprecated Use __selection_add_record__.
					#endregion
					static __selection_undo_snapshot_push__ = function() {
						__selection_add_record__();
					};
					#region jsDoc
					/// @func    __selection_undo_snapshot_pop__()
					/// @ignore
					/// @desc    Backwards-compatible alias for __selection_jump__(-1) (Ctrl+U).
					/// @self    WWTextField
					/// @returns {Bool}
					/// @deprecated Use __selection_jump__.
					#endregion
					static __selection_undo_snapshot_pop__ = function() {
						return __selection_jump__(-1);
					};
					#region jsDoc
					/// @func    __selection_undo_snapshot_redo__()
					/// @ignore
					/// @desc    Backwards-compatible alias for __selection_jump__(+1) (Ctrl+Shift+U).
					/// @self    WWTextField
					/// @returns {Bool}
					/// @deprecated Use __selection_jump__.
					#endregion
					static __selection_undo_snapshot_redo__ = function() {
						return __selection_jump__(1);
					};
					#region jsDoc
					/// @func    __selection_undo_push__()
					/// @ignore
					/// @desc    Backwards-compatible alias for __selection_add_record__.
					/// @self    WWTextField
					/// @returns {Undefined}
					/// @deprecated Use __selection_add_record__.
					#endregion
					static __selection_undo_push__ = function() {
						__selection_add_record__();
					};
					#region jsDoc
					/// @func    __selection_undo_pop__()
					/// @ignore
					/// @desc    Backwards-compatible alias for __selection_jump__(-1).
					/// @self    WWTextField
					/// @returns {Bool}
					/// @deprecated Use __selection_jump__.
					#endregion
					static __selection_undo_pop__ = function() {
						return __selection_jump__(-1);
					};
					#region jsDoc
					/// @func    __cursors_sort_and_dedupe_by_index__()
					/// @ignore
					/// @desc    Sorts __cursors__ by cursor index and removes duplicate carets at the same index.
					/// @self    WWTextField
					/// @returns {Undefined}
					#endregion
					static __cursors_sort_and_dedupe_by_index__ = function() {
						var _n = array_length(__cursors__);
						if (_n <= 1) return;
						// insertion sort by index
						var _j = 1;
						while (_j < _n) {
							var _key = __cursors__[_j];
							var _k = _j - 1;
							while (_k >= 0 && __cursors__[_k].index > _key.index) {
								__cursors__[_k + 1] = __cursors__[_k];
								_k -= 1;
							}
							__cursors__[_k + 1] = _key;
							_j += 1;
						}
						// dedupe
						var _out = [];
						array_push(_out, __cursors__[0]);
						var _i = 1;
						repeat (_n - 1) {
							var _c = __cursors__[_i];
							var _last = _out[array_length(_out) - 1];
							if (_c.index != _last.index) {
								array_push(_out, _c);
							}
							_i += 1;
						}
						__cursors__ = _out;
						__cursor_active__ = clamp(__cursor_active__, 0, max(0, array_length(__cursors__) - 1));
					};
					#region jsDoc
					/// @func    __cursors_add_cursor_vertical__()
					/// @ignore
					/// @desc    Adds new cursors one line above/below each existing cursor (Sublime-style).
					/// @self    WWTextField
					/// @param   {Real} dir : -1 for up, +1 for down.
					/// @returns {Bool} True if any cursor was added.
					#endregion
					static __cursors_add_cursor_vertical__ = function(_dir) {
						var _n = array_length(__cursors__);
						if (_n <= 0) return false;
						var _line_count = renderer.get_line_count();
						if (_line_count <= 0) return false;
						var _added = [];
						var _i = 0;
						repeat (_n) {
							var _c = __cursors__[_i];
							var _line = renderer.get_line_from_index(_c.index);
							var _new_line = clamp(_line + _dir, 0, max(0, _line_count - 1));
							if (_new_line == _line) {
								_i += 1;
								continue;
							}
							var _yoff = renderer.get_line_y_offset(_new_line);
							var _sticky = _c.sticky_px;
							if (is_undefined(_sticky) || _sticky == 0) {
								_sticky = renderer.get_x_from_index(_c.index);
								_c.sticky_px = _sticky;
							}
							var _new_index = renderer.get_index_from_xy(x + _sticky, y + _yoff);
							var _nc = __cursor_record_create__(_new_index);
							_nc.sticky_px = _sticky;
							array_push(_added, _nc);
							_i += 1;
						}
						var _m = array_length(_added);
						if (_m <= 0) return false;
						_i = 0;
						repeat (_m) {
							array_push(__cursors__, _added[_i]);
							_i += 1;
						}
						__cursor_active__ = array_length(__cursors__) - 1;
						__cursors_sort_and_dedupe_by_index__();
						__cursors_sync_sticky_x__();
						__history_update_latest_cursor__();
						return true;
					};
					#region jsDoc
					/// @func    __cursor_select_word_if_empty__()
					/// @ignore
					/// @desc    Ensures the active cursor has a non-empty selection; if empty, selects the word under the caret.
					/// @self    WWTextField
					/// @returns {Bool} True if a selection exists/was created.
					#endregion
					static __cursor_select_word_if_empty__ = function() {
						var _c = __cursors__[__cursor_active__];
						if (_c.highlight_active && _c.highlight_start_index != _c.highlight_end_index) return true;
						var _loc = __compute_word_boundaries__(_c.index);
						if (is_undefined(_loc) || !is_struct(_loc)) return false;
						if (_loc.index_start == _loc.index_end) return false;
						_c.highlight_active = true;
						_c.highlight_start_index = _loc.index_start;
						_c.highlight_end_index = _loc.index_end;
						__cursor_set_index_synced__(_loc.index_end, true);
						return true;
					};
					#region jsDoc
					/// @func    __cursors_get_merged_selection_ranges__()
					/// @ignore
					/// @desc    Returns merged (unioned) selection ranges across all cursors as [{a,b},...], sorted by a.
					/// @self    WWTextField
					/// @returns {Array}
					#endregion
					static __cursors_get_merged_selection_ranges__ = function() {
						var _ranges = [];
						var _n = array_length(__cursors__);
						var _i = 0;
						repeat (_n) {
							var _c = __cursors__[_i];
							if (_c.highlight_active && _c.highlight_start_index != _c.highlight_end_index) {
								var _a = min(_c.highlight_start_index, _c.highlight_end_index);
								var _b = max(_c.highlight_start_index, _c.highlight_end_index);
								array_push(_ranges, { a: _a, b: _b });
							}
							_i += 1;
						}
						var _rlen = array_length(_ranges);
						if (_rlen <= 1) return _ranges;
						// sort
						var _j = 1;
						while (_j < _rlen) {
							var _key = _ranges[_j];
							var _k = _j - 1;
							while (_k >= 0 && _ranges[_k].a > _key.a) {
								_ranges[_k + 1] = _ranges[_k];
								_k -= 1;
							}
							_ranges[_k + 1] = _key;
							_j += 1;
						}
						// merge overlaps/touching
						var _merged = [];
						array_push(_merged, _ranges[0]);
						var _i2 = 1;
						repeat (_rlen - 1) {
							var _cur = _ranges[_i2];
							var _last = _merged[array_length(_merged) - 1];
							if (_cur.a <= _last.b) {
								_last.b = max(_last.b, _cur.b);
								_merged[array_length(_merged) - 1] = _last;
							}
							else {
								array_push(_merged, _cur);
							}
							_i2 += 1;
						}
						return _merged;
					};
					#region jsDoc
					/// @func    __ranges_overlap_any__()
					/// @ignore
					/// @desc    Tests whether [a,b) overlaps any range in a range list.
					/// @self    WWTextField
					/// @param   {Array} ranges
					/// @param   {Real}  a
					/// @param   {Real}  b
					/// @returns {Bool}
					#endregion
					static __ranges_overlap_any__ = function(_ranges, _a, _b) {
						var _n = array_length(_ranges);
						var _i = 0;
						repeat (_n) {
							var _r = _ranges[_i];
							if (_a < _r.b && _b > _r.a) return true;
							_i += 1;
						}
						return false;
					};
					#region jsDoc
					/// @func    __cursors_add_occurrence_selection__()
					/// @ignore
					/// @desc    Adds a new cursor with an active selection range [a,b].
					/// @self    WWTextField
					/// @param   {Real} a
					/// @param   {Real} b
					/// @returns {Undefined}
					#endregion
					static __cursors_add_occurrence_selection__ = function(_a, _b) {
						var _cid = array_length(__cursors__);
						var _c = __cursor_record_create__(_b);
						_c.highlight_active = true;
						_c.highlight_start_index = _a;
						_c.highlight_end_index = _b;
						_c.index = _b;
						_c.sticky_px = renderer.get_x_from_index(_b);
						array_push(__cursors__, _c);
						__cursor_active__ = _cid;
					};
					#region jsDoc
					/// @func    __cursors_add_next_occurrence__()
					/// @ignore
					/// @desc    Adds the next occurrence of the current selection/word as a new selection cursor.
					/// @self    WWTextField
					/// @returns {Bool}
					#endregion
					static __cursors_add_next_occurrence__ = function() {
						if (!__cursor_select_word_if_empty__()) return false;
						var _c = __cursors__[__cursor_active__];
						var _a0 = min(_c.highlight_start_index, _c.highlight_end_index);
						var _b0 = max(_c.highlight_start_index, _c.highlight_end_index);
						var _needle = buffer.get_substring(buffer.get_byte_index_from_index(_a0), buffer.get_byte_index_from_index(_b0));
						if (_needle == "") return false;
						var _text = buffer.get_text();
						var _needle_len = string_length(_needle);
						if (_needle_len <= 0) return false;
						var _ranges = __cursors_get_merged_selection_ranges__();
						// Search start: after the last selected range end
						var _search_index = _b0;
						var _i = 0;
						repeat (array_length(_ranges)) {
							_search_index = max(_search_index, _ranges[_i].b);
							_i += 1;
						}
						var _pos1 = string_pos_ext(_needle, _text, _search_index + 1);
						while (_pos1 > 0) {
							var _idx = _pos1 - 1;
							var _a = _idx;
							var _b = _idx + _needle_len;
							if (!__ranges_overlap_any__(_ranges, _a, _b)) {
								__cursors_add_occurrence_selection__(_a, _b);
								__cursors_sort_and_dedupe_by_index__();
								__history_update_latest_cursor__();
								return true;
							}
							_pos1 = string_pos_ext(_needle, _text, _pos1 + 1);
						}
						// Wrap search
						_pos1 = string_pos_ext(_needle, _text, 1);
						while (_pos1 > 0 && _pos1 - 1 < _search_index) {
							var _idx2 = _pos1 - 1;
							var _a2 = _idx2;
							var _b2 = _idx2 + _needle_len;
							if (!__ranges_overlap_any__(_ranges, _a2, _b2)) {
								__cursors_add_occurrence_selection__(_a2, _b2);
								__cursors_sort_and_dedupe_by_index__();
								__history_update_latest_cursor__();
								return true;
							}
							_pos1 = string_pos_ext(_needle, _text, _pos1 + 1);
						}
						return false;
					};
					#region jsDoc
					/// @func    __cursors_add_all_occurrences__()
					/// @ignore
					/// @desc    Adds cursors/selections for all non-overlapping occurrences of the current selection/word.
					///         Intended for Sublime-style “select all occurrences”.
					/// @self    WWTextField
					/// @returns {Bool}
					#endregion
					static __cursors_add_all_occurrences__ = function() {
						if (!__cursor_select_word_if_empty__()) return false;
						var _c = __cursors__[__cursor_active__];
						var _a0 = min(_c.highlight_start_index, _c.highlight_end_index);
						var _b0 = max(_c.highlight_start_index, _c.highlight_end_index);
						var _needle = buffer.get_substring(buffer.get_byte_index_from_index(_a0), buffer.get_byte_index_from_index(_b0));
						if (_needle == "") return false;
						var _text = buffer.get_text();
						var _needle_len = string_length(_needle);
						if (_needle_len <= 0) return false;
						var _pos1 = 1;
						var _added = 0;
						var _ranges = __cursors_get_merged_selection_ranges__();
						_pos1 = string_pos_ext(_needle, _text, 1);
						while (_pos1 > 0) {
							var _idx = _pos1 - 1;
							var _a = _idx;
							var _b = _idx + _needle_len;
							if (!__ranges_overlap_any__(_ranges, _a, _b)) {
								__cursors_add_occurrence_selection__(_a, _b);
								array_push(_ranges, { a: _a, b: _b });
								_added += 1;
								if (_added >= 1024) break;
							}
							_pos1 = string_pos_ext(_needle, _text, _pos1 + 1);
						}
						if (_added > 0) {
							__cursors_sort_and_dedupe_by_index__();
							__history_update_latest_cursor__();
							return true;
						}
						return false;
					};
					#region jsDoc
					/// @func    __cursor_rotate_next_occurrence__()
					/// @ignore
					/// @desc    For a single selection/word, moves the selection to the next occurrence (wraps).
					///         Returns false when multi-cursor is active or no match exists.
					/// @self    WWTextField
					/// @returns {Bool}
					#endregion
					static __cursor_rotate_next_occurrence__ = function() {
						if (array_length(__cursors__) != 1) return false;
						if (!__cursor_select_word_if_empty__()) return false;
						var _c = __cursors__[0];
						var _a0 = min(_c.highlight_start_index, _c.highlight_end_index);
						var _b0 = max(_c.highlight_start_index, _c.highlight_end_index);
						var _needle = buffer.get_substring(buffer.get_byte_index_from_index(_a0), buffer.get_byte_index_from_index(_b0));
						if (_needle == "") return false;
						var _text = buffer.get_text();
						var _needle_len = string_length(_needle);
						var _pos1 = string_pos_ext(_needle, _text, _b0 + 1);
						if (_pos1 <= 0) _pos1 = string_pos_ext(_needle, _text, 1);
						if (_pos1 <= 0) return false;
						var _idx = _pos1 - 1;
						var _a = _idx;
						var _b = _idx + _needle_len;
						_c.highlight_active = true;
						_c.highlight_start_index = _a;
						_c.highlight_end_index = _b;
						__cursor_set_index_synced__(_b, true);
						__history_update_latest_cursor__();
						return true;
					};
					#region jsDoc
					/// @func    __cursors_split_selection_into_lines__()
					/// @ignore
					/// @desc    Splits a single selection into per-line selections, producing one cursor per line.
					///         Returns false if there is not exactly one non-empty selection.
					/// @self    WWTextField
					/// @returns {Bool}
					#endregion
					static __cursors_split_selection_into_lines__ = function() {
						if (array_length(__cursors__) != 1) return false;
						var _c = __cursors__[0];
						if (!_c.highlight_active || _c.highlight_start_index == _c.highlight_end_index) return false;
						var _a = min(_c.highlight_start_index, _c.highlight_end_index);
						var _b = max(_c.highlight_start_index, _c.highlight_end_index);
						var _start_line = renderer.get_line_from_index(_a);
						var _end_line = renderer.get_line_from_index(max(_a, _b - 1));
						var _last_line_index = renderer.get_line_count() - 1;
						var _out = [];
						var _line = _start_line;
						while (_line <= _end_line) {
							var _ls = renderer.get_line_index_start(_line);
							var _le = renderer.get_line_index_end(_line);
							var _sa = max(_a, _ls);
							var _sb = min(_b, _le);
							if (!renderer.get_line_forced_wrapped(_line) && _line != _last_line_index) {
								// avoid selecting the literal line break when selecting to EOL
								if (_sb == _le) {
									_sb = max(_sa, _sb - 1);
								}
							}
							var _nc = __cursor_record_create__(_sb);
							_nc.highlight_active = true;
							_nc.highlight_start_index = _sa;
							_nc.highlight_end_index = _sb;
							_nc.index = _sb;
							_nc.sticky_px = renderer.get_x_from_index(_sb);
							array_push(_out, _nc);
							_line += 1;
						}
						if (array_length(_out) <= 0) return false;
						__cursors__ = _out;
						__cursor_active__ = array_length(__cursors__) - 1;
						__cursors_sort_and_dedupe_by_index__();
						__cursors_sync_sticky_x__();
						__history_update_latest_cursor__();
						return true;
					};
					#region jsDoc
					/// @func    __cursors_copy_selections_to_clipboard__()
					/// @ignore
					/// @desc    Copies multi-cursor selections to clipboard, merging overlapping/touching selections.
					///         Clipboard output joins merged ranges with '\n'.
					/// @self    WWTextField
					/// @returns {Bool} True if clipboard was set; false if fewer than 2 cursors or any selection was empty.
					#endregion
					static __cursors_copy_selections_to_clipboard__ = function() {
						var _n = array_length(__cursors__);
						if (_n <= 1) return false;
				
						// Require every cursor to have a non-empty selection.
						var _ranges = [];
						array_resize(_ranges, _n);
						var _i = 0;
						repeat (_n) {
							var _c = __cursors__[_i];
							if (!_c.highlight_active || _c.highlight_start_index == _c.highlight_end_index) {
								return false;
							}
							var _a = min(_c.highlight_start_index, _c.highlight_end_index);
							var _b = max(_c.highlight_start_index, _c.highlight_end_index);
							_ranges[_i] = { a: _a, b: _b, cid: _i };
							_i += 1;
						}
				
						// Sort ascending by selection start (stable order in text).
						var _j = 1;
						while (_j < _n) {
							var _key = _ranges[_j];
							var _k = _j - 1;
							while (_k >= 0 && _ranges[_k].a > _key.a) {
								_ranges[_k + 1] = _ranges[_k];
								_k -= 1;
							}
							_ranges[_k + 1] = _key;
							_j += 1;
						}
					
						// Merge overlaps (and touching ranges) so overlapping selections become one logical selection.
						var _merged = [];
						array_push(_merged, { a: _ranges[0].a, b: _ranges[0].b });
						_i = 1;
						repeat (_n - 1) {
							var _cur = _ranges[_i];
							var _last = _merged[array_length(_merged) - 1];
							if (_cur.a <= _last.b) {
								_last.b = max(_last.b, _cur.b);
								_merged[array_length(_merged) - 1] = _last;
							}
							else {
								array_push(_merged, { a: _cur.a, b: _cur.b });
							}
							_i += 1;
						}
				
						// Build the clipboard string as merged-ranges separated by \n.
						var _out = "";
						var _m = array_length(_merged);
						_i = 0;
						repeat (_m) {
							var _r = _merged[_i];
							var _bs = buffer.get_byte_index_from_index(_r.a);
							var _be = buffer.get_byte_index_from_index(_r.b);
							var _piece = buffer.get_substring(_bs, _be);
							if (_i > 0) _out += "\n";
							_out += _piece;
							_i += 1;
						}
				
						__clipboard_set_text__(_out);
						return true;
					};
					#region jsDoc
					/// @func    __insert_lines_at_cursors__()
					/// @ignore
					/// @desc    Multi-cursor paste helper. Inserts one string per cursor (mapped by cursor index order).
					///         Returns false if cursor count != line count or if selections overlap.
					/// @self    WWTextField
					/// @param   {Array} lines : Array of strings, one per cursor.
					/// @returns {Bool}
					#endregion
					static __insert_lines_at_cursors__ = function(_lines) {
						var _n = array_length(__cursors__);
						if (_n <= 1) return false;
						if (array_length(_lines) != _n) return false;
				
						// If selections overlap, fall back to normal paste.
						var _sel = [];
						var _slen = 0;
						var _i = 0;
						repeat (_n) {
							var _c0 = __cursors__[_i];
							if (_c0.highlight_active && _c0.highlight_start_index != _c0.highlight_end_index) {
								var _a0 = min(_c0.highlight_start_index, _c0.highlight_end_index);
								var _b0 = max(_c0.highlight_start_index, _c0.highlight_end_index);
								array_push(_sel, { a: _a0, b: _b0 });
							}
							_i += 1;
						}
						_slen = array_length(_sel);
						if (_slen > 1) {
							// sort and check overlaps
							var _j = 1;
							while (_j < _slen) {
								var _key = _sel[_j];
								var _k = _j - 1;
								while (_k >= 0 && _sel[_k].a > _key.a) {
									_sel[_k + 1] = _sel[_k];
									_k -= 1;
								}
								_sel[_k + 1] = _key;
								_j += 1;
							}
							_i = 1;
							while (_i < _slen) {
								if (_sel[_i].a < _sel[_i - 1].b) {
									return false;
								}
								_i += 1;
							}
						}
				
						// Map clipboard lines to cursors by cursor index order (ascending).
						var _ids_asc = __cursors_sorted_ids_by_index__(false);
						var _line_for_cid = [];
						array_resize(_line_for_cid, _n);
						_i = 0;
						repeat (_n) {
							var _cid = _ids_asc[_i];
							_line_for_cid[_cid] = _lines[_i];
							_i += 1;
						}
				
						// Apply edits from right-to-left to keep indices stable.
						var _ids_desc = __cursors_sorted_ids_by_index__(true);
						_i = 0;
						repeat (_n) {
							var _cid2 = _ids_desc[_i];
							var _c = __cursors__[_cid2];
							var _raw = _line_for_cid[_cid2];
							_raw = __clipboard_strip_trailing_cr__(_raw);
							var _text = buffer.__filter_allowed__(_raw);
					
							// Replace selection for this cursor only.
							if (_c.highlight_active && _c.highlight_start_index != _c.highlight_end_index) {
								var _a = min(_c.highlight_start_index, _c.highlight_end_index);
								var _b = max(_c.highlight_start_index, _c.highlight_end_index);
								var _bs = buffer.get_byte_index_from_index(_a);
								var _be = buffer.get_byte_index_from_index(_b);
								buffer.erase(_bs, _be);
								__cursors_shift_after_delete__(_a, _b, _b - _a);
								_c = __cursors__[_cid2];
								_c.index = _a;
								_c.highlight_active = false;
								_c.highlight_start_index = _c.index;
								_c.highlight_end_index = _c.index;
							}
					
							var _insert_at = clamp(_c.index, 0, renderer.get_glyph_count());
							if (_text != "") {
								var _len = string_length(_text);
								var _bi = buffer.get_byte_index_from_index(_insert_at);
								buffer.insert(_bi, _text);
								__cursors_shift_right_of__(_insert_at, _len);
								_c.index = _insert_at + _len;
								_c.highlight_active = false;
								_c.highlight_start_index = _c.index;
								_c.highlight_end_index = _c.index;
							}
					
							_i += 1;
						}
				
						__force_rebuild__();
						__cursors_sync_sticky_x__();
						__history_add_record__();
						trigger_event(events.change);
						return true;
					};
				
				#endregion
				
			#endregion
			
			#region Undo / Redo
				
				#region jsDoc
				/// @func    __history_record_create__()
				/// @ignore
				/// @desc    Constructor for an undo/redo snapshot.
				/// @self    WWTextField
				/// @param   {String} content : Full text content.
				/// @param   {Array} cursors : Cursor record array.
				/// @param   {Real} cursor_active : Active cursor id.
				/// @returns {Struct} A history snapshot.
				#endregion
				static __history_record_create__ = function(_content, _cursors, _cursor_active) constructor {
					content = _content;
					cursors = _cursors;
					cursor_active = _cursor_active;
				};
				
				#region jsDoc
				/// @func    __history_add_record__()
				/// @ignore
				/// @desc    Captures a new snapshot and pushes it to the undo history.
				/// @self    WWTextField
				/// @returns {Undefined}
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
						__cursors_clone__(),
						__cursor_active__
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
				/// @ignore
				/// @desc    Updates the most recent snapshot's cursor field.
				/// @self    WWTextField
				/// @returns {Undefined}
				#endregion
				static __history_update_latest_cursor__ = function() {
					var _count = array_length(__historic_records__);
					if (_count <= 0) {
						__history_add_record__();
						return;
					}
					if (__historic_records_loc__ < 0 || __historic_records_loc__ >= _count) {
						__historic_records_loc__ = _count - 1;
					}

					var _record = __historic_records__[__historic_records_loc__];
					_record.cursors = __cursors_clone__();
					_record.cursor_active = __cursor_active__;
				};
				
				#region jsDoc
				/// @func    __history_jump__()
				/// @ignore
				/// @desc    Moves through undo/redo history by a signed offset
				///          and restores the corresponding snapshot.
				/// @self    WWTextField
				/// @param   {Real} change : Negative=undo, Positive=redo.
				/// @returns {Undefined}
				#endregion
				static __history_jump__ = function(_change) {

					var _target = __historic_records_loc__ + _change;

					// Bounds check
					if (_target < 0 || _target >= array_length(__historic_records__)) {
						return;
					}

					var _record = __historic_records__[_target];

					buffer.set_text(_record.content);
					__cursors__ = __cursors_clone_from__(_record.cursors);
					__cursor_active__ = clamp(_record.cursor_active, 0, max(0, array_length(__cursors__) - 1));
					
					__historic_records_loc__ = _target;

					__force_rebuild__();
					if (!multi_cursor_enabled && array_length(__cursors__) > 1) {
						var _idx = clamp(__cursors__[__cursor_active__].index, 0, renderer.get_glyph_count());
						__cursors__ = [ __cursor_record_create__(_idx) ];
						__cursor_active__ = 0;
						__cursors__[0].sticky_px = renderer.get_x_from_index(_idx);
						cursor_last_width = __cursors__[0].sticky_px;
					}
					else {
						__cursors_sync_sticky_x__();
					}
					trigger_event(events.change);
				};
				
			#endregion
			
			#region jsDoc
			/// @func    __force_rebuild__()
			/// @ignore
			/// @desc    Marks buffer/renderer as dirty and forces the renderer to ensure a valid layout.
			/// @self    WWTextField
			/// @returns {Undefined}
			#endregion
			static __force_rebuild__ = function(){
				buffer.__mark_dirty__();
				renderer.__mark_dirty__();
				renderer.__ensure_layout__();
			}
			
			#region jsDoc
			/// @func    __get_renderer__()
			/// @ignore
			/// @desc    Returns the active renderer instance.
			/// @self    WWTextField
			/// @returns {Struct|Undefined}
			#endregion
			static __get_renderer__ = function(){
				return renderer;
			}
			
			#region jsDoc
			/// @func    __cursor_blink_reset__()
			/// @ignore
			/// @desc    Resets the caret blink timer so the caret is immediately visible.
			/// @self    WWTextField
			/// @returns {Undefined}
			#endregion
			static __cursor_blink_reset__ = function() {
				__cursor_blink_start_ms__ = current_time;
			};
			
			#region jsDoc
			/// @func    __cursor_set_index_synced__()
			/// @ignore
			/// @desc    Sets cursor index, syncs selection rules, and optionally updates sticky x (cursor_last_width).
			/// @self    WWTextField
			/// @param   {Real} new_index
			/// @param   {Bool} shift_select
			/// @param   {Bool} update_history
			/// @param   {Bool} update_width
			/// @returns {Undefined}
			#endregion
			static __cursor_set_index_synced__ = function(_new_index, _shift_select = false, _update_history = true, _update_width = true) {
				
				var _c = __cursors__[__cursor_active__];
				var _old_index = _c.index;
				
				//if (_old_index == _new_index) return;
				
				_c.index = clamp(_new_index, 0, renderer.get_glyph_count());
				if (_c.index != _old_index || _shift_select) {
					__cursor_blink_reset__();
				}
				
				var _selection_is_non_zero = _c.index != _c.highlight_start_index;
				
				
				if (_shift_select && _selection_is_non_zero) {
					if (!_c.highlight_active) {
						_c.highlight_start_index = _old_index;
						_c.highlight_end_index = _c.index;
						_c.highlight_active = true;
					}
					_c.highlight_end_index = _c.index;
				}
				else {
					_c.highlight_active = false;
					_c.highlight_start_index = _c.index;
					_c.highlight_end_index = _c.index;
				}

				if (_update_width) {
					var _sx = renderer.get_x_from_index(_c.index);
					_c.sticky_px = _sx;
					cursor_last_width = _sx;
				}

				if (_update_history) {
					__history_update_latest_cursor__();
				}
			};
			
			#region Multi-cursor navigation helpers
			
				#region jsDoc
				/// @func    __cursors_sync_sticky_x__()
				/// @ignore
				/// @desc    Recomputes sticky-x for all cursors from their indices and updates cursor_last_width.
				/// @self    WWTextField
				/// @returns {Undefined}
				#endregion
				static __cursors_sync_sticky_x__ = function() {
					var _n = array_length(__cursors__);
					var _i = 0;
					repeat (_n) {
						var _c = __cursors__[_i];
						_c.sticky_px = renderer.get_x_from_index(_c.index);
						_i += 1;
					}
					cursor_last_width = __cursors__[__cursor_active__].sticky_px;
				};
				#region jsDoc
				/// @func    __cursor_set_index_synced_for__()
				/// @ignore
				/// @desc    Sets index/selection state for a specific cursor id (used by multi-cursor movement).
				/// @self    WWTextField
				/// @param   {Real} cid
				/// @param   {Real} new_index
				/// @param   {Bool} shift_select
				/// @param   {Bool} update_width
				/// @returns {Undefined}
				#endregion
				static __cursor_set_index_synced_for__ = function(_cid, _new_index, _shift_select = false, _update_width = true) {
					var _c = __cursors__[_cid];
					var _old_index = _c.index;
					_c.index = clamp(_new_index, 0, renderer.get_glyph_count());
					if (_c.index != _old_index || _shift_select) {
						__cursor_blink_reset__();
					}
					var _selection_is_non_zero = _c.index != _c.highlight_start_index;
					if (_shift_select && _selection_is_non_zero) {
						if (!_c.highlight_active) {
							_c.highlight_start_index = _old_index;
							_c.highlight_end_index = _c.index;
							_c.highlight_active = true;
						}
						_c.highlight_end_index = _c.index;
					}
					else {
						_c.highlight_active = false;
						_c.highlight_start_index = _c.index;
						_c.highlight_end_index = _c.index;
					}
					if (_update_width) {
						_c.sticky_px = renderer.get_x_from_index(_c.index);
						if (_cid == __cursor_active__) {
							cursor_last_width = _c.sticky_px;
						}
					}
				};
				#region jsDoc
				/// @func    __cursors_move_offset__()
				/// @ignore
				/// @desc    Moves all cursors by a signed offset (horizontal/vertical) with optional word-mode.
				/// @self    WWTextField
				/// @param   {Real} vector
				/// @param   {Bool} shift
				/// @param   {Bool} vertical
				/// @param   {Bool} word_mode
				/// @returns {Undefined}
				#endregion
				static __cursors_move_offset__ = function(_vector, _shift, _vertical, _word_mode=false) {
					static __word_breakers = "\n"+chr(9)+chr(34)+" ,.;:?!><#$%&'()*+-/=@[\]^`{|}~¡¢£¤¥¦§¨©«¬­®¯°±´¶·¸»¿×÷";
					if (_vector == 0) return;
					var _n = array_length(__cursors__);
					var _i = 0;
					repeat (_n) {
						var _c = __cursors__[_i];
						var _index = _c.index;
						var _new_index = _index;
						if (_vertical) {
							var _line = renderer.get_line_from_index(_index);
							var _line_count = renderer.get_line_count();
							var _new_line = clamp(_line + _vector, 0, max(0, _line_count - 1));
							var _yoff = renderer.get_line_y_offset(_new_line);
							var _sticky = _c.sticky_px;
							if (is_undefined(_sticky) || _sticky == 0) {
								_sticky = renderer.get_x_from_index(_index);
								_c.sticky_px = _sticky;
							}
							_new_index = renderer.get_index_from_xy(x + _sticky, y + _yoff);
							// Vertical move should NOT update sticky-x.
							__cursor_set_index_synced_for__(_i, _new_index, _shift, false);
						}
						else {
							if (_word_mode) {
								var _idx2 = _index + _vector;
								var _line2 = renderer.get_line_from_index(_idx2);
								var _start = renderer.get_line_index_start(_line2);
								var _end   = renderer.get_line_index_end(_line2);
								var _v = sign(_vector);
								var _newi = _index;
								var _j = _index + _v;
								var _length = (_v) ? _end - _j : _j - _start + 1;
								repeat (_length) {
									var _char = renderer.get_glyph_char(_j);
									if (string_pos(_char, __word_breakers)) {
										if (_v) {
											_newi = _j;
										}
										break;
									}
									_newi = _j;
									_j += _v;
								}
								_new_index = _newi;
							}
							else {
								_new_index = clamp(_index + _vector, 0, renderer.get_glyph_count());
							}
							__cursor_set_index_synced_for__(_i, _new_index, _shift, true);
						}
						_i += 1;
					}
					cursor_last_width = __cursors__[__cursor_active__].sticky_px;
					__history_update_latest_cursor__();
				};
				#region jsDoc
				/// @func    __cursors_move_paged_offset__()
				/// @ignore
				/// @desc    Moves all cursors by a page-up/page-down style vertical offset while preserving sticky-x.
				/// @self    WWTextField
				/// @param   {Real} vector
				/// @param   {Bool} shift
				/// @returns {Undefined}
				#endregion
				static __cursors_move_paged_offset__ = function(_vector, _shift) {
					if (_vector == 0) return;
					var _n = array_length(__cursors__);
					var _i = 0;
					repeat (_n) {
						var _c = __cursors__[_i];
						var _cursor_index = _c.index;
						var _current_line = renderer.get_line_from_index(_cursor_index);
						var _line_count = renderer.get_line_count();
						var _current_y_offset = renderer.get_line_y_offset(_current_line);
						var _page_height = height * 0.75 * abs(_vector);
						var _target_y_offset = _current_y_offset + (_page_height * _vector);
						var _target_line = _current_line;
						if (_vector > 0) {
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
						var _final_y_offset = renderer.get_line_y_offset(_target_line);
						var _sticky = _c.sticky_px;
						if (is_undefined(_sticky) || _sticky == 0) {
							_sticky = renderer.get_x_from_index(_cursor_index);
							_c.sticky_px = _sticky;
						}
						var _new_index = renderer.get_index_from_xy(x + _sticky, y + _final_y_offset);
						// Page move is vertical; do NOT update sticky-x.
						__cursor_set_index_synced_for__(_i, _new_index, _shift, false);
						_i += 1;
					}
					cursor_last_width = __cursors__[__cursor_active__].sticky_px;
					__history_update_latest_cursor__();
				};
			
			#endregion
			
			#region jsDoc
			/// @func    __delete_selection_if_any__()
			/// @ignore
			/// @desc    If a highlight selection exists, erase it from the buffer and place the cursor.
			/// @self    WWTextField
			/// @param   {Bool} force_rebuild
			/// @param   {Bool} push_history
			/// @returns {Bool} True if something was deleted, false otherwise
			#endregion
			static __delete_selection_if_any__ = function(_force_rebuild = true, _push_history = true) {
				var _ranges = [];
				var _n = array_length(__cursors__);
				var _i = 0;
				repeat (_n) {
					var _c = __cursors__[_i];
					if (_c.highlight_active && _c.highlight_start_index != _c.highlight_end_index) {
						var _a = min(_c.highlight_start_index, _c.highlight_end_index);
						var _b = max(_c.highlight_start_index, _c.highlight_end_index);
						array_push(_ranges, { a: _a, b: _b });
					}
					_i += 1;
				}
				if (array_length(_ranges) == 0) return false;
				
				// Sort ascending by start (simple insertion sort for small counts)
				var _rlen = array_length(_ranges);
				var _j = 1;
				while (_j < _rlen) {
					var _key = _ranges[_j];
					var _k = _j - 1;
					while (_k >= 0 && _ranges[_k].a > _key.a) {
						_ranges[_k + 1] = _ranges[_k];
						_k -= 1;
					}
					_ranges[_k + 1] = _key;
					_j += 1;
				}
				
				// Merge overlaps
				var _merged = [];
				array_push(_merged, _ranges[0]);
				_i = 1;
				repeat (_rlen - 1) {
					var _cur = _ranges[_i];
					var _last = _merged[array_length(_merged) - 1];
					if (_cur.a <= _last.b) {
						_last.b = max(_last.b, _cur.b);
						_merged[array_length(_merged) - 1] = _last;
					}
					else {
						array_push(_merged, _cur);
					}
					_i += 1;
				}
				
				// Delete from right-to-left so indices remain stable
				var _m = array_length(_merged);
				_i = _m - 1;
				while (_i >= 0) {
					var _range = _merged[_i];
					var _min_index = _range.a;
					var _max_index = _range.b;
					
					var _buffer_start = buffer.get_byte_index_from_index(_min_index);
					var _buffer_end = buffer.get_byte_index_from_index(_max_index);
					buffer.erase(_buffer_start, _buffer_end);
					
					var _delta = _max_index - _min_index;
					__cursors_shift_after_delete__(_min_index, _max_index, _delta);
					
					_i -= 1;
				}
				
				// Clear selections after delete and clamp active cursor
				_i = 0;
				_n = array_length(__cursors__);
				repeat (_n) {
					var _c2 = __cursors__[_i];
					_c2.highlight_active = false;
					_c2.highlight_start_index = _c2.index;
					_c2.highlight_end_index = _c2.index;
					_i += 1;
				}
				
				if (_force_rebuild) {
					__force_rebuild__();
					__cursors_sync_sticky_x__();
				}
				if (_push_history) {
					__history_add_record__();
				}
				return true;
			};
			
			#region Cursor helpers (textfield-owned)
			
				#region jsDoc
				/// @func    __cursor_get_index__()
				/// @ignore
				/// @desc    Returns the active cursor index (global glyph index in renderer/buffer space).
				/// @self    WWTextField
				/// @returns {Real}
				#endregion
				static __cursor_get_index__ = function() {
					return __cursors__[__cursor_active__].index;
				};
				#region jsDoc
				/// @func    __cursor_get_highlight_active__()
				/// @ignore
				/// @desc    Returns whether the active cursor has selection mode enabled.
				/// @self    WWTextField
				/// @returns {Bool}
				#endregion
				static __cursor_get_highlight_active__ = function() {
					return __cursors__[__cursor_active__].highlight_active;
				};
				#region jsDoc
				/// @func    __cursor_get_highlight_start_index__()
				/// @ignore
				/// @desc    Returns the active cursor selection anchor/start index.
				/// @self    WWTextField
				/// @returns {Real}
				#endregion
				static __cursor_get_highlight_start_index__ = function() {
					return __cursors__[__cursor_active__].highlight_start_index;
				};
				#region jsDoc
				/// @func    __cursor_get_highlight_end_index__()
				/// @ignore
				/// @desc    Returns the active cursor selection end index.
				/// @self    WWTextField
				/// @returns {Real}
				#endregion
				static __cursor_get_highlight_end_index__ = function() {
					return __cursors__[__cursor_active__].highlight_end_index;
				};
				#region jsDoc
				/// @func    __cursor_set_highlight_active__()
				/// @ignore
				/// @desc    Sets highlight_active for the active cursor.
				/// @self    WWTextField
				/// @param   {Bool} active
				/// @returns {Undefined}
				#endregion
				static __cursor_set_highlight_active__ = function(_active) {
					__cursors__[__cursor_active__].highlight_active = _active;
				};
				#region jsDoc
				/// @func    __cursor_set_highlight_start_index__()
				/// @ignore
				/// @desc    Sets highlight_start_index for the active cursor.
				/// @self    WWTextField
				/// @param   {Real} index
				/// @returns {Undefined}
				#endregion
				static __cursor_set_highlight_start_index__ = function(_index) {
					__cursors__[__cursor_active__].highlight_start_index = _index;
				};
				#region jsDoc
				/// @func    __cursor_set_highlight_end_index__()
				/// @ignore
				/// @desc    Sets highlight_end_index for the active cursor.
				/// @self    WWTextField
				/// @param   {Real} index
				/// @returns {Undefined}
				#endregion
				static __cursor_set_highlight_end_index__ = function(_index) {
					__cursors__[__cursor_active__].highlight_end_index = _index;
				};
				#region jsDoc
				/// @func    __cursor_set_col__()
				/// @ignore
				/// @desc    Sets the active cursor column on its current line.
				/// @self    WWTextField
				/// @param   {Real} col
				/// @returns {Undefined}
				#endregion
				static __cursor_set_col__ = function(_col) {
					var _line = renderer.get_line_from_index(__cursor_get_index__());
					var _idx = renderer.get_index_from_line_col(_line, _col);
					__cursor_set_index_synced__(_idx, false);
				};
				#region jsDoc
				/// @func    __cursor_set_line__()
				/// @ignore
				/// @desc    Sets the active cursor line while preserving its current column.
				/// @self    WWTextField
				/// @param   {Real} line
				/// @returns {Undefined}
				#endregion
				static __cursor_set_line__ = function(_line) {
					var _col = renderer.get_col_from_index(__cursor_get_index__());
					var _idx = renderer.get_index_from_line_col(_line, _col);
					__cursor_set_index_synced__(_idx, false);
				};
				#region jsDoc
				/// @func    __cursor_set_highlight_start_line__()
				/// @ignore
				/// @desc    Sets highlight_start_index by line while preserving its current column.
				/// @self    WWTextField
				/// @param   {Real} line
				/// @returns {Undefined}
				#endregion
				static __cursor_set_highlight_start_line__ = function(_line) {
					var _col = renderer.get_col_from_index(__cursor_get_highlight_start_index__());
					__cursor_set_highlight_start_index__(renderer.get_index_from_line_col(_line, _col));
				};
				#region jsDoc
				/// @func    __cursor_set_highlight_start_col__()
				/// @ignore
				/// @desc    Sets highlight_start_index by column on its current highlight-start line.
				/// @self    WWTextField
				/// @param   {Real} col
				/// @returns {Undefined}
				#endregion
				static __cursor_set_highlight_start_col__ = function(_col) {
					var _line = renderer.get_line_from_index(__cursor_get_highlight_start_index__());
					__cursor_set_highlight_start_index__(renderer.get_index_from_line_col(_line, _col));
				};
				#region jsDoc
				/// @func    __cursor_set_highlight_end_line__()
				/// @ignore
				/// @desc    Sets highlight_end_index by line while preserving its current column.
				/// @self    WWTextField
				/// @param   {Real} line
				/// @returns {Undefined}
				#endregion
				static __cursor_set_highlight_end_line__ = function(_line) {
					var _col = renderer.get_col_from_index(__cursor_get_highlight_end_index__());
					__cursor_set_highlight_end_index__(renderer.get_index_from_line_col(_line, _col));
				};
				#region jsDoc
				/// @func    __cursor_set_highlight_end_col__()
				/// @ignore
				/// @desc    Sets highlight_end_index by column on its current highlight-end line.
				/// @self    WWTextField
				/// @param   {Real} col
				/// @returns {Undefined}
				#endregion
				static __cursor_set_highlight_end_col__ = function(_col) {
					var _line = renderer.get_line_from_index(__cursor_get_highlight_end_index__());
					__cursor_set_highlight_end_index__(renderer.get_index_from_line_col(_line, _col));
				};

				#region jsDoc
				/// @func    __cursors_clear_to_single__()
				/// @ignore
				/// @desc    Replaces the cursor set with a single caret at the provided index.
				/// @self    WWTextField
				/// @param   {Real} index
				/// @returns {Undefined}
				#endregion
				static __cursors_clear_to_single__ = function(_index) {
					_index = clamp(_index, 0, renderer.get_glyph_count());
					__cursors__ = [ __cursor_record_create__(_index) ];
					__cursor_active__ = 0;
					__cursors__[0].sticky_px = renderer.get_x_from_index(_index);
					cursor_last_width = __cursors__[0].sticky_px;
					__history_update_latest_cursor__();
				};
				#region jsDoc
				/// @func    __cursors_add_at_index__()
				/// @ignore
				/// @desc    Adds a new caret at the given index (no-op if one already exists there).
				/// @self    WWTextField
				/// @param   {Real} index
				/// @returns {Undefined}
				#endregion
				static __cursors_add_at_index__ = function(_index) {
					_index = clamp(_index, 0, renderer.get_glyph_count());
					var _n = array_length(__cursors__);
					var _i = 0;
					repeat (_n) {
						if (__cursors__[_i].index == _index) {
							__cursor_active__ = _i;
							return;
						}
						_i += 1;
					}
					array_push(__cursors__, __cursor_record_create__(_index));
					__cursors__[array_length(__cursors__) - 1].sticky_px = renderer.get_x_from_index(_index);
					__cursor_active__ = array_length(__cursors__) - 1;
					cursor_last_width = __cursors__[__cursor_active__].sticky_px;
					__history_update_latest_cursor__();
				};
				#region jsDoc
				/// @func    __cursors_remove_nearest_to_xy__()
				/// @ignore
				/// @desc    Removes the cursor nearest to the provided GUI position (when multiple cursors exist).
				/// @self    WWTextField
				/// @param   {Real} mx
				/// @param   {Real} my
				/// @param   {Real} threshold
				/// @returns {Undefined}
				#endregion
				static __cursors_remove_nearest_to_xy__ = function(_mx, _my, _threshold) {
					var _n = array_length(__cursors__);
					if (_n <= 1) return;
				
					var _best = -1;
					var _best_d2 = _threshold * _threshold;
				
					var _i = 0;
					repeat (_n) {
						var _c = __cursors__[_i];
						var _line = renderer.get_line_from_index(_c.index);
						var _cx = renderer.x + renderer.get_x_from_index(_c.index);
						var _cy = renderer.y + renderer.get_line_y_offset(_line);
						var _dx = _mx - _cx;
						var _dy = _my - _cy;
						var _d2 = (_dx * _dx) + (_dy * _dy);
						if (_d2 <= _best_d2) {
							_best_d2 = _d2;
							_best = _i;
						}
						_i += 1;
					}
				
					if (_best >= 0) {
						var _removed_was_active = (__cursor_active__ == _best);
						var _removed_before_active = (_best < __cursor_active__);
						array_delete(__cursors__, _best, 1);
						// Preserve the same active cursor when deleting a cursor before it.
						if (_removed_before_active) {
							__cursor_active__ -= 1;
						}
						// If we removed the active cursor, choose the cursor that slid into its slot.
						if (_removed_was_active) {
							__cursor_active__ = clamp(_best, 0, max(0, array_length(__cursors__) - 1));
						} else {
							__cursor_active__ = clamp(__cursor_active__, 0, max(0, array_length(__cursors__) - 1));
						}
						cursor_last_width = __cursors__[__cursor_active__].sticky_px;
						__history_update_latest_cursor__();
					}
				};
				#region jsDoc
				/// @func    __cursors_sorted_ids_by_index__()
				/// @ignore
				/// @desc    Returns cursor ids sorted by cursor index.
				/// @self    WWTextField
				/// @param   {Bool} descending
				/// @returns {Array} Array of cursor indices (ids).
				#endregion
				static __cursors_sorted_ids_by_index__ = function(_descending) {
					var _n = array_length(__cursors__);
					var _ids = [];
					array_resize(_ids, _n);
					var _i = 0;
					repeat (_n) {
						_ids[_i] = _i;
						_i += 1;
					}
					// insertion sort by cursor.index
					var _j = 1;
					while (_j < _n) {
						var _key = _ids[_j];
						var _k = _j - 1;
						while (_k >= 0) {
							var _a = __cursors__[_ids[_k]].index;
							var _b = __cursors__[_key].index;
							if (_descending ? (_a < _b) : (_a > _b)) {
								_ids[_k + 1] = _ids[_k];
								_k -= 1;
								continue;
							}
							break;
						}
						_ids[_k + 1] = _key;
						_j += 1;
					}
					return _ids;
				};
				#region jsDoc
				/// @func    __cursors_shift_right_of__()
				/// @ignore
				/// @desc    Shifts all cursor and selection indices strictly greater than the given index.
				/// @self    WWTextField
				/// @param   {Real} index_exclusive
				/// @param   {Real} delta
				/// @returns {Undefined}
				#endregion
				static __cursors_shift_right_of__ = function(_index_exclusive, _delta) {
					var _n = array_length(__cursors__);
					var _i = 0;
					repeat (_n) {
						var _c = __cursors__[_i];
						if (_c.index > _index_exclusive) _c.index += _delta;
						if (_c.highlight_start_index > _index_exclusive) _c.highlight_start_index += _delta;
						if (_c.highlight_end_index > _index_exclusive) _c.highlight_end_index += _delta;
						_i += 1;
					}
				};
				#region jsDoc
				/// @func    __cursors_shift_after_delete__()
				/// @ignore
				/// @desc    Adjusts cursor/selection indices after deleting the interval [_del_start,_del_end].
				/// @self    WWTextField
				/// @param   {Real} del_start
				/// @param   {Real} del_end
				/// @param   {Real} delta
				/// @returns {Undefined}
				#endregion
				static __cursors_shift_after_delete__ = function(_del_start, _del_end, _delta) {
					var _n = array_length(__cursors__);
					var _i = 0;
					repeat (_n) {
						var _c = __cursors__[_i];
						// index
						if (_c.index > _del_end) _c.index -= _delta;
						else if (_c.index > _del_start) _c.index = _del_start;
						// selection anchors
						if (_c.highlight_start_index > _del_end) _c.highlight_start_index -= _delta;
						else if (_c.highlight_start_index > _del_start) _c.highlight_start_index = _del_start;
						if (_c.highlight_end_index > _del_end) _c.highlight_end_index -= _delta;
						else if (_c.highlight_end_index > _del_start) _c.highlight_end_index = _del_start;
						_i += 1;
					}
				};
				#region jsDoc
				/// @func    __cursors_clone__()
				/// @ignore
				/// @desc    Deep-clones the current cursor array into new cursor records.
				/// @self    WWTextField
				/// @returns {Array} Cursor record array.
				#endregion
				static __cursors_clone__ = function() {
					var _n = array_length(__cursors__);
					var _out = [];
					array_resize(_out, _n);
					var _i = 0;
					repeat (_n) {
						var _c = __cursors__[_i];
						var _nc = __cursor_record_create__(_c.index);
						_nc.highlight_active = _c.highlight_active;
						_nc.highlight_start_index = _c.highlight_start_index;
						_nc.highlight_end_index = _c.highlight_end_index;
						_nc.sticky_px = _c.sticky_px;
						_out[_i] = _nc;
						_i += 1;
					}
					return _out;
				};
				#region jsDoc
				/// @func    __cursors_clone_from__()
				/// @ignore
				/// @desc    Deep-clones a cursor array (or creates a single cursor if undefined/empty).
				/// @self    WWTextField
				/// @param   {Array|Undefined} src
				/// @returns {Array} Cursor record array.
				#endregion
				static __cursors_clone_from__ = function(_src) {
					if (is_undefined(_src)) return [ __cursor_record_create__(0) ];
					var _n = array_length(_src);
					if (_n <= 0) return [ __cursor_record_create__(0) ];
					var _out = [];
					array_resize(_out, _n);
					var _i = 0;
					repeat (_n) {
						var _c = _src[_i];
						var _nc = __cursor_record_create__(_c.index);
						_nc.highlight_active = _c.highlight_active;
						_nc.highlight_start_index = _c.highlight_start_index;
						_nc.highlight_end_index = _c.highlight_end_index;
						_nc.sticky_px = _c.sticky_px;
						_out[_i] = _nc;
						_i += 1;
					}
					return _out;
				};
				#region jsDoc
				/// @func    __delete_backspace_all_cursors__()
				/// @ignore
				/// @desc    Deletes one glyph to the left of each cursor (or deletes selections if any).
				/// @self    WWTextField
				/// @returns {Undefined}
				#endregion
				static __delete_backspace_all_cursors__ = function() {
					if (__delete_selection_if_any__(true, true)) return;
					var _ids = __cursors_sorted_ids_by_index__(true);
					var _n = array_length(_ids);
					var _i = 0;
					repeat (_n) {
						var _cid = _ids[_i];
						var _c = __cursors__[_cid];
						var _idx = _c.index;
						if (_idx <= 0) { _i += 1; continue; }
						var _prev = _idx - 1;
						var _bs = buffer.get_byte_index_from_index(_prev);
						var _be = buffer.get_byte_index_from_index(_idx);
						buffer.erase(_bs, _be);
						__cursors_shift_after_delete__(_prev, _idx, 1);
						_c.index = _prev;
						_c.highlight_active = false;
						_c.highlight_start_index = _c.index;
						_c.highlight_end_index = _c.index;
						_i += 1;
					}
					__force_rebuild__();
					__cursors_sync_sticky_x__();
					__history_add_record__();
				};
				#region jsDoc
				/// @func    __delete_forward_all_cursors__()
				/// @ignore
				/// @desc    Deletes one glyph to the right of each cursor (or deletes selections if any).
				/// @self    WWTextField
				/// @returns {Undefined}
				#endregion
				static __delete_forward_all_cursors__ = function() {
					if (__delete_selection_if_any__(true, true)) return;
					var _glyphs = renderer.get_glyph_count();
					var _ids = __cursors_sorted_ids_by_index__(true);
					var _n = array_length(_ids);
					var _i = 0;
					repeat (_n) {
						var _cid = _ids[_i];
						var _c = __cursors__[_cid];
						var _idx = _c.index;
						if (_idx >= _glyphs) { _i += 1; continue; }
						var _next = _idx + 1;
						var _bs = buffer.get_byte_index_from_index(_idx);
						var _be = buffer.get_byte_index_from_index(_next);
						buffer.erase(_bs, _be);
						__cursors_shift_after_delete__(_idx, _next, 1);
						_c.highlight_active = false;
						_c.highlight_start_index = _c.index;
						_c.highlight_end_index = _c.index;
						_i += 1;
					}
					__force_rebuild__();
					__cursors_sync_sticky_x__();
					__history_add_record__();
				};
				#region jsDoc
				/// @func    __delete_word_left_all_cursors__()
				/// @ignore
				/// @desc    Deletes the word to the left of each cursor (or deletes selections if any).
				/// @self    WWTextField
				/// @returns {Undefined}
				#endregion
				static __delete_word_left_all_cursors__ = function() {
					if (__delete_selection_if_any__(true, true)) return;
					var _ids = __cursors_sorted_ids_by_index__(true);
					var _n = array_length(_ids);
					var _i = 0;
					repeat (_n) {
						var _cid = _ids[_i];
						var _c = __cursors__[_cid];
						var _idx = _c.index;
						if (_idx <= 0) { _i += 1; continue; }
						var _pointed_index = max(0, _idx - 1);
						var _bounds = __compute_word_boundaries__(_pointed_index, false);
						var _start = _bounds.index_start;
						if (_start >= _idx) { _i += 1; continue; }
						var _bs = buffer.get_byte_index_from_index(_start);
						var _be = buffer.get_byte_index_from_index(_idx);
						buffer.erase(_bs, _be);
						var _delta = _idx - _start;
						__cursors_shift_after_delete__(_start, _idx, _delta);
						_c.index = _start;
						_c.highlight_active = false;
						_c.highlight_start_index = _c.index;
						_c.highlight_end_index = _c.index;
						_i += 1;
					}
					__force_rebuild__();
					__cursors_sync_sticky_x__();
					__history_add_record__();
				};
				#region jsDoc
				/// @func    __delete_word_right_all_cursors__()
				/// @ignore
				/// @desc    Deletes the word to the right of each cursor (or deletes selections if any).
				/// @self    WWTextField
				/// @returns {Undefined}
				#endregion
				static __delete_word_right_all_cursors__ = function() {
					if (__delete_selection_if_any__(true, true)) return;
					var _glyphs = renderer.get_glyph_count();
					var _ids = __cursors_sorted_ids_by_index__(true);
					var _n = array_length(_ids);
					var _i = 0;
					repeat (_n) {
						var _cid = _ids[_i];
						var _c = __cursors__[_cid];
						var _idx = _c.index;
						if (_idx >= _glyphs) { _i += 1; continue; }
						var _pointed_index = min(_idx + 1, _glyphs);
						var _bounds = __compute_word_boundaries__(_pointed_index, false);
						var _end = _bounds.index_end;
						if (_end <= _idx) { _i += 1; continue; }
						var _bs = buffer.get_byte_index_from_index(_idx);
						var _be = buffer.get_byte_index_from_index(_end);
						buffer.erase(_bs, _be);
						var _delta = _end - _idx;
						__cursors_shift_after_delete__(_idx, _end, _delta);
						_c.highlight_active = false;
						_c.highlight_start_index = _c.index;
						_c.highlight_end_index = _c.index;
						_i += 1;
					}
					__force_rebuild__();
					__cursors_sync_sticky_x__();
					__history_add_record__();
				};
				#region jsDoc
				/// @func    __delete_to_line_start_all_cursors__()
				/// @ignore
				/// @desc    Deletes from each cursor to the start of its current line (or deletes selections if any).
				/// @self    WWTextField
				/// @returns {Undefined}
				#endregion
				static __delete_to_line_start_all_cursors__ = function() {
					if (__delete_selection_if_any__(true, true)) return;
					var _ids = __cursors_sorted_ids_by_index__(true);
					var _n = array_length(_ids);
					var _i = 0;
					repeat (_n) {
						var _cid = _ids[_i];
						var _c = __cursors__[_cid];
						var _end = _c.index;
						var _line = renderer.get_line_from_index(_end);
						var _start = renderer.get_line_index_start(_line);
						if (_start >= _end) { _i += 1; continue; }
						var _bs = buffer.get_byte_index_from_index(_start);
						var _be = buffer.get_byte_index_from_index(_end);
						buffer.erase(_bs, _be);
						var _delta = _end - _start;
						__cursors_shift_after_delete__(_start, _end, _delta);
						_c.index = _start;
						_c.highlight_active = false;
						_c.highlight_start_index = _c.index;
						_c.highlight_end_index = _c.index;
						_i += 1;
					}
					__force_rebuild__();
					__cursors_sync_sticky_x__();
					__history_add_record__();
				};
				#region jsDoc
				/// @func    __delete_to_line_end_all_cursors__()
				/// @ignore
				/// @desc    Deletes from each cursor to the end of its current line (or deletes selections if any).
				/// @self    WWTextField
				/// @returns {Undefined}
				#endregion
				static __delete_to_line_end_all_cursors__ = function() {
					if (__delete_selection_if_any__(true, true)) return;
					var _ids = __cursors_sorted_ids_by_index__(true);
					var _n = array_length(_ids);
					var _i = 0;
					repeat (_n) {
						var _cid = _ids[_i];
						var _c = __cursors__[_cid];
						var _start = _c.index;
						var _line = renderer.get_line_from_index(_start);
						var _end = renderer.get_line_index_end(_line);
						if not (renderer.get_line_forced_wrapped(_line)) {
							_end -= 1;
						}
						if (_end <= _start) { _i += 1; continue; }
						var _bs = buffer.get_byte_index_from_index(_start);
						var _be = buffer.get_byte_index_from_index(_end);
						buffer.erase(_bs, _be);
						var _delta = _end - _start;
						__cursors_shift_after_delete__(_start, _end, _delta);
						_c.highlight_active = false;
						_c.highlight_start_index = _c.index;
						_c.highlight_end_index = _c.index;
						_i += 1;
					}
					__force_rebuild__();
					__cursors_sync_sticky_x__();
					__history_add_record__();
				};
			
			#endregion
			
		#endregion
		
	#endregion
	
}


enum __WW_Text_Field_Selection_Mode {
	Regular = 0,
	Word = 1,
	Line = 2,
}


