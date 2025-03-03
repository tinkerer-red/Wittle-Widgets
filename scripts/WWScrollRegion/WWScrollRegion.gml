#region jsDoc
/// @func    WWScrollRegion()
/// @desc    A scrollable region that contains a larger canvas of content.
/// @returns {Struct.WWScrollRegion}
#endregion
function WWScrollRegion() : WWCore() constructor {
    debug_name = "WWScrollRegion";
	
	#region Public
		
		#region Builder Functions
			
		#endregion
		
		#region Events
			
		#endregion
		
		#region Variables
			
			viewport_width = 100;
		    viewport_height = 100;
		    canvas_width = 100;
		    canvas_height = 100;
		    scroll_x = 0;
		    scroll_y = 0;
			
		#endregion
	
		#region Functions
			
		#endregion
		
	#endregion
	
	#region Private
		
		#region Variables
			
		#endregion
		
		#region Functions
			
		#endregion
		
	#endregion
	
    #region Components
    
    viewport = new WWCore()
        .set_size(0, 0, viewport_width, viewport_height)
        .set_clipping(true); // Ensures content outside the viewport is hidden.
		
		//ad sub-child canvas
		canvas = new WWCore()
	        .set_size(0, 0, canvas_width, canvas_height);
		
	    viewport.add(canvas);
		
	
    scrollbar_horz = new WWScrollbarHorz()
        .set_size(0, 0, viewport_width, 16)
        .set_canvas_size(canvas_width)
        .set_coverage_size(viewport_width)
        .set_callback(function() {
            set_scroll_x(scrollbar_horz.get_value());
        });
    
    scrollbar_vert = new WWScrollbarVert()
        .set_size(0, 0, 16, viewport_height)
        .set_canvas_size(canvas_height)
        .set_coverage_size(viewport_height)
        .set_callback(function() {
            set_scroll_y(scrollbar_vert.get_value());
        });

    add([viewport, scrollbar_horz, scrollbar_vert]);
	
	
	
	
    #endregion

    #region 📌 Scrolling Logic

    /// @desc Updates the horizontal scroll position.
    static set_scroll_x = function(_x) {
        scroll_x = clamp(_x, 0, max(0, canvas_width - viewport_width));
        canvas.set_offset(-scroll_x, -scroll_y);
    };

    /// @desc Updates the vertical scroll position.
    static set_scroll_y = function(_y) {
        scroll_y = clamp(_y, 0, max(0, canvas_height - viewport_height));
        canvas.set_offset(-scroll_x, -scroll_y);
    };

    /// @desc Adjusts scrollbars when content size changes.
    static update_scrollbars = function() {
        scrollbar_horz.set_canvas_size(canvas_width);
        scrollbar_horz.set_coverage_size(viewport_width);
        
        scrollbar_vert.set_canvas_size(canvas_height);
        scrollbar_vert.set_coverage_size(viewport_height);
    };

    /// @desc Sets the size of the viewport.
    static set_viewport_size = function(_width, _height) {
        viewport_width = _width;
        viewport_height = _height;
        viewport.set_size(0, 0, viewport_width, viewport_height);
        update_scrollbars();
        return self;
    };

    /// @desc Sets the size of the canvas (content area).
    static set_canvas_size = function(_width, _height) {
        canvas_width = _width;
        canvas_height = _height;
        canvas.set_size(0, 0, canvas_width, canvas_height);
        update_scrollbars();
        return self;
    };

    #endregion

    #region 📌 Mouse Wheel Scrolling

    on_scroll(function(_input) {
        var _scroll_delta = -_input.scroll_y * 10;
        set_scroll_y(scroll_y + _scroll_delta);
        scrollbar_vert.set_value(scroll_y);
    });

    #endregion
}
