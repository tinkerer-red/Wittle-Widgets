/*
hotkey_manager = WWHotkeyManager();
hotkey_manager.register([ord("S"), vk_control], function(){
	//ctrl+s = save file
})
hotkey_manager.register([ord("S"), vk_control, vk_alt], function(){
	//ctrl+alt+s = save file as
})
hotkey_manager.optimize();

//step event
hotkey_manager.step();
*/

#macro WW_TEXTBOX_REPEAT_DELAY     500
#macro WW_TEXTBOX_REPEAT_INTERVAL   33

function WWHotkeyManager() constructor {
    __registry = []; // Array of { keys: [], callback: fn }
    __root = {}; // Optimized lookup tree
    __repeat_state = {
        active_node: undefined,
        start_time: 0,
        last_fire: 0
    };
	
    /// @func    register()
    /// @desc    Adds a hotkey combination to the registry.
    /// @param   {Array<Real>} _key_arr : Array of key codes.
    /// @param   {Function} _callback : The callback to invoke.
    static register = function(_key_arr, _callback) {
        array_push(__registry, {
            keys: _key_arr,
            callback: _callback
        });
        return self;
    };

    /// @func    build()
    /// @desc    Builds the optimized lookup tree from all registered hotkeys.
    static build = function() {
		
		// Count key frequency across all registrations
        var _key_count = {};
        for (var i = 0; i < array_length(__registry); i++) {
            var _keys = __registry[i].keys;
            for (var j = 0; j < array_length(_keys); j++) {
                var _key = _keys[j];
                _key_count[$ _key] ??= 0;
                _key_count[$ _key] += 1;
            }
        }

        // Sort each key array in descending order of frequency
        for (var i = 0; i < array_length(__registry); i++) {
            var _entry = __registry[i];
			
			// fake a closure
			with (_key_count) {
	            array_sort(_entry.keys, function(a, b) {
	                return (self[$ b] - self[$ a]);
	            });
			}
        }

        // Build tree from sorted keys
        __root = {};
        for (var i = 0; i < array_length(__registry); i++) {
            var _entry = __registry[i];
            var _keys = _entry.keys;
            var _callback = _entry.callback;

            var _node = __root;
            for (var j = 0; j < array_length(_keys); j++) {
                var _key = _keys[j];
                if (j == array_length(_keys) - 1) {
                    _node[$ _key] ??= {};
                    _node[$ _key].callback = _callback;
                } else {
                    _node[$ _key] ??= {};
                    _node = _node[$ _key];
                }
            }
        }

        return self;
    };
	
	static step = function(_node = __root, _depth = 0, _deepest = undefined) {
		var _keys = struct_get_names(_node);
	    var _i = 0, _length = array_length(_keys);

	    // Track the current deepest valid node
	    if (_node[$ "callback"] != undefined) {
	        if (_deepest == undefined || _depth > _deepest.depth) {
	            _deepest = { node: _node, depth: _depth };
	        }
	    }

	    repeat (_length) {
	        var _key = _keys[_i++];
	        if (_key == "callback") continue;

	        var _key_id = real(_key);
	        if (keyboard_check(_key_id)) {
	            _deepest = step(_node[$ _key], _depth + 1, _deepest);
	        }
	    }

	    // At root: check if we should call the callback (first frame or repeat)
        if (_node == __root) {
            var _state = __repeat_state;
            var _now = current_time;

            if (_deepest != undefined) {
                if (_state.active_node != _deepest.node) {
                    // New combo: trigger immediately and start timing
                    _deepest.node.callback();
                    _state.active_node = _deepest.node;
                    _state.start_time = _now;
                    _state.last_fire = _now;
                }
                else {
                    var _since_start = _now - _state.start_time;
                    var _since_last = _now - _state.last_fire;

                    if (_since_start >= WW_TEXTBOX_REPEAT_DELAY && _since_last >= WW_TEXTBOX_REPEAT_INTERVAL) {
                        _deepest.node.callback();
                        _state.last_fire = _now;
                    }
                }
            }
            else {
                // Reset when no combo is active
                _state.active_node = undefined;
            }
        }
		
	    return _deepest;
	};
	
}



var hotkey_manager = new WWHotkeyManager();

// Register various key sequences
hotkey_manager.register([ord("S"), vk_control], function() { show_debug_message("Ctrl+S called"); });
hotkey_manager.register([ord("S"), vk_alt, vk_control], function() { show_debug_message("Ctrl+Alt+S called"); });
hotkey_manager.register([vk_control, ord("Z")], function() { show_debug_message("Undo"); });
hotkey_manager.register([vk_pageup], function() { show_debug_message("PageUp called"); });
hotkey_manager.register([vk_control, vk_shift, ord("Z")], function() { show_debug_message("Redo"); });
hotkey_manager.register([vk_alt, ord("F")], function() { show_debug_message("Alt+F called"); });
hotkey_manager.register([vk_control, ord("S")], function() { show_debug_message("Ctrl+S duplicate"); }); // This should overwrite the earlier callback

hotkey_manager.build();

// Before optimization
show_debug_message("--- Before Optimize ---");
pprint(hotkey_manager.__root, 0);
