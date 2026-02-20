#region jsDoc
/// @func    WWDropdownCombo()
/// @desc    Combo dropdown: editable text header + selectable dropdown options.
/// @returns {Struct.WWDropdownCombo}
#endregion
function WWDropdownCombo() : WWDropdownSelect() constructor {
	debug_name = "WWDropdownCombo";
	
	#region Public
		#region Builder Functions
		static set_size = function(_width, _height) {
			static __base_set_size__ = WWDropdown.set_size;
			__base_set_size__(_width, _height);
			__sync_header_chrome__();
			return self;
		}
		
		static set_text_value = function(_text="") {
			__input_header__.set_value(_text);
			return self;
		}
		
		static set_open_on_focus = function(_enabled=true) {
			__open_on_focus__ = _enabled;
			return self;
		}
		
		static set_commit_on_submit = function(_enabled=true) {
			__commit_on_submit__ = _enabled;
			return self;
		}
		#endregion
		
		#region Events
			static on_input_change = function(_func) {
				__input_header__.on_change(_func);
				return self;
			}
		#endregion
		
		#region Variables
			__open_on_focus__ = true;
			__commit_on_submit__ = true;
		#endregion
		
		#region Functions
			static get_text_value = function() {
				return __input_header__.get_value();
			}
		#endregion
	#endregion
	
	#region Private
		#region Variables
			__input_header__ = new WWInputString()
				.set_size(140, 24);
			__header_chevron__ = new WWLabel()
				.set_text("v");
			__header_divider__ = new WWCore()
				.set_size(1, 14);
			__header_chrome_width__ = 20;
			__theme_header_bg__ = undefined;
			__theme_divider_col__ = undefined;
			__theme_input_text__ = undefined;
		#endregion
		
		#region Functions
		static __sync_header_chrome__ = function() {
			var _w = __input_header__.width;
			var _h = __input_header__.height;
			
			__header_divider__.set_offset(max(0, _w - __header_chrome_width__), max(0, floor((_h - __header_divider__.height) * 0.5)));
			__header_chevron__.set_offset(max(0, _w - __header_chrome_width__ + 6), max(0, floor((_h - __header_chevron__.height) * 0.5)));
		}

		static __apply_theme_header_chrome__ = function() {
			var _header_bg = wwThemeGetColor("colors.surface.control.color");
			var _divider_col = wwThemeGetColor("colors.outline.normal.color");
			var _input_text = wwThemeGetColor("colors.text.primary.color");

			if (_header_bg != undefined) __theme_header_bg__ = _header_bg;
			if (_divider_col != undefined) __theme_divider_col__ = _divider_col;
			if (_input_text != undefined) __theme_input_text__ = _input_text;

			// Intentionally avoid force-setting visuals here.
			// Components should render from theme defaults/fallbacks.
		}
		#endregion
	#endregion
	
	set_header_toggle_enabled(false);
	__input_header__.add([__header_divider__, __header_chevron__]);
	set_header(__input_header__);
	set_text("Select...");
	
	// Light visual affordance so combo reads like a dropdown, not a plain text box.
	__apply_theme_header_chrome__();
	__sync_header_chrome__();
	
	on_pre_step(function(_input) {
		__apply_theme_header_chrome__();
		if (!mouse_check_button_pressed(mb_left)) return;
		if (__input_header__.mouse_on_group()) {
			set_open(true);
		}
	});
	
	__input_header__.on_focus_enter(function(_input) {
		if (__open_on_focus__) set_open(true);
	});
	
	__input_header__.on_submit(function(_input) {
		if (!__commit_on_submit__) {
			set_open(false);
			return;
		}
		
		var _needle = string_lower(string(__input_header__.get_value()));
		var _opts = get_options();
		for (var _i=0; _i<array_length(_opts); _i++) {
			if (string_lower(string(_opts[_i])) == _needle) {
				set_value(_i);
				return;
			}
		}
		set_open(false);
	});
	
	on_event(events.changed, function(_data) {
		__input_header__.set_value(_data.text);
	});
}
