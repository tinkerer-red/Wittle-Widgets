#region jsDoc
/// @func    WWCheckbox()
/// @desc    Sprite checkbox that toggles between checked and unchecked states.
/// @returns {Struct.WWCheckbox}
#endregion
function WWCheckbox() : WWButtonSprite() constructor {
	debug_name = "WWCheckbox";
	
	#region Public
	
		#region Builder Functions
			
			#region jsDoc
			/// @func    set_checkbox_sprites()
			/// @desc    Sets the sprites used for the checked and unchecked states.
			/// @self    WWCheckbox
			/// @param   {Asset.GMSprite} checked_sprite : Sprite used when checked.
			/// @param   {Asset.GMSprite} unchecked_sprite : Sprite used when unchecked.
			/// @returns {Struct.WWCheckbox}
			#endregion
			static set_checkbox_sprites = function(_checked_sprite=s9CheckBoxChecked, _unchecked_sprite=s9CheckBoxUnchecked) {
				/// NOTE: These are the default structure of GUI button sprites
				/// image_index[0] = idle; no interaction;
				/// image_index[1] = mouse over; the mouse is over it;
				/// image_index[2] = mouse down; actively being pressed;
				/// image_index[3] = disabled; not allowed to interact with;
				
				sprite_checked = _checked_sprite;
				sprite_unchecked = _unchecked_sprite;
				
				var _sprite = (is_checked) ? sprite_checked : sprite_unchecked;
				set_sprite(_sprite);
				
				return self;
			}
			
			#region jsDoc
			/// @func    set_value()
			/// @desc    Sets whether the checkbox is checked.
			/// @self    WWCheckbox
			/// @param   {Bool} is_checked : True to check, false to uncheck.
			/// @returns {Struct.WWCheckbox}
			#endregion
			static set_value = function(_is_checked) {
				is_checked = _is_checked;
				
				var _sprite = (is_checked) ? sprite_checked : sprite_unchecked;
				set_sprite(_sprite);
				
				return self;
			}
			
			#region jsDoc
			/// @func    set_checked()
			/// @desc    Sets whether the checkbox is checked.
			/// @self    WWCheckbox
			/// @param   {Bool} is_checked : True to check, false to uncheck.
			/// @returns {Struct.WWCheckbox}
			#endregion
			static set_checked = set_value;
			
			#region jsDoc
			/// @func    set_callback()
			/// @desc    Sets the callback invoked when the checkbox is released (after toggle).
			/// @self    WWCheckbox
			/// @param   {Function} callback : Function called with (is_checked).
			/// @returns {Struct.WWCheckbox}
			#endregion
			static set_callback = function(_callback) {
				__callback__ = _callback;

				var _self = self;
				on_released(method({this: _self, callback: _callback}, function() {
					callback(this.is_checked);
				}));

				return self;
			};

		#endregion
		
		#region Events
			
			on_released(function(){
				is_checked = !is_checked;
				sprite_index = (is_checked) ? sprite_checked : sprite_unchecked;
			})
			
			
		#endregion
		
		#region Variables
			
			is_checked = false;
			
			sprite_checked = s9CheckBoxChecked;
			sprite_unchecked = s9CheckBoxUnchecked;
			
			set_sprite(sprite_unchecked);
			
		#endregion
	
		#region Functions
			
			#region jsDoc
			/// @func    get_value()
			/// @desc    Returns whether the checkbox is checked. Alias of get_checked().
			/// @self    WWCheckbox
			/// @returns {Bool}
			#endregion
			static get_value = function() {
				//the only reason this is a function is so it shows up better in feather
				
				return is_checked;
			}
			
			#region jsDoc
			/// @func    get_checked()
			/// @desc    Returns if the checkbox is checked
			/// @self    WWCheckbox
			/// @returns {Bool}
			#endregion
			static get_checked = get_value;
			
			#region jsDoc
			/// @func    get_checkbox_sprites()
			/// @desc    Returns the sprites used for the checked and unchecked states.
			/// @self    WWCheckbox
			/// @returns {Struct} sprites_struct_with_checked_unchecked
			#endregion
			static get_checkbox_sprites = function() {
				return {
					checked: sprite_checked,
					unchecked: sprite_unchecked,
				};
			};

			#region jsDoc
			/// @func    get_callback()
			/// @desc    Returns the current release callback.
			/// @self    WWCheckbox
			/// @returns {Function} callback_or_undefined
			#endregion
			static get_callback = function() {
				return __callback__;
			};
			
			#region jsDoc
			/// @func    toggle()
			/// @desc    Toggles the checkbox between checked and unchecked.
			/// @self    WWCheckbox
			/// @returns {Struct.WWCheckbox}
			#endregion
			static toggle = function() {
				return set_value(!is_checked);
			};
			
		#endregion
	
	#endregion
	
	#region Private
		
		#region Variables
			
			__callback__ = undefined;
			
		#endregion
		
		#region Functions
			
			
		#endregion
		
	#endregion
}

