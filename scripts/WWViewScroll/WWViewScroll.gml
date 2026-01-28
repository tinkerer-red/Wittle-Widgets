#region jsDoc
/// @func    WWViewScroll()
/// @desc    View that clips its content and applies a clamped scroll offset to its canvas.
/// @returns {Struct.WWViewScroll}
#endregion
function WWViewScroll() : WWView() constructor {
	debug_name = "WWViewScroll";

	#region Public

		#region Builder Functions

			#region jsDoc
			/// @func    set_canvas()
			/// @desc    Assigns the canvas component and reapplies the current scroll offset.
			/// @self    WWViewScroll
			/// @param   {Struct.WWCore} _canvas : Canvas component to mount into the view.
			/// @returns {Struct.WWViewScroll}
			#endregion
			static set_canvas = function(_canvas) {
				static _view_set_canvas = WWView.set_canvas;

				_view_set_canvas(_canvas);

				__sync_content_size__();
				__clamp_scroll__();
				__apply_scroll__();

				return self;
			};

			#region jsDoc
			/// @func    set_size()
			/// @desc    Sets the view size and re-clamps the current scroll offset.
			/// @self    WWViewScroll
			/// @param   {Real} _width : View width.
			/// @param   {Real} _height : View height.
			/// @returns {Struct.WWViewScroll}
			#endregion
			static set_size = function(_width, _height) {
				static _core_set_size = WWCore.set_size;

				_core_set_size(_width, _height);

				__clamp_scroll__();
				__apply_scroll__();

				return self;
			};

			#region jsDoc
			/// @func    set_scroll_offset()
			/// @desc    Sets the scroll offset in pixels (clamped to content bounds).
			/// @self    WWViewScroll
			/// @param   {Real} _xoff : Horizontal scroll offset.
			/// @param   {Real} _yoff : Vertical scroll offset.
			/// @returns {Struct.WWViewScroll}
			#endregion
			static set_scroll_offset = function(_xoff=0, _yoff=0) {
				scroll_x = _xoff;
				scroll_y = _yoff;
				
				__clamp_scroll__();
				__apply_scroll__();

				return self;
			};

			#region jsDoc
			/// @func    scroll_by()
			/// @desc    Adds a delta to the current scroll offset (clamped).
			/// @self    WWViewScroll
			/// @param   {Real} _dx : Horizontal delta.
			/// @param   {Real} _dy : Vertical delta.
			/// @returns {Struct.WWViewScroll}
			#endregion
			static scroll_by = function(_dx=0, _dy=0) {
				return set_scroll_offset(scroll_x + _dx, scroll_y + _dy);
			};

			#region jsDoc
			/// @func    set_content_size()
			/// @desc    Sets the content size used for clamping (also sizes the canvas if present).
			/// @self    WWViewScroll
			/// @param   {Real} _width : Content width.
			/// @param   {Real} _height : Content height.
			/// @returns {Struct.WWViewScroll}
			#endregion
			static set_content_size = function(_width, _height) {
				content_width = _width;
				content_height = _height;

				if (canvas != undefined) {
					canvas.set_size(content_width, content_height);
				}

				__clamp_scroll__();
				__apply_scroll__();

				return self;
			};

			#region jsDoc
			/// @func    set_scroll_max()
			/// @desc    Convenience: sets the maximum scroll offsets by converting them into a content size.
			///          Equivalent to set_content_size(view_width + max_x, view_height + max_y).
			/// @self    WWViewScroll
			/// @param   {Real} _max_x : Max horizontal scroll in pixels.
			/// @param   {Real} _max_y : Max vertical scroll in pixels.
			/// @returns {Struct.WWViewScroll}
			#endregion
			static set_scroll_max = function(_max_x=0, _max_y=0) {
				_max_x = max(0, _max_x);
				_max_y = max(0, _max_y);
				return set_content_size(width + _max_x, height + _max_y);
			};

		#endregion

		#region Variables

			scroll_x = 0;
			scroll_y = 0;

			content_width = 0;
			content_height = 0;

		#endregion

		#region Functions

			#region jsDoc
			/// @func    get_scroll_offset()
			/// @desc    Returns the current scroll offset in pixels.
			/// @self    WWViewScroll
			/// @returns {Struct} offset_struct_with_x_y
			#endregion
			static get_scroll_offset = function() {
				return { x: scroll_x, y: scroll_y };
			};

			#region jsDoc
			/// @func    get_content_size()
			/// @desc    Returns the content size used for clamping.
			/// @self    WWViewScroll
			/// @returns {Struct} size_struct_with_width_height
			#endregion
			static get_content_size = function() {
				return { width: content_width, height: content_height };
			};

			#region jsDoc
			/// @func    get_scroll_max()
			/// @desc    Returns the maximum scroll offsets based on content and view sizes.
			/// @self    WWViewScroll
			/// @returns {Struct} max_struct_with_x_y
			#endregion
			static get_scroll_max = function() {
				var _max_x = content_width - width;
				var _max_y = content_height - height;

				if (_max_x < 0) { _max_x = 0; }
				if (_max_y < 0) { _max_y = 0; }

				return { x: _max_x, y: _max_y };
			};

		#endregion

	#endregion

	#region Private

		#region Functions

			#region jsDoc
			/// @func    __sync_content_size__()
			/// @desc    Updates cached content size from the current canvas.
			/// @returns {Undefined}
			///@ignore
			#endregion
			static __sync_content_size__ = function() {
				if (canvas == undefined) {
					content_width = 0;
					content_height = 0;
					return;
				}

				content_width = canvas.width;
				content_height = canvas.height;
			};

			#region jsDoc
			/// @func    __clamp_scroll__()
			/// @desc    Clamps scroll offsets to [0..max] based on content size and view size.
			/// @returns {Undefined}
			///@ignore
			#endregion
			static __clamp_scroll__ = function() {
				var _max_x = content_width - width;
				var _max_y = content_height - height;

				if (_max_x < 0) { _max_x = 0; }
				if (_max_y < 0) { _max_y = 0; }

				scroll_x = clamp(scroll_x, 0, _max_x);
				scroll_y = clamp(scroll_y, 0, _max_y);
			};

			#region jsDoc
			/// @func    __apply_scroll__()
			/// @desc    Applies the current scroll offset to the canvas.
			/// @returns {Undefined}
			///@ignore
			#endregion
			static __apply_scroll__ = function() {
				if (canvas == undefined) { return; }
				canvas.set_offset(-scroll_x, -scroll_y);
			};

		#endregion

	#endregion

}
