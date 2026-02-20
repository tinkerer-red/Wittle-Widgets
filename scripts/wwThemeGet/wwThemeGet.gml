function __wwThemeGetTyped(_fallback_key, _keys) {
	var _flat = global.ww_theme_flat;
	var _n = array_length(_keys);

	for (var i = 0; i < _n; i++) {
		var _candidate = _keys[i];
		if (is_undefined(_candidate)) continue;

		// Literal direct value support (non-string means "use this value now").
		if (!is_string(_candidate)) return _candidate;

		if (_candidate != "" && variable_struct_exists(_flat, _candidate)) {
			return variable_struct_get(_flat, _candidate);
		}
	}

	return variable_struct_get(_flat, _fallback_key);
}

function wwThemeGetColor() {
	var _keys = [];
	for (var i = 0; i < argument_count; i++) array_push(_keys, argument[i]);
	return __wwThemeGetTyped("fallback.color", _keys);
}

function wwThemeGetSprite() {
	var _keys = [];
	for (var i = 0; i < argument_count; i++) array_push(_keys, argument[i]);
	return __wwThemeGetTyped("fallback.sprite", _keys);
}

function wwThemeGetIcon() {
	var _keys = [];
	for (var i = 0; i < argument_count; i++) array_push(_keys, argument[i]);
	return __wwThemeGetTyped("fallback.icon", _keys);
}

function wwThemeGetAlpha() {
	var _keys = [];
	for (var i = 0; i < argument_count; i++) array_push(_keys, argument[i]);
	return __wwThemeGetTyped("fallback.alpha", _keys);
}

function wwThemeGetSize() {
	var _keys = [];
	for (var i = 0; i < argument_count; i++) array_push(_keys, argument[i]);
	return __wwThemeGetTyped("fallback.size", _keys);
}

function wwThemeGetFont() {
	var _keys = [];
	for (var i = 0; i < argument_count; i++) array_push(_keys, argument[i]);
	return __wwThemeGetTyped("fallback.font", _keys);
}
