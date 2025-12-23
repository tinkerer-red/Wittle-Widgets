/// @func regex_hljs__scan()
/// @desc Scan buffer and return token spans for highlighting.
/// @param {Real} _buff
/// @param {Real} _len
/// @param {Array} _rules
/// @param {Struct} _dict  lookup maps: keyword/literal/builtin/langvar
/// @returns {Array} spans
function regex_hljs__scan(_buff, _len, _rules, _dict) {
    var _spans = [];
    var _pos = 0;

    while (_pos < _len) {
        var _best_rule = -1;
        var _best_start = 2147483647;
        var _best_end = -1;

        var _rule_count = array_length(_rules);
        var _ri = 0;
        repeat (_rule_count) {
            var _rule = _rules[_ri];

            var _result = regex_search(_rule.program, _buff, _len, _pos);
            if (_result.found) {
                var _start = _result.start;
                var _end_pos = _result.end;

                if (_start < _best_start) {
                    _best_rule = _ri;
                    _best_start = _start;
                    _best_end = _end_pos;
                } else if (_start == _best_start) {
                    var _best_len = _best_end - _best_start;
                    var _cand_len = _end_pos - _start;

                    if (_cand_len > _best_len) {
                        _best_rule = _ri;
                        _best_end = _end_pos;
                    } else if (_cand_len == _best_len) {
                        if (_rule.priority < _rules[_best_rule].priority) {
                            _best_rule = _ri;
                            _best_end = _end_pos;
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

        // Emit gap as "plain" if you want (optional). For now, skip gaps.
        if (_best_start > _pos) {
            _pos = _best_start;
        }

        var _picked = _rules[_best_rule];
        var _scope = _picked.scope;

        // Post-classify identifiers into keyword/literal/builtin/langvar
        if (_scope == "identifier") {
            var _text = buffer_read_string(_buff, _best_start, _best_end - _best_start);

            if (variable_struct_exists(_dict.keyword, _text)) _scope = "keyword";
            else if (variable_struct_exists(_dict.literal, _text)) _scope = "literal";
            else if (variable_struct_exists(_dict.builtin, _text)) _scope = "title.function";
            else if (variable_struct_exists(_dict.langvar, _text)) _scope = "variable.language";
            else _scope = "identifier";
        }

        array_push(_spans, {
            start: _best_start,
            "end": _best_end,
            scope: _scope
        });

        _pos = _best_end;
    }

    return _spans;
}
