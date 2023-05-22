#region jsDoc
/// @func    GUICompDropdown()
/// @desc    Creates a Dropdown Component
/// @param   {Real} x : The x possition of the component on screen.
/// @param   {Real} y : The y possition of the component on screen.
/// @returns {Struct.GUICompDropdown}
#endregion
function GUICompDropdown(_x, _y) : GUICompCore(_x, _y) constructor {
	debug_name = "GUICompDropdown";
	
	#region Public
		
		#region Builder functions
			
			#region jsDoc
			/// @func    set_sprite()
			/// @desc    Sets the sprite for the dropdown
			/// @self    GUICompDropdown
			/// @param   {Asset.GMSprite} sprite : The sprite to be used
			/// @returns {Struct.GUICompDropdown}
			#endregion
			static set_sprite = function(_sprite) {
				/// NOTE: These are the default structure of GUI sprites
				/// image.index[0] = idle; no interaction;
				/// image.index[1] = mouse over; the mouse is over it;
				/// image.index[2] = mouse down; actively being pressed;
				/// image.index[3] = disabled; not allowed to interact with;
				
				__SUPER__.set_sprite(_sprite);
				image.speed = 0;
				
				return self;
			}
			
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
				
				sprite.header = _spr_header;
				sprite.top    = _spr_top;
				sprite.middle = _spr_mid;
				sprite.bottom = _spr_bot;
				
				set_sprite(_spr_header);
				
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
				if (GUI_GLOBAL_DEBUG) {
					if (!is_array(_strings_array)) {
						show_error("Input is not an array.", true)
					}
				}
				
				elements = [];
				
				var _elm;
				var _length = array_length(_strings_array)
				var _i=0; repeat(_length) {
					elements[_i] = new __new_element__(_strings_array[_i]);
				_i+=1;}//end repeat loop
				
				
				__is_empty__ = (_length == 0);
				
				return self;
			}
			
			#region jsDoc
			/// @func    set_header_text()
			/// @desc    Sets the text of the header
			/// @self    GUICompDropdown
			/// @param   {String} text : The text to be drawn by the header.
			/// @returns {Struct.GUICompDropdown}
			#endregion
			static set_text = function(_text="DefaultText") {
				text = _text
				__default_text__ = text;
				
				return self;
			}
			static set_header_text = set_text;
			
			#region jsDoc
			/// @func    set_text_font()
			/// @desc    Sets the font which will be used for drawing the text
			/// @self    GUICompDropdown
			/// @param   {Asset.GMFont} font : The font to use when drawing the text
			/// @returns {Struct.GUICompDropdown}
			#endregion
			static set_text_font = function(_font=fGUIDefault) {
				font = _font;								// font
				
				return self;
			}
			
			#region jsDoc
			/// @func    set_text_colors()
			/// @desc    Sets the colors for the text for the header.
			/// @self    GUICompDropdown
			/// @param   {Real} idle_color     : The color to draw the text when the component is idle
			/// @param   {Real} hover_color    : The color to draw the text when the component is hovered or clicked
			/// @param   {Real} disabled_color : The color to draw the text when the component is disabled
			/// @returns {Struct.GUICompDropdown}
			#endregion
			static set_text_colors = function(_idle=c_white, _hover=c_white, _disabled=c_dkgrey) {
				color.idle = _idle;
				color.hover = _hover;
				color.disabled = _disabled;
				
				return self;
			}
			
			#region jsDoc
			/// @func    set_element_colors()
			/// @desc    Sets the colors for the supplied element. Note: A value of -1 will have the element make use of the header's colors
			/// @self    GUICompDropdown
			/// @param   {Real} index : The index of the dropdown selection element which will have it's unique colors changed
			/// @param   {Real} idle_color : The color to be drawn when the element is idle
			/// @param   {Real} hover_color : The color to be drawn when the element is currently being hovered over
			/// @returns {Struct.GUICompDropdown}
			#endregion
			static set_element_colors = function(_index, _idle_text_color=c_white, _hover_text_color=c_white) {
				elements[_index].color.idle  = _idle_text_color;
				elements[_index].color.hover = _hover_text_color;
				
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
				text_halign = _h;
				text_valign = _v;
		
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
				text_x_off = _x;
				text_y_off = _y;
				text_click_y_off = _click_y;
				
				return self;
			};
			
			#region jsDoc
			/// @func    set_value()
			/// @desc    Sets the selected element to the given index. Note: A value of -1 will reset the value to the default set by set_header_text().
			/// @self    GUICompDropdown
			/// @param   {Real} index : The index of the element you wish to 
			/// @returns {Struct.GUICompDropdown}
			#endregion
			static set_value = function(_index){
				if (_index == -1) {
					text = __default_text__;
				}
				else{
					text = elements[_index].text;
				}
				
				is_open = false;
				current_index = _index;
				
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
				
				draw_set_font(font);
				var _largest_text_width  = string_width(text);
				var _largest_text_height = string_height(text);
				
				var _i=0; repeat(array_length(elements)) {
					_largest_text_width  = max(_largest_text_width,  string_width(elements[_i].text) );
					_largest_text_height = max(_largest_text_height, string_height(elements[_i].text) );
				_i++;}//end repeat loop
				
				
				var _slice = sprite_get_nineslice(sprite.index);
				var _width  = _largest_text_width  + (_slice.left + _slice.right);
				var _height = _largest_text_height + (_slice.top  + _slice.bottom);
				
				//update internal variables
				set_region(0, 0, _width, _height);
				set_text_offsets(_slice.left, _slice.top, text_click_y_off);
				set_text_alignment(fa_left, fa_top);
				
				
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
			
		#endregion
		
		#region Events
			
			self.events.mouse_over = "mouse_over"; //triggered when the mouse is over the header
			self.events.pressed    = "pressed"; //triggered when mouse first clicks the header
			self.events.held       = "held"; //triggered every frame the mouse's click is down on the header
			self.events.released   = "released"; //triggered when when the mouses click is released from the header
			
			self.events.element_mouse_over = "element_mouse_over"; //triggered when the mouse is over an element
			self.events.element_pressed    = "element_pressed"; //triggered when mouse first clicks an element
			self.events.element_held       = "element_held"; //triggered every frame the mouse's click is down on an element
			self.events.element_released   = "element_released"; //triggered when when the mouses click is released from an element
			
			self.events.opened = "opened"; //triggered when the dropdown is expanded
			self.events.closed = "closed"; //triggered when the dropdown is collapsed
			
			self.events.selected = "selected"; //triggered when an element is selected
			self.events.changed  = "changed"; //triggered when a different element then the currently active one is selected (This will be triggered any time set_value is used)
			self.events.cleared  = "cleared"; //triggered when the dropdown is cleared (this is done by the developer)
			
		#endregion
		
		#region Variables
			
			is_open = false;
			
			//text offsets
			text_x_off = 0;
			text_y_off = 0;
			text_click_y_off = 2;
			text_halign = fa_left;
			text_valign = fa_top;
			
			//header
			text = "<undefined>";
			font = fGUIDefault;
			
			color = {};
			color.idle     = c_white;
			color.hover    = c_white;
			color.clicked  = c_white;
			color.disabled = c_dkgrey;
			
			//sprites
			sprite = {};
			sprite.header = s9DropDown;
			sprite.top    = s9DropDownTop;
			sprite.middle = s9DropDownMiddle;
			sprite.bottom = s9DropDownBottom;
			
			
			//elements
			current_index = -1;
			elements = [];
			
			set_sprite(s9DropDown);
			set_sprite_to_auto_wrap();
			
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
				
				var _current_length = array_length(elements);
				var _length = 0;
				var _push_info;
				
				//convert supplied data to expected data
				if (is_array(_string)) {
					_length = array_length(_string);
					
					//write the texts in
					var _i=0; repeat(_length) {
						//check to make sure it's a string
						if (GUI_GLOBAL_SAFETY) {
							if (!is_string(_string[_i])) {
								show_error("Trying to insert a value which is not a string", true)
							}
						}
						
						_push_info[_i] = new __new_element__(_string[_i]);
					_i+=1;}//end repeat loop
					
				}
				else {
					//check to make sure it's a string
					if (GUI_GLOBAL_SAFETY) {
						if (!is_string(_string)) {
							show_error("Trying to insert a value which is not a string", true)
						}
					}
					
					_length = 1;
					//init a new array
					_push_info = [{
						text : _string,
						font : -1,
						image : {
							index : 0,
						},
						color : {
							idle : -1,
							hover : -1,
						}
					}];
				}
				
				//safety checks
				if (GUI_GLOBAL_SAFETY) {
					var _elm_str, _j, _found_count;
					
					var _i=0; repeat(_length) {
						_elm_str = _push_info[_i].text;
						
						//verify the component doeant appear twice in the supplied array
						_found_count = 0;
						_j = 0; repeat(_length) {
							if (_push_info[_j].text == _elm_str) {
								_found_count+=1;
								if (_found_count > 1) {
									show_error("Trying to insert an array which contains the same string twice", true)
								}
							}
						_j+=1;}//end repeat loop
							
						//verify the component is not already in the controller
						_j = 0; repeat(_current_length) {
							if (elements[_j].text == _elm_str) {
								show_error("Trying to insert a string which already exists inside this dropdown", true)
							}
						_j+=1;}//end repeat loop
					_i+=1;}//end repeat loop
				}
				
				array_push(elements, _push_info);
				
				return array_length(elements);
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
				
				var _current_length = array_length(elements);
				var _length = 0;
				var _push_info;
				
				//convert supplied data to expected data
				if (is_array(_string)) {
					_length = array_length(_string);
					
					//write the texts in
					var _i=0; repeat(_length) {
						//check to make sure it's a string
						if (GUI_GLOBAL_SAFETY) {
							if (!is_string(_string[_i])) {
								show_error("Trying to insert a value which is not a string", true)
							}
						}
						
						_push_info[_i] = new __new_element__(_string[_i]);
					_i+=1;}//end repeat loop
					
				}
				else {
					//check to make sure it's a string
					if (GUI_GLOBAL_SAFETY) {
						if (!is_string(_string)) {
							show_error("Trying to insert a value which is not a string", true)
						}
					}
					
					_length = 1;
					//init a new array
					_push_info = [{
						text : _string,
						font : -1,
						image : {
							index : 0,
						},
						color : {
							idle : -1,
							hover : -1,
						}
					}];
				}
				
				//safety checks
				if (GUI_GLOBAL_SAFETY) {
					var _elm_str, _j, _found_count;
					
					var _i=0; repeat(_length) {
						
						_elm_str = _arr[_i].text;
						
						//verify the component doeant appear twice in the supplied array
						_found_count = 0;
						_j = 0; repeat(_length) {
							if (_arr[_j].text == _elm_str) {
								_found_count+=1;
								if (_found_count > 1) {
									show_error("Trying to insert an array which contains the same string twice", true)
								}
							}
						_j+=1;}//end repeat loop
							
						//verify the component is not already in the controller
						_j = 0; repeat(_current_length) {
							if (elements[_j].text == _elm_str) {
								show_error("Trying to insert a string which already exists inside this dropdown", true)
							}
						_j+=1;}//end repeat loop
					_i+=1;}//end repeat loop
				}
				
				array_insert(elements, _index, _arr);
				
				return array_length(elements);
			}
			
			#region jsDoc
			/// @func    remove()
			/// @desc    Remove an element from the dropdown.
			/// @self    GUICompDropdown
			/// @param   {Real} index : The index of the element you wish to remove from the dropdown.
			/// @returns {Undefined}
			#endregion
			static remove = function(_index) {
				//revert the header text back to its default if we removed a selection
				var _name = elements[_index].text;
				if (text == _name) {
					text = __default_text__;
				}
				
				array_delete(elements, _index, 1);
				
				if(array_length(elements) == 0) {
					__is_empty__ = true;
				}
				
			}
			
			#region jsDoc
			/// @func    find()
			/// @desc    Find the index of the given element value. Will return -1 if the element was not found.
			/// @self    GUICompDropdown
			/// @param   {String} string : The string you wish to find the index of.
			/// @returns {Real}
			#endregion
			static find = function(_string) {
				return array_get_index(elements, _string);
			}
			
			#region GML Events
				
				static draw_gui = function(_input) {
					
					//init draw
					draw_set_font(font);
					draw_set_halign(text_halign);
					draw_set_valign(text_valign);
					draw_set_alpha(image_alpha);
					
					//set font color
					switch (image.index) {
						case GUI_IMAGE_ENABLED: {
							draw_set_color(color.idle);
							break;}
						case GUI_IMAGE_HOVER:
						case GUI_IMAGE_CLICKED: {
							draw_set_color(color.hover);
							break;}
						case GUI_IMAGE_DISABLED: {
							draw_set_color(color.disabled);
							break;}
						
					}
					
					
					//draw the header
					if (is_enabled) {
						var _click_off = (image.index == GUI_IMAGE_CLICKED) ? text_click_y_off : 0;
						draw_sprite_stretched(sprite.index, image.index, x, y, region.get_width(), region.get_height());
						draw_text(x + text_x_off, y + text_y_off + _click_off, text);
					}
					else{
						draw_sprite_stretched(sprite.index, image.index, x, y, region.get_width(), region.get_height());
						draw_text(x + text_x_off, y + text_y_off, text);
					}
					
				}
				
				static draw_gui_end = function(_input) {
					if (is_open)
					&& (!__is_empty__) {
						
						//init draw
						draw_set_font(font);
						draw_set_halign(text_halign);
						draw_set_valign(text_valign);
						draw_set_alpha(image.alpha);
						
						var _slice = sprite_get_nineslice(sprite.index);
						
						//draw sub elements
						var _element_dist = region.bottom - region.top;
						
						var _posX = x;
						var _posY = y + _element_dist;
						var _size = array_length(elements);
						var _i=0;
						
						static _draw = function(_x, _y, _spr, _element) {
							draw_sprite_stretched(_spr, _element.image.index, _x, _y, region.get_width(), region.get_height());
							
							var _click_off = (_element.image.index == GUI_IMAGE_CLICKED) ? text_click_y_off : 0;
							
							//set font color
							switch (_element.image.index) {
								case GUI_IMAGE_ENABLED: {
									if (_element.color.idle < 0) {
										draw_set_color(color.idle);
									}
									else {
										draw_set_color(_element.color.idle);
									}
									break;}
								case GUI_IMAGE_HOVER: {
									if (_element.color.hover < 0) {
										draw_set_color(color.hover);
									}
									else {
										draw_set_color(_element.color.hover);
									}
									break;}
								case GUI_IMAGE_CLICKED: {
									if (_element.color.clicked < 0) {
										draw_set_color(color.clicked);
									}
									else {
										draw_set_color(_element.color.clicked);
									}
									break;}
								case GUI_IMAGE_DISABLED: {
									if (_element.color.disabled < 0) {
										draw_set_color(color.disabled);
									}
									else {
										draw_set_color(_element.color.disabled);
									}
									break;}
							}
							
							draw_text(
									_x + text_x_off,
									_y + text_y_off + _click_off,
									_element.text
								);
						}
						
						//Top
						if (_size > 2) {
							// we only draw the top sprite if there is at least two elements,
							// otherwise we just drawn the bottom element's sprite
							_draw(_posX, _posY, sprite.top, elements[_i]);
							_posY += _element_dist;
							_i++;
						}
						
						//draw the middle ones
						repeat(_size-2) {
							_draw(_posX, _posY, sprite.middle, elements[_i]);
							_posY += _element_dist;
						_i++;}//end repeat loop
						
						//draw the bottom one
						_draw(_posX, _posY, sprite.bottom, elements[_i]);
						
					}
				}
				
			#endregion
			
		#endregion
		
	#endregion
	
	#region Private Library
		
		#region Variables
			
			__is_empty__ = true;
			
			__default_text__ = text;
			
		#endregion
		
		#region Functions
			
			__add_event_listener_priv__(self.events.released, function() {
				if (!__is_empty__) {
					is_open = !is_open;
									
					//trigger events
					if (is_open) {
						__trigger_event__(self.events.opened, {index : current_index, element : (current_index == -1) ? undefined : elements[current_index]});
					}
					else {
						__trigger_event__(self.events.closed, {index : current_index, element : (current_index == -1) ? undefined : elements[current_index]});
					}
				}
			});
			
			static __begin_step__ = function(_input) {
				begin_step(_input);
				
				var _mX = device_mouse_x_to_gui(0);
				var _mY = device_mouse_y_to_gui(0);
				
				var _i;
				
				//mouse over drop down region
				if (!__is_empty__)
				&& (is_open) {
					var _size = array_length(elements);
					
					if (!_input.consumed) {
						var _slice = sprite_get_nineslice(sprite.index);
						var _element_dist = region.get_height();
						
						var _posX = x;
						var _posY = y + _element_dist;
						
						
						_i=0; repeat(_size) {
							//if element is disabled continue
							if (!elements[_i].is_enabled) {
								elements[_i].image.index = GUI_IMAGE_DISABLED;
								_i+=1;
								continue;
							}
							
							if (point_in_rectangle(_mX, _mY, _posX, _posY, _posX + region.get_width(), _posY + region.get_height())) {
								capture_input();
								elements[_i].image.index = GUI_IMAGE_HOVER;
								
								if (mouse_check_button_pressed(mb_left)) {
									//trigger events
									__trigger_event__(self.events.element_pressed, {index : current_index, element : (current_index == -1) ? undefined : elements[current_index]});
									
									elements[_i].image.index = GUI_IMAGE_CLICKED;
									
								}
								else if (mouse_check_button(mb_left)) {
									//trigger events
									__trigger_event__(self.events.element_held, {index : current_index, element : (current_index == -1) ? undefined : elements[current_index]});
									
									elements[_i].image.index = GUI_IMAGE_CLICKED;
									
								}
								else if (mouse_check_button_released(mb_left)) {
									//trigger events
									__trigger_event__(self.events.element_released, {index : current_index, element : (current_index == -1) ? undefined : elements[current_index]});
									__trigger_event__(self.events.selected, {index : current_index, element : (current_index == -1) ? undefined : elements[current_index]});
									if (get_value() != _i) {
										__trigger_event__(self.events.changed, {index : current_index, element : (current_index == -1) ? undefined : elements[current_index]});
									}
									
									elements[_i].image.index = GUI_IMAGE_HOVER;
									set_value(_i);
									is_open = false;
								}
								
							}
							else{
								elements[_i].image.index = GUI_IMAGE_ENABLED;
							}
							
							_posY += _element_dist;
							
						_i++;}//end repeat loop
					}
				}
				
			}
			
			static __step__ = function(_input) {
				step(_input);
				
				__handle_click__(_input);
				
				//close drop down if clicked elsewhere
				if (is_open)
				&& (mouse_check_button_released(mb_left))
				&& (!mouse_on_comp()) {
					is_open = false;
				}
				
				//close the drop down if we attempt to scroll (usually because it's inside a scroll region)
				if (is_open)
				&& (mouse_wheel_down() || mouse_wheel_up()) {
					is_open = false;
				}
				
			}
			
			static __reset_focus__ = function() {
				is_open = false;
				__is_on_focus__ = false;
			}
			
			#region jsDoc
			/// @func    __new_element__()
			/// @desc    Constructs a new dropdown element from the given string.
			/// @self    GUICompDropdown
			/// @param   {String} string : The text which will be drawn by the element.
			/// @ignore
			#endregion
			static __new_element__ = function(_string) constructor {
				text = _string;
				font = -1;
				image.index = 0;
				is_enabled = true;
				color = {
					idle     : -1,
					hover    : -1,
					clicked  : -1,
					disabled : -1,
				}
			}
			
		#endregion
		
	#endregion
	
}
