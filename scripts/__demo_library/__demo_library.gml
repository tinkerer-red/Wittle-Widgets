#region jsDoc
/// @func    ww_inspector_lib()
/// @desc    Returns the singleton inspector metadata library.
///          Keys: constructor script name
///          Values: struct { "builder_name": [ {name,type}, ... ], ... }
/// @returns {Struct}
#endregion
ww_inspector_lib = function() {
	static __library = {};
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
/// @func    demo_library_validate_all()
/// @desc    Validates that every registered constructor has metadata for all of its
///          builder functions, allowing inheritance fallback via @@parent tags.
/// @returns {Undefined}
#endregion
demo_library_validate_all = function() {
	static __library = ww_inspector_lib();
	
	//before anything else initialize core to prevent a GM bug
	//	https://github.com/YoYoGames/GameMaker-Bugs/issues/13747
	//	https://github.com/YoYoGames/GameMaker-Bugs/issues/13663
	var _last_resort = new WWCore();

	var _constructor_names = struct_get_names(__library);
	var _constructor_count = array_length(_constructor_names);

	var _errors = [];

	for (var _ctor_index = 0; _ctor_index < _constructor_count; _ctor_index += 1) {
		var _constructor_name = _constructor_names[_ctor_index];

		var _constructor_func = asset_get_index(_constructor_name);
		

		var _instance = new _constructor_func();
		var _builder_names = _instance.get_builder_functions();

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
			var _error_text = "library :: " + _constructor_name + " :: missing builder definitions ::\n" + _missing_text;
			array_push(_errors, _error_text);
		}
	}

	if (array_length(_errors) != 0) {
		throw string_join_ext("\n\n", _errors);
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
	"set_scrollbars": [
		{ name:"horz", type:"Struct.WWScrollbarHorz" },
		{ name:"vert", type:"Struct.WWScrollbarVert" },
	],
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
});
#endregion
#region Text
demo_library_register(WWLabelScrolling, {
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
#endregion

demo_library_validate_all()