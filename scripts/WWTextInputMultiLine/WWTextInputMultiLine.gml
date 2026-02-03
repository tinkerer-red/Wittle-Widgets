#region jsDoc
/// @func    WWTextInputMultiLine()
/// @desc    Multi-line text input preset built on WWTextInput.
///          Defaults:
///          - Word wrap enabled
///          - Vertical scrolling enabled with auto-hide scrollbar
///          - Caret-follow scroll only when caret leaves view
/// @returns {Struct.WWTextInputMultiLine}
#endregion
function WWTextInputMultiLine() : WWTextInput() constructor {
	debug_name = "WWTextInputMultiLine";
	
	#region Public
		
		#region Builder Functions
			#region jsDoc
			/// @func    set_size(_width, _height)
			/// @desc    Sets control size and re-fits internal canvas.
			/// @self    WWTextInputMultiLine
			/// @param   {Real} width
			/// @param   {Real} height
			/// @returns {Struct.WWTextInputMultiLine}
			#endregion
			static set_size = function(_width, _height) {
				static __base_set_size__ = WWTextInput.set_size;
				__base_set_size__(_width, _height);
				__fit_canvas__();
				__ensure_caret_visible_vert__();
				return self;
			};
		#endregion
		
	#endregion
	
	#region Private

		#region Functions
			#region jsDoc
			/// @func    __fit_canvas__()
			/// @desc    Sizes the internal field height to content height (min viewport height) so vertical scrolling works.
			/// @self    WWTextInputMultiLine
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __fit_canvas__ = function() {
				var _vw = region.viewport_width;
				var _vh = region.viewport_height;
				if (_vw <= 0) { _vw = width; }
				if (_vh <= 0) { _vh = height; }

				// Ensure wrap calculation is based on viewport width
				field.set_offset(0, 0);
				field.set_size(_vw, max(_vh, 1));

				var _content_h = field.get_content_height();
				var _h = max(_vh, _content_h);
				field.set_size(_vw, _h);

				region.set_canvas_size_from_children();

				// Clamp scroll if content shrank
				region.set_scroll_offset(0, region.scroll_y);
			};
		#endregion
		
	#endregion

	// Defaults
	field.set_wrap_enabled(true);
	field.set_read_only(false);

	// Multi-line: vertical scrollbar auto-hides, horizontal disabled.
	region.set_scrollbars_enabled(false, true);
	region.set_scrollbars_auto_hide(true, true);

	// Keep canvas height in sync with content changes, and caret-follow only when leaving view.
	field.on_change(function(_data) {
		__fit_canvas__();
		__ensure_caret_visible_vert__();
	});
	field.on_cursor_move(function(_data) {
		__ensure_caret_visible_vert__();
	});
		
	#endregion
	
}
