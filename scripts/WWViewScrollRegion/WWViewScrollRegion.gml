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

			scrollbar_thickness = 12;
			wheel_step = 100;
			smooth_scrolling = true;

			scrollbar_horz_enabled = true;
			scrollbar_vert_enabled = true;
			scrollbar_horz_auto = true;
			scrollbar_vert_auto = true;
			scrollbar_horz_visible = false;
			scrollbar_vert_visible = false;
			scrollbar_horz_navigable = false;
			scrollbar_vert_navigable = false;

				wheel_scroll_horz_enabled = true;
				wheel_scroll_vert_enabled = true;

			__syncing_scrollbars__ = false;
			__reflowing__ = false;
			__scroll_event_data__ = { x: 0, y: 0, dx: 0, dy: 0 };
			__nav_entry_mode__ = __WW_SCROLL_NAV_MODE.DIRECT;
			__nav_trap_when_active__ = true;
			__nav_enter_action__ = __WW_NAV_ACTION.SUBMIT;
			__nav_exit_action__ = __WW_NAV_ACTION.CANCEL;
			__nav_remember_last_target__ = true;
			__nav_active__ = false;
			__nav_last_target_id__ = -1;
			__nav_locked_nodes__ = [];
			__nav_content_locked__ = false;
			__scroll_sync_source_axis__ = 0; // 0 none, 1 horz, 2 vert
			__canvas_auto_resize__ = true;
			__last_canvas_w__ = -1;
			__last_canvas_h__ = -1;
			__smooth_clamp_hold_x__ = false;
			__smooth_clamp_hold_y__ = false;
			__smooth_clamp_target_x__ = 0;
			__smooth_clamp_target_y__ = 0;
			__smooth_clamp_epsilon__ = 0.5;
		#endregion
		
		#region Components
			
			// Internal view + canvas must be created early so events/builders can reference them.
			__view__ = new WWViewScroll();
			__canvas__ = new WWCanvas()
				.set_draw_fill(false)
				.set_draw_border(false)
				.set_auto_resize(true)
				.set_offset(0, 0);
			
			// Back-compat alias: many callsites expect a `canvas` field.
			canvas = __canvas__;
			__view__.set_canvas(__canvas__);
			__last_canvas_w__ = __canvas__.width;
			__last_canvas_h__ = __canvas__.height;
			
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
			/// @param   {Function} func : callback(data)
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static on_scroll = function(_func) { add_event_listener(events.scroll, _func); return self; };
			#region jsDoc
			/// @func    on_scroll_horz()
			/// @desc    Fires whenever horizontal scroll offset changes.
			/// @self    WWViewScrollRegion
			/// @param   {Function} func : callback(data)
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static on_scroll_horz = function(_func) { add_event_listener(events.scroll_horz, _func); return self; };
			#region jsDoc
			/// @func    on_scroll_vert()
			/// @desc    Fires whenever vertical scroll offset changes.
			/// @self    WWViewScrollRegion
			/// @param   {Function} func : callback(data)
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static on_scroll_vert = function(_func) { add_event_listener(events.scroll_vert, _func); return self; };
			#region jsDoc
			/// @func    on_scrolled_up()
			/// @desc    Fires when vertical scroll decreases.
			/// @self    WWViewScrollRegion
			/// @param   {Function} func
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static on_scrolled_up = function(_func) { add_event_listener(events.scrolled_up, _func); return self; };
			#region jsDoc
			/// @func    on_scrolled_down()
			/// @desc    Fires when vertical scroll increases.
			/// @self    WWViewScrollRegion
			/// @param   {Function} func
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static on_scrolled_down = function(_func) { add_event_listener(events.scrolled_down, _func); return self; };
			#region jsDoc
			/// @func    on_scrolled_left()
			/// @desc    Fires when horizontal scroll decreases.
			/// @self    WWViewScrollRegion
			/// @param   {Function} func
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static on_scrolled_left = function(_func) { add_event_listener(events.scrolled_left, _func); return self; };
			#region jsDoc
			/// @func    on_scrolled_right()
			/// @desc    Fires when horizontal scroll increases.
			/// @self    WWViewScrollRegion
			/// @param   {Function} func
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static on_scrolled_right = function(_func) { add_event_listener(events.scrolled_right, _func); return self; };

			// Mouse wheel hook: scroll when mouse is over the region (view or scrollbars).
			on_mouse_over(function(_input) {
				//horz
				if (_input.keyboard.key_down(vk_shift)) {
					if (!wheel_scroll_horz_enabled) { return; }
					if (_input.pointer.wheel_up) {
						if (smooth_scrolling
						&& (scrollbar_horz != undefined)) {
							scrollbar_horz.set_lerp_target(scrollbar_horz.get_lerp_target() - wheel_step);
						}
						else {
							scroll_by(-wheel_step, 0);
						}
					}
					else if (_input.pointer.wheel_down) {
						if (smooth_scrolling
						&& (scrollbar_horz != undefined)) {
							scrollbar_horz.set_lerp_target(scrollbar_horz.get_lerp_target() + wheel_step);
						}
						else {
							scroll_by(wheel_step, 0);
						}
					}
				}
				else { //vert
					if (!wheel_scroll_vert_enabled) { return; }
					if (_input.pointer.wheel_up) {
						if (smooth_scrolling
						&& (scrollbar_vert != undefined)) {
							scrollbar_vert.set_lerp_target(scrollbar_vert.get_lerp_target() - wheel_step);
						}
						else {
							scroll_by(0, -wheel_step);
						}
					}
					else if (_input.pointer.wheel_down) {
						if (smooth_scrolling
						&& (scrollbar_vert != undefined)) {
							scrollbar_vert.set_lerp_target(scrollbar_vert.get_lerp_target() + wheel_step);
						}
						else {
							scroll_by(0, wheel_step);
						}
					}
				}
			});

			// Reflow whenever canvas bounds change (e.g. nested folder collapse/expand).
			on_post_step(function(_input) {
				if (__canvas__ == undefined) return;

				var _cw = __canvas__.width;
				var _ch = __canvas__.height;
				if (_cw != __last_canvas_w__
				|| _ch != __last_canvas_h__) {
					__last_canvas_w__ = _cw;
					__last_canvas_h__ = _ch;
					__reflow__();
				}
			});
		#endregion

		#region Builder Functions
			#region jsDoc
			/// @func    set_region_mode()
			/// @desc    Enables/disables "scroll region" behavior (auto layout + auto-hide scrollbars).
			///          When enabled, this component treats its own width/height as the total region size.
			/// @self    WWViewScrollRegion
			/// @param   {Bool} enabled : Enable scroll region behavior.
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
			/// @param   {Bool} horz_enabled
			/// @param   {Bool} vert_enabled
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
			/// @param   {Bool} horz_auto
			/// @param   {Bool} vert_auto
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_scrollbars_auto_hide = function(_horz_auto=true, _vert_auto=true) {
				scrollbar_horz_auto = _horz_auto;
				scrollbar_vert_auto = _vert_auto;
				__reflow__();
				return self;
			};
			
			#region jsDoc
			/// @func    set_scrollbar_navigable()
			/// @desc    Enables/disables keyboard/controller navigation targeting for scrollbars.
			///          Pointer interaction still works when disabled.
			/// @self    WWViewScrollRegion
			/// @param   {Bool} horz_navigable
			/// @param   {Bool} vert_navigable
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_scrollbar_navigable = function(_horz_navigable=false, _vert_navigable=false) {
				scrollbar_horz_navigable = !!_horz_navigable;
				scrollbar_vert_navigable = !!_vert_navigable;
				__sync_scrollbar_navigable__();
				return self;
			};
			
			#region jsDoc
			/// @func    set_nav_entry_mode()
			/// @desc    Sets how keyboard/controller navigation enters this scroll region.
			///          DIRECT   : children are globally navigable, no activation step.
			///          ACTIVATE : region itself is navigable; submit enters child scope.
			///          NONE     : region content is excluded from keyboard/controller nav.
			/// @self    WWViewScrollRegion
			/// @param   {Real} mode : Value from __WW_SCROLL_NAV_MODE.
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_nav_entry_mode = function(_mode) {
				switch (_mode) {
					case __WW_SCROLL_NAV_MODE.NONE:
					case __WW_SCROLL_NAV_MODE.DIRECT:
					case __WW_SCROLL_NAV_MODE.ACTIVATE:
						__nav_entry_mode__ = _mode;
					break;
					default:
						__nav_entry_mode__ = __WW_SCROLL_NAV_MODE.DIRECT;
					break;
				}
				__sync_nav_entry_mode__();
				return self;
			};
			
			#region jsDoc
			/// @func    set_nav_trap_when_active()
			/// @desc    In ACTIVATE mode, traps next/prev/directional nav inside region scope while active.
			/// @self    WWViewScrollRegion
			/// @param   {Bool} enabled
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_nav_trap_when_active = function(_enabled=true) {
				__nav_trap_when_active__ = !!_enabled;
				return self;
			};
			
			#region jsDoc
			/// @func    set_nav_enter_action()
			/// @desc    Sets which nav action enters an ACTIVATE-mode region.
			/// @self    WWViewScrollRegion
			/// @param   {Real} action : Value from __WW_NAV_ACTION.
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_nav_enter_action = function(_action=__WW_NAV_ACTION.SUBMIT) {
				__nav_enter_action__ = _action;
				return self;
			};
			
			#region jsDoc
			/// @func    set_nav_exit_action()
			/// @desc    Sets which nav action exits an active ACTIVATE-mode region.
			/// @self    WWViewScrollRegion
			/// @param   {Real} action : Value from __WW_NAV_ACTION.
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_nav_exit_action = function(_action=__WW_NAV_ACTION.CANCEL) {
				__nav_exit_action__ = _action;
				return self;
			};
			
			#region jsDoc
			/// @func    set_nav_remember_last_target()
			/// @desc    When enabled, ACTIVATE mode re-enters using the last selected child when possible.
			/// @self    WWViewScrollRegion
			/// @param   {Bool} enabled
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_nav_remember_last_target = function(_enabled=true) {
				__nav_remember_last_target__ = !!_enabled;
				if (!__nav_remember_last_target__) {
					__nav_last_target_id__ = -1;
				}
				return self;
			};

			#region jsDoc
			/// @func    set_scrollbar_thickness()
			/// @desc    Sets the thickness (pixels) of both scrollbars when they are shown.
			/// @self    WWViewScrollRegion
			/// @param   {Real} thickness
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
			/// @param   {Real} pixels_per_wheel
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
			/// @param   {Bool} horz_enabled
			/// @param   {Bool} vert_enabled
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
			/// @param   {Bool} smooth
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_smooth_scrolling = function(_smooth=false) {
				smooth_scrolling = _smooth;
				if (scrollbar_horz != undefined) scrollbar_horz.set_smooth_scrolling(_smooth);
				if (scrollbar_vert != undefined) scrollbar_vert.set_smooth_scrolling(_smooth);
				if (!smooth_scrolling) {
					__smooth_clamp_hold_x__ = false;
					__smooth_clamp_hold_y__ = false;
				}
				__reflow__();
				return self;
			};

			#region jsDoc
			/// @func    set_canvas()
			/// @desc    Assigns the internal view canvas.
			/// @self    WWViewScrollRegion
			/// @param   {Struct.WWCore} canvas
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_canvas = function(_canvas) {
				__canvas__ = _canvas;
				canvas = __canvas__;
				__canvas_auto_resize__ = false;
				if (is_struct(__canvas__)
				&& variable_struct_exists(__canvas__, "set_auto_resize")) {
					var _set_auto_resize = __canvas__.set_auto_resize;
					if (is_callable(_set_auto_resize)) {
						var _bound_set_auto_resize = method(__canvas__, _set_auto_resize);
						_bound_set_auto_resize(true);
						__canvas_auto_resize__ = true;
					}
				}

				__view__.set_canvas(__canvas__);
				__last_canvas_w__ = __canvas__.width;
				__last_canvas_h__ = __canvas__.height;
				__sync_cached_state_from_view__();
				__reflow__();
				return self;
			};


			#region jsDoc
			/// @func    set_canvas_size()
			/// @desc    Sets the content size used for clamping. Pass -1 to auto-size from canvas children.
			/// @self    WWViewScrollRegion
			/// @param   {Real} width
			/// @param   {Real} height
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_canvas_size = function(_width, _height) {
				if (_width == -1 || _height == -1) {
					if (is_struct(__canvas__)
					&& variable_struct_exists(__canvas__, "set_auto_resize")) {
						__canvas__.set_auto_resize(true);
						__canvas_auto_resize__ = true;
					}
					__set_content_size_from_canvas_children__();
					__reflow__();
					return self;
				}

				if (is_struct(__canvas__)
				&& variable_struct_exists(__canvas__, "set_auto_resize")) {
					__canvas__.set_auto_resize(false);
					__canvas_auto_resize__ = false;
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
				if (is_struct(__canvas__)
				&& variable_struct_exists(__canvas__, "set_auto_resize")) {
					__canvas__.set_auto_resize(true);
					__canvas_auto_resize__ = true;
				}
				__set_content_size_from_canvas_children__();
				__reflow__();
				return self;
			};

			#region jsDoc
			/// @func    set_size()
			/// @desc    Sets the total region size (region mode) or viewport size (normal mode).
			/// @self    WWViewScrollRegion
			/// @param   {Real} width
			/// @param   {Real} height
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
			/// @param   {Real} width
			/// @param   {Real} height
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
			/// @param   {Real} xoff
			/// @param   {Real} yoff
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
			/// @param   {Real} dx
			/// @param   {Real} dy
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static scroll_by = function(_dx=0, _dy=0) {
				return set_scroll_offset(scroll_x + _dx, scroll_y + _dy);
			};

			#region jsDoc
			/// @func    set_content_size()
			/// @desc    Sets the content size used for clamping.
			/// @self    WWViewScrollRegion
			/// @param   {Real} width
			/// @param   {Real} height
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_content_size = function(_width, _height) {
				if (is_struct(__canvas__)
				&& variable_struct_exists(__canvas__, "set_auto_resize")) {
					__canvas__.set_auto_resize(false);
					__canvas_auto_resize__ = false;
				}
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
			/// @param   {Real} max_x
			/// @param   {Real} max_y
			/// @returns {Struct.WWViewScrollRegion}
			#endregion
			static set_scroll_max = function(_max_x=0, _max_y=0) {
				if (is_struct(__canvas__)
				&& variable_struct_exists(__canvas__, "set_auto_resize")) {
					__canvas__.set_auto_resize(false);
					__canvas_auto_resize__ = false;
				}
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
			/// @param   {Struct.WWCore|Array} comp
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
			/// @param   {Real|Struct.WWCore|Array} a
			/// @param   {Real|Struct.WWCore|Array} b
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
			/// @param   {Struct.WWCore} comp
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
			/// @func    should_auto_consume_on_nav_target()
			/// @desc    Region header nav-target should not auto-consume typed input.
			/// @self    WWViewScrollRegion
			/// @returns {Bool}
			#endregion
			static should_auto_consume_on_nav_target = function() {
				return false;
			};
			
			#region jsDoc
			/// @func    handle_nav_action()
			/// @desc    Handles ACTIVATE-mode navigation entry/exit and optional in-region nav trapping.
			/// @self    WWViewScrollRegion
			/// @param   {Real} action : __WW_NAV_ACTION.*
			/// @param   {Struct} input
			/// @returns {Undefined}
			#endregion
			static handle_nav_action = function(_action, _input) {
				if (!is_struct(_input) || !is_struct(_input.nav)) return;
				
				var _source = _input.nav.source;
				var _current = nav_get_target();
				var _current_is_content = __is_target_within_content__(_current);
				
				switch (__nav_entry_mode__) {
					case __WW_SCROLL_NAV_MODE.NONE: {
						return;
					}
					
					case __WW_SCROLL_NAV_MODE.DIRECT: {
						return;
					}
					
					case __WW_SCROLL_NAV_MODE.ACTIVATE: {
						if (__nav_active__) {
							if (_action == __nav_exit_action__) {
								if (__deactivate_nav_to_header__(_source)) {
									_input.nav.consumed = true;
								}
								return;
							}
							
							if (_action == __nav_enter_action__) {
								if (!is_struct(_current) || _current.__comp_id__ == __comp_id__) {
									if (__activate_nav_to_content__(_source)) {
										_input.nav.consumed = true;
									}
								}
								return;
							}
							
							if (__nav_trap_when_active__ && __is_nav_direction_action__(_action)) {
								if (__move_nav_within_content__(_action, _source)) {
									_input.nav.consumed = true;
								}
								else {
									_input.nav.consumed = true;
								}
							}
							return;
						}
						
						if (_action == __nav_enter_action__) {
							if (is_struct(_current) && _current.__comp_id__ == __comp_id__) {
								if (__activate_nav_to_content__(_source)) {
									_input.nav.consumed = true;
								}
							}
							return;
						}
						
						if (_current_is_content) {
							if (__deactivate_nav_to_header__(_source)) {
								_input.nav.consumed = true;
							}
						}
						return;
					}
				}
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
			/// @func    get_scrollbar_navigable()
			/// @desc    Returns whether each scrollbar axis is keyboard/controller navigable.
			/// @self    WWViewScrollRegion
			/// @returns {Struct}
			#endregion
			static get_scrollbar_navigable = function() {
				return { horz: scrollbar_horz_navigable, vert: scrollbar_vert_navigable };
			};
			
			#region jsDoc
			/// @func    get_nav_entry_mode()
			/// @desc    Returns the current scroll region nav entry mode.
			/// @self    WWViewScrollRegion
			/// @returns {Real}
			#endregion
			static get_nav_entry_mode = function() {
				return __nav_entry_mode__;
			};
			
			#region jsDoc
			/// @func    get_nav_trap_when_active()
			/// @desc    Returns whether ACTIVATE mode traps next/prev/directional nav inside this region.
			/// @self    WWViewScrollRegion
			/// @returns {Bool}
			#endregion
			static get_nav_trap_when_active = function() {
				return __nav_trap_when_active__;
			};
			
			#region jsDoc
			/// @func    get_nav_enter_action()
			/// @desc    Returns the nav action used to enter an ACTIVATE-mode region.
			/// @self    WWViewScrollRegion
			/// @returns {Real}
			#endregion
			static get_nav_enter_action = function() {
				return __nav_enter_action__;
			};
			
			#region jsDoc
			/// @func    get_nav_exit_action()
			/// @desc    Returns the nav action used to exit an ACTIVATE-mode region.
			/// @self    WWViewScrollRegion
			/// @returns {Real}
			#endregion
			static get_nav_exit_action = function() {
				return __nav_exit_action__;
			};
			
			#region jsDoc
			/// @func    get_nav_remember_last_target()
			/// @desc    Returns whether ACTIVATE mode remembers last selected child target.
			/// @self    WWViewScrollRegion
			/// @returns {Bool}
			#endregion
			static get_nav_remember_last_target = function() {
				return __nav_remember_last_target__;
			};
			
			#region jsDoc
			/// @func    get_nav_active()
			/// @desc    Returns whether ACTIVATE-mode child navigation is currently active.
			/// @self    WWViewScrollRegion
			/// @returns {Bool}
			#endregion
			static get_nav_active = function() {
				return __nav_active__;
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
			/// @self    WWViewScrollRegion
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
			/// @self    WWViewScrollRegion
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __sync_content_size_from_canvas__ = function() {
				if (__canvas__ == undefined) {
					content_width = 0;
					content_height = 0;
					__view__.content_width = 0;
					__view__.content_height = 0;
					__view__.scroll_x = 0;
					__view__.scroll_y = 0;
					__view__.__apply_scroll__();
					return;
				}

				var _cw = __canvas__.width;
				var _ch = __canvas__.height;
				var _size_changed = (_cw != content_width || _ch != content_height);

				var _off = __view__.get_scroll_offset();
				var _sx = variable_struct_get(_off, "x");
				var _sy = variable_struct_get(_off, "y");

				var _vw = __view__.width;
				var _vh = __view__.height;
				var _max_x = max(0, _cw - _vw);
				var _max_y = max(0, _ch - _vh);

				content_width = _cw;
				content_height = _ch;
				__last_canvas_w__ = _cw;
				__last_canvas_h__ = _ch;

				if (_size_changed) {
					if (_sx > _max_x) {
						if (smooth_scrolling && scrollbar_horz != undefined) {
							__smooth_clamp_hold_x__ = true;
							__smooth_clamp_target_x__ = _max_x;
						}
						else {
							__smooth_clamp_hold_x__ = false;
							_sx = _max_x;
						}
					}
					else {
						__smooth_clamp_hold_x__ = false;
					}

					if (_sy > _max_y) {
						if (smooth_scrolling && scrollbar_vert != undefined) {
							__smooth_clamp_hold_y__ = true;
							__smooth_clamp_target_y__ = _max_y;
						}
						else {
							__smooth_clamp_hold_y__ = false;
							_sy = _max_y;
						}
					}
					else {
						__smooth_clamp_hold_y__ = false;
					}
				}

				if (__smooth_clamp_hold_x__) {
					__smooth_clamp_target_x__ = _max_x;
					if (_sx <= (_max_x + __smooth_clamp_epsilon__)) {
						__smooth_clamp_hold_x__ = false;
						_sx = clamp(_sx, 0, _max_x);
					}
				}
				else {
					_sx = clamp(_sx, 0, _max_x);
				}

				if (__smooth_clamp_hold_y__) {
					__smooth_clamp_target_y__ = _max_y;
					if (_sy <= (_max_y + __smooth_clamp_epsilon__)) {
						__smooth_clamp_hold_y__ = false;
						_sy = clamp(_sy, 0, _max_y);
					}
				}
				else {
					_sy = clamp(_sy, 0, _max_y);
				}

				var _effective_max_x = _max_x;
				var _effective_max_y = _max_y;
				if (__smooth_clamp_hold_x__) {
					_effective_max_x = max(_effective_max_x, _sx);
				}
				if (__smooth_clamp_hold_y__) {
					_effective_max_y = max(_effective_max_y, _sy);
				}

				var _effective_w = _vw + _effective_max_x;
				var _effective_h = _vh + _effective_max_y;

				__view__.content_width = _effective_w;
				__view__.content_height = _effective_h;
				__view__.scroll_x = _sx;
				__view__.scroll_y = _sy;
				__view__.__apply_scroll__();
				__sync_cached_state_from_view__();

				if (smooth_scrolling) {
					if (__smooth_clamp_hold_x__ && scrollbar_horz != undefined) {
						scrollbar_horz.set_lerp_target(__smooth_clamp_target_x__);
					}
					if (__smooth_clamp_hold_y__ && scrollbar_vert != undefined) {
						scrollbar_vert.set_lerp_target(__smooth_clamp_target_y__);
					}
				}
			};


			#region jsDoc
			/// @func    __on_scrollbar_horz__()
			/// @desc    Applies the horizontal scrollbar value to the region scroll.
			/// @self    WWViewScrollRegion
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __on_scrollbar_horz__ = function() {
				if (scrollbar_horz == undefined) { return; }
				if (__syncing_scrollbars__) { return; }
				__scroll_sync_source_axis__ = 1;
				set_scroll_offset(scrollbar_horz.get_value(), scroll_y);
				__scroll_sync_source_axis__ = 0;
			};

			#region jsDoc
			/// @func    __on_scrollbar_vert__()
			/// @desc    Applies the vertical scrollbar value to the region scroll.
			/// @self    WWViewScrollRegion
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __on_scrollbar_vert__ = function() {
				if (scrollbar_vert == undefined) { return; }
				if (__syncing_scrollbars__) { return; }
				__scroll_sync_source_axis__ = 2;
				set_scroll_offset(scroll_x, scrollbar_vert.get_value());
				__scroll_sync_source_axis__ = 0;
			};

			#region jsDoc
			/// @func    __set_content_size_from_canvas_children__()
			/// @desc    Updates content size from canvas group bounds.
			/// @self    WWViewScrollRegion
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __set_content_size_from_canvas_children__ = function() {
				__canvas__.__update_group_region__();
				var _w = __canvas__.__group__.width;
				var _h = __canvas__.__group__.height;

				if (__canvas_auto_resize__) {
					__canvas__.__set_size__(_w, _h);
				}
				else {
					__canvas__.set_size(_w, _h);
				}

				__sync_content_size_from_canvas__();
			};
			
			#region jsDoc
			/// @func    __set_subtree_navigable__()
			/// @desc    Applies keyboard/controller navigable state to a component subtree.
			/// @self    WWViewScrollRegion
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __set_subtree_navigable__ = function(_root_comp, _is_navigable) {
				var _stack = [_root_comp];
				while (array_length(_stack) > 0) {
					var _node = array_pop(_stack);
					_node.set_navigable(_is_navigable);
					
					var _child_count = _node.__children_count__;
					if (_child_count > 0) {
						var _stack_len = array_length(_stack);
						array_copy(_stack, _stack_len, _node.__children__, 0, _child_count);
					}
				}
			};
			
			#region jsDoc
			/// @func    __sync_scrollbar_navigable__()
			/// @desc    Applies configured navigable state to attached scrollbar trees.
			/// @self    WWViewScrollRegion
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __sync_scrollbar_navigable__ = function() {
				if (is_struct(scrollbar_horz)) {
					__set_subtree_navigable__(scrollbar_horz, scrollbar_horz_navigable);
				}
				if (is_struct(scrollbar_vert)) {
					__set_subtree_navigable__(scrollbar_vert, scrollbar_vert_navigable);
				}
			};
			
			#region jsDoc
			/// @func    __is_nav_candidate__()
			/// @desc    Returns true when a component qualifies as a nav candidate for region content scope.
			/// @self    WWViewScrollRegion
			/// @returns {Bool}
			/// @ignore
			#endregion
			static __is_nav_candidate__ = function(_comp, _respect_navigable=true) {
				if (!_comp.__is_focusable__) return false;
				if (!_comp.__is_enabled__) return false;
				if (!_comp.__is_active__) return false;
				if (_respect_navigable && !_comp.__is_navigable__) return false;
				if (!_comp.visible) return false;
				return true;
			};
			
			#region jsDoc
			/// @func    __collect_content_candidates__()
			/// @desc    Collects navigable candidates from the region canvas subtree.
			/// @self    WWViewScrollRegion
			/// @returns {Array<Struct.WWCore>}
			/// @ignore
			#endregion
			static __collect_content_candidates__ = function(_respect_navigable=true) {
				var _scope = [];
				if (!is_struct(__canvas__)) return _scope;
				
				var _stack = [__canvas__];
				while (array_length(_stack) > 0) {
					var _node = array_pop(_stack);
					
					if (_node.__comp_id__ != __canvas__.__comp_id__) {
						if (__is_nav_candidate__(_node, _respect_navigable)) {
							array_push(_scope, _node);
						}
					}
					
					var _count = _node.__children_count__;
					if (_count > 0) {
						var _stack_len = array_length(_stack);
						array_copy(_stack, _stack_len, _node.__children__, 0, _count);
					}
				}
				
				return _scope;
			};
			
			#region jsDoc
			/// @func    __scope_index_of__()
			/// @desc    Returns the index of a component id in a scope array.
			/// @self    WWViewScrollRegion
			/// @returns {Real}
			/// @ignore
			#endregion
			static __scope_index_of__ = function(_scope, _comp_id) {
				var _count = array_length(_scope);
				for (var _i=0; _i<_count; _i++) {
					if (_scope[_i].__comp_id__ == _comp_id) return _i;
				}
				return -1;
			};
			
			#region jsDoc
			/// @func    __is_target_within_content__()
			/// @desc    Returns true when target exists in this region's canvas subtree.
			/// @self    WWViewScrollRegion
			/// @returns {Bool}
			/// @ignore
			#endregion
			static __is_target_within_content__ = function(_target) {
				if (!is_struct(_target) || !is_struct(__canvas__)) return false;
				
				var _node = _target;
				repeat (256) {
					if (!is_struct(_node)) return false;
					if (_node.__comp_id__ == __canvas__.__comp_id__) return true;
					if (!variable_struct_exists(_node, "__is_child__") || !_node.__is_child__) return false;
					if (!variable_struct_exists(_node, "__parent__")) return false;
					_node = _node.__parent__;
				}
				
				return false;
			};
			
			#region jsDoc
			/// @func    __remember_current_content_target__()
			/// @desc    Saves the currently targeted content component id for later re-entry.
			/// @self    WWViewScrollRegion
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __remember_current_content_target__ = function() {
				if (!__nav_remember_last_target__) return;
				var _target = nav_get_target();
				if (!__is_target_within_content__(_target)) return;
				__nav_last_target_id__ = _target.__comp_id__;
			};
			
			#region jsDoc
			/// @func    __set_content_locked__()
			/// @desc    Locks/unlocks content subtree from keyboard/controller navigation.
			/// @self    WWViewScrollRegion
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __set_content_locked__ = function(_locked) {
				_locked = !!_locked;
				
				if (_locked) {
					if (__nav_content_locked__) return;
					array_resize(__nav_locked_nodes__, 0);
					
					var _scope = __collect_content_candidates__(false);
					var _count = array_length(_scope);
					for (var _i=0; _i<_count; _i++) {
						var _comp = _scope[_i];
						if (!variable_struct_exists(_comp, "set_navigable")) continue;
						if (variable_struct_exists(_comp, "__is_navigable__") && _comp.__is_navigable__) {
							array_push(__nav_locked_nodes__, _comp);
							_comp.set_navigable(false);
						}
					}
					
					__nav_content_locked__ = true;
					return;
				}
				
				if (!__nav_content_locked__) return;
				
				var _count_nodes = array_length(__nav_locked_nodes__);
				for (var _j=0; _j<_count_nodes; _j++) {
					var _node = __nav_locked_nodes__[_j];
					if (!is_struct(_node)) continue;
					if (!variable_struct_exists(_node, "set_navigable")) continue;
					_node.set_navigable(true);
				}
				array_resize(__nav_locked_nodes__, 0);
				__nav_content_locked__ = false;
			};
			
			#region jsDoc
			/// @func    __set_nav_active__()
			/// @desc    Sets whether ACTIVATE-mode content scope is currently active.
			/// @self    WWViewScrollRegion
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __set_nav_active__ = function(_active) {
				_active = !!_active;
				if (__nav_entry_mode__ != __WW_SCROLL_NAV_MODE.ACTIVATE) {
					_active = false;
				}
				
				__nav_active__ = _active;
				
				if (__nav_entry_mode__ == __WW_SCROLL_NAV_MODE.ACTIVATE) {
					__set_content_locked__(!__nav_active__);
				}
			};
			
			#region jsDoc
			/// @func    __sync_nav_entry_mode__()
			/// @desc    Applies nav entry mode behavior (header targeting + content lock state).
			/// @self    WWViewScrollRegion
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __sync_nav_entry_mode__ = function() {
				switch (__nav_entry_mode__) {
					case __WW_SCROLL_NAV_MODE.NONE: {
						__nav_active__ = false;
						set_focusable(false);
						set_navigable(false);
						__set_content_locked__(true);
					break;}
					
					case __WW_SCROLL_NAV_MODE.DIRECT: {
						__nav_active__ = false;
						set_focusable(false);
						set_navigable(false);
						__set_content_locked__(false);
					break;}
					
					case __WW_SCROLL_NAV_MODE.ACTIVATE: {
						set_focusable(true);
						set_navigable(true);
						__set_nav_active__(__nav_active__);
					break;}
				}
			};
			
			#region jsDoc
			/// @func    __is_nav_direction_action__()
			/// @desc    Returns true when action is a directional/next-prev navigation action.
			/// @self    WWViewScrollRegion
			/// @returns {Bool}
			/// @ignore
			#endregion
			static __is_nav_direction_action__ = function(_action) {
				switch (_action) {
					case __WW_NAV_ACTION.NEXT:
					case __WW_NAV_ACTION.PREV:
					case __WW_NAV_ACTION.LEFT:
					case __WW_NAV_ACTION.RIGHT:
					case __WW_NAV_ACTION.UP:
					case __WW_NAV_ACTION.DOWN:
						return true;
				}
				return false;
			};
			
			#region jsDoc
			/// @func    __action_to_direction__()
			/// @desc    Converts nav action enum to direction string.
			/// @self    WWViewScrollRegion
			/// @returns {String|Undefined}
			/// @ignore
			#endregion
			static __action_to_direction__ = function(_action) {
				switch (_action) {
					case __WW_NAV_ACTION.NEXT: return "next";
					case __WW_NAV_ACTION.PREV: return "prev";
					case __WW_NAV_ACTION.LEFT: return "left";
					case __WW_NAV_ACTION.RIGHT: return "right";
					case __WW_NAV_ACTION.UP: return "up";
					case __WW_NAV_ACTION.DOWN: return "down";
				}
				return undefined;
			};
			
			#region jsDoc
			/// @func    __scope_target_from_direction__()
			/// @desc    Returns next target in local scope for direction/next-prev action.
			/// @self    WWViewScrollRegion
			/// @returns {Struct.WWCore|Undefined}
			/// @ignore
			#endregion
			static __scope_target_from_direction__ = function(_scope, _current_index, _dir) {
				var _count = array_length(_scope);
				if (_count <= 0) return undefined;
				
				var _is_prev_like = (_dir == "prev" || _dir == "left" || _dir == "up");
				if (_current_index < 0 || _current_index >= _count) {
					return _scope[_is_prev_like ? (_count - 1) : 0];
				}
				
				if (_dir == "next") {
					var _ni = _current_index + 1;
					if (_ni >= _count) _ni = 0;
					return _scope[_ni];
				}
				if (_dir == "prev") {
					var _pi = _current_index - 1;
					if (_pi < 0) _pi = _count - 1;
					return _scope[_pi];
				}
				
				var _current = _scope[_current_index];
				var _cx = _current.x + _current.width * 0.5;
				var _cy = _current.y + _current.height * 0.5;
				var _best = noone;
				var _best_score = infinity;
				
				for (var _i=0; _i<_count; _i++) {
					if (_i == _current_index) continue;
					var _candidate = _scope[_i];
					var _tx = _candidate.x + _candidate.width * 0.5;
					var _ty = _candidate.y + _candidate.height * 0.5;
					var _dx = _tx - _cx;
					var _dy = _ty - _cy;
					
					var _primary = 0;
					var _secondary = 0;
					switch (_dir) {
						case "left": {
							_primary = -_dx;
							_secondary = _dy;
						break;}
						case "right": {
							_primary = _dx;
							_secondary = _dy;
						break;}
						case "up": {
							_primary = -_dy;
							_secondary = _dx;
						break;}
						case "down": {
							_primary = _dy;
							_secondary = _dx;
						break;}
					}
					
					if (_primary <= 0) continue;
					var _secondary_abs = abs(_secondary);
					var _score = (_primary * _primary) + (_secondary_abs * _secondary_abs * 4);
					if (_score < _best_score) {
						_best_score = _score;
						_best = _candidate;
					}
				}
				
				if (is_struct(_best)) return _best;
				
				var _fallback_index = _is_prev_like ? (_current_index - 1) : (_current_index + 1);
				if (_fallback_index < 0) _fallback_index = _count - 1;
				if (_fallback_index >= _count) _fallback_index = 0;
				return _scope[_fallback_index];
			};
			
			#region jsDoc
			/// @func    __move_nav_within_content__()
			/// @desc    Moves nav target within content scope for trapped ACTIVATE-mode navigation.
			/// @self    WWViewScrollRegion
			/// @returns {Bool}
			/// @ignore
			#endregion
			static __move_nav_within_content__ = function(_action, _source) {
				var _dir = __action_to_direction__(_action);
				if (is_undefined(_dir)) return false;
				
				var _scope = __collect_content_candidates__(true);
				var _count = array_length(_scope);
				if (_count <= 0) return false;
				
				var _current = nav_get_target();
				var _idx = -1;
				if (is_struct(_current)) {
					_idx = __scope_index_of__(_scope, _current.__comp_id__);
				}
				
				var _target = __scope_target_from_direction__(_scope, _idx, _dir);
				if (!is_struct(_target)) return false;
				
				var _assigned = nav_set_target(_target, false, _source);
				return is_struct(_assigned);
			};
			
			#region jsDoc
			/// @func    __activate_nav_to_content__()
			/// @desc    Activates ACTIVATE-mode child scope and moves target to entry component.
			/// @self    WWViewScrollRegion
			/// @returns {Bool}
			/// @ignore
			#endregion
			static __activate_nav_to_content__ = function(_source) {
				if (__nav_entry_mode__ != __WW_SCROLL_NAV_MODE.ACTIVATE) return false;
				
				__set_nav_active__(true);
				
				var _scope = __collect_content_candidates__(true);
				var _count = array_length(_scope);
				if (_count <= 0) {
					__set_nav_active__(false);
					return false;
				}
				
				var _target = noone;
				if (__nav_remember_last_target__ && __nav_last_target_id__ >= 0) {
					var _idx = __scope_index_of__(_scope, __nav_last_target_id__);
					if (_idx >= 0) _target = _scope[_idx];
				}
				if (!is_struct(_target)) {
					_target = _scope[0];
				}
				
				var _assigned = nav_set_target(_target, false, _source);
				if (is_struct(_assigned)) return true;
				
				__set_nav_active__(false);
				return false;
			};
			
			#region jsDoc
			/// @func    __deactivate_nav_to_header__()
			/// @desc    Deactivates ACTIVATE-mode child scope and retargets region header.
			/// @self    WWViewScrollRegion
			/// @returns {Bool}
			/// @ignore
			#endregion
			static __deactivate_nav_to_header__ = function(_source) {
				if (__nav_entry_mode__ != __WW_SCROLL_NAV_MODE.ACTIVATE) return false;
				
				__remember_current_content_target__();
				__set_nav_active__(false);
				
				var _assigned = nav_set_target(self, false, _source);
				return is_struct(_assigned);
			};

			#region jsDoc
			/// @func    __get_thickness__()
			/// @desc    Returns scrollbar thickness.
			/// @self    WWViewScrollRegion
			/// @returns {Real}
			/// @ignore
			#endregion
			static __get_thickness__ = function() {
				return max(0, scrollbar_thickness);
			};

			#region jsDoc
			/// @func    __sync_scrollbars__()
			/// @desc    Updates scrollbar sizes and values from current content and viewport state.
			/// @self    WWViewScrollRegion
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

				var _bar_canvas_w = content_width;
				var _bar_canvas_h = content_height;
				if (__smooth_clamp_hold_x__) {
					_bar_canvas_w = max(_bar_canvas_w, _cov_w + scroll_x);
				}
				if (__smooth_clamp_hold_y__) {
					_bar_canvas_h = max(_bar_canvas_h, _cov_h + scroll_y);
				}

				// Lazy wire: if you assign scrollbar_horz/scrollbar_vert directly,
				// they will still drive scrolling without needing a set/get wrapper.
				if (scrollbar_horz != undefined) {
					scrollbar_horz.set_callback(method(self, __on_scrollbar_horz__));
					scrollbar_horz.set_smooth_scrolling(smooth_scrolling);
				}
				if (scrollbar_vert != undefined) {
					scrollbar_vert.set_callback(method(self, __on_scrollbar_vert__));
					scrollbar_vert.set_smooth_scrolling(smooth_scrolling);
				}
				__sync_scrollbar_navigable__();

				__syncing_scrollbars__ = true;
				if (scrollbar_horz != undefined) {
					scrollbar_horz.set_canvas_size(_bar_canvas_w);
					scrollbar_horz.set_coverage_size(_cov_w);
					if (!(smooth_scrolling && __scroll_sync_source_axis__ == 1)) {
						scrollbar_horz.set_value(scroll_x);
					}
					if (smooth_scrolling && __smooth_clamp_hold_x__) {
						scrollbar_horz.set_lerp_target(__smooth_clamp_target_x__);
					}
				}
				if (scrollbar_vert != undefined) {
					scrollbar_vert.set_canvas_size(_bar_canvas_h);
					scrollbar_vert.set_coverage_size(_cov_h);
					if (!(smooth_scrolling && __scroll_sync_source_axis__ == 2)) {
						scrollbar_vert.set_value(scroll_y);
					}
					if (smooth_scrolling && __smooth_clamp_hold_y__) {
						scrollbar_vert.set_lerp_target(__smooth_clamp_target_y__);
					}
				}
				__syncing_scrollbars__ = false;
			};

			#region jsDoc
			/// @func    __layout_scrollbars__()
			/// @desc    Sizes/positions scrollbars and applies their active state.
			/// @self    WWViewScrollRegion
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
							// Anchor to bottom edge of this region.
							scrollbar_horz.set_alignment(fa_left, fa_bottom);
							scrollbar_horz.set_offset(0, -_t);
							scrollbar_horz.set_size(viewport_width, _t);
						} else if (_is_child && _parent == __parent__) {
							// Sibling layout: use this region's anchor space and edge offsets.
							// Horizontal bar is anchored to the bottom edge of the region.
							scrollbar_horz.set_alignment(__halign__, __valign__);
							scrollbar_horz.set_offset(x_offset, y_offset + height - _t);
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
							// Anchor to right edge of this region.
							scrollbar_vert.set_alignment(fa_right, fa_top);
							scrollbar_vert.set_offset(-_t, 0);
							scrollbar_vert.set_size(_t, viewport_height);
						} else if (_is_child && _parent == __parent__) {
							// Sibling layout: use this region's anchor space and edge offsets.
							// Vertical bar is anchored to the right edge of the region.
							scrollbar_vert.set_alignment(__halign__, __valign__);
							scrollbar_vert.set_offset(x_offset + width - _t, y_offset);
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
			/// @self    WWViewScrollRegion
			/// @param   {Real} old_x
			/// @param   {Real} old_y
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
			/// @self    WWViewScrollRegion
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
					__sync_nav_entry_mode__();
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
				__sync_nav_entry_mode__();
				__trigger_scroll_events__(_old_x, _old_y);

				__reflowing__ = false;
			};
		#endregion
	#endregion

	// Ensure the internal view starts sized correctly.
	__reflow__();

}

