// Inherit the parent event
event_inherited();

event_user(15);

//var _button = new ControlPanelButton("Button 1", function(){log("Working")})
//cc.add(_button)

//var _checkbox = new ControlPanelCheckbox("This is a test 0123456789This is a test 0123456789This is a test 0123456789This is a test 0123456789This is a test 0123456789", function(_bool){log(["Working", _bool])})
//cc.add(_checkbox)

//var _checkbox = new ControlPanelCheckbox("This is a test 0123456789This is a test 0123456789This is a test 0123456789This is a test 0123456789This is a test 0123456789", function(_bool){log(["Working", _bool])})
//cc.add(_checkbox)

var _dropdown = new ControlPanelDropdown("This is a test 0123456789This is a test 0123456789This is a test 0123456789This is a test 0123456789This is a test 0123456789", ["Option 1", "Option 2", "Option 3"], function(_bool){log(["Working", _bool])})
	.set_anchor(100, 100)
	.set_position(100, 100)
	.set_alignment(fa_left, fa_top)
cc.add(_dropdown)

//var __dropdown__ = new GUICompDropdown() //the x/y doesnt matter as the set region will move this
//	.set_position(100, 100)
//	.set_alignment(fa_right, fa_top)
//	.set_dropdown_array(["Option 1", "Option 2", "Option 3"])
//cc.add(__dropdown__)