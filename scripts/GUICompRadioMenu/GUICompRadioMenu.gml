#region jsDoc
/// @func    GUICompRadioMenu()
/// @desc    A menu that manages a group of radio buttons, ensuring only one is selected.
/// @return  {Struct.GUICompRadioMenu}
#endregion
function GUICompRadioMenu() : GUICompCore() constructor {
    debug_name = "GUICompRadioMenu";

    #region Public
        
        #region Builder Functions
            
            #region jsDoc
            /// @func    add_option()
            /// @desc    Adds a radio button option to the menu.
			/// @param   {String} label : The text label for the radio button.
			/// @returns {Struct.GUICompCheckbox}
            #endregion
            static add_option = function(_label, _callback) {
                var option = new GUICompCheckbox()
					.set_text(_label)
					.set_callback(_callback ?? function(){})
				
				if (__size_set__) {
					option.set_size(0, 0, 100, 20)
				}
                    
                    
                add(option);
                __reposition_options();
                return option;
            }

            #region jsDoc
            /// @func    get_selected()
            /// @desc    Returns the currently selected option.
			/// @returns {Struct.GUICompCheckbox|Noone}
            #endregion
            static get_selected = function() {
                var _i = 0; repeat(get_children_count()) {
                    var _comp = __children__[_i];
                    if (_comp.is_checked) {
                        return _comp;
                    }
                    _i += 1;
                }
                return noone;
            }

        #endregion
        
        #region Management Functions
            
            #region jsDoc
            /// @func    update_radio_group()
            /// @desc    Ensures only one option is selected at a time.
			/// @param   {Struct.GUICompCheckbox} selected_option : The newly selected option.
            #endregion
            static update_radio_group = function(selected_option) {
                var _i = 0; repeat(get_children_count()) {
                    var _comp = __children__[_i];
                    if (_comp != selected_option) {
                        _comp.is_checked = false;
                    }
                    _i += 1;
                }
            }

            #region jsDoc
            /// @func    __reposition_options()
            /// @desc    Automatically stacks radio buttons vertically.
            #endregion
            static __reposition_options = function() {
                var _y_offset = 0;
                var _i = 0; repeat(get_children_count()) {
                    var _comp = __children__[_i];
                    _comp.set_offset(0, _y_offset);
                    _y_offset += 25;
                    _i += 1;
                }
            }

        #endregion
        
        #region Variables
            set_size(0, 0, 120, 200);
        #endregion

    #endregion
}


#region jsDoc
/// @func    GUICompRadioOption()
/// @desc    A menu that manages a group of radio buttons, ensuring only one is selected.
/// @return  {Struct.GUICompRadioOption}
#endregion
function GUICompRadioOption() : GUICompCore() constructor {
	debug_name = "GUICompTemplate";
	
	#region Public
		
		#region Builder Functions
			
		#endregion
		
		#region Events
			
		#endregion
		
		#region Variables
			
			label = new GUICompCore()
				
			button = new GUICompCheckbox()
				
			add([button, label]);
			
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
