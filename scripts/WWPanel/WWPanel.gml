#region jsDoc
/// @func    WWPanel()
/// @desc    General-purpose themed panel for grouping content.
///          Typical use: section blocks, settings groups, and card-like areas.
///          Theme values are compiled by `wwThemeBuild`:
///          - `panel.color.main.*` from surface/control paints
///          - `panel.color.border.*` from outline/accent paints
/// @returns {Struct.WWPanel}
#endregion
function WWPanel() : WWCanvas() constructor {
	debug_name = "WWPanel";
	set_theme_role("panel");
	__draw_border__ = true;
}
