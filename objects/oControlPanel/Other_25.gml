/// @desc Window Resize Handling

view_visible[0] = true;
view_enabled = true;

if (os_browser != browser_not_a_browser) {
	get_current_width = function() {
		return browser_width;
	};
	get_current_height = function() {
		return browser_height;
	};
}
else{
	get_current_width = function() {
		return window_get_width();
	};
	get_current_height = function() {
		return window_get_height();
	};
}


//add a window resize handler to the component controller
cc.__add_event_listener_priv__(cc.events.pre_update, function(_data) {
	var _width = get_current_width();
	var _height = get_current_height();
	
	if (camera_get_view_width(0) != _width)
	|| (camera_get_view_height(0) != _height) {
		//resize the browser's window
		if (os_browser != browser_not_a_browser) {
			window_set_size(browser_width, browser_height);
		}
		
		camera_set_view_size(view_camera[0], _width, _height);
		surface_resize(application_surface, _width, _height);
	}
});
