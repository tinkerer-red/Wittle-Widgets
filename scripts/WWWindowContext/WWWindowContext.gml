#region jsDoc
/// @func    WWWindowContext()
/// @desc    Lightweight context popup window. Anchored or absolute open, optional auto-close.
/// @returns {Struct.WWWindowContext}
#endregion
function WWWindowContext() : WWWindow() constructor {
	debug_name = "WWWindowContext";
	
	#region Public
		
		#region Builder Functions
		static set_auto_close_outside = function(_enabled=true) {
			auto_close_outside = _enabled;
			return self;
		};
		
		static set_auto_close_escape = function(_enabled=true) {
			auto_close_escape = _enabled;
			return self;
		};
		
		static set_anchor = function(_host=noone, _xoff=0, _yoff=0) {
			anchor_host = _host;
			anchor_xoff = _xoff;
			anchor_yoff = _yoff;
			return self;
		};
		
		static set_keep_on_screen = function(_enabled=true) {
			keep_on_screen = _enabled;
			return self;
		};
		#endregion
		
		#region Variables
		auto_close_outside = true;
		auto_close_escape = true;
		keep_on_screen = true;
		anchor_host = noone;
		anchor_xoff = 0;
		anchor_yoff = 0;
		ignore_outside_click_once = false;
		#endregion
		
		#region Functions
		static open_at = function(_x, _y) {
			if (__is_child__) {
				set_offset(_x - __parent__.x, _y - __parent__.y);
			}
			else {
				set_offset(_x, _y);
			}
			__clamp_to_gui__();
			set_open(true);
			bring_to_front();
			ignore_outside_click_once = (!is_undefined(__user_input__) && !is_undefined(__user_input__.pointer)) && (__user_input__.pointer.left.down || __user_input__.pointer.right.down);
			return self;
		};
		
		static open_anchored = function(_host=anchor_host, _xoff=anchor_xoff, _yoff=anchor_yoff) {
			if (is_undefined(_host) || _host == noone) return self;
			anchor_host = _host;
			anchor_xoff = _xoff;
			anchor_yoff = _yoff;
			
			var _x = _host.x + _xoff;
			var _y = _host.y + _host.height + _yoff;
			return open_at(_x, _y);
		};
		
		static close_context = function() {
			set_open(false);
			return self;
		};
		
		static get_auto_close_outside = function() { return auto_close_outside; };
		static get_auto_close_escape = function() { return auto_close_escape; };
		static get_keep_on_screen = function() { return keep_on_screen; };
		static get_anchor_host = function() { return anchor_host; };
		static get_anchor_xoff = function() { return anchor_xoff; };
		static get_anchor_yoff = function() { return anchor_yoff; };
		
		static overlay_step = function(_input=undefined) {
			__base_overlay_step__(_input);
			if (is_undefined(_input)) _input = __user_input__;
			if (!is_open) return;
			
			if (keep_on_screen) {
				__clamp_to_gui__();
			}
			
			if (ignore_outside_click_once) {
				if (!_input.pointer.left.down && !_input.pointer.right.down) {
					ignore_outside_click_once = false;
				}
				return;
			}
			
			if (auto_close_escape && _input.keyboard.key_pressed(vk_escape)) {
				set_open(false);
				return;
			}
			
			if (auto_close_outside) {
				var _pressed = _input.pointer.left.pressed || _input.pointer.right.pressed;
				if (_pressed && !mouse_on_group(_input)) {
					set_open(false);
				}
			}
		};
		#endregion
		
	#endregion
	
	#region Private
		#region Variables
		__base_overlay_step__ = method(self, WWOverlay.overlay_step);
		#endregion
		
		#region Functions
		static __clamp_to_gui__ = function() {
			if (!keep_on_screen) return;
			var _gw = max(1, display_get_gui_width());
			var _gh = max(1, display_get_gui_height());
			var _nx = clamp(x, 0, max(0, _gw - width));
			var _ny = clamp(y, 0, max(0, _gh - height));
			if (__is_child__) {
				set_offset(_nx - __parent__.x, _ny - __parent__.y);
			}
			else {
				set_offset(_nx, _ny);
			}
		};
		#endregion
	#endregion
	
	set_overlay_role(WWOverlayRole.POPUP);
	set_size(280, 180);
	set_title("Context");
	set_close_visible(false);
	set_scrollbars_enabled(false, false);
	set_open(false);
}

