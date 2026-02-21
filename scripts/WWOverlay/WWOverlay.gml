enum WWOverlayRole {
	WINDOW,
	OVERLAY,
	POPUP,
	DROPDOWN,
	CONTEXT_MENU,
	TOOLTIP,
}

enum WWOverlaySpace {
	GLOBAL_ROOT,
	LOCAL_HOST,
}

#region jsDoc
/// @func    WWOverlay()
/// @desc    Retained overlay component that is hoisted to an overlay manager.
/// @returns {Struct.WWOverlay}
#endregion
function WWOverlay() : WWCore() constructor {
	debug_name = "WWOverlay";
	
	#region Public
		
		#region Builder Functions
		static set_overlay_role = function(_role) {
			__overlay_role__ = _role;
			__overlay_sync_dirty__ = true;
			__overlay_sync__();
			return self;
		}
		
		static set_overlay_priority = function(_priority) {
			__overlay_priority__ = _priority;
			__overlay_sync_dirty__ = true;
			__overlay_sync__();
			return self;
		}
		
		static set_overlay_always_on_top = function(_enabled=true) {
			__overlay_always_on_top__ = _enabled;
			__overlay_sync_dirty__ = true;
			__overlay_sync__();
			return self;
		}
		
		static set_overlay_enabled = function(_enabled=true) {
			__overlay_enabled__ = _enabled;
			__overlay_sync_dirty__ = true;
			__overlay_sync__();
			return self;
		}
		
		static set_overlay_space = function(_space=WWOverlaySpace.GLOBAL_ROOT) {
			__overlay_space__ = _space;
			__overlay_sync_dirty__ = true;
			__overlay_sync__();
			return self;
		}
		
		static set_overlay_host = function(_host=noone) {
			__overlay_host__ = _host;
			__overlay_sync_dirty__ = true;
			__overlay_sync__();
			return self;
		}
		#endregion
		
		#region Functions
		static mouse_on_comp = function(_input=undefined) {
			// Hoisted overlays should not be blocked by parent group hit-tests.
			if (__overlay_registered__) {
				if (is_undefined(_input)) _input = __user_input__;
				var _mx = (!is_undefined(_input.pointer)) ? _input.pointer.x : 0;
				var _my = (!is_undefined(_input.pointer)) ? _input.pointer.y : 0;
				__mouse_on_comp__ = point_in_rectangle(
					_mx,
					_my,
					x,
					y,
					x + width,
					y + height
				);
				return __mouse_on_comp__;
			}
			return __overlay_base_mouse_on_comp__(_input);
		};
		
		static mouse_on_group = function(_input=undefined) {
			// Hoisted overlays should not be blocked by parent group hit-tests.
			if (__overlay_registered__) {
				if (is_undefined(_input)) _input = __user_input__;
				var _mx = (!is_undefined(_input.pointer)) ? _input.pointer.x : 0;
				var _my = (!is_undefined(_input.pointer)) ? _input.pointer.y : 0;
				__mouse_on_group__ = point_in_rectangle(
					_mx,
					_my,
					x,
					y,
					x + __group__.width,
					y + __group__.height
				);
				return __mouse_on_group__;
			}
			return __overlay_base_mouse_on_group__(_input);
		};
		
		// Hoisted overlay events. By default they run WWCore behavior.
		static overlay_step = function(_input=undefined) {
			__overlay_base_step__(_input);
		}
		
		static overlay_draw = function(_input=undefined, _debug=false) {
			__overlay_base_draw__(_input, _debug);
		}
		
		// Keep normal pass as a resilient fallback until registration is valid.
		// Once registered, WWCore skips normal pass and only hoisted pass executes.
		static step = function(_input=undefined) {
			__overlay_sync__();
			if (!__overlay_registered__) {
				overlay_step(_input);
			}
		};
		
		static draw = function(_input=undefined, _debug=false) {
			__overlay_sync__();
			if (!__overlay_registered__) {
				overlay_draw(_input, _debug);
			}
		};
		
		#endregion
		
	#endregion
	
	#region Private
		
		#region Variables
		__overlay_base_mouse_on_comp__ = method(self, WWCore.mouse_on_comp);
		__overlay_base_mouse_on_group__ = method(self, WWCore.mouse_on_group);
		__overlay_base_step__ = method(self, WWCore.step);
		__overlay_base_draw__ = method(self, WWCore.draw);
		__overlay_component__ = true;
		__overlay_enabled__ = true;
		__overlay_role__ = WWOverlayRole.WINDOW;
		__overlay_priority__ = 0;
		__overlay_always_on_top__ = false;
		__overlay_last_focus_time__ = -1;
		__overlay_order_seq__ = 0;
		__overlay_registered__ = false;
		__overlay_sync_dirty__ = true;
		__overlay_space__ = WWOverlaySpace.GLOBAL_ROOT;
		__overlay_host__ = noone;
		__overlay_manager_owner__ = noone;
		#endregion
		
	#endregion
	
}

