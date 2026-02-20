#region jsDoc
/// @func    WWCore()
/// @desc    This is the root most component, only use this if you need a very basic component for drawing purposes or if you're creating a new component.
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
			///          The component's x and y coordinates are updated relative to the parent controller and its anchor.
			/// @self    WWCore
			/// @param   {Real} x : The x of the component.
			/// @param   {Real} y : The y of the component.
			/// @returns {Struct.WWCore}
			#endregion
			static set_position = function(_x, _y) {
				if (__position_set__ == false) {
					__position_set__ = true;
					xstart = x;
					ystart = y;
				}
				__set_position__(_x, _y);
				return self;
			}
			#region jsDoc
			/// @func    set_size()
			/// @desc    Sets the user-preferred size (width/height) and updates regions; note: some components will have a minimum size override.
			/// @self    WWCore
			/// @param   {Real} width : The width of the component
			/// @param   {Real} height : The height of the component
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
				
				__halign__ = _halign;
				__valign__ = _valign;
				
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
				set_size(_width, height)
				
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
				set_size(width, _height)
				
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
				var _info = sprite_get_info(_sprite);
				
				sprite_index   = _sprite;
				sprite_height  = _info.height;
				sprite_width   = _info.width;
				sprite_xoffset = _info.xoffset;
				sprite_yoffset = _info.yoffset;
				
				//visible = true;
				
				image_index  = 0;
				image_number = _info.num_subimages;
				image_speed = (_info.frame_type == spritespeed_framespersecond) ? (_info.frame_speed / game_get_speed(gamespeed_fps)) : _info.frame_speed;
				
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
			/// @param   {Real} col : The color of the sprite.
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
			/// @param   {Real} col : The color of the background.
			/// @returns {Struct.WWCore}
			#endregion
			static set_background_color = function(_col) {
				__background_color_set__ = true;
				background_color = _col;
				return self;
			}
			
			#endregion
			
			
			#region jsDoc
			/// @func    set_focusable()
			/// @desc    Sets whether this component can be focused/hovered/interacted with.
			/// @self    WWCore
			/// @param   {Bool} is_focusable : True to allow interaction.
			/// @returns {Struct.WWCore}
			#endregion
			static set_focusable = function(_is_focusable) {
				__is_focusable__ = _is_focusable;
				__focus_registry_mark_dirty__();
				if (!__is_focusable__) {
					set_focus(false);
					set_hover(false);
					set_interact(false);
					set_pressed(false);
					set_pointer_consumer(false);
				}
				return self;
			};
			#region jsDoc
			/// @func    set_enabled()
			/// @desc    Enable or Disable the Component, This usually effects how some components are handled in terms of greying out a component.
			/// @self    WWCore
			/// @param   {Bool} is_enabled : If the component should be enabled or not.
			/// @returns {Struct.WWCore}
			#endregion
			static set_enabled = function(_is_enabled) {
				if (__is_enabled__ == _is_enabled) return self;
				
				__is_enabled__ = _is_enabled;
				__focus_registry_mark_dirty__();
				
				// Propagate the state change to children components.
				if (!__is_empty__) {
					var _comp;
					var _i=0; repeat(__children_count__) {
						_comp = __children__[_i];
						_comp.set_enabled(_is_enabled);
					_i+=1;}//end repeat loop
				}
				
				if (__is_enabled__) {
					trigger_event(events.enabled);
				}
				else {
					trigger_event(events.disabled);
				}
				
				return self;
			}
			#region jsDoc
			/// @func    set_active()
			/// @desc    Activate of Deactivate the Component from executing any of it's code. This will also prevent all subcomponets code from running.
			/// @self    WWCore
			/// @param   {Bool} is_active : Whether this component (and subtree) executes update logic.
			/// @returns {Struct.WWCore}
			#endregion
			static set_active = function(_is_active) {
				if (__is_active__ == _is_active) return self;
				
				__is_active__ = _is_active;
				__focus_registry_mark_dirty__();
				__overlay_mark_subtree_dirty__();
				__overlay_sync_subtree__();
				
				if (__is_active__) {
					trigger_event(events.activated);
				}
				else {
					trigger_event(events.deactivated);
				}
				
				return self;
			}
			#region jsDoc
			/// @func    set_debug()
			/// @desc    Enable or Disable the Component's debug drawing and logging.
			/// @self    WWCore
			/// @param   {Bool} debug_enabled : If the component should log and draw debugging information
			/// @returns {Struct.WWCore}
			#endregion
			static set_debug = function(_debug_enabled) {
				__debug_enabled__ = _debug_enabled;
				return self;
			}
			#region jsDoc
			/// @func    set_overlay_host_enabled()
			/// @desc    Enables this component as a local overlay host.
			/// @self    WWCore
			/// @param   {Bool} enabled : True to allow LOCAL_HOST overlays to resolve here.
			/// @returns {Struct.WWCore}
			#endregion
			static set_overlay_host_enabled = function(_enabled=true) {
				__overlay_host_enabled__ = _enabled;
				if (_enabled) {
					__overlay_ensure_manager__();
				}
				else if (is_struct(__overlay_manager__)) {
					__overlay_manager__.dirty = true;
				}
				__overlay_mark_subtree_dirty__();
				__overlay_sync_subtree__();
				return self;
			}
			#region jsDoc
			/// @func    set_focus()
			/// @desc    Sets the focus state for this component.
			/// @self    WWCore
			/// @param   {Bool} focus : True to focus; false to unfocus.
			/// @returns {Struct.WWCore}
			#endregion
			static set_nav_target = function(_is_nav_target) {
				_is_nav_target = !!_is_nav_target;
				if (_is_nav_target && (!__is_focusable__ || !__is_enabled__ || !__is_active__)) {
					_is_nav_target = false;
				}
				__is_nav_target__ = _is_nav_target;
				if (_is_nav_target && __overlay_component__) {
					__overlay_last_focus_time__ = current_time;
					bring_to_front();
				}
				return self;
			}
			static set_input_consumer = function(_is_input_consumer) {
				_is_input_consumer = !!_is_input_consumer;
				if (_is_input_consumer && (!__is_focusable__ || !__is_enabled__ || !__is_active__)) {
					_is_input_consumer = false;
				}
				if (_is_input_consumer && !__is_input_consumer__) {
					__is_input_consumer__ = true;
					trigger_event(events.focus_enter, __user_input__);
					trigger_event(events.focus, __user_input__);
				}
				else if (!_is_input_consumer && __is_input_consumer__) {
					__is_input_consumer__ = false;
					trigger_event(events.focus_exit, __user_input__);
				}
				else {
					__is_input_consumer__ = _is_input_consumer;
				}
				__sync_legacy_input_flags__();
				return self;
			}
			static set_focus = function(_focus) {
				_focus = !!_focus;
				if (_focus) {
					var _root = __root_canvas__;
					if (!is_struct(_root)) _root = self;
					var _target = _root.__focus_registry_set_target__(self, true);
					if (!is_struct(_target)) {
						set_nav_target(true);
						set_input_consumer(true);
					}
				}
				else {
					set_nav_target(false);
					set_input_consumer(false);
				}
				return self;
			}
			#region jsDoc
			/// @func    set_hover()
			/// @desc    Sets the hover state for this component.
			/// @self    WWCore
			/// @param   {Bool} hover : True to hover; false to unhover.
			/// @returns {Struct.WWCore}
			#endregion
			static set_pointer_over = function(_is_pointer_over) {
				_is_pointer_over = !!_is_pointer_over;
			    if (_is_pointer_over && !__is_pointer_over__) {
					__is_pointer_over__ = true;
					trigger_event(events.hover_enter, __user_input__);
					trigger_event(events.hover, __user_input__);
				}
			    else if (!_is_pointer_over && __is_pointer_over__) {
					__is_pointer_over__ = false;
					trigger_event(events.hover_exit, __user_input__);
				}
				else {
					__is_pointer_over__ = _is_pointer_over;
				}
				__sync_legacy_input_flags__();
			    return self;
			}
			static set_hover = function(_hover) {
				set_pointer_over(_hover);
			    return self;
			}
			#region jsDoc
			/// @func    set_interact()
			/// @desc    Sets the interaction state for this component.
			/// @self    WWCore
			/// @param   {Bool} interact : True while interacting; false to stop.
			/// @returns {Struct.WWCore}
			#endregion
			static set_engaged = function(_is_engaged) {
				_is_engaged = !!_is_engaged;
			    if (_is_engaged && !__is_engaged__) {
					__is_engaged__ = true;
					trigger_event(events.interact_enter, __user_input__);
					trigger_event(events.interact, __user_input__);
				}
			    else if (!_is_engaged && __is_engaged__) {
					__is_engaged__ = false;
					trigger_event(events.interact_exit, __user_input__);
				}
				else {
					__is_engaged__ = _is_engaged;
				}
				if (!_is_engaged) {
					__is_pressed__ = false;
				}
				__sync_legacy_input_flags__();
			    return self;
			}
			static set_interact = function(_interact) {
				set_engaged(_interact);
				return self;
			}
			static set_pointer_consumer = function(_is_pointer_consumer) {
				__is_pointer_consumer__ = !!_is_pointer_consumer;
				return self;
			}
			static set_pressed = function(_is_pressed) {
				__is_pressed__ = !!_is_pressed;
				return self;
			}
			static set_last_input_modality = function(_modality) {
				var _last_input_modality = string_lower(string(_modality));
				switch (_last_input_modality) {
					case "mouse":
					case "keyboard":
					case "controller":
					case "touch":
					break;
					default: _last_input_modality = "unknown"; break;
				}
				__last_input_modality__ = _last_input_modality;
			    return self;
			}
			static should_yield_keyboard_nav = function(_direction) {
				return true;
			}
			static should_auto_consume_on_nav_target = function() {
				return true;
			}
			static handle_keyboard_nav_override = function(_direction) {
				if (_direction != "left") return undefined;
				var _folder = __find_ancestor_folder__();
				if (!is_struct(_folder)) return undefined;
				if (_folder.__comp_id__ == __comp_id__) return undefined;
				
				if (variable_struct_exists(_folder, "get_open")) {
					var _get_open = _folder.get_open;
					if (is_callable(_get_open) && !_folder.get_open()) {
						return undefined;
					}
				}
				
				return _folder;
			}
			static handle_keyboard_submit_override = function(_input) {
				return false;
			}
			static handle_keyboard_cancel_override = function(_input) {
				return false;
			}
			
		#endregion
		
		#region Events
			
			events = {};
			#region jsDoc
			/// @func    on_event()
			/// @desc    Adds an event listener for a given event id or name.
			/// @self    WWCore
			/// @param   {String|Real} event : Event name (string) or event hash id.
			/// @param   {Function} func : Listener invoked with event payload.
			/// @returns {Struct.WWCore}
			#endregion
			static on_event = function(_event, _func) {
				var _hash = is_string(_event) ? variable_get_hash(_event) : _event;
				add_event_listener(_hash, _func);
				return self;
			}
			
			#region Focus
			events.focus_enter = variable_get_hash("focus_enter"); //triggered when component first accepted keyboard inputs
			events.focus       = variable_get_hash("focus"); //triggered every frame component can accept keyboard inputs
			events.focus_exit  = variable_get_hash("focus_exit"); //triggered when the component can no longer accept keyboard inputs
			#region jsDoc
			/// @func    on_focus_enter()
			/// @desc    Adds a listener for the focus_enter event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked when focus enters.
			/// @returns {Struct.WWCore}
			#endregion
			static on_focus_enter = function(_func) {
				add_event_listener(events.focus_enter, _func);
				return self;
			}
			#region jsDoc
			/// @func    on_focus()
			/// @desc    Adds a listener for the focus event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked while focused.
			/// @returns {Struct.WWCore}
			#endregion
			static on_focus = function(_func) {
				add_event_listener(events.focus, _func);
				return self;
			}
			#region jsDoc
			/// @func    on_focus_exit()
			/// @desc    Adds a listener for the focus_exit event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked when focus exits.
			/// @returns {Struct.WWCore}
			#endregion
			static on_focus_exit = function(_func) {
				add_event_listener(events.focus_exit, _func);
				return self;
			}
			#endregion
			#region Interact
			events.interact_enter = variable_get_hash("interact_enter"); //triggered when component first accepted keyboard inputs
			events.interact       = variable_get_hash("interact"); //triggered every frame component can accept keyboard inputs
			events.interact_exit  = variable_get_hash("interact_exit"); //triggered when the component can no longer accept keyboard inputs
			#region jsDoc
			/// @func    on_interact_enter()
			/// @desc    Adds a listener for the interact_enter event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked when interaction begins.
			/// @returns {Struct.WWCore}
			#endregion
			static on_interact_enter = function(_func) {
				add_event_listener(events.interact_enter, _func);
				return self;
			}
			#region jsDoc
			/// @func    on_interact()
			/// @desc    Adds a listener for the interact event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked while interacting.
			/// @returns {Struct.WWCore}
			#endregion
			static on_interact = function(_func) {
				add_event_listener(events.interact, _func);
				return self;
			}
			#region jsDoc
			/// @func    on_interact_exit()
			/// @desc    Adds a listener for the interact_exit event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked when interaction ends.
			/// @returns {Struct.WWCore}
			#endregion
			static on_interact_exit = function(_func) {
				add_event_listener(events.interact_exit, _func);
				return self;
			}
			#endregion
			#region Hover
			events.hover_enter = variable_get_hash("hover_enter"); //triggered when component first accepted keyboard inputs
			events.hover       = variable_get_hash("hover"); //triggered every frame component can accept keyboard inputs
			events.hover_exit  = variable_get_hash("hover_exit"); //triggered when the component can no longer accept keyboard inputs
			#region jsDoc
			/// @func    on_hover_enter()
			/// @desc    Adds a listener for the hover_enter event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked when hover begins.
			/// @returns {Struct.WWCore}
			#endregion
			static on_hover_enter = function(_func) {
				add_event_listener(events.hover_enter, _func);
				return self;
			}
			#region jsDoc
			/// @func    on_hover()
			/// @desc    Adds a listener for the hover event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked while hovered.
			/// @returns {Struct.WWCore}
			#endregion
			static on_hover = function(_func) {
				add_event_listener(events.hover, _func);
				return self;
			}
			#region jsDoc
			/// @func    on_hover_exit()
			/// @desc    Adds a listener for the hover_exit event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked when hover ends.
			/// @returns {Struct.WWCore}
			#endregion
			static on_hover_exit = function(_func) {
				add_event_listener(events.hover_exit, _func);
				return self;
			}
			#endregion
			
			#region Click Handling
			events.pressed    = variable_get_hash("pressed");
			events.held       = variable_get_hash("held");
			events.long_press = variable_get_hash("long_press");
			events.released   = variable_get_hash("released");
			events.double_click = variable_get_hash("double_click");
			events.triple_click = variable_get_hash("triple_click");
			#region jsDoc
			/// @func    on_pressed()
			/// @desc    Adds a listener for the pressed event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked when pressed.
			/// @returns {Struct.WWCore}
			#endregion
			static on_pressed = function(_func) {
				add_event_listener(events.pressed, _func);
				return self;
			}
			#region jsDoc
			/// @func    on_held()
			/// @desc    Adds a listener for the held event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked while held.
			/// @returns {Struct.WWCore}
			#endregion
			static on_held = function(_func) {
				add_event_listener(events.held, _func);
				return self;
			}
			#region jsDoc
			/// @func    on_long_press()
			/// @desc    Adds a listener for the long_press event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked on long press.
			/// @returns {Struct.WWCore}
			#endregion
			static on_long_press = function(_func) {
				add_event_listener(events.long_press, _func);
				return self;
			}
			#region jsDoc
			/// @func    on_released()
			/// @desc    Adds a listener for the released event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked when released.
			/// @returns {Struct.WWCore}
			#endregion
			static on_released = function(_func) {
				add_event_listener(events.released, _func);
				return self;
			}
			#region jsDoc
			/// @func    on_double_click()
			/// @desc    Adds a listener for the double_click event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked on double click.
			/// @returns {Struct.WWCore}
			#endregion
			static on_double_click = function(_func) {
				add_event_listener(events.double_click, _func);
				return self;
			}
			#region jsDoc
			/// @func    on_triple_click()
			/// @desc    Adds a listener for the triple_click event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked on triple click.
			/// @returns {Struct.WWCore}
			#endregion
			static on_triple_click = function(_func) {
				add_event_listener(events.triple_click, _func);
				return self;
			}
			#endregion
			
			#region Step/Draw
			events.pre_step  = variable_get_hash("pre_step"); //triggered every frame before the begin step event is activated
			events.post_step = variable_get_hash("post_step"); //triggered every frame after the end step event is activated
			#region jsDoc
			/// @func    on_pre_step()
			/// @desc    Adds a listener for the pre_step event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked before step.
			/// @returns {Struct.WWCore}
			#endregion
			static on_pre_step = function(_func) {
				add_event_listener(events.pre_step, _func);
				return self;
			}
			#region jsDoc
			/// @func    on_post_step()
			/// @desc    Adds a listener for the post_step event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked after step.
			/// @returns {Struct.WWCore}
			#endregion
			static on_post_step = function(_func) {
				add_event_listener(events.post_step, _func);
				return self;
			}
			
			events.pre_draw    = variable_get_hash("pre_draw"); //triggered every frame after the end step event is activated
			events.post_draw   = variable_get_hash("post_draw"); //triggered every frame after the end step event is activated
			#region jsDoc
			/// @func    on_pre_draw()
			/// @desc    Adds a listener for the pre_draw event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked before draw.
			/// @returns {Struct.WWCore}
			#endregion
			static on_pre_draw = function(_func) {
				add_event_listener(events.pre_draw, _func);
				return self;
			}
			#region jsDoc
			/// @func    on_post_draw()
			/// @desc    Adds a listener for the post_draw event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked after draw.
			/// @returns {Struct.WWCore}
			#endregion
			static on_post_draw = function(_func) {
				add_event_listener(events.post_draw, _func);
				return self;
			}
			#endregion
			
			#region Mouse Over/Off
			events.mouse_over = variable_get_hash("mouse_over");
			events.mouse_off = variable_get_hash("mouse_off");
			#region jsDoc
			/// @func    on_mouse_over()
			/// @desc    Adds a listener for the mouse_over event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked when mouse enters.
			/// @returns {Struct.WWCore}
			#endregion
			static on_mouse_over = function(_func) {
				add_event_listener(events.mouse_over, _func);
				return self;
			}
			#region jsDoc
			/// @func    on_mouse_off()
			/// @desc    Adds a listener for the mouse_off event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked when mouse exits.
			/// @returns {Struct.WWCore}
			#endregion
			static on_mouse_off = function(_func) {
				add_event_listener(events.mouse_off, _func);
				return self;
			}
			
			events.mouse_over_group = variable_get_hash("mouse_over_group"); //triggered every frame the mouse is over the controller region bounding box, This will be a square box encapsulating all sub components.
			events.mouse_off_group = variable_get_hash("mouse_off_group"); //triggered every frame the mouse is over the controller region bounding box, This will be a square box encapsulating all sub components.
			#region jsDoc
			/// @func    on_mouse_over_group()
			/// @desc    Adds a listener for the mouse_over_group event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked while mouse is within group bounds.
			/// @returns {Struct.WWCore}
			#endregion
			static on_mouse_over_group = function(_func) {
				add_event_listener(events.mouse_over_group, _func);
				return self;
			}
			#region jsDoc
			/// @func    on_mouse_off_group()
			/// @desc    Adds a listener for the mouse_off_group event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked when mouse leaves group bounds.
			/// @returns {Struct.WWCore}
			#endregion
			static on_mouse_off_group = function(_func) {
				add_event_listener(events.mouse_off_group, _func);
				return self;
			}
			#endregion
			
			events.enabled     = variable_get_hash("enabled"); //triggered when the component is enabled (this is done by the developer)
			events.disabled    = variable_get_hash("disabled"); //triggered when the component is disabled (this is done by the developer)
			#region jsDoc
			/// @func    on_enable()
			/// @desc    Adds a listener for the enabled event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked when enabled.
			/// @returns {Struct.WWCore}
			#endregion
			static on_enable = function(_func) {
				add_event_listener(events.enabled, _func);
				return self;
			}
			#region jsDoc
			/// @func    on_disabled()
			/// @desc    Adds a listener for the disabled event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked when disabled.
			/// @returns {Struct.WWCore}
			#endregion
			static on_disabled = function(_func) {
				add_event_listener(events.disabled, _func);
				return self;
			}
			
			events.activated   = variable_get_hash("activated"); //triggered when the component is enabled (this is done by the developer)
			events.deactivated = variable_get_hash("deactivated"); //triggered when the component is disabled (this is done by the developer)
			#region jsDoc
			/// @func    on_activated()
			/// @desc    Adds a listener for the activated event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked when activated.
			/// @returns {Struct.WWCore}
			#endregion
			static on_activated = function(_func) {
				add_event_listener(events.activated, _func);
				return self;
			}
			#region jsDoc
			/// @func    on_deactivated()
			/// @desc    Adds a listener for the deactivated event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked when deactivated.
			/// @returns {Struct.WWCore}
			#endregion
			static on_deactivated = function(_func) {
				add_event_listener(events.deactivated, _func);
				return self;
			}
			
			events.resize = variable_get_hash("resize"); //triggered when the component is disabled (this is done by the developer)
			#region jsDoc
			/// @func    on_resize()
			/// @desc    Adds a listener for the resize event.
			/// @self    WWCore
			/// @param   {Function} func : Listener invoked on resize.
			/// @returns {Struct.WWCore}
			#endregion
			static on_resize = function(_func) {
				add_event_listener(events.resize, _func);
				return self;
			}
			
		#endregion
		
		#region Focus & Navigation
            
			#region jsDoc
			/// @func    navigate_focus()
			/// @desc    Attempts to shift focus in the given direction ("next", "prev", "up", "down", etc.)
			///          using the root focus registry cache.
			/// @self    WWCore
			/// @param   {String} dir : The navigation direction.
			/// @returns {Struct.WWCore} The component that received focus, or self if none found.
			#endregion
            static navigate_focus = function(_dir) {
				var _root = __root_canvas__;
				if (!is_struct(_root)) _root = self;
				var _target = _root.__focus_registry_navigate__(_dir, self, __last_input_modality__);
				if (is_struct(_target)) return _target;
				return self;
            }
			
			#region jsDoc
			/// @func    handle_keyboard_navigation()
			/// @desc    Root-only keyboard navigation handler for tab/shift-tab and arrow keys.
			/// @self    WWCore
			/// @param   {Struct} input : The input struct (should contain keyboard state).
			/// @returns {Undefined}
			#endregion
			static handle_keyboard_navigation = function(_input) {
				var _root = __root_canvas__;
				if (!is_struct(_root)) _root = self;
				if (_root.__comp_id__ != __comp_id__) return;
				if (!is_struct(_input)) return;
				if (!is_struct(_input.nav)) return;
				if (_input.nav.consumed) return;
				
				var _nav_modality = "unknown";
				var _nav_source = string_lower(string(_input.nav.source));
				switch (_nav_source) {
					case "keyboard":
					case "controller": _nav_modality = _nav_source; break;
				}
				
				if (_input.nav.submit.pressed || _input.nav.submit.repeat) {
					var _registry_submit = _root.__focus_registry_get_entries__();
					var _entries_submit = _registry_submit.entries;
					var _count_submit = array_length(_entries_submit);
					if (_count_submit > 0) {
						var _current_index_submit = _root.__focus_registry_find_current_index__(_entries_submit, _count_submit);
						if (_current_index_submit >= 0) {
							var _current_submit = _entries_submit[_current_index_submit];
							var _submit_handled = _current_submit.handle_keyboard_submit_override(_input);
							var _submit_handler_comp = _current_submit;
							if (!_submit_handled) {
								var _submit_owner = __resolve_dropdown_owner_for_nav__(_current_submit);
								if (is_struct(_submit_owner) && _submit_owner.__comp_id__ != _current_submit.__comp_id__) {
									_submit_handled = _submit_owner.handle_keyboard_submit_override(_input);
									if (_submit_handled) {
										_submit_handler_comp = _submit_owner;
									}
								}
							}
							if (_submit_handled) {
								set_last_input_modality(_nav_modality);
								_submit_handler_comp.set_last_input_modality(_nav_modality);
								_input.nav.consumed = true;
								return;
							}
							if (!_current_submit.__is_input_consumer__) {
								var _assigned_submit = _root.__focus_registry_set_target__(_current_submit, true);
								if (is_struct(_assigned_submit)) {
									set_last_input_modality(_nav_modality);
									_assigned_submit.set_last_input_modality(_nav_modality);
									_input.nav.consumed = true;
									return;
								}
							}
						}
					}
				}
				
				if (_input.nav.cancel.pressed || _input.nav.cancel.repeat) {
					var _registry_cancel = _root.__focus_registry_get_entries__();
					var _entries_cancel = _registry_cancel.entries;
					var _count_cancel = array_length(_entries_cancel);
					if (_count_cancel > 0) {
						var _current_index_cancel = _root.__focus_registry_find_current_index__(_entries_cancel, _count_cancel);
						if (_current_index_cancel >= 0) {
							var _current_cancel = _entries_cancel[_current_index_cancel];
							var _cancel_handled = _current_cancel.handle_keyboard_cancel_override(_input);
							var _cancel_handler_comp = _current_cancel;
							if (!_cancel_handled) {
								var _cancel_owner = __resolve_dropdown_owner_for_nav__(_current_cancel);
								if (is_struct(_cancel_owner) && _cancel_owner.__comp_id__ != _current_cancel.__comp_id__) {
									_cancel_handled = _cancel_owner.handle_keyboard_cancel_override(_input);
									if (_cancel_handled) {
										_cancel_handler_comp = _cancel_owner;
									}
								}
							}
							if (_cancel_handled) {
								set_last_input_modality(_nav_modality);
								_cancel_handler_comp.set_last_input_modality(_nav_modality);
								_input.nav.consumed = true;
								return;
							}
						}
					}
				}
				
				var _did_navigate = false;
				if (_input.nav.next.pressed || _input.nav.next.repeat) {
					_did_navigate = is_struct(_root.__focus_registry_navigate__("next", undefined, _nav_modality));
				}
				else if (_input.nav.prev.pressed || _input.nav.prev.repeat) {
					_did_navigate = is_struct(_root.__focus_registry_navigate__("prev", undefined, _nav_modality));
				}
				else if (_input.nav.left.pressed || _input.nav.left.repeat) {
					_did_navigate = is_struct(_root.__focus_registry_navigate__("left", undefined, _nav_modality));
				}
				else if (_input.nav.right.pressed || _input.nav.right.repeat) {
					_did_navigate = is_struct(_root.__focus_registry_navigate__("right", undefined, _nav_modality));
				}
				else if (_input.nav.up.pressed || _input.nav.up.repeat) {
					_did_navigate = is_struct(_root.__focus_registry_navigate__("up", undefined, _nav_modality));
				}
				else if (_input.nav.down.pressed || _input.nav.down.repeat) {
					_did_navigate = is_struct(_root.__focus_registry_navigate__("down", undefined, _nav_modality));
				}
				
				if (_did_navigate) {
					_input.nav.consumed = true;
				}
            }
			
        #endregion
		
		#region Variables
			
			background_color = c_black;
			
			//each component will have it's own events these will always be listed in this region
			
			#region GML Variables
				depth = 0;
				
				x = 0;
				y = 0;
				width = 0;
				height = 0;
				
				xstart = 0;
				ystart = 0;
				
				xprevious = 0;
				yprevious = 0;
				
				x_offset = 0;
				y_offset = 0;
				
				sprite_index   = undefined;
				sprite_height  = undefined;
				sprite_width   = undefined;
				sprite_xoffset = undefined;
				sprite_yoffset = undefined;
				
				visible = true;
				
				image_alpha  = undefined;
				image_angle  = undefined;
				image_blend  = undefined;
				image_index  = undefined;
				image_number = undefined;
				image_speed  = undefined;
				image_xscale = 1;
				image_yscale = 1;
				
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
			/// @returns {Undefined}
			#endregion
			static trigger_event = function(_event_id, _data=undefined) {
			    static __depth = 0;
			    static __queue = [];
				
				// if the event doesnt exist for some reason throw a warning message and continue
				var _event_arr = struct_get_from_hash(__event_listeners__, _event_id);
			    if (_event_arr == undefined) {
					if (!code_is_compiled() && !struct_exists_from_hash(events, _event_id)) {
						show_debug_message($"Event hash '{_event_id}' not registered for component '{debug_name}'.\n{json_stringify(debug_get_callstack(5), true)}")
					}
					
					return;
				}
					
				
			    // If we're in the middle of an event chain, queue this trigger rather than running it immediately.
			    if (__depth > 0) {
					var _this = self;
			        array_push(__queue, { event: _event_id, data: _data, this: _this });
			        return;
			    }
				
			    __depth++;
				_depth = __depth;
				
			    var _event_arr = struct_get_from_hash(__event_listeners__, _event_id);
			    if (_event_arr != undefined) {
			        var _size = array_length(_event_arr);
			        var _i = 0;
			        repeat(_size) {
			            var _struct = _event_arr[_i];
			            _struct.func(_data);
			            _i += 1;
			        }
			    }
				
			    __depth--;
				
			    // If we're back at the root, process any queued events.
			    if (__depth == 0 && array_length(__queue) > 0) {
			        while (array_length(__queue) > 0) {
			            var queued = array_shift(__queue); // Remove the first queued event.
			            with (queued.this) trigger_event(queued.event, queued.data);
			        }
			    }
			};
			
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
				if (struct_get_from_hash(__event_listeners__, _hash) == undefined) {
					struct_set_from_hash(__event_listeners__, _hash, [])
				}
				
				var _uid = __event_listener_uid__;
				__event_listener_uid__+=1;
				var _arr = struct_get_from_hash(__event_listeners__, _hash)
				array_push(_arr, {func: _func, UID: _uid});
				struct_set_from_hash(__event_listeners__, _hash, _arr)
				
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
				if (struct_get_from_hash(__event_listeners__, _hash) == undefined) {
					struct_set_from_hash(__event_listeners__, _hash, [])
				}
				
				var _uid = __event_listener_uid__;
				__event_listener_uid__+=1;
				var _arr = struct_get_from_hash(__event_listeners__, _hash)
				array_insert(_arr, _index, {func: _func, UID: _uid});
				struct_set_from_hash(__event_listeners__, _hash, _arr)
				
				return _uid
			}
			#region jsDoc
			/// @func    remove_event_listener()
			/// @desc    Remove an event listener to the component
			/// @self    WWCore
			/// @param   {Real} uid : The Unique ID of a previously added event function returned by add_event_listener.
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
						struct_set_from_hash(__event_listeners__, _hash, _event_arr)
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
			/// @param   {Real} event_id : The hash of the event_id, example: `event.change`
			/// @returns {Bool}
			#endregion
			static event_exists = function(_event_id) {
				return struct_exists_from_hash(__event_listeners__, _event_id)
			}
			#region jsDoc
			/// @func   event_name(_event_id)
			/// @desc   Converts an event id into a readable event name string.
			/// @self   WWCore
			/// @param  {Real} event_id
			/// @returns {String} event_name_string
			#endregion
			static event_name = function(_event_id) {
				var _names = struct_get_names(events);
				var _len = array_length(_names)
				var _i=0; repeat(_len) {
					var _name = _names[_i];
					if (struct_get(events, _name) == _event_id) {
						return _name;
					}
				_i++}
				
				return undefined;
			}
			
			#endregion
			
			#region Getter Functions
			
			#region jsDoc
			/// @func    get_focusable()
			/// @desc    Returns whether this component can be focused/hovered/interacted with.
			/// @self    WWCore
			/// @returns {Bool} is_focusable
			#endregion
			static get_focusable = function() {
				return __is_focusable__;
			};
			#region jsDoc
			/// @func    get_functions()
			/// @desc    With this function you can retrieve an array populated with the names of the component's functions. Useful for learning what available public functions you have access to.
			/// @self    WWCore
			/// @returns {Array<String>}
			#endregion
			static get_functions = function() {
				static __core_static = static_get(WWCore);
				var _arr = [];
				var _statics = static_get(self);
				
				while (true) {
					var _names = variable_struct_get_names(_statics);
					var _size = array_length(_names);
					var _key;
					
					var _i = 0; repeat (_size) {
						_key = _names[_i];
						if (string_pos("__", _key) != 1) {
							if (!array_contains(_arr, _key)) {
								array_push(_arr, _key);
							}
						}
						_i += 1;
					}
					
					// Stop once we've included WWCore's statics.
					if (_statics == __core_static) { break; }
					
					// Walk to parent statics.
					var _next = static_get(_statics);
					if (_next == _statics) { break; } // safety
					_statics = _next;
				}
				
				return _arr;
			}
			#region jsDoc
			/// @func    get_builder_functions()
			/// @desc    With this function you can retrieve an array populated with the names of the component's builder functions. Useful for learning what functions you can make use of when initializing a the component.
			/// @self    WWCore
			/// @returns {Array<String>}
			#endregion
			static get_builder_functions = function() {
				static __core_static = static_get(WWCore);
				var _arr = [];
				var _statics = static_get(self);
				
				while (true) {
					var _names = variable_struct_get_names(_statics);
					var _size = array_length(_names);
					var _key;
					
					var _i = 0; repeat (_size) {
						_key = _names[_i];
						if (string_pos("set_", _key) == 1) {
							if (!array_contains(_arr, _key)) {
								array_push(_arr, _key);
							}
						}
						_i += 1;
					}
					
					if (_statics == __core_static) { break; }
					var _next = static_get(_statics);
					if (_next == _statics) { break; }
					_statics = _next;
				}
				
				return _arr;
			}
			#region jsDoc
			/// @func    get_children_count()
			/// @desc    Returns the number of children this component directly controls. This will not include children of children.
			/// @self    WWCore
			/// @returns {Real}
			#endregion
			static get_children_count = function() {
				return __children_count__;
			}
			#region jsDoc
			/// @func    get_sub_children_count()
			/// @desc    Returns the number of all children. This will include all children of children.
			/// @self    WWCore
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
			/// @self    WWCore
			/// @returns {Array<Struct.WWCore>}
			#endregion
			static get_children = function() {
				return __children__
			}
			#region jsDoc
			/// @func   get_position()
			/// @desc   Returns the current position of this component.
			/// @self   WWCore
			/// @returns {Struct} position_struct_with_x_y
			#endregion
			static get_position = function() {
				return { x: x, y: y };
			};
			#region jsDoc
			/// @func   get_size()
			/// @desc   Returns the current size of this component.
			/// @self   WWCore
			/// @returns {Struct} size_struct_with_width_height
			#endregion
			static get_size = function() {
				return { width: width, height: height };
			};
			#region jsDoc
			/// @func   get_offset()
			/// @desc   Returns the current draw offset for this component.
			/// @self   WWCore
			/// @returns {Struct} offset_struct_with_x_y
			#endregion
			static get_offset = function() {
				return { x: x_offset, y: y_offset };
			};
			#region jsDoc
			/// @func   get_alignment()
			/// @desc   Returns the current horizontal and vertical alignment.
			/// @self   WWCore
			/// @returns {Struct} alignment_struct_with_halign_valign
			#endregion
			static get_alignment = function() {
				return { halign: __halign__, valign: __valign__ };
			};
			#region jsDoc
			/// @func   get_width()
			/// @desc   Returns the current width of this component.
			/// @self   WWCore
			/// @returns {Real} width_value
			#endregion
			static get_width = function() {
				return width;
			};
			#region jsDoc
			/// @func   get_height()
			/// @desc   Returns the current height of this component.
			/// @self   WWCore
			/// @returns {Real} height_value
			#endregion
			static get_height = function() {
				return height;
			};
			#region jsDoc
			/// @func   get_sprite()
			/// @desc   Returns the current sprite assigned to this component.
			/// @self   WWCore
			/// @returns {Asset.GMSprite} sprite_asset
			#endregion
			static get_sprite = function() {
				return sprite_index;
			};
			#region jsDoc
			/// @func   get_sprite_angle()
			/// @desc   Returns the current sprite rotation angle.
			/// @self   WWCore
			/// @returns {Real} angle_degrees
			#endregion
			static get_sprite_angle = function() {
				return image_angle;
			};
			#region jsDoc
			/// @func   get_sprite_color()
			/// @desc   Returns the current sprite color multiplier.
			/// @self   WWCore
			/// @returns {Real} color_value
			#endregion
			static get_sprite_color = function() {
				return image_blend;
			};
			#region jsDoc
			/// @func   get_sprite_alpha()
			/// @desc   Returns the current sprite alpha multiplier.
			/// @self   WWCore
			/// @returns {Real} alpha_value
			#endregion
			static get_sprite_alpha = function() {
				return image_alpha;
			};
			#region jsDoc
			/// @func   get_background_color()
			/// @desc   Returns the current background color and whether it is set.
			/// @self   WWCore
			/// @returns {Real} background_color
			#endregion
			static get_background_color = function() {
				return background_color;
			};
			#region jsDoc
			/// @func   get_enabled()
			/// @desc   Returns whether this component is enabled.
			/// @self   WWCore
			/// @returns {Bool} is_enabled
			#endregion
			static get_enabled = function() {
				return __is_enabled__;
			};
			#region jsDoc
			/// @func   get_active()
			/// @desc   Returns whether this component is active.
			/// @self   WWCore
			/// @returns {Bool} is_active
			#endregion
			static get_active = function() {
				return __is_active__;
			};
			#region jsDoc
			/// @func   get_debug()
			/// @desc   Returns whether debug drawing is enabled for this component.
			/// @self   WWCore
			/// @returns {Bool} is_debug_enabled
			#endregion
			static get_debug = function() {
				return __debug_enabled__;
			};
			#region jsDoc
			/// @func   get_group_width()
			/// @desc   Returns this component's cached group width (layout/collision extents).
			///         Override in composite components when raw __group__ is not suitable.
			/// @self   WWCore
			/// @returns {Real} group_width
			#endregion
			static get_group_width = function() {
				return __group__.width;
			};
			#region jsDoc
			/// @func   get_group_height()
			/// @desc   Returns this component's cached group height (layout/collision extents).
			///         Override in composite components when raw __group__ is not suitable.
			/// @self   WWCore
			/// @returns {Real} group_height
			#endregion
			static get_group_height = function() {
				return __group__.height;
			};
			#endregion
			
			#region Input Functions
			
			#region jsDoc
			/// @func    mouse_on_comp()
			/// @desc    Checks to see if the mouse is currently on the component. Used for optimization when hundreds of components are available.
			/// @self    WWCore
			/// @returns {Bool}
			#endregion
			static mouse_on_comp = function(_input=undefined) {
				//check if parent even has a mouse over it
				if (__is_child__) {
					if (!__parent__.__mouse_on_group__) {
						return false;
					}
				}
				
				if (!is_struct(_input)) _input = __user_input__;
				var _mx = is_struct(_input) && is_struct(_input.pointer) ? _input.pointer.x : 0;
				var _my = is_struct(_input) && is_struct(_input.pointer) ? _input.pointer.y : 0;
				__mouse_on_comp__ = point_in_rectangle(
					_mx,
					_my,
					x,
					y,
					x+width,
					y+height
				)
				
				return __mouse_on_comp__;
			}
			#region jsDoc
			/// @func    mouse_on_group()
			/// @desc    This function is internally used to help assist early outing collision checks.
			/// @self    WWCore
			/// @returns {Bool}
			#endregion
			static mouse_on_group = function(_input=undefined) {
				//check if parent even has a mouse over it
				if (__is_child__) {
					if (!__parent__.__mouse_on_group__) {
						return false;
					}
				}
				
				if (!is_struct(_input)) _input = __user_input__;
				var _mx = is_struct(_input) && is_struct(_input.pointer) ? _input.pointer.x : 0;
				var _my = is_struct(_input) && is_struct(_input.pointer) ? _input.pointer.y : 0;
				__mouse_on_group__ = point_in_rectangle(
						_mx,
						_my,
						x,
						y,
						x+__group__.width,
						y+__group__.height
				);
				
				return __mouse_on_group__;
			}
			#region jsDoc
			/// @func    build_input_state()
			/// @desc    Builds the WW input schema. When sampling is enabled, reads current device state.
			/// @self    WWCore
			/// @param   {Bool} sample_runtime : True to sample keyboard/mouse state.
			/// @returns {Struct}
			#endregion
			static build_input_state = function(_sample_runtime=true) {
				return __build_input_state__(_sample_runtime);
			}
			static __build_input_action__ = function() {
				return {
					pressed:false,
					down:false,
					released:false,
					repeat:false,
				};
			}
			static __build_input_schema__ = function() {
				return {
					frame_time_ms : current_time,
					modality : "none",
					pointer : {
						x : device_mouse_x_to_gui(0),
						y : device_mouse_y_to_gui(0),
						left : __build_input_action__(),
						right : __build_input_action__(),
						middle : __build_input_action__(),
						wheel_up : false,
						wheel_down : false,
						wheel_left : false,
						wheel_right : false,
						consumed : false,
					},
					keyboard : {
						key_down : function(_key) { return false; },
						key_pressed : function(_key) { return false; },
						key_released : function(_key) { return false; },
						key_repeat : function(_key) { return false; },
					},
					nav : {
						left : __build_input_action__(),
						right : __build_input_action__(),
						up : __build_input_action__(),
						down : __build_input_action__(),
						next : __build_input_action__(),
						prev : __build_input_action__(),
						submit : __build_input_action__(),
						cancel : __build_input_action__(),
						axis_x : 0,
						axis_y : 0,
						source : "none",
						consumed : false,
					},
					text : {
						input_string : "",
						backspace : __build_input_action__(),
						del : __build_input_action__(),
						consumed : false,
					},
				};
			}
			static __is_valid_input_schema__ = function(_input) {
				if (!is_struct(_input)) return false;
				if (!is_struct(_input.pointer) || !is_struct(_input.keyboard) || !is_struct(_input.nav) || !is_struct(_input.text)) return false;
				if (!is_struct(_input.pointer.left) || !is_struct(_input.pointer.right) || !is_struct(_input.pointer.middle)) return false;
				if (!is_struct(_input.nav.left) || !is_struct(_input.nav.right) || !is_struct(_input.nav.up) || !is_struct(_input.nav.down)) return false;
				if (!is_struct(_input.nav.next) || !is_struct(_input.nav.prev) || !is_struct(_input.nav.submit) || !is_struct(_input.nav.cancel)) return false;
				if (!is_struct(_input.text.backspace) || !is_struct(_input.text.del)) return false;
				if (!is_callable(_input.keyboard.key_down)) return false;
				if (!is_callable(_input.keyboard.key_pressed)) return false;
				if (!is_callable(_input.keyboard.key_released)) return false;
				if (!is_callable(_input.keyboard.key_repeat)) return false;
				return true;
			}
			static __input_repeat_pulse__ = function(_id, _down, _delay_ms, _interval_ms) {
				var _state = __input_repeat_state__[$ _id];
				if (!is_struct(_state)) {
					_state = {
						down : false,
						next_ms : 0,
					};
					__input_repeat_state__[$ _id] = _state;
				}
				
				if (!_down) {
					_state.down = false;
					_state.next_ms = 0;
					return false;
				}
				
				if (!_state.down) {
					_state.down = true;
					_state.next_ms = current_time + _delay_ms;
					return false;
				}
				
				if (current_time >= _state.next_ms) {
					while (current_time >= _state.next_ms) {
						_state.next_ms += _interval_ms;
					}
					return true;
				}
				
				return false;
			}
			static __build_input_state__ = function(_sample_runtime=true) {
				var _input = __build_input_schema__();
				if (!_sample_runtime) {
					return _input;
				}
				
				var _pointer = _input.pointer;
				_pointer.x = device_mouse_x_to_gui(0);
				_pointer.y = device_mouse_y_to_gui(0);
				_pointer.left.pressed = mouse_check_button_pressed(mb_left);
				_pointer.left.down = mouse_check_button(mb_left);
				_pointer.left.released = mouse_check_button_released(mb_left);
				_pointer.left.repeat = __input_repeat_pulse__(
					"pointer.left",
					_pointer.left.down,
					__input_repeat_config__.pointer_initial_delay_ms,
					__input_repeat_config__.pointer_interval_ms
				);
				
				_pointer.right.pressed = mouse_check_button_pressed(mb_right);
				_pointer.right.down = mouse_check_button(mb_right);
				_pointer.right.released = mouse_check_button_released(mb_right);
				_pointer.right.repeat = __input_repeat_pulse__(
					"pointer.right",
					_pointer.right.down,
					__input_repeat_config__.pointer_initial_delay_ms,
					__input_repeat_config__.pointer_interval_ms
				);
				
				_pointer.middle.pressed = mouse_check_button_pressed(mb_middle);
				_pointer.middle.down = mouse_check_button(mb_middle);
				_pointer.middle.released = mouse_check_button_released(mb_middle);
				_pointer.middle.repeat = __input_repeat_pulse__(
					"pointer.middle",
					_pointer.middle.down,
					__input_repeat_config__.pointer_initial_delay_ms,
					__input_repeat_config__.pointer_interval_ms
				);
				
				_pointer.wheel_up = mouse_wheel_up();
				_pointer.wheel_down = mouse_wheel_down();
				
				var _keyboard = _input.keyboard;
				_keyboard.key_down = function(_key) { return keyboard_check(_key); };
				_keyboard.key_pressed = function(_key) { return keyboard_check_pressed(_key); };
				_keyboard.key_released = function(_key) { return keyboard_check_released(_key); };
				_keyboard.key_repeat = function(_key) {
					return __input_repeat_pulse__(
						$"key.{_key}",
						keyboard_check(_key),
						__input_repeat_config__.text_initial_delay_ms,
						__input_repeat_config__.text_interval_ms
					);
				};

				var _nav = _input.nav;
				_nav.left.pressed = keyboard_check_pressed(vk_left);
				_nav.left.down = keyboard_check(vk_left);
				_nav.left.released = keyboard_check_released(vk_left);
				_nav.left.repeat = __input_repeat_pulse__(
					"nav.left",
					_nav.left.down,
					__input_repeat_config__.nav_initial_delay_ms,
					__input_repeat_config__.nav_interval_ms
				);
				
				_nav.right.pressed = keyboard_check_pressed(vk_right);
				_nav.right.down = keyboard_check(vk_right);
				_nav.right.released = keyboard_check_released(vk_right);
				_nav.right.repeat = __input_repeat_pulse__(
					"nav.right",
					_nav.right.down,
					__input_repeat_config__.nav_initial_delay_ms,
					__input_repeat_config__.nav_interval_ms
				);
				
				_nav.up.pressed = keyboard_check_pressed(vk_up);
				_nav.up.down = keyboard_check(vk_up);
				_nav.up.released = keyboard_check_released(vk_up);
				_nav.up.repeat = __input_repeat_pulse__(
					"nav.up",
					_nav.up.down,
					__input_repeat_config__.nav_initial_delay_ms,
					__input_repeat_config__.nav_interval_ms
				);
				
				_nav.down.pressed = keyboard_check_pressed(vk_down);
				_nav.down.down = keyboard_check(vk_down);
				_nav.down.released = keyboard_check_released(vk_down);
				_nav.down.repeat = __input_repeat_pulse__(
					"nav.down",
					_nav.down.down,
					__input_repeat_config__.nav_initial_delay_ms,
					__input_repeat_config__.nav_interval_ms
				);
				
				var _shift_down = keyboard_check(vk_shift);
				var _tab_pressed = keyboard_check_pressed(vk_tab);
				var _tab_down = keyboard_check(vk_tab);
				var _tab_released = keyboard_check_released(vk_tab);
				_nav.next.pressed = _tab_pressed && !_shift_down;
				_nav.next.down = _tab_down && !_shift_down;
				_nav.next.released = _tab_released;
				_nav.next.repeat = __input_repeat_pulse__(
					"nav.next",
					_nav.next.down,
					__input_repeat_config__.nav_initial_delay_ms,
					__input_repeat_config__.nav_interval_ms
				);
				
				_nav.prev.pressed = _tab_pressed && _shift_down;
				_nav.prev.down = _tab_down && _shift_down;
				_nav.prev.released = _tab_released;
				_nav.prev.repeat = __input_repeat_pulse__(
					"nav.prev",
					_nav.prev.down,
					__input_repeat_config__.nav_initial_delay_ms,
					__input_repeat_config__.nav_interval_ms
				);
				
				_nav.submit.pressed = keyboard_check_pressed(vk_enter);
				_nav.submit.down = keyboard_check(vk_enter);
				_nav.submit.released = keyboard_check_released(vk_enter);
				_nav.submit.repeat = __input_repeat_pulse__(
					"nav.submit",
					_nav.submit.down,
					__input_repeat_config__.nav_initial_delay_ms,
					__input_repeat_config__.nav_interval_ms
				);
				
				_nav.cancel.pressed = keyboard_check_pressed(vk_escape);
				_nav.cancel.down = keyboard_check(vk_escape);
				_nav.cancel.released = keyboard_check_released(vk_escape);
				_nav.cancel.repeat = __input_repeat_pulse__(
					"nav.cancel",
					_nav.cancel.down,
					__input_repeat_config__.nav_initial_delay_ms,
					__input_repeat_config__.nav_interval_ms
				);
				
				_nav.axis_x = (_nav.right.down ? 1 : 0) - (_nav.left.down ? 1 : 0);
				_nav.axis_y = (_nav.down.down ? 1 : 0) - (_nav.up.down ? 1 : 0);
				if (_nav.left.down || _nav.right.down || _nav.up.down || _nav.down.down
				|| _nav.next.down || _nav.prev.down || _nav.submit.down || _nav.cancel.down) {
					_nav.source = "keyboard";
				}
				
				var _text = _input.text;
				_text.input_string = keyboard_string;
				keyboard_string = "";
				_text.backspace.pressed = keyboard_check_pressed(vk_backspace);
				_text.backspace.down = keyboard_check(vk_backspace);
				_text.backspace.released = keyboard_check_released(vk_backspace);
				_text.backspace.repeat = __input_repeat_pulse__(
					"text.backspace",
					_text.backspace.down,
					__input_repeat_config__.text_initial_delay_ms,
					__input_repeat_config__.text_interval_ms
				);
				
				_text.del.pressed = keyboard_check_pressed(vk_delete);
				_text.del.down = keyboard_check(vk_delete);
				_text.del.released = keyboard_check_released(vk_delete);
				_text.del.repeat = __input_repeat_pulse__(
					"text.del",
					_text.del.down,
					__input_repeat_config__.text_initial_delay_ms,
					__input_repeat_config__.text_interval_ms
				);
				
				if (_pointer.left.down || _pointer.right.down || _pointer.middle.down
				|| _pointer.wheel_up || _pointer.wheel_down) {
					_input.modality = "mouse";
				}
				else if (_nav.source != "none"
				|| _text.input_string != ""
				|| _text.backspace.down
				|| _text.del.down) {
					_input.modality = "keyboard";
				}
				
				return _input;
			}
			#region jsDoc
			/// @func    consume_input()
			/// @desc    Marks pointer input as consumed so lower-priority components do not process it.
			/// @self    WWCore
			/// @returns {Undefined}
			#endregion
			static consume_input = function() {
				if (is_struct(__user_input__.pointer)) {
					__user_input__.pointer.consumed = true;
				}
				__is_pointer_consumer__ = true;
			}
			static consume_nav_input = function() {
				if (is_struct(__user_input__.nav)) {
					__user_input__.nav.consumed = true;
				}
			}
			static consume_text_input = function() {
				if (is_struct(__user_input__.text)) {
					__user_input__.text.consumed = true;
				}
			}
			
			#region Overlay Functions
			static bring_to_front = function() {
				if (!__overlay_component__) return self;
				if (!__overlay_registered__) {
					__overlay_sync__();
				}
				if (is_struct(__overlay_manager_owner__)) {
					var _mgr = __overlay_manager_owner__.__overlay_ensure_manager__();
					_mgr.seq_counter += 1;
					__overlay_order_seq__ = _mgr.seq_counter;
					_mgr.dirty = true;
				}
				return self;
			}
			
			static send_to_back = function() {
				if (!__overlay_component__) return self;
				__overlay_last_focus_time__ = -1;
				__overlay_order_seq__ = -1;
				if (is_struct(__overlay_manager_owner__)) {
					__overlay_manager_owner__.__overlay_ensure_manager__().dirty = true;
				}
				return self;
			}
			
			// Hoisted overlay methods; WWOverlay can override these.
			static overlay_step = function(_input=undefined) {
				step(_input);
			}
			
			static overlay_draw = function(_input=undefined, _debug=false) {
				draw(_input, _debug);
			}
			#endregion
			
			#endregion
			
			#region Sub Component Functions
			
			#region jsDoc
			/// @func    add()
			/// @desc    Add a Component to the controller.
			/// @self    WWCore
			/// @param   {Struct.WWCore|Array} comp : The component you wish to add to the controller.
			/// @returns {Undefined}
			#endregion
			static add = function(_comp) {
				__is_empty__ = false;
				
				var _arr = (is_array(_comp)) ? _comp : [_comp];
				
				if (argument_count > 1) {
					var _i=1; repeat(argument_count-1) {
						array_push(_arr, argument[_i])
						_i++
					}
				}
				
				__validate_component_additions__(_arr);
				
				__include_children__(_arr, -1);
				__focus_registry_mark_dirty__();
				
				update_component_positions();
				__update_group_region__();
				
			}
			#region jsDoc
			/// @func    add_inline()
			/// @desc    Lays out and adds components inline inside this controller.
			///          Components are grouped by a WWInline operator in the array.
			/// @self    WWCore
			/// @param   {Array<Struct>} componentsArray : Components and optional WWInline separators.
			/// @param   {Real} horizontalSpacing : Spacing between inline items.
			/// @param   {Real} verticalSpacing : Spacing between lines.
			/// @param   {Bool} scaleInline : True to scale components to fit the container width.
			/// @returns {Struct.WWCore}
			#endregion
			static add_inline = function(componentsArray, horizontalSpacing=0, verticalSpacing=0, scaleInline=true) {
				var lines = [];
			    var currentLine = [];
			    for (var i = 0; i < array_length(componentsArray); i++) {
			        var comp = componentsArray[i];
			        // Check if this element is our inline operator.
			        if (instanceof(comp) == "WWInline") {
			            continue;
			        }
			        // If the previous element was an inline operator, add this component to the current line.
			        if (i > 0 && (instanceof(componentsArray[i - 1]) == "WWInline")) {
			            array_push(currentLine, comp);
			        } else {
			            // If currentLine is not empty, push it into lines.
			            if (array_length(currentLine) > 0) {
			                array_push(lines, currentLine);
			            }
			            // Start a new line with the current component.
			            currentLine = [comp];
			        }
			    }
			    if (array_length(currentLine) > 0) {
			        array_push(lines, currentLine);
			    }
				
			    // Layout each line.
			    var cumulativeY = 0;
			    for (var l = 0; l < array_length(lines); l++) {
			        var line = lines[l];
			        // Determine maximum height among components in this line.
			        var lineHeight = 0;
			        for (var j = 0; j < array_length(line); j++) {
			            var comp = line[j];
			            var compHeight = (comp.height != undefined) ? comp.height : 30;
			            if (compHeight > lineHeight) {
			                lineHeight = compHeight;
			            }
			        }
					
			        // If scaling inline, calculate a common width for all components.
			        var numComponents = array_length(line);
			        var compWidthScaled = 0;
			        if (scaleInline) {
			            compWidthScaled = (width - (numComponents - 1) * horizontalSpacing) / numComponents;
			        }
					
			        // Layout components horizontally in this line.
			        var currentX = 0;
			        for (var j = 0; j < numComponents; j++) {
			            var comp = line[j];
			            var compWidth = scaleInline ? compWidthScaled : ((comp.width != undefined) ? comp.width : 100);
			            // Set component's offset relative to the container.
			            comp.set_offset(currentX, cumulativeY);
			            // If scaling, update the component's width accordingly.
			            if (scaleInline) {
			                comp.set_size(compWidth, (comp.height != undefined) ? comp.height : 30);
			            }
			            currentX += compWidth;
			            // Add horizontal spacing if not the last component in the line.
			            if (j < numComponents - 1) {
			                currentX += horizontalSpacing;
			            }
			            // Add the component to the container.
			            add(comp);
			        }
			        // Increase cumulativeY by the line's height plus vertical spacing (if not the last line).
			        cumulativeY += lineHeight;
			        if (l < array_length(lines) - 1) {
			            cumulativeY += verticalSpacing;
			        }
			    }
				
			    return self;
			}

			#region jsDoc
			/// @func    insert()
			/// @desc    Inserts a Component into the controller's children array.
			/// @self    WWCore
			/// @param   {Real} index : The index (possition) you wish to insert the component into the children array
			/// @param   {Struct.WWCore|Array} comp : The component you wish to add to the controller.
			/// @returns {Undefined}
			#endregion
			static insert = function(_index, _comp) {
				__is_empty__ = false;
				
				var _arr = (is_array(_comp)) ? _comp : [_comp];
				
				__validate_component_additions__(_arr);
				
				__include_children__(_comp, _index)
				__focus_registry_mark_dirty__();
				
				__update_group_region__();
				
				return __children_count__;
			}
			#region jsDoc
			/// @func    remove()
			/// @desc    Remove a Child Component from the children array.
			/// @self    WWCore
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
			/// @self    WWCore
			/// @param   {Real} index : The index of the component you wish to remove from the controller's children array.
			/// @returns {Undefined}
			#endregion
			static remove_index = function(_index) {
				if ((_index < 0) || (_index >= __children_count__)) return;
				__focus_registry_mark_dirty__();
				var _comp = __children__[_index];
				_comp.__overlay_unregister_subtree__();
				
				_comp.__is_child__ = false;
				_comp.__parent__ = noone;
				_comp.__root_canvas__ = _comp;
				_comp.__propagate_root_canvas__(_comp);
				
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
			/// @self    WWCore
			/// @param   {Struct.WWCore} comp : The component you wish to find the index of.
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
			/// @self    WWCore
			/// @returns {Undefined}
			#endregion
			static update_component_positions = function() {
				if (!__is_empty__) {
					//move the children
					var _i=0; repeat(__children_count__) {
						var _comp = __children__[_i];
						
						var _xx = __get_controller_archor_x__(_comp.__halign__);
						var _yy = __get_controller_archor_y__(_comp.__valign__);
						
						_comp.x = x + _xx + _comp.x_offset;
						_comp.y = y + _yy + _comp.y_offset;
						
						//if the component is a controller it's self have it update it's children
						_comp.update_component_positions();
					_i+=1;}//end repeat loop
					
				}
			}
			
			#region jsDoc
			/// @func    clear_children()
			/// @desc    Clears all children from the children array, deleting their structs and running their cleanup events. Use this when you are deleting components.
			/// @self    WWCore
			/// @returns {Undefined}
			#endregion
			static clear_children = function() {
				__focus_registry_mark_dirty__();
				var _i=0; repeat(__children_count__) {
					var _comp = __children__[_i];
					_comp.__overlay_unregister_subtree__();
					_comp.__is_child__ = false;
					_comp.__parent__ = noone;
					_comp.__root_canvas__ = _comp;
					_comp.__propagate_root_canvas__(_comp);
					_comp.__cleanup__();
					delete _comp
				_i+=1;}//end repeat loop
				array_resize(__children__, 0)
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
				if (!__is_active__) return;
				
				if (is_undefined(_input)) {
					_input = build_input_state(true);
				}
				else if (!__is_valid_input_schema__(_input)) {
					_input = build_input_state(false);
				}
				__user_input__ = _input;
				__mouse_on_group__ = mouse_on_group(_input);
				
				__overlay_step_pass__(_input);
				
				trigger_event(events.pre_step, _input);
				
				//run the children
				var _comp, xx, yy;
				var _count = __children_count__;
				var _i=_count; repeat(_count) { _i--;
					if (_i >= __children_count__) { continue; }
					_comp = __children__[_i];
					if (_comp.__overlay_component__ && _comp.__overlay_registered__) continue;
					_comp.step(_input);
				}//end repeat loop
				
				trigger_event(events.post_step, _input);
			};
			#region jsDoc
			/// @func    draw()
			/// @desc    Emulates the GML equivalant event.
			/// @self    WWCore
			/// @param   {Struct} input : The input struct components pass around to capture inputs
			/// @param   {Bool} debug : True to enable additional debug drawing.
			/// @returns {Undefined}
			#endregion
			static draw = function(_input=undefined, _debug=false) {
				if (!__is_active__) return;
				
				
				if (is_undefined(_input)) {
					if (is_struct(__user_input__)) {
						_input = __user_input__;
					}
					else {
						_input = build_input_state(false);
					}
				}
				else if (!__is_valid_input_schema__(_input)) {
					_input = build_input_state(false);
				}
				__user_input__ = _input;
				__mouse_on_group__ = mouse_on_group(_input);
				
				
				
				//if __is_focusable__
				if (__background_color_set__) {
					draw_sprite_stretched_ext(
						spr_ww_pixel,
						0,
						x,
						y,
						width,
						height,
						background_color,
						1
					);
				}
				
				//if __is_focusable__
				trigger_event(events.pre_draw, _input);
				
				//run the children
				var _comp, xx, yy;
				var _count = __children_count__;
				var _i=0; repeat(_count) {
					if (_i >= __children_count__) { break; }
					_comp = __children__[_i];
					if (_comp.__overlay_component__ && _comp.__overlay_registered__) { _i+=1; continue; }
					_comp.draw(_input, _debug);
				_i+=1;}//end repeat loop
				
				if (_debug || __debug_enabled__) {
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
					
					draw_text(x, y, string_join("\n",
						$"__is_enabled__ = {__is_enabled__};",
						$"__is_engaged__ = {__is_engaged__};",
						$"__is_pointer_over__ = {__is_pointer_over__};",
						$"__is_nav_target__ = {__is_nav_target__};",
						$"__is_input_consumer__ = {__is_input_consumer__};",
						$"__is_pointer_consumer__ = {__is_pointer_consumer__};",
						$"__is_pressed__ = {__is_pressed__};",
						$"__last_input_modality__ = {__last_input_modality__};",
						$"__visual_state__ = {__visual_state__};",
						"",
						$"WW_STATE_DISABLED = {WW_STATE_DISABLED};",
						$"WW_STATE_ACTIVE = {WW_STATE_ACTIVE};",
						$"WW_STATE_HOVER = {WW_STATE_HOVER};",
						$"WW_STATE_NAV = {WW_STATE_NAV};",
						$"WW_STATE_NORMAL = {WW_STATE_NORMAL};",
					))
				}
				
				__overlay_draw_pass__(_input, _debug);
				
				trigger_event(events.post_draw, _input);
			};
			
			#endregion
			
		#endregion
		
	#endregion
	
	#region Private
		
		#region Variables
			
			static __GLOBAL_ID__ = 100000; // internally used to keep track of component indexes
			__comp_id__ = __GLOBAL_ID__++; // used to make sure we dont re add the same component to a controller
			__previous_scissor__ = undefined;
			
			__is_focusable__ = false; // Mark this component as focusable (set to false if a component should never receive focus)
			
			__is_enabled__ = true; //if the component is in a enabled/disabled state, typically if you want to grey out a button
			__is_active__  = true; //is the component's code is being executed
			
			__debug_enabled__ = false;
			
			__halign__ = fa_left;
			__valign__ = fa_top;
			
			__root_canvas__ = self; // The root component, this will be updated when components are added to one another. Primarily used when we need a popup or overlay
			
			#region Event Variables
			__event_listeners__ = {}; //the struct which will contain all of the event listener functions to be called when an event is triggered
			__event_listener_uid__ = 0; // a unique identifier for event listeners
			#endregion
			#region Input Variables
			__user_input__ = build_input_state(false);
			__input_repeat_state__ = {};
			__input_repeat_config__ = {
				nav_initial_delay_ms : 300,
				nav_interval_ms : 60,
				pointer_initial_delay_ms : 300,
				pointer_interval_ms : 60,
				text_initial_delay_ms : 350,
				text_interval_ms : 35,
			};
			__mouse_on_comp__  = false;
			__mouse_on_group__ = false;
			__click_held_timer__ = 0; //long press timer
			__last_click_time_single__ = 0; //timer to measure the distance from a single click to a double
			__last_click_time_double__ = 0; //timer to measure the distance from a double click to a triple
			__is_pointer_over__ = false; // pointer is currently over this component
			__is_nav_target__ = false; // keyboard/controller navigation has targeted this component
			__is_input_consumer__ = false; // component is the active consumer of typed/button input
			__is_engaged__ = false; // active interaction in progress (held, dragging, scrubbing, etc)
			__is_pointer_consumer__ = false; // pointer input was consumed by this component this step
			__last_input_modality__ = "unknown"; // mouse | keyboard | controller | touch | unknown
			__is_pressed__ = false; // pointer/button is currently pressed on this component
			// Legacy private aliases kept for WW migration compatibility.
			__is_interacting__ = false;
			__is_focused__ = false;
			__is_hovered__ = false;
			#endregion
			#region Sub Component Variables
			__is_empty__ = true;
			__children_count__ = 0;
			__children__ = [];
			__is_child__ = false; // if the component is a child of another component
			__parent__ = noone; // a reference to the parent controller
			__focus_registry__ = undefined;
			__group__ = {width : 0, height : 0};
			__overlay_host_enabled__ = false;
			__overlay_manager__ = undefined;
			__overlay_component__ = false;
			__overlay_enabled__ = true;
			__overlay_role__ = 0;
			__overlay_priority__ = 0;
			__overlay_always_on_top__ = false;
			__overlay_last_focus_time__ = -1;
			__overlay_order_seq__ = 0;
			__overlay_registered__ = false;
			__overlay_sync_dirty__ = false;
			__overlay_space__ = 0;
			__overlay_host__ = noone;
			__overlay_manager_owner__ = noone;
			#endregion
			#region Misc
			__position_set__ = false;
			__offset_set__   = false;
			__size_set__     = false;
			__background_color_set__ = false;
			#endregion
			
		#endregion
		
		#region Functions
			#region Input Priv Functions
			on_post_step(function(){
				__is_pointer_consumer__ = false;

				if (!__is_enabled__) {
					return;
				}

				if (self == __root_canvas__) {
					handle_keyboard_navigation(__user_input__);
				}
				
				var _mouse_on_group = mouse_on_group(__user_input__);
				if (_mouse_on_group) {
					trigger_event(events.mouse_over_group, __user_input__);
				}
				else {
					trigger_event(events.mouse_off_group, __user_input__);
				}
				
				var _mouse_on = mouse_on_comp(__user_input__);
				if (_mouse_on) {
					trigger_event(events.mouse_over, __user_input__);
				}
				else {
					trigger_event(events.mouse_off, __user_input__);
				}
				
				if (__is_pointer_over__) trigger_event(events.hover, __user_input__);
				if (__is_input_consumer__) trigger_event(events.focus, __user_input__);
				if (__is_engaged__) trigger_event(events.interact, __user_input__);
			})
			on_mouse_over(function(){
				if (!__is_enabled__) {
					return;
				}
				
				var _input_captured = __user_input__.pointer.consumed;
				set_hover(!_input_captured);
			})
			on_mouse_off(function(){
				set_hover(false);
				if (__user_input__.pointer.left.pressed || __user_input__.pointer.left.released) {
					set_focus(false);
				}
			})
			on_hover(function(){
				if (!__is_enabled__ || !__is_focusable__) {
					return;
				}
				
				consume_input();
				
				if (__user_input__.pointer.left.pressed) {
					trigger_event(events.pressed, __user_input__);
				}
				
			})
			on_pressed(function(){
				set_last_input_modality("mouse");
				set_pressed(true);
				set_interact(true);
				
				if (current_time - __last_click_time_double__ < 1_000/3) {
					trigger_event(events.triple_click, __user_input__);
					return;
				}
				
				if (current_time - __last_click_time_single__ < 1_000/3) {
					__last_click_time_double__ = current_time;
					trigger_event(events.double_click, __user_input__);
					return;
				}
				
				__last_click_time_single__ = current_time;
			})
			on_interact_enter(function(){
				if (!__is_enabled__ || !__is_focusable__) {
					return;
				}
				
				set_focus(true);
			})
			on_interact(function(_input) {
				if (!__is_enabled__ || !__is_focusable__) {
					set_pressed(false);
					return;
				}
				
				if (__user_input__.pointer.left.down) {
				    trigger_event(events.held, __user_input__);
						
				    // Handle long press timing
				    __click_held_timer__ += 1;
				    if (current_time-__click_held_timer__ > 1_000/3) {
				        trigger_event(events.long_press, __user_input__);
				    }
				}
				else {
					// Always clear interact once the button is no longer held.
					// This prevents visual "stuck pressed" states if a release edge is missed.
					var _did_release = __user_input__.pointer.left.released;
					set_pressed(false);
				    set_interact(false);
				    if (_did_release) {
						if (mouse_on_comp(__user_input__)) {
				    		trigger_event(events.released, __user_input__);
						}
				    }
				}
					
			})
			#endregion
			#region Sub Component Priv Functions
			#region jsDoc
			/// @func    __validate_component_additions__()
			/// @desc    Validates that we are not adding existing components to our controller, or that a supplied array of components does not contain duplicates.
			/// @self    WWCore
			/// @param   {Array<Struct>} arr : The array of structs to validate
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __validate_component_additions__ = function(_arr) {
				var _cid, _j, _found_count, _comp;
				var _size = array_length(_arr);
				var _i=0; repeat(_size) {
						_comp = _arr[_i];
						
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
			/// @self    WWCore
			/// @param   {Array<Struct>} arr : The array of components you wish to include into the children.
			/// @param   {Real} index : The index the array will be inserted into. Note: a value of -1 will push the array to the end.
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __include_children__ = function(_arr, _index) {
				var _size, _i, _comp, _new_root;
				
				_size = array_length(_arr);
				_i=0; repeat(_size) {
					_comp = _arr[_i];
					_comp.__is_child__ = true;
					_comp.__parent__ = self;
					_new_root = (__root_canvas__ == undefined) ? self : __root_canvas__;
					_comp.__root_canvas__ = _new_root;
					_comp.__propagate_root_canvas__(_new_root);
					_comp.__overlay_mark_subtree_dirty__();
					
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
					
					_comp.__overlay_sync_subtree__();
					
				_i+=1;}//end repeat loop
				
				__children_count__ += _size;
				__focus_registry_mark_dirty__();
				
			}
			#region jsDoc
			/// @func    __update_group_region__()
			/// @desc    Internal: recalculates the controller bounding region based on children.
			///          Used primarily for mouse hit testing and early-out collision checks.
			/// @self    WWCore
			/// @returns {Undefined}
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
					
					_w = max(_w, xoff + _comp.get_group_width());
					_h = max(_h, yoff + _comp.get_group_height());
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
			/// @returns {Real}
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
			#region jsDoc
			/// @func    __adopt_children_events__()
			/// @desc    Adopts all child component events into this component, wiring their events
			///          to re-dispatch through this component.
			/// @self    WWCore
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __adopt_children_events__ = function() {
				for (var _i=0; _i<array_length(__children__); _i++) {
					var _child = __children__[_i];
					__adopt_child_events__(_child);
				}
				
			}
			#region jsDoc
			/// @func    __adopt_child_events__()
			/// @desc    Wires a child component's events so they bubble through this component,
			///          and dynamically exposes on_<event>() helper functions for chaining.
			/// @self    WWCore
			/// @param   {Struct.WWCore} comp : Child component whose events are adopted.
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __adopt_child_events__ = function(_comp) {
				var _self = self;
				var _events = _comp.get_events();
				for (var _j=0; _j<array_length(_events); _j++) {
					
					var _event_id = _events[_j];
					var hash = _comp.events[$ _event_id];
					
					//set up the events
					_comp.add_event_listener(
						hash,
						method(
							{this: _self, event_id: hash},
							function(data){
								with (this) trigger_event(other.event_id, data)
							}
						)
					)
					
					//set up the functions
					self[$ $"on_{_event_id}"] = method(
						{this: _self, event_id: hash},
						function(_func){
							with (this) add_event_listener(other.event_id, _func)
							return this;
						}
					)
				}
			}
			#endregion
			#region Overlay Internals
			static __overlay_ensure_manager__ = function() {
				if (!is_struct(__overlay_manager__)) {
					__overlay_manager__ = {
						entries : [],
						dirty : false,
						seq_counter : 0,
						exec_step : [],
						exec_step_count : 0,
						exec_draw : [],
						exec_draw_count : 0,
					};
				}
				return __overlay_manager__;
			}
			
			static __overlay_is_effectively_active__ = function() {
				var _node = self;
				while (is_struct(_node)) {
					if (!_node.__is_active__) return false;
					if (!_node.__is_child__) break;
					_node = _node.__parent__;
				}
				return true;
			}
			
			static __resolve_overlay_host__ = function() {
				if (!__overlay_component__) return noone;
				
				// LOCAL_HOST
				if (__overlay_space__ == 1) {
					if (is_struct(__overlay_host__)) {
						if (__overlay_host__.__comp_id__ != __comp_id__
						&& __overlay_host__.__overlay_host_enabled__) {
							return __overlay_host__;
						}
					}
					
					var _node = __parent__;
					while (is_struct(_node)) {
						if (_node.__overlay_host_enabled__) return _node;
						if (!_node.__is_child__) break;
						_node = _node.__parent__;
					}
				}
				
				return __root_canvas__;
			}
			
			static __overlay_sync__ = function() {
				if (!__overlay_component__) return;
				if (__overlay_registered__ && !__overlay_sync_dirty__) return;
				
				static __overlay_local_unregister__ = function() {
					var _mgr_owner = __overlay_manager_owner__;
					if (is_struct(_mgr_owner) && is_struct(_mgr_owner.__overlay_manager__)) {
						var _entries = _mgr_owner.__overlay_manager__.entries;
						var _j = array_length(_entries);
						repeat(array_length(_entries)) { _j--;
							var _entry = _entries[_j];
							if (_entry.__comp_id__ != __comp_id__) continue;
							array_delete(_entries, _j, 1);
							_mgr_owner.__overlay_manager__.dirty = true;
						}
					}
					__overlay_registered__ = false;
					__overlay_manager_owner__ = noone;
					__overlay_sync_dirty__ = true;
				}
				
				if (!__overlay_enabled__)
				|| (!__is_child__)
				|| (!__overlay_is_effectively_active__()) {
					__overlay_local_unregister__();
					__overlay_sync_dirty__ = false;
					return;
				}
				
				var _target = __resolve_overlay_host__();
				if (!is_struct(_target)) {
					__overlay_local_unregister__();
					__overlay_sync_dirty__ = false;
					return;
				}
				
				if (__overlay_registered__ && is_struct(__overlay_manager_owner__)) {
					if (__overlay_manager_owner__.__comp_id__ == _target.__comp_id__) {
						_target.__overlay_ensure_manager__().dirty = true;
						__overlay_sync_dirty__ = false;
						return;
					}
				}
				
				__overlay_local_unregister__();
				
				var _manager = _target.__overlay_ensure_manager__();
				if (__overlay_order_seq__ == 0) {
					_manager.seq_counter += 1;
					__overlay_order_seq__ = _manager.seq_counter;
				}
				array_push(_manager.entries, self);
				__overlay_registered__ = true;
				__overlay_manager_owner__ = _target;
				__overlay_sync_dirty__ = false;
				_manager.dirty = true;
			}
			
			static __overlay_compare_data__ = function(_a, _b) {
				var _atop = (_a.__overlay_always_on_top__) ? 1 : 0;
				var _btop = (_b.__overlay_always_on_top__) ? 1 : 0;
				if (_atop != _btop) return _atop - _btop;
				
				var _abase = 100;
				switch(_a.__overlay_role__) {
					case 1: _abase = 200; break; // OVERLAY
					case 2: _abase = 300; break; // POPUP
					case 3: _abase = 300; break; // DROPDOWN
					case 4: _abase = 400; break; // CONTEXT_MENU
					case 5: _abase = 500; break; // TOOLTIP
				}
				var _bbase = 100;
				switch(_b.__overlay_role__) {
					case 1: _bbase = 200; break;
					case 2: _bbase = 300; break;
					case 3: _bbase = 300; break;
					case 4: _bbase = 400; break;
					case 5: _bbase = 500; break;
				}
				var _ap = _abase + _a.__overlay_priority__;
				var _bp = _bbase + _b.__overlay_priority__;
				if (_ap != _bp) return _ap - _bp;
				
				if (_a.__overlay_last_focus_time__ != _b.__overlay_last_focus_time__) return _a.__overlay_last_focus_time__ - _b.__overlay_last_focus_time__;
				if (_a.__overlay_order_seq__ != _b.__overlay_order_seq__) return _a.__overlay_order_seq__ - _b.__overlay_order_seq__;
				
				return _a.__comp_id__ - _b.__comp_id__;
			}
			
			static __overlay_rebuild_exec__ = function() {
				if (!is_struct(__overlay_manager__)) return;
				if (!__overlay_manager__.dirty) return;
				array_sort(__overlay_manager__.entries, __overlay_compare_data__);
				
				__overlay_manager__.exec_step_count = 0;
				__overlay_manager__.exec_draw_count = 0;
				var _entries = __overlay_manager__.entries;
				var _size = array_length(_entries);
				var _i=0; repeat(_size) {
					var _comp = _entries[_i];
					__overlay_manager__.exec_step[__overlay_manager__.exec_step_count] = _comp;
					__overlay_manager__.exec_step_count += 1;
					__overlay_manager__.exec_draw[__overlay_manager__.exec_draw_count] = _comp;
					__overlay_manager__.exec_draw_count += 1;
				_i+=1;}
				__overlay_manager__.dirty = false;
			}
			
			static __overlay_step_pass__ = function(_input) {
				if (!is_struct(__overlay_manager__)) return;
				__overlay_rebuild_exec__();
				var _i=__overlay_manager__.exec_step_count;
				repeat(__overlay_manager__.exec_step_count) { _i--;
					__overlay_manager__.exec_step[_i].overlay_step(_input);
				}
			}
			
			static __overlay_draw_pass__ = function(_input, _debug=false) {
				if (!is_struct(__overlay_manager__)) return;
				__overlay_rebuild_exec__();
				
				var _use_clip = (__overlay_host_enabled__ && __is_child__);
				if (_use_clip) __apply_clipping_region__();
				
				var _i=0; repeat(__overlay_manager__.exec_draw_count) {
					__overlay_manager__.exec_draw[_i].overlay_draw(_input, _debug);
				_i+=1;}
				
				if (_use_clip) __restore_clipping_region__();
			}
			
			static __propagate_root_canvas__ = function(_new_root) {
				var _old_root = __root_canvas__;
				var _stack = [self];
				while (array_length(_stack) > 0) {
					var _node = array_pop(_stack);
					_node.__root_canvas__ = _new_root;
					_node.__focus_registry_mark_dirty__();
					if (_node.__overlay_component__) {
						_node.__overlay_sync_dirty__ = true;
					}
					var _i=0; repeat(_node.__children_count__) {
						array_push(_stack, _node.__children__[_i]);
					_i+=1;}
				}
				if (is_struct(_old_root)) {
					_old_root.__focus_registry_mark_dirty__();
				}
			}
			
			static __overlay_mark_subtree_dirty__ = function() {
				var _stack = [self];
				while (array_length(_stack) > 0) {
					var _node = array_pop(_stack);
					if (_node.__overlay_component__) {
						_node.__overlay_sync_dirty__ = true;
					}
					var _i=0; repeat(_node.__children_count__) {
						array_push(_stack, _node.__children__[_i]);
					_i+=1;}
				}
			}
			
			static __overlay_sync_subtree__ = function() {
				var _stack = [self];
				while (array_length(_stack) > 0) {
					var _node = array_pop(_stack);
					_node.__overlay_sync__();
					var _i=0; repeat(_node.__children_count__) {
						array_push(_stack, _node.__children__[_i]);
					_i+=1;}
				}
			}
			
			static __overlay_unregister_subtree__ = function() {
				var _stack = [self];
				while (array_length(_stack) > 0) {
					var _node = array_pop(_stack);
					if (_node.__overlay_component__) {
						var _mgr_owner = _node.__overlay_manager_owner__;
						if (is_struct(_mgr_owner) && is_struct(_mgr_owner.__overlay_manager__)) {
							var _entries = _mgr_owner.__overlay_manager__.entries;
							var _j = array_length(_entries);
							repeat(array_length(_entries)) { _j--;
								var _entry = _entries[_j];
								if (_entry.__comp_id__ != _node.__comp_id__) continue;
								array_delete(_entries, _j, 1);
								_mgr_owner.__overlay_manager__.dirty = true;
							}
						}
						
						_node.__overlay_registered__ = false;
						_node.__overlay_manager_owner__ = noone;
						_node.__overlay_sync_dirty__ = true;
					}
					
					var _i=0; repeat(_node.__children_count__) {
						array_push(_stack, _node.__children__[_i]);
					_i+=1;}
				}
			}
			#endregion
			#region Render Clipping
			#region jsDoc
			/// @func    __apply_clipping_region__()
			/// @desc    Sets the GPU scissor region to limit rendering to the viewport bounds.
			/// @self    WWCore
			/// @returns {Undefined}
			/// @ignore
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
			/// @self    WWCore
			/// @returns {Undefined}
			/// @ignore
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
			/// @ignore
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
				
				sprite_index = _sprite;
				
				if (!sprite_exists(_sprite)) return self;
				
				sprite_height  = image_yscale * sprite_get_height(_sprite);
				sprite_width   = image_xscale * sprite_get_width(_sprite);
				sprite_xoffset = image_xscale * sprite_get_xoffset(_sprite);
				sprite_yoffset = image_yscale * sprite_get_yoffset(_sprite);
				
				image_index  = 0;
				image_number = sprite_get_number(_sprite);
				image_speed  = sprite_get_speed(_sprite);
				
				visible = true;
				
				return self;
			}
			#region jsDoc
			/// @func    __set_size__()
			/// @desc    Sets the user-preferred size (width/height) and updates regions; note: some components will have a minimum size override.
			/// @self    WWCore
			/// @param   {Real} width : The width of the component
			/// @param   {Real} height : The height of the component
			/// @returns {Struct.WWCore}
			/// @ignore
			#endregion
			static __set_size__ = function(_width, _height) {
				width  = _width ;
				height = _height;
				
				//update click regions
				update_component_positions();
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
			/// @ignore
			#endregion
			static __set_position__ = function(_x, _y) {
				if (_x == x && _y == y) return self; // Avoid redundant updates
				
				xprevious = x;
				yprevious = y;
				x = _x;
				y = _y;
				
				update_component_positions();
				
				// If this component is a child, trigger an update on the parent's group size.
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
			/// @ignore
			#endregion
			static __set_offset__ = function(_x, _y) {
			    if (_x == x_offset && _y == y_offset) return self; // Avoid redundant updates
				
				x_offset = _x;
			    y_offset = _y;
				
			    // Recalculate position based on parent
			    if (__is_child__) {
					xprevious = x;
					yprevious = y;
					x = __parent__.x + x_offset;
					y = __parent__.y + y_offset;
					
					update_component_positions();
					
			    	__parent__.__update_group_region__();
			    }
				
			    return self;
			};
			#region jsDoc
			/// @func    __get_controller_archor_x__()
			/// @desc    Gets the anchor's desired x location from the controller region.
			/// @self    WWCore
			/// @param   {Constant.HAlign} halign : Horizontal alignment.
			/// @returns {Real}
			/// @ignore
			#endregion
			static __get_controller_archor_x__ = function(_halign=fa_center) {
				switch (_halign) {
					default:
					case fa_left:{
						 return 0;
					}
					case fa_center:{
						 return floor(width/2 + 0.5);
					}
					case fa_right:{
						return width;
					}
				}
			}
			#region jsDoc
			/// @func    __get_controller_archor_y__()
			/// @desc    Gets the anchor's desired y location from the controller region.
			/// @self    WWCore
			/// @param   {Constant.VAlign} valign : Vertical alignment.
			/// @returns {Real}
			/// @ignore
			#endregion
			static __get_controller_archor_y__= function(_valign=fa_middle) {
				switch (_valign) {
					default:
					case fa_top:{
						 return 0;
					}
					case fa_middle:{
						 return floor(height/2 + 0.5);
					}
					case fa_bottom:{
						 return height;
					}
				}
			}
			static __focus_registry_ensure__ = function() {
				var _root = __root_canvas__;
				if (!is_struct(_root)) _root = self;
				if (!is_struct(_root.__focus_registry__)) {
					_root.__focus_registry__ = {
						entries : [],
						count : 0,
						dirty : true,
					};
				}
				return _root.__focus_registry__;
			}
			static __focus_registry_mark_dirty__ = function() {
				var _root = __root_canvas__;
				if (!is_struct(_root)) _root = self;
				if (!is_struct(_root.__focus_registry__)) {
					_root.__focus_registry__ = {
						entries : [],
						count : 0,
						dirty : true,
					};
				}
				else {
					_root.__focus_registry__.dirty = true;
				}
			}
			static __find_ancestor_folder__ = function() {
				var _node = self;
				while (is_struct(_node) && _node.__is_child__) {
					var _parent = _node.__parent__;
					if (!is_struct(_parent)) break;
					if (variable_struct_exists(_parent, "__is_ww_folder__")) {
						if (_parent.__is_ww_folder__) {
							return _parent;
						}
					}
					_node = _parent;
				}
				return noone;
			}
			static __focus_registry_is_navigable__ = function(_comp) {
				if (!is_struct(_comp)) return false;
				if (!_comp.__is_focusable__) return false;
				if (!_comp.__is_enabled__) return false;
				if (!_comp.__is_active__) return false;
				if (variable_struct_exists(_comp, "visible")) {
					if (!_comp.visible) return false;
				}
				return true;
			}
			static __focus_registry_rebuild__ = function() {
				var _root = __root_canvas__;
				if (!is_struct(_root)) _root = self;
				var _registry = _root.__focus_registry_ensure__();
				
				array_resize(_registry.entries, 0);
				_registry.count = 0;
				
				var _stack = [{ node:_root, ancestor_allows:true }];
				while (array_length(_stack) > 0) {
					var _entry = array_pop(_stack);
					var _node = _entry.node;
					var _ancestor_allows = _entry.ancestor_allows;
					
					var _node_allows = _ancestor_allows && _node.__is_active__;
					if (_node_allows && variable_struct_exists(_node, "visible")) {
						if (!_node.visible) _node_allows = false;
					}
					
					if (_node_allows && _root.__focus_registry_is_navigable__(_node)) {
						array_push(_registry.entries, _node);
						_registry.count += 1;
					}
					
					var _i = _node.__children_count__;
					repeat (_node.__children_count__) {
						_i -= 1;
						array_push(_stack, {
							node:_node.__children__[_i],
							ancestor_allows:_node_allows
						});
					}
				}
				
				var _entries = _registry.entries;
				var _count = array_length(_entries);
				var _first_nav = noone;
				var _first_input = noone;
				var _j = 0;
				repeat (_count) {
					var _comp = _entries[_j];
					if (_comp.__is_nav_target__) {
						if (!is_struct(_first_nav)) {
							_first_nav = _comp;
						}
						else {
							_comp.set_nav_target(false);
						}
					}
					if (_comp.__is_input_consumer__) {
						if (!is_struct(_first_input)) {
							_first_input = _comp;
						}
						else {
							_comp.set_input_consumer(false);
						}
					}
					_j += 1;
				}
				
				if (is_struct(_first_input) && !is_struct(_first_nav)) {
					_first_input.set_nav_target(true);
					_first_nav = _first_input;
				}
				
				_registry.dirty = false;
				return _registry;
			}
			static __focus_registry_get_entries__ = function() {
				var _root = __root_canvas__;
				if (!is_struct(_root)) _root = self;
				var _registry = _root.__focus_registry_ensure__();
				if (_registry.dirty) {
					_registry = _root.__focus_registry_rebuild__();
				}
				return _registry;
			}
			static __focus_registry_find_index_by_id__ = function(_entries, _count, _comp_id) {
				var _i = 0;
				repeat (_count) {
					if (_entries[_i].__comp_id__ == _comp_id) return _i;
					_i += 1;
				}
				return -1;
			}
			static __focus_registry_find_current_index__ = function(_entries, _count) {
				var _i = 0;
				repeat (_count) {
					if (_entries[_i].__is_nav_target__) return _i;
					_i += 1;
				}
				_i = 0;
				repeat (_count) {
					if (_entries[_i].__is_input_consumer__) return _i;
					_i += 1;
				}
				return -1;
			}
			static __focus_registry_component_yields_nav__ = function(_comp, _direction) {
				if (!is_struct(_comp)) return true;
				if (variable_struct_exists(_comp, "should_yield_keyboard_nav")) {
					var _func = _comp.should_yield_keyboard_nav;
					if (is_callable(_func)) {
						var _bound = method(_comp, _func);
						return !!_bound(_direction);
					}
				}
				return true;
			}
			static __focus_registry_component_override_target__ = function(_comp, _direction) {
				if (!is_struct(_comp)) return undefined;
				if (!variable_struct_exists(_comp, "handle_keyboard_nav_override")) return undefined;
				
				var _func = _comp.handle_keyboard_nav_override;
				if (!is_callable(_func)) return undefined;
				
				var _bound = method(_comp, _func);
				var _result = _bound(_direction);
				if (is_struct(_result)) return _result;
				if (is_bool(_result) && _result) return _comp;
				return undefined;
			}
			static __resolve_dropdown_owner_for_nav__ = function(_comp) {
				if (!is_struct(_comp)) return noone;
				var _node = _comp;
				repeat (16) {
					if (variable_struct_exists(_node, "__dropdown_owner__")) {
						var _owner = _node.__dropdown_owner__;
						if (is_struct(_owner)) return _owner;
					}
					if (!variable_struct_exists(_node, "__parent__")) break;
					var _parent = _node.__parent__;
					if (!is_struct(_parent)) break;
					_node = _parent;
				}
				return noone;
			}
			static __focus_registry_should_auto_consume_on_nav_target__ = function(_comp) {
				if (!is_struct(_comp)) return true;
				if (!variable_struct_exists(_comp, "should_auto_consume_on_nav_target")) return true;
				
				var _func = _comp.should_auto_consume_on_nav_target;
				if (!is_callable(_func)) return true;
				
				var _bound = method(_comp, _func);
				return !!_bound();
			}
			static __focus_registry_set_target__ = function(_target, _set_input_consumer=true) {
				if (!is_struct(_target)) return noone;
				
				var _registry = __focus_registry_get_entries__();
				var _entries = _registry.entries;
				var _count = array_length(_entries);
				var _target_index = __focus_registry_find_index_by_id__(_entries, _count, _target.__comp_id__);
				if (_target_index < 0) return noone;
				
				var _i = 0;
				repeat (_count) {
					var _comp = _entries[_i];
					if (_i != _target_index) {
						if (_comp.__is_nav_target__) _comp.set_nav_target(false);
						if (_comp.__is_input_consumer__) _comp.set_input_consumer(false);
					}
					_i += 1;
				}
				
				var _target_comp = _entries[_target_index];
				if (!_target_comp.__is_nav_target__) _target_comp.set_nav_target(true);
				if (!_set_input_consumer && _target_comp.__is_input_consumer__) {
					_target_comp.set_input_consumer(false);
				}
				if (_set_input_consumer && !_target_comp.__is_input_consumer__) {
					_target_comp.set_input_consumer(true);
				}
				
				return _target_comp;
			}
			static __focus_registry_find_linear_target__ = function(_entries, _count, _current_index, _dir) {
				if (_count <= 0) return noone;
				if (_current_index < 0 || _current_index >= _count) {
					if (_dir == "prev") return _entries[_count - 1];
					return _entries[0];
				}
				if (_dir == "prev") {
					var _prev = _current_index - 1;
					if (_prev < 0) _prev = _count - 1;
					return _entries[_prev];
				}
				var _next = _current_index + 1;
				if (_next >= _count) _next = 0;
				return _entries[_next];
			}
			static __focus_registry_find_directional_target__ = function(_entries, _count, _current_index, _dir) {
				if (_count <= 0) return noone;
				
				if (_current_index < 0 || _current_index >= _count) {
					var _fallback = (_dir == "left" || _dir == "up") ? "prev" : "next";
					return __focus_registry_find_linear_target__(_entries, _count, -1, _fallback);
				}
				
				var _current = _entries[_current_index];
				var _cx = _current.x + _current.width * 0.5;
				var _cy = _current.y + _current.height * 0.5;
				var _best = noone;
				var _best_score = infinity;
				
				var _i = 0;
				repeat (_count) {
					if (_i != _current_index) {
						var _candidate = _entries[_i];
						var _tx = _candidate.x + _candidate.width * 0.5;
						var _ty = _candidate.y + _candidate.height * 0.5;
						var _dx = _tx - _cx;
						var _dy = _ty - _cy;
						
						var _primary = 0;
						var _secondary = 0;
						switch (_dir) {
							case "left": {
								_primary = -_dx;
								_secondary = _dy;
							break;}
							case "right": {
								_primary = _dx;
								_secondary = _dy;
							break;}
							case "up": {
								_primary = -_dy;
								_secondary = _dx;
							break;}
							case "down": {
								_primary = _dy;
								_secondary = _dx;
							break;}
						}
						
						if (_primary > 0) {
							var _secondary_abs = abs(_secondary);
							var _score = (_primary * _primary) + (_secondary_abs * _secondary_abs * 4);
							if (_score < _best_score) {
								_best_score = _score;
								_best = _candidate;
							}
						}
					}
					
					_i += 1;
				}
				
				if (!is_struct(_best)) {
					var _fallback_dir = (_dir == "left" || _dir == "up") ? "prev" : "next";
					return __focus_registry_find_linear_target__(_entries, _count, _current_index, _fallback_dir);
				}
				
				return _best;
			}
			static __focus_registry_navigate__ = function(_dir, _from=undefined, _modality="unknown") {
				var _nav_modality = string_lower(string(_modality));
				switch (_nav_modality) {
					case "keyboard":
					case "controller":
					break;
					default: _nav_modality = "unknown"; break;
				}
				
				var _registry = __focus_registry_get_entries__();
				var _entries = _registry.entries;
				var _count = array_length(_entries);
				if (_count <= 0) return undefined;
				
				var _current_index = -1;
				if (is_struct(_from)) {
					_current_index = __focus_registry_find_index_by_id__(_entries, _count, _from.__comp_id__);
				}
				if (_current_index < 0) {
					_current_index = __focus_registry_find_current_index__(_entries, _count);
				}
				
				var _current = (_current_index >= 0) ? _entries[_current_index] : noone;
				if (!__focus_registry_component_yields_nav__(_current, _dir)) {
					return undefined;
				}
				
				var _override_target = __focus_registry_component_override_target__(_current, _dir);
				if (is_struct(_override_target)) {
					var _auto_consume_override = __focus_registry_should_auto_consume_on_nav_target__(_override_target);
					var _assigned_override = __focus_registry_set_target__(_override_target, _auto_consume_override);
					if (is_struct(_assigned_override)) {
						set_last_input_modality(_nav_modality);
						_assigned_override.set_last_input_modality(_nav_modality);
						return _assigned_override;
					}
					return undefined;
				}
				
				var _target = noone;
				switch (_dir) {
					case "next": {
						_target = __focus_registry_find_linear_target__(_entries, _count, _current_index, "next");
					break;}
					case "prev": {
						_target = __focus_registry_find_linear_target__(_entries, _count, _current_index, "prev");
					break;}
					case "left":
					case "right":
					case "up":
					case "down": {
						_target = __focus_registry_find_directional_target__(_entries, _count, _current_index, _dir);
					break;}
					default: {
						return undefined;
					}
				}
				
				if (!is_struct(_target)) return undefined;
				if (is_struct(_current) && _target.__comp_id__ == _current.__comp_id__) return undefined;
				
				var _auto_consume = __focus_registry_should_auto_consume_on_nav_target__(_target);
				var _assigned = __focus_registry_set_target__(_target, _auto_consume);
				if (is_struct(_assigned)) {
					set_last_input_modality(_nav_modality);
					_assigned.set_last_input_modality(_nav_modality);
					return _assigned;
				}
				
				return undefined;
			}
			static __recalc_visual_state__ = function() {
				if (!__is_enabled__)    { 
					__visual_state__ = WW_STATE_DISABLED; return; 
					}
				if (__is_engaged__) { 
					__visual_state__ = WW_STATE_ACTIVE; return; 
					}
				if (__is_pointer_over__)     { 
					__visual_state__ = WW_STATE_HOVER; return; 
					}
				if (__is_nav_target__
				&& (__last_input_modality__ == "keyboard"
				|| __last_input_modality__ == "controller")) { 
					__visual_state__ = WW_STATE_NAV; return; 
					}
				//else
				__visual_state__ = WW_STATE_NORMAL;
			};
			static __sync_legacy_input_flags__ = function() {
				__is_interacting__ = __is_engaged__;
				__is_focused__ = __is_input_consumer__;
				__is_hovered__ = __is_pointer_over__;
			};
			#region jsDoc
			/// @func    __cleanup__()
			/// @desc    Used to cleanup anything the component may have created
			/// @self    WWCore
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __cleanup__ = function(){
				//empty function to overwrite by others.
			}
			#endregion
		#endregion
		
	#endregion
	
}

//before anything else initialize core to prevent a GM bug
//	https://github.com/YoYoGames/GameMaker-Bugs/issues/13747
//	https://github.com/YoYoGames/GameMaker-Bugs/issues/13663
var _last_resort = new WWCore();

