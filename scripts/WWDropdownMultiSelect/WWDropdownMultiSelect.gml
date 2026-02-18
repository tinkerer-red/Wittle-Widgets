#region jsDoc
/// @func    WWDropdownMultiSelect()
/// @desc    Multi-select dropdown using toggle rows and summary header text.
/// @returns {Struct.WWDropdownMultiSelect}
#endregion
function WWDropdownMultiSelect() : WWDropdown() constructor {
	debug_name = "WWDropdownMultiSelect";
	
	#region Public
		#region Builder Functions
		static set_options = function(_labels=[]) {
			clear_options();
			var _arr = is_array(_labels) ? _labels : [_labels];
			for (var _i=0; _i<array_length(_arr); _i++) {
				add_option(_arr[_i], false);
			}
			__update_summary__();
			return self;
		}
		
		static add_option = function(_label, _selected=false) {
			var _text = is_string(_label) ? _label : string(_label);
			array_push(__option_labels__, _text);
			array_push(__option_selected__, _selected);
			
			var _idx = array_length(__option_labels__) - 1;
			var _row = new WWButtonText().set_size(width, get_row_height());
			_row.__dropdown_multi_index__ = _idx;
			_row.__dropdown_owner__ = self;
			_row.set_callback(method(_row, function(_input) {
				if (!variable_struct_exists(self, "__dropdown_owner__")) { exit; }
				if (!variable_struct_exists(self, "__dropdown_multi_index__")) { exit; }
				var _owner = self.__dropdown_owner__;
				if (!is_struct(_owner)) { exit; }
				if (!variable_struct_exists(_owner, "__toggle_index__")) { exit; }
				if (!is_callable(_owner.__toggle_index__)) { exit; }
				_owner.__toggle_index__(self.__dropdown_multi_index__);
			}));
			
			array_push(__option_rows__, _row);
			add(_row);
			__refresh_row_text__(_idx);
			return self;
		}
		
		static clear_options = function() {
			clear_items();
			__option_labels__ = [];
			__option_selected__ = [];
			__option_rows__ = [];
			__update_summary__();
			return self;
		}
		
		static set_selected_indices = function(_indices=[]) {
			for (var _i=0; _i<array_length(__option_selected__); _i++) {
				__option_selected__[_i] = false;
			}
			
			var _arr = is_array(_indices) ? _indices : [_indices];
			for (var _j=0; _j<array_length(_arr); _j++) {
				var _idx = _arr[_j];
				if ((_idx >= 0) && (_idx < array_length(__option_selected__))) {
					__option_selected__[_idx] = true;
				}
			}
			
			for (var _k=0; _k<array_length(__option_rows__); _k++) {
				__refresh_row_text__(_k);
			}
			
			__update_summary__();
			trigger_event(events.changed, __event_payload_multi__());
			return self;
		}
		
		static set_close_on_toggle = function(_enabled=false) {
			__close_on_toggle__ = _enabled;
			return self;
		}
		#endregion
		
		#region Events
			events.selection_changed = variable_get_hash("selection_changed");
		#endregion
		
		#region Variables
			__option_labels__ = [];
			__option_selected__ = [];
			__option_rows__ = [];
			__close_on_toggle__ = false;
		#endregion
		
		#region Functions
			static get_selected_indices = function() {
				var _out = [];
				for (var _i=0; _i<array_length(__option_selected__); _i++) {
					if (__option_selected__[_i]) array_push(_out, _i);
				}
				return _out;
			}
			
			static get_selected_texts = function() {
				var _out = [];
				for (var _i=0; _i<array_length(__option_selected__); _i++) {
					if (__option_selected__[_i]) array_push(_out, __option_labels__[_i]);
				}
				return _out;
			}
		#endregion
	#endregion
	
	#region Private
		#region Variables
			__event_data_multi__ = { indices:[], labels:[] };
		#endregion
		
		#region Functions
		static __refresh_row_text__ = function(_index) {
			if ((_index < 0) || (_index >= array_length(__option_rows__))) return;
			var _prefix = __option_selected__[_index] ? "[x] " : "[ ] ";
			__option_rows__[_index].set_text(_prefix + __option_labels__[_index]);
		}
		
		static __toggle_index__ = function(_index) {
			if ((_index < 0) || (_index >= array_length(__option_selected__))) return;
			__option_selected__[_index] = !__option_selected__[_index];
			__refresh_row_text__(_index);
			__update_summary__();
			
			trigger_event(events.selection_changed, __event_payload_multi__());
			trigger_event(events.changed, __event_payload_multi__());
			
			if (__close_on_toggle__) set_open(false);
		}
		
		static __update_summary__ = function() {
			var _texts = get_selected_texts();
			var _count = array_length(_texts);
			if (_count == 0) {
				set_text("Select...");
				return;
			}
			if (_count <= 2) {
				set_text(string_join_ext(", ", _texts));
				return;
			}
			set_text($"{_count} selected");
		}
		
		static __event_payload_multi__ = function() {
			__event_data_multi__.indices = get_selected_indices();
			__event_data_multi__.labels = get_selected_texts();
			return __event_data_multi__;
		}
		#endregion
	#endregion
	
	set_text("Select...");
	set_close_on_toggle(false);
}
