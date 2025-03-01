function GUICompScrollBar() : GUICompController() constructor {
	debug_name = "GUICompScrollBar";
	
	#region Public
		
		#region Builder Functions
			
			static set_size = function(_left, _top, _right, _bottom) {
				region.left   = _left;
				region.top    = _top;
				region.right  = _right;
				region.bottom = _bottom;
				
				//update click regions
				if (__is_child__) {
					__parent__.__update_group_region__()
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
			static set_vertical = function(_vert) {
				
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
			static set_canvas_size = function(_size) {
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
			static set_coverage_size = function(_size) {
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
			static set_button_usage = function(_btn_used) {
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
			static set_button_sprites = function(_decrement_sprite, _increment_sprite) {
				__button_inc__.set_sprite(_increment_sprite);
				__button_dec__.set_sprite(_decrement_sprite);
				
				__button_inc__.set_offset(-__button_inc__.region.get_width(), -__button_inc__.region.get_height())
				
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
			static set_background_sprite = function(_sprite) {
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
			static set_thumb_sprite = function(_sprite) {
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
			static set_thumb_margin = function(_margin=-1) {
				
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
			static set_smooth_scrolling = function(_smooth=false) {
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
			static set_value = function(_value) {
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
			static set_normalized_value = function(_value) {
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
			static set_target_value = function(_target_value) {
				__scrollbar__.set_target_value(_target_value)
				target_value = __scrollbar__.target_value;
				
				return self;
			}
			
		#endregion
		
		#region Events
			
			self.events.mouse_over = variable_get_hash("mouse_over");
			self.events.pressed    = variable_get_hash("pressed");
			self.events.held       = variable_get_hash("held");
			self.events.long_press = variable_get_hash("long_press");
			self.events.released   = variable_get_hash("released");
			
			self.events.value_input       = variable_get_hash("value_input"); //if a value was input in any way, this will trigger every frame the slider is interacted wtih
			self.events.value_changed     = variable_get_hash("value_changed"); //if a value was changed in any way, this will trigger only when the previous frame's value does not equal the current frames value
			self.events.value_incremented = variable_get_hash("value_incremented"); //if a value was incremented, this will trigger only when the previous frame's value is less than the current frames value
			self.events.value_decremented = variable_get_hash("value_decremented"); //if a value was decremented, this will trigger only when the previous frame's value greater than the current frames value
			
		#endregion
		
		#region Variables
			
			canvas_size = 0;
			coverage_size = 0;
			max_scroll = 0;
			is_vertical = false;
			smooth_scrolling = false;
			target_value = 0;
			
		#endregion
		
		#region Functions
			
			#region jsDoc
			/// @func    get_value()
			/// @desc    Returns the value of the component
			/// @self    GUICompScrollBar
			/// @returns {Real}
			#endregion
			static get_value = function() {
				return value;
			}
			
			#region jsDoc
			/// @func    increment_scroll()
			/// @desc    Increments the scroll bar's value by a ratio of the coverage size, usually the view.
			/// @self    GUICompScrollBar
			/// @param   {Real} amount_of_view : The total amount of the view which should be moved, be default this is 0.06 which is a general standard but if you wish to include a faster scroll rate you can increase this value.
			/// @returns {Undefined}
			#endregion
			static increment_scroll = function(_amount_of_view = 0.0666) {
				
				if (smooth_scrolling) {
					var _loc = __scrollbar__.target_value + coverage_size * _amount_of_view;
					__scrollbar__.set_target_value(_loc);
				}
				else {
					var _loc = __scrollbar__.value + coverage_size * _amount_of_view;
					__scrollbar__.set_value(_loc);
					trigger_event(self.events.value_changed, __scrollbar__.value)
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
			static decrement_scroll = function(_amount_of_view = 0.0666) {
				
				if (smooth_scrolling) {
					var _loc = __scrollbar__.target_value - coverage_size * _amount_of_view;
					__scrollbar__.set_target_value(_loc);
				}
				else {
					var _loc = __scrollbar__.value - coverage_size * _amount_of_view;
					__scrollbar__.set_value(_loc);
					trigger_event(self.events.value_changed, __scrollbar__.value)
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
			__scrollbar__ = new GUICompSlider()
				.set_offset(0,0)
				.set_alignment(fa_left, fa_top)
				.set_clamp_values(0, 1)
				.set_thumb_enabled(true)
				.set_thumb_sprite(s9ScrollbarThumb)
				.set_thumb_clamped_in_bounds(true)
				.set_bar_enabled(false)
				.set_background_sprite(s9ScrollbarVertBackground)
				.set_thumb_only_input(true)
			
			__button_inc__ = new GUICompButtonSprite()
				.set_offset(0,0)
				.set_alignment(fa_right, fa_bottom)
			__button_dec__ = new GUICompButtonSprite()
				.set_offset(0,0)
				.set_alignment(fa_left, fa_top)
			
			//set the sprites and adjust the components over
			__button_inc__.set_sprite(s9ScrollbarVertButtonDown);
			__button_dec__.set_sprite(s9ScrollbarVertButtonUp);
			
			__button_inc__.set_offset(-__button_inc__.region.get_width(), -__button_inc__.region.get_height())
			
			__update_scrollbar__();
			
			
			add([__scrollbar__, __button_dec__, __button_inc__]);
			
		#endregion
		
		#region Functions
			
			static __mouse_on_controller__ = function() {
				//check if parent even has a mouse over it
				if (__is_child__) {
					if (!__parent__.__mouse_on_comp__) {
						return false;
					}
				}
				
				//check to see if the mouse is out of the window it's self
				//static is_desktop = (os_type == os_windows || os_type == os_macosx || os_type == os_linux)
				//if (is_desktop) {
				//	if (window_mouse_get_x() != display_mouse_get_x() - window_get_x())
				//	|| (window_mouse_get_y() != display_mouse_get_y() - window_get_y()) {
				//		__mouse_on_comp__ = false;
				//		return false;
				//	}
				//}
				
				__mouse_on_comp__ = point_in_rectangle(
						device_mouse_x_to_gui(0),
						device_mouse_y_to_gui(0),
						x+region.left,
						y+region.top,
						x+region.right,
						y+region.bottom
				)
				
				if (__mouse_on_comp__) {
					trigger_event(self.events.on_hover);
				}
				
				return __mouse_on_comp__;
			}
			
			static update_component_positions = function() {
				//if we changed the use of buttons re build their anchor points
				if (__prev_using_buttons__ != __using_buttons__) {
					if (__using_buttons__) {
						
						//move buttons into possition
						__button_dec__.set_offset(0,0)
						__button_inc__.set_offset(
								-__button_inc__.region.get_width(),
								-__button_inc__.region.get_height()
						)
						
						//adjust the scroll bar
						if (is_vertical) {
							__scrollbar__.set_offset(0, __button_dec__.region.get_height())
						}
						else {
							__scrollbar__.set_offset(__button_dec__.region.get_width(), 0);
						}
						
					}
					else {
						//adjust the scroll bar
						__scrollbar__.set_size(0, 0, region.get_width(), region.get_height());
						__scrollbar__.set_offset(0, 0);
					}
					
					__prev_using_buttons__ = __using_buttons__;
				}
				
				static __update_component_positions = GUICompController.update_component_positions;
				__update_component_positions();
			}
			
			static __update_scrollbar__ = function() {
				//adjust the scroll bar
				if (__using_buttons__) {
					if (is_vertical) {
						var _btn_height = __button_inc__.region.get_height() + __button_dec__.region.get_height();
						var _bar_height = region.get_height() - _btn_height;
						__scrollbar__.set_size(0, 0, region.get_width(), _bar_height);
						__scrollbar__.set_offset(0, __button_dec__.region.get_height())
					}
					else {
						var _btn_width = __button_inc__.region.get_width() + __button_dec__.region.get_width();
						var _bar_width = region.get_width() - _btn_width;
						__scrollbar__.set_size(0, 0, _bar_width, region.get_height());
						__scrollbar__.set_offset(__button_dec__.region.get_width(), 0)
					}
				}
				else {
					__scrollbar__.set_size(0, 0, region.get_width(), region.get_height());
				}
			}
			
			static __adjust_scrollbar_thumb_size__ = function() {
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
			
			static __update_button_enables__ = function() {
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
					
					__scrollbar__.add_event_listener(__scrollbar__.events.mouse_over, function() {trigger_event(self.events.mouse_over, __scrollbar__.value)});
					__scrollbar__.add_event_listener(__scrollbar__.events.pressed   , function() {trigger_event(self.events.pressed   , __scrollbar__.value)});
					__scrollbar__.add_event_listener(__scrollbar__.events.held      , function() {trigger_event(self.events.held      , __scrollbar__.value)});
					__scrollbar__.add_event_listener(__scrollbar__.events.long_press, function() {trigger_event(self.events.long_press, __scrollbar__.value)});
					__scrollbar__.add_event_listener(__scrollbar__.events.released  , function() {trigger_event(self.events.released  , __scrollbar__.value)});
					
					__scrollbar__.add_event_listener(__scrollbar__.events.value_input      , function() {trigger_event(self.events.value_input      , __scrollbar__.value)});
					__scrollbar__.add_event_listener(__scrollbar__.events.value_changed    , function() {trigger_event(self.events.value_changed    , __scrollbar__.value)});
					__scrollbar__.add_event_listener(__scrollbar__.events.value_incremented, function() {trigger_event(self.events.value_incremented, __scrollbar__.value)});
					__scrollbar__.add_event_listener(__scrollbar__.events.value_decremented, function() {trigger_event(self.events.value_decremented, __scrollbar__.value)});
					
					__button_inc__.add_event_listener(__button_inc__.events.mouse_over, function() {trigger_event(self.events.mouse_over, __scrollbar__.value)});
					__button_inc__.add_event_listener(__button_inc__.events.pressed   , function() {trigger_event(self.events.pressed   , __scrollbar__.value)});
					__button_inc__.add_event_listener(__button_inc__.events.held      , function() {trigger_event(self.events.held      , __scrollbar__.value)});
					__button_inc__.add_event_listener(__button_inc__.events.released  , function() {trigger_event(self.events.released  , __scrollbar__.value)});
					
					__button_dec__.add_event_listener(__button_dec__.events.mouse_over, function() {trigger_event(self.events.mouse_over, __scrollbar__.value)});
					__button_dec__.add_event_listener(__button_dec__.events.pressed   , function() {trigger_event(self.events.pressed   , __scrollbar__.value)});
					__button_dec__.add_event_listener(__button_dec__.events.held      , function() {trigger_event(self.events.held      , __scrollbar__.value)});
					__button_dec__.add_event_listener(__button_dec__.events.released  , function() {trigger_event(self.events.released  , __scrollbar__.value)});
					
				#endregion
				
				//self
				add_event_listener(self.events.value_input, function(){
					value            = __scrollbar__.value;
					normalized_value = __scrollbar__.normalized_value;
					target_value     = __scrollbar__.target_value;
					
					__update_button_enables__();
				});
				
				//scrollbar
				__scrollbar__.add_event_listener(__scrollbar__.events.post_step, function(){
					if (__scrollbar__.__is_on_focus__) {
						__update_button_enables__();
					}
				});
				
				//increment button events
				__button_inc__.add_event_listener(__button_inc__.events.pressed, function(){
					__button_held_time__ = 0;
					increment_scroll();
				});
				__button_inc__.add_event_listener(__button_inc__.events.held, function(){
					__button_held_time__ += game_get_speed(gamespeed_fps) * 0.000001 * delta_time;
					
					if (__button_held_time__ > game_get_speed(gamespeed_fps)*0.333) {
						increment_scroll();
					}
				});
				
				//decrement button events
				__button_dec__.add_event_listener(__button_dec__.events.pressed, function(){
					__button_held_time__ = 0;
					decrement_scroll();
				});
				__button_dec__.add_event_listener(__button_dec__.events.held, function(){
					__button_held_time__ += game_get_speed(gamespeed_fps) * 0.000001 * delta_time;
					
					if (__button_held_time__ > game_get_speed(gamespeed_fps)*0.333) {
						decrement_scroll();
					}
				});
				
			#endregion
			
		#endregion
		
	#endregion
	
	static draw_debug = function(){
		if (!should_draw_debug) return;
		
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
