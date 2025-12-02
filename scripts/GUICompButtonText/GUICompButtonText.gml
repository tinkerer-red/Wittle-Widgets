#region jsDoc
/// @func    GUICompButtonText()
/// @desc    Creates a button component
/// @self    GUICompButtonText
/// @param   {Real} x : The x possition of the component on screen.
/// @param   {Real} y : The y possition of the component on screen.
/// @return {Struct.GUICompButtonText}
#endregion
function GUICompButtonText() : GUICompButtonSprite() constructor {
	debug_name = "GUICompButtonText";
	
	#region Public
		
		#region Builder Functions
			
			#region jsDoc
			/// @func    set_sprite()
			/// @desc    Sets the sprite of the button.
			/// @self    GUICompButtonText
			/// @param   {Asset.GMSprite} sprite : The sprite the button will use.
			/// @returns {Struct.GUICompButtonText}
			#endregion
			static set_sprite = function(_sprite=s9ButtonText) {
				/// NOTE: These are the default structure of GUI button sprites
				/// image.index[0] = idle; no interaction;
				/// image.index[1] = mouse over; the mouse is over it;
				/// image.index[2] = mouse down; actively being pressed;
				/// image.index[3] = disabled; not allowed to interact with;
				
				//Component Core's set_sprite
				__set_sprite__(_sprite);
				self.image.speed = 0;
				
				return self;
			}
			#region jsDoc
			/// @func    set_text()
			/// @desc    Sets the variables for text drawing
			/// @self    GUICompButtonText
			/// @param   {String} text : The text to write on the button.
			/// @returns {Struct.GUICompButtonText}
			#endregion
			static set_text = function(_text="DefaultText") {
				text.text = _text
				
				return self;
			}
			#region jsDoc
			/// @func    set_text_font()
			/// @desc    Sets the font which will be used for drawing the text
			/// @self    GUICompButtonText
			/// @param   {Asset.GMFont} font : The font to use when drawing the text
			/// @returns {Struct.GUICompButtonText}
			#endregion
			static set_text_font = function(_font=fGUIDefault) {
				text.font = _font;								// font
				
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
				text.color.idle    = _idle;
				text.color.hover   = _hover;
				text.color.clicked = _clicked;
				text.color.disable = _disable;
				
				return self;
			}
			#region jsDoc
			/// @func    set_text_alignment()
			/// @desc    Sets how the text is aligned when drawing
			/// @self    GUICompButtonText
			/// @param   {Constant.HAlign} halign : Horizontal alignment
			/// @param   {Constant.VAlign} valign : Vertical alignment
			/// @returns {Struct.GUICompButtonText}
			#endregion
			static set_text_alignment = function(_h=fa_left, _v=fa_top) {
				text.halign = _h;
				text.valign = _v;
		
				return self;
			};
			#region jsDoc
			/// @func    set_text_offsets()
			/// @desc    Sets the Text's offsets reletive to the component's x/y. Note: click_y will be applied in addition to the y, when the component is actively being pressed.
			/// @self    GUICompButtonText
			/// @param   {Real} x : The x offset
			/// @param   {Real} y : The y offset
			/// @param   {Real} click_y : The additional y offset used when 
			/// @returns {Struct.GUICompButtonText}
			#endregion
			static set_text_offsets = function(_x=0, _y=0, _click_y=2) {
				text.xoff = _x;
				text.yoff = _y;
				text.click_y_off = _click_y;
				
				return self;
			};
			#region jsDoc
			/// @func    set_sprite_to_auto_wrap()
			/// @desc    Automatically wrap the sprite around the suplied text. This will change the click region for you. Note: This should be called after calling the sprite and text builder functions.
			/// @self    GUICompButtonText
			/// @param   {Real} x : The x offset
			/// @param   {Real} y : The y offset
			/// @returns {Struct.GUICompButtonText}
			#endregion
			static set_sprite_to_auto_wrap = function() {
				
				draw_set_font(text.font);
				var _slice = sprite_get_nineslice(sprite.index);
				var _width  = string_width(text.text)  + (_slice.left + _slice.right);
				var _height = string_height(text.text) + (_slice.top  + _slice.bottom);
				
				//update internal variables
				set_region(0, 0, _width, _height);
				set_text_offsets(_slice.left, _slice.top, text.click_y_off);
				set_text_alignment(fa_left, fa_top);
				
				
				return self;
			}
			
		#endregion
		
		#region Variables
			
			set_sprite(s9ButtonText);
			
			set_region(0, 0, sprite_get_width(s9ButtonText), sprite_get_height(s9ButtonText)) // imitates bbox, but used to register where the acceptable click regions are
			
		#endregion
		
		#region Functions
			
			#region GML Events
				
				static draw_gui = function() {
					var _image_index = (is_enabled) ? image.index : GUI_IMAGE_DISABLED;
					
					if (self.image.alpha != 0)
					&& (self.visible) {
						
						//draw the nineslice
						if (self.image.alpha == 1)
						&& (self.image.blend == c_white) {
							draw_sprite_stretched(
									self.sprite.index,
									_image_index,
									x,
									y,
									region.get_width(),
									region.get_height()
							);
						}
						else{
							draw_sprite_stretched_ext(
									self.sprite.index, 
									_image_index, 
									x, 
									y, 
									region.get_width(), 
									region.get_height(), 
									self.image.blend, 
									self.image.alpha
							);
						}
						
						draw_set_alpha(self.image.alpha);
						
						//set font color
						switch (_image_index) {
							case GUI_IMAGE_ENABLED : {
								draw_set_color(text.color.idle);
								break;}
							case GUI_IMAGE_HOVER: {
								draw_set_color(text.color.hover);
								break;}
							case GUI_IMAGE_CLICKED: {
								draw_set_color(text.color.clicked);
								break;}
							case GUI_IMAGE_DISABLED: {
								draw_set_color(text.color.disable);
								break;}
						}
						
						draw_set_font(text.font);
						draw_set_halign(text.halign);
						draw_set_valign(text.valign);
						
						var _text_y_off = (image.index == GUI_IMAGE_CLICKED) ? text.click_y_off : 0;
						
						draw_text(
								(self.x+text.xoff),
								(self.y+text.yoff+_text_y_off),
								text.text
							);
					}
				
				}
				
			#endregion
			
		#endregion
		
	#endregion
	
	#region Private Library
		
		#region Variables
			
		#endregion
		
		#region Functions
			
		#endregion
	
	#endregion
	
}