#region jsDoc
/// @func    WWDropdownDateTime()
/// @desc    Date/time preset dropdown that stores selected datetime value.
/// @returns {Struct.WWDropdownDateTime}
#endregion
function WWDropdownDateTime() : WWDropdownSelect() constructor {
	debug_name = "WWDropdownDateTime";
	
	#region Public
		#region Builder Functions
		static set_mode = function(_mode="datetime") {
			__mode__ = string_lower(string(_mode));
			refresh_options();
			return self;
		}
		
		static refresh_options = function() {
			var _now = date_current_datetime();
			var _items = [];
			
			switch (__mode__) {
				case "date": {
					array_push(_items, { label: date_date_string(_now), value: _now });
					array_push(_items, { label: date_date_string(date_inc_day(_now, 1)), value: date_inc_day(_now, 1) });
					array_push(_items, { label: date_date_string(date_inc_day(_now, 7)), value: date_inc_day(_now, 7) });
					break;
				}
				case "time": {
					array_push(_items, { label: date_time_string(_now), value: _now });
					array_push(_items, { label: date_time_string(date_inc_hour(_now, 1)), value: date_inc_hour(_now, 1) });
					array_push(_items, { label: date_time_string(date_inc_hour(_now, 2)), value: date_inc_hour(_now, 2) });
					break;
				}
				default: {
					array_push(_items, { label: date_datetime_string(_now), value: _now });
					array_push(_items, { label: date_datetime_string(date_inc_hour(_now, 1)), value: date_inc_hour(_now, 1) });
					array_push(_items, { label: date_datetime_string(date_inc_day(_now, 1)), value: date_inc_day(_now, 1) });
					array_push(_items, { label: date_datetime_string(date_inc_month(_now, 1)), value: date_inc_month(_now, 1) });
					break;
				}
			}
			
			set_options(_items);
			if (array_length(_items) > 0) set_value(0);
			return self;
		}
		#endregion
		
		#region Variables
			__mode__ = "datetime";
		#endregion
		
		#region Functions
			static get_mode = function() {
				return __mode__;
			}
			
			static get_datetime_value = function() {
				return get_selected_value();
			}
		#endregion
	#endregion
	
	set_text("Select date/time...");
	refresh_options();
	
	on_event(events.opened, function(_data) {
		refresh_options();
	});
}
