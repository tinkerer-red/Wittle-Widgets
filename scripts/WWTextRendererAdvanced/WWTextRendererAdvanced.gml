/*
#region jsDoc
/// @func    WWTextRendererAdvanced()
/// @desc    Advanced renderer extending Core. Adds:
///          - Per-glyph formatting via set_format_range
///          - Whitespace visualization markers
///          - Underlines (line / warning / error) via sprites in layer 0
///          - Per-glyph font resolution (override, base font, fallbacks)
///          - Decorator pipeline (Scribble/BBCode/Markdown/GML)
/// @returns {Struct.WWTextRendererAdvanced}
#endregion
function WWTextRendererAdvanced() : WWTextRendererCore() constructor {
    debug_name = "WWTextRendererAdvanced";

    #region Public
		
        #region Whitespace visibility

            whitespace_visible = false;
            whitespace_color = c_gray;
            whitespace_alpha = 0.35;
            whitespace_marker_space = ".";
            whitespace_marker_tab = ">";

			#region jsDoc
			/// @func    set_whitespace_visible()
			/// @desc    Enables or disables whitespace marker visualization.
			/// @self    WWTextRendererAdvanced
			/// @param   {Bool} is_visible
			/// @returns {Struct.WWTextRendererAdvanced}
			#endregion
            static set_whitespace_visible = function(_is_visible) {
                if (whitespace_visible == _is_visible) {
                    return self;
                }
                whitespace_visible = _is_visible;
                __mark_vb_dirty__();
                return self;
            };

			#region jsDoc
			/// @func    set_whitespace_color()
			/// @desc    Sets the marker color used for visible whitespace.
			/// @self    WWTextRendererAdvanced
			/// @param   {Constant.Color} color_value
			/// @returns {Struct.WWTextRendererAdvanced}
			#endregion
            static set_whitespace_color = function(_color_value) {
                if (whitespace_color == _color_value) {
                    return self;
                }
                whitespace_color = _color_value;
                __mark_vb_dirty__();
                return self;
            };

			#region jsDoc
			/// @func    set_whitespace_alpha()
			/// @desc    Sets the marker alpha used for visible whitespace.
			/// @self    WWTextRendererAdvanced
			/// @param   {Real} alpha_value
			/// @returns {Struct.WWTextRendererAdvanced}
			#endregion
            static set_whitespace_alpha = function(_alpha_value) {
                if (whitespace_alpha == _alpha_value) {
                    return self;
                }
                whitespace_alpha = _alpha_value;
                __mark_vb_dirty__();
                return self;
            };

        #endregion

        #region Formatting API

            #region jsDoc
            /// @func   set_format_range()
            /// @desc   Applies formatting directly into glyph records for the logical index range.
            ///         Range is [start_index, end_index).
            ///         Pass undefined for any field you do not want to change.
			/// @self   WWTextRendererAdvanced
			/// @param  {Real} start_index
			/// @param  {Real} end_index
			/// @param  {Constant.Color|Undefined} color_value
			/// @param  {Real|Undefined} alpha_value
			/// @param  {Asset.GMFont|Real|Undefined} font_asset_or_minus1
			/// @param  {Real|Undefined} style
			/// @param  {Real|Undefined} size_mul
			/// @param  {Real|Undefined} underline_value
            /// @returns {Struct.WWTextRendererAdvanced}
            #endregion
            static set_format_range = function(
                _start_index,
                _end_index,
                _color_value,
                _alpha_value,
                _font_asset_or_minus1,
                _style,
                _size_mul,
                _underline_value
            ) {
                __ensure_layout__();

                if (_end_index <= _start_index) {
                    return self;
                }

                var _layout_data = __layout__.get_layout_data();
                var _glyphs = _layout_data.glyphs;
                var _glyph_count = _layout_data.glyphs_count;

                if (_glyph_count <= 0) {
                    return self;
                }

                if (_start_index < 0) { _start_index = 0; }

                var _base = 0;
                var _glyph_index = 0;

                repeat (_glyph_count) {

                    var _logical_index = _glyphs[_base + __WW_Layout_Glyph.Index];

                    if (_logical_index >= _end_index) {
                        break;
                    }

                    if (_logical_index >= _start_index) {

                        if (!is_undefined(_color_value)) {
                            _glyphs[_base + __WW_Layout_Glyph.Color] = _color_value;
                        }

                        if (!is_undefined(_alpha_value)) {
                            _glyphs[_base + __WW_Layout_Glyph.Alpha] = _alpha_value;
                        }

                        if (!is_undefined(_font_asset_or_minus1)) {
                            _glyphs[_base + __WW_Layout_Glyph.Font] = _font_asset_or_minus1;
                        }

                        if (!is_undefined(_style)) {
                            _glyphs[_base + __WW_Layout_Glyph.Style] = _style;
                        }

                        if (!is_undefined(_size_mul)) {
                            var _size_val = _size_mul;
                            if (_size_val <= 0) { _size_val = 1; }
                            _glyphs[_base + __WW_Layout_Glyph.Size_Mul] = _size_val;
                        }

                        if (!is_undefined(_underline_value)) {
                            _glyphs[_base + __WW_Layout_Glyph.Underline] = _underline_value;
                        }
                    }

                    _base += __WW_Layout_Glyph.__Size__;
                    _glyph_index++;
                }

                __mark_vb_dirty__();
                return self;
            };

			#region jsDoc
			/// @func    clear_format_range()
			/// @desc    Clears formatting for the logical index range by restoring base renderer settings.
			/// @self    WWTextRendererAdvanced
			/// @param   {Real} start_index
			/// @param   {Real} end_index
			/// @returns {Struct.WWTextRendererAdvanced}
			#endregion
            static clear_format_range = function(_start_index, _end_index) {
                return set_format_range(
                    _start_index,
                    _end_index,
                    color,
                    alpha,
                    -1,
                    __WW_Text_Glyph_Style.Regular,
                    1,
                    __WW_Text_Glyph_Underline.None
                );
            };

        #endregion

    #endregion

    #region Private

        // Underline sprites
        underline_sprite_white = spr_ww_pixel;
        underline_sprite_warning = spr_ww_underline_warning;
        underline_sprite_error = spr_ww_underline_error;

        // Underline tuning
        underline_thickness = 1;
        underline_y_offset = -1;
		
        #region VB emit styled glyph

			#region jsDoc
			/// @func    __vb_emit_glyph_styled_to_buffer__()
			/// @desc    Emits a styled glyph quad into the given vertex buffer.
			/// @self    WWTextRendererAdvanced
			/// @param   {Id.VertexBuffer} vb_buffer
			/// @param   {Struct} font_data
			/// @param   {String} char
			/// @param   {Real} pos_x
			/// @param   {Real} pos_y
			/// @param   {Constant.Color} col
			/// @param   {Real} alp
			/// @param   {Real} size_mul
			/// @param   {Real} style
			/// @returns {Bool}
			/// @ignore
			#endregion
            static __vb_emit_glyph_styled_to_buffer__ = function(_vb_buffer, _font_data, _char, _pos_x, _pos_y, _col, _alp, _size_mul, _style) {

                if (_char == "" || is_undefined(_font_data)) {
                    return false;
                }

                if (_size_mul <= 0) {
                    return false;
                }

                var _glyph_info = _font_data.info.glyphs[$ _char];
                if (is_undefined(_glyph_info)) {
                    return false;
                }

                var _gx = _glyph_info.x;
                var _gy = _glyph_info.y;
                var _gw = _glyph_info.w;
                var _gh = _glyph_info.h;

                if (_gx < 0 || _gy < 0 || _gw <= 0 || _gh <= 0) {
                    return false;
                }

                var _uv_w = texture_get_texel_width(_font_data.tex);
                var _uv_h = texture_get_texel_height(_font_data.tex);

                var _u0 = _gx * _uv_w;
                var _v0 = _gy * _uv_h;
                var _u1 = (_gx + _gw) * _uv_w;
                var _v1 = (_gy + _gh) * _uv_h;

                var _xoff = _glyph_info.offset * _size_mul;
                var _yoff = _glyph_info.yoffset * _size_mul;

                var _w = _gw * _size_mul;
                var _h = _gh * _size_mul;

                var _x0 = _pos_x + _xoff;
                var _x1 = _x0 + _w;
                var _y0 = floor(_pos_y + _yoff);
                var _y1 = floor(_y0 + _h);

                var _italic = ((_style == __WW_Text_Glyph_Style.Italic) || (_style == __WW_Text_Glyph_Style.Bold_Italic));

                var _slant_top = 0;
                var _slant_bottom = 0;

                if (_italic) {
                    _slant_top = 2 * _size_mul;
                    _slant_bottom = -1 * _size_mul;
                }

                vertex_position(_vb_buffer, floor(_x0 + _slant_top), _y0);
                vertex_texcoord(_vb_buffer, _u0, _v0);
                vertex_colour(_vb_buffer, _col, _alp);

                vertex_position(_vb_buffer, floor(_x1 + _slant_top), _y0);
                vertex_texcoord(_vb_buffer, _u1, _v0);
                vertex_colour(_vb_buffer, _col, _alp);

                vertex_position(_vb_buffer, floor(_x1 + _slant_bottom), _y1);
                vertex_texcoord(_vb_buffer, _u1, _v1);
                vertex_colour(_vb_buffer, _col, _alp);

                vertex_position(_vb_buffer, floor(_x0 + _slant_top), _y0);
                vertex_texcoord(_vb_buffer, _u0, _v0);
                vertex_colour(_vb_buffer, _col, _alp);

                vertex_position(_vb_buffer, floor(_x1 + _slant_bottom), _y1);
                vertex_texcoord(_vb_buffer, _u1, _v1);
                vertex_colour(_vb_buffer, _col, _alp);

                vertex_position(_vb_buffer, floor(_x0 + _slant_bottom), _y1);
                vertex_texcoord(_vb_buffer, _u0, _v1);
                vertex_colour(_vb_buffer, _col, _alp);

                var _bold = ((_style == __WW_Text_Glyph_Style.Bold) || (_style == __WW_Text_Glyph_Style.Bold_Italic));

                if (_bold) {
					var _bold_offset =  1 * _size_mul;
					
                    vertex_position(_vb_buffer, floor(_x0 + _slant_top + _bold_offset), floor(_y0 - _bold_offset));
                    vertex_texcoord(_vb_buffer, _u0, _v0);
                    vertex_colour(_vb_buffer, _col, _alp);

                    vertex_position(_vb_buffer, floor(_x1 + _slant_top + _bold_offset), floor(_y0 - _bold_offset));
                    vertex_texcoord(_vb_buffer, _u1, _v0);
                    vertex_colour(_vb_buffer, _col, _alp);

                    vertex_position(_vb_buffer, floor(_x1 + _slant_bottom + _bold_offset), floor(_y1 - _bold_offset));
                    vertex_texcoord(_vb_buffer, _u1, _v1);
                    vertex_colour(_vb_buffer, _col, _alp);

                    vertex_position(_vb_buffer, floor(_x0 + _slant_top + _bold_offset), floor(_y0 - _bold_offset));
                    vertex_texcoord(_vb_buffer, _u0, _v0);
                    vertex_colour(_vb_buffer, _col, _alp);

                    vertex_position(_vb_buffer, floor(_x1 + _slant_bottom + _bold_offset), floor(_y1 - _bold_offset));
                    vertex_texcoord(_vb_buffer, _u1, _v1);
                    vertex_colour(_vb_buffer, _col, _alp);

                    vertex_position(_vb_buffer, floor(_x0 + _slant_bottom + _bold_offset), floor(_y1 - _bold_offset));
                    vertex_texcoord(_vb_buffer, _u0, _v1);
                    vertex_colour(_vb_buffer, _col, _alp);
                }

                return true;
            };

        #endregion

        #region Underline flush span

			#region jsDoc
			/// @func    __ul_flush_span__()
			/// @desc    Flushes the active underline span into the underline vertex batch.
			/// @self    WWTextRendererAdvanced
			/// @param   {Struct} span_state
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __ul_flush_span__ = function(_span_state) {

			    if (!_span_state.active) {
			        return;
			    }

			    if (_span_state.under == __WW_Text_Glyph_Underline.None) {
			        _span_state.active = false;
			        return;
			    }

			    var _width = _span_state.x1 - _span_state.x0;
			    if (_width <= 0) {
			        _span_state.active = false;
			        return;
			    }

			    var _spr = underline_sprite_white;

			    if (_span_state.under == __WW_Text_Glyph_Underline.Warning) {
			        _spr = underline_sprite_warning;
			    } else if (_span_state.under == __WW_Text_Glyph_Underline.Error) {
			        _spr = underline_sprite_error;
			    }

			    var _tex = sprite_get_texture(_spr, 0);
			    var _spr_uvs = sprite_get_uvs(_spr, 0);

			    var _u0 = _spr_uvs[0];
			    var _v0 = _spr_uvs[1];
			    var _u1 = _spr_uvs[2];
			    var _v1 = _spr_uvs[3];

			    var _x0 = floor(_span_state.x0);
			    var _x1 = floor(_span_state.x1);
			    var _y0 = floor(_span_state.y);

			    // Plain underline: one stretched quad, thickness controlled by span_state.thick
			    if (_span_state.under == __WW_Text_Glyph_Underline.Line) {

			        var _thick = _span_state.thick;
			        if (_thick < 1) { _thick = 1; }

			        var _y1 = floor(_y0 + _thick);

			        var _res_plain = __vb_get_batch_for_material__(_tex, _spr_uvs, 0);
			        var _vb_plain = _res_plain.batch.buffer;

			        vertex_position(_vb_plain, _x0, _y0);
			        vertex_texcoord(_vb_plain, _u0, _v0);
			        vertex_colour(_vb_plain, _span_state.col, _span_state.alp);

			        vertex_position(_vb_plain, _x1, _y0);
			        vertex_texcoord(_vb_plain, _u1, _v0);
			        vertex_colour(_vb_plain, _span_state.col, _span_state.alp);

			        vertex_position(_vb_plain, _x1, _y1);
			        vertex_texcoord(_vb_plain, _u1, _v1);
			        vertex_colour(_vb_plain, _span_state.col, _span_state.alp);

			        vertex_position(_vb_plain, _x0, _y0);
			        vertex_texcoord(_vb_plain, _u0, _v0);
			        vertex_colour(_vb_plain, _span_state.col, _span_state.alp);

			        vertex_position(_vb_plain, _x1, _y1);
			        vertex_texcoord(_vb_plain, _u1, _v1);
			        vertex_colour(_vb_plain, _span_state.col, _span_state.alp);

			        vertex_position(_vb_plain, _x0, _y1);
			        vertex_texcoord(_vb_plain, _u0, _v1);
			        vertex_colour(_vb_plain, _span_state.col, _span_state.alp);

			        _span_state.active = false;
			        return;
			    }

			    // Squiggles: tiled sprite
			    var _spr_w = sprite_get_width(_spr);
			    if (_spr_w <= 0) { _spr_w = 1; }

			    var _spr_h = sprite_get_height(_spr);
			    if (_spr_h <= 0) { _spr_h = 1; }

			    var _res = __vb_get_batch_for_material__(_tex, _spr_uvs, 0);
			    var _vb_ul = _res.batch.buffer;

			    var _y1s = floor(_y0 + _spr_h);

			    var _full_count = floor(_width / _spr_w);
			    var _rem_width = ceil(_width - (_full_count * _spr_w));

			    var _tile_index = 0;
			    repeat (_full_count) {

			        var _sx0 = floor(_x0 + (_tile_index * _spr_w));
			        var _sx1 = floor(_sx0 + _spr_w);

			        vertex_position(_vb_ul, _sx0, _y0);
			        vertex_texcoord(_vb_ul, _u0, _v0);
			        vertex_colour(_vb_ul, _span_state.col, _span_state.alp);

			        vertex_position(_vb_ul, _sx1, _y0);
			        vertex_texcoord(_vb_ul, _u1, _v0);
			        vertex_colour(_vb_ul, _span_state.col, _span_state.alp);

			        vertex_position(_vb_ul, _sx1, _y1s);
			        vertex_texcoord(_vb_ul, _u1, _v1);
			        vertex_colour(_vb_ul, _span_state.col, _span_state.alp);

			        vertex_position(_vb_ul, _sx0, _y0);
			        vertex_texcoord(_vb_ul, _u0, _v0);
			        vertex_colour(_vb_ul, _span_state.col, _span_state.alp);

			        vertex_position(_vb_ul, _sx1, _y1s);
			        vertex_texcoord(_vb_ul, _u1, _v1);
			        vertex_colour(_vb_ul, _span_state.col, _span_state.alp);

			        vertex_position(_vb_ul, _sx0, _y1s);
			        vertex_texcoord(_vb_ul, _u0, _v1);
			        vertex_colour(_vb_ul, _span_state.col, _span_state.alp);

			        _tile_index += 1;
			    }

			    if (_rem_width > 0) {

			        var _sx0r = floor(_x0 + (_full_count * _spr_w));
			        var _sx1r = floor(_sx0r + _rem_width);

			        var _tu = (_rem_width / _spr_w);
			        if (_tu < 0) { _tu = 0; }
			        if (_tu > 1) { _tu = 1; }

			        var _u1r = _u0 + ((_u1 - _u0) * _tu);

			        vertex_position(_vb_ul, _sx0r, _y0);
			        vertex_texcoord(_vb_ul, _u0, _v0);
			        vertex_colour(_vb_ul, _span_state.col, _span_state.alp);

			        vertex_position(_vb_ul, _sx1r, _y0);
			        vertex_texcoord(_vb_ul, _u1r, _v0);
			        vertex_colour(_vb_ul, _span_state.col, _span_state.alp);

			        vertex_position(_vb_ul, _sx1r, _y1s);
			        vertex_texcoord(_vb_ul, _u1r, _v1);
			        vertex_colour(_vb_ul, _span_state.col, _span_state.alp);

			        vertex_position(_vb_ul, _sx0r, _y0);
			        vertex_texcoord(_vb_ul, _u0, _v0);
			        vertex_colour(_vb_ul, _span_state.col, _span_state.alp);

			        vertex_position(_vb_ul, _sx1r, _y1s);
			        vertex_texcoord(_vb_ul, _u1r, _v1);
			        vertex_colour(_vb_ul, _span_state.col, _span_state.alp);

			        vertex_position(_vb_ul, _sx0r, _y1s);
			        vertex_texcoord(_vb_ul, _u0, _v1);
			        vertex_colour(_vb_ul, _span_state.col, _span_state.alp);
			    }

			    _span_state.active = false;
			};

        #endregion

        #region VB override (advanced)

			#region jsDoc
			/// @func    __ensure_vb__()
			/// @desc    Rebuilds the cached vertex buffers if they are marked dirty.
			/// @self    WWTextRendererAdvanced
			/// @returns {Undefined}
			/// @ignore
			#endregion
            static __ensure_vb__ = function() {

                if (!__vb_is_dirty__) {
                    return;
                }

                __ensure_layout__();
                __vb_ensure_format__();

                __vb_free__();
                __build_vb__();

                __vb_is_dirty__ = false;
            };

			#region jsDoc
			/// @func    __build_vb__()
			/// @desc    Builds draw batches (glyphs, whitespace markers, underlines) into vertex buffers.
			/// @self    WWTextRendererAdvanced
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __build_vb__ = function() {

			    var _old_font = draw_get_font();
			    if (font_exists(font)) {
			        draw_set_font(font);
			    }

			    var _layout_data = __layout__.get_layout_data();
			    var _glyphs = _layout_data.glyphs;
			    var _glyph_count = _layout_data.glyphs_count;

			    if (_glyph_count <= 0) {
			        if (font_exists(_old_font) && _old_font != draw_get_font()) {
			            draw_set_font(_old_font);
			        }
			        return;
			    }

			    var _default_font_data = __font_get_render_data__(font);
			    if (is_undefined(_default_font_data)) {
			        if (font_exists(_old_font) && _old_font != draw_get_font()) {
			            draw_set_font(_old_font);
			        }
			        return;
			    }

			    var _ws_batch_res = undefined;
			    if (whitespace_visible) {
			        _ws_batch_res = __vb_get_batch_for_material__(_default_font_data.tex, _default_font_data.uvs, 1);
			    }

			    var _span_state = {
			        active: false,
			        under: __WW_Text_Glyph_Underline.None,
			        x0: 0,
			        x1: 0,
			        y: 0,
			        col: color,
			        alp: alpha,
			        thick: 1
			    };

			    var _glyph_index = 0;
			    repeat (_glyph_count) {

			        var _base = _glyph_index * __WW_Layout_Glyph.__Size__;
			        var _char = _glyphs[_base + __WW_Layout_Glyph.Char];

			        if (_char == "\n" || _char == "\r" || _char == "") {
			            __ul_flush_span__(_span_state);
			            _glyph_index += 1;
			            continue;
			        }

			        if (_char == "\t" && !whitespace_visible) {
			            __ul_flush_span__(_span_state);
			            _glyph_index += 1;
			            continue;
			        }

			        var _pos_x = _glyphs[_base + __WW_Layout_Glyph.X];
			        var _pos_y = _glyphs[_base + __WW_Layout_Glyph.Y];
			        var _wid = _glyphs[_base + __WW_Layout_Glyph.Width];
			        var _hei = _glyphs[_base + __WW_Layout_Glyph.Height];

			        if (whitespace_visible) {

			            if (_char == " ") {

			                __ul_flush_span__(_span_state);

			                var _cell_w = _wid;
			                var _mark_char = whitespace_marker_space;
			                var _mark_w = string_width(_mark_char);

			                var _mark_x = _pos_x;
			                if (_cell_w > 0 && _mark_w > 0) {
			                    _mark_x = _pos_x + ((_cell_w - _mark_w) * 0.5);
			                }

			                __vb_emit_glyph_styled_to_buffer__(
			                    _ws_batch_res.batch.buffer,
			                    _default_font_data,
			                    _mark_char,
			                    _mark_x,
			                    _pos_y,
			                    whitespace_color,
			                    whitespace_alpha,
			                    1,
			                    __WW_Text_Glyph_Style.Regular
			                );

			                _glyph_index += 1;
			                continue;
			            }

			            if (_char == "\t") {

			                __ul_flush_span__(_span_state);

			                var _mark_char2 = whitespace_marker_tab;

			                __vb_emit_glyph_styled_to_buffer__(
			                    _ws_batch_res.batch.buffer,
			                    _default_font_data,
			                    _mark_char2,
			                    _pos_x,
			                    _pos_y,
			                    whitespace_color,
			                    whitespace_alpha,
			                    1,
			                    __WW_Text_Glyph_Style.Regular
			                );

			                _glyph_index += 1;
			                continue;
			            }
			        }

			        var _final_color = _glyphs[_base + __WW_Layout_Glyph.Color];
			        var _final_alpha = _glyphs[_base + __WW_Layout_Glyph.Alpha];
			        var _final_font = _glyphs[_base + __WW_Layout_Glyph.Font];
			        var _final_style = _glyphs[_base + __WW_Layout_Glyph.Style];
			        var _final_size = _glyphs[_base + __WW_Layout_Glyph.Size_Mul];
			        var _final_under = _glyphs[_base + __WW_Layout_Glyph.Underline];

			        if (is_undefined(_final_color)) { _final_color = color; }
			        if (is_undefined(_final_alpha)) { _final_alpha = alpha; }
			        if (is_undefined(_final_style)) { _final_style = __WW_Text_Glyph_Style.Regular; }
			        if (is_undefined(_final_size) || _final_size <= 0) { _final_size = 1; }
			        if (is_undefined(_final_under)) { _final_under = __WW_Text_Glyph_Underline.None; }

			        var _font_data = __glyph_resolve_font_data__(_final_font, _char);
			        if (is_undefined(_font_data)) {
			            __ul_flush_span__(_span_state);
			            _glyph_index += 1;
			            continue;
			        }

			        var _glyph_batch = __vb_get_batch_for_material__(_font_data.tex, _font_data.uvs, 1);

			        __vb_emit_glyph_styled_to_buffer__(
			            _glyph_batch.batch.buffer,
			            _font_data,
			            _char,
			            _pos_x,
			            _pos_y,
			            _final_color,
			            _final_alpha,
			            _final_size,
			            _final_style
			        );

			        if (_final_under != __WW_Text_Glyph_Underline.None) {

						var _scale_true = _final_size;
						if (_scale_true <= 0) { _scale_true = 1; }

						var _scale_int = round(_scale_true);
						if (_scale_int < 1) { _scale_int = 1; }

						// Y position uses TRUE scale, so 1.5 stays 1.5
						var _underline_y = _pos_y + (_hei * _scale_true) + underline_y_offset;

						// Thickness uses snapped integer scale for crispness
						var _underline_thick = 1;
						if (underline_thickness > 0) {
						    _underline_thick = round(underline_thickness * _scale_int);
						} else {
						    _underline_thick = round((_hei * 0.08) * _scale_int);
						}
						if (_underline_thick < 1) { _underline_thick = 1; }

						_span_state.y = _underline_y;
						_span_state.thick = _underline_thick;

			            if (!_span_state.active) {

			                _span_state.active = true;
			                _span_state.under = _final_under;
			                _span_state.x0 = _pos_x;
			                _span_state.x1 = _pos_x + _wid;
			                _span_state.y = _underline_y;
			                _span_state.col = _final_color;
			                _span_state.alp = _final_alpha;
			                _span_state.thick = _underline_thick;

			            } else {

			                var _same_type = (_span_state.under == _final_under);
			                var _same_col = (_span_state.col == _final_color);
			                var _same_alp = (_span_state.alp == _final_alpha);
			                var _same_y = (_span_state.y == _underline_y);

			                if (!_same_type || !_same_col || !_same_alp || !_same_y) {

			                    __ul_flush_span__(_span_state);

			                    _span_state.active = true;
			                    _span_state.under = _final_under;
			                    _span_state.x0 = _pos_x;
			                    _span_state.x1 = _pos_x + _wid;
			                    _span_state.y = _underline_y;
			                    _span_state.col = _final_color;
			                    _span_state.alp = _final_alpha;
			                    _span_state.thick = _underline_thick;

			                } else {

			                    _span_state.x1 = _pos_x + _wid;
			                }
			            }

			        } else {

			            __ul_flush_span__(_span_state);
			        }

			        _glyph_index += 1;
			    }

			    __ul_flush_span__(_span_state);

			    var _batch_count = array_length(__draw_batches__);
			    var _batch_index = 0;
			    repeat (_batch_count) {
			        vertex_end(__draw_batches__[_batch_index].buffer);
			        _batch_index += 1;
			    }

			    if (font_exists(_old_font) && _old_font != draw_get_font()) {
			        draw_set_font(_old_font);
			    }
			};

			#region jsDoc
			/// @func    __draw_text_vb__()
			/// @desc    Draws the prepared vertex-buffer batches at the given origin.
			/// @self    WWTextRendererAdvanced
			/// @param   {Real} origin_x
			/// @param   {Real} origin_y
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __draw_text_vb__ = function(_origin_x, _origin_y) {

                __ensure_vb__();

                var _old_mat = matrix_get(matrix_world);
                matrix_set(matrix_world, matrix_build(_origin_x, _origin_y, 0, 0, 0, 0, 1, 1, 1));

                var _old_filt = gpu_get_tex_filter();
                gpu_set_tex_filter(true);

                var _batch_count = array_length(__draw_batches__);
                var _batch_index = 0;

                repeat (_batch_count) {
                    var _batch = __draw_batches__[_batch_index];
                    if (_batch.layer == 0) {
                        _batch.material.draw(_origin_x, _origin_y);
                    }
                    _batch_index++;
                }

                _batch_index = 0;
                repeat (_batch_count) {
                    var _batch2 = __draw_batches__[_batch_index];
                    if (_batch2.layer == 1) {
                        _batch2.material.draw(_origin_x, _origin_y);
                    }
                    _batch_index++;
                }

                matrix_set(matrix_world, _old_mat);
                gpu_set_tex_filter(_old_filt);
            };

        #endregion

    #endregion
}


