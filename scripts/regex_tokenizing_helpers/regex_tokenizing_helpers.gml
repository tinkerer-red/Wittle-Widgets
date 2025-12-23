function regex__tok_push(_ctx, _tok_kind, _tok_type, _tok_data, _tok_min, _tok_max, _tok_lazy) {
    array_push(_ctx.tok_kinds, _tok_kind);
    array_push(_ctx.tok_types, _tok_type);
    array_push(_ctx.tok_datas, _tok_data);
    array_push(_ctx.tok_mins,  _tok_min);
    array_push(_ctx.tok_maxs,  _tok_max);
    array_push(_ctx.tok_lazys, _tok_lazy);
}

function regex__out_push(_ctx, _kind, _type, _data, _minn, _maxx, _lazy) {
    array_push(_ctx.out_kinds, _kind);
    array_push(_ctx.out_types, _type);
    array_push(_ctx.out_datas, _data);
    array_push(_ctx.out_mins,  _minn);
    array_push(_ctx.out_maxs,  _maxx);
    array_push(_ctx.out_lazys, _lazy);
}

function regex__prec(_kind) {
    // CONCAT > ALT
    if (_kind == 5) return 2; // TK_CONCAT
    if (_kind == 4) return 1; // TK_ALT
    return 0;
}

function regex__pat_peek(_ctx) {
    if (_ctx.pat_pos >= _ctx.pat_len) return -1;
    return buffer_peek(_ctx.pat_buff, _ctx.pat_pos, buffer_u8);
}

function regex__pat_read(_ctx) {
    if (_ctx.pat_pos >= _ctx.pat_len) return -1;
    var _byte = buffer_read(_ctx.pat_buff, buffer_u8);
    _ctx.pat_pos += 1;
    return _byte;
}

function regex__parse_int(_ctx) {
    var _value = 0;
    var _seen = false;

    while (true) {
        var _peek = regex__pat_peek(_ctx);
        if (_peek < 48 || _peek > 57) break;
        _seen = true;
        regex__pat_read(_ctx);
        _value = _value * 10 + (_peek - 48);
    }

    if (!_seen) return -1;
    return _value;
}

function regex__class_new(_ctx, _pairs_arr, _negate) {
    var _class_id = array_length(_ctx.cls_pairs);
    array_push(_ctx.cls_pairs, _pairs_arr);
    array_push(_ctx.cls_neg, (_negate ? 1 : 0));
    return _class_id;
}

function regex__pairs_add(_pairs_arr, _start, _endd) {
    array_push(_pairs_arr, _start);
    array_push(_pairs_arr, _endd);
    return _pairs_arr;
}

function regex__lex_escape_atom(_ctx) {
    var _esc = regex__pat_read(_ctx);
    if (_esc < 0) return false;

    // Common escapes
    if (_esc == ord("n")) { regex__tok_push(_ctx, _ctx.TK_ATOM, _ctx.AT_CHAR, 10, 0, 0, 0); return true; }
    if (_esc == ord("r")) { regex__tok_push(_ctx, _ctx.TK_ATOM, _ctx.AT_CHAR, 13, 0, 0, 0); return true; }
    if (_esc == ord("t")) { regex__tok_push(_ctx, _ctx.TK_ATOM, _ctx.AT_CHAR, 9, 0, 0, 0); return true; }

    if (_esc == ord("b")) { regex__tok_push(_ctx, _ctx.TK_ATOM, _ctx.AT_WB, 0, 0, 0, 0); return true; }
    if (_esc == ord("B")) { regex__tok_push(_ctx, _ctx.TK_ATOM, _ctx.AT_NWB, 0, 0, 0, 0); return true; }

    if (_esc == ord("s")) {
        var _pairs = [];
        _pairs = regex__pairs_add(_pairs, 9, 9);
        _pairs = regex__pairs_add(_pairs, 10, 10);
        _pairs = regex__pairs_add(_pairs, 13, 13);
        _pairs = regex__pairs_add(_pairs, 32, 32);
        var _cid = regex__class_new(_ctx, _pairs, false);
        regex__tok_push(_ctx, _ctx.TK_ATOM, _ctx.AT_CLASS, _cid, 0, 0, 0);
        return true;
    }

    if (_esc == ord("S")) {
        var _pairs2 = [];
        _pairs2 = regex__pairs_add(_pairs2, 9, 9);
        _pairs2 = regex__pairs_add(_pairs2, 10, 10);
        _pairs2 = regex__pairs_add(_pairs2, 13, 13);
        _pairs2 = regex__pairs_add(_pairs2, 32, 32);
        var _cid2 = regex__class_new(_ctx, _pairs2, true);
        regex__tok_push(_ctx, _ctx.TK_ATOM, _ctx.AT_CLASS, _cid2, 0, 0, 0);
        return true;
    }

    // Default: escaped literal byte
    regex__tok_push(_ctx, _ctx.TK_ATOM, _ctx.AT_CHAR, _esc, 0, 0, 0);
    return true;
}

function regex__lex_escape_class(_ctx, _pairs_arr) {
    var _esc = regex__pat_read(_ctx);
    if (_esc < 0) return _pairs_arr;

    if (_esc == ord("n")) return regex__pairs_add(_pairs_arr, 10, 10);
    if (_esc == ord("r")) return regex__pairs_add(_pairs_arr, 13, 13);
    if (_esc == ord("t")) return regex__pairs_add(_pairs_arr, 9, 9);

    if (_esc == ord("s")) {
        _pairs_arr = regex__pairs_add(_pairs_arr, 9, 9);
        _pairs_arr = regex__pairs_add(_pairs_arr, 10, 10);
        _pairs_arr = regex__pairs_add(_pairs_arr, 13, 13);
        _pairs_arr = regex__pairs_add(_pairs_arr, 32, 32);
        return _pairs_arr;
    }

    if (_esc == ord("S")) {
        // treat as literal 'S' inside class
        return regex__pairs_add(_pairs_arr, ord("S"), ord("S"));
    }

    return regex__pairs_add(_pairs_arr, _esc, _esc);
}

function regex__emit(_ctx, _opcode, _arga, _argb, _data) {
    var _idx = array_length(_ctx.prog_op);
    array_push(_ctx.prog_op, _opcode);
    array_push(_ctx.prog_a, _arga);
    array_push(_ctx.prog_b, _argb);
    array_push(_ctx.prog_data, _data);
    return _idx;
}

// Patch list encoding: positive = patch A, negative = patch B
function regex__out_a(_state) { return _state + 1; }
function regex__out_b(_state) { return -(_state + 1); }
function regex__out_get_state(_patch) { return abs(_patch) - 1; }
function regex__out_is_a(_patch) { return (_patch > 0); }

function regex__outs_patch(_ctx, _outs_arr, _target) {
    var _olen = array_length(_outs_arr);
    var _ii = 0;
    repeat (_olen) {
        var _patch = _outs_arr[_ii];
        _ii += 1;

        var _st = regex__out_get_state(_patch);
        if (regex__out_is_a(_patch)) _ctx.prog_a[_st] = _target;
        else _ctx.prog_b[_st] = _target;
    }
}

function regex__outs_merge(_left, _rght) {
    var _outt = [];
    var _llen = array_length(_left);
    var _rlen = array_length(_rght);

    var _ii = 0;
    repeat (_llen) { array_push(_outt, _left[_ii]); _ii += 1; }

    _ii = 0;
    repeat (_rlen) { array_push(_outt, _rght[_ii]); _ii += 1; }

    return _outt;
}

function regex__frag_push(_ctx, _start, _outs, _ckind, _cdata) {
    array_push(_ctx.frag_start, _start);
    array_push(_ctx.frag_outs, _outs);
    array_push(_ctx.frag_ckind, _ckind);
    array_push(_ctx.frag_cdata, _cdata);
}

function regex__frag_pop(_ctx) {
    var _len = array_length(_ctx.frag_start);
    var _idx = _len - 1;

    var _start = _ctx.frag_start[_idx];
    var _outs  = _ctx.frag_outs[_idx];
    var _ckind = _ctx.frag_ckind[_idx];
    var _cdata = _ctx.frag_cdata[_idx];

    array_pop(_ctx.frag_start);
    array_pop(_ctx.frag_outs);
    array_pop(_ctx.frag_ckind);
    array_pop(_ctx.frag_cdata);

    return { start: _start, outs: _outs, ckind: _ckind, cdata: _cdata };
}

function regex__frag_is_clonable(_frag) {
    return (_frag.ckind != 0);
}

function regex__frag_compile_atom(_ctx, _ckind, _cdata) {
    if (_ckind == _ctx.AT_CHAR) {
        var _st = regex__emit(_ctx, _ctx.OP_CHAR, -1, -1, _cdata);
        return { start: _st, outs: [ regex__out_a(_st) ], ckind: 1, cdata: _cdata };
    }
    if (_ckind == _ctx.AT_CLASS) {
        var _st2 = regex__emit(_ctx, _ctx.OP_CLASS, -1, -1, _cdata);
        return { start: _st2, outs: [ regex__out_a(_st2) ], ckind: 2, cdata: _cdata };
    }
    if (_ckind == _ctx.AT_ANY) {
        var _st3 = regex__emit(_ctx, _ctx.OP_ANY, -1, -1, 0);
        return { start: _st3, outs: [ regex__out_a(_st3) ], ckind: 3, cdata: 0 };
    }
    if (_ckind == _ctx.AT_BOL) {
        var _st4 = regex__emit(_ctx, _ctx.OP_BOL, -1, -1, 0);
        return { start: _st4, outs: [ regex__out_a(_st4) ], ckind: 4, cdata: 0 };
    }
    if (_ckind == _ctx.AT_EOL) {
        var _st5 = regex__emit(_ctx, _ctx.OP_EOL, -1, -1, 0);
        return { start: _st5, outs: [ regex__out_a(_st5) ], ckind: 5, cdata: 0 };
    }
    if (_ckind == _ctx.AT_WB) {
        var _st6 = regex__emit(_ctx, _ctx.OP_WB, -1, -1, 0);
        return { start: _st6, outs: [ regex__out_a(_st6) ], ckind: 6, cdata: 0 };
    }
    if (_ckind == _ctx.AT_NWB) {
        var _st7 = regex__emit(_ctx, _ctx.OP_NWB, -1, -1, 0);
        return { start: _st7, outs: [ regex__out_a(_st7) ], ckind: 7, cdata: 0 };
    }

    var _st8 = regex__emit(_ctx, _ctx.OP_JUMP, -1, -1, 0);
    return { start: _st8, outs: [ regex__out_a(_st8) ], ckind: 0, cdata: 0 };
}

function regex__frag_clone_atom(_ctx, _frag) {
    if (_frag.ckind == 1) return regex__frag_compile_atom(_ctx, _ctx.AT_CHAR, _frag.cdata);
    if (_frag.ckind == 2) return regex__frag_compile_atom(_ctx, _ctx.AT_CLASS, _frag.cdata);
    if (_frag.ckind == 3) return regex__frag_compile_atom(_ctx, _ctx.AT_ANY, 0);
    if (_frag.ckind == 4) return regex__frag_compile_atom(_ctx, _ctx.AT_BOL, 0);
    if (_frag.ckind == 5) return regex__frag_compile_atom(_ctx, _ctx.AT_EOL, 0);
    if (_frag.ckind == 6) return regex__frag_compile_atom(_ctx, _ctx.AT_WB, 0);
    if (_frag.ckind == 7) return regex__frag_compile_atom(_ctx, _ctx.AT_NWB, 0);
    return regex__frag_compile_atom(_ctx, _ctx.AT_ANY, 0);
}