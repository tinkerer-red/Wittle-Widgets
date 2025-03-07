#region jsDoc
/// @func    WWTextBase()
/// @desc    Base text component providing common functionality: text storage, rendering hook, and selection support.
///         By default, it is read-only.
/// @returns {Struct.WWTextBase}
#endregion
function WWTextBase() : WWCore() constructor {
    debug_name = "WWTextBase";
    
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
					if (text.content == _text) return self;
				
					var _prev_cursor_x = get_cursor_x_pos();
					var _prev_cursor_y = get_cursor_y_pos();
				
					clear_text();
					__insert_string_at_cursor__(_text);
				
					set_cursor_x_pos(_prev_cursor_x);
					set_cursor_y_pos(_prev_cursor_y);
				
					if (!__size_set__ || dynamic_width) {
						width = get_content_width();
						height = get_content_height();
					}
				
					__refresh_surf__ = true;
				
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
					if (text.font == _font) return self;
				
					text.font = _font;
				
					if (!__allowed_char_set__) {
						__allowed_char__ = __build_allowed_char__(_font);
					}
				
					if (!__line_height_set__) {
						line_height = font_get_info(_font).size + 1;
					}
				
					if (!__size_set__ || dynamic_width) {
						width = get_content_width();
						height = get_content_height();
					}
				
					__refresh_surf__ = true;
				
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
					if (text.color == _color) return self;
				
					text.color = _color;
					__refresh_surf__ = true;
				
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
					if (text.alpha == _alpha) return self;
				
					text.alpha = _alpha;
				
					__refresh_surf__ = true;
				
					return self;
				}
				
			#endregion
			
			#region jsDoc
			/// @func	set_highlight_color()
			/// @desc	Sets the color for the selection highlight.
			/// @self	WWTextBase
			/// @param   {Constant.Color} _color : The highlight color.
			/// @returns {Struct.WWTextBase}
			#endregion
			static set_highlight_color = function(_color = #0A68D8) {
				highlight_region_color  = _color;
				
				return self;
			}
			
			#region jsDoc
			/// @func    set_dynamic_width()
			/// @desc    Sets the textbox to break to a new line when reaching the width. This will still enforce new lines even for single line text boxes.
			/// @self    GUICompTextbox
			/// @param   {Bool} memory_limit : If the text box will break to a new line when reaching the width.
			/// @returns {Struct.GUICompTextbox}
			#endregion
			static set_dynamic_width = function(_dynamic_width=true) {
				if (dynamic_width == _dynamic_width) return self;
				
				dynamic_width = _dynamic_width;
				__refresh_surf__ = true;
				
				return self;
			}
			
			#region jsDoc
			/// @func    set_line_height()
			/// @desc    Explicitly sets the line height. Overrides the automatic value from the font.
			/// @self    GUICompTextbox
			/// @param   {Real} height : The desired line height.
			/// @returns {Struct.WWTextBase}
			#endregion
			static set_line_height = function(_line_height=0) {
				if (line_height == _line_height) return self;
				
				if (_line_height) {
					line_height = _line_height;
				}
				else {
					line_height = font_get_info(text.font).size + 1;
				}
				
				__line_height_set__ = true;
				__refresh_surf__ = true;
				
				return self;
			}
			
			#region jsDoc
			/// @func	set_allowed_char()
			/// @desc	Sets the allowed characters to be used in this textbox. If undefined, the allowed characters are generated from the current font.
			/// @self	WWTextBase
			/// @param   {String} _allowed_char : A string of allowed characters (optional).
			/// @returns {Struct.WWTextBase}
			#endregion
			static set_allowed_char = function(_allowed_char = undefined) {
				if (is_undefined(_allowed_char)) {
					__allowed_char__ = __build_allowed_char__(text.font);
				}
				else {
					__allowed_char__ = {};
					__allowed_char_set__ = true;
					string_foreach(_allowed_char, function(_char, _pos) {
						__allowed_char__[$ _char] = true;
					});
				}
				return self;
			}
			
			#region Cursor
				
				#region jsDoc
				/// @func    set_cursor_x_pos()
				/// @desc    Sets the x position of the cursor on the current line, a value of `0` will indicate the furthest left, and a value of `1` will place the cursor on the right of the first letter in the line's string.
				/// @self    GUICompTextbox
				/// @param   {Real} xpos : The x position of the cursor
				/// @returns {Struct.GUICompTextbox}
				#endregion
				static set_cursor_x_pos = function(_x_pos) {
					if (_x_pos == cursor_x_pos) {
						return self;
					}
				
					//clamp the value
					var _line_length = string_length(__lines__[cursor_y_pos]);
					if (_x_pos > _line_length) {
						_x_pos = _line_length;
					}
				
					cursor_x_pos = _x_pos;
					draw.display_cursor = 30;
					
					// update cursor usually for scrolling
					static __args = {};
					__args.x = get_cursor_x_pos_gui()
					__args.y = get_cursor_y_pos_gui()
					trigger_event(events.cursor_move, {})
					
					return self;
				}
				#region jsDoc
				/// @func    set_cursor_y_pos()
				/// @desc    Sets the y position of the cursor. A value of `0` will place the cursor on the top most line, and a value of `1` will place the cursor on the second line of text if possible.
				///
				///          NOTE:
				///
				///          This value corrilates to the line the cursor will be on and not the y position in the world. If you wish to set the cursor's location with coordinates use 
				/// @self    GUICompTextbox
				/// @param   {Real} ypos : The y position of the cursor.
				/// @returns {Struct.GUICompTextbox}
				#endregion
				static set_cursor_y_pos = function(_y_pos) {
					if (_y_pos == cursor_y_pos) {
						return self;
					}
				
					cursor_y_pos = clamp(_y_pos, 0, array_length(__lines__)-1);
					draw.display_cursor = 30;
				
					// update cursor usually for scrolling
					static __args = {};
					__args.x = get_cursor_x_pos_gui()
					__args.y = get_cursor_y_pos_gui()
					trigger_event(events.cursor_move, {})
				
					return self;
				}
				#region jsDoc
				/// @func    set_cursor_gui_loc()
				/// @desc    Sets the cursor position based on the provided GUI x/y coordinates. The function
				///          converts the GUI coordinates to the text box’s local coordinate space (accounting for scrolling)
				///          and finds the best matching character position on the appropriate line.
				/// @self    GUICompTextbox
				/// @param   {Real} _gui_x : The x position in GUI space.
				/// @param   {Real} _gui_y : The y position in GUI space.
				/// @returns {Struct.GUICompTextbox}
				#endregion
				static set_cursor_gui_loc = function(_gui_x, _gui_y) {
				    var _loc = __get_pos_from_gui__ (_gui_x, _gui_y)
					
					// Update internal cursor positions.
				    set_cursor_y_pos(_loc.y);
				    set_cursor_x_pos(_loc.x_start);
				    __textbox_records_rec__(_loc.y, _loc.x_start);
					
				    return self;
				}

				#region jsDoc
				/// @func    set_cursor_width()
				/// @desc    Sets the cursor's width. This is usually used if you're manipulating you're GUI resolution and would like to increase the visibility of the cursor.
				/// @self    GUICompTextbox
				/// @param   {Real} width : The width of the cursor.
				/// @returns {Struct.GUICompTextbox}
				#endregion
				static set_cursor_width = function(_width) {
					draw.cursor_width = _width
				
					return self;
				}
				
			#endregion
			
		#endregion
		
        #region Events
			
            events.select    = variable_get_hash("select"); //triggered when the component gets focus, this commonly occurs when the mouse is clicked down on it.
			static on_select = function(_func) {
				add_event_listener(events.select, _func);
				return self;
			}
			events.copy    = variable_get_hash("change"); //triggered when the component gets focus, this commonly occurs when the mouse is clicked down on it.
			static on_change = function(_func) {
				add_event_listener(events.change, _func);
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
			
			on_post_step(function(_input) {
				var _input_captured = _input.consumed;
				var _mouse_on_comp = mouse_on_comp();
				
				//handle focus/bluring
				if (_mouse_on_comp) {
					consume_input();
					
					if (!__is_focused__) {
						__is_focused__ = true;
						trigger_event(self.events.focus);
					}
					trigger_event(self.events.is_focused);
				}
				else {
					if (__is_focused__) {
						__is_focused__ = false;
						trigger_event(self.events.blur);
					}
					trigger_event(self.events.is_blurred);
				}
				
				// Early exit if disabled
				if (!is_enabled) {
					if (__is_interacting__) {
			            __is_interacting__ = false
			        }
					if (__is_focused__) {
			            __reset_focus__();
			        }
					return;
				}
				
				// Early exit if input was captured
				if (_input_captured) {
					if (__is_interacting__ && mouse_check_button_released(mb_left)) {
				        __reset_focus__();
				    }
					return;
				}
				
				//handle input
				if (_mouse_on_comp) {
					var _double_trigger = false;
					if (mouse_check_button_pressed(mb_left)) {
						if (current_time - __last_click_time__ < 1_000/3) {
							_double_trigger = true;
						}
						
				        __is_interacting__ = true;
						__last_click_time__ = current_time;
				        __click_held_timer__ = current_time;
				        trigger_event(self.events.pressed);
						
						if (_double_trigger) trigger_event(self.events.double_click);
				    }
					
					else if (__is_interacting__ && mouse_check_button(mb_left)) {
				        trigger_event(self.events.held);
						
				        // Handle long press timing
				        __click_held_timer__ += 1;
				        if (current_time-__click_held_timer__ > 1_000/3) {
				            trigger_event(self.events.long_press);
				        }
				    }
					
					else if (__is_interacting__ && mouse_check_button_released(mb_left)) {
				        __reset_focus__();
				        trigger_event(self.events.released);
				    }
					
				}
				else {
					if (__is_interacting__ && mouse_check_button_released(mb_left)) {
				        __reset_focus__();
				    }
				}
				
			})
			
			on_pressed(function(_data) {
				// get focus
				__mouse_down_x__ = device_mouse_x_to_gui(0);
				__mouse_down_y__ = device_mouse_y_to_gui(0);
				
				__check_minput__(false);
				log("pressed")
			})
			on_held(function(_data) {
				var mx = device_mouse_x_to_gui(0);
				var my = device_mouse_y_to_gui(0);
				if (__mouse_down_x__ = mx)
				&& (__mouse_down_y__ = my) {
					return;
				}
				
				// stay focused if mouse is on component
				log("held")
				if (__word_selection_mode__) {
			        __update_word_selection_drag__();
			    } else {
			        __check_minput__(true);
			    }
			})
			on_long_press(function(_data) {
				// Phone support for selecting text
			})
			on_released(function(_data) {
				// stay focused if mouse is on component
				log("released")
				__word_selection_mode__ = false;
			})
			on_double_click(function(_data) {
			    __highlight_word_at_cursor__();
			    __word_anchor_start__ = highlight_x_pos;
			    // Assuming the current cursor position after double-click is the end of the word:
			    __word_anchor_end__ = get_cursor_x_pos();
			    __word_anchor_line__ = cursor_y_pos;
			    __word_selection_mode__ = true;
				log("double")
			});


			
			// Pre-draw event handler.
			on_pre_draw(function(_input) {
			    // If using cached drawing, update the cached surface if necessary.
			    if (__using_cached_drawing__) {
			        if (__refresh_surf__) {
			            draw_to_surface();
			            __refresh_surf__ = false;
			        }
			        // Draw the cached surface at the component's position.
			        draw_surface(textSurface, x, y);
			    }
			    else {
					// Direct drawing: use GPU scissor optimization.
			        __draw_highlight_selection__(x, y);
			        __draw_text__(x, y);
			    }
				
			    // Draw the cursor on top.
			    __draw_cursor__(x, y);
			});
			
        #endregion
        
        #region Variables
			
			text = {
				content : "", // The main text string displayed or edited in the component.
				font : fGUIDefault, // The font asset used for rendering text.
				alpha : 1, 
				color : c_white, // The color used to draw the text.
			}
			
			#region Cursor
			cursor_x_pos = 0; // Current cursor index (position within the current line).
			cursor_y_pos = 0; // Index of the active line (for multi-line support).
			//cursor_width = 0;
			//cursor_height = 0;
			#endregion
			#region Highlight
			highlight_x_pos = 0; // Current highlight index (position within the current line).
			highlight_y_pos = 0; // Index of the highlight line (for multi-line support).
			
			#endregion
			
			dynamic_width = false; // If true, the component will resize to fit the text, meaning text wont automatically wrap to next line
			
			line_height = font_get_info(text.font).size + 1; // The height of a line (computed from the font); initialized later.
			
			highlight_region_color = /*#*/0xD8680A; // The color used to render the selection highlight.
			highlight_selected = false; // if a region is being highlighted
			history_records_limit = 64;	// Maximum number of undo/redo records kept.
			
			///////////////////////////////////////////////////////////////
			// Place holder until a better solution is made
			///////////////////////////////////////////////////////////////
			keys = {
				last_key : undefined, //the last key pressed
				last_key_time : 0, //used to simulate keypresses
				home : vk_home,			// home
				end_key : vk_end,			// end
				backspace : vk_backspace,		// backspace
				delete_key : vk_delete,			// delete
				control : vk_control,		// control
				a : ord("A"),			// A
				x : ord("X"),			// X
				c : ord("C"),			// C
				v : ord("V"),			// V
				z : ord("Z"),			// Z
				y : ord("Y"),			// Y
				left : vk_left,			// left
				right : vk_right,			// right
				up : vk_up,				// up
				down : vk_down,			// down
				mouse_left : mb_left,			// mouse left
				enter : vk_enter,			// enter
				shift : vk_shift,			// shift
				escape : vk_escape,			// escape
				page_up : vk_pageup,
				page_down : vk_pagedown,
			}
			
		#endregion
        
        #region Functions
            
			#region jsDoc
			/// @func    get_text()
			/// @desc    Returns the text from the textbox
			/// @self    GUICompTextbox
			/// @returns {String}
			#endregion
			static get_text = function() {
				var _text = __lines_to_text__(__lines__);
				
				if (dynamic_width) {
					_text = __close_lines__(_text, 0);
				}
				
				return _text;
			}
			
			#region jsDoc
			/// @func    clear_text()
			/// @desc    Clear the text from the text box.
			/// @self    GUICompTextbox
			/// @returns {Undefined}
			#endregion
			static clear_text = function() {
				var _last_line_index = array_length(__lines__) - 1;
				var _last_line_length = string_length(__lines__[_last_line_index]);
				if (_last_line_index < 1 && _last_line_length < 1) return;
				highlight_y_pos = 0;
				highlight_x_pos = 0;
				set_cursor_y_pos(_last_line_index);
				set_cursor_x_pos(_last_line_length);
				__textbox_delete_string__(false);
			}
			
			#region Sizing
				
				#region jsDoc
				/// @func    get_content_width()
				/// @desc    Get the canvas width of the textbox. This is the width of the underlying region where text can be drawn.
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static get_content_width = function() {
					draw_set_font(text.font);
					var _width, _max_width, _lines, _size;
					static __args = {
						max_width : 0
					};
				
					array_foreach(__lines__, method(__args, function(_element, _index) {
						var _width = string_width(_element)
						if (_width > max_width) {
							max_width = _width
						}
					}));
				
					return __args.max_width;
				}
				#region jsDoc
				/// @func    get_content_height()
				/// @desc    Get the canvas height of the textbox. This is the height of the underlying region where text can be drawn.
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static get_content_height = function() {
					return array_length(__lines__) * line_height;
				}
				
			#endregion
			
			#region Cursor
				
				#region jsDoc
				/// @func    get_cursor_x_pos()
				/// @desc    Get cursor's x position in the GUI
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static get_cursor_x_pos = function() {
					return cursor_x_pos;
				}
				#region jsDoc
				/// @func    get_cursor_y_pos()
				/// @desc    Get cursor's y position in the GUI
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static get_cursor_y_pos = function() {
					return cursor_y_pos;
				}
				#region jsDoc
				/// @func    get_cursor_x_pos_gui()
				/// @desc    Get cursor's x position in the GUI
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static get_cursor_x_pos_gui = function() {
					var _derivative_x = string_width(string_copy(__lines__[cursor_y_pos], 1, cursor_x_pos))
					return x + _derivative_x;
				}
				#region jsDoc
				/// @func    get_cursor_y_pos_gui()
				/// @desc    Get cursor's y position in the GUI
				/// @self    GUICompTextbox
				/// @returns {Real}
				#endregion
				static get_cursor_y_pos_gui = function() {
					var _derivative_y = cursor_y_pos * line_height;
					return y + _derivative_y;
				}
				
			#endregion
			
        #endregion
		
    #endregion
    
    #region Private
        
		#region Variables
			
			__refresh_surf__ = false; //flag to determin if we need to update the surface drawing at the render step
			__using_cached_drawing__ = false;
			
			__lines__ = [""]; // Array containing individual lines of text, internally used to enhance efficiency of rendering.
			__lines_broken_by_width__ = [false]; // internally used to know if a line has been broken by a width restriction, or a line break.
			
			__historic_records__ = []; // internally used array of records history
			__historic_records_loc__ = -1; // internally used where the undo/redo marker is at, this allows for redo to exist
			__textbox_records_add__(cursor_y_pos, cursor_x_pos)
			
			// User has defined these values manually
			__line_height_set__ = false;
			
			__allowed_char__ = __build_allowed_char__(text.font); // Struct holding characters allowed in input (for character enforcement).
			__allowed_char_set__ = false; // Indicates whether allowed characters have been explicitly set.
			
			//used to better handle drag selections being ignored if mouse doesnt move
			__mouse_down_x__ = -infinity;
			__mouse_down_y__ = -infinity;
			
			__word_selection_mode__ = false;
			
		#endregion
		
		#region Functions
			
			#region Drawing
			
			#region jsDoc
			/// @func    draw_to_surface()
			/// @desc    Draws the static parts (highlight selection and text) to a cached surface.
			///          This function is called whenever the text or formatting changes, so that the
			///          expensive drawing of text is only performed once.
			/// @returns {Void}
			#endregion
			static draw_to_surface = function() {
			    // Create or reuse a surface sized to the text box.
			    if (!surface_exists(textSurface)) {
			        textSurface = surface_create(width, height);
			    }
				
			    // Set the surface as the render target.
			    surface_set_target(textSurface);
				
			    // Clear the surface (with background color and 0 alpha if needed).
			    draw_clear_alpha(background_color, 0);
				
			    // Draw selection highlight and text to the surface.
			    __draw_highlight_selection__(0, 0);
			    __draw_text__(0, 0);
				
			    // Reset the render target.
			    surface_reset_target();
			}
			
			#region jsDoc
			/// @func    __draw_highlight_selection__()
			/// @desc    Draws the selection highlight rectangles. This function uses the selection
			///          anchor (highlight_x_pos, highlight_y_pos) and the current cursor (cursor_x_pos, cursor_y_pos)
			///          to compute the rectangular areas for each affected line.
			/// @param   {Real} _x : The x-offset (typically 0 when drawing to surface).
			/// @param   {Real} _y : The y-offset.
			/// @returns {Void}
			#endregion
			static __draw_highlight_selection__ = function(_x, _y) {
			    // Only draw a highlight if a selection is active.
			    if (!highlight_selected) return;
				
				draw_set_font(text.font)
				
			    // Normalize selection bounds.
			    var sel_start_line = min(cursor_y_pos, highlight_y_pos);
			    var sel_end_line   = max(cursor_y_pos, highlight_y_pos);
			    var sel_start_x    = (cursor_y_pos <= highlight_y_pos) ? cursor_x_pos : highlight_x_pos;
			    var sel_end_x      = (cursor_y_pos <= highlight_y_pos) ? highlight_x_pos : cursor_x_pos;
    
			    // For each affected line, compute the highlight rectangle.
			    for (var line = sel_start_line; line <= sel_end_line; line++) {
			        var current_text = __lines__[line];
			        var draw_y = _y + line * line_height;
			        var rect_x1, rect_x2;
					
			        if (line == sel_start_line && line == sel_end_line) {
			            // Single-line selection.
			            rect_x1 = _x + string_width(string_copy(current_text, 1, sel_start_x));
			            rect_x2 = _x + string_width(string_copy(current_text, 1, sel_end_x));
			        }
			        else if (line == sel_start_line) {
			            // First line of multi-line selection.
			            rect_x1 = _x + string_width(string_copy(current_text, 1, sel_start_x));
			            rect_x2 = _x + string_width(current_text);
			        }
			        else if (line == sel_end_line) {
			            // Last line of selection.
			            rect_x1 = _x;
			            rect_x2 = _x + string_width(string_copy(current_text, 1, sel_end_x));
			        }
			        else {
			            // Full-line selection.
			            rect_x1 = _x;
			            rect_x2 = _x + string_width(current_text);
			        }
					
			        // Draw the selection rectangle. (Using s9GUIPixel as a 1x1 pixel that can be stretched.)
			        draw_sprite_stretched_ext(
			            s9GUIPixel,
			            0,
			            min(rect_x1, rect_x2),
			            draw_y,
			            abs(rect_x2 - rect_x1),
			            line_height,
			            highlight_region_color,
			            1
			        );
			    }
			}
			
			#region jsDoc
			/// @func    __draw_text__()
			/// @desc    Draws text lines starting at offset (_x, _y). When not drawing to a surface,
			///          the function uses the current GPU scissor region to determine which lines are visible.
			/// @param   {Real} _x : The x-offset for drawing.
			/// @param   {Real} _y : The y-offset for drawing.
			/// @returns {Void}
			#endregion
			static __draw_text__ = function(_x, _y) {
			    // Set the font and color.
			    draw_set_font(text.font);
			    draw_set_color(text.color);
			    draw_set_alpha(text.alpha);
			    draw_set_halign(fa_left);
			    draw_set_valign(fa_top);
    
			    // If not drawing to a cached surface, optimize by drawing only visible lines.
			    if (!__using_cached_drawing__) {
			        var scissor = gpu_get_scissor();  // Assume this returns a structure with x, y, width, height.
			        // Compute which lines are visible (relative to the text box's top y-coordinate).
			        var first_line = clamp(floor((scissor.y - _y) / line_height), 0, array_length(__lines__) - 1);
			        var last_line  = clamp(ceil((scissor.y + scissor.h - _y) / line_height), 0, array_length(__lines__) - 1);
        
			        for (var i = first_line; i <= last_line; i++) {
			            draw_text(_x, _y + i * line_height, __lines__[i]);
			        }
			    }
			    else {
			        // If drawing to a surface, simply draw all lines.
			        for (var i = 0; i < array_length(__lines__); i++) {
			            draw_text(_x, _y + i * line_height, __lines__[i]);
			        }
			    }
			}
			
			#region jsDoc
			/// @func    __draw_cursor__()
			/// @desc    Draws the blinking cursor at its current position. The cursor is drawn
			///          directly (not cached) because it updates frequently.
			/// @param   {Real} _x : The x-offset of the component.
			/// @param   {Real} _y : The y-offset of the component.
			/// @returns {Void}
			#endregion
			static __draw_cursor__ = function(_x, _y) {
			    // Only draw the cursor if the component is focused.
			    if (!__is_interacting__) return;
				
			    // Compute the cursor's pixel x coordinate.
			    var current_line = __lines__[cursor_y_pos];
			    var cursor_pixel_x = _x + string_width(string_copy(current_line, 1, cursor_x_pos));
			    var cursor_pixel_y = _y + cursor_y_pos * line_height;
				
			    // Draw a vertical line (or sprite) as the cursor.
			    // Here, get_cursor_width() and get_cursor_height() are assumed to return the dimensions.
			    draw_sprite_stretched_ext(
			        s9GUIPixel,
			        0,
			        cursor_pixel_x,
			        cursor_pixel_y,
			        1,
			        line_height,
			        text.color,  // or use a dedicated cursor color if desired.
			        1
			    );
			}
			
			#endregion
			
			#region Converters
				
				#region jsDoc
				/// @func    __lines_to_text__()
				/// @desc    Converts the Text array into a single string. This does not account for addaptive width! See `__textbox_return__()` if you wish for adaptive width to be accounted.
				/// @self    GUICompTextbox
				/// @param   {Array<String>} arr : The array of strings
				/// @returns {String}
				#endregion
				static __lines_to_text__ = function(_arr) {
					return string_concat_ext(_arr);
				}
				
				#region jsDoc
				/// @func    __text_to_lines__()
				/// @desc    Converts the a string into the Text array format.
				/// @self    GUICompTextbox
				/// @param   {String} str : The string to convert to an array
				/// @returns {Array}
				#endregion
				static __text_to_lines__ = function(_str) {
					_str = string_replace_all(_str, "\r\n", "\n");
					var _split_str = string_split(_str, "\n");
					
					//re-add the line breaks to everything except the last line
					var _i=0; repeat(array_length(_split_str)-1) {
						_split_str[_i] += "\n";
					_i++}
					
					return _split_str;
				}
				
			#endregion
			
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
			        var _struct_keys = variable_struct_get_names(_info.glyphs);
			        var _struct = {};

			        var _i = 0;
			        repeat (array_length(_struct_keys)) {
			            _struct[$ _struct_keys[_i]] = true;
			            _i += 1;
			        }
					
					if (_include_nl) _struct[$ "\n"] = true;
					
			        return _struct;
			    }
			
			    #region jsDoc
			    /// @func    __keep_allowed_char__()
			    /// @desc    Removes all characters from a string except for the specified struct of allowed characters.
			    ///          This acts as a whitelist for characters.
			    /// @self    WWTextBase
			    /// @param   {String} _text : The string to parse
			    /// @param   {Struct} _allowed_char : The struct of allowed characters.
			    /// @returns {String}
			    #endregion
			    static __keep_allowed_char__ = function(_text, _allowed_char=__allowed_char__) {
			        static __args = {
						buff : buffer_create(1, buffer_grow, 1),
					}
			        __args.__allowed_char__ = _allowed_char;
			        
					buffer_resize(__args.buff, 1024);
					buffer_seek(__args.buff, buffer_seek_start, 0);
			        
			        string_foreach(_text, method(__args, function(_char) {
			            if (__allowed_char__[$ _char]) {
			                buffer_write(buff, buffer_text, _char);
			            }
			        }));
					
					// Write a null terminator so the resulting string ends correctly.
					buffer_write(__args.buff, buffer_u8, 0);
					
			        buffer_seek(__args.buff, buffer_seek_start, 0);
			        var _new_text = buffer_read(__args.buff, buffer_string);
			        
			        return _new_text;
			    }
			
			#endregion
			
			#region Clipboard
				
				#region jsDoc
				/// @func	__copy_string__()
				/// @desc	Copies the selected text to the clipboard. If the selection is on a single line,
				///         it extracts the substring between the cursor and the selection anchor. For multi‑line
				///         selections, it extracts the portion from the selection start on the first line,
				///         all full lines in between, and the portion up to the selection end on the last line.
				/// @self	WWTextBase
				/// @returns {String} The copied text.
				#endregion
				static __copy_string__ = function() {
					// If no selection is active, return an empty string.
					if (!highlight_selected) return "";
	
					var _lines = __lines__;
					var _text = "";
					
					
					// Early out for Single-line selection.
					if (cursor_y_pos == highlight_y_pos) {
						var _start_x = min(cursor_x_pos, highlight_x_pos);
						var _end_x = max(cursor_x_pos, highlight_x_pos);
						_text = string_copy(_lines[cursor_y_pos], _start_x + 1, _end_x - _start_x);
						return _text;
					}
					
					
					// Determine start and end of selection.
					var _start_y, _end_y, _start_x, _end_x;
					// Normalize selection bounds.
					if (cursor_y_pos < highlight_y_pos) {
						_start_y = cursor_y_pos;
						_end_y   = highlight_y_pos;
						_start_x = cursor_x_pos;
						_end_x   = highlight_x_pos;
					} else {
						_start_y = highlight_y_pos;
						_end_y   = cursor_y_pos;
						_start_x = highlight_x_pos;
						_end_x   = cursor_x_pos;
					}
					
					// Copy the lines from _start_line to _end_line (inclusive).
					static __temp_arr = [];
					array_copy(__temp_arr, 0, _lines, _start_y, _end_y - _start_y + 1);
					var _length = array_length(__temp_arr);
					
					// On the first line, remove text before the selection start.
					__temp_arr[0] = string_copy(__temp_arr[0], _start_x + 1, string_length(__temp_arr[0]) - _start_x);
					// On the last line, only take text up to the selection end.
					__temp_arr[_length - 1] = string_copy(__temp_arr[_length - 1], 1, _end_x);
					
					_text = __lines_to_text__(__temp_arr);
					if (dynamic_width) _text = __close_lines__(_text, _start_y);
					
					//cleanup array
					array_resize(__temp_arr, 0);
					
					return _text;
				}
				
		    #endregion
			
			#region Line Breaking
				
				#region jsDoc
				/// @func    __break_lines__()
				/// @desc    Handles word wrapping for text lines based on the textbox’s width. This
				///          function splits lines at appropriate word boundaries when the text exceeds
				///          the available drawing width, and optionally adjusts the cursor position
				///          after a forced line break.
				/// @self    WWTextBase
				/// @param   {Real} _start_line_index       : The index of the line from which to start processing.
				/// @param   {Real} _number_of_lines           : The number of lines to process for wrapping.
				/// @param   {Real} _char_limit          : (Optional) The target character offset at which to force a break.
				/// @param   {Real} _cursor_line_offset   : (Optional) An offset applied to the cursor’s line position after a forced break.
				/// @returns {Undefeined}
				#endregion
				static __break_lines__ = function(_start_line_index, _number_of_lines, _char_limit = 0, _cursor_line_offset = 0) {
				    // Define characters that indicate a natural word-break.
				    static __word_breakers = "\n" + chr(9) + chr(34) + " ,.;:?!><#$%&'()*+-/=@[\]^`{|}~¡¢£¤¥¦§¨©«¬­®¯°±´¶·¸»¿×÷";
					
				    // Set the font for measurement.
				    draw_set_font(text.font);

				    // Calculate available width for text drawing.
				    var _draw_width = width;
				    var _end_line_index = _start_line_index + _number_of_lines; // Determines how many lines to process.
				    var _breaker_pos = 0;
				    var _current_char = "";

				    // Process each line within the specified range.
				    while (_start_line_index < _end_line_index) {
				        var _current_str = __lines__[_start_line_index];
				        var _current_strWidth = string_width(_current_str);

				        // If the current line exceeds the available drawing width, break it.
				        if (_current_strWidth > _draw_width) {
				            var _char_index = 0;
				            var _current_str_length = string_length(_current_str);
            
				            // Move forward until the text width exceeds the allowed draw width.
				            repeat (_current_str_length) {
				                if (string_width(string_copy(_current_str, 1, _char_index + 1)) > _draw_width) {
				                    // Backtrack to find a natural word-break.
				                    _breaker_pos = _char_index;
				                    repeat (_char_index) {
				                        _current_char = string_char_at(_current_str, _breaker_pos);
				                        if (string_pos(_current_char, __word_breakers)) {
				                            _char_index = _breaker_pos;
				                            break;
				                        }
				                        _breaker_pos--;
				                    }
                    
				                    // Ensure we have a valid break position.
				                    // (Guard here if _char_index is very low to avoid negative lengths.)
                    
				                    // Split the current line at the break position.
				                    array_insert(__lines__, _start_line_index + 1, string_delete(_current_str, 1, _char_index - 1));
				                    array_insert(__lines_broken_by_width__, _start_line_index + 1, false);
				                    __lines__[_start_line_index] = string_copy(_current_str, 1, _char_index - 1);
				                    break;
				                }
				                _char_index += 1;
				            }
				            // Since a new line was added, extend the end index.
				            _end_line_index += 1;
				        }
				        else {
				            // Attempt to merge the current line with the next one if possible.
				            var nextLineIdx = _start_line_index + 1;
				            if (nextLineIdx < array_length(__lines_broken_by_width__) && !__lines_broken_by_width__[nextLineIdx]) {
				                var nextText = __lines__[nextLineIdx];
				                var nextTextWidth = string_width(nextText);
                
				                // If merging does not exceed the allowed width, combine the lines.
				                if (_current_strWidth + nextTextWidth <= _draw_width) {
				                    __lines__[_start_line_index] = _current_str + nextText;
				                    array_delete(__lines__, nextLineIdx, 1);
				                    array_delete(__lines_broken_by_width__, nextLineIdx, 1);
				                    _end_line_index -= 1;
				                }
				                else {
				                    // Otherwise, process the next line to see where it can be split.
				                    var _char_index = 1;
				                    var nextTextLength = string_length(nextText);
				                    repeat (nextTextLength) {
				                        if (_current_strWidth + string_width(string_copy(nextText, 1, _char_index)) > _draw_width) {
				                            // Backtrack to a valid break point in the next line.
				                            _breaker_pos = _char_index;
				                            repeat (_char_index) {
				                                _current_char = string_char_at(nextText, _breaker_pos);
				                                if (string_pos(_current_char, __word_breakers)) {
				                                    _char_index = _breaker_pos;
				                                    break;
				                                }
				                                _breaker_pos--;
				                            }
                            
				                            // Break the next line at the determined point.
				                            __lines__[_start_line_index] = _current_str + string_copy(nextText, 1, _char_index - 1);
				                            __lines__[nextLineIdx] = string_delete(nextText, 1, _char_index - 1);
				                            break;
				                        }
				                        _char_index += 1;
				                    }
				                    // A new line was effectively created so adjust the end index.
				                    _end_line_index += 1;
				                }
				            }
				        }
        
				        // If a character limit is specified, adjust the cursor position.
				        if (_char_limit > 0) {
				            _current_str = __lines__[_start_line_index];
				            var _current_str_length = string_length(_current_str);
            
				            if (_current_str_length >= _char_limit) {
				                // Set the cursor’s line position, applying the offset.
				                set_cursor_y_pos(_start_line_index + _cursor_line_offset);
                
				                // If the offset is nonzero, position the cursor at the start of the line.
				                if (_cursor_line_offset > 0) {
				                    set_cursor_x_pos(0);
				                } else {
				                    set_cursor_x_pos(_char_limit);
				                }
				                // Clear the limit once applied.
				                _char_limit = 0;
				            }
				            else {
				                // Decrease the limit by the length of the current line.
				                _char_limit -= _current_str_length;
				            }
				        }
        
				        _start_line_index += 1;
				    }
    
				    // Mark the surface for refreshing.
				    __refresh_surf__ = true;
				}
				
			    #region jsDoc
				/// @func    __close_lines__()
				/// @desc    Removes unnecessary (soft) line breaks added due to dynamic width from a text string.
				///          It scans the text using string_pos_ext (to avoid allocating new strings) and, for each
				///          newline encountered, checks the corresponding flag in __lines_broken_by_width__. If the
				///          flag is false (a soft break), the newline is removed from the text.
				/// @self    WWTextBase
				/// @param   {String} _text         : The text string with forced line breaks.
				/// @param   {Real} _start_line     : The starting line index for checking/removing soft breaks.
				/// @returns {String} The cleaned text with adjusted line breaks.
				#endregion
				static __close_lines__ = function(_text, _start_line) {
				    // Reference the breakpoints array (true indicates a forced break).
				    var _breakpoints = __lines_broken_by_width__;
				    // _result will be the working text we modify.
				    var _result = _text;
				    // _search_start indicates where in the string to look for the next newline.
				    var _search_start = 1;
				    // Start from the next line index (the first line processed corresponds to _start_line+1).
				    var _line_index = _start_line + 1;
    
				    // Find the first newline in _result, starting at _search_start.
				    var _newline_pos = string_pos_ext("\n", _result, _search_start);
				    while (_newline_pos > 0) {
				        // If the current line break is a soft break (flag false), remove it.
				        if (!_breakpoints[_line_index]) {
				            _result = string_delete(_result, _newline_pos, 1);
				            // Since deletion shifts subsequent characters left, _search_start remains at _newline_pos.
				        } else {
				            // Otherwise, move _search_start past this newline.
				            _search_start = _newline_pos + 1;
				        }
				        // Move to the next line index for checking.
				        _line_index += 1;
				        // Look for the next newline in _result, starting at the updated _search_start.
				        _newline_pos = string_pos_ext("\n", _result, _search_start);
				    }
    
				    return _result;
				}
				
			#endregion
			
			#region Cursor Navigation

			    #region jsDoc
				/// @func    __check_hinput__()
				/// @desc    Adjusts the horizontal cursor position based on movement input. If the new position
				///          exceeds the current line's bounds, it moves to the previous or next line accordingly.
				/// @self    WWTextInputSingle
				/// @param   {Real} _change : Amount to adjust the cursor position horizontally.
				/// @returns {Real} The new horizontal cursor position.
				#endregion
				static __check_hinput__ = function(_change) {
				    var new_cursor_x = cursor_x_pos + _change;
				    var current_line = cursor_y_pos;
				    var line_length = string_length(__lines__[current_line]);
    
				    if (new_cursor_x < 0) {
				        if (current_line > 0) {
				            current_line -= 1;
				            new_cursor_x = string_length(__lines__[current_line]);
				        } else {
				            new_cursor_x = 0;
				        }
				    } else if (new_cursor_x > line_length) {
				        if (current_line < array_length(__lines__) - 1) {
				            current_line += 1;
				            new_cursor_x = 0;
				        } else {
				            new_cursor_x = line_length;
				        }
				    }
    
				    set_cursor_y_pos(current_line);
				    __textbox_records_rec__(current_line, new_cursor_x);
				    return new_cursor_x;
				}

				#region jsDoc
				/// @func    __check_vinput__()
				/// @desc    Adjusts the vertical cursor position based on movement input while trying to maintain
				///          the horizontal pixel offset of the current cursor.
				/// @self    WWTextInputSingle
				/// @param   {Real} _change : Amount to adjust the vertical cursor position.
				/// @returns {Real} The new horizontal cursor position on the new line.
				#endregion
				static __check_vinput__ = function(_change) {
				    var current_line = cursor_y_pos;
				    var new_line = clamp(current_line + _change, 0, array_length(__lines__) - 1);
				    if (new_line == current_line) return cursor_x_pos;
    
				    // Calculate the current horizontal pixel offset.
				    var current_offset = string_width(string_copy(__lines__[current_line], 1, cursor_x_pos));
				    var new_line_text = __lines__[new_line];
				    var new_line_length = string_length(new_line_text);
				    var new_cursor_x = 0;
    
				    if (current_offset >= string_width(new_line_text)) {
				        new_cursor_x = new_line_length;
				    } else {
				        // Iterate until the width of the substring reaches or exceeds current_offset.
				        for (var i = 1; i <= new_line_length; i++) {
				            if (string_width(string_copy(new_line_text, 1, i)) >= current_offset) {
				                new_cursor_x = i;
				                break;
				            }
				        }
				    }
    
				    set_cursor_y_pos(new_line);
				    __textbox_records_rec__(new_line, new_cursor_x);
				    return new_cursor_x;
				}

				#region jsDoc
				/// @func    __check_minput__()
				/// @desc    Updates the cursor position based on mouse input. When selection mode is enabled,
				///          if no selection anchor exists, it sets the anchor to the current cursor position.
				///          Then it updates the cursor position from the mouse coordinates. If the new cursor
				///          equals the anchor, selection is cleared; otherwise, selection remains active.
				/// @self    WWTextInputSingle
				/// @param   {Bool} _select : Whether selection mode is enabled.
				/// @returns {Void}
				#endregion
				static __check_minput__ = function(_select) {
				    // If selection mode is enabled and no anchor is set, establish the anchor.
				    if (_select && !highlight_selected) {
				        highlight_x_pos = cursor_x_pos;
				        highlight_y_pos = cursor_y_pos;
				        highlight_selected = true;
				    }
					
				    // Get mouse coordinates in GUI space.
				    var mx = device_mouse_x_to_gui(0);
				    var my = device_mouse_y_to_gui(0);
				    set_cursor_gui_loc(mx, my);
					
				    // If selecting, check if the new cursor equals the anchor.
				    if (_select) {
				        if (cursor_y_pos == highlight_y_pos && cursor_x_pos == highlight_x_pos) {
				            // If no movement from anchor, clear selection.
				            highlight_selected = false;
				        }
				        // Otherwise, leave the selection anchor intact.
				    }
				    else {
				        // If not selecting, clear any active selection.
				        highlight_selected = false;
				    }
				}
				
				#region jsDoc
				/// @func    __move_cursor_offset__()
				/// @desc    Moves the cursor based on input and optionally extends selection. When shift is
				///          held, it preserves the selection anchor; otherwise, any active selection is cleared.
				/// @self    WWTextInputSingle
				/// @param   {Real} _change : The amount to move the cursor.
				/// @param   {Bool} _shift  : Whether to extend the selection (shift key held).
				/// @param   {Bool} _vertical : Whether the movement is vertical (if false, horizontal).
				/// @returns {Void}
				#endregion
				static __move_cursor_offset__ = function(_change, _shift, _vertical) {
				    if (_change == 0) return;
					if (_shift) {
				        // If shift is held and no selection anchor is active, set the anchor.
				        if (!highlight_selected) {
				            highlight_x_pos = cursor_x_pos;
				            highlight_y_pos = cursor_y_pos;
				            highlight_selected = true;
				        }
				        // Move the cursor using the appropriate function.
				        var new_cursor = _vertical ? __check_vinput__(_change)
				                                   : __check_hinput__(_change);
				        // If the new cursor position equals the selection anchor, clear selection.
				        if (cursor_y_pos == highlight_y_pos && new_cursor == highlight_x_pos) {
				            highlight_selected = false;
				        }
				        set_cursor_x_pos(new_cursor);
				    } else {
				        // Without shift, clear any active selection.
				        if (highlight_selected) {
				            highlight_selected = false;
				        }
				        // Move the cursor normally.
				        if (_vertical) {
				            set_cursor_x_pos(__check_vinput__(_change));
				        } else {
				            set_cursor_x_pos(__check_hinput__(_change));
				        }
				    }
				}

			#endregion
			
			#region Utility
			
		        #region jsDoc
		        /// @func    __array_clone__()
		        /// @desc    Creates a shallow copy of an array.
		        /// @self    WWTextBase
		        /// @param   {Array} _arr : The array to clone.
		        /// @returns {Array} A new array with the same elements.
		        #endregion
		        static __array_clone__ = function(_arr) {
		            var _new_arr = array_create(array_length(_arr), 0);
		            array_copy(_new_arr, 0, _arr, 0, array_length(_arr));
		            return _new_arr;
		        }
				
		    #endregion
			
			#region Input Handling
				
				#region jsDoc
				/// @func    __compute_word_boundaries__
				/// @desc    Given a line of text and a cursor index (1-indexed), computes the word boundaries
				///          based on a shared list of word breakers. Returns a struct containing:
				///              { x_start, x_end }
				///          where x_start is the start index and x_end is the end index of the word.
				/// @param   {String} lineText   : The text content of the line.
				/// @param   {Real} cursorIndex  : The current cursor position in the line (1-indexed).
				/// @returns {Struct} A struct with properties x_start and x_end.
				/// @self    WWTextBase
				#endregion
				static __compute_word_boundaries__ = function(lineIndex, cursorIndex) {
				    // Shared word breakers constant.
				    static __word_breakers = "\n" + chr(9) + chr(34) + " ,.;:?!><#$%&'()*+-/=@[\]^`{|}~¡¢£¤¥¦§¨©«¬­®¯°±´¶·¸»¿×÷";
					
					// Retrieve the current line's text.
				    var lineText = __lines__[lineIndex];
				    var len = string_length(lineText);
				    if (len == 0) return { x_start: 0, x_end: 0 };
					
				    // Get the character at the current cursor position.
				    // Assume cursor_x_pos is 1-indexed.
				    var currentChar = string_char_at(lineText, cursorIndex);
    
				    // Define allowed set based on the current character.
				    var allowedSet;
				    if (string_pos(currentChar, __word_breakers) == 0) {
				        // Normal word: allowed characters are those NOT in __word_breakers.
				        // We'll handle that by scanning until we hit a breaker.
				        allowedSet = undefined;
				    }
				    else {
				        // Current char is a breaker.
				        // If it's a space or tab, we only allow spaces and tabs.
				        if (currentChar == " " || currentChar == chr(9)) {
				            allowedSet = " " + chr(9);
				        }
						else {
				            // Otherwise, allow any character that is in __word_breakers.
				            allowedSet = __word_breakers;
				        }
				    }
					
				    var startPos = cursorIndex;
				    var endPos = cursorIndex;
					
				    // If allowedSet is undefined, then we are in a normal word:
				    if (allowedSet == undefined) {
				        // Scan left until a word breaker is encountered.
				        while (startPos > 0 && string_pos(string_char_at(lineText, startPos), __word_breakers) == 0) {
				            startPos -= 1;
				        }
				        // Scan right until a word breaker is encountered.
				        while (endPos < len && string_pos(string_char_at(lineText, endPos + 1), __word_breakers) == 0) {
				            endPos += 1;
				        }
				    }
				    else {
				        // When the current char is a breaker, use the allowedSet.
				        // Scan left: while previous character exists and is in allowedSet.
				        while (startPos > 0 && string_pos(string_char_at(lineText, startPos), allowedSet) > 0) {
				            startPos -= 1;
				        }
				        // Scan right: while next character exists and is in allowedSet.
				        while (endPos < len && string_pos(string_char_at(lineText, endPos + 1), allowedSet) > 0) {
				            endPos += 1;
				        }
				    }
					
				    return { x_start: startPos, x_end: endPos };
				};

				#region jsDoc
				/// @func    __get_pos_from_gui__
				/// @desc    Converts GUI coordinates (absolute x, y) into a text position within the text box.
				///          It calculates the line index and character index in that line. If _wordMode is true,
				///          it returns the full word boundaries using __compute_word_boundaries__.
				/// @param   {Real} _gui_x    : The x coordinate in GUI space.
				/// @param   {Real} _gui_y    : The y coordinate in GUI space.
				/// @param   {Bool} _wordMode : (Optional) If true, returns word boundaries; otherwise, returns just the cursor position.
				/// @returns {Struct} A struct with properties:
				///           - x_start: For _wordMode true, the start index of the word; otherwise, the cursor position.
				///           - x_end  : For _wordMode true, the end index of the word; otherwise, equal to x_start.
				///           - y      : The line index.
				/// @self    WWTextBase
				#endregion
				static __get_pos_from_gui__ = function(_gui_x, _gui_y, _wordMode=false) {
				    // Set font for measurement.
				    draw_set_font(text.font);
				    var _lineHeight = line_height;
    
				    // Compute the relative Y coordinate and determine the line.
				    var relY = _gui_y - y;
				    var lineIndex = clamp(floor(relY / _lineHeight), 0, array_length(__lines__) - 1);
    
				    var lineText = __lines__[lineIndex];
				    var lineLen = string_length(lineText);
    
				    // Compute the relative X coordinate.
				    var relX = _gui_x - x;
				    var cursorPos = 0;
				    for (var i = 0; i <= lineLen; i++) {
				        if (string_width(string_copy(lineText, 1, i)) >= relX) {
				            cursorPos = i;
				            break;
				        }
				        cursorPos = i;
				    }
    
				    var result = { x_start: cursorPos, x_end: cursorPos, y: lineIndex };
    
				    if (_wordMode) {
				        var boundaries = __compute_word_boundaries__(lineIndex, cursorPos);
				        result.x_start = boundaries.x_start;
				        result.x_end = boundaries.x_end;
				    }
    
				    return result;
				};
				
				#region jsDoc
			    /// @func    __insert_string_at_cursor__()
			    /// @desc    Inserts a new string at the cursor position, respecting allowed characters.
			    /// @self    WWTextInputSingle
			    /// @param   {String} _str : The string to insert.
			    /// @returns {Void}
			    #endregion
			    static __insert_string_at_cursor__ = function(_str) {
			        // Sanitize input: only allowed characters are retained.
					_str = __keep_allowed_char__(_str, __allowed_char__);
					var _str_length = string_length(_str);
					
					// If text is highlighted, remove the selection before inserting.
			        if (highlight_selected) __textbox_delete_string__(false);
					
					// If the lines should wrap after reaching the width
					var _should_wrap = (__size_set__ && !dynamic_width);
					
					
					
					// split the text at newlines.
			        var _split_lines = __text_to_lines__(_str);
			        
					// Separate the current line into two parts: before and after the cursor.
				    var currentLine = __lines__[cursor_y_pos];
				    var leftText = string_copy(currentLine, 1, cursor_x_pos);
				    var rightText = string_copy(currentLine, cursor_x_pos + 1, string_length(currentLine) - cursor_x_pos);
					
					
					// Early exit if there is only a single line to add
					if (array_length(_split_lines) == 1) {
					    // Simple insertion when no newline is present.
					    __lines__[cursor_y_pos] = leftText + _split_lines[0] + rightText;
					    cursor_x_pos += string_length(_split_lines[0]);
					    // Optionally, update line breaks if needed.
					    if (_should_wrap) {
					        __break_lines__(cursor_y_pos, 1, _str_length, 0);
					    }
					    return;
					}
					
					
				    // The first inserted line merges with the text before the cursor.
				    __lines__[cursor_y_pos] = leftText + _split_lines[0];

				    // Insert any middle lines.
				    for (var i = 1; i < array_length(_split_lines) - 1; i++) {
				        array_insert(__lines__, cursor_y_pos + i, _split_lines[i]);
				        array_insert(__lines_broken_by_width__, cursor_y_pos + i, true);
				    }

				    // The last line of the inserted text is merged with the text after the cursor.
				    array_insert(
						__lines__,
						cursor_y_pos + array_length(_split_lines) - 1,
						_split_lines[array_length(_split_lines) - 1] + rightText
					);
				    array_insert(
						__lines_broken_by_width__,
						cursor_y_pos + array_length(_split_lines) - 1,
						true
					);
					

				    // Update cursor positions.
				    cursor_y_pos += array_length(_split_lines) - 1;
				    cursor_x_pos = string_length(_split_lines[array_length(_split_lines) - 1]);

				    // Adjust line breaks if dynamic width is enabled.
				    if (_should_wrap) {
				        __break_lines__(cursor_y_pos, 1, _str_length, string_count("\n", _str));
				    }
			    }
				
				#region jsDoc
				/// @func	__textbox_delete_string__()
				/// @desc	Deletes a character at the cursor position or removes a selection if active.
				///		  For forward deletion (delete key), it removes the character after the cursor,
				///		  merging with the next line if at the end. For backspace deletion, it removes the
				///		  character before the cursor, merging with the previous line if at the start.
				///		  When a selection is active, it deletes the entire selection and positions the cursor
				///		  at the beginning of the selection.
				/// @self	WWTextInputSingle
				/// @param   {Bool} _is_del_key : True if the delete key is pressed (forward delete), false if backspace.
				/// @returns {Void}
				#endregion
				static __textbox_delete_string__ = function(_is_del_key) {
					// Store current cursor position.
					var _current_line_index = cursor_y_pos;
					var _current_cursor_pos = cursor_x_pos;
					
					// If a selection is active, handle deletion and return early.
					if (highlight_selected) {
						// Retrieve selection details.
						var _select_line = highlight_y_pos;
						var _select_pos = highlight_x_pos;
						
						// Case 1: Selection is on a single line.
						if (_select_line == _current_line_index) {
							var _deletion_count = abs(_current_cursor_pos - _select_pos);
							// Set cursor to the beginning of the selection.
							_current_cursor_pos = min(_current_cursor_pos, _select_pos);
							__lines__[_current_line_index] = string_delete(__lines__[_current_line_index], _current_cursor_pos + 1, _deletion_count);
						} 
						// Case 2: Multi-line selection.
						else {
							// Determine start and end of selection.
							var _start_y, _end_y, _start_x, _end_x;
							// Normalize selection bounds.
							if (cursor_y_pos < highlight_y_pos) {
								_start_y = cursor_y_pos;
								_end_y   = highlight_y_pos;
								_start_x = cursor_x_pos;
								_end_x   = highlight_x_pos;
							}
							else {
								_start_y = highlight_y_pos;
								_end_y   = cursor_y_pos;
								_start_x = highlight_x_pos;
								_end_x   = cursor_x_pos;
							}
			
							// Merge text: Keep text from start line up to selection start and append
							// text from end line after the selection.
							var _tail_text = string_delete(__lines__[_end_y], 1, _end_x);
							__lines__[_start_y] = string_copy(__lines__[_start_y], 1, _start_x) + _tail_text;
			
							// Delete any lines between the start and end of selection.
							var _num_lines_to_del = _end_y - _start_y;
							array_delete(__lines__, _start_y + 1, _num_lines_to_del);
							array_delete(__lines_broken_by_width__, _start_y + 1, _num_lines_to_del);
			
							// Update the cursor to the beginning of the selection.
							_current_line_index = _start_y;
							_current_cursor_pos = _start_x;
						}
		
						highlight_selected = false;
		
						// Update cursor and view, then exit.
						set_cursor_y_pos(_current_line_index);
						set_cursor_x_pos(_current_cursor_pos);
						if (dynamic_width) __break_lines__(_current_line_index, 1);
						__textbox_records_add__(_current_line_index, _current_cursor_pos);
						return;
					}
	
					// No selection active – handle deletion of a single character.
					var _current_str = __lines__[_current_line_index];
	
					if (_is_del_key) {
						// Forward deletion: delete the character after the cursor.
						if (_current_cursor_pos == string_length(_current_str)) {
							// If at the end of the line, attempt to merge with the next line.
							if (_current_line_index == array_length(__lines__) - 1) return; // No next line.
							__lines__[_current_line_index] = _current_str + __lines__[_current_line_index + 1];
							array_delete(__lines__, _current_line_index + 1, 1);
							array_delete(__lines_broken_by_width__, _current_line_index + 1, 1);
						}
						else {
							// Delete one character after the cursor.
							__lines__[_current_line_index] = string_delete(_current_str, _current_cursor_pos + 1, 1);
						}
					}
					else {
						// Backspace deletion: delete the character before the cursor.
						if (_current_cursor_pos == 0) {
							// If at the beginning of the line, merge with the previous line.
							if (_current_line_index == 0) return; // Already at the first line.
							var _prev_line_text = __lines__[_current_line_index - 1];
							_current_cursor_pos = string_length(_prev_line_text);
							__lines__[_current_line_index - 1] = _prev_line_text + _current_str;
							array_delete(__lines__, _current_line_index, 1);
							array_delete(__lines_broken_by_width__, _current_line_index, 1);
							_current_line_index -= 1;
						}
						else {
							// Delete one character before the cursor.
							__lines__[_current_line_index] = string_delete(_current_str, _current_cursor_pos, 1);
							_current_cursor_pos -= 1;
						}
					}
	
					// Update cursor positions and refresh the display.
					set_cursor_y_pos(_current_line_index);
					set_cursor_x_pos(_current_cursor_pos);
					if (dynamic_width) __break_lines__(_current_line_index, 1);
					__textbox_records_add__(_current_line_index, _current_cursor_pos);
				}
				
				#region jsDoc
				/// @func    __highlight_word_at_cursor__
				/// @desc    Highlights the word at the current cursor position.  
				///          - If the character at the cursor is not a word breaker (as defined by __word_breakers),  
				///            it expands the selection left and right until a word breaker is encountered.  
				///          - If the character is a word breaker, then:
				///              - If it is a space or tab, it selects all adjacent spaces and tabs.
				///              - Otherwise, it selects all contiguous word breaker characters.
				/// @self    WWTextBase
				/// @returns {Void}
				#endregion
				static __highlight_word_at_cursor__ = function() {
				    var _loc = __compute_word_boundaries__(cursor_y_pos, cursor_x_pos);
					
				    // Set selection: highlight from startPos to endPos in the current line.
				    highlight_x_pos = _loc.x_start;
				    highlight_y_pos = cursor_y_pos;
    
				    // Move the cursor to the end of the selected range.
				    set_cursor_x_pos(_loc.x_end);
    
				    // Activate the selection.
				    highlight_selected = true;
				};
				
				#region jsDoc
				/// @func    __update_word_selection_drag__
				/// @desc    Updates the word selection during a mouse drag after a double-click.
				///          The cursor is updated based on the mouse position using __get_pos_from_gui__
				///          while the selection anchors (stored in __word_anchor_start__, __word_anchor_end__, and __word_anchor_line__)
				///          remain fixed from the double-click. If the cursor is to the left of the anchor on the same line,
				///          the highlight is set to __word_anchor_end__; if to the right, it is set to __word_anchor_start__.
				///          When on a different line, the highlight is anchored to the original word line.
				/// @self    WWTextBase
				/// @returns {Void}
				#endregion
				static __update_word_selection_drag__ = function() {
				    // Get current mouse coordinates.
				    var mx = device_mouse_x_to_gui(0);
				    var my = device_mouse_y_to_gui(0);
					
				    // Use the unified helper to get the text position from GUI coordinates.
				    var pos = __get_pos_from_gui__(mx, my, true); // _wordMode false; we only need the raw position.
					
				    // Update the cursor to the calculated position.
				    set_cursor_x_pos(pos.x_start);
				    set_cursor_y_pos(pos.y);
					
				    // Update the selection boundaries based on the stored anchor:
				    // If the current line is above the anchor, highlight using the anchor's end.
				    if (pos.y < __word_anchor_line__) {
				        highlight_x_pos = __word_anchor_end__;
				        highlight_y_pos = __word_anchor_line__;
				    }
				    // If below the anchor, highlight using the anchor's start.
				    else if (pos.y > __word_anchor_line__) {
				        highlight_x_pos = __word_anchor_start__;
				        highlight_y_pos = __word_anchor_line__;
				    }
				    else {
				        // On the same line, if the cursor is to the left of the anchor, use the anchor's end;
				        // otherwise, use the anchor's start.
				        if (pos.x_start > __word_anchor_start__) {
				            highlight_x_pos = __word_anchor_start__;
				        } else {
				            highlight_x_pos = __word_anchor_end__;
				        }
				        highlight_y_pos = __word_anchor_line__;
				    }
					
				    // Mark that a selection is active.
				    highlight_selected = true;
				};
				
			#endregion
			
			#region Undo / Redo

			    #region jsDoc
				/// @func    __record__()
				/// @desc    Snapshot record constructor for undo/redo history.
				///          Stores a clone of the text lines, the active line, cursor position, and the width‐breakpoints.
				/// @self    WWTextInputSingle
				/// @param   {Array<String>} _lines_arr : The text content as an array of lines.
				/// @param   {Real} _line              : The active line index.
				/// @param   {Real} _cursor            : The cursor position within the active line.
				/// @param   {Array<Bool>} _break_arr  : The array of soft-break flags.
				/// @returns {Struct} A record object.
				#endregion
				static __record__ = function(_lines_arr, _line, _cursor, _break_arr) constructor {
				    lines = _lines_arr;
				    line = _line;
				    cursor = _cursor;
				    width_breakpoints = _break_arr;
				};

				#region jsDoc
				/// @func    __textbox_records_add__()
				/// @desc    Adds a new snapshot to the history stack for undo/redo.
				/// @self    WWTextInputSingle
				/// @param   {Real} _line   : The active line index.
				/// @param   {Real} _cursor : The cursor position in the active line.
				/// @returns {Void}
				#endregion
				static __textbox_records_add__ = function(_line, _cursor) {
				    var nextRecordIndex = __historic_records_loc__ + 1;
    
				    // Truncate history if we're not at the end.
				    if (nextRecordIndex < array_length(__historic_records__)) {
				        array_resize(__historic_records__, nextRecordIndex);
				    }
    
				    // Create a new record by cloning current state.
				    var _record = new __record__(
				        variable_clone(__lines__), 
				        _line,
				        _cursor,
				        variable_clone(__lines_broken_by_width__)
				    );
    
				    array_push(__historic_records__, _record);
    
				    // Limit history to a maximum number of records.
				    if (array_length(__historic_records__) > history_records_limit) {
				        array_delete(__historic_records__, 0, 1);
				        nextRecordIndex -= 1;
				    }
    
				    __historic_records_loc__ = nextRecordIndex;
				};

				#region jsDoc
				/// @func    __textbox_records_rec__()
				/// @desc    Updates the latest history record with the current cursor position.
				/// @self    WWTextInputSingle
				/// @param   {Real} _line   : The active line index.
				/// @param   {Real} _cursor : The cursor position in the active line.
				/// @returns {Void}
				#endregion
				static __textbox_records_rec__ = function(_line, _cursor) {
				    var currentRecord = __historic_records__[__historic_records_loc__];
				    currentRecord.line = _line;
				    currentRecord.cursor = _cursor;
				    __historic_records__[__historic_records_loc__] = currentRecord;
				};

				#region jsDoc
				/// @func    __textbox_records_set__()
				/// @desc    Moves the history cursor by _change steps and restores that snapshot (for undo/redo).
				/// @self    WWTextInputSingle
				/// @param   {Real} _change : The number of steps to move in the history (negative for undo, positive for redo).
				/// @returns {Void}
				#endregion
				static __textbox_records_set__ = function(_change) {
				    var targetIndex = __historic_records_loc__ + _change;
    
				    // Ensure the target index is within bounds.
				    if (targetIndex < 0 || targetIndex >= array_length(__historic_records__)) {
				        return;
				    }
    
				    var record = __historic_records__[targetIndex];
				    // Restore the state from the record.
				    __lines__ = variable_clone(record.lines);
				    __lines_broken_by_width__ = variable_clone(record.width_breakpoints);
				    set_cursor_y_pos(record.line);
				    set_cursor_x_pos(record.cursor);
    
				    __historic_records_loc__ = targetIndex;
				    highlight_selected = false;
				};

			#endregion
			
			
		#endregion
		
    #endregion
	
}

#region jsDoc
/// @func    WWTextInputSingle()
/// @desc    A single-line text input component supporting editing, caret, and selection.
/// @returns {Struct.WWTextInputSingle}
#endregion
function WWTextInputSingle() : WWTextInputMulti() constructor {
    debug_name = "WWTextInputSingle";
    
    #region Public
		
        #region Builder Functions
		
			#region jsDoc
			/// @func    set_shift_only_new_line()
			/// @desc    Set the text box to only accept new line breaks when you press shift. This is commonly used for when you wish to take advantage of the "submit" event when hiting enter.
			/// @self    GUICompTextbox
			/// @param   {Bool} memory_limit : If pressing shift+enter is the only way to break to a new line. if so then the default press of enter will submit the text.
			/// @returns {Struct.GUICompTextbox}
			#endregion
			static set_shift_only_new_line = function(_shift_only_nl=true) {
				curt.shift_only_new_line = _shift_only_nl;
		
				curt.no_wrap = !(curt.dynamic_width || curt.shift_only_new_line || curt.multiline);
		
				return self;
			}
			#region jsDoc
			/// @func    set_password_mode()
			/// @desc    Sets the cursor's width. This is usually used if you're manipulating you're GUI resolution and would like to increase the visibility of the cursor.
			/// @self    GUICompTextbox
			/// @param   {Real} width : The width of the cursor.
			/// @returns {Struct.GUICompTextbox}
			#endregion
			static set_password_mode = function(_width) {
				password_mode = _width
				
				return self;
			}
			#region jsDoc
			/// @func	set_placeholder_text()
			/// @desc	Sets the placeholder text that is displayed when no user input exists.
			///		 This text is not selectable; for selectable text, use set_text().
			/// @self	WWTextBase
			/// @param   {String} _placeholder : The placeholder text.
			/// @returns {Struct.WWTextBase}
			#endregion
			static set_placeholder_text = function(_placeholder = "Enter Text") {
				placeholder_text = _placeholder;
				return self;
			}
			#region jsDoc
			/// @func	set_max_length()
			/// @desc	Sets the maximum number of characters allowed in the text component.
			///		 A value of infinity allows unlimited characters.
			/// @self	WWTextBase
			/// @param   {Real} _max_length : The maximum character count.
			/// @returns {Struct.WWTextBase}
			#endregion
			static set_max_length = function(_max_length = infinity) {
				curt.max_length = _max_length;
				return self;
			}
			#region jsDoc
			/// @func	set_records_limit()
			/// @desc	Sets the limit for undo/redo records, useful when memory is a concern.
			/// @self	WWTextBase
			/// @param   {Real} _memory_limit : The maximum number of records to keep.
			/// @returns {Struct.WWTextBase}
			#endregion
			static set_records_limit = function(_memory_limit = 64) {
				if (should_safety_check && (_memory_limit < 0)) {
					show_error(string("Cannot use a negative value for set_records_limit(): {0}", _memory_limit), true);
				}
				curt.records_upper_limit = _memory_limit;
				return self;
			}
			
		#endregion
		
		#region Components
            // Optionally, you could add a caret overlay here.
        #endregion
        
		#region Events
            // Add keyboard event listeners for editing.
            self.on_key_press(function(_key) {
                // Handle backspace, character input, etc.
                // Update textContent and re-render.
                self.handle_key(_key);
            });
        #endregion
        
		#region Variables
			
			placeholder_text = ""; // Placeholder text shown when textContent is empty.
			
			max_char_length = infinity; // Maximum allowed number of characters (infinity for no limit).
			
			shift_only_new_line = false; // If true, only Shift+Enter produces a new line (otherwise, Enter submits).
			
		#endregion
		
        #region Functions
            
			
        #endregion
		
    #endregion
	
	#region Private
        
		#region Variables
			
			
		#endregion
		
		#region Functions
			
			#region Input Handling

			    #region jsDoc
			    /// @func    __textbox_max_length__()
			    /// @desc    Enforces the maximum character limit for the text input component.
			    /// @self    WWTextInputSingle
			    /// @returns {Void}
			    #endregion
			    static __textbox_max_length__ = function() {
			        if (max_char_length == infinity) return;

			        var _lines = __array_clone__(__lines__);
			        var _current_text = __lines_to_text__(_lines);

			        if (string_length(_current_text) - string_count("\n", _current_text) > max_char_length) {
			            var _i = 0;
			            var _remaining_chars = max_char_length;

			            repeat (array_length(_lines)) {
			                var _line_text = _lines[_i];
			                var _line_length = string_length(_line_text);

			                if (_line_length >= _remaining_chars) {
			                    _lines[_i] = string_copy(_line_text, 1, _remaining_chars);
			                    array_delete(_lines, _i + 1, array_length(_lines) - _i - 1);
			                    break;
			                } else {
			                    _remaining_chars -= _line_length;
			                }
			                _i += 1;
			            }

			            if (cursor_y_pos > _i) {
			                set_cursor_y_pos(_i);
			                set_cursor_x_pos(_remaining_chars);
			            } else if (cursor_y_pos == _i && cursor_x_pos > _remaining_chars) {
			                set_cursor_x_pos(_remaining_chars);
			            }

			            __lines__ = _lines;
			        }
			    }
				
			    #region jsDoc
			    /// @func    __textbox_paste_string__()
			    /// @desc    Retrieves text from the clipboard for pasting into the input field.
			    /// @self    WWTextInputSingle
			    /// @returns {String}
			    #endregion
			    static __textbox_paste_string__ = function() {
			        var _pasted_string = "";

			        if (os_browser == browser_not_a_browser) {
			            if (clipboard_has_text()) {
			                _pasted_string = clipboard_get_text();
			            }
			        } else {
			            if (js_clipboard_has_text_()) {
			                _pasted_string = js_clipboard_get_text();
			            }
			        }

			        return _pasted_string;
			    }

			    #region jsDoc
			    /// @func    __textbox_break_line__()
			    /// @desc    Inserts a new line at the cursor position.
			    /// @self    WWTextInputSingle
			    /// @returns {Void}
			    #endregion
			    static __textbox_break_line__ = function() {
			        var _current_line = cursor_y_pos;
			        var _text = __lines__[_current_line];
			        var _length = string_length(_text);
			        var _cursor = cursor_x_pos;

			        _current_line += 1;
			        if (_cursor < _length) {
			            var _begin = _cursor + 1;
			            var _count = _length - _cursor;

			            __lines__[_current_line - 1] = string_delete(_text, _begin, _count);
			            array_insert(__lines__, _current_line, string_copy(_text, _begin, _count));
			        } else {
			            array_insert(__lines__, _current_line, "");
			        }

			        array_insert(__lines_broken_by_width__, _current_line, true);

			        set_cursor_y_pos(_current_line);
			        set_cursor_x_pos(0);
			        if (dynamic_width) __break_lines__(_current_line, 1);
			        __textbox_records_add__(_current_line, 0);
			    }
				
			#endregion
				
		#endregion
		
    #endregion
	
}

#region jsDoc
/// @func    WWTextInputMulti()
/// @desc    A multi-line text input component supporting editing, line wrapping, and scrolling if needed.
/// @returns {Struct.WWTextInputMulti}
#endregion
function WWTextInputMulti() : WWTextBase() constructor {
    debug_name = "WWTextInputMulti";
    
    #region Public
        #region Variables
            // Maintain an array of lines for multi-line editing.
            lines = [];
        #endregion
        
        #region Functions
            static set_text = function(_text) {
                // Split text into lines.
                lines = string_split(_text, "\n");
                textContent = _text;
                self.render_text();
                return self;
            }
            
            static render_text = function() {
                var currentY = y;
                for (var i = 0; i < array_length(lines); i++) {
                    draw_text(x, currentY, lines[i]);
                    currentY += 20; // line height
                }
                self.render_selection();
                // Optionally render caret on the active line.
            }
        #endregion
        
        #region Events
            // Handle key events for multi-line input similarly, with logic for newlines.
        #endregion
    #endregion
}

#region jsDoc
/// @func    WWCodeEditor()
/// @desc    A specialized text component for code editing, with syntax highlighting and line numbering.
/// @returns {Struct.WWCodeEditor}
#endregion
function WWCodeEditor() : WWTextInputMulti() constructor {
    debug_name = "WWCodeEditor";
    
    #region Public
        #region Functions
            static render_text = function() {
                // Example: iterate through lines and apply syntax highlighting.
                var currentY = y;
                for (var i = 0; i < array_length(lines); i++) {
                    var highlighted = apply_syntax_highlighting(lines[i]); // Assume a function exists.
                    // Optionally draw line numbers.
                    draw_text(x - 30, currentY, (i+1) + ".");
                    draw_highlighted_text(x, currentY, highlighted);
                    currentY += 20;
                }
                self.render_selection();
                // Render caret on the active line.
            }
        #endregion
        
        #region Events
            // Inherit keyboard handling from WWTextInputMulti.
            // Could add additional events for auto-indent, etc.
        #endregion
    #endregion
}


