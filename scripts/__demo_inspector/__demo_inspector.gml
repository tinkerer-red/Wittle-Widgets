#region jsDoc
/// @func    ww_inspector_get_tag_parent_name(_asset_index)
/// @desc    Reads asset tags and returns the parent constructor name from @@parent=... if present.
/// @param   {Real} _asset_index
/// @returns {String} parent_name_or_empty
#endregion
function ww_inspector_get_tag_parent_name(_asset_index) {
	if (_asset_index < 0) { return ""; }

	var _tags = asset_get_tags(_asset_index);
	if (!is_array(_tags)) { return ""; }

	var _tag_count = array_length(_tags);
	var _tag_index = 0;

	repeat(_tag_count) {
		var _tag_value = _tags[_tag_index];

		// Exact match pattern: "@@parent=Something"
		if (is_string(_tag_value)) {
			if (string_pos("@@parent=", _tag_value) == 1) {
				var _name = string_copy(_tag_value, 10, string_length(_tag_value) - 9);
				return _name;
			}
		}

		_tag_index += 1;
	}

	return "";
};

#region jsDoc
/// @func    ww_inspector_collect_constructor_chain(_leaf_constructor_name, _stop_constructor_name)
/// @desc    Returns an array of constructor names in order: stop -> ... -> leaf.
///          Uses @@parent=... tags and asset_get_index() resolution.
/// @param   {String} _leaf_constructor_name
/// @param   {String} _stop_constructor_name
/// @returns {Array} constructor_names
#endregion
function ww_inspector_collect_constructor_chain(_leaf_constructor_name, _stop_constructor_name) {
	var _names = [];

	var _current_name = _leaf_constructor_name;
	var _loop_guard = 0;

	// Walk upward until we hit stop or fail.
	repeat(64) {
		_loop_guard += 1;

		if (_current_name == "") { break; }

		// Push now; we will reverse at the end (leaf -> root collected).
		array_push(_names, _current_name);

		if (_current_name == _stop_constructor_name) {
			break;
		}

		var _asset_index = asset_get_index(_current_name);
		if (_asset_index < 0) {
			break;
		}

		var _parent_name = ww_inspector_get_tag_parent_name(_asset_index);
		if (_parent_name == "") {
			break;
		}

		// Prevent infinite loops if tags are wrong.
		if (_parent_name == _current_name) {
			break;
		}

		_current_name = _parent_name;
	}

	// Reverse so it becomes stop -> ... -> leaf
	var _reversed = [];
	var _count = array_length(_names);
	var _index = _count - 1;

	while (_index >= 0) {
		array_push(_reversed, _names[_index]);
		_index -= 1;
	}

	return _reversed;
};

#region jsDoc
/// @func    ww_inspector_collect_builders_for_constructor(_library, _leaf_constructor_name)
/// @desc    Collects builder defs by walking @@parent=... chain until WWCore.
/// @param   {Struct} _library
/// @param   {String} _leaf_constructor_name
/// @returns {Array} sections
#endregion
function ww_inspector_collect_builders_for_constructor(_library, _leaf_constructor_name) {
	// Legacy wrapper: ignore _library and use the global ww_inspector_lib() demo library.
	var _sections = ww_inspector_collect_sections_from_demo_library(_leaf_constructor_name, "WWCore");
	// Keep the old key name `builders` for older callers.
	for (var _i = 0; _i < array_length(_sections); _i += 1) {
		_sections[_i].builders = _sections[_i].builder_defs;
	}
	return _sections;
};

#region jsDoc
/// @func    ww_inspector_collect_sections_from_demo_library(_leaf_constructor_name, _stop_constructor_name)
/// @desc    Collects section structs from the global ww_inspector_lib() demo library.
///          Each section is { constructor_name, builder_defs } where builder_defs is a struct mapping
///          builder_name -> arg_defs array.
/// @param   {String} _leaf_constructor_name
/// @param   {String} _stop_constructor_name
/// @returns {Array} sections
#endregion
function ww_inspector_collect_sections_from_demo_library(_leaf_constructor_name, _stop_constructor_name="WWCore") {
	var _library = ww_inspector_lib();
	var _constructor_chain = ww_inspector_collect_constructor_chain(_leaf_constructor_name, _stop_constructor_name);

	var _sections = [];
	var _chain_count = array_length(_constructor_chain);
	for (var _i = 0; _i < _chain_count; _i += 1) {
		var _constructor_name = _constructor_chain[_i];
		var _builder_defs = {};
		if (is_struct(_library) && variable_struct_exists(_library, _constructor_name)) {
			_builder_defs = variable_struct_get(_library, _constructor_name);
		}
		array_push(_sections, {
			constructor_name: _constructor_name,
			builder_defs: _builder_defs,
		});
	}

	return _sections;
};

#region jsDoc
/// @func    ww_inspector_call_builder(_instance, _builder_name, _args)
/// @desc    Calls a builder function on a WW component instance by name.
/// @param   {Struct} _instance
/// @param   {String} _builder_name
/// @param   {Array} _args
/// @returns {Bool} success
/// @ignore
#endregion
function ww_inspector_call_builder(_instance, _builder_name, _args) {
	if (!is_struct(_instance)) { return false; }
	if (!is_string(_builder_name)) { return false; }
	if (!is_array(_args)) { _args = []; }
	if (!variable_struct_exists(_instance, _builder_name)) { return false; }

	var _fn = variable_struct_get(_instance, _builder_name);
	if (!is_callable(_fn)) { return false; }
	
	with (_instance) {
		script_execute_ext(_fn, _args)
	}
	//method_call(_fn, _args)
	
	return true;
};

#region jsDoc
/// @func    ww_inspector_try_get_builder_args(_instance, _builder_name, _arg_defs)
/// @desc    Best-effort read of current values using a matching get_* function.
///          Supports common patterns where the getter returns a struct (e.g. get_size -> {width,height}).
/// @param   {Struct} _instance
/// @param   {String} _builder_name
/// @param   {Array} _arg_defs
/// @returns {Array} args
/// @ignore
#endregion
function ww_inspector_try_get_builder_args(_instance, _builder_name, _arg_defs) {
	var _args = [];
	if (!is_struct(_instance)) { return _args; }
	if (!is_string(_builder_name)) { return _args; }
	if (!is_array(_arg_defs)) { _arg_defs = []; }

	var _argc = array_length(_arg_defs);
	if (_argc <= 0) { return _args; }
	array_resize(_args, _argc);

	var _suffix = string_delete(_builder_name, 1, 4);
	var _getter = "get_" + _suffix;
	if (!variable_struct_exists(_instance, _getter)) {
		return _args;
	}
	var _get_fn = variable_struct_get(_instance, _getter);
	if (!is_callable(_get_fn)) { return _args; }
	
	with (_instance) {
		var _v = script_execute_ext(_get_fn, _args)
	}
	
	if (is_struct(_v)) {
		for (var _i = 0; _i < _argc; _i += 1) {
			var _def = _arg_defs[_i];
			var _name = _def.name;
			if (is_string(_name) && variable_struct_exists(_v, _name)) {
				_args[_i] = variable_struct_get(_v, _name);
			}
		}
		return _args;
	}

	// Common single-arg getter
	if (_argc == 1) {
		_args[0] = _v;
	}

	return _args;
};

#region jsDoc
/// @func    ww_inspector_build_workbench_tree(_canvas, _leaf_constructor_name, _instance, _theme, _on_apply)
/// @desc    Builds an interactive inspector tree into a scroll-canvas.
///          For each builder in the demo library metadata, creates input controls and wires them
///          to call _on_apply(builder_name, args).
/// @param   {Struct.WWCore} _canvas
/// @param   {String} _leaf_constructor_name
/// @param   {Struct} _instance
/// @param   {Struct} _theme
/// @param   {Function} _on_apply
/// @returns {Undefined}
#endregion

function __ww_inspector_notify_canvas_changed__(_c) {
	if (!is_struct(_c)) { exit; }

	// Ensure group bounds are current.
	_c.update_component_positions();
	_c.__update_group_region__();

	// Walk up the parent chain to find a WWViewScrollRegion wrapper.
	// When found, update content size so scrolling stays correct.
	var _p = _c;
	repeat (8) {
		if (is_struct(_p) && variable_struct_exists(_p, "set_canvas_size_from_children")) {
			_p.set_canvas_size_from_children();
			exit;
		}
		if (!is_struct(_p) || !variable_struct_exists(_p, "__parent__")) { break; }
		_p = _p.__parent__;
	}
}

function ww_inspector_build_workbench_tree(_canvas, _leaf_constructor_name, _instance, _theme, _on_apply) {
	if (!is_struct(_canvas)) { exit; }
	_canvas.clear_children();

	var _sections = ww_inspector_collect_sections_from_demo_library(_leaf_constructor_name, "WWCore");
	var _gap = 8;

	// Root container folder is critical for correct reflow.
	// WWFolder only notifies/reflows when its parent is also a WWFolder.
	var _root = new WWFolder()
		.set_offset(8, 8)
		.set_size(_canvas.width - 16, 1)
		.set_text("")
		.set_children_offsets(0, _gap)
		.set_open(true);
	_canvas.add(_root);

	var _section_count = array_length(_sections);
	for (var _si = 0; _si < _section_count; _si += 1) {
		var _sec = _sections[_si];
		var _ctor_name = _sec.constructor_name;
		var _defs = _sec.builder_defs;
		if (!is_struct(_defs)) { _defs = {}; }

		var _folder = new WWFolder()
			.set_size(_root.width, 0)
			.set_text(_ctor_name)
			.set_children_offsets(12, 4)
			.set_open(_si == _section_count - 1);
		_root.add(_folder);

		// When folders open/close, the scroll region content size must be recomputed.
		var _ctx_folder_reflow = { canvas: _canvas };
		_folder.on_event(_folder.events.opened, method(_ctx_folder_reflow, function(_data) {
			__ww_inspector_notify_canvas_changed__(canvas);
		}));
		_folder.on_event(_folder.events.closed, method(_ctx_folder_reflow, function(_data) {
			__ww_inspector_notify_canvas_changed__(canvas);
		}));

		var _builder_names = struct_get_names(_defs);
		var _bnc = array_length(_builder_names);
		array_sort(_builder_names, true);
		for (var _bi = 0; _bi < _bnc; _bi += 1) {
			var _builder_name = _builder_names[_bi];
			var _arg_defs = variable_struct_get(_defs, _builder_name);
			if (!is_array(_arg_defs)) { _arg_defs = []; }

			var _bf = new WWFolder()
				.set_offset(0, 0)
				.set_size(_folder.width - 24, 0)
				.set_text(_builder_name)
				.set_children_offsets(8, 2)
				.set_open(false);
			_folder.add(_bf);

			var _debug_builder = (_builder_name == "set_size");
			if (_debug_builder) {
				//_bf.set_debug(true);
				var _ctx_dbg_bf = { comp: _bf };
				_bf.on_post_draw(method(_ctx_dbg_bf, function() {
					//if (!comp.get_debug()) { exit; }
					//draw_set_alpha(1);
					//draw_set_color(c_yellow);
					//var _txt = "DBG set_size";
					//_txt += "\ny_off=" + string(comp.y_offset) + " y=" + string(comp.y);
					//_txt += "\nh=" + string(comp.height) + " grp.h=" + string(comp.__group__.height);
					//draw_text(comp.x + 2, comp.y + 2, _txt);
				}));
			}

			var _ctx_bf_reflow = { canvas: _canvas };
			_bf.on_event(_bf.events.opened, method(_ctx_bf_reflow, function(_data) {
				__ww_inspector_notify_canvas_changed__(canvas);
			}));
			_bf.on_event(_bf.events.closed, method(_ctx_bf_reflow, function(_data) {
				__ww_inspector_notify_canvas_changed__(canvas);
			}));

			var _argc = array_length(_arg_defs);
			if (_argc == 0) {
				var _invoke = new WWButtonText()
					.set_offset(0, 0)
					.set_size(_bf.width - 16, 24)
					.set_text("Invoke")
					.set_text_font(fnt_ww_consolas_msdf);
				var _ctx_invoke = { on_apply: _on_apply, builder: _builder_name };
				_invoke.set_callback(method(_ctx_invoke, function() {
					if (is_callable(on_apply)) { on_apply(builder, []); }
				}));
				_bf.add(_invoke);
				continue;
			}

			// Prefill with best-effort values from getters
			var _current = ww_inspector_try_get_builder_args(_instance, _builder_name, _arg_defs);
			if (!is_array(_current) || array_length(_current) != _argc) {
				_current = [];
				array_resize(_current, _argc);
			}

			for (var _ai = 0; _ai < _argc; _ai += 1) {
				var _arg = _arg_defs[_ai];
				var _arg_name = _arg.name;
				var _arg_type = _arg.type;
				var _val = _current[_ai];
				if (is_undefined(_val)) {
					switch (_arg_type) {
						case "Real": _val = 0; break;
						case "Color": _val = 0; break;
						case "Bool": _val = false; break;
						case "String": _val = ""; break;
						default: _val = ""; break;
					}
					_current[_ai] = _val;
				}

				var _row = new WWCore()
					//.set_offset(0, 0)
					.set_size(_bf.width - 16, 26);
				_bf.add(_row);
				if (_debug_builder) {
					//_row.set_debug(true);
					var _ctx_dbg_row = { row: _row, name: _arg_name };
					_row.on_post_draw(method(_ctx_dbg_row, function() {
						//if (!row.get_debug()) { exit; }
						//draw_set_alpha(1);
						//draw_set_color(c_aqua);
						//var _txt = "row " + string(name);
						//_txt += "\ny_off=" + string(row.y_offset) + " y=" + string(row.y);
						//_txt += "\nh=" + string(row.height) + " grp.h=" + string(row.__group__.height);
						//draw_text(row.x + 2, row.y + 2, _txt);
					}));
				}

				var _lbl = new WWLabel()
					.set_offset(6, 4)
					.set_size(120, 18)
					.set_text(string(_arg_name));
				_row.add(_lbl);
				if (_debug_builder) {
					//_lbl.set_debug(true);
				}

				if (_arg_type == "Bool") {
					var _cb = new WWCheckbox()
						.set_offset(136, 2)
						.set_size(22, 22)
						.set_checked(_val);
					var _ctx_cb = { on_apply: _on_apply, builder: _builder_name, args: _current, index: _ai };
					_cb.set_callback(method(_ctx_cb, function(_checked) {
						args[index] = _checked;
						if (is_callable(on_apply)) { on_apply(builder, args); }
					}));
					_row.add(_cb);
					if (_debug_builder) {
						//_cb.set_debug(true);
						var _ctx_dbg_cb = { comp: _cb };
						_cb.on_post_draw(method(_ctx_dbg_cb, function() {
							//if (!comp.get_debug()) { exit; }
							//draw_set_alpha(1);
							//draw_set_color(c_lime);
							//var _txt = "cb";
							//_txt += "\ny_off=" + string(comp.y_offset);
							//_txt += "\nh=" + string(comp.height) + " grp.h=" + string(comp.__group__.height);
							//draw_text(comp.x + 2, comp.y + 2, _txt);
						}));
					}
				}
				else {
					var _in_w = _row.width - 142;
					var _x = 136;
					var _y = 2;

					if (_arg_type == "Real") {
						var _in = new WWInputReal()
							.set_offset(_x, _y)
							.set_size(_in_w, 22)
							.set_value(real(_val));
						var _ctx = { on_apply: _on_apply, builder: _builder_name, args: _current, index: _ai, input: _in };
						_in.on_value_change(method(_ctx, function(_d) {
							args[index] = input.get_value();
							if (is_callable(on_apply)) { on_apply(builder, args); }
						}));
						_row.add(_in);
					}
					else if (_arg_type == "Int") {
						var _in = new WWInputInt()
							.set_offset(_x, _y)
							.set_size(_in_w, 22)
							.set_value(real(_val));
						var _ctx = { on_apply: _on_apply, builder: _builder_name, args: _current, index: _ai, input: _in };
						_in.on_value_change(method(_ctx, function(_d) {
							args[index] = floor(input.get_value());
							if (is_callable(on_apply)) { on_apply(builder, args); }
						}));
						_row.add(_in);
					}
					else if (_arg_type == "String") {
						var _in = new WWInputString()
							.set_offset(_x, _y)
							.set_size(_in_w, 22)
							.set_value(string(_val));
						var _ctx = { on_apply: _on_apply, builder: _builder_name, args: _current, index: _ai, input: _in };
						_in.on_submit(method(_ctx, function(_data) {
							args[index] = input.get_value();
							if (is_callable(on_apply)) { on_apply(builder, args); }
						}));
						_row.add(_in);
					}
					else if (_arg_type == "Color") {
						var _in = new WWColorInput()
							.set_offset(_x, _y)
							.set_size(_in_w, 22)
							.set_use_alpha(false);
						var _ctx = { on_apply: _on_apply, builder: _builder_name, args: _current, index: _ai, input: _in };
						_in.on_color_change(method(_ctx, function(_d) {
							args[index] = _d.color;
							if (is_callable(on_apply)) { on_apply(builder, args); }
						}));
						_row.add(_in);
					}
					else {
						var _in = new WWTextInputSingleLine()
							.set_offset(_x, _y)
							.set_size(_in_w, 22)
							.set_value(string(_val));
						var _ctx_in = { on_apply: _on_apply, builder: _builder_name, args: _current, index: _ai, type: _arg_type, input: _in };
						_in.on_submit(method(_ctx_in, function(_data) {
							var _text = input.get_value();
							var _out = _text;
							if (type == "Real") {
								_out = real(_text);
							}
							args[index] = _out;
							if (is_callable(on_apply)) { on_apply(builder, args); }
						}));
						_row.add(_in);
					}
					if (_debug_builder) {
						_in.set_debug(true);
						//_in.get_region().set_debug(true);
						//_in.get_field().set_debug(true);
						var _ctx_dbg_in = { comp: _in };
						_in.on_post_draw(method(_ctx_dbg_in, function() {
							if (!comp.get_debug()) { exit; }
							draw_set_alpha(1);
							draw_set_color(c_green);
							var _txt = "input";
							_txt += "\ny_off=" + string(comp.y_offset);
							_txt += "\nh=" + string(comp.height) + " grp.h=" + string(comp.__group__.height);
							draw_text(comp.x + 2, comp.y + 2, _txt);
						}));
					}
				}
			}
		}

		_folder.update_component_positions();
		_folder.__update_group_region__();
	}

	_root.update_component_positions();
	_root.__update_group_region__();
	_canvas.update_component_positions();
	_canvas.__update_group_region__();
	__ww_inspector_notify_canvas_changed__(_canvas);
};

#region jsDoc
/// @func    ww_inspector_build_tree_ui(_root_container, _sections, _theme)
/// @desc    Builds an inspector tree UI under _root_container.
/// @param   {Struct.WWCore} _root_container
/// @param   {Array} _sections
/// @param   {Struct} _theme
/// @returns {Undefined}
#endregion
function ww_inspector_build_tree_ui(_root_container, _sections, _theme) {
	if (!is_struct(_root_container)) { exit; }
	if (!is_array(_sections)) { exit; }

	var _ypos = 10;
	var _y_gap = 6;

	var _section_count = array_length(_sections);
	var _section_index = 0;

	repeat(_section_count) {
		var _section = _sections[_section_index];
		var _constructor_name = _section.constructor_name;
		var _builders = undefined;
		if (variable_struct_exists(_section, "builder_defs")) { _builders = _section.builder_defs; }
		else if (variable_struct_exists(_section, "builders")) { _builders = _section.builders; }
		if (!is_struct(_builders)) { _builders = {}; }

		var _folder = new WWFolder()
			.set_offset(10, _ypos)
			.set_size(320, 0)
			.set_text(_constructor_name)
			.set_children_offsets(14, 4)
			.set_open(true);

		// Populate builder rows (signature-only)
		var _builder_names = struct_get_names(_builders);
		array_sort(_builder_names, true);
		var _builder_count = array_length(_builder_names);
		var _builder_index = 0;

		repeat(_builder_count) {
			var _builder_name = _builder_names[_builder_index];
			var _args = variable_struct_get(_builders, _builder_name);
			if (!is_array(_args)) { _args = []; }

			// Build a small signature string: set_size(width:Real, height:Real)
			var _signature = _builder_name + "(";

			var _arg_count = array_length(_args);
			var _arg_index = 0;

			repeat(_arg_count) {
				var _arg_def = _args[_arg_index];
				_signature += _arg_def.name + ":" + _arg_def.type;

				if (_arg_index < _arg_count - 1) {
					_signature += ", ";
				}

				_arg_index += 1;
			}

			_signature += ")";

			var _row = new WWLabel()
				.set_size(300, 20)
				.set_text(_signature);

			_folder.add(_row);

			_builder_index += 1;
		}

		_root_container.add(_folder);

		// Advance stacking. Folder self-updates group height; call these to be safe.
		_folder.update_component_positions();
		_folder.__update_group_region__();

		_ypos += _folder.get_group_height() + _y_gap;

		_section_index += 1;
	}
};

