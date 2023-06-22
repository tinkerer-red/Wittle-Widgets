/// @desc Methods

update_position = function(){
	if (widget.__is_controller__) {
		var _prev_x = widget.x;
		var _prev_y = widget.y;
	}
	
	widget.x = x;
	widget.y = y;
	
	if (widget.__is_controller__) {
		if (_prev_x != widget.x)
		|| (_prev_y != widget.y) {
			widget.update_component_positions()
		}
	}
}


