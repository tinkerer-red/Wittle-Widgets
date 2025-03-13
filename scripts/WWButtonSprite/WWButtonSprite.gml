#region jsDoc
/// @func    WWButton()
/// @desc    Creates a button component
/// @return {Struct.WWButton}
#endregion
function WWButton() : WWSprite() constructor {
	debug_name = "WWButton";
	
	#region Public
		
		#region Builder Functions
			static set_callback = function(_callback) {
				on_released(_callback);
				return self;
			}
		#endregion
		
		#region Events
			
			on_pressed(function(_input){
				image_index = GUI_IMAGE_PRESSED;
			})
			on_held(function(_input){
				if (__is_hovered__) {
					image_index = GUI_IMAGE_PRESSED;
				}
			})
			on_hover(function(_input){
				image_index = GUI_IMAGE_HOVER;
			})
			on_hover_exit(function(_input){
				image_index = GUI_IMAGE_ENABLED;
			})
			
			
		#endregion
		
		#region Variables
			
			is_focusable = true; // Mark this component as focusable (set to false if a component should never receive focus)
			
			set_sprite(sButton); // init the sprite variables
			
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
/// @func    WWButtonSprite()
/// @desc    Creates a button component
/// @return {Struct.WWButtonSprite}
#endregion
function WWButtonSprite() : WWButton() constructor {
	debug_name = "WWButtonSprite";
}