#region jsDoc
/// @func    WWDropdownBasic()
/// @desc    Bare-bones option dropdown: header text reflects selected row.
/// @returns {Struct.WWDropdownBasic}
#endregion
function WWDropdownBasic() : WWDropdown() constructor {
	debug_name = "WWDropdownBasic";
	
	#region Public
		#region Builder Functions
		static set_options = function(_options=[]) {
			__options__ = is_array(_options) ? _options : [_options];
			set_dropdown_array(__options__);
			return self;
		}
		
		static add_option = function(_label) {
			array_push(__options__, _label);
			add(_label);
			return self;
		}
		#endregion
		
		#region Variables
			__options__ = [];
		#endregion
		
		#region Functions
			static get_options = function() {
				return __options__;
			}
			
			static get_selected_text = function() {
				return get_text();
			}
		#endregion
	#endregion
	
	set_text("Select...");
}
