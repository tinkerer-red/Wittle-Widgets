#region jsDoc
/// @func    WWWindow()
/// @desc    Overlay window with draggable header, close button, and scrollable content region.
/// @returns {Struct.WWWindow}
#endregion
function WWWindow() : WWOverlay() constructor {
	debug_name = "WWWindow";
	
	#region Public
		
		#region Builder Functions
		static set_size = function(_width, _height) {
			static __base_set_size__ = WWCore.set_size;
			__base_set_size__(_width, _height);
			__refresh_structure__();
			return self;
		}

		static set_title = function(_title) {
			title = string(_title);
			header.set_text(title);
			return self;
		}

		static set_header_height = function(_height) {
			header_height = max(1, _height);
			__refresh_structure__();
			return self;
		}

		static set_draggable = function(_enabled=true) {
			draggable = _enabled;
			return self;
		}

		static set_close_visible = function(_visible=true) {
			close_visible = _visible;
			close_button.set_active(_visible);
			return self;
		}

		static set_close_text = function(_text="X") {
			close_button.set_text(_text);
			__layout_close_button_text__();
			return self;
		}

		static set_open = function(_is_open=true) {
			var _prev = is_open;
			is_open = _is_open;
			if (_prev != _is_open) {
				if (_is_open) {
					trigger_event(events.opened);
				}
				else {
					trigger_event(events.closed);
				}
			}
			set_active(_is_open);
			return self;
		}

		static set_content = function(_comp) {
			content_region.clear_children();
			if (is_struct(_comp)) {
				content_region.add(_comp);
				content_region.set_canvas_size_from_children();
			}
			return self;
		}

		static set_scrollbars_enabled = function(_horz=true, _vert=true) {
			content_region.set_scrollbars_enabled(_horz, _vert);
			return self;
		}

		static set_scrollbars_auto_hide = function(_horz=true, _vert=true) {
			content_region.set_scrollbars_auto_hide(_horz, _vert);
			return self;
		}

		static set_scrollbar_thickness = function(_thickness=16) {
			content_region.set_scrollbar_thickness(_thickness);
			__refresh_structure__();
			return self;
		}

		static set_wheel_scroll_enabled = function(_horz=true, _vert=true) {
			content_region.set_wheel_scroll_enabled(_horz, _vert);
			return self;
		}

		static set_smooth_scrolling = function(_smooth=false) {
			content_region.set_smooth_scrolling(_smooth);
			return self;
		}
		#endregion
		
		#region Variables
		// Initialize required state before any child add/layout can run.
		title = "Window";
		header_height = 20;
		draggable = true;
		close_visible = true;
		is_open = true;
		drag_dx = 0;
		drag_dy = 0;
		__is_dragging__ = false;
		close_button_margin = 3;
		__fa_close_ready__ = false;
		#endregion
		
		var __window_header_bg__ = wwThemeGetColor("colors.surface.control_alt.color");
		var __window_content_bg__ = wwThemeGetColor("colors.surface.panel.color");
		
		#region Components
		header = new WWButtonText()
			.set_text("Window")
			.set_size(width, header_height)
			.set_text_click_offset(undefined);

		close_button = new WWButtonText()
			.set_alignment(fa_right, fa_top)
			.set_size(header_height, header_height)
			.set_offset(-20,0)
			.set_text("X")
			.set_callback(method(self, function() {
				set_open(false);
			}));

		content_region = new WWViewScrollRegion()
			.set_region_mode(true)
			.set_scrollbars_auto_hide(true, true)
			.set_scrollbars_enabled(true, true)
			.set_size(width, max(1, height - header_height))
			.set_offset(0, 20);
		
		static __base_add__ = WWCore.add;
		__base_add__([header, content_region]);
		header.add(close_button);
		
		#endregion

		#region Events
		events.opened = variable_get_hash("opened");
		events.closed = variable_get_hash("closed");
		static on_opened = function(_func) {
			add_event_listener(events.opened, _func);
			return self;
		}
		static on_closed = function(_func) {
			add_event_listener(events.closed, _func);
			return self;
		}
			
		header.on_interact_enter(function(_input) {
			if (!draggable) { return; }
			drag_dx = device_mouse_x_to_gui(0) - x;
			drag_dy = device_mouse_y_to_gui(0) - y;
			bring_to_front();
			__is_dragging__ = true;
		});
		header.on_focus(function(_input) {
			if (!draggable) { return; }
			if (__is_dragging__) {
				var _new_x = device_mouse_x_to_gui(0) - drag_dx;
				var _new_y = device_mouse_y_to_gui(0) - drag_dy;
				if (__is_child__) {
					set_offset(_new_x - __parent__.x, _new_y - __parent__.y);
				}
				else {
					set_offset(_new_x, _new_y);
				}
			}
		});
		header.on_interact_exit(function(_input) {
			if (!draggable) { return; }
			__is_dragging__ = false;
		});
		
		#endregion
		
		#region Functions
		static add = function(_comp) {
			var _result = content_region.add(_comp);
			content_region.set_canvas_size_from_children();
			return _result;
		}

		static insert = function(_a, _b) {
			var _result = content_region.insert(_a, _b);
			content_region.set_canvas_size_from_children();
			return _result;
		}

		static remove = function(_comp) {
			if (_comp == header || _comp == content_region) {
				static __base_remove__ = WWCore.remove;
				__base_remove__(_comp);
				return;
			}
			content_region.remove(_comp);
			content_region.set_canvas_size_from_children();
		}

		static clear_children = function() {
			content_region.clear_children();
			content_region.set_canvas_size_from_children();
			return self;
		}
		
		static center = function(_gui_w=1280, _gui_h=720) {
			set_offset(floor((_gui_w - width) * 0.5), floor((_gui_h - height) * 0.5));
			return self;
		}

		static get_title = function() { return title; };
		static get_header_height = function() { return header_height; };
		static get_draggable = function() { return draggable; };
		static get_close_visible = function() { return close_visible; };
		static get_open = function() { return is_open; };
		static get_header = function() { return header; };
		static get_close_button = function() { return close_button; };
		static get_content_region = function() { return content_region; };
		static get_canvas = function() { return content_region.get_canvas(); };
		#endregion

	#endregion

	#region Private
		
		#region Functions
		static __compute_fa_ready__ = function() {
			if (!WW_FONT_AWESOME_ENABLED) return false;
			var _has_proc = asset_get_index("WWTextProcessorBBCode") != -1;
			var _has_fa_icon_get = asset_get_index("fa_icon_get") != -1;
			var _has_fa_get_font = asset_get_index("fa_get_font") != -1;
			var _has_fa_get_ord = asset_get_index("fa_get_ord") != -1;
			var _fa_font_asset = asset_get_index("fnt_fa_solid");
			var _has_fa_font = (_fa_font_asset != -1) && font_exists(_fa_font_asset);
			return _has_proc && _has_fa_icon_get && _has_fa_get_font && _has_fa_get_ord && _has_fa_font;
		};
		
		static __configure_close_button_icon__ = function() {
			if (__fa_close_ready__) {
				close_button
					.set_text_processor("bbcode")
					.set_text("[fa,xmark,solid]");
			}
			else {
				close_button
					.set_text_processor(undefined)
					.set_text("X");
			}
		};
		
		static __refresh_structure__ = function() {
			if (!is_struct(header) || !is_struct(content_region)) return;
			header.set_size(width, header_height);
			//close_button.set_offset(-close_button_margin-close_button.width, -close_button.width/2);
			//__layout_close_button_text__();
			//
			content_region.set_offset(0, header_height);
			content_region.set_size(width, max(1, height - header_height));
		}
		
		static __layout_close_button_text__ = function() {
			//if (!is_struct(close_button)) return;
			//if (!variable_struct_exists(close_button, "text_component")) return;
			//var _txt = close_button.text_component;
			//if (!is_struct(_txt)) return;
			//
			//var _x = floor((close_button.width - _txt.width) * 0.5);
			//var _y = floor((close_button.height - _txt.height) * 0.5);
			//close_button.set_text_offsets(_x, _y, _y + 1);
		}
		
		#endregion
		
	#endregion

	set_overlay_role(WWOverlayRole.WINDOW);
	__fa_close_ready__ = __compute_fa_ready__();
	__configure_close_button_icon__();
	set_size(320, 240);
	set_title("Window");
	__refresh_structure__();
	__layout_close_button_text__();
	__refresh_structure__();
	
}
