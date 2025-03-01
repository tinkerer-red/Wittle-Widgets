// Root component at (100,100)
root = new GUICompCore()
    .set_position(0, 0)
    .set_size(0, 0, 400, 300)
    .set_enabled(true)
	.on_pre_step(function(_input) {
        // Move comp2 one pixel to the right each frame.
        root.set_position(root.x + 1, root.y);
	})
    
// Child component (automatically placed relative to root at offset (20,20))
child = new GUICompButtonSprite()
    .set_offset(0, 0)
    .set_size(0, 0, 50, 50)
    .set_enabled(true)
	.on_pre_step(function(_input) {
        // Move comp2 one pixel to the right each frame.
        child.set_offset(child.x_offset - 1, child.y_offset);
	})

// Add child to root (it is automatically placed at 120,120)
root.add(child);

// Move root (child moves with it)
root.set_position(200, 200); // Child now moves to (220,220)
