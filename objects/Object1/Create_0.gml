// Create the root GUI component at (0, 0) with a size of 400x300
root = new GUICompCore()
    .set_position(0, 0)
    .set_size(0, 0, 400, 300)
    .set_enabled(true)
    .on_pre_step(function(_input) {
        // Move root one pixel to the right each frame.
        root.set_position(root.x + 1, root.y);
    });

// Create a button with text, positioned relative to root
button = new GUICompCheckbox()
    .set_offset(20, 20) // Positioned 20px right and 20px down from root
    .set_size(0, 0, 120, 40) // Set button size (width: 120px, height: 40px)
    .set_enabled(true)
    .set_callback(function(_data){ log(_data.is_checked) })
    .on_pre_step(function(_input) {
        // Move button left one pixel relative to parent
        button.set_offset(button.x_offset - 1, button.y_offset);
    });

// Add the button to the root component
root.add(button);

// Test: Change root position and ensure child follows
root.set_position(200, 150); // Moves root to (200,150), button moves to (220,170)
