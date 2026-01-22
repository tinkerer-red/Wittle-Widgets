#region jsDoc
/// @func    WWSprite()
/// @desc    Basic sprite-drawing component that sizes/offsets itself from the sprite unless overridden.
/// @returns {Struct.WWSprite}
#endregion
function WWSprite() : WWCore() constructor {
	debug_name = "WWSprite";
	
	#region Public
		
		#region Builder Functions
			#region jsDoc
			/// @func    set_sprite()
			/// @desc    Sets the sprite for the button. Also, if the user hasn't explicitly set a size,
            ///          the size is initialized internally based on the sprite's dimensions.
			/// @self    WWSprite
			/// @param   {Asset.GMSprite} sprite : The sprite the component will use.
			/// @returns {Struct.WWSprite}
			#endregion
			static set_sprite = function(_sprite) {
				
				///super equivalent
				static __set_sprite = WWCore.set_sprite;
				__set_sprite(_sprite);
				
				image_speed = 0;
				if (!__size_set__) {
					__set_size__(sprite_width * image_xscale, sprite_height * image_yscale)
				}
				if (!__offset_set__) {
					__set_offset__(-sprite_xoffset, -sprite_yoffset)
				}
				return self;
			}
			
		#endregion
		
		#region Events
			
			on_pre_draw(function(_input) {
				if (!sprite_exists(sprite_index)) return;
				if (!visible) return;
				if (self.image_alpha == 0) return;
				if (self.image_xscale == 0) return;
				if (self.image_yscale == 0) return;
				
				var _image_index = (__is_enabled__) ? image_index : GUI_IMAGE_DISABLED;
				
				//draw the nineslice
				if (self.image_alpha == 1)
				&& (self.image_blend == c_white)
				&& (self.image_xscale == 1)
				&& (self.image_yscale == 1) {
					draw_sprite_stretched(
							self.sprite_index,
							_image_index,
							x,
							y,
							width,
							height
					);
				}
				else {
					draw_sprite_stretched_ext(
							self.sprite_index, 
							_image_index, 
							x,
							y,
							width  * image_xscale,
							height * image_yscale,
							self.image_blend, 
							self.image_alpha
					);
				}
				
			})
			
		#endregion
		
		#region Variables
			
		#endregion
	
		#region Functions
			
		#endregion
		
	#endregion
	
	#region Private
		
		#region Variables
			
		#endregion
		
		#region Functions
			
		#endregion
		
	#endregion
	
}
