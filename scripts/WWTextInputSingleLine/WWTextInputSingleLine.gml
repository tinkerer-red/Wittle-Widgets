#region jsDoc
/// @func    WWTextInputSingleLine()
/// @desc    Single-line text input preset built on WWTextInput.
///          Defaults:
///          - No word wrap
///          - Enter submits (no newline insertion)
///          - No mouse wheel scrolling unless Shift+wheel (horizontal)
///          - Caret-follow scroll only when caret leaves view
/// @returns {Struct.WWTextInputSingleLine}
#endregion
function WWTextInputSingleLine() : WWTextInput() constructor {
	debug_name = "WWTextInputSingleLine";
	
	#region Public
		
		#region Variables
			__content_pad_x__ = 2;
		#endregion

		#region Builder Functions
			#region jsDoc
			/// @func    set_size(_width, _height)
			/// @desc    Sets control size and re-fits internal canvas.
			/// @self    WWTextInputSingleLine
			/// @param   {Real} width
			/// @param   {Real} height
			/// @returns {Struct.WWTextInputSingleLine}
			#endregion
			static set_size = function(_width, _height) {
				static __base_set_size__ = WWTextInput.set_size;
				__base_set_size__(_width, _height);
				__fit_canvas__();
				__ensure_caret_visible_horz__();
				return self;
			};
		#endregion
		
	#endregion
	
	#region Private

		#region Functions
			#region jsDoc
			/// @func    __fit_canvas__()
			/// @desc    Sizes the internal field to its content width (min viewport width) so horizontal scrolling works.
			/// @self    WWTextInputSingleLine
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __fit_canvas__ = function() {
				var _vw = region.viewport_width;
				if (_vw <= 0) { _vw = width; }

				var _content_w = field.get_content_width() + __content_pad_x__;
				var _w = max(_vw, _content_w);
				field.set_offset(0, 0);
				field.set_size(_w, height);
				region.set_canvas_size_from_children();

				// Clamp scroll if content shrank
				region.set_scroll_offset(region.scroll_x, 0);
			};
		#endregion
		
	#endregion

	// Defaults
	field.set_wrap_enabled(false);
	field.set_enter_submits_text(true);
	field.set_tab_exits_text(true);
	field.set_read_only(false);

	// Single-line: no scrollbars by default.
	region.set_scrollbars_enabled(false, false);
	region.set_scrollbars_auto_hide(true, true);

	// Single-line wheel behavior: Shift+wheel horizontal only.
	region.set_wheel_scroll_enabled(true, false);

	// Keep canvas width in sync with content changes, and caret-follow only when leaving view.
	field.on_change(function(_data) {
		__fit_canvas__();
		__ensure_caret_visible_horz__();
	});
	field.on_cursor_move(function(_data) {
		__ensure_caret_visible_horz__();
	});
		
	#endregion
	
}
