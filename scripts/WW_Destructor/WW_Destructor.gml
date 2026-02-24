enum __WW_DESTRUCTOR {
	TTL = 0,
	REF = 1,
}

#region jsDoc
/// @func    WW_Destructor(_initial_value, _destroy_method)
/// @desc    Creates a destructor wrapper that defers cleanup until its weak ref is no longer alive,
///          then waits a TTL window before calling _destroy_method(value). Centralized GC sweep.
/// @param   {Any} _initial_value Value to store (often a resource bundle struct).
/// @param   {Function} _destroy_method Function(value) called when the wrapper expires.
/// @returns {Struct} Destructor wrapper { value, destroy }.
#endregion
function WW_Destructor(_initial_value, _destroy_method) {
	static __gc = {
		grid: ds_grid_create(2, 0),
		used_rows: 0,
		time_source: undefined,
		collection_rate: 0,
		min_true_rows: 64,
	};

	//init
	if (__gc.time_source == undefined) {
		__gc.time_source = time_source_create(time_source_global, 1, time_source_units_frames,
			function() {
				static __gc = WW_Destructor.__gc;
				var _grid = __gc.grid;
				var _used_rows = __gc.used_rows;
				var _used_rows_start = _used_rows;
				var _tru_rows = ds_grid_height(_grid);
				
				// Decrement TTL for logical rows only.
				if (_used_rows > 0) {
					ds_grid_add_region(_grid, __WW_DESTRUCTOR.TTL, 0, __WW_DESTRUCTOR.TTL, _used_rows - 1, -1);
				}
				
				// sort all objects by TTL ascending (expired float to the top half)
				ds_grid_sort(_grid, __WW_DESTRUCTOR.TTL, true);
				
				// Sweep top for expired items (TTL <= 0)
				var _i = 0;
				repeat (_used_rows) {
					if (_grid[# __WW_DESTRUCTOR.TTL, _i]) {
						break;
					}
					else {
						var _ref = _grid[# __WW_DESTRUCTOR.REF, _i];
						if (weak_ref_alive(_ref)) {
							_grid[# __WW_DESTRUCTOR.TTL, _i] = __gc.collection_rate;
						} else {
							_ref.destroy(_ref.value);
							_grid[# __WW_DESTRUCTOR.TTL, _i] = infinity; // large positive sentinel
							_grid[# __WW_DESTRUCTOR.REF, _i] = undefined;
							_used_rows--
						}
					}
					_i++;
				}
				
				if (_used_rows < _used_rows_start) {
					// Optional hysteresis shrink of capacity to avoid ping-pong:
					// If logical size is much smaller than capacity, shrink capacity by half, but never below a floor.
					var _min_tru_rows = __gc.min_true_rows;
					if (_tru_rows > _min_tru_rows) {
						if (_used_rows <= (_tru_rows >> 2)) {
							var _new_tru_rows = (_tru_rows >> 1);
							if (_new_tru_rows < _min_tru_rows) _new_tru_rows = _min_tru_rows;
							if (_new_tru_rows < _tru_rows && _new_tru_rows >= _used_rows) {
								ds_grid_sort(_grid, __WW_DESTRUCTOR.TTL, true);
								ds_grid_resize(_grid, 2, _new_tru_rows);
								_tru_rows = _new_tru_rows;
							}
						}
					}
				}
				
				__gc.used_rows = _used_rows;
				
	        }, [], -1);
		time_source_start(__gc.time_source);
	}
	
	var _obj = {}
	with (_obj) {
		value = _initial_value;
	    with(weak_ref_create(_obj))
	    {
	        value = _initial_value;
	        destroy = _destroy_method;
			
			var _grid = __gc.grid;
            var _used_rows = __gc.used_rows;
            var _tru_rows = ds_grid_height(_grid);
			
			// If we are at capacity, grow geometrically (x2) and initialize slack rows.
			if (_used_rows >= _tru_rows) {
				var _new_tru_rows = (_tru_rows < 4) ? 4 : (_tru_rows << 1);
				ds_grid_resize(_grid, 2, _new_tru_rows);
				
				// Initialize newly added rows to sentinel values so they never get decremented or processed.
				var _y = _tru_rows;
				var _limit = _new_tru_rows - 1;
				while (_y <= _limit) {
					_grid[# __WW_DESTRUCTOR.TTL, _y] = infinity; // large positive sentinel
					_grid[# __WW_DESTRUCTOR.REF, _y] = undefined;
					_y += 1;
				}
				_tru_rows = _new_tru_rows;
			}
			
			_grid[# __WW_DESTRUCTOR.TTL, _used_rows] = irandom(15)+__gc.collection_rate;
            _grid[# __WW_DESTRUCTOR.REF, _used_rows] = self;

            // Advance logical size without touching capacity.
            __gc.used_rows = _used_rows + 1;
	    }
	}
	return _obj;
}