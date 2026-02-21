#region jsDoc
/// @func    WWIcon()
/// @desc    General-purpose icon renderer (Font Awesome glyph or sprite).
///          This is render-only: no button/focus/input behavior.
/// @returns {Struct.WWIcon}
#endregion
function WWIcon() : WWCore() constructor {
	debug_name = "WWIcon";
	
	#region Public
		#region Builder Functions
			static set_icon_sprite = function(_sprite, _subimg=0) {
				icon_mode = "sprite";
				icon_sprite = _sprite;
				icon_subimg = _subimg;
				return self;
			};

			static set_icon_fa = function(_icon, _style="solid") {
				icon_mode = "fa";
				if (is_real(_icon)) {
					icon_fa_packed = _icon;
				}
				else {
					if (__fa_ready__) icon_fa_packed = fa_icon_get(_icon, _style);
					else icon_fa_packed = -1;
				}
				return self;
			};

			static set_icon_fa_packed = function(_packed=-1) {
				icon_mode = "fa";
				icon_fa_packed = _packed;
				return self;
			};

			static clear_icon = function() {
				icon_mode = "none";
				icon_sprite = undefined;
				icon_fa_packed = -1;
				return self;
			};

			static set_fallback_text = function(_text="") {
				fallback_text = string(_text);
				return self;
			};

			static set_icon_scale = function(_scale=1) {
				icon_scale = max(0, _scale);
				return self;
			};

			static set_keep_aspect = function(_enabled=true) {
				keep_aspect = _enabled;
				return self;
			};

			static set_allow_upscale = function(_enabled=false) {
				allow_upscale = _enabled;
				return self;
			};

			static set_icon_insets = function(_left=0, _top=0, _right=0, _bottom=0) {
				inset_left = max(0, _left);
				inset_top = max(0, _top);
				inset_right = max(0, _right);
				inset_bottom = max(0, _bottom);
				return self;
			};

			static set_icon_padding = function(_pad=0) {
				return set_icon_insets(_pad, _pad, _pad, _pad);
			};

			static set_icon_color = function(_color=c_white, _alpha=1) {
				icon_color = _color;
				icon_alpha = _alpha;
				auto_icon_paint = false;
				return self;
			};
			static set_color = set_icon_color;

			static set_auto_icon_paint = function(_enabled=true) {
				auto_icon_paint = _enabled;
				return self;
			};
			
			#region jsDoc
			/// @func    set_theme_keys()
			/// @desc    Sets theme key prefixes used when auto icon paint is enabled.
			/// @self    WWIcon
			/// @param   {String} color_prefix : e.g. "button.color.text"
			/// @param   {String} alpha_prefix : e.g. "button.alpha.text"
			/// @param   {Struct|Undefined} state_source : Optional state source struct (defaults to self).
			/// @returns {Struct.WWIcon}
			#endregion
			static set_theme_keys = function(
				_color_prefix = "button.color.text",
				_alpha_prefix = "button.alpha.text",
				_state_source = undefined
			) {
				__theme_color_prefix__ = _color_prefix;
				__theme_alpha_prefix__ = _alpha_prefix;
				__theme_state_source__ = _state_source;
				return self;
			};
		#endregion

		#region Variables
			icon_mode = "none"; // "none" | "sprite" | "fa"
			icon_sprite = undefined;
			icon_subimg = 0;
			icon_fa_packed = -1;
			fallback_text = "";
			icon_scale = 1;
			keep_aspect = true;
			allow_upscale = false;
			inset_left = 0;
			inset_top = 0;
			inset_right = 0;
			inset_bottom = 0;
			auto_icon_paint = false;
			icon_color = undefined;
			icon_alpha = undefined;
			__fa_ready__ = false;
			__theme_color_prefix__ = "button.color.text";
			__theme_alpha_prefix__ = "button.alpha.text";
			__theme_state_source__ = undefined;
		#endregion

		#region Functions
			static get_icon_mode = function() { return icon_mode; };
			static get_icon_sprite = function() { return icon_sprite; };
			static get_icon_subimg = function() { return icon_subimg; };
			static get_icon_fa_packed = function() { return icon_fa_packed; };
			static get_icon_scale = function() { return icon_scale; };
			static get_keep_aspect = function() { return keep_aspect; };
			static get_allow_upscale = function() { return allow_upscale; };
			static get_icon_insets = function() {
				return {
					left: inset_left,
					top: inset_top,
					right: inset_right,
					bottom: inset_bottom,
				};
			};
			static get_icon_color = function() { return icon_color; };
			static get_icon_alpha = function() { return icon_alpha; };
			static get_auto_icon_paint = function() { return auto_icon_paint; };
			static get_fallback_text = function() { return fallback_text; };
		#endregion
	#endregion

	#region Private
		#region Functions
			static __compute_fa_ready__ = function() {
				if (!WW_FONT_AWESOME_ENABLED) return false;
				if (asset_get_index("fa_icon_get") == -1) return false;
				if (asset_get_index("fa_get_font") == -1) return false;
				if (asset_get_index("fa_get_ord") == -1) return false;
				var _fa_font_asset = asset_get_index("fnt_fa_solid");
				if (_fa_font_asset == -1 || !font_exists(_fa_font_asset)) return false;
				return true;
			};
			
			static __theme_state_specifier__ = function() {
				var _src = __theme_state_source__;
				if (is_undefined(_src) || _src == noone) _src = self;
				
				var _state = _src.__visual_state__;
				
				switch (_state) {
					case __WW_STATE.HOVER: return "hover";
					case __WW_STATE.ACTIVE: return "active";
					case __WW_STATE.DISABLED: return "disabled";
					case __WW_STATE.NAV: return "nav";
					default: return "idle";
				}
			};

			static __resolved_icon_paint__ = function() {
				if (auto_icon_paint) {
					var _state = __theme_state_specifier__();
					return {
						color: wwThemeGetColor(
							__theme_color_prefix__ + "." + _state,
							__theme_color_prefix__ + ".idle",
							__theme_color_prefix__
						),
						alpha: wwThemeGetAlpha(
							__theme_alpha_prefix__ + "." + _state,
							__theme_alpha_prefix__ + ".idle",
							__theme_alpha_prefix__
						)
					};
				}
				return { color: icon_color, alpha: icon_alpha };
			};

			static __get_content_rect__ = function() {
				var _w = max(1, width - inset_left - inset_right);
				var _h = max(1, height - inset_top - inset_bottom);
				return {
					x: x + inset_left,
					y: y + inset_top,
					w: _w,
					h: _h,
				};
			};

			static __fit_size__ = function(_src_w, _src_h, _box_w, _box_h) {
				if (_src_w <= 0 || _src_h <= 0) return { w: 0, h: 0 };
				if (!keep_aspect) {
					var _dw = _box_w * icon_scale;
					var _dh = _box_h * icon_scale;
					if (!allow_upscale) {
						_dw = min(_dw, _src_w);
						_dh = min(_dh, _src_h);
					}
					return { w: max(1, _dw), h: max(1, _dh) };
				}
				var _s = min(_box_w / _src_w, _box_h / _src_h) * icon_scale;
				if (!allow_upscale) _s = min(_s, 1);
				return { w: max(1, _src_w * _s), h: max(1, _src_h * _s) };
			};

			static __draw_fallback__ = function(_color, _alpha) {
				if (fallback_text == "") return;
				var _rect = __get_content_rect__();
				var _old_halign = draw_get_halign();
				var _old_valign = draw_get_valign();
				var _old_color = draw_get_color();
				var _old_alpha = draw_get_alpha();
				draw_set_halign(fa_center);
				draw_set_valign(fa_middle);
				draw_set_color(_color);
				draw_set_alpha(_alpha * (image_alpha ?? 1));
				draw_text(_rect.x + _rect.w * 0.5, _rect.y + _rect.h * 0.5, fallback_text);
				draw_set_halign(_old_halign);
				draw_set_valign(_old_valign);
				draw_set_color(_old_color);
				draw_set_alpha(_old_alpha);
			};
		#endregion
	#endregion

	on_pre_draw(function(_input) {
		if (!visible) return;
		if (image_alpha == 0) return;
		var _need_paint = auto_icon_paint || is_undefined(icon_color) || is_undefined(icon_alpha);
		var _paint = _need_paint ? __resolved_icon_paint__() : undefined;
		var _draw_color = icon_color ?? (_paint.color ?? c_white);
		var _draw_alpha = icon_alpha ?? (_paint.alpha ?? 1);
		var _rect = __get_content_rect__();
		var _did_draw = false;

		switch (icon_mode) {
			case "sprite": {
				if (icon_sprite != undefined && sprite_exists(icon_sprite)) {
					var _sw = max(1, sprite_get_width(icon_sprite));
					var _sh = max(1, sprite_get_height(icon_sprite));
					var _dst = __fit_size__(_sw, _sh, _rect.w, _rect.h);
					var _dx = _rect.x + floor((_rect.w - _dst.w) * 0.5);
					var _dy = _rect.y + floor((_rect.h - _dst.h) * 0.5);
					draw_sprite_stretched_ext(icon_sprite, icon_subimg, _dx, _dy, _dst.w, _dst.h, _draw_color, _draw_alpha * (image_alpha ?? 1));
					_did_draw = true;
				}
				break;
			}
			case "fa": {
				if (__fa_ready__ && is_real(icon_fa_packed) && icon_fa_packed >= 0) {
					var _font = fa_get_font(icon_fa_packed);
					if (_font != -1 && font_exists(_font)) {
						var _chr = chr(fa_get_ord(icon_fa_packed));
						var _old_font = draw_get_font();
						var _old_halign = draw_get_halign();
						var _old_valign = draw_get_valign();
						var _old_color = draw_get_color();
						var _old_alpha = draw_get_alpha();
						draw_set_font(_font);
						draw_set_halign(fa_center);
						draw_set_valign(fa_middle);
						draw_set_color(_draw_color);
						draw_set_alpha(_draw_alpha * (image_alpha ?? 1));
						var _gw = max(1, string_width(_chr));
						var _gh = max(1, string_height(_chr));
						var _dst2 = __fit_size__(_gw, _gh, _rect.w, _rect.h);
						var _sx = _dst2.w / _gw;
						var _sy = _dst2.h / _gh;
						draw_text_transformed(_rect.x + _rect.w * 0.5, _rect.y + _rect.h * 0.5, _chr, _sx, _sy, 0);
						draw_set_font(_old_font);
						draw_set_halign(_old_halign);
						draw_set_valign(_old_valign);
						draw_set_color(_old_color);
						draw_set_alpha(_old_alpha);
						_did_draw = true;
					}
				}
				break;
			}
		}

		if (!_did_draw) {
			__draw_fallback__(_draw_color, _draw_alpha);
		}
	});

	static __base_cleanup__ = WWCore.__cleanup__;
	static __cleanup__ = function() {
		__base_cleanup__();
		// Reserved for future buffer-based icon backends.
	};

	__fa_ready__ = __compute_fa_ready__();
}
