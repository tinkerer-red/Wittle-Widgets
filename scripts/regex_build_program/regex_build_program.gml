#region jsDoc
/// @func   regex_build_program()
/// @desc   Compile a regex pattern string (written as a GML raw string literal using @"" or @'')
///         into a compact Thompson NFA "program" representation that is efficient to execute
///         with a VM-style runner (two-state-lists simulation).
///
///         Supported (matches highlight.js gml.js needs):
///         - Literals (including escaped metacharacters)
///         - Dot '.'
///         - Character classes: [...], ranges, negation [^...]
///         - Grouping: (...), alternation: |
///         - Quantifiers: *, +, ?, {m}, {m,}, {m,n} and lazy forms *?, +?, ??, {m,n}?
///         - Anchors: ^, $
///         - Boundaries: \b, \B
///         - Shorthand classes: \s, \S
///         - Escape literals: \n, \r, \t, \\
///
///         Notes:
///         - The pattern string is read "as-is". In GML raw string literals, \n is two chars
///           '\' and 'n'. This builder interprets escapes itself.
///         - This builder compiles over bytes from buffer_text. Your runner must execute over
///           the same byte stream.
///
/// @param  {String} _pattern
/// @returns {Struct} program bundle:
///          {
///            op:    Array,  // opcode per state
///            a:     Array,  // edge A
///            b:     Array,  // edge B (or -1)
///            data:  Array,  // char byte, class id, or unused
///            cls:   Array,  // per class: packed pairs [s0,e0,s1,e1,...]
///            neg:   Array,  // per class: 0 or 1
///            start: Real    // start state index
///          }
#endregion
function regex_build_program(_pattern) {
    // Static buffers for turning strings into bytes quickly
    static _temp_buff = buffer_create(0, buffer_grow, 1);

    // Opcodes (numeric)
    static OP_MATCH = 0;
    static OP_CHAR  = 1;
    static OP_CLASS = 2;
    static OP_ANY   = 3;
    static OP_JUMP  = 4;
    static OP_SPLIT = 5;
    static OP_BOL   = 6;
    static OP_EOL   = 7;
    static OP_WB    = 8;
    static OP_NWB   = 9;

    // Token kinds (numeric)
    static TK_ATOM   = 1;
    static TK_LPAREN = 2;
    static TK_RPAREN = 3;
    static TK_ALT    = 4; // |
    static TK_CONCAT = 5; // explicit concat
    static TK_STAR   = 6; // *
    static TK_PLUS   = 7; // +
    static TK_QMARK  = 8; // ?
    static TK_REP    = 9; // {m,n}

    // Atom subtypes stored in token_type
    static AT_CHAR   = 1;
    static AT_CLASS  = 2;
    static AT_ANY    = 3;
    static AT_BOL    = 4;
    static AT_EOL    = 5;
    static AT_WB     = 6;
    static AT_NWB    = 7;

    // Build context (so helpers can be plain functions - no closures)
    var _ctx = {
        // constants
        OP_MATCH: OP_MATCH, OP_CHAR: OP_CHAR, OP_CLASS: OP_CLASS, OP_ANY: OP_ANY, OP_JUMP: OP_JUMP, OP_SPLIT: OP_SPLIT,
        OP_BOL: OP_BOL, OP_EOL: OP_EOL, OP_WB: OP_WB, OP_NWB: OP_NWB,
        TK_ATOM: TK_ATOM, TK_LPAREN: TK_LPAREN, TK_RPAREN: TK_RPAREN, TK_ALT: TK_ALT, TK_CONCAT: TK_CONCAT,
        TK_STAR: TK_STAR, TK_PLUS: TK_PLUS, TK_QMARK: TK_QMARK, TK_REP: TK_REP,
        AT_CHAR: AT_CHAR, AT_CLASS: AT_CLASS, AT_ANY: AT_ANY, AT_BOL: AT_BOL, AT_EOL: AT_EOL, AT_WB: AT_WB, AT_NWB: AT_NWB,

        // lexer output
        tok_kinds: [], tok_types: [], tok_datas: [], tok_mins: [], tok_maxs: [], tok_lazys: [],
        cls_pairs: [], cls_neg: [],

        // postfix output
        out_kinds: [], out_types: [], out_datas: [], out_mins: [], out_maxs: [], out_lazys: [],

        // program output
        prog_op: [], prog_a: [], prog_b: [], prog_data: [],

        // fragment stacks
        frag_start: [], frag_outs: [], frag_ckind: [], frag_cdata: [],

        // pattern buffer state
        pat_buff: -1, pat_len: 0, pat_pos: 0
    };

    // Write pattern into temp buffer, then scan bytes
    buffer_write(_temp_buff, buffer_text, _pattern);
    _ctx.pat_len = buffer_tell(_temp_buff);
    buffer_seek(_temp_buff, buffer_seek_start, 0);
    _ctx.pat_buff = _temp_buff;
    _ctx.pat_pos = 0;

    // ------------------------------------------------------------
    // Step 1: Lex pattern to token stream with explicit CONCAT insertion
    // ------------------------------------------------------------
    var _need_concat = false;

    while (_ctx.pat_pos < _ctx.pat_len) {
        var _chr = regex__pat_read(_ctx);

        // Metacharacters
        if (_chr == ord("(")) {
            if (_need_concat) regex__tok_push(_ctx, TK_CONCAT, 0, 0, 0, 0, 0);
            regex__tok_push(_ctx, TK_LPAREN, 0, 0, 0, 0, 0);
            _need_concat = false;
            continue;
        }
        if (_chr == ord(")")) {
            regex__tok_push(_ctx, TK_RPAREN, 0, 0, 0, 0, 0);
            _need_concat = true;
            continue;
        }
        if (_chr == ord("|")) {
            regex__tok_push(_ctx, TK_ALT, 0, 0, 0, 0, 0);
            _need_concat = false;
            continue;
        }

        // Anchors
        if (_chr == ord("^")) {
            if (_need_concat) regex__tok_push(_ctx, TK_CONCAT, 0, 0, 0, 0, 0);
            regex__tok_push(_ctx, TK_ATOM, AT_BOL, 0, 0, 0, 0);
            _need_concat = true;
            continue;
        }
        if (_chr == ord("$")) {
            if (_need_concat) regex__tok_push(_ctx, TK_CONCAT, 0, 0, 0, 0, 0);
            regex__tok_push(_ctx, TK_ATOM, AT_EOL, 0, 0, 0, 0);
            _need_concat = true;
            continue;
        }

        // Dot
        if (_chr == ord(".")) {
            if (_need_concat) regex__tok_push(_ctx, TK_CONCAT, 0, 0, 0, 0, 0);
            regex__tok_push(_ctx, TK_ATOM, AT_ANY, 0, 0, 0, 0);
            _need_concat = true;
            continue;
        }

        // Quantifiers (* + ? and lazy variants)
        if (_chr == ord("*") || _chr == ord("+") || _chr == ord("?")) {
            var _lazy = 0;
            if (regex__pat_peek(_ctx) == ord("?")) { regex__pat_read(_ctx); _lazy = 1; }

            if (_chr == ord("*")) regex__tok_push(_ctx, TK_STAR, 0, 0, 0, 0, _lazy);
            else if (_chr == ord("+")) regex__tok_push(_ctx, TK_PLUS, 0, 0, 0, 0, _lazy);
            else regex__tok_push(_ctx, TK_QMARK, 0, 0, 0, 0, _lazy);

            _need_concat = true;
            continue;
        }

        // {m,n} quantifier (supports {m}, {m,}, {m,n} with optional lazy '?')
        if (_chr == ord("{")) {
            var _minn = regex__parse_int(_ctx);
            if (_minn < 0) {
                if (_need_concat) regex__tok_push(_ctx, TK_CONCAT, 0, 0, 0, 0, 0);
                regex__tok_push(_ctx, TK_ATOM, AT_CHAR, ord("{"), 0, 0, 0);
                _need_concat = true;
                continue;
            }

            var _maxx = _minn;

            if (regex__pat_peek(_ctx) == ord(",")) {
                regex__pat_read(_ctx);
                var _read_max = regex__parse_int(_ctx);
                if (_read_max < 0) _maxx = -1;
                else _maxx = _read_max;
            }

            if (regex__pat_peek(_ctx) == ord("}")) {
                regex__pat_read(_ctx);
            } else {
                if (_need_concat) regex__tok_push(_ctx, TK_CONCAT, 0, 0, 0, 0, 0);
                regex__tok_push(_ctx, TK_ATOM, AT_CHAR, ord("{"), 0, 0, 0);
                _need_concat = true;
                continue;
            }

            var _lazy2 = 0;
            if (regex__pat_peek(_ctx) == ord("?")) { regex__pat_read(_ctx); _lazy2 = 1; }

            regex__tok_push(_ctx, TK_REP, 0, 0, _minn, _maxx, _lazy2);
            _need_concat = true;
            continue;
        }

        // Character class [...]
        if (_chr == ord("[")) {
            if (_need_concat) regex__tok_push(_ctx, TK_CONCAT, 0, 0, 0, 0, 0);

            var _negate = false;
            if (regex__pat_peek(_ctx) == ord("^")) { regex__pat_read(_ctx); _negate = true; }

            var _pairs = [];
            var _have_first = false;
            var _first_byte = 0;

            while (_ctx.pat_pos < _ctx.pat_len) {
                var _cc = regex__pat_read(_ctx);
                if (_cc == ord("]")) break;

                if (_cc == ord("\\")) {
                    if (!_have_first) {
                        _pairs = regex__lex_escape_class(_ctx, _pairs);
                        _have_first = false;
                        continue;
                    } else {
                        // consume escape as a single byte for range logic
                        var _temp_pairs = [];
                        _temp_pairs = regex__lex_escape_class(_ctx, _temp_pairs);
                        var _last_idx = array_length(_temp_pairs) - 2;
                        var _single = _temp_pairs[_last_idx];

                        if (regex__pat_peek(_ctx) == ord("-")) {
                            regex__pat_read(_ctx);
                            var _endd = regex__pat_read(_ctx);
                            if (_endd == ord("\\")) {
                                var _temp2 = [];
                                _temp2 = regex__lex_escape_class(_ctx, _temp2);
                                var _last2 = array_length(_temp2) - 2;
                                _endd = _temp2[_last2];
                            }
                            _pairs = regex__pairs_add(_pairs, _first_byte, _endd);
                            _have_first = false;
                        } else {
                            _pairs = regex__pairs_add(_pairs, _first_byte, _first_byte);
                            _first_byte = _single;
                            _have_first = true;
                        }
                        continue;
                    }
                }

                if (_have_first) {
                    if (_cc == ord("-") && regex__pat_peek(_ctx) != ord("]")) {
                        var _endd2 = regex__pat_read(_ctx);
                        if (_endd2 == ord("\\")) {
                            var _temp3 = [];
                            _temp3 = regex__lex_escape_class(_ctx, _temp3);
                            var _last3 = array_length(_temp3) - 2;
                            _endd2 = _temp3[_last3];
                        }
                        _pairs = regex__pairs_add(_pairs, _first_byte, _endd2);
                        _have_first = false;
                        continue;
                    } else {
                        _pairs = regex__pairs_add(_pairs, _first_byte, _first_byte);
                        _first_byte = _cc;
                        _have_first = true;
                        continue;
                    }
                } else {
                    _first_byte = _cc;
                    _have_first = true;
                    continue;
                }
            }

            if (_have_first) {
                _pairs = regex__pairs_add(_pairs, _first_byte, _first_byte);
            }

            var _cid = regex__class_new(_ctx, _pairs, _negate);
            regex__tok_push(_ctx, TK_ATOM, AT_CLASS, _cid, 0, 0, 0);
            _need_concat = true;
            continue;
        }

        // Escape outside class
        if (_chr == ord("\\")) {
            if (_need_concat) regex__tok_push(_ctx, TK_CONCAT, 0, 0, 0, 0, 0);
            if (!regex__lex_escape_atom(_ctx)) break;
            _need_concat = true;
            continue;
        }

        // Default literal char
        if (_need_concat) regex__tok_push(_ctx, TK_CONCAT, 0, 0, 0, 0, 0);
        regex__tok_push(_ctx, TK_ATOM, AT_CHAR, _chr, 0, 0, 0);
        _need_concat = true;
    }

    buffer_resize(_temp_buff, 0);

    // ------------------------------------------------------------
    // Step 2: Convert tokens to postfix via shunting-yard
    // ------------------------------------------------------------
    var _op_stack = [];
    var _op_top = 0;

    var _count = array_length(_ctx.tok_kinds);
    var _index = 0;
    repeat (_count) {
        var _kind = _ctx.tok_kinds[_index];
        var _type = _ctx.tok_types[_index];
        var _data = _ctx.tok_datas[_index];
        var _minn = _ctx.tok_mins[_index];
        var _maxx = _ctx.tok_maxs[_index];
        var _lazy = _ctx.tok_lazys[_index];
        _index += 1;

        if (_kind == TK_ATOM || _kind == TK_STAR || _kind == TK_PLUS || _kind == TK_QMARK || _kind == TK_REP) {
            regex__out_push(_ctx, _kind, _type, _data, _minn, _maxx, _lazy);
            continue;
        }

        if (_kind == TK_LPAREN) {
            array_push(_op_stack, _kind);
            _op_top += 1;
            continue;
        }

        if (_kind == TK_RPAREN) {
            while (_op_top > 0) {
                var _top_kind = _op_stack[_op_top - 1];
                _op_top -= 1;
                array_pop(_op_stack);
                if (_top_kind == TK_LPAREN) break;
                regex__out_push(_ctx, _top_kind, 0, 0, 0, 0, 0);
            }
            continue;
        }

        while (_op_top > 0) {
            var _peek_kind = _op_stack[_op_top - 1];
            if (_peek_kind == TK_LPAREN) break;
            if (regex__prec(_peek_kind) < regex__prec(_kind)) break;
            _op_top -= 1;
            array_pop(_op_stack);
            regex__out_push(_ctx, _peek_kind, 0, 0, 0, 0, 0);
        }

        array_push(_op_stack, _kind);
        _op_top += 1;
    }

    while (_op_top > 0) {
        var _top_kind2 = _op_stack[_op_top - 1];
        _op_top -= 1;
        array_pop(_op_stack);
        regex__out_push(_ctx, _top_kind2, 0, 0, 0, 0, 0);
    }

    // ------------------------------------------------------------
    // Step 3: Thompson compile postfix into NFA program arrays
    // ------------------------------------------------------------
    var _post_len = array_length(_ctx.out_kinds);
    var _pi = 0;

    repeat (_post_len) {
        var _kind2 = _ctx.out_kinds[_pi];
        var _type2 = _ctx.out_types[_pi];
        var _data2 = _ctx.out_datas[_pi];
        var _minn2 = _ctx.out_mins[_pi];
        var _maxx2 = _ctx.out_maxs[_pi];
        var _lazy2 = _ctx.out_lazys[_pi];
        _pi += 1;

        if (_kind2 == TK_ATOM) {
            var _frag_atom = regex__frag_compile_atom(_ctx, _type2, _data2);
            regex__frag_push(_ctx, _frag_atom.start, _frag_atom.outs, _frag_atom.ckind, _frag_atom.cdata);
            continue;
        }

        if (_kind2 == TK_CONCAT) {
            var _rght = regex__frag_pop(_ctx);
            var _left = regex__frag_pop(_ctx);
            regex__outs_patch(_ctx, _left.outs, _rght.start);
            regex__frag_push(_ctx, _left.start, _rght.outs, 0, 0);
            continue;
        }

        if (_kind2 == TK_ALT) {
            var _rght2 = regex__frag_pop(_ctx);
            var _left2 = regex__frag_pop(_ctx);
            var _split = regex__emit(_ctx, OP_SPLIT, _left2.start, _rght2.start, 0);
            var _outs2 = regex__outs_merge(_left2.outs, _rght2.outs);
            regex__frag_push(_ctx, _split, _outs2, 0, 0);
            continue;
        }

        if (_kind2 == TK_STAR) {
            var _subb = regex__frag_pop(_ctx);

            var _split2;
            var _exit_patch;
            if (_lazy2 == 0) {
                _split2 = regex__emit(_ctx, OP_SPLIT, _subb.start, -1, 0);
                _exit_patch = regex__out_b(_split2);
            } else {
                _split2 = regex__emit(_ctx, OP_SPLIT, -1, _subb.start, 0);
                _exit_patch = regex__out_a(_split2);
            }
            regex__outs_patch(_ctx, _subb.outs, _split2);
            regex__frag_push(_ctx, _split2, [ _exit_patch ], 0, 0);
            continue;
        }

        if (_kind2 == TK_PLUS) {
            var _subb2 = regex__frag_pop(_ctx);

            var _split3;
            var _exit_patch2;
            if (_lazy2 == 0) {
                _split3 = regex__emit(_ctx, OP_SPLIT, _subb2.start, -1, 0);
                _exit_patch2 = regex__out_b(_split3);
            } else {
                _split3 = regex__emit(_ctx, OP_SPLIT, -1, _subb2.start, 0);
                _exit_patch2 = regex__out_a(_split3);
            }
            regex__outs_patch(_ctx, _subb2.outs, _split3);
            regex__frag_push(_ctx, _subb2.start, [ _exit_patch2 ], 0, 0);
            continue;
        }

        if (_kind2 == TK_QMARK) {
            var _subb3 = regex__frag_pop(_ctx);

            var _split4;
            var _exit_patch3;
            if (_lazy2 == 0) {
                _split4 = regex__emit(_ctx, OP_SPLIT, _subb3.start, -1, 0);
                _exit_patch3 = regex__out_b(_split4);
            } else {
                _split4 = regex__emit(_ctx, OP_SPLIT, -1, _subb3.start, 0);
                _exit_patch3 = regex__out_a(_split4);
            }
            var _outs3 = regex__outs_merge(_subb3.outs, [ _exit_patch3 ]);
            regex__frag_push(_ctx, _split4, _outs3, 0, 0);
            continue;
        }

        if (_kind2 == TK_REP) {
            var _subb4 = regex__frag_pop(_ctx);

            var _built = undefined;

            if (_minn2 <= 0) {
                var _jmp = regex__emit(_ctx, OP_JUMP, -1, -1, 0);
                _built = { start: _jmp, outs: [ regex__out_a(_jmp) ], ckind: 0, cdata: 0 };
            }

            var _ii = 0;
            repeat (_minn2) {
                var _copy = (regex__frag_is_clonable(_subb4) ? regex__frag_clone_atom(_ctx, _subb4) : _subb4);

                if (_built == undefined) {
                    _built = _copy;
                } else {
                    regex__outs_patch(_ctx, _built.outs, _copy.start);
                    _built = { start: _built.start, outs: _copy.outs, ckind: 0, cdata: 0 };
                }

                _ii += 1;
            }

            if (_maxx2 < 0) {
                var _unit = (regex__frag_is_clonable(_subb4) ? regex__frag_clone_atom(_ctx, _subb4) : _subb4);

                var _split5;
                var _exit_patch4;
                if (_lazy2 == 0) {
                    _split5 = regex__emit(_ctx, OP_SPLIT, _unit.start, -1, 0);
                    _exit_patch4 = regex__out_b(_split5);
                } else {
                    _split5 = regex__emit(_ctx, OP_SPLIT, -1, _unit.start, 0);
                    _exit_patch4 = regex__out_a(_split5);
                }
                regex__outs_patch(_ctx, _unit.outs, _split5);
                var _star_frag = { start: _split5, outs: [ _exit_patch4 ], ckind: 0, cdata: 0 };

                if (_built == undefined) _built = _star_frag;
                else {
                    regex__outs_patch(_ctx, _built.outs, _star_frag.start);
                    _built = { start: _built.start, outs: _star_frag.outs, ckind: 0, cdata: 0 };
                }
            } else {
                var _remain = _maxx2 - _minn2;
                if (_remain > 0) {
                    var _jj = 0;
                    repeat (_remain) {
                        var _unit2 = (regex__frag_is_clonable(_subb4) ? regex__frag_clone_atom(_ctx, _subb4) : _subb4);

                        var _split6;
                        var _exit_patch5;
                        if (_lazy2 == 0) {
                            _split6 = regex__emit(_ctx, OP_SPLIT, _unit2.start, -1, 0);
                            _exit_patch5 = regex__out_b(_split6);
                        } else {
                            _split6 = regex__emit(_ctx, OP_SPLIT, -1, _unit2.start, 0);
                            _exit_patch5 = regex__out_a(_split6);
                        }

                        var _outs_opt = regex__outs_merge(_unit2.outs, [ _exit_patch5 ]);
                        var _opt_frag = { start: _split6, outs: _outs_opt, ckind: 0, cdata: 0 };

                        if (_built == undefined) _built = _opt_frag;
                        else {
                            regex__outs_patch(_ctx, _built.outs, _opt_frag.start);
                            _built = { start: _built.start, outs: _opt_frag.outs, ckind: 0, cdata: 0 };
                        }

                        _jj += 1;
                    }
                }
            }

            if (_built == undefined) {
                var _jmp2 = regex__emit(_ctx, OP_JUMP, -1, -1, 0);
                _built = { start: _jmp2, outs: [ regex__out_a(_jmp2) ], ckind: 0, cdata: 0 };
            }

            regex__frag_push(_ctx, _built.start, _built.outs, 0, 0);
            continue;
        }
    }

    var _final = regex__frag_pop(_ctx);
    var _match = regex__emit(_ctx, OP_MATCH, -1, -1, 0);
    regex__outs_patch(_ctx, _final.outs, _match);

    return {
        op: _ctx.prog_op,
        a: _ctx.prog_a,
        b: _ctx.prog_b,
        data: _ctx.prog_data,
        cls: _ctx.cls_pairs,
        neg: _ctx.cls_neg,
        start: _final.start
    };
}
