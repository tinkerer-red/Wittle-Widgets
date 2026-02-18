#region jsDoc
/// @func    WWDropdownSelect()
/// @desc    Value-select dropdown with label/value option mapping.
/// @returns {Struct.WWDropdownSelect}
#endregion
function WWDropdownSelect() : WWDropdown() constructor {
	debug_name = "WWDropdownSelect";
	
	#region Public
		#region Builder Functions
		static set_options = function(_options=[]) {
			__option_labels__ = [];
			__option_values__ = [];
			clear_items();
			
			var _arr = is_array(_options) ? _options : [_options];
			for (var _i=0; _i<array_length(_arr); _i++) {
				add_option(_arr[_i]);
			}
			return self;
		}
		
		static add_option = function(_option, _value=undefined) {
			var _label = "";
			var _stored = _value;
			
			if (is_string(_option)) {
				_label = _option;
				if (is_undefined(_stored)) _stored = _option;
			}
			else if (is_struct(_option)) {
				_label = variable_struct_exists(_option, "label") ? _option.label : string(_option);
				if (variable_struct_exists(_option, "value")) _stored = _option.value;
				if (is_undefined(_stored)) _stored = _label;
			}
			else {
				_label = string(_option);
				if (is_undefined(_stored)) _stored = _option;
			}
			
			array_push(__option_labels__, _label);
			array_push(__option_values__, _stored);
			add(_label);
			return self;
		}
		
		static set_selected_value = function(_value) {
			for (var _i=0; _i<array_length(__option_values__); _i++) {
				if (__option_values__[_i] == _value) {
					set_value(_i);
					return self;
				}
			}
			set_value(-1);
			return self;
		}
		#endregion
		
		#region Variables
			__option_labels__ = [];
			__option_values__ = [];
		#endregion
		
		#region Functions
			static get_options = function() {
				return __option_labels__;
			}
			
			static get_selected_value = function() {
				var _idx = get_value();
				if ((_idx < 0) || (_idx >= array_length(__option_values__))) return undefined;
				return __option_values__[_idx];
			}
		#endregion
	#endregion
	
	set_text("Select...");
}
