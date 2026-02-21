#region jsDoc
/// @func    WWButtonIconText()
/// @desc    WWButtonText with an optional WWIcon child rendered left/right of text.
/// @returns {Struct.WWButtonIconText}
#endregion
function WWButtonIconText() : WWButtonText() constructor {
	debug_name = "WWButtonIconText";

	#region Public
		#region Builder Functions
			static set_text = function(_text="DefaultText") {
				static __base_set_text__ = WWButtonText.set_text;
				__base_set_text__(_text);
				if (!__size_set__) set_sprite_to_auto_wrap();
				__layout_content__();
				return self;
			};

			static set_text_font = function(_font=fGUIDefault) {
				static __base_set_text_font__ = WWButtonText.set_text_font;
				__base_set_text_font__(_font);
				if (!__size_set__) set_sprite_to_auto_wrap();
				__layout_content__();
				return self;
			};

			static set_text_processor = function(_proc_or_name) {
				static __base_set_text_processor__ = WWButtonText.set_text_processor;
				__base_set_text_processor__(_proc_or_name);
				if (!__size_set__) set_sprite_to_auto_wrap();
				__layout_content__();
				return self;
			};

			static set_text_offsets = function(_x=0, _y=0, _click_y=2) {
				__user_text_offset_x__ = _x;
				__user_text_offset_y__ = _y;
				__user_text_click_y__ = _click_y;
				__layout_content__();
				return self;
			};

			static set_sprite_to_auto_wrap = function() {
				var _theme_spr = wwThemeGetSprite(
					"button_text.sprite.main.idle",
					"button_text.sprite.main"
				);
				var _spr = sprite_index ?? _theme_spr;
				if (_spr == undefined || !sprite_exists(_spr)) _spr = spr_ww_rr9_r4_all;
				var _slice = sprite_get_nineslice(_spr);

				var _text_w = text_component.width;
				var _text_h = text_component.height;
				var _button_h = _text_h + _slice.top + _slice.bottom;
				if (icon_enabled && icon_size > 0) {
					_button_h = max(_button_h, icon_size + (icon_padding * 2));
				}
				var _icon_s = 0;
				if (icon_enabled) {
					_icon_s = (icon_size > 0) ? icon_size : max(1, _button_h - (icon_padding * 2));
				}
				var _content_w = _text_w + (icon_enabled ? (_icon_s + icon_gap + icon_padding) : 0);
				__set_size__(_content_w + _slice.left + _slice.right, _button_h);
				__base_text_offset_x__ = _slice.left;
				__base_text_offset_y__ = _slice.top + floor((_button_h - _slice.top - _slice.bottom - _text_h) * 0.5);
				__layout_content__();
				return self;
			};

			static set_icon_side = function(_side="left") {
				icon_side = string_lower(_side);
				if (icon_side != "right") icon_side = "left";
				__layout_content__();
				return self;
			};

			static set_icon_gap = function(_gap=0) {
				icon_gap = max(0, _gap);
				if (!__size_set__) set_sprite_to_auto_wrap(); else __layout_content__();
				return self;
			};

			static set_icon_padding = function(_pad=0) {
				icon_padding = max(0, _pad);
				icon_component.set_icon_padding(icon_padding);
				if (!__size_set__) set_sprite_to_auto_wrap(); else __layout_content__();
				return self;
			};

			static set_icon_size = function(_size=-1) {
				icon_size = _size;
				if (!__size_set__) set_sprite_to_auto_wrap(); else __layout_content__();
				return self;
			};

			static set_icon_sprite = function(_sprite, _subimg=0) {
				icon_component.set_icon_sprite(_sprite, _subimg);
				icon_enabled = true;
				if (!__size_set__) set_sprite_to_auto_wrap(); else __layout_content__();
				return self;
			};

			static set_icon_fa = function(_icon, _style="solid") {
				icon_component.set_icon_fa(_icon, _style);
				icon_enabled = true;
				if (!__size_set__) set_sprite_to_auto_wrap(); else __layout_content__();
				return self;
			};

			static set_icon_fa_packed = function(_packed=-1) {
				icon_component.set_icon_fa_packed(_packed);
				icon_enabled = true;
				if (!__size_set__) set_sprite_to_auto_wrap(); else __layout_content__();
				return self;
			};

			static clear_icon = function() {
				icon_component.clear_icon();
				icon_enabled = false;
				if (!__size_set__) set_sprite_to_auto_wrap(); else __layout_content__();
				return self;
			};
			
			static set_icon_theme_keys = function(
				_color_prefix = "button_text.color.text",
				_alpha_prefix = "button_text.alpha.text",
				_state_source = undefined
			) {
				if (is_undefined(_state_source)) _state_source = self;
				icon_component.set_theme_keys(_color_prefix, _alpha_prefix, _state_source);
				return self;
			};
		#endregion
	#endregion

	#region Private
		#region Variables
			icon_component = new WWIcon();
			icon_enabled = false;
			icon_side = "left";
			icon_gap = 0;
			icon_padding = 0;
			icon_size = -1;
			__base_text_offset_x__ = 0;
			__base_text_offset_y__ = 0;
			__icon_base_x__ = 0;
			__icon_base_y__ = 0;
			__user_text_offset_x__ = 0;
			__user_text_offset_y__ = 0;
			__user_text_click_y__ = 2;
		#endregion

		#region Functions
			static __resolve_icon_size__ = function(_button_h=0) {
				if (!icon_enabled) return 0;
				var _h = _button_h;
				if (_h <= 0) _h = height;
				var _s = icon_size;
				if (_s <= 0) _s = max(1, _h - (icon_padding * 2));
				return max(1, floor(_s));
			};

			static __layout_content__ = function() {
				var _theme_spr = wwThemeGetSprite(
					"button_text.sprite.main.idle",
					"button_text.sprite.main"
				);
				var _spr = sprite_index ?? _theme_spr;
				if (_spr == undefined || !sprite_exists(_spr)) _spr = spr_ww_rr9_r4_all;
				var _slice = sprite_get_nineslice(_spr);

				var _text_w = text_component.width;
				var _text_h = text_component.height;
				var _icon_s = __resolve_icon_size__(height);
				var _content_h = max(1, height - _slice.top - _slice.bottom);
				var _base_y = _slice.top + floor((_content_h - _text_h) * 0.5);
				var _desc_bias = __estimate_descender_bias__();

				__base_text_offset_x__ = _slice.left;
				__base_text_offset_y__ = _base_y;

				var _text_x = __base_text_offset_x__ + __user_text_offset_x__;
				var _text_y = __base_text_offset_y__ + __user_text_offset_y__;

				if (icon_enabled) {
					if (icon_side == "left") {
						__icon_base_x__ = icon_padding;
						__icon_base_y__ = _slice.top + floor((_content_h - _icon_s) * 0.5) - _desc_bias;
						icon_component.set_offset(__icon_base_x__, __icon_base_y__);
						icon_component.set_size(_icon_s, _icon_s);
						_text_x = __base_text_offset_x__ + icon_padding + _icon_s + icon_gap + __user_text_offset_x__;
					}
					else {
						__icon_base_x__ = _text_x + _text_w + icon_gap;
						__icon_base_y__ = _slice.top + floor((_content_h - _icon_s) * 0.5) - _desc_bias;
						icon_component.set_offset(__icon_base_x__, __icon_base_y__);
						icon_component.set_size(_icon_s, _icon_s);
					}
					icon_component.set_active(true);
				}
				else {
					icon_component.set_active(false);
				}

				static __base_set_text_offsets__ = WWButtonText.set_text_offsets;
				__base_set_text_offsets__(_text_x, _text_y, __base_text_offset_y__ + __user_text_click_y__);
			};

			static get_text_offsets = function() {
				return {
					x: __user_text_offset_x__,
					y: __user_text_offset_y__,
					click_y: __user_text_click_y__,
				};
			};

			static set_text_click_offset = function(_click_y=2) {
				__user_text_click_y__ = _click_y;
				__layout_content__();
				return self;
			};

			static get_text_click_offset = function() {
				return __user_text_click_y__;
			};

			static __reset_icon_layout__ = function(_input) {
				__layout_content__();
			};

			static __estimate_descender_bias__ = function() {
				var _font = text_component.get_text_font();
				if (_font == undefined || !font_exists(_font)) return 0;
				var _old = draw_get_font();
				draw_set_font(_font);
				var _h_cap = string_height("H");
				var _h_low = string_height("gjpqy");
				draw_set_font(_old);
				if (_h_low <= _h_cap) return 0;
				return floor((_h_low - _h_cap) * 0.5);
			};
		#endregion
	#endregion

	on_held(function(_input) {
		if (!__is_pointer_over__ || !icon_enabled) return;
		icon_component.__set_offset__(__icon_base_x__, __icon_base_y__ + (__user_text_click_y__ - __user_text_offset_y__));
	});

	on_hover_exit(method(self, __reset_icon_layout__));
	on_released(method(self, __reset_icon_layout__));

	add(icon_component);
	icon_component.set_icon_padding(icon_padding);
	set_icon_theme_keys("button_text.color.text", "button_text.alpha.text", self);
	icon_component.set_auto_icon_paint(true);
	icon_component.set_active(false);
	__layout_content__();
}
