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
				image_index = GUI_IMAGE_PRESSED;
			})
			on_is_focused(function(_input){
				image_index = GUI_IMAGE_HOVER;
			})
			on_is_blurred(function(_input){
				image_index = GUI_IMAGE_ENABLED;
			})
			
			
		#endregion
		
		#region Variables
			
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