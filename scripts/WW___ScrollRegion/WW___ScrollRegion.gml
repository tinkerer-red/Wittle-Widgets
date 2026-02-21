#region jsDoc
/// @func    WW___ScrollRegion()
/// @desc    Scrollable view wrapper that owns a scroll view and its two scrollbars.
/// @returns {Struct.WW___ScrollRegion}
#endregion
function WW___ScrollRegion() : WWCore() constructor {
	debug_name = "WW___ScrollRegion";

	#region Public

		#region Builder Functions

			#region jsDoc
			/// @func    set_scrollbar_thickness()
			/// @desc    Sets the thickness (pixels) of both scrollbars.
			/// @self    WW___ScrollRegion
			/// @param   {Real} thickness : Scrollbar thickness in pixels.
			/// @returns {Struct.WW___ScrollRegion}
			#endregion
			static set_scrollbar_thickness = function(_thickness) {
				scrollbar_thickness = _thickness;
				__layout_children__();
				return self;
			};

			#region jsDoc
			/// @func    set_wheel_step()
			/// @desc    Sets the number of pixels scrolled per mouse wheel unit.
			/// @self    WW___ScrollRegion
			/// @param   {Real} pixels_per_wheel : Pixels per wheel unit.
			/// @returns {Struct.WW___ScrollRegion}
			#endregion
			static set_wheel_step = function(_pixels_per_wheel) {
				wheel_step = _pixels_per_wheel;
				return self;
			};
			
			#region jsDoc
			/// @func    set_nav_entry_mode()
			/// @desc    Forwards nav-entry mode configuration to internal WWViewScrollRegion.
			/// @self    WW___ScrollRegion
			/// @param   {Real} mode : __WW_SCROLL_NAV_MODE.*
			/// @returns {Struct.WW___ScrollRegion}
			#endregion
			static set_nav_entry_mode = function(_mode) {
				view.set_nav_entry_mode(_mode);
				return self;
			};
			
			#region jsDoc
			/// @func    set_nav_trap_when_active()
			/// @desc    Forwards active-nav trap setting to internal WWViewScrollRegion.
			/// @self    WW___ScrollRegion
			/// @param   {Bool} enabled
			/// @returns {Struct.WW___ScrollRegion}
			#endregion
			static set_nav_trap_when_active = function(_enabled=true) {
				view.set_nav_trap_when_active(_enabled);
				return self;
			};
			
			#region jsDoc
			/// @func    set_nav_enter_action()
			/// @desc    Forwards enter action configuration to internal WWViewScrollRegion.
			/// @self    WW___ScrollRegion
			/// @param   {Real} action : __WW_NAV_ACTION.*
			/// @returns {Struct.WW___ScrollRegion}
			#endregion
			static set_nav_enter_action = function(_action=__WW_NAV_ACTION.SUBMIT) {
				view.set_nav_enter_action(_action);
				return self;
			};
			
			#region jsDoc
			/// @func    set_nav_exit_action()
			/// @desc    Forwards exit action configuration to internal WWViewScrollRegion.
			/// @self    WW___ScrollRegion
			/// @param   {Real} action : __WW_NAV_ACTION.*
			/// @returns {Struct.WW___ScrollRegion}
			#endregion
			static set_nav_exit_action = function(_action=__WW_NAV_ACTION.CANCEL) {
				view.set_nav_exit_action(_action);
				return self;
			};
			
			#region jsDoc
			/// @func    set_nav_remember_last_target()
			/// @desc    Forwards remember-last-target setting to internal WWViewScrollRegion.
			/// @self    WW___ScrollRegion
			/// @param   {Bool} enabled
			/// @returns {Struct.WW___ScrollRegion}
			#endregion
			static set_nav_remember_last_target = function(_enabled=true) {
				view.set_nav_remember_last_target(_enabled);
				return self;
			};

			#region jsDoc
			/// @func    set_viewport_size()
			/// @desc    Sets the visible viewport size (excludes scrollbars).
			/// @self    WW___ScrollRegion
			/// @param   {Real} width  : Viewport width.
			/// @param   {Real} height : Viewport height.
			/// @returns {Struct.WW___ScrollRegion}
			#endregion
			static set_viewport_size = function(_width, _height) {
				viewport_width = _width;
				viewport_height = _height;

				__layout_children__();
				__sync_scrollbars__();

				return self;
			};

			#region jsDoc
			/// @func    set_canvas()
			/// @desc    Assigns the canvas component that will be scrolled inside the view.
			/// @self    WW___ScrollRegion
			/// @param   {Struct.WWCore} canvas : Canvas component to scroll.
			/// @returns {Struct.WW___ScrollRegion}
			#endregion
			static set_canvas = function(_canvas) {
				view.set_canvas(_canvas);
				__sync_scrollbars__();
				return self;
			};

			#region jsDoc
			/// @func    set_content_size()
			/// @desc    Sets the content size used for clamping scroll offsets.
			/// @self    WW___ScrollRegion
			/// @param   {Real} width  : Content width.
			/// @param   {Real} height : Content height.
			/// @returns {Struct.WW___ScrollRegion}
			#endregion
			static set_content_size = function(_width, _height) {
				view.set_content_size(_width, _height);
				__sync_scrollbars__();
				return self;
			};

			#region jsDoc
			/// @func    set_scroll_offset()
			/// @desc    Sets the scroll offset in pixels (clamped).
			/// @self    WW___ScrollRegion
			/// @param   {Real} xoff : Horizontal scroll offset.
			/// @param   {Real} yoff : Vertical scroll offset.
			/// @returns {Struct.WW___ScrollRegion}
			#endregion
			static set_scroll_offset = function(_xoff=0, _yoff=0) {
				view.set_scroll_offset(_xoff, _yoff);
				__sync_scrollbars__();
				return self;
			};

			#region jsDoc
			/// @func    scroll_by()
			/// @desc    Adds a delta to the current scroll offset (clamped).
			/// @self    WW___ScrollRegion
			/// @param   {Real} dx : Horizontal delta.
			/// @param   {Real} dy : Vertical delta.
			/// @returns {Struct.WW___ScrollRegion}
			#endregion
			static scroll_by = function(_dx=0, _dy=0) {
				view.scroll_by(_dx, _dy);
				__sync_scrollbars__();
				return self;
			};

			#region jsDoc
			/// @func    set_size()
			/// @desc    Sets the total region size (includes scrollbars).
			/// @self    WW___ScrollRegion
			/// @param   {Real} width  : Total width.
			/// @param   {Real} height : Total height.
			/// @returns {Struct.WW___ScrollRegion}
			#endregion
			static set_size = function(_width, _height) {
				
				//super equivalent
				static _core_set_size = WWCore.set_size;
				_core_set_size(_width, _height);

				viewport_width = max(0, width - scrollbar_thickness);
				viewport_height = max(0, height - scrollbar_thickness);

				__layout_children__();
				__sync_scrollbars__();

				return self;
			};

		#endregion

		#region Components

			#region jsDoc
			/// @func    get_view()
			/// @desc    Returns the internal scroll view component.
			/// @self    WW___ScrollRegion
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static get_view = function() {
				return view;
			};

			#region jsDoc
			/// @func    get_scrollbar_horz()
			/// @desc    Returns the horizontal scrollbar component.
			/// @self    WW___ScrollRegion
			/// @returns {Struct.WWScrollBarHorz}
			#endregion
			static get_scrollbar_horz = function() {
				return scrollbar_horz;
			};

			#region jsDoc
			/// @func    get_scrollbar_vert()
			/// @desc    Returns the vertical scrollbar component.
			/// @self    WW___ScrollRegion
			/// @returns {Struct.WWScrollBarVert}
			#endregion
			static get_scrollbar_vert = function() {
				return scrollbar_vert;
			};
			
			#region jsDoc
			/// @func    get_nav_entry_mode()
			/// @desc    Returns nav-entry mode from internal WWViewScrollRegion.
			/// @self    WW___ScrollRegion
			/// @returns {Real}
			#endregion
			static get_nav_entry_mode = function() {
				return view.get_nav_entry_mode();
			};
			
			#region jsDoc
			/// @func    get_nav_active()
			/// @desc    Returns active nav-scope state from internal WWViewScrollRegion.
			/// @self    WW___ScrollRegion
			/// @returns {Bool}
			#endregion
			static get_nav_active = function() {
				return view.get_nav_active();
			};

		#endregion

		#region Variables

			viewport_width = 100;
			viewport_height = 100;

			scrollbar_thickness = 16;
			wheel_step = 10;

		#endregion

	#endregion

	#region Private

		#region Variables

			view = undefined;
			scrollbar_horz = undefined;
			scrollbar_vert = undefined;

		#endregion

		#region Functions

			#region jsDoc
			/// @func    __layout_children__()
			/// @desc    Updates child sizes and positions based on viewport size and scrollbar thickness.
			/// @self    WW___ScrollRegion
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __layout_children__ = function() {
				view
					.set_position(0, 0)
					.set_size(viewport_width, viewport_height);

				scrollbar_horz
					.set_position(0, viewport_height)
					.set_size(viewport_width, scrollbar_thickness);

				scrollbar_vert
					.set_position(viewport_width, 0)
					.set_size(scrollbar_thickness, viewport_height);

				static _core_set_size = WWCore.set_size;
				_core_set_size(viewport_width + scrollbar_thickness, viewport_height + scrollbar_thickness);
			};

			#region jsDoc
			/// @func    __sync_scrollbars__()
			/// @desc    Synchronizes scrollbar ranges and values from the view state.
			/// @self    WW___ScrollRegion
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __sync_scrollbars__ = function() {
				var _content = view.get_content_size();
				var _offset = view.get_scroll_offset();

				scrollbar_horz.set_canvas_size(_content.width);
				scrollbar_horz.set_coverage_size(viewport_width);
				scrollbar_horz.set_value(_offset.x);

				scrollbar_vert.set_canvas_size(_content.height);
				scrollbar_vert.set_coverage_size(viewport_height);
				scrollbar_vert.set_value(_offset.y);
			};

			#region jsDoc
			/// @func    __on_scrollbar_horz__()
			/// @desc    Applies the horizontal scrollbar value to the view.
			/// @self    WW___ScrollRegion
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __on_scrollbar_horz__ = function() {
				set_scroll_offset(scrollbar_horz.get_value(), view.get_scroll_offset().y);
			};

			#region jsDoc
			/// @func    __on_scrollbar_vert__()
			/// @desc    Applies the vertical scrollbar value to the view.
			/// @self    WW___ScrollRegion
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __on_scrollbar_vert__ = function() {
				set_scroll_offset(view.get_scroll_offset().x, scrollbar_vert.get_value());
			};

			#region jsDoc
			/// @func    __on_wheel__()
			/// @desc    Handles mouse wheel scrolling when the mouse is over the view.
			/// @self    WW___ScrollRegion
			/// @param   {Struct} input : Input state containing scroll_y.
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __on_wheel__ = function(_input) {
				if (!view.mouse_on_comp()) { return; }

				var _delta = -_input.scroll_y * wheel_step;
				scroll_by(0, _delta);
			};

		#endregion

	#endregion

	#region Components

		view = new WWViewScrollRegion();

		scrollbar_horz = new WWScrollBarHorz();
		scrollbar_vert = new WWScrollBarVert();

		view.scrollbar_horz = scrollbar_horz;
		view.scrollbar_vert = scrollbar_vert;
		view.set_scrollbars_enabled(true, true);

		add([view, scrollbar_horz, scrollbar_vert]);

		__layout_children__();
		__sync_scrollbars__();

	#endregion

	#region Events

		on_scroll(function(_input) {
			__on_wheel__(_input);
		});

		scrollbar_horz.set_callback(function() {
			with (this) __on_scrollbar_horz__();
		});

		scrollbar_vert.set_callback(function() {
			with (this) __on_scrollbar_vert__();
		});

	#endregion

}
