#region jsDoc
/// @func    ww_inspector_get_tag_parent_name(_asset_index)
/// @desc    Reads asset tags and returns the parent constructor name from @@parent=... if present.
/// @param   {Real} _asset_index
/// @returns {String} parent_name_or_empty
#endregion
ww_inspector_get_tag_parent_name = function(_asset_index) {
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
ww_inspector_collect_constructor_chain = function(_leaf_constructor_name, _stop_constructor_name) {
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
ww_inspector_collect_builders_for_constructor = function(_library, _leaf_constructor_name) {
	var _constructor_chain = ww_inspector_collect_constructor_chain(_leaf_constructor_name, "WWCore");

	var _sections = [];
	var _chain_count = array_length(_constructor_chain);
	var _chain_index = 0;

	repeat(_chain_count) {
		var _constructor_name = _constructor_chain[_chain_index];
		var _builder_defs = ww_inspector_lib_get(_library, _constructor_name);

		array_push(_sections, {
			constructor_name: _constructor_name,
			builders: _builder_defs
		});

		_chain_index += 1;
	}

	return _sections;
};

#region jsDoc
/// @func    ww_inspector_build_tree_ui(_root_container, _sections, _theme)
/// @desc    Builds an inspector tree UI under _root_container.
/// @param   {Struct.WWCore} _root_container
/// @param   {Array} _sections
/// @param   {Struct} _theme
/// @returns {Undefined}
#endregion
ww_inspector_build_tree_ui = function(_root_container, _sections, _theme) {
	if (!is_struct(_root_container)) { exit; }
	if (!is_array(_sections)) { exit; }

	var _ypos = 10;
	var _y_gap = 6;

	var _section_count = array_length(_sections);
	var _section_index = 0;

	repeat(_section_count) {
		var _section = _sections[_section_index];
		var _constructor_name = _section.constructor_name;
		var _builders = _section.builders;

		var _folder = new WWFolder()
			.set_offset(10, _ypos)
			.set_size(320, 0)
			.set_text(_constructor_name)
			.set_children_offsets(14, 4)
			.set_open(true);

		// Populate builder rows
		var _builder_count = array_length(_builders);
		var _builder_index = 0;

		repeat(_builder_count) {
			var _builder_def = _builders[_builder_index];

			var _builder_name = _builder_def.name;
			var _args = _builder_def.args;

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
				.set_text(_signature)
				.set_text_color(_theme.text_dim)
				.set_background_color(_theme.panel_alt);

			_folder.add(_row);

			_builder_index += 1;
		}

		_root_container.add(_folder);

		// Advance stacking. Folder self-updates group height; call these to be safe.
		_folder.update_component_positions();
		_folder.__update_group_region__();

		_ypos += _folder.__group__.height + _y_gap;

		_section_index += 1;
	}
};

function build_ui_inspector_demo() {
	var _library = ww_inspector_lib_create();

	// Register WWCore builders
	ww_inspector_lib_register(_library, "WWCore", [
		{ name: "set_offset", args: [ { name:"x", type:"Real" }, { name:"y", type:"Real" } ] },
		{ name: "set_size", args: [ { name:"width", type:"Real" }, { name:"height", type:"Real" } ] },
		{ name: "set_enabled", args: [ { name:"enabled", type:"Bool" } ] }
	]);

	// Register WWSprite builders
	ww_inspector_lib_register(_library, "WWSprite", [
		{ name: "set_sprite", args: [ { name:"sprite", type:"Asset.Sprite" } ] },
		{ name: "set_image_index", args: [ { name:"index", type:"Real" } ] }
	]);

	// Register WWButton builders
	ww_inspector_lib_register(_library, "WWButton", [
		{ name: "set_text", args: [ { name:"text", type:"String" } ] },
		{ name: "set_callback", args: [ { name:"callback", type:"Function" } ] }
	]);

	// Root UI
	root = new WWCore()
		.set_offset(0, 0)
		.set_size(420, 700)
		.set_background_color(c_black)
		.set_enabled(true);

	var _theme = {
		text_dim: make_color_rgb(170, 170, 180),
		panel_alt: make_color_rgb(40, 40, 46)
	};

	// Collect sections for leaf constructor "WWButton"
	var _sections = ww_inspector_collect_builders_for_constructor(_library, "WWButton");

	// Build inspector tree into a container
	var _inspector_panel = new WWCore()
		.set_offset(10, 10)
		.set_size(400, 680)
		.set_background_color(make_color_rgb(32, 32, 36));
	root.add(_inspector_panel);

	ww_inspector_build_tree_ui(_inspector_panel, _sections, _theme);

	root.update_component_positions();
	root.__update_group_region__();

	// Keep library around if you want dynamic rebuilds. Otherwise destroy it.
	// ww_inspector_lib_destroy(_library);
};
