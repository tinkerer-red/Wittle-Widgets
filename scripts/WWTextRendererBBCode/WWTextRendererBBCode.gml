#region jsDoc
/// @func    WWTextRendererBBCode()
/// @desc    BBCode renderer with an instance-owned tag registry (no extra objects).
///         Plugins register tags on the renderer instance.
///         Parser + helpers are private static functions (no globals).
/// @returns {Struct.WWTextRendererBbcode}
#endregion
function WWTextRendererBBCode() : WWTextRendererBase() constructor {

    debug_name = "WWTextRendererBbcode";

    #region Public

        // Enable/disable BBCode parsing
        bbcode_enabled = true;

        // Instance-owned registry: tag_name -> handler struct
        // Handler shape:
        // {
        //   on_open: function(_renderer, _state, _arg_string) -> Struct new_state,
        //   on_close: function(_renderer, _state) -> Struct new_state (optional)
        // }
        __bbcode_tags__ = {};

        // Builtins installed per instance (keep simple)
        __bbcode_install_builtins__();

        #region jsDoc
        /// @func   set_bbcode_enabled()
        /// @param  {Bool} _enabled
        /// @returns {Struct.WWTextRendererBbcode}
        #endregion
        static set_bbcode_enabled = function(_enabled) {
            if (bbcode_enabled == _enabled) {
                return self;
            }
            bbcode_enabled = _enabled;
            __mark_dirty__();
            return self;
        };

        #region jsDoc
        /// @func   register_bbcode_tag()
        /// @desc   Register or replace a BBCode tag handler on THIS renderer instance.
        /// @param  {String} _tag_name
        /// @param  {Struct} _handler
        /// @returns {Struct.WWTextRendererBbcode}
        #endregion
        static register_bbcode_tag = function(_tag_name, _handler) {
            if (is_undefined(_tag_name) || _tag_name == "") {
                return self;
            }
            if (is_undefined(_handler)) {
                return self;
            }
            __bbcode_tags__[$ _tag_name] = _handler;
            __mark_dirty__();
            return self;
        };

        #region jsDoc
        /// @func   unregister_bbcode_tag()
        /// @desc   Removes a tag handler from THIS renderer instance.
        /// @param  {String} _tag_name
        /// @returns {Struct.WWTextRendererBbcode}
        #endregion
        static unregister_bbcode_tag = function(_tag_name) {
            if (!is_undefined(__bbcode_tags__[$ _tag_name])) {
                __bbcode_tags__[$ _tag_name] = undefined;
                __mark_dirty__();
            }
            return self;
        };

        #region jsDoc
        /// @func   clear_bbcode_tags()
        /// @desc   Removes all registered tags (including builtins). You can re-install builtins afterwards.
        /// @returns {Struct.WWTextRendererBbcode}
        #endregion
        static clear_bbcode_tags = function() {
            __bbcode_tags__ = {};
            __mark_dirty__();
            return self;
        };

        #region jsDoc
        /// @func   install_bbcode_builtins()
        /// @desc   Re-registers builtin tags onto THIS renderer instance.
        /// @returns {Struct.WWTextRendererBbcode}
        #endregion
        static install_bbcode_builtins = function() {
            __bbcode_install_builtins__();
            __mark_dirty__();
            return self;
        };

    #endregion

    #region Private

        __bbcode_plain_text__ = "";
        __bbcode_spans__ = [];
        __bbcode_metric_runs__ = [];

        // Override: parse -> build layout on plain text -> apply spans to glyph records
        static __ensure_layout__ = function() {

            if (!__is_dirty__) {
                return;
            }

            var _source_text = "";

            if (!is_undefined(__textbox_parent__)) {
                _source_text = __textbox_parent__.get_text();
            }

            if (_source_text == "") {
                _source_text = caption;
            }

            if (!bbcode_enabled) {

                __display_text__ = _source_text;

				var _default_spans = [{
				    index_count: string_length(_source_text),
				    font_asset: font,
				    style: __WW_Text_Glyph_Style.Regular,
				    size_mul: 1,
				    color: color,
				    alpha: alpha,
				    underline: __WW_Text_Glyph_Underline.None,
				    back_color: 0,
				    back_alpha: 0,
				    strike: __WW_Text_Glyph_Strike.None
				}];

				__layout__ = __build_layout__(_source_text, _default_spans);
	            __content_width__ = __layout__.get_content_width();
	            __content_height__ = __layout__.get_content_height();

	            __is_dirty__ = false;
	            return;
	        }

            var _parsed = __bbcode_parse__(_source_text);

            __display_text__ = _parsed.text;

            __layout__ = __build_layout__(_parsed.text, _parsed.spans);

            // Alignment is still a post-pass because it depends on final line breaks.
            var _align_width = __layout__.get_content_width();
            if (!is_undefined(__textbox_parent__)) {
                _align_width = __textbox_parent__.width;
            }

            __bbcode_apply_align_runs_to_layout__(__layout__, _parsed.align_runs, _align_width);

            __content_width__ = __layout__.get_content_width();
            __content_height__ = __layout__.get_content_height();

            __is_dirty__ = false;
        };

        #region BBCode state + span helpers

			static __bbcode_flush_metric_run__ = function(_runs, _state, _run_length) {

                if (_run_length <= 0) {
                    return;
                }

				array_push(_runs, {
				    index_count: _run_length,
				    font_asset: _state.font_asset,
				    style: _state.style,
				    size_mul: _state.size_mul
				});
            };

            static __bbcode_flush_visual_run__ = function(_runs, _state, _run_length) {

                if (_run_length <= 0) {
                    return;
                }

                array_push(_runs, {
                    index_count: _run_length,
                    color: _state.color,
                    alpha: _state.alpha,
                    underline: _state.underline
                });
            };

            static __bbcode_flush_align_run__ = function(_runs, _state, _run_length) {

                if (_run_length <= 0) {
                    return;
                }

                array_push(_runs, {
                    index_count: _run_length,
                    align_value: _state.align_value
                });
            };

            static __bbcode_merge_runs__ = function(_metric_runs, _visual_runs) {

                static __empty_arr = [];

                _metric_runs ??= __empty_arr;
                _visual_runs ??= __empty_arr;

                var _metric_count = array_length(_metric_runs);
                var _visual_count = array_length(_visual_runs);

                // If either side is missing, just return the other (already in span format)
                if (_metric_count <= 0) { return _visual_runs; }
                if (_visual_count <= 0) { return _metric_runs; }

                var _spans = [];

                var _metric_index = 0;
                var _visual_index = 0;

                var _metric_run = _metric_runs[0];
                var _visual_run = _visual_runs[0];

                var _metric_remaining = _metric_run.index_count;
                var _visual_remaining = _visual_run.index_count;

                // Hardening - avoid lockups
                if (_metric_remaining <= 0) { _metric_remaining = 999999999; }
                if (_visual_remaining <= 0) { _visual_remaining = 999999999; }

                while (true) {

                    var _take_count = _metric_remaining;
                    if (_visual_remaining < _take_count) { _take_count = _visual_remaining; }

					var _state = __text_state_make_default__();
					
					_state.font_asset = _metric_run.font_asset;
					_state.style = _metric_run.style;
					_state.size_mul = _metric_run.size_mul;
					
					_state.color = _visual_run.color;
					_state.alpha = _visual_run.alpha;
					_state.underline = _visual_run.underline;
					
					_state.strike = __WW_Text_Glyph_Strike.None;
					_state.back_color = 0;
					_state.back_alpha = 0;
					
					array_push(_spans, __text_span_run_from_state__(_take_count, _state));


                    _metric_remaining -= _take_count;
                    _visual_remaining -= _take_count;

                    // Advance metric
                    if (_metric_remaining <= 0) {

                        if (_metric_index >= _metric_count - 1) {
                            break;
                        }

                        _metric_index += 1;
                        _metric_run = _metric_runs[_metric_index];
                        _metric_remaining = _metric_run.index_count;

                        if (_metric_remaining <= 0) { _metric_remaining = 999999999; }
                    }

                    // Advance visual
                    if (_visual_remaining <= 0) {

                        if (_visual_index >= _visual_count - 1) {
                            break;
                        }

                        _visual_index += 1;
                        _visual_run = _visual_runs[_visual_index];
                        _visual_remaining = _visual_run.index_count;

                        if (_visual_remaining <= 0) { _visual_remaining = 999999999; }
                    }
                }

                return _spans;
            };
			
            static __bbcode_apply_align_runs_to_layout__ = function(_layout_instance, _align_runs, _available_width) {

                if (is_undefined(_layout_instance)) { return; }

                var _layout_data = _layout_instance.get_layout_data();
                if (is_undefined(_layout_data)) { return; }

                var _lines = _layout_data.lines;
                var _line_count = _layout_data.lines_count;
                if (_line_count <= 0) { return; }

                var _glyphs = _layout_data.glyphs;
                var _glyph_count = _layout_data.glyphs_count;

                var _run_count = array_length(_align_runs);
                if (_run_count <= 0) {
                    return;
                }

                var _run_index = 0;
                var _run_curr = _align_runs[0];
                var _run_end = _run_curr.index_count;

                var _line_index = 0;
                repeat (_line_count) {

                    var _line_base = _line_index * __WW_Layout_Line.__Size__;
                    var _line_start = _lines[_line_base + __WW_Layout_Line.Start_Index];
                    var _line_end = _lines[_line_base + __WW_Layout_Line.End_Index];

                    while (_line_start >= _run_end && _run_index < _run_count - 1) {
                        _run_index += 1;
                        _run_curr = _align_runs[_run_index];
                        _run_end += _run_curr.index_count;
                    }

                    var _line_align = _run_curr.align_value;
                    _lines[_line_base + __WW_Layout_Line.Alignment] = _line_align;

                    var _xoff = _layout_instance.get_line_x_offset(_line_index, _available_width);

                    if (_xoff != 0 && _line_end > _line_start) {

                        if (_line_start < 0) { _line_start = 0; }
                        if (_line_end > _glyph_count) { _line_end = _glyph_count; }

                        var _glyph_index = _line_start;
                        while (_glyph_index < _line_end) {

                            var _glyph_base = _glyph_index * __WW_Layout_Glyph.__Size__;
                            _glyphs[_glyph_base + __WW_Layout_Glyph.X] = _glyphs[_glyph_base + __WW_Layout_Glyph.X] + _xoff;

                            _glyph_index += 1;
                        }
                    }

                    _line_index += 1;
                }
            };

        #endregion

        #region Byte utilities

            static __bbcode_is_space_byte__ = function(_byte_val) {
                return (_byte_val == 32 || _byte_val == 9);
            };

            static __bbcode_lower_ascii_byte__ = function(_byte_val) {
                if (_byte_val >= 65 && _byte_val <= 90) {
                    return _byte_val + 32;
                }
                return _byte_val;
            };

            static __bbcode_utf8_byte_count__ = function(_first_byte) {
                if (_first_byte < 128) { return 1; }
                if (_first_byte >= 192 && _first_byte <= 223) { return 2; }
                if (_first_byte >= 224 && _first_byte <= 239) { return 3; }
                if (_first_byte >= 240 && _first_byte <= 247) { return 4; }
                return 1;
            };

            // Writes _literal (string) into _buffer_out as bytes, without leaving an extra terminator byte behind.
            static __bbcode_write_literal_ascii__ = function(_buffer_out, _literal) {

                buffer_write(_buffer_out, buffer_string, _literal);

                // buffer_string writes a trailing 0 terminator, we need to "remove" it by rewinding 1 byte.
                var _out_pos = buffer_tell(_buffer_out);
                if (_out_pos > 0) {
                    buffer_seek(_buffer_out, buffer_seek_start, _out_pos - 1);
                }
            };

            static __bbcode_ascii_bytes_to_string__ = function(_bytes, _start_index, _count) {

                if (_count <= 0) {
                    return "";
                }

                var _buffer_tmp = buffer_create(_count + 1, buffer_fixed, 1);
                buffer_seek(_buffer_tmp, buffer_seek_start, 0);

                var _indx = 0;
                repeat (_count) {
                    buffer_write(_buffer_tmp, buffer_u8, _bytes[_start_index + _indx]);
                    _indx += 1;
                }

                buffer_write(_buffer_tmp, buffer_u8, 0);
                buffer_seek(_buffer_tmp, buffer_seek_start, 0);

                var _out_text = buffer_read(_buffer_tmp, buffer_string);
                buffer_delete(_buffer_tmp);

                return _out_text;
            };

        #endregion

        #region Tag reader + tag parser (ASCII only)

            // Reads tag content into _buffer_tag until ']' (ASCII only). Returns true if ok.
            // IMPORTANT: bounded by _input_limit so we never read outside the buffer.
            // Assumes '[' has already been consumed and the input cursor is positioned AFTER it.
            static __bbcode_read_tag_ascii__ = function(_buffer_inp, _buffer_tag, _input_limit, _start_after_bracket_pos) {

                buffer_seek(_buffer_tag, buffer_seek_start, 0);

                var _count = 0;

                // If we fail, restore cursor so caller can treat '[' as literal and continue safely.
                while (buffer_tell(_buffer_inp) < _input_limit) {

                    var _byte_val = buffer_read(_buffer_inp, buffer_u8);

                    // ']'
                    if (_byte_val == 93) {
                        buffer_write(_buffer_tag, buffer_u8, 0);
                        return (_count > 0);
                    }

                    // Disallow newlines in tags
                    if (_byte_val == 10 || _byte_val == 13) {
                        buffer_seek(_buffer_inp, buffer_seek_start, _start_after_bracket_pos);
                        return false;
                    }

                    // ASCII-only tag syntax
                    if (_byte_val >= 128) {
                        buffer_seek(_buffer_inp, buffer_seek_start, _start_after_bracket_pos);
                        return false;
                    }

                    if (_count >= 480) {
                        buffer_seek(_buffer_inp, buffer_seek_start, _start_after_bracket_pos);
                        return false;
                    }

                    _byte_val = __bbcode_lower_ascii_byte__(_byte_val);

                    buffer_write(_buffer_tag, buffer_u8, _byte_val);
                    _count += 1;
                }

                // Reached end-of-input without finding ']'
                buffer_seek(_buffer_inp, buffer_seek_start, _start_after_bracket_pos);
                return false;
            };

            // Parses _buffer_tag (nul-terminated ASCII) into:
            // { is_close, name, arg, raw_literal, raw_len }
            static __bbcode_parse_tag_ascii__ = function(_buffer_tag) {

                buffer_seek(_buffer_tag, buffer_seek_start, 0);

                var _bytes = [];
                while (true) {
                    var _byte_val = buffer_read(_buffer_tag, buffer_u8);
                    if (_byte_val == 0) { break; }
                    array_push(_bytes, _byte_val);
                }

                var _leng = array_length(_bytes);
                if (_leng <= 0) {
                    return undefined;
                }

                // Trim
                var _left = 0;
                var _right = _leng - 1;

                while (_left <= _right) {
                    if (!__bbcode_is_space_byte__(_bytes[_left])) { break; }
                    _left += 1;
                }

                while (_right >= _left) {
                    if (!__bbcode_is_space_byte__(_bytes[_right])) { break; }
                    _right -= 1;
                }

                if (_right < _left) {
                    return undefined;
                }

                var _is_close = false;
                if (_bytes[_left] == 47) { // '/'
                    _is_close = true;
                    _left += 1;

                    while (_left <= _right) {
                        if (!__bbcode_is_space_byte__(_bytes[_left])) { break; }
                        _left += 1;
                    }

                    if (_left > _right) {
                        return undefined;
                    }
                }

                // Find '='
                var _equa = -1;
                var _scan = _left;
                while (_scan <= _right) {
                    if (_bytes[_scan] == 61) { // '='
                        _equa = _scan;
                        break;
                    }
                    _scan += 1;
                }

                // Name range
                var _name_left = _left;
                var _name_right = (_equa >= 0) ? (_equa - 1) : _right;

                while (_name_right >= _name_left) {
                    if (!__bbcode_is_space_byte__(_bytes[_name_right])) { break; }
                    _name_right -= 1;
                }

                if (_name_right < _name_left) {
                    return undefined;
                }

                var _name = __bbcode_ascii_bytes_to_string__(_bytes, _name_left, (_name_right - _name_left) + 1);

                // Arg
                var _arg = "";
                if (_equa >= 0) {

                    var _arg_left = _equa + 1;
                    var _arg_right = _right;

                    while (_arg_left <= _arg_right) {
                        if (!__bbcode_is_space_byte__(_bytes[_arg_left])) { break; }
                        _arg_left += 1;
                    }

                    while (_arg_right >= _arg_left) {
                        if (!__bbcode_is_space_byte__(_bytes[_arg_right])) { break; }
                        _arg_right -= 1;
                    }

                    if (_arg_right >= _arg_left) {
                        _arg = __bbcode_ascii_bytes_to_string__(_bytes, _arg_left, (_arg_right - _arg_left) + 1);
                    }
                }

                var _raw_inner = __bbcode_ascii_bytes_to_string__(_bytes, 0, _leng);
                var _raw_literal = "[" + _raw_inner + "]";
                var _raw_len = _leng + 2;

                return {
                    is_close: _is_close,
                    name: _name,
                    arg: _arg,
                    raw_literal: _raw_literal,
                    raw_len: _raw_len
                };
            };

        #endregion

        #region Color parsing (ASCII arg)

            static __bbcode_hex_nibble_ascii__ = function(_byte_val) {

                // '0'..'9'
                if (_byte_val >= 48 && _byte_val <= 57) { return _byte_val - 48; }
                // 'a'..'f'
                if (_byte_val >= 97 && _byte_val <= 102) { return 10 + (_byte_val - 97); }
                // 'A'..'F'
                if (_byte_val >= 65 && _byte_val <= 70) { return 10 + (_byte_val - 65); }

                return -1;
            };

            // Parses "#rrggbb" or "rrggbb" (ASCII) -> Color or undefined
            static __bbcode_parse_color_ascii__ = function(_arg_string) {

                if (is_undefined(_arg_string) || _arg_string == "") {
                    return undefined;
                }

                // Convert arg string to bytes once
                var _buffer_arg = buffer_create(64, buffer_grow, 1);
                buffer_seek(_buffer_arg, buffer_seek_start, 0);
                buffer_write(_buffer_arg, buffer_string, _arg_string);

                var _arg_end = buffer_tell(_buffer_arg);

                var _arg_limit = _arg_end;
                if (_arg_end > 0) {
                    buffer_seek(_buffer_arg, buffer_seek_start, _arg_end - 1);
                    var _last_byte = buffer_read(_buffer_arg, buffer_u8);
                    if (_last_byte == 0) {
                        _arg_limit = _arg_end - 1;
                    }
                }

                buffer_seek(_buffer_arg, buffer_seek_start, 0);

                var _bytes = [];
                while (buffer_tell(_buffer_arg) < _arg_limit) {
                    var _bval = buffer_read(_buffer_arg, buffer_u8);
                    array_push(_bytes, _bval);
                    if (array_length(_bytes) > 16) { break; }
                }

                buffer_delete(_buffer_arg);

                var _len = array_length(_bytes);
                if (_len <= 0) {
                    return undefined;
                }

                var _start = 0;
                if (_bytes[0] == 35) { // '#'
                    _start = 1;
                    _len -= 1;
                }

                if (_len != 6) {
                    return undefined;
                }

                // Lowercase
                var _ii = 0;
                repeat (6) {
                    _bytes[_start + _ii] = __bbcode_lower_ascii_byte__(_bytes[_start + _ii]);
                    _ii += 1;
                }

                var _rhi = __bbcode_hex_nibble_ascii__(_bytes[_start + 0]);
                var _rlo = __bbcode_hex_nibble_ascii__(_bytes[_start + 1]);
                var _ghi = __bbcode_hex_nibble_ascii__(_bytes[_start + 2]);
                var _glo = __bbcode_hex_nibble_ascii__(_bytes[_start + 3]);
                var _bhi = __bbcode_hex_nibble_ascii__(_bytes[_start + 4]);
                var _blo = __bbcode_hex_nibble_ascii__(_bytes[_start + 5]);

                if (_rhi < 0 || _rlo < 0 || _ghi < 0 || _glo < 0 || _bhi < 0 || _blo < 0) {
                    return undefined;
                }

                var _rr = (_rhi * 16) + _rlo;
                var _gg = (_ghi * 16) + _glo;
                var _bb = (_bhi * 16) + _blo;

                return make_color_rgb(_rr, _gg, _bb);
            };

        #endregion

        #region Text emitters (self-closing) support

            // Writes an emitter string into _buffer_out (WITHOUT leaving a trailing 0),
            // and returns how many logical glyph indices that emitted text should advance.
            // This counts UTF-8 codepoints by counting leading bytes.
            static __bbcode_emit_text__ = function(_buffer_out, _emit_text) {

                if (is_undefined(_emit_text) || _emit_text == "") {
                    return 0;
                }

                // Convert emit string to bytes so we can count codepoints without string_*.
                var _buffer_emit = buffer_create(64, buffer_grow, 1);
                buffer_seek(_buffer_emit, buffer_seek_start, 0);
                buffer_write(_buffer_emit, buffer_string, _emit_text);

                var _emit_end = buffer_tell(_buffer_emit);

                // Exclude trailing 0 written by buffer_string
                var _emit_limit = _emit_end;
                if (_emit_end > 0) {
                    buffer_seek(_buffer_emit, buffer_seek_start, _emit_end - 1);
                    var _last_byte = buffer_read(_buffer_emit, buffer_u8);
                    if (_last_byte == 0) {
                        _emit_limit = _emit_end - 1;
                    }
                }

                // Copy bytes to output
                buffer_seek(_buffer_emit, buffer_seek_start, 0);

                var _byte_indx = 0;
                while (_byte_indx < _emit_limit) {
                    var _byte_val = buffer_read(_buffer_emit, buffer_u8);
                    buffer_write(_buffer_out, buffer_u8, _byte_val);
                    _byte_indx += 1;
                }

                // Count UTF-8 codepoints: count leading bytes
                buffer_seek(_buffer_emit, buffer_seek_start, 0);

                var _codepoint_count = 0;

                _byte_indx = 0;
                while (_byte_indx < _emit_limit) {

                    var _lead_byte = buffer_read(_buffer_emit, buffer_u8);

                    // Leading byte detection:
                    // ASCII: 0xxxxxxx
                    // 2-byte lead: 110xxxxx
                    // 3-byte lead: 1110xxxx
                    // 4-byte lead: 11110xxx
                    // Continuations are 10xxxxxx, which we do NOT count as new codepoints.
                    if ((_lead_byte < 128) || (_lead_byte >= 192)) {
                        _codepoint_count += 1;
                    }

                    _byte_indx += 1;
                }

                buffer_delete(_buffer_emit);

                return _codepoint_count;
            };

        #endregion

        #region Main parser

            static __bbcode_parse__ = function(_text) {

                var _buffer_inp = buffer_create(256, buffer_grow, 1);
                buffer_seek(_buffer_inp, buffer_seek_start, 0);
                buffer_write(_buffer_inp, buffer_string, _text);

                var _input_end = buffer_tell(_buffer_inp);

                var _input_limit = _input_end;
                if (_input_end > 0) {
                    buffer_seek(_buffer_inp, buffer_seek_start, _input_end - 1);
                    var _last_byte = buffer_read(_buffer_inp, buffer_u8);
                    if (_last_byte == 0) {
                        _input_limit = _input_end - 1;
                    }
                }

                buffer_seek(_buffer_inp, buffer_seek_start, 0);

                var _buffer_out = buffer_create(256, buffer_grow, 1);
                buffer_seek(_buffer_out, buffer_seek_start, 0);

                var _buffer_tag = buffer_create(512, buffer_fixed, 1);

                var _metric_runs = [];
                var _visual_runs = [];
                var _align_runs = [];

                var _state = __text_state_make_default__();

                // stack entries: { tag_name, prev_state }
                var _stack = [];

                // run lengths in glyph indices
                var _metric_len = 0;
                var _visual_len = 0;
                var _align_len = 0;

                // flush all three, then reset lens
                // (no closures - inline pattern)
                var _out_index = 0;

                while (buffer_tell(_buffer_inp) < _input_limit) {

                    var _byte_val = buffer_read(_buffer_inp, buffer_u8);

                    if (_byte_val < 128) {

                        // Backslash escapes for literal '[' and ']'
                        if (_byte_val == 92) { // '\\'

                            if (buffer_tell(_buffer_inp) < _input_limit) {

                                var _peek_byte = buffer_read(_buffer_inp, buffer_u8);

                                if (_peek_byte == 91 || _peek_byte == 93) {
                                    buffer_write(_buffer_out, buffer_u8, _peek_byte);

                                    _metric_len += 1;
                                    _visual_len += 1;
                                    _align_len += 1;

                                    _out_index += 1;
                                    continue;
                                }

                                // Not an escapable character: emit both bytes literally.
                                buffer_write(_buffer_out, buffer_u8, 92);
                                buffer_write(_buffer_out, buffer_u8, _peek_byte);

                                _metric_len += 2;
                                _visual_len += 2;
                                _align_len += 2;

                                _out_index += 2;
                                continue;
                            }

                            // Backslash at end of input
                            buffer_write(_buffer_out, buffer_u8, 92);

                            _metric_len += 1;
                            _visual_len += 1;
                            _align_len += 1;

                            _out_index += 1;
                            continue;
                        }

                        if (_byte_val == 91) { // '['

                            var _start_after_bracket_pos = buffer_tell(_buffer_inp);
                            var _tag_ok = __bbcode_read_tag_ascii__(_buffer_inp, _buffer_tag, _input_limit, _start_after_bracket_pos);

                            if (_tag_ok) {

                                var _tag_info = __bbcode_parse_tag_ascii__(_buffer_tag);

                                if (!is_undefined(_tag_info)) {

                                    if (_tag_info.is_close) {

                                        var _stack_count = array_length(_stack);

                                        if (_stack_count > 0) {

                                            // Forgiving close: find a matching open tag anywhere in the stack.
                                            // If found, implicitly close any intermediate tags.
                                            var _match_index = -1;
                                            var _search_index = _stack_count - 1;
                                            while (_search_index >= 0) {
                                                if (_stack[_search_index].tag_name == _tag_info.name) {
                                                    _match_index = _search_index;
                                                    break;
                                                }
                                                _search_index -= 1;
                                            }

                                            if (_match_index >= 0) {

                                                // flush up to here under current state
                                                __bbcode_flush_metric_run__(_metric_runs, _state, _metric_len);
                                                __bbcode_flush_visual_run__(_visual_runs, _state, _visual_len);
                                                __bbcode_flush_align_run__(_align_runs, _state, _align_len);

                                                _metric_len = 0;
                                                _visual_len = 0;
                                                _align_len = 0;

                                                var _pop_index = _stack_count - 1;
                                                while (_pop_index >= _match_index) {

                                                    var _entry = _stack[_pop_index];

                                                    // optional handler close (for each implicitly closed tag)
                                                    var _handler_close = __bbcode_tags__[$ _entry.tag_name];
                                                    if (!is_undefined(_handler_close)) {
                                                        if (variable_struct_exists(_handler_close, "on_close")) {
                                                            var _close_func = _handler_close[$ "on_close"];
                                                            if (is_callable(_close_func)) {
                                                                _state = _close_func(self, _state);
                                                            }
                                                        }
                                                    }

                                                    // restore previous state
                                                    _state = _entry.prev_state;
                                                    array_pop(_stack);

                                                    _pop_index -= 1;
                                                }

                                                continue;
                                            }
                                        }

                                        // literal close tag
                                        __bbcode_write_literal_ascii__(_buffer_out, _tag_info.raw_literal);

                                        _metric_len += _tag_info.raw_len;
                                        _visual_len += _tag_info.raw_len;
                                        _align_len += _tag_info.raw_len;

                                        _out_index += _tag_info.raw_len;
                                        continue;
                                    }
                                    else {

                                        var _handler = __bbcode_tags__[$ _tag_info.name];

                                        // self-closing emitters
                                        if (!is_undefined(_handler)) {

                                            if (variable_struct_exists(_handler, "is_self_closing") && _handler.is_self_closing) {

                                                if (variable_struct_exists(_handler, "emit_text")) {

                                                    var _emit_text = _handler.emit_text;

                                                    var _emit_count = __bbcode_emit_text__(_buffer_out, _emit_text);

                                                    _metric_len += _emit_count;
                                                    _visual_len += _emit_count;
                                                    _align_len += _emit_count;

                                                    _out_index += _emit_count;
                                                }

                                                continue;
                                            }
                                        }

                                        // normal open tag that changes state
                                        if (!is_undefined(_handler)) {
                                            if (variable_struct_exists(_handler, "on_open")) {

                                                var _open_func = _handler[$ "on_open"];

                                                if (is_callable(_open_func)) {

                                                        if (array_length(_stack) >= 64) {

                                                        __bbcode_write_literal_ascii__(_buffer_out, _tag_info.raw_literal);

                                                        _metric_len += _tag_info.raw_len;
                                                        _visual_len += _tag_info.raw_len;
                                                        _align_len += _tag_info.raw_len;

                                                        _out_index += _tag_info.raw_len;
                                                        continue;
                                                    }

                                                        // flush runs before state changes
                                                    __bbcode_flush_metric_run__(_metric_runs, _state, _metric_len);
                                                    __bbcode_flush_visual_run__(_visual_runs, _state, _visual_len);
                                                    __bbcode_flush_align_run__(_align_runs, _state, _align_len);

                                                    _metric_len = 0;
                                                    _visual_len = 0;
                                                    _align_len = 0;

                                                    array_push(_stack, {
                                                        tag_name: _tag_info.name,
                                                        prev_state: _state
                                                    });

                                                    _state = _open_func(self, _state, _tag_info.arg);
                                                    continue;
                                                }
                                            }
                                        }

                                        // literal open tag
                                        __bbcode_write_literal_ascii__(_buffer_out, _tag_info.raw_literal);

                                        _metric_len += _tag_info.raw_len;
                                        _visual_len += _tag_info.raw_len;
                                        _align_len += _tag_info.raw_len;

                                        _out_index += _tag_info.raw_len;
                                        continue;
                                    }
                                }
                            }

                            // Failed parse -> literal '['
                            buffer_write(_buffer_out, buffer_u8, 91);

                            _metric_len += 1;
                            _visual_len += 1;
                            _align_len += 1;

                            _out_index += 1;
                            continue;
                        }

                        // normal ASCII byte
                        buffer_write(_buffer_out, buffer_u8, _byte_val);

                        _metric_len += 1;
                        _visual_len += 1;
                        _align_len += 1;

                        _out_index += 1;
                        continue;
                    }

                    // UTF-8 passthrough: copy bytes, count as 1 glyph index
                    var _utf8_len = __bbcode_utf8_byte_count__(_byte_val);

                    buffer_write(_buffer_out, buffer_u8, _byte_val);

                    var _copied = 1;
                    while (_copied < _utf8_len && buffer_tell(_buffer_inp) < _input_limit) {

                        var _next_byte = buffer_read(_buffer_inp, buffer_u8);
                        buffer_write(_buffer_out, buffer_u8, _next_byte);

                        _copied += 1;
                    }

                    _metric_len += 1;
                    _visual_len += 1;
                    _align_len += 1;

                    _out_index += 1;
                }

                // auto-close: just restore states, but also flush final runs
                var _remaining = array_length(_stack);
                while (_remaining > 0) {

                    // flush up to end under current state
                    __bbcode_flush_metric_run__(_metric_runs, _state, _metric_len);
                    __bbcode_flush_visual_run__(_visual_runs, _state, _visual_len);
                    __bbcode_flush_align_run__(_align_runs, _state, _align_len);

                    _metric_len = 0;
                    _visual_len = 0;
                    _align_len = 0;

                    var _top2 = _stack[_remaining - 1];
                    _state = _top2.prev_state;
                    array_pop(_stack);

                    _remaining -= 1;
                }

                // final flush
                __bbcode_flush_metric_run__(_metric_runs, _state, _metric_len);
                __bbcode_flush_visual_run__(_visual_runs, _state, _visual_len);
                __bbcode_flush_align_run__(_align_runs, _state, _align_len);

                buffer_write(_buffer_out, buffer_u8, 0);
                buffer_seek(_buffer_out, buffer_seek_start, 0);

                var _plain_text = buffer_read(_buffer_out, buffer_string);

                buffer_delete(_buffer_inp);
                buffer_delete(_buffer_out);
                buffer_delete(_buffer_tag);

                var _spans = __bbcode_merge_runs__(_metric_runs, _visual_runs);

                return {
                    text: _plain_text,
                    spans: _spans,
                    align_runs: _align_runs
                };
            };

        #endregion
		
        #region Builtin tags (instance-owned)

            static __bbcode_install_builtins__ = function() {

                #region Style tags

                    // [b]
                    __bbcode_tags__[$ "b"] = {
                        on_open: function(_renderer, _state, _arg_string) {
                            var _new_state = _renderer.__text_state_clone__(_state);

                            if (_new_state.style == __WW_Text_Glyph_Style.Italic) {
                                _new_state.style = __WW_Text_Glyph_Style.Bold_Italic;
                            } else if (_new_state.style == __WW_Text_Glyph_Style.Regular) {
                                _new_state.style = __WW_Text_Glyph_Style.Bold;
                            }

                            return _new_state;
                        }
                    };

                    // [i]
                    __bbcode_tags__[$ "i"] = {
                        on_open: function(_renderer, _state, _arg_string) {
                            var _new_state = _renderer.__text_state_clone__(_state);

                            if (_new_state.style == __WW_Text_Glyph_Style.Bold) {
                                _new_state.style = __WW_Text_Glyph_Style.Bold_Italic;
                            } else if (_new_state.style == __WW_Text_Glyph_Style.Regular) {
                                _new_state.style = __WW_Text_Glyph_Style.Italic;
                            }

                            return _new_state;
                        }
                    };

                    // [u]
                    __bbcode_tags__[$ "u"] = {
                        on_open: function(_renderer, _state, _arg_string) {
                            var _new_state = _renderer.__text_state_clone__(_state);
                            _new_state.underline = __WW_Text_Glyph_Underline.Line;
                            return _new_state;
                        }
                    };

                    // [warn]
                    __bbcode_tags__[$ "warn"] = {
                        on_open: function(_renderer, _state, _arg_string) {
                            var _new_state = _renderer.__text_state_clone__(_state);
                            _new_state.underline = __WW_Text_Glyph_Underline.Warning;
                            return _new_state;
                        }
                    };

                    // [err]
                    __bbcode_tags__[$ "err"] = {
                        on_open: function(_renderer, _state, _arg_string) {
                            var _new_state = _renderer.__text_state_clone__(_state);
                            _new_state.underline = __WW_Text_Glyph_Underline.Error;
                            return _new_state;
                        }
                    };

                #endregion

                #region Color/alpha/size

                    // [color=#rrggbb]
                    __bbcode_tags__[$ "color"] = {
                        on_open: function(_renderer, _state, _arg_string) {
                            var _new_state = _renderer.__text_state_clone__(_state);

                            var _col = _renderer.__bbcode_parse_color_ascii__(_arg_string);
                            if (!is_undefined(_col)) {
                                _new_state.color = _col;
                            }

                            return _new_state;
                        }
                    };

                    // [alpha=0..1]
                    __bbcode_tags__[$ "alpha"] = {
                        on_open: function(_renderer, _state, _arg_string) {
                            var _new_state = _renderer.__text_state_clone__(_state);

                            var _alp = real(_arg_string);
                            if (_alp < 0) { _alp = 0; }
                            if (_alp > 1) { _alp = 1; }

                            _new_state.alpha = _alp;
                            return _new_state;
                        }
                    };

                    // [size=...]
                    __bbcode_tags__[$ "size"] = {
                        on_open: function(_renderer, _state, _arg_string) {
                            var _new_state = _renderer.__text_state_clone__(_state);

                            var _mul = real(_arg_string);
                            if (_mul <= 0) { _mul = 1; }

                            _new_state.size_mul = _mul;
                            return _new_state;
                        }
                    };

                #endregion

                #region Text emitters (self-closing)

                    // [br]
                    __bbcode_tags__[$ "br"] = {
                        is_self_closing: true,
                        emit_text: "\n"
                    };

                    // [p]
                    __bbcode_tags__[$ "p"] = {
                        is_self_closing: true,
                        emit_text: "\n\n"
                    };

                #endregion

                #region Links

                    // [url]text[/url] and [url=target]text[/url]
                    // Visual-only for now (underline + light blue). You can extend state/spans later with a link id.
                    __bbcode_tags__[$ "url"] = {
                        on_open: function(_renderer, _state, _arg_string) {
                            var _new_state = _renderer.__text_state_clone__(_state);

                            _new_state.underline = __WW_Text_Glyph_Underline.Line;
                            _new_state.color = make_color_rgb(102, 204, 255);

                            return _new_state;
                        },
                        on_close: function(_renderer, _state) {
                            return _state;
                        }
                    };

                #endregion

                #region Code

                    // [code]...[/code]
                    // NOTE: uses fnt_consolas_10 as the demo monospace font. Swap to whatever your project standard is.
                    __bbcode_tags__[$ "code"] = {
                        on_open: function(_renderer, _state, _arg_string) {
                            var _new_state = _renderer.__text_state_clone__(_state);

                            _new_state.font_asset = fnt_ww_consolas_10;
                            _new_state.color = make_color_rgb(220, 220, 230);

                            return _new_state;
                        },
                        on_close: function(_renderer, _state) {
                            return _state;
                        }
                    };

                #endregion

                #region Alignment

                    // Alignment blocks (paired tags): [left]...[/left], etc.
                    __bbcode_tags__[$ "left"] = {
                        on_open: function(_renderer, _state, _arg_string) {
                            var _new_state = _renderer.__text_state_clone__(_state);
                            _new_state.align_value = __WW_Text_Alignment.Left;
                            return _new_state;
                        }
                    };

                    __bbcode_tags__[$ "center"] = {
                        on_open: function(_renderer, _state, _arg_string) {
                            var _new_state = _renderer.__text_state_clone__(_state);
                            _new_state.align_value = __WW_Text_Alignment.Center;
                            return _new_state;
                        }
                    };

                    __bbcode_tags__[$ "right"] = {
                        on_open: function(_renderer, _state, _arg_string) {
                            var _new_state = _renderer.__text_state_clone__(_state);
                            _new_state.align_value = __WW_Text_Alignment.Right;
                            return _new_state;
                        }
                    };

                #endregion
            };

        #endregion

    #endregion

}
