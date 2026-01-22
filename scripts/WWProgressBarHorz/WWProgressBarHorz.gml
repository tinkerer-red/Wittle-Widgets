#region jsDoc
/// @func    WWProgressBarHorz()
/// @desc    Horizontal progress bar with a normalized value range of 0..1.
/// @returns {Struct.WWProgressBarHorz}
#endregion
function WWProgressBarHorz() : WWSliderHorz() constructor {

	debug_name = "WWProgressBarHorz";

	#region Public

		#region Builder Functions

			set_focusable(false);
			set_clamp_values(0, 1);
			set_value(0);

		#endregion

	#endregion

}
