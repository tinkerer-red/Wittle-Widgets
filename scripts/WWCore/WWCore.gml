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
				if (!__is_focusable__) {
					set_focus(false);
					set_hover(false);
					set_interact(false);
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
			static set_focus = function(_focus) {
			    if (_focus && !__is_focused__) {
					__is_focused__ = true;
					if (__overlay_component__) {
						__overlay_last_focus_time__ = current_time;
						bring_to_front();
					}
					trigger_event(events.focus_enter);
					trigger_event(events.focus);
				}
			    else if (!_focus && __is_focused__) {
					__is_focused__ = false;
					trigger_event(events.focus_exit);
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
			static set_hover = function(_hover) {
			    if (_hover && !__is_hovered__) {
					__is_hovered__ = true;
					trigger_event(events.hover_enter);
					trigger_event(events.hover);
				}
			    else if (!_hover && __is_hovered__) {
					__is_hovered__ = false;
					trigger_event(events.hover_exit);
				}
				else {
					__is_hovered__ = _hover;
				}
			    return self;
			}
			#region jsDoc
			/// @func    set_interact()
			/// @desc    Sets the interaction state for this component.
			/// @self    WWCore
			/// @param   {Bool} interact : True while interacting; false to stop.
			/// @returns {Struct.WWCore}
			#endregion
			static set_interact = function(_interact) {
			    if (_interact && !__is_interacting__) {
					__is_interacting__ = true;
					trigger_event(events.interact_enter);
					trigger_event(events.interact);
				}
			    else if (!_interact && __is_interacting__) {
					__is_interacting__ = false;
					trigger_event(events.interact_exit);
				}
				else {
					__is_interacting__ = _interact;
				}
			    return self;
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
			/// @desc    Attempts to shift focus in the given direction ("next", "prev", "up", "down", etc.).
			///          This simple algorithm checks the parent's children list and, if needed, escalates upward.
			/// @self    WWCore
			/// @param   {String} dir : The navigation direction.
			/// @returns {Struct.WWCore} The component that received focus, or self if none found.
			#endregion
            static navigate_focus = function(_dir) {
                // If no parent, we cannot navigate away.
                if (__parent__ == noone) {
                    return self;
                }
                
                var siblings = __parent__.get_children();
                var currentIndex = __find_index_in_parent__();
                var target = undefined;
                
                // For simplicity, treat "next", "right", and "down" the same; similarly "prev", "left", "up"
                if (_dir == "next" || _dir == "right" || _dir == "down") {
                    var i = currentIndex + 1;
                    while (i < array_length(siblings)) {
                        if (siblings[i].__is_focusable__ && siblings[i].__is_enabled__) {
                            target = siblings[i];
                            break;
                        }
                        i++;
                    }
                }
                else if (_dir == "prev" || _dir == "left" || _dir == "up") {
                    var i = currentIndex - 1;
                    while (i >= 0) {
                        if (siblings[i].__is_focusable__ && siblings[i].__is_enabled__) {
                            target = siblings[i];
                            break;
                        }
                        i--;
                    }
                }
                
                // If no suitable sibling found, optionally escalate up the parent chain.
                if (target == undefined && __parent__ != noone) {
                    target = __parent__.navigate_focus(_dir);
                }
                
                // If found, remove focus from self and assign to the target.
                if (target != undefined && target != self) {
                    set_focus(false);
                    target.set_focus(true);
                }
                return target != undefined ? target : self;
            }
			
			#region jsDoc
			/// @func    handle_keyboard_navigation()
			/// @desc    Checks for tab or arrow key presses and navigates focus accordingly.
			///          When tab is pressed, if shift is down, it navigates in reverse.
			/// @self    WWCore
			/// @param   {Struct} input : The input struct (should contain keyboard state).
			/// @returns {Undefined}
			#endregion
            static handle_keyboard_navigation = function(_input) {
                // Example pseudo-code for key checking; replace with your own input functions.
                if (keyboard_check_pressed(vk_tab)) {
                    if (keyboard_check(vk_shift)) {
                        navigate_focus("prev");
                    }
                    else {
                        navigate_focus("next");
                    }
                    _input.consumed = true;
                }
                if (keyboard_check_pressed(vk_left)) {
                    navigate_focus("left");
                    _input.consumed = true;
                }
                if (keyboard_check_pressed(vk_right)) {
                    navigate_focus("right");
                    _input.consumed = true;
                }
                if (keyboard_check_pressed(vk_up)) {
                    navigate_focus("up");
                    _input.consumed = true;
                }
                if (keyboard_check_pressed(vk_down)) {
                    navigate_focus("down");
                    _input.consumed = true;
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
				
				return __mouse_on_comp__;
			}
			#region jsDoc
			/// @func    mouse_on_group()
			/// @desc    This function is internally used to help assist early outing collision checks.
			/// @self    WWCore
			/// @returns {Bool}
			#endregion
			static mouse_on_group = function() {
				//check if parent even has a mouse over it
				if (__is_child__) {
					if (!__parent__.__mouse_on_group__) {
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
				
				_input ??= {
					consumed : false,
				};
				__user_input__ = _input;
				__mouse_on_group__ = mouse_on_group();
				
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
				
				
				_input ??= {
					consumed : false,
				};
				__user_input__ = _input;
				__mouse_on_group__ = mouse_on_group();
				
				
				
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
						$"__is_interacting__ = {__is_interacting__};",
						$"__is_hovered__ = {__is_hovered__};",
						$"__is_focused__ = {__is_focused__};",
						$"__visual_state__ = {__visual_state__};",
						"",
						$"WW_STATE_DISABLED = {WW_STATE_DISABLED};",
						$"WW_STATE_ACTIVE = {WW_STATE_ACTIVE};",
						$"WW_STATE_HOVER = {WW_STATE_HOVER};",
						$"WW_STATE_FOCUSED = {WW_STATE_FOCUSED};",
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
			__default_user_input__ = {
				consumed : false,
			}
			__user_input__ = variable_clone(__default_user_input__);
			__mouse_on_comp__  = false;
			__mouse_on_group__ = false;
			__click_held_timer__ = 0; //long press timer
			__last_click_time_single__ = 0; //timer to measure the distance from a single click to a double
			__last_click_time_double__ = 0; //timer to measure the distance from a double click to a triple
			__is_interacting__ = false; // is currently being interacted with, to prevent draging a slider and clicking a button at the same time
			__is_focused__ = false; // is currently the component capturing the input, and accepting keyboard inputs
			__is_hovered__ = false; // is currently consuming the input through depth order (the mouse projected down onto this component, instead of others)
			#endregion
			#region Sub Component Variables
			__is_empty__ = true;
			__children_count__ = 0;
			__children__ = [];
			__is_child__ = false; // if the component is a child of another component
			__parent__ = noone; // a reference to the parent controller
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
				if (!__is_enabled__) {
					return;
				}
				
				var _mouse_on_group = mouse_on_group();
				if (_mouse_on_group) {
					trigger_event(events.mouse_over_group);
				}
				else {
					trigger_event(events.mouse_off_group);
				}
				
				var _mouse_on = mouse_on_comp();
				if (_mouse_on) {
					trigger_event(events.mouse_over);
				}
				else {
					trigger_event(events.mouse_off);
				}
				
				if (__is_hovered__) trigger_event(events.hover);
				if (__is_focused__) trigger_event(events.focus);
				if (__is_interacting__) trigger_event(events.interact);
			})
			on_mouse_over(function(){
				if (!__is_enabled__) {
					return;
				}
				
				var _input_captured = __user_input__.consumed;
				set_hover(!_input_captured);
			})
			on_mouse_off(function(){
				set_hover(false);
				if (mouse_check_button_pressed(mb_left) || mouse_check_button_released(mb_left)) {
					set_focus(false);
				}
			})
			on_hover(function(){
				if (!__is_enabled__ || !__is_focusable__) {
					return;
				}
				
				consume_input();
				
				if (mouse_check_button_pressed(mb_left)) {
					trigger_event(events.pressed);
				}
				
			})
			on_pressed(function(){
				set_interact(true);
				
				if (current_time - __last_click_time_double__ < 1_000/3) {
					trigger_event(events.triple_click);
					return;
				}
				
				if (current_time - __last_click_time_single__ < 1_000/3) {
					__last_click_time_double__ = current_time;
					trigger_event(events.double_click);
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
					return;
				}
				
				if (mouse_check_button(mb_left)) {
				    trigger_event(events.held);
						
				    // Handle long press timing
				    __click_held_timer__ += 1;
				    if (current_time-__click_held_timer__ > 1_000/3) {
				        trigger_event(events.long_press);
				    }
				}
				else {
					// Always clear interact once the button is no longer held.
					// This prevents visual "stuck pressed" states if a release edge is missed.
					var _did_release = mouse_check_button_released(mb_left);
				    set_interact(false);
				    if (_did_release) {
						if (mouse_on_comp()) {
				    		trigger_event(events.released);
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
				var _stack = [self];
				while (array_length(_stack) > 0) {
					var _node = array_pop(_stack);
					_node.__root_canvas__ = _new_root;
					if (_node.__overlay_component__) {
						_node.__overlay_sync_dirty__ = true;
					}
					var _i=0; repeat(_node.__children_count__) {
						array_push(_stack, _node.__children__[_i]);
					_i+=1;}
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
			static __recalc_visual_state__ = function() {
				if (!__is_enabled__)    { 
					__visual_state__ = WW_STATE_DISABLED; return; 
					}
				if (__is_interacting__) { 
					__visual_state__ = WW_STATE_ACTIVE; return; 
					}
				if (__is_hovered__)     { 
					__visual_state__ = WW_STATE_HOVER; return; 
					}
				if (__is_focused__)     { 
					__visual_state__ = WW_STATE_FOCUSED; return; 
					}
				//else
				__visual_state__ = WW_STATE_NORMAL;
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
