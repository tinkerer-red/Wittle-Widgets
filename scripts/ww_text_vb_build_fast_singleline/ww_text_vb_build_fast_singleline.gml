#region jsDoc
/// @func    ww_text_vb_build_fast_singleline(_text, _font, _color, _alpha)
/// @desc    Fast-pass single-line text bake into a vertex buffer, with:
///          - SDF/MSDF support (MSDF implies SDF enabled)
///          - font_size:<n> asset tag prescale (atlas is n times larger -> render at 1/n scale)
///          - renderer-style integer snapping for readability (floor x/y and floor w/h)
///          - renderer-style UVs using texel size
/// @param   {String} _text Single line text.
/// @param   {Asset.GMFont} _font Font asset.
/// @param   {Real} [_color] Vertex tint color (default c_white).
/// @param   {Real} [_alpha] Vertex alpha (default 1).
/// @returns {Struct} Bundle:
///          { vb, tex, format, width, height, baseline, shader, spread, sdf_enabled, msdf_enabled, size_mul }
#endregion
function ww_text_vb_build_fast_singleline(_text, _font, _color = c_white, _alpha = 1) {
	static __format__ = -1;

	if (__format__ == -1) {
		vertex_format_begin();
		vertex_format_add_position();
		vertex_format_add_texcoord();
		vertex_format_add_colour();
		__format__ = vertex_format_end();
	}

	var _info = font_get_info(_font);
	if (is_undefined(_info)) {
		return {
			vb: -1,
			tex: -1,
			format: __format__,
			width: 0,
			height: 0,
			baseline: 0,
			shader: -1,
			spread: 0,
			sdf_enabled: false,
			msdf_enabled: false,
			size_mul: 1
		};
	}

	if (_info.spriteIndex != -1) {
		throw "ww_text_vb_build_fast_singleline does not support sprite fonts";
	}

	// font_size:<n> prescale
	var _size_mul_default = 1;
	var _tags = asset_get_tags(_font);
	var _tagi = 0;
	repeat (array_length(_tags)) {
		var _tag_text = _tags[_tagi];
		_tagi += 1;

		if (string_pos("font_size:", _tag_text) == 1) {
			var _value_text = string_delete(_tag_text, 1, 10);
			var _valu4 = real(_value_text);
			if (_valu4 > 0) {
				_size_mul_default = 1 / _valu4;
			}
			break;
		}
	}

	var _sdf_enabled = (_info.sdfEnabled == true);
	var _msdf_enabled = false;
	var _spread = 0;
	var _shader = -1;

	if (_sdf_enabled) {
		_msdf_enabled = asset_has_any_tag(_font, "msdf");
		_spread = _info.sdfSpread;
		_shader = shd_ww_msdf;
	}

	var _tex = font_get_texture(_font);
	var _texel_w = texture_get_texel_width(_tex);
	var _texel_h = texture_get_texel_height(_tex);

	var _vbuu = vertex_create_buffer();
	vertex_begin(_vbuu, __format__);

	var _len4 = string_length(_text);

	var _penx = 0;
	var _miny = 0;
	var _maxx = 0;
	var _maxy = 0;

	// Renderer-style snap on baseline too
	var _base = floor(_info.ascenderOffset * _size_mul_default);

	// Renderer-style SDF padding shifts offsets (does not change w/h)
	var _padding = 0;
	if (_sdf_enabled) {
		_padding = _info.sdfSpread * _size_mul_default;
	}

	var _indx = 1;
	while (_indx <= _len4) {
		var _char = string_char_at(_text, _indx);
		_indx += 1;

		var _glyf = _info.glyphs[$ _char];
		if (is_undefined(_glyf)) {
			_penx += (_info.size * 0.5) * _size_mul_default;
			continue;
		}

		var _gx = _glyf.x;
		var _gy = _glyf.y;
		var _gw = _glyf.w;
		var _gh = _glyf.h;

		if (_gx < 0 || _gy < 0 || _gw <= 0 || _gh <= 0) {
			font_cache_glyph(_font, _glyf.char);

			_glyf = _info.glyphs[$ _char];
			_gx = _glyf.x;
			_gy = _glyf.y;
			_gw = _glyf.w;
			_gh = _glyf.h;

			if (_gx < 0 || _gy < 0 || _gw <= 0 || _gh <= 0) {
				_penx += _glyf.shift * _size_mul_default;
				continue;
			}
		}

		var _xoff = (_glyf.offset * _size_mul_default) - _padding;
		var _yoff = (_glyf.yoffset * _size_mul_default) - _padding;

		var _w_f = _gw * _size_mul_default;
		var _h_f = _gh * _size_mul_default;

		// Integer snapping (readability)
		var _x0 = floor(_penx + _xoff);
		var _y0 = floor(_base + _yoff);

		var _w_i = floor(_w_f);
		var _h_i = floor(_h_f);

		var _x1 = _x0 + _w_i;
		var _y1 = _y0 + _h_i;

		var _u0 = _gx * _texel_w;
		var _v0 = _gy * _texel_h;
		var _u1 = (_gx + _gw) * _texel_w;
		var _v1 = (_gy + _gh) * _texel_h;

		vertex_position(_vbuu, _x0, _y0);
		vertex_texcoord(_vbuu, _u0, _v0);
		vertex_colour(_vbuu, _color, _alpha);

		vertex_position(_vbuu, _x1, _y0);
		vertex_texcoord(_vbuu, _u1, _v0);
		vertex_colour(_vbuu, _color, _alpha);

		vertex_position(_vbuu, _x1, _y1);
		vertex_texcoord(_vbuu, _u1, _v1);
		vertex_colour(_vbuu, _color, _alpha);

		vertex_position(_vbuu, _x0, _y0);
		vertex_texcoord(_vbuu, _u0, _v0);
		vertex_colour(_vbuu, _color, _alpha);

		vertex_position(_vbuu, _x1, _y1);
		vertex_texcoord(_vbuu, _u1, _v1);
		vertex_colour(_vbuu, _color, _alpha);

		vertex_position(_vbuu, _x0, _y1);
		vertex_texcoord(_vbuu, _u0, _v1);
		vertex_colour(_vbuu, _color, _alpha);

		if (_y0 < _miny) { _miny = _y0; }
		if (_x1 > _maxx) { _maxx = _x1; }
		if (_y1 > _maxy) { _maxy = _y1; }

		_penx += _glyf.shift * _size_mul_default;
	}

	vertex_end(_vbuu);

	return {
		vb: _vbuu,
		tex: _tex,
		format: __format__,
		width: _maxx,
		height: (_maxy - _miny),
		baseline: _base,
		shader: _shader,
		spread: _spread,
		sdf_enabled: _sdf_enabled,
		msdf_enabled: _msdf_enabled,
		size_mul: _size_mul_default
	};
}