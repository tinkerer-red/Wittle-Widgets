#region jsDoc
/// @func    GUICompRadioMenu()
/// @desc    A menu that manages a group of radio buttons, ensuring only one is selected.
/// @return  {Struct.GUICompRadioMenu}
#endregion
function GUICompRadioMenu() : WWCore() constructor {
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
                var option = new WWCheckbox()
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
function GUICompRadioOption() : WWCore() constructor {
	debug_name = "GUICompRadioOption";
	
	#region Public
		
		#region Builder Functions
			
			#region Sprite
			#region jsDoc
			/// @func    set_sprite()
			/// @desc    Sets all default GML object's sprite variables with a given sprite.
			/// @self    GUICompCore
			/// @param   {Asset.GMSprite} sprite : The sprite to apply to the component.
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_sprite = function(_sprite) {
				button.set_sprite(_sprite);
				return self;
			}
			#region jsDoc
			/// @func    set_sprite_angle()
			/// @desc    Sets the angle of the sprite to be drawn.
			/// @self    GUICompCore
			/// @param   {Real} angle : The angle of the sprite.
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_sprite_angle = function(_angle) {
				button.set_sprite_angle(_angle);
				return self;
			}
			#region jsDoc
			/// @func    set_sprite_color()
			/// @desc    Sets the color of the sprite to be drawn.
			/// @self    GUICompCore
			/// @param   {Real} color : The color of the sprite.
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_sprite_color = function(_col) {
				button.set_sprite_color(_col);
				return self;
			}
			#region jsDoc
			/// @func    set_sprite_alpha()
			/// @desc    Sets the alpha of the sprite to be drawn.
			/// @self    GUICompCore
			/// @param   {Real} alpha : The alpha of the sprite.
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_sprite_alpha = function(_alpha) {
				button.set_sprite_alpha(_alpha);
				return self;
			}
			#endregion
			
			#region Text
			#region jsDoc
			/// @func    set_text()
			/// @desc    Sets the variables for text drawing
			/// @self    GUICompButtonText
			/// @param   {String} text : The text to write on the button.
			/// @returns {Struct.GUICompButtonText}
			#endregion
			static set_text = function(_text="DefaultText") {
				label.set_text(_text);
				return self;
			}
			#region jsDoc
			/// @func    set_text_font()
			/// @desc    Sets the font which will be used for drawing the text
			/// @self    GUICompButtonText
			/// @param   {Asset.GMFont} font : The font to use when drawing the text
			/// @returns {Struct.GUICompButtonText}
			#endregion
			static set_text_font = function(_font=fGUIDefault) {
				label.set_font(_font)
				return self;
			}
			#region jsDoc
			/// @func    set_text_colors()
			/// @desc    Sets the colors for the text of the button.
			/// @self    GUICompButtonText
			/// @param   {Real} idle_color     : The color to draw the text when the component is idle
			/// @param   {Real} hover_color    : The color to draw the text when the component is hovered or clicked
			/// @param   {Real} disabled_color : The color to draw the text when the component is disabled
			/// @returns {Struct.GUICompButtonText}
			#endregion
			static set_text_colors = function(_idle=c_white, _hover=c_white, _clicked=c_white, _disable=c_grey) {
				label.set_text_colors(_idle, _hover, _clicked, _disable);
				return self;
			}
			#region jsDoc
			/// @func    set_text_alignment()
			/// @desc    Sets how the text is aligned when drawing
			/// @self    GUICompButtonText
			/// @param   {Constant.HAlign} halign : Horizontal alignment
			/// @param   {Constant.VAlign} valign : Vertical alignment
			/// @returns {Struct.GUICompButtonText}
			#endregion
			static set_text_alignment = function(_h=fa_left, _v=fa_top) {
				label.set_text_alignment(_h, _v);
				return self;
			};
			#region jsDoc
			/// @func    set_text_offsets()
			/// @desc    Sets the Text's offsets reletive to the component's x/y. Note: click_y will be applied in addition to the y, when the component is actively being pressed.
			/// @self    GUICompButtonText
			/// @param   {Real} x : The x offset
			/// @param   {Real} y : The y offset
			/// @param   {Real} click_y : The additional y offset used when 
			/// @returns {Struct.GUICompButtonText}
			#endregion
			static set_text_offsets = function(_x=0, _y=0, _click_y=2) {
				label.set_text_offsets(_x, _y, _click_y);
				return self;
			};
			#endregion
			
			static set_callback = function(_callback) {
				var _self = self;
				button.on_released(method({this: _self, callback: _callback}, function(){
					callback(this.is_checked);
				}));
				return self;
			}
			
		#endregion
		
		#region Events
			
			
			
		#endregion
		
		#region Variables
			
			button = new WWCheckbox()
			
			label = new GUICompTextScrolling()
				.set_text_alignment(fa_left, fa_center)
				.set_offset(button.region.get_width(), button.region.get_height()/2)
			
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
