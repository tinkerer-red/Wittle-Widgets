#region jsDoc
/// @func    WWTextProcessorBBCode
/// @desc    BBCode parser producing plain text + span array + align runs.
///          renderer.set_text_processor(WWTextProcessorBBCode);
/// @param   {String} _raw_text
/// @param   {Struct} _default_state
/// @returns {Struct} { text, spans, align_runs }
#endregion
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
        return _res_empty;
    }

    var _length = string_length(_raw_text);

    // Stack entries: { tag_name, prev_state }
    var _state_stack = [];

    // Helper: flush current alignment run up to _ctx.out_len
    // (inline pattern - no closures)
    // NOTE: caller must ensure _ctx.out_len > _align_start
    // NOTE: updates _align_start to _ctx.out_len
    // (implemented as repeated code blocks where needed)

    var _index = 1;
    while (_index <= _length) {

        var _character = string_char_at(_raw_text, _index);

        if (_character != "[") {
            __ww_textproc_ctx_append_text__(_ctx, _character);
            _index += 1;
            continue;
        }

        // Scan for closing bracket
        var _close_index = 0;
        var _scan_index = _index + 1;

        while (_scan_index <= _length) {
            if (string_char_at(_raw_text, _scan_index) == "]") {
                _close_index = _scan_index;
                break;
            }
            _scan_index += 1;
        }

        // No close bracket -> literal
        if (_close_index == 0) {
            __ww_textproc_ctx_append_text__(_ctx, _character);
            _index += 1;
            continue;
        }

        var _tag_raw = string_copy(_raw_text, _index + 1, (_close_index - _index) - 1);
        var _tag_trim = string_trim(_tag_raw);
        var _tag = string_lower(_tag_trim);

        // Self-closing emitters
        if (_tag == "br" || _tag == "br/") {
            __ww_textproc_ctx_append_text__(_ctx, "\n");
            _index = _close_index + 1;
            continue;
        }

        if (_tag == "p" || _tag == "p/") {
            __ww_textproc_ctx_append_text__(_ctx, "\n\n");
            _index = _close_index + 1;
            continue;
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

                    _index = _close_index + 1;
                    continue;
                }
            }

            // Unknown close -> literal
            __ww_textproc_ctx_append_text__(_ctx, "[" + _tag_raw + "]");
            _index = _close_index + 1;
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

                _index = _close_index + 1;
                continue;
            }

            if (_key == "bgcolor" || _key == "background" || _key == "back") {

                __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
                array_push(_state_stack, { tag_name: _key, prev_state: __ww_textproc_state_clone__(_ctx.state) });

                var _back_value = __ww_textproc_parse_html_color__(_val, _ctx.state.back_color);
                __ww_textproc_ctx_apply_patch__(_ctx, { back_color: _back_value, back_alpha: 1 });

                _ctx.span_start = _ctx.out_len;

                _index = _close_index + 1;
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

                _index = _close_index + 1;
                continue;
            }

            if (_key == "size") {

                __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
                array_push(_state_stack, { tag_name: _key, prev_state: __ww_textproc_state_clone__(_ctx.state) });

                var _size_value = real(_val);
                if (_size_value <= 0) { _size_value = 1; }
                __ww_textproc_ctx_apply_patch__(_ctx, { size_mul: _size_value });

                _ctx.span_start = _ctx.out_len;

                _index = _close_index + 1;
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

                _index = _close_index + 1;
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

            _index = _close_index + 1;
            continue;
        }

        // Unknown tag -> literal, preserve full token and do not affect stack.
        __ww_textproc_ctx_append_text__(_ctx, "[" + _tag_raw + "]");
        _index = _close_index + 1;
    }

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
    return _res;
}
