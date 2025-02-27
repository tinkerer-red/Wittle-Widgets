event_inherited();

show_debug_overlay(true);

var _thing = new GUICompTextbox(128, 128)
textbox = _thing;
_thing//.set_enabled()
      .set_region(0, 0, 210, 256)
			.set_smooth_scrolling(true)
			//.set_scrollbar_horz_sprites(_bg, _thumb, _dec, _inc)
			//.set_scrollbar_vert_sprites(_bg, _thumb, _dec, _inc)
			.set_scrollbar_button_usage(false)
			.set_scrollbar_sizes(24, 24)
			//.set_vert_scroll(_y_off=0)
			//.set_horz_scroll(_x_off=0)
			
			.set_text_placeholder("a\nb\nc\nd")
			.set_text("This is a test")
      //.set_text_font()
      //.set_text_color(c_red)
      //.set_text_line_height()
      //.set_text_offsets()
      //.set_highlight_color()
      //.set_background_color()
      //.set_scrollbar_visible()
      //.set_max_length()
      //.set_records_limit()
      //.set_char_enforcement()
      //.set_multiline()
      //.set_force_wrapping()
      .set_shift_only_new_line(false)
      //.set_accepting_inputs()
      //.set_copy_override()
      //.set_paste_override()




log("\n\nadding thing\n\n")
cc.add(_thing);

/*
var _folder = new GUICompFolder(100,20)
	.set_text("Folder")
	.set_sprite_to_auto_wrap()
	.set_alignment(fa_left, fa_top)

var _btn = new GUICompButtonSprite(0,0)
var _drp = new GUICompDropdown(0,0)
		_drp.set_dropdown_array(["Red", "Blue", "Green", "Orange"])
var _chk = new GUICompCheckbox(0,0)

_folder.add([_btn, _drp, _chk]);

_controller.add(_folder);
*/
//var _btn = new GUICompButtonText(100,60)
//	_btn.set_text("This is a button")
//	_btn.set_text_offsets(0,0,2)
//	_btn.set_sprite_to_auto_wrap()

//_controller.add(_btn);



//var _adjustment_spacing = move_speed; //how far from the outer eadge to check the inner collisions, roughly your move speed, but can be any number
//var _height_dist = 2; //how many pixels above the player's head to check, this will want to be > or = to your jump speed
//
//var _left_outer = collision_point(bbox_left, bbox_top, obj_solid, false, true);
//var _left_inner = collision_point(bbox_left+_adjustment_spacing, bbox_top-_height_dist, obj_solid, false, true);
//if (_left_outer) && (!_left_inner) { //if we barely touched a block on the left
//	//move right
//}
//var _right_outer = collision_point(bbox_right, bbox_top, obj_solid, false, true);
//var _right_inner = collision_point(bbox_right-_adjustment_spacing, bbox_top-_height_dist, obj_solid, false, true);
//if (_right_outer) && (!_right_inner) { //if we barely touched a block on the right
//	//move left
//}


