#region jsDoc
/// @func    GUICompFolder()
/// @desc    Creates a folder component
/// @self    GUICompFolder
/// @param   {Real} x : The x possition of the component on screen.
/// @param   {Real} y : The y possition of the component on screen.
/// @return {Struct.GUICompFolder}
#endregion
function GUICompFolder(_x, _y) : GUICompController(_x, _y) constructor {
	debug_name = "GUICompFolder";
	
	#region Inherited Parents
		
		var _btn = new GUICompButtonText(_x, _y);
		variable_struct_inherite(_btn);
		delete _btn;
		
	#endregion
	
	#region Public
	
		#region Builder Functions
		
			#region jsDoc
			/// @func    set_children_offsets()
			/// @desc    Sets the indenting for sub components from the previous component. Good for making json style indenting.
			/// @self    GUICompFolder
			/// @param   {Real} xoff : The horizontal offset distance from the folder's x
			/// @param   {Real} yoff : The vertical offset distance from the folder's y
			/// @returns {Struct.GUICompFolder}
			#endregion
			static set_children_offsets = function(_xoff=0,_yoff=0){
				//sets the indenting for sub components from the previous component
		
				children_x_offset = _xoff;
				children_y_offset = _yoff;
		
				return self;
			}
		
			#region jsDoc
			/// @func    set_open()
			/// @desc    Sets the folder's is_open state.
			/// @self    GUICompFolder
			/// @param   {Bool} is_open : if the folder is open or not, true = open, false = closed;
			/// @returns {Struct.GUICompFolder}
			#endregion
			static set_open = function(_is_open=true){
			
				is_open = _is_open;
				
				return self;
			}
		
			#region jsDoc
			/// @func    set_header_shown()
			/// @desc    Sets if the folder's header to be drawn as well as interablbe.
			/// @self    GUICompFolder
			/// @param   {Bool} header_shown : if the folder's should header should be used, true = used, false = not used
			/// @returns {Struct.GUICompFolder}
			#endregion
			static set_header_shown = function(_header_shown=true){
			
				header_shown = _header_shown;
				set_region(0,0,0,0)
				return self;
			
			}
			
		#endregion
	
		#region Events
		
			self.events.opened = "opened";
			self.events.closed = "closed";
		
		#endregion
	
		#region Variables
			
			children_x_offset = 0;
			children_y_offset = 0;
			sprite.index = s9ButtonText;
			is_open = false;
			header_shown = true;
			halign = fa_left;
			valign = fa_top;
			
		#endregion
		
		#region Functions
			
			#region jsDoc
			/// @func    add()
			/// @desc    Add a Component to the folder.
			/// @self    GUICompFolder
			/// @param   {Struct.GUICompCore|Array} comp : The component you wish to add to the folder.
			/// @returns {Undefined}
			#endregion
			static add = function(_comp) {
				
				__is_empty__ = false;
				
				var _arr = (is_array(_comp)) ? _comp : [_comp];
				
				__validate_component_additions__(_arr);
				
				__include_children__(_arr, -1);
				
				if (is_open) {
					update_component_positions();
					__update_controller_region__();
				}
				
			}
			
			#region jsDoc
			/// @func    insert()
			/// @desc    Inserts a Component into the folder's children array.
			/// @self    GUICompFolder
			/// @param   {Real} index : The index (possition) you wish to insert the component into the children array
			/// @param   {Struct.GUICompCore|Array} comp : The component you wish to add to the folder.
			/// @returns {Undefined}
			#endregion
			static insert = function(_comp, _index) {
				
				__is_empty__ = false;
				
				var _arr = (is_array(_comp)) ? _comp : [_comp];
				
				__validate_component_additions__(_arr);
				
				__include_children__(_arr, _index);
				
				if (is_open) {
					update_component_positions();
					__update_controller_region__();
				}
				
			}
			
			#region jsDoc
			/// @func    update_component_positions()
			/// @desc    Updates the locations of the children
			/// @self    GUICompFolder
			/// @returns {Real}
			#endregion
			static update_component_positions = function() {
				if (is_open)
				&& (!__is_empty__) {
					var _posX, _posY, _i, _comp;
					_posX = x + children_x_offset;
					_posY = y + children_y_offset;
					
					_i=0; repeat(__children_count__) {
						
						_comp = __children__[_i];
						_comp.x = _posX;
						_comp.y = _posY;
				
						if (_comp.__is_controller__) {
							_comp.update_component_positions();
							//_comp.__update_controller_region__();
							_posY += _comp.__controller_region__.get_height();
						}
						else{
							_posY += _comp.region.get_height();
						}
						
					_i+=1;}//end repeat loop
					
				}
			}
			
		#endregion
		
	#endregion
	
	#region Private Library
		
		#region Variables
			
			__is_empty__ = true;
			__is_controller__ = true;
			__children__ = [];
			__children_count__ = 0;
			
		#endregion
		
		#region Functions
			
			__add_event_listener_priv__(self.events.released, function() {
				if(!__is_empty__) {
					is_open = !is_open;
					
					if (is_open) {
						update_component_positions();
						__trigger_event__(self.events.opened);
					}
					else {
						__trigger_event__(self.events.closed);
					}
					
					__update_controller_region__();
				}
			})
			
			#region GML Events
				
				static __begin_step__ = function(_input) {
					__post_remove__();
					
					__user_input__ = _input;
					__mouse_on_cc__ = __mouse_on_controller__();
					
					__trigger_event__(self.events.pre_update);
					
					begin_step(__user_input__);
					
					//run the children
					if(!__is_empty__ and is_open) {
						var _component, xx, yy;
						var _i=__children_count__; repeat(__children_count__) { _i--;
							_component = __children__[_i];
							////xx = _component.x - (x-_x);
							////yy = _component.y - (y-_y);
							_component.__begin_step__(__user_input__);
						}//end repeat loop
						
					}
					
					if (__user_input__.consumed) { capture_input(); };
				}
				static __step__ = function(_input){
					__user_input__ = _input;
					
					step(__user_input__);
					
					//run children
					if(!__is_empty__ and is_open) {
						//run the children
						var _component, xx, yy;
						var _i=__children_count__; repeat(__children_count__) { _i--;
							_component = __children__[_i];
							////xx = _component.x - (x-_x);
							////yy = _component.y - (y-_y);
							_component.__step__(__user_input__);
						}//end repeat loop
						
					}
					
					__handle_click__(_input);
					
					if (__user_input__.consumed) { capture_input(); };
				}
				static __end_step__ = function(_input) {
					__user_input__ = _input;
					
					if(!__is_empty__ and is_open) {
						
						end_step(__user_input__);
						
						//run the children
						var _component, xx, yy;
						var _i=__children_count__; repeat(__children_count__) { _i--;
							_component = __children__[_i];
							//xx = _component.x - (x-_x);
							//yy = _component.y - (y-_y);
							_component.__end_step__(__user_input__);
						}//end repeat loop
						
					}
					
					__trigger_event__(self.events.post_update);
					
					if (__user_input__.consumed) { capture_input(); };
				}
				
				static __draw_gui_begin__ = function(_input) {
					__post_remove__();
					
					__user_input__ = _input;
					
					draw_gui_begin(__user_input__);
					
					if(!__is_empty__ and is_open) {
						
						//run the children
						var _component, xx, yy;
						var _i=0; repeat(__children_count__) {
							_component = __children__[_i];
							//xx = _component.x - (x-_x);
							//yy = _component.y - (y-_y);
							_component.__draw_gui_begin__(__user_input__);
						_i++;}//end repeat loop
						
					}
					
					if (__user_input__.consumed) { capture_input(); };
				}
				static __draw_gui__ = function(_input) {
					__user_input__ = _input;
					
					//this is just imitating the inherited components draw_gui, in this case button
					if (header_shown) {
						draw_gui(__user_input__);
					}
					
					if (GUI_GLOBAL_DEBUG) {
						draw_set_color(c_red)
						draw_rectangle(
							x+__controller_region__.left,
							y+__controller_region__.top,
							x+__controller_region__.right,
							y+__controller_region__.bottom,
							true
						);
						
						draw_set_color(c_green)
						draw_rectangle(
							x+region.left,
							y+region.top,
							x+region.right,
							y+region.bottom,
							true
						);
						
					};
					
					//run children
					if(!__is_empty__ and is_open) {
						//update childrens possitions
						update_component_positions();
						
						//run the children
						var _component, xx, yy;
						var _i=0; repeat(__children_count__) {
							_component = __children__[_i];
							//xx = _component.x - (x-_x);
							//yy = _component.y - (y-_y);
							_component.__draw_gui__(__user_input__);
						_i++;}//end repeat loop
						
					}
					
					if (__user_input__.consumed) { capture_input(); };
				}
				static __draw_gui_end__ = function(_input) {
					__user_input__ = _input;
					
					draw_gui_end(__user_input__);
					
					if(!__is_empty__ and is_open) {
						
						//run the children
						var _component, xx, yy;
						var _i=0; repeat(__children_count__) {
							_component = __children__[_i];
							//xx = _component.x - (x-_x);
							//yy = _component.y - (y-_y);
							_component.__draw_gui_end__(__user_input__);
						_i++;}//end repeat loop
						
					}
					
					if (__user_input__.consumed) { capture_input(); };
					
					xprevious = x;
					yprevious = y;
					
					if (GUI_GLOBAL_DEBUG) {
						draw_debug();
					}
				}
				
				static __cleanup__ = function() {
					cleanup();
					
					if(!__is_empty__) {
						var _i=0; repeat(__children_count__) {
							var _comp = __children__[_i];
							_comp.__cleanup__();
							delete _comp;
						_i+=1;}//end repeat loop
						
					}
				}
				
			#endregion
			
			static __update_controller_region__ = function() {
				var _left   = region.left;
				var _top    = region.top;
				var _right  = region.right;
				var _bottom = region.bottom;
		
				//if it's closed we dont need to add anything extra to this
				if(!__is_empty__ and is_open) {
					var _component, xoff, yoff;
					var _i = 0; repeat(__children_count__) {
						_component = __children__[_i];
						xoff = _component.x-x;
						yoff = _component.y-y;
				
						if(_component.__is_controller__) {
							_left   = min(_left,   xoff+_component.__controller_region__.left);
							_top    = min(_top,    yoff+_component.__controller_region__.top);
							_right  = max(_right,  xoff+_component.__controller_region__.right);
							_bottom = max(_bottom, yoff+_component.__controller_region__.bottom);
						}
						//else{
							_left   = min(_left,   xoff+_component.region.left);
							_top    = min(_top,    yoff+_component.region.top);
							_right  = max(_right,  xoff+_component.region.right);
							_bottom = max(_bottom, yoff+_component.region.bottom);
						//}
						_i++
					}
				}
		
		
				__controller_region__ = { //usually internally used to detect if the mouse is anywhere over a folder or window, helps with early outing collission checks
					left   : _left,
					top    : _top,
					right  : _right,
					bottom : _bottom,
				}
		
				//if this controller is a child of another controller, update the parent controller, this will loop all the way to the top most parent
				if (__is_child__) {
					__parent__.update_component_positions();
					__parent__.__update_controller_region__();
				}
			}
			
		#endregion
		
	#endregion
	
	//post init
	set_children_offsets(8, region.get_height())
	__update_controller_region__();
}
