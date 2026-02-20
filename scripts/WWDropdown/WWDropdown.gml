#region jsDoc
/// @func    WWDropdown()
/// @desc    Generic dropdown core: pluggable header component + hoisted overlay menu.
/// @returns {Struct.WWDropdown}
#endregion
function WWDropdown() : WWCore() constructor {
	debug_name = "WWDropdown";
	
	#region Public
		#region Builder Functions
		static set_size = function(_width, _height) {
			static __base_set_size__ = WWCore.set_size;
			__base_set_size__(_width, _height);
			__refresh_dropdown_layout__();
			return self;
		}
		
		static set_header = function(_header_component) {
			if (!is_instanceof(_header_component, WWCore)) return self;
			if (_header_component.__comp_id__ == __menu_overlay__.__comp_id__) return self;
			
			if (is_struct(__header_component__)) {
				if (__header_component__.__is_child__ && (__header_component__.__parent__.__comp_id__ == __comp_id__)) {
					remove(__header_component__);
				}
			}
			
			__header_component__ = _header_component;
			static __base_add__ = WWCore.add;
			__base_add__(__header_component__);
			
			__bind_header_events__();
			if (current_index == -1) __header_set_text__(__default_text__);
			else __header_set_text__(__item_label_at__(current_index));
			
			__refresh_dropdown_layout__();
			return self;
		}
		
		static set_header_toggle_enabled = function(_enabled=true) {
			__header_toggle_enabled__ = _enabled;
			return self;
		}
		
		static set_item_builder = function(_builder_fn=undefined) {
			if (is_undefined(_builder_fn) || !is_callable(_builder_fn)) {
				__item_builder__ = undefined;
			}
			else {
				__item_builder__ = _builder_fn;
			}
			return self;
		}
		
		static set_text = function(_text="Select...") {
			__default_text__ = _text;
			if (current_index == -1) {
				__header_set_text__(_text);
			}
			return self;
		}
		
		static set_open = function(_is_open=true) {
			var _prev = is_open;
			is_open = _is_open;
			__menu_overlay__.set_active(is_open);
			if (is_open) {
				__menu_overlay__.bring_to_front();
			}
			
			if (_prev != is_open) {
				if (is_open) trigger_event(events.opened, __event_payload__());
				else trigger_event(events.closed, __event_payload__());
			}
			
			return self;
		}
		
		static set_value = function(_index) {
			var _prev = current_index;
			
			if (_index < -1) _index = -1;
			if (_index >= __items_count__) _index = __items_count__ - 1;
			current_index = _index;
			
			if (current_index == -1) {
				__header_set_text__(__default_text__);
				if (_prev != -1) {
					trigger_event(events.cleared, __event_payload__());
				}
				set_open(false);
				return self;
			}
			
			var _label = __item_label_at__(current_index);
			__header_set_text__(_label);
			set_open(false);
			trigger_event(events.selected, __event_payload__());
			if (_prev != current_index) {
				trigger_event(events.changed, __event_payload__());
			}
			return self;
		}
		
		static set_dropdown_array = function(_strings_array) {
			clear_items();
			add(_strings_array);
			return self;
		}
		
		static set_dropdown_anchor = function(_xoff=0, _yoff=undefined) {
			__dropdown_xoff__ = _xoff;
			if (is_undefined(_yoff)) {
				__dropdown_yoff_auto__ = true;
			}
			else {
				__dropdown_yoff_auto__ = false;
				__dropdown_yoff__ = _yoff;
			}
			__refresh_dropdown_layout__();
			return self;
		}
		
		static set_dropdown_space = function(_space=WWOverlaySpace.GLOBAL_ROOT) {
			__menu_overlay__.set_overlay_space(_space);
			return self;
		}
		
		static set_dropdown_host = function(_host=noone) {
			__menu_overlay__.set_overlay_host(_host);
			return self;
		}
		
		static set_dropdown_priority = function(_priority=0) {
			__menu_overlay__.set_overlay_priority(_priority);
			return self;
		}
		
		static set_row_height = function(_row_height) {
			__row_height__ = max(1, _row_height);
			__refresh_dropdown_layout__();
			return self;
		}
		
		static set_item_enabled = function(_index, _is_enabled) {
			if ((_index < 0) || (_index >= __items_count__)) return self;
			if (!is_struct(__items__[_index])) return self;
			if (!is_callable(__items__[_index].set_enabled)) return self;
			__items__[_index].set_enabled(_is_enabled);
			return self;
		}
		
		static add = function(_item) {
			var _arr = is_array(_item) ? _item : [_item];
			if (argument_count > 1) {
				for (var _i=1; _i<argument_count; _i++) {
					array_push(_arr, argument[_i]);
				}
			}
			
			for (var _i=0; _i<array_length(_arr); _i++) {
				var _elm = _arr[_i];
				var _comp = noone;
				if (is_callable(__item_builder__)) _comp = __item_builder__(_elm, self);
				if (!is_struct(_comp)) _comp = __make_default_item__(_elm);
				if (!is_instanceof(_comp, WWCore)) continue;
				__menu_overlay__.add(_comp);
				array_push(__items__, _comp);
				_comp.__dropdown_item_index__ = __items_count__;
				__bind_item_nav_overrides__(_comp);
				__items_count__ += 1;
			}
			
			__refresh_dropdown_layout__();
			return self;
		}
		
		static clear_items = function() {
			__menu_overlay__.clear_children();
			__items__ = [];
			__items_count__ = 0;
			current_index = -1;
			__header_set_text__(__default_text__);
			__refresh_dropdown_layout__();
			trigger_event(events.cleared, __event_payload__());
			return self;
		}
		#endregion
		
		#region Components
			__menu_overlay__ = new WWOverlay()
				.set_overlay_role(WWOverlayRole.DROPDOWN)
				.set_overlay_priority(0)
				.set_overlay_space(WWOverlaySpace.GLOBAL_ROOT)
				.set_active(false);
			
			__header_component__ = new WWButtonText()
				.set_text("Select...");
		#endregion
		
		#region Events
			events.opened   = variable_get_hash("opened");
			events.closed   = variable_get_hash("closed");
			events.selected = variable_get_hash("selected");
			events.changed  = variable_get_hash("changed");
			events.cleared  = variable_get_hash("cleared");
			
			on_pre_step(function(_input) {
				if (!is_open) return;
				if (!_input.pointer.left.pressed) return;
				if (mouse_on_group(_input)) return;
				if (__menu_overlay__.mouse_on_group(_input)) return;
				set_open(false);
			});
			
			on_deactivated(function(_input) {
				set_open(false);
			});
			
		#endregion
		
		#region Variables
			is_open = false;
			current_index = -1;
			
			__default_text__ = "Select...";
			__items__ = [];
			__items_count__ = 0;
			__row_height__ = 22;
			__dropdown_xoff__ = 0;
			__dropdown_yoff__ = 0;
			__dropdown_yoff_auto__ = true;
			
			__header_toggle_enabled__ = true;
			__item_builder__ = undefined;
		#endregion
		
		#region Functions
			static get_value = function() {
				return current_index;
			}
			
			static get_items_count = function() {
				return __items_count__;
			}
			
			static get_header = function() {
				return __header_component__;
			}
			
			static get_text = function() {
				return __header_get_text__();
			}
			
			static get_open = function() {
				return is_open;
			}
			
			static get_dropdown_priority = function() {
				return __menu_overlay__.__overlay_priority__;
			}
			
			static get_row_height = function() {
				return __row_height__;
			}
			
			static update_component_positions = function() {
				static __base_update__ = WWCore.update_component_positions;
				__refresh_dropdown_layout__();
				__base_update__();
			}
			static handle_keyboard_submit_override = function(_input) {
				if (is_open) {
					if (__keyboard_select_current_nav_item__()) {
						return true;
					}
				}
				return __keyboard_open_and_focus_first_item__(_input);
			}
			static handle_keyboard_cancel_override = function(_input) {
				return __keyboard_close_and_focus_header__(_input);
			}
		#endregion
	#endregion
	
	#region Private
		#region Variables
			__event_data__ = { index : -1, text : "", component : noone };
		#endregion
		
		#region Functions
		static __bind_header_events__ = function() {
			if (!is_struct(__header_component__)) return;
			__header_component__.__dropdown_owner__ = self;
			if (variable_struct_exists(__header_component__, "text_component")) {
				var _header_text = __header_component__.text_component;
				if (is_struct(_header_text) && is_callable(_header_text.set_focusable)) {
					_header_text.set_focusable(false);
				}
			}
			__header_component__.handle_keyboard_submit_override = function(_input) {
				if (!variable_struct_exists(self, "__dropdown_owner__")) return false;
				var _owner = self.__dropdown_owner__;
				if (!is_struct(_owner)) return false;
				return _owner.__keyboard_open_and_focus_first_item__(_input);
			}
			__header_component__.handle_keyboard_cancel_override = function(_input) {
				if (!variable_struct_exists(self, "__dropdown_owner__")) return false;
				var _owner = self.__dropdown_owner__;
				if (!is_struct(_owner)) return false;
				return _owner.__keyboard_close_and_focus_header__(_input);
			}
			__header_component__.handle_keyboard_nav_override = function(_direction) {
				if (!variable_struct_exists(self, "__dropdown_owner__")) return undefined;
				var _owner = self.__dropdown_owner__;
				if (!is_struct(_owner)) return undefined;
				return _owner.__keyboard_nav_override_from__(self, _direction);
			}
			if (variable_struct_exists(__header_component__, "on_released")) {
				var _on_released = variable_struct_get(__header_component__, "on_released");
				if (!is_callable(_on_released)) return;
				__header_component__.on_released(function(_input) {
					if (!__header_toggle_enabled__) return;
					set_open(!is_open);
				});
			}
		}
		static __bind_item_nav_overrides__ = function(_comp) {
			if (!is_struct(_comp)) return;
			_comp.__dropdown_owner__ = self;
			if (variable_struct_exists(_comp, "text_component")) {
				var _item_text = _comp.text_component;
				if (is_struct(_item_text) && is_callable(_item_text.set_focusable)) {
					_item_text.set_focusable(false);
				}
			}
			_comp.handle_keyboard_submit_override = function(_input) {
				if (!variable_struct_exists(self, "__dropdown_owner__")) return false;
				if (!variable_struct_exists(self, "__dropdown_item_index__")) return false;
				var _owner = self.__dropdown_owner__;
				if (!is_struct(_owner)) return false;
				var _idx = self.__dropdown_item_index__;
				if (_idx < 0) return false;
				_owner.set_value(_idx);
				_owner.__keyboard_focus_header__();
				return true;
			}
			_comp.handle_keyboard_cancel_override = function(_input) {
				if (!variable_struct_exists(self, "__dropdown_owner__")) return false;
				var _owner = self.__dropdown_owner__;
				if (!is_struct(_owner)) return false;
				return _owner.__keyboard_close_and_focus_header__(_input);
			}
			_comp.handle_keyboard_nav_override = function(_direction) {
				if (!variable_struct_exists(self, "__dropdown_owner__")) return undefined;
				var _owner = self.__dropdown_owner__;
				if (!is_struct(_owner)) return undefined;
				return _owner.__keyboard_nav_override_from__(self, _direction);
			}
		}
		static __keyboard_focus_header__ = function() {
			if (!is_struct(__header_component__)) return false;
			var _root = __root_canvas__;
			if (!is_struct(_root)) _root = self;
			var _assigned = _root.__focus_registry_set_target__(__header_component__, false);
			return is_struct(_assigned);
		}
		static __keyboard_find_first_navigable_item__ = function() {
			for (var _i=0; _i<__items_count__; _i++) {
				var _comp = __items__[_i];
				if (!is_struct(_comp)) continue;
				if (!_comp.__is_focusable__) continue;
				if (!_comp.__is_enabled__) continue;
				if (!_comp.__is_active__) continue;
				if (variable_struct_exists(_comp, "visible") && !_comp.visible) continue;
				return _comp;
			}
			return noone;
		}
		static __keyboard_get_nav_scope__ = function() {
			var _scope = [];
			for (var _i=0; _i<__items_count__; _i++) {
				var _comp = __items__[_i];
				if (!is_struct(_comp)) continue;
				if (!_comp.__is_focusable__) continue;
				if (!_comp.__is_enabled__) continue;
				if (!_comp.__is_active__) continue;
				if (variable_struct_exists(_comp, "visible") && !_comp.visible) continue;
				array_push(_scope, _comp);
			}
			return _scope;
		}
		static __keyboard_scope_index_of__ = function(_scope, _comp_id) {
			var _count = array_length(_scope);
			for (var _i=0; _i<_count; _i++) {
				if (_scope[_i].__comp_id__ == _comp_id) return _i;
			}
			return -1;
		}
		static __keyboard_nav_override_from__ = function(_from, _direction) {
			if (!is_open) return undefined;
			
			var _scope = __keyboard_get_nav_scope__();
			var _count = array_length(_scope);
			if (_count <= 0) return _from;
			
			var _idx = __keyboard_scope_index_of__(_scope, _from.__comp_id__);
			
			var _step = 0;
			switch (_direction) {
				case "next":
				case "down":
				case "right": _step = 1; break;
				case "prev":
				case "up":
				case "left": _step = -1; break;
				default: return (_idx < 0) ? _scope[0] : _scope[_idx];
			}
			
			if (_idx < 0) {
				if (_step >= 0) return _scope[0];
				return _scope[_count - 1];
			}
			
			var _next = _idx + _step;
			if (_next < 0) _next = _count - 1;
			if (_next >= _count) _next = 0;
			return _scope[_next];
		}
		static __keyboard_get_current_nav_target__ = function() {
			var _root = __root_canvas__;
			if (!is_struct(_root)) _root = self;
			var _registry = _root.__focus_registry_get_entries__();
			var _entries = _registry.entries;
			var _count = array_length(_entries);
			if (_count <= 0) return noone;
			var _idx = _root.__focus_registry_find_current_index__(_entries, _count);
			if (_idx < 0) return noone;
			return _entries[_idx];
		}
		static __keyboard_select_current_nav_item__ = function() {
			var _target = __keyboard_get_current_nav_target__();
			if (!is_struct(_target)) return false;
			if (!variable_struct_exists(_target, "__dropdown_owner__")) return false;
			var _owner = _target.__dropdown_owner__;
			if (!is_struct(_owner)) return false;
			if (_owner.__comp_id__ != __comp_id__) return false;
			if (!variable_struct_exists(_target, "__dropdown_item_index__")) return false;
			var _idx = _target.__dropdown_item_index__;
			if ((_idx < 0) || (_idx >= __items_count__)) return false;
			set_value(_idx);
			__keyboard_focus_header__();
			return true;
		}
		static __keyboard_open_and_focus_first_item__ = function(_input) {
			if (!is_open) {
				set_open(true);
			}
			var _first_item = __keyboard_find_first_navigable_item__();
			if (!is_struct(_first_item)) {
				return __keyboard_focus_header__();
			}
			var _root = __root_canvas__;
			if (!is_struct(_root)) _root = self;
			var _assigned = _root.__focus_registry_set_target__(_first_item, false);
			if (!is_struct(_assigned)) {
				return __keyboard_focus_header__();
			}
			return true;
		}
		static __keyboard_close_and_focus_header__ = function(_input) {
			if (!is_open) return false;
			set_open(false);
			__keyboard_focus_header__();
			return true;
		}
		
		static __header_set_text__ = function(_text) {
			if (!is_struct(__header_component__)) return;
			if (variable_struct_exists(__header_component__, "set_text")) {
				var _set_text = variable_struct_get(__header_component__, "set_text");
				if (!is_callable(_set_text)) {
					// continue to fallback
				}
				else {
					__header_component__.set_text(_text);
					return;
				}
			}
			if (variable_struct_exists(__header_component__, "set_value")) {
				var _set_value = variable_struct_get(__header_component__, "set_value");
				if (is_callable(_set_value)) {
					__header_component__.set_value(_text);
				}
			}
		}
		
		static __header_get_text__ = function() {
			if (!is_struct(__header_component__)) return __default_text__;
			if (variable_struct_exists(__header_component__, "get_text")) {
				var _get_text = variable_struct_get(__header_component__, "get_text");
				if (is_callable(_get_text)) {
					return __header_component__.get_text();
				}
			}
			if (variable_struct_exists(__header_component__, "get_value")) {
				var _get_value = variable_struct_get(__header_component__, "get_value");
				if (is_callable(_get_value)) {
					return __header_component__.get_value();
				}
			}
			return __default_text__;
		}
		
		static __event_payload__ = function() {
			__event_data__.index = current_index;
			__event_data__.text = (current_index == -1) ? __default_text__ : __item_label_at__(current_index);
			__event_data__.component = (current_index == -1) ? noone : __items__[current_index];
			return __event_data__;
		}
		
		static __item_label_at__ = function(_index) {
			if ((_index < 0) || (_index >= __items_count__)) return __default_text__;
			var _comp = __items__[_index];
			if (!is_struct(_comp)) return __default_text__;
			if (variable_struct_exists(_comp, "__dropdown_label__") && is_string(_comp.__dropdown_label__)) {
				return _comp.__dropdown_label__;
			}
			if (variable_struct_exists(_comp, "get_text")) {
				var _get_text = variable_struct_get(_comp, "get_text");
				if (is_callable(_get_text)) return _comp.get_text();
			}
			if (variable_struct_exists(_comp, "get_value")) {
				var _get_value = variable_struct_get(_comp, "get_value");
				if (is_callable(_get_value)) return string(_comp.get_value());
			}
			return $"Item {_index}";
		}
		
		static __refresh_dropdown_layout__ = function() {
			if (!is_struct(__header_component__)) return;
			
			if (variable_struct_exists(__header_component__, "set_size")) {
				var _set_size = variable_struct_get(__header_component__, "set_size");
				if (is_callable(_set_size)) {
					__header_component__.set_size(width, height);
				}
			}
			__header_component__.set_offset(0, 0);
			
			var _menu_w = width;
			var _menu_y = __dropdown_yoff_auto__ ? height : __dropdown_yoff__;
			__menu_overlay__.set_offset(__dropdown_xoff__, _menu_y);
			
			var _yy = 0;
			for (var _i=0; _i<__items_count__; _i++) {
				var _comp = __items__[_i];
				if (variable_struct_exists(_comp, "__dropdown_label__") && is_string(_comp.__dropdown_label__)) {
					_comp.set_size(_menu_w, __row_height__);
				}
				_comp.set_offset(0, _yy);
				_comp.update_component_positions();
				_comp.__update_group_region__();
				_yy += _comp.get_group_height();
			}
			
			__menu_overlay__.set_size(_menu_w, max(1, _yy));
			__menu_overlay__.update_component_positions();
		}
		
		static __make_default_item__ = function(_item) {
			if (is_instanceof(_item, WWCore)) return _item;
			if (!is_string(_item)) return noone;
			
			var _btn = new WWButtonText()
				.set_text(_item)
				.set_size(width, __row_height__);
			
			_btn.__dropdown_label__ = _item;
			_btn.__dropdown_owner__ = self;
			_btn.set_callback(method(_btn, function(_input) {
				if (!variable_struct_exists(self, "__dropdown_owner__")) { exit; }
				if (!variable_struct_exists(self, "__dropdown_item_index__")) { exit; }
				
				var _owner = self.__dropdown_owner__;
				if (!is_struct(_owner)) { exit; }
				if (!variable_struct_exists(_owner, "set_value")) { exit; }
				if (!is_callable(_owner.set_value)) { exit; }
				
				var _idx = self.__dropdown_item_index__;
				if (_idx >= 0) {
					_owner.set_value(_idx);
				}
			}));
			
			return _btn;
		}
		#endregion
	#endregion
	
	set_size(140, 24);
	set_text("Select...");
	set_open(false);
	
	static __base_add__ = WWCore.add;
	__base_add__([__header_component__, __menu_overlay__]);
	__bind_header_events__();
}

