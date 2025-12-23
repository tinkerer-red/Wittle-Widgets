#region jsDoc
/// @func   ww_apply_demo_syntax_to_textbox()
/// @desc   Applies demo syntax formatting to the textbox using the new
///         glyph-embedded formatting system.
///         This:
///         - Applies once immediately
///         - Re-applies on every text change (layout rebuild recreates glyphs)
/// @param  {Struct.WWTextBoxV3} _textbox
/// @returns {Struct.WWTextBoxV3}
#endregion
function ww_apply_demo_syntax_to_textbox(_textbox) {
	// Apply once now
    ww_apply_demo_syntax(_textbox);
	
    // Re-apply whenever the textbox text changes (because glyphs are rebuilt)
    _textbox.on_change(method(_textbox, function(_input) {
        ww_apply_demo_syntax(self);
    }));
    
    return _textbox;
}

#region jsDoc
/// @func   ww_apply_demo_syntax()
/// @desc   Reads the textbox current text, highlights via regex_hljs_gml_highlight(),
///         and applies formatting ranges to the renderer.
/// @param  {Struct.WWTextBoxv3} _textbox
#endregion
function ww_apply_demo_syntax(_textbox) {

    if (is_undefined(_textbox)) {
        return;
    }

    var _text = _textbox.get_text();
    var _text_len = string_length(_text);

    if (_text_len <= 0) {
        return;
    }

    // Clear any existing formatting first
    _textbox.clear_format_range(0, _text_len);

    // Theme colors (ARGB)
    var _theme = {
        col_default: #C0C0C0,
        col_normal_text: #C0C0C0,
        col_keywords: #FFB871,
        col_values: #FF8080,
        col_strings: #FFFF00,
        col_comments: #5B995B,
        col_constants: #FF8080,
        col_builtin_variables: #58E55A,
        col_object_variables: #B2B1FF,
        col_functions: #FFB871,
        col_script_names: #FFB871,
        col_resource_names: #FF8080,
        col_enums: #FF8080,
        col_enum_entries: #FF8080,
        col_macros: #FF5B5B,
        col_local_variable: #FFF899,
        col_global_variable: #FF7EFF,
        col_static_variable: #C52DE4,
        col_line_number_text: #40C3F4,
        col_read_only_line_numbers: #FF0000,
        col_bookmark_line_numbers: #222222,
        col_whitespace: #0000FF,
        col_obsolete_symbol: #0060FF,
        col_struct_member: #FF8080,
        col_braces: #FFB871
    };

    // Highlight -> spans: { start, "end", scope } where start/end are 0-based
    var _spans = regex_hljs_gml_highlight(_text);
    var _span_count = array_length(_spans);

    var _si = 0;
    repeat (_span_count) {

        var _span = _spans[_si];

        var _start_0 = _span.start;
        var _end_0_excl = _span.end;
        var _scope = _span.scope;

        var _color = ww__scope_to_color(_scope, _theme);
        ww__set_color_span_0(_textbox, _start_0, _end_0_excl, _color);

        // Optional style: make keywords bold if supported
        if (_scope == "keyword") {
            _textbox.set_glyph_style_range(_start_0, _end_0_excl, __WW_Text_Glyph_Style.Bold);
        }

        _si += 1;
    }
}

#region jsDoc
/// @func   ww__is_digit()
/// @desc   Returns true if the character is [0-9].
/// @param  {String} _char_val
/// @returns {Bool}
#endregion
function ww__is_digit(_char_val) {
    var _code = ord(_char_val);
    return (_code >= ord("0") && _code <= ord("9"));
}

#region jsDoc
/// @func   ww__is_alpha()
/// @desc   Returns true if the character is [A-Z] or [a-z].
/// @param  {String} _char_val
/// @returns {Bool}
#endregion
function ww__is_alpha(_char_val) {
    var _code = ord(_char_val);
    return ((_code >= ord("a") && _code <= ord("z")) || (_code >= ord("A") && _code <= ord("Z")));
}

#region jsDoc
/// @func   ww__is_ident_char()
/// @desc   Returns true if the character is valid in an identifier: [_a-zA-Z0-9].
/// @param  {String} _char_val
/// @returns {Bool}
#endregion
function ww__is_ident_char(_char_val) {
    return (_char_val == "_" || ww__is_alpha(_char_val) || ww__is_digit(_char_val));
}

#region jsDoc
/// @func   ww__is_ident_start()
/// @desc   Returns true if the character can start an identifier: [_a-zA-Z].
/// @param  {String} _char_val
/// @returns {Bool}
#endregion
function ww__is_ident_start(_char_val) {
    return (_char_val == "_" || ww__is_alpha(_char_val));
}

#region jsDoc
/// @func   ww__set_color_span_1()
/// @desc   Applies a color range using 1-based inclusive start/end indices,
///         converting to 0-based [start,end) for the renderer.
/// @param  {Struct.WWTextRendererBase} _renderer
/// @param  {Real} _start_1
/// @param  {Real} _end_1_inclusive
/// @param  {Constant.Color} _col
#endregion
function ww__set_color_span_1(_renderer, _start_1, _end_1_inclusive, _col) {

    var _start_0 = _start_1 - 1;
    var _end_0_excl = _end_1_inclusive;

    if (_end_0_excl <= _start_0) {
        return;
    }

    // Only call if supported (keeps demo robust)
    if (!is_undefined(_renderer.set_glyph_color_range)) {
        _renderer.set_glyph_color_range(_start_0, _end_0_excl, _col);
    }
}

#region jsDoc
/// @func   ww__set_color_span_0()
/// @desc   Applies a color range using 0-based [start,end) indices.
/// @param  {Struct.WWTextRendererBase} _renderer
/// @param  {Real} _start_0
/// @param  {Real} _end_0_excl
/// @param  {Constant.Color} _col
#endregion
function ww__set_color_span_0(_textbox, _start_0, _end_0_excl, _col) {

    if (_end_0_excl <= _start_0) {
        return;
    }

    _textbox.set_glyph_color_range(_start_0, _end_0_excl, _col);
    
}

#region jsDoc
/// @func   ww__scope_to_color()
/// @desc   Map hljs-like scopes to demo theme colors.
/// @param  {String} _scope
/// @param  {Struct} _theme
/// @returns {Constant.Color}
#endregion
function ww__scope_to_color(_scope, _theme) {

    // Fast path
    if (_scope == "" || is_undefined(_scope)) {
        return _theme.col_default;
    }

    // Common hljs scopes for GML rulesets
    if (_scope == "comment") return _theme.col_comments;
    if (_scope == "string") return _theme.col_strings;
    if (_scope == "number") return _theme.col_values;

    if (_scope == "keyword") return _theme.col_keywords;
    if (_scope == "literal") return _theme.col_values;

    // hljs sometimes uses either "built_in" or "builtin"
    if (_scope == "built_in") return _theme.col_functions;
    if (_scope == "builtin") return _theme.col_functions;

    // language vars like self/other/all/noone/global, etc
    if (_scope == "variable.language") return _theme.col_builtin_variables;

    // Some grammars tag types/enums/symbols distinctly
    if (_scope == "type") return _theme.col_enums;
    if (_scope == "symbol") return _theme.col_constants;
    if (_scope == "meta") return _theme.col_macros;

    // Titles are often used for function/script names in hljs grammars
    if (_scope == "title") return _theme.col_script_names;
    if (_scope == "title.function") return _theme.col_functions;
	
	if (_scope == "meta.func.call") return _theme.col_functions;
	if (_scope == "meta.function.decl") return _theme.col_functions;
	
	if (_scope == "meta.enum.decl") return _theme.col_enums;
	
	if (_scope == "meta.macro") return _theme.col_macros;
	if (_scope == "meta.macro.pair") return _theme.col_macros;
	
	if (_scope == "meta.prop.access") return _theme.col_struct_member;
	if (_scope == "meta.prop.invoke") return _theme.col_struct_member;
	if (_scope == "meta.struct.member") return _theme.col_struct_member;
	
	if (_scope == "variable.constant") return _theme.col_constants;


    // Fallback
    return _theme.col_normal_text;
}

#region jsDoc
/// @func   ww__try_get_renderer()
/// @desc   Best-effort renderer fetch so the demo doesn't explode if wiring differs.
/// @param  {Struct} _textbox
/// @returns {Struct|Undefined}
#endregion
function ww__try_get_renderer(_textbox) {

    if (is_undefined(_textbox)) {
        return undefined;
    }

    if (!is_undefined(_textbox.get_renderer)) {
        return _textbox.get_renderer();
    }

    if (!is_undefined(_textbox.renderer)) {
        return _textbox.renderer;
    }

    if (!is_undefined(_textbox.text_renderer)) {
        return _textbox.text_renderer;
    }

    return undefined;
}
