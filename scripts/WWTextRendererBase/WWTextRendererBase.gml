#region jsDoc
/// @func    WWTextRendererBase()
/// @desc    Unified text renderer component. Responsible for:
///          - Text source (textbox buffer or caption)
///          - Layout build (lines + glyphs)
///          - Metrics + hit testing helpers
///          - Basic VB baking (glyphs only, default style)
///          Does NOT implement markup parsing or diagnostics underlines.
/// @returns {Struct.WWTextRendererBase}
#endregion
function WWTextRendererBase() : WWCore() constructor {
    debug_name = "WWTextRendererBase";

    #region Public

        #region Builder Functions

            #region Text Source

                #region jsDoc
                /// @func   set_caption()
                /// @desc   Sets the caption or placeholder string. Used when there
                ///         is no text in the buffer, or when the renderer is used
                ///         for static labels.
                /// @param  {String} _text
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_caption = function(_text) {
                    var _new_text = string(_text);
                    if (caption == _new_text) {
                        return self;
                    }
                    caption = _new_text;
                    __mark_dirty__();
                    return self;
                };

            #endregion

            #region Styling

                #region jsDoc
                /// @func   set_font()
                /// @desc   Sets the font used for rendering. Also marks layout dirty.
                /// @param  {Asset.GMFont} _font_asset
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_font = function(_font_asset) {
                    if (font == _font_asset) {
                        return self;
                    }
                    font = _font_asset;
                    __mark_dirty__();
                    return self;
                };

                #region jsDoc
                /// @func   set_font_fallbacks()
                /// @desc   Sets an ordered list of fallback fonts (highest priority first).
                /// @param  {Array<Asset.GMFont>} _font_array
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_font_fallbacks = function(_font_array) {
                    font_fallbacks = _font_array;
                    __mark_dirty__();
                    return self;
                };

                #region jsDoc
                /// @func   set_text_color()
                /// @desc   Sets the color used to render text.
                /// @param  {Constant.Color} _color_value
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_text_color = function(_color_value) {
                    if (color == _color_value) {
                        return self;
                    }
                    color = _color_value;
                    __mark_vb_dirty__();
                    return self;
                };

                #region jsDoc
                /// @func   set_text_alpha()
                /// @desc   Sets the alpha used to render text.
                /// @param  {Real} _alpha_value
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_text_alpha = function(_alpha_value) {
                    if (alpha == _alpha_value) {
                        return self;
                    }
                    alpha = _alpha_value;
                    __mark_vb_dirty__();
                    return self;
                };

            #endregion

            #region Layout Config

                #region jsDoc
                /// @func   set_wrap_enabled()
                /// @desc   Sets if word wrapping is enabled.
                /// @param  {Bool} _should_wrap
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_wrap_enabled = function(_should_wrap) {
                    should_wrap = _should_wrap;
                    __mark_dirty__();
                    return self;
                };

                #region jsDoc
                /// @func   set_line_sep()
                /// @desc   Sets the extra spacing between wrapped lines (in pixels).
                /// @param  {Real} _line_sep_pixels
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_line_sep = function(_line_sep_pixels) {
                    line_sep = _line_sep_pixels;
                    __mark_dirty__();
                    return self;
                };

                #region jsDoc
                /// @func   set_tab_size_spaces()
                /// @desc   Sets how many spaces per tab stop (usually 2 or 4).
                /// @param  {Real} _space_count
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_tab_size_spaces = function(_space_count) {
                    var _space_count_int = floor(_space_count);
                    if (_space_count_int < 1) { _space_count_int = 1; }

                    if (tab_size_spaces == _space_count_int) {
                        return self;
                    }

                    tab_size_spaces = _space_count_int;
                    __mark_dirty__();
                    return self;
                };

                #region jsDoc
                /// @func   set_tab_use_stops()
                /// @desc   If enabled, a tab advances to the next tab stop.
                /// @param  {Bool} _use_stops
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_tab_use_stops = function(_use_stops) {
                    if (tab_use_stops == _use_stops) {
                        return self;
                    }

                    tab_use_stops = _use_stops;
                    __mark_dirty__();
                    return self;
                };
				
				#region Whitespace visibility
					
		            whitespace_visible = false;
		            whitespace_color = c_gray;
		            whitespace_alpha = 0.35;
		            whitespace_marker_space = ".";
		            whitespace_marker_tab = ">";

		            static set_whitespace_visible = function(_is_visible) {
		                if (whitespace_visible == _is_visible) {
		                    return self;
		                }
		                whitespace_visible = _is_visible;
		                __mark_vb_dirty__();
		                return self;
		            };

		            static set_whitespace_color = function(_color_value) {
		                if (whitespace_color == _color_value) {
		                    return self;
		                }
		                whitespace_color = _color_value;
		                __mark_vb_dirty__();
		                return self;
		            };

		            static set_whitespace_alpha = function(_alpha_value) {
		                if (whitespace_alpha == _alpha_value) {
		                    return self;
		                }
		                whitespace_alpha = _alpha_value;
		                __mark_vb_dirty__();
		                return self;
		            };

		        #endregion
            #endregion

        #endregion

        #region Events

            events.text_change = variable_get_hash("text_change");
            static on_text_change = function(_func) {
                add_event_listener(events.text_change, _func);
                return self;
            };

            on_text_change(function(_input) {
                __mark_dirty__();
            });

            on_post_step(function(_input) {
                __ensure_layout__();
            });

            on_post_draw(function(_input) {
                __draw_text_vb__(x, y);
            });

        
            #region Markup / formatting options

                #region jsDoc
                /// @func    set_formatting_enabled()
                /// @desc    Enable or disable per-glyph formatting (style/size/font overrides).
                /// @param   {Bool} _enabled
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_formatting_enabled = function(_enabled) {

                    _enabled = (_enabled == true);

                    if (formatting_enabled == _enabled) {
                        return self;
                    }

                    formatting_enabled = _enabled;
                    __mark_vb_dirty__();

                    return self;
                }

            #endregion

            #region Whitespace visualization

                #region jsDoc
                /// @func    set_whitespace_visible()
                /// @desc    Toggle visualization of spaces/tabs using marker glyphs.
                /// @param   {Bool} _visible
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_whitespace_visible = function(_visible) {

                    _visible = (_visible == true);

                    if (whitespace_visible == _visible) {
                        return self;
                    }

                    whitespace_visible = _visible;
                    __mark_vb_dirty__();

                    return self;
                }

                #region jsDoc
                /// @func    set_whitespace_markers()
                /// @desc    Set marker characters used for space and tab.
                /// @param   {String} _space_marker
                /// @param   {String} _tab_marker
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_whitespace_markers = function(_space_marker, _tab_marker) {

                    if (is_string(_space_marker) && string_length(_space_marker) > 0) {
                        whitespace_marker_space = string_char_at(_space_marker, 1);
                    }

                    if (is_string(_tab_marker) && string_length(_tab_marker) > 0) {
                        whitespace_marker_tab = string_char_at(_tab_marker, 1);
                    }

                    __mark_vb_dirty__();
                    return self;
                }

                #region jsDoc
                /// @func    set_whitespace_color()
                /// @desc    Set whitespace marker color and alpha.
                /// @param   {Real} _color_value
                /// @param   {Real} _alpha_value
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_whitespace_color = function(_color_value, _alpha_value=undefined) {

                    whitespace_color = _color_value;

                    if (!is_undefined(_alpha_value)) {
                        whitespace_alpha = _alpha_value;
                    }

                    __mark_vb_dirty__();
                    return self;
                }

            #endregion

            #region Underline options

                #region jsDoc
                /// @func    set_underline_enabled()
                /// @desc    Enable or disable underline rendering.
                /// @param   {Bool} _enabled
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_underline_enabled = function(_enabled) {

                    _enabled = (_enabled == true);

                    if (underline_enabled == _enabled) {
                        return self;
                    }

                    underline_enabled = _enabled;
                    __mark_vb_dirty__();

                    return self;
                }

                #region jsDoc
                /// @func    set_underline_offset()
                /// @desc    Adjust underline Y offset in pixels (added after glyph height).
                /// @param   {Real} _offset
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_underline_offset = function(_offset) {

                    underline_y_offset = _offset;
                    __mark_vb_dirty__();

                    return self;
                }

                #region jsDoc
                /// @func    set_underline_thickness()
                /// @desc    Set thickness for plain underline in pixels.
                /// @param   {Real} _thickness
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_underline_thickness = function(_thickness) {

                    underline_thickness = _thickness;
                    __mark_vb_dirty__();

                    return self;
                }

                #region jsDoc
                /// @func    set_underline_sprites()
                /// @desc    Set sprites used for underline styles.
                /// @param   {Asset.GMSprite} _sprite_white
                /// @param   {Asset.GMSprite} _sprite_warning
                /// @param   {Asset.GMSprite} _sprite_error
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_underline_sprites = function(_sprite_white, _sprite_warning, _sprite_error) {

                    underline_sprite_white = _sprite_white;
                    underline_sprite_warning = _sprite_warning;
                    underline_sprite_error = _sprite_error;

                    __mark_vb_dirty__();
                    return self;
                }

            

            #region Strike-through options

                #region jsDoc
                /// @func    set_strike_enabled()
                /// @desc    Enable or disable strike-through rendering.
                /// @param   {Bool} _enabled
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_strike_enabled = function(_enabled) {

                    _enabled = (_enabled == true);

                    if (strike_enabled == _enabled) {
                        return self;
                    }

                    strike_enabled = _enabled;
                    __mark_vb_dirty__();

                    return self;
                }

                #region jsDoc
                /// @func    set_strike_offset()
                /// @desc    Adjust strike-through Y offset in pixels (added around midline).
                /// @param   {Real} _offset
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_strike_offset = function(_offset) {

                    strike_y_offset = _offset;
                    __mark_vb_dirty__();

                    return self;
                }

                #region jsDoc
                /// @func    set_strike_thickness()
                /// @desc    Set thickness for plain strike-through in pixels.
                /// @param   {Real} _thickness
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_strike_thickness = function(_thickness) {

                    strike_thickness = _thickness;
                    __mark_vb_dirty__();

                    return self;
                }

                #region jsDoc
                /// @func    set_strike_sprites()
                /// @desc    Set sprites used for strike-through styles.
                /// @param   {Asset.GMSprite} _sprite_white
                /// @param   {Asset.GMSprite} _sprite_warning
                /// @param   {Asset.GMSprite} _sprite_error
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_strike_sprites = function(_sprite_white, _sprite_warning, _sprite_error) {

                    strike_sprite_white = _sprite_white;
                    strike_sprite_warning = _sprite_warning;
                    strike_sprite_error = _sprite_error;

                    __mark_vb_dirty__();
                    return self;
                }

            #endregion

#endregion
#endregion

        #region Variables

            // Styling
            caption = "";
            font = fnt_ww_default_small;
            font_fallbacks = [];
            color = c_white;
            alpha = 1;


            // Formatting / diagnostics (optional)
            formatting_enabled = true;

            // Whitespace visualization
            whitespace_visible = false;
            whitespace_marker_space = ".";
            whitespace_marker_tab = ">";
            whitespace_color = c_gray;
            whitespace_alpha = 0.5;

            // Underlines
            underline_enabled = true;
            underline_y_offset = 0;
            underline_thickness = 1;
            underline_sprite_white = spr_ww_pixel;
            underline_sprite_warning = spr_ww_underline_warning;
            underline_sprite_error = spr_ww_underline_error;

            // Strike-through
            strike_enabled = true;
            strike_y_offset = 0;
            strike_thickness = 1;
            strike_sprite_white = spr_ww_pixel;
            strike_sprite_warning = spr_ww_underline_warning;
            strike_sprite_error = spr_ww_underline_error;

            // Background (inline)
            background_sprite = spr_ww_pixel;
            // Layout
            should_wrap = false;
            line_sep = -1;

            // Tabs
            tab_size_spaces = 4;
            tab_use_stops = true;
			
        #endregion

        #region Public API - Core queries

            #region jsDoc
            /// @func   get_font()
            /// @returns {Asset.GMFont}
            #endregion
            static get_font = function() {
                return font;
            };

            #region jsDoc
            /// @func   get_width()
            /// @returns {Real}
            #endregion
            static get_width = function() {
                __ensure_layout__();
                return __content_width__;
            };

            #region jsDoc
            /// @func   get_height()
            /// @returns {Real}
            #endregion
            static get_height = function() {
                __ensure_layout__();
                return __content_height__;
            };

            #region Location Maths

            #region jsDoc
            /// @func   get_x_from_index()
            /// @param  {Real} _index
            /// @returns {Real}
            #endregion
            static get_x_from_index = function(_index) {
                __ensure_layout__();

                var _line_index = get_line_from_index(_index);
                var _start_index = __layout__.get_line_index_start(_line_index);
                var _end_index = __layout__.get_line_index_end(_line_index);
                var _line_width_val = __layout__.get_line_width(_line_index);

                var _line_len = _end_index - _start_index;
                if (_line_len <= 0) {
                    return 0;
                }

                if (_index <= _start_index) {
                    return 0;
                }
                if (_index >= _end_index) {
                    return _line_width_val;
                }

                var _target_index = _index;
                var _glyph_count = __layout__.get_glyph_count();
                var _sum_width = 0;

                var _glyph_index = 0;
                repeat (_glyph_count) {
                    var _glyph_logical_index = __layout__.get_glyph_index(_glyph_index);

                    if (_glyph_logical_index < _start_index) {
                        _glyph_index++;
                        continue;
                    }
                    if (_glyph_logical_index >= _target_index) {
                        break;
                    }

                    _sum_width += __layout__.get_glyph_width(_glyph_index);
                    _glyph_index++;
                }

                return _sum_width;
            };

            #region jsDoc
            /// @func   get_y_from_index()
            /// @param  {Real} _index
            /// @returns {Real}
            #endregion
            static get_y_from_index = function(_index) {
                __ensure_layout__();
                var _line_index = get_line_from_index(_index);
                return __layout__.get_line_y_offset(_line_index);
            };

            #region jsDoc
            /// @func   get_index_from_xy()
            /// @param  {Real} _x
            /// @param  {Real} _y
            /// @returns {Real}
            #endregion
            static get_index_from_xy = function(_x, _y) {
                __ensure_layout__();

                var _layout = __layout__;

                var _target_x = _x - x;
                var _target_y = clamp(_y - y, 0, get_height());

                var _line_count = _layout.get_line_count();
                var _line_index = 0;

                var _scan_index = 0;
                repeat (_line_count) {
                    var _y_offset = _layout.get_line_y_offset(_scan_index);
                    var _height_val = _layout.get_line_height(_scan_index);
                    _line_index = _scan_index;

                    if (_target_y >= _y_offset && _target_y < _y_offset + _height_val) {
                        break;
                    }

                    _scan_index++;
                }

                var _start_index = _layout.get_line_index_start(_line_index);
                var _end_index = _layout.get_line_index_end(_line_index);
                var _line_width_val = _layout.get_line_width(_line_index);

                if (_target_x <= 0) { return _start_index; }

                if (_target_x >= _line_width_val) {

                    var _is_forced_wrapped = _layout.get_line_forced_wrapped(_line_index);
                    var _is_last_line = (_line_index == _line_count - 1);

                    if (_is_forced_wrapped || _is_last_line) {
                        return _end_index;
                    }

                    return max(_start_index, _end_index - 1);
                }

                var _index_result = _end_index;
                var _sum_width = 0;

                var _line_len = _end_index - _start_index;
                var _walk_index = _start_index;

                repeat (_line_len) {
                    var _glyph_width = _layout.get_glyph_width(_walk_index);
                    var _mid = _sum_width + (_glyph_width * 0.5);

                    if (_target_x < _mid) {
                        _index_result = _walk_index;
                        break;
                    }

                    _sum_width += _glyph_width;
                    _index_result = _walk_index + 1;
                    _walk_index++;
                }

                return _index_result;
            };

            #region jsDoc
            /// @func   get_line_from_index()
            /// @param  {Real} _index
            /// @returns {Real}
            #endregion
            static get_line_from_index = function(_index) {
                __ensure_layout__();

                var _line_count = __layout__.get_line_count();
                if (_line_count <= 0) {
                    return 0;
                }

                var _result_line = 0;
                var _line_index = 0;
                repeat (_line_count) {
                    var _start_index = __layout__.get_line_index_start(_line_index);
                    var _end_index = __layout__.get_line_index_end(_line_index);

                    if (_index >= _start_index && _index < _end_index) {
                        return _line_index;
                    }

                    if (_index >= _end_index) {
                        _result_line = _line_index;
                    }

                    _line_index++;
                }

                return _result_line;
            };

            #region jsDoc
            /// @func   get_col_from_index()
            /// @param  {Real} _index
            /// @returns {Real}
            #endregion
            static get_col_from_index = function(_index) {
                __ensure_layout__();

                var _line_index = get_line_from_index(_index);
                var _start_index = __layout__.get_line_index_start(_line_index);

                var _col_index = _index - _start_index;
                if (_col_index < 0) { _col_index = 0; }
                return _col_index;
            };

            #region jsDoc
            /// @func   get_index_from_line_col()
            /// @param  {Real} _line
            /// @param  {Real} _col
            /// @returns {Real}
            #endregion
            static get_index_from_line_col = function(_line, _col) {
                __ensure_layout__();

                var _line_count = __layout__.get_line_count();
                if (_line_count <= 0) {
                    return 0;
                }

                var _line_index = _line;
                if (_line_index < 0) { _line_index = 0; }
                if (_line_index >= _line_count) { _line_index = _line_count - 1; }

                var _start_index = __layout__.get_line_index_start(_line_index);
                var _end_index = __layout__.get_line_index_end(_line_index);
                var _line_len = _end_index - _start_index;

                var _col_index = _col;
                if (_col_index < 0) { _col_index = 0; }
                if (_col_index > _line_len) { _col_index = _line_len; }

                return _start_index + _col_index;
            };

            #endregion

            #region Line getters

            static get_line_count = function() {
                __ensure_layout__();
                return __layout__.get_line_count();
            };

            static get_line = function(_line_index) {
                __ensure_layout__();
                return __layout__.get_line(_line_index);
            };

            static get_line_text = function(_line_index) {
                __ensure_layout__();
                return __layout__.get_line_text(_line_index);
            };

            static get_line_index_start = function(_line_index) {
                __ensure_layout__();
                return __layout__.get_line_index_start(_line_index);
            };

            static get_line_index_end = function(_line_index) {
                __ensure_layout__();
                return __layout__.get_line_index_end(_line_index);
            };

            static get_line_width = function(_line_index) {
                __ensure_layout__();
                return __layout__.get_line_width(_line_index);
            };

            static get_line_height = function(_line_index) {
                __ensure_layout__();
                return __layout__.get_line_height(_line_index);
            };

            static get_line_y_offset = function(_line_index) {
                __ensure_layout__();
                return __layout__.get_line_y_offset(_line_index);
            };

            static get_line_forced_wrapped = function(_line_index) {
                __ensure_layout__();
                return __layout__.get_line_forced_wrapped(_line_index);
            };

            #endregion

            #region Glyph getters

            static get_glyph_count = function() {
                __ensure_layout__();
                return __layout__.get_glyph_count();
            };

            static get_glyph = function(_glyph_index) {
                __ensure_layout__();
                return __layout__.get_glyph(_glyph_index);
            };

            static get_glyph_char = function(_glyph_index) {
                __ensure_layout__();
                return __layout__.get_glyph_char(_glyph_index);
            };

            static get_glyph_index = function(_glyph_index) {
                __ensure_layout__();
                return __layout__.get_glyph_index(_glyph_index);
            };

            static get_glyph_buffer_index = function(_glyph_index) {
                __ensure_layout__();
                return __layout__.get_glyph_buffer_index(_glyph_index);
            };

            static get_glyph_buffer_size = function(_glyph_index) {
                __ensure_layout__();
                return __layout__.get_glyph_buffer_size(_glyph_index);
            };

            static get_glyph_x = function(_glyph_index) {
                __ensure_layout__();
                return __layout__.get_glyph_x(_glyph_index);
            };

            static get_glyph_y = function(_glyph_index) {
                __ensure_layout__();
                return __layout__.get_glyph_y(_glyph_index);
            };

            static get_glyph_width = function(_glyph_index) {
                __ensure_layout__();
                return __layout__.get_glyph_width(_glyph_index);
            };

            static get_glyph_height = function(_glyph_index) {
                __ensure_layout__();
                return __layout__.get_glyph_height(_glyph_index);
            };

            #endregion

            #region Buffer region

            #region jsDoc
            /// @func   get_buffer_index_from_index()
            /// @param  {Real} _index
            /// @returns {Real}
            #endregion
            static get_buffer_index_from_index = function(_index) {
                __ensure_layout__();
                return __layout__.get_glyph_buffer_index(_index);
            };

            #region jsDoc
            /// @func   get_index_from_buffer_index()
            /// @param  {Real} _buffer_index
            /// @returns {Real}
            #endregion
            static get_index_from_buffer_index = function(_buffer_index) {
                __ensure_layout__();

                if (_buffer_index <= 0) { return 0; }

                var _glyph_count = __layout__.get_glyph_count();
                if (_glyph_count <= 0) { return 0; }

                var _last_glyph_index = _glyph_count - 1;
                var _last_glyph_buffer_start = __layout__.get_glyph_buffer_index(_last_glyph_index);

                if (_buffer_index == _last_glyph_buffer_start) {
                    return __layout__.get_glyph_index(_last_glyph_index);
                }

                var _last_glyph_buffer_end = _last_glyph_buffer_start + __layout__.get_glyph_buffer_size(_last_glyph_index);

                if (_buffer_index >= _last_glyph_buffer_end) {
                    return __layout__.get_glyph_index(_last_glyph_index) + 1;
                }

                var _line_count = __layout__.get_line_count();
                if (_line_count <= 0) {
                    return 0;
                }

                var _target_line_index = 0;
                var _found_line = false;

                var _line_index = 0;
                repeat (_line_count) {

                    var _glyph_start = __layout__.get_line_index_start(_line_index);
                    var _glyph_end = __layout__.get_line_index_end(_line_index);
                    var _glyph_count_line = _glyph_end - _glyph_start;

                    if (_glyph_count_line > 0) {

                        var _first_buf_start = __layout__.get_glyph_buffer_index(_glyph_start);
                        var _last_glyph_in_line = _glyph_end - 1;
                        var _last_buf_start = __layout__.get_glyph_buffer_index(_last_glyph_in_line);
                        var _last_buf_size = __layout__.get_glyph_buffer_size(_last_glyph_in_line);
                        var _line_buf_end = _last_buf_start + _last_buf_size;

                        if (_buffer_index < _first_buf_start) {
                            _target_line_index = _line_index;
                            _found_line = true;
                            break;
                        }

                        if (_buffer_index >= _first_buf_start && _buffer_index < _line_buf_end) {
                            _target_line_index = _line_index;
                            _found_line = true;
                            break;
                        }

                        _target_line_index = _line_index;
                    }

                    _line_index++;
                }

                if (!_found_line) {
                    var _last_line_index = _line_count - 1;
                    var _last_glyph_start2 = __layout__.get_line_index_start(_last_line_index);
                    var _last_glyph_end2 = __layout__.get_line_index_end(_last_line_index);

                    if (_last_glyph_end2 > _last_glyph_start2) {
                        var _last_glyph2 = _last_glyph_end2 - 1;
                        return __layout__.get_glyph_index(_last_glyph2) + 1;
                    }

                    return 0;
                }

                var _line_start_index = __layout__.get_line_index_start(_target_line_index);

                var _glyph_start_line = __layout__.get_line_index_start(_target_line_index);
                var _glyph_end_line = __layout__.get_line_index_end(_target_line_index);
                var _glyph_count_line2 = _glyph_end_line - _glyph_start_line;

                if (_glyph_count_line2 <= 0) {
                    return _line_start_index;
                }

                var _first_buf_start_line = __layout__.get_glyph_buffer_index(_glyph_start_line);
                if (_buffer_index <= _first_buf_start_line) {
                    return _line_start_index;
                }

                var _closest_index = _line_start_index;

                var _glyph_index2 = _glyph_start_line;
                repeat (_glyph_count_line2) {

                    var _buf_start = __layout__.get_glyph_buffer_index(_glyph_index2);
                    var _buf_size = __layout__.get_glyph_buffer_size(_glyph_index2);
                    var _buf_end = _buf_start + _buf_size;

                    var _logical_index = __layout__.get_glyph_index(_glyph_index2);

                    if (_buffer_index >= _buf_start && _buffer_index < _buf_end) {
                        return _logical_index;
                    }

                    if (_buffer_index < _buf_start) {
                        return _logical_index;
                    }

                    _closest_index = _logical_index + 1;
                    _glyph_index2++;
                }

                return _closest_index;
            };

            #endregion

        #endregion

    #endregion

    #region Private

        #region Variables

            __is_dirty__ = true;
            __display_text__ = "";
            __content_width__ = 0;
            __content_height__ = 0;

            // VB cache
            __vb_is_dirty__ = true;
            __vb_format__ = undefined;

            // Unified draw batches
            __draw_batches__ = [];

            // Per-font info cache
            __font_info_cache__ = {};
            __font_uv_cache__ = {};
            __font_tex_cache__ = {};
            __font_texw_cache__ = {};
            __font_texh_cache__ = {};

            // Per-font SDF/MSDF cache
            __font_sdf_enabled_cache__ = {};
            __font_sdf_spread_cache__ = {};
            __font_sdf_shader_cache__ = {};

            // Tab metrics cached per rebuild
            __space_width__ = 0;
            __tab_width__ = 0;
			
			__textbox_parent__ = undefined;
			__layout__ = __build_layout__("");
			
        #endregion

        #region Dirty flags

            static __mark_dirty__ = function() {
                __is_dirty__ = true;
                __mark_vb_dirty__();
            };

            static __mark_vb_dirty__ = function() {
                __vb_is_dirty__ = true;
            };

        #endregion

        #region VB batch helpers

            #region jsDoc
            /// @func   __vb_get_batch_for_material__()
            /// @param  {Id.Texture} _tex
            /// @param  {Array} _uvs
            /// @param  {Real} _layer
            /// @returns {Struct} { batch, created }
            #endregion
            static __vb_get_batch_for_material__ = function(_tex, _uvs, _layer, _shader, _spread) {

                var _u0 = 0;
                var _v0 = 0;
                var _u1 = 0;
                var _v1 = 0;

                if (is_array(_uvs) && array_length(_uvs) >= 4) {
                    _u0 = _uvs[0];
                    _v0 = _uvs[1];
                    _u1 = _uvs[2];
                    _v1 = _uvs[3];
                }

                var _batch_count = array_length(__draw_batches__);
                var _batch_index = 0;

                repeat (_batch_count) {
                    var _batch = __draw_batches__[_batch_index];

                    if (_batch.layer == _layer) {
                        var _material = _batch.material;

                        if (!is_undefined(_material) && _material.tex == _tex && _material.shader == _shader && _material.spread == _spread) {
                            var _material_uvs = _material.uvs;

                            if (is_array(_material_uvs) && array_length(_material_uvs) >= 4) {
                                if (_material_uvs[0] == _u0 && _material_uvs[1] == _v0 && _material_uvs[2] == _u1 && _material_uvs[3] == _v1) {
                                    return { batch: _batch, created: false };
                                }
                            }
                        }
                    }

                    _batch_index++;
                }

                var _vertex_buffer = vertex_create_buffer();
                var _closure = { vb: _vertex_buffer, tex: _tex, shader: _shader, spread: _spread };

                var _draw_fn = method(_closure, function(_x, _y) {
					if (!is_undefined(shader)) {
						shader_set(shader);
						vertex_submit(vb, pr_trianglelist, tex);
                        shader_reset();
                    }
					else {
                        vertex_submit(vb, pr_trianglelist, tex);
                    }
                });

                var _new_material = new WWMaterial(_draw_fn);
                _new_material.tex = _tex;
                _new_material.uvs = _uvs;
                _new_material.shader = _shader;
                _new_material.spread = _spread;

                var _new_batch = {
                    material: _new_material,
                    buffer: _vertex_buffer,
                    format: __vb_format__,
                    layer: _layer
                };

                array_push(__draw_batches__, _new_batch);
                vertex_begin(_new_batch.buffer, _new_batch.format);

                return { batch: _new_batch, created: true };
            };

            static __vb_ensure_format__ = function() {
                if (!is_undefined(__vb_format__)) {
                    return;
                }

                vertex_format_begin();
                vertex_format_add_position();
                vertex_format_add_texcoord();
                vertex_format_add_colour();
                __vb_format__ = vertex_format_end();
            };

        #endregion

        #region Tabs

            static __tab_advance__ = function(_cursor_x) {
                var _tab_width_local = __tab_width__;
                if (_tab_width_local <= 0) {
                    return 0;
                }

                if (!tab_use_stops) {
                    return _tab_width_local;
                }

                var _pos_mod = _cursor_x mod _tab_width_local;
                if (_pos_mod == 0) {
                    return _tab_width_local;
                }

                return _tab_width_local - _pos_mod;
            };

            static __measure_line_width_tabs__ = function(_line_text) {
                var _line_len = string_length(_line_text);
                if (_line_len <= 0) {
                    return 0;
                }

                var _cursor_x_local = 0;

                var _char_index = 1;
                repeat (_line_len) {
                    var _char_val = string_char_at(_line_text, _char_index);

                    if (_char_val == "\t") {
                        _cursor_x_local += __tab_advance__(_cursor_x_local);
                    } else if (_char_val == "\n" || _char_val == "\r") {
                        // no width
                    } else {
                        _cursor_x_local += string_width(_char_val);
                    }

                    _char_index++;
                }

                return _cursor_x_local;
            };

        #endregion

        #region Text + layout

            static __set_textbox__ = function(_comp) {
                __textbox_parent__ = _comp;
                return self;
            };

            static __string_split_and_retain__ = function(_str, _delim) {
                static __closure = {};
                static __fn = method(__closure, function(_value, _index) {
                    if (last_index == _index) { return _value; }
                    return _value + delim;
                });

                var _arr = string_split(_str, _delim);
                __closure.delim = _delim;
                __closure.last_index = array_length(_arr) - 1;
                array_map_ext(_arr, __fn);
                return _arr;
            };

            static __ensure_layout__ = function() {
                if (!__is_dirty__) {
                    return;
                }

                var _text_value = "";
                if (!is_undefined(__textbox_parent__)) {
                    _text_value = __textbox_parent__.get_text();
                }

                if (_text_value == "") {
                    _text_value = caption;
                }

                __display_text__ = _text_value;

                __layout__ = __build_layout__(_text_value);

                __content_width__ = __layout__.get_content_width();
                __content_height__ = __layout__.get_content_height();

                __is_dirty__ = false;
            };
			
			#region jsDoc
			/// @func   __build_layout__(_str, _metric_runs, _visual_runs)
			/// @param  {String} _str
			/// @param  {Array|Undefined} _metric_runs
			/// @param  {Array|Undefined} _visual_runs
			/// @returns {Struct.WWTextLayout}
			#endregion
			static __build_layout__ = function(_str, _metric_runs=undefined, _visual_runs=undefined) {

			    var _layout = new WWTextLayout();

			    if (_str == "") {

			        if (!is_undefined(__textbox_parent__)) {
			            _layout.apply_line_alignment(__textbox_parent__.width);
			        }

			        return _layout;
			    }

			    var _text_length = string_length(_str);

			    var _width_limit = infinity;
			    if (should_wrap && !is_undefined(__textbox_parent__)) {
			        _width_limit = __textbox_parent__.width;
			    }

			    var _wrap_enabled = (_width_limit != infinity && _width_limit >= 0);

			    // ---------------------------------
			    // Run cursors (no closures)
			    // ---------------------------------

			    static __empty_arr = [];

			    _metric_runs ??= __empty_arr;
			    _visual_runs ??= __empty_arr;

			    var _metric_run_count = array_length(_metric_runs);
			    var _metric_run_index = 0;
			    var _metric_remaining = 0;

			    var _metric_font_override = -1;
			    var _metric_style_value = __WW_Text_Glyph_Style.Regular;
			    var _metric_size_mul = 1;

			    var _visual_run_count = array_length(_visual_runs);
			    var _visual_run_index = 0;
			    var _visual_remaining = 0;

			    var _visual_color = color;
				var _visual_back_color = undefined;
				var _visual_back_alpha = undefined;
				var _visual_strike = __WW_Text_Glyph_Strike.None;
			    var _visual_alpha = alpha;
			    var _visual_underline = __WW_Text_Glyph_Underline.None;

			    // Load first metric run
			    if (_metric_run_count > 0) {

			        var _metric_run0 = _metric_runs[0];

			        _metric_remaining = _metric_run0.index_count;

			        _metric_font_override = is_undefined(_metric_run0.font_asset_or_minus1) ? -1 : _metric_run0.font_asset_or_minus1;
			        _metric_style_value = is_undefined(_metric_run0.style_value) ? __WW_Text_Glyph_Style.Regular : _metric_run0.style_value;
			        _metric_size_mul = is_undefined(_metric_run0.size_mul) ? 1 : _metric_run0.size_mul;

			        if (_metric_size_mul <= 0) { _metric_size_mul = 1; }
			    }

			    // Load first visual run
			    if (_visual_run_count > 0) {

			        var _run = _visual_runs[0];

			        _visual_remaining = _run.index_count;

					_visual_color = is_undefined(_run.color) ? color : _run.color;
					_visual_alpha = is_undefined(_run.alpha) ? alpha : _run.alpha;
					_visual_underline = is_undefined(_run.underline) ? __WW_Text_Glyph_Underline.None : _run.underline;

					_visual_back_color = _run[$ "back_color"];
					_visual_back_alpha = _run[$ "back_alpha"];
					_visual_strike = _run[$ "strike"] ?? __WW_Text_Glyph_Strike.None;
			    }

			    // ---------------------------------
			    // Font cache for measurement
			    // ---------------------------------

			    var _old_font = draw_get_font();

			    var _active_font = -1;
			    var _active_space_width = 0;
			    var _active_tab_width = 0;
			    var _active_font_height = 1;

			    // Select initial font = renderer font
			    if (font_exists(font)) {
			        draw_set_font(font);
			        _active_font = font;
			    } else {
			        _active_font = draw_get_font();
			    }

			    _active_space_width = string_width(" ");
			    _active_tab_width = _active_space_width * tab_size_spaces;
				__space_width__ = _active_space_width;
				__tab_width__ = _active_tab_width;

			    _active_font_height = string_height("A");
			    if (_active_font_height <= 0) { _active_font_height = 1; }

			    // ---------------------------------
			    // Pass 1: build line segments using scaled advances
			    // Each segment is [start_index, end_index) in plain text indices
			    // Newline segments INCLUDE the newline glyph (end_index = i+1)
			    // ---------------------------------

			    var _line_segments = [];

			    var _line_start_index = 0;
			    var _line_width = 0;
			    var _line_height = 0;

			    var _last_break_pos = -1;
			    var _width_at_break = 0;
			    var _height_at_break = 0;

			    var _line_char_widths = [];
			    var _line_char_heights = [];

			    var _logical_index = 0;
			    while (_logical_index < _text_length) {

			        // Advance metric run if needed
			        while (_metric_remaining <= 0 && _metric_run_index < _metric_run_count - 1) {

			            _metric_run_index += 1;

			            var _metric_runn = _metric_runs[_metric_run_index];

			            _metric_remaining = _metric_runn.index_count;

			            _metric_font_override = is_undefined(_metric_runn.font_asset_or_minus1) ? -1 : _metric_runn.font_asset_or_minus1;
			            _metric_style_value = is_undefined(_metric_runn.style_value) ? __WW_Text_Glyph_Style.Regular : _metric_runn.style_value;
			            _metric_size_mul = is_undefined(_metric_runn.size_mul) ? 1 : _metric_runn.size_mul;

			            if (_metric_size_mul <= 0) { _metric_size_mul = 1; }
			        }

			        // Advance visual run if needed
			        while (_visual_remaining <= 0 && _visual_run_index < _visual_run_count - 1) {

			            _visual_run_index += 1;

			            var _run = _visual_runs[_visual_run_index];

			            _visual_remaining = _run.index_count;

						_visual_color = is_undefined(_run.color) ? color : _run.color;
						_visual_alpha = is_undefined(_run.alpha) ? alpha : _run.alpha;
						_visual_underline = is_undefined(_run.underline) ? __WW_Text_Glyph_Underline.None : _run.underline;

						_visual_back_color = _run[$ "back_color"];
						_visual_back_alpha = _run[$ "back_alpha"];
						_visual_strike = _run[$ "strike"] ?? __WW_Text_Glyph_Strike.None;
			        }

			        // Select measurement font (only update caches when font changes)
			        var _want_font = font;

			        if (_metric_font_override != -1 && font_exists(_metric_font_override)) {
			            _want_font = _metric_font_override;
			        }

			        if (_active_font != _want_font && font_exists(_want_font)) {

			            draw_set_font(_want_font);
			            _active_font = _want_font;

			            _active_space_width = string_width(" ");
			            _active_tab_width = _active_space_width * tab_size_spaces;
						__space_width__ = _active_space_width;
						__tab_width__ = _active_tab_width;

			            _active_font_height = string_height("A");
			            if (_active_font_height <= 0) { _active_font_height = 1; }
			        }

			        var _char_val = string_char_at(_str, _logical_index + 1);

			        // Newline: include as glyph slot, end the line INCLUDING the newline
			        if (_char_val == "\n") {

			            var _fallback_height_scaled = _active_font_height * _metric_size_mul;
			            if (_fallback_height_scaled > _line_height) { _line_height = _fallback_height_scaled; }

			            array_push(_line_char_widths, 0);
			            array_push(_line_char_heights, _fallback_height_scaled);

			            array_push(_line_segments, {
			                start_index: _line_start_index,
			                end_index: _logical_index + 1,
			                force_wrapped: false
			            });

			            _line_start_index = _logical_index + 1;

			            _line_width = 0;
			            _line_height = 0;

			            _last_break_pos = -1;
			            _width_at_break = 0;
			            _height_at_break = 0;

			            _line_char_widths = [];
			            _line_char_heights = [];

			            _metric_remaining -= 1;
			            _visual_remaining -= 1;

			            _logical_index += 1;
			            continue;
			        }

			        // Measure advance and height
			        var _base_width = 0;

			        if (_char_val == "\t") {

			            if (_metric_size_mul == 1) {

			                if (tab_use_stops) {
			                    _base_width = __tab_advance__(_line_width);
			                } else {
			                    _base_width = _active_tab_width;
			                }

			            } else {

			                // Scaled tabs behave like fixed width (consistent + cheap)
			                _base_width = _active_tab_width;
			            }

			        } else {

			            _base_width = string_width(_char_val);
			        }

			        var _adv_width = _base_width * _metric_size_mul;
			        var _adv_height = _active_font_height * _metric_size_mul;

			        // Wrap check
			        if (_wrap_enabled && _line_width > 0 && (_line_width + _adv_width) > _width_limit) {

			            var _break_index = -1;
			            var _segment_width = _line_width;
			            var _segment_height = _line_height;

			            if (_last_break_pos >= 0) {
			                _break_index = _last_break_pos;
			                _segment_width = _width_at_break;
			                _segment_height = _height_at_break;
			            } else {
			                _break_index = _logical_index;
			                _segment_width = _line_width;
			                _segment_height = _line_height;
			            }

			            array_push(_line_segments, {
			                start_index: _line_start_index,
			                end_index: _break_index,
			                force_wrapped: true
			            });

			            // Remainder becomes new line state
			            var _old_count = array_length(_line_char_widths);

			            var _new_widths = [];
			            var _new_heights = [];

			            var _remainder_width = 0;
			            var _remainder_height = 0;

			            var _pos_index = 0;
			            while (_pos_index < _old_count) {

			                var _abs_index = _line_start_index + _pos_index;

			                if (_abs_index >= _break_index) {

			                    var _wid_val = _line_char_widths[_pos_index];
			                    var _hei_val = _line_char_heights[_pos_index];

			                    array_push(_new_widths, _wid_val);
			                    array_push(_new_heights, _hei_val);

			                    _remainder_width += _wid_val;
			                    if (_hei_val > _remainder_height) { _remainder_height = _hei_val; }
			                }

			                _pos_index += 1;
			            }

			            _line_char_widths = _new_widths;
			            _line_char_heights = _new_heights;

			            _line_start_index = _break_index;
			            _line_width = _remainder_width;
			            _line_height = _remainder_height;

			            _last_break_pos = -1;
			            _width_at_break = 0;
			            _height_at_break = 0;

			            // Re-process this char in the new line context
			            continue;
			        }

			        array_push(_line_char_widths, _adv_width);
			        array_push(_line_char_heights, _adv_height);

			        _line_width += _adv_width;
			        if (_adv_height > _line_height) { _line_height = _adv_height; }

			        if (_char_val == " " || _char_val == "\t") {
			            _last_break_pos = _logical_index + 1;
			            _width_at_break = _line_width;
			            _height_at_break = _line_height;
			        }

			        _metric_remaining -= 1;
			        _visual_remaining -= 1;

			        _logical_index += 1;
			    }

			    // Final segment (if any remaining chars)
			    if (_line_start_index < _text_length) {
			        array_push(_line_segments, {
			            start_index: _line_start_index,
			            end_index: _text_length,
			            force_wrapped: false
			        });
			    }

			    // ---------------------------------
			    // Pass 2: emit glyphs and lines using runs
			    // ---------------------------------

			    _metric_run_index = 0;
			    _visual_run_index = 0;

			    if (_metric_run_count > 0) {

			        var _metric_run2 = _metric_runs[0];

			        _metric_remaining = _metric_run2.index_count;

			        _metric_font_override = is_undefined(_metric_run2.font_asset_or_minus1) ? -1 : _metric_run2.font_asset_or_minus1;
			        _metric_style_value = is_undefined(_metric_run2.style_value) ? __WW_Text_Glyph_Style.Regular : _metric_run2.style_value;
			        _metric_size_mul = is_undefined(_metric_run2.size_mul) ? 1 : _metric_run2.size_mul;

			        if (_metric_size_mul <= 0) { _metric_size_mul = 1; }

			    } else {

			        _metric_remaining = 999999999;
			        _metric_font_override = -1;
			        _metric_style_value = __WW_Text_Glyph_Style.Regular;
			        _metric_size_mul = 1;
			    }

			    if (_visual_run_count > 0) {

			        var _run = _visual_runs[0];

			        _visual_remaining = _run.index_count;

					_visual_color = is_undefined(_run.color) ? color : _run.color;
					_visual_alpha = is_undefined(_run.alpha) ? alpha : _run.alpha;
					_visual_underline = is_undefined(_run.underline) ? __WW_Text_Glyph_Underline.None : _run.underline;

					_visual_back_color = _run[$ "back_color"];
					_visual_back_alpha = _run[$ "back_alpha"];
					_visual_strike = _run[$ "strike"] ?? __WW_Text_Glyph_Strike.None;

			    }
				else {
			        _visual_remaining = 999999999;
			        _visual_color = color;
			        _visual_alpha = alpha;
			        _visual_underline = __WW_Text_Glyph_Underline.None;
			    }

			    // Reset font cache for pass 2
			    _active_font = -1;

			    var _current_y = 0;

			    var _segment_count = array_length(_line_segments);
			    var _segment_index = 0;
			    repeat (_segment_count) {

			        var _seg = _line_segments[_segment_index];

			        var _seg_start = _seg.start_index;
			        var _seg_end = _seg.end_index;

			        var _cursor_x = 0;
			        var _max_height = 0;

			        var _emit_index = _seg_start;
			        while (_emit_index < _seg_end) {

			            // Advance metric run if needed
			            while (_metric_remaining <= 0 && _metric_run_index < _metric_run_count - 1) {

			                _metric_run_index += 1;

			                var _metric_run3 = _metric_runs[_metric_run_index];

			                _metric_remaining = _metric_run3.index_count;

			                _metric_font_override = is_undefined(_metric_run3.font_asset_or_minus1) ? -1 : _metric_run3.font_asset_or_minus1;
			                _metric_style_value = is_undefined(_metric_run3.style_value) ? __WW_Text_Glyph_Style.Regular : _metric_run3.style_value;
			                _metric_size_mul = is_undefined(_metric_run3.size_mul) ? 1 : _metric_run3.size_mul;

			                if (_metric_size_mul <= 0) { _metric_size_mul = 1; }
			            }

			            // Advance visual run if needed
			            while (_visual_remaining <= 0 && _visual_run_index < _visual_run_count - 1) {

			                _visual_run_index += 1;

			                var _run = _visual_runs[_visual_run_index];

			                _visual_remaining = _run.index_count;

							_visual_color = is_undefined(_run.color) ? color : _run.color;
							_visual_alpha = is_undefined(_run.alpha) ? alpha : _run.alpha;
							_visual_underline = is_undefined(_run.underline) ? __WW_Text_Glyph_Underline.None : _run.underline;

							_visual_back_color = _run[$ "back_color"];
						_visual_back_alpha = _run[$ "back_alpha"];
						_visual_strike = _run[$ "strike"] ?? __WW_Text_Glyph_Strike.None;
			            }

			            // Select font + refresh caches when it changes
			            var _want_font_emit = font;

			            if (_metric_font_override != -1 && font_exists(_metric_font_override)) {
			                _want_font_emit = _metric_font_override;
			            }

			            if (_active_font != _want_font_emit && font_exists(_want_font_emit)) {

			                draw_set_font(_want_font_emit);
			                _active_font = _want_font_emit;

			                _active_space_width = string_width(" ");
			                _active_tab_width = _active_space_width * tab_size_spaces;
							__space_width__ = _active_space_width;
							__tab_width__ = _active_tab_width;

			                _active_font_height = string_height("A");
			                if (_active_font_height <= 0) { _active_font_height = 1; }
			            }

			            var _char_emit = string_char_at(_str, _emit_index + 1);

			            // Newline placeholders: emit glyph slot, but line height must advance
			            if (_char_emit == "\n" || _char_emit == "\r") {

			                var _fallback_scaled = _active_font_height * _metric_size_mul;
			                if (_fallback_scaled > _max_height) { _max_height = _fallback_scaled; }

			                _layout.add_glyph(
			                    _char_emit,
			                    _emit_index,
			                    _emit_index,
			                    1,
			                    _cursor_x,
			                    _current_y,
			                    0,
			                    0,
			                    _visual_color,
			                    _visual_alpha,
			                    _metric_font_override,
			                    _metric_style_value,
			                    _metric_size_mul,
			                    _visual_underline
			                );

			                _metric_remaining -= 1;
			                _visual_remaining -= 1;

			                _emit_index += 1;
			                continue;
			            }

			            // Width
			            var _base_wid = 0;

			            if (_char_emit == "\t") {
			                if (_metric_size_mul == 1) {
			                    if (tab_use_stops) {
			                        _base_wid = __tab_advance__(_cursor_x);
			                    }
								else {
			                        _base_wid = _active_tab_width;
			                    }

			                }
							else {
			                    _base_wid = _active_tab_width;
			                }
			            }
						else {
			                _base_wid = string_width(_char_emit);
			            }

			            var _base_hei = _active_font_height;

			            var _scaled_hei = _base_hei * _metric_size_mul;
			            if (_scaled_hei > _max_height) { _max_height = _scaled_hei; }

			            _layout.add_glyph(
			                _char_emit,
			                _emit_index,
			                _emit_index,
			                1,
			                _cursor_x,
			                _current_y,
			                _base_wid,
			                _base_hei,
			                _visual_color,
			                _visual_alpha,
			                _metric_font_override,
			                _metric_style_value,
			                _metric_size_mul,
			                _visual_underline
			            );

			            _cursor_x += (_base_wid * _metric_size_mul);

			            _metric_remaining -= 1;
			            _visual_remaining -= 1;

			            _emit_index += 1;
			        }

			        // Line text for storage: exclude trailing newline if present
			        var _text_end = _seg_end;

			        if (_text_end > _seg_start) {
			            var _tail_char = string_char_at(_str, _text_end);
			            if (_tail_char == "\n" || _tail_char == "\r") {
			                _text_end -= 1;
			            }
			        }

			        var _line_text = "";
			        if (_text_end > _seg_start) {
			            _line_text = string_copy(_str, _seg_start + 1, _text_end - _seg_start);
			        }

			        var _extra_sep = (line_sep > 0) ? line_sep : 0;
			        var _line_height_val = _max_height + _extra_sep;

			        _layout.add_line(
			            _line_text,
			            _seg_start,
			            _seg_end,
			            _cursor_x,
			            _line_height_val,
			            _current_y,
			            _seg.force_wrapped
			        );

			        _current_y += _line_height_val;

			        _segment_index += 1;
			    }

			    if (!is_undefined(__textbox_parent__)) {
			        _layout.apply_line_alignment(__textbox_parent__.width);
			    }

			    if (font_exists(_old_font) && _old_font != draw_get_font()) {
			        draw_set_font(_old_font);
			    }

			    return _layout;
			};
			
        #endregion

        #region Font render data

            static __font_get_render_data__ = function(_font_asset) {

                if (is_undefined(__font_info_cache__[$ _font_asset])) {

                    var _info = font_get_info(_font_asset);

                    if (is_undefined(_info)) {
                        __font_info_cache__[$ _font_asset] = undefined;
                        return undefined;
                    }

                    var _tex = font_get_texture(_font_asset);
                    var _uvs = font_get_uvs(_font_asset);

                    var _sdf_enabled = _info.sdfEnabled;
                    var _sdf_spread = 0;
                    var _sdf_shader = undefined;
                    
					if (_sdf_enabled) {
                        _sdf_spread = _info.sdfSpread;
                        _sdf_shader = (asset_has_any_tag(_font_asset, "msdf")) ? shd_ww_msdf : shd_ww_sdf;
                    }

                    __font_info_cache__[$ _font_asset] = _info;
                    __font_sdf_enabled_cache__[$ _font_asset] = _sdf_enabled;
                    __font_sdf_spread_cache__[$ _font_asset] = _sdf_spread;
                    __font_sdf_shader_cache__[$ _font_asset] = _sdf_shader;
                    __font_uv_cache__[$ _font_asset] = _uvs;
                    __font_tex_cache__[$ _font_asset] = _tex;
                    __font_texw_cache__[$ _font_asset] = texture_get_width(_tex);
                    __font_texh_cache__[$ _font_asset] = texture_get_height(_tex);
                }
				
                return {
                    info: __font_info_cache__[$ _font_asset],
                    tex: __font_tex_cache__[$ _font_asset],
                    uvs: __font_uv_cache__[$ _font_asset],
                    tex_w: __font_texw_cache__[$ _font_asset],
                    tex_h: __font_texh_cache__[$ _font_asset],

                    sdf_enabled: __font_sdf_enabled_cache__[$ _font_asset],
                    sdf_spread: __font_sdf_spread_cache__[$ _font_asset],
                    sdf_shader: __font_sdf_shader_cache__[$ _font_asset]
                };
            };

            static __glyph_resolve_font_data__ = function(_font_override_or_minus1, _char) {

                if (!is_undefined(_font_override_or_minus1) && _font_override_or_minus1 != -1 && font_exists(_font_override_or_minus1)) {

                    var _data1 = __font_get_render_data__(_font_override_or_minus1);

                    if (!is_undefined(_data1) && !is_undefined(_data1.info.glyphs[$ _char])) {
                        return _data1;
                    }
                }

                if (font_exists(font)) {

                    var _data2 = __font_get_render_data__(font);

                    if (!is_undefined(_data2) && !is_undefined(_data2.info.glyphs[$ _char])) {
                        return _data2;
                    }
                }

                var _fallbacks = font_fallbacks;

                if (is_array(_fallbacks)) {

                    var _count = array_length(_fallbacks);
                    var _index = 0;

                    repeat (_count) {
                        var _fb = _fallbacks[_index];

                        if (!is_undefined(_fb) && font_exists(_fb)) {

                            var _data3 = __font_get_render_data__(_fb);

                            if (!is_undefined(_data3) && !is_undefined(_data3.info.glyphs[$ _char])) {
                                return _data3;
                            }
                        }

                        _index++;
                    }
                }

                return undefined;
            };

        #endregion

        #region VB glyph emitter (basic)

            static __vb_emit_glyph_basic_to_buffer__ = function(_vb_buffer, _font_data, _char, _pos_x, _pos_y, _col, _alp) {

			    if (_char == "" || is_undefined(_font_data)) {
			        return false;
			    }

			    var _glyph_info = _font_data.info.glyphs[$ _char];
			    if (is_undefined(_glyph_info)) {
			        return false;
			    }

			    var _gx = _glyph_info.x;
			    var _gy = _glyph_info.y;
			    var _gw = _glyph_info.w;
			    var _gh = _glyph_info.h;

			    if (_gx < 0 || _gy < 0 || _gw <= 0 || _gh <= 0) {
			        return false;
			    }

			    var _uv_w = texture_get_texel_width(_font_data.tex);
			    var _uv_h = texture_get_texel_height(_font_data.tex);

			    var _u0 = _gx * _uv_w;
			    var _v0 = _gy * _uv_h;
			    var _u1 = (_gx + _gw) * _uv_w;
			    var _v1 = (_gy + _gh) * _uv_h;

			    var _padding = 0;
			    if (!is_undefined(_font_data.info) && _font_data.info.sdfEnabled) {
			        _padding = _font_data.info.sdfSpread;
			    }

			    var _xoff = _glyph_info.offset - _padding;
			    var _yoff = _glyph_info.yoffset - _padding;

			    var _x0 = _pos_x + _xoff;
			    var _y0 = _pos_y + _yoff;
			    var _x1 = _x0 + _gw;
			    var _y1 = _y0 + _gh;

			    vertex_position(_vb_buffer, _x0, _y0);
			    vertex_texcoord(_vb_buffer, _u0, _v0);
			    vertex_colour(_vb_buffer, _col, _alp);

			    vertex_position(_vb_buffer, _x1, _y0);
			    vertex_texcoord(_vb_buffer, _u1, _v0);
			    vertex_colour(_vb_buffer, _col, _alp);

			    vertex_position(_vb_buffer, _x1, _y1);
			    vertex_texcoord(_vb_buffer, _u1, _v1);
			    vertex_colour(_vb_buffer, _col, _alp);

			    vertex_position(_vb_buffer, _x0, _y0);
			    vertex_texcoord(_vb_buffer, _u0, _v0);
			    vertex_colour(_vb_buffer, _col, _alp);

			    vertex_position(_vb_buffer, _x1, _y1);
			    vertex_texcoord(_vb_buffer, _u1, _v1);
			    vertex_colour(_vb_buffer, _col, _alp);

			    vertex_position(_vb_buffer, _x0, _y1);
			    vertex_texcoord(_vb_buffer, _u0, _v1);
			    vertex_colour(_vb_buffer, _col, _alp);

			    return true;
			};


        #endregion

        
        #region VB emit styled glyph

            static __vb_emit_glyph_styled_to_buffer__ = function(_vb_buffer, _font_data, _char, _pos_x, _pos_y, _col, _alp, _size_mul, _style) {

			    if (_char == "" || is_undefined(_font_data)) {
			        return false;
			    }

			    if (_size_mul <= 0) {
			        return false;
			    }

			    var _glyph_info = _font_data.info.glyphs[$ _char];
			    if (is_undefined(_glyph_info)) {
			        return false;
			    }

			    var _gx = _glyph_info.x;
			    var _gy = _glyph_info.y;
			    var _gw = _glyph_info.w;
			    var _gh = _glyph_info.h;

			    if (_gx < 0 || _gy < 0 || _gw <= 0 || _gh <= 0) {
			        return false;
			    }

			    var _uv_w = texture_get_texel_width(_font_data.tex);
			    var _uv_h = texture_get_texel_height(_font_data.tex);

			    var _u0 = _gx * _uv_w;
			    var _v0 = _gy * _uv_h;
			    var _u1 = (_gx + _gw) * _uv_w;
			    var _v1 = (_gy + _gh) * _uv_h;

			    var _padding = 0;
			    if (!is_undefined(_font_data.info) && _font_data.info.sdfEnabled) {
			        _padding = _font_data.info.sdfSpread * _size_mul;
			    }

			    var _xoff = (_glyph_info.offset * _size_mul) - _padding;
			    var _yoff = (_glyph_info.yoffset * _size_mul) - _padding;

			    var _w = _gw * _size_mul;
			    var _h = _gh * _size_mul;

			    var _x0 = floor(_pos_x + _xoff);
			    var _y0 = floor(_pos_y + _yoff);
			    var _x1 = floor(_x0 + _w);
			    var _y1 = floor(_y0 + _h);

			    var _italic = ((_style == __WW_Text_Glyph_Style.Italic) || (_style == __WW_Text_Glyph_Style.Bold_Italic));

			    var _slant_top = 0;
			    var _slant_bottom = 0;

			    if (_italic) {
			        _slant_top = 2 * _size_mul;
			        _slant_bottom = -1 * _size_mul;
			    }

			    vertex_position(_vb_buffer, floor(_x0 + _slant_top), _y0);
			    vertex_texcoord(_vb_buffer, _u0, _v0);
			    vertex_colour(_vb_buffer, _col, _alp);

			    vertex_position(_vb_buffer, floor(_x1 + _slant_top), _y0);
			    vertex_texcoord(_vb_buffer, _u1, _v0);
			    vertex_colour(_vb_buffer, _col, _alp);

			    vertex_position(_vb_buffer, floor(_x1 + _slant_bottom), _y1);
			    vertex_texcoord(_vb_buffer, _u1, _v1);
			    vertex_colour(_vb_buffer, _col, _alp);

			    vertex_position(_vb_buffer, floor(_x0 + _slant_top), _y0);
			    vertex_texcoord(_vb_buffer, _u0, _v0);
			    vertex_colour(_vb_buffer, _col, _alp);

			    vertex_position(_vb_buffer, floor(_x1 + _slant_bottom), _y1);
			    vertex_texcoord(_vb_buffer, _u1, _v1);
			    vertex_colour(_vb_buffer, _col, _alp);

			    vertex_position(_vb_buffer, floor(_x0 + _slant_bottom), _y1);
			    vertex_texcoord(_vb_buffer, _u0, _v1);
			    vertex_colour(_vb_buffer, _col, _alp);

			    return true;
			};

        #endregion

        #region Underline flush span

            static __ul_flush_span__ = function(_span_state) {

                if (!_span_state.active) {
                    return;
                }

                if (!underline_enabled) {
                    _span_state.active = false;
                    return;
                }

                if (_span_state.under == __WW_Text_Glyph_Underline.None) {
                    _span_state.active = false;
                    return;
                }

                var _width = _span_state.x1 - _span_state.x0;
                if (_width <= 0) {
                    _span_state.active = false;
                    return;
                }

                var _spr = underline_sprite_white;

                if (_span_state.under == __WW_Text_Glyph_Underline.Warning) {
                    _spr = underline_sprite_warning;
                } else if (_span_state.under == __WW_Text_Glyph_Underline.Error) {
                    _spr = underline_sprite_error;
                } else if (_span_state.under == 4) {
                    _spr = underline_sprite_white;
                }

                if (is_undefined(_spr) || !sprite_exists(_spr)) {
                    _span_state.active = false;
                    return;
                }

                var _tex = sprite_get_texture(_spr, 0);
                var _spr_uvs = sprite_get_uvs(_spr, 0);

                var _u0 = _spr_uvs[0];
                var _v0 = _spr_uvs[1];
                var _u1 = _spr_uvs[2];
                var _v1 = _spr_uvs[3];

                var _x0 = floor(_span_state.x0);
                var _x1 = floor(_span_state.x1);
                var _y0 = floor(_span_state.y);

                // Plain underline: one stretched quad, thickness controlled by renderer
                if (_span_state.under == __WW_Text_Glyph_Underline.Line || _span_state.under == 4) {

                    var _thick = underline_thickness;
                    if (_thick < 1) { _thick = 1; }

                    var _y1 = floor(_y0 + _thick);

                    var _res_plain = __vb_get_batch_for_material__(_tex, _spr_uvs, 0, undefined, 0);
                    var _vb_plain = _res_plain.batch.buffer;

                    vertex_position(_vb_plain, _x0, _y0);
                    vertex_texcoord(_vb_plain, _u0, _v0);
                    vertex_colour(_vb_plain, _span_state.col, _span_state.alp);

                    vertex_position(_vb_plain, _x1, _y0);
                    vertex_texcoord(_vb_plain, _u1, _v0);
                    vertex_colour(_vb_plain, _span_state.col, _span_state.alp);

                    vertex_position(_vb_plain, _x1, _y1);
                    vertex_texcoord(_vb_plain, _u1, _v1);
                    vertex_colour(_vb_plain, _span_state.col, _span_state.alp);

                    vertex_position(_vb_plain, _x0, _y0);
                    vertex_texcoord(_vb_plain, _u0, _v0);
                    vertex_colour(_vb_plain, _span_state.col, _span_state.alp);

                    vertex_position(_vb_plain, _x1, _y1);
                    vertex_texcoord(_vb_plain, _u1, _v1);
                    vertex_colour(_vb_plain, _span_state.col, _span_state.alp);

                    vertex_position(_vb_plain, _x0, _y1);
                    vertex_texcoord(_vb_plain, _u0, _v1);
                    vertex_colour(_vb_plain, _span_state.col, _span_state.alp);

                    _span_state.active = false;
                    return;
                }

                // Squiggles: tiled sprite
                var _spr_w = sprite_get_width(_spr);
                if (_spr_w <= 0) { _spr_w = 1; }

                var _spr_h = sprite_get_height(_spr);
                if (_spr_h <= 0) { _spr_h = 1; }

                var _res = __vb_get_batch_for_material__(_tex, _spr_uvs, 0, undefined, 0);
                var _vb_ul = _res.batch.buffer;

                var _y1s = floor(_y0 + _spr_h);

                var _full_count = floor(_width / _spr_w);
                var _rem_width = _width - (_full_count * _spr_w);

                var _du = _u1 - _u0;

                var _tile_index = 0;
                repeat (_full_count) {

                    var _sx0 = floor(_x0 + (_tile_index * _spr_w));
                    var _sx1 = floor(_sx0 + _spr_w);

                    vertex_position(_vb_ul, _sx0, _y0);
                    vertex_texcoord(_vb_ul, _u0, _v0);
                    vertex_colour(_vb_ul, _span_state.col, _span_state.alp);

                    vertex_position(_vb_ul, _sx1, _y0);
                    vertex_texcoord(_vb_ul, _u1, _v0);
                    vertex_colour(_vb_ul, _span_state.col, _span_state.alp);

                    vertex_position(_vb_ul, _sx1, _y1s);
                    vertex_texcoord(_vb_ul, _u1, _v1);
                    vertex_colour(_vb_ul, _span_state.col, _span_state.alp);

                    vertex_position(_vb_ul, _sx0, _y0);
                    vertex_texcoord(_vb_ul, _u0, _v0);
                    vertex_colour(_vb_ul, _span_state.col, _span_state.alp);

                    vertex_position(_vb_ul, _sx1, _y1s);
                    vertex_texcoord(_vb_ul, _u1, _v1);
                    vertex_colour(_vb_ul, _span_state.col, _span_state.alp);

                    vertex_position(_vb_ul, _sx0, _y1s);
                    vertex_texcoord(_vb_ul, _u0, _v1);
                    vertex_colour(_vb_ul, _span_state.col, _span_state.alp);

                    _tile_index += 1;
                }

                if (_rem_width > 0) {

                    var _sx0r = floor(_x0 + (_full_count * _spr_w));
                    var _sx1r = floor(_sx0r + _rem_width);

                    var _ratio = _rem_width / _spr_w;
                    if (_ratio < 0) { _ratio = 0; }
                    if (_ratio > 1) { _ratio = 1; }

                    var _ur1 = _u0 + (_du * _ratio);

                    vertex_position(_vb_ul, _sx0r, _y0);
                    vertex_texcoord(_vb_ul, _u0, _v0);
                    vertex_colour(_vb_ul, _span_state.col, _span_state.alp);

                    vertex_position(_vb_ul, _sx1r, _y0);
                    vertex_texcoord(_vb_ul, _ur1, _v0);
                    vertex_colour(_vb_ul, _span_state.col, _span_state.alp);

                    vertex_position(_vb_ul, _sx1r, _y1s);
                    vertex_texcoord(_vb_ul, _ur1, _v1);
                    vertex_colour(_vb_ul, _span_state.col, _span_state.alp);

                    vertex_position(_vb_ul, _sx0r, _y0);
                    vertex_texcoord(_vb_ul, _u0, _v0);
                    vertex_colour(_vb_ul, _span_state.col, _span_state.alp);

                    vertex_position(_vb_ul, _sx1r, _y1s);
                    vertex_texcoord(_vb_ul, _ur1, _v1);
                    vertex_colour(_vb_ul, _span_state.col, _span_state.alp);

                    vertex_position(_vb_ul, _sx0r, _y1s);
                    vertex_texcoord(_vb_ul, _u0, _v1);
                    vertex_colour(_vb_ul, _span_state.col, _span_state.alp);
                }

                _span_state.active = false;
            };



        #region Background flush span

            static __bg_flush_span__ = function(_span_state) {

                if (!_span_state.active) {
                    return;
                }

                if (_span_state.wid <= 0 || _span_state.hei <= 0) {
                    _span_state.active = false;
                    return;
                }

                if (is_undefined(background_sprite) || !sprite_exists(background_sprite)) {
                    _span_state.active = false;
                    return;
                }

                var _tex = sprite_get_texture(background_sprite, 0);
                var _spr_uvs = sprite_get_uvs(background_sprite, 0);

                var _u0 = _spr_uvs[0];
                var _v0 = _spr_uvs[1];
                var _u1 = _spr_uvs[2];
                var _v1 = _spr_uvs[3];

                var _x0 = floor(_span_state.x0);
                var _x1 = floor(_span_state.x1);
                var _y0 = floor(_span_state.y0);
                var _y1 = floor(_span_state.y1);

                var _res = __vb_get_batch_for_material__(_tex, _spr_uvs, 0, undefined, 0);
                var _vb_bg = _res.batch.buffer;

                vertex_position(_vb_bg, _x0, _y0);
                vertex_texcoord(_vb_bg, _u0, _v0);
                vertex_colour(_vb_bg, _span_state.col, _span_state.alp);

                vertex_position(_vb_bg, _x1, _y0);
                vertex_texcoord(_vb_bg, _u1, _v0);
                vertex_colour(_vb_bg, _span_state.col, _span_state.alp);

                vertex_position(_vb_bg, _x1, _y1);
                vertex_texcoord(_vb_bg, _u1, _v1);
                vertex_colour(_vb_bg, _span_state.col, _span_state.alp);

                vertex_position(_vb_bg, _x0, _y0);
                vertex_texcoord(_vb_bg, _u0, _v0);
                vertex_colour(_vb_bg, _span_state.col, _span_state.alp);

                vertex_position(_vb_bg, _x1, _y1);
                vertex_texcoord(_vb_bg, _u1, _v1);
                vertex_colour(_vb_bg, _span_state.col, _span_state.alp);

                vertex_position(_vb_bg, _x0, _y1);
                vertex_texcoord(_vb_bg, _u0, _v1);
                vertex_colour(_vb_bg, _span_state.col, _span_state.alp);

                _span_state.active = false;
            };

        #endregion

        #region Strike-through flush span

            static __st_flush_span__ = function(_span_state) {

                if (!_span_state.active) {
                    return;
                }

                if (!strike_enabled) {
                    _span_state.active = false;
                    return;
                }

                if (_span_state.kind == __WW_Text_Glyph_Strike.None) {
                    _span_state.active = false;
                    return;
                }

                var _width = _span_state.x1 - _span_state.x0;
                if (_width <= 0) {
                    _span_state.active = false;
                    return;
                }

                var _spr = strike_sprite_white;

                if (_span_state.kind == __WW_Text_Glyph_Strike.Warning) {
                    _spr = strike_sprite_warning;
                } else if (_span_state.kind == __WW_Text_Glyph_Strike.Error) {
                    _spr = strike_sprite_error;
                } else if (_span_state.kind == __WW_Text_Glyph_Strike.Squiggle) {
                    _spr = strike_sprite_warning;
                }

                if (is_undefined(_spr) || !sprite_exists(_spr)) {
                    _span_state.active = false;
                    return;
                }

                var _tex = sprite_get_texture(_spr, 0);
                var _spr_uvs = sprite_get_uvs(_spr, 0);

                var _u0 = _spr_uvs[0];
                var _v0 = _spr_uvs[1];
                var _u1 = _spr_uvs[2];
                var _v1 = _spr_uvs[3];

                var _x0 = floor(_span_state.x0);
                var _x1 = floor(_span_state.x1);
                var _y0 = floor(_span_state.y);

                // Plain strike: one stretched quad
                if (_span_state.kind == __WW_Text_Glyph_Strike.Line) {

                    var _thick = strike_thickness;
                    if (_thick < 1) { _thick = 1; }

                    var _y1 = floor(_y0 + _thick);

                    var _res_plain = __vb_get_batch_for_material__(_tex, _spr_uvs, 2, undefined, 0);
                    var _vb_plain = _res_plain.batch.buffer;

                    vertex_position(_vb_plain, _x0, _y0);
                    vertex_texcoord(_vb_plain, _u0, _v0);
                    vertex_colour(_vb_plain, _span_state.col, _span_state.alp);

                    vertex_position(_vb_plain, _x1, _y0);
                    vertex_texcoord(_vb_plain, _u1, _v0);
                    vertex_colour(_vb_plain, _span_state.col, _span_state.alp);

                    vertex_position(_vb_plain, _x1, _y1);
                    vertex_texcoord(_vb_plain, _u1, _v1);
                    vertex_colour(_vb_plain, _span_state.col, _span_state.alp);

                    vertex_position(_vb_plain, _x0, _y0);
                    vertex_texcoord(_vb_plain, _u0, _v0);
                    vertex_colour(_vb_plain, _span_state.col, _span_state.alp);

                    vertex_position(_vb_plain, _x1, _y1);
                    vertex_texcoord(_vb_plain, _u1, _v1);
                    vertex_colour(_vb_plain, _span_state.col, _span_state.alp);

                    vertex_position(_vb_plain, _x0, _y1);
                    vertex_texcoord(_vb_plain, _u0, _v1);
                    vertex_colour(_vb_plain, _span_state.col, _span_state.alp);

                    _span_state.active = false;
                    return;
                }

                // Squiggles: tiled sprite
                var _spr_w = sprite_get_width(_spr);
                if (_spr_w <= 0) { _spr_w = 1; }

                var _spr_h = sprite_get_height(_spr);
                if (_spr_h <= 0) { _spr_h = 1; }

                var _res = __vb_get_batch_for_material__(_tex, _spr_uvs, 2, undefined, 0);
                var _vb_st = _res.batch.buffer;

                var _y1s = floor(_y0 + _spr_h);

                var _full_count = floor(_width / _spr_w);
                var _rem_width = _width - (_full_count * _spr_w);

                var _du = _u1 - _u0;

                var _tile_index = 0;
                repeat (_full_count) {

                    var _sx0 = floor(_x0 + (_tile_index * _spr_w));
                    var _sx1 = floor(_sx0 + _spr_w);

                    vertex_position(_vb_st, _sx0, _y0);
                    vertex_texcoord(_vb_st, _u0, _v0);
                    vertex_colour(_vb_st, _span_state.col, _span_state.alp);

                    vertex_position(_vb_st, _sx1, _y0);
                    vertex_texcoord(_vb_st, _u1, _v0);
                    vertex_colour(_vb_st, _span_state.col, _span_state.alp);

                    vertex_position(_vb_st, _sx1, _y1s);
                    vertex_texcoord(_vb_st, _u1, _v1);
                    vertex_colour(_vb_st, _span_state.col, _span_state.alp);

                    vertex_position(_vb_st, _sx0, _y0);
                    vertex_texcoord(_vb_st, _u0, _v0);
                    vertex_colour(_vb_st, _span_state.col, _span_state.alp);

                    vertex_position(_vb_st, _sx1, _y1s);
                    vertex_texcoord(_vb_st, _u1, _v1);
                    vertex_colour(_vb_st, _span_state.col, _span_state.alp);

                    vertex_position(_vb_st, _sx0, _y1s);
                    vertex_texcoord(_vb_st, _u0, _v1);
                    vertex_colour(_vb_st, _span_state.col, _span_state.alp);

                    _tile_index += 1;
                }

                if (_rem_width > 0) {

                    var _sx0r = floor(_x0 + (_tile_index * _spr_w));
                    var _sx1r = floor(_sx0r + _rem_width);

                    var _ur1 = _u0 + (_du * (_rem_width / _spr_w));

                    vertex_position(_vb_st, _sx0r, _y0);
                    vertex_texcoord(_vb_st, _u0, _v0);
                    vertex_colour(_vb_st, _span_state.col, _span_state.alp);

                    vertex_position(_vb_st, _sx1r, _y0);
                    vertex_texcoord(_vb_st, _ur1, _v0);
                    vertex_colour(_vb_st, _span_state.col, _span_state.alp);

                    vertex_position(_vb_st, _sx1r, _y1s);
                    vertex_texcoord(_vb_st, _ur1, _v1);
                    vertex_colour(_vb_st, _span_state.col, _span_state.alp);

                    vertex_position(_vb_st, _sx0r, _y0);
                    vertex_texcoord(_vb_st, _u0, _v0);
                    vertex_colour(_vb_st, _span_state.col, _span_state.alp);

                    vertex_position(_vb_st, _sx1r, _y1s);
                    vertex_texcoord(_vb_st, _ur1, _v1);
                    vertex_colour(_vb_st, _span_state.col, _span_state.alp);

                    vertex_position(_vb_st, _sx0r, _y1s);
                    vertex_texcoord(_vb_st, _u0, _v1);
                    vertex_colour(_vb_st, _span_state.col, _span_state.alp);
                }

                _span_state.active = false;
            };

        #endregion

        #endregion

        #region VB build and draw (unified)

            static __ensure_vb__ = function() {

                if (!__vb_is_dirty__) {
                    return;
                }

                __ensure_layout__();
                __vb_ensure_format__();

                __vb_free__();
                __build_vb__();

                __vb_is_dirty__ = false;
            };

            static __build_vb__ = function() {

                var _old_font = draw_get_font();
                if (font_exists(font)) {
                    draw_set_font(font);
                }

                var _layout_data = __layout__.get_layout_data();
                var _glyphs = _layout_data.glyphs;
                var _glyph_count = _layout_data.glyphs_count;

                if (_glyph_count <= 0) {
                    if (font_exists(_old_font) && _old_font != draw_get_font()) {
                        draw_set_font(_old_font);
                    }
                    return;
                }

                var _default_font_data = __font_get_render_data__(font);
                if (is_undefined(_default_font_data)) {
                    if (font_exists(_old_font) && _old_font != draw_get_font()) {
                        draw_set_font(_old_font);
                    }
                    return;
                }

                var _ul_span_state = {
                    active: false,
                    under: __WW_Text_Glyph_Underline.None,
                    x0: 0,
                    x1: 0,
                    y: 0,
                    col: color,
                    alp: alpha
                };

                var _bg_span_state = {
                    active: false,
                    x0: 0,
                    x1: 0,
                    y0: 0,
                    y1: 0,
                    wid: 0,
                    hei: 0,
                    col: c_white,
                    alp: 1
                };

                var _st_span_state = {
                    active: false,
                    kind: __WW_Text_Glyph_Strike.None,
                    x0: 0,
                    x1: 0,
                    y: 0,
                    col: color,
                    alp: alpha
                };

                var _glyph_index = 0;
                repeat (_glyph_count) {

                    var _base = _glyph_index * __WW_Layout_Glyph.__Size__;
                    var _char = _glyphs[_base + __WW_Layout_Glyph.Char];

                    if (_char == "\n" || _char == "\r" || _char == "\t") {
                        __bg_flush_span__(_bg_span_state);
                        __st_flush_span__(_st_span_state);
                        __ul_flush_span__(_ul_span_state);
                        _glyph_index += 1;
                        continue;
                    }

                    if (_char == "\t" && !whitespace_visible) {
                        __bg_flush_span__(_bg_span_state);
                        __st_flush_span__(_st_span_state);
                        __ul_flush_span__(_ul_span_state);
                        _glyph_index += 1;
                        continue;
                    }

                    var _pos_x = _glyphs[_base + __WW_Layout_Glyph.X];
                    var _pos_y = _glyphs[_base + __WW_Layout_Glyph.Y];
                    var _wid = _glyphs[_base + __WW_Layout_Glyph.Width];
                    var _hei = _glyphs[_base + __WW_Layout_Glyph.Height];

                    var _final_color = _glyphs[_base + __WW_Layout_Glyph.Color];
                    var _final_alpha = _glyphs[_base + __WW_Layout_Glyph.Alpha];
                    var _final_font = _glyphs[_base + __WW_Layout_Glyph.Font];
                    var _final_style = _glyphs[_base + __WW_Layout_Glyph.Style];
                    var _final_size = _glyphs[_base + __WW_Layout_Glyph.Size_Mul];
                    var _final_under = _glyphs[_base + __WW_Layout_Glyph.Underline];
                    var _final_back_col = _glyphs[_base + __WW_Layout_Glyph.Back_Color];
                    var _final_back_alp = _glyphs[_base + __WW_Layout_Glyph.Back_Alpha];
                    var _final_strike = _glyphs[_base + __WW_Layout_Glyph.Strike];

                    if (is_undefined(_final_color)) { _final_color = color; }
                    if (is_undefined(_final_alpha)) { _final_alpha = alpha; }
                    if (is_undefined(_final_style)) { _final_style = __WW_Text_Glyph_Style.Regular; }
                    if (is_undefined(_final_size) || _final_size <= 0) { _final_size = 1; }
                    if (is_undefined(_final_under)) { _final_under = __WW_Text_Glyph_Underline.None; }
                    if (is_undefined(_final_strike)) { _final_strike = __WW_Text_Glyph_Strike.None; }

                    if (is_undefined(_final_back_col)) {
                        _final_back_alp = undefined;
                    } else if (is_undefined(_final_back_alp)) {
                        _final_back_alp = 1;
                    }

                    if (!formatting_enabled) {
                        _final_style = __WW_Text_Glyph_Style.Regular;
                        _final_size = 1;
                    }

                    if (!underline_enabled) {
                        _final_under = __WW_Text_Glyph_Underline.None;
                    }

                    if (!strike_enabled) {
                        _final_strike = __WW_Text_Glyph_Strike.None;
                    }

                    // Optional whitespace markers
                    if (whitespace_visible) {

                        if (_char == " ") {

                            __bg_flush_span__(_bg_span_state);
                            __st_flush_span__(_st_span_state);
                            __ul_flush_span__(_ul_span_state);

                            var _cell_w = _wid * _final_size;
                            var _mark_char = whitespace_marker_space;
                            var _mark_w = string_width(_mark_char);

                            var _mark_x = _pos_x;
                            if (_cell_w > 0 && _mark_w > 0) {
                                _mark_x = _pos_x + ((_cell_w - _mark_w) * 0.5);
                            }

                            var _ws_batch = __vb_get_batch_for_material__(_default_font_data.tex, _default_font_data.uvs, 1, _default_font_data.sdf_shader, _default_font_data.sdf_spread);

                            __vb_emit_glyph_styled_to_buffer__(
                                _ws_batch.batch.buffer,
                                _default_font_data,
                                _mark_char,
                                _mark_x,
                                _pos_y,
                                whitespace_color,
                                whitespace_alpha,
                                1,
                                __WW_Text_Glyph_Style.Regular
                            );

                            _glyph_index += 1;
                            continue;
                        }

                        if (_char == "\t") {

                            __bg_flush_span__(_bg_span_state);
                            __st_flush_span__(_st_span_state);
                            __ul_flush_span__(_ul_span_state);

                            var _mark_char2 = whitespace_marker_tab;

                            var _ws_batch2 = __vb_get_batch_for_material__(_default_font_data.tex, _default_font_data.uvs, 1, _default_font_data.sdf_shader, _default_font_data.sdf_spread);

                            __vb_emit_glyph_styled_to_buffer__(
                                _ws_batch2.batch.buffer,
                                _default_font_data,
                                _mark_char2,
                                _pos_x,
                                _pos_y,
                                whitespace_color,
                                whitespace_alpha,
                                1,
                                __WW_Text_Glyph_Style.Regular
                            );

                            _glyph_index += 1;
                            continue;
                        }
                    }

                    // Background accumulation (draw behind glyphs)
                    if (!is_undefined(_final_back_col)) {

                        var _bg_x0 = _pos_x;
                        var _bg_x1 = _pos_x + (_wid * _final_size);
                        var _bg_y0 = _pos_y;
                        var _bg_y1 = _pos_y + (_hei * _final_size);

                        if (!_bg_span_state.active) {

                            _bg_span_state.active = true;
                            _bg_span_state.x0 = _bg_x0;
                            _bg_span_state.x1 = _bg_x1;
                            _bg_span_state.y0 = _bg_y0;
                            _bg_span_state.y1 = _bg_y1;
                            _bg_span_state.wid = _bg_x1 - _bg_x0;
                            _bg_span_state.hei = _bg_y1 - _bg_y0;
                            _bg_span_state.col = _final_back_col;
                            _bg_span_state.alp = _final_back_alp;

                        } else {

                            var _same_col_bg = (_bg_span_state.col == _final_back_col);
                            var _same_alp_bg = (_bg_span_state.alp == _final_back_alp);
                            var _same_y0_bg = (_bg_span_state.y0 == _bg_y0);
                            var _same_y1_bg = (_bg_span_state.y1 == _bg_y1);

                            if (!_same_col_bg || !_same_alp_bg || !_same_y0_bg || !_same_y1_bg) {

                                __bg_flush_span__(_bg_span_state);

                                _bg_span_state.active = true;
                                _bg_span_state.x0 = _bg_x0;
                                _bg_span_state.x1 = _bg_x1;
                                _bg_span_state.y0 = _bg_y0;
                                _bg_span_state.y1 = _bg_y1;
                                _bg_span_state.wid = _bg_x1 - _bg_x0;
                                _bg_span_state.hei = _bg_y1 - _bg_y0;
                                _bg_span_state.col = _final_back_col;
                                _bg_span_state.alp = _final_back_alp;

                            } else {

                                _bg_span_state.x1 = _bg_x1;
                                _bg_span_state.wid = _bg_span_state.x1 - _bg_span_state.x0;
                            }
                        }

                    } else {

                        __bg_flush_span__(_bg_span_state);
                    }

                    var _font_data = __glyph_resolve_font_data__(_final_font, _char);
                    if (is_undefined(_font_data)) {
                        __bg_flush_span__(_bg_span_state);
                        __st_flush_span__(_st_span_state);
                        __ul_flush_span__(_ul_span_state);
                        _glyph_index += 1;
                        continue;
                    }

                    var _glyph_batch = __vb_get_batch_for_material__(_font_data.tex, _font_data.uvs, 1, _font_data.sdf_shader, _font_data.sdf_spread);

                    __vb_emit_glyph_styled_to_buffer__(
                        _glyph_batch.batch.buffer,
                        _font_data,
                        _char,
                        _pos_x,
                        _pos_y,
                        _final_color,
                        _final_alpha,
                        _final_size,
                        _final_style
                    );

                    // Optional underline accumulation
                    if (_final_under != __WW_Text_Glyph_Underline.None) {

                        var _underline_y = _pos_y + (_hei * _final_size) + underline_y_offset;

                        if (!_ul_span_state.active) {

                            _ul_span_state.active = true;
                            _ul_span_state.under = _final_under;
                            _ul_span_state.x0 = _pos_x;
                            _ul_span_state.x1 = _pos_x + (_wid * _final_size);
                            _ul_span_state.y = _underline_y;
                            _ul_span_state.col = _final_color;
                            _ul_span_state.alp = _final_alpha;

                        } else {

                            var _same_type = (_ul_span_state.under == _final_under);
                            var _same_col = (_ul_span_state.col == _final_color);
                            var _same_alp = (_ul_span_state.alp == _final_alpha);
                            var _same_y = (_ul_span_state.y == _underline_y);

                            if (!_same_type || !_same_col || !_same_alp || !_same_y) {

                                __ul_flush_span__(_ul_span_state);

                                _ul_span_state.active = true;
                                _ul_span_state.under = _final_under;
                                _ul_span_state.x0 = _pos_x;
                                _ul_span_state.x1 = _pos_x + (_wid * _final_size);
                                _ul_span_state.y = _underline_y;
                                _ul_span_state.col = _final_color;
                                _ul_span_state.alp = _final_alpha;

                            } else {

                                _ul_span_state.x1 = _pos_x + (_wid * _final_size);
                            }
                        }

                    } else {

                        __ul_flush_span__(_ul_span_state);
                    }

                    // Optional strike-through accumulation (independent from underline)
                    if (_final_strike != __WW_Text_Glyph_Strike.None) {

                        var _strike_y = _pos_y + floor((_hei * _final_size) * 0.5) + strike_y_offset;

                        if (!_st_span_state.active) {

                            _st_span_state.active = true;
                            _st_span_state.kind = _final_strike;
                            _st_span_state.x0 = _pos_x;
                            _st_span_state.x1 = _pos_x + (_wid * _final_size);
                            _st_span_state.y = _strike_y;
                            _st_span_state.col = _final_color;
                            _st_span_state.alp = _final_alpha;

                        } else {

                            var _same_kind = (_st_span_state.kind == _final_strike);
                            var _same_col_st = (_st_span_state.col == _final_color);
                            var _same_alp_st = (_st_span_state.alp == _final_alpha);
                            var _same_y_st = (_st_span_state.y == _strike_y);

                            if (!_same_kind || !_same_col_st || !_same_alp_st || !_same_y_st) {

                                __st_flush_span__(_st_span_state);

                                _st_span_state.active = true;
                                _st_span_state.kind = _final_strike;
                                _st_span_state.x0 = _pos_x;
                                _st_span_state.x1 = _pos_x + (_wid * _final_size);
                                _st_span_state.y = _strike_y;
                                _st_span_state.col = _final_color;
                                _st_span_state.alp = _final_alpha;

                            } else {

                                _st_span_state.x1 = _pos_x + (_wid * _final_size);
                            }
                        }

                    } else {

                        __st_flush_span__(_st_span_state);
                    }

                    _glyph_index += 1;
                }

                __bg_flush_span__(_bg_span_state);
                __st_flush_span__(_st_span_state);
                __ul_flush_span__(_ul_span_state);

                var _batch_count = array_length(__draw_batches__);
                var _batch_index = 0;
                repeat (_batch_count) {
                    vertex_end(__draw_batches__[_batch_index].buffer);
                    _batch_index += 1;
                }

                if (font_exists(_old_font) && _old_font != draw_get_font()) {
                    draw_set_font(_old_font);
                }
            };

            static __draw_text_vb__ = function(_origin_x, _origin_y) {

                __ensure_vb__();

                var _old_mat = matrix_get(matrix_world);
                matrix_set(matrix_world, matrix_build(_origin_x, _origin_y, 0, 0, 0, 0, 1, 1, 1));

                var _old_filt = gpu_get_tex_filter();
                gpu_set_tex_filter(true);

                var _batch_count = array_length(__draw_batches__);
                var _batch_index = 0;

                repeat (_batch_count) {

                    var _batch = __draw_batches__[_batch_index];

                    if (!is_undefined(_batch) && !is_undefined(_batch.material)) {
                        _batch.material.draw(_origin_x, _origin_y);
                    }

                    _batch_index += 1;
                }

                gpu_set_tex_filter(_old_filt);
                matrix_set(matrix_world, _old_mat);
            };

        #endregion


        #region Cleanup

            static __cleanup__ = function() {
                __vb_free__();

                if (!is_undefined(__vb_format__)) {
                    vertex_format_delete(__vb_format__);
                    __vb_format__ = undefined;
                }
            };

            static __vb_free__ = function() {
                var _batch_index = 0;
                var _batch_count = array_length(__draw_batches__);

                repeat (_batch_count) {
                    var _batch = __draw_batches__[_batch_index];

                    if (!is_undefined(_batch)) {

                        if (!is_undefined(_batch.material) && is_callable(_batch.material.destroy)) {
                            _batch.material.destroy();
                        }

                        if (!is_undefined(_batch.buffer)) {
                            vertex_delete_buffer(_batch.buffer);
                        }
                    }

                    _batch_index++;
                }

                __draw_batches__ = [];
            };

        #endregion

    #endregion
}
