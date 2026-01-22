#region jsDoc
/// @func    WWViewScrollAutoHorz()
/// @desc    Auto-scrolling view that loops right by 1 pixel per step.
/// @returns {Struct.WWViewScrollAutoHorz}
#endregion
function WWViewScrollAutoHorz() : WWViewScrollAuto() constructor {

	debug_name = "WWViewScrollAutoHorz";

	#region Public

		#region Builder Functions

			set_scroll_speeds(1, 0);
			set_scroll_looping(true, false);
			set_scroll_pause(false);
			set_scroll_offsets(0, 0);

		#endregion

	#endregion

}
