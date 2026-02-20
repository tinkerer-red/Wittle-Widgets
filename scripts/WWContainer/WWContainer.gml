#region jsDoc
/// @func    WWContainer()
/// @desc    Neutral content wrapper used for grouped controls and layout blocks.
///          Typical use: rows, columns, and utility grouping zones.
///          Theme values are compiled by `wwThemeBuild`:
///          - `container.color.main.*` from control paints
///          - `container.color.border.*` from subtle outline/accent paints
/// @returns {Struct.WWContainer}
#endregion
function WWContainer() : WWCanvas() constructor {
	debug_name = "WWContainer";
	set_theme_role("container");
	__draw_border__ = false;
}
