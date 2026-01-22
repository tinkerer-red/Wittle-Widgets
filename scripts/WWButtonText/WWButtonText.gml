#region jsDoc
/// @func    WWButtonText()
/// @desc    Sprite button with an embedded label component.
/// @self    WWButtonText
/// @returns {Struct.WWButtonText}
#endregion
function WWButtonText() : WWButtonSprite() constructor {
	debug_name = "WWButtonText";
	
	#region Public
		
		#region Builder Functions
			#region jsDoc
			/// @func    set_text()
			/// @desc    Sets the label text. If size is not user-set, re-wraps the sprite to fit the text.
			/// @self    WWButtonText
			/// @param   {String} text : Label text.
			/// @returns {Struct.WWButtonText}
			#endregion
			static set_text = function(_text="DefaultText") {
				text_component.set_text(_text);
				if (!__size_set__) {
					set_sprite_to_auto_wrap()
				}
				return self;
			}
			#region jsDoc
			/// @func    set_text_font()
			/// @desc    Sets the font used by the label.
			/// @self    WWButtonText
			/// @param   {Asset.GMFont} font : Font asset.
			/// @returns {Struct.WWButtonText}
			#endregion
			static set_text_font = function(_font=fGUIDefault) {
				text_component.set_text_font(_font);
				if (!__size_set__) {
					set_sprite_to_auto_wrap()
				}
				return self;
			}
			#region jsDoc
			/// @func    set_text_color()
			/// @desc    Sets the label text color.
			/// @self    WWButtonText
			/// @param   {Real} _color : Color value.
			/// @returns {Struct.WWButtonText}
			#endregion
			static set_text_color = function(_color=c_white) {
				text_component.set_text_color(_color);
				
				return self;
			}
			#region jsDoc
			/// @func    set_sprite_to_auto_wrap()
			/// @desc    Auto-sizes the button to fit the label using the current nine-slice margins.
			/// @self    WWButtonText
			/// @returns {Struct.WWButtonText}
			#endregion
			static set_sprite_to_auto_wrap = function() {
				
				var _slice = sprite_get_nineslice(sprite_index);
				var _width  = text_component.width  + (_slice.left + _slice.right);
				var _height = text_component.height + (_slice.top  + _slice.bottom);
				
				//update internal variables
				__set_size__(_width, _height);
				set_text_offsets(_slice.left, _slice.top, _slice.top + text.click_yoff);
				
				return self;
			}
			#region jsDoc
			/// @func    set_text_offsets()
			/// @desc    Sets the label offset relative to the button. While pressed, click_y is applied in addition to y.
			/// @self    WWButtonText
			/// @param   {Real} x : X offset.
			/// @param   {Real} y : Y offset.
			/// @param   {Real} click_y : Additional Y offset while pressed.
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
			
			text_component = new WWLabel();
			add(text_component);
			
		#endregion
		
		#region Events
			
			on_held(function(_input) {
				if (__is_hovered__) {
					text_component.__set_offset__(text.x_offset, text.click_yoff);
				}
				//else {
				//	text_component.__set_offset__(text.x_offset, text.y_offset);
				//}
			})
			var _func = function(_input) {
				text_component.__set_offset__(text.x_offset, text.y_offset);
			}
			on_hover_exit(_func)
			on_released(_func)
			
		#endregion
		
		#region Variables
			
			text = {
				x_offset:0,
				x_offset:0,
				click_yoff:2,
			}
			
			set_sprite(s9ButtonText);
			set_sprite_to_auto_wrap();
			__set_size__(sprite_get_width(s9ButtonText), sprite_get_height(s9ButtonText))
			
		#endregion
		
		#region Functions
			
			#region jsDoc
			/// @func    get_text()
			/// @desc    Returns the current label text.
			/// @self    WWButtonText
			/// @returns {String} text_value
			#endregion
			static get_text = function() {
				return text_component.get_text();
			};
			#region jsDoc
			/// @func    get_text_font()
			/// @desc    Returns the font currently used by the label.
			/// @self    WWButtonText
			/// @returns {Asset.GMFont} font_asset
			#endregion
			static get_text_font = function() {
				return text_component.get_text_font();
			};
			#region jsDoc
			/// @func    get_text_color()
			/// @desc    Returns the current label text color.
			/// @self    WWButtonText
			/// @returns {Real} color_value
			#endregion
			static get_text_color = function() {
				return text_component.get_text_color();
			};
			#region jsDoc
			/// @func    get_text_offsets()
			/// @desc    Returns the configured label offsets.
			/// @self    WWButtonText
			/// @returns {Struct} offsets_struct_with_x_y_click_y
			#endregion
			static get_text_offsets = function() {
				return {
					x: text.x_offset,
					y: text.y_offset,
					click_y: text.click_yoff,
				};
			};
			
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
	
	text_component.set_text("")
	
}


