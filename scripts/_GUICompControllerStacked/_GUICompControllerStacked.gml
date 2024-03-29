#region jsDoc
/// @func    GUICompControllerStacked()
/// @desc    Creates a folder component
/// @self    GUICompControllerStacked
/// @param   {Real} x : The x possition of the component on screen.
/// @param   {Real} y : The y possition of the component on screen.
/// @return {Struct.GUICompControllerStacked}
#endregion
function GUICompControllerStacked() : GUICompController() constructor {
	debug_name = "GUICompControllerStacked";
	
	#region Public
		
		#region Builder Functions
		
			#region jsDoc
			/// @func    set_children_offsets()
			/// @desc    Sets the indenting for sub components from the previous component. Good for making json style indenting.
			/// @self    GUICompControllerStacked
			/// @param   {Real} xoff : The horizontal offset distance from the folder's x
			/// @param   {Real} yoff : The vertical offset distance from the folder's y
			/// @returns {Struct.GUICompControllerStacked}
			#endregion
			static set_children_offsets = function(_xoff=0,_yoff=0){ //log(["set_children_offsets", set_children_offsets]);
				//sets the indenting for sub components from the previous component
				
				children_x_offset = _xoff;
				children_y_offset = _yoff;
				
				update_component_positions();
				
				return self;
			}
			
		#endregion
		
		#region Events
		
			self.events.opened = variable_get_hash("opened");
			self.events.closed = variable_get_hash("closed");
			self.events.on_hover_controller = variable_get_hash("on_hover_controller"); //triggered every frame the mouse is over the controller region bounding box, This will be a square box encapsulating all sub components.
			
		#endregion
		
		#region Variables
			
			halign = fa_left;
			valign = fa_top;
			
		#endregion
		
		#region Functions
			
			#region jsDoc
			/// @func    add()
			/// @desc    Add a Component to the folder.
			/// @self    GUICompControllerStacked
			/// @param   {Struct.GUICompCore|Array} comp : The component you wish to add to the folder.
			/// @returns {Undefined}
			#endregion
			static add = function(_comp) { //log(["add", add]);
				
				__is_empty__ = false;
				
				var _arr = (is_array(_comp)) ? _comp : [_comp];
				
				__validate_component_additions__(_arr);
				
				__include_children__(_arr, -1);
				
				update_component_positions();
				
				__update_controller_region__();
				
				//dont think this is needed anymore after a refactor of folders
				
				////fixes a bug where when a folder is added at the end of another folder, both folder's regions is incorrect
				//var _i=0; repeat(array_length(_arr)) {
				//	_comp = _arr[_i];
				//	if (_comp.__is_controller__) {
				//		_comp.__update_controller_region__();
				//	}
				//_i+=1;}//end repeat loop
				
			}
			#region jsDoc
			/// @func    insert()
			/// @desc    Inserts a Component into the folder's children array.
			/// @self    GUICompControllerStacked
			/// @param   {Real} index : The index (possition) you wish to insert the component into the children array
			/// @param   {Struct.GUICompCore|Array} comp : The component you wish to add to the folder.
			/// @returns {Undefined}
			#endregion
			static insert = function(_comp, _index) { //log(["insert", insert]);
				__is_empty__ = false;
				
				var _count = __children_count__;
				
				var _arr = (is_array(_comp)) ? _comp : [_comp];
				
				__validate_component_additions__(_arr);
				
				__include_children__(_arr, _index);
				
				update_component_positions();
				
				__update_controller_region__();
				
				return __children_count__;
			}
			#region jsDoc
			/// @func    update_component_positions()
			/// @desc    Updates the locations of the children
			/// @self    GUICompControllerStacked
			/// @returns {Real}
			#endregion
			static update_component_positions = function() { //log(["update_component_positions", update_component_positions]);
				var _changed = false;
				
				if (!__is_empty__) {
					var _posX, _posY, _i, _comp;
					_posX = x + children_x_offset;
					_posY = y + children_y_offset;
					
					_i=0; repeat(__children_count__) {
						_comp = __children__[_i];
						
						if (_comp.x != _posX)
						|| (_comp.y != _posY) {
							_changed = true;
						}
						
						_comp.x = _posX;
						_comp.y = _posY;
						
						if (_comp.__is_controller__) {
							
								_comp.update_component_positions();
								
							if (_changed) {
								//not this isnt needed if the parent is a folder, but if it's another folder inside a controller this is indeed neede
								_comp.__update_controller_region__();
							}
							_posY += _comp.__controller_region__.get_height();
						}
						else{
							_posY += _comp.region.get_height();
						}
						
					_i+=1;}//end repeat loop
					
				}
				
				__update_controller_region__();
				
			}
			
		#endregion
		
	#endregion
	
	#region Private Library
		
		#region Variables
			
		#endregion
		
		#region Functions
			
			#region GML Events
				
				static __begin_step__ = function(_input) { //log(["__begin_step__", __begin_step__]);
					__post_remove__();
					
					__user_input__ = _input;
					__mouse_on_cc__ = __mouse_on_controller__();
					
					__trigger_event__(self.events.pre_update);
					
					begin_step(__user_input__);
					
					//run the children
					if (!__is_empty__) {
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
				static __step__ = function(_input){ //log(["__step__", __step__]);
					__user_input__ = _input;
					
					step(__user_input__);
					
					//run children
					if (!__is_empty__) {
						//run the children
						var _component, xx, yy;
						var _i=__children_count__; repeat(__children_count__) { _i--;
							_component = __children__[_i];
							////xx = _component.x - (x-_x);
							////yy = _component.y - (y-_y);
							_component.__step__(__user_input__);
						}//end repeat loop
						
					}
					
					//__handle_click__(_input);
					
					if (__user_input__.consumed) { capture_input(); };
				}
				static __end_step__ = function(_input) { //log(["__end_step__", __end_step__]);
					__user_input__ = _input;
					
					end_step(__user_input__);
					
					if (!__is_empty__) {
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
				
				static __draw_gui_begin__ = function(_input) { //log(["__draw_gui_begin__", __draw_gui_begin__]);
					__post_remove__();
					
					__user_input__ = _input;
					
					draw_gui_begin(__user_input__);
					
					if (!__is_empty__) {
						//run the children
						var _component, xx, yy;
						var _i=0; repeat(__children_count__) {
							_component = __children__[_i];
							//xx = _component.x - (x-_x);
							//yy = _component.y - (y-_y);
							_component.__draw_gui_begin__(__user_input__);
						_i+=1;}//end repeat loop
						
					}
					
					if (__user_input__.consumed) { capture_input(); };
				}
				static __draw_gui__ = function(_input) { //log(["__draw_gui__", __draw_gui__]);
					__user_input__ = _input;
					
					//this is just imitating the inherited components draw_gui, in this case button
					draw_gui(__user_input__);
					
					//run children
					if (!__is_empty__) {
						//run the children
						var _component, xx, yy;
						var _i=0; repeat(__children_count__) {
							_component = __children__[_i];
							//xx = _component.x - (x-_x);
							//yy = _component.y - (y-_y);
							_component.__draw_gui__(__user_input__);
						_i+=1;}//end repeat loop
						
					}
					
					if (__user_input__.consumed) { capture_input(); };
				}
				static __draw_gui_end__ = function(_input) { //log(["__draw_gui_end__", __draw_gui_end__]);
					__user_input__ = _input;
					
					draw_gui_end(__user_input__);
					
					if (!__is_empty__) {
						//run the children
						var _component, xx, yy;
						var _i=0; repeat(__children_count__) {
							_component = __children__[_i];
							_component.__draw_gui_end__(__user_input__);
						_i+=1;}//end repeat loop
						
					}
					
					if (__user_input__.consumed) { capture_input(); };
					
					xprevious = x;
					yprevious = y;
					
					draw_debug();
				}
				
				static __cleanup__ = function() { //log(["__cleanup__", __cleanup__]);
					cleanup();
					
					if (!__is_empty__) {
						var _i=0; repeat(__children_count__) {
							var _comp = __children__[_i];
							_comp.__cleanup__();
							delete _comp;
						_i+=1;}//end repeat loop
						
					}
				}
				
				static draw_debug = function() {
					if (!should_draw_debug) return;
					
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
				}
				
			#endregion
			
			static __update_controller_region__ = function() { //log(["__update_controller_region__", __update_controller_region__]);
				var _left   = region.left;
				var _top    = region.top;
				var _right  = region.right;
				var _bottom = region.bottom;
				
				//if it's closed we dont need to add anything extra to this
				if (!__is_empty__) {
					var _component, xoff, yoff;
					var _i = 0; repeat(__children_count__) {
						_component = __children__[_i];
						xoff = _component.x-x;
						yoff = _component.y-y;
				
						if (_component.__is_controller__) {
							_left   = min(_left,   xoff+_component.__controller_region__.left);
							_top    = min(_top,    yoff+_component.__controller_region__.top);
							_right  = max(_right,  xoff+_component.__controller_region__.right);
							_bottom = max(_bottom, yoff+_component.__controller_region__.bottom);
						}
						
						_left   = min(_left,   xoff+_component.region.left);
						_top    = min(_top,    yoff+_component.region.top);
						_right  = max(_right,  xoff+_component.region.right);
						_bottom = max(_bottom, yoff+_component.region.bottom);
						
						_i+=1
					}
				}
				
				__controller_region__.left   = _left;
				__controller_region__.top    = _top;
				__controller_region__.right  = _right;
				__controller_region__.bottom = _bottom;
				
				//if this controller is a child of another controller, update the parent controller, this will loop all the way to the top most parent
				if (__is_child__) {
					__parent__.__update_controller_region__();
				}
			}
			
		#endregion
		
	#endregion
	
	//post init
	set_children_offsets(8, 0)
	__update_controller_region__();
}


