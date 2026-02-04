#region jsDoc
/// @func    WWInputString()
/// @desc    String input preset based on WWTextInputSingleLine.
///          Defaults:
///          - Height 24
///          - No extra chrome (plain single-line input)
/// @returns {Struct.WWInputString}
#endregion
function WWInputString() : WWTextInputSingleLine() constructor {
	debug_name = "WWInputString";

	// Default sizing: small and inspector-friendly.
	set_size(160, 22);

	// Report stable extents to layout parents.
	static get_group_width = function() { return width; };
	static get_group_height = function() { return height; };
}
