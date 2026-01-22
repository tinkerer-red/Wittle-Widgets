#region jsDoc
/// @func    WWButtonSprite()
/// @desc    Convenience alias / preset constructor for sprite-based buttons
/// @returns {Struct.WWButtonSprite}
#endregion
function WWButtonSprite() : WWSprite() constructor {
	debug_name = "WWButtonSprite";
	
		#region Public
		
		#region Builder Functions
			#region jsDoc
			/// @func    set_callback()
			/// @desc    Sets the callback invoked when the button is released.
			/// @self    WWButtonSprite
			/// @param   {Function} _callback : Function called on release.
			/// @returns {Struct.WWButtonSprite}
			#endregion
			static set_callback = function(_callback) {
				__callback__ = _callback;
				on_released(__callback__);
				return self;
			};

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
			
			set_sprite(sButton); // init the sprite variables
			
		#endregion
		
		#region Functions
			
			#region jsDoc
			/// @func    get_callback()
			/// @desc    Returns the callback currently used for the release event.
			/// @self    WWButtonSprite
			/// @returns {Function} callback_or_undefined
			#endregion
			static get_callback = function() {
				return __callback__;
			};
			
			#region GML Events
				
				
			#endregion
			
		#endregion
		
	#endregion
	
	#region Private Library
		
		#region Variables
			
			__is_focusable__ = true; // Mark this component as focusable (set to false if a component should never receive focus)
			__callback__ = undefined;
			
		#endregion
		
		#region Functions
			
			#region GML Events
				
				
			#endregion
			
		#endregion
	
	#endregion
}