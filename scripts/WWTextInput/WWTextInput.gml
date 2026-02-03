#region jsDoc
/// @func    WWTextInput()
/// @desc    Base composite text input: wraps a WWTextField inside a WWViewScrollRegion.
///          Intended to be subclassed by presets (single-line, multi-line, password, numeric, etc).
/// @returns {Struct.WWTextInput}
#endregion
function WWTextInput() : WWCore() constructor {
	debug_name = "WWTextInput";

	#region Public

		#region Components
			region = new WWViewScrollRegion().set_region_mode(true);
			field = new WWTextField();

			// Optional scrollbars (presets can enable/disable)
			__sb_horz__ = new WWScrollbarHorz();
			__sb_vert__ = new WWScrollbarVert();
			region.scrollbar_horz = __sb_horz__;
			region.scrollbar_vert = __sb_vert__;
			region.set_scrollbars_enabled(true, true);

			add([region, __sb_horz__, __sb_vert__]);
			region.add(field);
		#endregion

		#region Variables
			__caret_inset__ = 8;
		#endregion

		#region Events

			#region jsDoc
			/// @func    on_change(func)
			/// @desc    Adds a listener for text changes.
			/// @self    WWTextInput
			/// @param   {Function} func
			/// @returns {Struct.WWTextInput} self
			#endregion
			static on_change = function(_func) {
				field.on_change(_func);
				return self;
			};

			#region jsDoc
			/// @func    on_submit(func)
			/// @desc    Adds a listener for submit.
			/// @self    WWTextInput
			/// @param   {Function} func
			/// @returns {Struct.WWTextInput} self
			#endregion
			static on_submit = function(_func) {
				field.on_submit(_func);
				return self;
			};

			#region jsDoc
			/// @func    on_cursor_move(func)
			/// @desc    Adds a listener for cursor movement.
			/// @self    WWTextInput
			/// @param   {Function} func
			/// @returns {Struct.WWTextInput} self
			#endregion
			static on_cursor_move = function(_func) {
				field.on_cursor_move(_func);
				return self;
			};

		#endregion

		#region Builder Functions

			#region jsDoc
			/// @func    set_size(width, height)
			/// @desc    Sets input size and resizes internal region/field.
			/// @self    WWTextInput
			/// @param   {Real} width
			/// @param   {Real} height
			/// @returns {Struct.WWTextInput} self
			#endregion
			static set_size = function(_width, _height) {
				// WWCore.set_size equivalent (avoids WWCore.* dot-access issues)
				__size_set__ = true;
				__set_size__(_width, _height);
				region.set_size(_width, _height);
				field.set_offset(0, 0);
				field.set_size(_width, _height);
				region.set_canvas_size_from_children();

				return self;
			};

			#region jsDoc
			/// @func    set_value(text)
			/// @desc    Sets the text content.
			/// @self    WWTextInput
			/// @param   {String} text
			/// @returns {Struct.WWTextInput} self
			#endregion
			static set_value = function(_text) {
				field.set_text(_text);
				return self;
			};

			#region jsDoc
			/// @func    set_read_only(read_only)
			/// @desc    Sets read-only state (select/copy still allowed).
			/// @self    WWTextInput
			/// @param   {Bool} read_only
			/// @returns {Struct.WWTextInput} self
			#endregion
			static set_read_only = function(_read_only) {
				field.set_read_only(_read_only);
				return self;
			};

			#region jsDoc
			/// @func    set_scrollbars_enabled(horz_enabled, vert_enabled)
			/// @desc    Forwards to the internal WWViewScrollRegion.
			/// @self    WWTextInput
			/// @param   {Bool} horz_enabled
			/// @param   {Bool} vert_enabled
			/// @returns {Struct.WWTextInput} self
			#endregion
			static set_scrollbars_enabled = function(_horz_enabled=true, _vert_enabled=true) {
				region.set_scrollbars_enabled(_horz_enabled, _vert_enabled);
				return self;
			};

			#region jsDoc
			/// @func    set_scrollbars_auto_hide(horz_auto, vert_auto)
			/// @desc    Forwards to the internal WWViewScrollRegion.
			/// @self    WWTextInput
			/// @param   {Bool} horz_auto
			/// @param   {Bool} vert_auto
			/// @returns {Struct.WWTextInput} self
			#endregion
			static set_scrollbars_auto_hide = function(_horz_auto=true, _vert_auto=true) {
				region.set_scrollbars_auto_hide(_horz_auto, _vert_auto);
				return self;
			};

			#region jsDoc
			/// @func    set_scrollbar_thickness(thickness)
			/// @desc    Forwards to the internal WWViewScrollRegion.
			/// @self    WWTextInput
			/// @param   {Real} thickness
			/// @returns {Struct.WWTextInput} self
			#endregion
			static set_scrollbar_thickness = function(_thickness) {
				region.set_scrollbar_thickness(_thickness);
				return self;
			};

			#region jsDoc
			/// @func    set_wheel_step(pixels_per_wheel)
			/// @desc    Forwards to the internal WWViewScrollRegion.
			/// @self    WWTextInput
			/// @param   {Real} pixels_per_wheel
			/// @returns {Struct.WWTextInput} self
			#endregion
			static set_wheel_step = function(_pixels_per_wheel) {
				region.set_wheel_step(_pixels_per_wheel);
				return self;
			};

			#region jsDoc
			/// @func    set_smooth_scrolling(smooth)
			/// @desc    Forwards to the internal WWViewScrollRegion.
			/// @self    WWTextInput
			/// @param   {Bool} smooth
			/// @returns {Struct.WWTextInput} self
			#endregion
			static set_smooth_scrolling = function(_smooth=false) {
				region.set_smooth_scrolling(_smooth);
				return self;
			};

			#region jsDoc
			/// @func    set_wheel_scroll_enabled(horz_enabled, vert_enabled)
			/// @desc    Forwards to the internal WWViewScrollRegion.
			/// @self    WWTextInput
			/// @param   {Bool} horz_enabled
			/// @param   {Bool} vert_enabled
			/// @returns {Struct.WWTextInput} self
			#endregion
			static set_wheel_scroll_enabled = function(_horz_enabled=true, _vert_enabled=true) {
				region.set_wheel_scroll_enabled(_horz_enabled, _vert_enabled);
				return self;
			};

			#region jsDoc
			/// @func    set_scrollbar_thumb_sprite(sprite, apply_horz, apply_vert)
			/// @desc    Convenience forwarder for reskinning thumb sprite(s).
			/// @self    WWTextInput
			/// @param   {Asset.GMSprite} sprite
			/// @param   {Bool} apply_horz
			/// @param   {Bool} apply_vert
			/// @returns {Struct.WWTextInput} self
			#endregion
			static set_scrollbar_thumb_sprite = function(_sprite, _apply_horz=true, _apply_vert=true) {
				if (_apply_horz) {
					var _t = get_scrollbar_thumb_horz();
					if (_t != undefined) { _t.set_sprite(_sprite); }
				}
				if (_apply_vert) {
					var _t = get_scrollbar_thumb_vert();
					if (_t != undefined) { _t.set_sprite(_sprite); }
				}
				return self;
			};

			#region jsDoc
			/// @func    set_scrollbar_thumb_color(color, apply_horz, apply_vert)
			/// @desc    Convenience forwarder for reskinning thumb color(s).
			/// @self    WWTextInput
			/// @param   {Int} color
			/// @param   {Bool} apply_horz
			/// @param   {Bool} apply_vert
			/// @returns {Struct.WWTextInput} self
			#endregion
			static set_scrollbar_thumb_color = function(_color, _apply_horz=true, _apply_vert=true) {
				if (_apply_horz) {
					var _t = get_scrollbar_thumb_horz();
					if (_t != undefined) { _t.set_sprite_color(_color); }
				}
				if (_apply_vert) {
					var _t = get_scrollbar_thumb_vert();
					if (_t != undefined) { _t.set_sprite_color(_color); }
				}
				return self;
			};

		#endregion

		#region Functions
			#region Getters
				#region jsDoc
				/// @func    get_value()
				/// @desc    Gets the current text content.
				/// @self    WWTextInput
				/// @returns {String}
				#endregion
				static get_value = function() {
					return field.get_text();
				};

				#region jsDoc
				/// @func    get_field()
				/// @desc    Returns the internal WWTextField (advanced usage/customization).
				/// @self    WWTextInput
				/// @returns {Struct.WWTextField}
				#endregion
				static get_field = function() {
					return field;
				};

				#region jsDoc
				/// @func    get_region()
				/// @desc    Returns the internal WWViewScrollRegion (advanced usage/customization).
				/// @self    WWTextInput
				/// @returns {Struct.WWViewScrollRegion}
				#endregion
				static get_region = function() {
					return region;
				};

				#region jsDoc
				/// @func    get_scrollbar_horz()
				/// @desc    Returns the internal horizontal scrollbar instance.
				/// @self    WWTextInput
				/// @returns {Struct.WWScrollbarHorz}
				#endregion
				static get_scrollbar_horz = function() {
					return __sb_horz__;
				};

				#region jsDoc
				/// @func    get_scrollbar_vert()
				/// @desc    Returns the internal vertical scrollbar instance.
				/// @self    WWTextInput
				/// @returns {Struct.WWScrollbarVert}
				#endregion
				static get_scrollbar_vert = function() {
					return __sb_vert__;
				};

				#region jsDoc
				/// @func    get_scrollbar_thumb_horz()
				/// @desc    Returns the horizontal scrollbar's thumb (for reskinning).
				/// @self    WWTextInput
				/// @returns {Struct.WWSliderThumb}
				#endregion
				static get_scrollbar_thumb_horz = function() {
					return (__sb_horz__ != undefined) ? __sb_horz__.get_thumb() : undefined;
				};

				#region jsDoc
				/// @func    get_scrollbar_thumb_vert()
				/// @desc    Returns the vertical scrollbar's thumb (for reskinning).
				/// @self    WWTextInput
				/// @returns {Struct.WWSliderThumb}
				#endregion
				static get_scrollbar_thumb_vert = function() {
					return (__sb_vert__ != undefined) ? __sb_vert__.get_thumb() : undefined;
				};
			#endregion
		#endregion

	#endregion

	#region Private

		#region Functions
			// (intentionally no cached WWCore.* calls here; some analyzers reject type dot-access)

			#region jsDoc
			/// @func    __ensure_caret_visible_horz__()
			/// @ignore
			/// @desc    Scrolls horizontally only if caret is outside viewport.
			/// @self    WWTextInput
			/// @returns {Undefined}
			#endregion
			static __ensure_caret_visible_horz__ = function() {
				var _vw = region.viewport_width;
				if (_vw <= 0) { _vw = width; }

				var _inset = __caret_inset__;
				var _caret_x = field.get_cursor_x();

				var _cur = region.scroll_x;
				var _new = _cur;

				if (_caret_x < _cur + _inset) {
					_new = _caret_x - _inset;
				}
				else if (_caret_x > _cur + _vw - _inset) {
					_new = _caret_x - (_vw - _inset);
				}

				if (_new != _cur) {
					var _max = region.get_scroll_max();
					_new = clamp(_new, 0, variable_struct_get(_max, "x"));
					region.set_scroll_offset(_new, region.scroll_y);
				}
			};

			#region jsDoc
			/// @func    __ensure_caret_visible_vert__()
			/// @ignore
			/// @desc    Scrolls vertically only if caret is outside viewport.
			/// @self    WWTextInput
			/// @returns {Undefined}
			#endregion
			static __ensure_caret_visible_vert__ = function() {
				var _vh = region.viewport_height;
				if (_vh <= 0) { _vh = height; }

				var _inset = __caret_inset__;
				var _caret_y = field.get_cursor_y();

				var _cur = region.scroll_y;
				var _new = _cur;

				if (_caret_y < _cur + _inset) {
					_new = _caret_y - _inset;
				}
				else if (_caret_y > _cur + _vh - _inset) {
					_new = _caret_y - (_vh - _inset);
				}

				if (_new != _cur) {
					var _max = region.get_scroll_max();
					_new = clamp(_new, 0, variable_struct_get(_max, "y"));
					region.set_scroll_offset(region.scroll_x, _new);
				}
			};

		#endregion

	#endregion
}
