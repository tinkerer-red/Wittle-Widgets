function string_split_by_width(_str, _width, _font = draw_get_font()) {
	
	// means nothing will "wrap"
	if (_width < 0 || _width == infinity) {
		return string_split(_str, "\n");
	}
	
	var _old_font = draw_get_font();
	if (_font != _old_font) {
		draw_set_font(_font);
	}
	
	var _space_width = string_width(" ");
	
	var _input_lines = string_split(_str, "\n");
	var _input_line_count = array_length(_input_lines);
	
	var _output_arr = [];
	
	var _line_index = 0;
	repeat (_input_line_count) {
		var _raw_line = _input_lines[_line_index];
		
		// Preserve empty lines and short lines.
		if (_raw_line == "")
		|| (string_width(_raw_line) <= _width) {
			array_push(_output_arr, _raw_line+"\n");
			_line_index++;
			continue;
		}
		
		var _words = string_split(_raw_line, " ");
		var _word_count = array_length(_words);
		
		var _start_index = 0;
		var _segment_word_count = 0;
		var _current_width = 0;
		
		var _word_index = 0;
		repeat (_word_count) {
			var _word = _words[_word_index];
			var _word_width = string_width(_word);
			
			if (_word_width < _width) {
				var _new_width = _current_width + _word_width;
				
				if (_new_width < _width) {
					_current_width = _new_width + _space_width;
					_segment_word_count++;
				}
				else {
					// This word would overflow the current line, flush previous words
					if (_segment_word_count > 0) {
						array_push(
							_output_arr,
							string_join_ext(" ", _words, _start_index, _segment_word_count) + " "
						);
						_start_index += _segment_word_count;
					}
					
					// Start a new line with this word
					_current_width = _word_width + ((_word_index+1 < _word_count) ? _space_width : 0);
					_segment_word_count = 1;
				}
				
				// Width reached or exceeded: flush current line
				if (_current_width >= _width) {
					array_push(
						_output_arr,
						string_join_ext(" ", _words, _start_index, _segment_word_count) + " "
					);
					_current_width = 0;
					_start_index += _segment_word_count;
					_segment_word_count = 0;
				}
			}
			else {
				// Long word: subdivide into pieces that each fit within _width
				// Flush any accumulated shorter words first
				if (_segment_word_count > 0) {
					array_push(
						_output_arr,
						string_join_ext(" ", _words, _start_index, _segment_word_count) + " "
					);
					_start_index += _segment_word_count;
					_segment_word_count = 0;
					_current_width = 0;
				}
				
				var _word_len = string_length(_word);
				var _segment_start_char_index = 1;
				var _segment_width_chars = 0;
				
				var _char_index = 1;
				repeat (_word_len) {
					var _char = string_char_at(_word, _char_index);
					var _char_width = string_width(_char);
					
					// If adding this character would overflow the line, flush the segment so far
					if (_segment_width_chars > 0 && (_segment_width_chars + _char_width) > _width) {
						var _segment_length_chars = _char_index - _segment_start_char_index;
						if (_segment_length_chars <= 0) {
							// Worst case: single character wider than line, force it alone
							array_push(_output_arr, _char);
							_segment_start_char_index = _char_index + 1;
							_segment_width_chars = 0;
							_char_index++;
							continue;
						}
						
						var _segment_str = string_copy(
							_word,
							_segment_start_char_index,
							_segment_length_chars
						);
						array_push(_output_arr, _segment_str);
						
						_segment_start_char_index = _char_index;
						_segment_width_chars = 0;
					}
					
					_segment_width_chars += _char_width;
					_char_index++;
				}
				
				// Flush any remaining segment of the long word
				if (_segment_width_chars > 0 && _segment_start_char_index <= _word_len) {
					var _segment_length_final = (_word_len + 1) - _segment_start_char_index;
					var _segment_str_final = string_copy(
						_word,
						_segment_start_char_index,
						_segment_length_final
					);
					array_push(_output_arr, _segment_str_final);
				}
				
				// Long word is fully consumed; move start index past it
				_start_index = _word_index + 1;
				_current_width = 0;
				_segment_word_count = 0;
			}
			
			_word_index++;
		}
		
		// Flush any remaining words on this original line
		if (_segment_word_count > 0) {
			array_push(
				_output_arr,
				string_join_ext(" ", _words, _start_index, _segment_word_count) + " "
			);
		}
		
		_line_index++;
	}
	
	if (_font != _old_font) {
		draw_set_font(_old_font);
	}
	
	return _output_arr;
}



