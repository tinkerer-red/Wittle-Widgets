event_user(15);

build_ui_text_boxes()
root = new WWCore();

my_font = font_add_sprite(s9GUIPixel, ord("!"), true, 1)
font_replace_sprite_ext(my_font, sprEmojiTwemojiStrip, "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`", false, 1);

show_debug_overlay(true)