#region jsDoc
/// @func    WWViewScrollAutoVert()
/// @desc    Auto-scrolling view that loops down by 1 pixel per step.
/// @returns {Struct.WWViewScrollAutoVert}
#endregion
function WWViewScrollAutoVert() : WWViewScrollAuto() constructor {

	debug_name = "WWViewScrollAutoVert";

	#region Public

		#region Builder Functions

			set_scroll_speeds(0, 1);
			set_scroll_looping(false, true);
			set_scroll_pause(false);
			set_scroll_offsets(0, 0);

		#endregion

	#endregion

}
