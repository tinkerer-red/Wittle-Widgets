/// Basic smoke tests for regex_build_program()
/// These tests do NOT require a runner - they only sanity-check the compiled program shape.

function regex__count_op(_program, _opcode) {
    var _count = 0;
    var _op_arr = _program.op;
    var _len = array_length(_op_arr);

    var _i = 0;
    repeat (_len) {
        if (_op_arr[_i] == _opcode) _count += 1;
        _i += 1;
    }
    return _count;
}

function regex__has_op(_program, _opcode) {
    return (regex__count_op(_program, _opcode) > 0);
}

function regex__print_program_summary(_label, _program) {
    // Keep these numbers in sync with regex_build_program()'s opcode constants:
    // OP_MATCH=0 OP_CHAR=1 OP_CLASS=2 OP_ANY=3 OP_JUMP=4 OP_SPLIT=5 OP_BOL=6 OP_EOL=7 OP_WB=8 OP_NWB=9
    var _match_count = regex__count_op(_program, 0);
    var _char_count  = regex__count_op(_program, 1);
    var _class_count = regex__count_op(_program, 2);
    var _any_count   = regex__count_op(_program, 3);
    var _jump_count  = regex__count_op(_program, 4);
    var _split_count = regex__count_op(_program, 5);
    var _bol_count   = regex__count_op(_program, 6);
    var _eol_count   = regex__count_op(_program, 7);
    var _wb_count    = regex__count_op(_program, 8);
    var _nwb_count   = regex__count_op(_program, 9);

    var _prog_len = array_length(_program.op);
    var _cls_len  = array_length(_program.cls);

    show_debug_message("== " + _label + " ==");
    show_debug_message("start=" + string(_program.start) + " prog_len=" + string(_prog_len) + " class_defs=" + string(_cls_len));
    show_debug_message("ops: MATCH=" + string(_match_count)
        + " CHAR=" + string(_char_count)
        + " CLASS=" + string(_class_count)
        + " ANY=" + string(_any_count)
        + " JUMP=" + string(_jump_count)
        + " SPLIT=" + string(_split_count)
        + " BOL=" + string(_bol_count)
        + " EOL=" + string(_eol_count)
        + " WB=" + string(_wb_count)
        + " NWB=" + string(_nwb_count));
}

function regex__print_expect_result(_expect_label, _ok_a, _ok_b, _ok_c, _ok_d) {
    show_debug_message("EXPECT: " + _expect_label);
    show_debug_message("RESULT: " + string(_ok_a) + " " + string(_ok_b) + " " + string(_ok_c) + " " + string(_ok_d));
}

/// Test 1: Pure escaped literals (highlight.js comment start "///")
/// Pattern: \/\/\/
/// Expected:
/// - Contains CHAR ops (no CLASS needed)
/// - No SPLIT ops (no alternation/quantifiers)
/// - Exactly 1 MATCH op
function regex_test_01_triple_slash() {
    var _pattern = @'\/\/\/';
    var _program = regex_build_program(_pattern);

    regex__print_program_summary("Test01 triple-slash", _program);

    var _ok_match = (regex__count_op(_program, 0) == 1);
    var _ok_char  = regex__has_op(_program, 1);
    var _ok_split = (!regex__has_op(_program, 5));
    var _ok_class = (!regex__has_op(_program, 2));

    regex__print_expect_result("MATCH=1, CHAR>0, SPLIT=0, CLASS=0", _ok_match, _ok_char, _ok_split, _ok_class);
}

/// Test 2: Identifier rule (highlight.js style)
/// Pattern: [a-zA-Z_][a-zA-Z0-9_]*
/// Expected:
/// - At least 1 CLASS op (two class atoms in pattern)
/// - At least 1 SPLIT op (because of the trailing '*')
/// - Exactly 1 MATCH op
/// - At least 2 class definitions stored (builder may store 2 separate class ids)
function regex_test_02_identifier() {
    var _pattern = @"[a-zA-Z_][a-zA-Z0-9_]*";
    var _program = regex_build_program(_pattern);

    regex__print_program_summary("Test02 identifier", _program);

    var _ok_match = (regex__count_op(_program, 0) == 1);
    var _ok_class = regex__has_op(_program, 2);
    var _ok_split = regex__has_op(_program, 5);
    var _ok_cls_table = (array_length(_program.cls) >= 2);

    regex__print_expect_result("MATCH=1, CLASS>0, SPLIT>0, class_defs>=2", _ok_match, _ok_class, _ok_split, _ok_cls_table);
}

/// Test 3: Optional group + word boundary
/// Pattern: #(end)?region\b
/// Expected:
/// - CHAR ops for '#', 'e','n','d','r','e','g','i','o','n'
/// - SPLIT op for the optional "(end)?"
/// - WB op for \b
/// - Exactly 1 MATCH op
function regex_test_03_region_directive() {
    var _pattern = @"#(end)?region\b";
    var _program = regex_build_program(_pattern);

    regex__print_program_summary("Test03 #(end)?region\\b", _program);

    var _ok_match = (regex__count_op(_program, 0) == 1);
    var _ok_char  = regex__has_op(_program, 1);
    var _ok_split = regex__has_op(_program, 5);
    var _ok_wb    = regex__has_op(_program, 8);

    regex__print_expect_result("MATCH=1, CHAR>0, SPLIT>0, WB>0", _ok_match, _ok_char, _ok_split, _ok_wb);
}

/// Test 4: Alternation + grouping
/// Pattern: (ab|cd)e
/// Expected:
/// - CHAR ops present
/// - SPLIT ops present (from alternation)
/// - Exactly 1 MATCH op
/// - Program length > 1 + number of literal chars (branching adds extra states)
function regex_test_04_alternation_grouping() {
    var _pattern = @"(ab|cd)e";
    var _program = regex_build_program(_pattern);

    regex__print_program_summary("Test04 (ab|cd)e", _program);

    var _ok_match = (regex__count_op(_program, 0) == 1);
    var _ok_char  = regex__has_op(_program, 1);
    var _ok_split = regex__has_op(_program, 5);

    var _literal_count = 5; // a b c d e
    var _ok_len = (array_length(_program.op) > (_literal_count + 1)); // must exceed linear chain

    regex__print_expect_result("MATCH=1, CHAR>0, SPLIT>0, prog_len>(literals+1)", _ok_match, _ok_char, _ok_split, _ok_len);
}

/// Test 5: Lazy star structure (a*?b)
/// Expected:
/// - CHAR ops present (at least 'a' and 'b')
/// - SPLIT ops present (from '*?')
/// - Exactly 1 MATCH op
/// - No CLASS required
function regex_test_05_lazy_star() {
    var _pattern = @"a*?b";
    var _program = regex_build_program(_pattern);

    regex__print_program_summary("Test05 a*?b", _program);

    var _ok_match = (regex__count_op(_program, 0) == 1);
    var _ok_char  = (regex__count_op(_program, 1) >= 2);
    var _ok_split = regex__has_op(_program, 5);
    var _ok_class = (!regex__has_op(_program, 2));

    regex__print_expect_result("MATCH=1, CHAR>=2, SPLIT>0, CLASS=0", _ok_match, _ok_char, _ok_split, _ok_class);
}

/// Test 6: Negated class + plus ([^a-z]+)
/// Expected:
/// - CLASS ops present
/// - SPLIT ops present (from '+')
/// - Exactly 1 MATCH op
/// - At least 1 class definition, with negation flag set to 1 on the used class id
function regex_test_06_negated_class_plus() {
    var _pattern = @"[^a-z]+";
    var _program = regex_build_program(_pattern);

    regex__print_program_summary("Test06 [^a-z]+", _program);

    var _ok_match = (regex__count_op(_program, 0) == 1);
    var _ok_class = (regex__count_op(_program, 2) >= 1);
    var _ok_split = regex__has_op(_program, 5);

    var _ok_neg = false;
    var _class_count = array_length(_program.cls);
    if (_class_count > 0) {
        // Find a CLASS state and verify its class id is negated in program.neg
        var _op_arr = _program.op;
        var _data_arr = _program.data;
        var _len = array_length(_op_arr);

        var _i = 0;
        repeat (_len) {
            if (_op_arr[_i] == 2) { // OP_CLASS
                var _cid = _data_arr[_i];
                if (_cid >= 0 && _cid < array_length(_program.neg)) {
                    if (_program.neg[_cid] == 1) { _ok_neg = true; break; }
                }
            }
            _i += 1;
        }
    }

    regex__print_expect_result("MATCH=1, CLASS>=1, SPLIT>0, neg_flag_on_used_class=1", _ok_match, _ok_class, _ok_split, _ok_neg);
}

/// Run all builder-only tests
function regex_run_basic_builder_tests() {
    regex_test_01_triple_slash();
    regex_test_02_identifier();
    regex_test_03_region_directive();

    regex_test_04_alternation_grouping();
    regex_test_05_lazy_star();
    regex_test_06_negated_class_plus();
}
