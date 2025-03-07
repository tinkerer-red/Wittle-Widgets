// Create the root GUI window.
root = new WWCore()
    .set_offset(0, 0)
    .set_size(1280, 720)
    .set_background_color(c_black)
    .set_enabled(true);

// -------------------------------------------------------------
// Test 1: Basic Text Rendering & Selection
// -------------------------------------------------------------
var basicTextBox = new WWTextBase()
    .set_offset(50, 50)
    .set_size(600, 150)
    .set_text("Basic Test:\nThis is a basic test of text rendering and selection.\nIt should display three lines.")
    .set_text_color(c_white)
    .set_highlight_color(c_lime)
    .set_line_height(22);
// Simulate a selection on the second line (index 1)
basicTextBox.highlight_selected = true;
basicTextBox.highlight_y_pos = 1;  // Second line
basicTextBox.highlight_x_pos = 8;  // Selection starts at character index 8
basicTextBox.set_cursor_x_pos(20); // And the cursor is set at index 20 on that same line

// Bind a Ctrl+C hotkey to copy selection from basicTextBox.
//basicTextBox.on_pre_step(function(_input){
//    if (keyboard_check(vk_control) && keyboard_check_pressed(ord("C"))) {
//        var copied = basicTextBox.__copy_string__();
//        clipboard_set_text(copied);
//        show_debug_message("BasicTextBox copied: " + copied);
//    }
//});
root.add(basicTextBox);

// -------------------------------------------------------------
// Test 2: Dynamic Width TextBox
// -------------------------------------------------------------
var dynamicWidthTextBox = new WWTextBase()
    .set_offset(50, 220)
    .set_size(600, 150)
    .set_text("Dynamic Width Test: This text should adjust its line breaks automatically if it exceeds the width of the box. Dynamic width is enabled.")
    .set_text_color(c_white)
    .set_highlight_color(c_blue)
    .set_line_height(22)
    .set_dynamic_width(true); // Enable dynamic width so lines don't wrap unnecessarily
root.add(dynamicWidthTextBox);

// -------------------------------------------------------------
// Test 3: Custom Font TextBox
// -------------------------------------------------------------
// (Assume customFont is a valid font asset defined in your project.)
var customFontTextBox = new WWTextBase()
    .set_offset(50, 390)
    .set_size(600, 150)
    .set_text("Custom Font Test:\nThe quick brown fox jumps over the lazy dog.\nEnjoy the custom styling!")
    .set_text_font(fGUIDefaultBig)  // customFont must be defined in your project
    .set_text_color(c_white)
    .set_highlight_color(c_orange)
    .set_line_height(24);
root.add(customFontTextBox);

// -------------------------------------------------------------
// Test 4: Long Text with Scrolling/Line Breaking
// -------------------------------------------------------------
var longText = "Scrolling Test:\n" + string_repeat("Lorem ipsum dolor sit amet, consectetur adipiscing elit. ", 10);
var longTextBox = new WWTextBase()
    .set_offset(700, 50)
    .set_size(500, 300)
    .set_text(longText)
    .set_text_color(c_white)
    .set_highlight_color(c_red)
    .set_line_height(20);
root.add(longTextBox);