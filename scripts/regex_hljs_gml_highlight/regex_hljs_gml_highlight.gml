#region jsDoc
/// @func   regex_hljs_gml_highlight()
/// @desc   Highlight a GML source string using hljs-derived rules.
/// @param  {String} _input
/// @returns {Array<Struct>} spans: { start, "end", scope }
#endregion
function regex_hljs_gml_highlight(_input) {
    static _temp_buff = buffer_create(0, buffer_grow, 1);
    static _text_buff = buffer_create(0, buffer_fast, 1);

    var _rules = regex_hljs_gml__build_rules();
    var _lookup = regex_hljs_gml__dict();

    // Write input -> _text_buff as bytes
    buffer_write(_temp_buff, buffer_text, _input);
    var _len = buffer_tell(_temp_buff);

    buffer_resize(_text_buff, _len);
    buffer_copy(_temp_buff, 0, _len, _text_buff, 0);
    buffer_resize(_temp_buff, 0);

    var _spans = [];
    var _pos = 0;

    while (_pos < _len) {
        var _best_rule = -1;
        var _best_end = -1;

        // All rules are implicitly "search from _pos" by scanning forward.
        // Since regex__run_from() is anchored, we do: try each rule at each position.
        // This is simple and correct for now. We can speed it up later.
        var _rule_count = array_length(_rules);
        var _ri = 0;
        repeat (_rule_count) {
            var _rule = _rules[_ri];

            var _end_here = regex__run_from(_rule.program, _text_buff, _len, _pos);
            if (_end_here >= 0) {
                if (_best_rule < 0) {
                    _best_rule = _ri;
                    _best_end = _end_here;
                } else {
                    var _best_len = _best_end - _pos;
                    var _cand_len = _end_here - _pos;

                    if (_cand_len > _best_len) {
                        _best_rule = _ri;
                        _best_end = _end_here;
                    } else if (_cand_len == _best_len) {
                        if (_rule.priority < _rules[_best_rule].priority) {
                            _best_rule = _ri;
                            _best_end = _end_here;
                        }
                    }
                }
            }

            _ri += 1;
        }

        if (_best_rule < 0) {
            _pos += 1;
            continue;
        }

        var _picked = _rules[_best_rule];
        var _scope = _picked.scope;

        // Post-classify identifiers
        if (_scope == "identifier") {
            var _word = regex__buffer_read_text_range(_text_buff, _pos, _best_end);

            if (variable_struct_exists(_lookup.keyword, _word)) {
				_scope = "keyword";
			}
            else if (variable_struct_exists(_lookup.literal, _word)) {
				_scope = "literal";
			}
            else if (variable_struct_exists(_lookup.builtin, _word)) {
				_scope = "builtin";
			}
            else if (variable_struct_exists(_lookup.langvar, _word)) {
				_scope = "variable.language";
			}
            else {
				_scope = "identifier";
			}
        }

        array_push(_spans, { start: _pos, "end": _best_end, scope: _scope });
        _pos = _best_end;
    }

    buffer_resize(_text_buff, 0);
	
	_spans = regex_hljs_gml__postprocess_structured_spans(_spans, _text_buff, _len);
	
    return _spans;
}
