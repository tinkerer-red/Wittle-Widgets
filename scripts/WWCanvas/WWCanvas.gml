#region jsDoc
/// @func    WWCanvas()
/// @desc    Root surface-style component for application-level background planes.
///          Typical use: top-level UI canvas or broad background sections.
///          Visual keys are compiled by `wwThemeBuild` from semantic base colors:
///          - `canvas.color.main.*` derives from `colors.app.*`
///          - `canvas.color.border.*` derives from `colors.outline.*`
/// @returns {Struct.WWCanvas}
#endregion
function WWCanvas() : WWCore() constructor {
	debug_name = "WWCanvas";

	#region Public

		#region Builder Functions
		#region jsDoc
		/// @func    set_theme_role()
		/// @desc    Sets the theme role prefix used for all visual lookups.
		/// @self    WWCanvas
		/// @param   {String} role : Prefix like "canvas", "frame", "panel", "inset", "container".
		/// @returns {Struct.WWCanvas}
		#endregion
		static set_theme_role = function(_role) {
			__set_theme_role__(_role);
			return self;
		}
		#region jsDoc
		/// @func    set_draw_fill()
		/// @desc    Enables or disables drawing of the themed fill layer.
		/// @self    WWCanvas
		/// @param   {Bool} enabled : True to draw the fill.
		/// @returns {Struct.WWCanvas}
		#endregion
		static set_draw_fill = function(_enabled=true) {
			__draw_fill__ = _enabled;
			return self;
		}
		#region jsDoc
		/// @func    set_draw_border()
		/// @desc    Enables or disables drawing of the themed border layer.
		/// @self    WWCanvas
		/// @param   {Bool} enabled : True to draw border.
		/// @returns {Struct.WWCanvas}
		#endregion
		static set_draw_border = function(_enabled=true) {
			__draw_border__ = _enabled;
			return self;
		}
		#endregion

		#region Variables
		__visual_state__ = 0;
		__draw_fill__ = true;
		__draw_border__ = false;
		__theme_role__ = "canvas";
		__theme_sprite_prefix__ = "canvas.sprite.main";
		__theme_color_prefix__ = "canvas.color.main";
		__theme_alpha_prefix__ = "canvas.alpha.main";
		__theme_border_color_prefix__ = "canvas.color.border";
		__theme_border_alpha_prefix__ = "canvas.alpha.border";
		__theme_border_size_prefix__ = "canvas.size.border";
		#endregion

		#region Events
		on_pre_draw(function(_input) {
			if (!visible) return;
			__recalc_visual_state__();

			var _state = __theme_state_specifier__();

			if (__draw_fill__) {
				var _spr = wwThemeGetSprite(
					__theme_sprite_prefix__ + "." + _state,
					__theme_sprite_prefix__ + ".idle",
					__theme_sprite_prefix__
				);
				if (_spr != undefined && sprite_exists(_spr)) {
					var _fill_col = wwThemeGetColor(
						__theme_color_prefix__ + "." + _state,
						__theme_color_prefix__ + ".idle",
						__theme_color_prefix__
					);
					var _fill_alp = wwThemeGetAlpha(
						__theme_alpha_prefix__ + "." + _state,
						__theme_alpha_prefix__ + ".idle",
						__theme_alpha_prefix__
					);
					if (_fill_alp > 0) {
						draw_sprite_stretched_ext(_spr, 0, x, y, width, height, _fill_col, _fill_alp);
					}
				}
			}

			if (__draw_border__) {
				var _thickness = wwThemeGetSize(
					__theme_border_size_prefix__ + "." + _state,
					__theme_border_size_prefix__ + ".idle",
					__theme_border_size_prefix__
				);
				_thickness = max(0, floor(_thickness));
				if (_thickness > 0) {
					var _border_col = wwThemeGetColor(
						__theme_border_color_prefix__ + "." + _state,
						__theme_border_color_prefix__ + ".idle",
						__theme_border_color_prefix__
					);
					var _border_alp = wwThemeGetAlpha(
						__theme_border_alpha_prefix__ + "." + _state,
						__theme_border_alpha_prefix__ + ".idle",
						__theme_border_alpha_prefix__
					);
					if (_border_alp > 0) {
						draw_set_color(_border_col);
						draw_set_alpha(_border_alp);
						for (var _i = 0; _i < _thickness; _i++) {
							draw_rectangle(
								x + _i,
								y + _i,
								x + width - _i,
								y + height - _i,
								true
							);
						}
						draw_set_alpha(1);
					}
				}
			}
		});
		#endregion

		#region Functions
		static __theme_state_specifier__ = function() {
			switch (__visual_state__) {
				case WW_STATE_HOVER: return "hover";
				case WW_STATE_ACTIVE: return "active";
				case WW_STATE_DISABLED: return "disabled";
				case WW_STATE_NAV: return "nav";
				default: return "idle";
			}
		};
		#endregion

	#endregion

	#region Private

		#region Functions
		static __set_theme_role__ = function(_role) {
			__theme_role__ = string_lower(string(_role));
			__theme_sprite_prefix__ = __theme_role__ + ".sprite.main";
			__theme_color_prefix__ = __theme_role__ + ".color.main";
			__theme_alpha_prefix__ = __theme_role__ + ".alpha.main";
			__theme_border_color_prefix__ = __theme_role__ + ".color.border";
			__theme_border_alpha_prefix__ = __theme_role__ + ".alpha.border";
			__theme_border_size_prefix__ = __theme_role__ + ".size.border";
		}
		#endregion

	#endregion
}
