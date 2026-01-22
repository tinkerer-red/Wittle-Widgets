#region jsDoc
/// @func    WWViewScrollRegion()
/// @desc    Scroll view with scrollbars that drive and reflect scroll offsets.
/// @returns {Struct.WWViewScrollRegion}
#endregion
function WWViewScrollRegion() : WWViewScroll() constructor {
	debug_name = "WWViewScrollRegion";

	#region Public

		#region Builder Functions

			#region jsDoc
			/// @func    set_scrollbars()
			/// @desc    Assigns horizontal and vertical scrollbars and wires them to this view.
			/// @self    WWViewScrollRegion
			/// @param   {Struct.WWScrollbarHorz} _horz : Horizontal scrollbar or undefined.
			/// @param   {Struct.WWScrollbarVert} _vert : Vertical scrollbar or undefined.
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_scrollbars = function(_horz, _vert) {
				scrollbar_horz = _horz;
				scrollbar_vert = _vert;

				__wire_scrollbars__();
				__sync_scrollbars__();

				return self;
			};

			#region jsDoc
			/// @func    set_canvas()
			/// @desc    Assigns the canvas component and synchronizes scrollbars.
			/// @self    WWViewScrollRegion
			/// @param   {Struct.WWCore} _canvas : Canvas component to mount into the view.
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_canvas = function(_canvas) {
				static _base_set_canvas = WWViewScroll.set_canvas;

				_base_set_canvas(_canvas);

				__sync_scrollbars__();

				return self;
			};

			#region jsDoc
			/// @func    set_size()
			/// @desc    Sets the view size and synchronizes scrollbars.
			/// @self    WWViewScrollRegion
			/// @param   {Real} _width : View width.
			/// @param   {Real} _height : View height.
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_size = function(_width, _height) {
				static _base_set_size = WWViewScroll.set_size;

				_base_set_size(_width, _height);

				__sync_scrollbars__();

				return self;
			};

			#region jsDoc
			/// @func    set_scroll_offset()
			/// @desc    Sets the scroll offset and updates scrollbars.
			/// @self    WWViewScrollRegion
			/// @param   {Real} _xoff : Horizontal scroll offset.
			/// @param   {Real} _yoff : Vertical scroll offset.
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_scroll_offset = function(_xoff=0, _yoff=0) {
				static _base_set_scroll = WWViewScroll.set_scroll_offset;

				_base_set_scroll(_xoff, _yoff);

				__sync_scrollbars__();

				return self;
			};

			#region jsDoc
			/// @func    set_content_size()
			/// @desc    Sets the content size used for clamping and updates scrollbars.
			/// @self    WWViewScrollRegion
			/// @param   {Real} _width : Content width.
			/// @param   {Real} _height : Content height.
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_content_size = function(_width, _height) {
				static _base_set_content_size = WWViewScroll.set_content_size;

				_base_set_content_size(_width, _height);

				__sync_scrollbars__();

				return self;
			};

		#endregion

		#region Functions

			#region jsDoc
			/// @func    get_scrollbars()
			/// @desc    Returns the currently assigned scrollbars.
			/// @self    WWViewScrollRegion
			/// @returns {Struct} scrollbars_struct_with_horz_vert
			#endregion
			static get_scrollbars = function() {
				return { horz: scrollbar_horz, vert: scrollbar_vert };
			};

		#endregion

	#endregion

	#region Private

		#region Variables

			scrollbar_horz = undefined;
			scrollbar_vert = undefined;

		#endregion

		#region Functions

			#region jsDoc
			/// @func    __wire_scrollbars__()
			/// @desc    Wires scrollbar callbacks to update this view's scroll offsets.
			/// @returns {Undefined}
			///@ignore
			#endregion
			static __wire_scrollbars__ = function() {
				if (scrollbar_horz != undefined) {
					scrollbar_horz.set_callback(method({this: self}, function() {
						with (this) __on_scrollbar_horz__();
					}));
				}

				if (scrollbar_vert != undefined) {
					scrollbar_vert.set_callback(method({this: self}, function() {
						with (this) __on_scrollbar_vert__();
					}));
				}
			};

			#region jsDoc
			/// @func    __on_scrollbar_horz__()
			/// @desc    Applies the horizontal scrollbar value to the view's scroll offset.
			/// @returns {Undefined}
			///@ignore
			#endregion
			static __on_scrollbar_horz__ = function() {
				if (scrollbar_horz == undefined) { return; }
				set_scroll_offset(scrollbar_horz.get_value(), scroll_y);
			};

			#region jsDoc
			/// @func    __on_scrollbar_vert__()
			/// @desc    Applies the vertical scrollbar value to the view's scroll offset.
			/// @returns {Undefined}
			///@ignore
			#endregion
			static __on_scrollbar_vert__ = function() {
				if (scrollbar_vert == undefined) { return; }
				set_scroll_offset(scroll_x, scrollbar_vert.get_value());
			};

			#region jsDoc
			/// @func    __sync_scrollbars__()
			/// @desc    Updates scrollbar sizes and values from current content and view state.
			/// @returns {Undefined}
			///@ignore
			#endregion
			static __sync_scrollbars__ = function() {
				if (canvas != undefined) {
					content_width = canvas.width;
					content_height = canvas.height;
				}

				if (scrollbar_horz != undefined) {
					scrollbar_horz.set_canvas_size(content_width);
					scrollbar_horz.set_coverage_size(width);
					scrollbar_horz.set_value(scroll_x);
				}

				if (scrollbar_vert != undefined) {
					scrollbar_vert.set_canvas_size(content_height);
					scrollbar_vert.set_coverage_size(height);
					scrollbar_vert.set_value(scroll_y);
				}
			};

		#endregion

	#endregion

}
