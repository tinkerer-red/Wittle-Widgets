#region jsDoc
/// @func    WWButtonTextScribble()
/// @desc    Creates a button component
/// @self    WWButtonText
/// @param   {Real} x : The x possition of the component on screen.
/// @param   {Real} y : The y possition of the component on screen.
/// @returns {Struct.WWButtonText}
#endregion
function WWButtonTextScribble() : WWButtonSprite() constructor {
	debug_name = "WWButtonText";
	
	#region Public
		
		#region Builder Functions
			
			static set_scribble = function(_scrib) {
				my_scribble = _scrib;
				__update_region_from_text__()
				return self;
			}
			static set_scribble_typist = function(_typist) {
				my_typist = _typist;
				__update_region_from_text__()
				return self;
			}
			#region jsDoc
			/// @func    set_sprite_to_auto_wrap()
			/// @desc    Automatically wrap the sprite around the suplied text. This will change the click region for you. Note: This should be called after calling the sprite and text builder functions.
			/// @self    WWButtonText
			/// @param   {Real} x : The x offset
			/// @param   {Real} y : The y offset
			/// @returns {Struct.WWButtonText}
			#endregion
			static set_sprite_to_auto_wrap = function() {
				
				var _slice = sprite_get_nineslice(sprite_index);
				var _width  = text_component.width  + (_slice.left + _slice.right);
				var _height = text_component.height + (_slice.top  + _slice.bottom);
				
				//update internal variables
				__set_size__(_width, _height);
				set_text_offsets(_slice.left, _slice.top, text.click_yoff);
				
				return self;
			}
			#region jsDoc
			/// @func    set_text_offsets()
			/// @desc    Sets the Text's offsets reletive to the component's x/y. Note: click_y will be applied in addition to the y, when the component is actively being pressed.
			/// @self    WWButtonText
			/// @param   {Real} x : The x offset
			/// @param   {Real} y : The y offset
			/// @param   {Real} click_y : The additional y offset used when 
			/// @returns {Struct.WWButtonText}
			#endregion
			static set_text_offsets = function(_x=0, _y=0, _click_y=2) {
				text_component.set_offset(_x, _y);
				
				text.x_offset = _x;
				text.y_offset = _y;
				text.click_yoff = _click_y;
				
				return self;
			};
			
		#endregion
		
		#region Components
			
			text_component = new WWLabelScribble();
			add(text_component);
			
		#endregion
		
		#region Events
			on_held(function(_input) {
				text_component.set_offset(text.x_offset, text.click_yoff)
			})
			on_held(function(_input) {
				text_component.set_offset(text.x_offset, text.y_offset)
			})
			
		#endregion
		
		#region Variables
			
			set_sprite(s9ButtonText);
			set_sprite_to_auto_wrap();
			__set_size__(sprite_get_width(s9ButtonText), sprite_get_height(s9ButtonText))
			
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

