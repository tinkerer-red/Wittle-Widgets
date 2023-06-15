#region jsDoc
/// @func    GUICompTextbox()
/// @desc    Creates a text input component
/// @param   {Real} x : The x position of the component on screen.
/// @param   {Real} y : The y position of the component on screen.
/// @return {Struct.GUICompTextbox}
#endregion
function GUICompTextbox() : GUICompRegion() constructor {
	debug_name = "GUICompTextbox";
	
	#region Public
		
		#region Builder functions
			
			#region jsDoc
			/// @func    set_region()
			/// @desc    Set the reletive region for all click selections. Reletive to the x,y of the component.
			/// @self    GUICompCore
			/// @param   {real} left : The left side of the bounding box
			/// @param   {real} top : The top side of the bounding box
			/// @param   {real} right : The right side of the bounding box
			/// @param   {real} bottom : The bottom side of the bounding box
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_region = function(_left, _top, _right, _bottom) { static __run_once__ = log(["set_region", set_region]);
				__SUPER__.set_region(_left, _top, _right, _bottom);
				
				return self;
			}
			#region jsDoc
			/// @func    set_enabled()
			/// @desc    Enable or Disable the Component, This usually effects how some components are handled
			/// @self    GUICompTextbox
			/// @param   {Bool} is_enabled : If the component should be enabled or not.
			/// @returns {Struct.GUICompTextbox}
			#endregion
			static set_enabled = function(_enabled) { static __run_once__ = log(["set_enabled", set_enabled]);
				if(_enabled) {
					enabled = true;
					enabled_step = 0;
					keyboard_string = "";
					keys.last_key_time = 0;	
					keys.last_key = undefined;
				}
				else {
					enabled = false;
					__selection_start__ = 0;
				}
			}
			#region jsDoc
			/// @func    set_text_placeholder()
			/// @desc    Sets the display text to draw when no user input text has been entered. This text is not selectable, if you would like to have selectable text your self then use "set_text()".
			/// @self    GUICompTextbox
			/// @param   {String} str : The text to populate an empty text region
			/// @returns {Struct.GUICompTextbox}
			#endregion
			static set_text_placeholder = function(_placeholder="Enter Text") { static __run_once__ = log(["set_text_placeholder", set_text_placeholder]);
				curt.placeholder = _placeholder;
				
				return self;
			}
			#region jsDoc
			/// @func    set_text()
			/// @desc    Sets the string inside the text box. This text will be selectable by the user, if you wish to have not selectable text use "set_text_placeholder()".
			/// @self    GUICompTextbox
			/// @param   {String} str : The text to write on the button
			/// @returns {Struct.GUICompTextbox}
			#endregion
			static set_text = function(_text="") { static __run_once__ = log(["set_text", set_text]);
				var _prev_cursor_x = get_cursor_x_pos();
				var _prev_cursor_y = get_cursor_y_pos();
				var _prev_scroll_x = get_horz_scroll();
				var _prev_scroll_y = get_vert_scroll();
				
				clear_text();
				__textbox_insert_string__(_text);
				
				set_cursor_x_pos(_prev_cursor_x);
				set_cursor_y_pos(_prev_cursor_y);
				set_horz_scroll(_prev_scroll_x);
				set_vert_scroll(_prev_scroll_y);
				
				
				return self;
			}
			#region jsDoc
			/// @func    set_text_font()
			/// @desc    Sets the font which will be used for drawing the text
			/// @self    GUICompTextbox
			/// @param   {Asset.GMFont} font : The font to use when drawing the text
			/// @returns {Struct.GUICompTextbox}
			#endregion
			static set_text_font = function(_font=fGUIDefault) { static __run_once__ = log(["set_text_font", set_text_font]);
				draw.font = _font;								// font
				
				if (!__char_enforcement_defined__) {
					__allowed_char__ = __build_allowed_char__(_font);
				}
				
				if (!__line_height_defined__) {
					draw.line_height = font_get_info(draw.font).size;
				}
				
				return self;
			}
			#region jsDoc
			/// @func    set_font_color()
			/// @desc    Sets the font which will be used for drawing the text
			/// @self    GUICompTextbox
			/// @param   {Constant.Colour} font : The font to use when drawing the text
			/// @returns {Struct.GUICompTextbox}
			#endregion
			static set_text_color = function(_color=#D9D9D9) { static __run_once__ = log(["set_text_color", set_text_color]);
				draw.font_color = _color;					// font color
				
				return self;
			}
			#region jsDoc
			/// @func    set_text_line_height()
			/// @desc    Sets the height for lines of text. setting this to -1 will make the height auto addapt to the currently used font. So be sure to call this after you 
			/// @self    GUICompTextbox
			/// @param   {Real} height : The height of the courser and line spaces, this included the font, usually best as font height.
			/// @returns {Struct.GUICompTextbox}
			#endregion
			static set_text_line_height = function(_height=-1) { static __run_once__ = log(["set_text_line_height", set_text_line_height]);
				__line_height_defined__ = true;
				draw.line_height = (_height != -1) ? _height : font_get_info(draw.font).size;
				
				return self;
			}
			#region jsDoc
			/// @func    set_text_offsets()
			/// @desc    Sets the font which will be used for drawing the text
			/// @self    GUICompTextbox
			/// @param   {Real} xoff : The x offset of the text from the start of a line.
			/// @param   {Real} yoff : The y offset of the text from the start of a line.
			/// @returns {Struct.GUICompTextbox}
			#endregion
			static set_text_offsets = function(_x_off=0, _y_off=1) { static __run_once__ = log(["set_text_offsets", set_text_offsets]);
				scroll.x_off = _x_off;
				scroll.y_off = _y_off;
				
				return self;
			}
			#region jsDoc
			/// @func    set_highlight_color()
			/// @desc    Sets the colors of the box which surrounds the highlighted selection.
			/// @self    GUICompTextbox
			/// @param   {Constant.Colour} color : The highlight color
			/// @returns {Struct.GUICompTextbox}
			#endregion
			static set_highlight_color = function(_color=#0A68D8) { static __run_once__ = log(["set_highlight_color", set_highlight_color]);
				draw.highlight_region_color = _color;
				
				return self;
			}
			#region jsDoc
			/// @func    set_background_color()
			/// @desc    Sets the color of the background.
			/// @self    GUICompTextbox
			/// @param   {Constant.Colour} color : The background color
			/// @returns {Struct.GUICompTextbox}
			#endregion
			static set_background_color = function(_color=#363F39) { static __run_once__ = log(["set_background_color", set_background_color]);
				draw.text_background_color = _color;
				
				return self;
			}
			#region jsDoc
			/// @func    set_background_alpha()
			/// @desc    Sets the alpha of the background.
			/// @self    GUICompTextbox
			/// @param   {Constant.Colour} color : The background color
			/// @returns {Struct.GUICompTextbox}
			#endregion
			static set_background_alpha = function(_color=#363F39) { static __run_once__ = log(["set_background_alpha", set_background_alpha]);
				draw.text_background_alpha = _color;
				
				return self;
			}
			#region jsDoc
			/// @func    set_max_length()
			/// @desc    Sets the max character limit.
			/// @self    GUICompTextbox
			/// @param   {Real} max_length : The max number of characters to support. NOTE: A value of infinity will allow for any number of characters.
			/// @returns {Struct.GUICompTextbox}
			#endregion
			static set_max_length = function(_max_length=infinity) { static __run_once__ = log(["set_max_length", set_max_length]);
				if (should_safety_check) {
					if (_max_length < 0) {
						show_error(string("Can not use a negative value for \"set_max_length()\" : {0}", _max_length), true);
					}
				}
				curt.max_length = _max_length;
				
				return self;
			}
			#region jsDoc
			/// @func    set_records_limit()
			/// @desc    Sets how many undo and redo the component will remember. This is really only used if you are having memory issues with your game.
			/// @self    GUICompTextbox
			/// @param   {Real} memory_limit : The max number of characters to support. NOTE: A value of infinity will allow for any number of characters.
			/// @returns {Struct.GUICompTextbox}
			#endregion
			static set_records_limit = function(_memory_limit=64) { static __run_once__ = log(["set_records_limit", set_records_limit]);
				if (should_safety_check) {
					if (_memory_limit < 0) {
						show_error(string("Can not use a negative value for \"set_records_limit()\" : {0}", _memory_limit), true);
					}
				}
				
				curt.records_upper_limit = _memory_limit;
				return self;
			}
			#region jsDoc
			/// @func    set_char_enforcement()
			/// @desc    Set what characters the textbox should allow. You can either input a string of allowed characters for input boxes like passwords, or leaving the argument empty will generage the characters from the current font.
			/// @self    GUICompTextbox
			/// @param   {Real} memory_limit : The max number of characters to support. NOTE: A value of infinity will allow for any number of characters.
			/// @returns {Struct.GUICompTextbox}
			#endregion
			static set_char_enforcement = function(_allowed_char=undefined) { static __run_once__ = log(["set_char_enforcement", set_char_enforcement]);
				
				if (is_undefined(_allowed_char)) {
					__allowed_char__ = __build_allowed_char__(draw.font);
				}
				else {
					__allowed_char__ = {};
					__char_enforcement_defined__ = true;
					string_foreach(_allowed_char, function(_char, _pos) {
						__allowed_char__[$ _char] = true;
					})
				}
				
				return self;
			}
			#region jsDoc
			/// @func    set_multiline()
			/// @desc    Set the textbox to accept line breaks from user input.
			/// @self    GUICompTextbox
			/// @param   {Bool} multiline : If the textbox allows the inputting of "\n"
			/// @returns {Struct.GUICompTextbox}
			#endregion
			static set_multiline = function(_multiline=true) { static __run_once__ = log(["set_multiline", set_multiline]);
				curt.multiline = _multiline;
				
				curt.no_wrap = !(curt.adaptive_width || curt.shift_only_new_line || curt.multiline);
		
				return self;
			}
			#region jsDoc
			/// @func    set_force_wrapping()
			/// @desc    Sets the textbox to break to a new line when reaching the width. This will still enforce new lines even for single line text boxes.
			/// @self    GUICompTextbox
			/// @param   {Bool} memory_limit : If the text box will break to a new line when reaching the width.
			/// @returns {Struct.GUICompTextbox}
			#endregion
			static set_force_wrapping = function(_force_wrapping=true) { static __run_once__ = log(["set_force_wrapping", set_force_wrapping]);
				curt.adaptive_width = _force_wrapping;
				
				curt.no_wrap = !(curt.adaptive_width || curt.shift_only_new_line || curt.multiline);
				
				return self;
			}
			#region jsDoc
			/// @func    set_shift_only_new_line()
			/// @desc    Set the text box to only accept new line breaks when you press shift. This is commonly used for when you wish to take advantage of the "submit" event when hiting enter.
			/// @self    GUICompTextbox
			/// @param   {Bool} memory_limit : If pressing shift+enter is the only way to break to a new line. if so then the default press of enter will submit the text.
			/// @returns {Struct.GUICompTextbox}
			#endregion
			static set_shift_only_new_line = function(_shift_only_nl=true) { static __run_once__ = log(["set_shift_only_new_line", set_shift_only_new_line]);
				curt.shift_only_new_line = _shift_only_nl;
		
				curt.no_wrap = !(curt.adaptive_width || curt.shift_only_new_line || curt.multiline);
		
				return self;
			}
			#region jsDoc
			/// @func    set_accepting_inputs()
			/// @desc    Enables of disabled the ability for user input. Setting this to false will still allow highlighting, and copying of text, but will not allow text to be input from the user. Usually used for when we just want to draw selectable text.
			/// @self    GUICompTextbox
			/// @param   {Bool} accepting_inputs : If pressing shift+enter is the only way to break to a new line. if so then the default press of enter will submit the text.
			/// @returns {Struct.GUICompTextbox}
			#endregion
			static set_accepting_inputs = function(_bool=true) { static __run_once__ = log(["set_accepting_inputs", set_accepting_inputs]);
				curt.accepting_inputs = _bool;
		
				return self;
			}
			#region jsDoc
			/// @func    set_copy_override()
			/// @desc    Used to override what the default copy function will return.
			/// @self    GUICompTextbox
			/// @param   {Function} func : The return of this function will be what gets copied into the user's clipboard.
			/// @returns {Struct.GUICompTextbox}
			#endregion
			static set_copy_override = function(_func) { static __run_once__ = log(["set_copy_override", set_copy_override]);
				copy_function = _func;
				
				return self;
			}
			#region jsDoc
			/// @func    set_paste_override()
			/// @desc    Used to override what the default paste function will return.
			/// @self    GUICompTextbox
			/// @param   {Function} func : The return of this function will be what gets pasted into the user's clipboard.
			/// @returns {Struct.GUICompTextbox}
			#endregion
			static set_paste_override = function(_func) { static __run_once__ = log(["set_paste_override", set_paste_override]);
				paste_function = _func;
				
				return self;
			}
			#region jsDoc
			/// @func    set_cursor_x_pos()
			/// @desc    Sets the x position of the cursor on the current line, a value of `0` will indicate the furthest left, and a value of `1` will place the cursor on the right of the first letter in the line's string.
			/// @self    GUICompTextbox
			/// @param   {Real} xpos : The x position of the cursor
			/// @returns {Struct.GUICompTextbox}
			#endregion
			static set_cursor_x_pos = function(_x_pos) { static __run_once__ = log(["set_cursor_x_pos", set_cursor_x_pos]);
				if (_x_pos == curt.cursor) {
					return self;
				}
				
				//clamp the value
				var _line_length = string_length(curt.lines[curt.current_line]);
				if (_x_pos > _line_length) {
					_x_pos = _line_length;
				}
				
				curt.cursor = _x_pos;
				draw.display_cursor = 30;
				
				__update_scroll__();
				
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
			static set_cursor_y_pos = function(_y_pos) { static __run_once__ = log(["set_cursor_y_pos", set_cursor_y_pos]);
				if (_y_pos == curt.current_line) {
					return self;
				}
				
				curt.current_line = clamp(_y_pos, 0, curt.length-1);
				draw.display_cursor = 30;
				
				__update_scroll__();
				
				return self;
			}
			#region jsDoc
			/// @func    set_cursor_gui_loc()
			/// @desc    Sets the cursor position of the cursor based on the GUI x/y position supplied.
			/// @self    GUICompTextbox
			/// @param   {Real} xpos : The x position of the cursor.
			/// @param   {Real} ypos : The y position of the cursor.
			/// @returns {Struct.GUICompTextbox}
			#endregion
			static set_cursor_gui_loc = function(_x, _y) { static __run_once__ = log(["set_cursor_gui_loc", set_cursor_gui_loc]);
				draw_set_font(draw.font);
				
				var _cursor_x, _cursor_y;
				
				var _line_height = draw.line_height;
				_cursor_y  = clamp(floor((-scroll.y_off + _y - y) / _line_height), 0, curt.length - 1);
				var _text = curt.lines[_cursor_y];
				var _text_length = string_length(_text);
					
				if (_cursor_y  == curt.current_line) {
					_cursor_x = curt.cursor;
					var _cursor_width = string_width(string_copy(_text, 1, _cursor_x)) + scroll.x_off - _x + x;
					var _new_cursor = _cursor_x;
					
					if (_cursor_width < 0) {
						_cursor_width *= -1;
						if (_cursor_x == 0) _cursor_x = 1;
						repeat (_text_length) {
							var _remaining_area = _cursor_width - string_width(string_copy(_text, _new_cursor + 1, 1)) / 2;
							if (string_width(string_copy(_text, _cursor_x, _new_cursor - _cursor_x)) >= _remaining_area) break;
							_new_cursor +=1;
						}
					}
					else {
						repeat (_text_length) {
							var _remaining_area = _cursor_width - string_width(string_copy(_text, _new_cursor, 1)) / 2;
							if (string_width(string_copy(_text, _new_cursor, _cursor_x - _new_cursor)) >= _remaining_area) break;
							_new_cursor --;
						}
					}
					
					_cursor_x = clamp(_new_cursor, 0, _text_length);
				}
				else {
						
					var _cursor_width = -scroll.x_off + _x - x;
					_cursor_x = 0;
						
					if (_cursor_width >= string_width(_text)) {
						_cursor_x = _text_length;
					}
					else {
						repeat (_text_length) {
							var _remaining_area = _cursor_width - string_width(string_copy(_text, _cursor_x + 1, 1)) / 2;
							if (string_width(string_copy(_text, 1, _cursor_x)) >= _remaining_area) break;
							_cursor_x += 1;
						}
					}
					
				}
					
				set_cursor_y_pos(_cursor_y);
				set_cursor_x_pos(_cursor_x);
					
				__textbox_records_rec__(_cursor_y , _cursor_x);
				
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
			
			
			
			//forget the parent's functions, this is temporary and if it made it to release then Red messed up.
			// TODO: remove these and make the text region it's own internal functions to handle scrolling.
			//static set_canvas_size = undefined;
			static set_canvas_size_from_children = undefined;
			static add = undefined;
			static insert = undefined;
			static remove = undefined;
			
		#endregion
		
		#region Events
			
			self.events.change     = "change";
			self.events.submit     = "submit";
			
		#endregion
		
		#region Variables
			
			draw_set_font(fGUIDefault)
			
			owner = other;
			
			copy_function  = undefined; //these get set after private variables function are defined
			paste_function = undefined;
			
			draw = {
				refresh_surf : false,	// refresh surface
				display_cursor : 30,	// display cursor
				font : fGUIDefault,		// font
				font_color : /*#*/0xDEDDDC,	// font color
				highlight_region_color: /*#*/0xD8680A, //the color of the selection box when highlighting
				text_background_color: /*#*/0x3F3936, //the background rectangle
				text_background_alpha : 1,
				//scrollbar_visible: true, //if the scrollbar should be drawn
				//x_start : 0,					// x start
				//y_start : 0,					// y start
				//width : 0,			// draw width
				//height : 0,			// draw height
				line_height : font_get_info(fGUIDefault).size,			// line height
				scroll_width : 4,			// scrollbar width
				scroll_height : 0,		// scrollbar height
				scrollbar_y : 0,			// scrollbar y
				mouse_loc_y : 0,				// mouse y
				cursor_width : 1,
				cursor_height : -1,
			}
			
			curt = {
				focus : false,								// [internally used] really only used when the region is not a input region, but allows for selecting text
				view : false,									// view;
				multiline : true,							// multiline; if the text field is a multiline text field
				length : 1,										// length
				placeholder : "",							// placeholder; when there is no text in the field what should be written
				current_line : 0,							// current line; the current line number the cursor is on
				cursor : 0,										// cursor; what char pos is the cursor at
				select : -1,									// select; if a region is being highlighted
				max_length : infinity,				// max length; max char limit
				records_upper_limit : 64,			// records upper limit; how many undos are remembered
				no_wrap : true,							// allow for user input "\n"
				adaptive_width : false,				// adaptive width; can the text box canvas be bigger then the region set, allowing for scrolling sideways
				shift_only_new_line: true,    // shift_only_nl ; pressing enter will submit the text, but pressing shift+enter will break to new line if possible
				
				
				lines : [""],									// lines; [internally used] an array of each line of text in the input field
				select_line : -1,							// select line; [internally used] which line did the highlight start on
				historic_records : [],				// historic records; [internally used] array of records history 
				records_cursor : -1,					// records cursor [internally used] where the undo/redo marker is at
				width_breakpoints : [true],		// width breakpoints [internally used]
				button_repeat : 1,												//this was not documented from the original library... [internally used]
				accepting_inputs: true,				//if set to false only highlighting and copying is allowed
			}
			
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
			
			//font = fGUIDefault;
			is_disabled = false;
			
		#endregion
		
		#region Functions
			
			#region jsDoc
			/// @func    get_text()
			/// @desc    Returns the text from the textbox
			/// @self    GUICompTextbox
			/// @returns {String}
			#endregion
			static get_text = function() { static __run_once__ = log(["get_text", get_text]);
				return __textbox_return__();
			}
			#region jsDoc
			/// @func    clear_text()
			/// @desc    Clear the text from the text box.
			/// @self    GUICompTextbox
			/// @returns {Undefined}
			#endregion
			static clear_text = function() { static __run_once__ = log(["clear_text", clear_text]);
				var _last_line_index = curt.length - 1;
				var _last_line_length = string_length(curt.lines[_last_line_index]);
				if (_last_line_index < 1 && _last_line_length < 1) return;
				curt.select_line = 0;
				curt.select = 0;
				set_cursor_y_pos(_last_line_index);
				set_cursor_x_pos(_last_line_length);
				__textbox_delete_string__(false);
			}
			#region jsDoc
			/// @func    get_coverage_width()
			/// @desc    Get the coverage width of the textbox. This is the view width as displayed on the gui
			/// @self    GUICompTextbox
			/// @returns {Real}
			#endregion
			static get_coverage_width = function() { static __run_once__ = log(["get_coverage_width", get_coverage_width]);
				if (__scroll_vert_hidden__) {
					return region.get_width()
				}
				else {
					return region.get_width() - __scroll_vert__.region.get_width()
				}
			}
			#region jsDoc
			/// @func    get_coverage_height()
			/// @desc    Get the coverage height of the textbox. This is the view height as displayed on the gui
			/// @self    GUICompTextbox
			/// @returns {Real}
			#endregion
			static get_coverage_height = function() { static __run_once__ = log(["get_coverage_height", get_coverage_height]);
				if (__scroll_horz_hidden__) {
					return region.get_height()
				}
				else {
					return region.get_height() - __scroll_horz__.region.get_height()
				}
			}
			#region jsDoc
			/// @func    get_canvas_width()
			/// @desc    Get the canvas width of the textbox. This is the width of the underlying region where text can be drawn.
			/// @self    GUICompTextbox
			/// @returns {Real}
			#endregion
			static get_canvas_width = function() { static __run_once__ = log(["get_canvas_width", get_canvas_width]);
				draw_set_font(draw.font);
				var _width, _max_width, _lines, _size;
				var _struct = {
					max_width : 0
				};
				
				array_foreach(curt.lines, method(_struct, function(_element, _index) {
					var _width = string_width(_element)
					if (_width > max_width) {
						max_width = _width
					}
				}));
				
				return _struct.max_width;
			}
			#region jsDoc
			/// @func    get_canvas_height()
			/// @desc    Get the canvas height of the textbox. This is the height of the underlying region where text can be drawn.
			/// @self    GUICompTextbox
			/// @returns {Real}
			#endregion
			static get_canvas_height = function() { static __run_once__ = log(["get_canvas_height", get_canvas_height]);
				return curt.length * draw.line_height;
			}
			#region jsDoc
			/// @func    get_cursor_x_pos()
			/// @desc    Get cursor's x position in the GUI
			/// @self    GUICompTextbox
			/// @returns {Real}
			#endregion
			static get_cursor_x_pos = function() { static __run_once__ = log(["get_cursor_x_pos", get_cursor_x_pos]);
				var _derivative_x = string_width(string_copy(curt.lines[curt.current_line], 1, curt.cursor)) + scroll.x_off;
				return x + _derivative_x;
			}
			#region jsDoc
			/// @func    get_cursor_y_pos()
			/// @desc    Get cursor's y position in the GUI
			/// @self    GUICompTextbox
			/// @returns {Real}
			#endregion
			static get_cursor_y_pos = function() { static __run_once__ = log(["get_cursor_y_pos", get_cursor_y_pos]);
				var _center_y = (curt.multiline) ? 0 : ceil((draw.line_height-get_coverage_height())/2);
				var _derivative_y = curt.current_line * draw.line_height + scroll.y_off + _center_y;
				return y + _derivative_y;
			}
			#region jsDoc
			/// @func    get_cursor_width()
			/// @desc    Get cursor's width. This is directly related to the line width.
			/// @self    GUICompTextbox
			/// @returns {Real}
			#endregion
			static get_cursor_width = function() { static __run_once__ = log(["get_cursor_width", get_cursor_width]);
				return draw.cursor_width;
			}
			#region jsDoc
			/// @func    get_cursor_height()
			/// @desc    Get cursor's height. This is directly related to the line height.
			/// @self    GUICompTextbox
			/// @returns {Real}
			#endregion
			static get_cursor_height = function() { static __run_once__ = log(["get_cursor_height", get_cursor_height]);
				return (draw.cursor_height < 0) ? draw.line_height : draw.cursor_height;;
			}
			#region jsDoc
			/// @func    mouse_on_comp()
			/// @desc    Checks to see if the mouse is currently on the component. Used for optimization when hundreds of components are available.
			/// @self    GUICompCore
			/// @returns {Bool}
			#endregion
			static mouse_on_comp = function() { static __run_once__ = log(["mouse_on_comp", mouse_on_comp]);
				//check if parent even has a mouse over it
				if (__is_child__) {
					if (!__parent__.__mouse_on_cc__) {
						return false;
					}
				}
				
				//check to see if the mouse is out of the window it's self
				static is_desktop = (os_type == os_windows || os_type == os_macosx || os_type == os_linux)
				//if (is_desktop) {
				//	if (window_mouse_get_x() != display_mouse_get_x() - window_get_x())
				//	|| (window_mouse_get_y() != display_mouse_get_y() - window_get_y()) {
				//		__mouse_on_cc__ = false;
				//		return false;
				//	}
				//}
				
				__mouse_on_cc__ = point_in_rectangle(
						device_mouse_x_to_gui(0),
						device_mouse_y_to_gui(0),
						x+region.left,
						y+region.top,
						x+get_coverage_width(),
						y+get_coverage_height()
				)
				
				if (__mouse_on_cc__) {
					__trigger_event__(self.events.on_hover);
				}
				
				return __mouse_on_cc__;
			}
			
		#endregion
		
	#endregion
	
	#region Private Library
		
		#region Variables
			
			__allowed_char__ = {};
			__line_height_defined__ = false;
			__char_enforcement_defined__ = false;
			__using_cached_drawing__ = false;
			__component_surface__ = undefined;
			
		#endregion
		
		#region Functions
			
			#region GML Events
				
				static __cleanup__ = function() { static __run_once__ = log(["__cleanup__", __cleanup__]);
					
					cleanup();
					
					if (__component_surface__ != undefined) {
						surface_free(__component_surface__);
					}
					
					if (os_browser = browser_not_a_browser) {
						if (os_type = os_windows) {
							if (window_get_cursor() != cr_default) {
								window_set_cursor(cr_default);
							}
						}
					}
					else {
						js_set_cursor(cr_default);
					}
					
				}
				
				static __step__ = function(_input) { static __run_once__ = log(["__step__", __step__]);
					step(_input);
					
					if (is_disabled) return;
					
					var _mouse_x_gui = device_mouse_x_to_gui(0);
					var _mouse_y_gui = device_mouse_y_to_gui(0);
					
					var _draw_width = get_coverage_width();
					var _draw_height = get_coverage_height();
					var _start_x = x;
					var _start_y = y;
					var _scroll_width = (curt.multiline) ? draw.scroll_width : 0;
					var _mouse_on_comp = !_input.consumed && mouse_on_comp();
					
					if (_mouse_on_comp != curt.view) {
						var _cursor = (_mouse_on_comp) ? cr_beam : cr_default
						if (os_browser = browser_not_a_browser) {
							if (os_type = os_windows) {
								if (window_get_cursor() != _cursor) {
									window_set_cursor(_cursor);
								}
							}
						}
						else {
							js_set_cursor(_cursor);
						}
						curt.view = _mouse_on_comp;
					}
					
					var _display_cursor = draw.display_cursor - 1;
					if (_display_cursor < -30) {
						_display_cursor = 30;
						draw.refresh_surf = true;
					}
					else if (_display_cursor == 0) {
						draw.refresh_surf = true;
					}
					
					draw.display_cursor = _display_cursor;
					
					//allow early outs with breaks;
					repeat (1) {
						
						#region update cursor (with mouse)
					
							if (mouse_check_button_pressed(keys.mouse_left)) {
								if (!_mouse_on_comp) {
									if (__is_on_focus__) {
										if (__event_exists__(self.events.submit)) {
											var _text = __textbox_lines_to_text__(curt.lines);
											__trigger_event__(self.events.submit, _text);
										}
									}
									curt.focus = false;
								}
					
								if (curt.accepting_inputs) {
									__is_on_focus__ = _mouse_on_comp;
									if (__is_on_focus__){
										__trigger_event__(self.events.on_focus);
									}
									else{
										__trigger_event__(self.events.on_blur);
									}
									
									draw.display_cursor = (_mouse_on_comp) ? 30 : 0;
								}
								
								curt.focus = _mouse_on_comp;
								curt.select = -1;
					
								draw.refresh_surf = true;
					
								//if we clicked on the box
								if (_mouse_on_comp) {
									keyboard_string = "";
									__textbox_check_minput__(keyboard_check(keys.shift));
									curt.button_repeat = 5;
								}
								else {
									var _total_height = curt.length * draw.line_height;
									if (_total_height > _draw_height) {
										var _right_boundary = _start_x + _draw_width;
								
										if (!point_in_rectangle(
												_mouse_x_gui,
												_mouse_y_gui,
												_right_boundary - _scroll_width,
												_start_y,
												_right_boundary,
												_start_y + _draw_height
										)) {
											break;
										};
								
										var _derivative_y = draw.scrollbar_y;
										var _scroll_height = draw.scroll_height;
										var _text_y = _start_y + _derivative_y;
								
										if (_mouse_y_gui >= _text_y)
										&& (_mouse_y_gui <= _text_y + _scroll_height) {
											draw.mouse_loc_y = _mouse_y_gui;
										}
										else {
											var _cursor_height = _draw_height - _scroll_height;
											_derivative_y = _mouse_y_gui - _start_y;
										
											_derivative_y = (_derivative_y < _scroll_height) ? 0 : _cursor_height;
										
											set_vert_scroll(-(_derivative_y / _cursor_height * (_total_height - _draw_height)));
											draw.mouse_loc_y = _mouse_y_gui;
											draw.refresh_surf = true;
										}
									}
									break;
								}
								break;
							}
					
							if (draw.mouse_loc_y > 0) {
								if (mouse_check_button_released(keys.mouse_left)) {
									draw.mouse_loc_y = 0;
								}
								else if (mouse_check_button(keys.mouse_left)) {
									curt.button_repeat --;
									if (curt.button_repeat < 0) {
										var _derivative_y = draw.scrollbar_y;
										var _cursor_height = _draw_height - draw.scroll_height;
								
										_derivative_y = clamp(_derivative_y + _mouse_y_gui - draw.mouse_loc_y, 0, _cursor_height);
										set_vert_scroll(-(_derivative_y / _cursor_height * (curt.length * draw.line_height - _draw_height)));
									
										draw.mouse_loc_y = _mouse_y_gui;
										draw.refresh_surf = true;
										curt.button_repeat = 1;
									}
								}
							}

						#endregion
					
						#region update mouse selector
						
							//allow highlighting if the region is not an input region and it's just displaying copy-able text
							if (curt.focus) {
								if (mouse_check_button(keys.mouse_left)) {
									curt.button_repeat --;
									if (curt.button_repeat < 0) {
										__textbox_check_minput__(true);
										curt.button_repeat = 3;
									}
									break;
								}
							}
						
						#endregion
					
						#region Copy
						
							if (curt.focus)
							&& (keyboard_check(keys.control)) {
								if (keyboard_check(keys.c)) {
									if (keyboard_check_pressed(keys.c)) {
										var _text = copy_function();
										if (os_browser == browser_not_a_browser) {
											clipboard_set_text(_text);
										}
										else {
											js_clipboard_set_text(_text);
										}
									}
					
									//html5 support
									keyboard_string = "";
									
									keys.last_key = keys.c;
					
									break;
								}
							}
						
						#endregion
					
						#region PageUp PageDown
						
							if (curt.focus) {
								if (keyboard_check_pressed(keys.page_up)) {
									if (keyboard_check(keys.shift)) {
										if (curt.select == -1) {
											curt.select_line = curt.current_line;
											curt.select = curt.cursor;
										}
									}
									else {
										curt.select = -1;
									}
								
									var _height = get_coverage_height();
									var _lines_shown = floor(_height/draw.line_height)
									set_cursor_x_pos(__textbox_check_vinput__(-_lines_shown));
								
									//html5 support
									keyboard_string = "";
									
									keys.last_key = keys.page_up;
								
									curt.button_repeat = 40;
								
									break;
								}
								else if (keyboard_check_pressed(keys.page_down)) {
									if (keyboard_check(keys.shift)) {
										if (curt.select == -1) {
											curt.select_line = curt.current_line;
											curt.select = curt.cursor;
										}
									}
									else {
										curt.select = -1;
									}
									
									var _height = get_coverage_height();
									var _lines_shown = floor(_height/draw.line_height)
									set_cursor_x_pos(__textbox_check_vinput__(_lines_shown));
									
									//html5 support
									keyboard_string = "";
									
									keys.last_key = keys.page_down;
								
									curt.button_repeat = 40;
								
									break;
								}
							
								if (keyboard_check(keys.page_up)) {
									curt.button_repeat --;
									if (curt.button_repeat < 0) {
										if (keyboard_check(keys.shift)) {
											if (curt.select == -1) {
												curt.select_line = curt.current_line;
												curt.select = curt.cursor;
											}
										}
										else {
											curt.select = -1;
										}
									
										var _height = get_coverage_height();
										var _lines_shown = _height/draw.line_height
										set_vert_scroll(scroll.y_off + _height)
										set_cursor_y_pos(curt.current_line - _lines_shown)
									
										//html5 support
										keyboard_string = "";
										
										keys.last_key = keys.page_up;
									
										curt.button_repeat = 3;
									
										break;
									}
								}
								else if (keyboard_check(keys.page_down)) {
									curt.button_repeat --;
									if (curt.button_repeat < 0) {
										if (keyboard_check(keys.shift)) {
											if (curt.select == -1) {
												curt.select_line = curt.current_line;
												curt.select = curt.cursor;
											}
										}
										else {
											curt.select = -1;
										}
									
										var _height = get_coverage_height();
										var _lines_shown = _height/draw.line_height
										set_vert_scroll(scroll.y_off - _height)
										set_cursor_y_pos(curt.current_line + _lines_shown)
									
										//html5 support
										keyboard_string = "";
										
										keys.last_key = keys.page_down;
									
										curt.button_repeat = 3;
									
										break;
									}
								}
							}
						
						#endregion
					
					}
					
					if (curt.multiline) {
						__SUPER__.__step__(_input);
					}
					
					if (_mouse_on_comp) {
						capture_input();
					}
				
					if (!__is_on_focus__) return;
				
					//allow early outs with breaks;
					repeat (1) {
					
						#region escape
				
							if (keyboard_check_pressed(keys.escape))
							|| (!curt.multiline && keyboard_check_pressed(keys.enter))
							|| (!curt.shift_only_new_line && curt.no_wrap && keyboard_check_pressed(keys.enter))
							|| (curt.shift_only_new_line && keyboard_check_pressed(keys.enter) && !keyboard_check(keys.shift)) {
								var _text = __textbox_lines_to_text__(curt.lines);
								if (curt.adaptive_width) {
									_text = __textbox_close_lines__(_text, 0);
								}
								__is_on_focus__ = false;
								curt.focus = false;
								__trigger_event__(self.events.submit, _text);
								__trigger_event__(self.events.on_blur);
								break;
							}

						#endregion
					
						#region break line
	
							if (keyboard_check_pressed(keys.enter)) {
								curt.select = -1;
								__textbox_break_line__();
								
								if (__event_exists__(self.events.change)) {
									var _text = __textbox_lines_to_text__(curt.lines)
									__trigger_event__(self.events.change, _text);
								}
								
								break;
							}

						#endregion
					
						#region update cursor
	
							static _control_skip_word = function(_horz_input_vector) {
								static _word_breakers = "\n"+chr(9)+chr(34)+" ,.;:?!><#$%&'()*+-/=@[\]^`{|}~¡¢£¤¥¦§¨©«¬­®¯°±´¶·¸»¿×÷";
							
								//find our position on the line
								var _current_line = curt.current_line;
								var _cursor_pos_on_line = curt.cursor;
							
								//loop backwards to find the first thing which breaks a connected word like .,/
								var _current_line_text = curt.lines[_current_line];
								var _dir = _horz_input_vector;
								var _breaker_pos = (_dir > 0) ? _cursor_pos_on_line+_dir : _cursor_pos_on_line;
								var _prev_char;
								var _char = (_breaker_pos < 0 ) ? "\n" : string_char_at(_current_line_text, _breaker_pos);
								var _loop = (_dir) ? string_length(curt.lines[_current_line])-_cursor_pos_on_line : _cursor_pos_on_line;
							
								//skip to the next word breaker, this will skip double spaces
								repeat(_loop) {
									_prev_char = _char;
									_char = (_breaker_pos < 0 ) ? "\n" : string_char_at(_current_line_text, _breaker_pos);
								
									_horz_input_vector = _breaker_pos - _cursor_pos_on_line;
								
									if (_breaker_pos == 0) {
										return _horz_input_vector-1;
									}
								
								
									if (_dir > 0) {
										if (string_pos(_prev_char, _word_breakers))
										&& (!string_pos(_char, _word_breakers)) {
											return _horz_input_vector-1;
										}
									}
									else {
										if (!string_pos(_prev_char, _word_breakers))
										&& (string_pos(_char, _word_breakers)) {
											return _horz_input_vector;
										}
									}
								
								_breaker_pos += _dir;}//end repeat loop
							
							
								return _horz_input_vector+_dir;
							}
						
							//the initial press
							var _horz_input_vector = keyboard_check_pressed(keys.right) - keyboard_check_pressed(keys.left);
							if (_horz_input_vector != 0) {
								if (keyboard_check(keys.control)) {
									_horz_input_vector = _control_skip_word(_horz_input_vector)
								}
							
								curt.button_repeat = 40;
								__textbox_update_cursor__(_horz_input_vector, keyboard_check(keys.shift), false);
								break;
							}
						
							//the held press
							_horz_input_vector = keyboard_check(keys.right) - keyboard_check(keys.left);
							if (_horz_input_vector != 0) {
							
								curt.button_repeat --;
								if (curt.button_repeat < 0) {
									if (keyboard_check(keys.control)) {
										_horz_input_vector = _control_skip_word(_horz_input_vector)
									}
									__textbox_update_cursor__(_horz_input_vector, keyboard_check(keys.shift), false);
									curt.button_repeat = 3;
								}
								break;
							}
						
						
						
							var _vert_input_vector = keyboard_check_pressed(keys.down) - keyboard_check_pressed(keys.up);
						
							#region Top Bottom Lines
							
								//full left if on top line
								if (_vert_input_vector < 0)
								&& (curt.current_line == 0) {
									if (keyboard_check(keys.shift)) {
										if (curt.select == -1) {
											curt.select_line = curt.current_line;
											curt.select = curt.cursor;
										}
									}
									else {
										curt.select = -1;
									}
									set_cursor_x_pos(0);
									break;
								}
							
								//full right if on bottom line
								if (_vert_input_vector > 0)
								&& (curt.current_line == curt.length-1) {
									if (keyboard_check(keys.shift)) {
										if (curt.select == -1) {
											curt.select_line = curt.current_line;
											curt.select = curt.cursor;
										}
									}
									else {
										curt.select = -1;
									}
									set_cursor_x_pos(string_length(curt.lines[curt.current_line]));
									break;
								}
							
							#endregion
						
							if (curt.multiline)
							&& (curt.length != 1) {
							
								if (_vert_input_vector != 0) {
									__textbox_update_cursor__(_vert_input_vector, keyboard_check(keys.shift), true);
								
									if (keyboard_check(keys.control)) {
										//control + arrow scrolling
										// Update y-offset.
										var _line_height = draw.line_height;
										var _y_off = -scroll.y_off + _line_height * _vert_input_vector;
										var _max_height = curt.length * _line_height - get_coverage_height();
									
										_y_off = (_max_height < 0) ? 0 : clamp(_y_off, 0, _max_height)
									
										set_vert_scroll(-_y_off);
									
										draw.refresh_surf = true;
									}
								
									curt.button_repeat --;
									if (curt.button_repeat < 0) {
										__textbox_update_cursor__(_vert_input_vector, keyboard_check(keys.shift), true);
										curt.button_repeat = 3;
									}
									break;
								}
							
							}
							else { //full left or right if only one line exists.
								if (_vert_input_vector < 0) {
									set_cursor_x_pos(0);
									break;
								}
								else if (_vert_input_vector > 0) {
									set_cursor_x_pos(string_length(curt.lines[curt.current_line]));
									break;
								}
							}
	
						#endregion
					
						#region delete string
					
							var _delete = keyboard_check_pressed(keys.delete_key);
							if (keyboard_check_pressed(keys.backspace) || _delete) {
								curt.button_repeat = 40;
								__textbox_delete_string__(_delete);
								
								if (__event_exists__(self.events.change)) {
									var _text = __textbox_lines_to_text__(curt.lines)
									__trigger_event__(self.events.change, _text);
								}
							}
	
							_delete = keyboard_check(keys.delete_key);
							if (keyboard_check(keys.backspace) || _delete) {
								curt.button_repeat --;
								if (curt.button_repeat < 0) {
									__textbox_delete_string__(_delete);
									curt.button_repeat = 3;
									
									if (__event_exists__(self.events.change)) {
										var _text = __textbox_lines_to_text__(curt.lines)
										__trigger_event__(self.events.change, _text);
									}
								}
								break;
							}

						#endregion
					
						#region edit string
	
							if (keyboard_check(keys.control)) {
		
								// Keyboard repeat stuff
								if(keys.last_key != undefined) {
									if(keyboard_check(keys.last_key)) {
										keys.last_key_time += 1;
									
										if (keys.last_key_time > game_get_speed(gamespeed_fps)/3)
										&& (keys.last_key_time % floor(game_get_speed(gamespeed_fps)/30) == 0) { // simulate another keypress to do key repeat
											keyboard_key_release(keys.last_key);
											keyboard_key_press(keys.last_key);
										}
									}
									else {
										keys.last_key_time = 0;	
										keys.last_key = undefined;
										keyboard_string = "";
									}
								}
		
								// Select all string.
								if (keyboard_check(keys.a)) {
									if (keyboard_check_pressed(keys.a)) {
										var _line_last = curt.length - 1;
										var _line_last_length = string_length(curt.lines[_line_last]);
										if (_line_last < 1 && _line_last_length < 1) break;
										curt.select_line = 0;
										curt.select = 0;
										set_cursor_y_pos(_line_last);
										set_cursor_x_pos(_line_last_length);
									}
							
									//html5 support
									keyboard_string = "";
									
									keys.last_key = keys.a;
									
									break;
								}
		
								// Copy string.
								if (keyboard_check(keys.c)) {
									if (keyboard_check_pressed(keys.c)) {
										var _text = copy_function();
										if (os_browser == browser_not_a_browser) {
											clipboard_set_text(_text);
										}
										else {
											js_clipboard_set_text(_text);
										}
									}
			
									//html5 support
									keyboard_string = "";
									
									keys.last_key = keys.c;
									
									break;
								}
		
								// Cut string.
								if (keyboard_check(keys.x)) {
									if (keyboard_check_pressed(keys.x)) {
										var _text = copy_function();
										if (os_browser == browser_not_a_browser) {
											clipboard_set_text(_text);
										}
										else {
											js_clipboard_set_text(_text);
										}
							
										__textbox_delete_string__(false);
										__update_scroll__();
									}
									
									//html5 support
									keyboard_string = "";
									
									keys.last_key = keys.x;
									
									if (__event_exists__(self.events.change)) {
										var _text = __textbox_lines_to_text__(curt.lines)
										__trigger_event__(self.events.change, _text);
									}
									
									break;
								}
		
								// Paste string.
								if (keyboard_check(keys.v)) {
									if (keyboard_check_pressed(keys.v)) {
										var _pasted_text = paste_function()
										if (_pasted_text != "") __textbox_insert_string__(_pasted_text);
									}
			
									//html5 support
									keyboard_string = "";
									
									keys.last_key = keys.v;
									
									if (__event_exists__(self.events.change)) {
										var _text = __textbox_lines_to_text__(curt.lines)
										__trigger_event__(self.events.change, _text);
									}
									
									break;
								}
		
								// Undo.
								if (keyboard_check(keys.z)) {
									if (keyboard_check_pressed(keys.z)) {
										__textbox_records_set__(-1);
										__update_scroll__();
									}
			
									//html5 support
									keyboard_string = "";
									
									keys.last_key = keys.z;
									
									if (__event_exists__(self.events.change)) {
										var _text = __textbox_lines_to_text__(curt.lines)
										__trigger_event__(self.events.change, _text);
									}
									
									break;
								}
		
								// Redo.
								if (keyboard_check(keys.y)) {
									if (keyboard_check_pressed(keys.y)) {
										__textbox_records_set__(1);
										__update_scroll__();
									}
			
									//html5 support
									keyboard_string = "";
									
									keys.last_key = keys.y;
									
									if (__event_exists__(self.events.change)) {
										var _text = __textbox_lines_to_text__(curt.lines)
										__trigger_event__(self.events.change, _text);
									}
									
									break;
								}
		
							}
	
						#endregion
					
						#region others
	
							// Go to the beginning.
							if (keyboard_check_pressed(keys.home)) {
								if (keyboard_check(keys.shift)) {
									if (curt.select == -1) {
										curt.select_line = curt.current_line;
										curt.select = curt.cursor;
									}
								}
								else {
									curt.select = -1;
								}
								if (keyboard_check(keys.control)) {
									set_cursor_y_pos(0);
								}
								set_cursor_x_pos(0);
								break;
							}
			
							// Go to the end.
							if (keyboard_check_pressed(keys.end_key)) {
								if (keyboard_check(keys.shift)) {
									if (curt.select == -1) {
										curt.select_line = curt.current_line;
										curt.select = curt.cursor;
									}
								}
								else {
									curt.select = -1;
								}
								if (keyboard_check(keys.control)) {
									set_cursor_y_pos(curt.length - 1);
								}
								set_cursor_x_pos(string_length(curt.lines[curt.current_line]));
								break;
							}
	
						#endregion
					
						#region get string
					
							var _keyboard_string = keyboard_string;
							if (_keyboard_string != "") {
								keyboard_string = "";
					
								__textbox_insert_string__(_keyboard_string);
								
								if (__event_exists__(self.events.change)) {
									var _text = __textbox_lines_to_text__(curt.lines)
									__trigger_event__(self.events.change, _text);
								}
								
								break;
							}
	
						#endregion
					
					}
				
				}
				
				static __draw_gui__ = function(_input) { static __run_once__ = log(["__draw_gui__", __draw_gui__]);
				
					draw_gui(_input);
				
					draw_sprite_stretched_ext(
							s9GUIPixel,
							0,
							x+region.left,
							y+region.top,
							region.get_width(),
							region.get_height(),
							draw.text_background_color,
							draw.text_background_alpha
					);
				
				
					// Updates surfaces. (Surfaces are needed to allow for custom text selection coloring, and to only show certain parts of the whole text when it's too long. Might in some cases be faster as well.)
					//var _texfilter_previous = gpu_get_texfilter();
					//gpu_set_texfilter(true);
					
					__shader_set__();
					
					var _start_x = x;
					var _start_y = y;
					var _draw_width = get_coverage_width();
					var _draw_height = get_coverage_height();
				
					draw_set_color(draw.font_color);
					draw_set_alpha(1);
				
					//pre draw cached surf
					if (__using_cached_drawing__)
					&& (draw.refresh_surf) {
						//set the surface
						__surface_set_target__();
					}
				
					//draw the component it's self, either on a cached surf or directly.
					if (!__using_cached_drawing__) 
					|| (draw.refresh_surf) {
						var _draw_x = (__using_cached_drawing__) ? 0 : x;
						var _draw_y = (__using_cached_drawing__) ? 0 : y;
					
						var _font_color = draw.font_color;
						var _x_off = -scroll.x_off;
						var _y_off = -scroll.y_off;
						var _line_height = draw.line_height;
						var _arr_lines = __array_clone__(curt.lines);
						var _line_count = curt.length;
						var _current_line = curt.current_line;
						var _cursor_update = curt.cursor;
						var _center_y = (curt.multiline) ? 0 : ceil((draw.line_height-get_coverage_height())/2);
					
						draw_set_font(draw.font);
						draw_set_color(draw.font_color);
						draw_set_alpha(1);
						draw_set_valign(fa_top);
						draw_set_halign(fa_left);
					
						#region draw text
							
							if (_line_count == 1 && _arr_lines[0] == "") {
								//draw the place holder text
								draw_set_alpha(0.6);
								draw_text(_draw_x-_x_off, _draw_y-_center_y, curt.placeholder);
								draw_set_alpha(1);
							}
							else {
								var _select_line_start, _select_line_end, _cursor_start, _cursor_end;
							
								var _select_line = curt.select_line;
								var _select = curt.select;
								var _displayed_lines_index = floor(-scroll.y_off / draw.line_height);
								var _displayed_lines_length = min(_line_count - _displayed_lines_index, ceil(get_coverage_height() / draw.line_height));
							
								if (_select > -1) {
									_select_line_start = _select_line;
									_select_line_end = _current_line;
									_cursor_start = _select;
									_cursor_end = _cursor_update;
								
									if (_select_line > _current_line) {
										_select_line_start = _current_line;
										_select_line_end = _select_line;
										_cursor_start = _cursor_update;
										_cursor_end = _select;
									}
								}
							
								//prep the drawing of text, this wont effect the drawing of the selection box.
								draw_set_color(draw.font_color);
							
								//an optimizer for empty line selection and /n selection
								// this is used any time the line's string is empty, or when wrapping the selection to the next line
								var _selection_end_cap_width = string_width(" ");
							
								var _selection_x1 = 0;
								var _selection_x2 = 0;
								var _text, _derivative_y;
							
								repeat (_displayed_lines_length) {
									_text = _arr_lines[_displayed_lines_index];
									_derivative_y = _displayed_lines_index * _line_height - _y_off - _center_y;
								
									if (_select > -1)
									&& (_displayed_lines_index >= _select_line_start)
									&& (_displayed_lines_index <= _select_line_end) {
									
										if (_select_line_start == _displayed_lines_index)
										&& (_select_line_end == _displayed_lines_index) {
											_selection_x1 = string_width(string_copy(_text, 1, _cursor_start)) - _x_off;
											_selection_x2 = string_width(string_copy(_text, 1, _cursor_end)) - _x_off
										}
										else if (_select_line_start == _displayed_lines_index) {
											_selection_x1 = string_width(string_copy(_text, 1, _cursor_start)) - _x_off;
											_selection_x2 = string_width(_text) - _x_off
											if (_select_line > _displayed_lines_index) {
												_selection_x2 += _selection_end_cap_width
											}
										}
										else if (_select_line_end == _displayed_lines_index) {
											_selection_x1 = 0;
											_selection_x2 = string_width(string_copy(_text, 1, _cursor_end)) - _x_off;
											if (_select_line > _displayed_lines_index) {
												_selection_x2 += _selection_end_cap_width
											}
										}
										else {
											_selection_x1 = 0;
											_selection_x2 = string_width(_text) - _x_off + _selection_end_cap_width;
										}
									
										//draw the selection box
										draw_sprite_stretched_ext(
												s9GUIPixel,
												0,
												_draw_x+min(_selection_x1, _selection_x2),
												_draw_y+_derivative_y,
												abs(_selection_x2-_selection_x1),
												_line_height,
												draw.highlight_region_color,
												1
										);
									
									}
									
									draw_text(_draw_x-_x_off, _draw_y+_derivative_y, _text);
								
									_displayed_lines_index+=1;
								}
							}
							
						#endregion
					
						#region draw cursor
						
							if (__is_on_focus__)
							&& (draw.display_cursor > 0)
							&& (is_enabled) {
								var _cursor_xoff = (__using_cached_drawing__) ? -x : 0
								var _cursor_yoff = (__using_cached_drawing__) ? -y : 0
								var _y_offset = -(_center_y+_center_y);
								
								draw_sprite_stretched_ext(
										s9GUIPixel,
										0,
										_cursor_xoff + get_cursor_x_pos(),
										_cursor_yoff + get_cursor_y_pos() + _y_offset,
										get_cursor_width(),
										get_cursor_height(),
										draw.highlight_region_color,
										1
								);
							
							}
						
						#endregion
					
					}
				
					//post draw cached surf
					if (__using_cached_drawing__) {
						if (draw.refresh_surf) {
							draw.refresh_surf = false;
							__surface_reset_target__();
						}
					
						__draw_component_surface__();
					}
					
					__shader_reset__();
					
					//if (!_texfilter_previous) {
					//	gpu_set_texfilter(_texfilter_previous);
					//}
					
					if (curt.multiline) {
						__SUPER__.__draw_gui__(_input);
					}
					
					if (should_draw_debug) {
						draw_debug();
					}
				}
				
			#endregion
			
			#region helper functions
				
				#region Allowing Char
					
					#region jsDoc
					/// @func    __build_allowed_char__()
					/// @desc    Returns a struct of allowed charactors from the supplied font.
					/// @self    GUICompTextbox
					/// @param   {Asset.GMFont} font : The font to build the allowed charactor list.
					/// @returns {Struct} Allowed Charactors Struct
					#endregion
					static __build_allowed_char__ = function(_font) { static __run_once__ = log(["__build_allowed_char__", __build_allowed_char__]);
						var _info = font_get_info(_font);
						var _struct_keys = variable_struct_get_names(_info.glyphs)
						var _struct = {}
						
						var _i=0; repeat(array_length(_struct_keys)) {
							_struct[$ _struct_keys[_i]] = true
						_i+=1;}//end repeat loop
						
						return _struct;
					}
					
					#region jsDoc
					/// @func    __string_keep_allowed_char__()
					/// @desc    Removes all charactor from a string except for the specified struct of allowed characters. This acts as whitelisting charactors
					/// @self    GUICompTextbox
					/// @param   {String} text : The string to parse
					/// @param   {Struct} allowed_char : The font to build the allowed charactor list.
					/// @returns {String}
					#endregion
					static __string_keep_allowed_char__ = function(_text, _allowed_char) {
						var _buff = buffer_create(1, buffer_grow, 1);
						var _struct = {
							allowed_char : _allowed_char,
							buff : _buff
						};
						
						string_foreach(_text, method(_struct, function(_char) {
							if (variable_struct_exists(allowed_char, _char))
							|| (_char == "\n") {
								buffer_write(buff, buffer_text, _char);
							}
						}));
					
						buffer_seek(_buff, buffer_seek_start, 0)
						var _new_text = buffer_read(_buff, buffer_string)
					
						buffer_delete(_buff)
						
						return _new_text;
					}
					
				#endregion
				
				#region Format wrapping
					
					#region jsDoc
					/// @func    __textbox_format_nowrap__()
					/// @desc    Removes all line break, and tab charactor from a string.
					/// @self    GUICompTextbox
					/// @param   {String} str : The string to edit
					/// @returns {String}
					#endregion
					static __textbox_format_nowrap__ = function(_str) { static __run_once__ = log(["__textbox_format_nowrap__", __textbox_format_nowrap__]);
						var _return = string_replace_all(_str, "\n", "");
						_return = string_replace_all(_return, "\r", "");
						_return = string_replace_all(_return, "\t", "");
						
						return _return;

					}
					
					#region jsDoc
					/// @func    __textbox_format_newline__()
					/// @desc    Removes all tab charactors from a string.
					/// @self    GUICompTextbox
					/// @param   {String} str : The string to edit
					/// @returns {String}
					#endregion
					static __textbox_format_newline__ = function(_str) { static __run_once__ = log(["__textbox_format_newline__", __textbox_format_newline__]);
						var _return = string_replace_all(_str, "\r", "");
						_return = string_replace_all(_return, "\t", "");
						
						return _return;

					}
					
				#endregion
				
				#region Converters
					
					#region jsDoc
					/// @func    __textbox_lines_to_text__()
					/// @desc    Converts the Text array into a single string. This does not account for addaptive width! See `__textbox_return__()` if you wish for adaptive width to be accounted.
					/// @self    GUICompTextbox
					/// @param   {Array<String>} arr : The array of strings
					/// @returns {String}
					#endregion
					static __textbox_lines_to_text__ = function(_arr) { static __run_once__ = log(["__textbox_lines_to_text__", __textbox_lines_to_text__]);
						
						var _str = _arr[0];
						var _i = 1;
						var _length = array_length(_arr) - 1;

						repeat (_length) {
							_str += "\n" + _arr[_i];
							_i +=1;
						}
	
						return _str;

					}
					
					#region jsDoc
					/// @func    __textbox_text_to_lines__()
					/// @desc    Converts the a string into the Text array format.
					/// @self    GUICompTextbox
					/// @param   {String} str : The string to convert to an array
					/// @returns {String}
					#endregion
					static __textbox_text_to_lines__ = function(_str) { static __run_once__ = log(["__textbox_text_to_lines__", __textbox_text_to_lines__]);
					
						var _total_line_breaks = string_count("\n", _str)
						var _arr = array_create(_total_line_breaks+1, 0);
						var _text = _str;
						var _pos;
						var _i = 0; repeat(_total_line_breaks) {
						    _pos = string_pos("\n", _text);
								_arr[_i] = string_copy(_text, 1, _pos - 1);
						    _text = string_delete(_text, 1, _pos);
						_i+=1;}//end repeat loop

						_arr[_i] = _text;
						
						return _arr;

					}
					
					#region jsDoc
					/// @func    __textbox_return__()
					/// @desc    Returns the textboxes Text as a string. This will also adjust the linebreaks accordingly with the use of adaptive width
					/// @self    GUICompTextbox
					/// @returns {String}
					#endregion
					static __textbox_return__ = function() { static __run_once__ = log(["__textbox_return__", __textbox_return__]);
						var _text = "";
						
						_text = __textbox_lines_to_text__(curt.lines);
						if (curt.adaptive_width) {
							_text = __textbox_close_lines__(_text, 0);
						}
						
						return _text;
						
					}
					
				#endregion
				
				
				#region Undo / Redo
					
					static __record__ = function(_lines_arr, _line, _cursor, _break_points_arr) constructor {
					
						lines = _lines_arr;
						line = _line;
						cursor = _cursor;
						width_breakpoints = _break_points_arr;
					}
					
					/// @param current_line
					/// @param cursor
					static __textbox_records_add__ = function(_line, _cursor) { static __run_once__ = log(["__textbox_records_add__", __textbox_records_add__]);
						var _cursor_records = curt.records_cursor + 1;

						if (_cursor_records < array_length(curt.historic_records)) {
							array_resize(curt.historic_records, _cursor_records);
						}
					
						var _record = new __record__(
								__array_clone__(curt.lines), //NOTE: this may not be needed. not needed?
								_line,
								_cursor,
								__array_clone__(curt.width_breakpoints)  //this is done to support array copy on write (on/off)
						)
					
						//push the new recrd to the record array
						array_push(curt.historic_records, _record);
						
						if (array_length(curt.historic_records) > curt.records_upper_limit) {
							var _old_record = curt.historic_records[0];
							array_delete(curt.historic_records, 0, 1);
							delete _old_record;
						
							_cursor_records -= 1;
						}
						
						curt.records_cursor = _cursor_records;
					}
					
					/// @param current_line
					/// @param cursor
					static __textbox_records_rec__ = function(_line, _cursor) { static __run_once__ = log(["__textbox_records_rec__", __textbox_records_rec__]);
						
						var _record = curt.historic_records[curt.records_cursor];
						
						_record.line   = _line;
						_record.cursor = _cursor;
						
						curt.historic_records[curt.records_cursor] = _record;
					}
					
					/// @param change
					static __textbox_records_set__ = function(_change) { static __run_once__ = log(["__textbox_records_set__", __textbox_records_set__]);
						
						var _historic_records = curt.historic_records;
						var _cursor_records = curt.records_cursor + _change;
					
						if (_cursor_records < 0)
						|| (_cursor_records >= array_length(_historic_records)) {
							return;
						}
					
						var _record = _historic_records[_cursor_records];
					
						curt.lines = __array_clone__(_record.lines);
						curt.width_breakpoints = __array_clone__(_record.width_breakpoints);
						set_cursor_y_pos(_record.line);
						set_cursor_x_pos(_record.cursor);
						
						curt.records_cursor = _cursor_records;
						curt.select = -1;
						curt.length = array_length(curt.lines);
						
					}
					
				#endregion
				
				static __update_scroll__ = function() { static __run_once__ = log(["__update_scroll__", __update_scroll__]);
					
					var _canvas_width, _canvas_height, _draw_width, _draw_height;
					
					var _current_line = curt.current_line;
					var _text = curt.lines[_current_line];
					var _cursor_pos = curt.cursor;
					
					//Update is the horz scroll bar is visible before we move the cursors x/y
					if (!curt.adaptive_width) {
						_draw_width = get_coverage_width();
						_canvas_width = get_canvas_width();
						if (_canvas_width <= _draw_width) {
							set_scrollbar_hidden(true, undefined);
							set_horz_scroll(0);
						}
						else {
							set_scrollbar_hidden(false, undefined);
							set_canvas_size(_canvas_width, undefined);
						}
					}
					
					//Update is the vert scroll bar is visible before we move the cursors x/y
					if (curt.multiline) {
						_draw_height = get_coverage_height();
						_canvas_height = get_canvas_height();
						if (_canvas_height <= _draw_height) {
							set_scrollbar_hidden(undefined, true);
							set_vert_scroll(0);
						}
						else {
							set_scrollbar_hidden(undefined, false);
							set_canvas_size(undefined, _canvas_height);
						}
					}
						
					// Update y-offset.
					if (curt.multiline) {
						if (_canvas_height > _draw_height) {
							var _line_height = draw.line_height;
							var _cursor_dist = _current_line * _line_height + _line_height;
							var _bounds_top = -scroll.y_off
							var _bounds_bottom = _bounds_top + _draw_height
							
							if ((_cursor_dist-_line_height) < _bounds_top) {
								set_vert_scroll(-(_cursor_dist-_line_height));
							}
							else if (_cursor_dist > _bounds_bottom) {
								set_vert_scroll(-(_cursor_dist - _draw_height));
							}
							
						}
						
					}
					
					// Update x-offset.
					if (!curt.adaptive_width) {
						if (_canvas_width > _draw_width) {
							var _cursor_dist = string_width(string_copy(_text, 1, _cursor_pos));
							var _bounds_left = -scroll.x_off
							var _bounds_right = _bounds_left + _draw_width
							
							if (_cursor_dist < _bounds_left) {
								set_horz_scroll(-_cursor_dist);
							}
							else if (_cursor_dist > _bounds_right) {
								set_horz_scroll(-(_cursor_dist - _draw_width));
							}
							
						}
						
					}
					
				}
				
				
				static __textbox_max_length__ = function() { static __run_once__ = log(["__textbox_max_length__", __textbox_max_length__]);
					var _max_length = curt.max_length;
					if (should_safety_check) {
						if (_max_length < 0) {
							show_error(string("The \"max_length\" for the character count is less than 0 : {0}\nPlease use \"set_max_length()\" with a positive integer.", _max_length), true);
						}
					}
					if ((_max_length != infinity)) {
		
						var _lines = __array_clone__(curt.lines);
						var _current_text = __textbox_lines_to_text__(_lines);
		
						if (string_length(_current_text) - string_count("\n", _current_text) > _max_length) {
							var _width_breakpoints = curt.width_breakpoints;
							var _current_line = curt.current_line;
							var _i = 0;
							var _length = curt.length;
							
							repeat (_length) {
								_current_text = _lines[_i];
								var _str_length = string_length(_current_text);
								if (_str_length >= _max_length) {
									array_delete(_lines, _i + 1, _length - _i - 1);
									array_delete(_width_breakpoints, _i + 1, _length - _i - 1);
									_lines[_i] = string_copy(_current_text, 1, _max_length);
									break;
								}
								else {
									_max_length -= _str_length;
								}
								_i +=1;
							}
							if (_current_line > _i) {
								set_cursor_y_pos(_i);
								set_cursor_x_pos(_max_length);
							}
							else if (_current_line == _i && curt.cursor > _max_length) {
								set_cursor_x_pos(_max_length);
							}
							
							curt.length = _i + 1;
						}
						
						
						curt.lines = _lines;
					}

				}
				
				/// @param string
				static __textbox_insert_string__ = function(_str) { static __run_once__ = log(["__textbox_insert_string__", __textbox_insert_string__]);
					
					_str = __string_keep_allowed_char__(_str, __allowed_char__)
					
					
					if (curt.select > -1) __textbox_delete_string__(false);
		
					var _current_line = curt.current_line;
					var _cursor = curt.cursor;
					var _adaptive_width = curt.adaptive_width;
					var _no_wrap = (curt.no_wrap) ? __textbox_format_nowrap__(_str) : __textbox_format_newline__(_str);
					var _line_length = string_length(_no_wrap);
					
					if (curt.no_wrap)
					&& (string_pos("\n", _no_wrap) < 1) {
						var _line = curt.lines[_current_line];
						var _edited_line = string_insert(_no_wrap, _line, _cursor + 1);
						
						curt.lines[_current_line] = _edited_line;
			
						curt.cursor += _line_length;
						if (_adaptive_width) __textbox_break_lines__(_current_line, 1, _line_length + _cursor, 0);
		
					}
					else {
			
						var _current_line_offset = _current_line;
						var _current_text = curt.lines[_current_line_offset];
						var _current_text_length = string_length(_current_text);
						var _arr_additional_lines = __textbox_text_to_lines__(_no_wrap);
						var _additional_lines_count = array_length(_arr_additional_lines) - 1;
						var _line_index = _additional_lines_count;
						
						_current_line = _current_line_offset + _additional_lines_count;
						
						repeat (_additional_lines_count) {
							array_insert(curt.lines, _current_line_offset + 1, _arr_additional_lines[_line_index]);
							array_insert(curt.width_breakpoints, _current_line_offset + 1, true);
							_line_index --;
						}
			
						if (_current_text_length == 0) {
							_cursor = string_length(_arr_additional_lines[0]);
							curt.lines[_current_line_offset] = _current_text + _arr_additional_lines[0];
							set_cursor_y_pos(_current_line);
							curt.cursor += _cursor;
						}
						else {
							var _new_last_line_text = _arr_additional_lines[_additional_lines_count];
							curt.lines[_current_line] = _new_last_line_text + string_copy(_current_text, _cursor + 1, _current_text_length - _cursor);
							_current_text = string_copy(_current_text, 1, _cursor);
							_cursor = string_length(_new_last_line_text);
				
							curt.lines[_current_line_offset] = _current_text + curt.lines[_current_line];
							set_cursor_y_pos(_current_line);
							curt.cursor += _cursor;
						}
			
			
						if (_adaptive_width) {
							var _section_length = _line_length - string_count("\n", _no_wrap) + string_length(_current_text);
							var _number_of_new_lines = 0;
							var _current_newline_char = string_copy(_no_wrap, _line_length, 1);
							
							while (_line_length > 1 && _current_newline_char == "\n") {
								_line_length -= 1;
								_number_of_new_lines += 1;
								_current_newline_char = string_copy(_no_wrap, _line_length, 1);
							}
							__textbox_break_lines__(_current_line_offset, _additional_lines_count + 1, _section_length, _number_of_new_lines);
						}
		
					}
	
					curt.length = array_length(curt.lines);
					__textbox_max_length__();
					
					__textbox_records_add__(curt.current_line, curt.cursor);
					__update_scroll__();
				}
				
				/// @param delete_key?
				static __textbox_delete_string__ = function(_delete_key) { static __run_once__ = log(["__textbox_delete_string__", __textbox_delete_string__]);
					var _current_line = curt.current_line;
					var _cursor = curt.cursor;
					var _select_line = curt.select_line;
					var _select_cursor = curt.select;
					
					if (_select_cursor > -1) {
						if (_select_line == _current_line) {
							var _count = abs(_cursor - _select_cursor);
							_cursor = min(_cursor, _select_cursor);
							curt.lines[_current_line] = string_delete(curt.lines[_current_line], _cursor + 1, _count);
						}
						else {
							var _select_line_start = min(_current_line, _select_line);
							var _select_char_start = _select_cursor;
							var _select_char_end = _cursor;
							
							if (_select_line > _current_line) {
								_select_char_start = _cursor;
								_select_char_end = _select_cursor;
							}
							
							var _select_line_length = abs(_current_line - _select_line);
							var _current_text = string_delete(curt.lines[_select_line_start + _select_line_length], 1, _select_char_end);
							
							curt.lines[_select_line_start] = string_copy(curt.lines[_select_line_start], 1, _select_char_start) + _current_text;
							array_delete(curt.lines, _select_line_start + 1, _select_line_length);
							array_delete(curt.width_breakpoints, _select_line_start + 1, _select_line_length);
							_current_line = _select_line_start;
							_cursor = _select_char_start;
						}
						curt.select = -1;
					}
					else {
						var _current_text = curt.lines[_current_line];
						if (_delete_key) {
							if (_cursor == string_length(_current_text)) {
								if (_current_line == curt.length - 1) return;
								curt.lines[_current_line] = _current_text + curt.lines[_current_line + 1];
								array_delete(curt.lines, _current_line + 1, 1);
								array_delete(curt.width_breakpoints, _current_line + 1, 1);
							}
							else {
								curt.lines[_current_line] = string_delete(_current_text, _cursor + 1, 1);
							}
						}
						else {
							if (_cursor == 0) {
								if (_current_line == 0) return;
								array_delete(curt.lines, _current_line, 1);
								array_delete(curt.width_breakpoints, _current_line, 1);
								_current_line -= 1;
								var _next_text = curt.lines[_current_line];
								_cursor = string_length(_next_text);
								curt.lines[_current_line] = _next_text + _current_text;
							}
							else {
								curt.lines[_current_line] = string_delete(_current_text, _cursor, 1);
								_cursor -= 1;
							}
						}
					}
					
					set_cursor_y_pos(_current_line);
					set_cursor_x_pos(_cursor);
					curt.length = array_length(curt.lines);
					if (curt.adaptive_width) __textbox_break_lines__(_current_line, 1);
					
					__update_scroll__();
					
					__textbox_records_add__(_current_line, _cursor);
				}
				
				static __textbox_copy_string__ = function() { static __run_once__ = log(["__textbox_copy_string__", __textbox_copy_string__]);
	
					var _select = curt.select;
					if (_select < 0) return;
	
					var _lines = __array_clone__(curt.lines);
					var _current_line = curt.current_line;
					var _cursor = curt.cursor;
					var _select_line = curt.select_line;
					var _text = "";
	
					if (_current_line == _select_line) {
						_text = string_copy(_lines[_current_line], min(_cursor, _select) + 1, abs(_cursor - _select));
					}
					else {
						var _arr = [];
						var _select_start = min(_current_line, _select_line);
						var _char_start = _select;
						var _char_end = _cursor;
						if (_select_line > _current_line) {
							_char_start = _cursor;
							_char_end = _select;
						}
						var _line_length = abs(_current_line - _select_line);
						array_copy(_arr, 0, _lines, _select_start, _line_length + 1);
						_arr[0] = string_delete(_arr[0], 1, _char_start);
						_arr[_line_length] = string_copy(_arr[_line_length], 1, _char_end);		
						_text = __textbox_lines_to_text__(_arr);
						if (curt.adaptive_width) _text = __textbox_close_lines__(_text, _select_start);
					}
	
					return _text;
				}
				
				static __textbox_paste_string__ = function() { static __run_once__ = log(["__textbox_paste_string__", __textbox_paste_string__]);
					var _pasted_string = "";
					
					if (os_browser == browser_not_a_browser) {
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
				
				static __textbox_break_line__ = function() { static __run_once__ = log(["__textbox_break_line__", __textbox_break_line__]);
					
					var _current_line = curt.current_line;
					var _text = curt.lines[_current_line];
					var _length = string_length(_text);
					var _cursor = curt.cursor;
					
					_current_line += 1;
					if (_cursor < _length) {
						var _begin = _cursor + 1;
						var _count = _length - _cursor;
						
						curt.lines[_current_line - 1] = string_delete(_text, _begin, _count);
						array_insert(curt.lines, _current_line, string_copy(_text, _begin, _count));
					}
					else {
						array_insert(curt.lines, _current_line, "");
					}
					
					array_insert(curt.width_breakpoints, _current_line, true);
					
					curt.length = array_length(curt.lines);
					if (curt.adaptive_width) __textbox_break_lines__(_current_line, 1);
					set_cursor_y_pos(_current_line);
					set_cursor_x_pos(0);
					
					__textbox_records_add__(_current_line, 0);
					
				}
				
				/// @param start_line
				/// @param count
				/// @param length
				/// @param \n_length
				static __textbox_break_lines__ = function(_start_line, _count, _length = 0, _nl_length = 0) { static __run_once__ = log(["__textbox_break_lines__", __textbox_break_lines__]);
					
					static _word_breakers = "\n"+chr(9)+chr(34)+" ,.;:?!><#$%&'()*+-/=@[\]^`{|}~¡¢£¤¥¦§¨©«¬­®¯°±´¶·¸»¿×÷";
					
					draw_set_font(draw.font);
					
					var _draw_width = get_coverage_width() - draw.scroll_width;
					//var _arr_lines = __array_clone__(curt.lines);
					var _arr_line_break_widths = curt.width_breakpoints;
					var _end_line = (_start_line+_count);
					var _breaker_pos = 0;
					var _char = "";
					
					while (_start_line < _end_line) {
						var _current_text = curt.lines[_start_line];
						var _current_width = string_width(_current_text);
						
						if (_current_width > _draw_width) {
							var _current_text_iterator = 0;
							var _current_text_length = string_length(_current_text);
							
							repeat (_current_text_length) {
								
								//find how far forward we can go before triggering a line break
								if (string_width(string_copy(_current_text, 1, _current_text_iterator+1)) > _draw_width) {
									
									//loop backwards to find the first thing which breaks a connected word like .,/
									_breaker_pos = _current_text_iterator;
									repeat(_current_text_iterator) {
										_char = string_char_at(_current_text, _breaker_pos)
										if (string_pos(_char, _word_breakers)) {
											_current_text_iterator = _breaker_pos;
											break;
										}
									_breaker_pos--;}//end repeat loop
									
									//apply the line
									array_insert(curt.lines, _start_line + 1, string_delete(_current_text, 1, _current_text_iterator - 1));
									array_insert(curt.width_breakpoints, _start_line + 1, false);
									curt.lines[_start_line] = string_copy(_current_text, 1, _current_text_iterator - 1);
									break;
								}
								_current_text_iterator +=1;
							}
							_end_line += 1;
						}
						else {
							
							var _new_line_index = _start_line + 1;
							if (_new_line_index < array_length(curt.width_breakpoints) && !curt.width_breakpoints[_new_line_index]) {
								var _next_text = curt.lines[_new_line_index];
								var _next_text_width = string_width(_next_text);
								
								if (_current_width + _next_text_width <= _draw_width) {
									curt.lines[_start_line] = _current_text + _next_text;
									array_delete(curt.lines, _new_line_index, 1);
									array_delete(curt.width_breakpoints, _new_line_index, 1);
									_end_line -= 1;
								}
								else {
									var _current_text_iterator = 1;
									var _current_text_length = string_length(_next_text);
									
									repeat (_current_text_length) {
										if (_current_width + string_width(string_copy(_next_text, 1, _current_text_iterator)) > _draw_width) {
											
											//loop backwards to find the first thing which breaks a connected word like .,/
											_breaker_pos = _current_text_iterator;
											repeat(_current_text_iterator) {
												_char = string_char_at(_next_text, _breaker_pos)
												if (string_pos(_char, _word_breakers)) {
													_current_text_iterator = _breaker_pos;
													break;
												}
											_breaker_pos--;}//end repeat loop
											
											//break the line
											curt.lines[_start_line] = _current_text + string_copy(_next_text, 1, _current_text_iterator - 1);
											curt.lines[_new_line_index] = string_delete(_next_text, 1, _current_text_iterator - 1);
											break;
										}
										_current_text_iterator +=1;
									}
									
									_end_line += 1;
								}
							}
						}
						if (_length > 0) {
							_current_text = curt.lines[_start_line];
							var _string_length = string_length(_current_text);
							if (_string_length >= _length) {
								set_cursor_y_pos(_start_line + _nl_length);
								
								if (_nl_length > 0) {
									set_cursor_x_pos(0);
								}
								else {
									set_cursor_x_pos(_length);
								}
								
								_length = 0;
							}
							else {
								_length -= _string_length;
							}
						}
						_start_line +=1;
					}
					
					curt.length = array_length(curt.lines);
					
				}
				
				/// @param string
				/// @param start_line
				static __textbox_close_lines__ = function(_string, _start_line) { static __run_once__ = log(["__textbox_close_lines__", __textbox_close_lines__]);
					var _breakpoints = curt.width_breakpoints;
					var _text = _string;
					var _copied_text = _string;
					var _new_line_pos = string_pos("\n", _copied_text);
					var _line_end_pos = _new_line_pos;
	
					_start_line = _start_line + 1;
					
					while (_new_line_pos > 0) {
						if (!_breakpoints[_start_line]) {
							_text = string_delete(_text, _line_end_pos, 1);
							_line_end_pos--;
						}
						_copied_text = string_delete(_copied_text, 1, _new_line_pos);
						_new_line_pos = string_pos("\n", _copied_text);
						_line_end_pos += _new_line_pos;
						_start_line+=1;
					}
	
					return _text;

				}
				
				/// @param change
				static __textbox_check_hinput__ = function(_change) { static __run_once__ = log(["__textbox_check_hinput__", __textbox_check_hinput__]);
					
					var _arr_lines = __array_clone__(curt.lines);
					var _current_line = curt.current_line;
					var _cursor_update = curt.cursor + _change;
					var _current_line_length = string_length(_arr_lines[_current_line]);
					
					if (_cursor_update < 0) {
						if (_current_line < 1) {
							_cursor_update = 0;
						}
						else {
							_current_line -= 1;
							_cursor_update = string_length(_arr_lines[_current_line]);
						}
					}
					else if (_cursor_update > _current_line_length) {
						if (_current_line == curt.length - 1) {
							_cursor_update = _current_line_length;
						}
						else {
							_current_line += 1;
							_cursor_update = 0;
						}
					}
					
					set_cursor_y_pos(_current_line);
					__textbox_records_rec__(_current_line, _cursor_update);
					return _cursor_update;
					
				}
				
				/// @param change
				static __textbox_check_vinput__ = function(_change) { static __run_once__ = log(["__textbox_check_vinput__", __textbox_check_vinput__]);
					
					var _current_line = curt.current_line;
					var _cursor_update = curt.cursor;
					var _next_line = clamp(_current_line + _change, 0, curt.length - 1);
					
					if (_next_line == _current_line) return _cursor_update;
					
					draw_set_font(draw.font);
					
					var _arr_lines = __array_clone__(curt.lines);
					var _current_width = string_width(string_copy(_arr_lines[_current_line], 1, _cursor_update));
					var _text = _arr_lines[_next_line];
					var _new_line_length = string_length(_text);
					
					if (_current_width >= string_width(_text)) {
						_cursor_update = _new_line_length;
					}
					else {
						_cursor_update = 0;
						repeat (_new_line_length) {
							var _remaining_width = _current_width - string_width(string_copy(_text, _cursor_update + 1, 1)) / 2;
							if (string_width(string_copy(_text, 1, _cursor_update)) >= _remaining_width) break;
							_cursor_update += 1;
						}
					}
					
					set_cursor_y_pos(_next_line);
					__textbox_records_rec__(_next_line, _cursor_update);
					return _cursor_update;
					
				}
				
				/// @param select?
				static __textbox_check_minput__ = function(_select) { static __run_once__ = log(["__textbox_check_minput__", __textbox_check_minput__]);
					var _select_line , _select_end;
					
					//cache the select line
					if (_select) {
						_select_line = curt.select_line;
						_select_end = curt.select;
						
						if (_select_end < 0) {
							_select_line = curt.current_line;
							_select_end = curt.cursor;
						}
					}
					
					//set the cursor
					var _mouse_x_gui = device_mouse_x_to_gui(0);
					var _mouse_y_gui = device_mouse_y_to_gui(0);
					set_cursor_gui_loc(_mouse_x_gui, _mouse_y_gui);
					
					//apply the select line
					if (_select) {
						if (curt.current_line == _select_line)
						&& (curt.cursor == _select_end) {
							_select_end = -1;
						}
						curt.select_line = _select_line;
						curt.select = _select_end;
					}
					
				}
				
				/// @param change
				/// @param select?
				/// @param vertical?
				static __textbox_update_cursor__ = function(_change, _shift, _vertical) { static __run_once__ = log(["__textbox_update_cursor__", __textbox_update_cursor__]);
					
					if (_shift) {
						var _current_line = curt.current_line;
						var _cursor = curt.cursor;
						var _select_line = curt.select_line;
						var _select = curt.select;
						
						if (_select < 0) {
							_select_line = _current_line;
							_select = _cursor;
						}
						
						_cursor = (_vertical) ? __textbox_check_vinput__(_change) : __textbox_check_hinput__(_change);
						
						if (curt.current_line == _select_line)
						&& (_cursor == _select) {
							_select = -1;
						}
						
						set_cursor_x_pos(_cursor);
						curt.select_line = _select_line;
						curt.select = _select;
					}
					else {
						if (curt.select > -1) {
							curt.select = -1;
							return;
						}
						
						if (_vertical) {
							//yes this should be x because the return says how much to move the cursor
							set_cursor_x_pos(__textbox_check_vinput__(_change));
						}
						else {
							set_cursor_x_pos(__textbox_check_hinput__(_change));
						}
						
					}
					
				}
				
				static __array_clone__ = function(_arr) { static __run_once__ = log(["__array_clone__", __array_clone__]);
					var _new_arr = array_create(0,0);
					array_copy(_new_arr, 0, _arr, 0, array_length(_arr));
					return _new_arr;
				}
				
			#endregion
			
		#endregion
		
	#endregion
	
	copy_function  = __textbox_copy_string__;
	paste_function = __textbox_paste_string__;
	__allowed_char__ = __build_allowed_char__(fGUIDefault);
	set_text("");
}


