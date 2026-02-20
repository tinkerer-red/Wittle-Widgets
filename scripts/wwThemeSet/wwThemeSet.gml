function wwThemeSet(_theme_or_layers = undefined, _opts = undefined) {
	// Always build a compiled theme for fast direct lookups.
	var _built_theme = wwThemeBuild(_theme_or_layers, _opts);

	// Keep source around so callers can trigger a rebuild/reload quickly.
	global.ww_theme_source = variable_clone(_theme_or_layers);
	global.ww_theme_build_opts = variable_clone(_opts);

	// Store as the canonical current theme.
	global.ww_theme = _built_theme;
	global.ww_theme_flat = wwThemeCompile(_built_theme);

	return _built_theme;
}

function wwThemeReload() {
	var _source = variable_global_exists("ww_theme_source") ? global.ww_theme_source : undefined;
	var _opts = variable_global_exists("ww_theme_build_opts") ? global.ww_theme_build_opts : undefined;
	return wwThemeSet(_source, _opts);
}
