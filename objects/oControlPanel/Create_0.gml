// Inherit the parent event
event_inherited();

event_user(15);

var _folder = new ControlPanelFolder("This is a test 0123456789This is a test 0123456789This is a test 0123456789This is a test 0123456789This is a test 0123456789", function(){log("Folder")})
	var _folder2 = new ControlPanelFolder("This is a test 0123456789This is a test 0123456789This is a test 0123456789This is a test 0123456789This is a test 0123456789", function(){log("Folder")})
		.set_debug_drawing(true)
		var _button = new ControlPanelButton("Button", function(){log("Button")})
		_folder2.add(_button)
	_folder.add(_folder2)
cc.add(_folder)

var _button = new ControlPanelButton("Button", function(){log("Button")})
_folder.add(_button)

var _checkbox = new ControlPanelCheckbox("Checkbox", function(_bool){log(["Checkbox", _bool])})
//	.set_debug_drawing(true)
//_checkbox.should_draw_debug = true;
_folder.add(_checkbox)

var _dropdown = new ControlPanelDropdown("Dropdown", ["Option 1", "Option 2", "Option 3"], function(_index, _element){log(["Dropdown", _index, _element])})
_folder.add(_dropdown)

var _real = new ControlPanelReal("Real", 50, function(_real){log(["Real", _real])})
_folder.add(_real)

var _string = new ControlPanelString("String", "This is a test", function(_bool){log(["String", _bool])})
_folder.add(_string)

var _slider = new ControlPanelSlider("This is a test 0123456789This is a test 0123456789This is a test 0123456789This is a test 0123456789This is a test 0123456789", 0.25, -10, 10, function(_bool){log(["Working", _bool])})
_folder.add(_slider)

//var _button = new GUICompButtonSprite()
//	.set_sprite(s9ScrollbarHorzButtonRight)
//cc.add(_button)

//var _test = new GUICompTextRegion()
//	.set_text_placeholder("Enter value")
//	.set_region(0, 0, 190, 30)
//	.set_scrollbar_sizes(0, 0)
//	.set_text("Default Value")
//	.set_text_font(__CP_FONT)
//	.set_text_color(c_white)
//	.set_background_color(#1E2F4A)
//	.set_max_length(20)
//	.set_char_enforcement("0123456789")
//	.set_multiline(false)
//	.set_accepting_inputs(true)
//	
//cc.add(_test)
//var __dropdown__ = new GUICompDropdown() //the x/y doesnt matter as the set region will move this
//	.set_position(100, 100)
//	.set_alignment(fa_right, fa_top)
//	.set_dropdown_array(["Option 1", "Option 2", "Option 3"])
//cc.add(__dropdown__)