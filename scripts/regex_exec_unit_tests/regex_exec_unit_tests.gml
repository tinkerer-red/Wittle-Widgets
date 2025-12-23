/// Execution smoke tests for RegexPattern + VM runner
/// These DO require the runner (regex__run_from etc.) to be wired correctly.

function regex__print_exec_summary(_label, _pattern_text, _input_text, _result) {
    show_debug_message("== " + _label + " ==");
    show_debug_message("pattern=" + _pattern_text);
    show_debug_message("input=" + _input_text);
    show_debug_message("found=" + string(_result.found) + " start=" + string(_result.start) + " end=" + string(_result.end));
}

function regex__print_expect_exec(_expect_label, _ok_a, _ok_b, _ok_c, _ok_d) {
    show_debug_message("EXPECT: " + _expect_label);
    show_debug_message("RESULT: " + string(_ok_a) + " " + string(_ok_b) + " " + string(_ok_c) + " " + string(_ok_d));
}

/// Test 7: match() vs search()
/// Pattern: abc
/// Input:   zabc
/// Expected:
/// - match() fails (only byte 0)
/// - search() finds at start=1 end=4
function regex_test_07_match_vs_search() {
    var _pattern_text = @"abc";
    var _pattern = regex.compile(_pattern_text);

    var _input_text = "zabc";

    var _res_match = _pattern.match(_input_text);
    var _res_search = _pattern.search(_input_text, 0);

    regex__print_exec_summary("Test07 match() vs search() - match", _pattern_text, _input_text, _res_match);
    regex__print_exec_summary("Test07 match() vs search() - search", _pattern_text, _input_text, _res_search);

    var _ok_match_found = (_res_match.found == false);
    var _ok_search_found = (_res_search.found == true);
    var _ok_search_pos = (_res_search.start == 1);
    var _ok_search_end = (_res_search.end == 4);

    regex__print_expect_exec("match_found=0, search_found=1, search_start=1, search_end=4",
        _ok_match_found, _ok_search_found, _ok_search_pos, _ok_search_end);
}

/// Test 8: findall() of numbers with optional leading dot
/// Pattern: \.?[0-9]+
/// Input:   "a .123 b 0.123 c 123 d .9"
/// Expected (non-capturing):
/// - findall returns 4 matches
/// - exact strings: ".123", "0", ".123", "123", ".9"? wait: "0.123" should match "0" then ".123"
///   because our engine is NFA without alternation preference tuning for this pattern.
/// So we pick an input that avoids that ambiguity:
/// Input:   "a .123 b 123 c .9"
/// Expected: [".123","123",".9"]
function regex_test_08_findall_numbers() {
    var _pattern_text = @"\.?[0-9]+";
    var _pattern = regex.compile(_pattern_text);

    var _input_text = "a .123 b 123 c .9";
    var _arr = _pattern.findall(_input_text, 0);

    show_debug_message("== Test08 findall numbers ==");
    show_debug_message("pattern=" + _pattern_text);
    show_debug_message("input=" + _input_text);
    show_debug_message("count=" + string(array_length(_arr)));

    var _ok_count = (array_length(_arr) == 3);

    var _ok_0 = false;
    var _ok_1 = false;
    var _ok_2 = false;

    if (array_length(_arr) == 3) {
        _ok_0 = (_arr[0] == ".123");
        _ok_1 = (_arr[1] == "123");
        _ok_2 = (_arr[2] == ".9");
    }

    regex__print_expect_exec("count=3, [0]=.123, [1]=123, [2]=.9", _ok_count, _ok_0, _ok_1, _ok_2);
}

/// Test 9: sub() replacing identifiers (very simple)
/// Pattern: [a-zA-Z_][a-zA-Z0-9_]*
/// Input:   "var hello_world = foo2 + bar;"
/// Replacement: "ID"
/// Expected:
/// - returns "ID ID = ID + ID;"
/// Notes:
/// - This treats keywords the same as identifiers (fine for smoke test)
function regex_test_09_sub_identifiers() {
    var _pattern_text = @"[a-zA-Z_][a-zA-Z0-9_]*";
    var _pattern = regex.compile(_pattern_text);

    var _input_text = "var hello_world = foo2 + bar;";
    var _expected = "ID ID = ID + ID;";

    var _output_text = _pattern.sub(_input_text, "ID", 0);

    show_debug_message("== Test09 sub identifiers ==");
    show_debug_message("pattern=" + _pattern_text);
    show_debug_message("input=" + _input_text);
    show_debug_message("output=" + _output_text);

    var _ok_equal = (_output_text == _expected);

    // Additional sanity: output must be shorter or equal? Not necessarily, but here it is shorter.
    var _ok_len = (string_length(_output_text) == string_length(_expected));

    // Also ensure at least one replacement happened (output differs from input)
    var _ok_changed = (_output_text != _input_text);

    // Ensure it still ends with ';'
    var _ok_semicolon = (string_char_at(_output_text, string_length(_output_text)) == ";");

    regex__print_expect_exec("output==expected, len_ok, changed, ends_with_semicolon",
        _ok_equal, _ok_len, _ok_changed, _ok_semicolon);
}

/// Run execution tests (runner required)
function regex_run_basic_exec_tests() {
    regex_test_07_match_vs_search();
    regex_test_08_findall_numbers();
    regex_test_09_sub_identifiers();
}
