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

		        __layout__ = __build_layout__(_source_text, undefined, undefined);
		        __content_width__ = __layout__.get_content_width();
		        __content_height__ = __layout__.get_content_height();

		        __is_dirty__ = false;
		        return;
		    }

		    var _parsed = __bbcode_parse__(_source_text);

		    __display_text__ = _parsed.text;

		    __layout__ = __build_layout__(_parsed.text, _parsed.metric_runs, _parsed.visual_runs);

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
			
			static __bbcode_state_make_default__ = function() {
				return {
					color_value: undefined,
					alpha_value: undefined,
					font_asset_or_minus1: -1,
					style_value: __WW_Text_Glyph_Style.Regular,
					size_mul: 1,
					underline_value: __WW_Text_Glyph_Underline.None,

					// 0=left, 1=center, 2=right (matches WWTextLayout.get_line_x_offset)
					align_value: 0
				};
			};

			static __bbcode_state_copy__ = function(_state) {
				return {
					color_value: _state.color_value,
					alpha_value: _state.alpha_value,
					font_asset_or_minus1: _state.font_asset_or_minus1,
					style_value: _state.style_value,
					size_mul: _state.size_mul,
					underline_value: _state.underline_value,
					align_value: _state.align_value
				};
			};

			static __bbcode_flush_metric_run__ = function(_runs, _state, _run_length) {
				
			    if (_run_length <= 0) {
			        return;
			    }

			    array_push(_runs, {
			        index_count: _run_length,
			        font_asset_or_minus1: _state.font_asset_or_minus1,
			        style_value: _state.style_value,
			        size_mul: _state.size_mul
			    });
			};

			static __bbcode_flush_visual_run__ = function(_runs, _state, _run_length) {

			    if (_run_length <= 0) {
			        return;
			    }

			    array_push(_runs, {
			        index_count: _run_length,
			        color: _state.color_value,
			        alpha: _state.alpha_value,
			        underline: _state.underline_value
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

			    var _state = __bbcode_state_make_default__();

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

			    return {
			        text: _plain_text,
			        metric_runs: _metric_runs,
			        visual_runs: _visual_runs,
			        align_runs: _align_runs
			    };
			};

		#endregion
		
		#region Layout
			
static __bbcode_build_layout_with_metric_runs__ = function(_plain_text, _metric_runs) {

	var _layout_instance = new WWTextLayout();

	if (_plain_text == "") {
		return _layout_instance;
	}

	var _wrap_width = 0;
	if (!is_undefined(__textbox_parent__)) {
		_wrap_width = __textbox_parent__.width;
	}

	var _wrap_enabled = (_wrap_width > 0);

	var _old_font = draw_get_font();
	if (font_exists(font)) {
		draw_set_font(font);
	}

	// Run cursor state (no closures)
	var _run_count = array_length(_metric_runs);
	var _run_index = 0;
	var _run_curr = undefined;
	var _run_end = 0;

	if (_run_count > 0) {
		_run_curr = _metric_runs[0];
		_run_end = _run_curr.end_index;
	}

	// Line segments are [start_index, end_index) over logical indices,
	// and MUST fully cover the plain text domain in increasing order.
	var _line_segments = [];
	var _text_length = string_length(_plain_text);

	var _line_start_index = 0;
	var _line_width = 0;
	var _line_height = 0;

	var _last_break_pos = -1;
	var _width_at_break = 0;
	var _height_at_break = 0;

	// Track current line chars so we can split remainder on wrap
	var _line_char_widths = [];
	var _line_char_heights = [];
	var _line_char_values = [];

	var _logical_index = 0;
	while (_logical_index < _text_length) {

		var _char_val = string_char_at(_plain_text, _logical_index + 1);

		// Advance run cursor to cover this index
		if (_run_count > 0) {
			while (_logical_index >= _run_end && _run_index < _run_count - 1) {
				_run_index += 1;
				_run_curr = _metric_runs[_run_index];
				_run_end = _run_curr.end_index;
			}
		}

		var _font_override = -1;
		var _style_value = __WW_Text_Glyph_Style.Regular;
		var _size_mul = 1;

		if (_run_count > 0 && !is_undefined(_run_curr)) {
			_font_override = _run_curr.font_asset_or_minus1;
			_style_value = _run_curr.style_value;
			_size_mul = _run_curr.size_mul;
			if (_size_mul <= 0) { _size_mul = 1; }
		}

		// Measurement font selection
		if (_font_override != -1 && font_exists(_font_override)) {
			if (draw_get_font() != _font_override) {
				draw_set_font(_font_override);
			}
		} else {
			if (font_exists(font) && draw_get_font() != font) {
				draw_set_font(font);
			}
		}

		// Hard break glyphs: include them as real glyph slots (so spans stay aligned),
		// but they contribute no width, and we end the current line INCLUDING the break.
		if (_char_val == "\n" || _char_val == "\r") {

			// Commit the break glyph into current line tracking
			array_push(_line_char_widths, 0);
			array_push(_line_char_heights, 0);
			array_push(_line_char_values, _char_val);

			array_push(_line_segments, {
				start_index: _line_start_index,
				end_index: _logical_index + 1, // include newline glyph in the line range
				force_wrapped: false
			});

			_line_start_index = _logical_index + 1;

			_line_width = 0;
			_line_height = 0;

			_last_break_pos = -1;
			_width_at_break = 0;
			_height_at_break = 0;

			_line_char_widths = [];
			_line_char_heights = [];
			_line_char_values = [];

			_logical_index += 1;
			continue;
		}

		var _base_width = 0;
		var _base_height = 0;

		if (_char_val == "\t") {
			_base_width = string_width("    ");
			_base_height = string_height("A");
		} else {
			_base_width = string_width(_char_val);
			_base_height = string_height(_char_val);
			if (_base_height <= 0) { _base_height = string_height("A"); }
		}

		var _adv_width = _base_width * _size_mul;
		var _adv_height = _base_height * _size_mul;

		// Wrap check (only if this would exceed and we already have something on the line)
		if (_wrap_enabled && _line_width > 0 && (_line_width + _adv_width) > _wrap_width) {

			var _break_index = -1;
			var _segment_width = _line_width;
			var _segment_height = _line_height;

			if (_last_break_pos >= 0) {
				_break_index = _last_break_pos;
				_segment_width = _width_at_break;
				_segment_height = _height_at_break;
			} else {
				_break_index = _logical_index;
				_segment_width = _line_width;
				_segment_height = _line_height;
			}

			array_push(_line_segments, {
				start_index: _line_start_index,
				end_index: _break_index,
				force_wrapped: true
			});

			// Remainder becomes new line state
			var _old_count = array_length(_line_char_values);

			var _new_widths = [];
			var _new_heights = [];
			var _new_values = [];

			var _remainder_width = 0;
			var _remainder_height = 0;

			var _pos_index = 0;
			while (_pos_index < _old_count) {

				var _abs_index = _line_start_index + _pos_index;

				if (_abs_index >= _break_index) {

					var _wid_val = _line_char_widths[_pos_index];
					var _hei_val = _line_char_heights[_pos_index];

					array_push(_new_widths, _wid_val);
					array_push(_new_heights, _hei_val);
					array_push(_new_values, _line_char_values[_pos_index]);

					_remainder_width += _wid_val;
					if (_hei_val > _remainder_height) { _remainder_height = _hei_val; }
				}

				_pos_index += 1;
			}

			_line_char_widths = _new_widths;
			_line_char_heights = _new_heights;
			_line_char_values = _new_values;

			_line_start_index = _break_index;
			_line_width = _remainder_width;
			_line_height = _remainder_height;

			_last_break_pos = -1;
			_width_at_break = 0;
			_height_at_break = 0;

			// Re-process current char in the new line context
			continue;
		}

		// Commit char into current line tracking
		array_push(_line_char_widths, _adv_width);
		array_push(_line_char_heights, _adv_height);
		array_push(_line_char_values, _char_val);

		_line_width += _adv_width;
		if (_adv_height > _line_height) { _line_height = _adv_height; }

		if (_char_val == " " || _char_val == "\t") {
			_last_break_pos = _logical_index + 1;
			_width_at_break = _line_width;
			_height_at_break = _line_height;
		}

		_logical_index += 1;
	}

	// Final segment (only if any remaining chars)
	if (_line_start_index < _text_length) {
		array_push(_line_segments, {
			start_index: _line_start_index,
			end_index: _text_length,
			force_wrapped: false
		});
	}

	// Pass 2: emit glyphs and lines. Reset run cursor for this pass.
	_run_index = 0;
	_run_curr = undefined;
	_run_end = 0;

	if (_run_count > 0) {
		_run_curr = _metric_runs[0];
		_run_end = _run_curr.end_index;
	}

	var _current_y = 0;

	var _segment_count = array_length(_line_segments);
	var _segment_index = 0;
	repeat (_segment_count) {

		var _seg = _line_segments[_segment_index];

		var _seg_start = _seg.start_index;
		var _seg_end = _seg.end_index;

		var _pos_x = 0;
		var _max_height = 0;

		// Compute line visible metrics while emitting glyphs
		var _emit_index = _seg_start;
		while (_emit_index < _seg_end) {

			var _char_emit = string_char_at(_plain_text, _emit_index + 1);

			// Advance run cursor
			if (_run_count > 0) {
				while (_emit_index >= _run_end && _run_index < _run_count - 1) {
					_run_index += 1;
					_run_curr = _metric_runs[_run_index];
					_run_end = _run_curr.end_index;
				}
			}

			var _font_emit = -1;
			var _style_emit = __WW_Text_Glyph_Style.Regular;
			var _size_emit = 1;

			if (_run_count > 0 && !is_undefined(_run_curr)) {
				_font_emit = _run_curr.font_asset_or_minus1;
				_style_emit = _run_curr.style_value;
				_size_emit = _run_curr.size_mul;
				if (_size_emit <= 0) { _size_emit = 1; }
			}

			// Font select
			if (_font_emit != -1 && font_exists(_font_emit)) {
				if (draw_get_font() != _font_emit) {
					draw_set_font(_font_emit);
				}
			} else {
				if (font_exists(font) && draw_get_font() != font) {
					draw_set_font(font);
				}
			}

						// Newline glyphs: emit as zero-size placeholders to preserve 1:1 indexing,
			// but they MUST contribute a fallback line height so blank lines exist.
			if (_char_emit == "\n" || _char_emit == "\r") {

				var _fallback_base_height = string_height("A");
				if (_fallback_base_height <= 0) { _fallback_base_height = 1; }

				var _fallback_scaled_height = _fallback_base_height * _size_emit;
				if (_fallback_scaled_height > _max_height) { _max_height = _fallback_scaled_height; }

				_layout_instance.add_glyph(
					_char_emit,
					_emit_index,
					_emit_index,
					1,
					_pos_x,
					_current_y,
					0,
					0,
					undefined,
					undefined,
					_font_emit,
					_style_emit,
					_size_emit,
					__WW_Text_Glyph_Underline.None
				);

				_emit_index += 1;
				continue;
			}


			var _base_wid = 0;
			var _base_hei = 0;

			if (_char_emit == "\t") {
				_base_wid = string_width("    ");
				_base_hei = string_height("A");
			} else {
				_base_wid = string_width(_char_emit);
				_base_hei = string_height(_char_emit);
				if (_base_hei <= 0) { _base_hei = string_height("A"); }
			}

			var _scaled_hei = _base_hei * _size_emit;
			if (_scaled_hei > _max_height) { _max_height = _scaled_hei; }

			_layout_instance.add_glyph(
				_char_emit,
				_emit_index,
				_emit_index,
				1,
				_pos_x,
				_current_y,
				_base_wid,
				_base_hei,
				undefined,
				undefined,
				_font_emit,
				_style_emit,
				_size_emit,
				__WW_Text_Glyph_Underline.None
			);

			_pos_x += (_base_wid * _size_emit);
			_emit_index += 1;
		}

		// Line text should not include trailing hard break glyphs
		var _line_text = "";
		var _text_end = _seg_end;

		if (_text_end > _seg_start) {
			var _tail_char = string_char_at(_plain_text, _text_end);
			if (_tail_char == "\n" || _tail_char == "\r") {
				_text_end -= 1;
			}
		}

		if (_text_end > _seg_start) {
			_line_text = string_copy(_plain_text, _seg_start + 1, _text_end - _seg_start);
		}

		_layout_instance.add_line(
			_line_text,
			_seg_start,
			_seg_end, // includes newline glyph if present
			_pos_x,
			_max_height,
			_current_y,
			_seg.force_wrapped,
			0
		);

		_current_y += _max_height;

		_segment_index += 1;
	}

	if (font_exists(_old_font) && draw_get_font() != _old_font) {
		draw_set_font(_old_font);
	}

	return _layout_instance;
};

		#endregion
		
		#region Builtin tags (instance-owned)

			static __bbcode_install_builtins__ = function() {

				#region Style tags

					// [b]
					__bbcode_tags__[$ "b"] = {
						on_open: function(_renderer, _state, _arg_string) {
							var _new_state = _renderer.__bbcode_state_copy__(_state);

							if (_new_state.style_value == __WW_Text_Glyph_Style.Italic) {
								_new_state.style_value = __WW_Text_Glyph_Style.Bold_Italic;
							} else if (_new_state.style_value == __WW_Text_Glyph_Style.Regular) {
								_new_state.style_value = __WW_Text_Glyph_Style.Bold;
							}

							return _new_state;
						}
					};

					// [i]
					__bbcode_tags__[$ "i"] = {
						on_open: function(_renderer, _state, _arg_string) {
							var _new_state = _renderer.__bbcode_state_copy__(_state);

							if (_new_state.style_value == __WW_Text_Glyph_Style.Bold) {
								_new_state.style_value = __WW_Text_Glyph_Style.Bold_Italic;
							} else if (_new_state.style_value == __WW_Text_Glyph_Style.Regular) {
								_new_state.style_value = __WW_Text_Glyph_Style.Italic;
							}

							return _new_state;
						}
					};

					// [u]
					__bbcode_tags__[$ "u"] = {
						on_open: function(_renderer, _state, _arg_string) {
							var _new_state = _renderer.__bbcode_state_copy__(_state);
							_new_state.underline_value = __WW_Text_Glyph_Underline.Line;
							return _new_state;
						}
					};

					// [warn]
					__bbcode_tags__[$ "warn"] = {
						on_open: function(_renderer, _state, _arg_string) {
							var _new_state = _renderer.__bbcode_state_copy__(_state);
							_new_state.underline_value = __WW_Text_Glyph_Underline.Warning;
							return _new_state;
						}
					};

					// [err]
					__bbcode_tags__[$ "err"] = {
						on_open: function(_renderer, _state, _arg_string) {
							var _new_state = _renderer.__bbcode_state_copy__(_state);
							_new_state.underline_value = __WW_Text_Glyph_Underline.Error;
							return _new_state;
						}
					};

				#endregion

				#region Color/alpha/size

					// [color=#rrggbb]
					__bbcode_tags__[$ "color"] = {
						on_open: function(_renderer, _state, _arg_string) {
							var _new_state = _renderer.__bbcode_state_copy__(_state);

							var _col = _renderer.__bbcode_parse_color_ascii__(_arg_string);
							if (!is_undefined(_col)) {
								_new_state.color_value = _col;
							}

							return _new_state;
						}
					};

					// [alpha=0..1]
					__bbcode_tags__[$ "alpha"] = {
						on_open: function(_renderer, _state, _arg_string) {
							var _new_state = _renderer.__bbcode_state_copy__(_state);

							var _alp = real(_arg_string);
							if (_alp < 0) { _alp = 0; }
							if (_alp > 1) { _alp = 1; }

							_new_state.alpha_value = _alp;
							return _new_state;
						}
					};

					// [size=...]
					__bbcode_tags__[$ "size"] = {
						on_open: function(_renderer, _state, _arg_string) {
							var _new_state = _renderer.__bbcode_state_copy__(_state);

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
							var _new_state = _renderer.__bbcode_state_copy__(_state);

							_new_state.underline_value = __WW_Text_Glyph_Underline.Line;
							_new_state.color_value = make_color_rgb(102, 204, 255);

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
							var _new_state = _renderer.__bbcode_state_copy__(_state);

							_new_state.font_asset_or_minus1 = fnt_ww_consolas_10;
							_new_state.color_value = make_color_rgb(220, 220, 230);

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
							var _new_state = _renderer.__bbcode_state_copy__(_state);
							_new_state.align_value = __WW_Text_Alignment.Left;
							return _new_state;
						}
					};

					__bbcode_tags__[$ "center"] = {
						on_open: function(_renderer, _state, _arg_string) {
							var _new_state = _renderer.__bbcode_state_copy__(_state);
							_new_state.align_value = __WW_Text_Alignment.Center;
							return _new_state;
						}
					};

					__bbcode_tags__[$ "right"] = {
						on_open: function(_renderer, _state, _arg_string) {
							var _new_state = _renderer.__bbcode_state_copy__(_state);
							_new_state.align_value = __WW_Text_Alignment.Right;
							return _new_state;
						}
					};
					
				#endregion
			};

		#endregion

	#endregion
	
}
