function ControlPanelString(_label="<Missing Label>", _str, _func) : GUICompController() constructor {
	
	#region Public
		
		#region Builder functions
			
			static set_region = function(_left, _top, _right, _bottom) {
				var _info = sprite_get_nineslice(__button__.sprite.index)
				_top    = 0;
				_bottom = __textbox__.region.get_height() + _info.top + _info.bottom + __button__.text.click_y_off;
				
				__SUPER__.set_region(_left, _top, _right, _bottom)
				
				__button__.set_region(_left, _top, _right, _bottom)
				
				var _width = _right - _info.left - _info.right;
				
				__textbox__.set_width(_width*0.5)
				__textbox__.set_anchor(-_info.right - _width*0.5, _info.top)
				
				var _scroll_text_height = _bottom - _info.top  - _info.bottom + __button__.text.click_y_off;
				__scrolling_text__.set_region(
						0,
						-_scroll_text_height*0.5,
						_width*0.5 - _info.right,
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
				text.text = _text
				
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
			static set_value = function(_str) {
				_str = string_replace_all(_str, "\n", "\\n")
				_str = string_replace_all(_str, "\t", "\\t")
				_str = string_replace_all(_str, "\r", "\\r")
				
				__textbox__.set_text(_str)
				
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
			
			static get_value = function() {
				var _str = __textbox__.get_text()
				_str = string_replace_all(_str, "\\\\", "<__DOUBLE_BACKSLASH__>")
				_str = string_replace_all(_str, "\\n", "\n")
				_str = string_replace_all(_str, "\\t", "\t")
				_str = string_replace_all(_str, "\\r", "\r")
				_str = string_replace_all(_str, "<__DOUBLE_BACKSLASH__>", "\\")
				
				return _str;
			}
			
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
			
			var _ideal_h = font_get_info(__CP_FONT).size + _info.top + _info.bottom;
			
			__button__.set_region(0,0,0,_ideal_h)
			
			__textbox__ = new GUICompTextbox()
				.set_multiline(false)
				.set_anchor(-_info.right, _info.top)
				.set_alignment(fa_right, fa_top)
				.set_text_placeholder("String...")
				.set_region(0, 0, 0, _ideal_h)
				.set_scrollbar_sizes(0, 0)
				.set_text(string(_str))
				.set_text_font(__CP_FONT)
				.set_text_color(c_white)
				.set_background_color(#2B2D31)
				.set_highlight_color(#800000)
				.set_max_length(infinity)
				.set_char_enforcement()
				
				.set_accepting_inputs(true)
			
			
			__scrolling_text__ = new GUICompScrollingText()
				.set_anchor(_info.left, 0)
				.set_text(_label)
				.set_text_font(__CP_FONT)
				.set_scroll_looping(true, false)
				.set_scroll_speeds(-2,0)
				.set_text_alignment(fa_left, fa_middle)
				.set_alignment(fa_left, fa_middle)
			
			add([__button__, __textbox__, __scrolling_text__]);
			
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
			
			var _info = sprite_get_nineslice(__button__.sprite.index)
			var _left   = 0;
			var _top    = 0;
			var _right  = min(__CP_DEFAULT_WIDTH, _width + _info.left + _info.right);
			var _bottom = font_get_info(__button__.text.font).size + _info.top + _info.bottom + __button__.text.click_y_off;
			
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
					callback(get_value(_str)); //for use with the index as input
					//callback(_data.text); //for use with the string as input
				});
				
			#endregion
			
		#endregion
	
	#endregion
	
}


