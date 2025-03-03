#region jsDoc
/// @func    WWViewport()
/// @desc    A viewport component that acts as a container for a scrollable canvas.
///          This prevents interaction with elements outside the visible region.
/// @returns {Struct.WWViewport}
#endregion
function WWViewport() : WWCore() constructor {
	debug_name = "WWViewport";
	
	#region Public
		
		#region Builder Functions

			#region jsDoc
			/// @func    set_canvas()
			/// @desc    Assigns a canvas to the viewport, defining the scrollable content.
			/// @self    WWViewport
			/// @param   {Struct} _canvas : The canvas object to be displayed inside the viewport.
			/// @returns {Struct.WWViewport}
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
			/// @self    WWViewport
			/// @returns {Undefined}
			#endregion
			on_pre_draw(function() {
				__apply_clipping_region__();
			});

			#region jsDoc
			/// @func    on_post_draw()
			/// @desc    Restores the previous scissor clipping region after drawing.
			/// @self    WWViewport
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
			/// @func    mouse_on_comp()
			/// @desc    Checks to see if the mouse is currently on the component. Used for optimization when hundreds of components are available.
			/// @self    WWCore
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
					x+region.left,
					y+region.top,
					x+region.right,
					y+region.bottom
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
			/// @desc    This function is internally used to help assist early outing collision checks.
			/// @self    WWController
			/// @returns {Bool}
			/// @ignore
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
						x+region.left,
						y+region.top,
						x+region.right,
						y+region.bottom
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
			/// @desc    This function is internally used to help assist updating the bounding box of controllers. This bounding box is used for many things but primarily used for collision check optimizations.
			/// @self    WWController
			/// @param   {Real} index : The index of the component to remove.
			/// @returns {Struct.WWController}
			/// @ignore
			#endregion
			static __update_group_region__ = function() {
				__group_region__.left   = region.left;
				__group_region__.top    = region.top;
				__group_region__.right  = region.right;
				__group_region__.bottom = region.bottom;
				
			}
			
		#endregion
		
	#endregion
	
	
}
