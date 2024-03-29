#region jsDoc
/// @func    GUICompDropdown()
/// @desc    Creates a Dropdown Component
/// @param   {Real} x : The x possition of the component on screen.
/// @param   {Real} y : The y possition of the component on screen.
/// @returns {Struct.GUICompDropdown}
#endregion
function GUICompDropdown() : GUICompController() constructor {
	debug_name = "GUICompDropdown";
	should_draw_debug = false;
	
	#region Public
		
		#region Builder functions
			
			#region General
				
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
					__SUPER__.set_region(_left, _top, _right, _bottom);
					__button__.set_region(_left, _top, _right, _bottom);
					
					__controller__.set_anchor(0, __button__.region.get_height());
					__controller__.set_width(_right-_left);
					__controller__.set_region(__controller__.region.left, __controller__.region.top, __controller__.region.right, __controller__.region.bottom)
					
					__update_controller_region__();
					
					__update_dropdown_scrollbars__();
					
					return self;
				}
				#region jsDoc
				/// @func    set_open()
				/// @desc    Sets the folder's is_open state.
				/// @self    GUICompFolder
				/// @param   {Bool} is_open : if the folder is open or not, true = open, false = closed;
				/// @returns {Struct.GUICompFolder}
				#endregion
				static set_open = function(_is_open=!is_open){ //log(["set_open", set_open]);
					var _prev_open = is_open
					is_open = _is_open;
					
					//run events if needed
					if (_prev_open != is_open) {
						if (is_open) {
							__trigger_event__(self.events.opened, {index : current_index, text : text.text});
						}
						else {
							__trigger_event__(self.events.closed, {index : current_index, text : text.text});
						}
					}
					
					update_component_positions();
					return self;
				}
				#region jsDoc
				/// @func    set_value()
				/// @desc    Sets the selected element to the given index. Note: A value of -1 will reset the value to the default set by set_text().
				/// @self    GUICompDropdown
				/// @param   {Real} index : The index of the element you wish to 
				/// @returns {Struct.GUICompDropdown}
				#endregion
				static set_value = function(_index) {
					var _prev_index = current_index;
					
					if (_index == -1) {
						text.text = __default_text__;
					}
					else{
						var _elements = __controller__.__children__;
						text.text = _elements[_index].text.text;
					}
					
					__button__.set_text(text.text);
					
					is_open = false;
					current_index = _index;
					
					if (_prev_index != current_index) {
						
					}
					
					return self;
				}
				#region jsDoc
				/// @func    set_sprite_to_auto_wrap()
				/// @desc    Automatically wrap the sprite around the largest string among all elements, including the header text. This will change the click region for you. Note: This should be called after calling the sprite and text builder functions.
				/// @self    GUICompDropdown
				/// @param   {Real} x : The x offset
				/// @param   {Real} y : The y offset
				/// @returns {Struct.GUICompDropdown}
				#endregion
				static set_sprite_to_auto_wrap = function() {
					
					draw_set_font(text.font);
					var _largest_text_width  = string_width(text.text);
					var _largest_text_height = string_height(text.text);
					
					var _elements = __controller__.__children__;
					var _i=0; repeat(__controller__.__children_count__) {
						_largest_text_width  = max(_largest_text_width,  string_width(_elements[_i].text.text) );
						_largest_text_height = max(_largest_text_height, string_height(_elements[_i].text.text) );
					_i+=1;}//end repeat loop
					
					var _slice = sprite_get_nineslice(__button__.sprite.index);
					var _width  = _largest_text_width  + (_slice.left + _slice.right);
					var _height = _largest_text_height + (_slice.top  + _slice.bottom);
					
					//update internal variables
					set_region(0, 0, _width, _height);
					
					var _dropdown_height = __controller__.__children_count__*_height
					__controller__.set_region(0, 0, _width, _dropdown_height);
					__controller__.set_scrollbar_hidden(true, true);
					
					set_text_offsets(_slice.left, _slice.top, text.click_y_off);
					
					return self;
				}
				
			#endregion
			
			#region Header
				
				#region jsDoc
				/// @func    set_header_shown()
				/// @desc    Sets if the folder's header to be drawn as well as interablbe.
				/// @self    GUICompFolder
				/// @param   {Bool} header_shown : if the folder's should header should be used, true = used, false = not used
				/// @returns {Struct.GUICompDropdown}
				#endregion
				static set_header_shown = function(_header_shown=true){ //log(["set_header_shown", set_header_shown]);
					header_shown = _header_shown;
					
					return self;
				}
				#region jsDoc
				/// @func    set_sprite()
				/// @desc    Sets the sprite of the button.
				/// @self    GUICompDropdown
				/// @param   {Asset.GMSprite} sprite : The sprite the button will use.
				/// @returns {Struct.GUICompDropdown}
				#endregion
				static set_sprite = function(_sprite=s9ButtonText) {
					/// NOTE: These are the default structure of GUI button sprites
					/// image.index[0] = idle; no interaction;
					/// image.index[1] = mouse over; the mouse is over it;
					/// image.index[2] = mouse down; actively being pressed;
					/// image.index[3] = disabled; not allowed to interact with;
					
					__button__.set_sprite(_sprite);
					
					sprite_header = _sprite;
					
					return self;
				}
				#region jsDoc
				/// @func    set_text()
				/// @desc    Sets the variables for text drawing
				/// @self    GUICompDropdown
				/// @param   {String} text : The text to write on the button.
				/// @returns {Struct.GUICompDropdown}
				#endregion
				static set_text = function(_text="DefaultText") {
					__button__.set_text(_text);
					
					text.text = _text;
					__default_text__ = _text;
					
					return self;
				}
				#region jsDoc
				/// @func    set_text_font()
				/// @desc    Sets the font which will be used for drawing the text
				/// @self    GUICompDropdown
				/// @param   {Asset.GMFont} font : The font to use when drawing the text
				/// @returns {Struct.GUICompDropdown}
				#endregion
				static set_text_font = function(_font=fGUIDefault) {
					__button__.set_text_font(_font);
					
					text.font = _font;
					
					return self;
				}
				#region jsDoc
				/// @func    set_text_colors()
				/// @desc    Sets the colors for the text of the button.
				/// @self    GUICompDropdown
				/// @param   {Real} idle_color     : The color to draw the text when the component is idle
				/// @param   {Real} hover_color    : The color to draw the text when the component is hovered
				/// @param   {Real} click_color    : The color to draw the text when the component is clicked
				/// @param   {Real} disabled_color : The color to draw the text when the component is disabled
				/// @returns {Struct.GUICompDropdown}
				#endregion
				static set_text_colors = function(_idle=c_white, _hover=c_white, _clicked=c_white, _disable=c_grey) {
					__button__.set_text_colors(_idle, _hover, _clicked, _disable);
					
					text.color.idle = _idle;
					text.color.hover = _hover;
					text.color.clicked = _clicked;
					text.color.disable = _disable;
				
					return self;
				}
				#region jsDoc
				/// @func    set_text_alignment()
				/// @desc    Sets how the text is aligned when drawing
				/// @self    GUICompDropdown
				/// @param   {Constant.HAlign} halign : Horizontal alignment
				/// @param   {Constant.VAlign} valign : Vertical alignment
				/// @returns {Struct.GUICompDropdown}
				#endregion
				static set_text_alignment = function(_h=fa_left, _v=fa_top) {
					__button__.set_text_alignment(_h, _v);
					
					text.halign = _h;
					text.valign = _v;
		
					return self;
				};
				#region jsDoc
				/// @func    set_text_offsets()
				/// @desc    Sets the Text's offsets reletive to the component's x/y. Note: click_y will be applied in addition to the y, when the component is actively being pressed.
				/// @self    GUICompDropdown
				/// @param   {Real} x : The x offset
				/// @param   {Real} y : The y offset
				/// @param   {Real} click_y : The additional y offset used when 
				/// @returns {Struct.GUICompDropdown}
				#endregion
				static set_text_offsets = function(_x=0, _y=0, _click_y=2) {
					__button__.set_text_offsets(_x, _y, _click_y);
					
					text.xoff = _x;
					text.yoff = _y;
					text.click_y_off = _click_y;
					
					return self;
				};
				
			#endregion
			
			#region Dropdown
				
				#region jsDoc
				/// @func    set_dropdown_sprites()
				/// @desc    Sets all of the dropdown component's sprites
				/// @self    GUICompDropdown
				/// @param   {Asset.GMSprite} header_sprite : The sprite used to draw the dropdown box prior to dropping down.
				/// @param   {Asset.GMSprite} top_sprite : The sprite used to draw the top region of the dropdown box when displaying options.
				/// @param   {Asset.GMSprite} middle_sprite : The sprite used to draw the middle regions of the dropdown box when displaying options.
				/// @param   {Asset.GMSprite} bottom_sprite : The sprite used to draw the bottom region of the dropdown box when displaying options.
				/// @returns {Struct.GUICompDropdown}
				#endregion
				static set_dropdown_sprites = function(_spr_header, _spr_top, _spr_mid, _spr_bot) {
					/// NOTE: These are the default structure of GUI sprites
					/// image.index[0] = idle; no interaction;
					/// image.index[1] = mouse over; the mouse is over it;
					/// image.index[2] = mouse down; actively being pressed;
					/// image.index[3] = disabled; not allowed to interact with;
				
					sprite_header = _spr_header;
					sprite_top    = _spr_top;
					sprite_middle = _spr_mid;
					sprite_bottom = _spr_bot;
					
					set_sprite(_spr_header);
					
					__update_dropdown_sprites__();
					
					return self;
				}
				#region jsDoc
				/// @func    set_dropdown_array()
				/// @desc    Sets all of the dropdown component's selectable options
				/// @self    GUICompDropdown
				/// @param   {Array<String>} arr_of_strings : The strings each element will represent
				/// @returns {Struct.GUICompDropdown}
				#endregion
				static set_dropdown_array = function(_strings_array) {
					//error handler
					if (should_safety_check) {
						if (!is_array(_strings_array)) {
							show_error("Input is not an array.", true)
						}
					}
					
					add(_strings_array);
					
					return self;
				}
				#region jsDoc
				/// @func    set_element_colors()
				/// @desc    Sets the colors for the supplied element. Note: A value of -1 will have the element make use of the header's colors
				/// @self    GUICompDropdown
				/// @param   {Real} index : The index of the dropdown selection element which will have it's unique colors changed
				/// @param   {Real} idle_color : The color to be drawn when the element is idle
				/// @param   {Real} hover_color : The color to be drawn when the element is currently being hovered over
				/// @param   {Real} clicked_color : The color to be drawn when the element is currently being pressed
				/// @param   {Real} disabled_color : The color to be drawn when the element is disabled
				/// @returns {Struct.GUICompDropdown}
				#endregion
				static set_element_colors = function(_index, _idle=c_white, _hover=c_white, _clicked=c_white, _disabled=c_dkgrey) {
					elements[_index].text.color.idle     = _idle;
					elements[_index].text.color.hover    = _hover;
					elements[_index].text.color.clicked  = _clicked;
					elements[_index].text.color.disabled = _disabled;
				
					return self;
				}
				#region jsDoc
				/// @func    set_element_enabled()
				/// @desc    Sets a specific element to enabled or disabled.
				/// @self    GUICompDropdown
				/// @param   {Real} index : The index (possition) you wish to enable or disable
				/// @param   {Bool} is_enabled : if the element should be enabled. true = enabled, false = disabled
				/// @returns {Struct.GUICompDropdown}
				#endregion
				static set_element_enabled = function(_index, _is_enabled) {
					elements[_index].is_enabled = _is_enabled;
					
					return self;
				}
				#region jsDoc
				/// @func    set_dropdown_size()
				/// @desc    Sets the size of the drop down region.
				/// @self    GUICompDropdown
				/// @param   {real} left : The left side of the bounding box
				/// @param   {real} top : The top side of the bounding box
				/// @param   {real} right : The right side of the bounding box
				/// @param   {real} bottom : The bottom side of the bounding box
				/// @returns {Struct.GUICompDropdown}
				#endregion
				static set_dropdown_size = function(_left, _top, _right, _bottom) {
					__controller__.set_region(_left, _top, _right, _bottom)
					
					return self;
				}
				#region jsDoc
				/// @func    set_dropdown_anchor()
				/// @desc    Sets the location the drop down will appear reletive to the header button
				/// @self    GUICompDropdown
				/// @param   {real} xoff : The left side of the bounding box
				/// @param   {real} yoff : The top side of the bounding box
				/// @returns {Struct.GUICompDropdown}
				#endregion
				static set_dropdown_anchor = function(_xoff, _yoff) {
					__controller__.set_anchor(_xoff, _yoff);
					
					return self;
				}
				#region jsDoc
				/// @func    set_dropdown_height()
				/// @desc    Sets the height of the dropdown region.
				/// @self    GUICompDropdown
				/// @param   {real} height : The height of the dropdown.
				/// @returns {Struct.GUICompDropdown}
				#endregion
				static set_dropdown_height = function(_height) {
					__controller__.set_height(_height);
					__controller__.set_region(__controller__.region.left, __controller__.region.top, __controller__.region.right, __controller__.region.bottom)
					
					__update_dropdown_scrollbars__();
					
					return self;
				}
				
			#endregion
			
		#endregion
		
		#region Events
			
			self.events.mouse_over = variable_get_hash("mouse_over"); //triggered when the mouse is over the header
			self.events.pressed    = variable_get_hash("pressed"); //triggered when mouse first clicks the header
			self.events.held       = variable_get_hash("held"); //triggered every frame the mouse's click is down on the header
			self.events.long_press = variable_get_hash("long_press");
			self.events.released   = variable_get_hash("released"); //triggered when when the mouses click is released from the header
			
			self.events.element_mouse_over   = variable_get_hash("element_mouse_over"); //triggered when the mouse is over an element
			self.events.element_pressed      = variable_get_hash("element_pressed"); //triggered when mouse first clicks an element
			self.events.element_held         = variable_get_hash("element_held"); //triggered every frame the mouse's click is down on an element
			self.events.element_long_pressed = variable_get_hash("element_long_pressed"); //triggered every frame the mouse's click is down on an element
			self.events.element_released     = variable_get_hash("element_released"); //triggered when when the mouses click is released from an element
			
			self.events.opened = variable_get_hash("opened"); //triggered when the dropdown is expanded
			self.events.closed = variable_get_hash("closed"); //triggered when the dropdown is collapsed
			
			self.events.selected = variable_get_hash("selected"); //triggered when an element is selected
			self.events.changed  = variable_get_hash("changed"); //triggered when a different element then the currently active one is selected (This will be triggered any time set_value is used)
			self.events.cleared  = variable_get_hash("cleared"); //triggered when the dropdown is cleared (this is done by the developer)
			
		#endregion
		
		#region Variables
			
			is_open = false;
			
			header_shown = true;
			
			//sprites
			sprite_header = s9DropDown;
			sprite_top    = s9DropDownTop;
			sprite_middle = s9DropDownMiddle;
			sprite_bottom = s9DropDownBottom;
			
			//elements
			current_index = -1;
			
		#endregion
		
		#region Functions
			
			#region jsDoc
			/// @func    get_value()
			/// @desc    Returns the currently selected index
			/// @self    constructor_name
			/// @returns {Real}
			#endregion
			static get_value = function() {
				return current_index;
			}
			#region jsDoc
			/// @func    add()
			/// @desc    Add an element to the dropdown. Returns the length of the element array.
			/// @self    GUICompDropdown
			/// @param   {String|Array<String>} string : The element you wish to add to the dropdown.
			/// @returns {Real}
			#endregion
			static add = function(_string) {
				__is_empty__ = false;
				
				//convert supplied data to expected data
				_string = (is_array(_string)) ? _string : [_string];
				var _length = array_length(_string);
				
				//safety checks
				if (should_safety_check) {
					var _elm_str, _j, _found_count;
					
					var _current_length = __controller__.__children_count__;
					var _elements = __controller__.__children__;
					
					var _i=0; repeat(_length) {
						_elm_str = _string[_i];
						
						//verify the component doeant appear twice in the supplied array
						_j=_i+1; repeat(_length-_i-1) {
							if (_string[_j] == _elm_str) {
								show_error("Trying to insert an array which contains the same string twice", true)
							}
						_j+=1;}//end repeat loop
						
						//verify the component is not already in the controller
						_j=0; repeat(_current_length) {
							if (_elements[_j].text.text == _elm_str) {
								show_error("Trying to insert a string which already exists inside this dropdown", true)
							}
						_j+=1;}//end repeat loop
					_i+=1;}//end repeat loop
				}
				
				var _arr = array_create(_length);
				var _i=0; repeat(_length) {
					_arr[_i] = new __element__(_string[_i])
							.set_region(region.left, region.top, region.right, region.bottom)
					
					_arr[_i].__add_event_listener_priv__(_arr[_i].events.released, method({this: _arr[_i], parent: other}, function(){
						var _prev_index = parent.current_index;
						//update
						parent.set_value(this.__find_index_in_parent__());
						parent.set_open(false);
						//events
						parent.__trigger_event__(parent.events.selected, {index : parent.current_index, text : parent.text.text});
						if (_prev_index != parent.current_index) {
							parent.__trigger_event__(parent.events.changed, {index : parent.current_index, text : parent.text.text});
						}
					}));
					
					__adopt_element_events__(_arr[_i]);
					
				_i+=1;}//end repeat loop
				
				var _r = __controller__.add(_arr);
				__update_dropdown_sprites__();
				__update_dropdown_scrollbars__()
				__update_dropdown_canvas__();
				return _r;
			}
			#region jsDoc
			/// @func    insert()
			/// @desc    Inserts an element to the dropdown. Returns the length of the element array.
			/// @self    GUICompDropdown
			/// @param   {Real} index : The index (possition) you wish to insert the element
			/// @param   {String|Array<String>} string : The element you wish to add to the dropdown.
			/// @returns {Real}
			#endregion
			static insert = function(_index, _string) {
				__is_empty__ = false;
				
				//convert supplied data to expected data
				_string = (is_array(_string)) ? _string : [_string];
				var _length = array_length(_string);
				
				//safety checks
				if (should_safety_check) {
					var _elm_str, _j, _found_count;
					
					var _current_length = __controller__.__children_count__;
					var _elements = __controller__.__children__;
					
					var _i=0; repeat(_length) {
						_elm_str = _string[_i];
						
						//verify the component doeant appear twice in the supplied array
						_j=_i+1; repeat(_length-_i-1) {
							if (_arr[_j] == _elm_str) {
								show_error("Trying to insert an array which contains the same string twice", true)
							}
						_j+=1;}//end repeat loop
						
						//verify the component is not already in the controller
						_j=0; repeat(_current_length) {
							if (_elements[_j].text.text == _elm_str) {
								show_error("Trying to insert a string which already exists inside this dropdown", true)
							}
						_j+=1;}//end repeat loop
					_i+=1;}//end repeat loop
				}
				
				var _arr = array_create(_length);
				var _i=0; repeat(_length) {
					_arr[_i] = new __element__(_string[_i])
							.set_region(region.left, region.top, region.right, region.bottom)
					
					_arr[_i].__add_event_listener_priv__(_arr[_i].events.released, method({this: _arr[_i], parent: other}, function(){
						var _prev_index = parent.current_index;
						//update
						parent.set_value(this.__find_index_in_parent__());
						parent.set_open(false);
						//events
						parent.__trigger_event__(parent.events.selected, {index : parent.current_index, text : parent.text.text});
						if (_prev_index != parent.current_index) {
							parent.__trigger_event__(parent.events.changed, {index : parent.current_index, text : parent.text.text});
						}
					}));
					
					__adopt_element_events__(_arr[_i]);
					
				_i+=1;}//end repeat loop
				
				var _r = __controller__.insert(_index, _arr);
				__update_dropdown_sprites__();
				__update_dropdown_scrollbars__()
				__update_dropdown_canvas__();
				return _r;
			}
			#region jsDoc
			/// @func    remove()
			/// @desc    Remove an element from the dropdown.
			/// @self    GUICompDropdown
			/// @param   {Real} index : The index of the element you wish to remove from the dropdown.
			/// @returns {Undefined}
			#endregion
			static remove = function(_index) {
				__controller__.remove(_index);
			}
			#region jsDoc
			/// @func    find()
			/// @desc    Find the index of the given element value. Will return -1 if the element was not found.
			/// @self    GUICompDropdown
			/// @param   {String} string : The string you wish to find the index of.
			/// @returns {Real}
			#endregion
			static find = function(_string) {
				//verify the component is not already in the controller
				var _current_length = __controller__.__children_count__;
				var _elements = __controller__.__children__;
				var _i=0; repeat(_current_length) {
					if (_elements[_i].text.text == _string) {
						break;
					}
				_i+=1;}//end repeat loop
				
				return _i;
			}
			#region jsDoc
			/// @func    update_component_positions()
			/// @desc    Updates the locations of the children
			/// @self    GUICompHandler
			/// @returns {Real}
			#endregion
			static update_component_positions = function() { //log(["update_component_positions", update_component_positions]);
				static __update = function(_comp) {
					var _xx = __get_controller_archor_x__(_comp.halign);
					var _yy = __get_controller_archor_y__(_comp.valign);
					
					_comp.x = self.x + _xx + _comp.x_anchor + _comp.__internal_x__;
					_comp.y = self.y + _yy + _comp.y_anchor + _comp.__internal_y__;
					
					//if the component is a controller it's self have it update it's children
					if (_comp.__is_controller__) {
						_comp.update_component_positions();
					}
				}
				
				if (header_shown) {
					__update(__button__);
				}
				
				if (is_open) {
					__update(__controller__);
				}
			}
			
			#region GML Events
				
				static draw_debug = function() {
					if (!should_draw_debug) return;
					
					draw_set_color(c_yellow)
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
		
	#endregion
	
	#region Private Library
		
		#region Variables
			
			__is_empty__ = true;
			
			__default_text__ = text.text;
			
			__button__ = new GUICompButtonText()
					.set_sprite(sprite_header)
					.set_alignment(fa_left, fa_top)
			
			#region Adopt Events
				
				__button__.__add_event_listener_priv__(__button__.events.mouse_over, function() {
					__trigger_event__(self.events.mouse_over);
				})
				__button__.__add_event_listener_priv__(__button__.events.pressed, function() {
					__trigger_event__(self.events.pressed);
				})
				__button__.__add_event_listener_priv__(__button__.events.held, function() {
					__trigger_event__(self.events.held);
				})
				__button__.__add_event_listener_priv__(__button__.events.long_press, function() {
					__trigger_event__(self.events.long_press);
				})
				__button__.__add_event_listener_priv__(__button__.events.released, function() {
					__trigger_event__(self.events.released);
				})
				
			#endregion
			
			__button__.__add_event_listener_priv__(__button__.events.released, function() {
				set_open(!is_open);
				
				if (is_open) {
					__trigger_event__(self.events.opened);
				}
				else {
					__trigger_event__(self.events.closed);
				}
			})
			
			//inherit events
			///adopt_events(__button__)
			
			__controller__ = new GUICompRegion()
					.set_alignment(fa_left, fa_top)
					.set_region(0,0,0,0)
			
			
			__SUPER__.add([__button__])
			
		#endregion
		
		#region Functions
			
			#region Events
				
				
			#endregion
			
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
						__controller__.__step__(__user_input__);
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
					//we actually run the step event for the drop down in the begin step to allow for proper input capturing
					//if (is_open) {
					//	__controller__.__step__(__user_input__);
					//}
					
					
					//close drop down if clicked elsewhere
					var _mouse_on = __mouse_on_controller__();
					var _mouse_on_dropdown = __controller__.__mouse_on_controller__()
					
					if (is_open)
					&& (mouse_check_button_released(mb_left))
					&& (!_mouse_on && !_mouse_on_dropdown) {
						is_open = false;
					}
				
					//close the drop down if we attempt to scroll (usually because it's inside a scroll region)
					if (is_open)
					&& (mouse_wheel_down() || mouse_wheel_up())
					&& (!_mouse_on_dropdown) {
						is_open = false;
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
					
					//run the drop down in the post draw event
					//if (is_open) {
					//	__controller__.__draw_gui__(__user_input__);
					//}
					
					if (__user_input__.consumed) { capture_input(); };
				}
				static __draw_gui_end__ = function(_input) { //log(["__draw_gui_end__", __draw_gui_end__]);
					__user_input__ = _input;
					
					draw_gui_end(__user_input__);
					if (header_shown) {
						__button__.__draw_gui_end__(_input);
					}
					
					if (is_open) {
						__controller__.__draw_gui__(__user_input__);
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
			
			static __update_dropdown_sprites__ = function() {
				//fix the sprites and adjust positions
				var _x = 0;
				var _y = 0;
				
				var _i=0; repeat(__controller__.__children_count__) {
					var _comp = __controller__.__children__[_i];
					_comp.sprite.index = sprite_middle;
					_comp.set_anchor(_x, _y);
					_y += _comp.region.get_height();
				_i+=1;}//end repeat loop
				
				if (__controller__.__children_count__) {
					__controller__.__children__[0].sprite.index = sprite_top;
					__controller__.__children__[__controller__.__children_count__-1].sprite.index = sprite_bottom;
				}
				
			}
			static __update_dropdown_scrollbars__ = function() {
				var _total_height = 0
				var _total_width = 0
				var _i=0; repeat(__controller__.__children_count__) {
					var _region = __controller__.__children__[_i].region
					_total_height += _region.get_height();
					_total_width = max(_total_width, _region.get_width());
				_i+=1;}//end repeat loop
				
				var _horz = !(_total_width > __controller__.region.get_width())
				var _vert = !(_total_height > __controller__.region.get_height())
				__controller__.set_scrollbar_hidden(_horz, _vert);
			}
			static __update_dropdown_canvas__ = function() {
				update_component_positions();
				__controller__.set_canvas_size_from_children();
			}
			
			#region jsDoc
			/// @func    __element__()
			/// @desc    Constructs a new dropdown element from the given string.
			/// @self    GUICompDropdown
			/// @param   {String} string : The text which will be drawn by the element.
			/// @ignore
			#endregion
			static __element__ = function(_string) : GUICompButtonText()  constructor {
				debug_name = "GUICompDropdown__element__"
				
				halign = fa_left;
				valign = fa_top;
				
				set_sprite(other.sprite_middle);
				image.index = 0;
				
				text = variable_clone(other.text);
				set_text(_string);
				
				set_region(
					other.region.left,
					other.region.top,
					other.region.right,
					other.region.bottom
				)
			}
			
			static __adopt_element_events__ = function(_comp) {
				#region Adopt Events
					
					_comp.__add_event_listener_priv__(_comp.events.mouse_over, function() {
						__trigger_event__(self.events.element_mouse_over);
					})
					_comp.__add_event_listener_priv__(_comp.events.pressed, function() {
						__trigger_event__(self.events.element_pressed);
					})
					_comp.__add_event_listener_priv__(_comp.events.held, function() {
						__trigger_event__(self.events.element_held);
					})
					_comp.__add_event_listener_priv__(_comp.events.long_press, function() {
						__trigger_event__(self.events.element_long_pressed);
					})
					_comp.__add_event_listener_priv__(_comp.events.released, function() {
						__trigger_event__(self.events.element_released);
					})
					
				#endregion
			}
			
		#endregion
		
	#endregion
	
	set_sprite(s9DropDown);
	set_sprite_to_auto_wrap();
}


