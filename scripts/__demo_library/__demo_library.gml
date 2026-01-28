#region jsDoc
/// @func    ww_inspector_lib()
/// @desc    Returns the singleton inspector metadata library.
///          Keys: constructor script name
///          Values: struct { "builder_name": [ {name,type}, ... ], ... }
/// @returns {Struct}
#endregion
ww_inspector_lib = function() {
	static __library = {
		"$$register_order": [],
	};
	return __library;
};

#region jsDoc
/// @func    demo_library_register(_constructor, _builder_defs)
/// @desc    Registers builder definitions for a constructor (no validation).
/// @param   {Function} _constructor
/// @param   {Struct}   _builder_defs
/// @returns {Undefined}
#endregion
demo_library_register = function(_constructor, _builder_defs) {
	static __library = ww_inspector_lib();

	if (!is_callable(_constructor)) {
		throw "_constructor must be the constructor itself, not a string";
	}

	var _constructor_name = script_get_name(_constructor);
	variable_struct_set(__library, _constructor_name, _builder_defs);
	array_push(__library[$ "$$register_order"], _constructor_name)
};

#region jsDoc
/// @func    __demo_library_get_parent_name__(_constructor_name)
/// @desc    Reads @@parent=... from asset tags for a constructor script name.
/// @param   {String} _constructor_name
/// @returns {String} parent_name_or_empty
#endregion
__demo_library_get_parent_name__ = function(_constructor_name) {
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
__demo_library_collect_ancestor_builder_names__ = function(_library, _constructor_name) {
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
__demo_library_filter_prefix__ = function(_names, _prefix) {
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
__demo_library_array_union_unique__ = function(_a, _b) {
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
__demo_library_name_of_comp__ = function(_comp) {
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
demo_library_validate_all = function() {
	static __library = ww_inspector_lib();

	// Cache WWCore set/get names so validations don't demand wrappers for core methods
	// (e.g. set_size) which would collide with the controller's own builders.
	static __core_set_names__ = undefined;
	static __core_get_names__ = undefined;
	// Cache WWTextRenderer set/get names so controllers that embed labels/renderers
	// aren't forced to expose the entire renderer API as wrappers.
	static __trb_set_names__ = undefined;
	static __trb_get_names__ = undefined;
	// Cache WWTextCursor set/get names; cursors are internal implementation details
	// of textfields (and will become lighter-weight with multi-cursor refactors).
	static __cursor_set_names__ = undefined;
	static __cursor_get_names__ = undefined;
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
	if (is_undefined(__cursor_set_names__) || is_undefined(__cursor_get_names__)) {
		var _cur = new WWTextCursor();
		var _cur_funcs = _cur.get_functions();
		__cursor_set_names__ = __demo_library_filter_prefix__(_cur_funcs, "set_");
		__cursor_get_names__ = __demo_library_filter_prefix__(_cur_funcs, "get_");
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
				if (array_contains(__cursor_set_names__, _n)) { continue; }
				array_push(_child_sets_filtered, _n);
			}
			var _child_gets_filtered = [];
			var _cg = array_length(_child_gets);
			for (var _j = 0; _j < _cg; _j += 1) {
				var _n2 = _child_gets[_j];
				if (array_contains(__core_get_names__, _n2)) { continue; }
				if (array_contains(__trb_get_names__, _n2)) { continue; }
				if (array_contains(__cursor_get_names__, _n2)) { continue; }
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

demo_library_register(WWCore, {
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
		{ name:"color", type:"Real" }
	],
	"set_sprite_alpha": [
		{ name:"alpha", type:"Real" }
	],
	"set_background_color": [
		{ name:"color", type:"Real" }
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
});
demo_library_register(WWSprite, {
	"set_sprite": [
		{ name:"sprite", type:"Asset.GMSprite" },
	],
});
#region Buttons
demo_library_register(WWButtonSprite, {
	"set_callback": [
		{ name:"callback", type:"Function" }
	]
});
demo_library_register(WWButtonText, {
	"set_text": [
		{ name:"text", type:"String" }
	],
	"set_text_font": [
		{ name:"font", type:"Asset.GMFont" }
	],
	"set_text_color": [
		{ name:"color", type:"Real" }
	],
	"set_text_alpha": [
		{ name:"alpha", type:"Real" }
	],
	"set_text_processor": [
		{ name:"proc_or_name", type:"Any" }
	],
	"set_color": [
		{ name:"color", type:"Real" }
	],
	"set_text_offsets": [
		{ name:"x", type:"Real" },
		{ name:"y", type:"Real" },
		{ name:"click_y", type:"Real" }
	],
	"set_sprite_to_auto_wrap": []
});
demo_library_register(WWButton, {
});
#endregion
#region Checkbox
demo_library_register(WWCheckbox, {
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
demo_library_register(WWProgressBarHorz, {
});
demo_library_register(WWProgressBarVert, {
});
demo_library_register(WWProgressBar, {
});
#endregion
#region Rendering
#endregion
#region Scrollbars
demo_library_register(WWScrollbar, {
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
demo_library_register(WWScrollbarHorz, {
});
demo_library_register(WWScrollbarVert, {
});
demo_library_register(WWScrollbarButtons, {
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
demo_library_register(WWSliderBase, {
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
demo_library_register(WWSliderHorz, {
});
demo_library_register(WWSliderHorzThumb, {
});
demo_library_register(WWSliderVert, {
});
demo_library_register(WWSliderVertThumb, {
});
demo_library_register(WWSlider, {
});
#endregion
#region Viewports
demo_library_register(WWView, {
	"set_canvas": [
		{ name:"canvas", type:"Struct.WWCore" },
	],
});
demo_library_register(WWViewScroll, {
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
demo_library_register(WWViewScrollAuto, {
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
demo_library_register(WWViewScrollAutoHorz, {
});
demo_library_register(WWViewScrollAutoVert, {
});
demo_library_register(WWViewScrollRegion, {
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
#endregion
#region Text
demo_library_register(WWTextRenderer, {
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
		{ name:"color", type:"Real" },
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
		{ name:"space_count", type:"Real" },
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
		{ name:"color", type:"Real" },
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

demo_library_register(WWLabelScrolling, {
	"set_color": [
		{ name:"color", type:"Real" },
	],
	"set_text": [
		{ name:"text", type:"String" },
	],
	"set_text_font": [
		{ name:"font", type:"Asset.GMFont" },
	],
	"set_text_color": [
		{ name:"color", type:"Real" },
	],
	"set_text_alpha": [
		{ name:"alpha", type:"Real" },
	],
});
demo_library_register(WWLabel, {
	"set_color": [
		{ name:"color", type:"Real" },
	],
	"set_text": [
		{ name:"text", type:"String" },
	],
	"set_text_color": [
		{ name:"color", type:"Real" },
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

demo_library_register(WWTextField, {
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
		{ name:"color", type:"Real" },
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
		{ name:"color", type:"Real" },
	],
	"set_highlight_color": [
		{ name:"color", type:"Real" },
	],
	"set_cursor_index": [
		{ name:"index", type:"Real" },
	],
	"set_cursor_highlight_start_index": [
		{ name:"index", type:"Real" },
	],
	"set_cursor_highlight_end_index": [
		{ name:"index", type:"Real" },
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
	"set_format_range": [
		{ name:"start_index", type:"Real" },
		{ name:"end_index", type:"Real" },
		{ name:"color_value", type:"Any" },
		{ name:"alpha_value", type:"Any" },
		{ name:"font_asset", type:"Any" },
		{ name:"style", type:"Any" },
		{ name:"size_mul", type:"Any" },
		{ name:"underline_value", type:"Any" },
	],
	"set_glyph_color_range": [
		{ name:"start_index", type:"Real" },
		{ name:"end_index", type:"Real" },
		{ name:"color", type:"Real" },
	],
	"set_glyph_alpha_range": [
		{ name:"start_index", type:"Real" },
		{ name:"end_index", type:"Real" },
		{ name:"alpha", type:"Real" },
	],
	"set_glyph_font_range": [
		{ name:"start_index", type:"Real" },
		{ name:"end_index", type:"Real" },
		{ name:"font_asset_or_minus1", type:"Any" },
	],
	"set_glyph_style_range": [
		{ name:"start_index", type:"Real" },
		{ name:"end_index", type:"Real" },
		{ name:"style", type:"Real" },
	],
	"set_glyph_size_range": [
		{ name:"start_index", type:"Real" },
		{ name:"end_index", type:"Real" },
		{ name:"size_mul", type:"Real" },
	],
	"set_glyph_underline_range": [
		{ name:"start_index", type:"Real" },
		{ name:"end_index", type:"Real" },
		{ name:"underline_value", type:"Real" },
	],
	"set_renderer": [
		{ name:"renderer_constructor", type:"Any" },
	],
});
#endregion

//demo_library_validate_all()