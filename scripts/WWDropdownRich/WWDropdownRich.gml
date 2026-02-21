#region jsDoc
/// @func    WWDropdownRich()
/// @desc    Dropdown for richer option payloads (label/value/custom row component).
/// @returns {Struct.WWDropdownRich}
#endregion
function WWDropdownRich() : WWDropdown() constructor {
	debug_name = "WWDropdownRich";
	
	#region Public
		#region Builder Functions
		static set_rich_array = function(_items=[]) {
			clear_rich_items();
			var _arr = is_array(_items) ? _items : [_items];
			for (var _i=0; _i<array_length(_arr); _i++) {
				add_rich_item(_arr[_i]);
			}
			return self;
		}
		
		static add_rich_item = function(_item, _value=undefined, _component=noone) {
			var _label = "";
			var _stored = _value;
			var _comp = _component;
			
			if (is_struct(_item) && !is_instanceof(_item, WWCore)) {
				if (variable_struct_exists(_item, "label")) _label = string(_item.label);
				if (variable_struct_exists(_item, "value")) _stored = _item.value;
				if (variable_struct_exists(_item, "component")) _comp = _item.component;
				if (_label == "") _label = string(_item);
			}
			else if (is_string(_item)) {
				_label = _item;
				if (is_undefined(_stored)) _stored = _label;
			}
			else if (is_instanceof(_item, WWCore)) {
				_comp = _item;
				_label = "";
			}
			else {
				_label = string(_item);
				if (is_undefined(_stored)) _stored = _item;
			}
			
			if (!is_instanceof(_comp, WWCore)) {
				_comp = new WWButtonText().set_text(_label).set_size(width, get_row_height());
			}
			
			var _idx = array_length(__rich_values__);
			_comp.__dropdown_label__ = _label;
			_comp.__dropdown_owner__ = self;
			_comp.__dropdown_rich_index__ = _idx;
			
			if (is_callable(_comp.on_released)) {
				_comp.on_released(method(_comp, function(_input) {
					self.__dropdown_owner__.set_value(self.__dropdown_rich_index__);
				}));
			}
			
			array_push(__rich_values__, _stored);
			add(_comp);
			return self;
		}
		
		static clear_rich_items = function() {
			clear_items();
			__rich_values__ = [];
			return self;
		}
		#endregion
		
		#region Variables
			__rich_values__ = [];
		#endregion
		
		#region Functions
			static get_selected_rich_value = function() {
				var _idx = get_value();
				if ((_idx < 0) || (_idx >= array_length(__rich_values__))) return undefined;
				return __rich_values__[_idx];
			}
		#endregion
	#endregion
	
	set_text("Select...");
}
