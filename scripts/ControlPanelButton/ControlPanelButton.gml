function ControlPanelButton(_label="<Missing Label>", _func) : GUICompController(0, 0) constructor {
	
	#region Public
		
		#region Builder functions
			
			static set_region = function(_left, _top, _right, _bottom) {
				var _info = sprite_get_nineslice(__button__.sprite.index)
				_top    = 0;
				_bottom = font_get_info(__button__.font).size + _info.top + _info.bottom + __button__.text_click_y_off;
				
				__SUPER__.set_region(_left, _top, _right, _bottom)
				
				__button__.set_region(_left, _top, _right, _bottom)
				
				var _scroll_text_height = _bottom - _info.top  - _info.bottom + __button__.text_click_y_off;
				__scrolling_text__.set_region(
						0,
						-_scroll_text_height*0.5,
						_right  - _info.left - _info.right,
						_scroll_text_height*0.5
				)
				
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
				.set_text_alignment(fa_left, fa_top)
				.set_text_offsets(0, 0, 1)
			
			__button__.halign = fa_left;
			__button__.valign = fa_top;
			
			var _info = sprite_get_nineslice(__button__.sprite.index);
			
			__scrolling_text__ = new GUICompScrollingText()
				.set_anchor(_info.left, _info.top - __button__.text_click_y_off)
				.set_text(_label)
				.set_text_font(__CP_FONT)
				.set_scroll_looping(true, false)
				.set_scroll_speeds(-2,0)
				.set_text_alignment(fa_left, fa_top)
				.set_alignment(fa_left, fa_top)
			
			add(__button__);
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
						var _width = floor(window_get_width());
						if (region.get_width() != _width) {
							set_width(_width)
						}
					});
				}
				
				//adjust the visuals so all components are simillar
				__add_event_listener_priv__(events.pre_update, function(_data) {
					var _image_index = (is_enabled) ? __button__.image.index : GUI_IMAGE_DISABLED;
					
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
				
				//callback
				__button__.__add_event_listener_priv__(__button__.events.released, function(_data) {
					callback();
				});
				
				
			#endregion
			
		#endregion
	
	#endregion
	
}
