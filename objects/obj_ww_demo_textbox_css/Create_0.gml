// Define variables
prev_room = rm_ww_demo_textbox_markdown;
next_room = rm_ww_demo_textbox_scribble;

title = "CSS Demo";
subtitle = "Left is input. Right is CSS renderer.";

#region text
text = @'
<style>
.root        { color:#d8dee9; opacity:1; font-size:1em; font-family:ui; }
.muted       { color:#9aa4b2; opacity:0.85; }
.strong      { font-weight:bold; }
.emph        { font-style:italic; }
.link        { color:#7aa2f7; text-decoration:underline; }
.warn        { color:#ffcc66; text-decoration:underline; background-color:#332a10; opacity:0.95; }
.error       { color:#ff5c5c; text-decoration:underline; background-color:#3a1010; opacity:1; }
.strike      { text-decoration:line-through; opacity:0.9; }
.code        { font-family:mono; background-color:#1b1f2a; opacity:1; }
.pill        { background-color:#203049; color:#cde8ff; font-weight:bold; }
.hi_green    { background-color:#103a22; color:#b6ffcf; }
.hi_pink     { background-color:#3a1030; color:#ffd1f0; }
.big         { font-size:1.35em; }
.small       { font-size:0.85em; }
</style>

<span class="root">
CSS renderer demo.

<span class="muted">Muted text using class rules.</span>
<span class="strong">Bold text.</span>
<span class="emph">Italic text.</span>
<span class="strong emph">Bold and italic combined.</span>

Inline override example:
<span class="muted" style="color:#ffffff; opacity:1">Forced white text.</span>

Underline and strike:
<span class="link">Underlined link style</span>
<span class="strike">Strike through text</span>
<span class="link strike">Underline and strike together</span>

Background highlights:
<span class="hi_green">Green highlight</span>
<span class="hi_pink">Pink highlight</span>
<span class="pill">PILL TAG</span>
<span class="code">Inline code span</span>

Opacity demo:
<span style="color:#7aa2f7; opacity:1">Opacity 100</span>
<span style="color:#7aa2f7; opacity:0.6">Opacity 60</span>
<span style="color:#7aa2f7; opacity:0.3">Opacity 30</span>

Warnings and errors:
<span class="warn">Warning message span</span>
<span class="error">Error message span</span>

Font sizes:
<span class="small">Small text</span>
<span class="root">Normal text</span>
<span class="big">Large text</span>

Tabs:
	Column A	Column B	Column C
	Alpha		Bravo		Charlie

Wrapping stress test:
ThisLineIsVeryLongAndShouldOnlyWrapWhenTheTextboxIsTooNarrowToContainIt

End of CSS demo.
</span>
';
#endregion

left_init = function(_textbox_instance) {
    _textbox_instance.set_renderer(WWTextRendererBase);
    _textbox_instance.set_text_font(fnt_ww_consolas_msdf);
    _textbox_instance.set_wrap_enabled(true);
};

right_init = function(_textbox_instance) {
    _textbox_instance.set_renderer(WWTextRendererCSS);
    _textbox_instance.set_text_font(fnt_ww_consolas_msdf);
    _textbox_instance.set_wrap_enabled(true);
};

// Inherit the parent event
event_inherited();
