function draw_string_arr(_x, _y, _arr, _sep) {
	if (_sep == -1) {
		_sep = string_height("MLTQqpy") + 2;
	}
	
	var yy = _y;
	var _i=0; repeat(array_length(_arr)) {
		var _str = _arr[_i];
		draw_text(_x,yy,_str);
		yy += _sep;
	_i++}
	
}


