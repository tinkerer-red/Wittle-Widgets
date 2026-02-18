#region jsDoc
/// @func    ww_inspector_lib()
/// @desc    Returns the singleton inspector metadata library.
///          Keys: constructor script name
///          Values: struct { "builder_name": [ {name,type}, ... ], ... }
/// @returns {Struct}
#endregion
function ww_inspector_lib() {
	static __library = {
		"$$register_order": [],
		"$$examples": {},
		"$$paths": {},
	};
	return __library;
};

#region jsDoc
/// @func    demo_library_register(...)
/// @desc    Registers constructor metadata.
///          Supported signatures:
///          - demo_library_register(_constructor, _builder_defs, _examples=undefined)
///          - demo_library_register(_path, _constructor, _builder_defs, _examples=undefined)
/// @param   {String|Function} _path_or_constructor
/// @param   {Function|Struct} _constructor_or_builder_defs
/// @param   {Struct|Undefined} _builder_defs_or_examples
/// @param   {Struct|Undefined} _examples
/// @returns {Undefined}
#endregion
function demo_library_register(_path_or_constructor, _constructor_or_builder_defs, _builder_defs_or_examples=undefined, _examples=undefined) {
	static __library = ww_inspector_lib();
	
	var _path = "";
	var _constructor = undefined;
	var _builder_defs = undefined;
	var _examples_local = undefined;
	
	if (is_string(_path_or_constructor)) {
		_path = _path_or_constructor;
		_constructor = _constructor_or_builder_defs;
		_builder_defs = _builder_defs_or_examples;
		_examples_local = _examples;
	}
	else {
		_constructor = _path_or_constructor;
		_builder_defs = _constructor_or_builder_defs;
		_examples_local = _builder_defs_or_examples;
	}
	
	if (!is_struct(_builder_defs)) {
		_builder_defs = {};
	}

	if (!is_callable(_constructor)) {
		throw "_constructor must be the constructor itself, not a string";
	}

	var _constructor_name = script_get_name(_constructor);
	variable_struct_set(__library, _constructor_name, _builder_defs);
	
	var _path_norm = demo_library_path_normalize(_path);
	var _paths_lib = __library[$ "$$paths"];
	variable_struct_set(_paths_lib, _constructor_name, _path_norm);
	
	if (is_struct(_examples_local)) {
		var _examples_lib = __library[$ "$$examples"];
		variable_struct_set(_examples_lib, _constructor_name, _examples_local);
	}
	array_push(__library[$ "$$register_order"], _constructor_name)
};

#region jsDoc
/// @func    demo_library_path_normalize(_path)
/// @desc    Normalizes slash-separated tree path text.
/// @param   {String} _path
/// @returns {String}
#endregion
function demo_library_path_normalize(_path) {
	if (!is_string(_path)) { return ""; }
	var _p = string_trim(_path);
	_p = string_replace_all(_p, "\\", "/");
	while (string_pos("//", _p) != 0) {
		_p = string_replace_all(_p, "//", "/");
	}
	if (string_length(_p) > 0 && string_char_at(_p, 1) == "/") {
		_p = string_delete(_p, 1, 1);
	}
	if (string_length(_p) > 0 && string_char_at(_p, string_length(_p)) == "/") {
		_p = string_delete(_p, string_length(_p), 1);
	}
	return _p;
};

#region jsDoc
/// @func    demo_library_get_examples(_constructor_name)
/// @desc    Returns optional example definition struct for a constructor.
/// @param   {String} _constructor_name
/// @returns {Struct|Undefined}
#endregion
function demo_library_get_examples(_constructor_name) {
	static __library = ww_inspector_lib();
	var _examples_lib = __library[$ "$$examples"];
	if (!is_struct(_examples_lib)) { return undefined; }
	if (!variable_struct_exists(_examples_lib, _constructor_name)) { return undefined; }
	return variable_struct_get(_examples_lib, _constructor_name);
};

#region jsDoc
/// @func    demo_library_get_path(_constructor_name)
/// @desc    Returns optional tree path string for a constructor.
/// @param   {String} _constructor_name
/// @returns {String}
#endregion
function demo_library_get_path(_constructor_name) {
	static __library = ww_inspector_lib();
	var _paths_lib = __library[$ "$$paths"];
	if (!is_struct(_paths_lib)) { return ""; }
	if (!variable_struct_exists(_paths_lib, _constructor_name)) { return ""; }
	return variable_struct_get(_paths_lib, _constructor_name);
};

#region jsDoc
/// @func    __demo_library_get_parent_name__(_constructor_name)
/// @desc    Reads @@parent=... from asset tags for a constructor script name.
/// @param   {String} _constructor_name
/// @returns {String} parent_name_or_empty
#endregion
function __demo_library_get_parent_name__(_constructor_name) {
	var _asset = asset_get_index(_constructor_name);
	var _tags = asset_get_tags(_asset);

	var _tag_count = array_length(_tags);
	for (var _tag_index = 0; _tag_index < _tag_count; _tag_index += 1) {
		var _tag_text = _tags[_tag_index];
		if (string_pos("@@parent=", _tag_text) == 1) {
			return string_delete(_tag_text, 1, 9);
		}
	}

	return "";
};

#region jsDoc
/// @func    __demo_library_collect_ancestor_builder_names__(_library, _constructor_name)
/// @desc    Collects builder names from this constructor and all registered ancestors.
/// @param   {Struct} _library
/// @param   {String} _constructor_name
/// @returns {Array} names
#endregion
function __demo_library_collect_ancestor_builder_names__(_library, _constructor_name) {
	var _all_names = [];

	var _current_name = _constructor_name;

	while (true) {
		if (variable_struct_exists(_library, _current_name)) {
			var _defs = variable_struct_get(_library, _current_name);
			var _names = struct_get_names(_defs);

			var _count = array_length(_names);
			for (var _index = 0; _index < _count; _index += 1) {
				var _builder_name = _names[_index];
				if (!array_contains(_all_names, _builder_name)) {
					array_push(_all_names, _builder_name);
				}
			}
		}

		var _parent_name = __demo_library_get_parent_name__(_current_name);
		if (_parent_name == "") { break; }

		_current_name = _parent_name;
	}

	return _all_names;
};

#region jsDoc
/// @func    __demo_library_filter_prefix__(_names, _prefix)
/// @desc    Returns only names that start with _prefix.
/// @param   {Array<String>} _names
/// @param   {String} _prefix
/// @returns {Array<String>}
///@ignore
#endregion
function __demo_library_filter_prefix__(_names, _prefix) {
	var _out = [];
	var _count = array_length(_names);
	for (var _i = 0; _i < _count; _i += 1) {
		var _n = _names[_i];
		if (string_pos(_prefix, _n) == 1) {
			array_push(_out, _n);
		}
	}
	return _out;
};

#region jsDoc
/// @func    __demo_library_array_union_unique__(_a, _b)
/// @desc    Returns union of two arrays with unique values.
/// @param   {Array} _a
/// @param   {Array} _b
/// @returns {Array}
///@ignore
#endregion
function __demo_library_array_union_unique__(_a, _b) {
	var _out = [];
	var _ac = array_length(_a);
	for (var _i = 0; _i < _ac; _i += 1) {
		var _v = _a[_i];
		if (!array_contains(_out, _v)) { array_push(_out, _v); }
	}
	var _bc = array_length(_b);
	for (var _j = 0; _j < _bc; _j += 1) {
		var _v2 = _b[_j];
		if (!array_contains(_out, _v2)) { array_push(_out, _v2); }
	}
	return _out;
};

#region jsDoc
/// @func    __demo_library_name_of_comp__(_comp)
/// @desc    Best-effort debug name for a component instance.
/// @param   {Struct} _comp
/// @returns {String}
///@ignore
#endregion
function __demo_library_name_of_comp__(_comp) {
	if (is_undefined(_comp)) { return "<undefined>"; }
	if (variable_struct_exists(_comp, "debug_name")) {
		return variable_struct_get(_comp, "debug_name");
	}
	return "<component>";
};

#region jsDoc
/// @func    demo_library_validate_all()
/// @desc    Validates that every registered constructor has metadata for all of its
///          builder functions, allowing inheritance fallback via @@parent tags.
/// @returns {Undefined}
#endregion
function demo_library_validate_all() {
	static __library = ww_inspector_lib();

	// Cache WWCore set/get names so validations don't demand wrappers for core methods
	// (e.g. set_size) which would collide with the controller's own builders.
	static __core_set_names__ = undefined;
	static __core_get_names__ = undefined;
	// Cache WWTextRenderer set/get names so controllers that embed labels/renderers
	// aren't forced to expose the entire renderer API as wrappers.
	static __trb_set_names__ = undefined;
	static __trb_get_names__ = undefined;
	if (is_undefined(__core_set_names__) || is_undefined(__core_get_names__)) {
		var _core = new WWCore();
		var _core_funcs = _core.get_functions();
		__core_set_names__ = __demo_library_filter_prefix__(_core_funcs, "set_");
		__core_get_names__ = __demo_library_filter_prefix__(_core_funcs, "get_");
	}
	if (is_undefined(__trb_set_names__) || is_undefined(__trb_get_names__)) {
		var _trb = new WWTextRenderer();
		var _trb_funcs = _trb.get_functions();
		__trb_set_names__ = __demo_library_filter_prefix__(_trb_funcs, "set_");
		__trb_get_names__ = __demo_library_filter_prefix__(_trb_funcs, "get_");
	}
	
	//before anything else initialize core to prevent a GM bug
	//	https://github.com/YoYoGames/GameMaker-Bugs/issues/13747
	//	https://github.com/YoYoGames/GameMaker-Bugs/issues/13663
	var _constructor_names = __library[$ "$$register_order"];
	var _constructor_count = array_length(_constructor_names);

	for (var _ctor_index = 0; _ctor_index < _constructor_count; _ctor_index += 1) {
		var _constructor_name = _constructor_names[_ctor_index];
		
		var _constructor_func = asset_get_index(_constructor_name);

		var _instance = new _constructor_func();
		var _func_names = _instance.get_functions();
		var _builder_names = __demo_library_filter_prefix__(_func_names, "set_");
		var _getter_names = __demo_library_filter_prefix__(_func_names, "get_");

		var _available_names = __demo_library_collect_ancestor_builder_names__(__library, _constructor_name);

		var _missing = [];
		var _builder_count = array_length(_builder_names);

		for (var _builder_index = 0; _builder_index < _builder_count; _builder_index += 1) {
			var _builder_name = _builder_names[_builder_index];

			if (!array_contains(_available_names, _builder_name)) {
				array_push(_missing, _builder_name);
			}
		}

		if (array_length(_missing) != 0) {
			var _missing_text = string_join_ext("\n", _missing);
			throw "\n\r\n\rLibrary :: missing builder definitions ::\n\r" + _constructor_name + "\n\r\n\rFunctions not defined in demo library ::\n" + _missing_text + "\n\r";
		}

		// 1) Child wrapper coverage:
		// For each direct child, collect its non-core set_* and get_* functions and require the controller
		// exposes a wrapper with the same name.
		var _children = _instance.get_children();
		var _child_count = array_length(_children);
		for (var _child_index = 0; _child_index < _child_count; _child_index += 1) {
			var _child = _children[_child_index];
			if (is_undefined(_child)) { continue; }
			if (!is_callable(_child.get_functions)) { continue; }
			
			var _child_funcs = _child.get_functions();
			var _child_sets = __demo_library_filter_prefix__(_child_funcs, "set_");
			var _child_gets = __demo_library_filter_prefix__(_child_funcs, "get_");
			
			// Remove WWCore names to avoid collisions like set_size / get_size.
			var _child_sets_filtered = [];
			var _cs = array_length(_child_sets);
			for (var _i = 0; _i < _cs; _i += 1) {
				var _n = _child_sets[_i];
				if (array_contains(__core_set_names__, _n)) { continue; }
				if (array_contains(__trb_set_names__, _n)) { continue; }
				array_push(_child_sets_filtered, _n);
			}
			var _child_gets_filtered = [];
			var _cg = array_length(_child_gets);
			for (var _j = 0; _j < _cg; _j += 1) {
				var _n2 = _child_gets[_j];
				if (array_contains(__core_get_names__, _n2)) { continue; }
				if (array_contains(__trb_get_names__, _n2)) { continue; }
				array_push(_child_gets_filtered, _n2);
			}

			var _api_count = array_length(_child_sets_filtered) + array_length(_child_gets_filtered);
			if (_api_count == 0) { continue; }
			
			var _missing_set_wrappers = [];
			var _missing_get_wrappers = [];
			var _child_name = __demo_library_name_of_comp__(_child);
			
			var _sfc = array_length(_child_sets_filtered);
			for (var _k = 0; _k < _sfc; _k += 1) {
				var _set_api = _child_sets_filtered[_k];
				if (!array_contains(_func_names, _set_api)) {
					array_push(_missing_set_wrappers, _child_name+"."+_set_api);
				}
			}
			
			var _gfc = array_length(_child_gets_filtered);
			for (var _m = 0; _m < _gfc; _m += 1) {
				var _get_api = _child_gets_filtered[_m];
				if (!array_contains(_func_names, _get_api)) {
					array_push(_missing_get_wrappers, _child_name+"."+_get_api);
				}
			}
			
			if (array_length(_missing_set_wrappers) != 0 || array_length(_missing_get_wrappers) != 0) {
				var _msg = "\n\r\n\rLibrary :: missing child wrappers for ::\n\r" + _constructor_name + "\n\r";
				if (array_length(_missing_set_wrappers) != 0) {
					_msg += "\nSetters ::\n" + string_join_ext("\n", _missing_set_wrappers);
				}
				if (array_length(_missing_get_wrappers) != 0) {
					_msg += "\nGetters ::\n" + string_join_ext("\n", _missing_get_wrappers);
				}
				throw _msg + "\n\r";
			}
		}

		// 2) set/get symmetry:
		// For the actively validated constructor, ensure non-core set_* <-> get_* pairs exist.
		// Excludes event hookup patterns like set_on_*.
		var _missing_getters = [];
		var _missing_setters = [];
		var _set_count2 = array_length(_builder_names);
		for (var _s = 0; _s < _set_count2; _s += 1) {
			var _set_name = _builder_names[_s];
			if (array_contains(__core_set_names__, _set_name)) { continue; }
			if (string_pos("set_on_", _set_name) == 1) { continue; }
			
			var _suffix = string_delete(_set_name, 1, 4);
			var _want_get = "get_" + _suffix;
			if (!array_contains(_getter_names, _want_get)) {
				array_push(_missing_getters, _want_get);
			}
		}
		
		var _get_count2 = array_length(_getter_names);
		for (var _g = 0; _g < _get_count2; _g += 1) {
			var _get_name = _getter_names[_g];
			if (array_contains(__core_get_names__, _get_name)) { continue; }
			
			var _suffix2 = string_delete(_get_name, 1, 4);
			var _want_set = "set_" + _suffix2;
			// Only enforce get->set symmetry when the setter is part of the registered
			// builder surface for this constructor/ancestors. This avoids demanding
			// nonsense setters for query helpers like get_x_from_index().
			if (!array_contains(_available_names, _want_set)) { continue; }
			if (!array_contains(_builder_names, _want_set)) {
				array_push(_missing_setters, _want_set);
			}
		}
		
		if (array_length(_missing_getters) != 0 || array_length(_missing_setters) != 0) {
			var _msg2 = "\n\r\n\rLibrary :: missing set/get pairs ::\n\r" + _constructor_name + "\n\r";
			if (array_length(_missing_setters) != 0) {
				_msg2 += "\nSetters ::\n" + string_join_ext("\n", _missing_setters);
			}
			if (array_length(_missing_getters) != 0) {
				_msg2 += "\nGetters ::\n" + string_join_ext("\n", _missing_getters);
			}
			throw _msg2 + "\n\r";
		}
	}
};


// build library 

demo_library_register("Core", WWCore, {
	"set_position": [
		{ name:"x", type:"Real" },
		{ name:"y", type:"Real" }
	],
	"set_size": [
		{ name:"width", type:"Real" },
		{ name:"height", type:"Real" }
	],
	"set_offset": [
		{ name:"x", type:"Real" },
		{ name:"y", type:"Real" }
	],
	"set_alignment": [
		{ name:"halign", type:"Constant.HAlign" },
		{ name:"valign", type:"Constant.VAlign" }
	],
	"set_width": [
		{ name:"width", type:"Real" }
	],
	"set_height": [
		{ name:"height", type:"Real" }
	],
	"set_sprite": [
		{ name:"sprite", type:"Asset.GMSprite" }
	],
	"set_sprite_angle": [
		{ name:"angle", type:"Real" }
	],
	"set_sprite_color": [
		{ name:"color", type:"Color" }
	],
	"set_sprite_alpha": [
		{ name:"alpha", type:"Real" }
	],
	"set_background_color": [
		{ name:"color", type:"Color" }
	],
	"set_focusable": [
		{ name:"_is_focusable", type:"Bool" }
	],
	"set_enabled": [
		{ name:"is_enabled", type:"Bool" }
	],
	"set_active": [
		{ name:"is_active", type:"Bool" }
	],
	"set_debug": [
		{ name:"debug_enabled", type:"Bool" }
	],
	"set_focus": [
		{ name:"_is_focused", type:"Bool" }
	],
	"set_hover": [
		{ name:"_is_hovered", type:"Bool" }
	],
	"set_interact": [
		{ name:"_is_interacting", type:"Bool" }
	]
}, {
	"Anchor Matrix": function(_comp, _ctx) {
		_comp.clear_children();
		_comp.set_size(640, 360);
		_comp.set_background_color(make_color_rgb(10, 16, 28));
		
		var _title = new WWLabel()
			.set_text("WWCore Anchor Matrix Test")
			.set_offset(12, 8);
		_comp.add(_title);
		
		var _panel = new WWCore()
			.set_offset(12, 56)
			.set_size(420, 220)
			.set_background_color(make_color_rgb(24, 36, 58));
		_comp.add(_panel);
		
		var _w = 32;
		var _h = 24;
		var _m = 6;
		var _mid_x = -floor(_w * 0.5);
		var _mid_y = -floor(_h * 0.5);
		
		_panel.add(new WWButtonText().set_size(_w, _h).set_alignment(fa_left,   fa_top).set_offset(_m,             _m).set_text("TL").set_color(make_color_rgb(56, 86, 122)));
		_panel.add(new WWButtonText().set_size(_w, _h).set_alignment(fa_center, fa_top).set_offset(_mid_x,         _m).set_text("TC").set_color(make_color_rgb(62, 94, 132)));
		_panel.add(new WWButtonText().set_size(_w, _h).set_alignment(fa_right,  fa_top).set_offset(-(_w + _m),     _m).set_text("TR").set_color(make_color_rgb(68, 102, 142)));
		_panel.add(new WWButtonText().set_size(_w, _h).set_alignment(fa_left,   fa_middle).set_offset(_m,          _mid_y).set_text("ML").set_color(make_color_rgb(74, 110, 152)));
		_panel.add(new WWButtonText().set_size(_w, _h).set_alignment(fa_center, fa_middle).set_offset(_mid_x,      _mid_y).set_text("MC").set_color(make_color_rgb(80, 118, 162)));
		_panel.add(new WWButtonText().set_size(_w, _h).set_alignment(fa_right,  fa_middle).set_offset(-(_w + _m),  _mid_y).set_text("MR").set_color(make_color_rgb(86, 126, 172)));
		_panel.add(new WWButtonText().set_size(_w, _h).set_alignment(fa_left,   fa_bottom).set_offset(_m,         -(_h + _m)).set_text("BL").set_color(make_color_rgb(92, 134, 182)));
		_panel.add(new WWButtonText().set_size(_w, _h).set_alignment(fa_center, fa_bottom).set_offset(_mid_x,     -(_h + _m)).set_text("BC").set_color(make_color_rgb(98, 142, 192)));
		_panel.add(new WWButtonText().set_size(_w, _h).set_alignment(fa_right,  fa_bottom).set_offset(-(_w + _m), -(_h + _m)).set_text("BR").set_color(make_color_rgb(104, 150, 202)));
		
		var _lbl_w = new WWLabel().set_text("Width: 420").set_offset(456, 96);
		var _lbl_h = new WWLabel().set_text("Height: 220").set_offset(456, 156);
		
		var _slider_w = new WWSliderHorz()
			.set_offset(456, 116)
			.set_size(164, 18)
			.set_clamp_values(180, 580)
			.set_rounding(true)
			.set_value(420);
		_slider_w.__debug_enabled__ = true;
		
		var _slider_h = new WWSliderHorz()
			.set_offset(456, 176)
			.set_size(164, 18)
			.set_clamp_values(120, 300)
			.set_rounding(true)
			.set_value(220);
		_slider_h.__debug_enabled__ = true;
		
		_comp.add([_lbl_w, _slider_w, _lbl_h, _slider_h]);
		
		var _bind = {
			panel : _panel,
			lbl_w : _lbl_w,
			lbl_h : _lbl_h,
			slider_w : _slider_w,
			slider_h : _slider_h,
		};
		
		_slider_w.on_event(_slider_w.events.value_changed, method(_bind, function(_v) {
			var _new_w = floor(_v + 0.5);
			var _new_h = floor(slider_h.get_value() + 0.5);
			panel.set_size(_new_w, _new_h);
			lbl_w.set_text($"Width: {_new_w}");
		}));
		
		_slider_h.on_event(_slider_h.events.value_changed, method(_bind, function(_v) {
			var _new_h = floor(_v + 0.5);
			var _new_w = floor(slider_w.get_value() + 0.5);
			panel.set_size(_new_w, _new_h);
			lbl_h.set_text($"Height: {_new_h}");
		}));
	}
});
demo_library_register("Display/Sprites", WWSprite, {
	"set_sprite": [
		{ name:"sprite", type:"Asset.GMSprite" },
	],
});
#region Buttons
demo_library_register("Inputs/Buttons", WWButtonSprite, {
	"set_callback": [
		{ name:"callback", type:"Function" }
	]
});
demo_library_register("Inputs/Buttons", WWButtonText, {
	"set_text": [
		{ name:"text", type:"String" }
	],
	"set_text_font": [
		{ name:"font", type:"Asset.GMFont" }
	],
	"set_text_color": [
		{ name:"color", type:"Color" }
	],
	"set_text_alpha": [
		{ name:"alpha", type:"Real" }
	],
	"set_text_processor": [
		{ name:"proc_or_name", type:"Any" }
	],
	"set_color": [
		{ name:"color", type:"Color" }
	],
	"set_text_offsets": [
		{ name:"x", type:"Real" },
		{ name:"y", type:"Real" },
		{ name:"click_y", type:"Real" }
	],
	"set_sprite_to_auto_wrap": []
});
demo_library_register("Inputs/Buttons", WWButton, {
});
#endregion
#region Dropdowns
demo_library_register("Inputs/Dropdowns", WWDropdown, {
	"set_header": [
		{ name:"header_component", type:"Struct.WWCore" }
	],
	"set_header_toggle_enabled": [
		{ name:"enabled", type:"Bool" }
	],
	"set_item_builder": [
		{ name:"builder_fn", type:"Function" }
	],
	"set_text": [
		{ name:"text", type:"String" }
	],
	"set_open": [
		{ name:"is_open", type:"Bool" }
	],
	"set_value": [
		{ name:"index", type:"Real" }
	],
	"set_dropdown_array": [
		{ name:"strings_array", type:"Array<String>" }
	],
	"set_dropdown_anchor": [
		{ name:"xoff", type:"Real" },
		{ name:"yoff", type:"Real|Undefined" }
	],
	"set_dropdown_space": [
		{ name:"space", type:"Enum.WWOverlaySpace" }
	],
	"set_dropdown_host": [
		{ name:"host", type:"Struct.WWCore" }
	],
	"set_dropdown_priority": [
		{ name:"priority", type:"Real" }
	],
	"set_row_height": [
		{ name:"row_height", type:"Real" }
	],
	"set_item_enabled": [
		{ name:"index", type:"Real" },
		{ name:"is_enabled", type:"Bool" }
	]
}, {
	"Simple Menu": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_size", [220, 24]);
		_ctx.try_call(_comp, "set_text", ["Choose action..."]);
		_ctx.try_call(_comp, "set_dropdown_array", [["Open", "Save", "Close"]]);
	},
	"Long List": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_size", [260, 24]);
		_ctx.try_call(_comp, "set_row_height", [26]);
		_ctx.try_call(_comp, "set_dropdown_array", [[
			"Player Settings",
			"Graphics Settings",
			"Audio Settings",
			"Accessibility",
			"Controls"
		]]);
		_ctx.try_call(_comp, "set_open", [true]);
	},
	"Overlay Order Test": function(_comp, _ctx) {
		// Layout: one dropdown + two buttons below (left created before, right after).
		// Goal: prove overlay rendering is stable regardless of sibling insertion order.
		// Buttons intentionally overlap the open menu area but remain partially visible outside it.
		_ctx.try_call(_comp, "set_size", [180, 24]);
		_ctx.try_call(_comp, "set_text", ["Overlay order test"]);
		_ctx.try_call(_comp, "set_dropdown_array", [["First", "Second", "Third", "Fourth", "Fifth", "Sixth"]]);
		_ctx.try_call(_comp, "set_open", [true]);
		_ctx.try_call(_comp, "set_row_height", [24]);
		_ctx.try_call(_comp, "set_dropdown_priority", [4]);
		_ctx.try_call(_comp, "set_dropdown_space", [WWOverlaySpace.GLOBAL_ROOT]);
		_ctx.try_call(_comp, "set_offset", [120, 20]);
		
		var _host = _ctx.host;
		if (!is_struct(_host)) { return; }
		
		var _left_before = new WWButtonText()
			.set_size(110, 24)
			.set_text("Before")
			.set_offset(60, 78)
			.set_color(make_color_rgb(70, 48, 54));
		
		//var _idx = _host.find(_comp);
		//if (_idx >= 0) {
		//	_host.insert(_idx, _left_before); // added before dropdown
		//}
		//else {
			_host.add(_left_before);
		//}
		
		var _right_after = new WWButtonText()
			.set_size(110, 24)
			.set_text("After")
			.set_offset(250, 78)
			.set_color(make_color_rgb(48, 58, 78));
		_host.add(_right_after); // added after dropdown
	},
	"Custom Header": function(_comp, _ctx) {
		var _header = new WWInputString().set_size(240, 24).set_value("Type filter...");
		_ctx.try_call(_comp, "set_size", [240, 24]);
		_ctx.try_call(_comp, "set_header_toggle_enabled", [false]);
		_ctx.try_call(_comp, "set_header", [_header]);
		_ctx.try_call(_comp, "set_dropdown_array", [["Alpha", "Beta", "Gamma"]]);
		_ctx.try_call(_comp, "set_open", [true]);
	}
});
demo_library_register("Inputs/Dropdowns", WWDropdownBasic, {
	"set_options": [
		{ name:"options", type:"Array<String>" }
	],
	"add_option": [
		{ name:"label", type:"String" }
	]
}, {
	"Graphics Quality": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_size", [220, 24]);
		_ctx.try_call(_comp, "set_text", ["Graphics Quality"]);
		_ctx.try_call(_comp, "set_options", [["Low", "Medium", "High", "Ultra"]]);
		_ctx.try_call(_comp, "set_value", [2]);
	},
	"Language Picker": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_size", [220, 24]);
		_ctx.try_call(_comp, "set_text", ["Language"]);
		_ctx.try_call(_comp, "set_options", [["English", "Spanish", "German", "Japanese"]]);
	},
	"Difficulty": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_size", [180, 24]);
		_ctx.try_call(_comp, "set_text", ["Difficulty"]);
		_ctx.try_call(_comp, "set_options", [["Story", "Normal", "Hard"]]);
		_ctx.try_call(_comp, "set_value", [1]);
	}
});
demo_library_register("Inputs/Dropdowns", WWDropdownSelect, {
	"set_options": [
		{ name:"options", type:"Array<Any>" }
	],
	"add_option": [
		{ name:"option", type:"Any" },
		{ name:"value", type:"Any" }
	],
	"set_selected_value": [
		{ name:"value", type:"Any" }
	]
}, {
	"Priority Enum": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_size", [220, 24]);
		_ctx.try_call(_comp, "set_text", ["Priority"]);
		_ctx.try_call(_comp, "set_options", [[
			{ label:"Low", value:100 },
			{ label:"Normal", value:200 },
			{ label:"High", value:300 },
		]]);
		_ctx.try_call(_comp, "set_selected_value", [200]);
	},
	"Resolution IDs": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_size", [240, 24]);
		_ctx.try_call(_comp, "set_text", ["Resolution"]);
		_ctx.try_call(_comp, "set_options", [[
			{ label:"1280x720", value:"res_720p" },
			{ label:"1920x1080", value:"res_1080p" },
			{ label:"2560x1440", value:"res_1440p" },
		]]);
		_ctx.try_call(_comp, "set_selected_value", ["res_1080p"]);
	},
	"Status Codes": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_size", [220, 24]);
		_ctx.try_call(_comp, "set_text", ["Status"]);
		_ctx.try_call(_comp, "set_options", [[
			{ label:"Draft", value:0 },
			{ label:"Review", value:1 },
			{ label:"Published", value:2 },
		]]);
	}
});
demo_library_register("Inputs/Dropdowns", WWDropdownCombo, {
	"set_text_value": [
		{ name:"text", type:"String" }
	],
	"set_open_on_focus": [
		{ name:"enabled", type:"Bool" }
	],
	"set_commit_on_submit": [
		{ name:"enabled", type:"Bool" }
	],
	"set_options": [
		{ name:"options", type:"Array<Any>" }
	],
	"add_option": [
		{ name:"option", type:"Any" },
		{ name:"value", type:"Any" }
	]
}, {
	"Item Search": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_size", [260, 24]);
		_ctx.try_call(_comp, "set_options", [[
			{ label:"Health Potion", value:"item_hp" },
			{ label:"Mana Potion", value:"item_mp" },
			{ label:"Iron Sword", value:"item_sword_iron" },
			{ label:"Oak Shield", value:"item_shield_oak" },
		]]);
		_ctx.try_call(_comp, "set_text_value", ["Health Potion"]);
	},
	"Tag Picker": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_size", [240, 24]);
		_ctx.try_call(_comp, "set_open_on_focus", [true]);
		_ctx.try_call(_comp, "set_options", [[
			{ label:"UI", value:"ui" },
			{ label:"Gameplay", value:"gameplay" },
			{ label:"Audio", value:"audio" },
			{ label:"Rendering", value:"rendering" },
		]]);
	},
	"Command Palette": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_size", [320, 24]);
		_ctx.try_call(_comp, "set_options", [[
			{ label:"Open Project", value:"cmd_open" },
			{ label:"Save All", value:"cmd_save_all" },
			{ label:"Run Tests", value:"cmd_test" },
			{ label:"Build Release", value:"cmd_build_release" },
		]]);
		_ctx.try_call(_comp, "set_text_value", [">"]);
	}
});
demo_library_register("Inputs/Dropdowns", WWDropdownMultiSelect, {
	"set_options": [
		{ name:"labels", type:"Array<String>" }
	],
	"add_option": [
		{ name:"label", type:"String" },
		{ name:"selected", type:"Bool" }
	],
	"clear_options": [],
	"set_selected_indices": [
		{ name:"indices", type:"Array<Real>" }
	],
	"set_close_on_toggle": [
		{ name:"enabled", type:"Bool" }
	]
}, {
	"Inventory Filter": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_size", [260, 24]);
		_ctx.try_call(_comp, "set_options", [["Weapons", "Armor", "Consumables", "Quest"]]);
		_ctx.try_call(_comp, "set_selected_indices", [[0, 2]]);
	},
	"Permissions": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_size", [260, 24]);
		_ctx.try_call(_comp, "set_options", [["Read", "Write", "Execute", "Delete"]]);
		_ctx.try_call(_comp, "set_selected_indices", [[0, 1]]);
	},
	"Notification Channels": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_size", [260, 24]);
		_ctx.try_call(_comp, "set_options", [["Email", "SMS", "In-App", "Push"]]);
		_ctx.try_call(_comp, "set_selected_indices", [[2, 3]]);
	}
});
demo_library_register("Inputs/Dropdowns", WWDropdownRich, {
	"set_rich_array": [
		{ name:"items", type:"Array<Any>" }
	],
	"add_rich_item": [
		{ name:"item", type:"Any" },
		{ name:"value", type:"Any" },
		{ name:"component", type:"Struct.WWCore" }
	],
	"clear_rich_items": []
}, {
	"Status With Icons": function(_comp, _ctx) {
		var _ok = new WWButtonText().set_text("[OK] Connected");
		var _warn = new WWButtonText().set_text("[!] Degraded");
		var _err = new WWButtonText().set_text("[X] Offline");
		_ctx.try_call(_comp, "set_size", [260, 24]);
		_ctx.try_call(_comp, "clear_rich_items", []);
		_ctx.try_call(_comp, "add_rich_item", [{ label:"Connected", value:"ok", component:_ok }]);
		_ctx.try_call(_comp, "add_rich_item", [{ label:"Degraded", value:"warn", component:_warn }]);
		_ctx.try_call(_comp, "add_rich_item", [{ label:"Offline", value:"err", component:_err }]);
	},
	"Asset Presets": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_size", [280, 24]);
		_ctx.try_call(_comp, "set_rich_array", [[
			{ label:"Default Theme", value:"theme_default" },
			{ label:"High Contrast", value:"theme_hc" },
			{ label:"Retro CRT", value:"theme_crt" },
		]]);
		_ctx.try_call(_comp, "set_value", [1]);
	},
	"Build Profiles": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_size", [260, 24]);
		_ctx.try_call(_comp, "set_rich_array", [[
			{ label:"Debug Local", value:{ mode:"debug", target:"local" } },
			{ label:"Staging Cloud", value:{ mode:"release", target:"staging" } },
			{ label:"Production", value:{ mode:"release", target:"prod" } },
		]]);
	}
});
demo_library_register("Inputs/Dropdowns", WWDropdownDateTime, {
	"set_mode": [
		{ name:"mode", type:"String" }
	],
	"refresh_options": []
}, {
	"Due Date": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_size", [260, 24]);
		_ctx.try_call(_comp, "set_mode", ["date"]);
		_ctx.try_call(_comp, "set_text", ["Due date"]);
	},
	"Reminder Time": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_size", [260, 24]);
		_ctx.try_call(_comp, "set_mode", ["time"]);
		_ctx.try_call(_comp, "set_text", ["Reminder time"]);
	},
	"Schedule Slot": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_size", [280, 24]);
		_ctx.try_call(_comp, "set_mode", ["datetime"]);
		_ctx.try_call(_comp, "set_text", ["Meeting slot"]);
	}
});
#endregion
#region Checkbox
demo_library_register("Inputs/Selection", WWCheckbox, {
	"set_checkbox_sprites": [
		{ name:"checked_sprite", type:"Asset.GMSprite" },
		{ name:"unchecked_sprite", type:"Asset.GMSprite" }
	],
	"set_value": [
		{ name:"is_checked", type:"Bool" }
	],
	"set_checked": [
		{ name:"is_checked", type:"Bool" }
	],
	"set_callback": [
		{ name:"callback", type:"Function" }
	]
});
#endregion
#region Progress Bars
demo_library_register("Display/Progress", WWProgressBarHorz, {
});
demo_library_register("Display/Progress", WWProgressBarVert, {
});
demo_library_register("Display/Progress", WWProgressBar, {
});
#endregion
#region Rendering
#endregion
#region Scrollbars
demo_library_register("Inputs/Scrollbars", WWScrollbar, {
	"set_scroll_range": [
		{ name:"min", type:"Real" },
		{ name:"max", type:"Real" }
	],
	"set_scroll_value": [
		{ name:"value", type:"Real" }
	],
	"set_scroll_step": [
		{ name:"step", type:"Real" }
	],
	"set_canvas_size": [
		{ name:"size", type:"Real" }
	],
	"set_coverage_size": [
		{ name:"size", type:"Real" }
	],
	"set_smooth_scrolling": [
		{ name:"enabled", type:"Bool" }
	],
	"set_thumb": [
		{ name:"thumb", type:"Struct.WWSliderThumb" }
	],
	"set_on_change": [
		{ name:"callback", type:"Function" }
	]
});
demo_library_register("Inputs/Scrollbars", WWScrollbarHorz, {
});
demo_library_register("Inputs/Scrollbars", WWScrollbarVert, {
});
demo_library_register("Inputs/Scrollbars", WWScrollbarButtons, {
	"set_size": [
		{ name:"width", type:"Real" },
		{ name:"height", type:"Real" }
	],
	"set_canvas_size": [
		{ name:"height", type:"Real" }
	],
	"set_coverage_size": [
		{ name:"height", type:"Real" }
	],
	"set_callback": [
		{ name:"callback", type:"Function" }
	],
	"set_value": [
		{ name:"value", type:"Real" }
	],
	"set_normalized_value": [
		{ name:"value", type:"Real" }
	],
	"set_clamp_values": [
		{ name:"min", type:"Real" },
		{ name:"max", type:"Real" }
	],
	"set_rounding": [
		{ name:"round", type:"Bool" }
	],
	"set_lerp_target": [
		{ name:"lerp_target", type:"Real" }
	],
	"set_inverted": [
		{ name:"invert", type:"Bool" }
	],
	"set_bar_size": [
		{ name:"left", type:"Real" },
		{ name:"top", type:"Real" },
		{ name:"right", type:"Real" },
		{ name:"bottom", type:"Real" }
	],
	"set_background_size": [
		{ name:"left", type:"Real" },
		{ name:"top", type:"Real" },
		{ name:"right", type:"Real" },
		{ name:"bottom", type:"Real" }
	]
});
#endregion
#region Sliders
demo_library_register("Inputs/Sliders", WWSliderBase, {
	"set_size": [
		{ name:"width", type:"Real" },
		{ name:"height", type:"Real" }
	],
	"set_value": [
		{ name:"value", type:"Real" }
	],
	"set_normalized_value": [
		{ name:"value", type:"Real" }
	],
	"set_clamp_values": [
		{ name:"min", type:"Real" },
		{ name:"max", type:"Real" }
	],
	"set_rounding": [
		{ name:"round", type:"Bool" }
	],
	"set_lerp_target": [
		{ name:"lerp_target", type:"Real" }
	],
	"set_inverted": [
		{ name:"invert", type:"Bool" }
	],
	"set_bar_size": [
		{ name:"left", type:"Real" },
		{ name:"top", type:"Real" },
		{ name:"right", type:"Real" },
		{ name:"bottom", type:"Real" }
	],
	"set_background_size": [
		{ name:"left", type:"Real" },
		{ name:"top", type:"Real" },
		{ name:"right", type:"Real" },
		{ name:"bottom", type:"Real" }
	]
});
demo_library_register("Inputs/Sliders", WWSliderHorz, {
});
demo_library_register("Inputs/Sliders", WWSliderHorzThumb, {
});
demo_library_register("Inputs/Sliders", WWSliderVert, {
});
demo_library_register("Inputs/Sliders", WWSliderVertThumb, {
});
demo_library_register("Inputs/Sliders", WWSlider, {
});
#endregion
#region Viewports
demo_library_register("Layout/Views", WWView, {
	"set_canvas": [
		{ name:"canvas", type:"Struct.WWCore" },
	],
});
demo_library_register("Layout/Views", WWViewScroll, {
	"set_canvas": [
		{ name:"canvas", type:"Struct.WWCore" },
	],
	"set_size": [
		{ name:"width", type:"Real" },
		{ name:"height", type:"Real" },
	],
	"set_scroll_offset": [
		{ name:"xoff", type:"Real" },
		{ name:"yoff", type:"Real" },
	],
	"set_content_size": [
		{ name:"width", type:"Real" },
		{ name:"height", type:"Real" },
	],
	"set_scroll_max": [
		{ name:"max_x", type:"Real" },
		{ name:"max_y", type:"Real" },
	],
});
demo_library_register("Layout/Views", WWViewScrollAuto, {
	"set_scroll_speeds": [
		{ name:"hspeed", type:"Real" },
		{ name:"vspeed", type:"Real" },
	],
	"set_scroll_looping": [
		{ name:"x_loop", type:"Bool" },
		{ name:"y_loop", type:"Bool" },
	],
	"set_scroll_pause": [
		{ name:"paused", type:"Bool" },
	],
	"set_scroll_offsets": [
		{ name:"xoff", type:"Real" },
		{ name:"yoff", type:"Real" },
	],
});
demo_library_register("Layout/Views", WWViewScrollAutoHorz, {
});
demo_library_register("Layout/Views", WWViewScrollAutoVert, {
});
demo_library_register("Layout/Views", WWViewScrollRegion, {
	"set_region_mode": [
		{ name:"enabled", type:"Bool" },
	],
	"set_scrollbars_enabled": [
		{ name:"horz_enabled", type:"Bool" },
		{ name:"vert_enabled", type:"Bool" },
	],
	"set_scrollbars_auto_hide": [
		{ name:"horz_auto", type:"Bool" },
		{ name:"vert_auto", type:"Bool" },
	],
	"set_scrollbar_thickness": [
		{ name:"thickness", type:"Real" },
	],
	"set_wheel_step": [
		{ name:"pixels_per_wheel", type:"Real" },
	],
	"set_smooth_scrolling": [
		{ name:"smooth", type:"Bool" },
	],
	"set_canvas": [
		{ name:"canvas", type:"Struct.WWCore" },
	],
	"set_canvas_size": [
		{ name:"width", type:"Real" },
		{ name:"height", type:"Real" },
	],
	"set_canvas_size_from_children": [],
	"set_size": [
		{ name:"width", type:"Real" },
		{ name:"height", type:"Real" },
	],
	"set_viewport_size": [
		{ name:"width", type:"Real" },
		{ name:"height", type:"Real" },
	],
	"set_scroll_offset": [
		{ name:"xoff", type:"Real" },
		{ name:"yoff", type:"Real" },
	],
	"set_scroll_max": [
		{ name:"max_x", type:"Real" },
		{ name:"max_y", type:"Real" },
	],
	"set_content_size": [
		{ name:"width", type:"Real" },
		{ name:"height", type:"Real" },
	],
	"set_wheel_scroll_enabled": [
		{ name:"horz_enabled", type:"Bool" },
		{ name:"vert_enabled", type:"Bool" },
	],
});

demo_library_register("Layout/Windows", WWWindow, {
	"set_title": [
		{ name:"title", type:"String" },
	],
	"set_header_height": [
		{ name:"height", type:"Real" },
	],
	"set_draggable": [
		{ name:"enabled", type:"Bool" },
	],
	"set_close_visible": [
		{ name:"visible", type:"Bool" },
	],
	"set_close_text": [
		{ name:"text", type:"String" },
	],
	"set_open": [
		{ name:"is_open", type:"Bool" },
	],
	"set_content": [
		{ name:"comp", type:"Struct.WWCore" },
	],
	"set_scrollbars_enabled": [
		{ name:"horz", type:"Bool" },
		{ name:"vert", type:"Bool" },
	],
	"set_scrollbars_auto_hide": [
		{ name:"horz", type:"Bool" },
		{ name:"vert", type:"Bool" },
	],
	"set_scrollbar_thickness": [
		{ name:"thickness", type:"Real" },
	],
	"set_wheel_scroll_enabled": [
		{ name:"horz", type:"Bool" },
		{ name:"vert", type:"Bool" },
	],
	"set_smooth_scrolling": [
		{ name:"smooth", type:"Bool" },
	]
}, {
	"Basic Dialog": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_title", ["Properties"]);
		_ctx.try_call(_comp, "set_size", [320, 220]);
		_ctx.try_call(_comp, "set_offset", [140, 70]);
		_ctx.try_call(_comp, "set_header_height", [28]);
		_ctx.try_call(_comp, "set_close_text", ["X"]);
		
		_comp.clear_children();
		_comp.add(new WWLabel().set_text("Name"));
		_comp.add(new WWInputString().set_size(200, 24).set_offset(0, 18));
		_comp.add(new WWLabel().set_text("Notes").set_offset(0, 50));
		_comp.add(new WWInputString().set_size(240, 24).set_offset(0, 68));
		_comp.add(new WWButtonText().set_text("Apply").set_size(90, 24).set_offset(0, 108));
		_comp.add(new WWButtonText().set_text("Cancel").set_size(90, 24).set_offset(100, 108));
	},
	"Scrollable Content": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_title", ["Event Log"]);
		_ctx.try_call(_comp, "set_size", [360, 260]);
		_ctx.try_call(_comp, "set_offset", [120, 48]);
		_ctx.try_call(_comp, "set_scrollbars_auto_hide", [true, true]);
		_ctx.try_call(_comp, "set_smooth_scrolling", [true]);
		_comp.clear_children();
		
		var _y = 0;
		var _i = 0; repeat(20) {
			_comp.add(
				new WWButtonText()
					.set_size(300, 22)
					.set_offset(0, _y)
					.set_text($"Log Entry #{_i + 1}")
			);
			_y += 24;
		_i += 1;}
	},
	"Overlay Priority": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_title", ["Primary"]);
		_ctx.try_call(_comp, "set_size", [280, 180]);
		_ctx.try_call(_comp, "set_offset", [130, 90]);
		_ctx.try_call(_comp, "set_overlay_priority", [0]);
		_ctx.try_call(_comp, "set_overlay_always_on_top", [false]);
		_comp.clear_children();
		_comp.add(new WWLabel().set_text("Try dragging both windows.").set_offset(0, 0));
		_comp.add(new WWLabel().set_text("Secondary is always-on-top.").set_offset(0, 18));
		
		var _host = _ctx.host;
		if (!is_struct(_host)) { return; }
		
		var _secondary = new WWWindow()
			.set_title("Pinned")
			.set_size(220, 140)
			.set_offset(340, 130)
			.set_overlay_priority(5)
			.set_overlay_always_on_top(true);
		_secondary.add(new WWLabel().set_text("Always on top").set_offset(0, 0));
		_secondary.add(new WWButtonText().set_text("Close").set_size(90, 24).set_offset(0, 28).set_callback(function(){ _host.remove(_secondary); }));
		_host.add(_secondary);
	}
});
demo_library_register("Layout/Windows", WWWindowContext, {
	"set_auto_close_outside": [
		{ name:"enabled", type:"Bool" },
	],
	"set_auto_close_escape": [
		{ name:"enabled", type:"Bool" },
	],
	"set_anchor": [
		{ name:"host", type:"Struct.WWCore" },
		{ name:"xoff", type:"Real" },
		{ name:"yoff", type:"Real" },
	],
	"set_keep_on_screen": [
		{ name:"enabled", type:"Bool" },
	],
	"open_at": [
		{ name:"x", type:"Real" },
		{ name:"y", type:"Real" },
	],
	"open_anchored": [
		{ name:"host", type:"Struct.WWCore" },
		{ name:"xoff", type:"Real" },
		{ name:"yoff", type:"Real" },
	],
	"close_context": []
}, {
	"Auto-Close Popup": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_title", ["Context"]);
		_ctx.try_call(_comp, "set_size", [260, 120]);
		_ctx.try_call(_comp, "set_auto_close_outside", [true]);
		_ctx.try_call(_comp, "set_auto_close_escape", [true]);
		_comp.clear_children();
		_comp.add(new WWLabel().set_text("Click outside to close.").set_offset(0, 0));
		_comp.add(
			new WWButtonText()
				.set_text("Close")
				.set_size(90, 24)
				.set_offset(0, 26)
				.set_callback(method({ popup:_comp }, function() { popup.close_context(); }))
		);
		_comp.open_at(220, 120);
	},
	"Anchored To Button": function(_comp, _ctx) {
		var _host = _ctx.host;
		if (!is_struct(_host)) { return; }
		
		var _btn = new WWButtonText()
			.set_text("Open Context")
			.set_size(130, 24)
			.set_offset(120, 80);
		_host.add(_btn);
		
		_ctx.try_call(_comp, "set_title", ["Quick Actions"]);
		_ctx.try_call(_comp, "set_size", [220, 120]);
		_comp.clear_children();
		_comp.add(new WWButtonText().set_text("Rename").set_size(180, 22).set_offset(0, 0));
		_comp.add(new WWButtonText().set_text("Duplicate").set_size(180, 22).set_offset(0, 24));
		_comp.add(new WWButtonText().set_text("Delete").set_size(180, 22).set_offset(0, 48));
		
		_btn.set_callback(method({ popup:_comp, host_btn:_btn }, function() {
			popup.open_anchored(host_btn, 0, 4);
		}));
	}
});
demo_library_register("Layout/Windows", WWConfirmDialog, {
	"set_message": [
		{ name:"text", type:"String" },
	],
	"set_confirm_text": [
		{ name:"text", type:"String" },
	],
	"set_cancel_text": [
		{ name:"text", type:"String" },
	],
	"set_show_cancel": [
		{ name:"enabled", type:"Bool" },
	],
	"open_dialog": []
}, {
	"Delete Confirmation": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_title", ["Delete File"]);
		_ctx.try_call(_comp, "set_size", [340, 150]);
		_ctx.try_call(_comp, "set_offset", [180, 100]);
		_ctx.try_call(_comp, "set_message", ["Delete 'player_save_03.json'?"]);
		_ctx.try_call(_comp, "set_confirm_text", ["Delete"]);
		_ctx.try_call(_comp, "set_cancel_text", ["Cancel"]);
		_ctx.try_call(_comp, "set_show_cancel", [true]);
		_ctx.try_call(_comp, "open_dialog", []);
	},
	"Simple Acknowledge": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_title", ["Notice"]);
		_ctx.try_call(_comp, "set_size", [320, 130]);
		_ctx.try_call(_comp, "set_offset", [200, 120]);
		_ctx.try_call(_comp, "set_message", ["Settings applied successfully."]);
		_ctx.try_call(_comp, "set_confirm_text", ["OK"]);
		_ctx.try_call(_comp, "set_show_cancel", [false]);
		_ctx.try_call(_comp, "open_dialog", []);
	}
});
demo_library_register("Layout/Windows", WWInputDialog, {
	"set_prompt": [
		{ name:"text", type:"String" },
	],
	"set_value": [
		{ name:"value", type:"String" },
	],
	"set_placeholder": [
		{ name:"text", type:"String" },
	],
	"submit": []
}, {
	"Rename Asset": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_title", ["Rename"]);
		_ctx.try_call(_comp, "set_size", [360, 180]);
		_ctx.try_call(_comp, "set_offset", [180, 90]);
		_ctx.try_call(_comp, "set_prompt", ["Enter a new asset name"]);
		_ctx.try_call(_comp, "set_placeholder", ["my_asset_name"]);
		_ctx.try_call(_comp, "set_value", ["player_controller"]);
		_ctx.try_call(_comp, "open_dialog", []);
	},
	"Create Folder": function(_comp, _ctx) {
		_ctx.try_call(_comp, "set_title", ["New Folder"]);
		_ctx.try_call(_comp, "set_size", [340, 170]);
		_ctx.try_call(_comp, "set_offset", [220, 120]);
		_ctx.try_call(_comp, "set_prompt", ["Folder name"]);
		_ctx.try_call(_comp, "set_placeholder", ["Untitled Folder"]);
		_ctx.try_call(_comp, "set_value", [""]);
		_ctx.try_call(_comp, "open_dialog", []);
	}
});
#endregion
#region Text
demo_library_register("Text", WWTextRenderer, {
	"set_caption": [
		{ name:"text", type:"String" },
	],
	"set_text_processor": [
		{ name:"processor_fn", type:"Function" },
	],
	"set_font": [
		{ name:"font", type:"Asset.GMFont" },
	],
	"set_font_fallbacks": [
		{ name:"fonts", type:"Array<Asset.GMFont>" },
	],
	"set_text_color": [
		{ name:"color", type:"Color" },
	],
	"set_text_alpha": [
		{ name:"alpha", type:"Real" },
	],
	"set_wrap_enabled": [
		{ name:"should_wrap", type:"Bool" },
	],
	"set_line_sep": [
		{ name:"line_sep", type:"Real" },
	],
	"set_tab_size_spaces": [
		{ name:"space_count", type:"Int" },
	],
	"set_tab_use_stops": [
		{ name:"use_stops", type:"Bool" },
	],
	"set_formatting_enabled": [
		{ name:"enabled", type:"Bool" },
	],
	"set_whitespace_visible": [
		{ name:"visible", type:"Bool" },
	],
	"set_whitespace_markers": [
		{ name:"space_marker", type:"String" },
		{ name:"tab_marker", type:"String" },
	],
	"set_whitespace_color": [
		{ name:"color", type:"Color" },
		{ name:"alpha", type:"Real" },
	],
	"set_whitespace_alpha": [
		{ name:"alpha", type:"Real" },
	],
	"set_underline_offset": [
		{ name:"offset", type:"Real" },
	],
	"set_underline_thickness": [
		{ name:"thickness", type:"Real" },
	],
	"set_underline_sprites": [
		{ name:"sprite_white", type:"Asset.GMSprite" },
		{ name:"sprite_warning", type:"Asset.GMSprite" },
		{ name:"sprite_error", type:"Asset.GMSprite" },
	],
	"set_strike_offset": [
		{ name:"offset", type:"Real" },
	],
	"set_strike_thickness": [
		{ name:"thickness", type:"Real" },
	],
	"set_strike_sprites": [
		{ name:"sprite_white", type:"Asset.GMSprite" },
		{ name:"sprite_warning", type:"Asset.GMSprite" },
		{ name:"sprite_error", type:"Asset.GMSprite" },
	],
});

demo_library_register("Text/Labels", WWLabelScrolling, {
	"set_color": [
		{ name:"color", type:"Color" },
	],
	"set_text": [
		{ name:"text", type:"String" },
	],
	"set_text_font": [
		{ name:"font", type:"Asset.GMFont" },
	],
	"set_text_color": [
		{ name:"color", type:"Color" },
	],
	"set_text_alpha": [
		{ name:"alpha", type:"Real" },
	],
});
demo_library_register("Text/Labels", WWLabel, {
	"set_color": [
		{ name:"color", type:"Color" },
	],
	"set_text": [
		{ name:"text", type:"String" },
	],
	"set_text_color": [
		{ name:"color", type:"Color" },
	],
	"set_text_font": [
		{ name:"font", type:"Asset.GMFont" },
	],
	"set_text_alpha": [
		{ name:"alpha", type:"Real" },
	],
	"set_text_processor": [
		{ name:"proc_or_name", type:"Any" },
	],
});

demo_library_register("Text/Inputs", WWTextField, {
	"set_text": [
		{ name:"text", type:"String" },
	],
	"set_caption": [
		{ name:"text", type:"String" },
	],
	"set_text_font": [
		{ name:"font", type:"Asset.GMFont" },
	],
	"set_text_color": [
		{ name:"color", type:"Color" },
	],
	"set_text_alpha": [
		{ name:"alpha", type:"Real" },
	],
	"set_wrap_enabled": [
		{ name:"should_wrap", type:"Bool" },
	],
	"set_line_sep": [
		{ name:"line_sep_pixels", type:"Real" },
	],
	"set_read_only": [
		{ name:"is_read_only", type:"Bool" },
	],
	"set_allowed_char": [
		{ name:"allowed_char", type:"Any" },
	],
	"set_keyboard_type": [
		{ name:"keyboard_type", type:"Any" },
	],
	"set_enter_submits_text": [
		{ name:"enabled", type:"Bool" },
	],
	"set_tab_exits_text": [
		{ name:"enabled", type:"Bool" },
	],
	"set_cursor_color": [
		{ name:"color", type:"Color" },
	],
	"set_highlight_color": [
		{ name:"color", type:"Color" },
	],
	"set_cursor_index": [
		{ name:"index", type:"Int" },
	],
	"set_cursor_highlight_start_index": [
		{ name:"index", type:"Int" },
	],
	"set_cursor_highlight_end_index": [
		{ name:"index", type:"Int" },
	],
	"set_cursor_col": [],
	"set_cursor_line": [],
	"set_cursor_highlight_start_line": [],
	"set_cursor_highlight_start_col": [],
	"set_cursor_highlight_end_line": [],
	"set_cursor_highlight_end_col": [],
	"set_cursor_xy": [
		{ name:"x", type:"Real" },
		{ name:"y", type:"Real" },
	],
	"set_text_processor": [
		{ name:"processor_fn", type:"Function" },
	],
	"set_renderer": [
		{ name:"renderer_constructor", type:"Any" },
	],
});
#endregion

//demo_library_validate_all()
