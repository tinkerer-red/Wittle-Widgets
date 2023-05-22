#region jsDoc
/// @func    GUICompCheckbox()
/// @desc    Creates a Checkbox Component
/// @param   {Real} x : The x possition of the component on screen.
/// @param   {Real} y : The y possition of the component on screen.
/// @returns {Struct.GUICompCheckbox}
#endregion
function GUICompCheckbox(_x, _y) : GUICompButtonSprite(_x, _y) constructor {
	debug_name = "GUICompCheckbox";
	
	#region Public
	
		#region Builder Functions
			
			#region jsDoc
			/// @func    set_checkbox_sprites()
			/// @desc    Sets the sprites which will be used for the checkbox's checked and unchecked states
			/// @self    GUICompCheckbox
			/// @param   {Asset.GMSprite} checked_sprite : The sprite used to draw the check box when checked
			/// @param   {Asset.GMSprite} unchecked_sprite : The sprite used to draw the check box when unchecked
			/// @returns {Struct.GUICompCheckbox}
			#endregion
			static set_checkbox_sprites = function(_checked_sprite=s9CheckBoxChecked, _unchecked_sprite=s9CheckBoxUnchecked) {
				/// NOTE: These are the default structure of GUI button sprites
				/// image.index[0] = idle; no interaction;
				/// image.index[1] = mouse over; the mouse is over it;
				/// image.index[2] = mouse down; actively being pressed;
				/// image.index[3] = disabled; not allowed to interact with;
				
				sprite_checked = _checked_sprite;
				sprite_unchecked = _unchecked_sprite;
				
				var _sprite = (is_checked) ? sprite_checked : sprite_unchecked;
				set_sprite(_sprite);
				
				return self;
			}
			
			#region jsDoc
			/// @func    set_value()
			/// @desc    Sets the checkbox to checked or unchecked
			/// @self    GUICompCheckbox
			/// @param   {Bool} is_checked : If the checkbox should be changed to checked.
			/// @returns {Struct.GUICompCheckbox}
			#endregion
			static set_value = function(_is_checked) {
				is_checked = _is_checked;
				
				var _sprite = (is_checked) ? sprite_checked : sprite_unchecked;
				__SUPER__.set_sprite(_sprite);
		
				return self;
			}
			
		#endregion
	
		#region Variables
			is_checked = false;
			
			sprite_checked = s9CheckBoxChecked;
			sprite_unchecked = s9CheckBoxUnchecked;
			
			__SUPER__.set_sprite(sprite_unchecked);
			
		#endregion
	
		#region Functions
			
			#region jsDoc
			/// @func    get_is_checked()
			/// @desc    Returns if the checkbox is checked
			/// @self    GUICompCheckbox
			/// @returns {Bool}
			#endregion
			static get_is_checked = function() {
				//the only reason this is a function is so it shows up better in feather
				
				return is_checked;
			}
			
			static draw_gui = function(_input) {
				draw_sprite(sprite.index, image.index, x, y);
			}
			
		#endregion
	
	#endregion
	
	#region Private Library
		
		#region Variables
			
		#endregion
		
		#region Functions
			__add_event_listener_priv__(self.events.released, function(){
				is_checked = !is_checked;
				sprite.index = (is_checked) ? sprite_checked : sprite_unchecked;
			})
			
			
		#endregion
		
	#endregion
}

