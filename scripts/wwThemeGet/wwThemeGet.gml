function wwThemeGet(){
	if (!variable_global_exists("ww_theme")) {
		global.ww_theme = wwThemeBuild(wwThemeDefault());
	}
	return global.ww_theme;
}