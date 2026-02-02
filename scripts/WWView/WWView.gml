#region jsDoc
/// @func    WWView()
/// @desc    A viewport component that acts as a container for a scrollable canvas.
///          This prevents interaction with elements outside the visible region.
/// @returns {Struct.WWView}
#endregion
function WWView() : WWCore() constructor {
	debug_name = "WWView";
	
	#region Public
		
		#region Builder Functions

			#region jsDoc
			/// @func    set_canvas()
			/// @desc    Assigns the scrollable canvas component displayed inside the viewport.
			/// @self    WWView
			/// @param   {Struct.WWCore} canvas : Canvas component to mount into the viewport.
			/// @returns {Struct.WWView}
			#endregion
			static set_canvas = function(_canvas) {
				if (canvas) {
					remove(canvas);
				}
				canvas = _canvas;
				
				if (!canvas.__position_set__) {
					canvas.set_offset(0,0)
				}
				
				add(canvas);
				return self;
			}

		#endregion
		
		#region Components
			
			canvas = undefined;

		#endregion
		
		#region Events
			
			#region jsDoc
			/// @func    on_pre_draw()
			/// @desc    Applies the scissor clipping region before drawing.
			/// @self    WWView
			/// @returns {Undefined}
			#endregion
			on_pre_draw(function() {
				__apply_clipping_region__();
			});

			#region jsDoc
			/// @func    on_post_draw()
			/// @desc    Restores the previous scissor clipping region after drawing.
			/// @self    WWView
			/// @returns {Undefined}
			#endregion
			on_post_draw(function() {
				__restore_clipping_region__();
			});
			
		#endregion
		
		#region Variables
			
			previous_scissor = undefined;
			
		#endregion
		
		#region Functions
			
			#region jsDoc
			/// @func    get_canvas()
			/// @desc    Returns the currently assigned canvas component.
			/// @self    WWView
			/// @returns {Struct.WWCore} canvas_component_or_undefined
			#endregion
			static get_canvas = function() {
				return canvas;
			};
			#region jsDoc
			/// @func    mouse_on_comp()
			/// @desc    Returns true if the mouse is inside this viewport's bounds.
			/// @self    WWView
			/// @returns {Bool}
			#endregion
			static mouse_on_comp = function() {
				//check if parent even has a mouse over it
				if (__is_child__) {
					if (!__parent__.__mouse_on_group__) {
						return false;
					}
				}
				
				__mouse_on_comp__ = point_in_rectangle(
					device_mouse_x_to_gui(0),
					device_mouse_y_to_gui(0),
					x,
					y,
					x+width,
					y+height
				)
				
				if (__mouse_on_comp__) {
					trigger_event(self.events.mouse_over);
				}
				else {
					trigger_event(self.events.mouse_off);
				}
				
				return __mouse_on_comp__;
			}
			#region jsDoc
			/// @func    mouse_on_group()
			/// @desc    Returns true if the mouse is inside this viewport's group bounds.
			/// @self    WWView
			/// @returns {Bool}
			#endregion
			static mouse_on_group = function() {
				//check if parent even has a mouse over it
				if (__is_child__) {
					if (!__parent__.__mouse_on_group__) {
						return false;
					}
				}
				
				__mouse_on_group__ = point_in_rectangle(
						device_mouse_x_to_gui(0),
						device_mouse_y_to_gui(0),
						x,
						y,
						x+width,
						y+height
				);
				
				if (__mouse_on_group__) {
					trigger_event(self.events.mouse_over_group);
				}
				else {
					trigger_event(self.events.mouse_off_group);
				}
				
				return __mouse_on_group__;
			}
			
		#endregion
		
	#endregion
	
	#region Private
		
		#region Variables
			
		#endregion
		
		#region Functions
			
			#region jsDoc
			/// @func    __update_group_region__()
			/// @desc    Updates this viewport's cached group bounds used for collision early-outs.
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __update_group_region__ = function() {
				__group__.width  = x+width;
				__group__.height = y+height;
				
			}
			
		#endregion
		
	#endregion
	
	
}
