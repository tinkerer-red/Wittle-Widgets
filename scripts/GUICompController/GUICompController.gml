#region jsDoc
/// @func    GUICompController()
/// @desc    This is the root most component for components which can hold children. You can use this to group multiple components together under one component. Use this if you're creating a new component which can store children.
/// @param   {Real} x : The x possition of the component on screen.
/// @param   {Real} y : The y possition of the component on screen.
/// @returns {Struct.GUICompController}
#endregion
function GUICompController() : GUICompCore() constructor {
	debug_name = "GUICompController";
	
	static draw_debug = function() {
		if (!should_draw_debug) return;
		
		draw_set_color(c_orange)
		draw_rectangle(
				x+__group_region__.left,
				y+__group_region__.top,
				x+__group_region__.right,
				y+__group_region__.bottom,
				true
		);
		draw_set_color(c_yellow)
		draw_rectangle(
				x+region.left,
				y+region.top,
				x+region.right,
				y+region.bottom,
				true
		);
				
	}
	
	#region Public
		
		#region Functions
			
			#region jsDoc
			/// @func    mouse_on_comp()
			/// @desc    Checks to see if the mouse is currently on the component. Used for optimization when hundreds of components are available.
			/// @self    GUICompController
			/// @returns {Bool}
			#endregion
			static mouse_on_comp = function() {
				//check if parent even has a mouse over it
				if (__is_child__)
				&& (!__parent__.__mouse_on_comp__) {
					return false;
				}
				
				if (__mouse_on_comp__) {
					var _r = point_in_rectangle(
							device_mouse_x_to_gui(0),
							device_mouse_y_to_gui(0),
							x-region.left,
							y-region.top,
							x+region.right,
							y+region.bottom
					);
					
					if (_r) {
						trigger_event(self.events.on_hover);
					}
					
					return _r;
				}
				
				return false;
			}
			
			#region jsDoc
			/// @func    adopt_builder_functions()
			/// @desc    Adopts a specific component's builder functions, This is primarily used when a conponent controller is basically a single component which happens to have children, For instance the Folder component is simply a button which has children.
			/// @self    GUICompController
			/// @param   {type} name : desc
			/// @returns {type}
			#endregion
			static adopt_builder_functions = function(_comp) {
				var _arr = _comp.get_builder_functions();
				
				//var _key;
				var _i=0; repeat(array_length(_arr)) {
					//_key = _arr[_i];
					var _hash = variable_get_hash(_arr[_i]);
					var _func = struct_get_from_hash(_comp, _hash);
					
					struct_set_from_hash(self, _hash, method(self, _func));
					
					if (struct_get_from_hash(self, _hash) = undefined) {
						show_debug_message(":: Wittle Widgets :: Component <"+debug_name+"> builder function <"+_key+"> replaced with adopted builder function from <"+_comp.debug_name+">.")
					}
				_i+=1;}//end repeat loop
			}
			
		#endregion
		
	#endregion
	
	#region Private
		
		#region Functions
			
			
		#endregion
		
	#endregion
	
}