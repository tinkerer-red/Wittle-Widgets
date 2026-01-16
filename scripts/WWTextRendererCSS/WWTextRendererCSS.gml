#region jsDoc
/// @func    WWTextRendererCSS()
/// @desc    CSS-like inline markup renderer built on WWTextRendererBase.
///          Converts a small HTML/CSS subset into plain text + formatting runs,
///          then delegates layout + VB baking to the base renderer.
///
///          Supported markup (subset):
///          - <span class="a b" style="..."> ... </span>
///          - <b> <i> <u> <s> (s currently tracked but requires base support to draw)
///          - <br> and <br/>
///          - Self-closing tags are tolerated.
///
///          Supported stylesheet subset:
///          - Class rules only: .class_name { prop: value; ... }
///          - No combinators, no pseudo-classes/elements.
///
///          Supported properties (subset):
///          - color: #rgb/#rrggbb/rgb()/rgba()
///          - opacity: 0..1
///          - background-color: tracked (requires base support to draw)
///          - font-family: maps via user-provided resolver (optional)
///          - font-size: em, %, px (px treated as scale relative to renderer font height)
///          - font-weight: normal|bold|100..900
///          - font-style: normal|italic
///          - text-decoration / text-decoration-line: underline|line-through|none
///          - text-align: left|center|right (applied as a post-pass)
///          - white-space: normal|nowrap|pre|pre-wrap (global-only in this renderer)
///          - tab-size: integer (spaces) (global-only in this renderer)
///          - overflow-wrap / word-break: tracked (requires base option to disable long-word breaks)
///
///          Notes:
///          - This renderer is intentionally NOT a browser. It is an inline run emitter.
///          - Anything that requires per-span layout behavior is either approximated or tracked for future base support.
///
/// @returns {Struct.WWTextRendererCSS}
#endregion
function WWTextRendererCSS() : WWTextRendererBase() constructor {

    debug_name = "WWTextRendererCSS";

    #region Public

        // Enables parsing. When disabled, behaves like base renderer.
        css_enabled = true;

        // Optional stylesheet text for class rules.
        css_stylesheet_text = "";

        // Global-only behavior flags. These are applied to the whole region.
        // Values: "pre-wrap", "pre", "normal", "nowrap"
        css_white_space = "pre-wrap";

        // Track overflow-wrap intent (requires base support to fully respect).
        css_overflow_wrap = "break-word"; // "normal" or "break-word"

        // Optional font resolver: function(_family_name) -> font asset id or -1
        css_font_resolver = undefined;

        #region Builder Functions

            #region jsDoc
            /// @func   set_css_enabled()
            /// @param  {Bool} _enabled
            /// @returns {Struct.WWTextRendererCSS}
            #endregion
            static set_css_enabled = function(_enabled) {
                css_enabled = _enabled;
                __mark_dirty__();
                return self;
            };

            #region jsDoc
            /// @func   set_css_stylesheet()
            /// @desc   Sets the stylesheet text used for class rules.
            /// @param  {String} _css_text
            /// @returns {Struct.WWTextRendererCSS}
            #endregion
            static set_css_stylesheet = function(_css_text) {
                css_stylesheet_text = _css_text;
                __css_parse_stylesheet__();
                __mark_dirty__();
                return self;
            };

            #region jsDoc
            /// @func   set_css_font_resolver()
            /// @desc   Provide a callback to resolve font-family into a font asset id.
            /// @param  {Function|Undefined} _resolver
            /// @returns {Struct.WWTextRendererCSS}
            #endregion
            static set_css_font_resolver = function(_resolver) {
                css_font_resolver = _resolver;
                __mark_dirty__();
                return self;
            };

            #region jsDoc
            /// @func   set_css_white_space()
            /// @desc   Sets the global white-space mode: "pre-wrap", "pre", "normal", "nowrap".
            /// @param  {String} _mode
            /// @returns {Struct.WWTextRendererCSS}
            #endregion
            static set_css_white_space = function(_mode) {
                css_white_space = _mode;
                __mark_dirty__();
                return self;
            };

            #region jsDoc
            /// @func   set_css_overflow_wrap()
            /// @desc   Sets the overflow-wrap intent: "normal" or "break-word".
            /// @param  {String} _mode
            /// @returns {Struct.WWTextRendererCSS}
            #endregion
            static set_css_overflow_wrap = function(_mode) {
                css_overflow_wrap = _mode;
                __mark_dirty__();
                return self;
            };

        #endregion

    #endregion

    #region Private

        // Parsed output
        static __css_plain_text__ = "";
        static __css_spans__ = [];
        static __css_align_runs__ = [];

        // Stylesheet map: class name -> style delta struct
        static __css_class_styles__ = undefined;

        // ---------------------------------
        // Style state helpers
        // ---------------------------------

        static __css_state_make_default__ = function() {
            return {
                color_value: undefined,
                alpha_value: undefined,

                back_color_value: undefined,
                back_alpha_value: undefined,

                font_asset_or_minus1: -1,
                style_value: __WW_Text_Glyph_Style.Regular,
                size_mul: 1,

                underline_value: __WW_Text_Glyph_Underline.None,

                strike_value: __WW_Text_Glyph_Strike.None,

                // 0=left, 1=center, 2=right
                align_value: 0
            };
        };

        static __css_state_copy__ = function(_state) {
            return {
                color_value: _state.color_value,
                alpha_value: _state.alpha_value,
                back_color_value: _state.back_color_value,
                back_alpha_value: _state.back_alpha_value,
                font_asset_or_minus1: _state.font_asset_or_minus1,
                style_value: _state.style_value,
                size_mul: _state.size_mul,
                underline_value: _state.underline_value,
                strike_value: _state.strike_value,
                align_value: _state.align_value
            };
        };

        static __css_state_equals_span__ = function(_state_a, _state_b) {
            return (
                _state_a.font_asset_or_minus1 == _state_b.font_asset_or_minus1
                && _state_a.style_value == _state_b.style_value
                && _state_a.size_mul == _state_b.size_mul
                && _state_a.color_value == _state_b.color_value
                && _state_a.alpha_value == _state_b.alpha_value
                && _state_a.underline_value == _state_b.underline_value
                && _state_a.back_color_value == _state_b.back_color_value
                && _state_a.back_alpha_value == _state_b.back_alpha_value
                && _state_a.strike_value == _state_b.strike_value
            );
        };

        static __css_state_equals_align__ = function(_state_a, _state_b) {
            return (_state_a.align_value == _state_b.align_value);
        };

        // ---------------------------------
        // Span helpers
        // ---------------------------------

        static __css_push_span__ = function(_span_list, _span_start, _span_end, _state) {
            if (_span_end <= _span_start) return;

            array_push(_span_list, {
                start_index: _span_start,
                end_index: _span_end,
                state: __css_state_copy__(_state)
            });
        };

        static __css_span_state_to_span_run__ = function(_span_len, _state) {
            var _final_color = _state.color_value;
            if (is_undefined(_final_color)) { _final_color = color; }
            var _final_alpha = _state.alpha_value;
            if (is_undefined(_final_alpha)) { _final_alpha = alpha; }
            var _final_size = _state.size_mul;
            if (is_undefined(_final_size) || _final_size <= 0) { _final_size = 1; }
            var _final_underline = _state.underline_value;
            if (is_undefined(_final_underline)) { _final_underline = __WW_Text_Glyph_Underline.None; }
            var _final_strike = _state.strike_value;
            if (is_undefined(_final_strike)) { _final_strike = __WW_Text_Glyph_Strike.None; }
            var _run = {
                index_count: _span_len,
                font_asset_or_minus1: _state.font_asset_or_minus1,
                style_value: _state.style_value,
                size_mul: _final_size,
                color: _final_color,
                alpha: _final_alpha,
                underline: _final_underline
            };
            _run[$ "back_color"] = _state.back_color_value; _run[$ "back_alpha"] = _state.back_alpha_value;
            _run[$ "strike"] = _final_strike;
            return _run;
        };
        static __css_span_state_to_align_run__ = function(_span_len, _state) {
            return {
                index_count: _span_len,
                align_value: _state.align_value
            };
        };

        // ---------------------------------
        // Stylesheet parsing (class rules only)
        // ---------------------------------

        static __css_trim__ = function(_text) {
            return string_trim(_text);
        };

        static __css_parse_stylesheet__ = function(_css_text_override = "") {

            if (!ds_exists(__css_class_styles__, ds_type_map)) {
                __css_class_styles__ = ds_map_create();
            } else {
                ds_map_clear(__css_class_styles__);
            }

            var _css_text = css_stylesheet_text;
            if (_css_text_override != "") _css_text = _css_text_override;
            if (_css_text == "") return;

            var _len = string_length(_css_text);
            var _pos = 1;

            while (_pos <= _len) {

                // Find next '.'
                var _dot_pos = string_pos_ext(".", _css_text, _pos);
                if (_dot_pos <= 0) break;

                // Find '{' after dot
                var _brace_open = string_pos_ext("{", _css_text, _dot_pos + 1);
                if (_brace_open <= 0) break;

                // Class selector name
                var _selector = string_copy(_css_text, _dot_pos + 1, _brace_open - (_dot_pos + 1));
                _selector = __css_trim__(_selector);

                // Only accept a simple class name token
                var _selector_end = 1;
                var _selector_len = string_length(_selector);
                while (_selector_end <= _selector_len) {
                    var _cc = string_char_at(_selector, _selector_end);
                    var _ok = (
                        (_cc >= "a" && _cc <= "z")
                        || (_cc >= "A" && _cc <= "Z")
                        || (_cc >= "0" && _cc <= "9")
                        || (_cc == "_")
                        || (_cc == "-")
                    );
                    if (!_ok) break;
                    _selector_end += 1;
                }
                _selector = string_copy(_selector, 1, _selector_end - 1);

                // Find matching close brace
                var _brace_close = string_pos_ext("}", _css_text, _brace_open + 1);
                if (_brace_close <= 0) break;

                var _body = string_copy(_css_text, _brace_open + 1, _brace_close - (_brace_open + 1));

                if (_selector != "") {
                    var _delta = __css_style_delta_make__();
                    __css_apply_style_string_to_delta__(_delta, _body);

                    ds_map_set(__css_class_styles__, _selector, _delta);
                }

                _pos = _brace_close + 1;
            }
        };

        // ---------------------------------
        // Style delta representation
        // ---------------------------------

        static __css_style_delta_make__ = function() {
            return {
                has_color: false,
                color_value: undefined,

                has_alpha: false,
                alpha_value: undefined,

                has_back_color: false,
                back_color_value: undefined,
                has_back_alpha: false,
                back_alpha_value: undefined,

                has_font: false,
                font_asset_or_minus1: -1,

                has_style: false,
                style_value: __WW_Text_Glyph_Style.Regular,

                has_size_mul: false,
                size_mul: 1,

                has_underline: false,
                underline_value: __WW_Text_Glyph_Underline.None,

                has_strike: false,
                strike_value: __WW_Text_Glyph_Strike.None,

                has_align: false,
                align_value: 0,

                // Global-only hints
                has_white_space: false,
                white_space: "",
                has_tab_size: false,
                tab_size_spaces: 4,
                has_overflow_wrap: false,
                overflow_wrap: ""
            };
        };

        static __css_apply_delta_to_state__ = function(_state, _delta, _is_global_allowed) {

            if (_delta.has_color) _state.color_value = _delta.color_value;
            if (_delta.has_alpha) _state.alpha_value = _delta.alpha_value;

            if (_delta.has_back_color) _state.back_color_value = _delta.back_color_value;
            if (_delta.has_back_alpha) _state.back_alpha_value = _delta.back_alpha_value;

            if (_delta.has_font) _state.font_asset_or_minus1 = _delta.font_asset_or_minus1;
            if (_delta.has_style) _state.style_value = _delta.style_value;
            if (_delta.has_size_mul) _state.size_mul = _delta.size_mul;
            if (_delta.has_underline) _state.underline_value = _delta.underline_value;
            if (_delta.has_strike) _state.strike_value = _delta.strike_value;
            if (_delta.has_align) _state.align_value = _delta.align_value;

            // Global-only properties (only apply when allowed by caller)
            if (_is_global_allowed) {
                if (_delta.has_white_space) css_white_space = _delta.white_space;
                if (_delta.has_tab_size) set_tab_size_spaces(_delta.tab_size_spaces);
                if (_delta.has_overflow_wrap) css_overflow_wrap = _delta.overflow_wrap;
            }
        };

        // ---------------------------------
        // Property parsing helpers
        // ---------------------------------

        static __css_parse_number__ = function(_text, _default_val) {
            _text = __css_trim__(_text);
            if (_text == "") return _default_val;
            return real(_text);
        };

        static __css_parse_color__ = function(_text) {

            _text = __css_trim__(_text);
            if (_text == "") return undefined;

            // Hex #rgb or #rrggbb
            if (string_char_at(_text, 1) == "#") {

                var _hex = string_copy(_text, 2, string_length(_text) - 1);
                var _hlen = string_length(_hex);

                if (_hlen == 3) {
                    var _r1 = string_char_at(_hex, 1);
                    var _g1 = string_char_at(_hex, 2);
                    var _b1 = string_char_at(_hex, 3);
                    _hex = _r1 + _r1 + _g1 + _g1 + _b1 + _b1;
                    _hlen = 6;
                }

                if (_hlen == 6) {
                    var _rv = real("0x" + string_copy(_hex, 1, 2));
                    var _gv = real("0x" + string_copy(_hex, 3, 2));
                    var _bv = real("0x" + string_copy(_hex, 5, 2));
                    return make_color_rgb(_rv, _gv, _bv);
                }

                return undefined;
            }

            // rgb() or rgba()
            var _lower = string_lower(_text);
            if (string_pos("rgb(", _lower) == 1 || string_pos("rgba(", _lower) == 1) {

                var _open = string_pos("(", _lower);
                var _close = string_pos(")", _lower);
                if (_open > 0 && _close > _open) {

                    var _inside = string_copy(_lower, _open + 1, _close - (_open + 1));
                    var _parts = string_split(_inside, ",");
                    var _plen = array_length(_parts);

                    if (_plen >= 3) {
                        var _rr = __css_parse_number__(_parts[0], 0);
                        var _gg = __css_parse_number__(_parts[1], 0);
                        var _bb = __css_parse_number__(_parts[2], 0);
                        return make_color_rgb(_rr, _gg, _bb);
                    }
                }
            }

            // Named colors are not supported by default.
            return undefined;
        };

        static __css_parse_opacity__ = function(_text) {
            var _val = __css_parse_number__(_text, 1);
            return clamp(_val, 0, 1);
        };

        static __css_parse_font_size_mul__ = function(_text) {

            _text = __css_trim__(_text);
            if (_text == "") return 1;

            var _lower = string_lower(_text);
            var _len = string_length(_lower);

            // em
            if (_len >= 3 && string_copy(_lower, _len - 1, 2) == "em") {
                var _num = string_copy(_lower, 1, _len - 2);
                return max(0.001, real(_num));
            }

            // %
            if (_len >= 2 && string_copy(_lower, _len, 1) == "%") {
                var _num2 = string_copy(_lower, 1, _len - 1);
                return max(0.001, real(_num2) / 100);
            }

            // px (approx as scale from current font height)
            if (_len >= 3 && string_copy(_lower, _len - 1, 2) == "px") {
                var _px = real(string_copy(_lower, 1, _len - 2));
                var _base_font = draw_get_font();
                var _old_font = _base_font;
                if (font_exists(font)) {
                    draw_set_font(font);
                    _base_font = font;
                }
                var _height = font_get_size(_base_font);
                draw_set_font(_old_font);

                if (_height <= 0) _height = 1;
                return max(0.001, _px / _height);
            }

            // number
            return max(0.001, real(_lower));
        };

        static __css_parse_font_weight_style__ = function(_weight_text, _italic_text, _current_style) {

            var _is_bold = false;
            var _is_italic = false;

            if (!is_undefined(_weight_text)) {
                var _wlow = string_lower(__css_trim__(_weight_text));
                if (_wlow == "bold") _is_bold = true;
                else if (_wlow == "normal") _is_bold = false;
                else {
                    var _num = real(_wlow);
                    if (_num >= 600) _is_bold = true;
                }
            }

            if (!is_undefined(_italic_text)) {
                var _ilow = string_lower(__css_trim__(_italic_text));
                _is_italic = (_ilow == "italic" || _ilow == "oblique");
            }

            // Preserve unspecified parts from current style
            if (is_undefined(_weight_text)) {
                _is_bold = (_current_style == __WW_Text_Glyph_Style.Bold || _current_style == __WW_Text_Glyph_Style.Bold_Italic);
            }
            if (is_undefined(_italic_text)) {
                _is_italic = (_current_style == __WW_Text_Glyph_Style.Italic || _current_style == __WW_Text_Glyph_Style.Bold_Italic);
            }

            if (_is_bold && _is_italic) return __WW_Text_Glyph_Style.Bold_Italic;
            if (_is_bold) return __WW_Text_Glyph_Style.Bold;
            if (_is_italic) return __WW_Text_Glyph_Style.Italic;
            return __WW_Text_Glyph_Style.Regular;
        };

        static __css_parse_text_decoration__ = function(_text, _delta) {

            var _low = string_lower(__css_trim__(_text));
            if (_low == "") return;

            // Accept common spellings
            // "underline", "line-through", "none", or multiple words
            var _parts = string_split(_low, " ");
            var _plen = array_length(_parts);

            var _has_underline = false;
            var _has_strike = false;
            var _has_none = false;

            var _i = 0;
            repeat (_plen) {
                var _tok = __css_trim__(_parts[_i]);
                if (_tok == "underline") _has_underline = true;
                else if (_tok == "line-through") _has_strike = true;
                else if (_tok == "none") _has_none = true;
                _i += 1;
            }

            if (_has_none) {
                _delta.has_underline = true;
                _delta.underline_value = __WW_Text_Glyph_Underline.None;
                _delta.has_strike = true;
                _delta.strike_value = __WW_Text_Glyph_Strike.None;
                return;
            }

            if (_has_underline) {
                _delta.has_underline = true;
                _delta.underline_value = __WW_Text_Glyph_Underline.Line;
            }

            if (_has_strike) {
                _delta.has_strike = true;
                _delta.strike_value = __WW_Text_Glyph_Strike.Line;
            }
        };

        static __css_parse_align__ = function(_text) {
            var _low = string_lower(__css_trim__(_text));
            if (_low == "center") return 1;
            if (_low == "right" || _low == "end") return 2;
            return 0;
        };

        static __css_parse_white_space__ = function(_text) {
            var _low = string_lower(__css_trim__(_text));
            if (_low == "pre") return "pre";
            if (_low == "pre-wrap") return "pre-wrap";
            if (_low == "nowrap") return "nowrap";
            if (_low == "normal") return "normal";
            return "";
        };

        static __css_parse_overflow_wrap__ = function(_text) {
            var _low = string_lower(__css_trim__(_text));
            if (_low == "normal") return "normal";
            if (_low == "break-word" || _low == "anywhere") return "break-word";
            return "";
        };

        static __css_apply_style_string_to_delta__ = function(_delta, _style_text) {

            var _decls = string_split(_style_text, ";");
            var _decl_count = array_length(_decls);

            var _idx = 0;
            repeat (_decl_count) {

                var _decl = __css_trim__(_decls[_idx]);
                _idx += 1;

                if (_decl == "") continue;

                var _colon = string_pos(":", _decl);
                if (_colon <= 0) continue;

                var _prop = string_lower(__css_trim__(string_copy(_decl, 1, _colon - 1)));
                var _val = __css_trim__(string_copy(_decl, _colon + 1, string_length(_decl) - _colon));

                if (_prop == "color") {
                    var _col = __css_parse_color__(_val);
                    if (!is_undefined(_col)) {
                        _delta.has_color = true;
                        _delta.color_value = _col;
                    }
                }
                else if (_prop == "opacity") {
                    _delta.has_alpha = true;
                    _delta.alpha_value = __css_parse_opacity__(_val);
                }
                else if (_prop == "background" || _prop == "background-color") {
                    var _bcol = __css_parse_color__(_val);
                    if (!is_undefined(_bcol)) {
                        _delta.has_back_color = true;
                        _delta.back_color_value = _bcol;
                        // If user provides rgba() alpha, they likely intend opacity too, but we do not parse alpha from rgba here.
                    }
                }
                else if (_prop == "font-size") {
                    _delta.has_size_mul = true;
                    _delta.size_mul = __css_parse_font_size_mul__(_val);
                }
                else if (_prop == "font-weight") {
                    _delta.has_style = true;
                    _delta.style_value = __css_parse_font_weight_style__(_val, undefined, _delta.style_value);
                }
                else if (_prop == "font-style") {
                    _delta.has_style = true;
                    _delta.style_value = __css_parse_font_weight_style__(undefined, _val, _delta.style_value);
                }
                else if (_prop == "font-family") {

                    if (!is_undefined(css_font_resolver)) {

                        var _family = _val;

                        // Drop quotes if present
                        if (string_length(_family) >= 2) {
                            var _c1 = string_char_at(_family, 1);
                            var _c2 = string_char_at(_family, string_length(_family));
                            if ((_c1 == "'" && _c2 == "'") || (_c1 == "\"" && _c2 == "\"")) {
                                _family = string_copy(_family, 2, string_length(_family) - 2);
                            }
                        }

                        var _font_id = css_font_resolver(_family);
                        if (!is_undefined(_font_id)) {
                            _delta.has_font = true;
                            _delta.font_asset_or_minus1 = _font_id;
                        }
                    }
                }
                else if (_prop == "text-decoration" || _prop == "text-decoration-line") {
                    __css_parse_text_decoration__(_val, _delta);
                }
                else if (_prop == "text-align") {
                    _delta.has_align = true;
                    _delta.align_value = __css_parse_align__(_val);
                }
                else if (_prop == "white-space") {
                    var _ws = __css_parse_white_space__(_val);
                    if (_ws != "") {
                        _delta.has_white_space = true;
                        _delta.white_space = _ws;
                    }
                }
                else if (_prop == "tab-size") {
                    _delta.has_tab_size = true;
                    _delta.tab_size_spaces = max(1, floor(real(_val)));
                }
                else if (_prop == "overflow-wrap" || _prop == "word-break") {
                    var _ow = __css_parse_overflow_wrap__(_val);
                    if (_ow != "") {
                        _delta.has_overflow_wrap = true;
                        _delta.overflow_wrap = _ow;
                    }
                }
            }
        };

        // ---------------------------------
        // Markup parsing
        // ---------------------------------

        static __css_apply_classes_to_state__ = function(_state, _class_text, _is_global_allowed) {

            if (_class_text == "") return;
            if (!ds_exists(__css_class_styles__, ds_type_map)) return;

            var _tokens = string_split(_class_text, " ");
            var _count = array_length(_tokens);

            var _i = 0;
            repeat (_count) {
                var _name = __css_trim__(_tokens[_i]);
                _i += 1;
                if (_name == "") continue;

                if (ds_map_exists(__css_class_styles__, _name)) {
                    var _delta = ds_map_find_value(__css_class_styles__, _name);
                    __css_apply_delta_to_state__(_state, _delta, _is_global_allowed);
                }
            }
        };

        static __css_parse_tag_name__ = function(_src_text, _pos, _len) {

            var _start = _pos;

            while (_pos <= _len) {
                var _cc = string_char_at(_src_text, _pos);
                var _ok = (
                    (_cc >= "a" && _cc <= "z")
                    || (_cc >= "A" && _cc <= "Z")
                    || (_cc >= "0" && _cc <= "9")
                    || (_cc == "_")
                    || (_cc == "-")
                );
                if (!_ok) break;
                _pos += 1;
            }

            return [string_lower(string_copy(_src_text, _start, _pos - _start)), _pos];
        };

        static __css_parse_attr_value__ = function(_src_text, _pos, _len) {

            // Expect optional quotes
            if (_pos > _len) return ["", _pos];

            var _qch = string_char_at(_src_text, _pos);
            if (_qch == "\"" || _qch == "'") {

                var _quote = _qch;
                _pos += 1;
                var _start = _pos;

                while (_pos <= _len) {
                    if (string_char_at(_src_text, _pos) == _quote) break;
                    _pos += 1;
                }

                var _val = "";
                if (_pos > _start) _val = string_copy(_src_text, _start, _pos - _start);

                // Skip closing quote
                if (_pos <= _len && string_char_at(_src_text, _pos) == _quote) _pos += 1;

                return [_val, _pos];
            }

            // Unquoted: read until whitespace or '>' or '/'
            var _start2 = _pos;
            while (_pos <= _len) {
                var _cc2 = string_char_at(_src_text, _pos);
                if (_cc2 == " " || _cc2 == "\t" || _cc2 == "\n" || _cc2 == "\r" || _cc2 == ">" || _cc2 == "/") break;
                _pos += 1;
            }

            var _val2 = "";
            if (_pos > _start2) _val2 = string_copy(_src_text, _start2, _pos - _start2);
            return [_val2, _pos];
        };

        static __css_parse_tag__ = function(_src_text, _pos, _len) {

            // _pos points at '<'
            var _tag = {
                is_tag: false,
                is_close: false,
                is_self_close: false,
                name: "",
                class_text: "",
                style_text: "",
                href_text: "",
                end_pos: _pos
            };

            if (_pos > _len) return _tag;
            if (string_char_at(_src_text, _pos) != "<") return _tag;

            var _scan = _pos + 1;
            if (_scan > _len) return _tag;

            // Close tag?
            if (string_char_at(_src_text, _scan) == "/") {
                _tag.is_close = true;
                _scan += 1;
            }

            // Tag name
            var _pair = __css_parse_tag_name__(_src_text, _scan, _len);
            _tag.name = _pair[0];
            _scan = _pair[1];

            if (_tag.name == "") return _tag;

            // Attributes scan
            while (_scan <= _len) {

                var _cc = string_char_at(_src_text, _scan);

                // End of tag
                if (_cc == ">") {
                    _scan += 1;
                    break;
                }

                // Self close
                if (_cc == "/" && _scan < _len && string_char_at(_src_text, _scan + 1) == ">") {
                    _tag.is_self_close = true;
                    _scan += 2;
                    break;
                }

                // Skip whitespace
                if (_cc == " " || _cc == "\t" || _cc == "\n" || _cc == "\r") {
                    _scan += 1;
                    continue;
                }

                // Attribute name
                var _attr_pair = __css_parse_tag_name__(_src_text, _scan, _len);
                var _attr_name = string_lower(_attr_pair[0]);
                _scan = _attr_pair[1];

                // Skip whitespace
                while (_scan <= _len) {
                    var _cc2 = string_char_at(_src_text, _scan);
                    if (!(_cc2 == " " || _cc2 == "\t" || _cc2 == "\n" || _cc2 == "\r")) break;
                    _scan += 1;
                }

                // Expect '=' for value
                if (_scan <= _len && string_char_at(_src_text, _scan) == "=") {
                    _scan += 1;

                    // Skip whitespace
                    while (_scan <= _len) {
                        var _cc3 = string_char_at(_src_text, _scan);
                        if (!(_cc3 == " " || _cc3 == "\t" || _cc3 == "\n" || _cc3 == "\r")) break;
                        _scan += 1;
                    }

                    var _val_pair = __css_parse_attr_value__(_src_text, _scan, _len);
                    var _attr_val = _val_pair[0];
                    _scan = _val_pair[1];

                    if (_attr_name == "class") _tag.class_text = _attr_val;
                    else if (_attr_name == "style") _tag.style_text = _attr_val;
                    else if (_attr_name == "href") _tag.href_text = _attr_val;
                }
            }

            _tag.is_tag = true;
            _tag.end_pos = _scan;
            return _tag;
        };

        static __css_collapse_whitespace__ = function(_text) {

            // Collapse runs of whitespace into single spaces.
            // Convert line breaks to spaces.
            var _len = string_length(_text);
            if (_len <= 0) return "";

            var _out = "";
            var _prev_space = false;

            var _idx = 1;
            while (_idx <= _len) {
                var _ch = string_char_at(_text, _idx);
                var _is_space = (_ch == " " || _ch == "\t" || _ch == "\n" || _ch == "\r");

                if (_is_space) {
                    if (!_prev_space) {
                        _out += " ";
                        _prev_space = true;
                    }
                } else {
                    _out += _ch;
                    _prev_space = false;
                }

                _idx += 1;
            }

            return _out;
        };

        static __css_parse__ = function(_src_text) {

            __css_plain_text__ = "";
            __css_spans__ = [];
            __css_align_runs__ = [];

            var _src_len = string_length(_src_text);
            if (_src_len <= 0) return;

            // Apply global whitespace mode pre-pass if needed (normal/nowrap collapse)
            var _src_processed = _src_text;
            if (css_white_space == "normal" || css_white_space == "nowrap") {
                _src_processed = __css_collapse_whitespace__(_src_text);
            }

            var _src_lower = string_lower(_src_processed);

            // Configure wrapping based on white-space
            if (css_white_space == "nowrap") {
                set_wrap_enabled(false);
            } else {
                // "pre", "pre-wrap", "normal"
                set_wrap_enabled(true);
            }

            var _plain = "";
            var _spans = [];
            var _align_runs = [];

            var _state = __css_state_make_default__();
            var _stack = [];

            var _span_start = 0;

            var _pos = 1;
            var _len = string_length(_src_processed);

            // Root global allowed until first emitted glyph.
            var _global_allowed = true;

            while (_pos <= _len) {

                var _ch = string_char_at(_src_processed, _pos);

                if (_ch != "<") {
                    _plain += _ch;
                    _pos += 1;
                    _global_allowed = false;
                    continue;
                }

                // Try parse tag
                var _tag = __css_parse_tag__(_src_processed, _pos, _len);
                if (!_tag.is_tag) {
                    // Not a valid tag, treat as literal '<'
                    _plain += "<";
                    _pos += 1;
                    _global_allowed = false;
                    continue;
                }

                // Flush span before tag effect
                __css_push_span__(_spans, _span_start, string_length(_plain), _state);
                _span_start = string_length(_plain);

                // Move scan position after tag
                _pos = _tag.end_pos;

                // Handle known tags
                var _name = _tag.name;

                if (_name == "br") {
                    _plain += "\n";
                    _span_start = string_length(_plain);
                    _global_allowed = false;
                    continue;
                }

                if (_name == "style" && !_tag.is_close) {

                    // Consume <style> ... </style> without emitting it.
                    // Only class rules are supported inside, matching the renderer stylesheet subset.
                    var _close_pos = string_pos_ext("</style", _src_lower, _pos);
                    if (_close_pos > 0) {

                        var _css_block = string_copy(_src_processed, _pos, _close_pos - _pos);
                        __css_parse_stylesheet__(_css_block);

                        var _close_end = string_pos_ext(">", _src_processed, _close_pos);
                        if (_close_end > 0) {
                            _pos = _close_end + 1;
                        } else {
                            _pos = _close_pos + 7;
                        }

                        // style blocks do not affect global-allowed gating
                        _span_start = string_length(_plain);
                        continue;

                    } else {

                        // No closing tag found - treat remainder as stylesheet and stop parsing.
                        var _tail_len = string_length(_src_processed) - _pos + 1;
                        if (_tail_len > 0) {
                            var _css_tail = string_copy(_src_processed, _pos, _tail_len);
                            __css_parse_stylesheet__(_css_tail);
                        }
                        break;
                    }
                }

 if (_tag.is_close) {

                    // Pop until matching tag
                    var _top = array_length(_stack) - 1;
                    while (_top >= 0) {

                        var _frame = _stack[_top];
                        array_pop(_stack);

                        _state = __css_state_copy__(_frame.prev_state);

                        if (_frame.tag_name == _name) break;
                        _top -= 1;
                    }

                    _span_start = string_length(_plain);
                    continue;
                }

                // Open tag (or self close)
                var _prev_state = __css_state_copy__(_state);
                var _next_state = __css_state_copy__(_state);

                // Tag built-ins
                if (_name == "b") {
                    _next_state.style_value = __css_parse_font_weight_style__("bold", undefined, _next_state.style_value);
                }
                else if (_name == "i") {
                    _next_state.style_value = __css_parse_font_weight_style__(undefined, "italic", _next_state.style_value);
                }
                else if (_name == "u") {
                    _next_state.underline_value = __WW_Text_Glyph_Underline.Line;
                }
                else if (_name == "s") {
                    _next_state.strike_value = __WW_Text_Glyph_Strike.Line;
                }

                // Class + style attributes
                if (_tag.class_text != "") {
                    __css_apply_classes_to_state__(_next_state, _tag.class_text, _global_allowed);
                }

                if (_tag.style_text != "") {
                    var _delta_inline = __css_style_delta_make__();
                    __css_apply_style_string_to_delta__(_delta_inline, _tag.style_text);
                    __css_apply_delta_to_state__(_next_state, _delta_inline, _global_allowed);
                }

                // Alignment runs are recorded as separate spans (post-pass)
                if (!_tag.is_self_close) {
                    array_push(_stack, { tag_name: _name, prev_state: _prev_state });
                }

                // Apply
                _state = _next_state;

                _span_start = string_length(_plain);
            }

            // Flush last span
            __css_push_span__(_spans, _span_start, string_length(_plain), _state);

            // Build metric + visual runs from spans
            var _span_count = array_length(_spans);
            if (_span_count <= 0) {
                __css_plain_text__ = _plain;
                return;
            }

            // Initialize run builders
            var _span_runs = [];
            var _align_out = [];

            var _curr_span_state = _spans[0].state;
            var _curr_align_state = _spans[0].state;

            var _span_count_accum = 0;
            var _align_count = 0;

            var _i = 0;
            repeat (_span_count) {

                var _span = _spans[_i];
                var _span_len = _span.end_index - _span.start_index;

                var _span_state = _span.state;

                // Span merge (single definitive stream)
                if (_i == 0 || __css_state_equals_span__(_curr_span_state, _span_state)) {
                    _span_count_accum += _span_len;
                } else {
                    array_push(_span_runs, __css_span_state_to_span_run__(_span_count_accum, _curr_span_state));
                    _curr_span_state = _span_state;
                    _span_count_accum = _span_len;
                }

                // Align merge (separate stream - post-pass)
                if (_i == 0 || __css_state_equals_align__(_curr_align_state, _span_state)) {
                    _align_count += _span_len;
                } else {
                    array_push(_align_out, __css_span_state_to_align_run__(_align_count, _curr_align_state));
                    _curr_align_state = _span_state;
                    _align_count = _span_len;
                }

                _i += 1;
            }

            // Flush tails
            if (_span_count_accum > 0) {
                array_push(_span_runs, __css_span_state_to_span_run__(_span_count_accum, _curr_span_state));
            }

            if (_align_count > 0) {
                array_push(_align_out, __css_span_state_to_align_run__(_align_count, _curr_align_state));
            }

            __css_plain_text__ = _plain;
            __css_spans__ = _span_runs;
            __css_align_runs__ = _align_out;
        };

        // ---------------------------------
        // Align post-pass (copied from BBCode approach)
        // ---------------------------------

        static __css_apply_align_runs_to_layout__ = function(_layout_instance, _align_runs, _available_width) {

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

                    var _gi = _line_start;
                    while (_gi < _line_end) {
                        var _gbase = _gi * __WW_Layout_Glyph.__Size__;
                        _glyphs[_gbase + __WW_Layout_Glyph.X] += _xoff;
                        _gi += 1;
                    }
                }

                _line_index += 1;
            }
        };

        // ---------------------------------
        // Layout override
        // ---------------------------------

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

            if (!css_enabled) {

                __display_text__ = _source_text;

                var _default_spans = [{
                    index_count: string_length(_source_text),
                    font_asset_or_minus1: -1,
                    style_value: __WW_Text_Glyph_Style.Regular,
                    size_mul: 1,
                    color: color,
                    alpha: alpha,
                    underline: __WW_Text_Glyph_Underline.None,
                    back_color: undefined,
                    back_alpha: undefined,
                    strike: __WW_Text_Glyph_Strike.None
                }];

                __layout__ = __build_layout__(_source_text, _default_spans);
                __content_width__ = __layout__.get_content_width();
                __content_height__ = __layout__.get_content_height();

                __is_dirty__ = false;
                return;
            }

            // Ensure stylesheet map exists
            if (!ds_exists(__css_class_styles__, ds_type_map)) {
                __css_parse_stylesheet__();
            }

            __css_parse__(_source_text);

            __display_text__ = __css_plain_text__;

            __layout__ = __build_layout__(__css_plain_text__, __css_spans__);

            // Alignment is still a post-pass because it depends on final line breaks.
            var _align_width = __layout__.get_content_width();
            if (!is_undefined(__textbox_parent__)) {
                _align_width = __textbox_parent__.width;
            }

            __css_apply_align_runs_to_layout__(__layout__, __css_align_runs__, _align_width);

            __content_width__ = __layout__.get_content_width();
            __content_height__ = __layout__.get_content_height();

            __is_dirty__ = false;
        };

    #endregion

}