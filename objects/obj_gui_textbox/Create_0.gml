event_inherited();
var _ideal_h = font_get_info(__CP_FONT).size

widget = new GUICompTextbox()
	.set_alignment(fa_right, fa_top)
	.set_text_placeholder("String...")
	.set_size(300, 100)
	.set_text("")
	.set_text_font(__CP_FONT)
	//.set_text_color(c_white)
	//.set_background_color(#2B2D31)
	//.set_highlight_color(#800000)
	//.set_max_length(infinity)
	.set_char_enforcement()
	.set_multiline(true)
	//.set_text_line_height(1)
	//.set_accepting_inputs(true)
//widget.should_draw_debug = true;

