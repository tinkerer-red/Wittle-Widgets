#region jsDoc
/// @func    WWSearchInput()
/// @desc    Text input with a trailing action icon button (search/clear UX only).
/// @returns {Struct.WWSearchInput}
#endregion
function WWSearchInput() : WWCore() constructor {
	debug_name = "WWSearchInput";

	#region Public
		#region Events
		events.changed = variable_get_hash("changed");
		events.submitted = variable_get_hash("submitted");
		events.action = variable_get_hash("action");
		#endregion

		#region Variables
		value = "";
		action_mode = "clear"; // "focus" | "clear"
		__has_query_cached__ = false;
		#endregion

		#region Components
		input = new WWInputString().set_size(120, 22);
		action_button = new WWButtonIcon()
			.set_size(24, 22)
			.set_fallback_text("?")
			.set_callback(method(self, function() {
				var _current = string(input.get_value());
				trigger_event(events.action, __event_payload__());
				if (action_mode == "clear") {
					if (_current != "") {
						set_value("");
						trigger_event(events.changed, __event_payload__());
					}
					else {
						input.set_focus(true);
						var _field = input.get_field();
						if (!is_undefined(_field) && _field != noone && is_callable(_field.set_focus)) {
							_field.set_focus(true);
						}
					}
				}
				else {
					input.set_focus(true);
					var _field2 = input.get_field();
					if (!is_undefined(_field2) && _field2 != noone && is_callable(_field2.set_focus)) {
						_field2.set_focus(true);
					}
				}
			}));
		add([input, action_button]);
		#endregion

		#region Builder Functions
		static set_size = function(_w, _h) {
			static __base_set_size__ = WWCore.set_size;
			__base_set_size__(_w, _h);
			__layout__();
			return self;
		};

		static set_value = function(_value="") {
			value = string(_value);
			input.set_value(value);
			__sync_action_icon__();
			return self;
		};

		static set_placeholder = function(_text="") {
			var _field = input.get_field();
			if (!is_undefined(_field) && _field != noone && is_callable(_field.set_caption)) {
				_field.set_caption(string(_text));
			}
			return self;
		};

		static set_action_mode = function(_mode="focus") {
			action_mode = _mode;
			return self;
		};
		#endregion

		#region Functions
		static get_value = function() { return value; };
		static get_input = function() { return input; };
		static get_action_button = function() { return action_button; };
		static on_change = function(_func) { add_event_listener(events.changed, _func); return self; };
		static on_submit = function(_func) { add_event_listener(events.submitted, _func); return self; };
		static on_action = function(_func) { add_event_listener(events.action, _func); return self; };
		#endregion
	#endregion

	#region Private
		#region Variables
		__event_data__ = { source:self, value:"" };
		#endregion

		#region Functions
		static __event_payload__ = function() {
			__event_data__.source = self;
			__event_data__.value = value;
			return __event_data__;
		};

		static __layout__ = function() {
			var _btn_w = 24;
			action_button.set_square_size(min(_btn_w, height));
			action_button.set_offset(max(0, width - _btn_w), 0);
			input.set_offset(0, 0);
			input.set_size(max(1, width - _btn_w - 4), height);
		};

		static __sync_action_icon__ = function() {
			var _has_query = (string_trim(value) != "");
			if (__has_query_cached__ == _has_query) return;
			__has_query_cached__ = _has_query;
			action_button.set_icon_fa(_has_query ? "xmark" : "magnifying-glass", "solid");
			action_button.set_fallback_text(_has_query ? "X" : "?");
		};
		#endregion
	#endregion

	input.on_change(method(self, function(_d) {
		value = input.get_value();
		__sync_action_icon__();
		trigger_event(events.changed, __event_payload__());
	}));
	input.on_submit(method(self, function(_d) {
		value = input.get_value();
		trigger_event(events.submitted, __event_payload__());
	}));

	set_size(180, 22);
	__has_query_cached__ = !__has_query_cached__;
	__sync_action_icon__();
}
