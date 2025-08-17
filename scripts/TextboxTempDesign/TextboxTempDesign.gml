/*
#region jsDoc
/// @func    WWTextBaseCore()
/// @desc    A composable base text field object. Manages rendering, selection, cursor logic, input handling, and undo support through modular subcomponents.
/// @returns {Struct.WWTextBaseCore}
#endregion
function WWTextBaseCore() constructor {
    debug_name = "WWTextBaseCore";

    #region Public

        /// @func set_text()
        /// @desc Sets the entire content of the text buffer.
        static set_text = function(_text) {
            text_buffer.set_text(_text);
            return self;
        };

        /// @func get_text()
        /// @desc Retrieves the full contents of the buffer.
        static get_text = function() {
            return text_buffer.get_text();
        };

        /// @func set_focus()
        /// @desc Assigns focus to this field.
        static set_focus = function(_value) {
            focused = _value;
            if (focused) {
                text_event_router.on_focus();
            } else {
                text_event_router.on_blur();
            }
            return self;
        };

        /// @func has_focus()
        /// @desc Returns whether this field is focused.
        static has_focus = function() {
            return focused;
        };

        /// @func on_key_down()
        /// @desc Forwards key events to the internal router.
        static on_key_down = function(key, shift, ctrl, alt) {
            if (focused) {
                text_event_router.on_key_down(key, shift, ctrl, alt);
            }
        };

        /// @func on_paste()
        /// @desc Forwards clipboard paste data.
        static on_paste = function(paste_string) {
            if (focused) {
                text_event_router.on_paste(paste_string);
            }
        };

        /// @func on_mouse_down()
        static on_mouse_down = function(x, y) {
            if (focused) {
                text_event_router.on_mouse_down(x, y);
            }
        };

        /// @func on_mouse_move()
        static on_mouse_move = function(x, y, pressed) {
            if (focused) {
                text_event_router.on_mouse_move(x, y, pressed);
            }
        };

        /// @func on_mouse_up()
        static on_mouse_up = function(x, y) {
            if (focused) {
                text_event_router.on_mouse_up(x, y);
            }
        };

        /// @func record_state()
        /// @desc Manually push undo snapshot (if applicable)
        static record_state = function() {
            undo_manager.record_state(text_buffer.get_text()); // Simplistic snapshot
        };

        /// @func undo()
        /// @desc Restore last undo state
        static undo = function() {
            var text = undo_manager.undo();
            if (text != undefined) {
                text_buffer.set_text(text);
            }
        };

        /// @func redo()
        static redo = function() {
            var text = undo_manager.redo();
            if (text != undefined) {
                text_buffer.set_text(text);
            }
        };

    #endregion

    #region Private

        #region Variables

        static text_buffer       = new WWTextBuffer();
        static text_renderer     = new WWTextRenderer();
        static text_cursor       = new WWTextCursor();
        static text_selection    = new WWTextSelection();
        static text_input        = new WWTextInputHandler();
        static text_event_router = new WWTextEventRouter();
        static undo_manager      = new WWUndoManager();

        static focused = false;

        static __pos_x__ = 0;
        static __pos_y__ = 0;

        #endregion

        #region Functions

        /// @func step()
        /// @desc Internal update loop for blink + input
        static step = function() {
            if (focused) {
                text_input.update(text_buffer, text_cursor, text_selection);
                text_cursor.update_blink();
            }
        };

        /// @func draw()
        /// @desc Delegates rendering to the text renderer
        static draw = function(_x, _y) {
            __pos_x__ = _x;
            __pos_y__ = _y;

            text_renderer.update(); // Ensure render cache is valid
            text_renderer.draw(_x, _y);

            // Draw cursor if focused
            if (focused) {
                text_renderer.draw_cursor(text_cursor);
                if (text_selection.is_active()) {
                    text_renderer.draw_selection(text_selection);
                }
            }
        };

        /// @func init_links()
        /// @desc Binds all subcomponents to shared dependencies
        static init_links = function() {
            text_cursor.set_buffer(text_buffer);
            text_selection.set_buffer(text_buffer);

            text_renderer.set_buffer(text_buffer);
            text_input.set_buffer(text_buffer);
            text_input.set_cursor(text_cursor);
            text_input.set_selection(text_selection);

            text_event_router.set_input_handler(text_input);
            text_event_router.set_cursor(text_cursor);
            text_event_router.set_selection(text_selection);
            text_event_router.set_renderer(text_renderer);
        };

        init_links(); // Run once at construction

        #endregion

    #endregion
}

#region jsDoc
/// @func    WWTextBuffer()
/// @desc    Text storage layer for all WW text components. Manages string content as line arrays and provides mutation methods like insert, delete, and split.
/// @returns {Struct.WWTextBuffer}
#endregion
function WWTextBuffer() constructor {
    debug_name = "WWTextBuffer";

    #region Public

        /// @func    set_text()
        /// @desc    Replace entire text content (line-split internally)
        static set_text = function(_str) {
            __lines__ = string_split(_str, "\n");
            __dirty__ = true;
        };

        /// @func    get_text()
        /// @desc    Returns text as a single string (joins lines with `\n`)
        static get_text = function() {
            return string_join(__lines__, "\n");
        };

        /// @func    lines()
        /// @desc    Returns raw reference to internal line array (read-only usage)
        static lines = function() {
            return __lines__;
        };

        /// @func    is_dirty()
        /// @desc    Returns true if buffer has changed since last render.
        static is_dirty = function() {
            return __dirty__;
        };

        /// @func    clear_dirty()
        /// @desc    Clears dirty flag after renderer updates cache.
        static clear_dirty = function() {
            __dirty__ = false;
        };

        /// @func    insert_at()
        /// @desc    Insert string at exact location within a line.
        /// @param   {String} _text
        /// @param   {Int} _line
        /// @param   {Int} _col
        static insert_at = function(_text, _line, _col) {
            if (_line < 0 || _line >= array_length(__lines__)) return;

            var _line_str = __lines__[@ _line];
            var _before = string_copy(_line_str, 1, _col);
            var _after = string_delete(_line_str, 1, _col);
            __lines__[@ _line] = _before + _text + _after;

            __dirty__ = true;
        };

        /// @func    delete_range()
        /// @desc    Deletes characters across a single line or spanning multiple lines.
        static delete_range = function(_start_line, _start_col, _end_line, _end_col) {
            if (_start_line == _end_line) {
                var _line = __lines__[@ _start_line];
                __lines__[@ _start_line] =
                    string_copy(_line, 1, _start_col) +
                    string_delete(_line, 1, _end_col + 1);
            } else {
                var _before = string_copy(__lines__[@ _start_line], 1, _start_col);
                var _after = string_delete(__lines__[@ _end_line], 1, _end_col + 1);
                array_delete(__lines__, _start_line + 1, _end_line - _start_line);
                __lines__[@ _start_line] = _before + _after;
            }

            __dirty__ = true;
        };

        /// @func    insert_new_line()
        /// @desc    Splits current line at a given column into two lines.
        static insert_new_line = function(_line, _col) {
            var _line_str = __lines__[@ _line];
            var _left = string_copy(_line_str, 1, _col);
            var _right = string_delete(_line_str, 1, _col);

            __lines__[@ _line] = _left;
            array_insert(__lines__, _line + 1, _right);

            __dirty__ = true;
        };

        /// @func    insert_text_at_cursor()
        /// @desc    Inserts text at a cursor’s current position. Updates the cursor.
        static insert_text_at_cursor = function(cursor, text) {
            var [line, col] = cursor.get_position();
            insert_at(text, line, col);
            cursor.set_position(line, col + string_length(text));
        };

        /// @func    insert_char_at_cursor()
        /// @desc    Shortcut for inserting a single character.
        static insert_char_at_cursor = function(cursor, char) {
            insert_text_at_cursor(cursor, char);
        };

        /// @func    insert_new_line_at_cursor()
        /// @desc    Breaks line at cursor and moves cursor to start of next line.
        static insert_new_line_at_cursor = function(cursor) {
            var [line, col] = cursor.get_position();
            insert_new_line(line, col);
            cursor.set_position(line + 1, 0);
        };

        /// @func    delete_char_before_cursor()
        /// @desc    Deletes the character to the left of the cursor.
        static delete_char_before_cursor = function(cursor) {
            var [line, col] = cursor.get_position();
            if (col > 0) {
                delete_range(line, col - 1, line, col - 1);
                cursor.set_position(line, col - 1);
            } else if (line > 0) {
                var prev_line = line - 1;
                var prev_len = string_length(__lines__[@ prev_line]);
                __lines__[@ prev_line] += __lines__[@ line];
                array_delete(__lines__, line, 1);
                cursor.set_position(prev_line, prev_len);
                __dirty__ = true;
            }
        };

        /// @func    delete_char_after_cursor()
        /// @desc    Deletes the character to the right of the cursor.
        static delete_char_after_cursor = function(cursor) {
            var [line, col] = cursor.get_position();
            var _line_str = __lines__[@ line];
            if (col < string_length(_line_str)) {
                delete_range(line, col, line, col);
            } else if (line < array_length(__lines__) - 1) {
                __lines__[@ line] += __lines__[@ line + 1];
                array_delete(__lines__, line + 1, 1);
                __dirty__ = true;
            }
        };

        /// @func    delete_selection()
        /// @desc    Deletes text selected by the given selection object.
        static delete_selection = function(selection) {
            var [start_line, start_col, end_line, end_col] = selection.get_ordered_positions();
            delete_range(start_line, start_col, end_line, end_col - 1);
        };

    #endregion

    #region Private

        static __lines__ = [""];        // The internal representation of text content.
        static __dirty__ = false;      // Set true on changes, cleared after rendering.

    #endregion
}

#region jsDoc
/// @func    WWTextRenderer()
/// @desc    Converts WWTextBuffer content into drawable lines using font metrics. Supports layout caching, line metrics, selection highlighting, and text hit-testing.
/// @returns {Struct.WWTextRenderer}
#endregion
function WWTextRenderer() constructor {
    debug_name = "WWTextRenderer";

    #region Public

        /// @func    set_font()
        /// @desc    Sets the font used for layout/measurements.
        static set_font = function(_font) {
            __font__ = _font;
            __dirty__ = true;
        };

        /// @func    set_buffer()
        /// @desc    Sets the WWTextBuffer to render from.
        static set_buffer = function(_buffer) {
            __buffer__ = _buffer;
            __dirty__ = true;
        };

        /// @func    update()
        /// @desc    Rebuilds the layout cache if needed.
        static update = function() {
            if (!__dirty__ && !__buffer__.is_dirty()) return;

            draw_set_font(__font__);
            __line_cache__ = [];

            var _lines = __buffer__.lines();
            for (var i = 0; i < array_length(_lines); i++) {
                var _str = _lines[@ i];
                var _width = string_width(_str);
                var _height = string_height(_str);
                array_push(__line_cache__, {
                    text: _str,
                    w: _width,
                    h: _height
                });
            }

            __dirty__ = false;
            __buffer__.clear_dirty();
        };

        /// @func    draw()
        /// @desc    Draws cached text lines (with optional cursor/selection).
        /// @param   {Real} _x
        /// @param   {Real} _y
        /// @param   {Struct} _buffer
        /// @param   {Struct|undefined} _cursor
        /// @param   {Struct|undefined} _selection
        static draw = function(_x, _y, _buffer, _cursor = undefined, _selection = undefined) {
            draw_set_font(__font__);
            var _dy = 0;

            for (var i = 0; i < array_length(__line_cache__); i++) {
                var _line = __line_cache__[@ i];
                var _text = _line.text;

                // Highlight selection
                if (_selection != undefined && _selection.is_active()) {
                    var [sl, sc, el, ec] = _selection.get_ordered_positions();
                    if (i >= sl && i <= el) {
                        var _start_col = (i == sl) ? sc : 0;
                        var _end_col = (i == el) ? ec : string_length(_text);
                        var _sel_str = string_copy(_text, _start_col + 1, _end_col - _start_col);

                        var _pre_width = string_width(string_copy(_text, 1, _start_col));
                        var _sel_width = string_width(_sel_str);

                        draw_set_color(c_ltblue);
                        draw_rectangle(_x + _pre_width, _y + _dy, _x + _pre_width + _sel_width, _y + _dy + _line.h, false);
                        draw_set_color(c_white);
                    }
                }

                draw_text(_x, _y + _dy, _text);

                // Draw cursor
                if (_cursor != undefined) {
                    var [_cl, _cc] = _cursor.get_position();
                    if (_cl == i && _cursor.is_blink_visible()) {
                        var _cursor_x = _x + string_width(string_copy(_text, 1, _cc));
                        draw_line(_cursor_x, _y + _dy, _cursor_x, _y + _dy + _line.h);
                    }
                }

                _dy += _line.h;
            }
        };

        /// @func    get_line_metrics()
        /// @desc    Returns line width/height for layout purposes.
        static get_line_metrics = function(_index) {
            if (_index < 0 || _index >= array_length(__line_cache__)) return undefined;
            return __line_cache__[@ _index];
        };

        /// @func    get_total_height()
        /// @desc    Returns total vertical space occupied by all lines.
        static get_total_height = function() {
            var _h = 0;
            for (var i = 0; i < array_length(__line_cache__); i++) {
                _h += __line_cache__[@ i].h;
            }
            return _h;
        };

        /// @func    hit_test_position()
        /// @desc    Converts a pixel position to a line/column in the text.
        /// @param   {Real} _x
        /// @param   {Real} _y
        /// @returns {Struct} { line, column }
        static hit_test_position = function(_x, _y) {
            var _dy = 0;
            var _line_index = 0;

            for (var i = 0; i < array_length(__line_cache__); i++) {
                var _line = __line_cache__[@ i];
                if (_y >= _dy && _y < _dy + _line.h) {
                    _line_index = i;
                    break;
                }
                _dy += _line.h;
            }

            var _text = __line_cache__[@ _line_index].text;
            var _target_col = 0;
            var _accum = 0;

            for (var c = 1; c <= string_length(_text); c++) {
                var _w = string_width(string_copy(_text, c, 1));
                if (_x < _accum + _w / 2) break;
                _accum += _w;
                _target_col += 1;
            }

            return { line: _line_index, column: _target_col };
        };

    #endregion

    #region Private

        static __font__ = -1;
        static __buffer__ = undefined;
        static __dirty__ = true;
        static __line_cache__ = [];

    #endregion
}

#region jsDoc
/// @func    WWTextCursor()
/// @desc    Tracks the current editable position in the text. Supports navigation, bounds clamping, and optional blinking behavior for rendering.
/// @returns {Struct.WWTextCursor}
#endregion
function WWTextCursor() constructor {
    debug_name = "WWTextCursor";

    #region Public

        /// @func    set_buffer()
        /// @desc    Attach a WWTextBuffer instance for bounds checking.
        static set_buffer = function(_buffer) {
            __buffer__ = _buffer;
            clamp_position();
        };

        /// @func    set_position()
        /// @desc    Sets cursor position, clamped to buffer bounds.
        static set_position = function(_line, _col) {
            __line__ = _line;
            __col__ = _col;
            clamp_position();
        };

        /// @func    get_position()
        /// @desc    Returns [line, column] tuple.
        static get_position = function() {
            return [__line__, __col__];
        };

        /// @func    move_left()
        /// @desc    Moves cursor left (wraps to previous line if at 0).
        static move_left = function() {
            if (__col__ > 0) {
                __col__ -= 1;
            } else if (__line__ > 0) {
                __line__ -= 1;
                __col__ = string_length(__buffer__.lines()[@ __line__]);
            }
        };

        /// @func    move_right()
        /// @desc    Moves cursor right (wraps to next line if at end).
        static move_right = function() {
            var line_len = string_length(__buffer__.lines()[@ __line__]);
            if (__col__ < line_len) {
                __col__ += 1;
            } else if (__line__ < array_length(__buffer__.lines()) - 1) {
                __line__ += 1;
                __col__ = 0;
            }
        };

        /// @func    move_up()
        /// @desc    Moves cursor up by one line (clamps column).
        static move_up = function() {
            if (__line__ > 0) {
                __line__ -= 1;
                clamp_column();
            }
        };

        /// @func    move_down()
        /// @desc    Moves cursor down by one line (clamps column).
        static move_down = function() {
            if (__line__ < array_length(__buffer__.lines()) - 1) {
                __line__ += 1;
                clamp_column();
            }
        };

        /// @func    jump_to_start()
        /// @desc    Move to start of buffer.
        static jump_to_start = function() {
            __line__ = 0;
            __col__ = 0;
        };

        /// @func    jump_to_end()
        /// @desc    Move to end of buffer.
        static jump_to_end = function() {
            var lines = __buffer__.lines();
            __line__ = array_length(lines) - 1;
            __col__ = string_length(lines[@ __line__]);
        };

        /// @func    update_blink()
        /// @desc    Increments blink timer and toggles visibility.
        static update_blink = function() {
            __blink_timer__ += 1;
            if (__blink_timer__ >= __blink_interval__) {
                __blink_timer__ = 0;
                __blink_state__ = !__blink_state__;
            }
        };

        /// @func    is_blink_visible()
        /// @desc    Returns whether the cursor should currently be visible.
        static is_blink_visible = function() {
            return __blink_state__;
        };

        /// @func    reset_blink()
        /// @desc    Resets cursor blink cycle.
        static reset_blink = function() {
            __blink_timer__ = 0;
            __blink_state__ = true;
        };

    #endregion

    #region Private

        static __buffer__ = undefined;

        static __line__ = 0;
        static __col__ = 0;

        static __blink_timer__ = 0;
        static __blink_state__ = true;
        static __blink_interval__ = room_speed / 2; // Half second

        /// Clamp cursor inside text bounds
        static clamp_position = function() {
            if (__buffer__ == undefined) return;

            var lines = __buffer__.lines();
            __line__ = clamp(__line__, 0, array_length(lines) - 1);
            clamp_column();
        };

        /// Clamp column inside current line
        static clamp_column = function() {
            if (__buffer__ == undefined) return;

            var line_len = string_length(__buffer__.lines()[@ __line__]);
            __col__ = clamp(__col__, 0, line_len);
        };

    #endregion
}

#region jsDoc
/// @func    WWTextSelection()
/// @desc    Handles selection ranges using anchor and active positions. Supports multi-line selection and retrieval of selected text.
/// @returns {Struct.WWTextSelection}
#endregion
function WWTextSelection() constructor {
    debug_name = "WWTextSelection";

    #region Public

        /// @func    set_buffer()
        /// @desc    Attaches a WWTextBuffer instance for bounds checking.
        static set_buffer = function(_buffer) {
            __buffer__ = _buffer;
            clear();
        };

        /// @func    set_anchor()
        /// @desc    Sets the selection anchor position (start).
        static set_anchor = function(_line, _col) {
            __anchor_line__ = _line;
            __anchor_col__ = _col;
            __clamp_positions__();
        };

        /// @func    set_active()
        /// @desc    Sets the selection active position (end).
        static set_active = function(_line, _col) {
            __active_line__ = _line;
            __active_col__ = _col;
            __clamp_positions__();
        };

        /// @func    clear()
        /// @desc    Clears the selection by collapsing anchor and active positions.
        static clear = function() {
            __anchor_line__ = 0;
            __anchor_col__ = 0;
            __active_line__ = 0;
            __active_col__ = 0;
        };

        /// @func    is_active()
        /// @desc    Returns true if anchor and active differ (selection exists).
        static is_active = function() {
            return !(__anchor_line__ == __active_line__ && __anchor_col__ == __active_col__);
        };

        /// @func    has_selection()
        /// @desc    Alias for is_active().
        static has_selection = function() {
            return is_active();
        };

        /// @func    get_ordered_positions()
        /// @desc    Returns [startLine, startCol, endLine, endCol] in order.
        static get_ordered_positions = function() {
            if (__buffer__ == undefined) return [0, 0, 0, 0];

            if (__anchor_line__ < __active_line__ || 
               (__anchor_line__ == __active_line__ && __anchor_col__ <= __active_col__)) {
                return [__anchor_line__, __anchor_col__, __active_line__, __active_col__];
            } else {
                return [__active_line__, __active_col__, __anchor_line__, __anchor_col__];
            }
        };

        /// @func    get_positions()
        /// @desc    Returns [anchor_line, anchor_col, active_line, active_col] without sorting.
        static get_positions = function() {
            return [__anchor_line__, __anchor_col__, __active_line__, __active_col__];
        };

        /// @func    get_selected_text()
        /// @desc    Extracts the selected text from the buffer.
        static get_selected_text = function() {
            if (!is_active()) return "";

            var lines = __buffer__.lines();
            var [startLine, startCol, endLine, endCol] = get_ordered_positions();

            if (startLine == endLine) {
                return string_copy(lines[@ startLine], startCol + 1, endCol - startCol);
            }

            var result = "";

            // First partial line
            result += string_copy(lines[@ startLine], startCol + 1, string_length(lines[@ startLine]) - startCol) + "\n";

            // Full middle lines
            for (var i = startLine + 1; i < endLine; i++) {
                result += lines[@ i] + "\n";
            }

            // Final partial line
            result += string_copy(lines[@ endLine], 1, endCol);

            return result;
        };

    #endregion

    #region Private

        static __buffer__ = undefined;

        // Anchor is the static origin of the selection
        static __anchor_line__ = 0;
        static __anchor_col__ = 0;

        // Active is the moving caret end of the selection
        static __active_line__ = 0;
        static __active_col__ = 0;

        /// @func    __clamp_positions__()
        /// @desc    Clamp all selection coordinates inside the buffer bounds.
        static __clamp_positions__ = function() {
            if (__buffer__ == undefined) return;

            var lines = __buffer__.lines();
            var max_lines = array_length(lines);

            // Anchor
            __anchor_line__ = clamp(__anchor_line__, 0, max_lines - 1);
            __anchor_col__ = clamp(__anchor_col__, 0, string_length(lines[@ __anchor_line__]));

            // Active
            __active_line__ = clamp(__active_line__, 0, max_lines - 1);
            __active_col__ = clamp(__active_col__, 0, string_length(lines[@ __active_line__]));
        };

    #endregion
}

#region jsDoc
/// @func    WWTextInputHandler()
/// @desc    Interprets keyboard input and edits the buffer accordingly. Handles text insertion, deletion, navigation, and clipboard interactions.
/// @returns {Struct.WWTextInputHandler}
#endregion
function WWTextInputHandler() constructor {
    debug_name = "WWTextInputHandler";

    #region Public

        /// @func    set_buffer()
        /// @desc    Attach the text buffer this handler operates on.
        static set_buffer = function(_buffer) {
            __buffer__ = _buffer;
        };

        /// @func    set_cursor()
        /// @desc    Attach the cursor this handler controls.
        static set_cursor = function(_cursor) {
            __cursor__ = _cursor;
        };

        /// @func    set_selection()
        /// @desc    Attach the selection component this handler controls.
        static set_selection = function(_selection) {
            __selection__ = _selection;
        };

        /// @func    handle_key_down()
        /// @desc    Respond to a key down event, updating text state.
        /// @param   {String} key : Key identifier
        /// @param   {Bool} shift
        /// @param   {Bool} ctrl
        /// @param   {Bool} alt
        static handle_key_down = function(key, shift = false, ctrl = false, alt = false) {
            if (__buffer__ == undefined || __cursor__ == undefined || __selection__ == undefined) return;

            switch (key) {
                case "Backspace":
                    __handle_backspace__();
                    break;

                case "Delete":
                    __handle_delete__();
                    break;

                case "Enter":
                    __handle_enter__();
                    break;

                case "ArrowLeft":
                    __move_cursor__("left", shift);
                    break;

                case "ArrowRight":
                    __move_cursor__("right", shift);
                    break;

                case "ArrowUp":
                    __move_cursor__("up", shift);
                    break;

                case "ArrowDown":
                    __move_cursor__("down", shift);
                    break;

                default:
                    if (string_length(key) == 1 && !ctrl && !alt) {
                        __insert_character__(key);
                    }
                    break;
            }
        };

        /// @func    handle_paste()
        /// @desc    Inserts clipboard text into buffer.
        static handle_paste = function(pasted_text) {
            if (__buffer__ == undefined || __cursor__ == undefined || __selection__ == undefined) return;

            if (__selection__.is_active()) {
                __buffer__.delete_selection(__selection__);
                __selection__.clear();
            }

            __buffer__.insert_text_at_cursor(__cursor__, pasted_text);
        };

    #endregion

    #region Private

        static __buffer__ = undefined;
        static __cursor__ = undefined;
        static __selection__ = undefined;

        static __handle_backspace__ = function() {
            if (__selection__.is_active()) {
                __buffer__.delete_selection(__selection__);
                __selection__.clear();
            } else {
                __buffer__.delete_char_before_cursor(__cursor__);
            }
        };

        static __handle_delete__ = function() {
            if (__selection__.is_active()) {
                __buffer__.delete_selection(__selection__);
                __selection__.clear();
            } else {
                __buffer__.delete_char_after_cursor(__cursor__);
            }
        };

        static __handle_enter__ = function() {
            if (__selection__.is_active()) {
                __buffer__.delete_selection(__selection__);
                __selection__.clear();
            }
            __buffer__.insert_new_line_at_cursor(__cursor__);
        };

        static __insert_character__ = function(_char) {
            if (__selection__.is_active()) {
                __buffer__.delete_selection(__selection__);
                __selection__.clear();
            }

            __buffer__.insert_char_at_cursor(__cursor__, _char);
        };

        static __move_cursor__ = function(_dir, _shift) {
            var pos = __cursor__.get_position();
            var [_line, _col] = pos;

            switch (_dir) {
                case "left": __cursor__.move_left(); break;
                case "right": __cursor__.move_right(); break;
                case "up": __cursor__.move_up(); break;
                case "down": __cursor__.move_down(); break;
            }

            if (_shift) {
                __selection__.set_active(__cursor__.get_position()[0], __cursor__.get_position()[1]);
            } else {
                __selection__.clear();
            }
        };

    #endregion
}

#region jsDoc
/// @func    WWTextEventRouter()
/// @desc    Routes mouse, keyboard, clipboard, and focus events to appropriate text subcomponents. Manages input focus and cursor/selection interaction.
/// @returns {Struct.WWTextEventRouter}
#endregion
function WWTextEventRouter() constructor {
    debug_name = "WWTextEventRouter";

    #region Public

        /// @func    set_input_handler()
        /// @desc    Registers the input handler component for keyboard/keybind forwarding.
        static set_input_handler = function(_handler) {
            __input_handler__ = _handler;
        };

        /// @func    set_cursor()
        /// @desc    Registers the cursor component (for click placement or drag).
        static set_cursor = function(_cursor) {
            __cursor__ = _cursor;
        };

        /// @func    set_selection()
        /// @desc    Registers the selection component.
        static set_selection = function(_selection) {
            __selection__ = _selection;
        };

        /// @func    set_renderer()
        /// @desc    Registers the text renderer (must support hit testing).
        static set_renderer = function(_renderer) {
            __renderer__ = _renderer;
        };

        /// @func    on_key_down()
        /// @desc    Forwards a key press to the input handler.
        static on_key_down = function(key, shift = false, ctrl = false, alt = false) {
            if (__input_handler__ != undefined) {
                __input_handler__.handle_key_down(key, shift, ctrl, alt);
            }
        };

        /// @func    on_mouse_down()
        /// @desc    Begins selection by placing the cursor and anchor.
        static on_mouse_down = function(x, y) {
            if (__renderer__ == undefined || __cursor__ == undefined || __selection__ == undefined) return;

            var pos = __renderer__.hit_test_position(x, y);
            __cursor__.set_position(pos.line, pos.column);
            __selection__.set_anchor(pos.line, pos.column);
            __selection__.set_active(pos.line, pos.column);
        };

        /// @func    on_mouse_move()
        /// @desc    Updates selection during drag.
        static on_mouse_move = function(x, y, pressed) {
            if (!pressed) return;
            if (__renderer__ == undefined || __selection__ == undefined) return;

            var pos = __renderer__.hit_test_position(x, y);
            __selection__.set_active(pos.line, pos.column);
        };

        /// @func    on_mouse_up()
        /// @desc    Finalizes selection position after drag.
        static on_mouse_up = function(x, y) {
            if (__renderer__ == undefined || __selection__ == undefined) return;

            var pos = __renderer__.hit_test_position(x, y);
            __selection__.set_active(pos.line, pos.column);
        };

        /// @func    on_focus()
        /// @desc    Marks the text box as focused.
        static on_focus = function() {
            __has_focus__ = true;
        };

        /// @func    on_blur()
        /// @desc    Clears focus and resets interaction state.
        static on_blur = function() {
            __has_focus__ = false;
            if (__selection__ != undefined) __selection__.clear();
        };

        /// @func    on_paste()
        /// @desc    Forwards pasted text to the input handler.
        static on_paste = function(pasted_text) {
            if (__input_handler__ != undefined) {
                __input_handler__.handle_paste(pasted_text);
            }
        };

        /// @func    has_focus()
        /// @desc    Returns whether this textbox is currently focused.
        static has_focus = function() {
            return __has_focus__;
        };

    #endregion

    #region Private

        static __input_handler__ = undefined;
        static __cursor__ = undefined;
        static __selection__ = undefined;
        static __renderer__ = undefined;

        static __has_focus__ = false;

    #endregion
}

#region jsDoc
/// @func    WWUndoManager()
/// @desc    Provides undo/redo support for text editing by storing snapshots of state. Includes configurable history limit and clear/reset methods.
/// @returns {Struct.WWUndoManager}
#endregion
function WWUndoManager() constructor {
    debug_name = "WWUndoManager";

    #region Public

        /// @func    record_state(state_snapshot)
        /// @desc    Records a new state into the undo stack and clears redo history.
        static record_state = function(state_snapshot) {
            if (array_length(__redo_stack__) > 0) {
                __redo_stack__ = [];
            }

            array_push(__undo_stack__, state_snapshot);

            if (array_length(__undo_stack__) > __limit__) {
                array_delete(__undo_stack__, 0, array_length(__undo_stack__) - __limit__);
            }
        };

        /// @func    can_undo()
        /// @desc    Returns true if an undo operation is possible.
        static can_undo = function() {
            return array_length(__undo_stack__) > 1;
        };

        /// @func    can_redo()
        /// @desc    Returns true if a redo operation is possible.
        static can_redo = function() {
            return array_length(__redo_stack__) > 0;
        };

        /// @func    undo()
        /// @desc    Pops one state from the undo stack and pushes it to redo. Returns new current state.
        static undo = function() {
            if (!self.can_undo()) return undefined;

            var current_state = array_pop(__undo_stack__);
            array_push(__redo_stack__, current_state);

            return __undo_stack__[@ array_length(__undo_stack__) - 1];
        };

        /// @func    redo()
        /// @desc    Pops one state from the redo stack and returns it (also pushes to undo stack).
        static redo = function() {
            if (!self.can_redo()) return undefined;

            var redo_state = array_pop(__redo_stack__);
            array_push(__undo_stack__, redo_state);

            return redo_state;
        };

        /// @func    clear()
        /// @desc    Empties both undo and redo stacks.
        static clear = function() {
            __undo_stack__ = [];
            __redo_stack__ = [];
        };

        /// @func    set_limit(limit)
        /// @desc    Sets the maximum size of the undo history.
        static set_limit = function(_limit) {
            __limit__ = max(1, _limit);

            if (array_length(__undo_stack__) > __limit__) {
                array_delete(__undo_stack__, 0, array_length(__undo_stack__) - __limit__);
            }
        };

    #endregion

    #region Private

        static __undo_stack__ = [];
        static __redo_stack__ = [];
        static __limit__ = 64;

    #endregion
}
