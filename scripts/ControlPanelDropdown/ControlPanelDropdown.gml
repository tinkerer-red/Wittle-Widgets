function ControlPanelDropdown(_label="<Missing Label>", _arr_of_str, _func) : GUICompController() constructor {
	
	draw_debug = function(){
		draw_text(x,y,string(["is_open", is_open, "__dropdown__.is_open", __dropdown__.is_open]))
	}
	
	#region Public
		
		#region Builder functions
			
			static set_region = function(_left, _top, _right, _bottom) {
				var _info = sprite_get_nineslice(__button__.sprite.index)
				_top    = 0;
				_bottom = max(__dropdown__.region.get_height(), font_get_info(__button__.font).size) + _info.top + _info.bottom + __button__.text_click_y_off;
				
				__SUPER__.set_region(_left, _top, _right, _bottom)
				
				
				__button__.set_region(_left, _top, _right, _bottom)
				
				var _width = floor((_right  - _info.left - _info.right)*0.5);
				if (__dropdown__.region.get_width() > _width) {
					__dropdown__.set_sprite_to_auto_wrap()
				}
				else {
					__dropdown__.set_width(_width)
				}
				
				__dropdown__.set_position(-__dropdown__.region.get_width(), 0)
				
				
				var _scroll_text_height = _bottom - _info.top  - _info.bottom + __button__.text_click_y_off;
				__scrolling_text__.set_region(
						0,
						-_scroll_text_height*0.5,
						_right  - _info.left - _info.right - __dropdown__.region.get_width(),
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
			
			__dropdown__ = new GUICompDropdown() //the x/y doesnt matter as the set region will move this
				.set_anchor(-_info.right, _info.top)
				.set_alignment(fa_right, fa_top)
				.set_dropdown_sprites(s9CPDropDown, s9CPDropDownTop, s9CPDropDownMiddle, s9CPDropDownBottom)
				.set_dropdown_array(_arr_of_str)
				.set_sprite_to_auto_wrap()
			__dropdown__.set_position(-__dropdown__.region.get_width(), 0)
			
			__scrolling_text__ = new GUICompScrollingText()
				.set_anchor(_info.left, 0)
				.set_text(_label)
				.set_text_font(__CP_FONT)
				.set_scroll_looping(true, false)
				.set_scroll_speeds(-2,0)
				.set_text_alignment(fa_left, fa_middle)
				.set_alignment(fa_left, fa_middle)
			
			add(__button__);
			add(__dropdown__);
			add(__scrolling_text__);
			
			
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
			var _bottom = max(
												font_get_info(__button__.font).size + _info.top + _info.bottom + __button__.text_click_y_off,
												__dropdown__.region.get_height() + _info.top + _info.bottom + __button__.text_click_y_off,
										);
			
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
					
					var _image_index = (is_enabled) ? max(__dropdown__.image.index, __button__.image.index) : GUI_IMAGE_DISABLED;
					
					__button__.image.index   = _image_index;
					__dropdown__.image.index = _image_index;
					
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
				
				//update open state from button click
				__button__.__add_event_listener_priv__(__button__.events.released, function(_data) {
					is_open = !is_open
					__dropdown__.is_open = is_open
					with (__dropdown__){
						if (is_open) {
							__trigger_event__(self.events.opened, {index : current_index, element : (current_index == -1) ? undefined : elements[current_index]});
						}
						else {
							__trigger_event__(self.events.closed, {index : current_index, element : (current_index == -1) ? undefined : elements[current_index]});
						}
					}
					
				});
				
				//callback
				__dropdown__.__add_event_listener_priv__(__dropdown__.events.changed, function(_data) {
					//callback(_data.index); //for use with the index as input
					callback(_data.index, _data.element); //for use with the string as input
				});
				
				__dropdown__.__add_event_listener_priv__(__dropdown__.events.released, function(_data) {
					is_open = __dropdown__.is_open;
				});
				
				__dropdown__.__add_event_listener_priv__(__dropdown__.events.selected, function(_data) {
					is_open = __dropdown__.is_open;
				});
				
			#endregion
			
		#endregion
	
	#endregion
	
}
