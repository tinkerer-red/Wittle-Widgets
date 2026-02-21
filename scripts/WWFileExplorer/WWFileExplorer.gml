#region jsDoc
/// @func    WWFileExplorer()
/// @desc    General purpose file explorer surface (path/search/drive/list management).
/// @returns {Struct.WWFileExplorer}
#endregion
function WWFileExplorer() : WWCore() constructor {
	debug_name = "WWFileExplorer";

	#region Public
		#region Events
		events.selection_changed = variable_get_hash("selection_changed");
		events.path_changed = variable_get_hash("path_changed");
		events.entry_activated = variable_get_hash("entry_activated");
		events.refreshed = variable_get_hash("refreshed");
		#endregion

		#region Variables
		current_path = "";
		search_query = "";
		extension_filter = "*.*";
		allow_multi_select = false;
		folder_select_enabled = false;
		#endregion

		#region Components
		query = new WWFileSystemQuery();
		drive_selector = new WWDriveSelector().set_size(72, 22);
		up_button = new WWButtonIcon().set_square_size(22).set_icon_fa("arrow-up", "solid").set_fallback_text("^").set_callback(method(self, function(){ go_parent(); }));
		refresh_button = new WWButtonIcon().set_square_size(22).set_icon_fa("arrow-rotate-right", "solid").set_fallback_text("R").set_callback(method(self, function(){ refresh(); }));
		search = new WWSearchInput().set_size(220, 22).set_action_mode("clear").set_placeholder("Search...");
		breadcrumb = new WWPathBreadcrumb().set_size(100, 22).set_leading_component(drive_selector).set_show_root_segment(false);
		list_view = new WWFileListView().set_size(100, 100);
		add([up_button, refresh_button, search, breadcrumb, list_view]);
		#endregion

		#region Builder Functions
		static set_size = function(_w, _h) {
			static __base_set_size__ = WWCore.set_size;
			__base_set_size__(_w, _h);
			__layout__();
			return self;
		};

		static set_path = function(_path) {
			var _next = query.ensure_trailing_sep(query.normalize_path(_path));
			if (_next == "" || !directory_exists(_next)) return self;
			if (string_lower(_next) == string_lower(current_path)) return self;
			current_path = _next;
			__sync_drive_selector__();
			breadcrumb.set_path(current_path);
			list_view.set_scroll_offset(0, 0);
			trigger_event(events.path_changed, __path_payload__());
			refresh();
			return self;
		};

		static set_search_query = function(_query="") {
			search_query = string(_query);
			search.set_value(search_query);
			refresh();
			return self;
		};

		static set_extension_filter = function(_filter="*.*") {
			extension_filter = string(_filter);
			refresh();
			return self;
		};

		static set_allow_multi_select = function(_allow=false) {
			allow_multi_select = _allow;
			list_view.set_allow_multi_select(_allow);
			return self;
		};

		static set_folder_select_enabled = function(_enabled=false) {
			folder_select_enabled = _enabled;
			list_view.set_folder_select_enabled(_enabled);
			return self;
		};

		static set_drives = function(_drives=[]) {
			drive_selector.set_drives(_drives);
			__sync_drive_selector__();
			return self;
		};
		#endregion

		#region Functions
		static refresh = function() {
			var _entries = query.scan_entries(current_path, search_query, extension_filter, true, true, true);
			list_view.set_entries(_entries);
			trigger_event(events.refreshed, __path_payload__());
			return self;
		};

		static go_parent = function() {
			var _parent = query.parent_path(current_path);
			if (_parent != "") set_path(_parent);
			return self;
		};

		static get_path = function() { return current_path; };
		static get_entries = function() { return list_view.get_entries(); };
		static get_selected_paths = function() { return list_view.get_selected_paths(); };
		static get_selected_path = function() { return list_view.get_selected_path(); };
		static get_search_query = function() { return search_query; };
		static get_drive_selector = function() { return drive_selector; };
		static get_search_input = function() { return search; };
		static get_breadcrumb = function() { return breadcrumb; };
		static get_list_view = function() { return list_view; };
		static on_selection_changed = function(_func) { add_event_listener(events.selection_changed, _func); return self; };
		static on_path_changed = function(_func) { add_event_listener(events.path_changed, _func); return self; };
		static on_entry_activated = function(_func) { add_event_listener(events.entry_activated, _func); return self; };
		static on_refreshed = function(_func) { add_event_listener(events.refreshed, _func); return self; };
		#endregion
	#endregion

	#region Private
		#region Variables
		__event_data__ = { source:self, path:"", paths:[], entry:noone };
		#endregion

		#region Functions
		static __layout__ = function() {
			var _pad = 8;
			var _gap = 6;
			var _inner_w = max(60, width - _pad * 2);
			var _top_y = 0;

			up_button.set_offset(_pad, _top_y);

			var _search_w = max(120, min(240, floor(_inner_w * 0.28)));
			var _search_x = _pad + _inner_w - _search_w;
			search.set_offset(_search_x, _top_y);
			search.set_size(_search_w, 22);

			var _refresh_x = _search_x - _gap - refresh_button.width;
			refresh_button.set_offset(_refresh_x, _top_y);

			var _crumb_x = _pad + up_button.width + _gap;
			breadcrumb.set_offset(_crumb_x, _top_y);
			breadcrumb.set_size(max(80, _refresh_x - _gap - _crumb_x), 22);

			list_view.set_offset(_pad, _top_y + 24);
			list_view.set_size(_inner_w, max(40, height - (24 + 2)));
		};

		static __path_payload__ = function() {
			__event_data__.source = self;
			__event_data__.path = current_path;
			__event_data__.paths = list_view.get_selected_paths();
			return __event_data__;
		};

		static __entry_payload__ = function(_entry_payload) {
			__event_data__.source = self;
			__event_data__.path = current_path;
			__event_data__.paths = list_view.get_selected_paths();
			__event_data__.entry = _entry_payload.entry;
			return __event_data__;
		};

		static __sync_drive_selector__ = function() {
			var _drives = drive_selector.get_drives();
			if (array_length(_drives) <= 0) return;
			var _idx = query.drive_index_for_path(current_path, _drives);
			if (_idx != drive_selector.get_drive_index()) {
				drive_selector.set_drive_index(_idx);
			}
		};
		#endregion
	#endregion

	drive_selector.on_drive_changed(method(self, function(_data) {
		if (_data.drive != "") set_path(_data.drive);
	}));

	search.on_change(method(self, function(_data) {
		search_query = _data.value;
		refresh();
	}));
	search.on_submit(method(self, function(_data) {
		search_query = _data.value;
		refresh();
	}));

	breadcrumb.on_path_selected(method(self, function(_data) {
		set_path(_data.path);
	}));

	list_view.on_parent_requested(method(self, function(_data) {
		go_parent();
	}));

	list_view.on_entry_activated(method(self, function(_data) {
		trigger_event(events.entry_activated, __entry_payload__(_data));
		if (!is_undefined(_data.entry) && _data.entry != noone && _data.entry.is_dir && !folder_select_enabled) {
			set_path(_data.entry.path);
		}
	}));

	list_view.on_selection_changed(method(self, function(_data) {
		trigger_event(events.selection_changed, __path_payload__());
	}));

	set_size(640, 320);
	set_allow_multi_select(false);
	set_folder_select_enabled(false);
	drive_selector.set_drives([]);
	var _drives = drive_selector.get_drives();
	if (array_length(_drives) > 0) {
		set_path(_drives[0]);
	}
}
