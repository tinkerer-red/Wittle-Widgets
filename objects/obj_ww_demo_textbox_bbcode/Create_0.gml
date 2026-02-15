// Define variables
prev_room = rm_ww_demo_textbox_basic;
next_room = rm_ww_demo_textbox_markdown;

title = "BBCode Demo";
subtitle = "Left is input. Right is BBCode renderer.";

#region text
text = @'BBCode renderer demo.
AAAAA
[slider, 0.555,  0, 1, 0.01]
BBBBB
[plot, signal]
CCCCC

[b]Bold text[/b]
[i]Italic text[/i]
[u]Underlined text[/u]

[warn]Warning underline[/warn]
[err]Error underline[/err]

[color=#66ccff]Colored text blue[/color]
[color=#ff6666]Colored text red[/color]
[alpha=0.5]Half alpha text[/alpha]
[size=1.5]Scaled text[/size]

[url]URL styled text[/url]
[url=https://example.com]URL with target[/url]

Font Awesome icons (BBCode [fa, ...] tag):
Quoted string names: [fa, "address-book"] [fa, "user"]
Regular vs solid: [fa, "bell", regular] [fa, "bell", solid]
Brands: [fa, "github", brands]
Packed id (>16-bit): [fa, 126980] [fa, 192516]

[code]
var x = 10;
var y = x * 2;
[/code]

Line break test:[br]Second line after break

Paragraph test:[p]New paragraph starts here

[left]Left aligned text[/left]
[center]Centered text[/center]
[right]Right aligned text[/right]

[left]Left[/left][center]Center[/center][right]Right[/right]';
#endregion

left_init = function(_textbox_instance) {
	_textbox_instance.set_wrap_enabled(false);
};

right_init = function(_textbox_instance) {
	_textbox_instance.set_text_processor(WWTextProcessorBBCode);
	_textbox_instance.set_wrap_enabled(true);
};

// Inherit the parent event
event_inherited();