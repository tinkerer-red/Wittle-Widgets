#region jsDoc
/// @func    WWViewScrollAuto()
/// @desc    View scroll that automatically advances its scroll offset each step.
/// @returns {Struct.WWViewScrollAuto}
#endregion
function WWViewScrollAuto() : WWViewScroll() constructor {
	debug_name = "WWViewScrollAuto";

	#region Public

		#region Builder Functions

			#region jsDoc
			/// @func    set_scroll_speeds()
			/// @desc    Sets the automatic scroll speed in pixels per step.
			/// @self    WWViewScrollAuto
			/// @param   {Real} _hspeed : Horizontal speed.
			/// @param   {Real} _vspeed : Vertical speed.
			/// @returns {Struct.WWViewScrollAuto}
			#endregion
			static set_scroll_speeds = function(_hspeed=0, _vspeed=0) {
				auto_speed_x = _hspeed;
				auto_speed_y = _vspeed;

				auto_orig_speed_x = auto_speed_x;
				auto_orig_speed_y = auto_speed_y;

				return self;
			};

			#region jsDoc
			/// @func    set_scroll_looping()
			/// @desc    Enables or disables looping for each axis.
			/// @self    WWViewScrollAuto
			/// @param   {Bool} _x_loop : True to wrap horizontally.
			/// @param   {Bool} _y_loop : True to wrap vertically.
			/// @returns {Struct.WWViewScrollAuto}
			#endregion
			static set_scroll_looping = function(_x_loop=false, _y_loop=false) {
				auto_loop_x = _x_loop;
				auto_loop_y = _y_loop;

				return self;
			};

			#region jsDoc
			/// @func    set_scroll_pause()
			/// @desc    Pauses or resumes automatic scrolling.
			/// @self    WWViewScrollAuto
			/// @param   {Bool} _paused : True to pause.
			/// @returns {Struct.WWViewScrollAuto}
			#endregion
			static set_scroll_pause = function(_paused=true) {
				auto_paused = _paused;
				return self;
			};

			#region jsDoc
			/// @func    set_scroll_offsets()
			/// @desc    Sets the current scroll offsets in pixels.
			/// @self    WWViewScrollAuto
			/// @param   {Real} _xoff : Horizontal scroll offset.
			/// @param   {Real} _yoff : Vertical scroll offset.
			/// @returns {Struct.WWViewScrollAuto}
			#endregion
			static set_scroll_offsets = function(_xoff=0, _yoff=0) {
				set_scroll_offset(_xoff, _yoff);

				auto_orig_x_off = scroll_x;
				auto_orig_y_off = scroll_y;

				return self;
			};

		#endregion

		#region Variables

			auto_speed_x = 0;
			auto_speed_y = 0;

			auto_loop_x = true;
			auto_loop_y = true;

			auto_paused = false;

			auto_orig_x_off = 0;
			auto_orig_y_off = 0;

			auto_orig_speed_x = 0;
			auto_orig_speed_y = 0;

		#endregion

		#region Events

			on_pre_step(function(_input) {
				__auto_step__(_input);
			});

		#endregion

		#region Functions

			#region jsDoc
			/// @func    reset_scrolling()
			/// @desc    Resets scroll offsets and speeds back to their original values.
			/// @self    WWViewScrollAuto
			/// @returns {Undefined}
			#endregion
			static reset_scrolling = function() {
				set_scroll_offset(auto_orig_x_off, auto_orig_y_off);
				auto_speed_x = auto_orig_speed_x;
				auto_speed_y = auto_orig_speed_y;
			};

			#region jsDoc
			/// @func    get_scroll_offsets()
			/// @desc    Returns the current scroll offsets in pixels.
			/// @self    WWViewScrollAuto
			/// @returns {Struct} offset_struct_with_x_y
			#endregion
			static get_scroll_offsets = function() {
				return { x: scroll_x, y: scroll_y };
			};

			#region jsDoc
			/// @func    get_scroll_speeds()
			/// @desc    Returns the current automatic scroll speeds in pixels per step.
			/// @self    WWViewScrollAuto
			/// @returns {Struct} speed_struct_with_x_y
			#endregion
			static get_scroll_speeds = function() {
				return { x: auto_speed_x, y: auto_speed_y };
			};

			#region jsDoc
			/// @func    get_scroll_looping()
			/// @desc    Returns whether looping is enabled for each axis.
			/// @self    WWViewScrollAuto
			/// @returns {Struct} loop_struct_with_x_y
			#endregion
			static get_scroll_looping = function() {
				return { x: auto_loop_x, y: auto_loop_y };
			};

			#region jsDoc
			/// @func    get_scroll_pause()
			/// @desc    Returns whether automatic scrolling is paused.
			/// @self    WWViewScrollAuto
			/// @returns {Bool} paused
			#endregion
			static get_scroll_pause = function() {
				return auto_paused;
			};

		#endregion

	#endregion

	#region Private

		#region Functions

			#region jsDoc
			/// @func    __auto_step__()
			/// @desc    Advances the scroll offsets according to speed and looping settings.
			/// @param   {Struct} _input : Input state (unused here).
			/// @returns {Undefined}
			///@ignore
			#endregion
			static __auto_step__ = function(_input) {
				if (auto_paused) { return; }
				if (canvas == undefined) { return; }

				__sync_content_size__();

				var _max_x = content_width - width;
				var _max_y = content_height - height;

				if (_max_x < 0) { _max_x = 0; }
				if (_max_y < 0) { _max_y = 0; }

				var _new_x = scroll_x + auto_speed_x;
				var _new_y = scroll_y + auto_speed_y;

				if (auto_loop_x) {
					_new_x = __wrap_scroll_axis__(_new_x, _max_x);
				}

				if (auto_loop_y) {
					_new_y = __wrap_scroll_axis__(_new_y, _max_y);
				}

				set_scroll_offset(_new_x, _new_y);
			};

			#region jsDoc
			/// @func    __wrap_scroll_axis__()
			/// @desc    Wraps a scroll value into the range [0.._max] when looping is enabled.
			/// @param   {Real} _value : Scroll value to wrap.
			/// @param   {Real} _max : Maximum scroll value.
			/// @returns {Real} wrapped_value
			///@ignore
			#endregion
			static __wrap_scroll_axis__ = function(_value, _max) {
				if (_max <= 0) { return 0; }

				var _range = _max + 1;
				var _modu = _value mod _range;

				if (_modu < 0) { _modu += _range; }

				return _modu;
			};

		#endregion

	#endregion

}
