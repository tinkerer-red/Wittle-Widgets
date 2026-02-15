function json(_input) {
	return json_stringify(_input, true)
}

#macro pprint repeat (__pprint_pre(_GMFILE_, _GMFUNCTION_, string(_GMLINE_))) __pprint
/// @param ...args
function __pprint() {
    var _str = $"PRINTER :: {
		string_replace(string_replace(__pprint.__file, "gml_Object_", ""), "gml_GlobalScript_", "")}/{
		string_replace(string_replace(__pprint.__func, "gml_Object_", ""), "gml_Script_", "")}:{__pprint.__line}:\n"
    
    var _i=0; repeat(argument_count) {
		_str += json_stringify(__reStruct(argument[_i]), true)+"\n";
	_i++}
	show_debug_message(_str)
}
function __pprint_pre(_file, _func, _line) {
    __pprint.__file = _file;
    __pprint.__func = _func;
    __pprint.__line = _line;
    return 1;
}
/// @ignore
function __reStruct(_struct) {
	static __recursion_memory = []
	static __depth = 0;
	if (__depth == 0) { array_resize(__recursion_memory, 0) };
	__depth++
	
	if (is_method(_struct)) {
		var _self = method_get_self(_struct);
		var _outputStruct = __reStruct(_self)
		__depth--
		return _outputStruct
	}
	
	if (is_array(_struct)) {
		var _inputArray = []
		var _i=0; repeat(array_length(_struct)) {
			var _expr = _struct[_i];
			_inputArray[_i] = __reStruct(_expr)
		_i++}
		__depth--
		return _inputArray
	}
	
	if (is_struct(_struct)) {
		if (array_get_index(__recursion_memory, _struct) == -1) {
			array_push(__recursion_memory, _struct);
		}
		else {
			__depth--
			return "<Recursive Reference>";
		}
		
		var _outputStruct = {}
		var _names = struct_get_names(_struct)
		var _length = array_length(_names)
		if (_length < 300) {
			var _i=0; repeat(_length) {
				var _name = _names[_i];
			
			
				//skip these from printing
				if (_name == "errorMessage")
				|| (_name == "rootNode")
				|| (_name == "parentNode") {
					_i++
					continue;
				}
			
				var _new_name = _name;
				if (string_starts_with(_name, "@@")) {
					_new_name = string_replace(_name, "@@", "_@@")
				}
			
				_outputStruct[$ _new_name] = __reStruct(_struct[$ _name])
			_i++}
		}
		else {
			_outputStruct = "<Struct Is too Large to Print>"
		}
		__depth--
		return _outputStruct
	}
	
	if (is_handle(_struct))
	&& (script_exists(_struct))
	{
		__depth--
		return script_get_name(_struct)
	}
	
	__depth--
	return _struct;
}

#region jsDoc
/// @func    trace()
/// @desc    This function will create a custom debug message  that is shown in the compiler window at runtime.
///
///          .
///
///          output: `<file>/<function>:<line>: <string>`
/// @param   {string} str : The string you wish to log
/// @returns {Undefined}
#endregion
#macro log repeat (__log_pre(_GMFILE_, _GMFUNCTION_, string(_GMLINE_))) __log
/// @param ...args
function __log() {
    var _str = $"LOGGER :: {
		string_replace(string_replace(__log.__file, "gml_Object_", ""), "gml_GlobalScript_", "")}/{
		string_replace(string_replace(__log.__func, "gml_Object_", ""), "gml_Script_", "")}:{__log.__line}:"
	
	for (var i = 0; i < argument_count; i++) {
        _str += $"\n\t{argument[i]}"
    }
    
	show_debug_message(_str);
}
function __log_pre(_file, _func, _line) {
    __log.__file = _file;
    __log.__func = _func;
    __log.__line = _line;
	return 1;
}

#macro TIMER_START var __timer_start = get_timer();
#macro TIMER_LOG show_debug_message("::TIMER_LOG:: Timed : "+string((get_timer() -__timer_start) / 1000)+"ms")

#region GC Timer Internals
    //Beta IDE v2023.600.0.368 Beta Runtime v2023.600.0.387
    // as of now, this number is 2 but might change in the future so best to calculate it on build, note this is not needed just increases accuracy
    
    //forget the initial count as it builds new internals on first call
    gc_get_stats().num_objects_in_generation[0]
    //find out the offset from simply running the function
    var __gc_start = gc_get_stats().num_objects_in_generation[0]
    global.__gc_log_offset = gc_get_stats().num_objects_in_generation[0]-__gc_start;
#endregion
#macro GC_START var __gc_start = gc_get_stats().num_objects_in_generation[0]
#macro GC_LOG show_debug_message("::GC_LOG:: Newly Created Garbage : "+string(gc_get_stats().num_objects_in_generation[0] -__gc_start - global.__gc_log_offset))

#region jsDoc
/// @func   log_progress()
/// @desc   Throttled progress logger with cached state, milestone printing,
///         stable average ops/s, ETA estimation, and TTL cleanup.
/// @param  {Real}   _current_value Current progress index (monotonic).
/// @param  {Real}   _total_value   Total expected count for completion.
/// @param  {String} [_prefix]      Optional prefix text (part of cache key).
/// @param  {String} [_suffix]      Optional suffix text (display only).
/// @returns {Undefined}
#endregion
function log_progress(
	_current_value,
	_total_value,
	_prefix="",
	_suffix=""
) {
	static __cache__ = {};
	static __ttl_killer__ = time_source_start(time_source_create(time_source_game, 30, time_source_units_seconds, function(){
		var _cache = log_progress.__cache__;
		var _names = struct_get_names(_cache);
		var _i=0; repeat(array_length(_names)) {
			var _name = _names[_i];
			var _progress = _cache[$ _name];

			// Remove if finished, or if stale (not updated recently).
			if ((_progress.total > 0 && _progress.completed >= _progress.total)
			|| (current_time - _progress.last_update_time >= 1000)) {
				struct_remove(_cache, _name);
			}

			_i++;
		}
	}));

	var _cache = __cache__;
	var _time_now_ms = current_time;

	// Identity key: stable. _suffix is NOT included because it often contains per-iteration details.
	var _key_text = _prefix + "|" + string(_total_value);

	var _progress = _cache[$ _key_text];
	if (_progress == undefined) {
		_progress = {
			total: _total_value,
			completed: 0,
			start_time: _time_now_ms,
			last_update_time: _time_now_ms,
			last_print_time: 0,
			interval_ms: 1000,
			last_print_completed: 0,
			last_bucket10: -1,
			last_bucket25: -1,
			last_opsps: 0.0,
			last_eta_seconds: -1.0
		};
		_cache[$ _key_text] = _progress;
	}

	// Backwards progress implies a new run for this key
	if (_current_value < _progress.completed) {
		_progress.completed = 0;
		_progress.start_time = _time_now_ms;
		_progress.last_print_time = 0;
		_progress.interval_ms = 1000;
		_progress.last_print_completed = 0;
		_progress.last_bucket10 = -1;
		_progress.last_bucket25 = -1;
		_progress.last_opsps = 0.0;
		_progress.last_eta_seconds = -1.0;
	}

	_progress.completed = _current_value;
	_progress.last_update_time = _time_now_ms;

	var _completed_value = _progress.completed;
	var _total_curr = _progress.total;

	// Percent
	var _percent_value = 0.0;
	if (_total_curr > 0) {
		_percent_value = (_completed_value / _total_curr) * 100.0;
	}
	_percent_value = clamp(_percent_value, 0.0, 100.0);

	// Never show 100% unless complete
	if (_total_curr > 0 && _completed_value < _total_curr && _percent_value >= 100.0) {
		_percent_value = 99.999;
	}

	var _bucket10_value = floor(_percent_value / 10.0);
	var _bucket25_value = floor(_percent_value / 25.0);

	var _hit_bucket10 = (_bucket10_value != _progress.last_bucket10);
	var _hit_bucket25 = (_bucket25_value != _progress.last_bucket25);

	// First/last 3
	var _is_first_three = (_completed_value <= 3);
	var _is_last_three = false;
	if (_total_curr > 0) {
		_is_last_three = (_completed_value >= max(1, _total_curr - 2));
	}

	var _force_print = false;
	if (_hit_bucket10) { _force_print = true; }
	if (_hit_bucket25) { _force_print = true; }
	if (_is_first_three) { _force_print = true; }
	if (_is_last_three) { _force_print = true; }
	if (_total_curr > 0 && _completed_value >= _total_curr) { _force_print = true; }

	var _time_since_print_ms = (_time_now_ms - _progress.last_print_time);
	var _time_since_start_ms = (_time_now_ms - _progress.start_time);

	var _should_print = false;
	if (_progress.last_print_time == 0) { _should_print = true; }
	if (_force_print) { _should_print = true; }
	if (_time_since_print_ms >= _progress.interval_ms) { _should_print = true; }

	if (_should_print) {

		// Backoff interval (1s -> ... -> 60s) when not forced
		if (_force_print) {
			_progress.interval_ms = 1000;
		}
		else {
			var _next_interval = _progress.interval_ms;
			if (_time_since_start_ms >= 60000) {
				_next_interval = min(60000, _next_interval * 2);
			}
			_progress.interval_ms = clamp(_next_interval, 1000, 60000);
		}

		// Stable ops/s based on average rate since start.
		// Using max(1s, elapsed) prevents early spikes from tiny dt.
		var _elapsed_seconds = (_time_since_start_ms / 1000.0);
		if (_elapsed_seconds < 1.0) { _elapsed_seconds = 1.0; }

		var _avg_rate = 0.0;
		if (_completed_value > 0) {
			_avg_rate = _completed_value / _elapsed_seconds;
		}

		var _opsps_value = _avg_rate;

		// Keep first call nicer (and avoid printing 0.0 for tiny starts).
		if (_completed_value > 0 && _opsps_value < 1.0) {
			_opsps_value = 1.0;
		}

		// ETA based on average time per item since start:
		// (elapsed_time / completed) * remaining
		var _eta_seconds = -1.0;

		if (_total_curr > 0 && _completed_value >= _total_curr) {
			_eta_seconds = 0.0;
		}
		else if (_total_curr > 0 && _completed_value >= 1 && _elapsed_seconds >= 1.0) {

			var _avg_time_per_item = _elapsed_seconds / _completed_value;
			var _remaining_items = (_total_curr - _completed_value);

			if (_remaining_items > 0) {
				_eta_seconds = _avg_time_per_item * _remaining_items;
			}
			else {
				_eta_seconds = 0.0;
			}
		}

		// Bar width fixed internally
		var _width_value = 30;

		// Fractional bar via chr(codepoint). Full block 0x2588. Partials 0x258F..0x2589.
		var _total_eighths = 0;
		if (_total_curr > 0) {
			_total_eighths = floor((_completed_value / _total_curr) * (_width_value * 8));
		}
		_total_eighths = clamp(_total_eighths, 0, _width_value * 8);

		var _full_cells = floor(_total_eighths / 8);
		var _remainder_eighths = _total_eighths - (_full_cells * 8);

		var _bar_text = "[";
		if (_full_cells > 0) {
			_bar_text += string_repeat(chr(0x2588), _full_cells);
		}

		if (_remainder_eighths > 0 && _full_cells < _width_value) {
			var _partial_codepoint = 0;
			switch (_remainder_eighths) {
				case 1: _partial_codepoint = 0x258F; break;
				case 2: _partial_codepoint = 0x258E; break;
				case 3: _partial_codepoint = 0x258D; break;
				case 4: _partial_codepoint = 0x258C; break;
				case 5: _partial_codepoint = 0x258B; break;
				case 6: _partial_codepoint = 0x258A; break;
				case 7: _partial_codepoint = 0x2589; break;
				default: _partial_codepoint = 0; break;
			}
			if (_partial_codepoint != 0) {
				_bar_text += chr(_partial_codepoint);
			}
		}

		var _cells_used = _full_cells + ((_remainder_eighths > 0 && _full_cells < _width_value) ? 1 : 0);
		var _empty_cells = (_width_value - _cells_used);
		if (_empty_cells > 0) {
			_bar_text += string_repeat(" ", _empty_cells);
		}
		_bar_text += "]";

		// Percent text
		var _percent_text = "";
		if (_total_curr > 0 && _completed_value < _total_curr && _percent_value >= 99.0) {
			var _percent_floor_1dp = floor(_percent_value * 10.0) / 10.0;
			if (_percent_floor_1dp > 99.9) { _percent_floor_1dp = 99.9; }
			_percent_text = string_format(_percent_floor_1dp, 0, 1);
		}
		else {
			var _percent_integer = floor(_percent_value + 0.5);
			var _percent_fraction_abs = abs(_percent_value - _percent_integer);

			if (_total_curr > 0 && _completed_value < _total_curr && _percent_integer >= 100) {
				_percent_integer = 99;
			}

			if (_percent_fraction_abs >= 0.05) {
				var _percent_floor_1dp_general = floor(_percent_value * 10.0) / 10.0;
				if (_total_curr > 0 && _completed_value < _total_curr && _percent_floor_1dp_general >= 100.0) {
					_percent_floor_1dp_general = 99.9;
				}
				_percent_text = string_format(_percent_floor_1dp_general, 0, 1);
			}
			else {
				_percent_text = string(_percent_integer);
			}
		}

		// ETA text (omit 0h and 0m)
		var _eta_text = "ETA ?s";
		if (_eta_seconds >= 0.0) {
			var _eta_total_seconds = floor(_eta_seconds + 0.5);

			var _eta_hours = floor(_eta_total_seconds / 3600);
			var _eta_minutes = floor((_eta_total_seconds - (_eta_hours * 3600)) / 60);
			var _eta_seconds_int = (_eta_total_seconds - (_eta_hours * 3600) - (_eta_minutes * 60));

			_eta_text = "ETA ";
			if (_eta_hours > 0) {
				_eta_text += string(_eta_hours) + "h ";
			}
			if (_eta_minutes > 0 || _eta_hours > 0) {
				_eta_text += string(_eta_minutes) + "m ";
			}
			_eta_text += string(_eta_seconds_int) + "s";
		}

		var _prefix_part = (_prefix != "") ? (_prefix + " ") : "";
		var _suffix_part = (_suffix != "") ? (" " + _suffix) : "";
		var _opsps_text = string_format(_opsps_value, 0, 1);

		show_debug_message(
			_prefix_part
			+ _bar_text
			+ " ("
			+ _percent_text
			+ "%) "
			+ string(_completed_value)
			+ "/"
			+ string(_total_curr)
			+ ", "
			+ _opsps_text
			+ "ops/s, "
			+ _eta_text
			+ _suffix_part
		);

		_progress.last_print_time = _time_now_ms;
		_progress.last_print_completed = _completed_value;
		_progress.last_bucket10 = _bucket10_value;
		_progress.last_bucket25 = _bucket25_value;
	}
}
