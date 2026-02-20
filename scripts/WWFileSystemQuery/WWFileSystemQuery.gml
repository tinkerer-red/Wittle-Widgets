#region jsDoc
/// @func    WWFileSystemQuery()
/// @desc    Stateless helper for path/drive discovery and directory scanning.
/// @returns {Struct.WWFileSystemQuery}
#endregion
function WWFileSystemQuery() constructor {
	debug_name = "WWFileSystemQuery";

	#region Public
		#region Functions
		static normalize_path = function(_path) {
			if (!is_string(_path)) return "";
			var _p = string_trim(_path);
			_p = string_replace_all(_p, "/", "\\");
			while (string_pos("\\\\", _p) != 0) {
				_p = string_replace_all(_p, "\\\\", "\\");
			}
			return _p;
		};

		static ensure_trailing_sep = function(_path) {
			if (!is_string(_path) || _path == "") return "";
			if (!ends_with(_path, "\\")) return _path + "\\";
			return _path;
		};

		static join_path = function(_a, _b) {
			var _aa = normalize_path(_a);
			var _bb = normalize_path(_b);
			if (_aa == "") return _bb;
			if (_bb == "") return _aa;
			if (ends_with(_aa, "\\")) return _aa + _bb;
			return _aa + "\\" + _bb;
		};

		static split_path = function(_path) {
			var _p = normalize_path(_path);
			if (_p == "") return [];
			if (ends_with(_p, "\\")) {
				_p = string_delete(_p, string_length(_p), 1);
			}
			return string_split(_p, "\\");
		};

		static is_root_path = function(_path) {
			var _p = ensure_trailing_sep(normalize_path(_path));
			return (string_length(_p) <= 3) && (string_char_at(_p, 2) == ":");
		};

		static parent_path = function(_path) {
			var _parts = split_path(_path);
			var _count = array_length(_parts);
			if (_count <= 0) return "";
			if (_count == 1 && string_pos(":", _parts[0]) > 0) return ensure_trailing_sep(_parts[0]);
			array_delete(_parts, _count - 1, 1);

			var _new_path = "";
			var _i = 0; repeat(array_length(_parts)) {
				if (_i == 0 && string_pos(":", _parts[_i]) > 0) {
					_new_path = ensure_trailing_sep(_parts[_i]);
				}
				else {
					_new_path = join_path(_new_path, _parts[_i]);
					_new_path = ensure_trailing_sep(_new_path);
				}
			_i += 1;}
			return _new_path;
		};

		static discover_drives = function() {
			var _drives = [];
			if (os_type == os_windows) {
				var _ord = ord("A");
				repeat(26) {
					var _letter = chr(_ord);
					var _path = _letter + ":\\";
					if (directory_exists(_path)) {
						array_push(_drives, _path);
					}
					_ord += 1;
				}
			}

			if (array_length(_drives) <= 0) {
				var _wd = ensure_trailing_sep(normalize_path(working_directory));
				if (_wd != "" && directory_exists(_wd)) {
					array_push(_drives, _wd);
				}
			}
			return _drives;
		};

		static drive_index_for_path = function(_path, _drives) {
			var _idx = 0;
			var _needle = string_lower(ensure_trailing_sep(normalize_path(_path)));
			var _i = 0; repeat(array_length(_drives)) {
				var _d = string_lower(ensure_trailing_sep(normalize_path(_drives[_i])));
				if (string_pos(_d, _needle) == 1) {
					_idx = _i;
					break;
				}
			_i += 1;}
			return _idx;
		};

		static ends_with = function(_text, _suffix) {
			if (!is_string(_text) || !is_string(_suffix)) return false;
			var _lt = string_length(_text);
			var _ls = string_length(_suffix);
			if (_ls > _lt) return false;
			return string_copy(_text, _lt - _ls + 1, _ls) == _suffix;
		};

		static is_file_extension_filter = function(_filter) {
			if (!is_string(_filter)) return false;
			if (_filter == "*" || _filter == "*.*") return false;
			return string_pos(".", _filter) > 0;
		};

		static search_match = function(_name, _query) {
			var _q = string_lower(string_trim(string(_query)));
			if (_q == "" || _q == "*") return true;

			var _n = string_lower(string(_name));
			if (string_pos("*", _q) == 0) {
				return string_pos(_q, _n) > 0;
			}

			while (string_pos("**", _q) > 0) {
				_q = string_replace_all(_q, "**", "*");
			}
			if (string_char_at(_q, 1) != "*") _q = "*" + _q;
			if (string_char_at(_q, string_length(_q)) != "*") _q += "*";

			var _parts = string_split(_q, "*");
			var _cursor = 1;
			var _i = 0; repeat(array_length(_parts)) {
				var _token = _parts[_i];
				if (_token == "") { _i += 1; continue; }
				var _rest = string_copy(_n, _cursor, string_length(_n) - _cursor + 1);
				var _at = string_pos(_token, _rest);
				if (_at <= 0) return false;
				_cursor = _cursor + _at - 1 + string_length(_token);
				_i += 1;
			}
			return true;
		};

		static extension_match = function(_filename, _filter) {
			if (!is_file_extension_filter(_filter)) return true;
			return ends_with(string_lower(_filename), string_lower(_filter));
		};

		static scan_entries = function(_path, _search_query="", _extension_filter="*.*", _include_parent=true, _include_dirs=true, _include_files=true) {
			var _entries = [];
			var _dir = ensure_trailing_sep(normalize_path(_path));
			if (_dir == "" || !directory_exists(_dir)) return _entries;

			if (_include_parent && !is_root_path(_dir)) {
				array_push(_entries, { name:"..", path:"__PARENT__", is_dir:true });
			}

			if (_include_dirs) {
				var _f = file_find_first(_dir + "*", fa_directory);
				while (_f != "") {
					if (_f != "." && _f != "..") {
						var _full = join_path(_dir, _f);
						if (directory_exists(_full) && search_match(_f, _search_query)) {
							array_push(_entries, {
								name : _f,
								path : ensure_trailing_sep(_full),
								is_dir : true,
							});
						}
					}
					_f = file_find_next();
				}
				file_find_close();
			}

			if (_include_files) {
				var _ff = file_find_first(_dir + "*", 0);
				while (_ff != "") {
					var _fullf = join_path(_dir, _ff);
					if (!directory_exists(_fullf)) {
						if (search_match(_ff, _search_query) && extension_match(_ff, _extension_filter)) {
							array_push(_entries, {
								name : _ff,
								path : _fullf,
								is_dir : false,
							});
						}
					}
					_ff = file_find_next();
				}
				file_find_close();
			}

			array_sort(_entries, function(_a, _b) {
				if (_a.path == "__PARENT__") return -1;
				if (_b.path == "__PARENT__") return 1;
				if (_a.is_dir != _b.is_dir) return (_a.is_dir) ? -1 : 1;
				var _an = string_lower(_a.name);
				var _bn = string_lower(_b.name);
				if (_an == _bn) return 0;
				return (_an < _bn) ? -1 : 1;
			});

			return _entries;
		};
		#endregion
	#endregion
}
