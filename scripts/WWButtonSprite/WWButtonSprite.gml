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
				
				var _spr;
				var _bg;
				
				switch (__theme_kind__) {
					case 1:
						// Checkbox
						_spr = sprite_index ?? ((is_checked)
							? (sprite_checked ?? _t.assets.sprites.checkbox_checked)
							: (sprite_unchecked ?? _t.assets.sprites.checkbox_unchecked));
						_bg = _t.components.checkbox.bg;
						break;
					case 2:
						// Button (text variant sprite)
						_spr = sprite_index ?? _t.assets.sprites.button_text;
						_bg = _t.components.button.bg;
						break;
					default:
						// Button
						_spr = sprite_index ?? _t.assets.sprites.button;
						_bg = _t.components.button.bg;
						break;
				}
				
				if (!sprite_exists(_spr)) return;
				
				var _paint = _bg.normal;
				switch (__visual_state__) {
					case 3: _paint = _bg.disabled; break;
					case 2: _paint = _bg.active; break;
					case 1: _paint = _bg.hover; break;
					case 4: _paint = _bg.focused; break;
					default: break;
				}
				
				var _blend  = image_blend ?? _paint.color;
				var _alpha  = image_alpha ?? _paint.alpha;
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
			__theme_kind__ = 0; // 0=button, 1=checkbox, 2=button_text
			
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