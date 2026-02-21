#region jsDoc
/// @func    WWScrollbarButtonsVert()
/// @desc    A vertical scrollbar that includes up/down buttons and a thumb slider.
/// @returns {Struct.WWScrollbarButtonsVert}
#endregion
function WWScrollbarButtonsVert() : WWCore() constructor {
	debug_name = "WWScrollbarButtonsVert";

	#region Public
		#region Builder Functions
			static __layout_parts__ = function() {
				var _btn = max(0, __btn_size__);
				var _slider_h = max(0, height - (_btn * 2));
				upButton.set_size(width, _btn);
				slider.set_offset(0, _btn);
				slider.set_size(width, _slider_h);
				downButton.set_offset(0, _btn + _slider_h);
				downButton.set_size(width, _btn);
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

			static set_canvas_size = function(_height) {
				canvasHeight = _height;
				update_slider_range();
				return self;
			}

			static set_coverage_size = function(_height) {
				coverageHeight = _height;
				update_slider_range();
				return self;
			}

			static set_callback = function(_callback) {
				__user_callback__ = _callback;
				return self;
			}

			static set_debug_thumb_gizmo = function(_enabled=true) {
				__debug_thumb_gizmo__ = !!_enabled;
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
				
				slider.set_track_theme_keys(
					__track_theme_sprite_main__,
					__track_theme_sprite_state_prefix__,
					__track_theme_color_prefix__,
					__track_theme_alpha_prefix__
				);
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
				
				slider.set_thumb_theme_keys(
					__thumb_theme_sprite_main__,
					__thumb_theme_sprite_state_prefix__,
					__thumb_theme_color_prefix__,
					__thumb_theme_alpha_prefix__
				);
				return self;
			};
			
			static set_button_theme_keys = function(
				_up_sprite_main = "scrollbar.sprite.button.up.main",
				_up_sprite_state_prefix = "scrollbar.sprite.button.up",
				_up_color_prefix = "scrollbar.color.button.up",
				_up_alpha_prefix = "scrollbar.alpha.button.up",
				_down_sprite_main = "scrollbar.sprite.button.down.main",
				_down_sprite_state_prefix = "scrollbar.sprite.button.down",
				_down_color_prefix = "scrollbar.color.button.down",
				_down_alpha_prefix = "scrollbar.alpha.button.down"
			) {
				__up_button_theme_sprite_main__ = _up_sprite_main;
				__up_button_theme_sprite_state_prefix__ = _up_sprite_state_prefix;
				__up_button_theme_color_prefix__ = _up_color_prefix;
				__up_button_theme_alpha_prefix__ = _up_alpha_prefix;
				__down_button_theme_sprite_main__ = _down_sprite_main;
				__down_button_theme_sprite_state_prefix__ = _down_sprite_state_prefix;
				__down_button_theme_color_prefix__ = _down_color_prefix;
				__down_button_theme_alpha_prefix__ = _down_alpha_prefix;
				
				if (upButton != undefined) {
					upButton.set_theme_keys(
						__up_button_theme_sprite_main__,
						__up_button_theme_sprite_state_prefix__,
						__up_button_theme_color_prefix__,
						__up_button_theme_alpha_prefix__
					);
				}
				if (downButton != undefined) {
					downButton.set_theme_keys(
						__down_button_theme_sprite_main__,
						__down_button_theme_sprite_state_prefix__,
						__down_button_theme_color_prefix__,
						__down_button_theme_alpha_prefix__
					);
				}
				return self;
			};
		#endregion

		#region Components
			upButton = new WWButtonIcon()
				.set_offset(0, 0)
				.set_size(16, 10)
				.set_keep_square(false)
				.set_icon_padding(2)
				.set_callback(function() {
					slider.set_value(slider.get_value() - 0.05);
				});
			upButton.set_theme_keys(
				"scrollbar.sprite.button.up.main",
				"scrollbar.sprite.button.up",
				"scrollbar.color.button.up",
				"scrollbar.alpha.button.up"
			);

			slider = new WWSliderVertThumb()
				.set_offset(0, 10)
				.set_size(16, 108)
				.set_value(0.0);
			slider.set_track_theme_keys(
				"scrollbar.sprite.tray.main",
				"scrollbar.sprite.tray",
				"scrollbar.color.tray",
				"scrollbar.alpha.tray"
			);
			slider.thumb.set_theme_keys(
				"scrollbar.sprite.thumb.main",
				"scrollbar.sprite.thumb",
				"scrollbar.color.thumb",
				"scrollbar.alpha.thumb"
			);
			slider.thumb.set_navigable(false);

			downButton = new WWButtonIcon()
				.set_offset(0, 118)
				.set_size(16, 10)
				.set_keep_square(false)
				.set_icon_padding(2)
				.set_callback(function() {
					slider.set_value(slider.get_value() + 0.05);
				});
			downButton.set_theme_keys(
				"scrollbar.sprite.button.down.main",
				"scrollbar.sprite.button.down",
				"scrollbar.color.button.down",
				"scrollbar.alpha.button.down"
			);
			
			upButton.set_navigable(false);
			slider.set_navigable(false);
			downButton.set_navigable(false);

			add(upButton);
			add(slider);
			add(downButton);
		#endregion

		#region Events
			events.scroll_changed = variable_get_hash("scroll_changed");

			on_pre_draw(function(_input) {
				if (!__debug_thumb_gizmo__) return;
				__debug_prev_scissor__ = gpu_get_scissor();
				gpu_set_scissor(0, 0, display_get_gui_width(), display_get_gui_height());
				__debug_scissor_lifted__ = true;
			});

			on_post_draw(function(_input) {
				if (__debug_thumb_gizmo__ && !is_undefined(slider) && slider != noone && !is_undefined(slider.thumb) && slider.thumb != noone) {
					var _x1 = slider.thumb.x;
					var _y1 = slider.thumb.y;
					var _x2 = _x1 + slider.thumb.width;
					var _y2 = _y1 + slider.thumb.height;

					draw_set_color(c_lime);
					draw_rectangle(_x1, _y1, _x2, _y2, true);
					draw_line(_x1, _y1, _x2, _y2);
					draw_line(_x2, _y1, _x1, _y2);
				}

				if (__debug_scissor_lifted__) {
					gpu_set_scissor(__debug_prev_scissor__);
					__debug_prev_scissor__ = undefined;
					__debug_scissor_lifted__ = false;
				}
			});
		#endregion

		#region Variables
			canvasHeight = 128;
			coverageHeight = 108;
			__btn_size__ = 10;
			__track_theme_sprite_main__ = "scrollbar.sprite.tray.main";
			__track_theme_sprite_state_prefix__ = "scrollbar.sprite.tray";
			__track_theme_color_prefix__ = "scrollbar.color.tray";
			__track_theme_alpha_prefix__ = "scrollbar.alpha.tray";
			__thumb_theme_sprite_main__ = "scrollbar.sprite.thumb.main";
			__thumb_theme_sprite_state_prefix__ = "scrollbar.sprite.thumb";
			__thumb_theme_color_prefix__ = "scrollbar.color.thumb";
			__thumb_theme_alpha_prefix__ = "scrollbar.alpha.thumb";
			__up_button_theme_sprite_main__ = "scrollbar.sprite.button.up.main";
			__up_button_theme_sprite_state_prefix__ = "scrollbar.sprite.button.up";
			__up_button_theme_color_prefix__ = "scrollbar.color.button.up";
			__up_button_theme_alpha_prefix__ = "scrollbar.alpha.button.up";
			__down_button_theme_sprite_main__ = "scrollbar.sprite.button.down.main";
			__down_button_theme_sprite_state_prefix__ = "scrollbar.sprite.button.down";
			__down_button_theme_color_prefix__ = "scrollbar.color.button.down";
			__down_button_theme_alpha_prefix__ = "scrollbar.alpha.button.down";

			__user_callback__ = undefined;
			__default_up_callback__ = upButton.get_callback();
			__default_down_callback__ = downButton.get_callback();
			__on_slider_changed__ = function() {
				trigger_event(events.scroll_changed, slider.get_value());
				if (is_callable(__user_callback__)) __user_callback__();
			};
			__debug_thumb_gizmo__ = false;
			__debug_prev_scissor__ = undefined;
			__debug_scissor_lifted__ = false;
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
			static get_canvas_size = function() { return canvasHeight; }
			static get_coverage_size = function() { return coverageHeight; }
			static get_button_size = function() { return __btn_size__; }

			static update_slider_range = function() {
				var _canvas = max(0, canvasHeight);
				var _coverage = max(0, coverageHeight);
				var _max_scroll = max(0, _canvas - _coverage);

				slider.set_clamp_values(0, _max_scroll);
				slider.set_value(clamp(slider.get_value(), 0, _max_scroll));

				// Default thumb sizing should represent viewport coverage on the track.
				var _track_h = max(1, slider.height);
				var _ratio = (_canvas <= 0) ? 1 : clamp(_coverage / _canvas, 0, 1);
				var _thumb_min = min(10, _track_h);
				var _thumb_h = clamp(max(_thumb_min, floor(_track_h * _ratio + 0.5)), _thumb_min, _track_h);
				slider.thumb.set_size(slider.width, _thumb_h);
			}
		#endregion
	#endregion

	set_size(16, 128);
	set_show_track(true);
	set_show_fill(false);
	set_button_size(10);
	set_inverted(true);
	set_theme_keys(__track_theme_sprite_main__, __track_theme_sprite_state_prefix__, __track_theme_color_prefix__, __track_theme_alpha_prefix__);
	set_thumb_theme_keys(__thumb_theme_sprite_main__, __thumb_theme_sprite_state_prefix__, __thumb_theme_color_prefix__, __thumb_theme_alpha_prefix__);
	set_button_theme_keys(
		__up_button_theme_sprite_main__,
		__up_button_theme_sprite_state_prefix__,
		__up_button_theme_color_prefix__,
		__up_button_theme_alpha_prefix__,
		__down_button_theme_sprite_main__,
		__down_button_theme_sprite_state_prefix__,
		__down_button_theme_color_prefix__,
		__down_button_theme_alpha_prefix__
	);

	// Drive callback/event output from real value changes so drag and button presses
	// both move connected viewports reliably.
	slider.on_event(slider.events.value_changed, __on_slider_changed__);
}
