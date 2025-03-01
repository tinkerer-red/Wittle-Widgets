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
			/// @func    set_sprite_to_auto_wrap()
			/// @desc    Automatically wrap the sprite around the suplied text. This will change the click region for you. Note: This should be called after calling the sprite and text builder functions.
			/// @self    GUICompButtonText
			/// @param   {Real} x : The x offset
			/// @param   {Real} y : The y offset
			/// @returns {Struct.GUICompButtonText}
			#endregion
			static set_sprite_to_auto_wrap = function() {
				
				draw_set_font(text.font);
				var _slice = sprite_get_nineslice(sprite_index);
				var _width  = string_width(text.text)  + (_slice.left + _slice.right);
				var _height = string_height(text.text) + (_slice.top  + _slice.bottom);
				
				//update internal variables
				set_size(0, 0, _width, _height);
				set_text_offsets(_slice.left, _slice.top, text.click_yoff);
				set_text_alignment(fa_left, fa_top);
				
				
				return self;
			}
			
		#endregion
		
		#region Events
			on_pre_draw(function(_input) {
			var _image_index = (is_enabled) ? image_index : GUI_IMAGE_DISABLED;
					
			if (self.image_alpha != 0)
			&& (self.visible) {
						
				//draw the nineslice
				if (self.image_alpha == 1)
				&& (self.image_blend == c_white) {
					draw_sprite_stretched(
							self.sprite_index,
							_image_index,
							x,
							y,
							region.get_width(),
							region.get_height()
					);
				}
				else{
					draw_sprite_stretched_ext(
							self.sprite_index, 
							_image_index, 
							x, 
							y, 
							region.get_width(), 
							region.get_height(), 
							self.image_blend, 
							self.image_alpha
					);
				}
						
				draw_set_alpha(self.image_alpha);
						
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
						
				var _text_y_off = (image_index == GUI_IMAGE_CLICKED) ? text.click_yoff : 0;
						
				draw_text(
						(self.x+text.xoff),
						(self.y+text.yoff+_text_y_off),
						text.text
					);
			}
				
		})
		#endregion
		
		#region Variables
			
			set_sprite(s9ButtonText);
			set_sprite_to_auto_wrap();
			set_size(0, 0, sprite_get_width(s9ButtonText), sprite_get_height(s9ButtonText))
			
		#endregion
		
		#region Functions
			
			#region GML Events
				
				
				
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