#region jsDoc
/// @func    GUICompButton()
/// @desc    Creates a button component
/// @return {Struct.GUICompButton}
#endregion
function GUICompButton() : GUICompCore() constructor {
	debug_name = "GUICompButtonSprite";
	
	#region Public
		
		#region Builder Functions
			
			#region jsDoc
			/// @func    set_sprite()
			/// @desc    Sets the sprite for the button. Also, if the user hasn’t explicitly set a size,
            ///          the size is initialized internally based on the sprite’s dimensions.
			/// @self    GUICompButtonSprite
			/// @param   {Asset.GMSprite} sprite : The sprite the component will use.
			/// @returns {Struct.GUICompButtonSprite}
			#endregion
			static set_sprite = function(_sprite) {
				/// NOTE: These are the default structure of GUI button sprites
				/// image_index[0] = idle; no interaction;
				/// image_index[1] = mouse over; the mouse is over it;
				/// image_index[2] = mouse down; actively being pressed;
				/// image_index[3] = disabled; not allowed to interact with;
				
				static __set_sprite = GUICompCore.set_sprite;
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
			static set_callback = function(_callback) {
				callback = _callback;
				return self;
			}
		#endregion
		
		#region Events
			
			on_released(function(_data)  {
				callback(_data)
			})
			on_pre_step(function(_input) {
				__handle_click__(_input);
			})
			on_pre_draw(function(_input) {
				if (visible)
				&& (self.image_alpha != 0) {
					
					var _image_index = (is_enabled) ? image_index : GUI_IMAGE_DISABLED;
					
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
					else {
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
				}
			})
			
		#endregion
		
		#region Variables
			
			set_sprite(sButton); // init the sprite variables
			callback = function(_data){};
			
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
			
			#region GML Events
				
				
			#endregion
			
		#endregion
	
	#endregion
	
}

#region jsDoc
/// @func    GUICompButtonSprite()
/// @desc    Creates a button component
/// @return {Struct.GUICompButtonSprite}
#endregion
function GUICompButtonSprite() : GUICompButton() constructor {
	debug_name = "GUICompButton";
	
	#region Public
		
		#region Builder Functions
			
			
			
		#endregion
		
		#region Events
			
			
			
		#endregion
		
		#region Variables
			
			
			
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
			
			#region GML Events
				
				
			#endregion
			
		#endregion
	
	#endregion
	
}