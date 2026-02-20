#region jsDoc
/// @func    WWScrollbarButtonsHorz()
/// @desc    A horizontal scrollbar that includes left/right buttons and a thumb slider.
/// @returns {Struct.WWScrollbarButtonsHorz}
#endregion
function WWScrollbarButtonsHorz() : WWCore() constructor {
	debug_name = "WWScrollbarButtonsHorz";

	#region Public
		#region Builder Functions
			static __layout_parts__ = function() {
				var _btn = max(0, __btn_size__);
				var _slider_w = max(0, width - (_btn * 2));
				leftButton.set_size(_btn, height);
				slider.set_offset(_btn, 0);
				slider.set_size(_slider_w, height);
				rightButton.set_offset(_btn + _slider_w, 0);
				rightButton.set_size(_btn, height);
			};

			static set_size = function(_width, _height) {
				__size_set__ = true;
				__set_size__(_width, _height);
				__layout_parts__();
				return self;
			}

			static set_button_size = function(_size=10) {
				__btn_size__ = max(0, _size);
				__layout_parts__();
				return self;
			}

			static set_canvas_size = function(_width) {
				canvasWidth = _width;
				update_slider_range();
				return self;
			}

			static set_coverage_size = function(_width) {
				coverageWidth = _width;
				update_slider_range();
				return self;
			}

			static set_callback = function(_callback) {
				__user_callback__ = _callback;

				leftButton.set_callback(function() {
					if (is_callable(__default_left_callback__)) __default_left_callback__();
					if (is_callable(__user_callback__)) __user_callback__();
				});

				rightButton.set_callback(function() {
					if (is_callable(__default_right_callback__)) __default_right_callback__();
					if (is_callable(__user_callback__)) __user_callback__();
				});

				return self;
			}

			static set_value = function(_value) { slider.set_value(_value); return self; }
			static set_normalized_value = function(_value) { slider.set_normalized_value(_value); return self; }
			static set_clamp_values = function(_min, _max) { slider.set_clamp_values(_min, _max); return self; }
			static set_rounding = function(_round) { slider.set_rounding(_round); return self; }
			static set_lerp_target = function(_lerp_target) { slider.set_lerp_target(_lerp_target); return self; }
			static set_inverted = function(_invert) { slider.set_inverted(_invert); return self; }
			static set_bar_size = function(_left, _top, _right, _bottom) { slider.set_bar_size(_left, _top, _right, _bottom); return self; }
			static set_background_size = function(_left, _top, _right, _bottom) { slider.set_background_size(_left, _top, _right, _bottom); return self; }
			static set_show_track = function(_enabled=true) { slider.set_show_track(_enabled); return self; }
			static set_show_fill = function(_enabled=true) { slider.set_show_fill(_enabled); return self; }
			static set_show_bar = function(_enabled=true) { slider.set_show_bar(_enabled); return self; }
		#endregion

		#region Components
			leftButton = new WWButtonIcon()
				.set_offset(0, 0)
				.set_size(10, 16)
				.set_keep_square(false)
				.set_icon_padding(2)
				.set_callback(function() {
					slider.set_value(slider.get_value() - 0.05);
				});
			leftButton.__theme_sprite_key_main__ = "scrollbar.sprite.button.left.main";
			leftButton.__theme_sprite_key_state_prefix__ = "scrollbar.sprite.button.left";
			leftButton.__theme_color_prefix__ = "scrollbar.color.button.left";
			leftButton.__theme_alpha_prefix__ = "scrollbar.alpha.button.left";

			slider = new WWSliderHorzThumb()
				.set_offset(10, 0)
				.set_size(108, 16)
				.set_value(0.0)
				.set_callback(function() {
					trigger_event(events.scroll_changed, slider.get_value());
				});
			slider.__theme_sprite_key_main__ = "scrollbar.sprite.tray.main";
			slider.__theme_sprite_key_state_prefix__ = "scrollbar.sprite.tray";
			slider.__theme_color_prefix__ = "scrollbar.color.tray";
			slider.__theme_alpha_prefix__ = "scrollbar.alpha.tray";
			if (is_struct(slider.thumb)) {
				slider.thumb.__theme_sprite_key_main__ = "scrollbar.sprite.thumb.main";
				slider.thumb.__theme_sprite_key_state_prefix__ = "scrollbar.sprite.thumb";
				slider.thumb.__theme_color_prefix__ = "scrollbar.color.thumb";
				slider.thumb.__theme_alpha_prefix__ = "scrollbar.alpha.thumb";
			}

			rightButton = new WWButtonIcon()
				.set_offset(118, 0)
				.set_size(10, 16)
				.set_keep_square(false)
				.set_icon_padding(2)
				.set_callback(function() {
					slider.set_value(slider.get_value() + 0.05);
				});
			rightButton.__theme_sprite_key_main__ = "scrollbar.sprite.button.right.main";
			rightButton.__theme_sprite_key_state_prefix__ = "scrollbar.sprite.button.right";
			rightButton.__theme_color_prefix__ = "scrollbar.color.button.right";
			rightButton.__theme_alpha_prefix__ = "scrollbar.alpha.button.right";

			add(leftButton);
			add(slider);
			add(rightButton);
		#endregion

		#region Events
			events.scroll_changed = variable_get_hash("scroll_changed");
		#endregion

		#region Variables
			canvasWidth = 128;
			coverageWidth = 108;
			__btn_size__ = 10;

			__user_callback__ = undefined;
			__default_left_callback__ = leftButton.get_callback();
			__default_right_callback__ = rightButton.get_callback();
		#endregion

		#region Functions
			static get_callback = function() { return __user_callback__; }
			static get_value = function() { return slider.get_value(); }
			static get_normalized_value = function() { return slider.get_normalized_value(); }
			static get_clamp_values = function() { return slider.get_clamp_values(); }
			static get_rounding = function() { return slider.get_rounding(); }
			static get_lerp_target = function() { return slider.get_lerp_target(); }
			static get_inverted = function() { return slider.get_inverted(); }
			static get_bar_size = function() { return slider.get_bar_size(); }
			static get_background_size = function() { return slider.get_background_size(); }
			static get_show_track = function() { return slider.get_show_track(); }
			static get_show_fill = function() { return slider.get_show_fill(); }
			static get_show_bar = function() { return slider.get_show_bar(); }
			static get_canvas_size = function() { return canvasWidth; }
			static get_coverage_size = function() { return coverageWidth; }
			static get_button_size = function() { return __btn_size__; }

			static update_slider_range = function() {
				slider.set_value(slider.get_value());
			}
		#endregion
	#endregion

	set_size(128, 16);
	set_show_track(true);
	set_show_fill(false);
	set_button_size(10);
	set_inverted(false);
}
