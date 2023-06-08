#region jsDoc
/// @func    GUICompHandler()
/// @desc    This is the top most component for a GUI. This handles all sub components and running them, This should be initialized inside an object and all events should be declared in the object's native GML events.
/// @param   {Real} x : The x possition of the component on screen.
/// @param   {Real} y : The y possition of the component on screen.
/// @returns {Struct.GUICompHandler}
#endregion
function GUICompHandler() : GUICompController() constructor {
	debug_name = "GUICompHandler";
	
	#region Init
		set_region(0,0,display_get_gui_width(), display_get_gui_height());
	#endregion
	
	#region Public
		
		#region Functions
			
			#region GML Events
				
				#region jsDoc
				/// @func    begin_step()
				/// @desc    Internal function to help Emulate the GML equivalant event.
				/// @self    GUICompHandler
				/// @ignore
				#endregion
				static begin_step = function(_input) {
					__trigger_event__(self.events.pre_update);
					
					set_region(0,0,display_get_gui_width(), display_get_gui_height());
					__update_controller_region__();
					update_component_positions();
		
					var _x=x;
					var _y=y;
		
					//run the children
					var _component, xx, yy;
					var _i=__children_count__; repeat(__children_count__) { _i--;
						_component = __children__[_i];
						//xx = _component.x - (x-_x);
						//yy = _component.y - (y-_y);
						_component.__begin_step__(_input);
					}//end repeat loop
				}
				#region jsDoc
				/// @func    step()
				/// @desc    Internal function to help Emulate the GML equivalant event.
				/// @self    GUICompHandler
				/// @ignore
				#endregion
				static step = function(_input) {
					var _x=x;
					var _y=y;
		
					//run the children
					var _component, xx, yy;
					var _i=__children_count__; repeat(__children_count__) { _i--;
						_component = __children__[_i];
						//xx = _component.x - (x-_x);
						//yy = _component.y - (y-_y);
						_component.__step__(_input);
					}//end repeat loop
		
				}
				#region jsDoc
				/// @func    end_step()
				/// @desc    Internal function to help Emulate the GML equivalant event.
				/// @self    GUICompHandler
				/// @ignore
				#endregion
				static end_step = function(_input) {
					var _x=x;
					var _y=y;
		
					//run the children
					var _component, xx, yy;
					var _i=__children_count__; repeat(__children_count__) { _i--;
						_component = __children__[_i];
						//xx = _component.x - (x-_x);
						//yy = _component.y - (y-_y);
						_component.__end_step__(_input);
					}//end repeat loop
					
					__trigger_event__(self.events.post_update);
				}
				
				#region jsDoc
				/// @func    draw_gui_begin()
				/// @desc    Internal function to help Emulate the GML equivalant event.
				/// @self    GUICompHandler
				/// @ignore
				#endregion
				static draw_gui_begin = function(_input) {
					set_region(0,0,display_get_gui_width(), display_get_gui_height());
					__update_controller_region__();
					update_component_positions();
		
					var _x=x;
					var _y=y;
		
					//run the children
					var _component, xx, yy;
					var _i=0; repeat(__children_count__) {
						_component = __children__[_i];
						//xx = _component.x - (x-_x);
						//yy = _component.y - (y-_y);
						_component.__draw_gui_begin__(_input);
					_i++;}//end repeat loop
		
				}
				#region jsDoc
				/// @func    draw_gui()
				/// @desc    Internal function to help Emulate the GML equivalant event.
				/// @self    GUICompHandler
				/// @ignore
				#endregion
				static draw_gui = function(_input) {
					var _x=x;
					var _y=y;
		
					//run the children
					var _component, xx, yy;
					var _i=0; repeat(__children_count__) {
						_component = __children__[_i];
						//xx = _component.x - (x-_x);
						//yy = _component.y - (y-_y);
						_component.__draw_gui__(_input);
					_i++;}//end repeat loop
		
				}
				#region jsDoc
				/// @func    draw_gui_end()
				/// @desc    Internal function to help Emulate the GML equivalant event.
				/// @self    GUICompHandler
				/// @ignore
				#endregion
				static draw_gui_end = function(_input) {
					var _x=x;
					var _y=y;
		
					//run the children
					var _component, xx, yy;
					var _i=0; repeat(__children_count__) {
						_component = __children__[_i];
						//xx = _component.x - (x-_x);
						//yy = _component.y - (y-_y);
						_component.__draw_gui_end__(_input);
					_i++;}//end repeat loop
					
				}
				
				#region jsDoc
				/// @func    cleanup()
				/// @desc    Internal function to help Emulate the GML equivalant event.
				/// @self    GUICompHandler
				#endregion
				static cleanup = function() {
					if(!__is_empty__){
						var _i=0; repeat(__children_count__) {
				
							var _component = __children__[_i];
							_component.__cleanup__();
							delete _component;
				
						_i++;}//end repeat loop
			
					}
				}
				
			#endregion
			
		#endregion
		
	#endregion
	
	#region Private
		
		#region Variables
			
			//this must always be here to ensure the global controller knows to always return true
			__mouse_on_cc__ = true;
			
		#endregion
		
		#region Functions
			
			static __mouse_on_controller__ = function() {
				return __mouse_on_cc__;
			}
			
			static __update_controller_region__ = function() {
				//this is a global component controller, so anything placed directly into it should always be active
				//usually internally used to detect if the mouse is anywhere over a folder or window, helps with early outing collission checks
				__controller_region__ = new __region__(
					0,
					0,
					display_get_gui_width(),
					display_get_gui_height()
				)
			}
			
			#region jsDoc
			/// @func    __collect_input__()
			/// @desc    This gernerates a new struct reference based off the __default_user_input__ struct
			/// @param   {Real} x : The x possition of the component on screen.
			/// @param   {Real} y : The y possition of the component on screen.
			/// @returns {Struct}
			#endregion
			static __collect_input__ = function() {
				var _names = variable_struct_get_names(__default_user_input__);
				var _size = array_length(_names);
				var _key, _val;
			
				var _i=0; repeat(_size) {
					_key = _names[_i];
					__user_input__[$ _key] = __default_user_input__[$ _key];
				_i+=1;}//end repeat loop
			
				return __user_input__;
			}
			
		#endregion
		
		__update_controller_region__();
		
	#endregion
	
}