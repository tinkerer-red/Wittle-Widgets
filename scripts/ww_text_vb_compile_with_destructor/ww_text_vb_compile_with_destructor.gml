#region jsDoc
/// @func    ww_text_vb_compile_with_destructor(_owner, _text, _font, _color, _alpha)
/// @desc    Builds a fast single-line VB bundle (SDF/MSDF + font_size tag supported),
///          wraps it in WW_Destructor, then binds a draw method that selects the correct draw path.
/// @param   {Any} _owner Owner reference to keep alive.
/// @param   {String} _text Text to bake.
/// @param   {Asset.GMFont} _font Font asset.
/// @param   {Real} [_color] Color.
/// @param   {Real} [_alpha] Alpha 0..1.
/// @returns {Struct} Wrapper with fields: value, destroy, owner, draw
#endregion
function ww_text_vb_compile_with_destructor(_owner, _text, _font, _color = c_white, _alpha = 1) {
	var _bundle = ww_text_vb_build_fast_singleline(_text, _font, _color, _alpha);

	static _destroy = function(_vb) {
		vertex_delete_buffer(_vb);
	};

	var _wrap = WW_Destructor(_bundle.vb, _destroy);
	_wrap.owner = _owner;
	_wrap.bundle = _bundle;
	
	// Draw method:
	// - If SDF enabled, uses the shared SDF shader (MSDF is still routed here).
	// - Otherwise, submits normally.
	_wrap.draw = method(_wrap, function(_x, _y, _scale = 1) {
		var _valu4 = bundle;
		if (is_undefined(_valu4)) { return; }
		if (_valu4.vb == -1) { return; }

		matrix_set(matrix_world, matrix_build(_x, _y, 0, 0, 0, 0, _scale, _scale, 1));

		if (_valu4.sdf_enabled) {
			shader_set(_valu4.shader);

			// If your unified SDF/MSDF shader needs uniforms (spread, msdf toggle),
			// wire them here to match your shader contract.
			// This fast path mirrors the renderer behavior: shader_set -> submit -> reset.

			vertex_submit(_valu4.vb, pr_trianglelist, _valu4.tex);
			shader_reset();
		} else {
			vertex_submit(_valu4.vb, pr_trianglelist, _valu4.tex);
		}
		
		matrix_set(matrix_world, matrix_build_identity());
	});

	return _wrap;
}