// Define variables
prev_room = rm_ww_demo_textbox_bbcode;
next_room = rm_ww_demo_textbox_css;

title = "Markdown Demo";
subtitle = "Left is input. Right is Markdown renderer.";

#region text
text = @'Markdown renderer demo.

# Heading level one
## Heading level two
### Heading level three

Normal text with **bold**, *italic*,
and **bold *italic inside* bold**.

~~Strikethrough example~~

> Blockquote line one
> Blockquote line two
>
> Blockquote with **bold** and inline code

Ordered list:
1. First item
2. Second item
3. Third item

Unordered list:
- Alpha
- Bravo
- Charlie

Task list:
- [x] Completed task
- [ ] Pending task

Horizontal rule below

---

Table example:
| Name | Value |
| ---- | ----- |
| Alpha | One |
| Beta | Two |

Fenced code block:
```
{
value: 42,
enabled: true
}
```';
#endregion

left_init = function(_textbox_instance) {
	_textbox_instance.set_wrap_enabled(false);
};

right_init = function(_textbox_instance) {
	_textbox_instance.set_text_processor(WWTextProcessorMarkdown);
	_textbox_instance.set_wrap_enabled(true);
	_textbox_instance.set_text_font(fnt_ww_default_small_msdf);
};

// Inherit the parent event
event_inherited()