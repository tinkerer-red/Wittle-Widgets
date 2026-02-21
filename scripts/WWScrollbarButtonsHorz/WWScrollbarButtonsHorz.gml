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
			
			static set_theme_keys = function(
				_sprite_main = "scrollbar.sprite.tray.main",
				_sprite_state_prefix = "scrollbar.sprite.tray",
				_color_prefix = "scrollbar.color.tray",
				_alpha_prefix = "scrollbar.alpha.tray"
			) {
				__track_theme_sprite_main__ = _sprite_main;
				__track_theme_sprite_state_prefix__ = _sprite_state_prefix;
				__track_theme_color_prefix__ = _color_prefix;
				__track_theme_alpha_prefix__ = _alpha_prefix;
				
				if (is_struct(slider) && variable_struct_exists(slider, "set_track_theme_keys")) {
					slider.set_track_theme_keys(
						__track_theme_sprite_main__,
						__track_theme_sprite_state_prefix__,
						__track_theme_color_prefix__,
						__track_theme_alpha_prefix__
					);
				}
				return self;
			};
			
			static set_thumb_theme_keys = function(
				_sprite_main = "scrollbar.sprite.thumb.main",
				_sprite_state_prefix = "scrollbar.sprite.thumb",
				_color_prefix = "scrollbar.color.thumb",
				_alpha_prefix = "scrollbar.alpha.thumb"
			) {
				__thumb_theme_sprite_main__ = _sprite_main;
				__thumb_theme_sprite_state_prefix__ = _sprite_state_prefix;
				__thumb_theme_color_prefix__ = _color_prefix;
				__thumb_theme_alpha_prefix__ = _alpha_prefix;
				
				if (is_struct(slider) && variable_struct_exists(slider, "set_thumb_theme_keys")) {
					slider.set_thumb_theme_keys(
						__thumb_theme_sprite_main__,
						__thumb_theme_sprite_state_prefix__,
						__thumb_theme_color_prefix__,
						__thumb_theme_alpha_prefix__
					);
				}
				else if (is_struct(slider) && is_struct(slider.thumb) && variable_struct_exists(slider.thumb, "set_theme_keys")) {
					slider.thumb.set_theme_keys(
						__thumb_theme_sprite_main__,
						__thumb_theme_sprite_state_prefix__,
						__thumb_theme_color_prefix__,
						__thumb_theme_alpha_prefix__
					);
				}
				return self;
			};
			
			static set_button_theme_keys = function(
				_left_sprite_main = "scrollbar.sprite.button.left.main",
				_left_sprite_state_prefix = "scrollbar.sprite.button.left",
				_left_color_prefix = "scrollbar.color.button.left",
				_left_alpha_prefix = "scrollbar.alpha.button.left",
				_right_sprite_main = "scrollbar.sprite.button.right.main",
				_right_sprite_state_prefix = "scrollbar.sprite.button.right",
				_right_color_prefix = "scrollbar.color.button.right",
				_right_alpha_prefix = "scrollbar.alpha.button.right"
			) {
				__left_button_theme_sprite_main__ = _left_sprite_main;
				__left_button_theme_sprite_state_prefix__ = _left_sprite_state_prefix;
				__left_button_theme_color_prefix__ = _left_color_prefix;
				__left_button_theme_alpha_prefix__ = _left_alpha_prefix;
				__right_button_theme_sprite_main__ = _right_sprite_main;
				__right_button_theme_sprite_state_prefix__ = _right_sprite_state_prefix;
				__right_button_theme_color_prefix__ = _right_color_prefix;
				__right_button_theme_alpha_prefix__ = _right_alpha_prefix;
				
				if (is_struct(leftButton) && variable_struct_exists(leftButton, "set_theme_keys")) {
					leftButton.set_theme_keys(
						__left_button_theme_sprite_main__,
						__left_button_theme_sprite_state_prefix__,
						__left_button_theme_color_prefix__,
						__left_button_theme_alpha_prefix__
					);
				}
				if (is_struct(rightButton) && variable_struct_exists(rightButton, "set_theme_keys")) {
					rightButton.set_theme_keys(
						__right_button_theme_sprite_main__,
						__right_button_theme_sprite_state_prefix__,
						__right_button_theme_color_prefix__,
						__right_button_theme_alpha_prefix__
					);
				}
				return self;
			};
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
			leftButton.set_theme_keys(
				"scrollbar.sprite.button.left.main",
				"scrollbar.sprite.button.left",
				"scrollbar.color.button.left",
				"scrollbar.alpha.button.left"
			);

			slider = new WWSliderHorzThumb()
				.set_offset(10, 0)
				.set_size(108, 16)
				.set_value(0.0)
				.set_callback(function() {
					trigger_event(events.scroll_changed, slider.get_value());
				});
			slider.set_track_theme_keys(
				"scrollbar.sprite.tray.main",
				"scrollbar.sprite.tray",
				"scrollbar.color.tray",
				"scrollbar.alpha.tray"
			);
			if (is_struct(slider.thumb)) {
				slider.thumb.set_theme_keys(
					"scrollbar.sprite.thumb.main",
					"scrollbar.sprite.thumb",
					"scrollbar.color.thumb",
					"scrollbar.alpha.thumb"
				);
				slider.thumb.set_navigable(false);
			}

			rightButton = new WWButtonIcon()
				.set_offset(118, 0)
				.set_size(10, 16)
				.set_keep_square(false)
				.set_icon_padding(2)
				.set_callback(function() {
					slider.set_value(slider.get_value() + 0.05);
				});
			rightButton.set_theme_keys(
				"scrollbar.sprite.button.right.main",
				"scrollbar.sprite.button.right",
				"scrollbar.color.button.right",
				"scrollbar.alpha.button.right"
			);
			
			leftButton.set_navigable(false);
			slider.set_navigable(false);
			rightButton.set_navigable(false);

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
			__track_theme_sprite_main__ = "scrollbar.sprite.tray.main";
			__track_theme_sprite_state_prefix__ = "scrollbar.sprite.tray";
			__track_theme_color_prefix__ = "scrollbar.color.tray";
			__track_theme_alpha_prefix__ = "scrollbar.alpha.tray";
			__thumb_theme_sprite_main__ = "scrollbar.sprite.thumb.main";
			__thumb_theme_sprite_state_prefix__ = "scrollbar.sprite.thumb";
			__thumb_theme_color_prefix__ = "scrollbar.color.thumb";
			__thumb_theme_alpha_prefix__ = "scrollbar.alpha.thumb";
			__left_button_theme_sprite_main__ = "scrollbar.sprite.button.left.main";
			__left_button_theme_sprite_state_prefix__ = "scrollbar.sprite.button.left";
			__left_button_theme_color_prefix__ = "scrollbar.color.button.left";
			__left_button_theme_alpha_prefix__ = "scrollbar.alpha.button.left";
			__right_button_theme_sprite_main__ = "scrollbar.sprite.button.right.main";
			__right_button_theme_sprite_state_prefix__ = "scrollbar.sprite.button.right";
			__right_button_theme_color_prefix__ = "scrollbar.color.button.right";
			__right_button_theme_alpha_prefix__ = "scrollbar.alpha.button.right";

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
	set_theme_keys(__track_theme_sprite_main__, __track_theme_sprite_state_prefix__, __track_theme_color_prefix__, __track_theme_alpha_prefix__);
	set_thumb_theme_keys(__thumb_theme_sprite_main__, __thumb_theme_sprite_state_prefix__, __thumb_theme_color_prefix__, __thumb_theme_alpha_prefix__);
	set_button_theme_keys(
		__left_button_theme_sprite_main__,
		__left_button_theme_sprite_state_prefix__,
		__left_button_theme_color_prefix__,
		__left_button_theme_alpha_prefix__,
		__right_button_theme_sprite_main__,
		__right_button_theme_sprite_state_prefix__,
		__right_button_theme_color_prefix__,
		__right_button_theme_alpha_prefix__
	);
}
