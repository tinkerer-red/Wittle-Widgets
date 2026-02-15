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
		#endregion

		#region Components
		wheel = new WWCore();

		lbl_rgb = new WWLabel().set_text("RGB").set_text_color(c_white);
		lbl_r = new WWLabel().set_text("R").set_text_color(c_white);
		lbl_g = new WWLabel().set_text("G").set_text_color(c_white);
		lbl_b = new WWLabel().set_text("B").set_text_color(c_white);
		in_r = new WWInputInt().set_min(0).set_max(255);
		in_g = new WWInputInt().set_min(0).set_max(255);
		in_b = new WWInputInt().set_min(0).set_max(255);

		div_1 = new WWCore().set_background_color(c_gray);

		lbl_hsv = new WWLabel().set_text("HSV").set_text_color(c_white);
		lbl_h = new WWLabel().set_text("H").set_text_color(c_white);
		lbl_s = new WWLabel().set_text("S").set_text_color(c_white);
		lbl_v = new WWLabel().set_text("V").set_text_color(c_white);
		in_h = new WWInputReal().set_min(0).set_max(360).set_decimals(1).set_step(1);
		in_s = new WWInputReal().set_min(0).set_max(100).set_decimals(1).set_step(1);
		in_v = new WWInputReal().set_min(0).set_max(100).set_decimals(1).set_step(1);

		div_2 = new WWCore().set_background_color(c_gray);

		lbl_a = new WWLabel().set_text("A").set_text_color(c_white);
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
			set_background_color(c_dkgray);

			var _pad = 8;
			var _wheel_sz = min(190, height - _pad * 2);
			wheel.set_offset(_pad, _pad);
			wheel.set_size(_wheel_sz, _wheel_sz);

			var _rx = _pad + _wheel_sz + 10;
			var _rw = max(10, width - _rx - _pad);

			// Right-side layout constants
			var _row_h = 22;
			var _gap = 6;
			var _lbl_w = 14;
			var _in_w = max(60, _rw - _lbl_w - 6);

			btn_mode.set_offset(_rx + _rw - 60, _pad - 2);
			btn_mode.set_size(60, 22);

			var _y = _pad + 18;
			lbl_rgb.set_offset(_rx, _y);
			_y += 18;

			lbl_r.set_offset(_rx, _y + 2);
			in_r.set_offset(_rx + _lbl_w + 6, _y);
			in_r.set_size(_in_w, _row_h);
			_y += _row_h + _gap;

			lbl_g.set_offset(_rx, _y + 2);
			in_g.set_offset(_rx + _lbl_w + 6, _y);
			in_g.set_size(_in_w, _row_h);
			_y += _row_h + _gap;

			lbl_b.set_offset(_rx, _y + 2);
			in_b.set_offset(_rx + _lbl_w + 6, _y);
			in_b.set_size(_in_w, _row_h);
			_y += _row_h + _gap;

			// Divider between RGB and HSV (only when HSV shown)
			div_1.set_offset(_rx, _y);
			div_1.set_size(_rw, 1);
			_y += 8;

			lbl_hsv.set_offset(_rx, _y);
			_y += 18;

			lbl_h.set_offset(_rx, _y + 2);
			in_h.set_offset(_rx + _lbl_w + 6, _y);
			in_h.set_size(_in_w, _row_h);
			_y += _row_h + _gap;

			lbl_s.set_offset(_rx, _y + 2);
			in_s.set_offset(_rx + _lbl_w + 6, _y);
			in_s.set_size(_in_w, _row_h);
			_y += _row_h + _gap;

			lbl_v.set_offset(_rx, _y + 2);
			in_v.set_offset(_rx + _lbl_w + 6, _y);
			in_v.set_size(_in_w, _row_h);
			_y += _row_h + _gap;

			div_2.set_offset(_rx, _y);
			div_2.set_size(_rw, 1);
			_y += 8;

			lbl_a.set_offset(_rx, _y + 2);
			in_a.set_offset(_rx + _lbl_w + 6, _y);
			in_a.set_size(_in_w, _row_h);
		};

		static __update_wheel_geometry__ = function() {
			__wheel_cx__ = wheel.x + wheel.width * 0.5;
			__wheel_cy__ = wheel.y + wheel.height * 0.5;
			__wheel_outer__ = min(wheel.width, wheel.height) * 0.5 - 2;
			__wheel_inner__ = max(6, __wheel_outer__ - 18);

			__sq_s__ = __wheel_inner__ * sqrt(2);
			__sq_s__ = min(__sq_s__, wheel.width - 12);
			__sq_s__ = min(__sq_s__, wheel.height - 12);
			__sq_x__ = __wheel_cx__ - __sq_s__ * 0.5;
			__sq_y__ = __wheel_cy__ - __sq_s__ * 0.5;
		};

		static __hue_color__ = function(_deg) {
			var _h255 = clamp((_deg / 360.0) * 255.0, 0, 255);
			return make_color_hsv(_h255, 255, 255);
		};

		static __draw_wheel__ = function() {
			__update_wheel_geometry__();

			// Hue ring via triangle strip
			var _segs = 64;
			draw_primitive_begin(pr_trianglestrip);
			for (var i = 0; i <= _segs; i += 1) {
				var a = (i / _segs) * 360.0;
				var ca = cos(a);
				var sa = sin(a);
				var col = __hue_color__(a);
				draw_vertex_color(__wheel_cx__ + ca * __wheel_outer__, __wheel_cy__ + sa * __wheel_outer__, col, 1);
				draw_vertex_color(__wheel_cx__ + ca * __wheel_inner__, __wheel_cy__ + sa * __wheel_inner__, col, 1);
			}
			draw_primitive_end();

			// SV square
			var _base = __hue_color__(__h__);
			draw_set_alpha(1);
			draw_rectangle_color(__sq_x__, __sq_y__, __sq_x__ + __sq_s__, __sq_y__ + __sq_s__, c_white, _base, _base, c_white, false);

			// Value overlay (top transparent -> bottom black)
			draw_primitive_begin(pr_trianglestrip);
			draw_vertex_color(__sq_x__, __sq_y__, c_black, 0);
			draw_vertex_color(__sq_x__ + __sq_s__, __sq_y__, c_black, 0);
			draw_vertex_color(__sq_x__, __sq_y__ + __sq_s__, c_black, 1);
			draw_vertex_color(__sq_x__ + __sq_s__, __sq_y__ + __sq_s__, c_black, 1);
			draw_primitive_end();

			// Selection markers
			// Hue marker on ring
			var _ha = __h__;
			var _hx = __wheel_cx__ + cos(_ha) * ((__wheel_outer__ + __wheel_inner__) * 0.5);
			var _hy = __wheel_cy__ + sin(_ha) * ((__wheel_outer__ + __wheel_inner__) * 0.5);
			draw_set_alpha(1);
			draw_set_color(c_black);
			draw_circle(_hx, _hy, 4, false);
			draw_set_color(c_white);
			draw_circle(_hx, _hy, 3, false);

			// SV marker in square
			var _sx = __sq_x__ + __s__ * __sq_s__;
			var _sy = __sq_y__ + (1.0 - __v__) * __sq_s__;
			draw_set_color(c_black);
			draw_circle(_sx, _sy, 4, false);
			draw_set_color(c_white);
			draw_circle(_sx, _sy, 3, false);
		};

		static __wheel_apply_mouse__ = function() {
			__update_wheel_geometry__();
			var mx = device_mouse_x_to_gui(0);
			var my = device_mouse_y_to_gui(0);
			var dx = mx - __wheel_cx__;
			var dy = my - __wheel_cy__;
			var dist = sqrt(dx * dx + dy * dy);

			var _did = false;

			// Hue ring
			if (dist >= __wheel_inner__ && dist <= __wheel_outer__) {
				var ang = arctan2(dy, dx);
				__h__ = (ang + 360.0) mod 360.0;
				_did = true;
			}
			// SV square
			else if (mx >= __sq_x__ && mx <= __sq_x__ + __sq_s__ && my >= __sq_y__ && my <= __sq_y__ + __sq_s__) {
				__s__ = clamp((mx - __sq_x__) / __sq_s__, 0, 1);
				__v__ = clamp(1.0 - ((my - __sq_y__) / __sq_s__), 0, 1);
				_did = true;
			}

			if (_did) {
				__sync_color_from_hsv__();
				__sync_inputs__();
				__fire__("wheel");
			}
		};

		#endregion

	#endregion

	// Defaults
	set_size(380, 230);
	set_more(true);
	set_use_alpha(true);
	set_color(c_white, 1);

	// Wheel draw + interaction
	wheel.on_pre_draw(function(_input) {
		__draw_wheel__();
	});
	wheel.on_pressed(function(_input) {
		__wheel_apply_mouse__();
	});
	wheel.on_held(function(_input) {
		__wheel_apply_mouse__();
	});

	// Mode toggle
	btn_mode.set_callback(function() {
		set_more(!__show_more__);
	});

	// Numeric wiring
	var __on_rgb__ = function(_d) {
		if (__suppress__) { exit; }
		__col__ = make_color_rgb(in_r.get_value(), in_g.get_value(), in_b.get_value());
		__sync_from_color__();
		__sync_inputs__();
		__fire__("rgb");
	};
	in_r.on_value_change(__on_rgb__);
	in_g.on_value_change(__on_rgb__);
	in_b.on_value_change(__on_rgb__);

	var __on_hsv__ = function(_d) {
		if (__suppress__) { exit; }
		__h__ = clamp(in_h.get_value(), 0, 360);
		__s__ = clamp(in_s.get_value() / 100.0, 0, 1);
		__v__ = clamp(in_v.get_value() / 100.0, 0, 1);
		__sync_color_from_hsv__();
		__sync_inputs__();
		__fire__("hsv");
	};
	in_h.on_value_change(__on_hsv__);
	in_s.on_value_change(__on_hsv__);
	in_v.on_value_change(__on_hsv__);

	in_a.on_value_change(function(_d) {
		if (__suppress__) { exit; }
		__alpha__ = clamp(in_a.get_value(), 0, 1);
		__sync_inputs__();
		__fire__("alpha");
	});
}
