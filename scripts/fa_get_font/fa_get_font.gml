#region jsDoc
/// @func    fa_get_font()
/// @desc    Extracts the Font Awesome font asset id from packed FA glyph data.
/// @param   {Real} _packed_fa_data
/// @returns {Font} font_asset_id_or_minus_one
#endregion
function fa_get_font(_packed_fa_data) {
	var _font_id = (_packed_fa_data >> 16);

	if (_font_id == 1) { return fnt_fa_regular; }
	if (_font_id == 2) { return fnt_fa_solid; }
	if (_font_id == 3) { return fnt_fa_brands; }

	return -1;
}
