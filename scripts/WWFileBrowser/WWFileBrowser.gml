enum WWFileBrowserSelectMode {
	FILE_SINGLE,
	FILE_MULTI,
	FOLDER_SINGLE,
	FOLDER_MULTI,
}

enum WWFileBrowserIntent {
	OPEN_FILE,
	SAVE_FILE,
	SELECT_FOLDER,
}

#region jsDoc
/// @func    WWFileBrowser()
/// @desc    Dialog wrapper around WWFileExplorer for open/save/folder workflows.
/// @returns {Struct.WWFileBrowser}
#endregion
function WWFileBrowser() : WWWindow() constructor {
	debug_name = "WWFileBrowser";

	#region Public
		#region Events
		events.selection_changed = variable_get_hash("selection_changed");
		events.path_changed = variable_get_hash("path_changed");
		events.confirmed = variable_get_hash("confirmed");
		events.cancelled = variable_get_hash("cancelled");
		events.refreshed = variable_get_hash("refreshed");
		#endregion

		#region Variables
		select_mode = WWFileBrowserSelectMode.FILE_SINGLE;
		intent = WWFileBrowserIntent.OPEN_FILE;
		allow_multi_select = false;
		append_extension = true;

		extension_filters = ["*.*"];
		extension_filter_index = 0;
		#endregion

		#region Components
		explorer = new WWFileExplorer().set_offset(8, 0);
		filename_input = new WWInputString().set_size(200, 22);
		ext_button = new WWButtonText()
			.set_text("*.*")
			.set_size(110, 22)
			.set_callback(method(self, function() {
				__cycle_extension_filter__();
			}));
		ok_button = new WWButtonText()
			.set_text("OK")
			.set_size(84, 22)
			.set_callback(method(self, function() { confirm(); }));
		cancel_button = new WWButtonText()
			.set_text("Cancel")
			.set_size(84, 22)
			.set_callback(method(self, function() { cancel(); }));

		add([explorer, filename_input, ext_button, ok_button, cancel_button]);
		#endregion

		#region Builder Functions
		static set_size = function(_w, _h) {
			static __base_set_size__ = WWWindow.set_size;
			__base_set_size__(_w, _h);
			__layout__();
			return self;
		};

		static set_select_mode = function(_mode=WWFileBrowserSelectMode.FILE_SINGLE) {
			select_mode = _mode;
			allow_multi_select = (_mode == WWFileBrowserSelectMode.FILE_MULTI || _mode == WWFileBrowserSelectMode.FOLDER_MULTI);
			explorer
				.set_allow_multi_select(allow_multi_select)
				.set_folder_select_enabled(_mode == WWFileBrowserSelectMode.FOLDER_SINGLE || _mode == WWFileBrowserSelectMode.FOLDER_MULTI);
			return self;
		};

		static set_intent = function(_intent=WWFileBrowserIntent.OPEN_FILE) {
			intent = _intent;
			return self;
		};

		static set_path = function(_path) {
			explorer.set_path(_path);
			return self;
		};

		static set_search_query = function(_query="") {
			explorer.set_search_query(_query);
			return self;
		};

		static set_extension_filters = function(_filters=["*.*"]) {
			if (is_undefined(_filters) || array_length(_filters) <= 0) {
				extension_filters = ["*.*"];
			}
			else {
				extension_filters = [];
				var _i = 0; repeat(array_length(_filters)) {
					array_push(extension_filters, string(_filters[_i]));
				_i += 1;}
				if (array_length(extension_filters) <= 0) extension_filters = ["*.*"];
			}
			extension_filter_index = clamp(extension_filter_index, 0, array_length(extension_filters) - 1);
			ext_button.set_text(extension_filters[extension_filter_index]);
			explorer.set_extension_filter(extension_filters[extension_filter_index]);
			return self;
		};

		static set_extension_filter_index = function(_index=0) {
			extension_filter_index = clamp(_index, 0, array_length(extension_filters) - 1);
			ext_button.set_text(extension_filters[extension_filter_index]);
			explorer.set_extension_filter(extension_filters[extension_filter_index]);
			return self;
		};

		static set_drives = function(_drives) {
			explorer.set_drives(_drives);
			return self;
		};

		static set_append_extension = function(_enabled=true) {
			append_extension = _enabled;
			return self;
		};
		#endregion

		#region Functions
		static on_selection_changed = function(_func) { add_event_listener(events.selection_changed, _func); return self; };
		static on_path_changed = function(_func) { add_event_listener(events.path_changed, _func); return self; };
		static on_confirmed = function(_func) { add_event_listener(events.confirmed, _func); return self; };
		static on_cancelled = function(_func) { add_event_listener(events.cancelled, _func); return self; };
		static on_refreshed = function(_func) { add_event_listener(events.refreshed, _func); return self; };

		static refresh = function() {
			explorer.refresh();
			return self;
		};

		static go_to = function(_path) { return set_path(_path); };
		static go_parent = function() { explorer.go_parent(); return self; };

		static confirm = function() {
			__event_data__.source = self;
			__event_data__.is_multi = allow_multi_select;
			__event_data__.intent = intent;

			var _single = "";
			var _paths = [];
			var _selected = explorer.get_selected_paths();
			var _current_path = explorer.get_path();

			switch (intent) {
				case WWFileBrowserIntent.SELECT_FOLDER:
					if (allow_multi_select && array_length(_selected) > 0) {
						_paths = variable_clone(_selected);
						_single = _paths[0];
					}
					else if (array_length(_selected) > 0) {
						_single = _selected[0];
					}
					else {
						_single = _current_path;
					}
					break;

				case WWFileBrowserIntent.SAVE_FILE:
					var _name = string_trim(filename_input.get_value());
					if (_name == "" && array_length(_selected) > 0) {
						_name = filename_name(_selected[0]);
					}
					if (_name == "") return self;

					var _selected_filter = extension_filters[extension_filter_index];
					if (append_extension && (new WWFileSystemQuery()).is_file_extension_filter(_selected_filter)) {
						if (!(new WWFileSystemQuery()).ends_with(string_lower(_name), string_lower(_selected_filter))) {
							_name += _selected_filter;
						}
					}
					_single = (new WWFileSystemQuery()).join_path(_current_path, _name);
					break;

				default:
					if (allow_multi_select && array_length(_selected) > 0) {
						_paths = variable_clone(_selected);
						_single = _paths[0];
					}
					else if (array_length(_selected) > 0) {
						_single = _selected[0];
					}
					else {
						var _typed = string_trim(filename_input.get_value());
						if (_typed != "") {
							_single = (new WWFileSystemQuery()).join_path(_current_path, _typed);
						}
					}
					break;
			}

			if (_single == "" && array_length(_paths) <= 0) return self;
			if (array_length(_paths) <= 0 && _single != "") _paths = [_single];

			__event_data__.path = _single;
			__event_data__.paths = _paths;
			trigger_event(events.confirmed, __event_data__);
			set_open(false);
			return self;
		};

		static cancel = function() {
			trigger_event(events.cancelled, __event_data__);
			set_open(false);
			return self;
		};

		static get_path = function() { return explorer.get_path(); };
		static get_entries = function() { return explorer.get_entries(); };
		static get_selected_paths = function() { return explorer.get_selected_paths(); };
		static get_selected_path = function() { return explorer.get_selected_path(); };
		static get_search_query = function() { return explorer.get_search_query(); };
		static get_select_mode = function() { return select_mode; };
		static get_intent = function() { return intent; };
		static get_extension_filters = function() { return extension_filters; };
		static get_extension_filter_index = function() { return extension_filter_index; };
		static get_drives = function() { return explorer.get_drive_selector().get_drives(); };
		static get_explorer = function() { return explorer; };
		#endregion
	#endregion

	#region Private
		#region Variables
		__event_data__ = {
			source : self,
			path : "",
			paths : [],
			is_multi : false,
			intent : WWFileBrowserIntent.OPEN_FILE,
		};
		#endregion

		#region Functions
		static __layout__ = function() {
			var _pad = 8;
			var _gap = 6;
			var _content_h = max(1, height - header_height);
			var _inner_w = max(60, width - _pad * 2);
			var _footer_h = 22;
			var _explorer_top = 0;

			var _footer_y = max(0, _content_h - _pad - _footer_h);
			var _ok_x = _pad + _inner_w - (ok_button.width + cancel_button.width + _gap);
			ok_button.set_offset(_ok_x, _footer_y);
			cancel_button.set_offset(_ok_x + ok_button.width + _gap, _footer_y);

			var _ext_x = _ok_x - _gap - ext_button.width;
			ext_button.set_offset(_ext_x, _footer_y);
			filename_input.set_offset(_pad, _footer_y);
			filename_input.set_size(max(80, _ext_x - _gap - _pad), 22);

			var _explorer_h = max(40, (_footer_y - _gap) - _explorer_top);
			explorer.set_offset(_pad, _explorer_top);
			explorer.set_size(_inner_w, _explorer_h);
		};

		static __cycle_extension_filter__ = function() {
			extension_filter_index += 1;
			if (extension_filter_index >= array_length(extension_filters)) extension_filter_index = 0;
			ext_button.set_text(extension_filters[extension_filter_index]);
			explorer.set_extension_filter(extension_filters[extension_filter_index]);
			explorer.refresh();
		};

		static __sync_filename_from_selection__ = function() {
			if (intent == WWFileBrowserIntent.SELECT_FOLDER) return;
			var _p = explorer.get_selected_path();
			if (_p != "" && _p != "__PARENT__" && !directory_exists(_p)) {
				filename_input.set_value(filename_name(_p));
			}
		};
		#endregion
	#endregion

	explorer.on_path_changed(method(self, function(_d) {
		__event_data__.path = explorer.get_path();
		trigger_event(events.path_changed, __event_data__);
	}));

	explorer.on_selection_changed(method(self, function(_d) {
		__sync_filename_from_selection__();
		__event_data__.path = explorer.get_selected_path();
		__event_data__.paths = explorer.get_selected_paths();
		__event_data__.is_multi = allow_multi_select;
		__event_data__.intent = intent;
		trigger_event(events.selection_changed, __event_data__);
	}));

	explorer.on_refreshed(method(self, function(_d) {
		trigger_event(events.refreshed, __event_data__);
	}));

	filename_input.on_submit(method(self, function(_d) {
		confirm();
	}));

	set_title("File Browser");
	set_size(760, 520);
	set_scrollbars_enabled(false, false);
	set_smooth_scrolling(false);
	set_extension_filters(["*.*"]);
	set_select_mode(WWFileBrowserSelectMode.FILE_SINGLE);

	var _drives = get_drives();
	if (array_length(_drives) > 0) {
		set_path(_drives[0]);
	}
}
