// Inherit the parent event
event_inherited();
show_debug_overlay(true)

event_user(15);

control_panel = new ControlPanelFolder(" > Control Panel", function(){
	var _text = (control_panel.is_open) ? " V Control Panel" : " > Control Panel";
	control_panel.set_text(_text)
})

cc.add(control_panel)

#region Folder 1
var _folder = new ControlPanelFolder("Folder 1", function(){log("Folder 1")})
	
	#region Folder 2
	var _folder2 = new ControlPanelFolder("Folder 2", function(){log("Folder 2")})
		var _button1 = new ControlPanelButton("Button 1", function(){log("Button")})
		
		#region Folder 3
		var _folder3 = new ControlPanelFolder("Folder 3", function(){log("Folder 2")})
			var _button2 = new ControlPanelButton("Button 2", function(){log("Button")})
			var _checkbox1 = new ControlPanelCheckbox("Checkbox 1", function(_bool){log(["Checkbox", _bool])})
			var _dropdown1 = new ControlPanelDropdown("Dropdown 1", ["Option 1", "Option 2", "Option 3"], function(_index, _element){log(["Dropdown", _index, _element])})
			var _real1 = new ControlPanelReal("Real 1", 50, function(_real){log(["Real", _real])})
			var _string1 = new ControlPanelString("String 1", "This is a test", function(_bool){log(["String", _bool])})
			var _slider1 = new ControlPanelSlider("Slider 1", 0.25, -10, 10, function(_bool){log(["Slider", _bool])})
			_folder3.add([_button2, _checkbox1, _dropdown1, _real1, _string1, _slider1])
			
		#endregion
		_folder2.add([_button1, _folder3])
		
	#endregion
	
	var _button3 = new ControlPanelButton("Button 3", function(){log("Button")})
	var _checkbox2 = new ControlPanelCheckbox("Checkbox 2", function(_bool){log(["Checkbox", _bool])})
	var _dropdown2 = new ControlPanelDropdown("Dropdown 2", ["Option 1", "Option 2", "Option 3"], function(_index, _element){log(["Dropdown", _index, _element])})
	var _real2 = new ControlPanelReal("Real 2", 50, function(_real){log(["Real", _real])})
	var _string2 = new ControlPanelString("String 2", "This is a test", function(_bool){log(["String", _bool])})
	var _slider2 = new ControlPanelSlider("Slider 2", 0.25, -10, 10, function(_bool){log(["Slider", _bool])})

	_folder.add([_folder2, _button3, _checkbox2, _dropdown2, _real2, _string2, _slider2])
	
#endregion
control_panel.add(_folder)

repeat(50) {
#region Folder 4

var _folder4 = new ControlPanelFolder("Folder 4", function(){log("Folder 1")})
	var _button4 = new ControlPanelButton("Button 4", function(){log("Button")})
	var _checkbox3 = new ControlPanelCheckbox("Checkbox 3", function(_bool){log(["Checkbox", _bool])})
	var _dropdown3 = new ControlPanelDropdown("Dropdown 3", ["Option 1", "Option 2", "Option 3"], function(_index, _element){log(["Dropdown", _index, _element])})
	var _real3 = new ControlPanelReal("Real 3", 50, function(_real){log(["Real", _real])})
	var _string3 = new ControlPanelString("String 3", "This is a test", function(_bool){log(["String", _bool])})
	var _slider3 = new ControlPanelSlider("Slider 3", 0.25, -10, 10, function(_bool){log(["Slider", _bool])})
	_folder4.add([_button4, _checkbox3, _dropdown3, _real3, _string3, _slider3]);

#endregion
control_panel.add(_folder4)
}