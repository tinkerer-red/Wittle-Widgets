// This function follows the standards of msdf fonts set by Juju Adams with his library found here:
// https://github.com/JujuAdams/Msdf/releases/tag/1.0.0

function font_get_msdf_enabled(ind) {
	static __tags = ["msdf", "MSDF"];
	if (font_get_sdf_enabled(ind)) {
		return asset_has_any_tag(ind, __tags, asset_font);
	}
	
	return false;
}