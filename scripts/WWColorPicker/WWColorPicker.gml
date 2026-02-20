#region jsDoc
/// @func    WWColorPicker()
/// @desc    HSV/RGB color picker with a hue wheel + SV square and numeric input fields.
///          Designed for use inside a WWWindow (or embedded directly).
/// @returns {Struct.WWColorPicker}
#endregion
function WWColorPicker() : WWCore() constructor {
	debug_name = "WWColorPicker";

	#region Public

		#region Events
		events.color_change = variable_get_hash("color_change");
		static on_color_change = function(_func) {
			add_event_listener(events.color_change, _func);
			return self;
		}
		
		#endregion

		#region Components
		wheel = new WWCore().set_focusable(true);

		lbl_rgb = new WWLabel().set_text("RGB");
		lbl_r = new WWLabel().set_text("R");
		lbl_g = new WWLabel().set_text("G");
		lbl_b = new WWLabel().set_text("B");
		in_r = new WWInputInt().set_min(0).set_max(255);
		in_g = new WWInputInt().set_min(0).set_max(255);
		in_b = new WWInputInt().set_min(0).set_max(255);

		div_1 = new WWCore();

		lbl_hsv = new WWLabel().set_text("HSV");
		lbl_h = new WWLabel().set_text("H");
		lbl_s = new WWLabel().set_text("S");
		lbl_v = new WWLabel().set_text("V");
		in_h = new WWInputReal().set_min(0).set_max(360).set_decimals(1).set_step(1);
		in_s = new WWInputReal().set_min(0).set_max(100).set_decimals(1).set_step(1);
		in_v = new WWInputReal().set_min(0).set_max(100).set_decimals(1).set_step(1);

		div_2 = new WWCore();

		lbl_a = new WWLabel().set_text("A");
		in_a = new WWInputReal().set_min(0).set_max(1).set_decimals(2).set_step(0.05);

		btn_mode = new WWButtonText().set_text("More");

		add([
			wheel,
			lbl_rgb, lbl_r, lbl_g, lbl_b, in_r, in_g, in_b,
			div_1,
			lbl_hsv, lbl_h, lbl_s, lbl_v, in_h, in_s, in_v,
			div_2,
			lbl_a, in_a,
			btn_mode
		]);
		#endregion

		#region Variables
		__col__ = c_white;
		__alpha__ = 1;
		__h__ = 0;     // degrees [0..360)
		__s__ = 1;     // 0..1
		__v__ = 1;     // 0..1

		__use_alpha__ = true;
		__show_more__ = true;
		__suppress__ = false;
		__event_data__ = { color: c_white, alpha: 1, source: "" };

		// Cached wheel geometry (global coordinates)
		__wheel_cx__ = 0;
		__wheel_cy__ = 0;
		__wheel_outer__ = 0;
		__wheel_inner__ = 0;
		__sq_x__ = 0;
		__sq_y__ = 0;
		__sq_s__ = 0;
		__drag_mode__ = 0; // 0=none, 1=hue ring, 2=sv square
		#endregion

		#region Builder Functions
		static set_size = function(_w, _h) {
			__size_set__ = true;
			__set_size__(_w, _h);
			__layout__();
			return self;
		};

		/// @func set_color(color, alpha)
		static set_color = function(_color, _alpha=__alpha__) {
			__col__ = _color;
			__alpha__ = clamp(_alpha, 0, 1);
			__sync_from_color__();
			__sync_inputs__();
			return self;
		};

		static set_use_alpha = function(_use_alpha=true) {
			__use_alpha__ = _use_alpha;
			__apply_mode__();
			return self;
		};

		static set_more = function(_more=true) {
			__show_more__ = _more;
			__apply_mode__();
			return self;
		};

		static on_color_change = function(_func) { add_event_listener(events.color_change, _func); return self; };
		#endregion

		#region Functions
		static get_color = function() { return __col__; };
		static get_alpha = function() { return __alpha__; };

		static get_group_width = function() { return width; };
		static get_group_height = function() { return height; };
		#endregion

	#endregion

	#region Private

		#region Functions
		static __fire__ = function(_source) {
			__event_data__.color = __col__;
			__event_data__.alpha = __alpha__;
			__event_data__.source = _source;
			trigger_event(events.color_change, __event_data__);
		};

		static __sync_from_color__ = function() {
			// GameMaker HSV getters are 0..255
			var _h255 = color_get_hue(__col__);
			var _s255 = color_get_saturation(__col__);
			var _v255 = color_get_value(__col__);
			__h__ = (_h255 * 360.0) / 255.0;
			__s__ = _s255 / 255.0;
			__v__ = _v255 / 255.0;
		};

		static __sync_color_from_hsv__ = function() {
			var _h255 = clamp((__h__ / 360.0) * 255.0, 0, 255);
			var _s255 = clamp(__s__ * 255.0, 0, 255);
			var _v255 = clamp(__v__ * 255.0, 0, 255);
			__col__ = make_color_hsv(_h255, _s255, _v255);
		};

		static __sync_inputs__ = function() {
			__suppress__ = true;

			in_r.set_value(color_get_red(__col__));
			in_g.set_value(color_get_green(__col__));
			in_b.set_value(color_get_blue(__col__));

			in_h.set_value(__h__);
			in_s.set_value(__s__ * 100.0);
			in_v.set_value(__v__ * 100.0);

			in_a.set_value(__alpha__);

			__suppress__ = false;
		};

		static __apply_mode__ = function() {
			btn_mode.set_text(__show_more__ ? "Less" : "More");

			var _hsv_active = __show_more__;
			lbl_hsv.set_active(_hsv_active);
			lbl_h.set_active(_hsv_active);
			lbl_s.set_active(_hsv_active);
			lbl_v.set_active(_hsv_active);
			in_h.set_active(_hsv_active);
			in_s.set_active(_hsv_active);
			in_v.set_active(_hsv_active);
			div_1.set_active(_hsv_active);

			var _a_active = __use_alpha__;
			lbl_a.set_active(_a_active);
			in_a.set_active(_a_active);
			div_2.set_active(_a_active && _hsv_active);

			__layout__();
		};

		static __layout__ = function() {
			var _pad = 10;
			var _right_min_w = 180;
			var _wheel_sz = min(height - _pad * 2, width - (_pad * 3) - _right_min_w);
			_wheel_sz = clamp(_wheel_sz, 140, 220);
			wheel.set_offset(_pad, _pad);
			wheel.set_size(_wheel_sz, _wheel_sz);

			var _rx = _pad + _wheel_sz + _pad;
			var _rw = max(_right_min_w, width - _rx - _pad);

			// Right-side layout constants
			var _row_h = 20;
			var _gap = 4;
			var _lbl_w = 18;
			var _in_w = max(80, _rw - _lbl_w - 8);

			btn_mode.set_offset(_rx + _rw - 64, _pad);
			btn_mode.set_size(64, 20);

			var _y = _pad + 24;
			lbl_rgb.set_offset(_rx, _y);
			_y += 16;

			lbl_r.set_offset(_rx, _y + 2);
			in_r.set_offset(_rx + _lbl_w + 8, _y);
			in_r.set_size(_in_w, _row_h);
			_y += _row_h + _gap;

			lbl_g.set_offset(_rx, _y + 2);
			in_g.set_offset(_rx + _lbl_w + 8, _y);
			in_g.set_size(_in_w, _row_h);
			_y += _row_h + _gap;

			lbl_b.set_offset(_rx, _y + 2);
			in_b.set_offset(_rx + _lbl_w + 8, _y);
			in_b.set_size(_in_w, _row_h);
			_y += _row_h + _gap + 2;

			// Divider between RGB and HSV (only when HSV shown)
			div_1.set_offset(_rx, _y);
			div_1.set_size(_rw, 1);
			_y += 6;

			lbl_hsv.set_offset(_rx, _y);
			_y += 16;

			lbl_h.set_offset(_rx, _y + 2);
			in_h.set_offset(_rx + _lbl_w + 8, _y);
			in_h.set_size(_in_w, _row_h);
			_y += _row_h + _gap;

			lbl_s.set_offset(_rx, _y + 2);
			in_s.set_offset(_rx + _lbl_w + 8, _y);
			in_s.set_size(_in_w, _row_h);
			_y += _row_h + _gap;

			lbl_v.set_offset(_rx, _y + 2);
			in_v.set_offset(_rx + _lbl_w + 8, _y);
			in_v.set_size(_in_w, _row_h);
			_y += _row_h + _gap + 2;

			div_2.set_offset(_rx, _y);
			div_2.set_size(_rw, 1);
			_y += 6;

			lbl_a.set_offset(_rx, _y + 2);
			in_a.set_offset(_rx + _lbl_w + 8, _y);
			in_a.set_size(_in_w, _row_h);
		};

		static __update_wheel_geometry__ = function() {
			__wheel_cx__ = wheel.x + wheel.width * 0.5;
			__wheel_cy__ = wheel.y + wheel.height * 0.5;
			__wheel_outer__ = min(wheel.width, wheel.height) * 0.5 - 2;
			__wheel_inner__ = max(6, __wheel_outer__ - 18);

			// Keep the SV square slightly inset from the inner ring so it never overlaps.
			var _square_inset = 3;
			__sq_s__ = max(8, (__wheel_inner__ - _square_inset) * sqrt(2));
			__sq_s__ = min(__sq_s__, wheel.width - 12);
			__sq_s__ = min(__sq_s__, wheel.height - 12);
			__sq_s__ = floor(__sq_s__);
			__sq_x__ = floor(__wheel_cx__ - __sq_s__ * 0.5);
			__sq_y__ = floor(__wheel_cy__ - __sq_s__ * 0.5);
		};

		static __hue_color__ = function(_deg) {
			var _h255 = clamp((_deg / 360.0) * 255.0, 0, 255);
			return make_color_hsv(_h255, 255, 255);
		};

		static __draw_wheel__ = function() {
			__update_wheel_geometry__();

			// Hue ring built from fixed 10-degree wedges (36 segments).
			var _segs = 36;
			for (var _i = 0; _i < _segs; _i += 1) {
				var _a0 = _i * (360.0 / _segs);
				var _a1 = (_i + 1) * (360.0 / _segs);

				var _c0 = __hue_color__(_a0);
				var _c1 = __hue_color__(_a1);

				var _x0o = __wheel_cx__ + lengthdir_x(__wheel_outer__, _a0);
				var _y0o = __wheel_cy__ + lengthdir_y(__wheel_outer__, _a0);
				var _x1o = __wheel_cx__ + lengthdir_x(__wheel_outer__, _a1);
				var _y1o = __wheel_cy__ + lengthdir_y(__wheel_outer__, _a1);

				var _x0i = __wheel_cx__ + lengthdir_x(__wheel_inner__, _a0);
				var _y0i = __wheel_cy__ + lengthdir_y(__wheel_inner__, _a0);
				var _x1i = __wheel_cx__ + lengthdir_x(__wheel_inner__, _a1);
				var _y1i = __wheel_cy__ + lengthdir_y(__wheel_inner__, _a1);

				draw_triangle_color(_x0i, _y0i, _x0o, _y0o, _x1o, _y1o, _c0, _c0, _c1, false);
				draw_triangle_color(_x0i, _y0i, _x1o, _y1o, _x1i, _y1i, _c0, _c1, _c1, false);
			}

			// SV square
			var _base = __hue_color__(__h__);
			var _sq_x2 = __sq_x__ + __sq_s__ - 1;
			var _sq_y2 = __sq_y__ + __sq_s__ - 1;
			draw_set_alpha(1);
			draw_rectangle_color(__sq_x__, __sq_y__, _sq_x2, _sq_y2, c_white, _base, _base, c_white, false);

			// Value overlay (top transparent -> bottom black)
			draw_primitive_begin(pr_trianglestrip);
			draw_vertex_color(__sq_x__, __sq_y__, c_black, 0);
			draw_vertex_color(_sq_x2, __sq_y__, c_black, 0);
			draw_vertex_color(__sq_x__, _sq_y2, c_black, 1);
			draw_vertex_color(_sq_x2, _sq_y2, c_black, 1);
			draw_primitive_end();

			// Selection markers
			// Hue marker on ring
			var _ha = __h__;
			var _hr = (__wheel_outer__ + __wheel_inner__) * 0.5;
			var _hx = __wheel_cx__ + lengthdir_x(_hr, _ha);
			var _hy = __wheel_cy__ + lengthdir_y(_hr, _ha);
			draw_set_alpha(1);
			draw_set_color(c_black);
			draw_circle(_hx, _hy, 5, false);
			draw_set_color(c_white);
			draw_circle(_hx, _hy, 4, false);

			// SV marker in square
			var _sq_span = max(1, __sq_s__ - 1);
			var _sx = __sq_x__ + __s__ * _sq_span;
			var _sy = __sq_y__ + (1.0 - __v__) * _sq_span;
			draw_set_color(c_black);
			draw_circle(_sx, _sy, 5, false);
			draw_set_color(c_white);
			draw_circle(_sx, _sy, 4, false);
		};

		static __wheel_apply_mouse__ = function(_input) {
			__update_wheel_geometry__();
			var mx = _input.pointer.x;
			var my = _input.pointer.y;
			var _mode = __wheel_hit_mode__(mx, my);
			var _did = __wheel_apply_mouse_mode__(_mode, mx, my);

			if (_did) {
				__sync_color_from_hsv__();
				__sync_inputs__();
				__fire__("wheel");
			}
		};
		
		static __wheel_hit_mode__ = function(_mx, _my) {
			__update_wheel_geometry__();
			var _dist = point_distance(__wheel_cx__, __wheel_cy__, _mx, _my);
			if (_dist >= (__wheel_inner__ - 2) && _dist <= (__wheel_outer__ + 2)) {
				return 1;
			}
			if (_mx >= __sq_x__ && _mx <= (__sq_x__ + __sq_s__ - 1) && _my >= __sq_y__ && _my <= (__sq_y__ + __sq_s__ - 1)) {
				return 2;
			}
			return 0;
		};
		
		static __wheel_apply_mouse_mode__ = function(_mode, _mx, _my) {
			var _old_h = __h__;
			var _old_s = __s__;
			var _old_v = __v__;
			switch (_mode) {
				case 1:
					// Hue ring mode: once captured, update hue from angle anywhere mouse moves.
					__h__ = (point_direction(__wheel_cx__, __wheel_cy__, _mx, _my) + 360.0) mod 360.0;
					break;
				case 2:
					// SV mode: once captured, clamp pointer to square bounds for precision drags off-control.
					var _sq_span = max(1, __sq_s__ - 1);
					var _cx = clamp(_mx, __sq_x__, __sq_x__ + _sq_span);
					var _cy = clamp(_my, __sq_y__, __sq_y__ + _sq_span);
					__s__ = clamp((_cx - __sq_x__) / _sq_span, 0, 1);
					__v__ = clamp(1.0 - ((_cy - __sq_y__) / _sq_span), 0, 1);
					break;
			}
			return (_old_h != __h__) || (_old_s != __s__) || (_old_v != __v__);
		};
		
		static __apply_rgb_inputs__ = function() {
			if (__suppress__) { return; }
			__col__ = make_color_rgb(in_r.get_value(), in_g.get_value(), in_b.get_value());
			__sync_from_color__();
			__sync_inputs__();
			__fire__("rgb");
		};
		
		static __apply_hsv_inputs__ = function() {
			if (__suppress__) { return; }
			__h__ = clamp(in_h.get_value(), 0, 360);
			__s__ = clamp(in_s.get_value() / 100.0, 0, 1);
			__v__ = clamp(in_v.get_value() / 100.0, 0, 1);
			__sync_color_from_hsv__();
			__sync_inputs__();
			__fire__("hsv");
		};

		#endregion

	#endregion

	// Defaults
	set_size(500, 300);
	set_more(true);
	set_use_alpha(true);
	set_color(c_white);

	// Wheel draw + interaction
	wheel.on_pre_draw(function(_input) {
		__draw_wheel__();
	});
	wheel.on_pressed(function(_input) {
		__drag_mode__ = __wheel_hit_mode__(_input.pointer.x, _input.pointer.y);
		if (__drag_mode__ > 0) {
			if (__wheel_apply_mouse_mode__(__drag_mode__, _input.pointer.x, _input.pointer.y)) {
				__sync_color_from_hsv__();
				__sync_inputs__();
				__fire__("wheel");
			}
		}
	});
	wheel.on_held(function(_input) {
		if (__drag_mode__ > 0) {
			if (__wheel_apply_mouse_mode__(__drag_mode__, _input.pointer.x, _input.pointer.y)) {
				__sync_color_from_hsv__();
				__sync_inputs__();
				__fire__("wheel");
			}
		}
	});
	wheel.on_released(function(_input) {
		__drag_mode__ = 0;
	});

	// Mode toggle
	btn_mode.set_callback(function() {
		set_more(!__show_more__);
	});

	// Numeric wiring
	in_r.on_value_change(function(_d) { __apply_rgb_inputs__(); });
	in_g.on_value_change(function(_d) { __apply_rgb_inputs__(); });
	in_b.on_value_change(function(_d) { __apply_rgb_inputs__(); });
	in_r.get_input().on_change(function(_d) { __apply_rgb_inputs__(); });
	in_g.get_input().on_change(function(_d) { __apply_rgb_inputs__(); });
	in_b.get_input().on_change(function(_d) { __apply_rgb_inputs__(); });
	in_r.get_input().on_submit(function(_d) { __apply_rgb_inputs__(); });
	in_g.get_input().on_submit(function(_d) { __apply_rgb_inputs__(); });
	in_b.get_input().on_submit(function(_d) { __apply_rgb_inputs__(); });

	in_h.on_value_change(function(_d) { __apply_hsv_inputs__(); });
	in_s.on_value_change(function(_d) { __apply_hsv_inputs__(); });
	in_v.on_value_change(function(_d) { __apply_hsv_inputs__(); });
	in_h.get_input().on_change(function(_d) { __apply_hsv_inputs__(); });
	in_s.get_input().on_change(function(_d) { __apply_hsv_inputs__(); });
	in_v.get_input().on_change(function(_d) { __apply_hsv_inputs__(); });
	in_h.get_input().on_submit(function(_d) { __apply_hsv_inputs__(); });
	in_s.get_input().on_submit(function(_d) { __apply_hsv_inputs__(); });
	in_v.get_input().on_submit(function(_d) { __apply_hsv_inputs__(); });

	in_a.on_value_change(function(_d) {
		if (__suppress__) { exit; }
		__alpha__ = clamp(in_a.get_value(), 0, 1);
		__sync_inputs__();
		__fire__("alpha");
	});
}

