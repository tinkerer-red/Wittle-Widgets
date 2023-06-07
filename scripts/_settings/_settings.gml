if (__SETTINGS_AUTO_SCALE) {
	time_source_start(time_source_create(time_source_game, 1, time_source_units_frames, function(){
		static is_browser = (os_browser != browser_not_a_browser)
		
		static get_current_width  = (is_browser) ? function() {return browser_width}  : window_get_width;
		static get_current_height = (is_browser) ? function() {return browser_height} : window_get_height;
		
		var _width = get_current_width();
		var _height = get_current_height();
		
		if (camera_get_view_width(0) != _width)
		|| (camera_get_view_height(0) != _height) {
			//resize the browser's window
			if (is_browser) {
				window_set_size(browser_width, browser_height);
			}
			
			camera_set_view_size(view_camera[0], _width, _height);
			surface_resize(application_surface, _width, _height);
		}
		
	}
	,[],-1));
}

if (!__SETTINGS_ALLOW_WINDOW_RESIZE_HORZ) {
	time_source_start(time_source_create(time_source_game, 2, time_source_units_frames, function(){
		
		static is_browser = (os_browser != browser_not_a_browser)
		
		static get_current_width  = (is_browser) ? function() {return browser_width}  : window_get_width;
		static get_current_height = (is_browser) ? function() {return browser_height} : window_get_height;
		
		if (get_current_width() != 0) {
			static data = {
				width : get_current_width(),
				x : window_get_x(),
			}
			
			if (get_current_width() != data.width) {
				//resize the browser's window
				if (is_browser) {
					window_set_size(data.width, browser_height);
				}
				else {
					window_set_size(data.width, get_current_height());
					window_set_position(data.x, window_get_y());
				}
				
				camera_set_view_size(view_camera[0], data.width, get_current_height());
				surface_resize(application_surface,  data.width, get_current_height());
			}
		}
		
		data.x = window_get_x();
		
	}
	,[],-1));
}

if (!__SETTINGS_ALLOW_WINDOW_RESIZE_VERT) {
	time_source_start(time_source_create(time_source_game, 2, time_source_units_frames, function(){
		
		static is_browser = (os_browser != browser_not_a_browser)
		
		static get_current_width  = (is_browser) ? function() {return browser_width}  : window_get_width;
		static get_current_height = (is_browser) ? function() {return browser_height} : window_get_height;
		
		if (get_current_height() != 0) {
			static data = {
				height : get_current_height(),
				y : window_get_y(),
			}
			
			if (get_current_height() != data.height) {
				//resize the browser's window
				if (is_browser) {
					window_set_size(browser_width, data.height);
				}
				else {
					window_set_size(get_current_width(), data.height);
					window_set_position(window_get_x(), data.y);
				}
				
				camera_set_view_size(view_camera[0], get_current_width(), data.height);
				surface_resize(application_surface,  get_current_width(), data.height);
				
				
			}
		}
		
		data.y = window_get_y();
		
	}
	,[],-1));
}
