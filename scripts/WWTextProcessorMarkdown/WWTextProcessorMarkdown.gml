#region jsDoc
/// @func    WWTextProcessorMarkdown
/// @desc    Markdown processor producing plain text + spans + align runs.
///          Emits plain output text, a span list (state snapshots in output index space),
///          and optional alignment runs (output index space).
/// @param   {String} raw_text
/// @param   {Struct} default_state
/// @returns {Struct} { text, spans, align_runs }
#endregion

#region Markdown helpers (no closures)

function __ww_md_is_digit__(_character) {
    var _codepoint = ord(_character);
    return (_codepoint >= ord("0") && _codepoint <= ord("9"));
}

function __ww_md_is_whitespace__(_character) {
    return (_character == " " || _character == "\t" || _character == "\n" || _character == "\r");
}

function __ww_md_is_alnum__(_character) {

    var _codepoint = ord(_character);

    // 0-9
    if (_codepoint >= 48 && _codepoint <= 57) { return true; }

    // A-Z
    if (_codepoint >= 65 && _codepoint <= 90) { return true; }

    // a-z
    if (_codepoint >= 97 && _codepoint <= 122) { return true; }

    return false;
}

function __ww_md_is_punct__(_character) {
    if (__ww_md_is_whitespace__(_character)) { return false; }
    if (__ww_md_is_alnum__(_character)) { return false; }
    return true;
}

function __ww_md_can_open_emph__(_prev_character, _next_character, _is_underscore) {

    if (_next_character == "") { return false; }
    if (__ww_md_is_whitespace__(_next_character)) { return false; }

    if (__ww_md_is_punct__(_next_character)) {
        if (!(__ww_md_is_whitespace__(_prev_character) || __ww_md_is_punct__(_prev_character) || _prev_character == "")) {
            return false;
        }
    }

    // Underscore rule: do not emphasize within words.
    if (_is_underscore) {
        if (__ww_md_is_alnum__(_prev_character) || __ww_md_is_alnum__(_next_character)) {
            return false;
        }
    }

    return true;
}

function __ww_md_can_close_emph__(_prev_character, _next_character, _is_underscore) {

    if (_prev_character == "") { return false; }
    if (__ww_md_is_whitespace__(_prev_character)) { return false; }

    if (__ww_md_is_punct__(_prev_character)) {
        if (!(__ww_md_is_whitespace__(_next_character) || __ww_md_is_punct__(_next_character) || _next_character == "")) {
            return false;
        }
    }

    // Underscore rule: do not emphasize within words.
    if (_is_underscore) {
        if (__ww_md_is_alnum__(_prev_character) || __ww_md_is_alnum__(_next_character)) {
            return false;
        }
    }

    return true;
}

function __ww_md_count_run__(_text, _pos1, _character) {

    var _text_len = string_length(_text);
    var _index = _pos1;

    while (_index <= _text_len && string_char_at(_text, _index) == _character) {
        _index += 1;
    }

    return (_index - _pos1);
}

function __ww_md_find_char_from__(_text, _character_find, _start_pos1) {

    var _text_len = string_length(_text);

    if (_start_pos1 < 1) { _start_pos1 = 1; }
    if (_start_pos1 > _text_len) { return 0; }

    return string_pos_ext(_character_find, _text, _start_pos1);
}

function __ww_md_starts_with__(_text, _prefix, _pos1) {

    var _need = string_length(_prefix);
    if (_need <= 0) { return true; }

    var _have = string_length(_text);
    if (_pos1 < 1 || _pos1 + _need - 1 > _have) { return false; }

    return (string_copy(_text, _pos1, _need) == _prefix);
}

function __ww_md_find_backtick_closer__(_text, _start_pos1, _tick_count) {

    var _text_len = string_length(_text);
    var _index = _start_pos1;

    while (_index <= _text_len) {

        if (string_char_at(_text, _index) != "`") {
            _index += 1;
            continue;
        }

        var _run_count = __ww_md_count_run__(_text, _index, "`");
        if (_run_count == _tick_count) {
            return _index;
        }

        _index += _run_count;
    }

    return 0;
}

function __ww_md_normalize_style__(_bold_enabled, _italic_enabled) {

    if (_bold_enabled) {
        if (_italic_enabled) {
            return __WW_Text_Glyph_Style.Bold_Italic;
        }
        return __WW_Text_Glyph_Style.Bold;
    }

    if (_italic_enabled) {
        return __WW_Text_Glyph_Style.Italic;
    }

    return __WW_Text_Glyph_Style.Regular;
}

function __ww_md_get_line_end_pos__(_text, _start_pos1) {

    var _text_len = string_length(_text);

    if (_start_pos1 < 1) { _start_pos1 = 1; }
    if (_start_pos1 > _text_len) { return _text_len + 1; }

    var _n = string_pos_ext("\n", _text, _start_pos1);
    var _r = string_pos_ext("\r", _text, _start_pos1);

    if (_n <= 0) {
        if (_r <= 0) { return _text_len + 1; }
        return _r;
    }

    if (_r <= 0) { return _n; }
    return (_n < _r) ? _n : _r;
}

function __ww_md_line_has_pipe__(_line_text) {
    return (string_pos("|", _line_text) > 0);
}

function __ww_md_is_table_separator_line__(_line_text) {

    if (string_pos("|", _line_text) <= 0) { return false; }
    if (string_pos("-", _line_text) <= 0) { return false; }

    var _line_len = string_length(_line_text);
    if (_line_len <= 0) { return false; }

    var _index = 1;
    repeat (_line_len) {

        var _character = string_char_at(_line_text, _index);

        if (_character != "|" && _character != "-" && _character != ":" && _character != " " && _character != "\t") {
            return false;
        }

        _index += 1;
    }

    return true;
}

function __ww_md_split_table_row__(_line_text) {

    var _work = string_trim(_line_text);

    if (string_length(_work) > 0 && string_char_at(_work, 1) == "|") {
        _work = string_delete(_work, 1, 1);
        _work = string_trim(_work);
    }

    var _work_len = string_length(_work);
    if (_work_len > 0 && string_char_at(_work, _work_len) == "|") {
        _work = string_delete(_work, _work_len, 1);
        _work = string_trim(_work);
    }

    var _cells = string_split(_work, "|");

    var _count = array_length(_cells);
    var _index = 0;
    repeat (_count) {
        _cells[_index] = string_trim(_cells[_index]);
        _index += 1;
    }

    return _cells;
}

function __ww_md_table_build_separator_row__(_col_widths) {

    var _col_count = array_length(_col_widths);
    if (_col_count <= 0) { return ""; }

    var _out_text = "|";

    var _col_index = 0;
    repeat (_col_count) {

        var _width_value = _col_widths[_col_index];
        if (_width_value < 3) { _width_value = 3; }

        _out_text += " ";
        _out_text += string_repeat("-", _width_value);
        _out_text += " |";

        _col_index += 1;
    }

    return _out_text;
}

function __ww_md_table_emit_row__(_cells, _col_widths) {

    var _col_count = array_length(_col_widths);
    var _out_text = "|";

    var _col_index = 0;
    repeat (_col_count) {

        var _cell_text = "";
        if (_col_index < array_length(_cells)) {
            _cell_text = _cells[_col_index];
        }

        var _target_width = _col_widths[_col_index];
        var _cell_len = string_length(_cell_text);

        if (_cell_len < _target_width) {
            _cell_text += string_repeat(" ", _target_width - _cell_len);
        }

        _out_text += " ";
        _out_text += _cell_text;
        _out_text += " |";

        _col_index += 1;
    }

    return _out_text;
}

#endregion

function __ww_md_init_input_buff__(_text) {
    static __md_in_buff = buffer_create(0, buffer_grow, 1);

    buffer_seek(__md_in_buff, buffer_seek_start, 0);
    buffer_write(__md_in_buff, buffer_text, _text);
    var _byte_len = buffer_tell(__md_in_buff);
    buffer_write(__md_in_buff, buffer_u64, 0);

    return [ __md_in_buff, _byte_len ];
}

function __ww_md_find_u8__(_buff, _start, _endd, _target_u8) {

    var _pos = _start;
    while (_pos < _endd) {
        if (buffer_peek(_buff, _pos, buffer_u8) == _target_u8) {
            return _pos;
        }
        _pos += 1;
    }

    return -1;
}

function __ww_md_find_line_break_byte__(_buff, _start, _endd) {
    var _pos = _start;
    while (_pos < _endd) {
        var _b = buffer_peek(_buff, _pos, buffer_u8);
        if (_b == 10 || _b == 13) { return _pos; }
        _pos += 1;
    }
    return _endd;
}

function __ww_md_skip_newline_bytes__(_buff, _pos, _endd) {
    if (_pos >= _endd) { return _pos; }
    var _b0 = buffer_peek(_buff, _pos, buffer_u8);
    if (_b0 == 13) { _pos += 1; }
    if (_pos < _endd && buffer_peek(_buff, _pos, buffer_u8) == 10) { _pos += 1; }
    return _pos;
}

function __ww_md_utf8_decode_at__(_buff, _pos, _endd) {

    if (_pos >= _endd) { return [ 0, _pos ]; }

    var _b0 = buffer_peek(_buff, _pos, buffer_u8);
    var _cp = _b0;
    var _next = _pos + 1;

    if ((_b0 & $80) == 0) {
        return [ _cp, _next ];
    }

    // 2-byte: 110xxxxx 10xxxxxx
    if ((_b0 & $E0) == $C0) {
        var _b1 = (_pos + 1 < _endd) ? buffer_peek(_buff, _pos + 1, buffer_u8) : 0;
        _cp = ((_b0 & $1F) << 6) | (_b1 & $3F);
        _next = _pos + 2;
        return [ _cp, _next ];
    }

    // 3-byte: 1110xxxx 10xxxxxx 10xxxxxx
    if ((_b0 & $F0) == $E0) {
        var _b2 = (_pos + 1 < _endd) ? buffer_peek(_buff, _pos + 1, buffer_u8) : 0;
        var _b3 = (_pos + 2 < _endd) ? buffer_peek(_buff, _pos + 2, buffer_u8) : 0;
        _cp = ((_b0 & $0F) << 12) | ((_b2 & $3F) << 6) | (_b3 & $3F);
        _next = _pos + 3;
        return [ _cp, _next ];
    }

    // 4-byte: 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
    if ((_b0 & $F8) == $F0) {
        var _b4 = (_pos + 1 < _endd) ? buffer_peek(_buff, _pos + 1, buffer_u8) : 0;
        var _b5 = (_pos + 2 < _endd) ? buffer_peek(_buff, _pos + 2, buffer_u8) : 0;
        var _b6 = (_pos + 3 < _endd) ? buffer_peek(_buff, _pos + 3, buffer_u8) : 0;
        _cp = ((_b0 & $07) << 18) | ((_b4 & $3F) << 12) | ((_b5 & $3F) << 6) | (_b6 & $3F);
        _next = _pos + 4;
        return [ _cp, _next ];
    }

    // Fallback: treat as single byte
    return [ _cp, _next ];
}

function __ww_md_get_limit_width__(_default_state) {

    var _limit_width = 0;
    if (_default_state != undefined && variable_struct_exists(_default_state, "width")) {
        _limit_width = _default_state.width;
    }

    if (_limit_width <= 0) { _limit_width = 320; }
    return _limit_width;
}

function WWTextProcessorMarkdown__legacy__(_raw_text, _default_state) {

    var _ctx = __ww_textproc_ctx_begin__(_default_state);

    var _align_runs = [];
    var _align_value = __WW_Text_Alignment.Left;
    if (variable_struct_exists(_ctx.state, "align_value")) {
        _align_value = _ctx.state.align_value;
    } else {
        _ctx.state.align_value = _align_value;
    }
    var _align_start = 0;

    if (_raw_text == "" || string_length(_raw_text) <= 0) {
        var _result_empty = __ww_textproc_ctx_finish__(_ctx);
        _result_empty.align_runs = _align_runs;
        return _result_empty;
    }

    // Theme-like defaults (overrideable via _default_state optional fields)
    var _markdown_link_color = c_aqua;
    var _markdown_link_alpha = 1;
    var _markdown_link_underline = __WW_Text_Glyph_Underline.Line;

    var _markdown_quote_color = c_gray;
    var _markdown_quote_alpha = 0.85;

    var _markdown_code_font = fnt_ww_consolas_10;

    var _markdown_hs_size = 0.75;
    var _markdown_h1_size = 2;
    var _markdown_h2_size = 1.5;
    var _markdown_h3_size = 1.25;

    var _markdown_hr_dash_count = 64;

    if (variable_struct_exists(_default_state, "markdown_link_color")) { _markdown_link_color = _default_state.markdown_link_color; }
    if (variable_struct_exists(_default_state, "markdown_link_alpha")) { _markdown_link_alpha = _default_state.markdown_link_alpha; }
    if (variable_struct_exists(_default_state, "markdown_link_underline")) { _markdown_link_underline = _default_state.markdown_link_underline; }

    if (variable_struct_exists(_default_state, "markdown_quote_color")) { _markdown_quote_color = _default_state.markdown_quote_color; }
    if (variable_struct_exists(_default_state, "markdown_quote_alpha")) { _markdown_quote_alpha = _default_state.markdown_quote_alpha; }

    if (variable_struct_exists(_default_state, "markdown_code_font")) { _markdown_code_font = _default_state.markdown_code_font; }

    if (variable_struct_exists(_default_state, "markdown_hs_size")) { _markdown_hs_size = _default_state.markdown_hs_size; }
    if (variable_struct_exists(_default_state, "markdown_h1_size")) { _markdown_h1_size = _default_state.markdown_h1_size; }
    if (variable_struct_exists(_default_state, "markdown_h2_size")) { _markdown_h2_size = _default_state.markdown_h2_size; }
    if (variable_struct_exists(_default_state, "markdown_h3_size")) { _markdown_h3_size = _default_state.markdown_h3_size; }

    if (variable_struct_exists(_default_state, "markdown_hr_dash_count")) { _markdown_hr_dash_count = _default_state.markdown_hr_dash_count; }

    // Inline toggles
    var _bold_enabled = false;
    var _italic_enabled = false;
    var _underline_enabled = false;
    var _strike_enabled = false;

    var _in_code_block = false;

    var _text_len = string_length(_raw_text);
    var _index = 1;

    var _at_line_start = true;

    while (_index <= _text_len) {

        var _character = string_char_at(_raw_text, _index);

        // Line-start block constructs (not inside code block)
        if (_at_line_start) {

            // Table block heuristic: header row with pipes, separator next line
            if (!_in_code_block) {

                var _line_end1 = __ww_md_get_line_end_pos__(_raw_text, _index);
                var _line_text1 = "";

                if (_line_end1 > _index) {
                    _line_text1 = string_copy(_raw_text, _index, _line_end1 - _index);
                }

                var _next_line_start = _line_end1;

                if (_next_line_start <= _text_len) {
                    var _newline_char = string_char_at(_raw_text, _next_line_start);
                    if (_newline_char == "\r") { _next_line_start += 1; }
                    if (_next_line_start <= _text_len && string_char_at(_raw_text, _next_line_start) == "\n") { _next_line_start += 1; }
                }

                if (_next_line_start <= _text_len && __ww_md_line_has_pipe__(_line_text1)) {

                    var _line_end2 = __ww_md_get_line_end_pos__(_raw_text, _next_line_start);
                    var _line_text2 = "";

                    if (_line_end2 > _next_line_start) {
                        _line_text2 = string_copy(_raw_text, _next_line_start, _line_end2 - _next_line_start);
                    }

                    if (__ww_md_is_table_separator_line__(_line_text2)) {

                        // Flush any active span before emitting table
                        __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

                        var _rows = [];
                        var _col_widths = [];

                        // Header
                        var _header_cells = __ww_md_split_table_row__(_line_text1);
                        array_push(_rows, _header_cells);

                        // Ensure widths
                        var _header_count = array_length(_header_cells);
                        var _header_index = 0;
                        repeat (_header_count) {
                            if (_header_index >= array_length(_col_widths)) { array_push(_col_widths, 0); }
                            var _cell_len = string_length(_header_cells[_header_index]);
                            if (_cell_len > _col_widths[_header_index]) { _col_widths[_header_index] = _cell_len; }
                            _header_index += 1;
                        }

                        // Data rows begin after separator line
                        var _scan_pos = _line_end2;

                        if (_scan_pos <= _text_len) {
                            var _newline_char2 = string_char_at(_raw_text, _scan_pos);
                            if (_newline_char2 == "\r") { _scan_pos += 1; }
                            if (_scan_pos <= _text_len && string_char_at(_raw_text, _scan_pos) == "\n") { _scan_pos += 1; }
                        }

                        while (_scan_pos <= _text_len) {

                            var _row_end = __ww_md_get_line_end_pos__(_raw_text, _scan_pos);
                            var _row_text = "";

                            if (_row_end > _scan_pos) {
                                _row_text = string_copy(_raw_text, _scan_pos, _row_end - _scan_pos);
                            }

                            if (string_trim(_row_text) == "") { break; }
                            if (!__ww_md_line_has_pipe__(_row_text)) { break; }
                            if (__ww_md_is_table_separator_line__(_row_text)) { break; }

                            var _row_cells = __ww_md_split_table_row__(_row_text);
                            array_push(_rows, _row_cells);

                            var _row_cell_count = array_length(_row_cells);
                            var _row_cell_index = 0;
                            repeat (_row_cell_count) {
                                if (_row_cell_index >= array_length(_col_widths)) { array_push(_col_widths, 0); }
                                var _row_cell_len = string_length(_row_cells[_row_cell_index]);
                                if (_row_cell_len > _col_widths[_row_cell_index]) { _col_widths[_row_cell_index] = _row_cell_len; }
                                _row_cell_index += 1;
                            }

                            _scan_pos = _row_end;

                            if (_scan_pos <= _text_len) {
                                var _newline_char3 = string_char_at(_raw_text, _scan_pos);
                                if (_newline_char3 == "\r") { _scan_pos += 1; }
                                if (_scan_pos <= _text_len && string_char_at(_raw_text, _scan_pos) == "\n") { _scan_pos += 1; }
                            }
                        }

                        // Apply code-like styling for the table region
                        var _table_prev_state = __ww_textproc_state_clone__(_ctx.state);

                        var _table_patch = { style: __WW_Text_Glyph_Style.Regular, size_mul: 1 };
                        if (_markdown_code_font != -1) { _table_patch.font_asset = _markdown_code_font; }

                        __ww_textproc_ctx_apply_patch__(_ctx, _table_patch);

                        var _row_count = array_length(_rows);
                        if (_row_count > 0) {

                            __ww_textproc_ctx_append_text__(_ctx, __ww_md_table_emit_row__(_rows[0], _col_widths));
                            __ww_textproc_ctx_append_text__(_ctx, "\n");

                            __ww_textproc_ctx_append_text__(_ctx, __ww_md_table_build_separator_row__(_col_widths));
                            __ww_textproc_ctx_append_text__(_ctx, "\n");

                            var _row_index = 1;
                            while (_row_index < _row_count) {
                                __ww_textproc_ctx_append_text__(_ctx, __ww_md_table_emit_row__(_rows[_row_index], _col_widths));
                                __ww_textproc_ctx_append_text__(_ctx, "\n");
                                _row_index += 1;
                            }
                        }

                        // Restore prior state and advance source cursor past the table
                        __ww_textproc_ctx_apply_patch__(_ctx, _table_prev_state);
                        _ctx.span_start = _ctx.out_len;

                        _index = _scan_pos;
                        _at_line_start = true;
                        continue;
                    }
                }
            }

            // Fenced code block toggle
            if (__ww_md_starts_with__(_raw_text, "```", _index)) {

                __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

                _in_code_block = !_in_code_block;

                if (_in_code_block) {

                    _bold_enabled = false;
                    _italic_enabled = false;
                    _underline_enabled = false;
                    _strike_enabled = false;

                    var _enter_patch = {
                        style: __WW_Text_Glyph_Style.Regular,
                        size_mul: 1,
                        underline: __WW_Text_Glyph_Underline.None,
                        strike: __WW_Text_Glyph_Strike.None,
                        back_color: 0,
                        back_alpha: 0
                    };

                    if (_markdown_code_font != -1) { _enter_patch.font_asset = _markdown_code_font; }

                    __ww_textproc_ctx_apply_patch__(_ctx, _enter_patch);

                } else {

                    __ww_textproc_ctx_apply_patch__(_ctx, _default_state);
                }

                _ctx.span_start = _ctx.out_len;

                // Skip the fence line content entirely
                _index += 3;
                while (_index <= _text_len && !(string_char_at(_raw_text, _index) == "\n" || string_char_at(_raw_text, _index) == "\r")) {
                    _index += 1;
                }

                _at_line_start = true;
                continue;
            }

            // Headings at line start (must be followed by space)
            var _is_header_s = __ww_md_starts_with__(_raw_text, "-# ", _index);
            var _is_header_1 = __ww_md_starts_with__(_raw_text, "# ", _index);
            var _is_header_2 = __ww_md_starts_with__(_raw_text, "## ", _index);
            var _is_header_3 = __ww_md_starts_with__(_raw_text, "### ", _index);

            if (!_in_code_block && (_is_header_s || _is_header_1 || _is_header_2 || _is_header_3)) {

                __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

                _bold_enabled = false;
                _italic_enabled = false;

                var _new_size_mul = 1;

                if (_is_header_3) { _new_size_mul = _markdown_h3_size; _index += 4; }
                else if (_is_header_2) { _new_size_mul = _markdown_h2_size; _index += 3; }
                else if (_is_header_1) { _new_size_mul = _markdown_h1_size; _index += 2; }
                else { _new_size_mul = _markdown_hs_size; _index += 3; }

                __ww_textproc_ctx_apply_patch__(_ctx, { size_mul: _new_size_mul, style: __ww_md_normalize_style__(_bold_enabled, _italic_enabled) });

                _ctx.span_start = _ctx.out_len;
                _at_line_start = false;
                continue;
            }

            // Horizontal rule: --- (only spaces until EOL)
            if (!_in_code_block && __ww_md_starts_with__(_raw_text, "---", _index)) {

                var _scan_rule = _index + 3;
                var _only_spaces = true;

                while (_scan_rule <= _text_len) {
                    var _scan_char = string_char_at(_raw_text, _scan_rule);
                    if (_scan_char == "\n" || _scan_char == "\r") { break; }
                    if (_scan_char != " ") { _only_spaces = false; break; }
                    _scan_rule += 1;
                }

                if (_only_spaces) {

                    __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

                    var _rule_prev_state = __ww_textproc_state_clone__(_ctx.state);

                    var _rule_patch = {
                        style: __WW_Text_Glyph_Style.Regular,
                        size_mul: 1,
                        color: _markdown_quote_color,
                        alpha: _markdown_quote_alpha,
                        underline: __WW_Text_Glyph_Underline.None,
                        strike: __WW_Text_Glyph_Strike.None
                    };

                    __ww_textproc_ctx_apply_patch__(_ctx, _rule_patch);

                    var _dash_count = _markdown_hr_dash_count;

                    var _limit_width = __ww_md_get_limit_width__(_default_state);

                    var _old_font_asset = draw_get_font();
                    var _want_font_asset = _ctx.state.font_asset;
                    if (!font_exists(_want_font_asset)) { _want_font_asset = _default_state.font_asset; }

                    if (font_exists(_want_font_asset)) { draw_set_font(_want_font_asset); }

                    var _dash_width = string_width("-");
                    if (_dash_width <= 0) { _dash_width = 1; }

                    var _dash_fit = floor(_limit_width / _dash_width);

                    if (font_exists(_old_font_asset) && _old_font_asset != draw_get_font()) {
                        draw_set_font(_old_font_asset);
                    }

                    if (_dash_fit > 0) { _dash_count = _dash_fit; }

                    if (_dash_count < 3) { _dash_count = 3; }
                    if (_dash_count > 256) { _dash_count = 256; }

                    __ww_textproc_ctx_append_text__(_ctx, string_repeat("-", _dash_count));

                    __ww_textproc_ctx_apply_patch__(_ctx, _rule_prev_state);
                    _ctx.span_start = _ctx.out_len;

                    _index = _scan_rule;
                    _at_line_start = true;
                    continue;
                }
            }

            // Task list: - [x] or * [ ]
            if (!_in_code_block && (__ww_md_starts_with__(_raw_text, "- [", _index) || __ww_md_starts_with__(_raw_text, "* [", _index))) {

                if (_index + 5 <= _text_len) {

                    var _mark_character = string_char_at(_raw_text, _index + 3);
                    var _right_bracket = string_char_at(_raw_text, _index + 4);
                    var _after_character = string_char_at(_raw_text, _index + 5);

                    if (_right_bracket == "]" && _after_character == " ") {

                        __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

                        var _lead_text = "- [ ] ";
                        if (_mark_character == "x" || _mark_character == "X") { _lead_text = "- [x] "; }

                        var _lead_prev_state = __ww_textproc_state_clone__(_ctx.state);

                        __ww_textproc_ctx_apply_patch__(_ctx, {
                            style: __WW_Text_Glyph_Style.Regular,
                            size_mul: 1,
                            color: _markdown_quote_color,
                            alpha: 1,
                            underline: __WW_Text_Glyph_Underline.None,
                            strike: __WW_Text_Glyph_Strike.None
                        });

                        __ww_textproc_ctx_append_text__(_ctx, _lead_text);

                        __ww_textproc_ctx_apply_patch__(_ctx, _lead_prev_state);
                        _ctx.span_start = _ctx.out_len;

                        _index += 6;
                        _at_line_start = false;
                        continue;
                    }
                }
            }

            // Blockquote: > (optional following space)
            if (!_in_code_block && _character == ">") {

                // End any prior span before emitting the quote marker
                __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

                // Start marker span at current output position
                _ctx.span_start = _ctx.out_len;

                // Save current state so the quoted content can inherit it (except color/alpha)
                var _quote_prev_state = __ww_textproc_state_clone__(_ctx.state);

                // Emit the marker with quote styling
                __ww_textproc_ctx_apply_patch__(_ctx, {
                    style: __WW_Text_Glyph_Style.Regular,
                    size_mul: 1,
                    color: _markdown_quote_color,
                    alpha: _markdown_quote_alpha,
                    underline: __WW_Text_Glyph_Underline.None,
                    strike: __WW_Text_Glyph_Strike.None
                });

                __ww_textproc_ctx_append_text__(_ctx, "> ");

                // Flush the marker span so the styling does not leak
                __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

                // Restore previous state, then apply quote color/alpha for the rest of the line
                __ww_textproc_ctx_apply_patch__(_ctx, _quote_prev_state);
                __ww_textproc_ctx_apply_patch__(_ctx, { color: _markdown_quote_color, alpha: _markdown_quote_alpha });

                _ctx.span_start = _ctx.out_len;

                _index += 1;
                if (_index <= _text_len && string_char_at(_raw_text, _index) == " ") { _index += 1; }

                _at_line_start = false;
                continue;
            }

            // Unordered list: "- " or "* "
            if (!_in_code_block && (__ww_md_starts_with__(_raw_text, "- ", _index) || __ww_md_starts_with__(_raw_text, "* ", _index))) {

                __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

                var _bullet_prev_state = __ww_textproc_state_clone__(_ctx.state);

                __ww_textproc_ctx_apply_patch__(_ctx, {
                    style: __WW_Text_Glyph_Style.Regular,
                    size_mul: 1,
                    color: _markdown_quote_color,
                    alpha: 1,
                    underline: __WW_Text_Glyph_Underline.None,
                    strike: __WW_Text_Glyph_Strike.None
                });

                __ww_textproc_ctx_append_text__(_ctx, "- ");

                __ww_textproc_ctx_apply_patch__(_ctx, _bullet_prev_state);
                _ctx.span_start = _ctx.out_len;

                _index += 2;
                _at_line_start = false;
                continue;
            }

            // Ordered list: digits "." space
            if (!_in_code_block && __ww_md_is_digit__(_character)) {

                var _scan_digits = _index;
                while (_scan_digits <= _text_len && __ww_md_is_digit__(string_char_at(_raw_text, _scan_digits))) {
                    _scan_digits += 1;
                }

                if (_scan_digits + 1 <= _text_len) {
                    if (string_char_at(_raw_text, _scan_digits) == "." && string_char_at(_raw_text, _scan_digits + 1) == " ") {

                        __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

                        var _lead_len = (_scan_digits + 1) - _index + 1;
                        var _lead_text2 = string_copy(_raw_text, _index, _lead_len);

                        var _number_prev_state = __ww_textproc_state_clone__(_ctx.state);

                        __ww_textproc_ctx_apply_patch__(_ctx, {
                            style: __WW_Text_Glyph_Style.Regular,
                            size_mul: 1,
                            color: _markdown_quote_color,
                            alpha: 1,
                            underline: __WW_Text_Glyph_Underline.None,
                            strike: __WW_Text_Glyph_Strike.None
                        });

                        __ww_textproc_ctx_append_text__(_ctx, _lead_text2);

                        __ww_textproc_ctx_apply_patch__(_ctx, _number_prev_state);
                        _ctx.span_start = _ctx.out_len;

                        _index = _scan_digits + 2;
                        _at_line_start = false;
                        continue;
                    }
                }
            }
        }

        // Inside fenced code block: output verbatim (only fence handled at line start above)
        if (_in_code_block) {

            __ww_textproc_ctx_append_text__(_ctx, _character);

            if (_character == "\n" || _character == "\r") {
                // Keep code style, but update line-start tracking
                _at_line_start = true;
            } else {
                _at_line_start = false;
            }

            _index += 1;
            continue;
        }

        // Newlines reset line-level styles (headings, quote)
        if (_character == "\n" || _character == "\r") {

            __ww_textproc_ctx_append_text__(_ctx, _character);

            _bold_enabled = false;
            _italic_enabled = false;
            _underline_enabled = false;
            _strike_enabled = false;

            __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

            __ww_textproc_ctx_apply_patch__(_ctx, _default_state);
            _ctx.span_start = _ctx.out_len;

            _at_line_start = true;

            _index += 1;
            continue;
        }

        _at_line_start = false;

        // Backslash escapes (common ASCII punctuation)
        if (_character == "\\" && _index + 1 <= _text_len) {

            var _next_escape = string_char_at(_raw_text, _index + 1);

            if (__ww_md_is_punct__(_next_escape) || _next_escape == "\\") {
                __ww_textproc_ctx_append_text__(_ctx, _next_escape);
                _index += 2;
                continue;
            }
        }

        // Inline code spans with variable-length backticks
        if (_character == "`") {

            var _tick_count = __ww_md_count_run__(_raw_text, _index, "`");
            var _closer_pos = __ww_md_find_backtick_closer__(_raw_text, _index + _tick_count, _tick_count);

            if (_closer_pos > 0) {

                __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

                var _code_start_src = _index + _tick_count;
                var _code_len = _closer_pos - _code_start_src;

                var _code_text = "";
                if (_code_len > 0) {
                    _code_text = string_copy(_raw_text, _code_start_src, _code_len);
                }

                var _code_prev_state = __ww_textproc_state_clone__(_ctx.state);

                var _code_patch = { style: __WW_Text_Glyph_Style.Regular, size_mul: 1 };
                if (_markdown_code_font != -1) { _code_patch.font_asset = _markdown_code_font; }

                __ww_textproc_ctx_apply_patch__(_ctx, _code_patch);
                __ww_textproc_ctx_append_text__(_ctx, _code_text);
                __ww_textproc_ctx_apply_patch__(_ctx, _code_prev_state);

                _ctx.span_start = _ctx.out_len;

                _index = _closer_pos + _tick_count;
                continue;
            }

            // No closer: emit literal run
            __ww_textproc_ctx_append_text__(_ctx, string_repeat("`", _tick_count));
            _index += _tick_count;
            continue;
        }

        // Strikethrough: ~~text~~
        if (_character == "~" && _index + 1 <= _text_len && string_char_at(_raw_text, _index + 1) == "~") {

            __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

            _strike_enabled = !_strike_enabled;
            __ww_textproc_ctx_apply_patch__(_ctx, { strike: (_strike_enabled ? __WW_Text_Glyph_Strike.Line : __WW_Text_Glyph_Strike.None) });

            _ctx.span_start = _ctx.out_len;

            _index += 2;
            continue;
        }

        // Underline toggle: __text__
        if (_character == "_" && _index + 1 <= _text_len && string_char_at(_raw_text, _index + 1) == "_") {

            __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

            _underline_enabled = !_underline_enabled;
            __ww_textproc_ctx_apply_patch__(_ctx, { underline: (_underline_enabled ? __WW_Text_Glyph_Underline.Line : __WW_Text_Glyph_Underline.None) });

            _ctx.span_start = _ctx.out_len;

            _index += 2;
            continue;
        }

        // Emphasis: * or _ (1..3 run)
        if (_character == "*" || _character == "_") {

            var _is_underscore = (_character == "_");
            var _run_count = __ww_md_count_run__(_raw_text, _index, _character);
            if (_run_count > 3) { _run_count = 3; }

            var _prev_character = "";
            if (_index > 1) { _prev_character = string_char_at(_raw_text, _index - 1); }

            var _next_character = "";
            if (_index + _run_count <= _text_len) { _next_character = string_char_at(_raw_text, _index + _run_count); }

            var _can_open = __ww_md_can_open_emph__(_prev_character, _next_character, _is_underscore);
            var _can_close = __ww_md_can_close_emph__(_prev_character, _next_character, _is_underscore);

            if (!_can_open && !_can_close) {
                __ww_textproc_ctx_append_text__(_ctx, string_repeat(_character, _run_count));
                _index += _run_count;
                continue;
            }

            __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

            var _use_close = _can_close;

            if (_run_count >= 3) {
                if (_use_close) {
                    _bold_enabled = false;
                    _italic_enabled = false;
                } else {
                    _bold_enabled = true;
                    _italic_enabled = true;
                }
            }
            else if (_run_count == 2) {
                if (_use_close) { _bold_enabled = false; }
                else { _bold_enabled = true; }
            }
            else {
                if (_use_close) { _italic_enabled = false; }
                else { _italic_enabled = true; }
            }

            __ww_textproc_ctx_apply_patch__(_ctx, { style: __ww_md_normalize_style__(_bold_enabled, _italic_enabled) });

            _ctx.span_start = _ctx.out_len;

            _index += _run_count;
            continue;
        }

        // Image: ![alt](src) -> emit [alt]
        if (_character == "!" && _index + 1 <= _text_len && string_char_at(_raw_text, _index + 1) == "[") {

            var _alt_start = _index + 2;
            var _alt_end = __ww_md_find_char_from__(_raw_text, "]", _alt_start);

            if (_alt_end > 0 && _alt_end + 1 <= _text_len && string_char_at(_raw_text, _alt_end + 1) == "(") {

                var _url_end = __ww_md_find_char_from__(_raw_text, ")", _alt_end + 2);
                if (_url_end > 0) {

                    var _alt_text = string_copy(_raw_text, _alt_start, _alt_end - _alt_start);

                    __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

                    var _img_prev_state = __ww_textproc_state_clone__(_ctx.state);

                    __ww_textproc_ctx_apply_patch__(_ctx, {
                        style: __WW_Text_Glyph_Style.Italic,
                        size_mul: 1,
                        color: _markdown_quote_color,
                        alpha: 1,
                        underline: __WW_Text_Glyph_Underline.None,
                        strike: __WW_Text_Glyph_Strike.None
                    });

                    __ww_textproc_ctx_append_text__(_ctx, "[");
                    __ww_textproc_ctx_append_text__(_ctx, _alt_text);
                    __ww_textproc_ctx_append_text__(_ctx, "]");

                    __ww_textproc_ctx_apply_patch__(_ctx, _img_prev_state);
                    _ctx.span_start = _ctx.out_len;

                    _index = _url_end + 1;
                    continue;
                }
            }
        }

        // Link: [title](url) -> emit title with link styling
        if (_character == "[") {

            var _title_start = _index + 1;
            var _title_end = __ww_md_find_char_from__(_raw_text, "]", _title_start);

            if (_title_end > 0 && _title_end + 1 <= _text_len && string_char_at(_raw_text, _title_end + 1) == "(") {

                var _url_end2 = __ww_md_find_char_from__(_raw_text, ")", _title_end + 2);
                if (_url_end2 > 0) {

                    var _title_text = string_copy(_raw_text, _title_start, _title_end - _title_start);

                    __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

                    var _link_prev_state = __ww_textproc_state_clone__(_ctx.state);

                    __ww_textproc_ctx_apply_patch__(_ctx, {
                        color: _markdown_link_color,
                        alpha: _markdown_link_alpha,
                        underline: _markdown_link_underline
                    });

                    __ww_textproc_ctx_append_text__(_ctx, _title_text);

                    __ww_textproc_ctx_apply_patch__(_ctx, _link_prev_state);
                    _ctx.span_start = _ctx.out_len;

                    _index = _url_end2 + 1;
                    continue;
                }
            }
        }

        // Default: emit char as-is
        __ww_textproc_ctx_append_text__(_ctx, _character);
        _index += 1;
    }

    // Alignment runs flush (even if never changed)
    if (_ctx.out_len > _align_start) {
        array_push(_align_runs, { start_index: _align_start, end_index: _ctx.out_len, align_value: _align_value });
    }

    var _result = __ww_textproc_ctx_finish__(_ctx);
    _result.align_runs = _align_runs;
    return _result;
}

function WWTextProcessorMarkdown(_raw_text, _default_state) {

    var _ctx = __ww_textproc_ctx_begin__(_default_state);

    // Alignment runs (output index space, like BBCode/CSS)
    var _align_runs = [];
    var _align_value = __WW_Text_Alignment.Left;

    if (variable_struct_exists(_ctx.state, "align_value")) {
        _align_value = _ctx.state.align_value;
    } else {
        _ctx.state.align_value = _align_value;
    }

    var _align_start = 0;

    if (_raw_text == undefined || _raw_text == "") {
        var _result_empty = __ww_textproc_ctx_finish__(_ctx);
        _result_empty.align_runs = _align_runs;
        return _result_empty;
    }

    // Theme-like defaults (overrideable via _default_state optional fields)
    var _markdown_link_color = c_aqua;
    var _markdown_link_alpha = 1;
    var _markdown_link_underline = __WW_Text_Glyph_Underline.Line;

    var _markdown_quote_color = c_gray;
    var _markdown_quote_alpha = 0.85;

    var _markdown_code_font = fnt_ww_consolas_10;

    var _markdown_hs_size = 0.75;
    var _markdown_h1_size = 2;
    var _markdown_h2_size = 1.5;
    var _markdown_h3_size = 1.25;

    var _markdown_hr_dash_count = 64;

    if (variable_struct_exists(_default_state, "markdown_link_color")) { _markdown_link_color = _default_state.markdown_link_color; }
    if (variable_struct_exists(_default_state, "markdown_link_alpha")) { _markdown_link_alpha = _default_state.markdown_link_alpha; }
    if (variable_struct_exists(_default_state, "markdown_link_underline")) { _markdown_link_underline = _default_state.markdown_link_underline; }

    if (variable_struct_exists(_default_state, "markdown_quote_color")) { _markdown_quote_color = _default_state.markdown_quote_color; }
    if (variable_struct_exists(_default_state, "markdown_quote_alpha")) { _markdown_quote_alpha = _default_state.markdown_quote_alpha; }

    if (variable_struct_exists(_default_state, "markdown_code_font")) { _markdown_code_font = _default_state.markdown_code_font; }

    if (variable_struct_exists(_default_state, "markdown_hs_size")) { _markdown_hs_size = _default_state.markdown_hs_size; }
    if (variable_struct_exists(_default_state, "markdown_h1_size")) { _markdown_h1_size = _default_state.markdown_h1_size; }
    if (variable_struct_exists(_default_state, "markdown_h2_size")) { _markdown_h2_size = _default_state.markdown_h2_size; }
    if (variable_struct_exists(_default_state, "markdown_h3_size")) { _markdown_h3_size = _default_state.markdown_h3_size; }

    if (variable_struct_exists(_default_state, "markdown_hr_dash_count")) { _markdown_hr_dash_count = _default_state.markdown_hr_dash_count; }

    // Inline toggles
    var _bold_enabled = false;
    var _italic_enabled = false;
    var _underline_enabled = false;
    var _strike_enabled = false;
    var _in_code_block = false;
    var _at_line_start = true;
    var _prev_src_char = "";

    var _in_pair = __ww_md_init_input_buff__(_raw_text);
    var _in_buff = _in_pair[0];
    var _in_len = _in_pair[1];

    static __md_special_u8 = undefined;
    if (__md_special_u8 == undefined) {
        __md_special_u8 = array_create(128, false);
        __md_special_u8[10] = true;  // \n
        __md_special_u8[13] = true;  // \r
        __md_special_u8[33] = true;  // !
        __md_special_u8[42] = true;  // *
        __md_special_u8[62] = true;  // >
        __md_special_u8[91] = true;  // [
        __md_special_u8[92] = true;  // \\
        __md_special_u8[95] = true;  // _
        __md_special_u8[96] = true;  // `
        __md_special_u8[126] = true; // ~
    }

    var _pos = 0;
    while (_pos < _in_len) {

        // Fast-path: emit runs of plain ASCII that cannot trigger Markdown parsing.
        if (!_in_code_block && !_at_line_start) {
            var _b_plain0 = buffer_peek(_in_buff, _pos, buffer_u8);
            if (_b_plain0 < 128 && !__md_special_u8[_b_plain0]) {
                var _plain_start = _pos;
                _pos += 1;
                while (_pos < _in_len) {
                    var _b_plain = buffer_peek(_in_buff, _pos, buffer_u8);
                    if (_b_plain >= 128) { break; }
                    if (__md_special_u8[_b_plain]) { break; }
                    _pos += 1;
                }
                __ww_textproc_ctx_append_text__(_ctx, regex__buffer_read_text_range(_in_buff, _plain_start, _pos));
                _prev_src_char = chr(buffer_peek(_in_buff, _pos - 1, buffer_u8));
                continue;
            }
        }

        var _dec = __ww_md_utf8_decode_at__(_in_buff, _pos, _in_len);
        var _cp = _dec[0];
        var _next_pos = _dec[1];
        var _character = chr(_cp);

        // Line-start block constructs (not inside code block)
        if (_at_line_start) {

            // Table block heuristic: header row with pipes, separator next line
            if (!_in_code_block) {

                var _line_end1 = __ww_md_find_line_break_byte__(_in_buff, _pos, _in_len);
                var _line_text1 = regex__buffer_read_text_range(_in_buff, _pos, _line_end1);

                var _next_line_start = __ww_md_skip_newline_bytes__(_in_buff, _line_end1, _in_len);

                if (_next_line_start < _in_len && __ww_md_line_has_pipe__(_line_text1)) {

                    var _line_end2 = __ww_md_find_line_break_byte__(_in_buff, _next_line_start, _in_len);
                    var _line_text2 = regex__buffer_read_text_range(_in_buff, _next_line_start, _line_end2);

                    if (__ww_md_is_table_separator_line__(_line_text2)) {

                        __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

                        var _rows = [];
                        var _col_widths = [];

                        // Header
                        var _header_cells = __ww_md_split_table_row__(_line_text1);
                        array_push(_rows, _header_cells);

                        // Ensure widths
                        var _header_count = array_length(_header_cells);
                        var _header_index = 0;
                        repeat (_header_count) {
                            if (_header_index >= array_length(_col_widths)) { array_push(_col_widths, 0); }
                            var _cell_len = string_length(_header_cells[_header_index]);
                            if (_cell_len > _col_widths[_header_index]) { _col_widths[_header_index] = _cell_len; }
                            _header_index += 1;
                        }

                        // Data rows begin after separator line
                        var _scan_pos = __ww_md_skip_newline_bytes__(_in_buff, _line_end2, _in_len);

                        while (_scan_pos < _in_len) {

                            var _row_end = __ww_md_find_line_break_byte__(_in_buff, _scan_pos, _in_len);
                            var _row_text = regex__buffer_read_text_range(_in_buff, _scan_pos, _row_end);

                            if (string_trim(_row_text) == "") { break; }
                            if (!__ww_md_line_has_pipe__(_row_text)) { break; }
                            if (__ww_md_is_table_separator_line__(_row_text)) { break; }

                            var _row_cells = __ww_md_split_table_row__(_row_text);
                            array_push(_rows, _row_cells);

                            var _row_cell_count = array_length(_row_cells);
                            var _row_cell_index = 0;
                            repeat (_row_cell_count) {
                                if (_row_cell_index >= array_length(_col_widths)) { array_push(_col_widths, 0); }
                                var _row_cell_len = string_length(_row_cells[_row_cell_index]);
                                if (_row_cell_len > _col_widths[_row_cell_index]) { _col_widths[_row_cell_index] = _row_cell_len; }
                                _row_cell_index += 1;
                            }

                            _scan_pos = __ww_md_skip_newline_bytes__(_in_buff, _row_end, _in_len);
                        }

                        // Apply code-like styling for the table region
                        var _table_prev_state = __ww_textproc_state_clone__(_ctx.state);
                        var _table_patch = { style: __WW_Text_Glyph_Style.Regular, size_mul: 1 };
                        if (_markdown_code_font != -1) { _table_patch.font_asset = _markdown_code_font; }
                        __ww_textproc_ctx_apply_patch__(_ctx, _table_patch);

                        var _row_count = array_length(_rows);
                        if (_row_count > 0) {
                            __ww_textproc_ctx_append_text__(_ctx, __ww_md_table_emit_row__(_rows[0], _col_widths));
                            __ww_textproc_ctx_append_text__(_ctx, "\n");
                            __ww_textproc_ctx_append_text__(_ctx, __ww_md_table_build_separator_row__(_col_widths));
                            __ww_textproc_ctx_append_text__(_ctx, "\n");

                            var _row_index = 1;
                            while (_row_index < _row_count) {
                                __ww_textproc_ctx_append_text__(_ctx, __ww_md_table_emit_row__(_rows[_row_index], _col_widths));
                                __ww_textproc_ctx_append_text__(_ctx, "\n");
                                _row_index += 1;
                            }
                        }

                        // Restore prior state and advance source cursor past the table
                        __ww_textproc_ctx_apply_patch__(_ctx, _table_prev_state);
                        _ctx.span_start = _ctx.out_len;

                        _pos = _scan_pos;
                        _at_line_start = true;
                        continue;
                    }
                }
            }

            // Fenced code block toggle (```)
            if (_cp == 96 && _pos + 2 < _in_len && buffer_peek(_in_buff, _pos + 1, buffer_u8) == 96 && buffer_peek(_in_buff, _pos + 2, buffer_u8) == 96) {

                __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

                _in_code_block = !_in_code_block;

                if (_in_code_block) {

                    _bold_enabled = false;
                    _italic_enabled = false;
                    _underline_enabled = false;
                    _strike_enabled = false;

                    var _enter_patch = {
                        style: __WW_Text_Glyph_Style.Regular,
                        size_mul: 1,
                        underline: __WW_Text_Glyph_Underline.None,
                        strike: __WW_Text_Glyph_Strike.None,
                        back_color: 0,
                        back_alpha: 0
                    };

                    if (_markdown_code_font != -1) { _enter_patch.font_asset = _markdown_code_font; }
                    __ww_textproc_ctx_apply_patch__(_ctx, _enter_patch);

                } else {
                    __ww_textproc_ctx_apply_patch__(_ctx, _default_state);
                }

                _ctx.span_start = _ctx.out_len;

                // Skip the fence line content entirely, but do not consume the newline
                _pos += 3;
                _pos = __ww_md_find_line_break_byte__(_in_buff, _pos, _in_len);
                _at_line_start = true;
                continue;
            }

            // Headings at line start (must be followed by space)
            var _is_header_s = (_cp == 45 && _pos + 2 < _in_len && buffer_peek(_in_buff, _pos + 1, buffer_u8) == 35 && buffer_peek(_in_buff, _pos + 2, buffer_u8) == 32);
            var _is_header_1 = (_cp == 35 && _pos + 1 < _in_len && buffer_peek(_in_buff, _pos + 1, buffer_u8) == 32);
            var _is_header_2 = (_cp == 35 && _pos + 2 < _in_len && buffer_peek(_in_buff, _pos + 1, buffer_u8) == 35 && buffer_peek(_in_buff, _pos + 2, buffer_u8) == 32);
            var _is_header_3 = (_cp == 35 && _pos + 3 < _in_len && buffer_peek(_in_buff, _pos + 1, buffer_u8) == 35 && buffer_peek(_in_buff, _pos + 2, buffer_u8) == 35 && buffer_peek(_in_buff, _pos + 3, buffer_u8) == 32);

            if (!_in_code_block && (_is_header_s || _is_header_1 || _is_header_2 || _is_header_3)) {

                __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

                _bold_enabled = false;
                _italic_enabled = false;

                var _new_size_mul = 1;
                if (_is_header_3) { _new_size_mul = _markdown_h3_size; _pos += 4; }
                else if (_is_header_2) { _new_size_mul = _markdown_h2_size; _pos += 3; }
                else if (_is_header_1) { _new_size_mul = _markdown_h1_size; _pos += 2; }
                else { _new_size_mul = _markdown_hs_size; _pos += 3; }

                __ww_textproc_ctx_apply_patch__(_ctx, { size_mul: _new_size_mul, style: __ww_md_normalize_style__(_bold_enabled, _italic_enabled) });
                _ctx.span_start = _ctx.out_len;
                _at_line_start = false;
                continue;
            }

            // Horizontal rule: --- (only spaces until EOL)
            if (!_in_code_block && _cp == 45 && _pos + 2 < _in_len && buffer_peek(_in_buff, _pos + 1, buffer_u8) == 45 && buffer_peek(_in_buff, _pos + 2, buffer_u8) == 45) {

                var _scan_rule = _pos + 3;
                var _only_spaces = true;

                while (_scan_rule < _in_len) {
                    var _sb = buffer_peek(_in_buff, _scan_rule, buffer_u8);
                    if (_sb == 10 || _sb == 13) { break; }
                    if (_sb != 32) { _only_spaces = false; break; }
                    _scan_rule += 1;
                }

                if (_only_spaces) {

                    __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

                    var _rule_prev_state = __ww_textproc_state_clone__(_ctx.state);

                    var _rule_patch = {
                        style: __WW_Text_Glyph_Style.Regular,
                        size_mul: 1,
                        color: _markdown_quote_color,
                        alpha: _markdown_quote_alpha,
                        underline: __WW_Text_Glyph_Underline.None,
                        strike: __WW_Text_Glyph_Strike.None
                    };

                    __ww_textproc_ctx_apply_patch__(_ctx, _rule_patch);

                    var _dash_count = _markdown_hr_dash_count;
                    var _limit_width = __ww_md_get_limit_width__(_default_state);

                    var _old_font_asset = draw_get_font();
                    var _want_font_asset = _ctx.state.font_asset;
                    if (!font_exists(_want_font_asset)) { _want_font_asset = _default_state.font_asset; }
                    if (font_exists(_want_font_asset)) { draw_set_font(_want_font_asset); }

                    var _dash_width = string_width("-");
                    if (_dash_width <= 0) { _dash_width = 1; }

                    var _dash_fit = floor(_limit_width / _dash_width);

                    if (font_exists(_old_font_asset) && _old_font_asset != draw_get_font()) {
                        draw_set_font(_old_font_asset);
                    }

                    if (_dash_fit > 0) { _dash_count = _dash_fit; }
                    if (_dash_count < 3) { _dash_count = 3; }
                    if (_dash_count > 256) { _dash_count = 256; }

                    __ww_textproc_ctx_append_text__(_ctx, string_repeat("-", _dash_count));

                    __ww_textproc_ctx_apply_patch__(_ctx, _rule_prev_state);
                    _ctx.span_start = _ctx.out_len;

                    _pos = _scan_rule;
                    _at_line_start = true;
                    continue;
                }
            }

            // Task list: - [x] or * [ ]
            if (!_in_code_block && ((_cp == 45 || _cp == 42) && _pos + 2 < _in_len && buffer_peek(_in_buff, _pos + 1, buffer_u8) == 32 && buffer_peek(_in_buff, _pos + 2, buffer_u8) == 91)) {

                if (_pos + 5 < _in_len) {

                    var _mark_u8 = buffer_peek(_in_buff, _pos + 3, buffer_u8);
                    var _right_u8 = buffer_peek(_in_buff, _pos + 4, buffer_u8);
                    var _after_u8 = buffer_peek(_in_buff, _pos + 5, buffer_u8);

                    if (_right_u8 == 93 && _after_u8 == 32) {

                        __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

                        var _lead_text = "- [ ] ";
                        if (_mark_u8 == 120 || _mark_u8 == 88) { _lead_text = "- [x] "; }

                        var _lead_prev_state = __ww_textproc_state_clone__(_ctx.state);

                        __ww_textproc_ctx_apply_patch__(_ctx, {
                            style: __WW_Text_Glyph_Style.Regular,
                            size_mul: 1,
                            color: _markdown_quote_color,
                            alpha: 1,
                            underline: __WW_Text_Glyph_Underline.None,
                            strike: __WW_Text_Glyph_Strike.None
                        });

                        __ww_textproc_ctx_append_text__(_ctx, _lead_text);

                        __ww_textproc_ctx_apply_patch__(_ctx, _lead_prev_state);
                        _ctx.span_start = _ctx.out_len;

                        _pos += 6;
                        _at_line_start = false;
                        continue;
                    }
                }
            }

            // Blockquote: > (optional following space)
            if (!_in_code_block && _cp == 62) {

                __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
                _ctx.span_start = _ctx.out_len;

                var _quote_prev_state = __ww_textproc_state_clone__(_ctx.state);

                __ww_textproc_ctx_apply_patch__(_ctx, {
                    style: __WW_Text_Glyph_Style.Regular,
                    size_mul: 1,
                    color: _markdown_quote_color,
                    alpha: _markdown_quote_alpha,
                    underline: __WW_Text_Glyph_Underline.None,
                    strike: __WW_Text_Glyph_Strike.None
                });

                __ww_textproc_ctx_append_text__(_ctx, "> ");

                __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

                __ww_textproc_ctx_apply_patch__(_ctx, _quote_prev_state);
                __ww_textproc_ctx_apply_patch__(_ctx, { color: _markdown_quote_color, alpha: _markdown_quote_alpha });
                _ctx.span_start = _ctx.out_len;

                _pos += 1;
                if (_pos < _in_len && buffer_peek(_in_buff, _pos, buffer_u8) == 32) { _pos += 1; }

                _at_line_start = false;
                continue;
            }

            // Unordered list: "- " or "* "
            if (!_in_code_block && ((_cp == 45 || _cp == 42) && _pos + 1 < _in_len && buffer_peek(_in_buff, _pos + 1, buffer_u8) == 32)) {

                __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

                var _bullet_prev_state = __ww_textproc_state_clone__(_ctx.state);

                __ww_textproc_ctx_apply_patch__(_ctx, {
                    style: __WW_Text_Glyph_Style.Regular,
                    size_mul: 1,
                    color: _markdown_quote_color,
                    alpha: 1,
                    underline: __WW_Text_Glyph_Underline.None,
                    strike: __WW_Text_Glyph_Strike.None
                });

                __ww_textproc_ctx_append_text__(_ctx, "- ");

                __ww_textproc_ctx_apply_patch__(_ctx, _bullet_prev_state);
                _ctx.span_start = _ctx.out_len;

                _pos += 2;
                _at_line_start = false;
                continue;
            }

            // Ordered list: digits "." space
            if (!_in_code_block && _cp >= 48 && _cp <= 57) {

                var _scan_digits = _pos;
                while (_scan_digits < _in_len) {
                    var _db = buffer_peek(_in_buff, _scan_digits, buffer_u8);
                    if (_db < 48 || _db > 57) { break; }
                    _scan_digits += 1;
                }

                if (_scan_digits + 1 < _in_len) {
                    if (buffer_peek(_in_buff, _scan_digits, buffer_u8) == 46 && buffer_peek(_in_buff, _scan_digits + 1, buffer_u8) == 32) {

                        __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

                        var _lead_text2 = regex__buffer_read_text_range(_in_buff, _pos, _scan_digits + 2);

                        var _number_prev_state = __ww_textproc_state_clone__(_ctx.state);

                        __ww_textproc_ctx_apply_patch__(_ctx, {
                            style: __WW_Text_Glyph_Style.Regular,
                            size_mul: 1,
                            color: _markdown_quote_color,
                            alpha: 1,
                            underline: __WW_Text_Glyph_Underline.None,
                            strike: __WW_Text_Glyph_Strike.None
                        });

                        __ww_textproc_ctx_append_text__(_ctx, _lead_text2);

                        __ww_textproc_ctx_apply_patch__(_ctx, _number_prev_state);
                        _ctx.span_start = _ctx.out_len;

                        _pos = _scan_digits + 2;
                        _at_line_start = false;
                        continue;
                    }
                }
            }
        }

        // Inside fenced code block: output verbatim (only fence handled at line start above)
        if (_in_code_block) {

            __ww_textproc_ctx_append_text__(_ctx, _character);
            _at_line_start = (_cp == 10 || _cp == 13);

            _prev_src_char = _character;
            _pos = _next_pos;
            continue;
        }

        // Newlines reset line-level styles (headings, quote)
        if (_cp == 10 || _cp == 13) {

            __ww_textproc_ctx_append_text__(_ctx, _character);

            _bold_enabled = false;
            _italic_enabled = false;
            _underline_enabled = false;
            _strike_enabled = false;

            __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
            __ww_textproc_ctx_apply_patch__(_ctx, _default_state);
            _ctx.span_start = _ctx.out_len;

            _at_line_start = true;
            _prev_src_char = _character;
            _pos = _next_pos;
            continue;
        }

        _at_line_start = false;

        // Backslash escapes (common ASCII punctuation)
        if (_cp == 92 && _next_pos < _in_len) {

            var _esc_dec = __ww_md_utf8_decode_at__(_in_buff, _next_pos, _in_len);
            var _esc_cp = _esc_dec[0];
            var _esc_next = _esc_dec[1];
            var _next_escape = chr(_esc_cp);

            if (__ww_md_is_punct__(_next_escape) || _next_escape == "\\") {
                __ww_textproc_ctx_append_text__(_ctx, _next_escape);
                _prev_src_char = _next_escape;
                _pos = _esc_next;
                continue;
            }
        }

        // Inline code spans with variable-length backticks
        if (_cp == 96) {

            var _tick_count = 1;
            while (_pos + _tick_count < _in_len && buffer_peek(_in_buff, _pos + _tick_count, buffer_u8) == 96) {
                _tick_count += 1;
            }

            var _closer_pos = -1;
            var _scan = _pos + _tick_count;
            while (_scan < _in_len) {

                var _sb0 = buffer_peek(_in_buff, _scan, buffer_u8);
                if (_sb0 != 96) { _scan += 1; continue; }

                var _run = 1;
                while (_scan + _run < _in_len && buffer_peek(_in_buff, _scan + _run, buffer_u8) == 96) {
                    _run += 1;
                }

                if (_run == _tick_count) { _closer_pos = _scan; break; }
                _scan += _run;
            }

            if (_closer_pos >= 0) {

                __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

                var _code_text = regex__buffer_read_text_range(_in_buff, _pos + _tick_count, _closer_pos);
                var _code_prev_state = __ww_textproc_state_clone__(_ctx.state);

                var _code_patch = { style: __WW_Text_Glyph_Style.Regular, size_mul: 1 };
                if (_markdown_code_font != -1) { _code_patch.font_asset = _markdown_code_font; }

                __ww_textproc_ctx_apply_patch__(_ctx, _code_patch);
                __ww_textproc_ctx_append_text__(_ctx, _code_text);
                __ww_textproc_ctx_apply_patch__(_ctx, _code_prev_state);

                _ctx.span_start = _ctx.out_len;

                _prev_src_char = "`";
                _pos = _closer_pos + _tick_count;
                continue;
            }

            __ww_textproc_ctx_append_text__(_ctx, string_repeat("`", _tick_count));
            _prev_src_char = "`";
            _pos += _tick_count;
            continue;
        }

        // Strikethrough: ~~text~~
        if (_cp == 126 && _pos + 1 < _in_len && buffer_peek(_in_buff, _pos + 1, buffer_u8) == 126) {

            __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

            _strike_enabled = !_strike_enabled;
            __ww_textproc_ctx_apply_patch__(_ctx, { strike: (_strike_enabled ? __WW_Text_Glyph_Strike.Line : __WW_Text_Glyph_Strike.None) });
            _ctx.span_start = _ctx.out_len;

            _prev_src_char = "~";
            _pos += 2;
            continue;
        }

        // Underline toggle: __text__
        if (_cp == 95 && _pos + 1 < _in_len && buffer_peek(_in_buff, _pos + 1, buffer_u8) == 95) {

            __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

            _underline_enabled = !_underline_enabled;
            __ww_textproc_ctx_apply_patch__(_ctx, { underline: (_underline_enabled ? __WW_Text_Glyph_Underline.Line : __WW_Text_Glyph_Underline.None) });
            _ctx.span_start = _ctx.out_len;

            _prev_src_char = "_";
            _pos += 2;
            continue;
        }

        // Emphasis: * or _ (1..3 run)
        if (_cp == 42 || _cp == 95) {

            var _is_underscore = (_cp == 95);
            var _run_count = 1;
            while (_run_count < 3 && _pos + _run_count < _in_len && buffer_peek(_in_buff, _pos + _run_count, buffer_u8) == _cp) {
                _run_count += 1;
            }

            var _prev_character = _prev_src_char;
            var _next_character = "";

            var _next_mark_pos = _pos + _run_count;
            if (_next_mark_pos < _in_len) {
                var _nd = __ww_md_utf8_decode_at__(_in_buff, _next_mark_pos, _in_len);
                _next_character = chr(_nd[0]);
            }

            var _can_open = __ww_md_can_open_emph__(_prev_character, _next_character, _is_underscore);
            var _can_close = __ww_md_can_close_emph__(_prev_character, _next_character, _is_underscore);

            if (!_can_open && !_can_close) {
                __ww_textproc_ctx_append_text__(_ctx, string_repeat(_character, _run_count));
                _prev_src_char = _character;
                _pos += _run_count;
                continue;
            }

            __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

            var _use_close = _can_close;

            if (_run_count >= 3) {
                if (_use_close) { _bold_enabled = false; _italic_enabled = false; }
                else { _bold_enabled = true; _italic_enabled = true; }
            }
            else if (_run_count == 2) {
                if (_use_close) { _bold_enabled = false; }
                else { _bold_enabled = true; }
            }
            else {
                if (_use_close) { _italic_enabled = false; }
                else { _italic_enabled = true; }
            }

            __ww_textproc_ctx_apply_patch__(_ctx, { style: __ww_md_normalize_style__(_bold_enabled, _italic_enabled) });
            _ctx.span_start = _ctx.out_len;

            _prev_src_char = _character;
            _pos += _run_count;
            continue;
        }

        // Image: ![alt](src) -> emit [alt]
        if (_cp == 33 && _pos + 1 < _in_len && buffer_peek(_in_buff, _pos + 1, buffer_u8) == 91) {

            var _alt_start = _pos + 2;
            var _alt_end = __ww_md_find_u8__(_in_buff, _alt_start, _in_len, 93); // ']'

            if (_alt_end >= 0 && _alt_end + 1 < _in_len && buffer_peek(_in_buff, _alt_end + 1, buffer_u8) == 40) {

                var _url_end = __ww_md_find_u8__(_in_buff, _alt_end + 2, _in_len, 41); // ')'
                if (_url_end >= 0) {

                    var _alt_text = regex__buffer_read_text_range(_in_buff, _alt_start, _alt_end);

                    __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

                    var _img_prev_state = __ww_textproc_state_clone__(_ctx.state);

                    __ww_textproc_ctx_apply_patch__(_ctx, {
                        style: __WW_Text_Glyph_Style.Italic,
                        size_mul: 1,
                        color: _markdown_quote_color,
                        alpha: 1,
                        underline: __WW_Text_Glyph_Underline.None,
                        strike: __WW_Text_Glyph_Strike.None
                    });

                    __ww_textproc_ctx_append_text__(_ctx, "[");
                    __ww_textproc_ctx_append_text__(_ctx, _alt_text);
                    __ww_textproc_ctx_append_text__(_ctx, "]");

                    __ww_textproc_ctx_apply_patch__(_ctx, _img_prev_state);
                    _ctx.span_start = _ctx.out_len;

                    _prev_src_char = ")";
                    _pos = _url_end + 1;
                    continue;
                }
            }
        }

        // Link: [title](url) -> emit title with link styling
        if (_cp == 91) {

            var _title_start = _pos + 1;
            var _title_end = __ww_md_find_u8__(_in_buff, _title_start, _in_len, 93); // ']'

            if (_title_end >= 0 && _title_end + 1 < _in_len && buffer_peek(_in_buff, _title_end + 1, buffer_u8) == 40) {

                var _url_end2 = __ww_md_find_u8__(_in_buff, _title_end + 2, _in_len, 41); // ')'
                if (_url_end2 >= 0) {

                    var _title_text = regex__buffer_read_text_range(_in_buff, _title_start, _title_end);

                    __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

                    var _link_prev_state = __ww_textproc_state_clone__(_ctx.state);

                    __ww_textproc_ctx_apply_patch__(_ctx, {
                        color: _markdown_link_color,
                        alpha: _markdown_link_alpha,
                        underline: _markdown_link_underline
                    });

                    __ww_textproc_ctx_append_text__(_ctx, _title_text);

                    __ww_textproc_ctx_apply_patch__(_ctx, _link_prev_state);
                    _ctx.span_start = _ctx.out_len;

                    _prev_src_char = ")";
                    _pos = _url_end2 + 1;
                    continue;
                }
            }
        }

        // Default: emit char as-is
        __ww_textproc_ctx_append_text__(_ctx, _character);
        _prev_src_char = _character;
        _pos = _next_pos;
    }

    buffer_resize(_in_buff, 0);

    // Alignment runs flush (even if never changed)
    if (_ctx.out_len > _align_start) {
        array_push(_align_runs, { start_index: _align_start, end_index: _ctx.out_len, align_value: _align_value });
    }

    var _result = __ww_textproc_ctx_finish__(_ctx);
    _result.align_runs = _align_runs;
    return _result;
}
