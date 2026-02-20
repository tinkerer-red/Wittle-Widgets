#region jsDoc
/// @func    WWDriveSelector()
/// @desc    Drive selection dropdown specialized for file-system roots.
/// @returns {Struct.WWDriveSelector}
#endregion
function WWDriveSelector() : WWDropdownBasic() constructor {
	debug_name = "WWDriveSelector";

	#region Public
		#region Events
		events.drive_changed = variable_get_hash("drive_changed");
		#endregion

		#region Variables
		drives = [];
		drive_index = 0;
		#endregion

		#region Builder Functions
		static set_drives = function(_drives=[]) {
			drives = [];
			if (is_array(_drives)) {
				var _q = new WWFileSystemQuery();
				var _i = 0; repeat(array_length(_drives)) {
					var _d = _q.ensure_trailing_sep(_q.normalize_path(string(_drives[_i])));
					if (_d != "" && directory_exists(_d) && !array_contains(drives, _d)) {
						array_push(drives, _d);
					}
				_i += 1;}
			}
			if (array_length(drives) <= 0) {
				drives = (new WWFileSystemQuery()).discover_drives();
			}
			set_options(drives);
			drive_index = clamp(drive_index, 0, max(0, array_length(drives) - 1));
			set_value(drive_index);
			return self;
		};

		static set_drive_index = function(_index=0) {
			drive_index = clamp(_index, 0, max(0, array_length(drives) - 1));
			set_value(drive_index);
			return self;
		};
		#endregion

		#region Functions
		static get_drives = function() { return drives; };
		static get_drive_index = function() { return drive_index; };
		static get_drive = function() { return (array_length(drives) > 0) ? drives[drive_index] : ""; };
		static on_drive_changed = function(_func) { add_event_listener(events.drive_changed, _func); return self; };
		#endregion
	#endregion

	#region Private
		#region Variables
		__event_data__ = { source:self, index:0, drive:"" };
		#endregion

		#region Functions
		static __emit_drive_changed__ = function() {
			__event_data__.source = self;
			__event_data__.index = drive_index;
			__event_data__.drive = get_drive();
			trigger_event(events.drive_changed, __event_data__);
		};
		#endregion
	#endregion

	on_event(events.changed, method(self, function(_data) {
		drive_index = clamp(_data.index, 0, max(0, array_length(drives) - 1));
		__emit_drive_changed__();
	}));

	set_text("Drive");
	set_size(72, 22);
	set_drives([]);
}
