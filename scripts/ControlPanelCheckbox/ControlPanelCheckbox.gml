function ControlPanelCheckbox(_label="<Missing Label>", _func) : GUICompController() constructor {
	
	#region Public
		
		#region Builder functions
			
			static set_size = function(_left, _top, _right, _bottom) {
				var _info = sprite_get_nineslice(__button__.sprite_index)
				_top    = 0;
				_bottom = max(__checkbox__.sprite_height, font_get_info(__button__.text.font).size) + _info.top + _info.bottom + __button__.text.click_yoff;
				
				static __set_size = GUICompController.set_size;
				__set_size(_left, _top, _right, _bottom)
				
				__button__.set_size(_left, _top, _right, _bottom)
				
				//__checkbox__.x = -_info.right;
				//__checkbox__.y = _info.top;
				var _scroll_text_height = _bottom - _info.top  - _info.bottom + __button__.text.click_yoff
				__scrolling_text__.set_size(
						0,
						-_scroll_text_height*0.5,
						_right  - _info.left - _info.right - __checkbox__.sprite_width,
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
			
			static set_debug_drawing = function(_bool) {
				should_draw_debug = _bool;
				__button__.should_draw_debug = _bool;
				__checkbox__.should_draw_debug = _bool;
				__scrolling_text__.should_draw_debug = _bool;
				
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
			
			__button__ = new WWButtonText()
				.set_offset(0,0)
				.set_text("")
				.set_sprite(s9CPButton)
				.set_text_alignment(fa_left, fa_top)
				.set_alignment(fa_left, fa_top)
			
			var _info = sprite_get_nineslice(__button__.sprite_index);
			
			__checkbox__ = new WWCheckbox() //the x/y doesnt matter as the set region will move this
				.set_alignment(fa_right, fa_top)
				.set_checkbox_sprites(sCPCheckboxChecked, sCPCheckboxUnChecked)
			__checkbox__.set_offset(-_info.right - __checkbox__.sprite_width, _info.top)
			
			__scrolling_text__ = new WWTextScrolling()
				.set_offset(_info.left, 0)
				.set_alignment(fa_left, fa_middle)
				.set_text(_label)
				.set_text_font(__CP_FONT)
				.set_scroll_looping(true, false)
				.set_scroll_speeds(-2,0)
				.set_text_alignment(fa_left, fa_middle)
			
			
			add([__button__, __checkbox__, __scrolling_text__]);
			
			//set the default size of the component
			var _prev_font = draw_get_font();
			draw_set_font(__scrolling_text__.text.font);
			var _width = string_width(_label);
			draw_set_font(_prev_font);
				
			var _info = sprite_get_nineslice(__button__.sprite_index)
			var _left   = 0;
			var _top    = 0;
			var _right  = min(__CP_DEFAULT_WIDTH, _width + _info.left + _info.right);
			var _bottom = max(
												font_get_info(__button__.text.font).size + _info.top + _info.bottom + __button__.text.click_yoff,
												__checkbox__.sprite_height + _info.top + _info.bottom + __button__.text.click_yoff,
										);
				
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
							set_width(floor(_width))
						}
					});
				}
				
				//adjust the visuals so all components are simillar
				add_event_listener(self.events.post_step, function(_data) {
					
					var _image_index = (is_enabled) ? max(__checkbox__.image_index, __button__.image_index) : GUI_IMAGE_DISABLED;
					
					__button__.image_index   = _image_index;
					__checkbox__.image_index = _image_index;
					
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
						case GUI_IMAGE_PRESSED: {
							__scrolling_text__.set_text_color(__button__.text.color.hover);
							__scrolling_text__.set_text_offsets(0, __button__.text.click_yoff);
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
				
				//callback
				__button__.add_event_listener(__button__.events.released, function(_data) {
					__checkbox__.set_value(!__checkbox__.is_checked)
					callback(__checkbox__.is_checked);
				});
				
				//callback
				__checkbox__.add_event_listener(__checkbox__.events.released, function(_data) {
					callback(__checkbox__.is_checked);
				});
				
			#endregion
			
		#endregion
	
	#endregion
	
}


