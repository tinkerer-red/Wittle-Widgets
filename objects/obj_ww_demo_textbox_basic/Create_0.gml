// Define variables
prev_room = undefined;
next_room = rm_ww_demo_textbox_bbcode;

title = "Basic Demo";
subtitle = "Left is basic. Right is specalized renderer.";

#region text
text = @'
Base and advanced text demo.

This textbox shows raw editable text.
The preview mirrors input exactly.

Core editing:
- Cursor movement
- Selection
- Backspace and delete
- Multi line edits

Whitespace behavior:
Multiple spaces are preserved.    
Trailing spaces are visible.    

Tabs:
	One
	Two
	Three

Alignment and wrapping:
Resize the textbox to see how lines wrap.
Long words will only wrap if they cannot fit
inside the available width.

Underline spans and whitespace markers
should only appear when enabled
in the advanced renderer.

This demo combines the base and advanced
features into a single focused example.
';
#endregion

left_init = function(_textbox_instance) {
	_textbox_instance.set_renderer(WWTextRendererBase);
	_textbox_instance.set_wrap_enabled(false);
};

right_init = function(_textbox_instance) {
	_textbox_instance.set_renderer(WWTextRendererBase);
	_textbox_instance.set_wrap_enabled(true);
				
	// Font is a textbox concern, keep it here
	_textbox_instance.set_text_font(fnt_ww_consolas_10);
				
	// Advanced-only toggles live on the renderer instance now
	var _renderer = _textbox_instance.get_renderer();
	_renderer.set_whitespace_visible(true);
	_renderer.set_whitespace_alpha(0.45);
};

// Inherit the parent event
event_inherited();