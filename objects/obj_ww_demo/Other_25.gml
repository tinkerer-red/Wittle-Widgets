/// obj_ww_demo :: User Event 15
/// Workbench-only demo.

function __ww_demo_theme_palette() {
	return {
		page: wwThemeGetColor("colors.app.bg.color"),
		panel: wwThemeGetColor("colors.surface.panel.color"),
		panel_alt: wwThemeGetColor("colors.surface.panel_alt.color"),
		header: wwThemeGetColor("colors.surface.panel_alt.color"),
		text: wwThemeGetColor("colors.text.primary.color"),
		text_dim: wwThemeGetColor("colors.text.dim.color"),
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
		var _canvas = new WWContainer().set_offset(0, 0).set_size(520, 800);
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
				.set_text("Item " + string(_i + 1)));
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
	state.preview_host_workbench.clear_children();
	state.preview_host_examples.clear_children();

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
		state.preview_host_workbench.add(_instance);
		if (variable_struct_exists(_instance, "set_offset")) {
			_instance.set_offset(20, 20);
		}
	}
	if (is_array(_preview_children) && array_length(_preview_children) != 0) {
		state.preview_host_workbench.add(_preview_children);
	}

	rebuild_preview_tabs(_ctor_name);
	set_preview_tab(0);

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

function __ww_workbench_apply_theme_choice(_theme_id) {
	if (!is_string(_theme_id) || _theme_id == "") {
		_theme_id = "dark";
	}

	var _next = undefined;

	switch (_theme_id) {
		case "mono":
			_next = wwThemeCompose([wwThemeDefault(), wwThemeLayerRoundedRectangles(), wwThemeMono()]);
			break;
		case "duo":
			_next = wwThemeCompose([wwThemeDefault(), wwThemeLayerRoundedRectangles(), wwThemeDuo()]);
			break;
		case "trio":
			_next = wwThemeCompose([wwThemeDefault(), wwThemeLayerRoundedRectangles(), wwThemeTrio()]);
			break;
		case "quad":
			_next = wwThemeCompose([wwThemeDefault(), wwThemeLayerRoundedRectangles(), wwThemeQuad()]);
			break;
		case "light":
			_next = wwThemeCompose([wwThemeDefault(), wwThemeLayerRoundedRectangles(), wwThemeLayerLight()]);
			break;
		case "dark":
		default:
			_next = wwThemeCompose([wwThemeDefault(), wwThemeLayerRoundedRectangles(), wwThemeLayerDark()]);
			break;
	}

	wwThemeSet(_next);
	global.ww_demo_theme_choice = _theme_id;

	// Rebuild workbench UI so all colors/styles are re-read from the active theme.
	if (instance_exists(state.owner_id)) {
		with (state.owner_id) {
			event_user(15);
		}
	}
}

function __ww_workbench_preview_tab_run() {
	main.set_preview_tab(tab_index);
}

function __ww_workbench_theme_select_run() {
	var _theme_id = dropdown.get_selected_value();
	main.apply_theme_choice(_theme_id);
}

function __ww_workbench_try_call(_instance, _builder_name, _args=[]) {
	if (!is_struct(_instance)) { return false; }
	if (!is_string(_builder_name)) { return false; }
	if (!variable_struct_exists(_instance, _builder_name)) { return false; }
	return ww_inspector_call_builder(_instance, _builder_name, _args);
}

function __ww_workbench_make_example_defs(_ctor_name) {
	var _defs = [];
	var _examples = demo_library_get_examples(_ctor_name);
	if (!is_struct(_examples)) { return _defs; }
	
	var _names = struct_get_names(_examples);
	for (var _i = 0; _i < array_length(_names); _i += 1) {
		var _name = _names[_i];
		var _fn = variable_struct_get(_examples, _name);
		if (!is_callable(_fn)) { continue; }
		array_push(_defs, {
			name: _name,
			init: _fn,
		});
	}
	
	return _defs;
}

function __ww_workbench_apply_example_variant(_instance, _ctor_name, _variant_def, _host, _host_w, _host_h) {
	if (!is_struct(_instance)) { exit; }
	if (!is_struct(_variant_def)) { exit; }
	if (!variable_struct_exists(_variant_def, "init")) { exit; }
	var _fn = _variant_def.init;
	if (!is_callable(_fn)) { exit; }
	
	// Always pass a useful context for example initializers.
	_fn(_instance, {
		ctor_name: _ctor_name,
		host: _host,
		host_width: _host_w,
		host_height: _host_h,
		try_call: try_call,
	});
}

function __ww_workbench_show_example(_example_index) {
	if (state.constructor_name == "") { exit; }
	if (!is_array(state.preview_example_defs)) { exit; }
	if (_example_index < 0 || _example_index >= array_length(state.preview_example_defs)) { exit; }

	state.preview_host_examples.clear_children();
	state.preview_example_index = _example_index;

	var _def = state.preview_example_defs[_example_index];
	state.preview_label.set_text("Preview :: " + _def.name);

	var _build_out = instantiate(state.constructor_name);
	var _instance = _build_out;
	var _preview_children = [];
	if (is_struct(_build_out) && variable_struct_exists(_build_out, "instance")) {
		_instance = _build_out.instance;
		if (variable_struct_exists(_build_out, "preview_children")) {
			_preview_children = _build_out.preview_children;
		}
	}

	if (is_struct(_instance)) {
		state.preview_host_examples.add(_instance);
		if (variable_struct_exists(_instance, "set_offset")) {
			_instance.set_offset(20, 20);
		}
		apply_example_variant(_instance, state.constructor_name, _def, state.preview_host_examples, state.preview_host_examples.width, state.preview_host_examples.height);
	}
	if (is_array(_preview_children) && array_length(_preview_children) != 0) {
		state.preview_host_examples.add(_preview_children);
	}
}

function __ww_workbench_set_preview_tab(_tab_index) {
	if (!is_array(state.preview_tab_buttons)) { exit; }
	var _count = array_length(state.preview_tab_buttons);
	if (_count <= 0) { exit; }
	_tab_index = clamp(_tab_index, 0, _count - 1);
	state.preview_selected_tab = _tab_index;

	for (var _i = 0; _i < _count; _i += 1) {
		var _btn = state.preview_tab_buttons[_i];
		if (!is_struct(_btn)) { continue; }
		var _label = _btn.__ww_tab_label__;
		if (_i == _tab_index) {
			_btn.set_text("> " + _label);
		} else {
			_btn.set_text(_label);
		}
	}

	var _is_workbench = (_tab_index == 0);
	state.preview_host_workbench.set_active(_is_workbench);
	state.preview_host_examples.set_active(!_is_workbench);

	if (_is_workbench) {
		state.preview_label.set_text("Preview :: Workbench");
		return;
	}

	show_example(_tab_index - 1);
}

function __ww_workbench_rebuild_preview_tabs(_ctor_name) {
	state.preview_tabs_bar.clear_children();
	state.preview_tab_buttons = [];
	state.preview_example_defs = make_example_defs(_ctor_name);
	state.preview_example_index = -1;

	var _labels = ["Workbench"];
	for (var _i = 0; _i < array_length(state.preview_example_defs); _i += 1) {
		array_push(_labels, state.preview_example_defs[_i].name);
	}

	var _count = array_length(_labels);
	if (_count <= 0) { return; }
	var _gap = 6;
	var _btn_w = max(80, floor((state.preview_tabs_bar.width - (_gap * (_count - 1))) / _count));

	for (var _ti = 0; _ti < _count; _ti += 1) {
		var _label = _labels[_ti];
		var _x = _ti * (_btn_w + _gap);
		var _btn = new WWButtonText()
			.set_offset(_x, 0)
			.set_size(_btn_w, 24)
			.set_text(_label);
		_btn.__ww_tab_label__ = _label;
		var _ctx = new __WWWorkbench_PreviewTabCtx(self, _ti);
		_btn.set_callback(_ctx.run);
		state.preview_tabs_bar.add(_btn);
		array_push(state.preview_tab_buttons, _btn);
	}
}

function __ww_workbench_make_nav_button(_label_text, _ctor_name, _width) {
	var _b = new WWButtonText()
		.set_size(_width, 26)
		.set_text(_label_text);
	var _nav_ctx = new __WWWorkbench_NavCtx(self, _ctor_name);
	_b.set_callback(_nav_ctx.run);
	return _b;
}

function __ww_workbench_build_nav_list(_filter_text) {
	var _canvas = state.nav_canvas;
	if (!is_struct(_canvas)) { exit; }
	_canvas.clear_children();
	var _tree_indent = 12;
	var _tree_gap = 4;

	var _lib = ww_inspector_lib();
	var _order = _lib[$ "$$register_order"];
	if (!is_array(_order)) { _order = []; }

	var _filter = string_lower(string(_filter_text));
	var _root = new WWFolder()
		.set_offset(8, 8)
		.set_size(_canvas.width - 16, 0)
		.set_text("Components")
		.set_children_offsets(_tree_indent, _tree_gap)
		.set_open(true);
	_canvas.add(_root);
	
	var _folder_map = {};
	variable_struct_set(_folder_map, "__root__", _root);

	for (var _i = 0; _i < array_length(_order); _i += 1) {
		var _ctor_name = _order[_i];
		if (!is_string(_ctor_name)) { continue; }
		
		var _path = demo_library_get_path(_ctor_name);
		var _filter_blob = string_lower(_ctor_name + " " + _path);
		if (_filter != "" && string_pos(_filter, _filter_blob) == 0) { continue; }
		
		var _parent = _root;
		if (_path != "") {
			var _parts = string_split(_path, "/");
			var _acc = "";
			for (var _pi = 0; _pi < array_length(_parts); _pi += 1) {
				var _seg = string_trim(_parts[_pi]);
				if (_seg == "") { continue; }
				
				_acc = (_acc == "") ? _seg : (_acc + "/" + _seg);
				
				var _folder = undefined;
				if (variable_struct_exists(_folder_map, _acc)) {
					_folder = variable_struct_get(_folder_map, _acc);
				}
				else {
					var _child_w = max(120, _parent.width - _tree_indent);
					_folder = new WWFolder()
						.set_size(_child_w, 0)
						.set_text(_seg)
						.set_children_offsets(_tree_indent, _tree_gap)
						.set_open(true);
					_parent.add(_folder);
					variable_struct_set(_folder_map, _acc, _folder);
				}
				
				_parent = _folder;
			}
		}
		
		_parent.add(make_nav_button(_ctor_name, _ctor_name, max(120, _parent.width - _tree_indent)));
	}

	_root.update_component_positions();
	_root.__update_group_region__();
	_canvas.update_component_positions();
	_canvas.__update_group_region__();
	state.nav_region.set_canvas_size_from_children();
	state.nav_region.set_scroll_offset(0, 0);
}

function __ww_workbench_apply_layout(_gui_w, _gui_h) {
	var _margin = 10;
	var _pad = 10;
	var _header_h = 44;
	var _safe_w = max(640, _gui_w);
	var _safe_h = max(360, _gui_h);

	state.root
		.set_offset(0, 0)
		.set_size(_safe_w, _safe_h);

	state.page_fill
		.set_offset(0, 0)
		.set_size(_safe_w, _safe_h);

	var _header_x = _margin;
	var _header_y = _margin;
	var _header_w = max(220, _safe_w - (_margin * 2));

	state.header_panel
		.set_offset(_header_x, _header_y)
		.set_size(_header_w, _header_h);

	var _btn_gap = 10;
	var _btn_y = _header_y + 6;
	var _right = _header_x + _header_w - 10;
	var _x_theme = _right - state.theme_dropdown.width;
	var _x_copy = _x_theme - _btn_gap - state.btn_copy.width;
	var _x_reset = _x_copy - _btn_gap - state.btn_reset.width;
	var _x_validate = _x_reset - _btn_gap - state.btn_validate.width;

	state.btn_validate.set_offset(_x_validate, _btn_y);
	state.btn_reset.set_offset(_x_reset, _btn_y);
	state.btn_copy.set_offset(_x_copy, _btn_y);
	state.theme_dropdown.set_offset(_x_theme, _btn_y);

	var _title_x = _header_x + 14;
	var _title_w = max(120, _x_validate - _title_x - 10);
	state.title_label
		.set_offset(_title_x, _header_y + 12)
		.set_size(_title_w, 20);

	var _body_y = _header_y + _header_h + _pad;
	var _body_h = max(120, (_safe_h - _margin) - _body_y);
	var _body_inner_h = max(40, _body_h - 20);

	var _avail_w = _safe_w - (_margin * 2);
	var _min_content_w = 260;
	var _min_nav_w = 180;
	var _min_insp_w = 220;
	var _nav_w = clamp(round(_avail_w * 0.20), _min_nav_w, 320);
	var _insp_w = clamp(round(_avail_w * 0.26), _min_insp_w, 420);
	var _content_w = _avail_w - _nav_w - _insp_w - (_pad * 2);
	if (_content_w < _min_content_w) {
		var _deficit = _min_content_w - _content_w;
		var _take_insp = min(_deficit, max(0, _insp_w - _min_insp_w));
		_insp_w -= _take_insp;
		_deficit -= _take_insp;
		var _take_nav = min(_deficit, max(0, _nav_w - _min_nav_w));
		_nav_w -= _take_nav;
		_content_w = _avail_w - _nav_w - _insp_w - (_pad * 2);
	}
	_content_w = max(220, _content_w);

	var _nav_x = _margin;
	var _content_x = _nav_x + _nav_w + _pad;
	var _insp_x = _content_x + _content_w + _pad;

	state.nav_panel
		.set_offset(_nav_x, _body_y)
		.set_size(_nav_w, _body_h);
	state.content_panel
		.set_offset(_content_x, _body_y)
		.set_size(_content_w, _body_h);
	state.insp_panel
		.set_offset(_insp_x, _body_y)
		.set_size(_insp_w, _body_h);

	state.nav_search
		.set_offset(10, 10)
		.set_size(_nav_w - 20, 24);
	state.nav_search.get_field()
		.set_caption("Search components...");

	state.nav_region
		.set_offset(10, 42)
		.set_size(_nav_w - 30, _body_h - 52);
	state.nav_canvas.set_size(_nav_w - 30, state.nav_canvas.height);

	state.insp_label
		.set_offset(10, 10)
		.set_size(_insp_w - 20, 18);
	state.inspector_region
		.set_offset(10, 32)
		.set_size(_insp_w - 30, _body_h - 42);
	state.inspector_canvas.set_size(_insp_w - 30, state.inspector_canvas.height);

	var _content_inner_w = _content_w - 20;
	var _preview_h = clamp(round(_body_inner_h * 0.55), 180, max(180, _body_inner_h - 120));
	var _code_h = max(80, _body_inner_h - _preview_h - _pad);

	state.preview_panel
		.set_offset(10, 10)
		.set_size(_content_inner_w, _preview_h);
	state.preview_label
		.set_offset(10, 10)
		.set_size(_content_inner_w - 20, 18);
	state.preview_tabs_bar
		.set_offset(10, 30)
		.set_size(_content_inner_w - 20, 24);
	state.preview_host_workbench
		.set_offset(10, 58)
		.set_size(_content_inner_w - 20, _preview_h - 68);
	state.preview_host_examples
		.set_offset(10, 58)
		.set_size(_content_inner_w - 20, _preview_h - 68);

	state.code_panel
		.set_offset(10, 10 + _preview_h + _pad)
		.set_size(_content_inner_w, _code_h);
	state.code_label
		.set_offset(10, 10)
		.set_size(_content_inner_w - 20, 18);
	state.code_box
		.set_offset(10, 32)
		.set_size(_content_inner_w - 20, _code_h - 42);
}

function __ww_workbench_refresh_layout(_force = false) {
	var _gw = display_get_gui_width();
	var _gh = display_get_gui_height();
	if (!_force && _gw == state.gui_w && _gh == state.gui_h) { exit; }

	state.gui_w = _gw;
	state.gui_h = _gh;

	apply_layout(_gw, _gh);

	if (state.constructor_name != "" && is_struct(state.instance)) {
		build_inspector(state.constructor_name, state.instance);
	}

	var _filter = "";
	if (is_struct(state.nav_search)) {
		_filter = state.nav_search.get_value();
	}
	build_nav_list(_filter);
	if (state.constructor_name != "") {
		rebuild_preview_tabs(state.constructor_name);
		set_preview_tab(state.preview_selected_tab);
	}

	state.root.update_component_positions();
	state.root.__update_group_region__();
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

function __WWWorkbench_PreviewTabCtx(_main, _tab_index) constructor {
	main = _main;
	tab_index = _tab_index;
	run = method(self, __ww_workbench_preview_tab_run);
}

function __WWWorkbench_ThemeSelectCtx(_main, _dropdown) constructor {
	main = _main;
	dropdown = _dropdown;
	run = method(self, __ww_workbench_theme_select_run);
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
	apply_theme_choice = method(self, __ww_workbench_apply_theme_choice);
	try_call = method(self, __ww_workbench_try_call);
	make_example_defs = method(self, __ww_workbench_make_example_defs);
	apply_example_variant = method(self, __ww_workbench_apply_example_variant);
	show_example = method(self, __ww_workbench_show_example);
	set_preview_tab = method(self, __ww_workbench_set_preview_tab);
	rebuild_preview_tabs = method(self, __ww_workbench_rebuild_preview_tabs);
	make_nav_button = method(self, __ww_workbench_make_nav_button);
	build_nav_list = method(self, __ww_workbench_build_nav_list);
	apply_layout = method(self, __ww_workbench_apply_layout);
	refresh_layout = method(self, __ww_workbench_refresh_layout);
}

function build_ui_folder_demo() {
	root = new WWCanvas()
		.set_offset(0, 0)
		.set_size(max(1, display_get_gui_width()), max(1, display_get_gui_height()))
		.set_enabled(true);

	var _page_fill = new WWCanvas()
		.set_offset(0, 0)
		.set_size(max(1, display_get_gui_width()), max(1, display_get_gui_height()));
	root.add(_page_fill);

	var _pad = 10;
	var _header_h = 44;
	var _nav_w = 260;
	var _insp_w = 340;
	var _content_w = 1260 - _nav_w - _insp_w - (_pad * 2);
	var _content_x = 10 + _nav_w + _pad;
	var _insp_x = _content_x + _content_w + _pad;
	var _body_y = 10 + _header_h + _pad;
	var _body_h = 700 - _header_h - _pad;

	var _header_panel = new WWFrame()
		.set_offset(10, 10)
		.set_size(1260, _header_h);
	root.add(_header_panel);

	var _title = new WWLabel()
		.set_offset(24, 22)
		.set_size(700, 20)
		.set_text("WW Workbench");
	root.add(_title);

	var _nav_panel = new WWPanel()
		.set_offset(10, _body_y)
		.set_size(_nav_w, _body_h);
	root.add(_nav_panel);

	var _content_panel = new WWPanel()
		.set_offset(_content_x, _body_y)
		.set_size(_content_w, _body_h);
	root.add(_content_panel);

	var _insp_panel = new WWPanel()
		.set_offset(_insp_x, _body_y)
		.set_size(_insp_w, _body_h);
	root.add(_insp_panel);

	var _state = {
		owner_id: id,
		gui_w: -1,
		gui_h: -1,
		root: root,
		page_fill: _page_fill,
		header_panel: _header_panel,
		nav_panel: _nav_panel,
		content_panel: _content_panel,
		insp_panel: _insp_panel,
		preview_panel: undefined,
		preview_label: undefined,
		code_panel: undefined,
		code_label: undefined,
		insp_label: undefined,
		btn_validate: undefined,
		btn_reset: undefined,
		btn_copy: undefined,
		theme_dropdown: undefined,
		theme: global.ww_theme,
		title_label: _title,
		constructor_name: "",
		instance: undefined,
		calls: [],
		builder_arg_defs: {},
		code_prefix: "",
		var_name: "_comp",
		preview_tabs_bar: undefined,
		preview_tab_buttons: [],
		preview_selected_tab: 0,
		preview_example_defs: [],
		preview_example_index: -1,
		preview_host_workbench: undefined,
		preview_host_examples: undefined,
		inspector_region: undefined,
		inspector_canvas: undefined,
		code_box: undefined,
		nav_search: undefined,
		nav_region: undefined,
		nav_canvas: undefined,
	};

	var _preview_h = 380;
	var _code_h = _body_h - _preview_h - _pad;

	var _preview_panel = new WWInset()
		.set_offset(10, 10)
		.set_size(_content_w - 20, _preview_h);
	_content_panel.add(_preview_panel);
	_state.preview_panel = _preview_panel;

	var _preview_label = new WWLabel()
		.set_offset(10, 10)
		.set_size(_preview_panel.width - 20, 18)
		.set_text("Preview");
	_preview_panel.add(_preview_label);
	_state.preview_label = _preview_label;

	var _preview_tabs = new WWContainer()
		.set_offset(10, 30)
		.set_size(_preview_panel.width - 20, 24);
	_preview_panel.add(_preview_tabs);
	_state.preview_tabs_bar = _preview_tabs;

	var _preview_host_workbench = new WWCanvas()
		.set_offset(10, 58)
		.set_size(_preview_panel.width - 20, _preview_panel.height - 68);
	_preview_panel.add(_preview_host_workbench);
	_state.preview_host_workbench = _preview_host_workbench;

	var _preview_host_examples = new WWCanvas()
		.set_offset(10, 58)
		.set_size(_preview_panel.width - 20, _preview_panel.height - 68);
	_preview_panel.add(_preview_host_examples);
	_state.preview_host_examples = _preview_host_examples;
	_preview_host_examples.set_active(false);

	var _code_panel = new WWInset()
		.set_offset(10, 10 + _preview_h + _pad)
		.set_size(_content_w - 20, _code_h);
	_content_panel.add(_code_panel);
	_state.code_panel = _code_panel;

	var _code_label = new WWLabel()
		.set_offset(10, 10)
		.set_size(_code_panel.width - 20, 18)
		.set_text("Generated GML");
	_code_panel.add(_code_label);
	_state.code_label = _code_label;

	var _code_box = new WWTextInputMultiLine()
		.set_offset(10, 32)
		.set_size(_code_panel.width - 20, _code_panel.height - 42)
		.set_read_only(true);
	_code_box.get_field().set_wrap_enabled(false);
	_code_box.get_region().set_scrollbars_enabled(true, true);
	_code_box.get_region().set_scrollbars_auto_hide(false, false);
	_code_panel.add(_code_box);
	_state.code_box = _code_box;

	var _insp_label = new WWLabel()
		.set_offset(10, 10)
		.set_size(_insp_w - 20, 18)
		.set_text("Inspector");
	_insp_panel.add(_insp_label);
	_state.insp_label = _insp_label;

	var _insp_canvas = new WWContainer().set_offset(0, 0).set_size(_insp_w - 30, 0);
	var _insp_region = new WWViewScrollRegion().set_region_mode(true);
	var _sbv = new WWScrollbarVert();
	_insp_region.scrollbar_vert = _sbv;
	_insp_region.set_scrollbars_enabled(false, true);
	_insp_region.set_scrollbars_auto_hide(true, true);
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

	var _nav_canvas = new WWContainer().set_offset(0, 0).set_size(_nav_w - 30, 0);
	var _nav_region = new WWViewScrollRegion().set_region_mode(true);
	var _nav_sbv = new WWScrollbarVert();
	_nav_region.scrollbar_vert = _nav_sbv;
	_nav_region.set_scrollbars_enabled(false, true);
	_nav_region.set_scrollbars_auto_hide(true, true);
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
		.set_offset(700, 16)
		.set_size(130, 24)
		.set_text("Validate");
	_btn_validate.set_callback(_ctx.validate);
	root.add(_btn_validate);
	_state.btn_validate = _btn_validate;

	var _btn_reset = new WWButtonText()
		.set_offset(840, 16)
		.set_size(120, 24)
		.set_text("Reset");
	_btn_reset.set_callback(_ctx.reset);
	root.add(_btn_reset);
	_state.btn_reset = _btn_reset;

	var _btn_copy = new WWButtonText()
		.set_offset(970, 16)
		.set_size(130, 24)
		.set_text("Copy Code");
	_btn_copy.set_callback(_ctx.copy_code);
	root.add(_btn_copy);
	_state.btn_copy = _btn_copy;

	var _theme_choice = variable_global_exists("ww_demo_theme_choice") ? global.ww_demo_theme_choice : "dark";
	var _theme_dropdown = new WWDropdownSelect()
		.set_offset(1110, 16)
		.set_size(150, 24)
		.set_text("Theme...")
		.set_options([
			{ label: "Theme: Dark", value: "dark" },
			{ label: "Theme: Light", value: "light" },
			{ label: "Theme: Mono", value: "mono" },
			{ label: "Theme: Duo", value: "duo" },
			{ label: "Theme: Palette", value: "trio" },
			{ label: "Theme: Components", value: "quad" }
		])
		.set_selected_value(_theme_choice);
	var _theme_ctx = new __WWWorkbench_ThemeSelectCtx(_ctx, _theme_dropdown);
	_theme_dropdown.on_event(_theme_dropdown.events.changed, _theme_ctx.run);
	root.add(_theme_dropdown);
	_state.theme_dropdown = _theme_dropdown;

	_ctx.build_nav_list("");
	workbench_ctx = _ctx;
	_ctx.refresh_layout(true);
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



