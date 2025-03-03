// Container for all test elements
root = new WWCore()
    .set_size(0, 0, display_get_width(), display_get_height());

// ================================
// **TEST 1: Generic Scrolling Canvas**
// ================================
var _scrollCanvas = new WWScrollingCanvas()
    .set_position(50, 50)
    .set_size(250, 250) // Viewport size
    .set_scroll_speeds(1, 1)    // Move diagonally
    .set_scroll_looping(true, true);
    
// Add a dummy canvas (Could be an image or any component)
var _dummyCanvas = new WWButton()
    .set_size(0, 0, 500, 500); // Oversized canvas for testing
_scrollCanvas.set_canvas(_dummyCanvas);

root.add(_scrollCanvas);

// ================================
// **TEST 2: Horizontal Scrolling Text**
// ================================
var _scrollTextHorz = new WWTextScrolling()
    .set_position(300, 50) // Viewport size
    .set_size(550, 100) // Viewport size
    .set_scroll_speeds(-2, 0) // Moves left
    .set_scroll_looping(true, false)
    .set_text("This text scrolls left and loops!")
    .set_text_font(fGUIDefaultBig)
    .set_text_color(c_red);

root.add(_scrollTextHorz);

// ================================
// **TEST 3: Vertical Scrolling Text (Bouncing)**
// ================================
var _scrollTextVert = new WWTextScrolling()
    .set_position(600, 50) // Viewport size
    .set_size(850, 150) // Viewport size
    .set_scroll_speeds(0, 2) // Moves down
    .set_scroll_looping(false, false) // No looping, will bounce
    .set_text("This text moves up and down without looping.")
    .set_text_font(fGUIDefaultBig)
    .set_text_color(c_blue);

root.add(_scrollTextVert);

// ================================
// **TEST 4: Scribble Scrolling Text**
// ================================
var _scribText = scribble("This is Scribble scrolling text!");
    
var _scrollScribble = new WWTextScribbleScrolling()
    .set_position(50, 200)
    .set_size(350, 300)
    .set_scroll_speeds(-1, 0)
    .set_scroll_looping(true, false)
    .set_scribble(_scribText);

root.add(_scrollScribble);

// ================================
// **TEST 5: Nested Scrolling Viewports**
// ================================
var _nestedViewportOuter = new WWScrollingCanvas()
    .set_position(400, 200)
    .set_size(700, 400)
    .set_scroll_speeds(0, 1)
    .set_scroll_looping(false, true);

var _nestedViewportInner = new WWScrollingCanvas()
    .set_position(0, 0)
    .set_size(200, 300)
    .set_scroll_speeds(2, 0)
    .set_scroll_looping(true, false);

var _nestedText = new WWText()
    .set_text("Nested scrolling viewport")
    .set_text_color(c_white)
    .set_size(0, 0, 500, 100);

_nestedViewportInner.set_canvas(_nestedText);
_nestedViewportOuter.set_canvas(_nestedViewportInner);

root.add(_nestedViewportOuter);

// ================================
// **TEST 6: Paused and Resumed Scrolling**
// ================================
var _pausedScroll = new WWTextScrolling()
    .set_position(50, 350)
    .set_size(500, 400)
    .set_scroll_speeds(-2, 0)
    .set_scroll_looping(true, false)
    .set_text("Paused scrolling test - click to resume")
    .set_text_font(fGUIDefaultBig)
    .set_text_color(c_yellow)
    .set_scroll_pause(true);

_pausedScroll.on_pressed(function() {
    _pausedScroll.set_scroll_pause(false);
});

root.add(_pausedScroll);
