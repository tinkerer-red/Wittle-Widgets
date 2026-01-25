#region CSS helpers

function __ww_css_trim__(_text) {
    return string_trim(_text);
}

function __ww_css_is_space__(_char) {
    return (_char == " " || _char == "\t" || _char == "\n" || _char == "\r");
}

function __ww_css_collapse_whitespace__(_text) {

    var _length = string_length(_text);
    if (_length <= 0) { return ""; }

    var _output = "";
    var _prev_space = false;

    var _index = 1;
    while (_index <= _length) {

        var _char = string_char_at(_text, _index);
        var _space = __ww_css_is_space__(_char);

        if (_space) {
            if (!_prev_space) {
                _output += " ";
                _prev_space = true;
            }
        } else {
            _output += _char;
            _prev_space = false;
        }

        _index += 1;
    }

    return _output;
}

// Buffer-first helpers (performance)
function __ww_css_init_input_buff__(_text) {
    static __css_in_buff = buffer_create(0, buffer_grow, 1);

    buffer_seek(__css_in_buff, buffer_seek_start, 0);
    buffer_write(__css_in_buff, buffer_text, _text);

    // buffer_text includes a trailing NUL; exclude it from the content length
    var _byte_len = buffer_tell(__css_in_buff) - 1;
    buffer_write(__css_in_buff, buffer_u64, 0);

    return [ __css_in_buff, _byte_len ];
}

function __ww_css_is_space_u8__(_b) {
    return (_b == 32 || _b == 9 || _b == 10 || _b == 13);
}

function __ww_css_is_name_u8__(_b) {
    return (
        (_b >= 97 && _b <= 122) ||
        (_b >= 65 && _b <= 90) ||
        (_b >= 48 && _b <= 57) ||
        (_b == 95) ||
        (_b == 45)
    );
}

function __ww_css_lower_ascii_u8__(_b) {
    if (_b >= 65 && _b <= 90) { return _b + 32; }
    return _b;
}

function __ww_css_find_u8__(_buff, _start, _endd, _target_u8) {
    var _pos = _start;
    while (_pos < _endd) {
        if (buffer_peek(_buff, _pos, buffer_u8) == _target_u8) {
            return _pos;
        }
        _pos += 1;
    }
    return -1;
}

function __ww_css_collapse_whitespace_u8__(_text) {

    if (_text == "") { return ""; }

    var _in_pair = __ww_css_init_input_buff__(_text);
    var _in_buff = _in_pair[0];
    var _in_len = _in_pair[1];

    static __css_ws_out_buff = buffer_create(0, buffer_grow, 1);
    buffer_seek(__css_ws_out_buff, buffer_seek_start, 0);

    var _prev_space = false;
    var _pos = 0;
    while (_pos < _in_len) {
        var _b = buffer_peek(_in_buff, _pos, buffer_u8);
        if (__ww_css_is_space_u8__(_b)) {
            if (!_prev_space) {
                buffer_write(__css_ws_out_buff, buffer_u8, 32);
                _prev_space = true;
            }
        } else {
            buffer_write(__css_ws_out_buff, buffer_u8, _b);
            _prev_space = false;
        }
        _pos += 1;
    }

    buffer_write(__css_ws_out_buff, buffer_u8, 0);
    buffer_seek(__css_ws_out_buff, buffer_seek_start, 0);
    return buffer_read(__css_ws_out_buff, buffer_text);
}

function __ww_css_parse_tag_buff__(_buff, _pos, _endd) {

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

    if (_pos >= _endd) { return _tag; }
    if (buffer_peek(_buff, _pos, buffer_u8) != 60) { return _tag; } // '<'

    var _scan = _pos + 1;
    if (_scan >= _endd) { return _tag; }

    if (buffer_peek(_buff, _scan, buffer_u8) == 47) { // '/'
        _tag.is_close = true;
        _scan += 1;
    }

    var _name_start = _scan;
    while (_scan < _endd) {
        var _b = buffer_peek(_buff, _scan, buffer_u8);
        if (!__ww_css_is_name_u8__(_b)) { break; }
        _scan += 1;
    }

    if (_scan <= _name_start) { return _tag; }

    _tag.name = string_lower(regex__buffer_read_text_range(_buff, _name_start, _scan));

    while (_scan < _endd) {

        var _c = buffer_peek(_buff, _scan, buffer_u8);

        if (_c == 62) { // '>'
            _scan += 1;
            break;
        }

        if (_c == 47 && (_scan + 1) < _endd && buffer_peek(_buff, _scan + 1, buffer_u8) == 62) {
            _tag.is_self_close = true;
            _scan += 2;
            break;
        }

        if (__ww_css_is_space_u8__(_c)) {
            _scan += 1;
            continue;
        }

        var _attr_start = _scan;
        while (_scan < _endd) {
            var _ab = buffer_peek(_buff, _scan, buffer_u8);
            if (!__ww_css_is_name_u8__(_ab)) { break; }
            _scan += 1;
        }

        if (_scan <= _attr_start) {
            _scan += 1;
            continue;
        }

        var _attr_name = string_lower(regex__buffer_read_text_range(_buff, _attr_start, _scan));

        while (_scan < _endd) {
            var _s = buffer_peek(_buff, _scan, buffer_u8);
            if (!__ww_css_is_space_u8__(_s)) { break; }
            _scan += 1;
        }

        if (_scan < _endd && buffer_peek(_buff, _scan, buffer_u8) == 61) { // '='

            _scan += 1;

            while (_scan < _endd) {
                var _s2 = buffer_peek(_buff, _scan, buffer_u8);
                if (!__ww_css_is_space_u8__(_s2)) { break; }
                _scan += 1;
            }

            if (_scan >= _endd) { break; }

            var _val = "";
            var _first = buffer_peek(_buff, _scan, buffer_u8);

            if (_first == 34 || _first == 39) {
                var _quote = _first;
                _scan += 1;
                var _vstart = _scan;
                while (_scan < _endd) {
                    if (buffer_peek(_buff, _scan, buffer_u8) == _quote) { break; }
                    _scan += 1;
                }
                if (_scan > _vstart) {
                    _val = regex__buffer_read_text_range(_buff, _vstart, _scan);
                }
                if (_scan < _endd && buffer_peek(_buff, _scan, buffer_u8) == _quote) {
                    _scan += 1;
                }
            } else {
                var _vstart2 = _scan;
                while (_scan < _endd) {
                    var _vb = buffer_peek(_buff, _scan, buffer_u8);
                    if (__ww_css_is_space_u8__(_vb) || _vb == 62 || _vb == 47) { break; }
                    _scan += 1;
                }
                if (_scan > _vstart2) {
                    _val = regex__buffer_read_text_range(_buff, _vstart2, _scan);
                }
            }

            if (_attr_name == "class") { _tag.class_text = _val; }
            else if (_attr_name == "style") { _tag.style_text = _val; }
            else if (_attr_name == "href") { _tag.href_text = _val; }
        }
    }

    _tag.is_tag = true;
    _tag.end_pos = _scan;
    return _tag;
}

function __ww_css_find_style_close_u8__(_buff, _start, _endd) {

    // Find the '<' that starts a closing tag matching </style (ASCII, case-insensitive)
    var _pos = _start;
    while (_pos + 7 <= _endd) {
        if (buffer_peek(_buff, _pos, buffer_u8) == 60 && buffer_peek(_buff, _pos + 1, buffer_u8) == 47) {
            var _b2 = __ww_css_lower_ascii_u8__(buffer_peek(_buff, _pos + 2, buffer_u8));
            var _b3 = __ww_css_lower_ascii_u8__(buffer_peek(_buff, _pos + 3, buffer_u8));
            var _b4 = __ww_css_lower_ascii_u8__(buffer_peek(_buff, _pos + 4, buffer_u8));
            var _b5 = __ww_css_lower_ascii_u8__(buffer_peek(_buff, _pos + 5, buffer_u8));
            var _b6 = __ww_css_lower_ascii_u8__(buffer_peek(_buff, _pos + 6, buffer_u8));

            if (_b2 == 115 && _b3 == 116 && _b4 == 121 && _b5 == 108 && _b6 == 101) {
                return _pos;
            }
        }
        _pos += 1;
    }

    return -1;
}

function __ww_css_parse_tag_name__(_text, _pos, _len) {

    var _start = _pos;

    while (_pos <= _len) {

        var _char = string_char_at(_text, _pos);

        var _okay = (
            (_char >= "a" && _char <= "z") ||
            (_char >= "A" && _char <= "Z") ||
            (_char >= "0" && _char <= "9") ||
            (_char == "_") ||
            (_char == "-")
        );

        if (!_okay) { break; }
        _pos += 1;
    }

    var _name = "";
    if (_pos > _start) {
        _name = string_lower(string_copy(_text, _start, _pos - _start));
    }

    return [ _name, _pos ];
}

function __ww_css_parse_attr_value__(_text, _pos, _len) {

    if (_pos > _len) { return [ "", _pos ]; }

    var _first = string_char_at(_text, _pos);

    if (_first == "\"" || _first == "'") {

        var _quote = _first;
        _pos += 1;

        var _start = _pos;

        while (_pos <= _len) {
            if (string_char_at(_text, _pos) == _quote) { break; }
            _pos += 1;
        }

        var _value = "";
        if (_pos > _start) {
            _value = string_copy(_text, _start, _pos - _start);
        }

        if (_pos <= _len && string_char_at(_text, _pos) == _quote) {
            _pos += 1;
        }

        return [ _value, _pos ];
    }

    var _start2 = _pos;

    while (_pos <= _len) {

        var _char = string_char_at(_text, _pos);

        if (
            _char == " " || _char == "\t" || _char == "\n" || _char == "\r" ||
            _char == ">" || _char == "/"
        ) {
            break;
        }

        _pos += 1;
    }

    var _value2 = "";
    if (_pos > _start2) {
        _value2 = string_copy(_text, _start2, _pos - _start2);
    }

    return [ _value2, _pos ];
}

function __ww_css_parse_tag__(_text, _pos, _len) {

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

    if (_pos > _len) { return _tag; }
    if (string_char_at(_text, _pos) != "<") { return _tag; }

    var _scan = _pos + 1;
    if (_scan > _len) { return _tag; }

    if (string_char_at(_text, _scan) == "/") {
        _tag.is_close = true;
        _scan += 1;
    }

    var _name_pair = __ww_css_parse_tag_name__(_text, _scan, _len);
    _tag.name = _name_pair[0];
    _scan = _name_pair[1];

    if (_tag.name == "") { return _tag; }

    while (_scan <= _len) {

        var _char = string_char_at(_text, _scan);

        if (_char == ">") {
            _scan += 1;
            break;
        }

        if (_char == "/" && _scan < _len && string_char_at(_text, _scan + 1) == ">") {
            _tag.is_self_close = true;
            _scan += 2;
            break;
        }

        if (__ww_css_is_space__(_char)) {
            _scan += 1;
            continue;
        }

        var _attr_pair = __ww_css_parse_tag_name__(_text, _scan, _len);
        var _attr_name = string_lower(_attr_pair[0]);
        _scan = _attr_pair[1];

        while (_scan <= _len) {
            var _char2 = string_char_at(_text, _scan);
            if (!__ww_css_is_space__(_char2)) { break; }
            _scan += 1;
        }

        if (_scan <= _len && string_char_at(_text, _scan) == "=") {

            _scan += 1;

            while (_scan <= _len) {
                var _char3 = string_char_at(_text, _scan);
                if (!__ww_css_is_space__(_char3)) { break; }
                _scan += 1;
            }

            var _val_pair = __ww_css_parse_attr_value__(_text, _scan, _len);
            var _attr_val = _val_pair[0];
            _scan = _val_pair[1];

            if (_attr_name == "class") { _tag.class_text = _attr_val; }
            else if (_attr_name == "style") { _tag.style_text = _attr_val; }
            else if (_attr_name == "href") { _tag.href_text = _attr_val; }
        }
    }

    _tag.is_tag = true;
    _tag.end_pos = _scan;

    return _tag;
}

function __ww_css_style_delta_make__() {
    return {
        has_color: false,
        color: 0,

        has_alpha: false,
        alpha: 1,

        has_back_color: false,
        back_color: 0,

        has_back_alpha: false,
        back_alpha: 0,

        has_font: false,
        font_asset: -1,

        has_style: false,
        style: __WW_Text_Glyph_Style.Regular,

        has_size_mul: false,
        size_mul: 1,

        has_underline: false,
        underline: __WW_Text_Glyph_Underline.None,

        has_strike: false,
        strike: __WW_Text_Glyph_Strike.None,

        has_align: false,
        align_value: __WW_Text_Alignment.Left,

        has_white_space: false,
        white_space: "",

        has_tab_size: false,
        tab_size_spaces: 4,

        has_overflow_wrap: false,
        overflow_wrap: ""
    };
}

function __ww_css_parse_number__(_text, _default_val) {
    var _trim = __ww_css_trim__(_text);
    if (_trim == "") { return _default_val; }
    return real(_trim);
}

function __ww_css_parse_opacity__(_text) {
    var _val = __ww_css_parse_number__(_text, 1);
    if (_val < 0) { _val = 0; }
    if (_val > 1) { _val = 1; }
    return _val;
}

function __ww_css_parse_align__(_text) {
    var _low = string_lower(__ww_css_trim__(_text));
    if (_low == "center") { return __WW_Text_Alignment.Center; }
    if (_low == "right" || _low == "end") { return __WW_Text_Alignment.Right; }
    return __WW_Text_Alignment.Left;
}

function __ww_css_parse_white_space__(_text) {
    var _low = string_lower(__ww_css_trim__(_text));
    if (_low == "pre") { return "pre"; }
    if (_low == "pre-wrap") { return "pre-wrap"; }
    if (_low == "nowrap") { return "nowrap"; }
    if (_low == "normal") { return "normal"; }
    return "";
}

function __ww_css_parse_overflow_wrap__(_text) {
    var _low = string_lower(__ww_css_trim__(_text));
    if (_low == "normal") { return "normal"; }
    if (_low == "break-word" || _low == "anywhere") { return "break-word"; }
    return "";
}

function __ww_css_parse_font_weight_style__(_weight_text, _italic_text, _current_style) {

    var _bold = false;
    var _ital = false;

    if (_weight_text != undefined) {
        var _wlow = string_lower(__ww_css_trim__(_weight_text));
        if (_wlow == "bold") { _bold = true; }
        else if (_wlow == "normal") { _bold = false; }
        else {
            var _num = real(_wlow);
            if (_num >= 600) { _bold = true; }
        }
    }

    if (_italic_text != undefined) {
        var _ilow = string_lower(__ww_css_trim__(_italic_text));
        _ital = (_ilow == "italic" || _ilow == "oblique");
    }

    if (_weight_text == undefined) {
        _bold = (
            _current_style == __WW_Text_Glyph_Style.Bold ||
            _current_style == __WW_Text_Glyph_Style.Bold_Italic
        );
    }

    if (_italic_text == undefined) {
        _ital = (
            _current_style == __WW_Text_Glyph_Style.Italic ||
            _current_style == __WW_Text_Glyph_Style.Bold_Italic
        );
    }

    if (_bold && _ital) { return __WW_Text_Glyph_Style.Bold_Italic; }
    if (_bold) { return __WW_Text_Glyph_Style.Bold; }
    if (_ital) { return __WW_Text_Glyph_Style.Italic; }
    return __WW_Text_Glyph_Style.Regular;
}

function __ww_css_parse_text_decoration__(_text, _delta) {

    var _low = string_lower(__ww_css_trim__(_text));
    if (_low == "") { return; }

    var _parts = string_split(_low, " ");
    var _count = array_length(_parts);

    var _has_underline = false;
    var _has_strike = false;
    var _has_none = false;

    var _index = 0;
    repeat (_count) {
        var _tok = __ww_css_trim__(_parts[_index]);
        if (_tok == "underline") { _has_underline = true; }
        else if (_tok == "line-through") { _has_strike = true; }
        else if (_tok == "none") { _has_none = true; }
        _index += 1;
    }

    if (_has_none) {
        _delta.has_underline = true;
        _delta.underline = __WW_Text_Glyph_Underline.None;

        _delta.has_strike = true;
        _delta.strike = __WW_Text_Glyph_Strike.None;
        return;
    }

    if (_has_underline) {
        _delta.has_underline = true;
        _delta.underline = __WW_Text_Glyph_Underline.Line;
    }

    if (_has_strike) {
        _delta.has_strike = true;
        _delta.strike = __WW_Text_Glyph_Strike.Line;
    }
}

function __ww_css_parse_font_size_mul__(_text, _base_font_asset) {

    var _trim = __ww_css_trim__(_text);
    if (_trim == "") { return 1; }

    var _low = string_lower(_trim);
    var _len = string_length(_low);

    if (_len >= 3 && string_copy(_low, _len - 1, 2) == "em") {
        var _num = string_copy(_low, 1, _len - 2);
        var _val = real(_num);
        if (_val < 0.001) { _val = 0.001; }
        return _val;
    }

    if (_len >= 2 && string_copy(_low, _len, 1) == "%") {
        var _num2 = string_copy(_low, 1, _len - 1);
        var _val2 = real(_num2) / 100;
        if (_val2 < 0.001) { _val2 = 0.001; }
        return _val2;
    }

    if (_len >= 3 && string_copy(_low, _len - 1, 2) == "px") {

        var _px = real(string_copy(_low, 1, _len - 2));

        var _height = font_get_size(_base_font_asset);
        if (_height <= 0) { _height = 1; }

        var _mul = _px / _height;
        if (_mul < 0.001) { _mul = 0.001; }
        return _mul;
    }

    var _val3 = real(_low);
    if (_val3 < 0.001) { _val3 = 0.001; }
    return _val3;
}

function __ww_css_apply_style_string_to_delta__(_delta, _style_text, _base_font_asset, _font_resolver) {

    var _decls = string_split(_style_text, ";");
    var _decl_count = array_length(_decls);

    var _index = 0;
    repeat (_decl_count) {

        var _decl = __ww_css_trim__(_decls[_index]);
        _index += 1;

        if (_decl == "") { continue; }

        var _colon = string_pos(":", _decl);
        if (_colon <= 0) { continue; }

        var _prop = string_lower(__ww_css_trim__(string_copy(_decl, 1, _colon - 1)));
        var _val = __ww_css_trim__(string_copy(_decl, _colon + 1, string_length(_decl) - _colon));

        if (_prop == "color") {

            var _col = __ww_textproc_parse_html_color__(_val, 0);
            _delta.has_color = true;
            _delta.color = _col;
        }
        else if (_prop == "opacity") {

            _delta.has_alpha = true;
            _delta.alpha = __ww_css_parse_opacity__(_val);
        }
        else if (_prop == "background" || _prop == "background-color") {

            var _bcol = __ww_textproc_parse_html_color__(_val, 0);
            _delta.has_back_color = true;
            _delta.back_color = _bcol;

            if (!_delta.has_back_alpha) {
                _delta.has_back_alpha = true;
                _delta.back_alpha = 1;
            }
        }
        else if (_prop == "font-size") {

            _delta.has_size_mul = true;
            _delta.size_mul = __ww_css_parse_font_size_mul__(_val, _base_font_asset);
        }
        else if (_prop == "font-weight") {

            _delta.has_style = true;
            _delta.style = __ww_css_parse_font_weight_style__(_val, undefined, _delta.style);
        }
        else if (_prop == "font-style") {

            _delta.has_style = true;
            _delta.style = __ww_css_parse_font_weight_style__(undefined, _val, _delta.style);
        }
        else if (_prop == "font-family") {

            if (_font_resolver != undefined) {

                var _family = _val;

                if (string_length(_family) >= 2) {
                    var _c1 = string_char_at(_family, 1);
                    var _c2 = string_char_at(_family, string_length(_family));
                    if ((_c1 == "'" && _c2 == "'") || (_c1 == "\"" && _c2 == "\"")) {
                        _family = string_copy(_family, 2, string_length(_family) - 2);
                    }
                }

                var _font_id = _font_resolver(_family);
                if (_font_id != undefined) {
                    _delta.has_font = true;
                    _delta.font_asset = _font_id;
                }
            }
        }
        else if (_prop == "text-decoration" || _prop == "text-decoration-line") {

            __ww_css_parse_text_decoration__(_val, _delta);
        }
        else if (_prop == "text-align") {

            _delta.has_align = true;
            _delta.align_value = __ww_css_parse_align__(_val);
        }
        else if (_prop == "white-space") {

            var _ws = __ww_css_parse_white_space__(_val);
            if (_ws != "") {
                _delta.has_white_space = true;
                _delta.white_space = _ws;
            }
        }
        else if (_prop == "tab-size") {

            var _tabs = floor(real(_val));
            if (_tabs < 1) { _tabs = 1; }

            _delta.has_tab_size = true;
            _delta.tab_size_spaces = _tabs;
        }
        else if (_prop == "overflow-wrap" || _prop == "word-break") {

            var _ow = __ww_css_parse_overflow_wrap__(_val);
            if (_ow != "") {
                _delta.has_overflow_wrap = true;
                _delta.overflow_wrap = _ow;
            }
        }
    }
}

function __ww_css_parse_stylesheet__(_class_map, _css_text) {

    if (_css_text == "") { return; }

    var _len = string_length(_css_text);
    var _pos = 1;

    while (_pos <= _len) {

        var _dot = string_pos_ext(".", _css_text, _pos);
        if (_dot <= 0) { break; }

        var _brace_open = string_pos_ext("{", _css_text, _dot + 1);
        if (_brace_open <= 0) { break; }

        var _selector = string_copy(_css_text, _dot + 1, _brace_open - (_dot + 1));
        _selector = __ww_css_trim__(_selector);

        var _sel_len = string_length(_selector);
        var _sel_end = 1;

        while (_sel_end <= _sel_len) {

            var _cc = string_char_at(_selector, _sel_end);

            var _ok = (
                (_cc >= "a" && _cc <= "z") ||
                (_cc >= "A" && _cc <= "Z") ||
                (_cc >= "0" && _cc <= "9") ||
                (_cc == "_") ||
                (_cc == "-")
            );

            if (!_ok) { break; }
            _sel_end += 1;
        }

        _selector = string_copy(_selector, 1, _sel_end - 1);

        var _brace_close = string_pos_ext("}", _css_text, _brace_open + 1);
        if (_brace_close <= 0) { break; }

        var _body = string_copy(_css_text, _brace_open + 1, _brace_close - (_brace_open + 1));

        if (_selector != "") {
            ds_map_set(_class_map, _selector, _body);
        }

        _pos = _brace_close + 1;
    }
}

#endregion


#region jsDoc
/// @func    WWTextProcessorCSS
/// @desc    HTML/CSS-like processor producing plain text + spans + align runs.
///          Supports: <span class=".." style="..">, </span>, <b>, <i>, <u>, <s>, <br>, <style>..</style>.
///          Class rules: .name { prop:value; ... } from default stylesheet + inline style blocks.
///          Properties: color, opacity, background/background-color, font-family, font-size,
///                      font-weight, font-style, text-decoration(-line), text-align,
///                      white-space (global-gated), tab-size (global-gated),
///                      overflow-wrap/word-break (global-gated).
/// @param   {String} _raw_text
/// @param   {Struct} _default_state
/// @returns {Struct} { text, spans, align_runs, white_space, overflow_wrap, tab_size_spaces }
#endregion
function WWTextProcessorCSS(_raw_text, _default_state) {

    var _ctx = __ww_textproc_ctx_begin__(_default_state);

    var _res_empty = __ww_textproc_ctx_finish__(_ctx);
    _res_empty.align_runs = [];
    _res_empty.white_space = "pre-wrap";
    _res_empty.overflow_wrap = "break-word";
    _res_empty.tab_size_spaces = 4;

    if (_raw_text == undefined || _raw_text == "") {
        return _res_empty;
    }

    // Config (defaults match old renderer)
    var _white_space = "pre-wrap";
    var _overflow_wrap = "break-word";
    var _tab_size_spaces = 4;

    if (_default_state != undefined) {
        if (variable_struct_exists(_default_state, "css_white_space")) { _white_space = variable_struct_get(_default_state, "css_white_space"); }
        if (variable_struct_exists(_default_state, "css_overflow_wrap")) { _overflow_wrap = variable_struct_get(_default_state, "css_overflow_wrap"); }
        if (variable_struct_exists(_default_state, "tab_size_spaces")) { _tab_size_spaces = variable_struct_get(_default_state, "tab_size_spaces"); }
    }

    // Optional stylesheet + resolver hook
    var _stylesheet_text = "";
    var _font_resolver = undefined;

    if (_default_state != undefined) {
        if (variable_struct_exists(_default_state, "css_stylesheet_text")) { _stylesheet_text = variable_struct_get(_default_state, "css_stylesheet_text"); }
        if (variable_struct_exists(_default_state, "css_font_resolver")) { _font_resolver = variable_struct_get(_default_state, "css_font_resolver"); }
    }

    // Base font asset for px font-size scaling
    var _base_font_asset = _ctx.state.font_asset;

    // Class map (class -> body string). Keep a static ds_map to avoid garbage.
    static __css_class_map__ = undefined;

    if (!ds_exists(__css_class_map__, ds_type_map)) {
        __css_class_map__ = ds_map_create();
    } else {
        ds_map_clear(__css_class_map__);
    }

    // Parse base stylesheet
    __ww_css_parse_stylesheet__(__css_class_map__, _stylesheet_text);

    // Whitespace pre-pass
    var _source_text = _raw_text;

    if (_white_space == "normal" || _white_space == "nowrap") {
        _source_text = __ww_css_collapse_whitespace_u8__(_source_text);
    }

    // Input buffer (UTF-8 bytes)
    var _in_pair = __ww_css_init_input_buff__(_source_text);
    var _in_buff = _in_pair[0];
    var _in_len = _in_pair[1];

    // Alignment runs (output index space, like BBCode/Markdown)
    var _align_runs = [];
    var _align_value = __WW_Text_Alignment.Left;

    if (variable_struct_exists(_ctx.state, "align_value")) {
        _align_value = _ctx.state.align_value;
    } else {
        _ctx.state.align_value = _align_value;
    }

    var _align_start = 0;

    // Stack frames: { tag_name, prev_state }
    var _state_stack = [];

    // Global gating (matches old: only until first emitted glyph)
    var _global_allowed = true;

    var _pos = 0;

    while (_pos < _in_len) {

        var _lt = __ww_css_find_u8__(_in_buff, _pos, _in_len, 60); // '<'
        if (_lt < 0) {
            if (_pos < _in_len) {
                __ww_textproc_ctx_append_text__(_ctx, regex__buffer_read_text_range(_in_buff, _pos, _in_len));
                _global_allowed = false;
            }
            break;
        }

        if (_lt > _pos) {
            __ww_textproc_ctx_append_text__(_ctx, regex__buffer_read_text_range(_in_buff, _pos, _lt));
            _global_allowed = false;
            _pos = _lt;
        }

        var _tag = __ww_css_parse_tag_buff__(_in_buff, _pos, _in_len);

        if (!_tag.is_tag) {
            __ww_textproc_ctx_append_text__(_ctx, "<");
            _pos += 1;
            _global_allowed = false;
            continue;
        }

        // Advance past the tag immediately
        _pos = _tag.end_pos;

        var _name = _tag.name;

        // <br> always emits newline
        if (_name == "br") {
            __ww_textproc_ctx_append_text__(_ctx, "\n");
            _global_allowed = false;
            continue;
        }

        // <style> ... </style> parses class rules and emits nothing
        if (_name == "style" && !_tag.is_close) {

            var _close_pos = __ww_css_find_style_close_u8__(_in_buff, _pos, _in_len);

            if (_close_pos >= 0) {

                var _css_block = regex__buffer_read_text_range(_in_buff, _pos, _close_pos);
                __ww_css_parse_stylesheet__(__css_class_map__, _css_block);

                var _close_end = __ww_css_find_u8__(_in_buff, _close_pos, _in_len, 62); // '>'
                if (_close_end >= 0) {
                    _pos = _close_end + 1;
                } else {
                    _pos = _close_pos + 7;
                }

                // Do not toggle _global_allowed
                continue;
            }

            // No close found: parse tail and stop
            if (_pos < _in_len) {
                var _tail = regex__buffer_read_text_range(_in_buff, _pos, _in_len);
                __ww_css_parse_stylesheet__(__css_class_map__, _tail);
            }

            break;
        }

        // Closing tag: pop until matching name (forgiving, matches old behavior)
        if (_tag.is_close) {

            var _top = array_length(_state_stack) - 1;

            while (_top >= 0) {

                var _frame = _state_stack[_top];
                array_pop(_state_stack);

                __ww_textproc_ctx_flush_span__(_ctx, variable_struct_get(_ctx, "out_len"));
                _ctx.state = __ww_textproc_state_clone__(_frame.prev_state);
                _ctx.span_start = variable_struct_get(_ctx, "out_len");

                if (_frame.tag_name == _name) { break; }

                _top -= 1;
            }

            continue;
        }

        // Opening tag: snapshot current state
        var _prev_state = __ww_textproc_state_clone__(_ctx.state);

        if (!_tag.is_self_close) {
            array_push(_state_stack, { tag_name: _name, prev_state: _prev_state });
        }

        // Built-in tag effects
        if (_name == "b") {
            __ww_textproc_ctx_flush_span__(_ctx, variable_struct_get(_ctx, "out_len"));
            __ww_textproc_ctx_apply_patch__(_ctx, { style: __WW_Text_Glyph_Style.Bold });
            _ctx.span_start = variable_struct_get(_ctx, "out_len");
        }
        else if (_name == "i") {
            __ww_textproc_ctx_flush_span__(_ctx, variable_struct_get(_ctx, "out_len"));
            __ww_textproc_ctx_apply_patch__(_ctx, { style: __WW_Text_Glyph_Style.Italic });
            _ctx.span_start = variable_struct_get(_ctx, "out_len");
        }
        else if (_name == "u") {
            __ww_textproc_ctx_flush_span__(_ctx, variable_struct_get(_ctx, "out_len"));
            __ww_textproc_ctx_apply_patch__(_ctx, { underline: __WW_Text_Glyph_Underline.Line });
            _ctx.span_start = variable_struct_get(_ctx, "out_len");
        }
        else if (_name == "s") {
            __ww_textproc_ctx_flush_span__(_ctx, variable_struct_get(_ctx, "out_len"));
            __ww_textproc_ctx_apply_patch__(_ctx, { strike: __WW_Text_Glyph_Strike.Line });
            _ctx.span_start = variable_struct_get(_ctx, "out_len");
        }

        // Apply class rules (in order)
        if (_tag.class_text != "") {

            var _tokens = string_split(_tag.class_text, " ");
            var _count = array_length(_tokens);

            var _token_index = 0;
            repeat (_count) {

                var _class_name = __ww_css_trim__(_tokens[_token_index]);
                _token_index += 1;

                if (_class_name == "") { continue; }
                if (!ds_map_exists(__css_class_map__, _class_name)) { continue; }

                var _body = ds_map_find_value(__css_class_map__, _class_name);

                var _delta = __ww_css_style_delta_make__();
                __ww_css_apply_style_string_to_delta__(_delta, _body, _base_font_asset, _font_resolver);

                // Apply global-only changes only if allowed
                if (_delta.has_white_space && _global_allowed) { _white_space = _delta.white_space; }
                if (_delta.has_tab_size && _global_allowed) { _tab_size_spaces = _delta.tab_size_spaces; }
                if (_delta.has_overflow_wrap && _global_allowed) { _overflow_wrap = _delta.overflow_wrap; }

                // Alignment run changes
                if (_delta.has_align) {
                    var _new_align = _delta.align_value;
                    if (_new_align != _align_value) {
                        var _ctx_out_len = variable_struct_get(_ctx, "out_len");
                        if (_ctx_out_len > _align_start) {
                            array_push(_align_runs, { start_index: _align_start, end_index: _ctx_out_len, align_value: _align_value });
                        }
                        _align_value = _new_align;
                        _ctx.state.align_value = _align_value;
                        _align_start = variable_struct_get(_ctx, "out_len");
                    }
                }

                // Span patch changes
                var _patch = {};

                if (_delta.has_color) { _patch.color = _delta.color; }
                if (_delta.has_alpha) { _patch.alpha = _delta.alpha; }
                if (_delta.has_back_color) { _patch.back_color = _delta.back_color; }
                if (_delta.has_back_alpha) { _patch.back_alpha = _delta.back_alpha; }
                if (_delta.has_font) { _patch.font_asset = _delta.font_asset; }
                if (_delta.has_style) { _patch.style = _delta.style; }
                if (_delta.has_size_mul) { _patch.size_mul = _delta.size_mul; }
                if (_delta.has_underline) { _patch.underline = _delta.underline; }
                if (_delta.has_strike) { _patch.strike = _delta.strike; }

                if (variable_struct_names_count(_patch) > 0) {
                    __ww_textproc_ctx_flush_span__(_ctx, variable_struct_get(_ctx, "out_len"));
                    __ww_textproc_ctx_apply_patch__(_ctx, _patch);
                    _ctx.span_start = variable_struct_get(_ctx, "out_len");
                }
            }
        }

        // Apply inline style="..."
        if (_tag.style_text != "") {

            var _delta2 = __ww_css_style_delta_make__();
            __ww_css_apply_style_string_to_delta__(_delta2, _tag.style_text, _base_font_asset, _font_resolver);

            if (_delta2.has_white_space && _global_allowed) { _white_space = _delta2.white_space; }
            if (_delta2.has_tab_size && _global_allowed) { _tab_size_spaces = _delta2.tab_size_spaces; }
            if (_delta2.has_overflow_wrap && _global_allowed) { _overflow_wrap = _delta2.overflow_wrap; }

            if (_delta2.has_align) {

                var _new_align2 = _delta2.align_value;

                if (_new_align2 != _align_value) {
                    var _ctx_out_len2 = variable_struct_get(_ctx, "out_len");
                    if (_ctx_out_len2 > _align_start) {
                        array_push(_align_runs, { start_index: _align_start, end_index: _ctx_out_len2, align_value: _align_value });
                    }
                    _align_value = _new_align2;
                    _ctx.state.align_value = _align_value;
                    _align_start = variable_struct_get(_ctx, "out_len");
                }
            }

            var _patch2 = {};

            if (_delta2.has_color) { _patch2.color = _delta2.color; }
            if (_delta2.has_alpha) { _patch2.alpha = _delta2.alpha; }
            if (_delta2.has_back_color) { _patch2.back_color = _delta2.back_color; }
            if (_delta2.has_back_alpha) { _patch2.back_alpha = _delta2.back_alpha; }
            if (_delta2.has_font) { _patch2.font_asset = _delta2.font_asset; }
            if (_delta2.has_style) { _patch2.style = _delta2.style; }
            if (_delta2.has_size_mul) { _patch2.size_mul = _delta2.size_mul; }
            if (_delta2.has_underline) { _patch2.underline = _delta2.underline; }
            if (_delta2.has_strike) { _patch2.strike = _delta2.strike; }

            if (variable_struct_names_count(_patch2) > 0) {
                __ww_textproc_ctx_flush_span__(_ctx, variable_struct_get(_ctx, "out_len"));
                __ww_textproc_ctx_apply_patch__(_ctx, _patch2);
                _ctx.span_start = variable_struct_get(_ctx, "out_len");
            }
        }

        // Any emitted text after this point disables global-only changes
        // (kept identical to old behavior: it flips when we actually append chars)
    }

    // EOF align flush
    var _ctx_out_len_eof = variable_struct_get(_ctx, "out_len");
    if (_ctx_out_len_eof > _align_start) {
        array_push(_align_runs, { start_index: _align_start, end_index: _ctx_out_len_eof, align_value: _align_value });
    }

    var _res = __ww_textproc_ctx_finish__(_ctx);
    _res.align_runs = _align_runs;
    _res.white_space = _white_space;
    _res.overflow_wrap = _overflow_wrap;
    _res.tab_size_spaces = _tab_size_spaces;

    return _res;
}
