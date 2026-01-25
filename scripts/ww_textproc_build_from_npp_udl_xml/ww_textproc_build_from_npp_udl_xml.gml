#region jsDoc
/// @func    ww_textproc_build_from_npp_udl_xml(_xml_text)
/// @desc    Builds a renderer processor METHOD from a Notepad++ UDL XML file (udlVersion 2.1).
/// @param   {String} _xml_text
/// @returns {Method} processor_method(_raw_text, _default_state) -> { text, spans, align_runs }
#endregion
function ww_textproc_build_from_npp_udl_xml(_xml_text) {
	var _proc = {
		kw_sets: array_create(9),
		kw_list: array_create(9),
		kw_prefix: array_create(9),
		kw_sym_list: array_create(9),

		op_list1: [],
		op_list2: [],

		patches: {},

		comment_line_open: "",
		comment_line_continue: "",
		comment_line_close: "",
		comment_block_open: "",
		comment_block_close: "",

		// Comment tokens (byte form)
		comment_line_continue_bytes: [],
		comment_line_close_bytes: [],
		comment_block_close_bytes: [],

		delims_open: array_create(8, ""),
		delims_escape: array_create(8, ""),
		delims_close: array_create(8, ""),
		delims_close_is_eol: array_create(8, false),

		// Delimiter tokens (byte form)
		delims_escape_byte: array_create(8, -1),
		delims_close_bytes: array_create(8),
		delims_close_len: array_create(8, 0),

		fold_kind_map: {},
		fold_patch_name: array_create(4, ""),
		fold_word_map: {},
		fold_sym_list: [],
		fold_sym_index: [],

		sym_buckets: array_create(128),

		// Precomputed tries (byte-based)
		trie_symbols: undefined,
		trie_symbols_max: 0,
		trie_comments_open: undefined,
		trie_comments_open_max: 0,
		trie_delims_open: undefined,
		trie_delims_open_max: 0,
		trie_num_range: undefined,
		trie_num_range_max: 0,
		trie_num_prefix1: undefined,
		trie_num_prefix1_max: 0,
		trie_num_prefix2: undefined,
		trie_num_prefix2_max: 0,
		trie_num_suffix1: undefined,
		trie_num_suffix1_max: 0,
		trie_num_suffix2: undefined,
		trie_num_suffix2_max: 0,

		// Numbers (UDL 2.1)
		num_prefix1: [],
		num_prefix2: [],
		num_extras1: {},
		num_extras2: {},
		num_extras1_table: array_create(256, false),
		num_extras2_table: array_create(256, false),
		num_suffix1: [],
		num_suffix2: [],
		num_range: [],
		num_decimal_dot: true,
		num_decimal_comma: false,

		method: undefined,
	};
	
	var _kwnum = 1;
	repeat (8) {
		_proc.kw_sets[_kwnum] = {};
		_proc.kw_list[_kwnum] = [];
		_proc.kw_prefix[_kwnum] = false;
		_proc.kw_sym_list[_kwnum] = [];
		_kwnum += 1;
	}
	
	var _bucki = 0;
	repeat (128) {
		_proc.sym_buckets[_bucki] = [];
		_bucki += 1;
	}
	
	
	var _xml_size = string_byte_length(_xml_text);
	var _xml_buff = buffer_create(_xml_size + 1, buffer_fixed, 1);
	buffer_seek(_xml_buff, buffer_seek_start, 0);
	buffer_write(_xml_buff, buffer_text, _xml_text);

	var _buff_used = buffer_tell(_xml_buff);
	buffer_seek(_xml_buff, buffer_seek_start, 0);
	
	try {
		var _xml_root = SnapBufferReadXML(_xml_buff, 0, _buff_used, true);
	}
	catch (err) {
		var _str = "\n\nTo use `ww_textproc_build_from_npp_udl_xml` please include\nSNAP by Juju Adams: https://github.com/jujuadams/snap\n\n";
		show_debug_message(_str);
		throw _str;
	}
	
	buffer_delete(_xml_buff);

	// Find first UserLang node
	var _node_lang = undefined;

	var _node_stak = [];
	array_push(_node_stak, _xml_root);

	while (array_length(_node_stak) > 0) {
		var _stak_len = array_length(_node_stak);
		var _node_curr = _node_stak[_stak_len - 1];
		array_resize(_node_stak, _stak_len - 1);

		if ((_node_curr[$ "type"]) == "UserLang") {
			_node_lang = _node_curr;
			break;
		}

		var _child_arr = _node_curr[$ "children"] ?? [];
		var _child_len = array_length(_child_arr);

		var _child_ind = 0;
		while (_child_ind < _child_len) {
			array_push(_node_stak, _child_arr[_child_ind]);
			_child_ind += 1;
		}
	}

	if (is_undefined(_node_lang)) {
		_proc.method = method(_proc, __ww_textproc_npp_udl_core__);
		return _proc.method;
	}

	// Locate Settings / KeywordLists / Styles nodes
	var _node_sets = undefined;
	var _node_list = undefined;
	var _node_styl = undefined;

	var _lang_chi = _node_lang[$ "children"] ?? [];
	var _lang_len = array_length(_lang_chi);

	var _lang_ind = 0;
	while (_lang_ind < _lang_len) {
		var _node_sub = _lang_chi[_lang_ind];
		_lang_ind += 1;

		var _sub_type = _node_sub[$ "type"];

		if (_sub_type == "Settings") { _node_sets = _node_sub; }
		else if (_sub_type == "KeywordLists") { _node_list = _node_sub; }
		else if (_sub_type == "Styles") { _node_styl = _node_sub; }
	}

	// Parse Settings/Prefix
	if (!is_undefined(_node_sets)) {
		var _sets_chi = _node_sets[$ "children"] ?? [];
		var _sets_len = array_length(_sets_chi);

		var _sets_ind = 0;
		while (_sets_ind < _sets_len) {
			var _sets_sub = _sets_chi[_sets_ind];
			_sets_ind += 1;

			if ((_sets_sub[$ "type"]) != "Prefix") { continue; }

			var _pref_att = _sets_sub[$ "attributes"] ?? {};

			var _pref_ind = 1;
			repeat (8) {
				var _pref_key = "Keywords" + string(_pref_ind);
				var _pref_val = _pref_att[$ _pref_key];

				if (!is_undefined(_pref_val)) {
					_proc.kw_prefix[_pref_ind] = (_pref_val == "yes");
				}

				_pref_ind += 1;
			}
		}
	}

	// Parse Styles (WordsStyle) into patches
	// IMPORTANT: font style fields are always written (style/underline/strike) so spans reset properly.
	if (!is_undefined(_node_styl)) {
		var _styl_chi = _node_styl[$ "children"] ?? [];
		var _styl_len = array_length(_styl_chi);

		var _styl_ind = 0;
		while (_styl_ind < _styl_len) {
			var _word_sty = _styl_chi[_styl_ind];
			_styl_ind += 1;

			if ((_word_sty[$ "type"]) != "WordsStyle") { continue; }

			var _sty_att = _word_sty[$ "attributes"] ?? {};
			var _sty_nam = _sty_att[$ "name"];
			if (is_undefined(_sty_nam) || _sty_nam == "") { continue; }

			// colorStyle rules:
			// missing -> use both fg and bg
			// 1 -> no background
			// 2 -> no foreground
			// 0 -> use neither
			var _cs_raw = _sty_att[$ "colorStyle"];
			var _allow_fg = true;
			var _allow_bg = true;

			if (!is_undefined(_cs_raw)) {
				var _cs_val = real(_cs_raw);

				if (_cs_val == 1) { _allow_bg = false; }
				else if (_cs_val == 2) { _allow_fg = false; }
				else if (_cs_val == 0) { _allow_fg = false; _allow_bg = false; }
			}

			var _patch = {};

			if (_allow_fg) {
				var _fg_hex = _sty_att[$ "fgColor"];
				if (!is_undefined(_fg_hex) && _fg_hex != "") {
					var _fg_val = real("0x" + _fg_hex);

					var _redv = (_fg_val >> 16) & 255;
					var _grnv = (_fg_val >> 8) & 255;
					var _bluv = (_fg_val) & 255;

					_patch.color = ((_bluv << 16) | (_grnv << 8) | _redv);
				}
			}

			if (_allow_bg) {
				var _bg_hex = _sty_att[$ "bgColor"];
				if (!is_undefined(_bg_hex) && _bg_hex != "") {
					var _bg_val = real("0x" + _bg_hex);

					var _red2 = (_bg_val >> 16) & 255;
					var _grn2 = (_bg_val >> 8) & 255;
					var _blu2 = (_bg_val) & 255;

					_patch.back_color = ((_blu2 << 16) | (_grn2 << 8) | _red2);
					_patch.back_alpha = 1;
				}
			}

			// fontStyle: always emit style/underline/strike so leaving tokens resets correctly
			var _fs_val = 0;
			var _fs_raw = _sty_att[$ "fontStyle"];
			if (!is_undefined(_fs_raw)) {
				_fs_val = real(_fs_raw);
			}

			var _is_bold = ((_fs_val & 1) != 0);
			var _is_ital = ((_fs_val & 2) != 0);

			if (_is_bold && _is_ital) { _patch.style = __WW_Text_Glyph_Style.Bold_Italic; }
			else if (_is_bold) { _patch.style = __WW_Text_Glyph_Style.Bold; }
			else if (_is_ital) { _patch.style = __WW_Text_Glyph_Style.Italic; }
			else { _patch.style = __WW_Text_Glyph_Style.Regular; }

			_patch.underline = (((_fs_val & 4) != 0) ? __WW_Text_Glyph_Underline.Line : __WW_Text_Glyph_Underline.None);
			_patch.strike = (((_fs_val & 8) != 0) ? __WW_Text_Glyph_Strike.Line : __WW_Text_Glyph_Strike.None);

			_proc.patches[$ _sty_nam] = _patch;
		}
	}

	
	// Ensure DEFAULT patch exists so style resets never "stick" when DEFAULT is missing in XML.
	if (is_undefined(_proc.patches[$ "DEFAULT"])) {
		_proc.patches[$ "DEFAULT"] = {
			style: __WW_Text_Glyph_Style.Regular,
			underline: __WW_Text_Glyph_Underline.None,
			strike: __WW_Text_Glyph_Strike.None,
		};
	}
	
	// Parse KeywordLists
	if (!is_undefined(_node_list)) {
		var _list_chi = _node_list[$ "children"] ?? [];
		var _list_len = array_length(_list_chi);

		var _list_ind = 0;
		while (_list_ind < _list_len) {
			var _kw_node = _list_chi[_list_ind];
			_list_ind += 1;

			if ((_kw_node[$ "type"]) != "Keywords") { continue; }

			var _kw_att = _kw_node[$ "attributes"] ?? {};
			var _lst_nam = _kw_att[$ "name"];
			if (is_undefined(_lst_nam) || _lst_nam == "") { continue; }

			var _lst_txt = _kw_node[$ "text"] ?? "";

			// Tokenize on ASCII whitespace (ord <= 32)
			var _tokens = [];
			var _token = "";
			var _txt_len = string_length(_lst_txt);

			var _txt_ind = 1;
			while (_txt_ind <= _txt_len) {
				var _char = string_char_at(_lst_txt, _txt_ind);
				_txt_ind += 1;

				if (ord(_char) <= 32) {
					if (_token != "") {
						array_push(_tokens, _token);
						_token = "";
					}
				}
				else {
					_token += _char;
				}
			}
			if (_token != "") { array_push(_tokens, _token); }

			// Comments coded list
			if (_lst_nam == "Comments") {
				var _tok_len = array_length(_tokens);
				var _tok_ind = 0;
				while (_tok_ind < _tok_len) {
					var _ctok = _tokens[_tok_ind];
					_tok_ind += 1;

					if (_ctok == "" || string_length(_ctok) < 2) { continue; }

					var _code = string_copy(_ctok, 1, 2);
					var _valu = "";
					if (string_length(_ctok) > 2) {
						_valu = string_copy(_ctok, 3, string_length(_ctok) - 2);
					}

					if (_code == "00") { _proc.comment_line_open = _valu; }
					else if (_code == "01") { _proc.comment_line_continue = _valu; }
					else if (_code == "02") { _proc.comment_line_close = _valu; }
					else if (_code == "03") { _proc.comment_block_open = _valu; }
					else if (_code == "04") { _proc.comment_block_close = _valu; }
				}

				continue;
			}

			// Operators1 / Operators2
			if (_lst_nam == "Operators1" || _lst_nam == "Operators2") {
				var _op_dst = ((_lst_nam == "Operators2") ? _proc.op_list2 : _proc.op_list1);

				var _tok_len2 = array_length(_tokens);
				var _tok_ind2 = 0;
				while (_tok_ind2 < _tok_len2) {
					var _otok = _tokens[_tok_ind2];
					_tok_ind2 += 1;

					if (_otok == "") { continue; }
					array_push(_op_dst, _otok);
				}

				continue;
			}

			// Delimiters coded list
			if (_lst_nam == "Delimiters") {
				var _tok_len3 = array_length(_tokens);
				var _tok_ind3 = 0;
				while (_tok_ind3 < _tok_len3) {
					var _dtok = _tokens[_tok_ind3];
					_tok_ind3 += 1;

					if (_dtok == "" || string_length(_dtok) < 2) { continue; }

					var _cod2 = real(string_copy(_dtok, 1, 2));
					var _tail = "";
					if (string_length(_dtok) > 2) {
						_tail = string_copy(_dtok, 3, string_length(_dtok) - 2);
					}

					var _grp = floor(_cod2 / 3);
					var _fld = _cod2 - (_grp * 3);

					if (_grp >= 0 && _grp < 8) {
						if (_fld == 0) { _proc.delims_open[_grp] = _tail; }
						else if (_fld == 1) { _proc.delims_escape[_grp] = _tail; }
						else if (_fld == 2) {
							if (_tail == "((EOL))") {
								_proc.delims_close_is_eol[_grp] = true;
								_proc.delims_close[_grp] = "";
							}
							else {
								_proc.delims_close_is_eol[_grp] = false;
								_proc.delims_close[_grp] = _tail;
							}
						}
					}
				}

				continue;
			}

			// Numbers (UDL 2.1)
			if (string_length(_lst_nam) >= 7 && string_copy(_lst_nam, 1, 7) == "Numbers") {
				var _sufx = "";
				var _comm = string_pos(",", _lst_nam);
				if (_comm > 0) {
					_sufx = string_lower(string_trim(string_copy(_lst_nam, _comm + 1, string_length(_lst_nam) - _comm)));
				}

				if      (_sufx == "prefix1") { _proc.num_prefix1 = _tokens; }
				else if (_sufx == "prefix2") { _proc.num_prefix2 = _tokens; }
				else if (_sufx == "suffix1") { _proc.num_suffix1 = _tokens; }
				else if (_sufx == "suffix2") { _proc.num_suffix2 = _tokens; }
				else if (_sufx == "range")   { _proc.num_range = _tokens;   }
				else if (_sufx == "extras1") {
					var _exi1 = 0;
					var _exl1 = array_length(_tokens);
					while (_exi1 < _exl1) {
						var _exv1 = _tokens[_exi1];
						_exi1 += 1;

						if (_exv1 == "") { continue; }
						_proc.num_extras1[$ _exv1] = 1;
					}
				}
				else if (_sufx == "extras2") {
					var _exi2 = 0;
					var _exl2 = array_length(_tokens);
					while (_exi2 < _exl2) {
						var _exv2 = _tokens[_exi2];
						_exi2 += 1;

						if (_exv2 == "") { continue; }
						_proc.num_extras2[$ _exv2] = 1;
					}
				}
				else if (_sufx == "decimal point") {
					_proc.num_decimal_dot = true;
					_proc.num_decimal_comma = false;

					if (array_length(_tokens) > 0) {
						var _mode = string_lower(_tokens[0]);

						if (_mode == "dot") {
							_proc.num_decimal_dot = true;
							_proc.num_decimal_comma = false;
						}
						else if (_mode == "comma") {
							_proc.num_decimal_dot = false;
							_proc.num_decimal_comma = true;
						}
						else if (_mode == "both") {
							_proc.num_decimal_dot = true;
							_proc.num_decimal_comma = true;
						}
					}
				}

				continue;
			}

			// Folding lists: "Folders in <kind>, open|middle|close"
			if (string_length(_lst_nam) >= 10 && string_copy(_lst_nam, 1, 10) == "Folders in") {
				var _comm_pos = string_pos(",", _lst_nam);
				var _base = _lst_nam;

				if (_comm_pos > 0) {
					_base = string_copy(_lst_nam, 1, _comm_pos - 1);
				}

				var _kind = string_trim(string_copy(_base, 11, string_length(_base) - 10));
				if (_kind == "") { continue; }

				var _fold_ind = _proc.fold_kind_map[$ _kind];
				if (is_undefined(_fold_ind)) {
					var _next = 1;
					repeat (3) {
						if (_proc.fold_patch_name[_next] == "") {
							_fold_ind = _next;
							break;
						}
						_next += 1;
					}

					if (!is_undefined(_fold_ind)) {
						_proc.fold_kind_map[$ _kind] = _fold_ind;

						var _patch_name = "FOLDER IN " + string_upper(_kind);
						_proc.fold_patch_name[_fold_ind] = _patch_name;
					}
				}

				if (is_undefined(_fold_ind)) { continue; }

				var _tok_len4 = array_length(_tokens);
				var _tok_ind4 = 0;
				while (_tok_ind4 < _tok_len4) {
					var _ftok = _tokens[_tok_ind4];
					_tok_ind4 += 1;

					if (_ftok == "") { continue; }

					var _fst = string_char_at(_ftok, 1);
					var _is_word = ((_fst >= "A" && _fst <= "Z") || (_fst >= "a" && _fst <= "z") || (_fst == "_"));

					if (_is_word) {
						_proc.fold_word_map[$ _ftok] = _fold_ind;
					}
					else {
						array_push(_proc.fold_sym_list, _ftok);
						array_push(_proc.fold_sym_index, _fold_ind);
					}
				}

				continue;
			}

			// Keywords1..8
			if (string_length(_lst_nam) >= 9 && string_copy(_lst_nam, 1, 8) == "Keywords") {
				var _num_str = string_copy(_lst_nam, 9, string_length(_lst_nam) - 8);
				var _num_val = real(_num_str);

				if (_num_val <= 8) {
					var _set_ref = _proc.kw_sets[_num_val];
					var _arr_ref = _proc.kw_list[_num_val];
					var _sym_ref = _proc.kw_sym_list[_num_val];

					var _tok_len5 = array_length(_tokens);
					var _tok_ind5 = 0;
					while (_tok_ind5 < _tok_len5) {
						var _wtok = _tokens[_tok_ind5];
						_tok_ind5 += 1;

						if (_wtok == "") { continue; }

						var _fst2 = string_char_at(_wtok, 1);
						var _is_word2 = ((_fst2 >= "A" && _fst2 <= "Z") || (_fst2 >= "a" && _fst2 <= "z") || (_fst2 == "_"));

						if (_is_word2) {
							_set_ref[$ _wtok] = 1;
							array_push(_arr_ref, _wtok);
						}
						else {
							array_push(_sym_ref, _wtok);
						}
					}
				}

				continue;
			}
		}
	}

	// Build symbol buckets for longest-match scanning
	var _grp_ind = 1;
	repeat (8) {
		var _sym_arr = _proc.kw_sym_list[_grp_ind];
		var _sym_len = array_length(_sym_arr);

		var _sym_ind = 0;
		while (_sym_ind < _sym_len) {
			var _toke = _sym_arr[_sym_ind];
			_sym_ind += 1;

			if (_toke == "") { continue; }

			var _ordv = ord(string_char_at(_toke, 1));
			if (_ordv < 0 || _ordv >= 128) { continue; }

			var _buck = _proc.sym_buckets[_ordv];
			array_push(_buck, [ _toke, 1, _grp_ind ]);
		}

		_grp_ind += 1;
	}

	var _op_len1 = array_length(_proc.op_list1);
	var _op_ind1 = 0;
	while (_op_ind1 < _op_len1) {
		var _toke1 = _proc.op_list1[_op_ind1];
		_op_ind1 += 1;

		if (_toke1 == "") { continue; }

		var _ord1 = ord(string_char_at(_toke1, 1));
		if (_ord1 < 0 || _ord1 >= 128) { continue; }

		var _buck1 = _proc.sym_buckets[_ord1];
		array_push(_buck1, [ _toke1, 2, 1 ]);
	}

	var _op_len2 = array_length(_proc.op_list2);
	var _op_ind2 = 0;
	while (_op_ind2 < _op_len2) {
		var _toke2 = _proc.op_list2[_op_ind2];
		_op_ind2 += 1;

		if (_toke2 == "") { continue; }

		var _ord2 = ord(string_char_at(_toke2, 1));
		if (_ord2 < 0 || _ord2 >= 128) { continue; }

		var _buck2 = _proc.sym_buckets[_ord2];
		array_push(_buck2, [ _toke2, 2, 2 ]);
	}

	var _fol_len = array_length(_proc.fold_sym_list);
	var _fol_ind = 0;
	while (_fol_ind < _fol_len) {
		var _toke3 = _proc.fold_sym_list[_fol_ind];
		var _find3 = _proc.fold_sym_index[_fol_ind];
		_fol_ind += 1;

		if (_toke3 == "") { continue; }

		var _ordf = ord(string_char_at(_toke3, 1));
		if (_ordf < 0 || _ordf >= 128) { continue; }

		var _buckf = _proc.sym_buckets[_ordf];
		array_push(_buckf, [ _toke3, 3, _find3 ]);
	}

	// Build byte-based tries (preferred by core)
	_proc.trie_symbols = __ww_udl_trie_create__();
	_proc.trie_symbols_max = 0;

	_proc.trie_comments_open = __ww_udl_trie_create__();
	_proc.trie_comments_open_max = 0;

	_proc.trie_delims_open = __ww_udl_trie_create__();
	_proc.trie_delims_open_max = 0;

	_proc.trie_num_range = __ww_udl_trie_create__();
	_proc.trie_num_range_max = 0;
	_proc.trie_num_prefix1 = __ww_udl_trie_create__();
	_proc.trie_num_prefix1_max = 0;
	_proc.trie_num_prefix2 = __ww_udl_trie_create__();
	_proc.trie_num_prefix2_max = 0;
	_proc.trie_num_suffix1 = __ww_udl_trie_create__();
	_proc.trie_num_suffix1_max = 0;
	_proc.trie_num_suffix2 = __ww_udl_trie_create__();
	_proc.trie_num_suffix2_max = 0;

	// Comments open trie: 1=line, 2=block
	if (!is_undefined(_proc.comment_line_open) && _proc.comment_line_open != "") {
		_proc.trie_comments_open_max = max(_proc.trie_comments_open_max, __ww_udl_trie_add__(_proc.trie_comments_open, _proc.comment_line_open, 1));
	}
	if (!is_undefined(_proc.comment_block_open) && _proc.comment_block_open != "") {
		_proc.trie_comments_open_max = max(_proc.trie_comments_open_max, __ww_udl_trie_add__(_proc.trie_comments_open, _proc.comment_block_open, 2));
	}

	// Delimiter open trie: terminal value = group index (1..8)
	var _dg = 0;
	repeat (8) {
		var _open_tok = _proc.delims_open[_dg];
		if (!is_undefined(_open_tok) && _open_tok != "") {
			_proc.trie_delims_open_max = max(_proc.trie_delims_open_max, __ww_udl_trie_add__(_proc.trie_delims_open, _open_tok, _dg + 1));
		}
		_dg += 1;
	}

	// Number range trie: terminal marker = 1
	var _nr_len = array_length(_proc.num_range);
	var _nr_ind = 0;
	while (_nr_ind < _nr_len) {
		var _rt = _proc.num_range[_nr_ind];
		_nr_ind += 1;
		if (_rt == "") { continue; }
		_proc.trie_num_range_max = max(_proc.trie_num_range_max, __ww_udl_trie_add__(_proc.trie_num_range, _rt, 1));
	}

	// Number prefix/suffix tries: terminal marker = 1
	var _p1i = 0;
	var _p1l = array_length(_proc.num_prefix1);
	while (_p1i < _p1l) {
		var _pt1 = _proc.num_prefix1[_p1i];
		_p1i += 1;
		if (_pt1 == "") { continue; }
		_proc.trie_num_prefix1_max = max(_proc.trie_num_prefix1_max, __ww_udl_trie_add__(_proc.trie_num_prefix1, _pt1, 1));
	}

	var _p2i = 0;
	var _p2l = array_length(_proc.num_prefix2);
	while (_p2i < _p2l) {
		var _pt2 = _proc.num_prefix2[_p2i];
		_p2i += 1;
		if (_pt2 == "") { continue; }
		_proc.trie_num_prefix2_max = max(_proc.trie_num_prefix2_max, __ww_udl_trie_add__(_proc.trie_num_prefix2, _pt2, 1));
	}

	var _s1i = 0;
	var _s1l = array_length(_proc.num_suffix1);
	while (_s1i < _s1l) {
		var _st1 = _proc.num_suffix1[_s1i];
		_s1i += 1;
		if (_st1 == "") { continue; }
		_proc.trie_num_suffix1_max = max(_proc.trie_num_suffix1_max, __ww_udl_trie_add__(_proc.trie_num_suffix1, _st1, 1));
	}

	var _s2i = 0;
	var _s2l = array_length(_proc.num_suffix2);
	while (_s2i < _s2l) {
		var _st2 = _proc.num_suffix2[_s2i];
		_s2i += 1;
		if (_st2 == "") { continue; }
		_proc.trie_num_suffix2_max = max(_proc.trie_num_suffix2_max, __ww_udl_trie_add__(_proc.trie_num_suffix2, _st2, 1));
	}

	// Build extras lookup tables (ASCII byte only)
	var _ei = 0;
	var _ek = variable_struct_get_names(_proc.num_extras1);
	var _ekl = array_length(_ek);
	while (_ei < _ekl) {
		var _k = _ek[_ei];
		_ei += 1;
		if (_k == "") { continue; }
		var _ob = ord(string_char_at(_k, 1));
		if (_ob >= 0 && _ob < 256) { _proc.num_extras1_table[_ob] = true; }
	}

	var _ei2 = 0;
	var _ek2 = variable_struct_get_names(_proc.num_extras2);
	var _ekl2 = array_length(_ek2);
	while (_ei2 < _ekl2) {
		var _k2 = _ek2[_ei2];
		_ei2 += 1;
		if (_k2 == "") { continue; }
		var _ob2 = ord(string_char_at(_k2, 1));
		if (_ob2 >= 0 && _ob2 < 256) { _proc.num_extras2_table[_ob2] = true; }
	}

	// Symbols trie: encode kind+id in a single integer
	// kind: 1=keyword-symbol (group 1..8), 2=operator (1/2), 3=fold-symbol (1..3)
	var _kgrp = 1;
	repeat (8) {
		var _sym_arr2 = _proc.kw_sym_list[_kgrp];
		var _sym_len2 = array_length(_sym_arr2);
		var _sind2 = 0;
		while (_sind2 < _sym_len2) {
			var _tok2 = _sym_arr2[_sind2];
			_sind2 += 1;
			if (_tok2 == "") { continue; }
			_proc.trie_symbols_max = max(_proc.trie_symbols_max, __ww_udl_trie_add__(_proc.trie_symbols, _tok2, (1 << 8) | _kgrp));
		}
		_kgrp += 1;
	}

	var _o1 = 0;
	var _o1len = array_length(_proc.op_list1);
	while (_o1 < _o1len) {
		var _ot1 = _proc.op_list1[_o1];
		_o1 += 1;
		if (_ot1 == "") { continue; }
		_proc.trie_symbols_max = max(_proc.trie_symbols_max, __ww_udl_trie_add__(_proc.trie_symbols, _ot1, (2 << 8) | 1));
	}

	var _o2 = 0;
	var _o2len = array_length(_proc.op_list2);
	while (_o2 < _o2len) {
		var _ot2 = _proc.op_list2[_o2];
		_o2 += 1;
		if (_ot2 == "") { continue; }
		_proc.trie_symbols_max = max(_proc.trie_symbols_max, __ww_udl_trie_add__(_proc.trie_symbols, _ot2, (2 << 8) | 2));
	}

	var _fs = 0;
	var _fslen = array_length(_proc.fold_sym_list);
	while (_fs < _fslen) {
		var _ft = _proc.fold_sym_list[_fs];
		var _fid = _proc.fold_sym_index[_fs];
		_fs += 1;
		if (_ft == "") { continue; }
		_proc.trie_symbols_max = max(_proc.trie_symbols_max, __ww_udl_trie_add__(_proc.trie_symbols, _ft, (3 << 8) | _fid));
	}

	// Precompute byte arrays for comment/delimiter close tokens
	_proc.comment_line_continue_bytes = __ww_udl_string_to_bytes__(_proc.comment_line_continue);
	_proc.comment_line_close_bytes = __ww_udl_string_to_bytes__(_proc.comment_line_close);
	_proc.comment_block_close_bytes = __ww_udl_string_to_bytes__(_proc.comment_block_close);

	var _dg2 = 0;
	repeat (8) {
		var _esc = _proc.delims_escape[_dg2];
		if (!is_undefined(_esc) && _esc != "") {
			var _esc_bytes = __ww_udl_string_to_bytes__(_esc);
			_proc.delims_escape_byte[_dg2] = (_esc_bytes[0] ?? -1);
		}
		else {
			_proc.delims_escape_byte[_dg2] = -1;
		}

		var _clo = _proc.delims_close[_dg2];
		var _clo_bytes = __ww_udl_string_to_bytes__(_clo);
		_proc.delims_close_bytes[_dg2] = _clo_bytes;
		_proc.delims_close_len[_dg2] = array_length(_clo_bytes);

		_dg2 += 1;
	}

	_proc.method = method(_proc, __ww_textproc_npp_udl_core__);
	return _proc.method;
}

// -----------------------------------------------------------------------------
// UDL trie helpers (byte-based)
// Node is array[256] with optional terminal value at index 0.
// -----------------------------------------------------------------------------

function __ww_udl_trie_create__() {
	return array_create(256, undefined);
}

function __ww_udl_trie_add__(_root, _token, _term_value) {
	static __tmp = buffer_create(0, buffer_grow, 1);

	if (is_undefined(_token) || _token == "") { return 0; }

	buffer_resize(__tmp, 0);
	buffer_seek(__tmp, buffer_seek_start, 0);
	buffer_write(__tmp, buffer_text, _token);
	var _len = buffer_tell(__tmp);
	buffer_seek(__tmp, buffer_seek_start, 0);

	var _node = _root;
	var _i = 0;
	repeat (_len) {
		var _b = buffer_read(__tmp, buffer_u8);
		_i += 1;

		var _next = _node[_b];
		if (is_undefined(_next)) {
			_next = array_create(256, undefined);
			_node[_b] = _next;
		}
		_node = _next;
	}

	_node[0] = _term_value;
	buffer_resize(__tmp, 0);
	return _len;
}

function __ww_udl_string_to_bytes__(_text) {
	static __tmp = buffer_create(0, buffer_grow, 1);

	if (is_undefined(_text) || _text == "") { return []; }

	buffer_resize(__tmp, 0);
	buffer_seek(__tmp, buffer_seek_start, 0);
	buffer_write(__tmp, buffer_text, _text);
	var _len = buffer_tell(__tmp);
	buffer_seek(__tmp, buffer_seek_start, 0);

	var _out = array_create(_len);
	var _i = 0;
	repeat (_len) {
		_out[_i] = buffer_read(__tmp, buffer_u8);
		_i += 1;
	}

	buffer_resize(__tmp, 0);
	return _out;
}

