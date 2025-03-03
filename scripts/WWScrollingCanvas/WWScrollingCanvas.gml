#region jsDoc
/// @func    WWScrollingCanvas()
/// @desc    A general scrolling viewport for any type of content.
/// @returns {Struct.WWScrollingCanvas}
#endregion
function WWScrollingCanvas() : WWViewport() constructor {
	debug_name = "WWScrollingCanvas";

	#region Public
		
		#region Builder Functions

			#region jsDoc
			/// @func    set_scroll_speeds()
			/// @desc    Sets the scrolling speed for the viewport's content.
			/// @self    WWScrollingCanvas
			/// @param   {Real} hspeed : Horizontal scrolling speed.
			/// @param   {Real} vspeed : Vertical scrolling speed.
			/// @returns {Struct.WWScrollingCanvas}
			#endregion
			static set_scroll_speeds = function(_hspeed=0, _vspeed=0) {
				scroll.x_speed = _hspeed;
				scroll.y_speed = _vspeed;
				
				return self;
			};
			
			#region jsDoc
			/// @func    set_scroll_looping()
			/// @desc    Enables or disables looping for scrolling.
			/// @self    WWScrollingCanvas
			/// @param   {Bool} x_loop : Whether horizontal scrolling should loop.
			/// @param   {Bool} y_loop : Whether vertical scrolling should loop.
			/// @returns {Struct.WWScrollingCanvas}
			#endregion
			static set_scroll_looping = function(_x_loop=false, _y_loop=false) {
				scroll.x_looping = _x_loop;
				scroll.y_looping = _y_loop;
				
				return self;
			};
			
			#region jsDoc
			/// @func    set_scroll_pause()
			/// @desc    Pauses or resumes scrolling.
			/// @self    WWScrollingCanvas
			/// @param   {Bool} paused : Whether scrolling should be paused.
			/// @returns {Struct.WWScrollingCanvas}
			#endregion
			static set_scroll_pause = function(_paused=true) {
				scroll.paused = _paused;
				return self;
			};
			
			#region jsDoc
			/// @func    set_scroll_offsets()
			/// @desc    Sets the current position of the scrolling text.
			/// @self    WWScrollingText
			/// @param   {Real} xoff : The current x possition of the scrolling text.
			/// @param   {Real} yoff : The current y possition of the scrolling text.
			/// @returns {Struct.WWScrollingText}
			#endregion
			static set_scroll_offsets = function(_xoff=0, _yoff=0){
				scroll.x_off = _xoff;
				scroll.y_off = _yoff;
				
				scroll.orig_x_off   = scroll.x_off;
				scroll.orig_y_off   = scroll.y_off;
				
				return self;
			}
			
		#endregion
		
		#region Variables
			
			scroll = {};
			scroll.x_off = 0;
			scroll.y_off = 0;
			scroll.x_speed = 0;
			scroll.y_speed = 0;
			scroll.x_looping = true;
			scroll.y_looping = true;
			scroll.paused = false;

		#endregion

		#region Events

			on_pre_step(function(_input) {
				if (scroll.paused || canvas == undefined) return;

				// Update position
				scroll.x_off += scroll.x_speed;
				scroll.y_off += scroll.y_speed;
				
				var _w = width;
				var _h = height;
				var _canvas_w = canvas.width;
				var _canvas_h = canvas.height;
				
				
				// Horizontal Looping
				if (scroll.x_looping) {
					scroll.x_off = __wrap(
						scroll.x_off,
						-_canvas_w,
						_w
					);
				} else {
			        //if moving down
					if (scroll.x_speed > 0) {
						if (scroll.x_off + _canvas_w >= _w) {
							scroll.x_speed = -abs(scroll.x_speed);
						}
					}
					//if moving up
					else if (scroll.x_speed < 0) {
						if (scroll.x_off < 0) {
							scroll.x_speed = abs(scroll.x_speed);
						}
					}
			    }
				
				// Vertical Looping
				if (scroll.y_looping) {
					scroll.y_off = __wrap(
						scroll.y_off,
						-_canvas_h,
						_h
					);
				} else {
			        //if moving down
					if (scroll.y_speed > 0) {
						if (scroll.y_off + _canvas_h >= _h) {
							scroll.y_speed = -abs(scroll.y_speed);
						}
					}
					//if moving up
					else if (scroll.y_speed < 0) {
						if (scroll.y_off < 0) {
							scroll.y_speed = abs(scroll.y_speed);
						}
					}
					
			    }
				
				canvas.set_offset(scroll.x_off, scroll.y_off);
				
			});

		#endregion
		
		#region Functions
			
			#region jsDoc
			/// @func    reset_scrolling()
			/// @desc    Resets the text scrolling back to the originally defiened locations.
			/// @self    WWScrollingText
			/// @returns {Undefined}
			#endregion
			static reset_scrolling = function() {
				scroll.x_off = scroll.orig_x_off;
				scroll.y_off = scroll.orig_y_off;
				scroll.y_speed = scroll.orig_y_speed;
				scroll.x_speed = scroll.orig_x_speed;
			}
			
		#endregion

	#endregion

	#region Private
		
		#region Functions
		
			#region jsDoc
			/// @func    __wrap()
			/// @desc    Wraps a value between a minimum and maximum.
			/// @param   {Real} value : The value to wrap.
			/// @param   {Real} min   : The minimum value.
			/// @param   {Real} max   : The maximum value.
			/// @returns {Real}
			#endregion
			static __wrap = function(_value, _min, _max) {
				if (_max == 0) return 0;
				var _mod = (_value - _min) mod (_max - _min);
				return (_mod < 0) ? _mod + _max : _mod + _min;
			};
			
			static __update_viewport_from_canvas__ = function() {
				__set_size__(canvas.width, canvas.height);
			}
			
		#endregion
		
	#endregion

}
