// Define variables
prev_room = rm_ww_demo_textbox_scribble;
next_room = undefined;

title = "GML Demo";
subtitle = "Left is input. Right is GML renderer.";

#region text
text = @'
function demo_example() {
	var counter_value = 0;
	var message_text = "Hello";

	if (counter_value == 0) {
		message_text += " ready";
	}

	return message_text;
}

This block is intended to preview
syntax highlighting and code layout.
';
#endregion

left_init = function(_textbox_instance) {
	_textbox_instance.set_renderer(WWTextRendererBase);
	_textbox_instance.set_wrap_enabled(false);
	_textbox_instance.set_text_font(fnt_ww_default_small);
};

right_init = function(_textbox_instance) {
    //_textbox_instance.set_renderer(WWTextRendererGML);
    _textbox_instance.set_text_font(fnt_ww_consolas_msdf);
    _textbox_instance.set_wrap_enabled(false);
};

// Inherit the parent event
event_inherited()