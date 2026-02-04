#region jsDoc
/// @func    WWColorInput()
/// @desc    Inspector-friendly color input: shows a swatch and opens a WWColorPicker window on click.
/// @returns {Struct.WWColorInput}
#endregion
function WWColorInput() : WWCore() constructor {
	debug_name = "WWColorInput";
	var __self__ = self;

	#region Public

		#region Events
		events.color_change = variable_get_hash("color_change");
		#endregion

		#region Components
		btn = new WWButtonText().set_text("");
		add(btn);
		#endregion

		#region Variables
		__col__ = c_white;
		__alpha__ = 1;
		__use_alpha__ = true;
		__picker_window__ = undefined;
		__picker__ = undefined;
		__event_data__ = { color: c_white, alpha: 1, source: "" };
		#endregion

		#region Builder Functions
		static set_size = function(_w, _h) {
			__size_set__ = true;
			__set_size__(_w, _h);
			btn.set_offset(0, 0);
			btn.set_size(_w, _h);
			return self;
		};

		static set_color = function(_color, _alpha=__alpha__) {
			__col__ = _color;
			__alpha__ = clamp(_alpha, 0, 1);
			return self;
		};

		static set_use_alpha = function(_use_alpha=true) {
			__use_alpha__ = _use_alpha;
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

		static __get_root__ = function() {
			var r = __self__;
			while (!is_undefined(r.__parent__)) {
				r = r.__parent__;
			}
			return r;
		};

		static __close_picker__ = function() {
			if (!is_undefined(__picker_window__)) {
				if (!is_undefined(__picker_window__.__parent__)) {
					__picker_window__.__parent__.remove(__picker_window__);
				}
			}
			__picker_window__ = undefined;
			__picker__ = undefined;
		};

		static __open_picker__ = function() {
			__close_picker__();

			var root = __get_root__();
			var win = new WWWindow().set_title("Color");
			var picker = new WWColorPicker();
			picker.set_use_alpha(__use_alpha__);
			picker.set_color(__col__, __alpha__);

			picker.on_color_change(function(_d) {
				__col__ = _d.color;
				__alpha__ = _d.alpha;
				__fire__("picker");
			});

			win.set_size(420, 260);
			win.set_content(picker);

			// Position near this control (clamp to 0..1280/720 bounds for now)
			var _x = clamp(__self__.x, 0, 1280 - win.width);
			var _y = clamp(__self__.y + __self__.height + 6, 0, 720 - win.height);
			win.set_offset(_x, _y);

			root.add(win);

			__picker_window__ = win;
			__picker__ = picker;
		};
		#endregion

	#endregion

	// Defaults
	set_size(160, 22);
	set_color(c_white, 1);

	// Swatch drawing overlay on the button
	btn.on_post_draw(function(_input) {
		var _pad = 3;
		var _sx1 = btn.x + _pad;
		var _sy1 = btn.y + _pad;
		var _sx2 = btn.x + btn.width - _pad;
		var _sy2 = btn.y + btn.height - _pad;

		// Checker background for alpha
		var _cs = 4;
		for (var yy = _sy1; yy < _sy2; yy += _cs) {
			for (var xx = _sx1; xx < _sx2; xx += _cs) {
				var _odd = ((floor((xx - _sx1) / _cs) + floor((yy - _sy1) / _cs)) mod 2) == 1;
				draw_set_alpha(1);
				draw_set_color(_odd ? c_gray : c_ltgray);
				draw_rectangle(xx, yy, min(xx + _cs, _sx2), min(yy + _cs, _sy2), false);
			}
		}

		draw_set_alpha(__alpha__);
		draw_set_color(__col__);
		draw_rectangle(_sx1, _sy1, _sx2, _sy2, false);

		draw_set_alpha(1);
		draw_set_color(c_black);
		draw_rectangle(_sx1, _sy1, _sx2, _sy2, true);
	});

	btn.set_callback(function() {
		__open_picker__();
	});
}
