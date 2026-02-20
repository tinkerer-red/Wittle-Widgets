#region jsDoc
/// @func    WWPathBreadcrumb()
/// @desc    Horizontal breadcrumb region with optional leading component and path click events.
/// @returns {Struct.WWPathBreadcrumb}
#endregion
function WWPathBreadcrumb() : WWViewScrollRegion() constructor {
	debug_name = "WWPathBreadcrumb";

	#region Public
		#region Events
		events.path_selected = variable_get_hash("path_selected");
		#endregion

		#region Variables
		current_path = "";
		show_root_segment = false;
		leading_component = noone;
		#endregion

		#region Builder Functions
		static set_size = function(_w, _h) {
			static __base_set_size__ = WWViewScrollRegion.set_size;
			__base_set_size__(_w, _h);
			rebuild();
			return self;
		};

		static set_path = function(_path) {
			current_path = (new WWFileSystemQuery()).ensure_trailing_sep((new WWFileSystemQuery()).normalize_path(_path));
			rebuild();
			return self;
		};

		static set_show_root_segment = function(_show=false) {
			show_root_segment = _show;
			rebuild();
			return self;
		};

		static set_leading_component = function(_comp=noone) {
			leading_component = _comp;
			rebuild();
			return self;
		};
		#endregion

		#region Functions
		static get_path = function() { return current_path; };
		static on_path_selected = function(_func) { add_event_listener(events.path_selected, _func); return self; };
		static rebuild = function() {
			clear_children();

			var _x = 0;
			if (is_struct(leading_component)) {
				leading_component.set_offset(0, 0);
				add(leading_component);
				_x = leading_component.width + 4;
			}

			var _q = new WWFileSystemQuery();
			var _parts = _q.split_path(current_path);
			if (array_length(_parts) > 0) {
				var _acc = "";
				var _start_i = 0;
				if (!show_root_segment) {
					var _root = _parts[0];
					if (string_pos(":", _root) > 0) {
						_acc = _q.ensure_trailing_sep(_root);
						_start_i = 1;
					}
				}

				var _emit = method(self, __emit_path_selected__);
				var _i = 0; repeat(array_length(_parts)) {
					if (_i >= _start_i) {
						var _part = _parts[_i];
						if (_i == 0 && string_pos(":", _part) > 0) {
							_acc = _q.ensure_trailing_sep(_part);
						}
						else {
							_acc = _q.ensure_trailing_sep(_q.join_path(_acc, _part));
						}

						var _btn = new WWButtonText();
						_btn
							.set_text(_part)
							.set_sprite_to_auto_wrap()
							.set_size(max(40, _btn.width), height)
							.set_offset(_x, 0)
							.set_callback(method({fn:_emit, path:_acc}, function() {
								fn(path);
							}));
						add(_btn);
						_x += _btn.width + 4;
					}
					_i += 1;
				}
			}

			set_canvas_size_from_children();
			var _max = get_scroll_max();
			set_scroll_offset(_max.x, 0);
			return self;
		};
		#endregion
	#endregion

	#region Private
		#region Variables
		__event_data__ = { source:self, path:"" };
		#endregion

		#region Functions
		static __emit_path_selected__ = function(_path) {
			__event_data__.source = self;
			__event_data__.path = _path;
			trigger_event(events.path_selected, __event_data__);
		};
		#endregion
	#endregion

	set_region_mode(true);
	set_scrollbars_enabled(false, false);
	set_scrollbars_auto_hide(true, true);
	set_wheel_scroll_enabled(false, false);
	on_mouse_over(method(self, function(_input) {
		if (mouse_wheel_up()) {
			scroll_by(-16, 0);
		}
		else if (mouse_wheel_down()) {
			scroll_by(16, 0);
		}
	}));
	set_size(100, 22);
}
