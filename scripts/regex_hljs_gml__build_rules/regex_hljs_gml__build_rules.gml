/// @func regex_hljs_gml__build_rules()
/// @desc Build and compile the rule list used to highlight GML.
/// @returns {Array} rules
function regex_hljs_gml__build_rules() {
    var _rules = [];

    // ------------------------------------------------------------------
    // Comments (hljs: COMMENT variants)
    // ------------------------------------------------------------------
    array_push(_rules, {
        name: "comment_jsdoc_line",
        scope: "comment",
        priority: 10,
        program: regex_build_program(@"\/\/\/[^\n]*")
    });

    array_push(_rules, {
        name: "comment_jsdoc_block",
        scope: "comment",
        priority: 11,
        program: regex_build_program(@"\/\*\*([^*]|\*[^\/])*\*\/")
    });

    array_push(_rules, {
        name: "comment_line",
        scope: "comment",
        priority: 12,
        program: regex_build_program(@"\/\/[^\n]*")
    });

    array_push(_rules, {
        name: "comment_block",
        scope: "comment",
        priority: 13,
        program: regex_build_program(@"\/\*([^*]|\*[^\/])*\*\/")
    });

    // ------------------------------------------------------------------
    // Preprocessor (hljs: PREPROCESSOR variants) - keep high, before numbers/strings
    // ------------------------------------------------------------------
    // #macro Name:OtherName ...
    array_push(_rules, {
        name: "preproc_macro_pair",
        scope: "meta.macro.pair",
        priority: 18,
        program: regex_build_program(@"#macro\s+[a-zA-Z_][a-zA-Z0-9_]*\s*:\s*[a-zA-Z_][a-zA-Z0-9_]*[^\n]*")
    });

    // #macro Name ...
    array_push(_rules, {
        name: "preproc_macro_single",
        scope: "meta.macro",
        priority: 19,
        program: regex_build_program(@"#macro\s+[a-zA-Z_][a-zA-Z0-9_]*[^\n]*")
    });

    // #(end)?region\b ...
    array_push(_rules, {
        name: "preproc_region",
        scope: "meta",
        priority: 20,
        program: regex_build_program(@"#(end)?region\b[^\n]*")
    });

    // ------------------------------------------------------------------
    // Numbers (hljs: NUMBER variants)
    // ------------------------------------------------------------------
    array_push(_rules, {
        name: "number_hex_dollar",
        scope: "number",
        priority: 30,
        program: regex_build_program(@"\$[0-9a-fA-F]+")
    });

    array_push(_rules, {
        name: "number_hex_hash",
        scope: "number",
        priority: 31,
        program: regex_build_program(@"#[0-9a-fA-F]+")
    });

    array_push(_rules, {
        name: "number_0x",
        scope: "number",
        priority: 32,
        program: regex_build_program(@"0x[0-9a-fA-F][0-9a-fA-F_]*")
    });

    array_push(_rules, {
        name: "number_0b",
        scope: "number",
        priority: 33,
        program: regex_build_program(@"0b[01][01_]*")
    });

    array_push(_rules, {
        name: "number_dec",
        scope: "number",
        priority: 34,
        program: regex_build_program(@"[0-9][0-9_.]*")
    });

    // ------------------------------------------------------------------
    // Strings (hljs: STRING variants order)
    // ------------------------------------------------------------------
    // $"..." template string (single-span; includes { ... } blocks, non-nested)
    array_push(_rules, {
        name: "string_template",
        scope: "string",
        priority: 40,
        program: regex_build_program(@'\$""([^\\\n""]|\\.|{[^}\n]*})*""')
    });

    // @'...' raw single (can span newlines)
    array_push(_rules, {
        name: "string_raw_single",
        scope: "string",
        priority: 41,
        program: regex_build_program(@"@'[^']*'")
    });

    // @"..." raw double (can span newlines)
    array_push(_rules, {
        name: "string_raw_double",
        scope: "string",
        priority: 42,
        program: regex_build_program(@'@""[^""]*""')
    });

    // "..." normal (newline illegal; allow escapes)
    array_push(_rules, {
        name: "string_double",
        scope: "string",
        priority: 43,
        program: regex_build_program(@'""([^\\\n""]|\\.)*""')
    });

    // ------------------------------------------------------------------
    // hljs: ENUM_DEFINITION, SWITCH_CASE, and other structured constructs
    // ------------------------------------------------------------------
    // enum <ident> {
    array_push(_rules, {
        name: "enum_decl_whole",
        scope: "meta.enum.decl",
        priority: 50,
        program: regex_build_program(@"\benum\s+[a-zA-Z_][a-zA-Z0-9_]*\s*{")
    });

    // case <expr>:
    array_push(_rules, {
        name: "switch_case_whole",
        scope: "meta.switch.case",
        priority: 51,
        program: regex_build_program(@"\bcase\s+[^:\n]*:")
    });

    // Struct literal member: <ident>:
    array_push(_rules, {
        name: "struct_member_whole",
        scope: "meta.struct.member",
        priority: 60,
        program: regex_build_program(@"\b[a-zA-Z_][a-zA-Z0-9_]*\s*:")
    });

    // function <ident>(
    array_push(_rules, {
        name: "function_decl_whole",
        scope: "meta.function.decl",
        priority: 61,
        program: regex_build_program(@"\bfunction\s+[a-zA-Z_][a-zA-Z0-9_]*\s*\(")
    });

    // ------------------------------------------------------------------
    // hljs: DS_MAP_ACCESS, FUNCTION_CALL, USER_ASSET_CONSTANT, PROP_ACCESS
    // ------------------------------------------------------------------
    // ds_map accessor prefix [?
    array_push(_rules, {
        name: "ds_map_access",
        scope: "punctuation",
        priority: 70,
        program: regex_build_program(@"\[\?")
    });

    // user asset constants: spr_* and obj_* (direct scope)
    array_push(_rules, {
        name: "user_asset_constant_spr",
        scope: "variable.constant",
        priority: 71,
        program: regex_build_program(@"\bspr_[a-zA-Z_][a-zA-Z0-9_]*")
    });

    array_push(_rules, {
        name: "user_asset_constant_obj",
        scope: "variable.constant",
        priority: 72,
        program: regex_build_program(@"\bobj_[a-zA-Z_][a-zA-Z0-9_]*")
    });

    // dot-access invoke: . ident (
    array_push(_rules, {
        name: "dot_invoke_whole",
        scope: "meta.prop.invoke",
        priority: 80,
        program: regex_build_program(@"\.\s*[a-zA-Z_][a-zA-Z0-9_]*\s*\(")
    });

    // dot-access property: . ident
    array_push(_rules, {
        name: "dot_prop_whole",
        scope: "meta.prop.access",
        priority: 81,
        program: regex_build_program(@"\.\s*[a-zA-Z_][a-zA-Z0-9_]*")
    });

    // function call: ident(
    array_push(_rules, {
        name: "function_call_whole",
        scope: "meta.func.call",
        priority: 90,
        program: regex_build_program(@"\b[a-zA-Z_][a-zA-Z0-9_]*\s*\(")
    });

    // ------------------------------------------------------------------
    // Identifiers (post-classify using lookup dict)
    // ------------------------------------------------------------------
    array_push(_rules, {
        name: "identifier",
        scope: "identifier",
        priority: 100,
        program: regex_build_program(@"[a-zA-Z_][a-zA-Z0-9_]*")
    });

    return _rules;
}
