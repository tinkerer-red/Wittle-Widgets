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

			#region jsDoc
			/// @func    set_theme_keys()
			/// @desc    Sets theme key prefixes used for sprite/color/alpha lookup.
			///          For checkbox-style variants, checked/unchecked keys can be provided.
			/// @self    WWButtonSprite
			/// @param   {String} sprite_main : Base sprite key (e.g. "button.sprite.main").
			/// @param   {String} sprite_state_prefix : Stateful sprite prefix (e.g. "button.sprite.main").
			/// @param   {String} color_prefix : Stateful color prefix (e.g. "button.color.main").
			/// @param   {String} alpha_prefix : Stateful alpha prefix (e.g. "button.alpha.main").
			/// @param   {String|Undefined} sprite_checked : Optional checked sprite key.
			/// @param   {String|Undefined} sprite_unchecked : Optional unchecked sprite key.
			/// @returns {Struct.WWButtonSprite}
			#endregion
			static set_theme_keys = function(
				_sprite_main,
				_sprite_state_prefix,
				_color_prefix,
				_alpha_prefix,
				_sprite_checked = undefined,
				_sprite_unchecked = undefined
			) {
				if (!is_undefined(_sprite_main)) __theme_sprite_key_main__ = _sprite_main;
				if (!is_undefined(_sprite_state_prefix)) __theme_sprite_key_state_prefix__ = _sprite_state_prefix;
				if (!is_undefined(_color_prefix)) __theme_color_prefix__ = _color_prefix;
				if (!is_undefined(_alpha_prefix)) __theme_alpha_prefix__ = _alpha_prefix;
				if (!is_undefined(_sprite_checked)) __theme_sprite_key_checked__ = _sprite_checked;
				if (!is_undefined(_sprite_unchecked)) __theme_sprite_key_unchecked__ = _sprite_unchecked;
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
				var _state = __theme_state_specifier__();
				var _spr = __theme_resolve_sprite__(_state);
				if (_spr == undefined || !sprite_exists(_spr)) return;

				var _blend  = image_blend;
				var _alpha  = image_alpha;
				if (_blend == undefined) _blend = __theme_resolve_color__(_state);
				if (_alpha == undefined) _alpha = __theme_resolve_alpha__(_state);
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
			
			__visual_state__ = __WW_STATE.NORMAL;
			__theme_sprite_key_main__ = "button.sprite.main";
			__theme_sprite_key_state_prefix__ = "button.sprite.main";
			__theme_sprite_key_checked__ = undefined;
			__theme_sprite_key_unchecked__ = undefined;
			__theme_color_prefix__ = "button.color.main";
			__theme_alpha_prefix__ = "button.alpha.main";
			
		#endregion
		
		#region Functions
			static __theme_state_specifier__ = function() {
				switch (__visual_state__) {
					case __WW_STATE.HOVER: return "hover";
					case __WW_STATE.ACTIVE: return "active";
					case __WW_STATE.DISABLED: return "disabled";
					case __WW_STATE.NAV: return "nav";
					case __WW_STATE.NORMAL: return "idle";
					default: return "idle";
				}
			};

			static __theme_resolve_sprite__ = function(_state) {
				if (sprite_index != undefined) return sprite_index;

				var _use_checkbox = variable_struct_exists(self, "is_checked");
				if (_use_checkbox) {
					if (is_checked) {
						return sprite_checked
							?? wwThemeGetSprite(
								__theme_sprite_key_checked__,
								__theme_sprite_key_state_prefix__ + ".checked",
								__theme_sprite_key_state_prefix__ + "." + _state,
								__theme_sprite_key_state_prefix__ + ".idle",
								__theme_sprite_key_main__
							);
					}
					return sprite_unchecked
						?? wwThemeGetSprite(
							__theme_sprite_key_unchecked__,
							__theme_sprite_key_state_prefix__ + ".unchecked",
							__theme_sprite_key_state_prefix__ + "." + _state,
							__theme_sprite_key_state_prefix__ + ".idle",
							__theme_sprite_key_main__
						);
				}

				return wwThemeGetSprite(
					__theme_sprite_key_state_prefix__ + "." + _state,
					__theme_sprite_key_state_prefix__ + ".idle",
					__theme_sprite_key_main__
				);
			};

			static __theme_resolve_color__ = function(_state) {
				return wwThemeGetColor(
					__theme_color_prefix__ + "." + _state,
					__theme_color_prefix__ + ".idle",
					__theme_color_prefix__
				);
			};

			static __theme_resolve_alpha__ = function(_state) {
				return wwThemeGetAlpha(
					__theme_alpha_prefix__ + "." + _state,
					__theme_alpha_prefix__ + ".idle",
					__theme_alpha_prefix__
				);
			};
			
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
