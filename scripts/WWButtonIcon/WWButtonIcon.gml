#region jsDoc
/// @func    WWButtonIcon()
/// @desc    Button with a centered icon child (WWIcon), supporting FA or sprite icons.
/// @returns {Struct.WWButtonIcon}
#endregion
function WWButtonIcon() : WWButtonSprite() constructor {
	debug_name = "WWButtonIcon";

	#region Public
		#region Builder Functions
			static set_size = function(_w, _h) {
				static __base_set_size__ = WWCore.set_size;
				if (keep_square) {
					var _s = max(1, min(_w, _h));
					__base_set_size__(_s, _s);
				}
				else {
					__base_set_size__(_w, _h);
				}
				__layout_icon__();
				return self;
			};

			static set_square_size = function(_size=22) {
				return set_size(_size, _size);
			};

			static set_keep_square = function(_enabled=true) {
				keep_square = _enabled;
				if (keep_square) set_size(width, height);
				return self;
			};

			static set_icon_sprite = function(_sprite, _subimg=0) {
				icon.set_icon_sprite(_sprite, _subimg);
				return self;
			};

			static set_icon_fa = function(_icon, _style="solid") {
				icon.set_icon_fa(_icon, _style);
				return self;
			};

			static set_icon_fa_packed = function(_packed=-1) {
				icon.set_icon_fa_packed(_packed);
				return self;
			};

			static clear_icon = function() {
				icon.clear_icon();
				return self;
			};

			static set_icon_padding = function(_px=0) {
				icon_padding = max(0, _px);
				__layout_icon__();
				return self;
			};
			
			static set_icon_click_offset = function(_click_y=1) {
				icon_click_offset = _click_y;
				return self;
			};

			static set_icon_scale = function(_scale=1) {
				icon.set_icon_scale(_scale);
				return self;
			};

			static set_icon_keep_aspect = function(_enabled=true) {
				icon.set_keep_aspect(_enabled);
				return self;
			};

			static set_icon_allow_upscale = function(_enabled=false) {
				icon.set_allow_upscale(_enabled);
				return self;
			};

			static set_icon_color = function(_color=c_white, _alpha=1) {
				icon_color = _color;
				icon_alpha = _alpha;
				auto_icon_paint = false;
				icon.set_auto_icon_paint(false);
				icon.set_icon_color(_color, _alpha);
				return self;
			};

			static set_auto_icon_paint = function(_enabled=true) {
				auto_icon_paint = _enabled;
				icon.set_auto_icon_paint(false);
				return self;
			};

			static set_fallback_text = function(_text="") {
				icon.set_fallback_text(_text);
				return self;
			};
		#endregion

		#region Components
			icon = new WWIcon().set_size(1, 1);
		#endregion

		#region Variables
			keep_square = true;
			icon_padding = 0;
			icon_click_offset = 1;
			auto_icon_paint = true;
			icon_color = c_white;
			icon_alpha = 1;
		#endregion

		#region Functions
			static get_icon = function() { return icon; };
			static get_keep_square = function() { return keep_square; };
			static get_icon_padding = function() { return icon_padding; };
			static get_icon_click_offset = function() { return icon_click_offset; };
			static get_auto_icon_paint = function() { return auto_icon_paint; };
			static get_icon_color = function() { return icon_color; };
			static get_icon_alpha = function() { return icon_alpha; };
			static get_icon_mode = function() { return icon.get_icon_mode(); };
			static get_icon_sprite = function() { return icon.get_icon_sprite(); };
			static get_icon_subimg = function() { return icon.get_icon_subimg(); };
			static get_icon_fa_packed = function() { return icon.get_icon_fa_packed(); };
			static get_icon_scale = function() { return icon.get_icon_scale(); };
		#endregion
	#endregion

	#region Private
		#region Functions
			static __resolved_icon_paint__ = function() {
				if (!auto_icon_paint) {
					return { color: icon_color, alpha: icon_alpha };
				}
				var _state = __theme_state_specifier__();
				return {
					color: wwThemeGetColor(
						"button.color.text." + _state,
						"button.color.text.idle"
					),
					alpha: wwThemeGetAlpha(
						"button.alpha.text." + _state,
						"button.alpha.text.idle"
					)
				};
			};

			static __layout_icon__ = function() {
				var _left = icon_padding;
				var _top = icon_padding;
				var _right = icon_padding;
				var _bottom = icon_padding;
				var _w = max(1, width - _left - _right);
				var _h = max(1, height - _top - _bottom);
				icon.set_offset(_left, _top);
				icon.set_size(_w, _h);
			};
		#endregion
	#endregion

	on_held(function(_input) {
		if (!__is_pointer_over__) return;
		__layout_icon__();
		icon.__set_offset__(icon.x_offset, icon.y_offset + icon_click_offset);
	});
	
	var _reset_icon_offset = function(_input) {
		__layout_icon__();
	};
	on_hover_exit(_reset_icon_offset);
	on_released(_reset_icon_offset);

	static __base_update_component_positions__ = WWCore.update_component_positions;
	static update_component_positions = function() {
		__layout_icon__();
		__base_update_component_positions__();
	};

	icon.set_auto_icon_paint(true);
	add(icon);
	set_square_size(22);
}
