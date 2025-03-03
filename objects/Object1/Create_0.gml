// Create the root GUI component to cover the full screen
root = new WWCore()
    .set_offset(0, 0)
    .set_size(0, 0, window_get_width(), window_get_height())
    .set_enabled(true)
	

button = new WWButtonSprite()
	//.on_focus(function(_data){ log( $":: Event Tiggered :: 'on_focus' :: {_data}" )})
	//.on_blur(function(_data){ log( $":: Event Tiggered :: 'on_blur' :: {_data}" )})
	//.on_is_focused(function(_data){ log( $":: Event Tiggered :: 'on_is_focused' :: {_data}" )})
	//.on_is_blurred(function(_data){ log( $":: Event Tiggered :: 'on_is_blurred' :: {_data}" )})
	//.on_interact(function(_data){ log( $":: Event Tiggered :: 'on_interact' :: {_data}" )})
	//.on_mouse_over(function(_data){ log( $":: Event Tiggered :: 'on_mouse_over' :: {_data}" )})
	//.on_pressed(function(_data){ log( $":: Event Tiggered :: 'on_pressed' :: {_data}" )})
	//.on_held(function(_data){ log($":: Event Tiggered :: 'on_held' :: {_data}" ) })
	//.on_long_press(function(_data){ log( $":: Event Tiggered :: 'on_long_press' :: {_data}" )})
	//.on_released(function(_data){ log( $":: Event Tiggered :: 'on_released' :: {_data}" )})
	//.on_double_click(function(_data){ log( $":: Event Tiggered :: 'on_double_click' :: {_data}" )})
	//.on_pre_step(function(_data){ log( $":: Event Tiggered :: 'on_pre_step' :: {_data}" )})
	//.on_post_step(function(_data){ log( $":: Event Tiggered :: 'on_post_step' :: {_data}" )})
	//.on_pre_draw(function(_data){ log( $":: Event Tiggered :: 'on_pre_draw' :: {_data}" )})
	//.on_post_draw(function(_data){ log( $":: Event Tiggered :: 'on_post_draw' :: {_data}" )})
	//.on_enable(function(_data){ log( $":: Event Tiggered :: 'on_enable' :: {_data}" )})
	//.on_disabled(function(_data){ log( $":: Event Tiggered :: 'on_disabled' :: {_data}" )})
	//.on_mouse_over_group(function(_data){ log( $":: Event Tiggered :: 'on_mouse_over_group' :: {_data}" )})
	
button2 = new WWButtonSprite()
	.set_position(20, 20)
// Add the test panel to the root GUI
root.add(button);
root.add(button2);
