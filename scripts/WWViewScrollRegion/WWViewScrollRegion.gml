#region jsDoc
/// @func    WWViewScrollRegion()
/// @desc    Wrapper-style scroll region (GUICompRegion replacement).
///          This component is a WWCore wrapper that owns an internal WWViewScroll.
///          - Child management (add/insert/remove/clear_children) forwards to the internal canvas.
///          - Scrollbars are normal children of the wrapper (like WWFolder's container pattern).
///          - Backward compatible API is preserved via delegation.
/// @returns {Struct.WWViewScrollRegion}
#endregion
function WWViewScrollRegion() : WWCore() constructor {
	debug_name = "WWViewScrollRegion";

	#region Public

		#region Variables
			// Compatibility fields (mirror internal view state)
			scroll_x = 0;
			scroll_y = 0;
			content_width = 0;
			content_height = 0;

			scrollbar_horz = undefined;
			scrollbar_vert = undefined;

			region_mode = false;
			viewport_width = 0;
			viewport_height = 0;

			scrollbar_thickness = 16;
			wheel_step = 10;
			smooth_scrolling = false;

			scrollbar_horz_enabled = true;
			scrollbar_vert_enabled = true;
			scrollbar_horz_auto = true;
			scrollbar_vert_auto = true;
			scrollbar_horz_visible = false;
			scrollbar_vert_visible = false;

				wheel_scroll_horz_enabled = true;
				wheel_scroll_vert_enabled = true;

			__syncing_scrollbars__ = false;
			__reflowing__ = false;
			__scroll_event_data__ = { x: 0, y: 0, dx: 0, dy: 0 };
		#endregion
		
		#region Components
			
			// Internal view + canvas must be created early so events/builders can reference them.
			__view__ = new WWViewScroll();
			__canvas__ = new WWCore().set_offset(0, 0);
			
			// Back-compat alias: many callsites expect a `canvas` field.
			canvas = __canvas__;
			__view__.set_canvas(__canvas__);
			
			// Add the internal view as the first wrapper child.
			// Must call the base add, not our overridden add that forwards into the canvas.
			__base_add__([__view__]);
			
		#endregion
		
		#region Events
			// Scroll events (GUICompRegion parity + axis split).
			events.scroll = variable_get_hash("scroll");
			events.scroll_horz = variable_get_hash("scroll_horz");
			events.scroll_vert = variable_get_hash("scroll_vert");
			events.scrolled_up = variable_get_hash("scrolled_up");
			events.scrolled_down = variable_get_hash("scrolled_down");
			events.scrolled_left = variable_get_hash("scrolled_left");
			events.scrolled_right = variable_get_hash("scrolled_right");

			#region jsDoc
			/// @func    on_scroll()
			/// @desc    Fires whenever scroll offset changes (any axis).
			/// @self    WWViewScrollRegion
			/// @param   {Function} _func : callback(data)
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static on_scroll = function(_func) { add_event_listener(events.scroll, _func); return self; };
			#region jsDoc
			/// @func    on_scroll_horz()
			/// @desc    Fires whenever horizontal scroll offset changes.
			/// @self    WWViewScrollRegion
			/// @param   {Function} _func : callback(data)
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static on_scroll_horz = function(_func) { add_event_listener(events.scroll_horz, _func); return self; };
			#region jsDoc
			/// @func    on_scroll_vert()
			/// @desc    Fires whenever vertical scroll offset changes.
			/// @self    WWViewScrollRegion
			/// @param   {Function} _func : callback(data)
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static on_scroll_vert = function(_func) { add_event_listener(events.scroll_vert, _func); return self; };
			#region jsDoc
			/// @func    on_scrolled_up()
			/// @desc    Fires when vertical scroll decreases.
			/// @self    WWViewScrollRegion
			/// @param   {Function} _func
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static on_scrolled_up = function(_func) { add_event_listener(events.scrolled_up, _func); return self; };
			#region jsDoc
			/// @func    on_scrolled_down()
			/// @desc    Fires when vertical scroll increases.
			/// @self    WWViewScrollRegion
			/// @param   {Function} _func
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static on_scrolled_down = function(_func) { add_event_listener(events.scrolled_down, _func); return self; };
			#region jsDoc
			/// @func    on_scrolled_left()
			/// @desc    Fires when horizontal scroll decreases.
			/// @self    WWViewScrollRegion
			/// @param   {Function} _func
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static on_scrolled_left = function(_func) { add_event_listener(events.scrolled_left, _func); return self; };
			#region jsDoc
			/// @func    on_scrolled_right()
			/// @desc    Fires when horizontal scroll increases.
			/// @self    WWViewScrollRegion
			/// @param   {Function} _func
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static on_scrolled_right = function(_func) { add_event_listener(events.scrolled_right, _func); return self; };

			// Mouse wheel hook: scroll when mouse is over the region (view or scrollbars).
			on_mouse_over(function(_input) {
				//horz
				if (keyboard_check(vk_shift)) {
					if (!wheel_scroll_horz_enabled) { return; }
					if (mouse_wheel_up()) {
						scroll_by(-wheel_step, 0);
					}
					else if (mouse_wheel_down()) {
						scroll_by(wheel_step, 0);
					}
				}
				else { //vert
					if (!wheel_scroll_vert_enabled) { return; }
					if (mouse_wheel_up()) {
						scroll_by(0, -wheel_step);
					}
					else if (mouse_wheel_down()) {
						scroll_by(0, wheel_step);
					}
				}
			});
		#endregion

		#region Builder Functions
			#region jsDoc
			/// @func    set_region_mode()
			/// @desc    Enables/disables "scroll region" behavior (auto layout + auto-hide scrollbars).
			///          When enabled, this component treats its own width/height as the total region size.
			/// @self    WWViewScrollRegion
			/// @param   {Bool} _enabled : Enable scroll region behavior.
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_region_mode = function(_enabled=true) {
				region_mode = _enabled;
				__reflow__();
				return self;
			};

			#region jsDoc
			/// @func    set_scrollbars_enabled()
			/// @desc    Enables/disables horizontal and/or vertical scrollbar usage.
			/// @self    WWViewScrollRegion
			/// @param   {Bool} _horz_enabled
			/// @param   {Bool} _vert_enabled
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_scrollbars_enabled = function(_horz_enabled=true, _vert_enabled=true) {
				scrollbar_horz_enabled = _horz_enabled;
				scrollbar_vert_enabled = _vert_enabled;
				__reflow__();
				return self;
			};

			#region jsDoc
			/// @func    set_scrollbars_auto_hide()
			/// @desc    Sets auto-hide behavior. When true, scrollbars only appear if content exceeds the viewport.
			/// @self    WWViewScrollRegion
			/// @param   {Bool} _horz_auto
			/// @param   {Bool} _vert_auto
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_scrollbars_auto_hide = function(_horz_auto=true, _vert_auto=true) {
				scrollbar_horz_auto = _horz_auto;
				scrollbar_vert_auto = _vert_auto;
				__reflow__();
				return self;
			};

			#region jsDoc
			/// @func    set_scrollbar_thickness()
			/// @desc    Sets the thickness (pixels) of both scrollbars when they are shown.
			/// @self    WWViewScrollRegion
			/// @param   {Real} _thickness
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_scrollbar_thickness = function(_thickness) {
				scrollbar_thickness = _thickness;
				__reflow__();
				return self;
			};

			#region jsDoc
			/// @func    set_wheel_step()
			/// @desc    Sets pixels scrolled per mouse wheel unit.
			/// @self    WWViewScrollRegion
			/// @param   {Real} _pixels_per_wheel
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_wheel_step = function(_pixels_per_wheel) {
				wheel_step = _pixels_per_wheel;
				return self;
			};

			#region jsDoc
			/// @func    set_wheel_scroll_enabled()
			/// @desc    Enables/disables mouse wheel scrolling per-axis.
			///          Note: horizontal wheel scrolling is triggered by Shift+wheel.
			/// @self    WWViewScrollRegion
			/// @param   {Bool} _horz_enabled
			/// @param   {Bool} _vert_enabled
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_wheel_scroll_enabled = function(_horz_enabled=true, _vert_enabled=true) {
				wheel_scroll_horz_enabled = _horz_enabled;
				wheel_scroll_vert_enabled = _vert_enabled;
				return self;
			};

			#region jsDoc
			/// @func    set_smooth_scrolling()
			/// @desc    Enables/disables smooth scrolling on attached scrollbars.
			/// @self    WWViewScrollRegion
			/// @param   {Bool} _smooth
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_smooth_scrolling = function(_smooth=false) {
				smooth_scrolling = _smooth;
				if (scrollbar_horz != undefined) scrollbar_horz.set_smooth_scrolling(_smooth);
				if (scrollbar_vert != undefined) scrollbar_vert.set_smooth_scrolling(_smooth);
				return self;
			};

			#region jsDoc
			/// @func    set_canvas()
			/// @desc    Assigns the internal view canvas.
			/// @self    WWViewScrollRegion
			/// @param   {Struct.WWCore} _canvas
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_canvas = function(_canvas) {
				__canvas__ = _canvas;
				canvas = __canvas__;
				__view__.set_canvas(__canvas__);
				__sync_cached_state_from_view__();
				__reflow__();
				return self;
			};


			#region jsDoc
			/// @func    set_canvas_size()
			/// @desc    Sets the content size used for clamping. Pass -1 to auto-size from canvas children.
			/// @self    WWViewScrollRegion
			/// @param   {Real} _width
			/// @param   {Real} _height
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_canvas_size = function(_width, _height) {
				if (_width == -1 || _height == -1) {
					__set_content_size_from_canvas_children__();
					__reflow__();
					return self;
				}

				content_width = _width;
				content_height = _height;

				__view__.set_content_size(content_width, content_height);
				__sync_cached_state_from_view__();
				__reflow__();
				return self;
			};

			#region jsDoc
			/// @func    set_canvas_size_from_children()
			/// @desc    Auto-sizes content size from the canvas group bounds.
			/// @self    WWViewScrollRegion
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_canvas_size_from_children = function() {
				__set_content_size_from_canvas_children__();
				__reflow__();
				return self;
			};

			#region jsDoc
			/// @func    set_size()
			/// @desc    Sets the total region size (region mode) or viewport size (normal mode).
			/// @self    WWViewScrollRegion
			/// @param   {Real} _width
			/// @param   {Real} _height
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_size = function(_width, _height) {
				__base_set_size__(_width, _height);
				__reflow__();
				return self;
			};

			#region jsDoc
			/// @func    set_viewport_size()
			/// @desc    Sets the desired viewport size. In non-region mode this matches set_size.
			///          In region mode, adjusts total region size to converge on the requested viewport size.
			/// @self    WWViewScrollRegion
			/// @param   {Real} _width
			/// @param   {Real} _height
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_viewport_size = function(_width, _height) {
				_width = max(0, _width);
				_height = max(0, _height);
				
				if (!region_mode) {
					return set_size(_width, _height);
				}
				
				var _w = _width;
				var _h = _height;
				repeat (3) {
					__base_set_size__(_w, _h);
					__reflow__();
					
					var _dw = _width - viewport_width;
					var _dh = _height - viewport_height;
					if (_dw == 0 && _dh == 0) { break; }
					
					_w = max(0, _w + _dw);
					_h = max(0, _h + _dh);
				}
				
				return self;
			};

			#region jsDoc
			/// @func    set_scroll_offset()
			/// @desc    Sets the scroll offset and updates scrollbars.
			/// @self    WWViewScrollRegion
			/// @param   {Real} _xoff
			/// @param   {Real} _yoff
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_scroll_offset = function(_xoff=0, _yoff=0) {
				var _old_x = scroll_x;
				var _old_y = scroll_y;
				__view__.set_scroll_offset(_xoff, _yoff);
				__sync_cached_state_from_view__();
				__sync_scrollbars__();
				__trigger_scroll_events__(_old_x, _old_y);
				return self;
			};

			#region jsDoc
			/// @func    scroll_by()
			/// @desc    Adds a delta to the current scroll offset (clamped).
			/// @self    WWViewScrollRegion
			/// @param   {Real} _dx
			/// @param   {Real} _dy
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static scroll_by = function(_dx=0, _dy=0) {
				return set_scroll_offset(scroll_x + _dx, scroll_y + _dy);
			};

			#region jsDoc
			/// @func    set_content_size()
			/// @desc    Sets the content size used for clamping.
			/// @self    WWViewScrollRegion
			/// @param   {Real} _width
			/// @param   {Real} _height
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_content_size = function(_width, _height) {
				content_width = _width;
				content_height = _height;
				__view__.set_content_size(content_width, content_height);
				__sync_cached_state_from_view__();
				__reflow__();
				return self;
			};

			#region jsDoc
			/// @func    set_scroll_max()
			/// @desc    Forwards to the internal view's set_scroll_max (convenience for sizing content via max scroll).
			/// @self    WWViewScrollRegion
			/// @param   {Real} _max_x
			/// @param   {Real} _max_y
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_scroll_max = function(_max_x=0, _max_y=0) {
				var _old_x = scroll_x;
				var _old_y = scroll_y;
				__view__.set_scroll_max(_max_x, _max_y);
				__sync_cached_state_from_view__();
				__reflow__();
				__sync_scrollbars__();
				__trigger_scroll_events__(_old_x, _old_y);
				return self;
			};
		#endregion

		#region Functions
			#region jsDoc
			/// @func    add()
			/// @desc    Forwards additions into the internal canvas.
			/// @self    WWViewScrollRegion
			/// @param   {Struct.WWCore|Array} _comp
			/// @returns {Undefined}
			#endregion
			static add = function(_comp) {
				var _result = __canvas__.add(_comp);
				__reflow__();
				return _result;
			};

			#region jsDoc
			/// @func    insert()
			/// @desc    Forwards insertions into the internal canvas.
			/// @self    WWViewScrollRegion
			/// @param   {Real|Struct.WWCore|Array} _a
			/// @param   {Real|Struct.WWCore|Array} _b
			/// @returns {Undefined}
			#endregion
			static insert = function(_a, _b) {
				var _index;
				var _comp;
				if (is_real(_a)) {
					_index = _a;
					_comp = _b;
				} else {
					_comp = _a;
					_index = _b;
				}
				var _result = __canvas__.insert(_index, _comp);
				__reflow__();
				return _result;
			};

			#region jsDoc
			/// @func    remove()
			/// @desc    Removes from the canvas by default; removes wrapper-owned children (view/scrollbars) via base.
			/// @self    WWViewScrollRegion
			/// @param   {Struct.WWCore} _comp
			/// @returns {Undefined}
			#endregion
			static remove = function(_comp) {
				if (_comp == __view__ || _comp == scrollbar_horz || _comp == scrollbar_vert) {
					__base_remove__(_comp);
					return;
				}
				__canvas__.remove(_comp);
				__reflow__();
			};

			#region jsDoc
			/// @func    clear_children()
			/// @desc    Clears only canvas children (does not remove the internal view or scrollbars).
			/// @self    WWViewScrollRegion
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static clear_children = function() {
				__canvas__.clear_children();
				__reflow__();
				return self;
			};

			#region jsDoc
			/// @func    update_component_positions()
			/// @desc    Keeps internal view and scrollbars laid out.
			/// @self    WWViewScrollRegion
			/// @returns {Undefined}
			#endregion
			static update_component_positions = function() {
				// Ensure child offsets/sizes are current before the base positions them.
				__view__.set_alignment(fa_left, fa_top);
				__view__.set_offset(0, 0);
				__view__.set_size(viewport_width, viewport_height);
				__layout_scrollbars__();
				__base_update_component_positions__();
			};

			#region jsDoc
			/// @func    get_viewport_size()
			/// @desc    Returns the current viewport size used for clamping.
			/// @self    WWViewScrollRegion
			/// @returns {Struct} size_struct_with_width_height
			#endregion
			static get_viewport_size = function() {
				return { width: viewport_width, height: viewport_height };
			};

			#region jsDoc
			/// @func    get_region_mode()
			/// @desc    Returns whether scroll region behavior is enabled.
			/// @self    WWViewScrollRegion
			/// @returns {Bool}
			#endregion
			static get_region_mode = function() {
				return region_mode;
			};

			#region jsDoc
			/// @func    get_scrollbars_enabled()
			/// @desc    Returns whether each scrollbar axis is enabled.
			/// @self    WWViewScrollRegion
			/// @returns {Struct}
			#endregion
			static get_scrollbars_enabled = function() {
				return { horz: scrollbar_horz_enabled, vert: scrollbar_vert_enabled };
			};

			#region jsDoc
			/// @func    get_scrollbars_auto_hide()
			/// @desc    Returns whether each scrollbar axis is set to auto-hide.
			/// @self    WWViewScrollRegion
			/// @returns {Struct}
			#endregion
			static get_scrollbars_auto_hide = function() {
				return { horz: scrollbar_horz_auto, vert: scrollbar_vert_auto };
			};

			#region jsDoc
			/// @func    get_scrollbar_thickness()
			/// @desc    Returns the configured scrollbar thickness in pixels.
			/// @self    WWViewScrollRegion
			/// @returns {Real}
			#endregion
			static get_scrollbar_thickness = function() {
				return scrollbar_thickness;
			};

			#region jsDoc
			/// @func    get_wheel_step()
			/// @desc    Returns the configured mouse wheel step in pixels.
			/// @self    WWViewScrollRegion
			/// @returns {Real}
			#endregion
			static get_wheel_step = function() {
				return wheel_step;
			};

			#region jsDoc
			/// @func    get_wheel_scroll_enabled()
			/// @desc    Returns whether wheel scrolling is enabled for each axis.
			/// @self    WWViewScrollRegion
			/// @returns {Struct}
			#endregion
			static get_wheel_scroll_enabled = function() {
				return { horz: wheel_scroll_horz_enabled, vert: wheel_scroll_vert_enabled };
			};

			#region jsDoc
			/// @func    get_smooth_scrolling()
			/// @desc    Returns whether smooth scrolling is enabled on attached scrollbars.
			/// @self    WWViewScrollRegion
			/// @returns {Bool}
			#endregion
			static get_smooth_scrolling = function() {
				return smooth_scrolling;
			};

			#region jsDoc
			/// @func    get_scroll_offset()
			/// @desc    Returns the current scroll offset in pixels.
			/// @self    WWViewScrollRegion
			/// @returns {Struct} offset_struct_with_x_y
			#endregion
			static get_scroll_offset = function() {
				return { x: scroll_x, y: scroll_y };
			};

			#region jsDoc
			/// @func    get_content_size()
			/// @desc    Returns the content size used for clamping.
			/// @self    WWViewScrollRegion
			/// @returns {Struct} size_struct_with_width_height
			#endregion
			static get_content_size = function() {
				return { width: content_width, height: content_height };
			};

			#region jsDoc
			/// @func    get_canvas_size()
			/// @desc    Alias of get_content_size (compatibility).
			/// @self    WWViewScrollRegion
			/// @returns {Struct} size_struct_with_width_height
			#endregion
			static get_canvas_size = function() {
				return get_content_size();
			};

			#region jsDoc
			/// @func    get_canvas_size_from_children()
			/// @desc    Returns the canvas group bounds size computed from current children.
			/// @self    WWViewScrollRegion
			/// @returns {Struct} size_struct_with_width_height
			#endregion
			static get_canvas_size_from_children = function() {
				__canvas__.__update_group_region__();
				return { width: __canvas__.__group__.width, height: __canvas__.__group__.height };
			};

			#region jsDoc
			/// @func    get_scroll_max()
			/// @desc    Returns maximum scroll offsets based on content and viewport sizes.
			/// @self    WWViewScrollRegion
			/// @returns {Struct} max_struct_with_x_y
			#endregion
			static get_scroll_max = function() {
				return __view__.get_scroll_max();
			};

			#region jsDoc
			/// @func    get_canvas()
			/// @desc    Returns the current internal canvas (advanced usage).
			/// @self    WWViewScrollRegion
			/// @returns {Struct.WWCore}
			#endregion
			static get_canvas = function() {
				return __canvas__;
			};
		#endregion

	#endregion

	#region Private
		#region Functions
			// Capture base methods BEFORE overriding (avoids WWCore.* dot-access issues).
			static __base_add__ = WWCore.add;
			static __base_remove__ = WWCore.remove;
			static __base_set_size__ = WWCore.set_size;
			static __base_update_component_positions__ = WWCore.update_component_positions;
			

			#region jsDoc
			/// @func    __sync_cached_state_from_view__()
			/// @desc    Mirrors internal view state into wrapper compatibility fields.
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __sync_cached_state_from_view__ = function() {
				var _off = __view__.get_scroll_offset();
				if (is_struct(_off)) {
					scroll_x = variable_struct_get(_off, "x");
					scroll_y = variable_struct_get(_off, "y");
				} else {
					scroll_x = 0;
					scroll_y = 0;
				}
				// Prefer the canvas size as authoritative (matches legacy WWViewScrollRegion behavior).
				content_width = __canvas__.width;
				content_height = __canvas__.height;
			};

			#region jsDoc
			/// @func    __sync_content_size_from_canvas__()
			/// @desc    Ensures internal view content size matches canvas size (and clamps scroll if needed).
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __sync_content_size_from_canvas__ = function() {
				var _cw = __canvas__.width;
				var _ch = __canvas__.height;
				if (_cw != content_width || _ch != content_height) {
					content_width = _cw;
					content_height = _ch;
					__view__.set_content_size(content_width, content_height);
					__sync_cached_state_from_view__();
				}
			};


			#region jsDoc
			/// @func    __on_scrollbar_horz__()
			/// @desc    Applies the horizontal scrollbar value to the region scroll.
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __on_scrollbar_horz__ = function() {
				if (scrollbar_horz == undefined) { return; }
				if (__syncing_scrollbars__) { return; }
				set_scroll_offset(scrollbar_horz.get_value(), scroll_y);
			};

			#region jsDoc
			/// @func    __on_scrollbar_vert__()
			/// @desc    Applies the vertical scrollbar value to the region scroll.
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __on_scrollbar_vert__ = function() {
				if (scrollbar_vert == undefined) { return; }
				if (__syncing_scrollbars__) { return; }
				set_scroll_offset(scroll_x, scrollbar_vert.get_value());
			};

			#region jsDoc
			/// @func    __set_content_size_from_canvas_children__()
			/// @desc    Updates content size from canvas group bounds.
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __set_content_size_from_canvas_children__ = function() {
				__canvas__.__update_group_region__();
				content_width = __canvas__.__group__.width;
				content_height = __canvas__.__group__.height;
				__view__.set_content_size(content_width, content_height);
				__sync_cached_state_from_view__();
			};

			#region jsDoc
			/// @func    __get_thickness__()
			/// @desc    Returns scrollbar thickness.
			/// @returns {Real}
			/// @ignore
			#endregion
			static __get_thickness__ = function() {
				return max(0, scrollbar_thickness);
			};

			#region jsDoc
			/// @func    __sync_scrollbars__()
			/// @desc    Updates scrollbar sizes and values from current content and viewport state.
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __sync_scrollbars__ = function() {
				var _cov_w = viewport_width;
				var _cov_h = viewport_height;
				if (!region_mode) {
					_cov_w = width;
					_cov_h = height;
				}

				__sync_content_size_from_canvas__();
				__sync_cached_state_from_view__();

				// Lazy wire: if you assign scrollbar_horz/scrollbar_vert directly,
				// they will still drive scrolling without needing a set/get wrapper.
				if (scrollbar_horz != undefined) {
					scrollbar_horz.set_callback(method({ this: self }, function() { with (this) __on_scrollbar_horz__(); }));
				}
				if (scrollbar_vert != undefined) {
					scrollbar_vert.set_callback(method({ this: self }, function() { with (this) __on_scrollbar_vert__(); }));
				}

				__syncing_scrollbars__ = true;
				if (scrollbar_horz != undefined) {
					scrollbar_horz.set_canvas_size(content_width);
					scrollbar_horz.set_coverage_size(_cov_w);
					scrollbar_horz.set_value(scroll_x);
				}
				if (scrollbar_vert != undefined) {
					scrollbar_vert.set_canvas_size(content_height);
					scrollbar_vert.set_coverage_size(_cov_h);
					scrollbar_vert.set_value(scroll_y);
				}
				__syncing_scrollbars__ = false;
			};

			#region jsDoc
			/// @func    __layout_scrollbars__()
			/// @desc    Sizes/positions scrollbars and applies their active state.
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __layout_scrollbars__ = function() {
				var _t = __get_thickness__();

				if (!region_mode) {
					// In normal mode, we do not manage visibility or layout.
					return;
				}

				if (scrollbar_horz != undefined) {
					scrollbar_horz.set_active(scrollbar_horz_visible);
					if (scrollbar_horz_visible) {
						var _is_child = scrollbar_horz.__is_child__;
						var _parent = scrollbar_horz.__parent__;
						if (_is_child && _parent == self) {
							scrollbar_horz.set_alignment(fa_left, fa_top);
							scrollbar_horz.set_offset(0, viewport_height);
							scrollbar_horz.set_size(viewport_width, _t);
						} else {
							scrollbar_horz.set_position(x, y + viewport_height);
							scrollbar_horz.set_size(viewport_width, _t);
						}
					}
				}

				if (scrollbar_vert != undefined) {
					scrollbar_vert.set_active(scrollbar_vert_visible);
					if (scrollbar_vert_visible) {
						var _is_child = scrollbar_vert.__is_child__;
						var _parent = scrollbar_vert.__parent__;
						if (_is_child && _parent == self) {
							scrollbar_vert.set_alignment(fa_left, fa_top);
							scrollbar_vert.set_offset(viewport_width, 0);
							scrollbar_vert.set_size(_t, viewport_height);
						} else {
							scrollbar_vert.set_position(x + viewport_width, y);
							scrollbar_vert.set_size(_t, viewport_height);
						}
					}
				}
			};

			#region jsDoc
			/// @func    __trigger_scroll_events__()
			/// @desc    Emits scroll events if the scroll offset changed.
			/// @param   {Real} _old_x
			/// @param   {Real} _old_y
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __trigger_scroll_events__ = function(_old_x, _old_y) {
				var _dx = scroll_x - _old_x;
				var _dy = scroll_y - _old_y;
				if (_dx == 0 && _dy == 0) { return; }

				var _data = __scroll_event_data__;
				_data.x = scroll_x;
				_data.y = scroll_y;
				_data.dx = _dx;
				_data.dy = _dy;

				trigger_event(events.scroll, _data);
				if (_dx != 0) {
					trigger_event(events.scroll_horz, _data);
					if (_dx < 0) { trigger_event(events.scrolled_left, _data); }
					else { trigger_event(events.scrolled_right, _data); }
				}
				if (_dy != 0) {
					trigger_event(events.scroll_vert, _data);
					if (_dy < 0) { trigger_event(events.scrolled_up, _data); }
					else { trigger_event(events.scrolled_down, _data); }
				}
			};

			#region jsDoc
			/// @func    __reflow__()
			/// @desc    Recomputes scrollbar visibility, viewport size, layout, and clamps scroll.
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __reflow__ = function() {
				var _old_x = scroll_x;
				var _old_y = scroll_y;
				if (__reflowing__) { return; }
				__reflowing__ = true;

				__sync_content_size_from_canvas__();

				// Keep viewport in sync.
				if (!region_mode) {
					viewport_width = width;
					viewport_height = height;
					__view__.set_size(viewport_width, viewport_height);
					__view__.set_scroll_offset(scroll_x, scroll_y);
					__sync_cached_state_from_view__();
					__sync_scrollbars__();
					__trigger_scroll_events__(_old_x, _old_y);
					__reflowing__ = false;
					return;
				}

				__sync_cached_state_from_view__();

				var _t = __get_thickness__();

				// Iteratively resolve interdependent scrollbar visibility.
				var _show_h = (scrollbar_horz != undefined) && scrollbar_horz_enabled;
				var _show_v = (scrollbar_vert != undefined) && scrollbar_vert_enabled;
				if (_show_h && scrollbar_horz_auto) { _show_h = false; }
				if (_show_v && scrollbar_vert_auto) { _show_v = false; }

				repeat (3) {
					var _vw = width - (_show_v ? _t : 0);
					var _vh = height - (_show_h ? _t : 0);
					if (_vw < 0) { _vw = 0; }
					if (_vh < 0) { _vh = 0; }

					var _want_h = (scrollbar_horz != undefined) && scrollbar_horz_enabled;
					var _want_v = (scrollbar_vert != undefined) && scrollbar_vert_enabled;
					if (_want_h) { _want_h = scrollbar_horz_auto ? (content_width > _vw) : true; }
					if (_want_v) { _want_v = scrollbar_vert_auto ? (content_height > _vh) : true; }

					if (_want_h == _show_h && _want_v == _show_v) { break; }
					_show_h = _want_h;
					_show_v = _want_v;
				}

				scrollbar_horz_visible = _show_h;
				scrollbar_vert_visible = _show_v;

				viewport_width = width - (_show_v ? _t : 0);
				viewport_height = height - (_show_h ? _t : 0);
				if (viewport_width < 0) { viewport_width = 0; }
				if (viewport_height < 0) { viewport_height = 0; }

				__view__.set_size(viewport_width, viewport_height);
				__view__.set_scroll_offset(scroll_x, scroll_y);
				__sync_cached_state_from_view__();

				__layout_scrollbars__();
				__sync_scrollbars__();
				__trigger_scroll_events__(_old_x, _old_y);

				__reflowing__ = false;
			};
		#endregion
	#endregion

	// Ensure the internal view starts sized correctly.
	__reflow__();

}
