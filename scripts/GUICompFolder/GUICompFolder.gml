#region jsDoc
/// @func    GUICompFolder()
/// @desc    Creates a folder component
/// @self    GUICompFolder
/// @param   {Real} x : The x possition of the component on screen.
/// @param   {Real} y : The y possition of the component on screen.
/// @return {Struct.GUICompFolder}
#endregion
function GUICompFolder() : GUICompController() constructor {
	debug_name = "GUICompFolder";
	
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
			static set_children_offsets = function(_xoff=0,_yoff=0){ //log(["set_children_offsets", set_children_offsets]);
				//sets the indenting for sub components from the previous component
				
				__controller__.set_children_offsets(_xoff, _yoff);
				
				return self;
			}
			#region jsDoc
			/// @func    set_open()
			/// @desc    Sets the folder's is_open state.
			/// @self    GUICompFolder
			/// @param   {Bool} is_open : if the folder is open or not, true = open, false = closed;
			/// @returns {Struct.GUICompFolder}
			#endregion
			static set_open = function(_is_open=true){ //log(["set_open", set_open]);
				is_open = !is_open;
				update_component_positions();
				
				return self;
			}
			#region jsDoc
			/// @func    set_header_shown()
			/// @desc    Sets if the folder's header to be drawn as well as interablbe.
			/// @self    GUICompFolder
			/// @param   {Bool} header_shown : if the folder's should header should be used, true = used, false = not used
			/// @returns {Struct.GUICompFolder}
			#endregion
			static set_header_shown = function(_header_shown=true){ //log(["set_header_shown", set_header_shown]);
				header_shown = _header_shown;
				
				return self;
			}
			
		#endregion
		
		#region Events
		
			self.events.opened = variable_get_hash("opened");
			self.events.closed = variable_get_hash("closed");
			self.events.on_hover_controller = variable_get_hash("on_hover_controller"); //triggered every frame the mouse is over the controller region bounding box, This will be a square box encapsulating all sub components.
			
		#endregion
		
		#region Variables
			
			is_open = true;
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
			static add = function(_comp) { //log(["add", add]);
				
				var _r = __controller__.add(_comp);
				
				if (is_open) {
					update_component_positions();
					__update_controller_region__();
				}
				
				return _r;
				
			}
			#region jsDoc
			/// @func    insert()
			/// @desc    Inserts a Component into the folder's children array.
			/// @self    GUICompFolder
			/// @param   {Real} index : The index (possition) you wish to insert the component into the children array
			/// @param   {Struct.GUICompCore|Array} comp : The component you wish to add to the folder.
			/// @returns {Undefined}
			#endregion
			static insert = function(_comp, _index) { //log(["insert", insert]);
				
				var _r = __controller__.add(_comp);
				
				if (is_open) {
					update_component_positions();
					__update_controller_region__();
				}
				
				return _r;
			}
			#region jsDoc
			/// @func    update_component_positions()
			/// @desc    Updates the locations of the children
			/// @self    GUICompFolder
			/// @returns {Real}
			#endregion
			static update_component_positions = function() { //log(["update_component_positions", update_component_positions]);
				var _changed = false;
				
				var _anchor_point, _comp, _xx, _yy;
				
				//move the children
				var _i=0; repeat(__children_count__) {
					_comp = __children__[_i];
					
					_xx = __get_controller_archor_x__(_comp.halign);
					_yy = __get_controller_archor_y__(_comp.valign);
					
					_comp.x = self.x + _xx + _comp.x_anchor + _comp.__internal_x__;
					_comp.y = self.y + _yy + _comp.y_anchor + _comp.__internal_y__;
					
				_i+=1;}//end repeat loop
				
				if (is_open) {
					__controller__.update_component_positions();
				}
				
				__update_controller_region__();
			}
			
		#endregion
		
	#endregion
	
	#region Private Library
		
		#region Variables
			
			__button__ = new GUICompButtonText();
			adopt_builder_functions(__button__);
			
			__controller__ = new GUICompControllerStacked();
			
			__SUPER__.add([__button__, __controller__])
			
		#endregion
		
		#region Functions
			
			__button__.__add_event_listener_priv__(__button__.events.released, function() {
				set_open(is_open);
				
				if (is_open) {
					__trigger_event__(self.events.opened);
				}
				else {
					__trigger_event__(self.events.closed);
				}
			})
			
			#region GML Events
				
				static __begin_step__ = function(_input) { //log(["__begin_step__", __begin_step__]);
					__post_remove__();
					
					__user_input__ = _input;
					__mouse_on_cc__ = __mouse_on_controller__();
					
					__trigger_event__(self.events.pre_update);
					
					begin_step(__user_input__);
					
					if (header_shown) {
						__button__.__begin_step__(_input);
					}
					
					//run the children
					if (is_open) {
						__controller__.__begin_step__(__user_input__);
					}
					
					if (__user_input__.consumed) { capture_input(); };
				}
				static __step__ = function(_input){ //log(["__step__", __step__]);
					__user_input__ = _input;
					
					step(__user_input__);
					if (header_shown) {
						__button__.__step__(_input);
					}
					
					//run children
					if (is_open) {
						__controller__.__step__(__user_input__);
					}
					
					if (__user_input__.consumed) { capture_input(); };
				}
				static __end_step__ = function(_input) { //log(["__end_step__", __end_step__]);
					__user_input__ = _input;
					
					
					end_step(__user_input__);
					if (header_shown) {
						__button__.__end_step__(_input);
					}
					
					if (is_open) {
						__controller__.__end_step__(__user_input__);
					}
					
					__trigger_event__(self.events.post_update);
					
					if (__user_input__.consumed) { capture_input(); };
				}
				
				static __draw_gui_begin__ = function(_input) { //log(["__draw_gui_begin__", __draw_gui_begin__]);
					__post_remove__();
					
					__user_input__ = _input;
					
					draw_gui_begin(__user_input__);
					if (header_shown) {
						__button__.__draw_gui_begin__(_input);
					}
					
					if (is_open) {
						__controller__.__draw_gui_begin__(__user_input__);
					}
					
					if (__user_input__.consumed) { capture_input(); };
				}
				static __draw_gui__ = function(_input) { //log(["__draw_gui__", __draw_gui__]);
					__user_input__ = _input;
					
					//this is just imitating the inherited components draw_gui, in this case button
					draw_gui(__user_input__);
					if (header_shown) {
						__button__.__draw_gui__(_input);
					}
					
					//run children
					if (is_open) {
						__controller__.__draw_gui__(__user_input__);
					}
					
					if (__user_input__.consumed) { capture_input(); };
				}
				static __draw_gui_end__ = function(_input) { //log(["__draw_gui_end__", __draw_gui_end__]);
					__user_input__ = _input;
					
					draw_gui_end(__user_input__);
					if (header_shown) {
						__button__.__draw_gui_end__(_input);
					}
					
					if (is_open) {
						__controller__.__draw_gui_end__(__user_input__);
					}
					
					if (__user_input__.consumed) { capture_input(); };
					
					xprevious = x;
					yprevious = y;
					
					draw_debug();
				}
				
				static __cleanup__ = function() { //log(["__cleanup__", __cleanup__]);
					cleanup();
					__button__.__cleanup__();
					__controller__.__cleanup__();
				}
				
			#endregion
			
			static __update_controller_region__ = function() { //log(["__update_controller_region__", __update_controller_region__]);
				var _left   = region.left;
				var _top    = region.top;
				var _right  = region.right;
				var _bottom = region.bottom;
				
				//if it's closed we dont need to add anything extra to this
				var _component, xoff, yoff;
				var _i = 0; repeat(__children_count__) {
					_component = __children__[_i];
					
					//skip the controller if the folder is closed
					if (!is_open)
					&& (_component.__is_controller__) {
						_i+=1;
						continue;
					}
					
					//skip the button if the header is not shown
					if (!header_shown)
					&& (!_component.__is_controller__) {
						_i+=1;
						continue;
					}
					
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
				
				
				__controller_region__.left   = _left;
				__controller_region__.top    = _top;
				__controller_region__.right  = _right;
				__controller_region__.bottom = _bottom;
				
				//if this controller is a child of another controller, update the parent controller, this will loop all the way to the top most parent
				if (__is_child__) {
					//__parent__.update_component_positions();
					__parent__.__update_controller_region__();
				}
			}
			
		#endregion
		
	#endregion
	
	//post init
	__update_controller_region__();
}


