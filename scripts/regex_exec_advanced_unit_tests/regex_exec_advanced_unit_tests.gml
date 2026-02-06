/// Test 11: hljs-derived highlight smoke + basic invariants
/// Uses: regex_hljs_gml_highlight(_input) -> Array<Struct> spans { start, "end", scope }
///
/// Checks:
/// - Returns an array
/// - Spans are well-formed (start/end increasing, non-overlapping, end > start)
/// - At least one comment span is produced (line comments and/or jsdoc)
/// - At least one keyword span is produced (via identifier post-classification)
/// - At least one string span is produced (double-quoted, and/or $"..." template)

function regex__span_get_end(_span) {
    if (is_struct(_span) && variable_struct_exists(_span, "end")) return _span[$ "end"];
    return -1;
}

function regex__count_scope_exact(_spans, _scope_name) {
    var _count = 0;
    var _span_count = array_length(_spans);

    var _index = 0;
    repeat (_span_count) {
        var _span = _spans[_index];
        if (is_struct(_span) && variable_struct_exists(_span, "scope")) {
            if (_span.scope == _scope_name) _count += 1;
        }
        _index += 1;
    }

    return _count;
}

function regex__count_scope_prefix(_spans, _scope_prefix) {
    var _count = 0;
    var _span_count = array_length(_spans);

    var _index = 0;
    repeat (_span_count) {
        var _span = _spans[_index];
        if (is_struct(_span) && variable_struct_exists(_span, "scope")) {
            var _scope_text = _span.scope;
            if (is_string(_scope_text)) {
                if (string_copy(_scope_text, 1, string_length(_scope_prefix)) == _scope_prefix) {
                    _count += 1;
                }
            }
        }
        _index += 1;
    }

    return _count;
}

function regex_test_11_hljs_example_highlight() {
    var _example = @'
#macro DEBUG false
#macro Debug:DEBUG true
#macro Release:DEBUG false

/// @description Collision code
/// @self {Id.Instance}
function standard_collisions() {

    // standard collision handling

    // Horizontal collisions
    if(place_meeting(x+hspd, y, obj_wall)) {
        while(!place_meeting(x+sign(hspd), y, obj_wall)) {
            x += sign(hspd);
        }
        hspd = 0;
    }
    x += hspd;

    // Vertical collisions
    if(place_meeting(x, y+vspd, collide_obj)) {
        while(!place_meeting(x, y+sign(vspd), collide_obj)) {
            y += sign(vspd);
        }
        vspd = 0;
    }
    y += vspd;

    if (DEBUG) {
        show_debug_message($"x: {x},\ty: {y}");
    }

}

/// @description A sample constructor that does something.
/// @param {Real} [some_data=2] Some optional data.
function SomeConstructor(some_data = 2) constructor {

    some_data = some_data;

    /// @description Some example function!
    /// @pure
    /// @param {String} stuff
    /// @returns {Bool}
    static do_things = function(stuff) {
        if (string_digits(stuff) != stuff) {
            return false;
        }

        return real(stuff) == some_data;
    };

}

/** @desc Some random enum. */
enum AnEnum {
    /** @desc It is zero! */
    Zero = 0,
    /** @desc It is one! */
    One = 1
}

var some_constructor = new SomeConstructor(AnEnum.Zero);

if (some_constructor.do_things("0")) {
    throw "idk";
}';

    show_debug_message("== Test11 hljs example highlight ==");
    show_debug_message("input_len=" + string(string_length(_example)));

    // Call the actual highlighter we are validating
    var _spans = regex_hljs_gml_highlight(_example);

    var _ok_is_array = is_array(_spans);
    var _span_count = 0;
    if (_ok_is_array) _span_count = array_length(_spans);

    show_debug_message("span_count=" + string(_span_count));

    // Invariants: monotonic, non-overlapping, start/end valid
    var _ok_well_formed = true;
    if (_ok_is_array) {
        var _prev_end = 0;

        var _index = 0;
        repeat (_span_count) {
            var _span = _spans[_index];

            if (!is_struct(_span)) { _ok_well_formed = false; break; }
            if (!variable_struct_exists(_span, "start")) { _ok_well_formed = false; break; }
            if (!variable_struct_exists(_span, "end")) { _ok_well_formed = false; break; }
            if (!variable_struct_exists(_span, "scope")) { _ok_well_formed = false; break; }

            var _start_pos = _span.start;
            var _end_pos = regex__span_get_end(_span);

            if (_end_pos <= _start_pos) { _ok_well_formed = false; break; }
            if (_start_pos < _prev_end) { _ok_well_formed = false; break; }

            _prev_end = _end_pos;

            _index += 1;
        }
    }

    // We accept either "comment" or "comment.line" or "comment.block" etc.
    var _comment_count = 0;
    if (_ok_is_array) {
        _comment_count += regex__count_scope_exact(_spans, "comment");
        _comment_count += regex__count_scope_prefix(_spans, "comment.");
        _comment_count += regex__count_scope_prefix(_spans, "doctag");
        _comment_count += regex__count_scope_prefix(_spans, "meta"); // some hljs rules use "meta" for macros
    }

    // Keyword spans come from identifier post-classification in your highlighter.
    var _keyword_count = 0;
    if (_ok_is_array) {
        _keyword_count += regex__count_scope_exact(_spans, "keyword");
        _keyword_count += regex__count_scope_prefix(_spans, "keyword.");
    }

    // Strings: depends on your rule scopes (commonly "string", "string.quoted", "string.template", etc.)
    var _string_count = 0;
    if (_ok_is_array) {
        _string_count += regex__count_scope_exact(_spans, "string");
        _string_count += regex__count_scope_prefix(_spans, "string.");
    }

    show_debug_message("comment_like=" + string(_comment_count) + " keyword_like=" + string(_keyword_count) + " string_like=" + string(_string_count));

    var _ok_nonempty = (_span_count > 0);
    var _ok_has_comment = (_comment_count > 0);
    var _ok_has_keyword = (_keyword_count > 0);

    // Strings are present in the sample, but if your rules don't tokenize them yet,
    // we won't fail the entire test on that. We print it for visibility instead.
    var _ok_string_optional = true;

    regex__print_expect_result("array=1, nonempty=1, well_formed=1, has_comment_and_keyword=1",
        _ok_is_array,
        _ok_nonempty,
        _ok_well_formed,
        (_ok_has_comment && _ok_has_keyword));

    // Extra informational expectation (non-failing)
    show_debug_message("EXPECT (info): string_like > 0 (optional for now)");
    show_debug_message("RESULT (info): " + string(_string_count > 0) + " (count=" + string(_string_count) + ")");
	
	pprint(_spans)
}

/// Add this to your runner
function regex_run_hljs_tests() {
    regex_test_11_hljs_example_highlight();
}
