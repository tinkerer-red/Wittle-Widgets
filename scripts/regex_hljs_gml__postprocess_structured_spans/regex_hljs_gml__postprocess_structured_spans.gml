/// @func regex_hljs_gml__postprocess_structured_spans
/// @desc Add refined spans for function/enum/struct-member names and related hljs scopes.
/// @param {Array<Struct>} _spans
/// @param {Real} _buff
/// @param {Real} _len
/// @returns {Array<Struct>} new spans appended (caller may sort/merge later)
function regex_hljs_gml__postprocess_structured_spans(_spans, _buff, _len) {
    var _extra = [];

    // Build exclusion ranges for strings/comments so enum-body scans don't misfire.
    var _exclude = [];
    var _span_count_a = array_length(_spans);
    var _span_index_a = 0;
    repeat (_span_count_a) {
        var _span_a = _spans[_span_index_a];
        _span_index_a += 1;

        var _scope_a = _span_a.scope;

        if (_scope_a == "comment" || _scope_a == "string") {
            array_push(_exclude, { start: _span_a.start, "end": _span_a.end });
        }
    }

    var _exclude_count = array_length(_exclude);

    function regex_hljs_gml__pos_is_excluded(_pos) {
        var _idx = 0;
        repeat (_exclude_count) {
            var _range = _exclude[_idx];
            if (_pos >= _range.start && _pos < _range.end) return true;
            _idx += 1;
        }
        return false;
    }

    function regex_hljs_gml__skip_excluded_forward(_pos) {
        var _best_end = -1;

        var _idx2 = 0;
        repeat (_exclude_count) {
            var _range2 = _exclude[_idx2];
            if (_pos >= _range2.start && _pos < _range2.end) {
                if (_range2.end > _best_end) _best_end = _range2.end;
            }
            _idx2 += 1;
        }

        if (_best_end >= 0) return _best_end;
        return _pos;
    }

    function regex_hljs_gml__is_ident_start(_byte) {
        return ((_byte >= 65 && _byte <= 90) || (_byte >= 97 && _byte <= 122) || (_byte == 95));
    }

    function regex_hljs_gml__is_ident_char(_byte) {
        if (regex_hljs_gml__is_ident_start(_byte)) return true;
        return (_byte >= 48 && _byte <= 57);
    }

    // First pass: split “whole spans” into sub-spans
    var _span_count = array_length(_spans);
    var _span_index = 0;
    repeat (_span_count) {
        var _span = _spans[_span_index];
        _span_index += 1;

        var _scope = _span.scope;

        if (_scope == "meta.function.decl") {
            // "function" WS <ident> ...
            var _pos = _span.start + 8;

            while (_pos < _span.end) {
                var _byte = buffer_peek(_buff, _pos, buffer_u8);
                if (_byte != 32 && _byte != 9 && _byte != 10 && _byte != 13) break;
                _pos += 1;
            }

            var _name_start = _pos;

            while (_pos < _span.end) {
                var _byte2 = buffer_peek(_buff, _pos, buffer_u8);
                if (!regex_hljs_gml__is_ident_char(_byte2)) break;
                _pos += 1;
            }

            var _name_end = _pos;

            if (_name_end > _name_start) {
                array_push(_extra, { start: _name_start, "end": _name_end, scope: "title.function" });
            }

            continue;
        }

        if (_scope == "meta.enum.decl") {
            // "enum" WS <ident> ...
            var _pos3 = _span.start + 4;

            while (_pos3 < _span.end) {
                var _byte3 = buffer_peek(_buff, _pos3, buffer_u8);
                if (_byte3 != 32 && _byte3 != 9 && _byte3 != 10 && _byte3 != 13) break;
                _pos3 += 1;
            }

            var _name_start2 = _pos3;

            while (_pos3 < _span.end) {
                var _byte4 = buffer_peek(_buff, _pos3, buffer_u8);
                if (!regex_hljs_gml__is_ident_char(_byte4)) break;
                _pos3 += 1;
            }

            var _name_end2 = _pos3;

            if (_name_end2 > _name_start2) {
                array_push(_extra, { start: _name_start2, "end": _name_end2, scope: "variable.constant" });
            }

            continue;
        }

        if (_scope == "meta.struct.member") {
            // Span begins at ident: <ident> :
            var _pos5 = _span.start;

            while (_pos5 < _span.end) {
                var _byte5 = buffer_peek(_buff, _pos5, buffer_u8);
                if (!regex_hljs_gml__is_ident_char(_byte5)) break;
                _pos5 += 1;
            }

            if (_pos5 > _span.start) {
                array_push(_extra, { start: _span.start, "end": _pos5, scope: "variable" });
            }

            continue;
        }

        if (_scope == "meta.prop.invoke") {
            // ".  <ident>   ("
            var _pos6 = _span.start;

            // find first ident after dot
            while (_pos6 < _span.end) {
                var _byte6 = buffer_peek(_buff, _pos6, buffer_u8);
                if (regex_hljs_gml__is_ident_start(_byte6)) break;
                _pos6 += 1;
            }

            var _name_start3 = _pos6;

            while (_pos6 < _span.end) {
                var _byte7 = buffer_peek(_buff, _pos6, buffer_u8);
                if (!regex_hljs_gml__is_ident_char(_byte7)) break;
                _pos6 += 1;
            }

            var _name_end3 = _pos6;

            if (_name_end3 > _name_start3) {
                array_push(_extra, { start: _name_start3, "end": _name_end3, scope: "title.function.invoke" });
            }

            continue;
        }

        if (_scope == "meta.prop.access") {
            // ". <ident>"
            var _pos7 = _span.start;

            while (_pos7 < _span.end) {
                var _byte8 = buffer_peek(_buff, _pos7, buffer_u8);
                if (regex_hljs_gml__is_ident_start(_byte8)) break;
                _pos7 += 1;
            }

            var _name_start4 = _pos7;

            while (_pos7 < _span.end) {
                var _byte9 = buffer_peek(_buff, _pos7, buffer_u8);
                if (!regex_hljs_gml__is_ident_char(_byte9)) break;
                _pos7 += 1;
            }

            var _name_end4 = _pos7;

            if (_name_end4 > _name_start4) {
                array_push(_extra, { start: _name_start4, "end": _name_end4, scope: "property" });
            }

            continue;
        }

        if (_scope == "meta.func.call") {
            // "<ident>("
            var _pos8 = _span.start;

            while (_pos8 < _span.end) {
                var _byte10 = buffer_peek(_buff, _pos8, buffer_u8);
                if (regex_hljs_gml__is_ident_start(_byte10)) break;
                _pos8 += 1;
            }

            var _name_start5 = _pos8;

            while (_pos8 < _span.end) {
                var _byte11 = buffer_peek(_buff, _pos8, buffer_u8);
                if (!regex_hljs_gml__is_ident_char(_byte11)) break;
                _pos8 += 1;
            }

            var _name_end5 = _pos8;

            if (_name_end5 > _name_start5) {
                array_push(_extra, { start: _name_start5, "end": _name_end5, scope: "title.function.invoke" });
            }

            continue;
        }

        if (_scope == "meta.macro") {
            // "#macro" WS <ident> ...
            var _pos9 = _span.start;

            // find first identifier on the line after "#macro"
            while (_pos9 < _span.end) {
                var _byte12 = buffer_peek(_buff, _pos9, buffer_u8);
                if (regex_hljs_gml__is_ident_start(_byte12)) break;
                _pos9 += 1;
            }

            var _name_start6 = _pos9;

            while (_pos9 < _span.end) {
                var _byte13 = buffer_peek(_buff, _pos9, buffer_u8);
                if (!regex_hljs_gml__is_ident_char(_byte13)) break;
                _pos9 += 1;
            }

            var _name_end6 = _pos9;

            if (_name_end6 > _name_start6) {
                array_push(_extra, { start: _name_start6, "end": _name_end6, scope: "variable.constant" });
            }

            continue;
        }

        if (_scope == "meta.macro.pair") {
            // "#macro" WS <ident> WS ":" WS <ident> ...
            var _pos10 = _span.start;

            // first name
            while (_pos10 < _span.end) {
                var _byte14 = buffer_peek(_buff, _pos10, buffer_u8);
                if (regex_hljs_gml__is_ident_start(_byte14)) break;
                _pos10 += 1;
            }

            var _name_start7 = _pos10;

            while (_pos10 < _span.end) {
                var _byte15 = buffer_peek(_buff, _pos10, buffer_u8);
                if (!regex_hljs_gml__is_ident_char(_byte15)) break;
                _pos10 += 1;
            }

            var _name_end7 = _pos10;

            if (_name_end7 > _name_start7) {
                array_push(_extra, { start: _name_start7, "end": _name_end7, scope: "variable.constant" });
            }

            // find colon
            while (_pos10 < _span.end) {
                var _byte16 = buffer_peek(_buff, _pos10, buffer_u8);
                if (_byte16 == 58) break;
                _pos10 += 1;
            }

            // second name
            while (_pos10 < _span.end) {
                var _byte17 = buffer_peek(_buff, _pos10, buffer_u8);
                if (regex_hljs_gml__is_ident_start(_byte17)) break;
                _pos10 += 1;
            }

            var _name_start8 = _pos10;

            while (_pos10 < _span.end) {
                var _byte18 = buffer_peek(_buff, _pos10, buffer_u8);
                if (!regex_hljs_gml__is_ident_char(_byte18)) break;
                _pos10 += 1;
            }

            var _name_end8 = _pos10;

            if (_name_end8 > _name_start8) {
                array_push(_extra, { start: _name_start8, "end": _name_end8, scope: "variable.constant" });
            }

            continue;
        }
    }

    // Second pass: approximate hljs ENUM_DEFINITION "contains" by scanning enum body braces
    // and tagging identifiers inside as variable.constant (excluding comment/string ranges).
    var _span_count2 = array_length(_spans);
    var _span_index2 = 0;
    repeat (_span_count2) {
        var _span2 = _spans[_span_index2];
        _span_index2 += 1;

        if (_span2.scope != "meta.enum.decl") continue;

        // Find the '{' inside this span
        var _open_pos = _span2.start;
        var _found_open = false;

        while (_open_pos < _span2.end) {
            var _byte19 = buffer_peek(_buff, _open_pos, buffer_u8);
            if (_byte19 == 123) { _found_open = true; break; } // '{'
            _open_pos += 1;
        }

        if (!_found_open) continue;

        var _scan_pos = _open_pos + 1;
        var _brace_depth = 1;

        while (_scan_pos < _len) {
            if (regex_hljs_gml__pos_is_excluded(_scan_pos)) {
                _scan_pos = regex_hljs_gml__skip_excluded_forward(_scan_pos);
                continue;
            }

            var _byte20 = buffer_peek(_buff, _scan_pos, buffer_u8);

            if (_byte20 == 123) { // '{'
                _brace_depth += 1;
                _scan_pos += 1;
                continue;
            }

            if (_byte20 == 125) { // '}'
                _brace_depth -= 1;
                _scan_pos += 1;

                if (_brace_depth <= 0) break;
                continue;
            }

            // identifier
            if (regex_hljs_gml__is_ident_start(_byte20)) {
                var _name_start9 = _scan_pos;
                var _name_end9 = _scan_pos + 1;

                while (_name_end9 < _len) {
                    var _byte21 = buffer_peek(_buff, _name_end9, buffer_u8);
                    if (!regex_hljs_gml__is_ident_char(_byte21)) break;
                    _name_end9 += 1;
                }

                array_push(_extra, { start: _name_start9, "end": _name_end9, scope: "variable.constant" });

                _scan_pos = _name_end9;
                continue;
            }

            _scan_pos += 1;
        }
    }

    // Append extras
    var _extra_count = array_length(_extra);
    var _extra_index = 0;
    repeat (_extra_count) {
        array_push(_spans, _extra[_extra_index]);
        _extra_index += 1;
    }

    return _spans;
}
