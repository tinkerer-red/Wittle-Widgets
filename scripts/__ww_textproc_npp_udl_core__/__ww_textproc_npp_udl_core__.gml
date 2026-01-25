#region jsDoc
/// @func    __ww_textproc_npp_udl_core__(_raw_text, _default_state)
/// @desc    Core processor for UDL-derived highlighting.
///
///          Fixes included:
///          - Font style spans now always reset correctly: style/underline/strike are always emitted
///            in style patches (builder function), so leaving begin/end does not leak bold.
///          - Numbers match UDL 2.1 rules:
///              Prefix1 + digits only
///              Prefix2 + digits/extras1 (digits not required, but at least 1 body char required)
///              Suffix1 + digits/extras2 (digits not required, but at least 1 body char required)
///              Suffix2 + digits only
///              Decimal point selection is honored and only one point is allowed.
///          - Range symbols can act as a leading sign when they appear at the start of a number
///            (not after an alnum or underscore).
///
/// @param   {String} _raw_text
/// @param   {Struct} _default_state
/// @returns {Struct} { text, spans, align_runs }
#endregion
function __ww_textproc_npp_udl_core__(_raw_text, _default_state) {
	// Prefer the newer buffer+trie scanner when available.
	// Fallback to the legacy string scanner for older processor structs.
	if (!is_undefined(self.trie_symbols)) {
		return __ww_textproc_npp_udl_core__buff__(_raw_text, _default_state);
	}

	var _ctx = __ww_textproc_ctx_begin__(_default_state);

	if (is_undefined(_raw_text) || _raw_text == "") {
		var _done = __ww_textproc_ctx_finish__(_ctx);
		_done.align_runs = [];
		return _done;
	}

	var _patches = patches;

	var _patch_def = _patches[$ "DEFAULT"];
	var _patch_com_line = _patches[$ "LINE COMMENTS"];
	var _patch_com_blk = _patches[$ "COMMENTS"];

	var _patch_num1 = _patches[$ "NUMBERS"];
	var _patch_num2 = _patches[$ "NUMBERS2"];

	__ww_textproc_ctx_apply_patch__(_ctx, _patch_def);
	_ctx.span_start = 0;

	var _text_len = string_length(_raw_text);
	var _indx = 1;

	var _kw_sets = kw_sets;
	var _kw_list = kw_list;
	var _kw_pref = kw_prefix;

	var _fold_word = fold_word_map;
	var _fold_pnam = fold_patch_name;

	var _del_open = delims_open;
	var _del_escp = delims_escape;
	var _del_clos = delims_close;
	var _del_eolc = delims_close_is_eol;

	var _sym_buck = sym_buckets;

	var _line_open = comment_line_open;
	var _line_cont = comment_line_continue;
	var _line_close = comment_line_close;
	var _bloc_open = comment_block_open;
	var _bloc_close = comment_block_close;

	var _leng_line_open = string_length(_line_open);
	var _leng_line_cont = string_length(_line_cont);
	var _leng_line_close = string_length(_line_close);
	var _leng_bloc_open = string_length(_bloc_open);
	var _leng_bloc_close = string_length(_bloc_close);

	// Numbers data
	var _num_pref1 = num_prefix1;
	var _num_pref2 = num_prefix2;
	var _num_suf1 = num_suffix1;
	var _num_suf2 = num_suffix2;
	var _num_rng = num_range;
	var _num_ext1 = num_extras1;
	var _num_ext2 = num_extras2;
	var _num_dot = num_decimal_dot;
	var _num_com = num_decimal_comma;

	while (_indx <= _text_len) {
		var _char = string_char_at(_raw_text, _indx);

		// Comments (line)
		if (_leng_line_open > 0 && (_indx + _leng_line_open - 1) <= _text_len && string_copy(_raw_text, _indx, _leng_line_open) == _line_open) {
			__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
			__ww_textproc_ctx_apply_patch__(_ctx, _patch_com_line);
			_ctx.span_start = _ctx.out_len;

			while (_indx <= _text_len) {
				if (_leng_line_close > 0 && (_indx + _leng_line_close - 1) <= _text_len && string_copy(_raw_text, _indx, _leng_line_close) == _line_close) {
					var _closei = 0;
					while (_closei < _leng_line_close) {
						__ww_textproc_ctx_append_text__(_ctx, string_char_at(_raw_text, _indx));
						_indx += 1;
						_closei += 1;
					}
					break;
				}

				var _ccur = string_char_at(_raw_text, _indx);
				__ww_textproc_ctx_append_text__(_ctx, _ccur);
				_indx += 1;

				if (_ccur == "\n" || _ccur == "\r") { break; }
			}

			__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
			__ww_textproc_ctx_apply_patch__(_ctx, _patch_def);
			_ctx.span_start = _ctx.out_len;

			if (_leng_line_cont > 0 && _indx <= _text_len && (_indx + _leng_line_cont - 1) <= _text_len && string_copy(_raw_text, _indx, _leng_line_cont) == _line_cont) {
				__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
				__ww_textproc_ctx_apply_patch__(_ctx, _patch_com_line);
				_ctx.span_start = _ctx.out_len;

				var _conti = 0;
				while (_conti < _leng_line_cont)
				{
					__ww_textproc_ctx_append_text__(_ctx, string_char_at(_raw_text, _indx));
					_indx += 1;
					_conti += 1;
				}
			}

			continue;
		}

		// Comments (block)
		if (_leng_bloc_open > 0 && (_indx + _leng_bloc_open - 1) <= _text_len && string_copy(_raw_text, _indx, _leng_bloc_open) == _bloc_open) {
			__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
			__ww_textproc_ctx_apply_patch__(_ctx, _patch_com_blk);
			_ctx.span_start = _ctx.out_len;

			while (_indx <= _text_len) {
				if (_leng_bloc_close > 0 && (_indx + _leng_bloc_close - 1) <= _text_len && string_copy(_raw_text, _indx, _leng_bloc_close) == _bloc_close) {
					var _bclose = 0;
					while (_bclose < _leng_bloc_close) {
						__ww_textproc_ctx_append_text__(_ctx, string_char_at(_raw_text, _indx));
						_indx += 1;
						_bclose += 1;
					}
					break;
				}

				__ww_textproc_ctx_append_text__(_ctx, string_char_at(_raw_text, _indx));
				_indx += 1;
			}

			__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
			__ww_textproc_ctx_apply_patch__(_ctx, _patch_def);
			_ctx.span_start = _ctx.out_len;

			continue;
		}

		// Delimiters (8 groups)
		var _del_hit = false;
		var _delgrp = 0;

		while (_delgrp < 8 && !_del_hit) {
			var _openv = _del_open[_delgrp];
			var _openl = string_length(_openv);

			if (_openl > 0 && (_indx + _openl - 1) <= _text_len && string_copy(_raw_text, _indx, _openl) == _openv) {
				_del_hit = true;

				var _styname = "DELIMITERS" + string(_delgrp + 1);
				var _stypat = _patches[$ _styname] ?? _patch_def;

				__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
				__ww_textproc_ctx_apply_patch__(_ctx, _stypat);
				_ctx.span_start = _ctx.out_len;

				var _escpv = _del_escp[_delgrp];
				var _closev = _del_clos[_delgrp];
				var _closel = string_length(_closev);
				var _eolcl = _del_eolc[_delgrp];

				var _openi = 0;
				while (_openi < _openl) {
					__ww_textproc_ctx_append_text__(_ctx, string_char_at(_raw_text, _indx));
					_indx += 1;
					_openi += 1;
				}

				if (_eolcl) {
					while (_indx <= _text_len) {
						var _dch = string_char_at(_raw_text, _indx);
						__ww_textproc_ctx_append_text__(_ctx, _dch);
						_indx += 1;

						if (_dch == "\n" || _dch == "\r") { break; }
					}
				}
				else {
					while (_indx <= _text_len) {
						var _dch2 = string_char_at(_raw_text, _indx);

						if (_escpv != "" && _dch2 == _escpv && (_indx + 1) <= _text_len) {
							__ww_textproc_ctx_append_text__(_ctx, _dch2);
							__ww_textproc_ctx_append_text__(_ctx, string_char_at(_raw_text, _indx + 1));
							_indx += 2;
							continue;
						}

						if (_closel > 0 && (_indx + _closel - 1) <= _text_len && string_copy(_raw_text, _indx, _closel) == _closev) {
							var _closei2 = 0;
							while (_closei2 < _closel) {
								__ww_textproc_ctx_append_text__(_ctx, string_char_at(_raw_text, _indx));
								_indx += 1;
								_closei2 += 1;
							}
							break;
						}

						__ww_textproc_ctx_append_text__(_ctx, _dch2);
						_indx += 1;
					}
				}

				__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
				__ww_textproc_ctx_apply_patch__(_ctx, _patch_def);
				_ctx.span_start = _ctx.out_len;
			}

			_delgrp += 1;
		}

		if (_del_hit) { continue; }

		// Symbol tokens (keywords/operators/folding) by bucket, longest match
		var _ordv = ord(_char);
		if (_ordv >= 0 && _ordv < 128) {
			var _buck = _sym_buck[_ordv];
			var _buck_len = array_length(_buck);

			var _best_len = 0;
			var _best_knd = 0;
			var _best_idd = 0;

			var _bidx = 0;
			while (_bidx < _buck_len) {
				var _rec = _buck[_bidx];
				_bidx += 1;

				var _toke = _rec[0];
				var _tlen = string_length(_toke);
				if (_tlen <= _best_len) { continue; }
				if ((_indx + _tlen - 1) > _text_len) { continue; }

				if (string_copy(_raw_text, _indx, _tlen) == _toke) {
					_best_len = _tlen;
					_best_knd = _rec[1];
					_best_idd = _rec[2];
				}
			}

			if (_best_len > 0) {
				var _sty_nam2 = "";
				if (_best_knd == 1) {
					_sty_nam2 = "KEYWORDS" + string(_best_idd);
				}
				else if (_best_knd == 2) {
					_sty_nam2 = ((_best_idd == 2) ? "OPERATORS2" : "OPERATORS");
				}
				else if (_best_knd == 3) {
					_sty_nam2 = (_fold_pnam[_best_idd] ?? "");
				}

				var _sty_pat2 = ((_sty_nam2 != "") ? (_patches[$ _sty_nam2] ?? _patch_def) : _patch_def);

				__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
				__ww_textproc_ctx_apply_patch__(_ctx, _sty_pat2);
				_ctx.span_start = _ctx.out_len;

				var _midx = 0;
				while (_midx < _best_len) {
					__ww_textproc_ctx_append_text__(_ctx, string_char_at(_raw_text, _indx));
					_indx += 1;
					_midx += 1;
				}

				__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
				__ww_textproc_ctx_apply_patch__(_ctx, _patch_def);
				_ctx.span_start = _ctx.out_len;

				continue;
			}
		}

		// Range tokens that are glued between two numbers (e.g. 1_2)
		// This must run before identifier parsing so '_' does not become a keyword prefix.
		if (array_length(_num_rng) > 0 && _indx > 1) {
			var _lhs = string_char_at(_raw_text, _indx - 1);
			var _lhs_is_digit = (_lhs >= "0" && _lhs <= "9");

			if (_lhs_is_digit) {
				var _rbest = "";
				var _rbest_len = 0;

				var _rlen = array_length(_num_rng);
				var _rind = 0;
				while (_rind < _rlen) {
					var _rtok = _num_rng[_rind];
					_rind += 1;

					var _rtlen = string_length(_rtok);
					if (_rtlen <= _rbest_len) { continue; }
					if ((_indx + _rtlen - 1) > _text_len) { continue; }

					if (string_copy(_raw_text, _indx, _rtlen) == _rtok) {
						_rbest = _rtok;
						_rbest_len = _rtlen;
					}
				}

				if (_rbest_len > 0) {
					// Must be glued: no whitespace directly on either side
					var _pos_after = _indx + _rbest_len;
					var _ok_glue = true;

					if (ord(_lhs) <= 32) { _ok_glue = false; }
					if (_pos_after > _text_len) { _ok_glue = false; }
					else {
						var _post_ch = string_char_at(_raw_text, _pos_after);
						if (ord(_post_ch) <= 32) { _ok_glue = false; }
					}

					if (_ok_glue) {
						// Parse second number starting at _pos_after (allow prefixes and extras)
						var _posn2 = _pos_after;

						var _best_p1b_len = 0;
						var _best_p2b_len = 0;

						var _p1b_len = array_length(_num_pref1);
						var _p1b_ind = 0;
						while (_p1b_ind < _p1b_len) {
							var _tokp1b = _num_pref1[_p1b_ind];
							_p1b_ind += 1;

							var _tl1b = string_length(_tokp1b);
							if (_tl1b <= _best_p1b_len) { continue; }
							if ((_posn2 + _tl1b - 1) > _text_len) { continue; }
							if (string_copy(_raw_text, _posn2, _tl1b) == _tokp1b) {
								_best_p1b_len = _tl1b;
							}
						}

						var _p2b_len = array_length(_num_pref2);
						var _p2b_ind = 0;
						while (_p2b_ind < _p2b_len) {
							var _tokp2b = _num_pref2[_p2b_ind];
							_p2b_ind += 1;

							var _tl2b = string_length(_tokp2b);
							if (_tl2b <= _best_p2b_len) { continue; }
							if ((_posn2 + _tl2b - 1) > _text_len) { continue; }
							if (string_copy(_raw_text, _posn2, _tl2b) == _tokp2b) {
								_best_p2b_len = _tl2b;
							}
						}

						var _use_prefb = 0;
						var _scan2 = _posn2;
						if (_best_p2b_len > 0) { _use_prefb = 2; _scan2 = _posn2 + _best_p2b_len; }
						else if (_best_p1b_len > 0) { _use_prefb = 1; _scan2 = _posn2 + _best_p1b_len; }

						var _body2_len = 0;
						var _seen_pt2 = false;
						var _allow_ex2 = (_use_prefb == 2);

						while (_scan2 <= _text_len) {
							var _ch2 = string_char_at(_raw_text, _scan2);
							var _is_d2 = (_ch2 >= "0" && _ch2 <= "9");
							if (_is_d2) {
								_scan2 += 1;
								_body2_len += 1;
								continue;
							}

							var _is_pt2 = false;
							if (!_seen_pt2) {
								if (_num_dot && _ch2 == ".") { _is_pt2 = true; }
								else if (_num_com && _ch2 == ",") { _is_pt2 = true; }
							}

							if (_is_pt2) {
								_seen_pt2 = true;
								_scan2 += 1;
								_body2_len += 1;
								continue;
							}

							if (_allow_ex2 && !is_undefined(_num_ext1[$ _ch2])) {
								_scan2 += 1;
								_body2_len += 1;
								continue;
							}

							break;
						}

						// Accept if we have any body content, or if a prefix was present
						var _ok_second = ((_body2_len > 0) || (_use_prefb != 0));

						if (_ok_second) {
							var _use_style2b = (_use_prefb == 2);
							var _num_patb = (_use_style2b ? _patch_num2 : _patch_num1);

							__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
							__ww_textproc_ctx_apply_patch__(_ctx, _num_patb);
							_ctx.span_start = _ctx.out_len;

							// Emit range token
							var _emit_rng = 0;
							while (_emit_rng < _rbest_len) {
								__ww_textproc_ctx_append_text__(_ctx, string_char_at(_raw_text, _indx));
								_indx += 1;
								_emit_rng += 1;
							}

							// Emit second number (prefix + body)
							var _emit_end2 = _scan2;
							while (_indx < _emit_end2) {
								__ww_textproc_ctx_append_text__(_ctx, string_char_at(_raw_text, _indx));
								_indx += 1;
							}

							__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
							__ww_textproc_ctx_apply_patch__(_ctx, _patch_def);
							_ctx.span_start = _ctx.out_len;

							continue;
						}
					}
				}
			}
		}

		// Identifiers (fold words, keyword exact, keyword prefix)
		var _is_id0 = ((_char >= "A" && _char <= "Z") || (_char >= "a" && _char <= "z") || (_char == "_"));
		if (_is_id0) {
			var _id_beg = _indx;

			while (_indx <= _text_len) {
				var _ic = string_char_at(_raw_text, _indx);
				var _ok3 = ((_ic >= "A" && _ic <= "Z") || (_ic >= "a" && _ic <= "z") || (_ic >= "0" && _ic <= "9") || (_ic == "_"));
				if (!_ok3) { break; }
				_indx += 1;
			}

			var _id_len = _indx - _id_beg;
			var _ident = string_copy(_raw_text, _id_beg, _id_len);

			var _fold_ind = _fold_word[$ _ident];
			if (!is_undefined(_fold_ind)) {
				var _pnam = (_fold_pnam[_fold_ind] ?? "");
				var _ppat = ((_pnam != "") ? (_patches[$ _pnam] ?? _patch_def) : _patch_def);

				__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
				__ww_textproc_ctx_apply_patch__(_ctx, _ppat);
				_ctx.span_start = _ctx.out_len;

				__ww_textproc_ctx_append_text__(_ctx, _ident);

				__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
				__ww_textproc_ctx_apply_patch__(_ctx, _patch_def);
				_ctx.span_start = _ctx.out_len;

				continue;
			}

			var _grp_hit = 0;

			var _gidx = 1;
	repeat (8) {
		var _setv = (_kw_sets[_gidx] ?? {});
		if (!is_undefined(_setv[$ _ident])) {
			_grp_hit = _gidx;
			break;
		}
		_gidx += 1;
	}

			if (_grp_hit == 0) {
				var _best_grp = 0;
				var _best_pre = 0;

				var _pidx = 1;
		repeat (8) {
					if (_kw_pref[_pidx] == true) {
						var _arrv = (_kw_list[_pidx] ?? []);
						var _arr_len = array_length(_arrv);

						var _aidx = 0;
						while (_aidx < _arr_len) {
							var _pre = _arrv[_aidx];
							_aidx += 1;

							var _plen = string_length(_pre);
							if (_plen <= 0) { continue; }
							if (_plen > _id_len) { continue; }

							if (string_copy(_ident, 1, _plen) == _pre) {
								if (_plen > _best_pre || (_plen == _best_pre && (_best_grp < 0 || _pidx < _best_grp))) {
									_best_pre = _plen;
									_best_grp = _pidx;
								}
							}
						}
					}

					_pidx += 1;
				}

				_grp_hit = _best_grp;
			}

			if (_grp_hit >= 0) {
				var _knam = "KEYWORDS" + string(_grp_hit);
				var _kpat = (_patches[$ _knam] ?? _patch_def);

				__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
				__ww_textproc_ctx_apply_patch__(_ctx, _kpat);
				_ctx.span_start = _ctx.out_len;

				__ww_textproc_ctx_append_text__(_ctx, _ident);

				__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
				__ww_textproc_ctx_apply_patch__(_ctx, _patch_def);
				_ctx.span_start = _ctx.out_len;

				continue;
			}

			__ww_textproc_ctx_append_text__(_ctx, _ident);
			continue;
		}

		// Numbers (UDL 2.1), including optional leading range symbol as sign
		if (true) {
			var _scan_start = _indx;

			// Optional leading range symbol, only if previous char is not alnum or underscore
			var _sign_len = 0;

			var _allow_sign = true;
			if (_scan_start > 1) {
				var _prevc = string_char_at(_raw_text, _scan_start - 1);
				var _is_aln = ((_prevc >= "A" && _prevc <= "Z") || (_prevc >= "a" && _prevc <= "z") || (_prevc >= "0" && _prevc <= "9") || (_prevc == "_"));
				if (_is_aln) { _allow_sign = false; }
			}

			if (_allow_sign && array_length(_num_rng) > 0) {
				var _rngi = 0;
				var _rngl = array_length(_num_rng);

				while (_rngi < _rngl) {
					var _rtok = _num_rng[_rngi];
					_rngi += 1;

					var _rtokl = string_length(_rtok);
					if (_rtokl <= _sign_len) { continue; }
					if ((_scan_start + _rtokl - 1) > _text_len) { continue; }

					if (string_copy(_raw_text, _scan_start, _rtokl) == _rtok) {
						_sign_len = _rtokl;
					}
				}

				if (_sign_len > 0) {
					_scan_start += _sign_len;
				}
			}

			// Match longest prefix at _scan_start
			var _best_p1_len = 0;

			var _p1_len = array_length(_num_pref1);
			var _p1_ind = 0;
			while (_p1_ind < _p1_len) {
				var _tokp = _num_pref1[_p1_ind];
				_p1_ind += 1;

				var _tokl = string_length(_tokp);
				if (_tokl <= _best_p1_len) { continue; }
				if ((_scan_start + _tokl - 1) > _text_len) { continue; }

				if (string_copy(_raw_text, _scan_start, _tokl) == _tokp) {
					_best_p1_len = _tokl;
				}
			}

			var _best_p2_len = 0;

			var _p2_len = array_length(_num_pref2);
			var _p2_ind = 0;
			while (_p2_ind < _p2_len) {
				var _tokp2 = _num_pref2[_p2_ind];
				_p2_ind += 1;

				var _tokl2 = string_length(_tokp2);
				if (_tokl2 <= _best_p2_len) { continue; }
				if ((_scan_start + _tokl2 - 1) > _text_len) { continue; }

				if (string_copy(_raw_text, _scan_start, _tokl2) == _tokp2) {
					_best_p2_len = _tokl2;
				}
			}

			var _use_pref_kind = 0; // 0 none, 1 prefix1, 2 prefix2
			var _posn = _scan_start;

			if (_best_p2_len > 0) {
				_use_pref_kind = 2;
				_posn = _scan_start + _best_p2_len;
			}
			else if (_best_p1_len > 0) {
				_use_pref_kind = 1;
				_posn = _scan_start + _best_p1_len;
			}

			// Consume number body
			var _body_len = 0;
			var _seen_point = false;

			var _allow_extras = (_use_pref_kind == 2);

			while (_posn <= _text_len) {
				var _ch = string_char_at(_raw_text, _posn);

				var _is_dig = (_ch >= "0" && _ch <= "9");
				if (_is_dig) {
					_posn += 1;
					_body_len += 1;
					continue;
				}

				var _is_point = false;
				if (!_seen_point) {
					if (_num_dot && _ch == ".") { _is_point = true; }
					else if (_num_com && _ch == ",") { _is_point = true; }
				}

				if (_is_point) {
					_seen_point = true;
					_posn += 1;
					_body_len += 1;
					continue;
				}

				if (_allow_extras) {
					if (!is_undefined(_num_ext1[$ _ch])) {
						_posn += 1;
						_body_len += 1;
						continue;
					}
				}

				break;
			}

			// Validate body requirements by kind:
			// - prefix1: at least 1 digit (not just point)
			// - prefix2: at least 1 body char (digits not required)
			// - no prefix: at least 1 digit (not just point)
			var _body_ok = false;
			var _has_digit = false;

			if (_body_len > 0) {
				var _scan_pos = _posn - _body_len;
				var _scan_end = _posn - 1;

				while (_scan_pos <= _scan_end) {
					var _sd = string_char_at(_raw_text, _scan_pos);
					if (_sd >= "0" && _sd <= "9")
					{
						_has_digit = true;
						break;
					}
					_scan_pos += 1;
				}

				if (_use_pref_kind == 2) {
					_body_ok = true;
				}
				else {
					_body_ok = _has_digit;
				}
			}

			if (_body_ok) {
				// Attempt suffix matches at _posn
				var _best_s1_len = 0;

				var _s1_len = array_length(_num_suf1);
				var _s1_ind = 0;
				while (_s1_ind < _s1_len) {
					var _toks1 = _num_suf1[_s1_ind];
					_s1_ind += 1;

					var _tl1 = string_length(_toks1);
					if (_tl1 <= _best_s1_len) { continue; }
					if ((_posn + _tl1 - 1) > _text_len) { continue; }

					if (string_copy(_raw_text, _posn, _tl1) == _toks1) {
						_best_s1_len = _tl1;
					}
				}

				var _best_s2_len = 0;

				var _s2_len = array_length(_num_suf2);
				var _s2_ind = 0;
				while (_s2_ind < _s2_len) {
					var _toks2 = _num_suf2[_s2_ind];
					_s2_ind += 1;

					var _tl2 = string_length(_toks2);
					if (_tl2 <= _best_s2_len) { continue; }
					if ((_posn + _tl2 - 1) > _text_len) { continue; }

					if (string_copy(_raw_text, _posn, _tl2) == _toks2) {
						_best_s2_len = _tl2;
					}
				}

				var _use_suffix_kind = 0; // 0 none, 1 suffix1, 2 suffix2
				var _suf_len = 0;

				// Validate suffix1: digits + extras2 (digits not required)
				if (_best_s1_len > 0) {
					var _ok_body = true;

					var _scan_pos2 = _posn - _body_len;
					var _scan_end2 = _posn - 1;

					while (_scan_pos2 <= _scan_end2) {
						var _sb = string_char_at(_raw_text, _scan_pos2);

						var _is_dig2 = (_sb >= "0" && _sb <= "9");
						if (_is_dig2) {
							_scan_pos2 += 1;
							continue;
						}

						var _is_point2 = false;
						if (_num_dot && _sb == ".") { _is_point2 = true; }
						else if (_num_com && _sb == ",") { _is_point2 = true; }

						if (_is_point2) {
							_scan_pos2 += 1;
							continue;
						}

						if (is_undefined(_num_ext2[$ _sb])) {
							_ok_body = false;
							break;
						}

						_scan_pos2 += 1;
					}

					if (_ok_body) {
						_use_suffix_kind = 1;
						_suf_len = _best_s1_len;
					}
				}

				// Validate suffix2: digits only (digits required)
				if (_use_suffix_kind == 0 && _best_s2_len > 0) {
					if (_has_digit) {
						var _ok_body2 = true;

						var _scan_pos3 = _posn - _body_len;
						var _scan_end3 = _posn - 1;

						while (_scan_pos3 <= _scan_end3) {
							var _sb2 = string_char_at(_raw_text, _scan_pos3);

							var _is_dig3 = (_sb2 >= "0" && _sb2 <= "9");
							if (_is_dig3) {
								_scan_pos3 += 1;
								continue;
							}

							var _is_point3 = false;
							if (_num_dot && _sb2 == ".") { _is_point3 = true; }
							else if (_num_com && _sb2 == ",") { _is_point3 = true; }

							if (_is_point3) {
								_scan_pos3 += 1;
								continue;
							}

							_ok_body2 = false;
							break;
						}

						if (_ok_body2) {
							_use_suffix_kind = 2;
							_suf_len = _best_s2_len;
						}
					}
				}

				// Choose number style:
				// - Prefix2 OR Suffix1 uses NUMBERS2
				// - otherwise NUMBERS
				var _use_style2 = ((_use_pref_kind == 2) || (_use_suffix_kind == 1));
				var _num_pat = (_use_style2 ? _patch_num2 : _patch_num1);

				// Emit number token from original _indx through end
				var _emit_end = _posn + _suf_len;

				// Must ensure we did not match sign-only (requires body_len > 0 already)
				if (_emit_end > _indx) {
					__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
					__ww_textproc_ctx_apply_patch__(_ctx, _num_pat);
					_ctx.span_start = _ctx.out_len;

					while (_indx < _emit_end) {
						__ww_textproc_ctx_append_text__(_ctx, string_char_at(_raw_text, _indx));
						_indx += 1;
					}

					__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
					__ww_textproc_ctx_apply_patch__(_ctx, _patch_def);
					_ctx.span_start = _ctx.out_len;

					continue;
				}
			}
		}

		// Standalone number ranges (between numbers)
		// Longest match at current position
		var _rng_best_len = 0;

		var _rng_len = array_length(_num_rng);
		var _rng_ind = 0;
		while (_rng_ind < _rng_len) {
			var _rng_tok = _num_rng[_rng_ind];
			_rng_ind += 1;

			var _rng_tln = string_length(_rng_tok);
			if (_rng_tln <= _rng_best_len) { continue; }
			if ((_indx + _rng_tln - 1) > _text_len) { continue; }

			if (string_copy(_raw_text, _indx, _rng_tln) == _rng_tok) {
				_rng_best_len = _rng_tln;
			}
		}

		if (_rng_best_len > 0) {
			__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
			__ww_textproc_ctx_apply_patch__(_ctx, _patch_num1);
			_ctx.span_start = _ctx.out_len;

			var _ri = 0;
			while (_ri < _rng_best_len) {
				__ww_textproc_ctx_append_text__(_ctx, string_char_at(_raw_text, _indx));
				_indx += 1;
				_ri += 1;
			}

			__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
			__ww_textproc_ctx_apply_patch__(_ctx, _patch_def);
			_ctx.span_start = _ctx.out_len;

			continue;
		}

		// Default char
		__ww_textproc_ctx_append_text__(_ctx, _char);
		_indx += 1;
	}

	__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

	var _resu = __ww_textproc_ctx_finish__(_ctx);
	_resu.align_runs = [];
	return _resu;
}

// -----------------------------------------------------------------------------
// Buffer + trie implementation (high-performance path)
// -----------------------------------------------------------------------------

function __ww_textproc_npp_udl_core__buff__(_raw_text, _default_state) {
	var _ctx = __ww_textproc_ctx_begin__(_default_state);

	if (is_undefined(_raw_text) || _raw_text == "") {
		var _done = __ww_textproc_ctx_finish__(_ctx);
		_done.align_runs = [];
		return _done;
	}

	static __in_buff = buffer_create(0, buffer_grow, 1);
	var _in_buff = __in_buff;
	
	var _byte_len = string_byte_length(_raw_text);
	buffer_resize(_in_buff, _byte_len);
	buffer_seek(_in_buff, buffer_seek_start, 0);
	buffer_write(_in_buff, buffer_text, _raw_text);

	var _patches = patches;
	var _patch_def = _patches[$ "DEFAULT"];
	var _patch_com_line = _patches[$ "LINE COMMENTS"];
	var _patch_com_blk = _patches[$ "COMMENTS"];
	var _patch_num1 = _patches[$ "NUMBERS"];
	var _patch_num2 = _patches[$ "NUMBERS2"];

	__ww_textproc_ctx_apply_patch__(_ctx, _patch_def);
	_ctx.span_start = 0;

	// Aliases
	var _fold_word = fold_word_map;
	var _fold_pnam = fold_patch_name;
	var _kw_sets   = kw_sets;
	var _kw_list   = kw_list;
	var _kw_pref   = kw_prefix;

	var _trie_com = trie_comments_open;
	var _trie_com_max = trie_comments_open_max;
	var _trie_del = trie_delims_open;
	var _trie_del_max = trie_delims_open_max;
	var _trie_sym = trie_symbols;
	var _trie_sym_max = trie_symbols_max;
	var _trie_rng = trie_num_range;
	var _trie_rng_max = trie_num_range_max;

	var _trie_p1 = trie_num_prefix1;
	var _trie_p1_max = trie_num_prefix1_max;
	var _trie_p2 = trie_num_prefix2;
	var _trie_p2_max = trie_num_prefix2_max;
	var _trie_s1 = trie_num_suffix1;
	var _trie_s1_max = trie_num_suffix1_max;
	var _trie_s2 = trie_num_suffix2;
	var _trie_s2_max = trie_num_suffix2_max;

	var _num_ext1_tbl = num_extras1_table;
	var _num_ext2_tbl = num_extras2_table;
	var _num_dot = num_decimal_dot;
	var _num_com = num_decimal_comma;

	var _line_cont_bytes = comment_line_continue_bytes;
	var _line_cont_len = array_length(_line_cont_bytes);
	var _line_close_bytes = comment_line_close_bytes;
	var _line_close_len = array_length(_line_close_bytes);
	var _bloc_close_bytes = comment_block_close_bytes;
	var _bloc_close_len = array_length(_bloc_close_bytes);

	var _del_eolc = delims_close_is_eol;
	var _del_escb = delims_escape_byte;
	var _del_clob = delims_close_bytes;
	var _del_clol = delims_close_len;

	// Accumulate plain text runs to avoid per-byte substring extraction.
	var _plain_start = -1;

	var _pos = 0;
	while (_pos < _byte_len) {
		var _b0 = buffer_peek(_in_buff, _pos, buffer_u8);

		// Fast path: non-ASCII (UTF-8 multibyte). Treat as plain text.
		if (_b0 >= 128) {
			if (_plain_start < 0) { _plain_start = _pos; }
			var _step = 1;
			if (_b0 < 224) { _step = 2; }
			else if (_b0 < 240) { _step = 3; }
			else if (_b0 < 248) { _step = 4; }
			if ((_pos + _step) > _byte_len) { _step = _byte_len - _pos; }
			_pos += _step;
			continue;
		}

		// --- Comments open ---
		if (!is_undefined(_trie_com) && !is_undefined(_trie_com[_b0])) {
			var _cm = __ww_udl_trie_match_best__(_in_buff, _pos, _byte_len, _trie_com, _trie_com_max);
			var _cm_len = (_cm >> 16);
			if (_cm_len > 0) {
			var _cm_kind = (_cm & 65535); // 1 line, 2 block
			var _scan = _pos;

			if (_cm_kind == 1) {
				if (_plain_start >= 0 && _plain_start < _pos) {
					__ww_textproc_ctx_append_text__(_ctx, regex__buffer_read_text_range(_in_buff, _plain_start, _pos));
					_plain_start = -1;
				}
				__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
				__ww_textproc_ctx_apply_patch__(_ctx, _patch_com_line);
				_ctx.span_start = _ctx.out_len;

				_scan = _pos;
				buffer_seek(_in_buff, buffer_seek_start, _scan);
				while (_scan < _byte_len) {
					if (_line_close_len > 0) {
						var _b0c = buffer_peek(_in_buff, _scan, buffer_u8);
						if (_b0c == _line_close_bytes[0]) {
							var _okc = true;
							var _ci = 1;
							repeat (_line_close_len - 1) {
								if (buffer_peek(_in_buff, _scan + _ci, buffer_u8) != _line_close_bytes[_ci]) { _okc = false; break; }
								_ci += 1;
							}
							if (_okc) { _scan += _line_close_len; break; }
						}
					}
					var _b = buffer_read(_in_buff, buffer_u8);
					_scan += 1;
					if (_b == 10 || _b == 13) { break; }
				}

				__ww_textproc_ctx_append_text__(_ctx, regex__buffer_read_text_range(_in_buff, _pos, _scan));
				__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
				__ww_textproc_ctx_apply_patch__(_ctx, _patch_def);
				_ctx.span_start = _ctx.out_len;
				_pos = _scan;

				// Line continuation token (rare): emit token if present
				if (_line_cont_len > 0 && _pos < _byte_len && __ww_udl_match_bytes_at__(_in_buff, _pos, _byte_len, _line_cont_bytes, _line_cont_len)) {
					__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
					__ww_textproc_ctx_apply_patch__(_ctx, _patch_com_line);
					_ctx.span_start = _ctx.out_len;

					__ww_textproc_ctx_append_text__(_ctx, regex__buffer_read_text_range(_in_buff, _pos, _pos + _line_cont_len));
					_pos += _line_cont_len;
				}
				continue;
			}
			else if (_cm_kind == 2) {
				if (_plain_start >= 0 && _plain_start < _pos) {
					__ww_textproc_ctx_append_text__(_ctx, regex__buffer_read_text_range(_in_buff, _plain_start, _pos));
					_plain_start = -1;
				}
				__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
				__ww_textproc_ctx_apply_patch__(_ctx, _patch_com_blk);
				_ctx.span_start = _ctx.out_len;

				_scan = _pos;
				buffer_seek(_in_buff, buffer_seek_start, _scan);
				while (_scan < _byte_len) {
					if (_bloc_close_len > 0) {
						var _b0bc = buffer_peek(_in_buff, _scan, buffer_u8);
						if (_b0bc == _bloc_close_bytes[0]) {
							var _okbc = true;
							var _bci = 1;
							repeat (_bloc_close_len - 1) {
								if (buffer_peek(_in_buff, _scan + _bci, buffer_u8) != _bloc_close_bytes[_bci]) { _okbc = false; break; }
								_bci += 1;
							}
							if (_okbc) { _scan += _bloc_close_len; break; }
						}
					}
					buffer_read(_in_buff, buffer_u8);
					_scan += 1;
				}

				__ww_textproc_ctx_append_text__(_ctx, regex__buffer_read_text_range(_in_buff, _pos, _scan));
				__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
				__ww_textproc_ctx_apply_patch__(_ctx, _patch_def);
				_ctx.span_start = _ctx.out_len;
				_pos = _scan;
				continue;
			}
			}
		}

		// --- Delimiters open (8 groups) ---
		if (!is_undefined(_trie_del) && !is_undefined(_trie_del[_b0])) {
			var _dm = __ww_udl_trie_match_best__(_in_buff, _pos, _byte_len, _trie_del, _trie_del_max);
			var _dm_len = (_dm >> 16);
			if (_dm_len > 0) {
			if (_plain_start >= 0 && _plain_start < _pos) {
				__ww_textproc_ctx_append_text__(_ctx, regex__buffer_read_text_range(_in_buff, _plain_start, _pos));
				_plain_start = -1;
			}
			var _grp = ((_dm & 65535) - 1);
			var _styname = "DELIMITERS" + string(_grp + 1);
			var _stypat = _patches[$ _styname] ?? _patch_def;

			__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
			__ww_textproc_ctx_apply_patch__(_ctx, _stypat);
			_ctx.span_start = _ctx.out_len;

			var _scan2 = _pos + _dm_len;
			if (_del_eolc[_grp]) {
				buffer_seek(_in_buff, buffer_seek_start, _scan2);
				while (_scan2 < _byte_len) {
					var _b2 = buffer_read(_in_buff, buffer_u8);
					_scan2 += 1;
					if (_b2 == 10 || _b2 == 13) { break; }
				}
			}
			else {
				var _escb = _del_escb[_grp];
				var _clb = _del_clob[_grp] ?? [];
				var _cll = (_del_clol[_grp] ?? 0);
				buffer_seek(_in_buff, buffer_seek_start, _scan2);
				while (_scan2 < _byte_len) {
					var _b3 = buffer_read(_in_buff, buffer_u8);
					_scan2 += 1;

					if (_escb != -1 && _b3 == _escb && _scan2 < _byte_len) {
						buffer_read(_in_buff, buffer_u8);
						_scan2 += 1;
						continue;
					}

					if (_cll > 0 && _b3 == _clb[0]) {
						if (_cll == 1) { break; }
						var _okd = true;
						var _di = 1;
						repeat (_cll - 1) {
							if ((_scan2 + _di - 1) >= _byte_len) { _okd = false; break; }
							if (buffer_peek(_in_buff, _scan2 + _di - 1, buffer_u8) != _clb[_di]) { _okd = false; break; }
							_di += 1;
						}
						if (_okd) {
							_scan2 += (_cll - 1);
							break;
						}
					}
				}
			}

			__ww_textproc_ctx_append_text__(_ctx, regex__buffer_read_text_range(_in_buff, _pos, _scan2));
			__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
			__ww_textproc_ctx_apply_patch__(_ctx, _patch_def);
			_ctx.span_start = _ctx.out_len;
			_pos = _scan2;
			continue;
			}
		}

		// --- Symbol tokens (keywords/operators/folding), longest match ---
		if (!is_undefined(_trie_sym) && !is_undefined(_trie_sym[_b0])) {
			var _sm = __ww_udl_trie_match_best__(_in_buff, _pos, _byte_len, _trie_sym, _trie_sym_max);
			var _sm_len = (_sm >> 16);
			if (_sm_len > 0) {
			if (_plain_start >= 0 && _plain_start < _pos) {
				__ww_textproc_ctx_append_text__(_ctx, regex__buffer_read_text_range(_in_buff, _plain_start, _pos));
				_plain_start = -1;
			}
			var _code = (_sm & 65535);
			var _kind = (_code >> 8) & 255;
			var _idd = (_code & 255);

			var _sty_nam2 = "";
			if (_kind == 1) {
				_sty_nam2 = "KEYWORDS" + string(_idd);
			}
			else if (_kind == 2) {
				_sty_nam2 = ((_idd == 2) ? "OPERATORS2" : "OPERATORS");
			}
			else if (_kind == 3) {
				_sty_nam2 = (_fold_pnam[_idd] ?? "");
			}

			var _sty_pat2 = ((_sty_nam2 != "") ? (_patches[$ _sty_nam2] ?? _patch_def) : _patch_def);

			__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
			__ww_textproc_ctx_apply_patch__(_ctx, _sty_pat2);
			_ctx.span_start = _ctx.out_len;

			__ww_textproc_ctx_append_text__(_ctx, regex__buffer_read_text_range(_in_buff, _pos, _pos + _sm_len));

			__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
			__ww_textproc_ctx_apply_patch__(_ctx, _patch_def);
			_ctx.span_start = _ctx.out_len;
			_pos += _sm_len;
			continue;
			}
		}

		// --- Range tokens glued between numbers (e.g. 1_2) ---
		if (_trie_rng_max > 0 && _pos > 0 && !is_undefined(_trie_rng) && !is_undefined(_trie_rng[_b0])) {
			var _lhs = buffer_peek(_in_buff, _pos - 1, buffer_u8);
			var _lhs_is_digit = (_lhs >= 48 && _lhs <= 57);
			if (_lhs_is_digit) {
				var _rg = __ww_udl_trie_match_best__(_in_buff, _pos, _byte_len, _trie_rng, _trie_rng_max);
				var _rg_len = (_rg >> 16);
				if (_rg_len > 0) {
					var _pos_after = _pos + _rg_len;
					if (_pos_after <= _byte_len) {
						var _ok_glue = true;
						if (_lhs <= 32) { _ok_glue = false; }
						if (_pos_after >= _byte_len) { _ok_glue = false; }
							else {
								var _post = buffer_peek(_in_buff, _pos_after, buffer_u8);
							if (_post <= 32) { _ok_glue = false; }
						}

						if (_ok_glue) {
							var _n2_start = _pos_after;
							var _p2m = __ww_udl_trie_match_best__(_in_buff, _n2_start, _byte_len, _trie_p2, _trie_p2_max);
							var _p1m = __ww_udl_trie_match_best__(_in_buff, _n2_start, _byte_len, _trie_p1, _trie_p1_max);
							var _use_prefb = 0;
							var _scanb = _n2_start;
							var _p2l = (_p2m >> 16);
							var _p1l = (_p1m >> 16);
							if (_p2l > 0) { _use_prefb = 2; _scanb = _n2_start + _p2l; }
							else if (_p1l > 0) { _use_prefb = 1; _scanb = _n2_start + _p1l; }

							var _body2_len = 0;
							var _seen_pt2 = false;
							var _allow_ex2 = (_use_prefb == 2);
							buffer_seek(_in_buff, buffer_seek_start, _scanb);
							while (_scanb < _byte_len) {
								var _ch2 = buffer_read(_in_buff, buffer_u8);
								_scanb += 1;
								if (_ch2 >= 48 && _ch2 <= 57) { _body2_len += 1; continue; }
								if (!_seen_pt2 && ((_num_dot && _ch2 == 46) || (_num_com && _ch2 == 44))) { _seen_pt2 = true; _body2_len += 1; continue; }
								if (_allow_ex2 && _ch2 >= 0 && _ch2 < 256 && _num_ext1_tbl[_ch2]) { _body2_len += 1; continue; }
								break;
							}

							var _ok_second = ((_body2_len > 0) || (_use_prefb != 0));
							if (_ok_second) {
								if (_plain_start >= 0 && _plain_start < _pos) {
									__ww_textproc_ctx_append_text__(_ctx, regex__buffer_read_text_range(_in_buff, _plain_start, _pos));
									_plain_start = -1;
								}
								var _use_style2b = (_use_prefb == 2);
								var _num_patb = (_use_style2b ? _patch_num2 : _patch_num1);

								__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
								__ww_textproc_ctx_apply_patch__(_ctx, _num_patb);
								_ctx.span_start = _ctx.out_len;

								__ww_textproc_ctx_append_text__(_ctx, regex__buffer_read_text_range(_in_buff, _pos, _scanb));

								__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
								__ww_textproc_ctx_apply_patch__(_ctx, _patch_def);
								_ctx.span_start = _ctx.out_len;
								_pos = _scanb;
								continue;
							}
						}
					}
				}
			}
		}
		
		// --- Identifiers (fold words, keyword exact, keyword prefix) ---
		var _is_id0 = ((_b0 >= 65 && _b0 <= 90) || (_b0 >= 97 && _b0 <= 122) || (_b0 == 95));
		if (_is_id0) {
			if (_plain_start >= 0 && _plain_start < _pos) {
				__ww_textproc_ctx_append_text__(_ctx, regex__buffer_read_text_range(_in_buff, _plain_start, _pos));
				_plain_start = -1;
			}
			var _id_beg = _pos;
			var _scan_id = _pos + 1;
			buffer_seek(_in_buff, buffer_seek_start, _scan_id);
			while (_scan_id < _byte_len) {
				var _ic = buffer_read(_in_buff, buffer_u8);
				var _ok3 = ((_ic >= 65 && _ic <= 90) || (_ic >= 97 && _ic <= 122) || (_ic >= 48 && _ic <= 57) || (_ic == 95));
				if (!_ok3) { break; }
				_scan_id += 1;
			}

			var _ident_len = (_scan_id - _id_beg);
			var _ident = regex__buffer_read_text_range(_in_buff, _id_beg, _scan_id);

			var _fold_ind = _fold_word[$ _ident];
			if (!is_undefined(_fold_ind)) {
				var _pnam = (_fold_pnam[_fold_ind] ?? "");
				var _ppat = ((_pnam != "") ? (_patches[$ _pnam] ?? _patch_def) : _patch_def);

				__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
				__ww_textproc_ctx_apply_patch__(_ctx, _ppat);
				_ctx.span_start = _ctx.out_len;
				__ww_textproc_ctx_append_text__(_ctx, _ident);
				__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
				__ww_textproc_ctx_apply_patch__(_ctx, _patch_def);
				_ctx.span_start = _ctx.out_len;
				_pos = _scan_id;
				continue;
			}

			var _grp_hit = 0;
			var _gidx = 1;
			repeat (8) {
				var _setv = (_kw_sets[_gidx] ?? {});
				if (!is_undefined(_setv[$ _ident])) {
					_grp_hit = _gidx;
					break;
				}
				_gidx += 1;
			}

			if (_grp_hit == 0) {
				var _best_grp = 0;
				var _best_pre = 0;
				var _pidx = 1;
				repeat (8) {
					if (_kw_pref[_pidx] == true) {
						var _arrv = (_kw_list[_pidx] ?? []);
						var _arr_len = array_length(_arrv);
						var _aidx = 0;
						while (_aidx < _arr_len) {
							var _pre = _arrv[_aidx];
							_aidx += 1;
							var _plen = string_length(_pre);
							if (_plen <= 0) { continue; }
							if (_plen > _ident_len) { continue; }
							if (string_copy(_ident, 1, _plen) == _pre) {
								if (_plen > _best_pre || (_plen == _best_pre && (_best_grp < 0 || _pidx < _best_grp))) {
									_best_pre = _plen;
									_best_grp = _pidx;
								}
							}
						}
					}
					_pidx += 1;
				}
				_grp_hit = _best_grp;
			}

			if (_grp_hit >= 0) {
				var _knam = "KEYWORDS" + string(_grp_hit);
				var _kpat = (_patches[$ _knam] ?? _patch_def);
				__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
				__ww_textproc_ctx_apply_patch__(_ctx, _kpat);
				_ctx.span_start = _ctx.out_len;
				__ww_textproc_ctx_append_text__(_ctx, _ident);
				__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
				__ww_textproc_ctx_apply_patch__(_ctx, _patch_def);
				_ctx.span_start = _ctx.out_len;
				_pos = _scan_id;
				continue;
			}

			__ww_textproc_ctx_append_text__(_ctx, _ident);
			_pos = _scan_id;
			continue;
		}

		// --- Numbers (UDL 2.1) ---
		var _scan_start = _pos;
		var _sign_len = 0;
		var _allow_sign = true;
		if (_scan_start > 0) {
			var _prevc = buffer_peek(_in_buff, _scan_start - 1, buffer_u8);
			var _is_aln = ((_prevc >= 65 && _prevc <= 90) || (_prevc >= 97 && _prevc <= 122) || (_prevc >= 48 && _prevc <= 57) || (_prevc == 95));
			if (_is_aln) { _allow_sign = false; }
		}

		if (_allow_sign && _trie_rng_max > 0 && !is_undefined(_trie_rng) && !is_undefined(_trie_rng[_b0])) {
			var _sg = __ww_udl_trie_match_best__(_in_buff, _scan_start, _byte_len, _trie_rng, _trie_rng_max);
			_sign_len = (_sg >> 16);
			if (_sign_len > 0) { _scan_start += _sign_len; }
		}

		var _p2m2 = __ww_udl_trie_match_best__(_in_buff, _scan_start, _byte_len, _trie_p2, _trie_p2_max);
		var _p1m2 = __ww_udl_trie_match_best__(_in_buff, _scan_start, _byte_len, _trie_p1, _trie_p1_max);

		var _use_pref_kind = 0;
		var _posn = _scan_start;
		var _p2l2 = (_p2m2 >> 16);
		var _p1l2 = (_p1m2 >> 16);
		if (_p2l2 > 0) { _use_pref_kind = 2; _posn = _scan_start + _p2l2; }
		else if (_p1l2 > 0) { _use_pref_kind = 1; _posn = _scan_start + _p1l2; }

		var _body_len = 0;
		var _seen_point = false;
		var _allow_extras = (_use_pref_kind == 2);
		var _has_digit = false;
		var _body_start = _posn;
		buffer_seek(_in_buff, buffer_seek_start, _posn);
		while (_posn < _byte_len) {
			var _ch = buffer_read(_in_buff, buffer_u8);
			_posn += 1;
			if (_ch >= 48 && _ch <= 57) { _body_len += 1; _has_digit = true; continue; }
			if (!_seen_point && ((_num_dot && _ch == 46) || (_num_com && _ch == 44))) { _seen_point = true; _body_len += 1; continue; }
			if (_allow_extras && _ch >= 0 && _ch < 256 && _num_ext1_tbl[_ch]) { _body_len += 1; continue; }
			break;
		}

		var _body_ok = false;
		if (_body_len > 0) {
			if (_use_pref_kind == 2) { _body_ok = true; }
			else { _body_ok = _has_digit; }
		}

		if (_body_ok) {
			var _best_s1 = __ww_udl_trie_match_best__(_in_buff, _posn, _byte_len, _trie_s1, _trie_s1_max);
			var _best_s2 = __ww_udl_trie_match_best__(_in_buff, _posn, _byte_len, _trie_s2, _trie_s2_max);

			var _use_suffix_kind = 0;
			var _suf_len = 0;

			// Validate suffix1 body: digits/point/extras2 (digits not required)
			var _s1l = (_best_s1 >> 16);
			var _s2l = (_best_s2 >> 16);
			if (_s1l > 0) {
				var _ok_body = true;
				var _sp = _body_start;
				var _se = _posn;
				buffer_seek(_in_buff, buffer_seek_start, _sp);
				while (_sp < _se) {
					var _sb = buffer_read(_in_buff, buffer_u8);
					_sp += 1;
					if (_sb >= 48 && _sb <= 57) { continue; }
					if ((_num_dot && _sb == 46) || (_num_com && _sb == 44)) { continue; }
					if (_sb >= 0 && _sb < 256 && _num_ext2_tbl[_sb]) { continue; }
					_ok_body = false;
					break;
				}
				if (_ok_body) { _use_suffix_kind = 1; _suf_len = _s1l; }
			}

			// Validate suffix2 body: digits/point only (digits required)
			if (_use_suffix_kind == 0 && _s2l > 0 && _has_digit) {
				var _ok_body2 = true;
				var _sp2 = _body_start;
				var _se2 = _posn;
				buffer_seek(_in_buff, buffer_seek_start, _sp2);
				while (_sp2 < _se2) {
					var _sb2 = buffer_read(_in_buff, buffer_u8);
					_sp2 += 1;
					if (_sb2 >= 48 && _sb2 <= 57) { continue; }
					if ((_num_dot && _sb2 == 46) || (_num_com && _sb2 == 44)) { continue; }
					_ok_body2 = false;
					break;
				}
				if (_ok_body2) { _use_suffix_kind = 2; _suf_len = _s2l; }
			}

			var _use_style2 = ((_use_pref_kind == 2) || (_use_suffix_kind == 1));
			var _num_pat = (_use_style2 ? _patch_num2 : _patch_num1);
			var _emit_end = _posn + _suf_len;
			if (_emit_end > _pos) {
				if (_plain_start >= 0 && _plain_start < _pos) {
					__ww_textproc_ctx_append_text__(_ctx, regex__buffer_read_text_range(_in_buff, _plain_start, _pos));
					_plain_start = -1;
				}
				__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
				__ww_textproc_ctx_apply_patch__(_ctx, _num_pat);
				_ctx.span_start = _ctx.out_len;
				__ww_textproc_ctx_append_text__(_ctx, regex__buffer_read_text_range(_in_buff, _pos, _emit_end));
				__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
				__ww_textproc_ctx_apply_patch__(_ctx, _patch_def);
				_ctx.span_start = _ctx.out_len;
				_pos = _emit_end;
				continue;
			}
		}

		// --- Standalone number ranges ---
		var _rngm = __ww_udl_trie_match_best__(_in_buff, _pos, _byte_len, _trie_rng, _trie_rng_max);
		var _rngl = (_rngm >> 16);
		if (_rngl > 0) {
			if (_plain_start >= 0 && _plain_start < _pos) {
				__ww_textproc_ctx_append_text__(_ctx, regex__buffer_read_text_range(_in_buff, _plain_start, _pos));
				_plain_start = -1;
			}
			__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
			__ww_textproc_ctx_apply_patch__(_ctx, _patch_num1);
			_ctx.span_start = _ctx.out_len;
			__ww_textproc_ctx_append_text__(_ctx, regex__buffer_read_text_range(_in_buff, _pos, _pos + _rngl));
			__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
			__ww_textproc_ctx_apply_patch__(_ctx, _patch_def);
			_ctx.span_start = _ctx.out_len;
			_pos += _rngl;
			continue;
		}

		// Default: accumulate plain bytes and flush in larger slices.
		if (_plain_start < 0) { _plain_start = _pos; }
		_pos += 1;
	}

	// Flush any remaining pending plain run.
	if (_plain_start >= 0 && _plain_start < _pos) {
		__ww_textproc_ctx_append_text__(_ctx, regex__buffer_read_text_range(_in_buff, _plain_start, _pos));
		_plain_start = -1;
	}

	__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
	var _resu = __ww_textproc_ctx_finish__(_ctx);
	_resu.align_runs = [];

	buffer_resize(_in_buff, 0);
	return _resu;
}

function __ww_udl_read_u8_at__(_buff, _pos) {
	return buffer_peek(_buff, _pos, buffer_u8);
}

function __ww_udl_match_bytes_at__(_buff, _pos, _limit, _bytes, _blen) {
	if (_blen <= 0) { return false; }
	if ((_pos + _blen) > _limit) { return false; }
	buffer_seek(_buff, buffer_seek_start, _pos);
	var _i = 0;
	repeat (_blen) {
		var _b = buffer_read(_buff, buffer_u8);
		if (_b != _bytes[_i]) { return false; }
		_i += 1;
	}
	return true;
}

function __ww_udl_trie_match_best__(_buff, _pos, _limit, _trie_root, _max_len) {
	if (is_undefined(_trie_root) || _max_len <= 0) { return 0; }

	var _cap = _limit - _pos;
	if (_cap <= 0) { return 0; }
	var _n = ((_cap < _max_len) ? _cap : _max_len);

	buffer_seek(_buff, buffer_seek_start, _pos);
	var _node = _trie_root;
	var _best_len = 0;
	var _best_val = 0;
	var _i = 0;
	repeat (_n) {
		var _b = buffer_read(_buff, buffer_u8);
		_i += 1;
		var _next = _node[_b];
		if (is_undefined(_next)) {
			break;
		}
		_node = _next;
		var _term = _node[0];
		if (!is_undefined(_term)) {
			_best_len = _i;
			_best_val = _term;
		}
	}

	return ((_best_len << 16) | (_best_val & 65535));
}

