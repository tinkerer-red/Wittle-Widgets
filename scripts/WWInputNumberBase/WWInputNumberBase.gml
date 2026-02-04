#region jsDoc
/// @func    WWInputNumberBase()
/// @desc    Internal base for numeric input controls.
///          Provides a single-line text input with stepper up/down buttons.
///          Intended to be subclassed by WWInputInt / WWInputReal.
/// @returns {Struct.WWInputNumberBase}
/// @ignore
#endregion
function WWInputNumberBase() : WWCore() constructor {
	debug_name = "WWInputNumberBase";

	#region Public

		#region Components
			input = new WWTextInputSingleLine();
			btn_up = new WWButtonText();
			btn_dn = new WWButtonText();
			add([input, btn_up, btn_dn]);
		#endregion

		#region Variables
			__value__ = 0;
			__min__ = -infinity;
			__max__ = infinity;
			__step__ = 1;
			__decimals__ = 2;
			__is_int__ = false;
			__live_update__ = true;

			__btn_w__ = 18;
			__suppress__ = false;
			__parsed_value__ = 0;
			__event_data__ = { value: 0, source: "", text: "" };
		#endregion

		#region Events
			events.value_change = variable_get_hash("value_change");
		#endregion

		#region Builder Functions

			#region jsDoc
			/// @func    set_size(width, height)
			/// @desc    Sets control size and relayouts internal widgets.
			/// @self    WWInputNumberBase
			/// @param   {Real} width
			/// @param   {Real} height
			/// @returns {Struct.WWInputNumberBase}
			#endregion
			static set_size = function(_width, _height) {
				__size_set__ = true;
				__set_size__(_width, _height);

				var _btn_w = __btn_w__;
				if (_btn_w < 10) { _btn_w = 10; }
				if (_btn_w > _width) { _btn_w = _width; }

				var _inp_w = _width - _btn_w;
				if (_inp_w < 0) { _inp_w = 0; }

				input.set_offset(0, 0);
				input.set_size(_inp_w, _height);

				var _half = floor(_height * 0.5);
				btn_up.set_offset(_inp_w, 0);
				btn_up.set_size(_btn_w, _half);
				btn_dn.set_offset(_inp_w, _half);
				btn_dn.set_size(_btn_w, _height - _half);

				// Keep button labels centered-ish.
				btn_up.set_text_offsets(0, -2, 0);
				btn_dn.set_text_offsets(0, -2, 0);

				return self;
			};

			#region jsDoc
			/// @func    set_value(value)
			/// @desc    Sets the numeric value (clamped) and refreshes text.
			/// @self    WWInputNumberBase
			/// @param   {Real} value
			/// @returns {Struct.WWInputNumberBase}
			#endregion
			static set_value = function(_value) {
				_value = clamp(_value, __min__, __max__);
				if (__is_int__) { _value = floor(_value); }
				__value__ = _value;
				__refresh_text__();
				return self;
			};

			#region jsDoc
			/// @func    set_min(value)
			/// @desc    Sets the minimum allowed value.
			/// @self    WWInputNumberBase
			/// @param   {Real} value
			/// @returns {Struct.WWInputNumberBase}
			#endregion
			static set_min = function(_value) { __min__ = _value; return set_value(__value__); };

			#region jsDoc
			/// @func    set_max(value)
			/// @desc    Sets the maximum allowed value.
			/// @self    WWInputNumberBase
			/// @param   {Real} value
			/// @returns {Struct.WWInputNumberBase}
			#endregion
			static set_max = function(_value) { __max__ = _value; return set_value(__value__); };

			#region jsDoc
			/// @func    set_step(value)
			/// @desc    Sets the step amount used by the up/down buttons.
			/// @self    WWInputNumberBase
			/// @param   {Real} value
			/// @returns {Struct.WWInputNumberBase}
			#endregion
			static set_step = function(_value) { __step__ = _value; return self; };

			#region jsDoc
			/// @func    set_decimals(count)
			/// @desc    Sets the displayed decimal precision (real inputs).
			/// @self    WWInputNumberBase
			/// @param   {Real} count
			/// @returns {Struct.WWInputNumberBase}
			#endregion
			static set_decimals = function(_count) { __decimals__ = max(0, floor(_count)); __refresh_text__(); return self; };

			#region jsDoc
			/// @func    set_live_update(enabled)
			/// @desc    If enabled, typing updates the value when the text parses.
			/// @self    WWInputNumberBase
			/// @param   {Bool} enabled
			/// @returns {Struct.WWInputNumberBase}
			#endregion
			static set_live_update = function(_enabled=true) { __live_update__ = _enabled; return self; };

			#region jsDoc
			/// @func    set_button_width(width)
			/// @desc    Sets the width of the stepper button strip.
			/// @self    WWInputNumberBase
			/// @param   {Real} width
			/// @returns {Struct.WWInputNumberBase}
			#endregion
			static set_button_width = function(_width) { __btn_w__ = _width; return set_size(width, height); };

			#region jsDoc
			/// @func    on_value_change(func)
			/// @desc    Adds a listener fired when the numeric value changes.
			/// @self    WWInputNumberBase
			/// @param   {Function} func
			/// @returns {Struct.WWInputNumberBase}
			#endregion
			static on_value_change = function(_func) { add_event_listener(events.value_change, _func); return self; };

		#endregion

		#region Functions

			#region jsDoc
			/// @func    get_value()
			/// @desc    Returns the current numeric value.
			/// @self    WWInputNumberBase
			/// @returns {Real}
			#endregion
			static get_value = function() { return __value__; };

			#region jsDoc
			/// @func    get_input()
			/// @desc    Returns the internal WWTextInputSingleLine.
			/// @self    WWInputNumberBase
			/// @returns {Struct.WWTextInputSingleLine}
			#endregion
			static get_input = function() { return input; };

			// Stable extents for parent layout.
			static get_group_width = function() { return width; };
			static get_group_height = function() { return height; };

		#endregion

	#endregion

	#region Private

		#region Functions

			static __format_value__ = function(_v) {
				if (__is_int__) {
					return string(floor(_v));
				}
				return string_format(_v, 0, __decimals__);
			};

			static __refresh_text__ = function() {
				__suppress__ = true;
				input.set_value(__format_value__(__value__));
				__suppress__ = false;
			};

			static __try_parse__ = function(_s) {
				_s = string_trim(string(_s));
				if (_s == "") { return false; }

				var _has_digit = false;
				var _len = string_length(_s);
				for (var _i = 1; _i <= _len; _i += 1) {
					var _ch = string_char_at(_s, _i);
					if ((_ch >= "0") && (_ch <= "9")) { _has_digit = true; continue; }
					if (_ch == "." || _ch == "-" || _ch == "+" || _ch == "e" || _ch == "E") { continue; }
					return false;
				}
				if (!_has_digit) { return false; }

				__parsed_value__ = real(_s);
				if (__is_int__) { __parsed_value__ = floor(__parsed_value__); }
				return true;
			};

			static __fire_change__ = function(_source) {
				__event_data__.value = __value__;
				__event_data__.source = _source;
				__event_data__.text = input.get_value();
				trigger_event(events.value_change, __event_data__);
			};

			static __commit_text__ = function(_source) {
				var _t = input.get_value();
				if (__try_parse__(_t)) {
					var _newv = clamp(__parsed_value__, __min__, __max__);
					var _changed = (_newv != __value__);
					set_value(_newv);
					if (_changed) { __fire_change__(_source); }
				}
				else {
					// Revert invalid text.
					__refresh_text__();
				}
			};

		#endregion

	#endregion

	// Defaults / setup
	input.set_size(160 - __btn_w__, 22);
	btn_up.set_text("▲").set_text_font(fnt_ww_consolas_msdf);
	btn_dn.set_text("▼").set_text_font(fnt_ww_consolas_msdf);

	btn_up.set_callback(function() {
		set_value(__value__ + __step__);
		__fire_change__("step_up");
	});
	btn_dn.set_callback(function() {
		set_value(__value__ - __step__);
		__fire_change__("step_down");
	});

	input.on_submit(function(_data) {
		if (__suppress__) { exit; }
		__commit_text__("submit");
	});
	input.on_change(function(_data) {
		if (__suppress__) { exit; }
		if (!__live_update__) { exit; }
		if (__try_parse__(input.get_value())) {
			var _newv = clamp(__parsed_value__, __min__, __max__);
			if (_newv != __value__) {
				__value__ = _newv;
				__fire_change__("type");
			}
		}
	});

	set_size(160, 22);
	set_value(0);
}
