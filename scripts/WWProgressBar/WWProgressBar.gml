#region jsDoc
/// @func    WWProgressBar()
/// @desc    A visual indicator of task progress.
/// @returns {Struct.WWProgressBar}
#endregion
function WWProgressBar() : WWSlider() constructor {
    debug_name = "WWProgressBar";
    // Disable user input for progress display.
    set_input_enabled(false);
    static draw = function(_input) {
        // Draw the background
        draw_set_color(c_gray);
        draw_rectangle(x, y, x + width, y + height, true);
        // Draw the filled progress bar
        draw_set_color(c_green);
        draw_rectangle(x, y, x + width * normalized_value, y + height, true);
    }
}
