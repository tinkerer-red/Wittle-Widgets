function ScribbleEmoji(_str, _spr=sprEmojiTwemoji24) {
	#region Load Json
	static __json_load_file = function(_filename) {
		var _path = working_directory + _filename;
	    if (!file_exists(_path)) {
	        return undefined;
	    }
	    var _file = file_text_open_read(_path);
	    var _json = "";
	    while (!file_text_eof(_file)) {
	        _json += file_text_readln(_file);
	    }
	    file_text_close(_file);
		return json_parse(_json);
	}
	static __lookup = __json_load_file("EmojiLookup.json")
	#endregion
	#region Cache
	static __cache = {};
	#endregion
	
	var _spr_name = sprite_get_name(_spr);
	
	if (struct_exists(__cache, _spr_name+_str)) {
		return scribble(__cache[$ _spr_name+_str]);
	}
	
	
	var _split = string_split(_str, ":", false);
	// If there are less than 3 segments, no valid emoji markers exist.
    if (array_length(_split) < 3) {
        return scribble(_str);
    }
	
	var _last_was_emoji = false;
	
	// skip the first and last
	var _i=1; repeat(array_length(_split)-2) {
		
		if (_last_was_emoji) {
			_last_was_emoji = false;
			_i++;
			continue;
		}
		
		var _segment = _split[_i];
		if (struct_exists(__lookup, _segment)) {
			_split[_i] = $"[{_spr_name},{__lookup[$ _segment]}]";
			_last_was_emoji = true;
		}
		else {
			_split[_i] = ":"+_segment;
			//_last_was_emoji = false;
		}
		
	_i++}
	
	//adjust the last
	if (!_last_was_emoji) {
		_split[_i] = ":"+_split[_i];
	}
	
	var _return = string_concat_ext(_split);
	
	__cache[$ _spr_name+_str] = _return;
	
	return scribble(_return);
}

