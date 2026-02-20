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
			
			#region jsDoc
			/// @func    set_color()
			/// @desc    Sets the color of the component.
			/// @self    WWSprite
			/// @param   {Real} col : The color the component will use.
			/// @returns {Struct.WWSprite}
			#endregion
			static set_color = set_sprite_color;
			
		#endregion
		
		#region Events
			
			on_pre_draw(function(_input) {
				if (undefined == sprite_index) return;
				if (undefined == visible) return;
				
				if (!sprite_exists(sprite_index)) return;
				if (!visible) return;
				
				var _alpha = image_alpha ?? 1;
				var _xscale = image_xscale ?? 1;
				var _yscale = image_yscale ?? 1;
				var _blend = image_blend ?? c_white;
				if (_alpha == 0) return;
				if (_xscale == 0) return;
				if (_yscale == 0) return;
				
				var _image_index = (__is_enabled__) ? image_index : GUI_IMAGE_DISABLED;
				
				//draw the nineslice
				if (_alpha == 1)
				&& (_blend == c_white)
				&& (_xscale == 1)
				&& (_yscale == 1) {
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
							sprite_index, 
							_image_index, 
							x,
							y,
							width  * _xscale,
							height * _yscale,
							_blend, 
							_alpha
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
