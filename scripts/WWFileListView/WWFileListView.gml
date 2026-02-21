#region jsDoc
/// @func    WWFileListView()
/// @desc    Scrollable file-entry list with selection and activation events.
/// @returns {Struct.WWFileListView}
#endregion
function WWFileListView() : WWViewScrollRegion() constructor {
	debug_name = "WWFileListView";

	#region Public
		#region Events
		events.entry_activated = variable_get_hash("entry_activated");
		events.selection_changed = variable_get_hash("selection_changed");
		events.parent_requested = variable_get_hash("parent_requested");
		#endregion

		#region Variables
		entries = [];
		selected_paths = [];
		allow_multi_select = false;
		folder_select_enabled = false;
		row_height = 22;
		__entry_buttons__ = [];
		__fa_icons_ready__ = false;
		#endregion

		#region Builder Functions
		static set_entries = function(_entries=[]) {
			entries = is_array(_entries) ? _entries : [];
			rebuild();
			return self;
		};

		static set_allow_multi_select = function(_allow=false) {
			allow_multi_select = _allow;
			if (!allow_multi_select && array_length(selected_paths) > 1) {
				selected_paths = [selected_paths[0]];
			}
			rebuild();
			return self;
		};

		static set_folder_select_enabled = function(_enabled=false) {
			folder_select_enabled = _enabled;
			return self;
		};

		static set_row_height = function(_h=22) {
			row_height = max(1, _h);
			rebuild();
			return self;
		};

		static set_selected_paths = function(_paths=[]) {
			selected_paths = is_array(_paths) ? variable_clone(_paths) : [];
			rebuild();
			trigger_event(events.selection_changed, __selection_payload__());
			return self;
		};

		static clear_selection = function() {
			selected_paths = [];
			rebuild();
			trigger_event(events.selection_changed, __selection_payload__());
			return self;
		};
		#endregion

		#region Functions
		static get_entries = function() { return entries; };
		static get_selected_paths = function() { return selected_paths; };
		static get_selected_path = function() { return (array_length(selected_paths) > 0) ? selected_paths[0] : ""; };
		static on_entry_activated = function(_func) { add_event_listener(events.entry_activated, _func); return self; };
		static on_selection_changed = function(_func) { add_event_listener(events.selection_changed, _func); return self; };
		static on_parent_requested = function(_func) { add_event_listener(events.parent_requested, _func); return self; };
		static rebuild = function() {
			clear_children();
			__entry_buttons__ = [];
			var _click = method(self, __entry_click__);

			var _row_w = max(40, width - 6);
			var _y = 0;
			var _i = 0; repeat(array_length(entries)) {
				var _e = entries[_i];
				var _prefix = (_e.path == "__PARENT__") ? "[D] " : (_e.is_dir ? "[D] " : "[F] ");
				if (__fa_icons_ready__) {
					_prefix = (_e.is_dir || _e.path == "__PARENT__") ? "[fa,folder,solid] " : "[fa,file,regular] ";
				}

				var _btn = new WWButtonText()
					.set_size(_row_w, row_height)
					.set_offset(0, _y)
					.set_callback(method({fn:_click, index:_i}, function(_input) {
						fn(index, _input);
					}));
				if (__fa_icons_ready__) _btn.set_text_processor("bbcode");

				var _label = _prefix + _e.name;
				if (__is_selected__(_e.path)) {
					_label = "> " + _label;
				}
				_btn.set_text(_label);

				add(_btn);
				array_push(__entry_buttons__, _btn);
				_y += row_height;
				_i += 1;
			}

			set_canvas_size_from_children();
			return self;
		};
		#endregion
	#endregion

	#region Private
		#region Variables
		__entry_data__ = { source:self, entry:noone, index:-1 };
		__selection_data__ = { source:self, paths:[], path:"" };
		#endregion

		#region Functions
		static __compute_fa_ready__ = function() {
			if (!WW_FONT_AWESOME_ENABLED) return false;
			var _has_proc = asset_get_index("WWTextProcessorBBCode") != -1;
			var _has_fa_icon_get = asset_get_index("fa_icon_get") != -1;
			var _has_fa_get_font = asset_get_index("fa_get_font") != -1;
			var _has_fa_get_ord = asset_get_index("fa_get_ord") != -1;
			var _fa_font_asset = asset_get_index("fnt_fa_solid");
			var _has_fa_font = (_fa_font_asset != -1) && font_exists(_fa_font_asset);
			return _has_proc && _has_fa_icon_get && _has_fa_get_font && _has_fa_get_ord && _has_fa_font;
		};

		static __entry_payload__ = function(_entry, _index) {
			__entry_data__.source = self;
			__entry_data__.entry = _entry;
			__entry_data__.index = _index;
			return __entry_data__;
		};

		static __selection_payload__ = function() {
			__selection_data__.source = self;
			__selection_data__.paths = selected_paths;
			__selection_data__.path = (array_length(selected_paths) > 0) ? selected_paths[0] : "";
			return __selection_data__;
		};

		static __is_selected__ = function(_path) {
			return array_contains(selected_paths, _path);
		};

		static __toggle_selected__ = function(_path) {
			var _idx = array_get_index(selected_paths, _path);
			if (_idx >= 0) array_delete(selected_paths, _idx, 1);
			else array_push(selected_paths, _path);
		};

		static __entry_click__ = function(_index, _input) {
			if (_index < 0 || _index >= array_length(entries)) return;
			var _e = entries[_index];
			var _ctrl = !is_undefined(_input) && !is_undefined(_input.keyboard) && is_callable(_input.keyboard.key_down) && _input.keyboard.key_down(vk_control);

			if (_e.path == "__PARENT__") {
				trigger_event(events.parent_requested, __entry_payload__(_e, _index));
				return;
			}

			if (_e.is_dir) {
				if (folder_select_enabled) {
					if (allow_multi_select && _ctrl) __toggle_selected__(_e.path);
					else selected_paths = [_e.path];
					rebuild();
					trigger_event(events.selection_changed, __selection_payload__());
				}
				trigger_event(events.entry_activated, __entry_payload__(_e, _index));
				return;
			}

			if (allow_multi_select && _ctrl) __toggle_selected__(_e.path);
			else selected_paths = [_e.path];
			rebuild();
			trigger_event(events.selection_changed, __selection_payload__());
			trigger_event(events.entry_activated, __entry_payload__(_e, _index));
		};
		#endregion
	#endregion

	set_region_mode(true);
	set_scrollbars_enabled(false, true);
	set_scrollbars_auto_hide(true, true);
	set_size(100, 100);
	__fa_icons_ready__ = __compute_fa_ready__();
}

