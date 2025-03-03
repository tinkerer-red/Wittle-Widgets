#region jsDoc
/// @func    WWCore()
/// @desc    This is the root most component, only use this if you need a very basic component for drawing purposes or if you're creating a new component.
/// @param   {Real} x : The x possition of the component on screen.
/// @param   {Real} y : The y possition of the component on screen.
/// @returns {Struct.WWCore}
#endregion
function WWCore() constructor {
	debug_name = "WWCore";
	
	#region Public
		
		#region Builder Functions
			
			#region Position and Size
			#region jsDoc
			/// @func    set_position()
			/// @desc    Publicly sets the position of the component, recording the user's preferred position.
			///          The component’s x and y coordinates are updated relative to the parent controller and its anchor.
			/// @self    WWCore
			/// @param   {Real} x : The x of the component.
			/// @param   {Real} y : The y of the component.
			/// @returns {Struct.WWCore}
			#endregion
			static set_position = function(_x, _y) {
				if (__position_set__ == false) {
					__position_set__ = true;
					self.xstart = self.x;
					self.ystart = self.y;
				}
				__set_position__(_x, _y);
				return self;
			}
			#region jsDoc
			/// @func    set_size()
			/// @desc    Sets the component's size (i.e., its interactive boundaries) as specified by the user.  
			///          This updates the region and marks the size as user–preferred so that future internal updates won’t override it.
			/// @self    WWCore
			/// @param   {real} left : The left side of the bounding box
			/// @param   {real} top : The top side of the bounding box
			/// @param   {real} right : The right side of the bounding box
			/// @param   {real} bottom : The bottom side of the bounding box
			/// @returns {Struct.WWCore}
			#endregion
			static set_size = function(_width, _height) {
				__size_set__ = true;
				__set_size__(_width, _height);
				return self;
			}
			#region jsDoc
			/// @func    set_offset()
			/// @desc    Sets the anchor of the component, This anchor will depict how the component is attached to the parent controller when resizing
			/// @self    WWCore
			/// @param   {Real} x : The x anchor of the component.
			/// @param   {Real} y : The y anchor of the component.
			/// @returns {Struct.WWCore}
			#endregion
			static set_offset = function(_x, _y) {
				__offset_set__ = true;
				__set_offset__(_x, _y);
				return self;
			}
			#region jsDoc
			/// @func    set_alignment()
			/// @desc    Sets how the component will anchor to it's parent. Note: Some parent controllers will ignore this value if they see fit.
			/// @self    WWCore
			/// @param   {Constant.HAlign} halign : Horizontal alignment.
			/// @param   {Constant.VAlign} valign : Vertical alignment.
			/// @returns {Struct.WWCore}
			#endregion
			static set_alignment = function(_halign=fa_left, _valign=fa_top) {
				
				halign = _halign;
				valign = _valign;
				
				return self;
			}
			#region jsDoc
			/// @func    set_width()
			/// @desc    Sets the width of the component
			/// @self    WWCore
			/// @param   {Real} width : The width of the component.
			/// @returns {Struct.WWCore}
			#endregion
			static set_width = function(_width) {
				self.set_size(_width, height)
				
				return self;
			}
			#region jsDoc
			/// @func    set_height()
			/// @desc    Sets the height of the component
			/// @self    WWCore
			/// @param   {Real} height : The height of the component.
			/// @returns {Struct.WWCore}
			#endregion
			static set_height = function(_height) {
				self.set_size(width, _height)
				
				return self;
			}
			
			#endregion
			#region Sprite
			#region jsDoc
			/// @func    set_sprite()
			/// @desc    Sets all default GML object's sprite variables with a given sprite.
			/// @self    WWCore
			/// @param   {Asset.GMSprite} sprite : The sprite to apply to the component.
			/// @returns {Struct.WWCore}
			#endregion
			static set_sprite = function(_sprite) {
				__set_sprite__(_sprite);
				return self;
			}
			#region jsDoc
			/// @func    set_sprite_angle()
			/// @desc    Sets the angle of the sprite to be drawn.
			/// @self    WWCore
			/// @param   {Real} angle : The angle of the sprite.
			/// @returns {Struct.WWCore}
			#endregion
			static set_sprite_angle = function(_angle) {
				image_angle = _angle;
				return self;
			}
			#region jsDoc
			/// @func    set_sprite_color()
			/// @desc    Sets the color of the sprite to be drawn.
			/// @self    WWCore
			/// @param   {Real} color : The color of the sprite.
			/// @returns {Struct.WWCore}
			#endregion
			static set_sprite_color = function(_col) {
				image_blend = _col;
				return self;
			}
			#region jsDoc
			/// @func    set_sprite_alpha()
			/// @desc    Sets the alpha of the sprite to be drawn.
			/// @self    WWCore
			/// @param   {Real} alpha : The alpha of the sprite.
			/// @returns {Struct.WWCore}
			#endregion
			static set_sprite_alpha = function(_alpha) {
				image_alpha = _alpha;
				return self;
			}
			#region jsDoc
			/// @func    set_background_color()
			/// @desc    Sets the color of the background.
			/// @self    WWCore
			/// @param   {Real} color : The color of the background.
			/// @returns {Struct.WWCore}
			#endregion
			static set_background_color = function(_col) {
				background_color_set = true;
				background_color = _col;
				return self;
			}
			
			#endregion
			
			
			#region jsDoc
			/// @func    set_enabled()
			/// @desc    Enable or Disable the Component, This usually effects how some components are handled in terms of greying out a component.
			/// @self    WWCore
			/// @param   {Bool} is_enabled : If the component should be enabled or not.
			/// @returns {Struct.WWCore}
			#endregion
			static set_enabled = function(_is_enabled) {
				if (is_enabled == _is_enabled) return self;
				
				is_enabled = _is_enabled;
				
				if (!__is_empty__) {
					var _comp;
					var _i=0; repeat(__children_count__) {
						_comp = __children__[_i];
						_comp.set_enabled(_is_enabled);
					_i+=1;}//end repeat loop
				}
				
				if (is_enabled) {
					trigger_event(self.events.enabled);
				}
				else {
					trigger_event(self.events.disabled);
				}
				
				return self;
			}
			#region jsDoc
			/// @func    set_active()
			/// @desc    Activate of Deactivate the Component from executing any of it's code. This will also prevent all subcomponets code from running.
			/// @self    WWCore
			/// @param   {Bool} is_enabled : If the component should be enabled or not.
			/// @returns {Struct.WWCore}
			#endregion
			static set_active = function(_is_active) {
				if (is_active == _is_active) return self;
				
				is_active = _is_active;
				
				if (is_active) {
					trigger_event(self.events.activated);
				}
				else {
					trigger_event(self.events.deactivated);
				}
				
				return self;
			}
			
		#endregion
		
		#region Events
			
			events = {};
			static on_event = function(_event, _func) {
				var _hash = is_string(_event) ? variable_get_hash(_event) : _event;
				add_event_listener(_hash, _func);
				return self;
			}
			
			
			#region Focus/Blur
			events.focus     = variable_get_hash("focus"); //triggered when the component gets focus, this commonly occurs when the mouse is clicked down on it.
			events.is_focused = variable_get_hash("is_focused"); //triggered when the component gets focus, this commonly occurs when the mouse is clicked down on it.
			events.blur      = variable_get_hash("blur");  //triggered when the component loses focus, this commonly occurs when the mouse is clicked down off it, or when the mouse is released off it.
			events.is_blurred = variable_get_hash("is_blurred"); //triggered when the component gets focus, this commonly occurs when the mouse is clicked down on it.
			static on_focus = function(_func) {
				add_event_listener(events.focus, _func);
				return self;
			}
			static on_is_focused = function(_func) {
				add_event_listener(events.is_focused, _func);
				return self;
			}
			static on_blur = function(_func) {
				add_event_listener(events.blur, _func);
				return self;
			}
			static on_is_blurred = function(_func) {
				add_event_listener(events.is_blurred, _func);
				return self;
			}
			#endregion
			
			#region Click Handling
			events.pressed    = variable_get_hash("pressed");
			events.held       = variable_get_hash("held");
			events.long_press = variable_get_hash("long_press");
			events.released   = variable_get_hash("released");
			events.double_click = variable_get_hash("double_click");
			static on_pressed = function(_func) {
				add_event_listener(events.pressed, _func);
				return self;
			}
			static on_held = function(_func) {
				add_event_listener(events.held, _func);
				return self;
			}
			static on_long_press = function(_func) {
				add_event_listener(events.long_press, _func);
				return self;
			}
			static on_released = function(_func) {
				add_event_listener(events.released, _func);
				return self;
			}
			static on_double_click = function(_func) {
				add_event_listener(events.double_click, _func);
				return self;
			}
			#endregion
			#region Step/Draw
			events.pre_step  = variable_get_hash("pre_step"); //triggered every frame before the begin step event is activated
			events.post_step = variable_get_hash("post_step"); //triggered every frame after the end step event is activated
			static on_pre_step = function(_func) {
				add_event_listener(events.pre_step, _func);
				return self;
			}
			static on_post_step = function(_func) {
				add_event_listener(events.post_step, _func);
				return self;
			}
			
			events.pre_draw    = variable_get_hash("pre_draw"); //triggered every frame after the end step event is activated
			events.post_draw   = variable_get_hash("post_draw"); //triggered every frame after the end step event is activated
			static on_pre_draw = function(_func) {
				add_event_listener(events.pre_draw, _func);
				return self;
			}
			static on_post_draw = function(_func) {
				add_event_listener(events.post_draw, _func);
				return self;
			}
			#endregion
			
			#region Mouse Over/Off
			events.mouse_over = variable_get_hash("mouse_over");
			events.mouse_off = variable_get_hash("mouse_off");
			static on_mouse_over = function(_func) {
				add_event_listener(events.mouse_over, _func);
				return self;
			}
			static on_mouse_off = function(_func) {
				add_event_listener(events.mouse_off, _func);
				return self;
			}
			
			events.mouse_over_group = variable_get_hash("mouse_over_group"); //triggered every frame the mouse is over the controller region bounding box, This will be a square box encapsulating all sub components.
			events.mouse_off_group = variable_get_hash("mouse_off_group"); //triggered every frame the mouse is over the controller region bounding box, This will be a square box encapsulating all sub components.
			static on_mouse_off_group = function(_func) {
				add_event_listener(events.mouse_off_group, _func);
				return self;
			}
			
			#endregion
			
			events.interact    = variable_get_hash("interact"); //triggered when the component gets focus, this commonly occurs when the mouse is clicked down on it.
			static on_interact = function(_func) {
				add_event_listener(events.interact, _func);
				return self;
			}
			
			events.enabled     = variable_get_hash("enabled"); //triggered when the component is enabled (this is done by the developer)
			events.disabled    = variable_get_hash("disabled"); //triggered when the component is disabled (this is done by the developer)
			static on_enable = function(_func) {
				add_event_listener(events.enabled, _func);
				return self;
			}
			static on_disabled = function(_func) {
				add_event_listener(events.disabled, _func);
				return self;
			}
			
			events.activated   = variable_get_hash("activated"); //triggered when the component is enabled (this is done by the developer)
			events.deactivated = variable_get_hash("deactivated"); //triggered when the component is disabled (this is done by the developer)
			static on_activated = function(_func) {
				add_event_listener(events.activated, _func);
				return self;
			}
			static on_deactivated = function(_func) {
				add_event_listener(events.deactivated, _func);
				return self;
			}
			
			
		#endregion
		
		#region Variables
			
			is_enabled = true; //if the component is in a enabled/disabled state, typically if you want to grey out a button
			is_active  = true; //is the component's code is being executed
			
			halign = fa_left;
			valign = fa_top;
			
			background_color_set = false;
			background_color = c_black;
			
			//each component will have it's own events these will always be listed in this region
			
			#region GML Variables
				self.depth = 0;
				
				self.x = 0;
				self.y = 0;
				self.width = 0;
				self.height = 0;
				
				self.xstart = 0;
				self.ystart = 0;
				
				self.xprevious = 0;
				self.yprevious = 0;
				
				self.x_offset = 0;
				self.y_offset = 0;
				
				self.sprite_index   = -1;
				self.sprite_height  = 0;
				self.sprite_width   = 0;
				self.sprite_xoffset = 0;
				self.sprite_yoffset = 0;
				
				self.visible = true;
				
				self.image_alpha  = 1;
				self.image_angle  = 0;
				self.image_blend  = c_white;
				self.image_index  = -1;
				self.image_number = 0;
				self.image_speed  = 0;
				self.image_xscale = 1;
				self.image_yscale = 1;
				
			#endregion
			
		#endregion
	
		#region Functions
			
			#region Event Functions
			
			#region jsDoc
			/// @func    trigger_event()
			/// @desc    Run the callbacks for the given event lister id. 
			/// @self    WWCore
			/// @param   {String} event_id : One of the component's event IDs, see get_events for more info
			/// @param   {Struct} data : The data supplied from the struct, dependant on the component.
			/// @returns {undefined}
			/// @ignore
			#endregion
			static trigger_event = function(_event_id, _data=undefined) {
				var _event_arr = struct_get_from_hash(self.__event_listeners__, _event_id)
				if (_event_arr != undefined) {
					var _size = array_length(_event_arr);
					
					var _i=0; repeat(_size) {
						var _struct = _event_arr[_i];
						_struct.func(_data);
					_i+=1;}//end repeat loop
				}
				
			}
			#region jsDoc
			/// @func    add_event_listener()
			/// @desc    Add an event listener to the component,
			///          This function will be ran when the event is triggered
			/// @self    WWCore
			/// @param   {String} event_id : The comonent's event you wish to bound this function to.
			/// @param   {Function} func : The function to run when the event is triggered
			/// @returns {Real}
			#endregion
			static add_event_listener = function(_event_id, _func) {
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
			#region jsDoc
			/// @func    insert_event_listener()
			/// @desc    Insert an event listener to the component,
			///          This function will be ran when the event is triggered
			/// @self    WWCore
			/// @param   {Real} index : The index to insert the event handler
			/// @param   {String} event_id : The comonent's event you wish to bound this function to.
			/// @param   {Function} func : The function to run when the event is triggered
			/// @returns {Real}
			#endregion
			static insert_event_listener = function(_index, _event_id, _func) {
				var _hash = _event_id;
				if (struct_get_from_hash(self.__event_listeners__, _hash) == undefined) {
					struct_set_from_hash(self.__event_listeners__, _hash, [])
				}
				
				var _uid = __event_listener_uid__;
				__event_listener_uid__+=1;
				var _arr = struct_get_from_hash(self.__event_listeners__, _hash)
				array_insert(_arr, _index, {func: _func, UID: _uid});
				struct_set_from_hash(self.__event_listeners__, _hash, _arr)
				
				return _uid
			}
			#region jsDoc
			/// @func    remove_event_listener()
			/// @desc    Remove an event listener to the component
			/// @self    WWCore
			/// @param   {real} uid : The Unique ID of a previously added event function returned by add_event_listener.
			/// @returns {Struct.WWCore}
			#endregion
			static remove_event_listener = function(_uid) {
				
				var _event_names = get_events();
				var _i=0; repeat(array_length(_event_names)) {
					
					var _event_arr = __event_listeners__[$ _event_names[_i]];
					var _size = array_length(_event_arr);
					var _j=0; repeat(_size) {
						var _struct = _event_arr[_j];
						if (_uid == _struct.UID) {
							break;
						}
					_j+=1;}//end repeat loop
					
					if (_j < _size) {
						array_delete(_event_arr, _i, 1);
						struct_set_from_hash(self.__event_listeners__, _hash, _event_arr)
						return self;
					}
					else{
						show_error("remove_event_listener : Attempting to remove a UID which doesnt exist", true);
					}
					
				_i+=1;}//end repeat loop
				
			}
			#region jsDoc
			/// @func    get_events()
			/// @desc    With this function you can retrieve an array populated with the names of the component's events.
			/// @self    WWCore
			/// @returns {Array<String>}
			#endregion
			static get_events = function() {
				return variable_struct_get_names(events)
			}
			#region jsDoc
			/// @func    event_exists()
			/// @desc    Lightweight check to see if an event exists.
			/// @self    WWCore
			/// @param   {String} event_id : One of the component's event IDs, see get_events for more info
			/// @returns {undefined}
			/// @ignore
			#endregion
			static event_exists = function(_event_id) {
				return struct_exists_from_hash(self.__event_listeners__, _event_id)
			}
			static event_name = function(_event_id) {
				var _names = struct_get_names(events);
				var _len = array_length(_names)
				var _i=0; repeat(_len) {
					var _name = _names[_i];
					if (struct_get(events, _name) == _event_id) {
						return _name;
					}
				_i++}
			}
			
			#endregion
			
			#region Overlay Functions
			
			static add_overlay = function(_id, _component, _depth) {
				
			}
			static remove_overlay = function(_id) {
				
			}
			
			#endregion
			
			#region Getter Functions
			
			#region jsDoc
			/// @func    get_functions()
			/// @desc    With this function you can retrieve an array populated with the names of the component's functions. Useful for learning what available public functions you have access to.
			/// @self    WWCore
			/// @returns {Array<String>}
			#endregion
			static get_functions = function() {
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
			/// @self    WWCore
			/// @returns {Array<String>}
			#endregion
			static get_builder_functions = function() {
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
			/// @func    get_children_count()
			/// @desc    Returns the number of children this component directly controls. This will not include children of children.
			/// @self    WWController
			/// @returns {Real}
			#endregion
			static get_children_count = function() {
				return __children_count__;
			}
			#region jsDoc
			/// @func    get_sub_children_count()
			/// @desc    Returns the number of all children. This will include all children of children.
			/// @self    WWController
			/// @returns {Real}
			#endregion
			static get_sub_children_count = function() {
				var _comp;
				var _children_count = 0;
				
				var _i=0; repeat(__children_count__) {
					_comp = __children__[_i];
					_children_count += _comp.get_sub_children_count();
				_i+=1;}//end repeat loop
				
				return _children_count;
			}
			#region jsDoc
			/// @func    get_children()
			/// @desc    Returns an array of the children
			/// @self    WWController
			/// @returns {Array<Struct>}
			#endregion
			static get_children = function() {
				return __children__
			}
			
			#endregion
			
			#region Input Functions
			
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
					if (__parent__.__mouse_on_comp__) {
						return false;
					}
				}
				
				__mouse_on_group__ = point_in_rectangle(
						device_mouse_x_to_gui(0),
						device_mouse_y_to_gui(0),
						x,
						y,
						x+__group__.width,
						y+__group__.height
				);
				
				if (__mouse_on_group__) {
					trigger_event(self.events.mouse_over_group);
				}
				else {
					trigger_event(self.events.mouse_off_group);
				}
				
				return __mouse_on_group__;
			}
			#region jsDoc
			/// @func    consume_input()
			/// @desc    Used to capture the input so no other components try to use an already consumed input.
			/// @self    WWCore
			/// @returns {Undefined}
			#endregion
			static consume_input = function() {
				__user_input__.consumed = true;
			}
			
			#endregion
			
			#region Sub Component Functions
			
			#region jsDoc
			/// @func    add()
			/// @desc    Add a Component to the controller.
			/// @self    WWController
			/// @param   {Struct.WWCore|Array} comp : The component you wish to add to the controller.
			/// @returns {Undefined}
			#endregion
			static add = function(_comp) {
				__is_empty__ = false;
				
				var _arr = (is_array(_comp)) ? _comp : [_comp];
				
				if (argument_count > 1) {
					for(var _i=1; _i<argument_count; _i++) {
						array_push(_arr, argument[_i])
					}
				}
				
				__validate_component_additions__(_arr);
				
				__include_children__(_arr, -1);
				
				update_component_positions();
				__update_group_region__();
				
			}
			#region jsDoc
			/// @func    insert()
			/// @desc    Inserts a Component into the controller's children array.
			/// @self    WWController
			/// @param   {Real} index : The index (possition) you wish to insert the component into the children array
			/// @param   {Struct.WWCore|Array} comp : The component you wish to add to the controller.
			/// @returns {Undefined}
			#endregion
			static insert = function(_index, _comp) {
				__is_empty__ = false;
				
				var _arr = (is_array(_comp)) ? _comp : [_comp];
				
				__validate_component_additions__(_arr);
				
				__include_children__(_comp, _index)
				
				__update_group_region__();
				
				return __children_count__;
			}
			#region jsDoc
			/// @func    remove()
			/// @desc    Remove a Child Component from the children array.
			/// @self    WWController
			/// @param   {Real} comp : The component you wish to remove from the controller's children array.
			/// @returns {Undefined}
			#endregion
			static remove = function(_comp) {
				var _index = array_get_index(__children__, _comp);
				if (_index == -1) return;
				remove_index(_index);
			}
			#region jsDoc
			/// @func    remove_index()
			/// @desc    Remove a Child Component from the children array by it's index.
			/// @self    WWController
			/// @param   {Real} index : The index of the component you wish to remove from the controller's children array.
			/// @returns {Undefined}
			#endregion
			static remove_index = function(_index) {
				//remove the component
				array_delete(__children__, _index, 1);
				__children_count__--;
				
				update_component_positions(); // we update for stacked components such as folders, dropdowns, combo boxes, radios, etc
				__update_group_region__();
				if (__children_count__ == 0) {__is_empty__ = true; };
			}
			#region jsDoc
			/// @func    find()
			/// @desc    Find the index of the given component. Will return -1 if the component was not found.
			/// @self    WWController
			/// @param   {Struct.WWController} component : The component you wish to find the index of.
			/// @returns {Real}
			#endregion
			static find = function(_comp) {
				//Find it in the list
				var _i = 0; repeat(__children_count__) {
					if (__children__[_i].__comp_id__ == _comp.__comp_id__) {
						return _i;
					}
				_i+=1;}//end repeat loop
				return -1;
			}
			#region jsDoc
			/// @func    update_component_positions()
			/// @desc    Updates the locations of all sub components of the top most controller
			/// @self    WWHandler
			/// @returns {Real}
			#endregion
			static update_component_positions = function() {
				if (!__is_empty__) {
					//move the children
					var _i=0; repeat(__children_count__) {
						var _comp = __children__[_i];
						
						var _xx = __get_controller_archor_x__(_comp.halign);
						var _yy = __get_controller_archor_y__(_comp.valign);
						
						_comp.x = self.x + _xx + _comp.x_offset;
						_comp.y = self.y + _yy + _comp.y_offset;
						
						//if the component is a controller it's self have it update it's children
						_comp.update_component_positions();
					_i+=1;}//end repeat loop
					
				}
			}
			
			#region jsDoc
			/// @func    clear_children()
			/// @desc    Clears all children from the children array, deleting their structs and running their cleanup events. Use this when you are deleting components.
			/// @self    WWController
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
			
			
			#endregion
			
			#region GML Events
			
			#region jsDoc
			/// @func    step()
			/// @desc    Emulates the GML equivalant event.
			/// @self    WWCore
			/// @param   {Struct} input : The input struct components pass around to capture inputs
			/// @returns {Undefined}
			#endregion
			static step = function(_input=undefined) {
				_input ??= {
					consumed : false,
				};
				__user_input__ = _input;
				__mouse_on_group__ = mouse_on_group();
				
				trigger_event(self.events.pre_step, _input);
				
				//run the children
				var _comp, xx, yy;
				var _i=__children_count__; repeat(__children_count__) { _i--;
					_comp = __children__[_i];
					_comp.step(_input);
				}//end repeat loop
				
				trigger_event(self.events.post_step, _input);
			};
			#region jsDoc
			/// @func    draw()
			/// @desc    Emulates the GML equivalant event.
			/// @self    WWCore
			/// @param   {Struct} input : The input struct components pass around to capture inputs
			/// @returns {Undefined}
			#endregion
			static draw = function(_input=undefined, _debug=false) {
				_input ??= {
					consumed : false,
				};
				__user_input__ = _input;
				__mouse_on_group__ = mouse_on_group();
				
				if (background_color_set) {
					draw_sprite_stretched_ext(
						s9GUIPixel,
						0,
						x,
						y,
						width,
						height,
						background_color,
						1
					);
				}
				
				trigger_event(self.events.pre_draw, _input);
				
				//run the children
				var _comp, xx, yy;
				var _i=0; repeat(__children_count__) {
					_comp = __children__[_i];
					_comp.draw(_input, _debug);
				_i+=1;}//end repeat loop
				
				if (_debug) {
					draw_set_alpha(0.2)
					#region Comp Region
					draw_set_color(c_red)
					draw_rectangle(
						x,
						y,
						x + width,
						y + height,
						true
					);
					draw_line(
						x,
						y,
						x + width,
						y + height
					)
					draw_line(
						x + width,
						y,
						x,
						y + height
					)
					#endregion
					#region Pointers
					draw_set_color(c_orange)
					//connect comp and group corners
					draw_line(x,       y,                    x,       y);
					draw_line(x+width, y,                    x+width, y);
					draw_line(x,       y + __group__.height, x,       y + height);
					draw_line(x+width, y + __group__.height, x+width, y + height);
					//connect children to parent
					if (__is_child__) {
						draw_line(
							__parent__.x,
							__parent__.y,
							x,
							y
						)
					}
					#endregion
					#region Group Region
					draw_set_color(c_yellow)
					draw_rectangle(
							x,
							y,
							x+__group__.width,
							y+__group__.height,
							true
					);
					draw_line(
						x,
						y,
						x+__group__.width,
						y+__group__.height
					)
					draw_line(
						x+__group__.width,
						y,
						x,
						y+__group__.height
					)
					#endregion
					//draw_text(x,y, $"__mouse_on_group__ :: {__mouse_on_group__}\n__mouse_on_comp__ :: {__mouse_on_comp__}")
					draw_set_alpha(1)
				}
				
				trigger_event(self.events.post_draw, _input);
			};
			
			#endregion
			
		#endregion
		
	#endregion
	
	#region Private
		
		#region Variables
			
			static __GLOBAL_ID__ = 100000; // internally used to keep track of component indexes
			__comp_id__ = __GLOBAL_ID__++; // used to make sure we dont re add the same component to a controller
			__previous_scissor__ = undefined;
			
			
			#region Event Variables
			__event_listeners__ = {}; //the struct which will contain all of the event listener functions to be called when an event is triggered
			__event_listener_uid__ = 0; // a unique identifier for event listeners
			#endregion
			#region Input Variables
			__default_user_input__ = {
				consumed : false,
			}
			__user_input__ = json_parse(json_stringify(__default_user_input__));
			__mouse_on_comp__  = false;
			__mouse_on_group__ = false;
			__click_held_timer__ = 0;
			__is_interacting__ = false; // is currently being interacted with, to prevent draging a slider and clicking a button at the same time
			__is_focused__ = false; // is currently the component capturing the input
			
			#endregion
			#region Sub Component Variables
			__is_empty__ = true;
			__children_count__ = 0;
			__children__ = [];
			__is_child__ = false; // if the component is a child of another component
			__parent__ = noone; // a reference to the parent controller
			__group__ = {width : 0, height : 0};
			#endregion
			#region Misc
			__position_set__ = false;
			__offset_set__   = false;
			__size_set__     = false;
			#endregion
			
		#endregion
		
		#region Functions
			#region Input Priv Functions
			#region jsDoc
			/// @func    __reset_focus__()
			/// @desc    Resets the component from being currently interacted with
			/// @self    WWCore
			/// @returns {undefined}
			/// @ignore
			#endregion
			static __reset_focus__ = function() {
				if (__is_interacting__) {
					__is_interacting__ = false;
					trigger_event(self.events.blur);
				}
			}
			
			#region jsDoc
			/// @func    __handle_interaction__()
			/// @desc    Handles input interactions for buttons and sliders.
			/// @self    WWCore
			/// @param   {Struct.Input} _input : The input struct containing shared data.
			/// @param   {Bool} _keep_focus : If true, retains focus even if the mouse moves off (for sliders).
			/// @param   {Bool} _use_value : If true, passes `self.value` to the held/released events (for sliders).
			#endregion
			static __handle_interaction__ = function(_input) {
				// Early exit if disabled
			    if (is_enabled) {
			        
				    var _input_captured = _input.consumed;
					var _mouse_on_comp = mouse_on_comp();
					
					
					//handle focus/bluring
					if (_mouse_on_comp) {
						consume_input();
						
						if (!__is_focused__) {
							__is_focused__ = true;
							trigger_event(self.events.focus);
						}
						trigger_event(self.events.is_focused);
					}
					else {
						if (__is_focused__) {
							__is_focused__ = false;
							trigger_event(self.events.blur);
						}
						trigger_event(self.events.is_blurred);
					}
					
					
					//handle input
					if (!_input_captured) {
						if (_mouse_on_comp) {
							
							if (mouse_check_button_pressed(mb_left)) {
					            __is_interacting__ = true;
					            __click_held_timer__ = current_time;
					            trigger_event(self.events.pressed);
					        }
							
							else if (__is_interacting__ && mouse_check_button(mb_left)) {
					            trigger_event(self.events.held);
						
					            // Handle long press timing
					            __click_held_timer__ += 1;
					            if (current_time-__click_held_timer__ > 1_000/3) {
					                trigger_event(self.events.long_press);
					            }
					        }
							
							else if (__is_interacting__ && mouse_check_button_released(mb_left)) {
					            __reset_focus__();
					            trigger_event(self.events.released);
					        }
						}
						else {
							if (__is_interacting__ && mouse_check_button_released(mb_left)) {
					            __reset_focus__();
					        }
						}
					}
					else {
						if (__is_interacting__ && mouse_check_button_released(mb_left)) {
				            __reset_focus__();
				        }
					}
				}
				else {
					if (__is_interacting__) {
			            __reset_focus__();
			        }
				}
				
				if (__is_interacting__) {
					trigger_event(self.events.interact);
				}
			}
			
			#endregion
			#region Event Priv Functions
			
			#endregion
			#region Sub Component Priv Functions
			#region jsDoc
			/// @func    __validate_component_additions__()
			/// @desc    Validates that we are not adding existing components to our controller, or that a supplied array of components does not contain duplicates.
			/// @self    WWController
			/// @param   {Array<Struct>} arr : The array of structs to validate
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __validate_component_additions__ = function(_arr) {
				var _cid, _j, _found_count, _comp;
				var _size = array_length(_arr);
				var _i=0; repeat(_size) {
						_comp = _arr[_i];
						
						//safety checks
						_cid = _comp.__comp_id__;
						
						//verify the component doeant appear twice in the supplied array
						_found_count = 0;
						_j=_i+1; repeat(_size-_i-1) {
							if (_arr[_j].__comp_id__ == _cid) {
								show_error("Trying to insert an array which contains the same component twice", true)
							}
						_j+=1;}//end repeat loop
						
						//verify the component is not already in the controller
						_j=0; repeat(__children_count__) {
							if (__children__[_j].__comp_id__ == _cid) {
								show_error("Trying to insert a component which already exists inside this controller", true)
							}
						_j+=1;}//end repeat loop
						
						//verify the component isn't already in another controller
						if (_comp.__is_child__) {
							show_error("Trying to add a new component which is alread inside another controller", true)
						}
						
					_i+=1;}//end repeat loop
			}
			#region jsDoc
			/// @func    __include_children__()
			/// @desc    Includes the children by either pushing them into the list or inserting them into the list. Any index under 0 will push the component.
			/// @self    WWController
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
					
					if (_index < 0) {
						array_push(__children__, _comp);
					}
					else {
						array_insert(__children__, _index, _comp);
					}
					
					
					if (!_comp.__position_set__) {
						_comp.__set_position__(x+_comp.x_offset, y+_comp.y_offset);
					}
					
					if (!_comp.__offset_set__) {
						_comp.__set_offset__(_comp.x-x, _comp.y-y);
					}
					
				_i+=1;}//end repeat loop
				
				__children_count__ += _size;
				
			}
			#region jsDoc
			/// @func    __update_group_region__()
			/// @desc    This function is internally used to help assist updating the bounding box of controllers. This bounding box is used for many things but primarily used for collision check optimizations.
			/// @self    WWController
			/// @param   {Real} index : The index of the component to remove.
			/// @returns {Struct.WWController}
			/// @ignore
			#endregion
			static __update_group_region__ = function() {
				var _w = width;
				var _h = height;
				
				var _prev_w = __group__.width;
				var _prev_h = __group__.height;
				
				
				var _comp, xoff, yoff;
				var i = 0; repeat(__children_count__) {
					_comp = __children__[i];
					xoff = _comp.x_offset;
					yoff = _comp.y_offset;
					
					_w = max(_w, xoff + _comp.__group__.width);
					_h = max(_h, yoff + _comp.__group__.height);
				i+=1}
				
				//usually internally used to detect if the mouse is anywhere over a folder or window, helps with early outing collission checks
				__group__.width = _w;
				__group__.height = _h;
				
				//if this controller is a child of another controller, update the parent controller, this will loop all the way to the top most parent
				if (__is_child__) {
					if (_prev_w != _w)
					|| (_prev_h != _h) {
						__parent__.__update_group_region__();
					}
				}
				
			}
			#region jsDoc
			/// @func    __find_index_in_parent__()
			/// @desc    Find the child's index inside it's parent. Typically used for updating the Achor point
			/// @self    WWCore
			/// @returns {real}
			/// @ignore
			#endregion
			static __find_index_in_parent__ = function() {
				//if we're not a child early out
				if (!__is_child__) {return -1; };
				var _comps = __parent__.__children__;
		
				var _i = 0; repeat(__parent__.__children_count__) {
					if (_comps[_i].__comp_id__ == __comp_id__) break;
					_i+=1;
				}
		
				return _i;
			}
			
			#endregion
			#region Render Clipping
			#region jsDoc
			/// @func    __apply_clipping_region__()
			/// @desc    Sets the GPU scissor region to limit rendering to the viewport bounds.
			/// @self    WWViewport
			/// @returns {Undefined}
			#endregion
			static __apply_clipping_region__ = function() {
				previous_scissor = gpu_get_scissor();

				var _new_x = x;
				var _new_y = y;
				var _new_w = width;
				var _new_h = height;

				// Adjust clipping to stay within the existing scissor bounds
				_new_x = max(previous_scissor.x, _new_x);
				_new_y = max(previous_scissor.y, _new_y);
				_new_w = min(previous_scissor.x + previous_scissor.w, _new_x + _new_w) - _new_x;
				_new_h = min(previous_scissor.y + previous_scissor.h, _new_y + _new_h) - _new_y;
				
				gpu_set_scissor(_new_x, _new_y, _new_w, _new_h);
			};

			#region jsDoc
			/// @func    __restore_clipping_region__()
			/// @desc    Restores the previous GPU scissor region after drawing.
			/// @self    WWViewport
			/// @returns {Undefined}
			#endregion
			static __restore_clipping_region__ = function() {
				gpu_set_scissor(previous_scissor);
				previous_scissor = undefined;
			};
			#endregion
			#region Misc
			#region jsDoc
			/// @func    __set_sprite__()
			/// @desc    Define all of the built in GML object variables for the supplied sprite
			/// @self    WWCore
			/// @param   {Asset.GMSprite} sprite : The sprite to apply to the component, and to get the values from.
			/// @returns {Struct.WWCore}
			#endregion
			static __set_sprite__ = function(_sprite) {
				/// NOTE: These are the default structure of GUI button sprites
				/// image_index[0] = idle; no interaction;
				/// image_index[1] = mouse over; the mouse is over it;
				/// image_index[2] = mouse down; actively being pressed;
				/// image_index[3] = disabled; not allowed to interact with;
				
				// sorry everything is dirty looking
				// feather really doesnt want us to write to these variables.
				// and linux YYC builds throw errors on compile
				
				self.sprite_index = _sprite;
				
				if (!sprite_exists(_sprite)) return self;
				
				self.sprite_height  = self.image_yscale * sprite_get_height(_sprite);
				self.sprite_width   = self.image_xscale * sprite_get_width(_sprite);
				self.sprite_xoffset = self.image_xscale * sprite_get_xoffset(_sprite);
				self.sprite_yoffset = self.image_yscale * sprite_get_yoffset(_sprite);
				
				self.image_index  = 0;
				self.image_number = sprite_get_number(_sprite);
				self.image_speed  = sprite_get_speed(_sprite);
				
				self.visible = true;
				
				return self;
			}
			
			#region jsDoc
			/// @func    __set_size__()
			/// @desc    Internally updates the component's region without marking the size as user–preferred.  
			///          This function is used by internal layout routines so that they can adjust the component's dimensions  
			///          without overwriting an explicit user setting.
			/// @self    WWCore
			/// @param   {real} left : The left side of the bounding box
			/// @param   {real} top : The top side of the bounding box
			/// @param   {real} right : The right side of the bounding box
			/// @param   {real} bottom : The bottom side of the bounding box
			/// @returns {Struct.WWCore}
			#endregion
			static __set_size__ = function(_width, _height) {
				width  = _width ;
				height = _height;
				
				//update click regions
				__update_group_region__();
				if (__is_child__) {
					__parent__.__update_group_region__()
				}
				
				return self;
			}
			#region jsDoc
			/// @func    __set_position__()
			/// @desc    Internally updates the component's position without marking the position as user–preferred.  
			///          This function is used by internal layout routines so that they can adjust the component's position
			///          without overwriting an explicit user setting.
			/// @self    WWCore
			/// @param   {Real} x : The x of the component.
			/// @param   {Real} y : The y of the component.
			/// @returns {Struct.WWCore}
			#endregion
			static __set_position__ = function(_x, _y) {
				if (_x == self.x && _y == self.y) return self; // Avoid redundant updates
				
				self.xprevious = self.x;
				self.yprevious = self.y;
				self.x = _x;
				self.y = _y;
				
				update_component_positions();
				
				// If this component is a child, trigger an update on the parent’s group size.
			    if (__is_child__) {
			        __parent__.__update_group_region__();
			    }
				
				return self;
			}
			#region jsDoc
			/// @func    __set_offset__
			/// @desc    Internal function that updates the offset without marking it as user-defined.  
			///          This keeps the component positioned relative to the parent dynamically.
			/// @self    WWCore
			/// @param   {Real} x : The x offset.
			/// @param   {Real} y : The y offset.
			/// @returns {Struct.WWCore}
			#endregion
			static __set_offset__ = function(_x, _y) {
			    if (_x == self.x_offset && _y == self.y_offset) return self; // Avoid redundant updates
				
				self.x_offset = _x;
			    self.y_offset = _y;
				
			    // Recalculate position based on parent
			    if (__is_child__) {
					self.xprevious = self.x;
					self.yprevious = self.y;
					self.x = __parent__.x + self.x_offset;
					self.y = __parent__.y + self.y_offset;
					
					update_component_positions();
					
			    	__parent__.__update_group_region__();
			    }
				
			    return self;
			};

			#endregion
		#endregion
		
	#endregion
	
}
