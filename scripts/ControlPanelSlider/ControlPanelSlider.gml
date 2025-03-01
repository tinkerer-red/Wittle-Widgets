function ControlPanelSlider(_label="<Missing Label>", _value, _min, _max, _func) : GUICompController() constructor {
	
	#region Public
		
		#region Builder functions
			
			static set_size = function(_left, _top, _right, _bottom) {
				var _info = sprite_get_nineslice(__button__.sprite_index)
				_top    = 0;
				_bottom = max(
					font_get_info(__CP_FONT).size + _info.top + _info.bottom,
					__button_dec__.region.get_height() + _info.top + _info.bottom,
					__button_inc__.region.get_height() + _info.top + _info.bottom,
				);
				
				static __set_size = GUICompController.set_size;
				__set_size(_left, _top, _right, _bottom)
				
				__button__.set_size(_left, _top, _right, _bottom)
				
				
				var _scroll_text_height = _bottom - _info.top  - _info.bottom + __button__.text.click_y_off;
				__scrolling_text__.set_size(
						0,
						-_scroll_text_height*0.5,
						floor(_right*0.5) - _info.right,
						_scroll_text_height*0.5
				)
				
				var _width = floor(_right*0.5) - _info.left - _info.right - __button_inc__.region.get_width() - __button_dec__.region.get_width()
				var _spacing = 2;
				
				var _prev_font = draw_get_font();
				draw_set_font(__textbox__.draw.font);
				var _max_w = ceil(string_width("1234567890")/10) * 8; //10 is all the numbers, 7 is the count of numbers we want to show
				draw_set_font(_prev_font);
				
				var _textbox_width = min(
						_max_w,
						ceil(_width*0.5) - _info.right
				)
				
				__textbox__.set_size(
						0,
						0,
						_textbox_width,
						_bottom - _info.top  - _info.bottom + __button__.text.click_y_off
				)
				__textbox__.set_offset(-_info.right - _textbox_width, _info.top)
				
				__button_inc__.set_offset(-_info.right - _textbox_width - _spacing - __button_inc__.region.get_width(), _info.top)
				
				__slider__.set_size(
						0,
						0,
						_width - _textbox_width - _info.right,
						_bottom - _info.top  - _info.bottom + __button__.text.click_y_off
				)
				__slider__.set_offset(-_info.right - _textbox_width - _spacing - __button_inc__.region.get_width() - _spacing - __slider__.region.get_width(), _info.top)
				
				__button_dec__.set_offset(-_info.right - _textbox_width - _spacing - __button_inc__.region.get_width() - _spacing - __slider__.region.get_width() - _spacing - __button_dec__.region.get_width(), _info.top)
				
				update_component_positions()
				
				return self
			}
			#region jsDoc
			/// @func    set_text()
			/// @desc    Sets the variables for text drawing
			/// @self    ControlPanelButton
			/// @param   {String} text : The text to write on the button.
			/// @returns {Struct.ControlPanelButton}
			#endregion
			static set_text = function(_text="DefaultText") {
				text.text = _text;
				__scrolling_text__.set_text(_text);
				
				return self;
			}
			#region jsDoc
			/// @func    set_text_font()
			/// @desc    Sets the font which will be used for drawing the text
			/// @self    ControlPanelButton
			/// @param   {Asset.GMFont} font : The font to use when drawing the text
			/// @returns {Struct.ControlPanelButton}
			#endregion
			static set_text_font = function(_font=fGUIDefault) {
				font = _font;								// font
				__scrolling_text__.set_text_font(font);
				
				return self;
			}
			#region jsDoc
			/// @func    set_text_colors()
			/// @desc    Sets the colors for the text of the button.
			/// @self    GUICompButtonText
			/// @param   {Real} idle_color     : The color to draw the text when the component is idle
			/// @param   {Real} hover_color    : The color to draw the text when the component is hovered or clicked
			/// @param   {Real} disabled_color : The color to draw the text when the component is disabled
			/// @returns {Struct.GUICompButtonText}
			#endregion
			static set_text_colors = function(_idle=c_white, _hover=c_white, _clicked=c_white, _disable=c_grey) {
				__button__.set_text_colors(_idle, _hover, _clicked, _disable);
				
				return self;
			}
			static set_value = function(_real) {
				__textbox__.set_text(string(_real))
				
				return self;
			}
			
		#endregion
		
		#region Variables
			
			halign = fa_left
			valign = fa_top;
			callback = _func;
			is_open = false;
			
		#endregion
		
		#region Functions
			
			#region GML Events
				
			#endregion
			
		#endregion
		
	#endregion
	
	#region Private Library
		
		#region Variables
			
			var _sprite_button_dec = sCPScrollbarHorzButtonLeft;
			var _sprite_button_inc = sCPScrollbarHorzButtonRight;
			
			
			__button__ = new GUICompButtonText()
				.set_offset(0,0)
				.set_text("")
				.set_sprite(s9CPButton)
				.set_text_alignment(fa_left, fa_top)
				.set_alignment(fa_left, fa_top)
			
			var _info = sprite_get_nineslice(__button__.sprite_index);
			
			var _ideal_h = max(
					font_get_info(__CP_FONT).size + _info.top + _info.bottom,
					sprite_get_height(_sprite_button_dec),
					sprite_get_height(_sprite_button_inc),
			)
			
			__button__.set_size(0,0,0,_ideal_h)
			
			__button_inc__ = new GUICompButtonSprite()
				//.set_offset(-_info.right, _info.top)
				.set_alignment(fa_right, fa_top)
				.set_sprite(_sprite_button_inc)
			__button_inc__.set_offset(-_info.right - __button_inc__.region.get_width(), _info.top)
			
			__button_dec__ = new GUICompButtonSprite()
				.set_offset(-_info.right, _info.top)
				.set_alignment(fa_right, fa_top)
				.set_sprite(_sprite_button_dec)
			__button_dec__.set_offset(-_info.right - __button_dec__.region.get_width(), _info.top)
			
			__slider__ = new GUICompSlider()
				.set_offset(-_info.right, _info.top)
				.set_alignment(fa_right, fa_top)
				.set_value(clamp(_value, _min, _max))
				.set_clamp_values(_min, _max)
				.set_background_min_colors(#232428, #2B2D31, #313338, #1E1F22)
				.set_background_max_colors(#232428, #2B2D31, #313338, #1E1F22)
				.set_bar_min_colors(#670000, #800000, #8E0000, #5D0000)
				.set_bar_max_colors(#670000, #800000, #8E0000, #5D0000)
			
			__textbox__ = new GUICompTextbox()
				.set_offset(-_info.right, _info.top)
				.set_alignment(fa_right, fa_top)
				.set_text_placeholder("Value...")
				.set_size(0, 0, 0, _ideal_h)
				.set_scrollbar_sizes(0, 0)
				.set_text(string(_value))
				.set_text_font(__CP_FONT)
				.set_text_color(c_white)
				.set_background_color(#2B2D31)
				.set_highlight_color(#800000)
				.set_max_length(20)
				.set_char_enforcement("0123456789.-")
				.set_multiline(false)
				//.set_force_wrapping(false)
				//.set_shift_only_new_line(false)
				.set_accepting_inputs(true)
			
			__scrolling_text__ = new GUICompScrollingText()
				.set_offset(_info.left, 0)
				.set_text(_label)
				.set_text_font(__CP_FONT)
				.set_scroll_looping(true, false)
				.set_scroll_speeds(-2,0)
				.set_text_alignment(fa_left, fa_middle)
				.set_alignment(fa_left, fa_middle)
			
			add([__button__, __textbox__, __button_inc__, __slider__, __button_dec__, __scrolling_text__]);
			
			static draw_debug = function() {
				if (!should_draw_debug) return;
				
				draw_rectangle(
						x+region.left,
						y+region.top,
						x+region.right,
						y+region.bottom,
						true
				);
			}
			
			//set the default size of the component
			//get the label width
			var _prev_font = draw_get_font();
			draw_set_font(__scrolling_text__.text.font);
			var _width = string_width(_label);
			draw_set_font(_prev_font);
			
			var _info = sprite_get_nineslice(__button__.sprite_index)
			var _left   = 0;
			var _top    = 0;
			var _right  = min(__CP_DEFAULT_WIDTH, _width + _info.left + _info.right);
			var _bottom = font_get_info(__button__.text.font).size + _info.top + _info.bottom + __button__.text.click_y_off;
			
			set_size(_left, _top, _right, _bottom);
			
		#endregion
		
		#region Functions
			
			#region GML Events
				
			#endregion
			
			#region Private Events
				
				//adjust the region size based off the window's size
				if (__CP_ADAPT_TO_WINDOW) {
					add_event_listener(self.events.pre_step, function(_data) {
						var _width = floor(window_get_width()-self.x);
						if (region.get_width() != _width) {
							set_width(_width)
						}
					});
				}
				
				//adjust the visuals so all components are simillar
				add_event_listener(self.events.post_step, function(_data) {
					
					var _image_index = (is_enabled) ? __button__.image_index : GUI_IMAGE_DISABLED;
					_image_index = max(_image_index, __textbox__.__is_on_focus__)
					
					__button__.image_index   = _image_index;
					
					switch (_image_index) {
						case GUI_IMAGE_ENABLED : {
							__scrolling_text__.set_text_color(__button__.text.color.idle);
							__scrolling_text__.set_text_offsets(0, 0);
							__scrolling_text__.set_scroll_pause(true);
							__scrolling_text__.set_scroll_looping(true, false)
							__scrolling_text__.reset_scrolling();
						break;}
						case GUI_IMAGE_HOVER: {
							__scrolling_text__.set_text_color(__button__.text.color.hover);
							__scrolling_text__.set_text_offsets(0, 0);
							__scrolling_text__.set_scroll_pause(false);
						break;}
						case GUI_IMAGE_CLICKED: {
							__scrolling_text__.set_text_color(__button__.text.color.hover);
							__scrolling_text__.set_text_offsets(0, __button__.text.click_y_off);
							__scrolling_text__.set_scroll_pause(false);
						break;}
						case GUI_IMAGE_DISABLED: {
							__scrolling_text__.set_text_color(__button__.text.color.disable);
							__scrolling_text__.set_text_offsets(0, 0);
							__scrolling_text__.set_scroll_pause(true);
							__scrolling_text__.reset_scrolling();
						break;}
					}
					
				});
				
				//set the focus to the textbox
				__button__.add_event_listener(__button__.events.released, function(_data) {
					with (__textbox__) {
						__is_on_focus__ = true;
						trigger_event(self.events.on_focus);
						
						var _line_last = curt.length - 1;
						var _line_last_length = string_length(curt.lines[_line_last]);
						if (_line_last < 1 && _line_last_length < 1) break;
						curt.select_line = 0;
						curt.select = 0;
						set_cursor_y_pos(_line_last);
						set_cursor_x_pos(_line_last_length);
					}
					
					//callback(__textbox__.is_checked);
				});
				
				//inc button increases slider and textbox
				var _inc_func = function() {
					var _offset = 1;
					var _dist = __slider__.max_value - __slider__.min_value
					if (_dist < 2) _offset = 0.01;
					
					__slider__.set_value(__slider__.value + _offset)
					__textbox__.set_text(__slider__.value)
					
					callback(__slider__.value); //for use with the index as input
				}
				__button_inc__.add_event_listener(__button_inc__.events.released, _inc_func);
				__button_inc__.add_event_listener(__button_inc__.events.long_press, _inc_func);
				
				//dec button increases slider and textbox
				var _dec_func = function() {
					var _offset = -1;
					var _dist = __slider__.max_value - __slider__.min_value
					if (_dist < 2) _offset = -0.01;
					
					__slider__.set_value(__slider__.value + _offset)
					__textbox__.set_text(__slider__.value)
					
					callback(__slider__.value); //for use with the index as input
				}
				__button_dec__.add_event_listener(__button_dec__.events.released, _dec_func);
				__button_dec__.add_event_listener(__button_dec__.events.long_press, _dec_func);
				
				//slider changed textbox
				__slider__.add_event_listener(__slider__.events.value_changed, function(_value) {
					__textbox__.set_text(string(_value))
					
					callback(_value); //for use with the index as input
				});
				
				//textbox changes slider
				__textbox__.add_event_listener(__textbox__.events.submit, function(_str) {
					var _value = __slider__.value;
					
					if (string_digits(_str) == "") {
						_str = string(__slider__.value);
						__textbox__.set_text(_str)
					}
					
					if (string_count(".", _str)) {
						_str = string_replace(_str, ".", "#")
						_str = string_replace_all(_str, ".", "")
						_str = string_replace(_str, "#", ".")
					}
					
					if (string_count("-", _str)) {
						_str = string_replace(_str, "-", "#")
						_str = string_replace_all(_str, "-", "")
						_str = string_replace(_str, "#", "-")
					}
					
					var _add_neg = false;
					if (string_pos("-", _str) == 1) {
						_str = string_delete(_str, 1, 1)
						_add_neg = true;
					}
					
					if (string_pos(".", _str) == 1) {
							_str = "0"+_str;
							__textbox__.set_text(_str)
						}
					if (_str == "0.") {
							_str = "0";
							__textbox__.set_text(_str)
						}
					
					if (_add_neg) {
						_str = "-"+_str;
						__textbox__.set_text(_str)
					}
					
					_value = real(_str)
					__slider__.set_value(_value)
					
					
					callback(_value); //for use with the index as input
				});
				
				//remove any second periods, double dashes, or any other missused formatting
				__textbox__.add_event_listener(__textbox__.events.change, function(_str) {
					if (string_count(".", _str)) {
						_str = string_replace(_str, ".", "#")
						_str = string_replace_all(_str, ".", "")
						_str = string_replace(_str, "#", ".")
					}
					
					var _pos = string_pos_ext("-", _str, 2)
					while (_pos) {
						_str = string_delete(_str, _pos, 1)
						_pos = string_pos_ext("-", _str, 2)
					}
					
					//essentially a string clamp which allows for keeping the decimal place as you type
					if (string_digits(_str) != "") {
						var _value = real(_str)
						if (_value > __slider__.max_value) {
							_str = string(__slider__.max_value)
						}
						else if (_value < __slider__.min_value) {
							_str = string(__slider__.min_value)
						}
					}
					
					__textbox__.set_text(_str);
				});
				
			#endregion
			
			static __real_to_str__ = function(_val) {
				var _str = string_format(_val, 1, 5);
				if (!ceil(frac(real(_str)))) {
					_str = string_replace(_str, ".00000", "");
				}
				return _str;
			}
			
		#endregion
	
	#endregion
	
}


