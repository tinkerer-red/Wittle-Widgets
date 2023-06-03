cc = new GUICompHandler();

#region super test
/*
a = new A();
b = new B();
//c = new C();
//d = new D();
//e = new E();

//log(["a.get_name()", a.get_name()])
log(["a.get_real_name()", a.get_real_name()])

log("\n\n=====\n\n")

//log(["b.get_name()", b.get_name()])
log(["b.get_real_name()", b.get_real_name()])

//log("\n\n=====\n\n")
//
//log(["c.get_name()", c.get_name()])
//log(["c.get_real_name()", c.get_real_name()])
//
//log("\n\n=====\n\n")
//
//log(["d.get_name()", d.get_name()])
//log(["d.get_real_name()", d.get_real_name()])
//
//log("\n\n=====\n\n")
//
//log(["e.get_name()", e.get_name()])
//log(["e.get_real_name()", e.get_real_name()])
//*/
#endregion


//var _controller = new GUICompController(0,0);
//_controller.draw_gui = function(_input){ draw_circle(x,y, 9, true)}
//cc.add(_controller);

//var _core = new GUICompCore(0,0);
//_core.draw_gui = function(_input){ draw_circle(x,y, 4, true)}
//_controller.add(_core);

//var _thing = new GUICompFolder(0,0)
//_thing.set_alignment(fa_left, fa_top)

//var _thing = new GUICompScrollBar(128,128)
//			.set_region(0,0,124,128)
//			.set_canvas_size(256)
//			.set_coverage_size(128)
//			.set_vertical(true)
//			.set_background_sprite(s9ScrollbarVertBackground)
			

//_thing.add(_scroll)


//var _thing = new GUICompRegion(128,128)
//					.set_region(0,0, 400, 240)
//					.set_scrollbar_sizes(24, 24)
//					.set_canvas_size(400*2, 240*2)
//		      .set_scrollbar_horz_sprites(s9ScrollbarHorzBackground, s9ScrollbarThumb, s9ScrollbarHorzButtonLeft, s9ScrollbarHorzButtonRight)
//					.set_scrollbar_vert_sprites(s9ScrollbarVertBackground, s9ScrollbarThumb, s9ScrollbarVertButtonUp, s9ScrollbarVertButtonDown)
//		      //.set_scrollbar_button_usage(true)
//					//.set_button_sprites(s9ScrollbarHorzButtonLeft, s9ScrollbarHorzButtonRight)
//					//.set_background_sprite(s9ScrollbarHorzBackground)
//					//.set_smooth_scrolling(true)
//
//var _btn = new GUICompButtonSprite(128,128)
//var _drp = new GUICompDropdown(250,720)
//		_drp.set_dropdown_array(["Red", "Blue", "Green", "Orange"])
//var _chk = new GUICompCheckbox(167,500)
//
//_thing.add([_btn, _drp, _chk])

//_thing.add_event_listener(_thing.events.value_input      , function(){show_debug_message("1")})
//_thing.add_event_listener(_thing.events.value_changed    , function(){show_debug_message("2")})
//_thing.add_event_listener(_thing.events.value_incremented, function(){show_debug_message("3")})
//_thing.add_event_listener(_thing.events.value_decremented, function(){show_debug_message("4")})


show_debug_overlay(true);


var _thing = new GUICompTextRegion(128, 128)
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


