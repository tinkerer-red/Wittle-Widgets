#region jsDoc
/// @func    WWTextProcessorBBCode
/// @desc    BBCode parser producing plain text + span array + align runs.
///          renderer.set_text_processor(WWTextProcessorBBCode);
/// @param   {String} _raw_text
/// @param   {Struct} _default_state
/// @returns {Struct} { text, spans, align_runs, widgets }
#endregion

function __ww_bbcode_find_u8__(_buff, _start, _endd, _target_u8) {

    var _pos = _start;
    while (_pos < _endd) {
        if (buffer_peek(_buff, _pos, buffer_u8) == _target_u8) {
            return _pos;
        }
        _pos += 1;
    }

    return -1;
}

function __ww_bbcode_init_input_buff__(_text) {
    static __bbcode_in_buff = buffer_create(0, buffer_grow, 1);

    buffer_seek(__bbcode_in_buff, buffer_seek_start, 0);
    buffer_write(__bbcode_in_buff, buffer_text, _text);
    var _byte_len = buffer_tell(__bbcode_in_buff);
    buffer_write(__bbcode_in_buff, buffer_u64, 0);

    return [ __bbcode_in_buff, _byte_len ];
}
function WWTextProcessorBBCode(_raw_text, _default_state) {

    var _ctx = __ww_textproc_ctx_begin__(_default_state);

    // Alignment runs in glyph-index space:
    // [{ start_index, end_index, align_value }, ...]
    var _align_runs = [];
    var _align_value = __WW_Text_Alignment.Left;

    if (variable_struct_exists(_ctx.state, "align_value")) {
        _align_value = _ctx.state.align_value;
    } else {
        _ctx.state.align_value = _align_value;
    }

    // Start of the current alignment span in output indices
    var _align_start = 0;

    if (is_undefined(_raw_text) || _raw_text == "") {
        var _res_empty = __ww_textproc_ctx_finish__(_ctx);
        _res_empty.align_runs = [];
        _res_empty.widgets = [];
        return _res_empty;
    }

    var _in_pair = __ww_bbcode_init_input_buff__(_raw_text);
    var _in_buff = _in_pair[0];
    var _in_len = _in_pair[1];

    // Stack entries: { tag_name, prev_state }
    var _state_stack = [];

    // Optional widgets (output index space)
    var _widgets = [];

    // Helper: flush current alignment run up to _ctx.out_len
    // (inline pattern - no closures)
    // NOTE: caller must ensure _ctx.out_len > _align_start
    // NOTE: updates _align_start to _ctx.out_len
    // (implemented as repeated code blocks where needed)

    var _pos = 0;
    while (_pos < _in_len) {

        // Emit plain text up to next '[' in a single chunk.
        var _open_pos = __ww_bbcode_find_u8__(_in_buff, _pos, _in_len, 91); // '['
        if (_open_pos < 0) {
            __ww_textproc_ctx_append_text__(_ctx, regex__buffer_read_text_range(_in_buff, _pos, _in_len));
            break;
        }

        if (_open_pos > _pos) {
            __ww_textproc_ctx_append_text__(_ctx, regex__buffer_read_text_range(_in_buff, _pos, _open_pos));
            _pos = _open_pos;
        }

        // Scan for closing bracket ']'
        var _close_pos = __ww_bbcode_find_u8__(_in_buff, _pos + 1, _in_len, 93); // ']'

        // No close bracket -> literal '['
        if (_close_pos < 0) {
            __ww_textproc_ctx_append_text__(_ctx, regex__buffer_read_text_range(_in_buff, _pos, _pos + 1));
            _pos += 1;
            continue;
        }

        var _tag_raw = regex__buffer_read_text_range(_in_buff, _pos + 1, _close_pos);
        var _tag_trim = string_trim(_tag_raw);
        var _tag = string_lower(_tag_trim);

        // Self-closing emitters
        if (_tag == "br" || _tag == "br/") {
            __ww_textproc_ctx_append_text__(_ctx, "\n");
            _pos = _close_pos + 1;
            continue;
        }

        if (_tag == "p" || _tag == "p/") {
            __ww_textproc_ctx_append_text__(_ctx, "\n\n");
            _pos = _close_pos + 1;
            continue;
        }

        // Font Awesome icon emitter: [fa, <real|string>, <real|string optional>]
        // - arg1: icon name (string) or packed glyph id/codepoint (number)
        // - arg2: optional style selector when arg1 is a name or raw codepoint
        //         string: "regular"|"solid"|"brands" (also: r/s/b, far/fas/fab)
        //         real: 1|2|3
        // - if arg1 is numeric > 16 bits, arg2 is ignored (packed glyph id)
        if (WW_FONT_AWESOME_ENABLED) {
            var _comma_pos_raw = string_pos(",", _tag_raw);
            if (_comma_pos_raw > 0) {
                var _fa_head = string_lower(string_trim(string_copy(_tag_raw, 1, _comma_pos_raw - 1)));
                if (_fa_head == "fa") {

                    var _args_raw = string_copy(_tag_raw, _comma_pos_raw + 1, string_length(_tag_raw) - _comma_pos_raw);
                    var _comma2 = string_pos(",", _args_raw);

                    var _arg1 = "";
                    var _arg2 = "";
                    if (_comma2 > 0) {
                        _arg1 = string_trim(string_copy(_args_raw, 1, _comma2 - 1));
                        _arg2 = string_trim(string_copy(_args_raw, _comma2 + 1, string_length(_args_raw) - _comma2));
                    } else {
                        _arg1 = string_trim(_args_raw);
                    }

                    // Strip optional quotes
                    if (string_length(_arg1) >= 2) {
                        var _a1c1 = string_char_at(_arg1, 1);
                        var _a1cN = string_char_at(_arg1, string_length(_arg1));
                        if ((_a1c1 == "\"" && _a1cN == "\"") || (_a1c1 == "'" && _a1cN == "'")) {
                            _arg1 = string_copy(_arg1, 2, string_length(_arg1) - 2);
                        }
                    }
                    if (string_length(_arg2) >= 2) {
                        var _a2c1 = string_char_at(_arg2, 1);
                        var _a2cN = string_char_at(_arg2, string_length(_arg2));
                        if ((_a2c1 == "\"" && _a2cN == "\"") || (_a2c1 == "'" && _a2cN == "'")) {
                            _arg2 = string_copy(_arg2, 2, string_length(_arg2) - 2);
                        }
                    }

                    var _packed_fa = -1;

                    // Try name lookup first (handles names like "0", "1", etc.)
                    _packed_fa = fa_icon_get(_arg1, (_arg2 == "") ? undefined : _arg2);

                    // If not a known name, try numeric forms.
                    if (_packed_fa < 0) {

                        // Basic numeric check for decimal int/float strings
                        var _is_num = (string_length(_arg1) > 0);
                        var _dot = 0;
                        if (_is_num) {
                            var _i = 1;
                            var _nlen = string_length(_arg1);
                            while (_i <= _nlen) {
                                var _ch = string_char_at(_arg1, _i);
                                if (_ch >= "0" && _ch <= "9") {
                                    // ok
                                } else if (_ch == ".") {
                                    _dot += 1;
                                    if (_dot > 1) { _is_num = false; break; }
                                } else if ((_ch == "-" || _ch == "+") && _i == 1) {
                                    // ok
                                } else {
                                    _is_num = false;
                                    break;
                                }
                                _i += 1;
                            }
                        }

                        if (_is_num) {
                            var _n = real(_arg1);

                            if (_n > 65535) {
                                // Packed glyph id (font_id is already in upper 16 bits)
                                _packed_fa = _n;
                            } else {
                                // Raw unicode codepoint; resolve style to pick the font_id
                                var _font_id = 2; // default: solid
                                if (_arg2 != "") {
                                    var _st = string_lower(_arg2);
                                    if (_st == "regular" || _st == "r" || _st == "far") { _font_id = 1; }
                                    else if (_st == "solid" || _st == "s" || _st == "fas") { _font_id = 2; }
                                    else if (_st == "brands" || _st == "brand" || _st == "b" || _st == "fab") { _font_id = 3; }
                                    else if (real(_arg2) == 1) { _font_id = 1; }
                                    else if (real(_arg2) == 2) { _font_id = 2; }
                                    else if (real(_arg2) == 3) { _font_id = 3; }
                                }
                                _packed_fa = _n + (_font_id << 16);
                            }
                        }
                    }

                    if (_packed_fa >= 0) {
                        var _fa_font = fa_get_font(_packed_fa);
                        if (_fa_font != -1) {
                            var _fa_chr = chr(fa_get_ord(_packed_fa));

                            // Emit a single-glyph span with a temporary font override.
                            var _prev_state_fa = __ww_textproc_state_clone__(_ctx.state);
                            __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
                            __ww_textproc_ctx_apply_patch__(_ctx, { font_asset: _fa_font });
                            _ctx.span_start = _ctx.out_len;

                            __ww_textproc_ctx_append_text__(_ctx, _fa_chr);

                            __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
                            _ctx.state = _prev_state_fa;
                            _ctx.span_start = _ctx.out_len;

                            _pos = _close_pos + 1;
                            continue;
                        }
                    }

                    // Failed to resolve -> treat as literal tag
                    __ww_textproc_ctx_append_text__(_ctx, "[" + _tag_raw + "]");
                    _pos = _close_pos + 1;
                    continue;
                }
            }
        }

        // Widgets (self-closing): [slider, value, min, max, step]
        //                     and: [plot, value]
        // Emits plain output text but also returns a widget descriptor anchored to that output.
        var _comma_pos_widgets = string_pos(",", _tag_raw);
        if (_comma_pos_widgets > 0) {

            var _widget_head = string_lower(string_trim(string_copy(_tag_raw, 1, _comma_pos_widgets - 1)));

            if (_widget_head == "slider") {

                var _parts = string_split(_tag_raw, ",");
                var _pcount = array_length(_parts);

                var _pi = 0;
                repeat (_pcount) {
                    _parts[_pi] = string_trim(_parts[_pi]);
                    _pi += 1;
                }

                var _value_text = (_pcount >= 2) ? _parts[1] : "0";
                var _value = real(_value_text);

                var _min = (_pcount >= 3) ? real(_parts[2]) : 0;
                var _max = (_pcount >= 4) ? real(_parts[3]) : 1;
                var _step = (_pcount >= 5) ? real(_parts[4]) : 0.01;

                if (_max < _min) {
                    var _tmp = _min;
                    _min = _max;
                    _max = _tmp;
                }

                if (_step <= 0) { _step = 0.01; }

                // Anchor at the start of the emitted value.
                var _start_index_widget = _ctx.out_len;
                __ww_textproc_ctx_append_text__(_ctx, _value_text);

                array_push(_widgets, {
                    kind: "inline",
                    type: "slider",
                    start_index: _start_index_widget,
                    value: _value,
                    min: _min,
                    max: _max,
                    step: _step,

                    // Basic default size in pixels; renderer may override height.
                    width: 96,
                    height: 0
                });

                _pos = _close_pos + 1;
                continue;
            }

            if (_widget_head == "plot") {

                var _parts2 = string_split(_tag_raw, ",");
                var _pcount2 = array_length(_parts2);

                var _plot_value_text = "";
                if (_pcount2 >= 2) {
                    _plot_value_text = string_trim(_parts2[1]);
                }

                // Ensure plot occupies its own line: emit a leading newline if needed,
                // then a space + newline for the plot line itself.
                if (_ctx.out_len > 0) {
                    var _chunk_count = array_length(_ctx.out_chunks);
                    if (_chunk_count > 0) {
                        var _last_chunk = _ctx.out_chunks[_chunk_count - 1];
                        var _lc_len = string_length(_last_chunk);
                        if (_lc_len > 0) {
                            var _lc_last = string_char_at(_last_chunk, _lc_len);
                            if (_lc_last != "\n") {
                                __ww_textproc_ctx_append_text__(_ctx, "\n");
                            }
                        }
                    }
                }

                var _start_index_plot = _ctx.out_len;
                __ww_textproc_ctx_append_text__(_ctx, " \n");

                array_push(_widgets, {
                    kind: "block",
                    type: "plot",
                    start_index: _start_index_plot,
                    value_text: _plot_value_text,

                    // 4 lines tall by default; renderer can translate to pixels.
                    height_lines: 4,
                    width: 0,
                    height: 0
                });

                // We already emitted a newline as part of the plot placeholder line.
                // If the source BBCode has a line break immediately after the tag,
                // consume it to avoid producing an extra blank line.
                _pos = _close_pos + 1;
                if (_pos < _in_len) {
                    var _n0 = buffer_peek(_in_buff, _pos, buffer_u8);
                    if (_n0 == 13) {
                        _pos += 1;
                        if (_pos < _in_len) {
                            var _n1 = buffer_peek(_in_buff, _pos, buffer_u8);
                            if (_n1 == 10) { _pos += 1; }
                        }
                    } else if (_n0 == 10) {
                        _pos += 1;
                    }
                }
                continue;
            }
        }

        // Closing tag
        if (string_length(_tag) > 0 && string_char_at(_tag, 1) == "/") {

            var _close_name = string_trim(string_copy(_tag, 2, string_length(_tag) - 1));
            var _stack_count = array_length(_state_stack);

            if (_stack_count > 0) {

                // Find matching open tag from the top.
                var _match_index = -1;
                var _search_index = _stack_count - 1;
                while (_search_index >= 0) {
                    if (_state_stack[_search_index].tag_name == _close_name) {
                        _match_index = _search_index;
                        break;
                    }
                    _search_index -= 1;
                }

                if (_match_index >= 0) {

                    __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

                    // Pop until match inclusive.
                    var _pop_index = _stack_count - 1;
                    while (_pop_index >= _match_index) {

                        var _prev_state = _state_stack[_pop_index].prev_state;

                        // Determine restored alignment (if present).
                        var _next_align = _align_value;
                        if (variable_struct_exists(_prev_state, "align_value")) {
                            _next_align = _prev_state.align_value;
                        }

                        // Only if the alignment actually changes do we flush a run boundary.
                        if (_next_align != _align_value) {

                            if (_ctx.out_len > _align_start) {
                                array_push(_align_runs, {
                                    start_index: _align_start,
                                    end_index: _ctx.out_len,
                                    align_value: _align_value
                                });
                                _align_start = _ctx.out_len;
                            }

                            _align_value = _next_align;
                        }

                        _ctx.state = _prev_state;
                        array_pop(_state_stack);

                        _pop_index -= 1;
                    }

                    _ctx.span_start = _ctx.out_len;

                    _pos = _close_pos + 1;
                    continue;
                }
            }

            // Unknown close -> literal
            __ww_textproc_ctx_append_text__(_ctx, "[" + _tag_raw + "]");
            _pos = _close_pos + 1;
            continue;
        }

        // Key=value tags
        var _equal_position = string_pos("=", _tag);
        if (_equal_position > 0) {

            var _key = string_lower(string_trim(string_copy(_tag, 1, _equal_position - 1)));
            var _val = string_trim(string_copy(_tag_raw, _equal_position + 1, string_length(_tag_raw) - _equal_position));

            if (_key == "color") {

                __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
                array_push(_state_stack, { tag_name: _key, prev_state: __ww_textproc_state_clone__(_ctx.state) });

                var _color_value = __ww_textproc_parse_html_color__(_val, _ctx.state.color);
                __ww_textproc_ctx_apply_patch__(_ctx, { color: _color_value });

                _ctx.span_start = _ctx.out_len;

                _pos = _close_pos + 1;
                continue;
            }

            if (_key == "bgcolor" || _key == "background" || _key == "back") {

                __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
                array_push(_state_stack, { tag_name: _key, prev_state: __ww_textproc_state_clone__(_ctx.state) });

                var _back_value = __ww_textproc_parse_html_color__(_val, _ctx.state.back_color);
                __ww_textproc_ctx_apply_patch__(_ctx, { back_color: _back_value, back_alpha: 1 });

                _ctx.span_start = _ctx.out_len;

                _pos = _close_pos + 1;
                continue;
            }

            if (_key == "alpha") {

                __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
                array_push(_state_stack, { tag_name: _key, prev_state: __ww_textproc_state_clone__(_ctx.state) });

                var _alpha_value = real(_val);
                if (_alpha_value < 0) { _alpha_value = 0; }
                if (_alpha_value > 1) { _alpha_value = 1; }
                __ww_textproc_ctx_apply_patch__(_ctx, { alpha: _alpha_value });

                _ctx.span_start = _ctx.out_len;

                _pos = _close_pos + 1;
                continue;
            }

            if (_key == "size") {

                __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
                array_push(_state_stack, { tag_name: _key, prev_state: __ww_textproc_state_clone__(_ctx.state) });

                var _size_value = real(_val);
                if (_size_value <= 0) { _size_value = 1; }
                __ww_textproc_ctx_apply_patch__(_ctx, { size_mul: _size_value });

                _ctx.span_start = _ctx.out_len;

                _pos = _close_pos + 1;
                continue;
            }

            // [url=target]text[/url] (visual only)
            if (_key == "url") {

                __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
                array_push(_state_stack, { tag_name: _key, prev_state: __ww_textproc_state_clone__(_ctx.state) });

                __ww_textproc_ctx_apply_patch__(_ctx, {
                    underline: __WW_Text_Glyph_Underline.Line,
                    color: make_color_rgb(102, 204, 255)
                });

                _ctx.span_start = _ctx.out_len;

                _pos = _close_pos + 1;
                continue;
            }
        }

        // Open tags (stateful)
        if (_tag == "b" || _tag == "i" || _tag == "u" || _tag == "s" || _tag == "warn" || _tag == "err" || _tag == "url" || _tag == "code" || _tag == "left" || _tag == "center" || _tag == "right") {

            __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
            array_push(_state_stack, { tag_name: _tag, prev_state: __ww_textproc_state_clone__(_ctx.state) });

            if (_tag == "b") {
                __ww_textproc_ctx_apply_patch__(_ctx, { style: __WW_Text_Glyph_Style.Bold });
            } else if (_tag == "i") {
                __ww_textproc_ctx_apply_patch__(_ctx, { style: __WW_Text_Glyph_Style.Italic });
            } else if (_tag == "u") {
                __ww_textproc_ctx_apply_patch__(_ctx, { underline: __WW_Text_Glyph_Underline.Line });
            } else if (_tag == "s") {
                __ww_textproc_ctx_apply_patch__(_ctx, { strike: __WW_Text_Glyph_Strike.Line });
            } else if (_tag == "warn") {
                __ww_textproc_ctx_apply_patch__(_ctx, { underline: __WW_Text_Glyph_Underline.Warning });
            } else if (_tag == "err") {
                __ww_textproc_ctx_apply_patch__(_ctx, { underline: __WW_Text_Glyph_Underline.Error });
            } else if (_tag == "url") {
                __ww_textproc_ctx_apply_patch__(_ctx, {
                    underline: __WW_Text_Glyph_Underline.Line,
                    color: make_color_rgb(102, 204, 255)
                });
            } else if (_tag == "code") {
                __ww_textproc_ctx_apply_patch__(_ctx, {
                    font_asset: fnt_ww_consolas_10,
                    color: make_color_rgb(220, 220, 230)
                });
            } else if (_tag == "left" || _tag == "center" || _tag == "right") {

                var _next_align2 = __WW_Text_Alignment.Left;
                if (_tag == "center") { _next_align2 = __WW_Text_Alignment.Center; }
                if (_tag == "right") { _next_align2 = __WW_Text_Alignment.Right; }

                if (_next_align2 != _align_value) {

                    if (_ctx.out_len > _align_start) {
                        array_push(_align_runs, {
                            start_index: _align_start,
                            end_index: _ctx.out_len,
                            align_value: _align_value
                        });
                        _align_start = _ctx.out_len;
                    }

                    _align_value = _next_align2;
                }

                __ww_textproc_ctx_apply_patch__(_ctx, { align_value: _next_align2 });
            }

            _ctx.span_start = _ctx.out_len;

            _pos = _close_pos + 1;
            continue;
        }

        // Unknown tag -> literal, preserve full token and do not affect stack.
        __ww_textproc_ctx_append_text__(_ctx, "[" + _tag_raw + "]");
        _pos = _close_pos + 1;
    }

    buffer_resize(_in_buff, 0);

    // Auto-close remaining tags: restore states, tracking alignment changes.
    var _remaining = array_length(_state_stack);
    while (_remaining > 0) {

        __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

        var _entry = _state_stack[_remaining - 1];
        var _prev_state2 = _entry.prev_state;

        var _next_align3 = _align_value;
        if (variable_struct_exists(_prev_state2, "align_value")) {
            _next_align3 = _prev_state2.align_value;
        }

        if (_next_align3 != _align_value) {

            if (_ctx.out_len > _align_start) {
                array_push(_align_runs, {
                    start_index: _align_start,
                    end_index: _ctx.out_len,
                    align_value: _align_value
                });
                _align_start = _ctx.out_len;
            }

            _align_value = _next_align3;
        }

        _ctx.state = _prev_state2;
        array_pop(_state_stack);

        _ctx.span_start = _ctx.out_len;

        _remaining -= 1;
    }

    // Final span flush
    __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

    // Final align flush (always apply EOF alignment if it covers anything)
    if (_ctx.out_len > _align_start) {
        array_push(_align_runs, {
            start_index: _align_start,
            end_index: _ctx.out_len,
            align_value: _align_value
        });
    }

    var _res = __ww_textproc_ctx_finish__(_ctx);
    _res.align_runs = _align_runs;
    _res.widgets = _widgets;
    return _res;
}
