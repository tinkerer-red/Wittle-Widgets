#region jsDoc
/// @func    WWProgressBarVert()
/// @desc    Vertical progress bar with a normalized value range of 0..1.
/// @returns {Struct.WWProgressBarVert}
#endregion
function WWProgressBarVert() : WWSliderVert() constructor {

	debug_name = "WWProgressBarVert";

	#region Public

		#region Builder Functions

			set_focusable(false);
			set_clamp_values(0, 1);
			set_value(0);

		#endregion

	#endregion

}
