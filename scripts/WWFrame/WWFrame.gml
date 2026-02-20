#region jsDoc
/// @func    WWFrame()
/// @desc    Structural frame surface used to outline or contain a major UI section.
///          Typical use: window shells, group boundaries, and framed panels.
///          Theme values are compiled by `wwThemeBuild`:
///          - `frame.color.main.*` from surface paints
///          - `frame.color.border.*` from outline/accent paints
/// @returns {Struct.WWFrame}
#endregion
function WWFrame() : WWCanvas() constructor {
	debug_name = "WWFrame";
	set_theme_role("frame");
	__draw_border__ = true;
}
