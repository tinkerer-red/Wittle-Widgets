function ControlPanelReal(_label="<Missing Label>", _value, _func) : GUICompController() constructor {
	
	draw_debug = function(){
		
	}
	
	#region Public
		
		#region Builder functions
			
			static set_region = function(_left, _top, _right, _bottom) {
				var _info = sprite_get_nineslice(__button__.sprite.index)
				_top    = 0;
				_bottom = __textbox__.region.get_height() + _info.top + _info.bottom + __button__.text_click_y_off;
				
				__SUPER__.set_region(_left, _top, _right, _bottom)
				
				__button__.set_region(_left, _top, _right, _bottom)
				
				var _width = _right  - _info.left - _info.right - __textbox__.region.get_width();
				
				
				var _scroll_text_height = _bottom - _info.top  - _info.bottom + __button__.text_click_y_off;
				__scrolling_text__.set_region(
						0,
						-_scroll_text_height*0.5,
						_width - _info.right,
						_scroll_text_height*0.5
				)
				
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
				text = _text
				__scrolling_text__.set_text(text);
				
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
			static set_text_colors = function(_idle_text_color=c_white, _hover_text_color=c_white, _disable_text_color=c_grey) {
				__button__.set_text_colors(_idle_text_color, _hover_text_color, _disable_text_color)
				
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
			
			__button__ = new GUICompButtonText()
				.set_anchor(0,0)
				.set_text("")
				.set_sprite(s9CPButton)
				.set_text_alignment(fa_left, fa_top)
				.set_alignment(fa_left, fa_top)
			
			var _info = sprite_get_nineslice(__button__.sprite.index);
			
			var _prev_font = draw_get_font();
			draw_set_font(__CP_FONT);
			var _ideal_w = ceil(string_width("1234567890")/10) * 7; //10 is all the numbers, 7 is the count of numbers we want to show
			draw_set_font(_prev_font);
			
			var _ideal_h = font_get_info(__CP_FONT).size + _info.top + _info.bottom;
			
			__button__.set_region(0,0,0,_ideal_h)
			
			__textbox__ = new GUICompTextbox()
				.set_anchor(-_info.right - _ideal_w, _info.top)
				.set_alignment(fa_right, fa_top)
				.set_text_placeholder("Value...")
				.set_region(0, 0, _ideal_w, _ideal_h)
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
				.set_anchor(_info.left, 0)
				.set_text(_label)
				.set_text_font(__CP_FONT)
				.set_scroll_looping(true, false)
				.set_scroll_speeds(-2,0)
				.set_text_alignment(fa_left, fa_middle)
				.set_alignment(fa_left, fa_middle)
			
			add(__button__);
			add(__textbox__);
			add(__scrolling_text__);
			
			draw_debug = function() {
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
			
			var _info = sprite_get_nineslice(__button__.sprite.index)
			var _left   = 0;
			var _top    = 0;
			var _right  = min(__CP_DEFAULT_WIDTH, _width + _info.left + _info.right);
			var _bottom = font_get_info(__button__.font).size + _info.top + _info.bottom + __button__.text_click_y_off;
			
			set_region(_left, _top, _right, _bottom);
			
		#endregion
		
		#region Functions
			
			#region GML Events
				
			#endregion
			
			#region Private Events
				
				//adjust the region size based off the window's size
				if (__CP_ADAPT_TO_WINDOW) {
					__add_event_listener_priv__(self.events.pre_update, function(_data) {
						var _width = floor(window_get_width()-self.x);
						if (region.get_width() != _width) {
							set_width(_width)
						}
					});
				}
				
				//adjust the visuals so all components are simillar
				__add_event_listener_priv__(self.events.post_update, function(_data) {
					
					var _image_index = (is_enabled) ? __button__.image.index : GUI_IMAGE_DISABLED;
					_image_index = max(_image_index, __textbox__.__is_on_focus__)
					
					__button__.image.index   = _image_index;
					
					switch (_image_index) {
						case GUI_IMAGE_ENABLED : {
							__scrolling_text__.set_text_color(__button__.text_color_idle);
							__scrolling_text__.set_text_offsets(0, 0);
							__scrolling_text__.set_scroll_pause(true);
							__scrolling_text__.set_scroll_looping(true, false)
							__scrolling_text__.reset_scrolling();
						break;}
						case GUI_IMAGE_HOVER: {
							__scrolling_text__.set_text_color(__button__.text_color_hover);
							__scrolling_text__.set_text_offsets(0, 0);
							__scrolling_text__.set_scroll_pause(false);
						break;}
						case GUI_IMAGE_CLICKED: {
							__scrolling_text__.set_text_color(__button__.text_color_hover);
							__scrolling_text__.set_text_offsets(0, __button__.text_click_y_off);
							__scrolling_text__.set_scroll_pause(false);
						break;}
						case GUI_IMAGE_DISABLED: {
							__scrolling_text__.set_text_color(__button__.text_color_disable);
							__scrolling_text__.set_text_offsets(0, 0);
							__scrolling_text__.set_scroll_pause(true);
							__scrolling_text__.reset_scrolling();
						break;}
					}
					
				});
				
				//set the focus to the textbox
				__button__.__add_event_listener_priv__(__button__.events.released, function(_data) {
					with (__textbox__) {
						__is_on_focus__ = true;
						__trigger_event__(self.events.on_focus);
						
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
				
				//callback
				__textbox__.__add_event_listener_priv__(__textbox__.events.submit, function(_str) {
					if (string_digits(_str) == "") {
						_str = "0";
						var _value = 0;
						__textbox__.set_text(_str);
					}
					else {
						var _value = real(_str);
						//just incase it's a string like "-.0"
						if (_value == 0) {
							__textbox__.set_text("0")
						}
					}
					
					callback(_value); //for use with the index as input
					//callback(_data.element); //for use with the string as input
				});
				
				//remove any second periods, double dashes, or any other missused formatting
				__textbox__.__add_event_listener_priv__(__textbox__.events.change, function(_str) {
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
					
					__textbox__.set_text(_str);
				});
				
			#endregion
			
		#endregion
	
	#endregion
	
}
