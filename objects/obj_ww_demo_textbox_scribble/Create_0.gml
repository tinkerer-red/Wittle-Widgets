// Define variables
prev_room = rm_ww_demo_textbox_css;
next_room = rm_ww_demo_textbox_gml;

title = "Scribble Demo";
subtitle = "Left is input. Right is Scribble renderer.";

#region text
text = @''
#endregion

left_init = function(_textbox_instance) {
	_textbox_instance.set_renderer(WWTextRenderer);
	_textbox_instance.set_wrap_enabled(false);
};

right_init = function(_textbox_instance) {
	//_textbox_instance.set_renderer(WWTextRendererScribble);
	//_textbox_instance.set_wrap_enabled(true);
};

// Inherit the parent event
event_inherited()