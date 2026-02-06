/// obj_ww_demo :: User Event 15
/// Workbench-only demo.

function __ww_demo_paint_color(_paint, _fallback) {
	if (_paint == undefined) return _fallback;
	var _c = variable_struct_get(_paint, "color");
	return (_c != undefined) ? _c : _fallback;
}

function __ww_demo_theme_palette() {
	var _t = wwThemeGet();
	var _meta = (is_struct(_t)) ? variable_struct_get(_t, "meta") : undefined;
	var _mode = (_meta != undefined) ? variable_struct_get(_meta, "mode") : "";
	if (_mode == "") {
		_t = wwThemeSet(wwThemeDark());
	}
	var _colors = (is_struct(_t)) ? variable_struct_get(_t, "colors") : undefined;
	var _app = (_colors != undefined) ? variable_struct_get(_colors, "app") : undefined;
	var _surface = (_colors != undefined) ? variable_struct_get(_colors, "surface") : undefined;
	var txt = (_colors != undefined) ? variable_struct_get(_colors, "text") : undefined;

	return {
		page: __ww_demo_paint_color((_app != undefined) ? variable_struct_get(_app, "bg") : undefined, make_color_rgb(16, 16, 18)),
		panel: __ww_demo_paint_color((_surface != undefined) ? variable_struct_get(_surface, "panel") : undefined, make_color_rgb(32, 32, 36)),
		panel_alt: __ww_demo_paint_color((_surface != undefined) ? variable_struct_get(_surface, "panel_alt") : undefined, make_color_rgb(40, 40, 46)),
		header: __ww_demo_paint_color((_surface != undefined) ? variable_struct_get(_surface, "panel_alt") : undefined, make_color_rgb(26, 26, 30)),
		text: __ww_demo_paint_color((txt != undefined) ? variable_struct_get(txt, "primary") : undefined, make_color_rgb(230, 230, 235)),
		text_dim: __ww_demo_paint_color((txt != undefined) ? variable_struct_get(txt, "dim") : undefined, make_color_rgb(170, 170, 180)),
	};
}

function __ww_workbench_nav_run() {
	main.select_ctor(ctor);
}

function __ww_workbench_search_run(_data) {
	main.build_nav_list(input.get_value());
}

function __ww_workbench_validate() {
	demo_library_validate_all();
	show_debug_message("Demo library validated OK.");
}

function __ww_workbench_format_arg(_value, _type) {
	if (_type == "String") {
		var _s = string(_value);
		_s = string_replace_all(_s, "\\", "\\\\");
		_s = string_replace_all(_s, "\"", "\\\"");
		_s = string_replace_all(_s, "\n", "\\n");
		_s = string_replace_all(_s, "\r", "\\r");
		_s = string_replace_all(_s, "\t", "\\t");
		return "\"" + _s + "\"";
	}
	if (_type == "Bool") {
		return (_value) ? "true" : "false";
	}
	if (is_string(_value) && _type != "Real") {
		return _value;
	}
	return string(_value);
}

function __ww_workbench_set_call(_builder_name, _args) {
	for (var _i = 0; _i < array_length(state.calls); _i += 1) {
		if (state.calls[_i].name == _builder_name) {
			state.calls[_i].args = _args;
			return;
		}
	}
	array_push(state.calls, { name: _builder_name, args: _args });
}

function __ww_workbench_regen_code() {
	var _lines = [];
	if (state.code_prefix != "") {
		array_push(_lines, state.code_prefix);
	}
	if (state.constructor_name == "") {
		state.code_box.set_value("");
		exit;
	}

	array_push(_lines, "var " + state.var_name + " = new " + state.constructor_name + "()");
	for (var _ci = 0; _ci < array_length(state.calls); _ci += 1) {
		var _call = state.calls[_ci];
		var _b = _call.name;
		var _args = _call.args;

		var _arg_defs = {};
		if (variable_struct_exists(state.builder_arg_defs, _b)) {
			_arg_defs = variable_struct_get(state.builder_arg_defs, _b);
		}

		var _arg_text = "";
		var _ac = array_length(_args);
		for (var _ai = 0; _ai < _ac; _ai += 1) {
			var _t = "Any";
			if (is_array(_arg_defs) && _ai < array_length(_arg_defs)) {
				_t = _arg_defs[_ai].type;
			}
			_arg_text += format_arg(_args[_ai], _t);
			if (_ai < _ac - 1) { _arg_text += ", "; }
		}
		array_push(_lines, "\t." + _b + "(" + _arg_text + ")");
	}
	array_push(_lines, ";");

	state.code_box.set_value(string_join_ext("\n", _lines));
}

function __ww_workbench_apply_builder(_builder_name, _args) {
	if (!is_struct(state.instance)) { exit; }
	ww_inspector_call_builder(state.instance, _builder_name, _args);
	set_call(_builder_name, _args);
	regen_code();
}

function __ww_workbench_on_apply(_builder_name, _args) {
	apply_builder(_builder_name, _args);
}

function __ww_workbench_cache_builder_arg_defs(_ctor_name) {
	state.builder_arg_defs = {};
	var _sections = ww_inspector_collect_sections_from_demo_library(_ctor_name, "WWCore");
	for (var _si = 0; _si < array_length(_sections); _si += 1) {
		var _defs = _sections[_si].builder_defs;
		if (!is_struct(_defs)) { continue; }
		var _names = struct_get_names(_defs);
		for (var _ni = 0; _ni < array_length(_names); _ni += 1) {
			var _bn = _names[_ni];
			if (!variable_struct_exists(state.builder_arg_defs, _bn)) {
				variable_struct_set(state.builder_arg_defs, _bn, variable_struct_get(_defs, _bn));
			}
		}
	}
}

function __ww_workbench_build_inspector(_ctor_name, _instance) {
	state.inspector_canvas.clear_children();
	ww_inspector_build_workbench_tree(state.inspector_canvas, _ctor_name, _instance, state.theme, on_apply);
	state.inspector_canvas.update_component_positions();
	state.inspector_canvas.__update_group_region__();
	state.inspector_region.set_canvas_size_from_children();
	state.inspector_region.set_scroll_offset(0, 0);
}

function __ww_workbench_build_special_instance(_ctor_name) {
	if (_ctor_name == "WWViewScrollRegion") {
		var _canvas = new WWCore().set_offset(0, 0).set_size(520, 800);
		var _view = new WWViewScrollRegion().set_region_mode(true);
		var _sbv2 = new WWScrollbarVert();
		_view.scrollbar_vert = _sbv2;
		_view.set_scrollbars_enabled(false, true);
		_view.set_scrollbars_auto_hide(false, false);
		_view.set_canvas(_canvas);
		_view.set_size(360, 220);
		for (var _i = 0; _i < 20; _i += 1) {
			_canvas.add(new WWLabel()
				.set_offset(12, 12 + _i * 22)
				.set_size(500, 20)
				.set_text("Item " + string(_i + 1))
				.set_text_color(c_white));
		}
		_view.set_canvas_size_from_children();
		return { instance: _view, preview_children: [_sbv2] };
	}
	return undefined;
}

function __ww_workbench_instantiate(_ctor_name) {
	var _special = build_special_instance(_ctor_name);
	if (is_struct(_special)) { return _special; }

	var _ctor_func = asset_get_index(_ctor_name);
	if (_ctor_func < 0) { return undefined; }
	return new _ctor_func();
}

function __ww_workbench_apply_initial_defaults() {
	var _inst = state.instance;
	if (!is_struct(_inst)) { exit; }
	if (variable_struct_exists(_inst, "set_size")) {
		apply_builder("set_size", [preview_default_w, preview_default_h]);
	}
	if (variable_struct_exists(_inst, "set_text")) {
		apply_builder("set_text", ["Hello"]);
	}
}

function __ww_workbench_select_ctor(_ctor_name) {
	state.title_label.set_text("WW Workbench :: " + _ctor_name);
	state.constructor_name = _ctor_name;
	state.calls = [];
	state.code_prefix = "";
	state.preview_host.clear_children();

	var _build_out = instantiate(_ctor_name);
	var _instance = _build_out;
	var _preview_children = [];
	if (is_struct(_build_out) && variable_struct_exists(_build_out, "instance")) {
		_instance = _build_out.instance;
		if (variable_struct_exists(_build_out, "preview_children")) {
			_preview_children = _build_out.preview_children;
		}
	}

	state.instance = _instance;
	if (is_struct(_instance)) {
		state.preview_host.add(_instance);
		if (variable_struct_exists(_instance, "set_offset")) {
			_instance.set_offset(20, 20);
		}
	}
	if (is_array(_preview_children) && array_length(_preview_children) != 0) {
		state.preview_host.add(_preview_children);
	}

	cache_builder_arg_defs(_ctor_name);
	apply_initial_defaults();
	build_inspector(_ctor_name, _instance);
	regen_code();
}

function __ww_workbench_reset() {
	if (state.constructor_name == "") { exit; }
	select_ctor(state.constructor_name);
}

function __ww_workbench_copy_code() {
	clipboard_set_text(state.code_box.get_value());
}

function __ww_workbench_make_nav_button(_label_text, _ctor_name, _width) {
	var _b = new WWButtonText()
		.set_size(_width, 26)
		.set_text(_label_text)
		.set_text_font(fnt_ww_consolas_msdf);
	var _nav_ctx = new __WWWorkbench_NavCtx(self, _ctor_name);
	_b.set_callback(_nav_ctx.run);
	return _b;
}

function __ww_workbench_build_nav_list(_filter_text) {
	var _canvas = state.nav_canvas;
	if (!is_struct(_canvas)) { exit; }
	_canvas.clear_children();

	var _lib = ww_inspector_lib();
	var _order = _lib[$ "$$register_order"];
	if (!is_array(_order)) { _order = []; }

	var _filter = string_lower(string(_filter_text));
	var _root = new WWFolder()
		.set_offset(8, 8)
		.set_size(_canvas.width - 16, 0)
		.set_text("Components")
		.set_children_offsets(12, 4)
		.set_open(true);
	_canvas.add(_root);

	for (var _i = 0; _i < array_length(_order); _i += 1) {
		var _ctor_name = _order[_i];
		if (!is_string(_ctor_name)) { continue; }
		if (_filter != "" && string_pos(_filter, string_lower(_ctor_name)) == 0) { continue; }
		_root.add(make_nav_button(_ctor_name, _ctor_name, _root.width - 24));
	}

	_root.update_component_positions();
	_root.__update_group_region__();
	_canvas.update_component_positions();
	_canvas.__update_group_region__();
	state.nav_region.set_canvas_size_from_children();
	state.nav_region.set_scroll_offset(0, 0);
}

function __WWWorkbench_NavCtx(_main, _ctor_name) constructor {
	main = _main;
	ctor = _ctor_name;
	run = method(self, __ww_workbench_nav_run);
}

function __WWWorkbench_SearchCtx(_main, _input) constructor {
	main = _main;
	input = _input;
	run = method(self, __ww_workbench_search_run);
}

function __WWWorkbenchCtx(_state) constructor {
	state = _state;
	preview_default_w = 240;
	preview_default_h = 32;
	validate = method(self, __ww_workbench_validate);
	format_arg = method(self, __ww_workbench_format_arg);
	set_call = method(self, __ww_workbench_set_call);
	regen_code = method(self, __ww_workbench_regen_code);
	apply_builder = method(self, __ww_workbench_apply_builder);
	on_apply = method(self, __ww_workbench_on_apply);
	cache_builder_arg_defs = method(self, __ww_workbench_cache_builder_arg_defs);
	build_inspector = method(self, __ww_workbench_build_inspector);
	build_special_instance = method(self, __ww_workbench_build_special_instance);
	instantiate = method(self, __ww_workbench_instantiate);
	apply_initial_defaults = method(self, __ww_workbench_apply_initial_defaults);
	select_ctor = method(self, __ww_workbench_select_ctor);
	reset = method(self, __ww_workbench_reset);
	copy_code = method(self, __ww_workbench_copy_code);
	make_nav_button = method(self, __ww_workbench_make_nav_button);
	build_nav_list = method(self, __ww_workbench_build_nav_list);
}

function build_ui_folder_demo() {
	var _theme = __ww_demo_theme_palette();

	root = new WWCore()
		.set_offset(0, 0)
		.set_size(1280, 720)
		.set_background_color(c_black)
		.set_enabled(true);

	root.add(new WWCore()
		.set_offset(10, 10)
		.set_size(1260, 700)
		.set_background_color(_theme.page));

	var _pad = 10;
	var _header_h = 44;
	var _nav_w = 260;
	var _insp_w = 340;
	var _content_w = 1260 - _nav_w - _insp_w - (_pad * 2);
	var _content_x = 10 + _nav_w + _pad;
	var _insp_x = _content_x + _content_w + _pad;
	var _body_y = 10 + _header_h + _pad;
	var _body_h = 700 - _header_h - _pad;

	root.add(new WWCore()
		.set_offset(10, 10)
		.set_size(1260, _header_h)
		.set_background_color(_theme.header));

	var _title = new WWLabel()
		.set_offset(24, 22)
		.set_size(700, 20)
		.set_text("WW Workbench")
		.set_text_color(_theme.text);
	root.add(_title);

	var _nav_panel = new WWCore()
		.set_offset(10, _body_y)
		.set_size(_nav_w, _body_h)
		.set_background_color(_theme.panel);
	root.add(_nav_panel);

	var _content_panel = new WWCore()
		.set_offset(_content_x, _body_y)
		.set_size(_content_w, _body_h)
		.set_background_color(_theme.panel);
	root.add(_content_panel);

	var _insp_panel = new WWCore()
		.set_offset(_insp_x, _body_y)
		.set_size(_insp_w, _body_h)
		.set_background_color(_theme.panel);
	root.add(_insp_panel);

	var _state = {
		theme: _theme,
		title_label: _title,
		constructor_name: "",
		instance: undefined,
		calls: [],
		builder_arg_defs: {},
		code_prefix: "",
		var_name: "_comp",
		preview_host: undefined,
		inspector_region: undefined,
		inspector_canvas: undefined,
		code_box: undefined,
		nav_search: undefined,
		nav_region: undefined,
		nav_canvas: undefined,
	};

	var _preview_h = 380;
	var _code_h = _body_h - _preview_h - _pad;

	var _preview_panel = new WWCore()
		.set_offset(10, 10)
		.set_size(_content_w - 20, _preview_h)
		.set_background_color(_theme.panel_alt);
	_content_panel.add(_preview_panel);

	_preview_panel.add(new WWLabel()
		.set_offset(10, 10)
		.set_size(_preview_panel.width - 20, 18)
		.set_text("Preview")
		.set_text_color(_theme.text_dim));

	var _preview_host = new WWCore()
		.set_offset(10, 32)
		.set_size(_preview_panel.width - 20, _preview_panel.height - 42)
		.set_background_color(_theme.page);
	_preview_panel.add(_preview_host);
	_state.preview_host = _preview_host;

	var _code_panel = new WWCore()
		.set_offset(10, 10 + _preview_h + _pad)
		.set_size(_content_w - 20, _code_h)
		.set_background_color(_theme.panel_alt);
	_content_panel.add(_code_panel);

	_code_panel.add(new WWLabel()
		.set_offset(10, 10)
		.set_size(_code_panel.width - 20, 18)
		.set_text("Generated GML")
		.set_text_color(_theme.text_dim));

	var _code_box = new WWTextInputMultiLine()
		.set_offset(10, 32)
		.set_size(_code_panel.width - 20, _code_panel.height - 42)
		.set_read_only(true);
	_code_box.get_field().set_text_font(fnt_ww_consolas_msdf);
	_code_box.get_field().set_wrap_enabled(false);
	_code_box.get_region().set_scrollbars_enabled(true, true);
	_code_box.get_region().set_scrollbars_auto_hide(false, false);
	_code_panel.add(_code_box);
	_state.code_box = _code_box;

	_insp_panel.add(new WWLabel()
		.set_offset(10, 10)
		.set_size(_insp_w - 20, 18)
		.set_text("Inspector")
		.set_text_color(_theme.text_dim));

	var _insp_canvas = new WWCore().set_offset(0, 0).set_size(_insp_w - 30, 0);
	var _insp_region = new WWViewScrollRegion().set_region_mode(true);
	var _sbv = new WWScrollbarVert();
	_insp_region.scrollbar_vert = _sbv;
	_insp_region.set_scrollbars_enabled(false, true);
	_insp_region.set_scrollbars_auto_hide(true, true);
	_insp_region.set_scrollbar_thickness(14);
	_insp_region.set_offset(10, 32);
	_insp_region.set_size(_insp_w - 30, _body_h - 42);
	_insp_region.set_canvas(_insp_canvas);
	_insp_panel.add([_insp_region, _sbv]);
	_state.inspector_region = _insp_region;
	_state.inspector_canvas = _insp_canvas;

	var _nav_search = new WWTextInputSingleLine()
		.set_offset(10, 10)
		.set_size(_nav_w - 20, 24)
		.set_value("");
	_nav_panel.add(_nav_search);
	_state.nav_search = _nav_search;

	var _nav_canvas = new WWCore().set_offset(0, 0).set_size(_nav_w - 30, 0);
	var _nav_region = new WWViewScrollRegion().set_region_mode(true);
	var _nav_sbv = new WWScrollbarVert();
	_nav_region.scrollbar_vert = _nav_sbv;
	_nav_region.set_scrollbars_enabled(false, true);
	_nav_region.set_scrollbars_auto_hide(true, true);
	_nav_region.set_scrollbar_thickness(14);
	_nav_region.set_offset(10, 42);
	_nav_region.set_size(_nav_w - 30, _body_h - 52);
	_nav_region.set_canvas(_nav_canvas);
	_nav_panel.add([_nav_region, _nav_sbv]);
	_state.nav_region = _nav_region;
	_state.nav_canvas = _nav_canvas;

	var _ctx = new __WWWorkbenchCtx(_state);
	var _search_ctx = new __WWWorkbench_SearchCtx(_ctx, _nav_search);
	_nav_search.on_submit(_search_ctx.run);

	var _btn_validate = new WWButtonText()
		.set_offset(840, 16)
		.set_size(130, 24)
		.set_text("Validate")
		.set_text_font(fnt_ww_consolas_msdf);
	_btn_validate.set_callback(_ctx.validate);
	root.add(_btn_validate);

	var _btn_reset = new WWButtonText()
		.set_offset(980, 16)
		.set_size(120, 24)
		.set_text("Reset")
		.set_text_font(fnt_ww_consolas_msdf);
	_btn_reset.set_callback(_ctx.reset);
	root.add(_btn_reset);

	var _btn_copy = new WWButtonText()
		.set_offset(1110, 16)
		.set_size(150, 24)
		.set_text("Copy Code")
		.set_text_font(fnt_ww_consolas_msdf);
	_btn_copy.set_callback(_ctx.copy_code);
	root.add(_btn_copy);

	_ctx.build_nav_list("");
	root.update_component_positions();
	root.__update_group_region__();

	if (asset_get_index("WWButtonText") >= 0) {
		_ctx.select_ctor("WWButtonText");
	}
	else {
		var _lib2 = ww_inspector_lib();
		var _order2 = _lib2[$ "$$register_order"];
		if (is_array(_order2) && array_length(_order2) > 0) {
			_ctx.select_ctor(_order2[0]);
		}
	}

	return root;
}

// User Event 15 entrypoint
build_ui_folder_demo();
show_debug_overlay(true);



