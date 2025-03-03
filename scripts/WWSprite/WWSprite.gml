#region jsDoc
/// @func    WWSprite()
/// @desc    The bar used inside of sliders
/// @returns {Struct.WWSprite}
#endregion
function WWSprite() : WWCore() constructor {
	debug_name = "WWSliderThumb";
	
	#region Public
		
		#region Builder Functions
			#region jsDoc
			/// @func    set_sprite()
			/// @desc    Sets the sprite for the button. Also, if the user hasn’t explicitly set a size,
            ///          the size is initialized internally based on the sprite’s dimensions.
			/// @self    WWButtonSprite
			/// @param   {Asset.GMSprite} sprite : The sprite the component will use.
			/// @returns {Struct.WWButtonSprite}
			#endregion
			static set_sprite = function(_sprite) {
				/// NOTE: These are the default structure of GUI button sprites
				/// image_index[0] = idle; no interaction;
				/// image_index[1] = mouse over; the mouse is over it;
				/// image_index[2] = mouse down; actively being pressed;
				/// image_index[3] = disabled; not allowed to interact with;
				
				static __set_sprite = WWCore.set_sprite;
				__set_sprite(_sprite);
				
				image_speed = 0;
				if (!__size_set__) {
					__set_size__(
						-sprite_xoffset,
						-sprite_yoffset,
						-sprite_xoffset + sprite_width,
						-sprite_yoffset + sprite_height
					)
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
				
				var _image_index = (is_enabled) ? image_index : GUI_IMAGE_DISABLED;
				
				//draw the nineslice
				if (self.image_alpha == 1)
				&& (self.image_blend == c_white)
				&& (self.image_xscale == 1)
				&& (self.image_yscale == 1) {
					draw_sprite_stretched(
							self.sprite_index,
							_image_index,
							x-region.left,
							y-region.top,
							region.get_width(),
							region.get_height()
					);
				}
				else {
					draw_sprite_stretched_ext(
							self.sprite_index, 
							_image_index, 
							x-region.left,
							y-region.top,
							region.get_width() * image_xscale, 
							region.get_height() * image_yscale, 
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
