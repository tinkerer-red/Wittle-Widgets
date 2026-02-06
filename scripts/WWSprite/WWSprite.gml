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
				if (undefined == sprite_index) return;
				if (undefined == visible) return;
				if (undefined == image_alpha) return;
				if (undefined == image_xscale) return;
				if (undefined == image_yscale) return;
				
				if (!sprite_exists(sprite_index)) return;
				if (!visible) return;
				if (image_alpha == 0) return;
				if (image_xscale == 0) return;
				if (image_yscale == 0) return;
				
				var _image_index = (__is_enabled__) ? image_index : GUI_IMAGE_DISABLED;
				
				//draw the nineslice
				if (image_alpha == 1)
				&& (image_blend == c_white)
				&& (image_xscale == 1)
				&& (image_yscale == 1) {
					draw_sprite_stretched(
							sprite_index,
							_image_index,
							x,
							y,
							width,
							height
					);
				}
				else {
					draw_sprite_stretched_ext(
							_sprite_index, 
							_image_index, 
							_x,
							_y,
							width  * image_xscale,
							height * image_yscale,
							image_blend, 
							image_alpha
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
