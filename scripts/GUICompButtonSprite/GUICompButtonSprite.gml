#region jsDoc
/// @func    GUICompButtonSprite()
/// @desc    Creates a button component
/// @param   {Real} x : The x possition of the component on screen.
/// @param   {Real} y : The y possition of the component on screen.
/// @return {Struct.GUICompButtonSprite}
#endregion
function GUICompButtonSprite() : GUICompCore() constructor {
	debug_name = "GUICompButtonSprite";
	
	#region Public
		
		#region Builder Functions
			
			#region jsDoc
			/// @func    set_sprite()
			/// @desc    Sets the sprite of the component.
			/// @self    GUICompButtonSprite
			/// @param   {Asset.GMSprite} sprite : The sprite the component will use.
			/// @returns {Struct.GUICompButtonSprite}
			#endregion
			static set_sprite = function(_sprite) {
				/// NOTE: These are the default structure of GUI button sprites
				/// image.index[0] = idle; no interaction;
				/// image.index[1] = mouse over; the mouse is over it;
				/// image.index[2] = mouse down; actively being pressed;
				/// image.index[3] = disabled; not allowed to interact with;
				
				static __set_sprite = GUICompCore.set_sprite;
				__set_sprite(_sprite);
				
				image.speed = 0;
				set_region(
						-sprite.xoffset,
						-sprite.yoffset,
						-sprite.xoffset + sprite.width,
						-sprite.yoffset + sprite.height
					)
				
				return self;
			}
			
		#endregion
		
		#region Events
			
			self.events.mouse_over = variable_get_hash("mouse_over");
			self.events.pressed    = variable_get_hash("pressed");
			self.events.held       = variable_get_hash("held");
			self.events.long_press = variable_get_hash("long_press");
			self.events.released   = variable_get_hash("released");
			
		#endregion
		
		#region Variables
			
			set_sprite(sButton); // init the sprite variables
			
		#endregion
		
		#region Functions
			
			#region GML Events
				
				static draw_gui = function() {
					if (visible) {
						var _image_index = (is_enabled) ? image.index : GUI_IMAGE_DISABLED;
						draw_sprite_ext(sprite.index, _image_index, x, y, image.xscale, image.yscale, image.angle, image.blend, image.alpha);
					}
				}
			
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
