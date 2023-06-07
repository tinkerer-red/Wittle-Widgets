function GUICompScrollBar(_x, _y) : GUICompController(_x, _y) constructor {
	debug_name = "GUICompScrollBar";
	
	#region Public
		
		#region Builder Functions
			static set_region = function(_left, _top, _right, _bottom) {//log(["set_region", set_region])
				region.left   = _left;
				region.top    = _top;
				region.right  = _right;
				region.bottom = _bottom;
				
				//update click regions
				if (__is_child__) {
					__parent__.__update_controller_region__()
				}
				
				__update_scrollbar__();
				update_component_positions();
				
				return self;
			}
			#region jsDoc
			/// @func    set_vertical()
			/// @desc    Sets the slider to be vertical, this does not rotate the slider, only how the inputs and drawing are calculated.
			/// @self    GUICompScrollBar
			/// @param   {Bool} is_vertical : If the slider is vertically oriented. true = vertical, false = horizontal
			/// @returns {Struct.GUICompScrollBar}
			#endregion
			static set_vertical = function(_vert) {//log(["set_vertical", set_vertical])
				
				is_vertical = _vert;
				__scrollbar__.set_vertical(_vert);
				__update_scrollbar__();
				
				update_component_positions();
				
				return self;
			}
			#region jsDoc
			/// @func    set_canvas_size()
			/// @desc    Sets the canvas size. This is used to help calculate the scroll bars height based off how much is viewed with in a region.
			///
			///          Example: 
			///
			///          if it's a scrolling text box which is 20 lines big and you only want to show 5 lines,
			///
			///          use `set_canvas_size(string_height("M")*20)`
			///
			///          and `set_coverage_size(string_height("M")*5)`
			/// @self    GUICompScrollBar
			/// @param   {Real} size : The size of the canvas this scrollbar represents.
			/// @returns {Struct.GUICompScrollBar}
			#endregion
			static set_canvas_size = function(_size) {//log(["set_canvas_size", set_canvas_size])
				canvas_size = _size;
				
				max_scroll = clamp(canvas_size-coverage_size, 0, canvas_size);
				
				__scrollbar__.set_clamp_values(0, max_scroll);
				
				__adjust_scrollbar_thumb_size__();
				
				return self;
			}
			#region jsDoc
			/// @func    set_coverage_size()
			/// @desc    Sets the coverage size. This is used to help calculate the scroll bars height based off how much is viewed with in a region.
			///
			///          Example: 
			///
			///          if it's a scrolling text box which is 20 lines big and you only want to show 5 lines,
			///
			///          use `set_canvas_size(string_height("M")*20)`
			///
			///          and `set_coverage_size(string_height("M")*5)`
			/// @self    GUICompScrollBar
			/// @param   {Real} size : The size of the canvas this scrollbar represents.
			/// @returns {Struct.GUICompScrollBar}
			#endregion
			static set_coverage_size = function(_size) {//log(["set_coverage_size", set_coverage_size])
				coverage_size = _size;
				max_scroll = clamp(canvas_size-coverage_size, 0, canvas_size);
				
				__scrollbar__.set_clamp_values(0, max_scroll);
				
				__adjust_scrollbar_thumb_size__();
				
				return self;
			}
			#region jsDoc
			/// @func    set_button_usage()
			/// @desc    Sets the buttons to be used or not
			/// @self    GUICompScrollBar
			/// @param   {Bool} btn_used : If the buttons are used or not
			/// @returns {Struct.GUICompScrollBar}
			#endregion
			static set_button_usage = function(_btn_used) {//log(["set_button_usage", set_button_usage])
				__using_buttons__ = _btn_used;
				
				return self;
			}
			#region jsDoc
			/// @func    set_button_sprites()
			/// @desc    Sets the button sprites to be used in the scroll bar component. The decrement sprite is either the scroll left or up button depending on if the scroll bar is horizontal or vertical. The increment sprite is either the scroll right or down button.
			/// @self    GUICompScrollBar
			/// @param   {Asset.GMSprite} decrement_sprite : The nineslice sprite to use for the decrementer button (left or up).
			/// @param   {Asset.GMSprite} increment_sprite : The nineslice sprite to use for the incrementer button (right or down).
			/// @returns {Struct.GUICompScrollBar}
			#endregion
			static set_button_sprites = function(_decrement_sprite, _increment_sprite) {//log(["set_button_sprites", set_button_sprites])
				__button_inc__.set_sprite(_increment_sprite);
				__button_dec__.set_sprite(_decrement_sprite);
				
				update_component_positions();
				
				return self;
			}
			#region jsDoc
			/// @func    set_background_sprite()
			/// @desc    Sets the background to be used in the slider component.
			/// @self    GUICompScrollBar
			/// @param   {Asset.GMSprite} sprite : The nineslice sprite to use for the background.
			/// @returns {Struct.GUICompScrollBar}
			#endregion
			static set_background_sprite = function(_sprite) {//log(["set_background_sprite", set_background_sprite])
				__scrollbar__.set_background_sprite(_sprite);
				
				if (__thumb_margin__ == -1) {
					__adjust_scrollbar_thumb_size__();
				}
				
				return self;
			}
			#region jsDoc
			/// @func    set_thumb_sprite()
			/// @desc    Sets the thumb sprite to be used in the slider component.
			/// @self    GUICompScrollBar
			/// @param   {Asset.GMSprite} sprite : The nineslice sprite to use for the thumb.
			/// @returns {Struct.GUICompSlider}
			#endregion
			static set_thumb_sprite = function(_sprite) {//log(["set_thumb_sprite", set_thumb_sprite])
				__scrollbar__.set_thumb_sprite(_sprite)
				
				__adjust_scrollbar_thumb_size__();
				
				return self;
			}
			#region jsDoc
			/// @func    set_thumb_margin()
			/// @desc    Sets the border margins of the thumb. This is the distance from the background's border the thumb should stay away from.
			/// @self    GUICompScrollBar
			/// @param   {Real} margin : The margin to set for the thumb. A margin of -1 will make the thumb automatically scale to the background's center region of its nineslice if it's enabled.
			/// @returns {Struct.GUICompSlider}
			#endregion
			static set_thumb_margin = function(_margin=-1) {//log(["set_thumb_margin", set_thumb_margin])
				
				if (__thumb_margin__ != _margin) {
					__thumb_margin__ = _margin;
					__adjust_scrollbar_thumb_size__();
				}
				else {
					__thumb_margin__ = _margin;
				}
					
				return self;
			}
			#region jsDoc
			/// @func    set_scrolling_smooth()
			/// @desc    Sets the scrolling to be smooth
			/// @self    GUICompScrollBar
			/// @param   {Bool} smooth : If the scroll bar should be smooth, this only effects how the buttons interact with the slider.
			/// @returns {Struct.GUICompScrollBar}
			#endregion
			static set_smooth_scrolling = function(_smooth=false) {//log(["set_smooth_scrolling", set_smooth_scrolling])
				smooth_scrolling = _smooth;
				
				return self;
			}
			#region jsDoc
			/// @func    set_value()
			/// @desc    Sets the value of the slider
			/// @self    GUICompScrollBar
			/// @param   {Real} value : The value to set the slider to.
			/// @returns {Struct.GUICompSlider}
			#endregion
			static set_value = function(_value) {//log(["set_value", set_value])
				__scrollbar__.set_value(_value)
				value = __scrollbar__.value;
				
				return self;
			}
			#region jsDoc
			/// @func    set_normalized_value()
			/// @desc    Sets the value of the slider using a normalized input, The input must be a value between 0 and 1. This is similar to the lerp function.
			/// @self    GUICompScrollBar
			/// @param   {Real} value : The normalized value to set the slider to.
			/// @returns {Struct.GUICompSlider}
			#endregion
			static set_normalized_value = function(_value) {//log(["set_normalized_value", set_normalized_value])
				__scrollbar__.set_normalized_value(_value);
				normalized_value = __scrollbar__.normalized_value;
				
				return self;
			}
			#region jsDoc
			/// @func    set_target_value()
			/// @desc    This function will smoothly set the slider's value to a target value.
			/// @self    GUICompScrollBar
			/// @param   {Real} target_value : The target value the slider should smooth towards.
			/// @returns {Struct.GUICompSlider}
			#endregion
			static set_target_value = function(_target_value) {//log(["set_target_value", set_target_value])
				__scrollbar__.set_target_value(_target_value)
				target_value = __scrollbar__.target_value;
				
				return self;
			}
			
		#endregion
		
		#region Events
			
			self.events.mouse_over = "mouse_over";
			self.events.pressed    = "pressed";
			self.events.held       = "held";
			self.events.released   = "released";
			
			self.events.value_input       = "value_input"; //if a value was input in any way, this will trigger every frame the slider is interacted wtih
			self.events.value_changed     = "value_changed"; //if a value was changed in any way, this will trigger only when the previous frame's value does not equal the current frames value
			self.events.value_incremented = "value_incremented"; //if a value was incremented, this will trigger only when the previous frame's value is less than the current frames value
			self.events.value_decremented = "value_decremented"; //if a value was decremented, this will trigger only when the previous frame's value greater than the current frames value
			
		#endregion
		
		#region Variables
			
			canvas_size = 0;
			coverage_size = 0;
			max_scroll = 0;
			is_vertical = false;
			smooth_scrolling = false;
			
		#endregion
		
		#region Functions
			
			#region jsDoc
			/// @func    get_value()
			/// @desc    Returns the value of the component
			/// @self    GUICompScrollBar
			/// @returns {Real}
			#endregion
			static get_value = function() {//log(["get_value", get_value])
				return value;
			}
			
			#region jsDoc
			/// @func    increment_scroll()
			/// @desc    Increments the scroll bar's value by a ratio of the coverage size, usually the view.
			/// @self    GUICompScrollBar
			/// @param   {Real} amount_of_view : The total amount of the view which should be moved, be default this is 0.06 which is a general standard but if you wish to include a faster scroll rate you can increase this value.
			/// @returns {Undefined}
			#endregion
			static increment_scroll = function(_amount_of_view = 0.0666) {//log(["increment_scroll", increment_scroll])
				
				if (smooth_scrolling) {
					var _loc = __scrollbar__.target_value + coverage_size * _amount_of_view;
					__scrollbar__.set_target_value(_loc);
				}
				else {
					var _loc = __scrollbar__.value + coverage_size * _amount_of_view;
					__scrollbar__.set_value(_loc);
				}
				
				__update_button_enables__()
			}
			
			#region jsDoc
			/// @func    decrement_scroll()
			/// @desc    Decrements the scroll bar's value by a ratio of the coverage size, usually the view.
			/// @self    GUICompScrollBar
			/// @param   {Real} amount_of_view : The total amount of the view which should be moved, be default this is 0.06 which is a general standard but if you wish to include a faster scroll rate you can increase this value.
			/// @returns {Undefined}
			#endregion
			static decrement_scroll = function(_amount_of_view = 0.0666) {//log(["decrement_scroll", decrement_scroll])
				
				if (smooth_scrolling) {
					var _loc = __scrollbar__.target_value - coverage_size * _amount_of_view;
					__scrollbar__.set_target_value(_loc);
				}
				else {
					var _loc = __scrollbar__.value - coverage_size * _amount_of_view;
					__scrollbar__.set_value(_loc);
				}
				
				__update_button_enables__();
			}
			
		#endregion
		
	#endregion
	
	#region Private Library
		
		#region Variables
			
			__using_buttons__ = true;
			__prev_using_buttons__ = __using_buttons__;
			__thumb_margin__ = -1;
			__button_held_time__ = 0;
			
			//pieces of the scrollbar
			__scrollbar__ = new GUICompSlider(_x,_y);
			__scrollbar__.set_clamp_values(0, 1)
			         .set_thumb_enabled(true)
							 .set_thumb_sprite(s9ScrollbarThumb)
							 .set_thumb_clamped_in_bounds(true)
							 .set_bar_enabled(false)
							 .set_background_sprite(s9ScrollbarVertBackground)
							 .set_thumb_only_input(true)
							 
			__button_inc__ = new GUICompButtonSprite(_x,_y);
			__button_dec__ = new GUICompButtonSprite(_x,_y);
			__button_inc__.set_sprite(s9ScrollbarVertButtonDown);
			__button_dec__.set_sprite(s9ScrollbarVertButtonUp);
			
			add([__scrollbar__, __button_dec__, __button_inc__]);
			
		#endregion
		
		#region Functions
			
			static __mouse_on_controller__ = function() {//log(["__mouse_on_controller__", __mouse_on_controller__])
				//check if parent even has a mouse over it
				if (__is_child__) {
					if (!__parent__.__mouse_on_cc__) {
						return false;
					}
				}
				
				//check to see if the mouse is out of the window it's self
				static is_desktop = (os_type == os_windows || os_type == os_macosx || os_type == os_linux)
				if (is_desktop) {
					if (window_mouse_get_x() != display_mouse_get_x() - window_get_x())
					|| (window_mouse_get_y() != display_mouse_get_y() - window_get_y()) {
						__mouse_on_cc__ = false;
						return false;
					}
				}
				
				__mouse_on_cc__ = point_in_rectangle(
						device_mouse_x_to_gui(0),
						device_mouse_y_to_gui(0),
						x+region.left,
						y+region.top,
						x+region.right,
						y+region.bottom
				)
				return __mouse_on_cc__;
			}
			
			static update_component_positions = function() {//log(["update_component_positions", update_component_positions])
				if (__prev_using_buttons__ != __using_buttons__) {
					if (__using_buttons__) {
					
						//move buttons into possition
						__button_dec__.x = x + region.left;
						__button_dec__.y = y + region.top;
						__button_inc__.x = x + region.right  - __button_inc__.region.get_width();
						__button_inc__.y = y + region.bottom - __button_inc__.region.get_height();
					
						//adjust the scroll bar
						if (is_vertical) {
							__scrollbar__.x = x + region.left;
							__scrollbar__.y = y + region.top + __button_dec__.region.get_height();
						}
						else {
							__scrollbar__.x = x + region.left + __button_dec__.region.get_width();
							__scrollbar__.y = y + region.top;
						}
					
					}
					else {
						//adjust the scroll bar
						__scrollbar__.set_region(0, 0, region.get_width(), region.get_height());
						__scrollbar__.x = x;
						__scrollbar__.y = y;
					}
					
					__prev_using_buttons__ = __using_buttons__;
				}
				
				#region Regenerate Anchors
					
					//var _comp, _index, _old_anchor;
					
					//_comp = __scrollbar__;
					//_index = find(_comp);
					//_old_anchor = __anchors__[_index];
					//__anchors__[_index] = new __anchor__(_comp.x+x, _comp.y+y, _comp.halign, _comp.valign);
					//delete _old_anchor;
					
					//_comp = __button_inc__;
					//_index = find(_comp);
					//_old_anchor = __anchors__[_index];
					//__anchors__[_index] = new __anchor__(_comp.x+x, _comp.y+y, _comp.halign, _comp.valign);
					//delete _old_anchor;
					
					//_comp = __button_dec__;
					//_index = find(_comp);
					//_old_anchor = __anchors__[_index];
					//__anchors__[_index] = new __anchor__(_comp.x+x, _comp.y+y, _comp.halign, _comp.valign);
					//delete _old_anchor;
					
				#endregion
				
				//__adjust_scrollbar_thumb_size__();
				
				//__update_controller_region__();
			}
			
			static __update_scrollbar__ = function() {//log(["__update_scrollbar__", __update_scrollbar__])
				//adjust the scroll bar
				if (__using_buttons__) {
					if (is_vertical) {
						var _btn_height = __button_inc__.region.get_height() + __button_dec__.region.get_height();
						var _bar_height = region.get_height() - _btn_height;
						__scrollbar__.set_region(0, 0, region.get_width(), _bar_height);
					}
					else {
						var _btn_width = __button_inc__.region.get_width() + __button_dec__.region.get_width();
						var _bar_width = region.get_width() - _btn_width;
						__scrollbar__.set_region(0, 0, _bar_width, region.get_height());
					}
				}
				else {
					__scrollbar__.set_region(0, 0, region.get_width(), region.get_height());
				}
			}
			
			static __adjust_scrollbar_thumb_size__ = function() {//log(["__adjust_scrollbar_thumb_size__", __adjust_scrollbar_thumb_size__])
				var _ratio = coverage_size / canvas_size;
				
				var _thumb_width, _thumb_height;
				
				if (__thumb_margin__ == -1) {
					var _slice = sprite_get_nineslice(__scrollbar__.background.sprite);
					_thumb_width  = region.get_width()  - _slice.right  - _slice.left;
					_thumb_height = region.get_height() - _slice.bottom - _slice.top ;
				}
				else {
					_thumb_width = region.get_width()   - __thumb_margin__ - __thumb_margin__;
					_thumb_height = region.get_height() -	__thumb_margin__ - __thumb_margin__;
				}
				
				if (is_vertical) {
					var _usable_height = region.get_height();
					if (__using_buttons__) {
						_usable_height -= __button_inc__.region.get_height();
						_usable_height -= __button_dec__.region.get_height();
					}
					
					_thumb_height = _usable_height*_ratio - __thumb_margin__ - __thumb_margin__;
				}
				else {
					var _usable_width = region.get_width();
					if (__using_buttons__) {
						_usable_width -= __button_inc__.region.get_width();
						_usable_width -= __button_dec__.region.get_width();
					}
					
					_thumb_width = _usable_width*_ratio - __thumb_margin__ - __thumb_margin__;
				}
				
				var _spr = __scrollbar__.thumb.sprite;
				var _spr_width  = sprite_get_width(_spr);
				var _spr_height = sprite_get_height(_spr);
				
				__scrollbar__.set_thumb_scales(_thumb_width/_spr_width, _thumb_height/_spr_height)
			}
			
			static __update_button_enables__ = function() {//log(["__update_button_enables__", __update_button_enables__])
				if (is_enabled) {
					if (__scrollbar__.value == max_scroll) {
						__button_inc__.set_enabled(false);
					}
					else {
						__button_inc__.set_enabled(true);
					}
					
					if (__scrollbar__.value == 0) {
						__button_dec__.set_enabled(false);
					}
					else {
						__button_dec__.set_enabled(true);
					}
				}
			}
			
			#region Private Events
				
				#region Parent child events
					
					__scrollbar__.__add_event_listener_priv__(__scrollbar__.events.mouse_over, method(self, function() {__trigger_event__(self.events.mouse_over, __scrollbar__.value)}));
					__scrollbar__.__add_event_listener_priv__(__scrollbar__.events.pressed   , method(self, function() {__trigger_event__(self.events.pressed   , __scrollbar__.value)}));
					__scrollbar__.__add_event_listener_priv__(__scrollbar__.events.held      , method(self, function() {__trigger_event__(self.events.held      , __scrollbar__.value)}));
					__scrollbar__.__add_event_listener_priv__(__scrollbar__.events.released  , method(self, function() {__trigger_event__(self.events.released  , __scrollbar__.value)}));
					
					__scrollbar__.__add_event_listener_priv__(__scrollbar__.events.value_input      , method(self, function() {__trigger_event__(self.events.value_input      , __scrollbar__.value)}));
					__scrollbar__.__add_event_listener_priv__(__scrollbar__.events.value_changed    , method(self, function() {__trigger_event__(self.events.value_changed    , __scrollbar__.value)}));
					__scrollbar__.__add_event_listener_priv__(__scrollbar__.events.value_incremented, method(self, function() {__trigger_event__(self.events.value_incremented, __scrollbar__.value)}));
					__scrollbar__.__add_event_listener_priv__(__scrollbar__.events.value_decremented, method(self, function() {__trigger_event__(self.events.value_decremented, __scrollbar__.value)}));
					
					__button_inc__.__add_event_listener_priv__(__button_inc__.events.mouse_over, method(self, function() {__trigger_event__(self.events.mouse_over, __scrollbar__.value)}));
					__button_inc__.__add_event_listener_priv__(__button_inc__.events.pressed   , method(self, function() {__trigger_event__(self.events.pressed   , __scrollbar__.value)}));
					__button_inc__.__add_event_listener_priv__(__button_inc__.events.held      , method(self, function() {__trigger_event__(self.events.held      , __scrollbar__.value)}));
					__button_inc__.__add_event_listener_priv__(__button_inc__.events.released  , method(self, function() {__trigger_event__(self.events.released  , __scrollbar__.value)}));
					
					__button_dec__.__add_event_listener_priv__(__button_dec__.events.mouse_over, method(self, function() {__trigger_event__(self.events.mouse_over, __scrollbar__.value)}));
					__button_dec__.__add_event_listener_priv__(__button_dec__.events.pressed   , method(self, function() {__trigger_event__(self.events.pressed   , __scrollbar__.value)}));
					__button_dec__.__add_event_listener_priv__(__button_dec__.events.held      , method(self, function() {__trigger_event__(self.events.held      , __scrollbar__.value)}));
					__button_dec__.__add_event_listener_priv__(__button_dec__.events.released  , method(self, function() {__trigger_event__(self.events.released  , __scrollbar__.value)}));
					
				#endregion
				
				//self
				__add_event_listener_priv__(self.events.value_input, method(self, function(){
					value            = __scrollbar__.value;
					normalized_value = __scrollbar__.normalized_value;
					target_value     = __scrollbar__.target_value;
					
					__update_button_enables__();
				}));
				
				//scrollbar
				__scrollbar__.__add_event_listener_priv__(__scrollbar__.events.post_update, method(self, function(){
					if (__scrollbar__.__is_on_focus__) {
						__update_button_enables__();
					}
				}));
				
				//increment button events
				__button_inc__.__add_event_listener_priv__(__button_inc__.events.pressed, method(self, function(){
					__button_held_time__ = 0;
					increment_scroll();
				}));
				__button_inc__.__add_event_listener_priv__(__button_inc__.events.held, method(self, function(){
					__button_held_time__ += game_get_speed(gamespeed_fps) * 0.000001 * delta_time;
					
					if (__button_held_time__ > game_get_speed(gamespeed_fps)*0.333) {
						increment_scroll();
					}
				}));
				
				//decrement button events
				__button_dec__.__add_event_listener_priv__(__button_dec__.events.pressed, method(self, function(){
					__button_held_time__ = 0;
					decrement_scroll();
				}));
				__button_dec__.__add_event_listener_priv__(__button_dec__.events.held, method(self, function(){
					__button_held_time__ += game_get_speed(gamespeed_fps) * 0.000001 * delta_time;
					
					if (__button_held_time__ > game_get_speed(gamespeed_fps)*0.333) {
						decrement_scroll();
					}
				}));
				
			#endregion
			
			#region GML Events
				
				static __begin_step__ = function(_input) {//log(["__begin_step__", __begin_step__])
					if (GUI_GLOBAL_SAFETY) {
						if (is_nan(coverage_size / canvas_size)) {
							show_error(string("Scroll bar is producing a NaN, make sure to set it's sizes with \"set_coverage_size()\" and \"set_canvas_size()\" \ncoverage_size : {0}\ncanvas_size : {1}", coverage_size, canvas_size), true);
						}
					}
					__post_remove__();
					
					__user_input__ = _input;
					__mouse_on_cc__ = __mouse_on_controller__();
					__trigger_event__(self.events.pre_update);
					
					begin_step(_input);
					
					
					//run the children
					__scrollbar__.__begin_step__(_input);
					if (__using_buttons__) {
						__button_inc__.__begin_step__(_input);
						__button_dec__.__begin_step__(_input);
					}
					
					//return the consumed inputs
					if (__user_input__.consumed) { capture_input(); };
				}
				static __step__ = function(_input) {//log(["__step__", __step__])
					__user_input__ = _input;
					
					step(_input);
					
					__mouse_on_cc__ = __mouse_on_controller__();
					
					//run the children
					__scrollbar__.__step__(_input);
					if (__using_buttons__) {
						__button_inc__.__step__(_input);
						__button_dec__.__step__(_input);
					}
					
					if (__user_input__.consumed) { capture_input(); };
				}
				static __end_step__ = function(_input) {//log(["__end_step__", __end_step__])
					__user_input__ = _input;
					
					end_step(_input);
					
					//run the children
					__scrollbar__.__end_step__(_input);
					if (__using_buttons__) {
						__button_inc__.__end_step__(_input);
						__button_dec__.__end_step__(_input);
					}
					
					__trigger_event__(self.events.post_update);
					
					if (__user_input__.consumed) { capture_input(); };
				}
				
				static __draw_gui_begin__ = function(_input) {//log(["__draw_gui_begin__", __draw_gui_begin__])
					__post_remove__();
					
					__user_input__ = _input;
					
					draw_gui_begin(_input);
					
					//run the children
					__scrollbar__.__draw_gui_begin__(_input);
					if (__using_buttons__) {
						__button_inc__.__draw_gui_begin__(_input);
						__button_dec__.__draw_gui_begin__(_input);
					}
					
					if (__user_input__.consumed) { capture_input(); };
				}
				static __draw_gui__ = function(_input) {//log(["__draw_gui__", __draw_gui__])
					__user_input__ = _input;
					
					draw_gui(_input);
					
					//run the children
					__scrollbar__.__draw_gui__(_input);
					if (__using_buttons__) {
						__button_inc__.__draw_gui__(_input);
						__button_dec__.__draw_gui__(_input);
					}
					
					if (__user_input__.consumed) { capture_input(); };
					
				}
				static __draw_gui_end__ = function(_input) {//log(["__draw_gui_end__", __draw_gui_end__])
					__user_input__ = _input;
					
					draw_gui_end(_input);
					
					//run the children
					__scrollbar__.__draw_gui_end__(_input);
					if (__using_buttons__) {
						__button_inc__.__draw_gui_end__(_input);
						__button_dec__.__draw_gui_end__(_input);
					}
					
					if (__user_input__.consumed) { capture_input(); };
					
					xprevious = x;
					yprevious = y;
					
					if (GUI_GLOBAL_DEBUG) {
						draw_debug();
					}
				}
				
				static __cleanup__ = function() {//log(["__cleanup__", __cleanup__])
					cleanup();
					
					//run the children
					__scrollbar__.__cleanup__();
					__button_inc__.__cleanup__();
					__button_dec__.__cleanup__();
					
					delete __scrollbar__;
					delete __button_inc__;
					delete __button_dec__;
				}
				
			#endregion
			
		#endregion
		
	#endregion
	
	static draw_debug = function(){//log(["draw_debug", draw_debug])
		return
		draw_rectangle(
				x+region.left,
				y+region.top,
				x+region.right,
				y+region.bottom,
				true
		)
		draw_text(x,y,""
			+"\n"+ string("x: {0}", x)
			+"\n"+ string("y: {0}", y)
			+"\n"+ string("value: {0}", value)
			+"\n"+ string("canvas_size: {0}", canvas_size)
			+"\n"+ string("coverage_size: {0}", coverage_size)
			+"\n"+ string("canvas_size-coverage_size: {0}", canvas_size-coverage_size)
			+"\n"+ json_stringify(region, true)
		)
	}
}
