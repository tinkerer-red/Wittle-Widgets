#region jsDoc
/// @func    WWTextRendererMarkdown()
/// @desc    Basic Markdown renderer built on WWTextRendererBase. Converts a subset of
///          Markdown into plain text + formatting runs, then delegates layout and VB
///          baking to the base renderer.
///          Supported (MVP):
///          - Headings: #, ##, ### at line start
///          - Bold: **text**
///          - Italic: *text*
///          - Inline code: `code`
///          - Fenced code blocks: ```
///          - Blockquote: > quote
///          - Unordered list: - item / * item
///          - Ordered list: 1. item
///          - Horizontal rule: --- on its own line
///          - Links: [title](url) -> emits title, styled + underlined
///          - Images: ![alt](src) -> emits alt text in brackets
///          - Strikethrough: ~~text~~ (styled dim, no true strike line)
///          - Task list: - [x] / - [ ] at line start
///          - Tables: treated as code-style rows (pipe text preserved)
/// @returns {Struct.WWTextRendererMarkdown}
#endregion
function WWTextRendererMarkdown() : WWTextRendererBase() constructor {

    debug_name = "WWTextRendererMarkdown";

    #region Public

        #region Builder Functions

            #region jsDoc
            /// @func    set_markdown_enabled()
            /// @desc    Enable or disable markdown parsing. When disabled, text is treated as plain.
            /// @param   {Bool} _enabled
            /// @returns {Struct.WWTextRendererMarkdown}
            #endregion
            static set_markdown_enabled = function(_enabled) {
                _enabled = (_enabled == true);
                if (markdown_enabled == _enabled) {
                    return self;
                }
                markdown_enabled = _enabled;
                __mark_dirty__();
                return self;
            };

            #region jsDoc
            /// @func    set_markdown_link_style()
            /// @desc    Set link color/alpha and underline style used for [title](url).
            /// @param   {Real} _color_value
            /// @param   {Real} _alpha_value
            /// @param   {Real} _underline_value
            /// @returns {Struct.WWTextRendererMarkdown}
            #endregion
            static set_markdown_link_style = function(_color_value, _alpha_value=undefined, _underline_value=undefined) {

                markdown_link_color = _color_value;

                if (!is_undefined(_alpha_value)) {
                    markdown_link_alpha = _alpha_value;
                }

                if (!is_undefined(_underline_value)) {
                    markdown_link_underline = _underline_value;
                }

                __mark_vb_dirty__();
                return self;
            };

            #region jsDoc
            /// @func    set_markdown_quote_style()
            /// @desc    Set blockquote color/alpha.
            /// @param   {Real} _color_value
            /// @param   {Real} _alpha_value
            /// @returns {Struct.WWTextRendererMarkdown}
            #endregion
            static set_markdown_quote_style = function(_color_value, _alpha_value=undefined) {

                markdown_quote_color = _color_value;

                if (!is_undefined(_alpha_value)) {
                    markdown_quote_alpha = _alpha_value;
                }

                __mark_vb_dirty__();
                return self;
            };

            #region jsDoc
            /// @func    set_markdown_code_font()
            /// @desc    Set font used for inline code and fenced code blocks. Use -1 to disable override.
            /// @param   {Asset.GMFont|Real} _font_asset_or_minus1
            /// @returns {Struct.WWTextRendererMarkdown}
            #endregion
            static set_markdown_code_font = function(_font_asset_or_minus1) {

                markdown_code_font = _font_asset_or_minus1;

                __mark_dirty__();
                return self;
            };

            #region jsDoc
            /// @func    set_markdown_heading_sizes()
            /// @desc    Set size multipliers for headings (#, ##, ###).
            /// @param   {Real} _h1_size
            /// @param   {Real} _h2_size
            /// @param   {Real} _h3_size
            /// @returns {Struct.WWTextRendererMarkdown}
            #endregion
            static set_markdown_heading_sizes = function(_hs_size, _h1_size, _h2_size, _h3_size) {

                markdown_hs_size = _hs_size;
                markdown_h1_size = _h1_size;
                markdown_h2_size = _h2_size;
                markdown_h3_size = _h3_size;

                __mark_dirty__();
                return self;
            };

        #endregion

    #endregion

    #region Private

        #region Variables

            markdown_enabled = true;

            // Feel free to override in your theme
            markdown_link_color = c_aqua;
            markdown_link_alpha = 1;
            markdown_link_underline = __WW_Text_Glyph_Underline.Line;

            markdown_quote_color = c_gray;
            markdown_quote_alpha = 0.85;

            markdown_code_font = fnt_ww_consolas_10;

            markdown_hs_size = 0.75;
            markdown_h1_size = 2;
            markdown_h2_size = 1.5;
            markdown_h3_size = 1.25;

            __md_spans__ = [];
            __md_plain_text__ = "";

        #endregion

        #region Markdown parse + runs
			
            static __md_is_line_break__ = function(_char_val) {
                return (_char_val == "\n" || _char_val == "\r");
            };

            static __md_is_digit__ = function(_char_val) {
                var _code = ord(_char_val);
                return (_code >= ord("0") && _code <= ord("9"));
            };


            static __md_is_whitespace__ = function(_char_val) {
                return (_char_val == " " || _char_val == "\t" || _char_val == "\n" || _char_val == "\r");
            };

            static __md_is_alnum__ = function(_char_val) {
                var _code = ord(_char_val);

                // 0-9
                if (_code >= 48 && _code <= 57) { return true; }

                // A-Z
                if (_code >= 65 && _code <= 90) { return true; }

                // a-z
                if (_code >= 97 && _code <= 122) { return true; }

                return false;
            };

            static __md_is_punct__ = function(_char_val) {
                // Treat anything not whitespace and not alnum as punctuation for our purposes.
                if (__md_is_whitespace__(_char_val)) { return false; }
                if (__md_is_alnum__(_char_val)) { return false; }
                return true;
            };

            static __md_can_open_emph__ = function(_prev_char, _next_char, _is_underscore) {

                // Left-flanking approximation:
                // next must be non-whitespace, and if next is punctuation, prev must be whitespace/punct.
                if (_next_char == "") { return false; }
                if (__md_is_whitespace__(_next_char)) { return false; }

                if (__md_is_punct__(_next_char)) {
                    if (!(__md_is_whitespace__(_prev_char) || __md_is_punct__(_prev_char) || _prev_char == "")) {
                        return false;
                    }
                }

                // Underscore rule: do not emphasize within words.
                if (_is_underscore) {
                    if (__md_is_alnum__(_prev_char) || __md_is_alnum__(_next_char)) {
                        return false;
                    }
                }

                return true;
            };

            static __md_can_close_emph__ = function(_prev_char, _next_char, _is_underscore) {

                // Right-flanking approximation:
                // prev must be non-whitespace, and if prev is punctuation, next must be whitespace/punct/end.
                if (_prev_char == "") { return false; }
                if (__md_is_whitespace__(_prev_char)) { return false; }

                if (__md_is_punct__(_prev_char)) {
                    if (!(__md_is_whitespace__(_next_char) || __md_is_punct__(_next_char) || _next_char == "")) {
                        return false;
                    }
                }

                // Underscore rule: do not emphasize within words.
                if (_is_underscore) {
                    if (__md_is_alnum__(_prev_char) || __md_is_alnum__(_next_char)) {
                        return false;
                    }
                }

                return true;
            };

            static __md_count_run__ = function(_text, _pos1, _char_val) {

                var _len = string_length(_text);
                var _pos = _pos1;

                while (_pos <= _len && string_char_at(_text, _pos) == _char_val) {
                    _pos += 1;
                }

                return (_pos - _pos1);
            };

            static __md_find_backtick_closer__ = function(_text, _start_pos1, _tick_count) {

                var _len = string_length(_text);
                var _pos = _start_pos1;

                while (_pos <= _len) {

                    if (string_char_at(_text, _pos) != "`") {
                        _pos += 1;
                        continue;
                    }

                    var _run = __md_count_run__(_text, _pos, "`");
                    if (_run == _tick_count) {
                        return _pos;
                    }

                    _pos += _run;
                }

                return 0;
            };

            static __md_starts_with__ = function(_text, _prefix, _pos1_based) {

                var _need = string_length(_prefix);
                if (_need <= 0) {
                    return true;
                }

                var _have = string_length(_text);
                if (_pos1_based < 1 || _pos1_based + _need - 1 > _have) {
                    return false;
                }

                return (string_copy(_text, _pos1_based, _need) == _prefix);
            };

            static __md_find_char_from__ = function(_text, _char_find, _start_pos1) {

                var _text_len = string_length(_text);
                if (_start_pos1 < 1) { _start_pos1 = 1; }
                if (_start_pos1 > _text_len) { return 0; }

                var _pos = _start_pos1;
                while (_pos <= _text_len) {

                    if (string_char_at(_text, _pos) == _char_find) {
                        return _pos;
                    }

                    _pos += 1;
                }

                return 0;
            };

            static __md_normalize_style__ = function(_bold_enabled, _italic_enabled) {
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
            };

                        static __md_build_runs_from_spans__ = function(_plain_len, _spans, _default_state) {

                __md_spans__ = [];

                if (_plain_len <= 0) {
                    return;
                }

                var _span_count = array_length(_spans);

                var _pos_index = 0;

                // Current run state
                var _run_font = _default_state.font_asset_or_minus1;
                var _run_style = _default_state.style_value;
                var _run_size = _default_state.size_mul;

                var _run_color = _default_state.color;
                var _run_alpha = _default_state.alpha;
                var _run_underline = _default_state.underline;

                var _run_strike = _default_state.strike;
                var _run_back_color = _default_state.back_color;
                var _run_back_alpha = _default_state.back_alpha;

                var _run_start = 0;

                while (_pos_index < _plain_len) {

                    // Desired state at this index (later spans win)
                    var _want_font = _default_state.font_asset_or_minus1;
                    var _want_style = _default_state.style_value;
                    var _want_size = _default_state.size_mul;

                    var _want_color = _default_state.color;
                    var _want_alpha = _default_state.alpha;
                    var _want_underline = _default_state.underline;

                    var _want_strike = _default_state.strike;
                    var _want_back_color = _default_state.back_color;
                    var _want_back_alpha = _default_state.back_alpha;

                    var _scan_index = 0;
                    repeat (_span_count) {

                        var _sp = _spans[_scan_index];

                        if (_pos_index < _sp.start_index) {
                            _scan_index += 1;
                            continue;
                        }

                        if (_pos_index >= _sp.end_index) {
                            _scan_index += 1;
                            continue;
                        }

                        var _sp_state = _sp.state;

                        _want_font = _sp_state.font_asset_or_minus1;
                        _want_style = _sp_state.style_value;
                        _want_size = _sp_state.size_mul;

                        _want_color = _sp_state.color;
                        _want_alpha = _sp_state.alpha;
                        _want_underline = _sp_state.underline;

                        _want_strike = _sp_state.strike;
                        _want_back_color = _sp_state.back_color;
                        _want_back_alpha = _sp_state.back_alpha;

                        _scan_index += 1;
                    }

                    if (_want_size <= 0) { _want_size = 1; }

                    // Next boundary where state might change
                    var _next_boundary = _plain_len;

                    var _scan_index2 = 0;
                    repeat (_span_count) {

                        var _sp2 = _spans[_scan_index2];

                        if (_pos_index < _sp2.start_index) {
                            if (_sp2.start_index < _next_boundary) { _next_boundary = _sp2.start_index; }
                        }
                        else if (_pos_index < _sp2.end_index) {
                            if (_sp2.end_index < _next_boundary) { _next_boundary = _sp2.end_index; }
                        }

                        _scan_index2 += 1;
                    }

                    // Run change (any metric or visual field)
                    if (_want_font != _run_font
                        || _want_style != _run_style
                        || _want_size != _run_size
                        || _want_color != _run_color
                        || _want_alpha != _run_alpha
                        || _want_underline != _run_underline
                        || _want_strike != _run_strike
                        || _want_back_color != _run_back_color
                        || _want_back_alpha != _run_back_alpha) {

                        var _run_count = _pos_index - _run_start;
                        if (_run_count > 0) {
                            array_push(__md_spans__, {
                                index_count: _run_count,
                                font_asset_or_minus1: _run_font,
                                style_value: _run_style,
                                size_mul: _run_size,
                                color: _run_color,
                                alpha: _run_alpha,
                                underline: _run_underline,
                                strike: _run_strike,
                                back_color: _run_back_color,
                                back_alpha: _run_back_alpha
                            });
                        }

                        _run_font = _want_font;
                        _run_style = _want_style;
                        _run_size = _want_size;

                        _run_color = _want_color;
                        _run_alpha = _want_alpha;
                        _run_underline = _want_underline;

                        _run_strike = _want_strike;
                        _run_back_color = _want_back_color;
                        _run_back_alpha = _want_back_alpha;

                        _run_start = _pos_index;
                    }

                    _pos_index = _next_boundary;
                }

                // Flush last run
                var _tail_count = _plain_len - _run_start;
                if (_tail_count > 0) {
                    array_push(__md_spans__, {
                        index_count: _tail_count,
                        font_asset_or_minus1: _run_font,
                        style_value: _run_style,
                        size_mul: _run_size,
                        color: _run_color,
                        alpha: _run_alpha,
                        underline: _run_underline,
                        strike: _run_strike,
                        back_color: _run_back_color,
                        back_alpha: _run_back_alpha
                    });
                }
            };

static __md_get_line_end_pos__ = function(_text, _start_pos1) {

			    var _text_len = string_length(_text);
			    var _pos = _start_pos1;

			    while (_pos <= _text_len) {

			        var _char_val = string_char_at(_text, _pos);

			        if (_char_val == "\n" || _char_val == "\r") {
			            return _pos;
			        }

			        _pos += 1;
			    }

			    return _text_len + 1;
			};

			static __md_line_has_pipe__ = function(_line_text) {
			    return (string_pos("|", _line_text) > 0);
			};

			static __md_is_table_separator_line__ = function(_line_text) {

			    // Accept: pipes, dashes, colons, spaces
			    // Must contain at least one '|' and at least one '-'
			    if (string_pos("|", _line_text) <= 0) {
			        return false;
			    }

			    if (string_pos("-", _line_text) <= 0) {
			        return false;
			    }

			    var _len = string_length(_line_text);
			    if (_len <= 0) {
			        return false;
			    }

			    var _pos = 1;
			    repeat (_len) {

			        var _char_val = string_char_at(_line_text, _pos);

			        if (_char_val != "|" && _char_val != "-" && _char_val != ":" && _char_val != " " && _char_val != "\t") {
			            return false;
			        }

			        _pos += 1;
			    }

			    return true;
			};

			static __md_split_table_row__ = function(_line_text) {

			    // Returns array of trimmed cell strings
			    var _work = string_trim(_line_text);

			    // Strip leading/trailing pipe if present
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
			};

			static __md_table_build_separator_row__ = function(_col_widths) {

			    var _col_count = array_length(_col_widths);
			    if (_col_count <= 0) {
			        return "";
			    }

			    var _out = "|";

			    var _col_index = 0;
			    repeat (_col_count) {

			        var _wid = _col_widths[_col_index];
			        if (_wid < 3) { _wid = 3; }

			        _out += " ";
			        _out += string_repeat("-", _wid);
			        _out += " |";

			        _col_index += 1;
			    }

			    return _out;
			};

			static __md_table_emit_row__ = function(_cells, _col_widths) {

			    var _col_count = array_length(_col_widths);
			    var _out = "|";

			    var _col_index = 0;
			    repeat (_col_count) {

			        var _cell_text = "";
			        if (_col_index < array_length(_cells)) {
			            _cell_text = _cells[_col_index];
			        }

			        var _target_wid = _col_widths[_col_index];
			        var _cell_len = string_length(_cell_text);

			        if (_cell_len < _target_wid) {
			            _cell_text += string_repeat(" ", _target_wid - _cell_len);
			        }

			        _out += " ";
			        _out += _cell_text;
			        _out += " |";

			        _col_index += 1;
			    }

			    return _out;
			};

            static __md_parse__ = function(_src_text) {

                __md_plain_text__ = "";
                __md_spans__ = [];
				
                var _src_len = string_length(_src_text);
                if (_src_len <= 0) {
                    return;
                }

                var _plain = "";
                var _spans = [];

                var _state = __text_state_make_default__();

                var _bold = false;
                var _italic = false;
				var _strike = false;
				var _underline = false;

                var _in_code_inline = false;
                var _in_code_block = false;

                var _span_start = 0;

                var _pos_src = 1;

                // Track line starts
                var _at_line_start = true;

                // Table heuristic (one line at a time)
                var _table_line_has_pipe = false;

                while (_pos_src <= _src_len) {

                    var _char_val = string_char_at(_src_text, _pos_src);

                    // Handle line starts for block-level constructs (unless inside fenced code block)
                    if (_at_line_start) {

                        _table_line_has_pipe = false;
						
						// Table block: header row with pipes + separator line next
						if (!_in_code_block) {

						    var _line_end1 = __md_get_line_end_pos__(_src_text, _pos_src);
						    var _line_text1 = "";

						    if (_line_end1 > _pos_src) {
						        _line_text1 = string_copy(_src_text, _pos_src, _line_end1 - _pos_src);
						    }

						    // Look ahead to next line (skip newline chars)
						    var _next_line_start = _line_end1;

						    if (_next_line_start <= _src_len) {
						        var _nl_char = string_char_at(_src_text, _next_line_start);
						        if (_nl_char == "\r") { _next_line_start += 1; }
						        if (_next_line_start <= _src_len && string_char_at(_src_text, _next_line_start) == "\n") { _next_line_start += 1; }
						    }

						    if (_next_line_start <= _src_len && __md_line_has_pipe__(_line_text1)) {

						        var _line_end2 = __md_get_line_end_pos__(_src_text, _next_line_start);
						        var _line_text2 = "";

						        if (_line_end2 > _next_line_start) {
						            _line_text2 = string_copy(_src_text, _next_line_start, _line_end2 - _next_line_start);
						        }

						        if (__md_is_table_separator_line__(_line_text2)) {

						            // We have a table block. Flush prior span.
						            if ((string_length(_plain)) > (_span_start)) {
                    array_push(_spans, {
                        start_index: _span_start,
                        end_index: string_length(_plain),
                        state: __text_state_clone__(_state)
                    });
                }

						            // Parse header + rows
						            var _rows = [];
						            var _col_widths = [];

						            // Helper to register column widths
						            var _register_row = method({_rows, _col_widths}, function(_cells) {

						                var _col_count_local = array_length(_cells);

						                // Expand widths array
						                var _need_cols = _col_count_local;
						                if (array_length(_col_widths) < _need_cols) {
						                    var _old_cols = array_length(_col_widths);
						                    var _fill_index = _old_cols;
						                    repeat (_need_cols - _old_cols) {
						                        array_push(_col_widths, 0);
						                        _fill_index += 1;
						                    }
						                }

						                // Update max widths
						                var _col_index_local = 0;
						                repeat (_col_count_local) {

						                    var _cell_len_local = string_length(_cells[_col_index_local]);
						                    if (_cell_len_local > _col_widths[_col_index_local]) {
						                        _col_widths[_col_index_local] = _cell_len_local;
						                    }

						                    _col_index_local += 1;
						                }

						                array_push(_rows, _cells);
						            });

						            // Header row
						            _register_row(__md_split_table_row__(_line_text1));

						            // Data rows: start after separator line
						            var _scan_pos = _line_end2;

						            // Skip newline after separator
						            if (_scan_pos <= _src_len) {
						                var _nl_char2 = string_char_at(_src_text, _scan_pos);
						                if (_nl_char2 == "\r") { _scan_pos += 1; }
						                if (_scan_pos <= _src_len && string_char_at(_src_text, _scan_pos) == "\n") { _scan_pos += 1; }
						            }

						            while (_scan_pos <= _src_len) {

						                var _row_end = __md_get_line_end_pos__(_src_text, _scan_pos);
						                var _row_text = "";

						                if (_row_end > _scan_pos) {
						                    _row_text = string_copy(_src_text, _scan_pos, _row_end - _scan_pos);
						                }

						                // Stop table at blank line or non-pipe line
						                if (string_trim(_row_text) == "") {
						                    break;
						                }

						                if (!__md_line_has_pipe__(_row_text)) {
						                    break;
						                }

						                // Stop if we encounter another separator-like line directly (rare but keep safe)
						                if (__md_is_table_separator_line__(_row_text)) {
						                    break;
						                }

						                _register_row(__md_split_table_row__(_row_text));

						                // Advance to next line start
						                _scan_pos = _row_end;

						                if (_scan_pos <= _src_len) {
						                    var _nl_char3 = string_char_at(_src_text, _scan_pos);
						                    if (_nl_char3 == "\r") { _scan_pos += 1; }
						                    if (_scan_pos <= _src_len && string_char_at(_src_text, _scan_pos) == "\n") { _scan_pos += 1; }
						                }
						            }

						            // Emit formatted table text (padded)
						            var _table_plain_start = string_length(_plain);

						            var _row_count = array_length(_rows);
						            if (_row_count > 0) {

						                // Header
						                _plain += __md_table_emit_row__(_rows[0], _col_widths);
						                _plain += "\n";

						                // Separator
						                _plain += __md_table_build_separator_row__(_col_widths);
						                _plain += "\n";

						                // Body
						                var _row_index = 1;
						                while (_row_index < _row_count) {
						                    _plain += __md_table_emit_row__(_rows[_row_index], _col_widths);
						                    _plain += "\n";
						                    _row_index += 1;
						                }
						            }

						            var _table_plain_end = string_length(_plain);

						            // Span the whole emitted table with code font
						            var _table_metric_state = __text_state_clone_patch__(_state, { style_value: __WW_Text_Glyph_Style.Regular, size_mul: 1 });

                            if (!is_undefined(markdown_code_font) && markdown_code_font != -1) {
                                __text_state_apply_patch__(_table_metric_state, { font_asset_or_minus1: markdown_code_font });
                            }

						            if ((_table_plain_end) > (_table_plain_start)) {
                    array_push(_spans, {
                        start_index: _table_plain_start,
                        end_index: _table_plain_end,
                        state: _table_metric_state
                    });
                }

						            // Resume state from after the table, reset span start to current plain end
						            _span_start = string_length(_plain);

						            // Advance source cursor to after the table block
						            _pos_src = _scan_pos;

						            _at_line_start = true;
						            continue;
						        }
						    }
						}
						
                        // Fenced code block
                        if (__md_starts_with__(_src_text, "```", _pos_src)) {

                            // Flush span before toggling
                            if ((string_length(_plain)) > (_span_start)) {
                    array_push(_spans, {
                        start_index: _span_start,
                        end_index: string_length(_plain),
                        state: __text_state_clone__(_state)
                    });
                }

                            _in_code_block = !_in_code_block;

                            // Configure code style when entering
                            if (_in_code_block) {
                                _bold = false;
                                _italic = false;
                                _in_code_inline = false;

                                _state.style_value = __WW_Text_Glyph_Style.Regular;
                                _state.size_mul = 1;

                                if (!is_undefined(markdown_code_font) && markdown_code_font != -1) {
                                    _state.font_asset_or_minus1 = markdown_code_font;
                                }
                            } else {
                                _state.font_asset_or_minus1 = -1;
                                _state.style_value = __WW_Text_Glyph_Style.Regular;
                                _state.size_mul = 1;
                            }

                            _span_start = string_length(_plain);

                            // Skip fence line content entirely
                            _pos_src += 3;
                            while (_pos_src <= _src_len && !__md_is_line_break__(string_char_at(_src_text, _pos_src))) {
                                _pos_src += 1;
                            }
                            continue;
                        }

                        // Heading (#, ##, ###) must be followed by space
						var _is_header_s = __md_starts_with__(_src_text, "-# ", _pos_src);
						var _is_header_1 = __md_starts_with__(_src_text, "# ", _pos_src);
						var _is_header_2 = __md_starts_with__(_src_text, "## ", _pos_src);
						var _is_header_3 = __md_starts_with__(_src_text, "### ", _pos_src);
						
                        if (_is_header_s || _is_header_1 || _is_header_2 || _is_header_3) {

                            if ((string_length(_plain)) > (_span_start)) {
			                    array_push(_spans, {
			                        start_index: _span_start,
			                        end_index: string_length(_plain),
			                        state: __text_state_clone__(_state)
			                    });
			                }

                            _bold = false;
                            _italic = false;

                            var _new_size = 1;

                            if (_is_header_3) {
                                _new_size = markdown_h3_size;
                                _pos_src += 4;
                            }
							else if (_is_header_2) {
                                _new_size = markdown_h2_size;
                                _pos_src += 3;
							}
							else if (_is_header_1) {
                                _new_size = markdown_h1_size;
                                _pos_src += 2;
                            }
							else { //if (_is_header_s) {
                                _new_size = markdown_hs_size;
                                _pos_src += 3;
                            }

                            _state.size_mul = _new_size;
                            _state.style_value = __md_normalize_style__(_bold, _italic);

                            _span_start = string_length(_plain);
                            _at_line_start = false;
                            continue;
                        }

                        // Horizontal rule --- (allow spaces)
                        if (__md_starts_with__(_src_text, "---", _pos_src)) {

                            // Confirm only spaces then line end
                            var _scan_src = _pos_src + 3;
                            var _only_spaces = true;

                            while (_scan_src <= _src_len) {
                                var _scan_char = string_char_at(_src_text, _scan_src);
                                if (__md_is_line_break__(_scan_char)) {
                                    break;
                                }
                                if (_scan_char != " ") {
                                    _only_spaces = false;
                                    break;
                                }
                                _scan_src += 1;
                            }

                            if (_only_spaces) {

                                if ((string_length(_plain)) > (_span_start)) {
                    array_push(_spans, {
                        start_index: _span_start,
                        end_index: string_length(_plain),
                        state: __text_state_clone__(_state)
                    });
                }

                                var _rule_start = string_length(_plain);

                                var _dash_count = 32;

                                var _old_font = draw_get_font();
                                if (font_exists(font)) {
                                    draw_set_font(font);
                                }

                                var _dash_w = string_width("-");
                                if (_dash_w <= 0) { _dash_w = 1; }

                                var _limit_w = 320;
                                if (!is_undefined(__textbox_parent__)) {
                                    _limit_w = __textbox_parent__.width;
                                }

                                _dash_count = floor(_limit_w / _dash_w);

                                if (_dash_count < 3) { _dash_count = 3; }
                                if (_dash_count > 256) { _dash_count = 256; }

                                _plain += string_repeat("-", _dash_count);

                                if (font_exists(_old_font) && _old_font != draw_get_font()) {
                                    draw_set_font(_old_font);
                                }

                                if ((string_length(_plain)) > (_rule_start)) {
                    array_push(_spans, {
                        start_index: _rule_start,
                        end_index: string_length(_plain),
                        state: __text_state_clone_patch__(_state, {
                                    style_value: __WW_Text_Glyph_Style.Regular,
                                    size_mul: 1,
                                    color: markdown_quote_color,
                                    alpha: markdown_quote_alpha,
                                    underline: __WW_Text_Glyph_Underline.None
                                })
                    });
                }

                                _span_start = string_length(_plain);

                                _pos_src = _scan_src;
                                continue;
                            }
                        }

                        // Task list: - [x] or - [ ] (case insensitive x)
                        if (__md_starts_with__(_src_text, "- [", _pos_src) || __md_starts_with__(_src_text, "* [", _pos_src)) {

                            if (_pos_src + 5 <= _src_len) {

                                var _left_bracket = string_char_at(_src_text, _pos_src + 2);
                                var _mark = string_char_at(_src_text, _pos_src + 3);
                                var _right_bracket = string_char_at(_src_text, _pos_src + 4);
                                var _after = string_char_at(_src_text, _pos_src + 5);

                                if (_left_bracket == "[" && _right_bracket == "]" && _after == " ") {

                                    if ((string_length(_plain)) > (_span_start)) {
                    array_push(_spans, {
                        start_index: _span_start,
                        end_index: string_length(_plain),
                        state: __text_state_clone__(_state)
                    });
                }

                                    var _lead = "- [ ] ";
                                    if (_mark == "x" || _mark == "X") {
                                        _lead = "- [x] ";
                                    }

                                    var _lead_start = string_length(_plain);
                                    _plain += _lead;

                                    if ((string_length(_plain)) > (_lead_start)) {
                    array_push(_spans, {
                        start_index: _lead_start,
                        end_index: string_length(_plain),
                        state: __text_state_clone_patch__(_state, {
                                    style_value: __WW_Text_Glyph_Style.Regular,
                                    size_mul: 1,
                                    color: markdown_quote_color,
                                    alpha: 1,
                                    underline: __WW_Text_Glyph_Underline.None,
                                })
                    });
                }

                                    _span_start = string_length(_plain);

                                    _pos_src += 6;
                                    _at_line_start = false;
                                    continue;
                                }
                            }
                        }

                        // Blockquote: > (optional space)
                        if (_char_val == ">") {

                            if ((string_length(_plain)) > (_span_start)) {
                    array_push(_spans, {
                        start_index: _span_start,
                        end_index: string_length(_plain),
                        state: __text_state_clone__(_state)
                    });
                }

                            var _quote_start = string_length(_plain);
                            _plain += "> ";

                            if ((string_length(_plain)) > (_quote_start)) {
                    array_push(_spans, {
                        start_index: _quote_start,
                        end_index: string_length(_plain),
                        state: __text_state_clone_patch__(_state, {
                                    style_value: __WW_Text_Glyph_Style.Regular,
                                    size_mul: 1,
                                    color: markdown_quote_color,
                                    alpha: markdown_quote_alpha,
                                    underline: __WW_Text_Glyph_Underline.None,
                                })
                    });
                }

                            _span_start = string_length(_plain);

                            _state.color = markdown_quote_color;
                            _state.alpha = markdown_quote_alpha;

                            _pos_src += 1;
                            if (_pos_src <= _src_len && string_char_at(_src_text, _pos_src) == " ") {
                                _pos_src += 1;
                            }

                            _at_line_start = false;
                            continue;
                        }

                        // Unordered list: "- " or "* "
                        if (__md_starts_with__(_src_text, "- ", _pos_src) || __md_starts_with__(_src_text, "* ", _pos_src)) {

                            if ((string_length(_plain)) > (_span_start)) {
                    array_push(_spans, {
                        start_index: _span_start,
                        end_index: string_length(_plain),
                        state: __text_state_clone__(_state)
                    });
                }

                            var _bul_start = string_length(_plain);
                            _plain += "- ";

                            if ((string_length(_plain)) > (_bul_start)) {
                    array_push(_spans, {
                        start_index: _bul_start,
                        end_index: string_length(_plain),
                        state: __text_state_clone_patch__(_state, {
                                    style_value: __WW_Text_Glyph_Style.Regular,
                                    size_mul: 1,
                                    color: markdown_quote_color,
                                    alpha: 1,
                                    underline: __WW_Text_Glyph_Underline.None,
                                })
                    });
                }

                            _span_start = string_length(_plain);

                            _pos_src += 2;
                            _at_line_start = false;
                            continue;
                        }

                        // Ordered list: digits "." space
                        if (__md_is_digit__(_char_val)) {

                            var _scan_num = _pos_src;
                            while (_scan_num <= _src_len && __md_is_digit__(string_char_at(_src_text, _scan_num))) {
                                _scan_num += 1;
                            }

                            if (_scan_num + 1 <= _src_len) {
                                if (string_char_at(_src_text, _scan_num) == "." && string_char_at(_src_text, _scan_num + 1) == " ") {

                                    if ((string_length(_plain)) > (_span_start)) {
                    array_push(_spans, {
                        start_index: _span_start,
                        end_index: string_length(_plain),
                        state: __text_state_clone__(_state)
                    });
                }

                                    var _num_len = (_scan_num + 1) - _pos_src + 1;
                                    var _lead_text = string_copy(_src_text, _pos_src, _num_len);

                                    var _lead_start2 = string_length(_plain);
                                    _plain += _lead_text;

                                    if ((string_length(_plain)) > (_lead_start2)) {
                    array_push(_spans, {
                        start_index: _lead_start2,
                        end_index: string_length(_plain),
                        state: __text_state_clone_patch__(_state, {
                                    style_value: __WW_Text_Glyph_Style.Regular,
                                    size_mul: 1,
                                    color: markdown_quote_color,
                                    alpha: 1,
                                    underline: __WW_Text_Glyph_Underline.None,
                                })
                    });
                }

                                    _span_start = string_length(_plain);

                                    _pos_src = _scan_num + 2;
                                    _at_line_start = false;
                                    continue;
                                }
                            }
                        }
                    }

                    // In fenced code block: only interpret closing fence at line start (handled above)
                    if (_in_code_block) {

                        if (__md_is_line_break__(_char_val)) {

                            _plain += _char_val;

                            if ((string_length(_plain) - 1) > (_span_start)) {
                    array_push(_spans, {
                        start_index: _span_start,
                        end_index: string_length(_plain) - 1,
                        state: __text_state_clone__(_state)
                    });
                }

                            _span_start = string_length(_plain) - 1;
                            _at_line_start = true;

                            _pos_src += 1;
                            continue;
                        }

                        _plain += _char_val;
                        _pos_src += 1;
                        _at_line_start = false;
                        continue;
                    }

                    // Inline parsing (not in fenced code block)

                    // Newline resets line-level state (quote color, heading size/style)
                    if (__md_is_line_break__(_char_val)) {

                        _plain += _char_val;

                        if ((string_length(_plain) - 1) > (_span_start)) {
                    array_push(_spans, {
                        start_index: _span_start,
                        end_index: string_length(_plain) - 1,
                        state: __text_state_clone__(_state)
                    });
                }

                        _bold = false;
                        _italic = false;
                        _strike = false;

                        __text_state_apply_patch__(_state, {
                            font_asset_or_minus1: -1,
                            style_value: __WW_Text_Glyph_Style.Regular,
                            size_mul: 1,
                            color: color,
                            alpha: alpha,
                            underline: __WW_Text_Glyph_Underline.None,
                            strike: __WW_Text_Glyph_Strike.None,
                            back_color: undefined,
                            back_alpha: undefined
                        });

                        _span_start = string_length(_plain) - 1;

                        _at_line_start = true;

                        // End of a table line: keep code font only within the line
                        if (_table_line_has_pipe) {
                            _state.font_asset_or_minus1 = -1;
                        }

                        _pos_src += 1;
                        continue;
                    }

                    // Backslash escapes for common punctuation
                    if (_char_val == "\\" && _pos_src + 1 <= _src_len && !_in_code_inline && !_in_code_block) {

                        var _next_char_escape = string_char_at(_src_text, _pos_src + 1);

                        // CommonMark/GFM allow escaping ASCII punctuation. Keep it pragmatic.
                        if (__md_is_punct__(_next_char_escape) || _next_char_escape == "\\" ) {

                            _plain += _next_char_escape;

                            _pos_src += 2;
                            _at_line_start = false;
                            continue;
                        }
                    }

                    // Inline code spans using variable-length backtick runs
                    if (_char_val == "`" && !_in_code_block) {

                        var _tick_count = __md_count_run__(_src_text, _pos_src, "`");

                        var _closer_pos = __md_find_backtick_closer__(_src_text, _pos_src + _tick_count, _tick_count);

                        if (_closer_pos > 0) {

                            if ((string_length(_plain)) > (_span_start)) {
                    array_push(_spans, {
                        start_index: _span_start,
                        end_index: string_length(_plain),
                        state: __text_state_clone__(_state)
                    });
                }

                            // Extract code content between runs (do not parse markdown inside)
                            var _code_start_src = _pos_src + _tick_count;
                            var _code_len = _closer_pos - _code_start_src;
                            var _code_text = "";
                            if (_code_len > 0) {
                                _code_text = string_copy(_src_text, _code_start_src, _code_len);
                            }

                            // GFM trims a single leading/trailing space in some cases, but keep literal for now.
                            var _code_plain_start = string_length(_plain);
                            _plain += _code_text;

                            var _code_state = __text_state_clone_patch__(_state, { style_value: __WW_Text_Glyph_Style.Regular, size_mul: 1 });

                            if (!is_undefined(markdown_code_font) && markdown_code_font != -1) {
                                __text_state_apply_patch__(_code_state, { font_asset_or_minus1: markdown_code_font });
                            }

                            if ((string_length(_plain)) > (_code_plain_start)) {
                    array_push(_spans, {
                        start_index: _code_plain_start,
                        end_index: string_length(_plain),
                        state: _code_state
                    });
                }

                            _span_start = string_length(_plain);

                            _pos_src = _closer_pos + _tick_count;
                            _at_line_start = false;
                            continue;
                        }

                        // No closer found: treat as literal backtick(s)
                        _plain += string_repeat("`", _tick_count);
                        _pos_src += _tick_count;
                        _at_line_start = false;
                        continue;
                    }

                    // Strikethrough ~~text~~
                    if (_char_val == "~" && _pos_src + 1 <= _src_len && string_char_at(_src_text, _pos_src + 1) == "~" && !_in_code_inline && !_in_code_block) {

                        if ((string_length(_plain)) > (_span_start)) {
		                    array_push(_spans, {
		                        start_index: _span_start,
		                        end_index: string_length(_plain),
		                        state: __text_state_clone__(_state)
		                    });
		                }

                        _strike = !_strike;

                        // Strikethrough is its own channel (can coexist with underline).
                        if (_strike) {
                            _state.strike = __WW_Text_Glyph_Strike.Line;
                        } else {
                            _state.strike = __WW_Text_Glyph_Strike.None;
                        }

						_span_start = string_length(_plain);

                        _pos_src += 2;
                        continue;
                    }
					
					// Underline __text__
                    if (_char_val == "_" && _pos_src + 1 <= _src_len && string_char_at(_src_text, _pos_src + 1) == "_" && !_in_code_inline && !_in_code_block) {
						if ((string_length(_plain)) > (_span_start)) {
		                    array_push(_spans, {
		                        start_index: _span_start,
		                        end_index: string_length(_plain),
		                        state: __text_state_clone__(_state)
		                    });
		                }
						
                        _underline = !_underline;
						
                        // Strikethrough is its own channel (can coexist with underline).
                        _state.underline = (_underline) ? __WW_Text_Glyph_Underline.Line : __WW_Text_Glyph_Strike.None;
                        
						_span_start = string_length(_plain);
                        _pos_src += 2;
                        continue;
                    }
					
                    // Emphasis with asterisks and underscores (GFM-style approximations)
                    if ((_char_val == "*" || _char_val == "_") && !_in_code_inline && !_in_code_block) {

                        var _is_underscore = (_char_val == "_");

                        var _run_count = __md_count_run__(_src_text, _pos_src, _char_val);

                        // Cap like GFM's practical behavior (we only care about 1..3)
                        if (_run_count > 3) { _run_count = 3; }

                        var _prev_char = "";
                        if (_pos_src > 1) { _prev_char = string_char_at(_src_text, _pos_src - 1); }

                        var _next_char = "";
                        if (_pos_src + _run_count <= _src_len) { _next_char = string_char_at(_src_text, _pos_src + _run_count); }

                        var _can_open = __md_can_open_emph__(_prev_char, _next_char, _is_underscore);
                        var _can_close = __md_can_close_emph__(_prev_char, _next_char, _is_underscore);

                        // If neither, treat as literal run
                        if (!_can_open && !_can_close) {

                            _plain += string_repeat(_char_val, _run_count);

                            _pos_src += _run_count;
                            _at_line_start = false;
                            continue;
                        }

                        // Prefer closing if possible (more intuitive for single-pass toggles)
                        var _use_close = _can_close;

                        if ((string_length(_plain)) > (_span_start)) {
                    array_push(_spans, {
                        start_index: _span_start,
                        end_index: string_length(_plain),
                        state: __text_state_clone__(_state)
                    });
                }

                        if (_run_count >= 3) {

                            // Toggle both when possible
                            if (_use_close) {
                                _bold = false;
                                _italic = false;
                            } else {
                                _bold = true;
                                _italic = true;
                            }

                        } else if (_run_count == 2) {

                            if (_use_close) {
                                _bold = false;
                            } else {
                                _bold = true;
                            }

                        } else {

                            if (_use_close) {
                                _italic = false;
                            } else {
                                _italic = true;
                            }
                        }

                        _state.style_value = __md_normalize_style__(_bold, _italic);

                        _span_start = string_length(_plain);

                        _pos_src += _run_count;
                        _at_line_start = false;
                        continue;
                    }
                    
					// Image: ![alt](src) -> emit [alt]
                    if (_char_val == "!" && _pos_src + 1 <= _src_len && string_char_at(_src_text, _pos_src + 1) == "[") {

                        var _alt_start_src = _pos_src + 2;
                        var _alt_end_src = __md_find_char_from__(_src_text, "]", _alt_start_src);

                        if (_alt_end_src > 0 && _alt_end_src + 1 <= _src_len && string_char_at(_src_text, _alt_end_src + 1) == "(") {

                            var _url_end_src = __md_find_char_from__(_src_text, ")", _alt_end_src + 2);
                            if (_url_end_src > 0) {

                                var _alt_text = string_copy(_src_text, _alt_start_src, _alt_end_src - _alt_start_src);

                                if ((string_length(_plain)) > (_span_start)) {
                    array_push(_spans, {
                        start_index: _span_start,
                        end_index: string_length(_plain),
                        state: __text_state_clone__(_state)
                    });
                }

                                var _img_start = string_length(_plain);
                                _plain += "[";
                                _plain += _alt_text;
                                _plain += "]";

                                if ((string_length(_plain)) > (_img_start)) {
                    array_push(_spans, {
                        start_index: _img_start,
                        end_index: string_length(_plain),
                        state: __text_state_clone_patch__(_state, {
                                    style_value: __WW_Text_Glyph_Style.Italic,
                                    size_mul: 1,
                                    color: markdown_quote_color,
                                    alpha: 1,
                                    underline: __WW_Text_Glyph_Underline.None
                                })
                    });
                }

                                _span_start = string_length(_plain);

                                _pos_src = _url_end_src + 1;
                                _at_line_start = false;
                                continue;
                            }
                        }
                    }

                    // Link: [title](url) -> emit title with link style
                    if (_char_val == "[") {

                        var _title_start_src = _pos_src + 1;
                        var _title_end_src = __md_find_char_from__(_src_text, "]", _title_start_src);

                        if (_title_end_src > 0 && _title_end_src + 1 <= _src_len && string_char_at(_src_text, _title_end_src + 1) == "(") {

                            var _url_end_src2 = __md_find_char_from__(_src_text, ")", _title_end_src + 2);

                            if (_url_end_src2 > 0) {

                                var _title_text = string_copy(_src_text, _title_start_src, _title_end_src - _title_start_src);

                                if ((string_length(_plain)) > (_span_start)) {
                    array_push(_spans, {
                        start_index: _span_start,
                        end_index: string_length(_plain),
                        state: __text_state_clone__(_state)
                    });
                }

                                var _title_plain_start = string_length(_plain);
                                _plain += _title_text;

                                if ((string_length(_plain)) > (_title_plain_start)) {
                    array_push(_spans, {
                        start_index: _title_plain_start,
                        end_index: string_length(_plain),
                        state: __text_state_clone_patch__(_state, {
                                    style_value: _state.style_value,
                                    size_mul: _state.size_mul,
                                    color: markdown_link_color,
                                    alpha: markdown_link_alpha,
                                    underline: markdown_link_underline,
                                })
                    });
                }

                                _span_start = string_length(_plain);

                                _pos_src = _url_end_src2 + 1;
                                _at_line_start = false;
                                continue;
                            }
                        }
                    }
					
                    // Emit the character as-is
                    _plain += _char_val;

                    _pos_src += 1;
                    _at_line_start = false;
                }

                // Flush
                if ((string_length(_plain)) > (_span_start)) {
                    array_push(_spans, {
                        start_index: _span_start,
                        end_index: string_length(_plain),
                        state: __text_state_clone__(_state)
                    });
                }

                __md_plain_text__ = _plain;

                var _plain_len = string_length(_plain);

                var _default_state = __text_state_make_default__();

                __md_build_runs_from_spans__(_plain_len, _spans, _default_state);
            };

        #endregion

        #region Override layout builder hook

                                    static __ensure_layout__ = function() {

                if (!__is_dirty__) { return; }

                var _text_value = "";
                if (!is_undefined(__textbox_parent__)) {
                    _text_value = __textbox_parent__.get_text();
                }
                if (_text_value == "") { _text_value = caption; }

                __display_text__ = _text_value;

                if (!markdown_enabled) {

                    var _default_state = __text_state_make_default__();
                    var _default_spans = [{
                        index_count: string_length(_text_value),
                        font_asset_or_minus1: _default_state.font_asset_or_minus1,
                        style_value: _default_state.style_value,
                        size_mul: _default_state.size_mul,
                        color: _default_state.color,
                        alpha: _default_state.alpha,
                        underline: _default_state.underline,
                        strike: _default_state.strike,
                        back_color: _default_state.back_color,
                        back_alpha: _default_state.back_alpha
                    }];

                    __layout__ = __build_layout__(_text_value, _default_spans);

                } else {

                    __md_parse__(_text_value);
                    __layout__ = __build_layout__(__md_plain_text__, __md_spans__);
                }

                __content_width__ = __layout__.get_content_width();
                __content_height__ = __layout__.get_content_height();
                __is_dirty__ = false;
            };

        #endregion

    #endregion
}
