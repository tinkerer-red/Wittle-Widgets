#region jsDoc
/// @func    GUICompCore()
/// @desc    This is the root most component, only use this if you need a very basic component for drawing purposes or if you're creating a new component.
/// @param   {Real} x : The x possition of the component on screen.
/// @param   {Real} y : The y possition of the component on screen.
/// @returns {Struct.GUICompCore}
#endregion
function GUICompCore() constructor {
	debug_name = "GUICompCore";
	
	#region Public
		
		#region Builder Functions
			
			#region Position and Size
			#region jsDoc
			/// @func    set_position()
			/// @desc    Publicly sets the position of the component, recording the user's preferred position.
			///          The component’s x and y coordinates are updated relative to the parent controller and its anchor.
			/// @self    GUICompCore
			/// @param   {Real} x : The x of the component.
			/// @param   {Real} y : The y of the component.
			/// @returns {Struct.GUICompCore}
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
			/// @self    GUICompCore
			/// @param   {real} left : The left side of the bounding box
			/// @param   {real} top : The top side of the bounding box
			/// @param   {real} right : The right side of the bounding box
			/// @param   {real} bottom : The bottom side of the bounding box
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_size = function(_left, _top, _right, _bottom) {
				log(json_stringify(debug_get_callstack(10), true))
				__size_set__ = true;
				__set_size__(_left, _top, _right, _bottom);
				return self;
			}
			#region jsDoc
			/// @func    set_offset()
			/// @desc    Sets the anchor of the component, This anchor will depict how the component is attached to the parent controller when resizing
			/// @self    GUICompCore
			/// @param   {Real} x : The x anchor of the component.
			/// @param   {Real} y : The y anchor of the component.
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_offset = function(_x, _y) {
				__offset_set__ = true;
				__set_offset__(_x, _y);
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
			static set_alignment = function(_halign=fa_center, _valign=fa_middle) {
				
				halign = _halign;
				valign = _valign;
				
				return self;
			}
			#region jsDoc
			/// @func    set_width()
			/// @desc    Sets the width of the component, this is just a short cut for doing `set_size(0, 0, _width, region.get_height())`
			/// @self    GUICompCore
			/// @param   {Real} width : The width of the component.
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_width = function(_width) {
				self.set_size(0, 0, _width, region.get_height())
				
				return self;
			}
			#region jsDoc
			/// @func    set_height()
			/// @desc    Sets the height of the component, this is just a short cut for doing `set_size(0, 0, region.get_width(), _height)`
			/// @self    GUICompCore
			/// @param   {Real} height : The height of the component.
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_height = function(_height) {
				self.set_size(0, 0, region.get_width(), _height)
				
				return self;
			}
			
			#endregion
			#region Sprite
			#region jsDoc
			/// @func    set_sprite()
			/// @desc    Sets all default GML object's sprite variables with a given sprite.
			/// @self    GUICompCore
			/// @param   {Asset.GMSprite} sprite : The sprite to apply to the component.
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_sprite = function(_sprite) {
				__set_sprite__(_sprite);
				return self;
			}
			#region jsDoc
			/// @func    set_sprite_angle()
			/// @desc    Sets the angle of the sprite to be drawn.
			/// @self    GUICompCore
			/// @param   {Real} angle : The angle of the sprite.
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_sprite_angle = function(_angle) {
				image_angle = _angle;
				return self;
			}
			#region jsDoc
			/// @func    set_sprite_color()
			/// @desc    Sets the color of the sprite to be drawn.
			/// @self    GUICompCore
			/// @param   {Real} color : The color of the sprite.
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_sprite_color = function(_col) {
				image_blend = _col;
				return self;
			}
			#region jsDoc
			/// @func    set_sprite_alpha()
			/// @desc    Sets the alpha of the sprite to be drawn.
			/// @self    GUICompCore
			/// @param   {Real} alpha : The alpha of the sprite.
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_sprite_alpha = function(_alpha) {
				image_alpha = _alpha;
				return self;
			}
			#endregion
			#region Text
			#region jsDoc
			/// @func    set_text()
			/// @desc    Sets the variables for text drawing
			/// @self    GUICompButtonText
			/// @param   {String} text : The text to write on the button.
			/// @returns {Struct.GUICompButtonText}
			#endregion
			static set_text = function(_text="DefaultText") {
				text.text = _text
				
				return self;
			}
			#region jsDoc
			/// @func    set_text_font()
			/// @desc    Sets the font which will be used for drawing the text
			/// @self    GUICompButtonText
			/// @param   {Asset.GMFont} font : The font to use when drawing the text
			/// @returns {Struct.GUICompButtonText}
			#endregion
			static set_text_font = function(_font=fGUIDefault) {
				text.font = _font;
				return self;
			}
			#region jsDoc
			/// @func    set_text_colors()
			/// @desc    Sets the colors for the text of the button.
			/// @self    GUICompButtonText
			/// @param   {Real} idle_color     : The color to draw the text when the component is idle
			/// @param   {Real} hover_color    : The color to draw the text when the component is hovered or clicked
			/// @param   {Real} disabled_color : The color to draw the text when the component is disabled
			/// @returns {Struct.GUICompButtonText}
			#endregion
			static set_text_colors = function(_idle=c_white, _hover=c_white, _clicked=c_white, _disable=c_grey) {
				text.color.idle    = _idle;
				text.color.hover   = _hover;
				text.color.clicked = _clicked;
				text.color.disable = _disable;
				
				return self;
			}
			#region jsDoc
			/// @func    set_text_alignment()
			/// @desc    Sets how the text is aligned when drawing
			/// @self    GUICompButtonText
			/// @param   {Constant.HAlign} halign : Horizontal alignment
			/// @param   {Constant.VAlign} valign : Vertical alignment
			/// @returns {Struct.GUICompButtonText}
			#endregion
			static set_text_alignment = function(_h=fa_left, _v=fa_top) {
				text.halign = _h;
				text.valign = _v;
		
				return self;
			};
			#region jsDoc
			/// @func    set_text_offsets()
			/// @desc    Sets the Text's offsets reletive to the component's x/y. Note: click_y will be applied in addition to the y, when the component is actively being pressed.
			/// @self    GUICompButtonText
			/// @param   {Real} x : The x offset
			/// @param   {Real} y : The y offset
			/// @param   {Real} click_y : The additional y offset used when 
			/// @returns {Struct.GUICompButtonText}
			#endregion
			static set_text_offsets = function(_x=0, _y=0, _click_y=2) {
				text.xoff = _x;
				text.yoff = _y;
				text.click_yoff = _click_y;
				
				return self;
			};
			#endregion
			
			#region jsDoc
			/// @func    set_enabled()
			/// @desc    Enable or Disable the Component, This usually effects how some components are handled
			/// @self    GUICompCore
			/// @param   {Bool} is_enabled : If the component should be enabled or not.
			/// @returns {Struct.GUICompCore}
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
			
			
		#endregion
		
		#region Events
			
			events = {};
			
			events.focus    = variable_get_hash("focus"); //triggered when the component gets focus, this commonly occurs when the mouse is clicked down on it.
			events.blur     = variable_get_hash("blur");  //triggered when the component loses focus, this commonly occurs when the mouse is clicked down off it, or when the mouse is released off it.
			static on_focus = function(_func) {
				add_event_listener(events.pre_step, _func);
				return self;
			}
			static on_blur = function(_func) {
				add_event_listener(events.post_step, _func);
				return self;
			}
			
			events.mouse_over = variable_get_hash("mouse_over");
			events.pressed    = variable_get_hash("pressed");
			events.held       = variable_get_hash("held");
			events.long_press = variable_get_hash("long_press");
			events.released   = variable_get_hash("released");
			events.double_click = variable_get_hash("double_click");
			static on_mouse_over = function(_func) {
				add_event_listener(events.mouse_over, _func);
				return self;
			}
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
			
			events.mouse_over_group = variable_get_hash("mouse_over_group"); //triggered every frame the mouse is over the controller region bounding box, This will be a square box encapsulating all sub components.
			static on_mouse_over_group = function(_func) {
				add_event_listener(events.mouse_over_group, _func);
				return self;
			}
			
		#endregion
		
		#region Variables
			
			my_data = {};
			
			is_enabled = true;
			
			halign = fa_left;
			valign = fa_top;
			
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
				
				text = {
					text : "<undefined>",
					font : fGUIDefault,
					
					xoff : 0,
					yoff : 0,
					click_yoff : 0,
					
					width  : 0,
					height : 0,
					
					halign : fa_left,
					valign : fa_top,
					
					alpha : 1,
					color : {
						idle : c_white,
						hover : c_white,
						clicked : c_white,
						disable : c_white,
					},
				}
				
			#endregion
			
		#endregion
	
		#region Functions
			
			#region Event Functions
			
			#region jsDoc
			/// @func    trigger_event()
			/// @desc    Run the callbacks for the given event lister id. 
			/// @self    GUICompCore
			/// @param   {String} event_id : One of the component's event IDs, see get_events for more info
			/// @param   {Struct} data : The data supplied from the struct, dependant on the component.
			/// @returns {undefined}
			/// @ignore
			#endregion
			static trigger_event = function(_event_id, _data=my_data) {
				
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
			/// @self    GUICompCore
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
			/// @self    GUICompCore
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
			/// @self    GUICompCore
			/// @param   {real} uid : The Unique ID of a previously added event function returned by add_event_listener.
			/// @returns {Struct.GUICompCore}
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
			/// @self    GUICompCore
			/// @returns {Array<String>}
			#endregion
			static get_events = function() {
				return variable_struct_get_names(events)
			}
			#region jsDoc
			/// @func    event_exists()
			/// @desc    Lightweight check to see if an event exists.
			/// @self    GUICompCore
			/// @param   {String} event_id : One of the component's event IDs, see get_events for more info
			/// @returns {undefined}
			/// @ignore
			#endregion
			static event_exists = function(_event_id) {
				return struct_exists_from_hash(self.__event_listeners__, _event_id)
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
			/// @self    GUICompCore
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
			/// @self    GUICompCore
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
			/// @self    GUICompController
			/// @returns {Real}
			#endregion
			static get_children_count = function() {
				return __children_count__;
			}
			#region jsDoc
			/// @func    get_sub_children_count()
			/// @desc    Returns the number of all children. This will include all children of children.
			/// @self    GUICompController
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
			/// @self    GUICompController
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
			/// @self    GUICompCore
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
				
				return __mouse_on_comp__;
			}
			#region jsDoc
			/// @func    mouse_on_group()
			/// @desc    This function is internally used to help assist early outing collision checks.
			/// @self    GUICompController
			/// @returns {Bool}
			/// @ignore
			#endregion
			static mouse_on_group = function() {
				//check if parent even has a mouse over it
				if (__is_child__) {
					if (!__parent__.__mouse_on_comp__) {
						return false;
					}
				}
				
				__mouse_on_group__ = point_in_rectangle(
						device_mouse_x_to_gui(0),
						device_mouse_y_to_gui(0),
						x+__group_region__.left,
						y+__group_region__.top,
						x+__group_region__.right,
						y+__group_region__.bottom
				);
				
				if (__mouse_on_group__) {
					trigger_event(self.events.mouse_over_group);
				}
				
				return __mouse_on_group__;
			}
			#region jsDoc
			/// @func    consume_input()
			/// @desc    Used to capture the input so no other components try to use an already consumed input.
			/// @self    GUICompCore
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
			/// @self    GUICompController
			/// @param   {Struct.GUICompCore|Array} comp : The component you wish to add to the controller.
			/// @returns {Undefined}
			#endregion
			static add = function(_comp) {
				__is_empty__ = false;
				
				var _arr = (is_array(_comp)) ? _comp : [_comp];
				
				__validate_component_additions__(_arr);
				
				__include_children__(_arr, -1);
				
				update_component_positions();
				__update_group_region__();
				
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
				
				__update_group_region__();
				
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
				//clean up the component
				__children__[_index].__cleanup__();
				delete __children__[_index];
				
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
			/// @self    GUICompController
			/// @param   {Struct.GUICompController} component : The component you wish to find the index of.
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
			/// @self    GUICompHandler
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
			
			
			#endregion
			
			#region GML Events
			
			#region jsDoc
			/// @func    step()
			/// @desc    Emulates the GML equivalant event.
			/// @self    GUICompCore
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
			/// @self    GUICompCore
			/// @param   {Struct} input : The input struct components pass around to capture inputs
			/// @returns {Undefined}
			#endregion
			static draw = function(_input=undefined, _debug=false) {
				_input ??= {
					consumed : false,
				};
				__user_input__ = _input;
				__mouse_on_group__ = mouse_on_group();
				
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
						x+region.left,
						y+region.top,
						x+region.right,
						y+region.bottom,
						true
					);
					draw_line(
						x+region.left,
						y+region.top,
						x+region.right,
						y+region.bottom
					)
					draw_line(
						x+region.right,
						y+region.top,
						x+region.left,
						y+region.bottom
					)
					#endregion
					#region Pointers
					draw_set_color(c_orange)
					//connect comp and group corners
					draw_line(x+__group_region__.left,  y+__group_region__.top,    x+region.left,  y+region.top);
					draw_line(x+__group_region__.right, y+__group_region__.top,    x+region.right, y+region.top);
					draw_line(x+__group_region__.left,  y+__group_region__.bottom, x+region.left,  y+region.bottom);
					draw_line(x+__group_region__.right, y+__group_region__.bottom, x+region.right, y+region.bottom);
					//connect children to parent
					if (__is_child__) {
						draw_line(
							__parent__.x+region.left,
							__parent__.y+region.top,
							x+region.left,
							y+region.top
						)
					}
					#endregion
					
					draw_set_color(c_yellow)
					draw_rectangle(
							x+__group_region__.left,
							y+__group_region__.top,
							x+__group_region__.right,
							y+__group_region__.bottom,
							true
					);
					draw_line(
						x+__group_region__.left,
						y+__group_region__.top,
						x+__group_region__.right,
						y+__group_region__.bottom
					)
					draw_line(
						x+__group_region__.right,
						y+__group_region__.top,
						x+__group_region__.left,
						y+__group_region__.bottom
					)
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
			__is_focused__ = false; // is currently being interacted with, to prevent draging a slider and clicking a button at the same time
			
			#endregion
			#region Sub Component Variables
			__is_empty__ = true;
			__children_count__ = 0;
			__children__ = [];
			__is_child__ = false; // if the component is a child of another component
			__parent__ = noone; // a reference to the parent controller
			__group_region__ = new __region__(); // used for component controllers to know the bounds of all children and self
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
			/// @self    GUICompCore
			/// @returns {undefined}
			/// @ignore
			#endregion
			static __reset_focus__ = function() {
				__is_focused__ = false;
				trigger_event(self.events.blur);
			}
			#region jsDoc
			/// @func    __handle_click__()
			/// @desc    This handle all of the monotinous click code which is reused all over the place. If you need a component to do something when a click the component has been clicked, see "add_event_listener" or "add_event_listener".
			/// @self    GUICompCore
			/// @param   {Struct.Input} input : The input struct containing passed around data between components.
			#endregion
			static __handle_click__ = function(_input) {
				//early out if we're disabled
				if (!is_enabled) {
					if (__is_focused__) {
						__reset_focus__();
					}
					return;
				}
				
				var _input_captured = _input.consumed
				
				//capture input if we still have focus
				if (__is_focused__)
				&& (is_enabled) {
					consume_input();
				}
				
				//run the internal step
				if (!_input_captured)
				&& (mouse_on_comp()) {
					consume_input();
					
					//trigger the event for mouse over
					trigger_event(self.events.mouse_over);
					
					image_index = GUI_IMAGE_HOVER;
					
					//mouse button checks
					if (mouse_check_button_pressed(mb_left)) {
						__is_focused__ = true;
						image_index = GUI_IMAGE_CLICKED;
						__click_held_timer__ = 0;
						trigger_event(self.events.pressed);
						trigger_event(self.events.focus);
					}
					else if (__is_focused__) && (mouse_check_button(mb_left)) {
						image_index = GUI_IMAGE_CLICKED;
						trigger_event(self.events.held);
						
						__click_held_timer__ += 1;
						if (__click_held_timer__ > game_get_speed(gamespeed_fps)/3)
						&& (__click_held_timer__  % floor(game_get_speed(gamespeed_fps)/30) == 0) {
							trigger_event(self.events.long_press);
						}
					}
					else if (__is_focused__) && (mouse_check_button_released(mb_left)) {
						__reset_focus__();
						__click_held_timer__ = 0;
						image_index = GUI_IMAGE_HOVER;
						trigger_event(self.events.released);
						trigger_event(self.events.blur);
					}
					
				}
				else {
					image_index = GUI_IMAGE_ENABLED;
					if (__is_focused__) && (mouse_check_button_released(mb_left)) {
						__reset_focus__();
						trigger_event(self.events.blur);
					}
				}
				
			}
			#endregion
			#region Event Priv Functions
			
			#endregion
			#region Sub Component Priv Functions
			#region jsDoc
			/// @func    __validate_component_additions__()
			/// @desc    Validates that we are not adding existing components to our controller, or that a supplied array of components does not contain duplicates.
			/// @self    GUICompController
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
				var _cid, _j, _found_count, _comp;
				var _size = array_length(_arr);
				var _i=0; repeat(_size) {
					_comp = _arr[_i];
						
					//verify the component does not reach out of bounds of the controller
					switch (_comp.halign) {
						case fa_left:{
							//make sure the child component's region does not reach outside of the controller's left side
							var _offset = self.__group_region__.left - _comp.x_offset - _comp.__group_region__.left;
								
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
							var _offset = _comp.x_offset + _comp.__group_region__.right - self.__group_region__.right;
								
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
							var _offset = self.__group_region__.top - _comp.y_offset - _comp.__group_region__.top;
								
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
							var _offset = _comp.y_offset + _comp.__group_region__.bottom - self.__group_region__.bottom;
								
							if (_offset > 0) {
								show_error("Newly added component : "+string(_comp.debug_name)+" : is anchored to the bottom, but is outside of the controller's bottom region."
										+"\nThe component was "+string(_offset)+" pixels too far down."
										+"\nmake sure to move the component to the up before adding, or change the valign of the component.\n\n", true)
							}
						break;}
					}
						
				_i+=1;}//end repeat loop
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
					
					if (_index < 0) {
						array_push(__children__, _comp);
					}
					else {
						array_insert(__children__, _index, _comp);
					}
					
					if (!_comp.__position_set__) {
						_comp.__set_position__(x+_comp.x_offset, y+_comp.y_offset);
					}
					
				_i+=1;}//end repeat loop
				
				__children_count__ += _size;
				
			}
			#region jsDoc
			/// @func    __update_group_region__()
			/// @desc    This function is internally used to help assist updating the bounding box of controllers. This bounding box is used for many things but primarily used for collision check optimizations.
			/// @self    GUICompController
			/// @param   {Real} index : The index of the component to remove.
			/// @returns {Struct.GUICompController}
			/// @ignore
			#endregion
			static __update_group_region__ = function() {
				var _left   = region.left;
				var _top    = region.top;
				var _right  = region.right;
				var _bottom = region.bottom;
				
				var _prev_left   = __group_region__.left;
				var _prev_top    = __group_region__.top;
				var _prev_right  = __group_region__.right;
				var _prev_bottom = __group_region__.bottom;
				
				
				var _comp, xoff, yoff;
				var i = 0; repeat(__children_count__) {
					_comp = __children__[i];
					xoff = _comp.x-x;
					yoff = _comp.y-y;
					
					_left   = min(_left,   xoff+_comp.__group_region__.left);
					_right  = max(_right,  xoff+_comp.__group_region__.right);
					_top    = min(_top,    yoff+_comp.__group_region__.top);
					_bottom = max(_bottom, yoff+_comp.__group_region__.bottom);
				i+=1}
			
				//usually internally used to detect if the mouse is anywhere over a folder or window, helps with early outing collission checks
				__group_region__.left   = _left;
				__group_region__.top    = _top;
				__group_region__.right  = _right;
				__group_region__.bottom = _bottom;
				
				//if this controller is a child of another controller, update the parent controller, this will loop all the way to the top most parent
				if (__is_child__) {
						if (_prev_left   != _left)
						|| (_prev_top    != _top)
						|| (_prev_right  != _right)
						|| (_prev_bottom != _bottom) {
							__parent__.__update_group_region__();
						}
					}
				
			}
			#region jsDoc
			/// @func    __find_index_in_parent__()
			/// @desc    Find the child's index inside it's parent. Typically used for updating the Achor point
			/// @self    GUICompCore
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
			#region Misc
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
			static __region__ = function(_l=0, _t=0, _r=0, _b=0) constructor {
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
			/// @func    __set_sprite__()
			/// @desc    Define all of the built in GML object variables for the supplied sprite
			/// @self    GUICompCore
			/// @param   {Asset.GMSprite} sprite : The sprite to apply to the component, and to get the values from.
			/// @returns {Struct.GUICompCore}
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
			/// @self    GUICompCore
			/// @param   {real} left : The left side of the bounding box
			/// @param   {real} top : The top side of the bounding box
			/// @param   {real} right : The right side of the bounding box
			/// @param   {real} bottom : The bottom side of the bounding box
			/// @returns {Struct.GUICompCore}
			#endregion
			static __set_size__ = function(_left, _top, _right, _bottom) {
				region.left   = _left;
				region.top    = _top;
				region.right  = _right;
				region.bottom = _bottom;
				
				//update click regions
				__update_group_region__();
				if (__is_child__) {
					__parent__.__update_group_region__()
				}
				
			}
			#region jsDoc
			/// @func    __set_position__()
			/// @desc    Internally updates the component's position without marking the position as user–preferred.  
			///          This function is used by internal layout routines so that they can adjust the component's position
			///          without overwriting an explicit user setting.
			/// @self    GUICompCore
			/// @param   {Real} x : The x of the component.
			/// @param   {Real} y : The y of the component.
			/// @returns {Struct.GUICompCore}
			#endregion
			static __set_position__ = function(_x, _y) {
				if (_x == self.x && _y == self.y) return self; // Avoid redundant updates
				
				self.xprevious = self.x;
				self.yprevious = self.y;
				self.x = _x;
				self.y = _y;
				
				update_component_positions();
				
				// If this component is a child, trigger an update on the parent’s group region.
			    if (__is_child__) {
			        __parent__.__update_group_region__();
			    }
				
				return self;
			}
			#region jsDoc
			/// @func    __set_offset__
			/// @desc    Internal function that updates the offset without marking it as user-defined.  
			///          This keeps the component positioned relative to the parent dynamically.
			/// @self    GUICompCore
			/// @param   {Real} x : The x offset.
			/// @param   {Real} y : The y offset.
			/// @returns {Struct.GUICompCore}
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
			    }
				
				update_component_positions();
				
				// If this component is a child, trigger an update on the parent’s group region.
			    if (__is_child__) {
					__parent__.__update_group_region__();
			    }
				
			    return self;
			};

			#endregion
		#endregion
		
	#endregion
	
}
