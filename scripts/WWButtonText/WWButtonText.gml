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
			/// @param   {Real} color : Color value.
			/// @returns {Struct.WWButtonText}
			#endregion
			static set_text_color = function(_color=c_white) {
				text_component.set_text_color(_color);
				
				return self;
			}
			#region jsDoc
			/// @func    set_text_alpha()
			/// @desc    Sets the label text alpha.
			/// @self    WWButtonText
			/// @param   {Real} alpha : Alpha value.
			/// @returns {Struct.WWButtonText}
			#endregion
			static set_text_alpha = function(_alpha=1) {
				text_component.set_text_alpha(_alpha);
				return self;
			}
			#region jsDoc
			/// @func    set_text_processor()
			/// @desc    Sets the label text processor (bbcode/markdown/css/etc).
			/// @self    WWButtonText
			/// @param   {Any} proc_or_name : Processor function or name.
			/// @returns {Struct.WWButtonText}
			#endregion
			static set_text_processor = function(_proc_or_name) {
				text_component.set_text_processor(_proc_or_name);
				if (!__size_set__) {
					set_sprite_to_auto_wrap();
				}
				return self;
			}
			// Child wrapper parity: WWLabel exposes set_color as an alias.
			static set_color = set_text_color;
			
			#region jsDoc
			/// @func    set_sprite_to_auto_wrap()
			/// @desc    Auto-sizes the button to fit the label using the current nine-slice margins.
			/// @self    WWButtonText
			/// @returns {Struct.WWButtonText}
			#endregion
			static set_sprite_to_auto_wrap = function() {
				var _theme_spr = wwThemeGetSprite(
					"button_text.sprite.main.idle",
					"button_text.sprite.main"
				);
				var _spr = sprite_index ?? _theme_spr;
				if (_spr == undefined || !sprite_exists(_spr)) {
					_spr = spr_ww_rr9_r4_all;
				}
				var _slice = sprite_get_nineslice(_spr);
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
			#region jsDoc
			/// @func    set_text_click_offset()
			/// @desc    Sets the label offset relative to the button. While pressed.
			/// @self    WWButtonText
			/// @param   {Real} click_y : Additional Y offset while pressed.
			/// @returns {Struct.WWButtonText}
			#endregion
			static set_text_click_offset = function(_click_y=text.x_offset) {
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
				y_offset:0,
				click_yoff:2,
			}
			
			// Theme-driven sprite: only referenced when sprite_index is undefined.
			__theme_sprite_key_main__ = "button_text.sprite.main";
			__theme_sprite_key_state_prefix__ = "button_text.sprite.main";
			__theme_color_prefix__ = "button_text.color.main";
			__theme_alpha_prefix__ = "button_text.alpha.main";
			sprite_index = undefined;
			set_sprite_to_auto_wrap();
			
			
		#endregion
		
		#region Functions
			
			#region jsDoc
			/// @func    get_sprite_to_auto_wrap()
			/// @desc    Returns the auto-wrap sizing info the button would use for the current sprite + label.
			/// @self    WWButtonText
			/// @returns {Struct} info_struct_with_width_height_and_slice
			#endregion
			static get_sprite_to_auto_wrap = function() {
				var _theme_spr = wwThemeGetSprite(
					"button_text.sprite.main.idle",
					"button_text.sprite.main"
				);
				var _spr = sprite_index ?? _theme_spr;
				if (_spr == undefined || !sprite_exists(_spr)) {
					_spr = spr_ww_rr9_r4_all;
				}
				var _slice = sprite_get_nineslice(_spr);
				var _width  = text_component.width  + (_slice.left + _slice.right);
				var _height = text_component.height + (_slice.top  + _slice.bottom);
				return {
					width: _width,
					height: _height,
					left: _slice.left,
					top: _slice.top,
					right: _slice.right,
					bottom: _slice.bottom,
				};
			};
			
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
			// Child wrapper parity: WWLabel exposes set_color as an alias.
			static get_color = get_text_color;
			
			#region jsDoc
			/// @func    get_text_alpha()
			/// @desc    Returns the current label alpha.
			/// @self    WWButtonText
			/// @returns {Real} alpha_value
			#endregion
			static get_text_alpha = function() {
				return text_component.get_text_alpha();
			};
			
			#region jsDoc
			/// @func    get_text_processor()
			/// @desc    Returns the last processor value set via set_text_processor().
			/// @self    WWButtonText
			/// @returns {Any} proc_or_name
			#endregion
			static get_text_processor = function() {
				return text_component.get_text_processor();
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
			
			#region jsDoc
			/// @func    get_text_click_offset()
			/// @desc    Returns the configured label offsets.
			/// @self    WWButtonText
			/// @returns {Real} click_y
			#endregion
			static get_text_click_offset = function() {
				return text.click_yoff;
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


