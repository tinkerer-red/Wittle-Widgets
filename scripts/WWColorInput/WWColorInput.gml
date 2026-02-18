#region jsDoc
/// @func    WWColorInput()
/// @desc    Inspector-friendly color input: shows a swatch and opens a WWColorPicker window on click.
/// @returns {Struct.WWColorInput}
#endregion
function WWColorInput() : WWCore() constructor {
	debug_name = "WWColorInput";
	
	#region Public

		#region Events
		events.color_change = variable_get_hash("color_change");
		#endregion

		#region Components
		btn = new WWButton();
		__picker__ = new WWColorPicker()
			.on_color_change(function() {
				__commit_picker_close__();
			})
		__picker_window__ = new WWWindow()
			.set_title("Color")
			.set_size(560, 360)
			.set_content(__picker__)
			.set_open(false)
		
		// Picker events (wired once).
		__picker__.on_color_change(function(_d) {
			__col__ = _d.color;
			__alpha__ = _d.alpha;
			__fire__("picker");
		});
		
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
		
		add(btn);
		add(__picker_window__);
		#endregion

		#region Variables
		__col__ = c_white;
		__alpha__ = 1;
		__use_alpha__ = true;
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

		static __commit_picker_close__ = function() {
			__col__ = __picker__.get_color();
			__alpha__ = __picker__.get_alpha();
			__fire__("close");
		};
		
		static __close_picker__ = function() {
			__picker_window__.set_open(false);
		};

		static __open_picker__ = function() {
			__picker__.set_use_alpha(__use_alpha__);
			__picker__.set_color(__col__, __alpha__);
			__picker_window__.set_open(true);

			// Position near this control and clamp to active GUI size.
			var _gui_w = max(1, display_get_gui_width());
			var _gui_h = max(1, display_get_gui_height());
			var _x = clamp(self.x, 0, _gui_w - __picker_window__.width);
			var _y = clamp(self.y + self.height + 6, 0, _gui_h - __picker_window__.height);
			if (__picker_window__.__is_child__) {
				__picker_window__.set_offset(_x - __picker_window__.__parent__.x, _y - __picker_window__.__parent__.y);
			}
			else {
				__picker_window__.set_offset(_x, _y);
			}
			__picker_window__.bring_to_front();
		};
		#endregion

	#endregion

	
}
