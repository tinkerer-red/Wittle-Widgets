#region jsDoc
/// @func    GUICompCore()
/// @desc    This is the root most component, only use this if you need a very basic component for drawing purposes or if you're creating a new component.
/// @param   {Real} x : The x possition of the component on screen.
/// @param   {Real} y : The y possition of the component on screen.
/// @returns {Struct.GUICompCore}
#endregion
function GUICompCore() constructor {
	debug_name = "GUICompCore";
	should_draw_debug = GUI_GLOBAL_DEBUG;
	should_safety_check = GUI_GLOBAL_SAFETY;
	
	#region Public
		
		#region Builder Functions
			
			#region jsDoc
			/// @func    set_anchor()
			/// @desc    Sets the anchor of the component, This anchor will depict how the component is attached to the parent controller when resizing
			/// @self    GUICompCore
			/// @param   {Real} x : The x anchor of the component.
			/// @param   {Real} y : The y anchor of the component.
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_anchor = function(_x, _y) { //log(["set_anchor", set_anchor]);
				self.x_anchor = _x;
				self.y_anchor = _y;
				
				return self;
			}
			#region jsDoc
			/// @func    set_alignment()
			/// @desc    Sets how the component will anchor to it's parent. Note: Some parent controllers will ignore this value if they see fit.
			/// @self    GUICompCore
			/// @param   {Constant.HAlign} halign : Horizontal alignment.
			/// @param   {Constant.VAlign} valign : Vertical alignment.
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_alignment = function(_halign=fa_center, _valign=fa_middle) { //log(["set_alignment", set_alignment]);
				
				halign = _halign;
				valign = _valign;
				
				return self;
			}
			#region jsDoc
			/// @func    set_position()
			/// @desc    Sets the position of the component, This position will be reletive to the parent controller and the anchor.
			/// @self    GUICompCore
			/// @param   {Real} x : The x of the component.
			/// @param   {Real} y : The y of the component.
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_position = function(_x, _y) { //log(["set_position", set_position]);
				self.x = _x;
				self.y = _y;
				self.__internal_x__ = _x;
				self.__internal_y__ = _y;
				
				if (__position_set__ == false) {
					__position_set__ = true;
					self.xprevious = self.x;
					self.yprevious = self.y;
					self.xstart = self.x;
					self.ystart = self.y;
				}
				
				return self;
			}
			#region jsDoc
			/// @func    set_sprite()
			/// @desc    Sets all default GML object's sprite variables with a given sprite.
			/// @self    GUICompCore
			/// @param   {Asset.GMSprite} sprite : The sprite to apply to the component.
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_sprite = function(_sprite) { //log(["set_sprite", set_sprite]);
				__set_sprite__(_sprite);
			}
			#region jsDoc
			/// @func    set_sprite_angle()
			/// @desc    Sets the angle of the sprite to be drawn.
			/// @self    GUICompCore
			/// @param   {Real} angle : The angle of the sprite.
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_sprite_angle = function(_angle) { //log(["set_sprite_angle", set_sprite_angle]);
				image.angle = _angle;
			}
			#region jsDoc
			/// @func    set_sprite_color()
			/// @desc    Sets the color of the sprite to be drawn.
			/// @self    GUICompCore
			/// @param   {Real} color : The color of the sprite.
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_sprite_color = function(_col) { //log(["set_sprite_color", set_sprite_color]);
				image.blend = _col;
			}
			#region jsDoc
			/// @func    set_sprite_alpha()
			/// @desc    Sets the alpha of the sprite to be drawn.
			/// @self    GUICompCore
			/// @param   {Real} alpha : The alpha of the sprite.
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_sprite_alpha = function(_alpha) { //log(["set_sprite_alpha", set_sprite_alpha]);
				image.alpha = _alpha;
			}
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
			static set_region = function(_left, _top, _right, _bottom) { //log(["set_region", set_region]);
				region.left   = _left;
				region.top    = _top;
				region.right  = _right;
				region.bottom = _bottom;
				
				//update click regions
				if (__is_controller__) {
					__update_controller_region__();
				}
				else {
					if (__is_child__) {
						__parent__.__update_controller_region__()
					}
				}
				
				return self;
			}
			#region jsDoc
			/// @func    set_enabled()
			/// @desc    Enable or Disable the Component, This usually effects how some components are handled
			/// @self    GUICompCore
			/// @param   {Bool} is_enabled : If the component should be enabled or not.
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_enabled = function(_is_enabled) { //log(["set_enabled", set_enabled]);
				is_enabled = _is_enabled;
				
				if (is_enabled) {
					__trigger_event__(self.events.enabled);
				}
				else {
					__trigger_event__(self.events.disabled);
				}
				
				return self;
			}
			#region jsDoc
			/// @func    set_width()
			/// @desc    Sets the width of the component, this is just a short cut for doing `set_region(0, 0, _width, region.get_height())`
			/// @self    GUICompCore
			/// @param   {Real} width : The width of the component.
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_width = function(_width) { //log(["set_width", set_width]);
				set_region(0, 0, _width, region.get_height())
				
				return self;
			}
			#region jsDoc
			/// @func    set_height()
			/// @desc    Sets the height of the component, this is just a short cut for doing `set_region(0, 0, region.get_width(), _height)`
			/// @self    GUICompCore
			/// @param   {Real} height : The height of the component.
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_height = function(_height) { //log(["set_height", set_height]);
				set_region(0, 0, region.get_width(), _height)
				
				return self;
			}
			
			static set_debug_drawing = function(_bool=false) { //log(["set_debug_drawing", set_debug_drawing]);
				should_draw_debug = _bool;
				
				return self;
			}
			static set_do_safety_check = function(_bool=true) { //log(["set_do_safety_check", set_do_safety_check]);
				should_safety_check = _bool
				
				return self;
			}
		#endregion
		
		#region Events
			
			events = {};
			
			events.on_focus    = variable_get_hash("on_focus"); //triggered when the component gets focus, this commonly occurs when the mouse is clicked down on it.
			events.on_blur     = variable_get_hash("on_blur");  //triggered when the component loses focus, this commonly occurs when the mouse is clicked down off it, or when the mouse is released off it.
			events.on_hover    = variable_get_hash("on_hover"); //triggered every frame the mouse is over the regions bounding box
			events.pre_update  = variable_get_hash("pre_update"); //triggered every frame before the begin step event is activated
			events.post_update = variable_get_hash("post_update"); //triggered every frame after the end step event is activated
			events.enabled     = variable_get_hash("enabled"); //triggered when the component is enabled (this is done by the developer)
			events.disabled    = variable_get_hash("disabled"); //triggered when the component is disabled (this is done by the developer)
			self.events.on_hover_controller = variable_get_hash("on_hover_controller"); //triggered every frame the mouse is over the controller region bounding box, This will be a square box encapsulating all sub components.
			
		#endregion
		
		#region Variables
			
			is_enabled = true;
			
			halign = fa_center;
			valign = fa_middle;
			
			region = new __region__();
			
			//each component will have it's own events these will always be listed in this region
			
			#region GML Variables
				self.depth = 0;
				
				self.x = 0;
				self.y = 0;
				
				self.xstart = 0;
				self.ystart = 0;
				
				self.xprevious = 0;
				self.yprevious = 0;
				
				self.x_anchor = 0;
				self.y_anchor = 0;
				
				self.sprite = {};
				self.sprite.index   = -1;
				self.sprite.height  = 0;
				self.sprite.width   = 0;
				self.sprite.xoffset = 0;
				self.sprite.yoffset = 0;
				
				self.visible = true;
				
				self.image = {};
				self.image.alpha  = 1;
				self.image.angle  = 0;
				self.image.blend  = c_white;
				self.image.index  = -1;
				self.image.number = 0;
				self.image.speed  = 0;
				self.image.xscale = 1;
				self.image.yscale = 1;
			#endregion
			
		#endregion
	
		#region Functions
			#region jsDoc
			/// @func    add_event_listener()
			/// @desc    Add an event listener to the component,
			///          This function will be ran when the event is triggered
			/// @self    GUICompCore
			/// @param   {String} event_id : The comonent's event you wish to bound this function to.
			/// @param   {Function} func : The function to run when the event is triggered
			/// @returns {Real}
			#endregion
			static add_event_listener = function(_event_id, _func) { //log(["add_event_listener", add_event_listener]);
				var _hash = _event_id;
				if (struct_get_from_hash(self.__event_listeners__, _hash) == undefined) {
					struct_set_from_hash(self.__event_listeners__, _hash, [])
				}
				
				var _uid = __event_listener_uid__;
				__event_listener_uid__+=1;
				var _arr = struct_get_from_hash(self.__event_listeners__, _hash)
				array_push(_arr, {func: _func, UID: _uid});
				struct_set_from_hash(self.__event_listeners__, _hash, _arr)
				
				return _uid
			}
			//TODO: Fix this function
			#region jsDoc
			/// @func    remove_event_listener()
			/// @desc    Remove an event listener to the component
			/// @self    GUICompCore
			/// @param   {real} uid : The Unique ID of a previously added event function returned by add_event_listener.
			/// @returns {Struct.GUICompCore}
			#endregion
			static remove_event_listener = function(_uid) { //log(["remove_event_listener", remove_event_listener]);
				var _struct, _func;
				
				var _hash = _uid;
				
				var _event_arr = struct_get_from_hash(self.__event_listeners__, _hash);
				var _size = array_length(_event_arr);
		
				var _i=0; repeat(_size) {
					_struct = _event_arr[_i];
					if (_uid == _struct.UID) {
						break;
					}
				_i+=1;}//end repeat loop
		
				if (_i < _size) {
					array_delete(_event_arr, _i, 1);
					struct_set_from_hash(self.__event_listeners__, _hash, _event_arr)
					return self;
				}
				else{
					show_error("remove_event_listener : Attempting to remove a UID which doesnt exist", true);
				}
			}
			#region jsDoc
			/// @func    get_events()
			/// @desc    With this function you can retrieve an array populated with the names of the component's events.
			/// @self    GUICompCore
			/// @returns {Array<String>}
			#endregion
			static get_events = function() { //log(["get_events", get_events]);
				return variable_struct_get_names(events)
			}
			#region jsDoc
			/// @func    get_functions()
			/// @desc    With this function you can retrieve an array populated with the names of the component's functions. Useful for learning what available public functions you have access to.
			/// @self    GUICompCore
			/// @returns {Array<String>}
			#endregion
			static get_functions = function() { //log(["get_functions", get_functions]);
				var _statics = static_get(self)
				var _arr = [];
				var _names = variable_struct_get_names(_statics)
				var _size = array_length(_names)
				var _key;
				var _i=0; repeat(_size) {
					_key = _names[_i];
					if (string_pos("__", _key) != 1) {
						array_push(_arr, _key)
					}
				_i+=1;}//end repeat loop
				return _arr;
			}
			#region jsDoc
			/// @func    get_builder_functions()
			/// @desc    With this function you can retrieve an array populated with the names of the component's builder functions. Useful for learning what functions you can make use of when initializing a the component.
			/// @self    GUICompCore
			/// @returns {Array<String>}
			#endregion
			static get_builder_functions = function() { //log(["get_builder_functions", get_builder_functions]);
				var _statics = static_get(self)
				var _arr = [];
				var _names = variable_struct_get_names(_statics)
				var _size = array_length(_names)
				var _key;
				var _i=0; repeat(_size) {
					_key = _names[_i];
					if (string_pos("set_", _key) = 1) {
						array_push(_arr, _key)
					}
				_i+=1;}//end repeat loop
				return _arr;
			}
			#region jsDoc
			/// @func    mouse_on_comp()
			/// @desc    Checks to see if the mouse is currently on the component. Used for optimization when hundreds of components are available.
			/// @self    GUICompCore
			/// @returns {Bool}
			#endregion
			static mouse_on_comp = function() { //log(["mouse_on_comp", mouse_on_comp]);
				//check if parent even has a mouse over it
				if (__is_child__) {
					if (!__parent__.__mouse_on_cc__) {
						return false;
					}
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
				
				__mouse_on_cc__ = point_in_rectangle(
						device_mouse_x_to_gui(0),
						device_mouse_y_to_gui(0),
						x+region.left,
						y+region.top,
						x+region.right,
						y+region.bottom
				)
				
				if (__mouse_on_cc__) {
					__trigger_event__(self.events.on_hover);
				}
				
				return __mouse_on_cc__;
			}
			#region jsDoc
			/// @func    capture_input()
			/// @desc    Used to capture the input so no other components try to use an already consumed input.
			/// @self    GUICompCore
			/// @returns {Undefined}
			#endregion
			static capture_input = function() { //log(["capture_input", capture_input]);
				if (__is_child__) {
					__parent__.capture_input()
				}
				
				__user_input__.consumed = true;
			}
			#region jsDoc
			/// @func    update_all_component_positions()
			/// @desc    Updates the locations of all sub components of the top most controller
			/// @self    GUICompHandler
			/// @returns {Real}
			#endregion
			static update_all_component_positions = function() { 
				if (__is_child__) {
					__parent__.update_component_positions();
				}
				else {
					//update_component_positions();
					//if (__is_controller__){
					//	__update_controller_region__();
					//}
					
				}
				
			}
			
			#region GML Events
			#region jsDoc
			/// @func    begin_step()
			/// @desc    Emulates the GML equivalant event.
			/// @self    GUICompCore
			/// @param   {Struct} input : The input struct components pass around to capture inputs
			/// @returns {Undefined}
			#endregion
			static begin_step = function(_input) {}; log(["begin_step", begin_step]);
			#region jsDoc
			/// @func    step()
			/// @desc    Emulates the GML equivalant event.
			/// @self    GUICompCore
			/// @param   {Struct} input : The input struct components pass around to capture inputs
			/// @returns {Undefined}
			#endregion
			static step = function(_input) {}; log(["step", step]);
			#region jsDoc
			/// @func    end_step()
			/// @desc    Emulates the GML equivalant event.
			/// @self    GUICompCore
			/// @param   {Struct} input : The input struct components pass around to capture inputs
			/// @returns {Undefined}
			#endregion
			static end_step = function(_input) {}; log(["end_step", end_step]);
			#region jsDoc
			/// @func    draw_gui_begin()
			/// @desc    Emulates the GML equivalant event.
			/// @self    GUICompCore
			/// @param   {Struct} input : The input struct components pass around to capture inputs
			/// @returns {Undefined}
			#endregion
			static draw_gui_begin = function(_input) {}; log(["draw_gui_begin", draw_gui_begin]);
			#region jsDoc
			/// @func    draw_gui()
			/// @desc    Emulates the GML equivalant event.
			/// @self    GUICompCore
			/// @param   {Struct} input : The input struct components pass around to capture inputs
			/// @returns {Undefined}
			#endregion
			static draw_gui = function(_input) {}; log(["draw_gui", draw_gui]);
			#region jsDoc
			/// @func    draw_gui_end()
			/// @desc    Emulates the GML equivalant event.
			/// @self    GUICompCore
			/// @param   {Struct} input : The input struct components pass around to capture inputs
			/// @returns {Undefined}
			#endregion
			static draw_gui_end = function(_input) {}; log(["draw_gui_end", draw_gui_end]);
			#region jsDoc
			/// @func    cleanup()
			/// @desc    Emulates the GML equivalant event.
			/// @self    GUICompCore
			/// @returns {Undefined}
			#endregion
			static cleanup = function(){}; log(["cleanup", cleanup]);
			#endregion
			
			#region jsDoc
			/// @func    draw_debug()
			/// @desc    This is the debug drawing which is used for development purposes.
			/// @self    GUICompCore
			/// @param   {Undefined}
			#endregion
			static draw_debug = function() { //log(["draw_debug", draw_debug]);
				draw_set_color(c_red)
				draw_rectangle(
						x+region.left,
						y+region.top,
						x+region.right,
						y+region.bottom,
						true
				);
			}
			
		#endregion
		
	#endregion
	
	#region Private
		
		#region Variables
	
			static __GLOBAL_ID__ = 100000; // internally used to keep track of component indexes
			__cid__ = __GLOBAL_ID__++; // used to make sure we dont re add the same component to a controller
			
			__is_controller__ = false; // if the component is accepting sub components
			__is_child__ = false; // if the component is a child of another component
			__parent__ = noone; // a reference to the parent controller
			
			__is_on_focus__ = false; // is currently being interacted with, to prevent draging a slider and clicking a button
			
			__default_user_input__ = {
				consumed : false,
			}
			__user_input__ = json_parse(json_stringify(__default_user_input__));
			
			__shader_u_clips__ = shader_get_uniform(shd_clip_rect, "u_clips");
			
			__event_listeners__ = {}; //the struct which will contain all of the event listener functions to be called when an event is triggered
			__event_listener_uid__ = 0 // a unique identifier for event listeners
			
			__priv_event_listeners__ = {}; //the struct which will contain all of the event listener functions to be called when an event is triggered
			__priv_event_listener_uid__ = 0 // a unique identifier for event listeners
			
			__position_set__ = false;
			
			__internal_x__ = 0;
			__internal_y__ = 0;
			
			__click_held_timer__ = 0;
			
		#endregion
		
		#region Functions
			
			#region GML Events
				#region jsDoc
				/// @func    __begin_step__()
				/// @desc    Internal function to help Emulate the GML equivalant event.
				/// @self    GUICompCore
				/// @param   {Struct} input : The input struct components pass around to capture inputs
				/// @returns {Undefined}
				/// @ignore
				#endregion
				static __begin_step__ = function(_input) { //log(["__begin_step__", __begin_step__]);
					__trigger_event__(self.events.pre_update);
					begin_step(_input);
				}
				#region jsDoc
				/// @func    __step__()
				/// @desc    Internal function to help Emulate the GML equivalant event.
				/// @self    GUICompCore
				/// @param   {Struct} input : The input struct components pass around to capture inputs
				/// @returns {Undefined}
				/// @ignore
				#endregion
				static __step__ = function(_input) { //log(["__step__", __step__]);
					step(_input);
				}
				#region jsDoc
				/// @func    __end_step__()
				/// @desc    Internal function to help Emulate the GML equivalant event.
				/// @self    GUICompCore
				/// @param   {Struct} input : The input struct components pass around to capture inputs
				/// @returns {Undefined}
				/// @ignore
				#endregion
				static __end_step__ = function(_input) { //log(["__end_step__", __end_step__]);
					end_step(_input);
					__trigger_event__(self.events.post_update);
				}
				
				#region jsDoc
				/// @func    __draw_gui_begin__()
				/// @desc    Internal function to help Emulate the GML equivalant event.
				/// @self    GUICompCore
				/// @param   {Struct} input : The input struct components pass around to capture inputs
				/// @returns {Undefined}
				/// @ignore
				#endregion
				static __draw_gui_begin__ = function(_input) { //log(["__draw_gui_begin__", __draw_gui_begin__]);
					draw_gui_begin(_input);
				}
				#region jsDoc
				/// @func    __draw_gui__()
				/// @desc    Internal function to help Emulate the GML equivalant event.
				/// @self    GUICompCore
				/// @param   {Struct} input : The input struct components pass around to capture inputs
				/// @returns {Undefined}
				/// @ignore
				#endregion
				static __draw_gui__ = function(_input) { //log(["__draw_gui__", __draw_gui__]);
					draw_gui(_input);
				}
				#region jsDoc
				/// @func    __draw_gui_end__()
				/// @desc    Internal function to help Emulate the GML equivalant event.
				/// @self    GUICompCore
				/// @param   {Struct} input : The input struct components pass around to capture inputs
				/// @returns {Undefined}
				/// @ignore
				#endregion
				static __draw_gui_end__ = function(_input) { //log(["__draw_gui_end__", __draw_gui_end__]);
		
					draw_gui_end(_input);
		
					xprevious = x;
					yprevious = y;
					
					if (should_draw_debug) {
						draw_debug();
					}
				}
				
				#region jsDoc
				/// @func    __cleanup__()
				/// @desc    Internal function to help Emulate the GML equivalant event.
				/// @self    GUICompCore
				/// @returns {Undefined}
				/// @ignore
				#endregion
				static __cleanup__ = function() { //log(["__cleanup__", __cleanup__]);
					cleanup();
				}
				
			#endregion
			
			#region jsDoc
			/// @func    __region__()
			/// @desc    Constructs a new region struct.
			/// @self    GUICompCore
			/// @param   {Real} left   : The reletive bounding box from the component's x/y
			/// @param   {Real} top    : The reletive bounding box from the component's x/y
			/// @param   {Real} right  : The reletive bounding box from the component's x/y
			/// @param   {Real} bottom : The reletive bounding box from the component's x/y
			/// @returns {Struct.Region}
			#endregion
			static __region__ = function(_l=0, _t=0, _r=0, _b=0) constructor { //log(["__region__", other.__region__]);
				left   = _l;
				top    = _t;
				right  = _r;
				bottom = _b;
				
				#region jsDoc
				/// @func    get_width()
				/// @desc    Returns the width of the region
				/// @self    Struct.region
				/// @returns {Real}
				#endregion
				static get_width = function() {
					return right-left;
				};
				
				#region jsDoc
				/// @func    get_height()
				/// @desc    Returns the height of the region
				/// @self    Struct.region
				/// @returns {Real}
				#endregion
				static get_height = function() {
					return bottom-top;
				};
			}
			
			#region jsDoc
			/// @func    __event_exists__()
			/// @desc    Lightweight check to see if an event exists.
			/// @self    GUICompCore
			/// @param   {String} event_id : One of the component's event IDs, see get_events for more info
			/// @returns {undefined}
			/// @ignore
			#endregion
			static __event_exists__ = function(_event_id) { //log(["__event_exists__", __event_exists__]);
				
				if (variable_struct_exists(self.__event_listeners__, _event_id)) {
					return true
				}
				
				if (variable_struct_exists(self.__priv_event_listeners__, _event_id)) {
					return true
				}
				
				return false;
			}
			
			
			#region jsDoc
			/// @func    __trigger_event__()
			/// @desc    Run the callbacks for the given event lister id. 
			/// @self    GUICompCore
			/// @param   {String} event_id : One of the component's event IDs, see get_events for more info
			/// @param   {Struct} data : The data supplied from the struct, dependant on the component.
			/// @returns {undefined}
			/// @ignore
			#endregion
			static __trigger_event__ = function(_event_id, _data) { //log(["__trigger_event__", __trigger_event__]);
				//leave if the relevant event listener doesnt exist
				var _struct, _func, _event_arr, _size, _i;
				var _hash = _event_id;
				
				#region public event listener
					
					_event_arr = struct_get_from_hash(self.__event_listeners__, _hash)
					if (_event_arr != undefined) {
						_size = array_length(_event_arr);
						
						_i=0; repeat(_size) {
							_struct = _event_arr[_i];
							_struct.func(_data);
						_i+=1;}//end repeat loop
					}
					
				#endregion
				
				#region privat event listener
					
					_event_arr = struct_get_from_hash(self.__priv_event_listeners__, _hash)
					if (_event_arr != undefined) {
						_size = array_length(_event_arr);
						
						_i=0; repeat(_size) {
							_struct = _event_arr[_i];
							_struct.func(_data);
						_i+=1;}//end repeat loop
					}
					
				#endregion
				
			}
			
			#region jsDoc
			/// @func    __add_event_listener_priv__()
			/// @desc    Add a private event listener to the component,
			///          This function will be ran when the event is triggered
			///          These are internally used events components will rely on.
			/// @self    GUICompCore
			/// @param   {String} event_id : The comonent's event you wish to bound this function to.
			/// @param   {Function} func : The function to run when the event is triggered
			/// @returns {Real}
			#endregion
			static __add_event_listener_priv__ = function(_event_id, _func) { //log(["__add_event_listener_priv__", __add_event_listener_priv__]);
				var _hash = _event_id;
				if (struct_get_from_hash(self.__priv_event_listeners__, _hash) == undefined) {
					struct_set_from_hash(self.__priv_event_listeners__, _hash, [])
				}
				
				var _uid = __event_listener_uid__;
				__event_listener_uid__+=1;
				
				var _arr = struct_get_from_hash(self.__priv_event_listeners__, _hash)
				array_push(_arr, {func: _func, UID: _uid});
				struct_set_from_hash(self.__priv_event_listeners__, _hash, _arr)
				
				return _uid
			}
			
			//TODO: Fix this function
			#region jsDoc
			/// @func    __remove_event_listener_priv__()
			/// @desc    Remove a private event listener to the component
			///          These are internally used events components will rely on.
			/// @self    GUICompCore
			/// @param   {real} uid : The Unique ID of a previously added event function returned by add_event_listener.
			/// @returns {Struct.GUICompCore}
			#endregion
			static __remove_event_listener_priv__ = function(_uid) { //log(["__remove_event_listener_priv__", __remove_event_listener_priv__]);
				var _i, _j, _names, _event_arr, _size1, _size2, _struct;
				
				_names = variable_struct_get_names(self.__priv_event_listeners__);
				_size1 = array_length(_names);
				
				_i=0; repeat(_size1) {
					
					_event_arr = self.__priv_event_listeners__[$ _names[_i]];
					_size2 = array_length(_event_arr);
					
					_j=0; repeat(_size2) {
						
						_struct = _event_arr[_j];
						if (_uid == _struct.UID) {
							array_delete(_event_arr, _j, 1);
							self.__priv_event_listeners__[$ _names[_i]] = _event_arr;
							return self;
						}
						
					_j+=1; }; //end inner repeat
					
				_i+=1; }; //end outer repeat
				
				show_error("remove_event_listener : Attempting to remove a UID which doesnt exist", true);
			}
			
			#region jsDoc
			/// @func    __reset_focus__()
			/// @desc    Resets the component from being currently interacted with
			/// @self    GUICompCore
			/// @returns {undefined}
			/// @ignore
			#endregion
			static __reset_focus__ = function() { //log(["__reset_focus__", __reset_focus__]);
				__is_on_focus__ = false;
				__trigger_event__(self.events.on_blur);
			}
			
			#region jsDoc
			/// @func    __find_index_in_parent__()
			/// @desc    Find the child's index inside it's parent. Typically used for updating the Achor point
			/// @self    GUICompCore
			/// @returns {real}
			/// @ignore
			#endregion
			static __find_index_in_parent__ = function() { //log(["__find_index_in_parent__", __find_index_in_parent__]);
				//if we're not a child early out
				if (!__is_child__) { return -1; };
				var _comps = __parent__.__children__;
		
				var _i = 0; repeat(__parent__.__children_count__) {
					if (_comps[_i].__cid__ == __cid__) break;
					_i+=1;
				}
		
				return _i;
			}
			
			#region Surface
				
				static __surface_set_target__ = function() { //log(["__surface_set_target__", __surface_set_target__]);
					
					surface_region = (__is_controller__) ? __controller_region__ : region;
		
		
					//remember the surface to return to
					__parent_surface_target__ = surface_get_target();
		
		
					//reset to the base surface to avoid GML errors
					if (__parent_surface_target__ != -1) {
						surface_reset_target();
					}
		
					//rebuild surface if needed
					if (is_undefined(__component_surface__)) {
						__component_surface__ = surface_create(
								(surface_bbox.right - surface_bbox.left),
								(surface_bbox.bottom - surface_bbox.top)
						)
					}
					else{
						__component_surface__ = __surface_rebuild__(
								__component_surface__,
								(surface_bbox.right - surface_bbox.left),
								(surface_bbox.bottom - surface_bbox.top)
						);
					}
		
					//set and clear our surface
					surface_set_target(__component_surface__);
					draw_clear_alpha(0,0);
				}
				
				static __surface_reset_target__ = function() { //log(["__surface_reset_target__", __surface_reset_target__]);
					//grab the current surface for all checks to use.
					var _current_shader = surface_get_target()
		
		
					// if we're on a surface which isnt our component surface revert to our component surface
					if (_current_shader != -1)
					&& (_current_shader != __component_surface__) {
						surface_reset_target();
						surface_set_target(__component_surface__);
						return;
					}
		
		
					// if we're on our component surface and would like to return to the next surface in the stack
					if (_current_shader == __component_surface__) {
						if (__parent_surface_target__ != -1) {
							surface_reset_target();
							surface_set_target(__parent_surface_target__);
						}
						else{
							surface_reset_target();
				
							///this fixes a bug where surface_free updates the gui size, but does not update the
							// display_get_gui_{width / height} functions. this is a hotfix for an issue with
							//  IDE v2022.3.0.625  Runtime v2022.3.0.497
							display_set_gui_size(display_get_gui_width(), display_get_gui_height());
						}
			
						return;
					}
		
					//if we're on the application surface, and the parent is on the application surface, then a dev called this at the wrong time
					var _err_msg = "Trying to __surface_reset_target__ when current surface is \""+string(_current_shader)+"\" and the parent surface is \""+string(__parent_surface_target__)+"\""
					show_error(_err_msg, true)
		
				}
				
				static __draw_component_surface__ = function(_x=x, _y=y) { //log(["__draw_component_surface__", __draw_component_surface__]);
		
					draw_surface_stretched_ext(
							__component_surface__,
							_x+surface_bbox.left,
							_y+surface_bbox.top,
							(surface_bbox.right - surface_bbox.left),
							(surface_bbox.bottom - surface_bbox.top),
							c_white, 1
					);
					
				}
				
			#endregion
			
			#region Shader
				
				#region jsDoc
				/// @func    __shader_set__()
				/// @desc    Internally used for setting the clipped region drawing, great for scroll regions inside regions
				/// @self    GUICompCore
				/// @returns {Undefined}
				/// @ignore
				#endregion
				static __shader_set__ = function(_custom_region = undefined) { //log(["__shader_set__", __shader_set__]);
					//this function is only intended for the component systems internal clipping handling.
					if (is_undefined(_custom_region)) {
						__clip_region__ = (__is_controller__) ? __controller_region__ : region;
					}
					else {
						__clip_region__ = _custom_region;
					}
					
					
					//remember the shader to return to
					__parent_shader_target__ = shader_current();
					
					
					//reset to the base shader to avoid GML errors
					if (__parent_shader_target__ != -1) {
						shader_reset();
						if (__is_child__) {
							var _par = __parent__;
							var _par_clip = _par.__clip_region__;
							__clip_region__.left = x - min(x-__clip_region__.left, _par.x-_par_clip.left);
							__clip_region__.right = x - max(x+__clip_region__.right, _par.x+_par_clip.right);
							__clip_region__.top = y - min(y-__clip_region__.top, _par.y-_par_clip.top);
							__clip_region__.bottom = y - max(y+__clip_region__.bottom, _par.y+_par_clip.bottom);
						}
					}
					
					//set our Shader and uniform
					shader_set(shd_clip_rect);
					shader_set_uniform_f(
						__shader_u_clips__,
						x + __clip_region__.left,
						y + __clip_region__.top,
						x + __clip_region__.right,
						y + __clip_region__.bottom
					);
				}
				
				#region jsDoc
				/// @func    __shader_reset__()
				/// @desc    Internally used for reseting the clipped region drawing, great for scroll regions inside regions
				/// @self    GUICompCore
				/// @returns {Undefined}
				/// @ignore
				#endregion
				static __shader_reset__ = function() { //log(["__shader_reset__", __shader_reset__]);
					
					//grab the current shader for all checks to use.
					var _current_shader = shader_current();
		
					// if we're using a shader
					if (_current_shader != -1) {
						//reset and set our shader back to the parent's values
						shader_reset();
							
						if (__is_child__)
						&& (__parent_shader_target__) {
							
							shader_set(__parent_shader_target__);
							with (__parent__) {
								shader_set_uniform_f(
									__shader_u_clips__,
									x-__clip_region__.left,
									y-__clip_region__.top,
									x+__clip_region__.right,
									y+__clip_region__.bottom
								);
							}
						}
						
						return;
					}
					
					
					
					var _err_msg = "Trying to __shader_reset__ when there is no currently active shader.";
					show_error(_err_msg, true);
				}
				
			#endregion
			
			#region jsDoc
			/// @func    __handle_click__()
			/// @desc    This handle all of the monotinous click code which is reused all over the place. If you need a component to do something when a click the component has been clicked, see "add_event_listener" or "__add_event_listener_priv__".
			/// @self    GUICompCore
			/// @param   {Struct.Input} input : The input struct containing passed around data between components.
			#endregion
			static __handle_click__ = function(_input) { //log(["__handle_click__", __handle_click__]);
				
				var _input_captured = _input.consumed
				
				//capture input if we still have focus
				if (__is_on_focus__)
				&& (is_enabled) {
					capture_input();
				}
				
				//early out if we're disabled
				if (!is_enabled) {
					__reset_focus__();
					return;
				}
				
				//run the internal step
				if (!_input_captured)
				&& (mouse_on_comp()) {
					capture_input();
					
					//trigger the event for mouse over
					__trigger_event__(self.events.mouse_over);
					
					image.index = GUI_IMAGE_HOVER;
					
					//mouse button checks
					if (mouse_check_button_pressed(mb_left)) {
						__is_on_focus__ = true;
						image.index = GUI_IMAGE_CLICKED;
						__click_held_timer__ = 0;
						__trigger_event__(self.events.pressed);
						__trigger_event__(self.events.on_focus);
					}
					else if (__is_on_focus__) && (mouse_check_button(mb_left)) {
						image.index = GUI_IMAGE_CLICKED;
						__trigger_event__(self.events.held);
						
						__click_held_timer__ += 1;
						if (__click_held_timer__ > game_get_speed(gamespeed_fps)/3)
						&& (__click_held_timer__  % floor(game_get_speed(gamespeed_fps)/30) == 0) {
							__trigger_event__(self.events.long_press);
						}
					}
					else if (__is_on_focus__) && (mouse_check_button_released(mb_left)) {
						__reset_focus__();
						__click_held_timer__ = 0;
						image.index = GUI_IMAGE_HOVER;
						__trigger_event__(self.events.released);
						__trigger_event__(self.events.on_blur);
					}
					
				}
				else {
					image.index = GUI_IMAGE_ENABLED;
					if (__is_on_focus__) && (mouse_check_button_released(mb_left)) {
						__reset_focus__();
						__trigger_event__(self.events.on_blur);
					}
				}
				
			}
			
			#region jsDoc
			/// @func    __set_sprite__()
			/// @desc    Define all of the built in GML object variables for the supplied sprite
			/// @self    GUICompCore
			/// @param   {Asset.GMSprite} sprite : The sprite to apply to the component, and to get the values from.
			/// @returns {Struct.GUICompCore}
			#endregion
			static __set_sprite__ = function(_sprite) { //log(["__set_sprite__", __set_sprite__]);
				/// NOTE: These are the default structure of GUI button sprites
				/// image.index[0] = idle; no interaction;
				/// image.index[1] = mouse over; the mouse is over it;
				/// image.index[2] = mouse down; actively being pressed;
				/// image.index[3] = disabled; not allowed to interact with;
				
				// sorry everything is dirty looking
				// feather really doesnt want us to write to these variables.
				// and linux YYC builds throw errors on compile
				
				self.sprite.index = _sprite;
				
				self.sprite.height  = self.image.yscale * sprite_get_height(_sprite);
				self.sprite.width   = self.image.xscale * sprite_get_width(_sprite);
				self.sprite.xoffset = self.image.xscale * sprite_get_xoffset(_sprite);
				self.sprite.yoffset = self.image.yscale * sprite_get_yoffset(_sprite);
				
				self.image.index  = 0;
				self.image.number = sprite_get_number(_sprite);
				self.image.speed  = sprite_get_speed(_sprite);
				
				self.visible = true;
				
				return self;
			}
		#endregion
		
	#endregion
	
}
