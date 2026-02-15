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
			/// @param   {Function} callback : Function called on release.
			/// @returns {Struct.WWButtonSprite}
			#endregion
			static set_callback = function(_callback) {
				__callback__ = _callback;
				on_released(__callback__);
				return self;
			};

		#endregion
		
		#region Events
			
			// Theme-driven draw path: only references theme when values are undefined.
			on_pre_draw(function(_input) {
				if (!visible) return;
				
				// If user explicitly set a sprite, let base WWSprite draw it.
				if (sprite_index != undefined) return;
				
				__recalc_visual_state__();
				
				var _t = wwThemeGet();
				var _missing_color = WW_COLOR_MISSING_THEME;
				var _missing = false;
				
				var _spr;
				var _bg;
				
				switch (__theme_kind__) {
					case __WW_Theme_Kind.Checkbox:
						// Checkbox
						_spr = sprite_index ?? ((is_checked)
							? (sprite_checked ?? _t.assets.sprites.checkbox_checked)
							: (sprite_unchecked ?? _t.assets.sprites.checkbox_unchecked));
						_bg = _t.components.checkbox.bg;
						break;
					case __WW_Theme_Kind.ButtonText:
						// Button (text variant sprite)
						_spr = sprite_index ?? _t.assets.sprites.button_text;
						_bg = _t.components.button.bg;
						break;
					case __WW_Theme_Kind.Slider:
						// Slider thumb (uses slider thumb bg paints)
						_spr = sprite_index ?? (_t.assets.sprites.slider_thumb ?? _t.assets.sprites.button);
						_bg = _t.components.slider.thumb_bg;
						break;
					case __WW_Theme_Kind.Button:
						// Button
						_spr = sprite_index ?? _t.assets.sprites.button;
						_bg = _t.components.button.bg;
						break;
					default:
						//todo:
						break;
				}
				
				// Missing sprite? Draw something obvious instead of silently failing.
				if (_spr == undefined || !sprite_exists(_spr)) {
					_missing = true;
					_spr = _t.assets.sprites.pixel;
					if (_spr == undefined) _spr = spr_ww_pixel;
				}
				if (_spr == undefined || !sprite_exists(_spr)) return;
				
				// Missing/malformed paints? Use magenta so it stands out.
				var _paint = { color: _missing_color, alpha: 1 };
				if (is_struct(_bg)) {
					_paint = _bg.normal;
					switch (__visual_state__) {
						case 3: _paint = _bg.disabled; break;
						case 2: _paint = _bg.active; break;
						case 1: _paint = _bg.hover; break;
						case 4: _paint = _bg.focused; break;
						default: break;
					}
				}
				if (!is_struct(_paint) || !variable_struct_exists(_paint, "color") || !variable_struct_exists(_paint, "alpha")) {
					_missing = true;
					_paint = { color: _missing_color, alpha: 1 };
				}
				
				if (!is_struct(_bg)) {
					_missing = true;
				}
				
				if (_missing) {
					_paint = { color: _missing_color, alpha: 1 };
				}
				
				var _blend  = image_blend;
				var _alpha  = image_alpha;
				if (_blend == undefined) _blend = _paint.color;
				if (_alpha == undefined) _alpha = _paint.alpha;
				if (_missing) {
					_blend = _missing_color;
					_alpha = 1;
				}
				var _xscale = image_xscale ?? 1;
				var _yscale = image_yscale ?? 1;
				var _frame  = (image_index ?? 0);
				if (_frame < 0) _frame = 0;
				
				if (_alpha == 0) return;
				if (_xscale == 0) return;
				if (_yscale == 0) return;
				
				if (_alpha == 1)
				&& (_blend == c_white)
				&& (_xscale == 1)
				&& (_yscale == 1) {
					draw_sprite_stretched(
						_spr,
						_frame,
						x,
						y,
						width,
						height
					);
				}
				else {
					draw_sprite_stretched_ext(
						_spr,
						_frame,
						x,
						y,
						width * _xscale,
						height * _yscale,
						_blend,
						_alpha
					);
				}
			});
			
			
		#endregion
		
		#region Variables
			
			__visual_state__ = 0;
			__theme_kind__ = __WW_Theme_Kind.Button;
			
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