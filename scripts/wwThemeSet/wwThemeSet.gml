function wwThemeSet(_theme_or_layers = undefined, _opts = undefined) {
	// Always build a compiled theme for fast direct lookups.
	var _built_theme = wwThemeBuild(_theme_or_layers, _opts);

	// Store as the canonical current theme.
	global.ww_theme = _built_theme;

	return _built_theme;
}