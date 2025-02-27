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
				x+__controller_region__.left,
				y+__controller_region__.top,
				x+__controller_region__.right,
				y+__controller_region__.bottom,
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
		
		#region Builder Functions
			
			#region jsDoc
			/// @func    set_region()
			/// @desc    Set the reletive region for all click selections. Reletive to the x,y of the component.
			/// @self    GUICompCore
			/// @param   {real} left : The left side of the bounding box
			/// @param   {real} top : The top side of the bounding box
			/// @param   {real} right : The right side of the bounding box
			/// @param   {real} bottom : The bottom side of the bounding box
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_region = function(_left, _top, _right, _bottom) {
				static __set_region = GUICompCore.set_region;
				__set_region(_left, _top, _right, _bottom);
				
				__update_controller_region__();
				
				return self;
			}
			
			#region jsDoc
			/// @func    set_enabled()
			/// @desc    Enable or Disable the Component, and all sub components. This usually effects how some components are handled.
			/// @self    GUICompController
			/// @param   {Bool} is_enabled : If the component and all sub components should be enabled or not.
			/// @returns {Struct.GUICompController}
			#endregion
			static set_enabled = function(_is_enabled) {
				is_enabled = _is_enabled;
				
				if (!__is_empty__) {
					var _comp;
					var _i=0; repeat(__children_count__) {
						_comp = __children__[_i];
						_comp.set_enabled(_is_enabled);
					_i+=1;}//end repeat loop
				}
				
				if (is_enabled) {
					__trigger_event__(self.events.enabled);
				}
				else {
					__trigger_event__(self.events.disabled);
				}
				
				return self;
			}
			
		#endregion
		
		#region Events
			
			self.events.on_hover_controller = variable_get_hash("on_hover_controller"); //triggered every frame the mouse is over the controller region bounding box, This will be a square box encapsulating all sub components.
			
		#endregion
		
		#region Variables
			__children__ = [];
		#endregion
		
		#region Functions
			#region jsDoc
			/// @func    add()
			/// @desc    Add a Component to the controller.
			/// @self    GUICompController
			/// @param   {Struct.GUICompCore|Array} comp : The component you wish to add to the controller.
			/// @returns {Undefined}
			#endregion
			static add = function(_comp) {
				__is_empty__ = false;
				
				var _arr = (is_array(_comp)) ? _comp : [_comp];
				
				__validate_component_additions__(_arr);
				
				__validate_component_positions__(_arr)
				
				__include_children__(_arr, -1);
				
				update_component_positions();
				
				__update_controller_region__();
				
			}
			#region jsDoc
			/// @func    insert()
			/// @desc    Inserts a Component into the controller's children array.
			/// @self    GUICompController
			/// @param   {Real} index : The index (possition) you wish to insert the component into the children array
			/// @param   {Struct.GUICompCore|Array} comp : The component you wish to add to the controller.
			/// @returns {Undefined}
			#endregion
			static insert = function(_index, _comp) {
				__is_empty__ = false;
				
				var _arr = (is_array(_comp)) ? _comp : [_comp];
				
				__validate_component_additions__(_arr);
				
				__include_children__(_comp, _index)
				
				__update_controller_region__();
				
				return __children_count__;
			}
			#region jsDoc
			/// @func    remove()
			/// @desc    Remove a Component from the controller's children array. Removal is done at the next event automatically and is not instantaneous.
			/// @self    GUICompController
			/// @param   {Real} index : The index of the component you wish to remove from the controller's children array.
			/// @returns {Undefined}
			#endregion
			static remove = function(_index) {
				array_push(__remove_requests__, _index);
			}
			
			#region jsDoc
			/// @func    find()
			/// @desc    Find the index of the given component. Will return -1 if the component was not found.
			/// @self    GUICompController
			/// @param   {Struct.GUICompController} component : The component you wish to find the index of.
			/// @returns {Real}
			#endregion
			static find = function(_comp) {
				//Find it in the list
				var _i = 0; repeat(__children_count__) {
					if (__children__[_i].__cid__ == _comp.__cid__) {
						return _i;
					}
				_i+=1;}//end repeat loop
				return -1;
			}
			
			#region jsDoc
			/// @func    update_component_positions()
			/// @desc    Updates the locations of the children
			/// @self    GUICompHandler
			/// @returns {Real}
			#endregion
			static update_component_positions = function() {
				if (!__is_empty__) {
					var _anchor_point, _comp, _xx, _yy;
					
					//move the children
					var _i=0; repeat(__children_count__) {
						_comp = __children__[_i];
						
						_xx = __get_controller_archor_x__(_comp.halign);
						_yy = __get_controller_archor_y__(_comp.valign);
						
						_comp.x = self.x + _xx + _comp.x_anchor + _comp.__internal_x__;
						_comp.y = self.y + _yy + _comp.y_anchor + _comp.__internal_y__;
						
						//if the component is a controller it's self have it update it's children
						if (_comp.__is_controller__) {
							_comp.update_component_positions();
						}
					_i+=1;}//end repeat loop
					
				}
			}
			
			#region jsDoc
			/// @func    children_count()
			/// @desc    Returns the number of children this component directly controls. This will not include children of children.
			/// @self    GUICompController
			/// @returns {Real}
			#endregion
			static children_count = function() {
				return __children_count__;
			}
			
			#region jsDoc
			/// @func    children_count_all()
			/// @desc    Returns the number of all children. This will include all children of children.
			/// @self    GUICompController
			/// @returns {Real}
			#endregion
			static children_count_all = function() {
				var _comp;
				var _children_count = 0;
				
				var _i=0; repeat(__children_count__) {
					_comp = __children__
					if (_comp.__is_controller__) {
						_children_count += children_count_all();
					}
					else {
						_children_count+=1;
					}
				_i+=1;}//end repeat loop
				
				return _children_count;
			}
			
			#region jsDoc
			/// @func    clear_children()
			/// @desc    Clears all children from the children array, deleting their structs and running their cleanup events. Use this when you are deleting components.
			/// @self    GUICompController
			/// @returns {Undefined}
			#endregion
			static clear_children = function() {
				var _i=0; repeat(__children_count__) {
					__children__[_i].__cleanup__();
					delete __children__[_i]
				_i+=1;}//end repeat loop
				array_delete(__children__, 0, __children_count__);
				__children_count__ = 0;
				__is_empty__ = true;
			}
			
			#region jsDoc
			/// @func    get_children()
			/// @desc    Returns an array of the children
			/// @self    GUICompController
			/// @returns {Array<Struct>}
			#endregion
			static get_children = function() {
				return __children__
			}
			
			#region jsDoc
			/// @func    mouse_on_comp()
			/// @desc    Checks to see if the mouse is currently on the component. Used for optimization when hundreds of components are available.
			/// @self    GUICompController
			/// @returns {Bool}
			#endregion
			static mouse_on_comp = function() {
				//check if parent even has a mouse over it
				if (__is_child__)
				&& (!__parent__.__mouse_on_cc__) {
					return false;
				}
				
				//check to see if the mouse is out of the window it's self
				//static is_desktop = (os_type == os_windows || os_type == os_macosx || os_type == os_linux)
				//if (is_desktop) {
				//	if (window_mouse_get_x() != display_mouse_get_x() - window_get_x())
				//	|| (window_mouse_get_y() != display_mouse_get_y() - window_get_y()) {
				//		__mouse_on_cc__ = false;
				//		return false;
				//	}
				//}
				
				if (__mouse_on_cc__) {
					var _r = point_in_rectangle(
							device_mouse_x_to_gui(0),
							device_mouse_y_to_gui(0),
							x-region.left,
							y-region.top,
							x+region.right,
							y+region.bottom
					);
					
					if (_r) {
						__trigger_event__(self.events.on_hover);
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
		
		#region Variables
			
			__children__ = [];
			__children_count__ = 0;
			__is_empty__ = true;
			
			__is_controller__ = true;
			__parent__ = noone;
			
			__remove_requests__ = []; //used to prevent components from deleting them selves while they are running
			
			__mouse_on_cc__ = false; // used for sub components to skip aditional secondary point in rect check
			__controller_region__ = new __region__(); // used for component controllers to know the bounds of all children and self
			
		#endregion
		
		#region Functions
			
			#region jsDoc
			/// @func    __remove__()
			/// @desc    This function is responsable for actually deleting the component from the children.
			/// @self    GUICompController
			/// @param   {Real} index : The index of the component to remove.
			/// @ignore
			#endregion
			static __remove__ = function(_index) {
				//clean up the component
				__children__[_index].__cleanup__();
				delete __children__[_index];
				
				//remove the component
				array_delete(__children__, _index, 1);
				__children_count__--;
				
				update_component_positions();
				__update_controller_region__();
				if (__children_count__ == 0) {__is_empty__ = true; };
			}
			
			#region jsDoc
			/// @func    __post_remove__()
			/// @desc    Internally used function to handle proper deletion of objects. This function runs at the begining of step and draw events to ensure deleting an object which isnt actively being referenced.
			/// @self    GUICompController
			/// @ignore
			#endregion
			static __post_remove__ = function() {
				//sort the array to contain the largest numbers first, as we will be cycling from back to front
				array_sort(__remove_requests__, true)
		
				var _size = array_length(__remove_requests__);
				var _index;
				var _i=_size; repeat(_size) {_i--;
					__remove__(array_pop(__remove_requests__));
				}//end repeat loop
			}
			
			#region jsDoc
			/// @func    __reset_focus_to_false__()
			/// @desc    This function is used to unfocus all sub components. Exists to assist components knowing what is currently being interacted with.
			/// @self    GUICompController
			/// @ignore
			#endregion
			static __reset_focus_to_false__ = function() {
				//this function is used to unfocus all sub components
				if (!__is_empty__) {
					var _comp;
					var _i=0; repeat(__children_count__) {
						_comp = __children__[i];
						_comp.__reset_focus_to_false__();
					_i+=1;}//end repeat loop
				}
				__is_on_focus__ = false;
				__trigger_event__(self.events.on_blur);
			}
			
			#region jsDoc
			/// @func    __mouse_on_controller__()
			/// @desc    This function is internally used to help assist early outing collision checks.
			/// @self    GUICompController
			/// @returns {Bool}
			/// @ignore
			#endregion
			static __mouse_on_controller__ = function() {
				//check if parent even has a mouse over it
				if (__is_child__) {
					if (!__parent__.__mouse_on_cc__) {
						return false;
					}
				}
				
				//check to see if the mouse is out of the window it's self
				static is_desktop = (os_type == os_windows || os_type == os_macosx || os_type == os_linux)
				//if (is_desktop) {
				//	if (window_mouse_get_x() != display_mouse_get_x() - window_get_x())
				//|| (window_mouse_get_y() != display_mouse_get_y() - window_get_y()) {
				//	__mouse_on_cc__ = false;
				//	return false;
				//}
				//}
				
				__mouse_on_cc__ = point_in_rectangle(
						device_mouse_x_to_gui(0),
						device_mouse_y_to_gui(0),
						x+__controller_region__.left,
						y+__controller_region__.top,
						x+__controller_region__.right,
						y+__controller_region__.bottom
				);
				
				if (__mouse_on_cc__) {
					__trigger_event__(self.events.on_hover_controller);
				}
				
				return __mouse_on_cc__;
			}
			
			#region jsDoc
			/// @func    __update_controller_region__()
			/// @desc    This function is internally used to help assist updating the bounding box of controllers. This bounding box is used for many things but primarily used for collision check optimizations.
			/// @self    GUICompController
			/// @param   {Real} index : The index of the component to remove.
			/// @returns {Struct.GUICompController}
			/// @ignore
			#endregion
			static __update_controller_region__ = function() {
				#region new
					
					var _left   = region.left;
					var _top    = region.top;
					var _right  = region.right;
					var _bottom = region.bottom;
					
					var _prev_left   = __controller_region__.left;
					var _prev_top    = __controller_region__.top;
					var _prev_right  = __controller_region__.right;
					var _prev_bottom = __controller_region__.bottom;
					
					
					var _comp, xoff, yoff;
					var i = 0; repeat(__children_count__) {
						_comp = __children__[i];
						xoff = _comp.x-x;
						yoff = _comp.y-y;
						
						
						switch (_comp.halign) {
							default:
							case fa_left:{
								 if (_comp.__is_controller__) {
									 _right  = max(_right,  xoff+_comp.__controller_region__.right);
								 }
								 else {
									 _right  = max(_right,  xoff+_comp.region.right);
								 }
							break;}
							case fa_center:{
								 if (_comp.__is_controller__) {
									 _left   = min(_left,   xoff+_comp.__controller_region__.left);
									 _right  = max(_right,  xoff+_comp.__controller_region__.right);
								 }
								 else {
									 _left   = min(_left,   xoff+_comp.region.left);
									 _right  = max(_right,  xoff+_comp.region.right);
								 }
							break;}
							case fa_right:{
							//We do not add Right anchors objects because they will always be with in the range of the right side and can not effect the left side
							
							//	 if (_comp.__is_controller__) {
							//		 _left   = min(_left,   xoff+_comp.__controller_region__.left);
							//	 }
							//	 else {
							//		 _left   = min(_left,   xoff+_comp.region.left);
							//	 }
							break;}
						}
						
						switch (_comp.valign) {
							default:
							case fa_top:{
								 if (_comp.__is_controller__) {
									 _bottom = max(_bottom, yoff+_comp.__controller_region__.bottom);
								 }
								 else {
									 _bottom = max(_bottom, yoff+_comp.region.bottom);
								 }
							break;}
							case fa_middle:{
								 if (_comp.__is_controller__) {
									 _top    = min(_top,    yoff+_comp.__controller_region__.top);
									 _bottom = max(_bottom, yoff+_comp.__controller_region__.bottom);
								 }
								 else {
									 _top    = min(_top,    yoff+_comp.region.top);
									 _bottom = max(_bottom, yoff+_comp.region.bottom);
								 }
							break;}
							case fa_bottom:{
							//We do not add Bottom anchors objects because they will always be with in the range of the right side and can not effect the top side
							
							//	 if (_comp.__is_controller__) {
							//		 _top    = min(_top,    yoff+_comp.__controller_region__.top);
							//	 }
							//	 else {
							//		 _top    = min(_top,    yoff+_comp.region.top);
							//	 }
							break;}
						}
						
						i+=1
					}
				
					//usually internally used to detect if the mouse is anywhere over a folder or window, helps with early outing collission checks
					__controller_region__.left   = _left;
					__controller_region__.top    = _top;
					__controller_region__.right  = _right;
					__controller_region__.bottom = _bottom;
					
					//if this controller is a child of another controller, update the parent controller, this will loop all the way to the top most parent
					if (__is_child__) {
						if (_prev_left   != _left)
						|| (_prev_top    != _top)
						|| (_prev_right  != _right)
						|| (_prev_bottom != _bottom) {
							__parent__.__update_controller_region__();
						}
					}
				#endregion
				
			}
			
			#region jsDoc
			/// @func    __validate_component_additions__()
			/// @desc    Validates that we are not adding existing components to our controller, or that a supplied array of components does not contain duplicates. This function will only throw errors and will only ever run if the config setting "should_safety_check" is true
			/// @self    GUICompController
			/// @param   {Array<Struct>} arr : The array of structs to validate
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __validate_component_additions__ = function(_arr) {
				if (should_safety_check) {
					var _cid, _j, _found_count, _comp;
					var _size = array_length(_arr);
					var _i=0; repeat(_size) {
						_comp = _arr[_i];
						
						//safety checks
						_cid = _comp.__cid__;
						
						//verify the component doeant appear twice in the supplied array
						_found_count = 0;
						_j=_i+1; repeat(_size-_i-1) {
							if (_arr[_j].__cid__ == _cid) {
								show_error("Trying to insert an array which contains the same component twice", true)
							}
						_j+=1;}//end repeat loop
						
						//verify the component is not already in the controller
						_j=0; repeat(__children_count__) {
							if (__children__[_j].__cid__ == _cid) {
								show_error("Trying to insert a component which already exists inside this controller", true)
							}
						_j+=1;}//end repeat loop
						
						//verify the component isn't already in another controller
						if (_comp.__is_child__) {
							show_error("Trying to add a new component which is alread inside another controller", true)
						}
						
					_i+=1;}//end repeat loop
				}
			}
			
			#region jsDoc
			/// @func    __validate_component_positions__()
			/// @desc    Validates that the newly added components are with in range of the controller's range,
			///            this safety check is implicetly to prevent an object being set out of range of the
			///            controler, which leads to the controller updating it's controller region size, which
			///            would anchor the component further out into an infinate loop.
			///
			/// @self    GUICompController
			/// @param   {Array<Struct>} arr : The array of structs to validate
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __validate_component_positions__ = function(_arr) {
				if (should_safety_check) {
					var _cid, _j, _found_count, _comp;
					var _size = array_length(_arr);
					var _i=0; repeat(_size) {
						_comp = _arr[_i];
						
						//skip if ignore safety
						if (!_comp.should_safety_check) {
							_i+=1;
							continue;
						}
						
						//verify the component does not reach out of bounds of the controller
						switch (_comp.halign) {
							case fa_left:{
								//make sure the child component's region does not reach outside of the controller's left side
								if (_comp.__is_controller__) {
									var _offset = self.__controller_region__.left - _comp.x_anchor - _comp.__controller_region__.left;
								}
								else {
									var _offset = self.__controller_region__.left - _comp.x_anchor - _comp.region.left;
								}
								
								if (_offset > 0) {
									show_error("Newly added component : "+string(_comp.debug_name)+" : is anchored to the left, but is outside of the controller's left region."
										+"\nThe component was "+string(_offset)+" pixels too far to the left."
										+"\nmake sure to move the component to the right before adding, or change the halign of the component.\n\n", true)
								}
							break;}
							case fa_center:{
								//nothing is needed here
							break;}
							case fa_right:{
								//make sure the child component's region does not reach outside of the controller's right side
								if (_comp.__is_controller__) {
									var _offset = _comp.x_anchor + _comp.__controller_region__.right - self.__controller_region__.right;
								}
								else {
									var _offset = _comp.x_anchor + _comp.region.right - self.__controller_region__.right;
								}
								
								if (_offset > 0) {
									show_error("Newly added component : "+string(_comp.debug_name)+" : is anchored to the right, but is outside of the controller's right region."
										+"\nThe component was "+string(_offset)+" pixels too far to the right."
										+"\nmake sure to move the component to the left before adding, or change the halign of the component.\n\n", true)
								}
							break;}
						}
						
						switch (_comp.valign) {
							case fa_top:{
								//make sure the child component's region does not reach outside of the controller's top side
								if (_comp.__is_controller__) {
									var _offset = self.__controller_region__.top - _comp.y_anchor - _comp.__controller_region__.top;
								}
								else {
									var _offset = self.__controller_region__.top - _comp.y_anchor - _comp.region.top;
								}
								
								if (_offset > 0) {
									show_error("Newly added component : "+string(_comp.debug_name)+" : is anchored to the top, but is outside of the controller's top region."
										+"\nThe component was "+string(_offset)+" pixels too far up."
										+"\nmake sure to move the component to the down before adding, or change the valign of the component.\n\n", true)
								}
							break;}
							case fa_middle:{
								//nothing is needed here
							break;}
							case fa_bottom:{
								//make sure the child component's region does not reach outside of the controller's bottom side
								if (_comp.__is_controller__) {
									var _offset = _comp.y_anchor + _comp.__controller_region__.bottom - self.__controller_region__.bottom;
								}
								else {
									var _offset = _comp.y_anchor + _comp.region.bottom - self.__controller_region__.bottom;
								}
								
								if (_offset > 0) {
									show_error("Newly added component : "+string(_comp.debug_name)+" : is anchored to the bottom, but is outside of the controller's bottom region."
											+"\nThe component was "+string(_offset)+" pixels too far down."
											+"\nmake sure to move the component to the up before adding, or change the valign of the component.\n\n", true)
								}
							break;}
						}
						
					_i+=1;}//end repeat loop
				}
			}
			
			#region jsDoc
			/// @func    __include_children__()
			/// @desc    Includes the children by either pushing them into the list or inserting them into the list. Any index under 0 will push the component.
			/// @self    GUICompController
			/// @param   {Array<Struct>} arr_of_comp : The array of components you wish to include into the children.
			/// @param   {Real} index : The index the array will be inserted into. Note: a value of -1 will push the array to the end.
			/// @ignore
			#endregion
			static __include_children__ = function(_arr, _index) {
				var _size, _i, _comp;
				
				_size = array_length(_arr);
				_i=0; repeat(_size) {
					_comp = _arr[_i];
					_comp.__is_child__ = true;
					_comp.__parent__ = self;
					
					if (!_comp.__position_set__) {
						_comp.__internal_x__ = _comp.x;
						_comp.__internal_y__ = _comp.y;
					}
					
					
					
					if (_index < 0) {
						array_push(__children__, _comp);
					}
					else {
						array_insert(__children__, _index, _comp);
					}
					
				_i+=1;}//end repeat loop
				
				__children_count__ += _size;
				
			}
			
		#endregion
		
	#endregion
	
}