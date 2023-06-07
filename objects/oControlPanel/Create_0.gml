// Inherit the parent event
event_inherited();

event_user(15);

//var _button = new ControlPanelButton("Button 1", function(){log("Working")})
//cc.add(_button)

var _checkbox = new ControlPanelCheckbox("This is a test 0123456789This is a test 0123456789This is a test 0123456789This is a test 0123456789This is a test 0123456789", function(){log("Working")})
_checkbox.x = 0
_checkbox.y = 0
_checkbox.xstart = 0
_checkbox.ystart = 0
_checkbox.xprevious = 0
_checkbox.yprevious = 0

log(["_checkbox.__button__.x", _checkbox.__button__.x])
log(["_checkbox.__checkbox__.x", _checkbox.__checkbox__.x])
log("\n")
cc.add(_checkbox)
log("\n")
log(["_checkbox.__anchors__", _checkbox.__anchors__])
log(["_checkbox.__button__.x", _checkbox.__button__.x])
log(["_checkbox.__checkbox__.x", _checkbox.__checkbox__.x])
