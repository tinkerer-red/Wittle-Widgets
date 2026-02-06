#region jsDoc
/// @func    fa_get_ord()
/// @desc    Extracts the unicode codepoint (ord value) from packed FA glyph data.
/// @param   {Real} _packed_fa_data
/// @returns {Real} unicode_codepoint
#endregion
function fa_get_ord(_packed_fa_data) {
	return _packed_fa_data & 0xFFFF;
}
