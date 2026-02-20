#region jsDoc
/// @func    WWInset()
/// @desc    Recessed inner surface for nested content zones.
///          Typical use: content wells, inner gutters, or grouped controls.
///          Theme values are compiled by `wwThemeBuild`:
///          - `inset.color.main.*` from control/surface-alt paints
///          - `inset.color.border.*` from outline/accent paints
/// @returns {Struct.WWInset}
#endregion
function WWInset() : WWCanvas() constructor {
	debug_name = "WWInset";
	set_theme_role("inset");
	__draw_border__ = true;
}
