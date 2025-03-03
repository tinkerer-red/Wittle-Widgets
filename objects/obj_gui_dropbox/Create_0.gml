event_inherited();
var _ideal_h = font_get_info(__CP_FONT).size

var _info = sprite_get_nineslice(s9CPDropDown);
var _arr_of_str = ["Option 1", "Option 2", "Option 3"]
widget = new GUICompDropdown() //the x/y doesnt matter as the set region will move this
	.set_alignment(fa_left, fa_top)
	.set_dropdown_sprites(s9CPDropDown, s9CPDropDownTop, s9CPDropDownMiddle, s9CPDropDownBottom)
	.set_dropdown_array(_arr_of_str)
	.set_sprite_to_auto_wrap()
//widget.set_offset(-_info.right - __dropdown__.__group_region__.get_width(), +_info.top)

/*
widget = new GUICompDropdown()
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

