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

                #region jsDoc
                /// @func   set_text_processor()
                /// @desc   Sets an optional text processor callback. The processor receives
                ///         a raw input string and may return a processed output string and
                ///         span array for layout/rendering.
                ///
                ///         Expected return values:
                ///         - { text: String, spans: Array }
                ///         - [String, Array]
                ///         - String (text only, spans will be defaulted)
                ///
                ///         Returning undefined disables processing for this build.
                /// @param  {Function} _processor_fn
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_text_processor = function(_processor_fn) {
					
	                if (is_callable(_processor_fn)) {
	                    // Bind to this renderer so processors can read renderer fields (font, color, alpha, etc.)
	                    __text_processor__ = _processor_fn;
	                }
					else {
	                    throw "text processor must be a callable function"
	                }

	                __is_dirty__ = true;
	                __vb_is_dirty__ = true;

	                return self;
	            };

                #region jsDoc
                /// @func   clear_text_processor()
                /// @desc   Clears the current text processor callback.
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static clear_text_processor = function() {
                    __text_processor__ = undefined;
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
				
				#region jsDoc
                /// @func    set_formatting_enabled()
                /// @desc    Enable or disable per-glyph formatting on advanced renders (style/size/font overrides).
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
				
				#region Whitespace visibility
					
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

		            static set_whitespace_alpha = function(_alpha_value) {
		                if (whitespace_alpha == _alpha_value) {
		                    return self;
		                }
		                whitespace_alpha = _alpha_value;
		                __mark_vb_dirty__();
		                return self;
		            };

		        #endregion
				
				#region Underline options
					
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

	            #endregion
				
				#region Strike-through options
	                
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

        #region Events

            events.change = variable_get_hash("change");
            static on_change = function(_func) {
                add_event_listener(events.change, _func);
                return self;
            };

            on_change(function(_input) {
                __mark_dirty__();
            });

            on_post_step(function(_input) {
                __ensure_layout__();
            });

            on_pre_draw(function(_input) {
                __draw_text_vb__(x, y, -1, -1);
                __draw_selection_highlight__();
            });

            on_post_draw(function(_input) {
                __draw_text_vb__(x, y, 0, undefined);
            });
			
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
            underline_y_offset = 0;
            underline_thickness = 1;
            underline_sprite_white = spr_ww_pixel;
            underline_sprite_warning = spr_ww_underline_warning;
            underline_sprite_error = spr_ww_underline_error;

            // Strike-through
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
            /// @func   get_content_width()
            /// @returns {Real}
            #endregion
            static get_content_width = function() {
                __ensure_layout__();
                return __content_width__;
            };

            #region jsDoc
            /// @func   get_content_height()
            /// @returns {Real}
            #endregion
            static get_content_height = function() {
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

                    var _lines = __layout_lines__;
                    var _glyphs = __layout_glyphs__;

                    var _line_index = get_line_from_index(_index);
                    var _line_base = _line_index * __WW_Layout_Line.__Size__;

                    var _start_index = _lines[_line_base + __WW_Layout_Line.Start_Index];
                    var _end_index = _lines[_line_base + __WW_Layout_Line.End_Index];
                    var _line_width_val = _lines[_line_base + __WW_Layout_Line.Width];

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
                    var _sum_width = 0;

                    // Glyph indices are emitted in logical order, so we can walk by index.
                    var _walk_index = _start_index;
                    repeat (_target_index - _start_index) {
                        var _glyph_base = _walk_index * __WW_Layout_Glyph.__Size__;
                        _sum_width += _glyphs[_glyph_base + __WW_Layout_Glyph.Width];
                        _walk_index += 1;
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
                    var _lines = __layout_lines__;
                    var _base = _line_index * __WW_Layout_Line.__Size__;

                    return _lines[_base + __WW_Layout_Line.Y_Offset];
                };

                #region jsDoc
                /// @func   get_index_from_xy()
                /// @param  {Real} _x
                /// @param  {Real} _y
                /// @returns {Real}
                #endregion
                static get_index_from_xy = function(_x, _y) {
                    __ensure_layout__();

                    var _lines = __layout_lines__;
                    var _glyphs = __layout_glyphs__;

                    var _target_x = _x - x;
                    var _target_y = clamp(_y - y, 0, get_height());

                    var _line_count = __layout_lines_count__;
                    if (_line_count <= 0) {
                        return 0;
                    }

                    // Find line by y
                    var _line_index = 0;
                    var _scan_index = 0;
                    repeat (_line_count) {

                        var _line_base = _scan_index * __WW_Layout_Line.__Size__;
                        var _y_offset = _lines[_line_base + __WW_Layout_Line.Y_Offset];
                        var _height_val = _lines[_line_base + __WW_Layout_Line.Height];

                        _line_index = _scan_index;

                        if (_target_y >= _y_offset && _target_y < _y_offset + _height_val) {
                            break;
                        }

                        _scan_index += 1;
                    }

                    var _line_base = _line_index * __WW_Layout_Line.__Size__;

                    var _start_index = _lines[_line_base + __WW_Layout_Line.Start_Index];
                    var _end_index = _lines[_line_base + __WW_Layout_Line.End_Index];
                    var _line_width_val = _lines[_line_base + __WW_Layout_Line.Width];

                    if (_target_x <= 0) {
                        return _start_index;
                    }

                    if (_target_x >= _line_width_val) {

                        var _is_forced_wrapped = _lines[_line_base + __WW_Layout_Line.Force_Wraped];
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

                        var _glyph_base = _walk_index * __WW_Layout_Glyph.__Size__;
                        var _glyph_width = _glyphs[_glyph_base + __WW_Layout_Glyph.Width];

                        var _mid = _sum_width + (_glyph_width * 0.5);

                        if (_target_x < _mid) {
                            _index_result = _walk_index;
                            break;
                        }

                        _sum_width += _glyph_width;
                        _index_result = _walk_index + 1;
                        _walk_index += 1;
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

                    var _lines = __layout_lines__;
                    var _line_count = __layout_lines_count__;

                    if (_line_count <= 0) {
                        return 0;
                    }

                    var _result_line = 0;
                    var _line_index = 0;
                    repeat (_line_count) {

                        var _base = _line_index * __WW_Layout_Line.__Size__;
                        var _start_index = _lines[_base + __WW_Layout_Line.Start_Index];
                        var _end_index = _lines[_base + __WW_Layout_Line.End_Index];

                        if (_index >= _start_index && _index < _end_index) {
                            return _line_index;
                        }

                        if (_index >= _end_index) {
                            _result_line = _line_index;
                        }

                        _line_index += 1;
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

                    var _lines = __layout_lines__;
                    var _line_index = get_line_from_index(_index);

                    var _base = _line_index * __WW_Layout_Line.__Size__;
                    var _start_index = _lines[_base + __WW_Layout_Line.Start_Index];

                    var _col_index = _index - _start_index;
                    if (_col_index < 0) {
                        _col_index = 0;
                    }

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

                    var _lines = __layout_lines__;
                    var _line_count = __layout_lines_count__;

                    if (_line_count <= 0) {
                        return 0;
                    }

                    var _line_index = _line;
                    if (_line_index < 0) { _line_index = 0; }
                    if (_line_index >= _line_count) { _line_index = _line_count - 1; }

                    var _base = _line_index * __WW_Layout_Line.__Size__;
                    var _start_index = _lines[_base + __WW_Layout_Line.Start_Index];
                    var _end_index = _lines[_base + __WW_Layout_Line.End_Index];

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
                    return __layout_lines_count__;
                };

                static get_line = function(_line_index) {
                    __ensure_layout__();

                    if (_line_index < 0 || _line_index >= __layout_lines_count__) {
                        return 0;
                    }

                    var _lines = __layout_lines__;
                    var _index = _line_index * __WW_Layout_Line.__Size__;

                    return {
                        text         : _lines[_index + __WW_Layout_Line.Text],
                        start_index  : _lines[_index + __WW_Layout_Line.Start_Index],
                        end_index    : _lines[_index + __WW_Layout_Line.End_Index],
                        width        : _lines[_index + __WW_Layout_Line.Width],
                        height       : _lines[_index + __WW_Layout_Line.Height],
                        y_offset     : _lines[_index + __WW_Layout_Line.Y_Offset],
                        force_wraped : _lines[_index + __WW_Layout_Line.Force_Wraped],
                        alignment    : _lines[_index + __WW_Layout_Line.Alignment]
                    };
                };

                static get_line_text = function(_line_index) {
                    __ensure_layout__();

                    if (_line_index < 0 || _line_index >= __layout_lines_count__) {
                        return "";
                    }

                    var _index = _line_index * __WW_Layout_Line.__Size__;
                    return __layout_lines__[_index + __WW_Layout_Line.Text];
                };

                static get_line_index_start = function(_line_index) {
                    __ensure_layout__();

                    if (_line_index < 0 || _line_index >= __layout_lines_count__) {
                        return 0;
                    }

                    var _index = _line_index * __WW_Layout_Line.__Size__;
                    return __layout_lines__[_index + __WW_Layout_Line.Start_Index];
                };

                static get_line_index_end = function(_line_index) {
                    __ensure_layout__();

                    if (_line_index < 0 || _line_index >= __layout_lines_count__) {
                        return 0;
                    }

                    var _index = _line_index * __WW_Layout_Line.__Size__;
                    return __layout_lines__[_index + __WW_Layout_Line.End_Index];
                };

                static get_line_width = function(_line_index) {
                    __ensure_layout__();

                    if (_line_index < 0 || _line_index >= __layout_lines_count__) {
                        return 0;
                    }

                    var _index = _line_index * __WW_Layout_Line.__Size__;
                    return __layout_lines__[_index + __WW_Layout_Line.Width];
                };

                static get_line_height = function(_line_index) {
                    __ensure_layout__();

                    if (_line_index < 0 || _line_index >= __layout_lines_count__) {
                        return 0;
                    }

                    var _index = _line_index * __WW_Layout_Line.__Size__;
                    return __layout_lines__[_index + __WW_Layout_Line.Height];
                };

                static get_line_y_offset = function(_line_index) {
                    __ensure_layout__();

                    if (_line_index < 0 || _line_index >= __layout_lines_count__) {
                        return 0;
                    }

                    var _index = _line_index * __WW_Layout_Line.__Size__;
                    return __layout_lines__[_index + __WW_Layout_Line.Y_Offset];
                };

                static get_line_forced_wrapped = function(_line_index) {
                    __ensure_layout__();

                    if (_line_index < 0 || _line_index >= __layout_lines_count__) {
                        return false;
                    }

                    var _index = _line_index * __WW_Layout_Line.__Size__;
                    return __layout_lines__[_index + __WW_Layout_Line.Force_Wraped];
                };

            #endregion

            #region Glyph getters

                static get_glyph_count = function() {
                    __ensure_layout__();
                    return __layout_glyphs_count__;
                };

                static get_glyph = function(_glyph_index) {
                    __ensure_layout__();

                    if (_glyph_index < 0 || _glyph_index >= __layout_glyphs_count__) {
                        return undefined;
                    }

                    var _glyphs = __layout_glyphs__;
                    var _index = _glyph_index * __WW_Layout_Glyph.__Size__;

                    return {
                        text       : _glyphs[_index + __WW_Layout_Glyph.Char],
                        index      : _glyphs[_index + __WW_Layout_Glyph.Index],
                        x          : _glyphs[_index + __WW_Layout_Glyph.X],
                        y          : _glyphs[_index + __WW_Layout_Glyph.Y],
                        width      : _glyphs[_index + __WW_Layout_Glyph.Width],
                        height     : _glyphs[_index + __WW_Layout_Glyph.Height],
                        span_index : _glyphs[_index + __WW_Layout_Glyph.Span]
                    };
                };

                static get_glyph_char = function(_glyph_index) {
                    __ensure_layout__();

                    if (_glyph_index < 0 || _glyph_index >= __layout_glyphs_count__) {
                        return undefined;
                    }

                    var _index = _glyph_index * __WW_Layout_Glyph.__Size__;
                    return __layout_glyphs__[_index + __WW_Layout_Glyph.Char];
                };

                static get_glyph_index = function(_glyph_index) {
                    __ensure_layout__();

                    if (_glyph_index < 0 || _glyph_index >= __layout_glyphs_count__) {
                        return undefined;
                    }

                    var _index = _glyph_index * __WW_Layout_Glyph.__Size__;
                    return __layout_glyphs__[_index + __WW_Layout_Glyph.Index];
                };

                static get_glyph_x = function(_glyph_index) {
                    __ensure_layout__();

                    if (_glyph_index < 0 || _glyph_index >= __layout_glyphs_count__) {
                        return 0;
                    }

                    var _index = _glyph_index * __WW_Layout_Glyph.__Size__;
                    return __layout_glyphs__[_index + __WW_Layout_Glyph.X];
                };

                static get_glyph_y = function(_glyph_index) {
                    __ensure_layout__();

                    if (_glyph_index < 0 || _glyph_index >= __layout_glyphs_count__) {
                        return 0;
                    }

                    var _index = _glyph_index * __WW_Layout_Glyph.__Size__;
                    return __layout_glyphs__[_index + __WW_Layout_Glyph.Y];
                };

                static get_glyph_width = function(_glyph_index) {
                    __ensure_layout__();

                    if (_glyph_index < 0 || _glyph_index >= __layout_glyphs_count__) {
                        return undefined;
                    }

                    var _index = _glyph_index * __WW_Layout_Glyph.__Size__;
                    return __layout_glyphs__[_index + __WW_Layout_Glyph.Width];
                };

                static get_glyph_height = function(_glyph_index) {
                    __ensure_layout__();

                    if (_glyph_index < 0 || _glyph_index >= __layout_glyphs_count__) {
                        return undefined;
                    }

                    var _index = _glyph_index * __WW_Layout_Glyph.__Size__;
                    return __layout_glyphs__[_index + __WW_Layout_Glyph.Height];
                };

            #endregion
        #endregion

    #endregion
	
    #region Private

        #region Variables

            __is_dirty__ = true;
            __display_text__ = "";
            __text_processor__ = undefined;

            __content_width__ = 0;
            __content_height__ = 0;

            // VB cache
            __vb_is_dirty__ = true;
            __vb_format__ = undefined;

            // Unified draw batches
            __draw_batches__ = [];

            // Per-font info cache
            __font_cache__ = {};

            // Tab metrics cached per rebuild
            __space_width__ = 0;
            __tab_width__ = 0;
			__textbox_parent__ = undefined;

			// Layout storage (merged from WWTextLayout)
			__layout_lines__ = [];
			__layout_glyphs__ = [];
			__layout_spans__ = [];
			__layout_lines_count__ = 0;
			__layout_glyphs_count__ = 0;
			__layout_content_width__ = 0;
			__layout_content_height__ = 0;

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
			/// @param  {Real} _layer
			/// @param  {Id.Shader|Undefined} _shader
			/// @param  {Real} _spread
			/// @returns {Struct} batch
			#endregion
			static __vb_get_batch_for_material__ = function(_tex, _layer, _shader, _spread) {

			    var _batch_count = array_length(__draw_batches__);
			    var _batch_index = 0;

			    repeat (_batch_count) {
			        var _batch = __draw_batches__[_batch_index];

			        if (_batch.layer == _layer) {

			            var _material = _batch.material;

			            if (!is_undefined(_material)) {
			                if (_material.tex == _tex && _material.shader == _shader && _material.spread == _spread) {
			                    return _batch;
			                }
			            }
			        }

			        _batch_index += 1;
			    }

			    var _vertex_buffer = vertex_create_buffer();
			    var _closure = {
			        vb: _vertex_buffer,
			        tex: _tex,
			        shader: _shader,
			        spread: _spread
			    };

			    var _draw_fn = method(_closure, function(_x, _y) {
			        if (!is_undefined(shader)) {
			            shader_set(shader);
			            vertex_submit(vb, pr_trianglelist, tex);
			            shader_reset();
			        } else {
			            vertex_submit(vb, pr_trianglelist, tex);
			        }
			    });

			    var _new_material = new WWMaterial(_draw_fn);
			    _new_material.tex = _tex;
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

			    return _new_batch;
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

				var _processed_text = _text_value;
				var _processed_spans = undefined;
				var _processed_align_runs = undefined;

				if (!is_undefined(__text_processor__)) {

					var _default_state = {
					    color: color,
					    alpha: alpha,
					    font_asset: font,
					    style: __WW_Text_Glyph_Style.Regular,
					    size_mul: 1,
					    underline: __WW_Text_Glyph_Underline.None,
					    strike: __WW_Text_Glyph_Strike.None,
					    back_color: c_white,
					    back_alpha: 0,
					    align_value: __WW_Text_Alignment.Left
					};

					var _result = __text_processor__(_text_value, _default_state);

					if (is_struct(_result)) {
					    _processed_text = _result.text;
					    _processed_spans = _result.spans;
						_processed_align_runs = _result.align_runs;
					} else {
					    throw "return of text processor must be a struct";
					}
				}


                __display_text__ = _processed_text;

                var _spans_to_use = _processed_spans;

                if (!is_array(_spans_to_use)) {

                    var _processed_len = string_length(_processed_text);

                    _spans_to_use = [{
                        start_index: 0,
                        end_index: _processed_len,
                        font_asset: font,
                        color: color,
                        alpha: alpha,
                        style: __WW_Text_Glyph_Style.Regular,
                        underline: __WW_Text_Glyph_Underline.None,
                        strike: __WW_Text_Glyph_Strike.None,
                        back_color: c_white,
                        back_alpha: 0,
                        size_mul: 1
                    }];
                }

                __build_layout__(_processed_text, _spans_to_use);

				// Apply alignment after layout has finalized line breaks.
				// If the processor supplies align_runs, we can support multi-align segments
				// on the same line (left, center, right) by shifting glyph ranges directly.
				if (!is_undefined(__textbox_parent__)) {
					if (is_array(_processed_align_runs) && array_length(_processed_align_runs) > 0) {
						__layout_apply_inline_align_runs__(_processed_align_runs, __textbox_parent__.width);
					} else {
						__layout_apply_line_alignment__(__textbox_parent__.width);
					}
				}

                __content_width__ = __layout_content_width__;
                __content_height__ = __layout_content_height__;

                __is_dirty__ = false;
            };
			
			static __layout_reset__ = function(_spans) {

                __layout_lines__ = [];
                __layout_glyphs__ = [];
                __layout_spans__ = _spans;

                __layout_lines_count__ = 0;
                __layout_glyphs_count__ = 0;

                __layout_content_width__ = 0;
                __layout_content_height__ = 0;
            };

            static __layout_add_line__ = function(_text, _start_ind, _end_ind, _width, _height, _yoff, _force_wrapped, _alignment) {

                var _lines = __layout_lines__;

                array_push(
                    _lines,
                    _text,
                    _start_ind,
                    _end_ind,
                    _width,
                    _height,
                    _yoff,
                    _force_wrapped,
                    _alignment
                );

                // Update content bounds
                var _line_bottom = _yoff + _height;

                if (_width > __layout_content_width__) {
                    __layout_content_width__ = _width;
                }

                if (_line_bottom > __layout_content_height__) {
                    __layout_content_height__ = _line_bottom;
                }

                var _line_index = __layout_lines_count__;
                __layout_lines_count__ += 1;

                return _line_index;
            };

            static __layout_add_glyph__ = function(_char, _index, _x, _y, _width, _height, _span_index) {

                var _glyphs = __layout_glyphs__;

                array_push(
                    _glyphs,
                    _char,
                    _index,
                    _x,
                    _y,
                    _width,
                    _height,
                    _span_index
                );

                // Update content bounds
                var _r = _x + _width;
                var _b = _y + _height;

                if (_r > __layout_content_width__) {
                    __layout_content_width__ = _r;
                }

                if (_b > __layout_content_height__) {
                    __layout_content_height__ = _b;
                }

                var _glyph_index = __layout_glyphs_count__;
                __layout_glyphs_count__ += 1;

                return _glyph_index;
            };

            static __layout_get_line_x_offset__ = function(_line_index, _available_width) {

                if (_line_index < 0 || _line_index >= __layout_lines_count__) {
                    return 0;
                }

                var _lines = __layout_lines__;
                var _base = _line_index * __WW_Layout_Line.__Size__;

                var _alignment = _lines[_base + __WW_Layout_Line.Alignment];
                var _line_width = _lines[_base + __WW_Layout_Line.Width];

                if (_alignment == __WW_Text_Alignment.Left) {
                    return 0;
                }

                var _remaining_space = _available_width - _line_width;
                if (_remaining_space <= 0) {
                    return 0;
                }

                if (_alignment == __WW_Text_Alignment.Center) {
                    return _remaining_space * 0.5;
                }

                if (_alignment == __WW_Text_Alignment.Right) {
                    return _remaining_space;
                }

                return 0;
            };

            static __layout_apply_line_alignment__ = function(_available_width) {

                if (is_undefined(_available_width)) {
                    return;
                }

                if (_available_width <= 0) {
                    return;
                }

                var _line_count = __layout_lines_count__;
                var _glyph_count = __layout_glyphs_count__;

                if (_line_count <= 0) {
                    return;
                }

                if (_glyph_count <= 0) {
                    return;
                }

                var _lines = __layout_lines__;
                var _glyphs = __layout_glyphs__;

                var _line_index = 0;
                repeat (_line_count) {

                    var _line_base = _line_index * __WW_Layout_Line.__Size__;

                    var _line_start = _lines[_line_base + __WW_Layout_Line.Start_Index];
                    var _line_end = _lines[_line_base + __WW_Layout_Line.End_Index];
                    var _line_alignment = _lines[_line_base + __WW_Layout_Line.Alignment];

                    if (_line_alignment == __WW_Text_Alignment.Left) {
                        _line_index += 1;
                        continue;
                    }

                    var _xoff = __layout_get_line_x_offset__(_line_index, _available_width);

                    if (_xoff != 0) {

                        var _count = _line_end - _line_start;
                        var _glyph_base = _line_start * __WW_Layout_Glyph.__Size__;

                        repeat (_count) {

                            var _char_val = _glyphs[_glyph_base + __WW_Layout_Glyph.Char];

                            if (_char_val != "\n" && _char_val != "\r" && _char_val != "") {
                                _glyphs[_glyph_base + __WW_Layout_Glyph.X] += _xoff;
                            }

                            _glyph_base += __WW_Layout_Glyph.__Size__;
                        }
                    }

                    _line_index += 1;
                }
            };

            static __layout_apply_inline_align_runs__ = function(_align_runs, _available_width) {

			    if (!is_array(_align_runs)) { return; }
			    if (is_undefined(_available_width) || _available_width <= 0) { return; }

			    var _run_count = array_length(_align_runs);
			    if (_run_count <= 0) { return; }

			    var _lines = __layout_lines__;
			    var _line_count = __layout_lines_count__;
			    var _glyphs = __layout_glyphs__;
			    var _glyph_count = __layout_glyphs_count__;

			    if (!is_array(_lines) || _line_count <= 0) { return; }
			    if (!is_array(_glyphs) || _glyph_count <= 0) { return; }

			    // Reusable segment arrays (avoid garbage)
			    var _seg_start = [];
			    var _seg_endd = [];
			    var _seg_alig = [];

			    var _line_index = 0;
			    repeat (_line_count) {

			        var _line_base = _line_index * __WW_Layout_Line.__Size__;
			        var _line_start = _lines[_line_base + __WW_Layout_Line.Start_Index];
			        var _line_endd = _lines[_line_base + __WW_Layout_Line.End_Index];

			        if (_line_endd <= _line_start) {
			            _line_index += 1;
			            continue;
			        }

			        // Build segments for this line from align_runs
			        var _seg_count = 0;

			        var _run_index = 0;
			        repeat (_run_count) {

			            var _run = _align_runs[_run_index];

			            var _run_start = _run.start_index;
			            var _run_endd = _run.end_index;

			            if (_run_endd > _line_start && _run_start < _line_endd) {

			                var _take_start = _run_start;
			                var _take_endd = _run_endd;

			                if (_take_start < _line_start) { _take_start = _line_start; }
			                if (_take_endd > _line_endd) { _take_endd = _line_endd; }

			                if (_take_endd > _take_start) {

			                    _seg_start[_seg_count] = _take_start;
			                    _seg_endd[_seg_count] = _take_endd;
			                    _seg_alig[_seg_count] = _run.align_value;

			                    _seg_count += 1;
			                }
			            }

			            _run_index += 1;
			        }

			        if (_seg_count <= 0) {
			            _line_index += 1;
			            continue;
			        }

			        // Priority clamp per line (monotonic non-decreasing)
			        var _max_alig = 0;

			        var _seg_index = 0;
			        repeat (_seg_count) {

			            var _curr_alig = _seg_alig[_seg_index];

			            if (_curr_alig < _max_alig) {
			                _seg_alig[_seg_index] = _max_alig;
			            } else {
			                _max_alig = _curr_alig;
			            }

			            _seg_index += 1;
			        }

			        // Merge adjacent equal-align segments (in-place compaction)
			        var _write = 0;
			        _seg_index = 0;

			        repeat (_seg_count) {

			            var _staa = _seg_start[_seg_index];
			            var _endd = _seg_endd[_seg_index];
			            var _alig = _seg_alig[_seg_index];

			            if (_endd <= _staa) {
			                _seg_index += 1;
			                continue;
			            }

			            if (_write > 0) {

			                var _prev_index = _write - 1;

			                if (_seg_alig[_prev_index] == _alig && _seg_endd[_prev_index] == _staa) {
			                    _seg_endd[_prev_index] = _endd;
			                    _seg_index += 1;
			                    continue;
			                }
			            }

			            _seg_start[_write] = _staa;
			            _seg_endd[_write] = _endd;
			            _seg_alig[_write] = _alig;
			            _write += 1;

			            _seg_index += 1;
			        }

			        _seg_count = _write;

			        // Apply each segment independently based on its own width
			        _seg_index = 0;
			        repeat (_seg_count) {

			            var _staa2 = _seg_start[_seg_index];
			            var _endd2 = _seg_endd[_seg_index];
			            var _alig2 = _seg_alig[_seg_index];

			            // Compute segment bounds (min_x, max_x)
			            var _min_x = 999999999;
			            var _max_x = -999999999;

			            var _scan_indx = _staa2;
			            while (_scan_indx < _endd2) {

			                var _glyph_base = _scan_indx * __WW_Layout_Glyph.__Size__;
			                var _char_val = _glyphs[_glyph_base + __WW_Layout_Glyph.Char];

			                if (_char_val != "\n" && _char_val != "\r" && _char_val != "") {

			                    var _xpos = _glyphs[_glyph_base + __WW_Layout_Glyph.X];
			                    var _widt = _glyphs[_glyph_base + __WW_Layout_Glyph.Width];

			                    if (_xpos < _min_x) { _min_x = _xpos; }
			                    if ((_xpos + _widt) > _max_x) { _max_x = _xpos + _widt; }
			                }

			                _scan_indx += 1;
			            }

			            if (_max_x > _min_x) {

			                var _seg_widt = _max_x - _min_x;

			                var _targ_min = 0;

			                if (_alig2 == __WW_Text_Alignment.Left) {
			                    _targ_min = 0;
			                } else if (_alig2 == __WW_Text_Alignment.Center) {
			                    _targ_min = (_available_width - _seg_widt) * 0.5;
			                } else if (_alig2 == __WW_Text_Alignment.Right) {
			                    _targ_min = (_available_width - _seg_widt);
			                }

			                var _xoff = _targ_min - _min_x;

			                __layout_apply_xoff_range__(_glyphs, _glyph_count, _staa2, _endd2, _xoff);
			            }

			            _seg_index += 1;
			        }

			        _line_index += 1;
			    }
			};

			static __layout_apply_xoff_range__ = function(
			    _glyphs,
			    _glyph_count,
			    _start_ind,
			    _end_ind,
			    _xoff
			) {
			    if (_xoff == 0) { return; }

			    if (_start_ind < 0) { _start_ind = 0; }
			    if (_end_ind > _glyph_count) { _end_ind = _glyph_count; }

			    var _glyph_indx = _start_ind;
			    while (_glyph_indx < _end_ind) {

			        var _glyph_base = _glyph_indx * __WW_Layout_Glyph.__Size__;
			        var _char_val = _glyphs[_glyph_base + __WW_Layout_Glyph.Char];

			        if (_char_val != "\n" && _char_val != "\r" && _char_val != "") {
			            _glyphs[_glyph_base + __WW_Layout_Glyph.X] = _glyphs[_glyph_base + __WW_Layout_Glyph.X] + _xoff;
			        }

			        _glyph_indx += 1;
			    }
			};


			#region jsDoc
            /// @func   __build_layout__(_str, _spans)
            /// @param  {String} _str
            /// @param  {Array|Undefined} _spans
            #endregion
            static __build_layout__ = function(_str, _spans=undefined) {

                static __empty_arr = [];

                _spans ??= __empty_arr;

                __layout_reset__(_spans);

                if (_str == "") {

                    return;
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

                var _metric_runs = _spans;
                var _visual_runs = _spans;

                var _metric_run_count = array_length(_metric_runs);
                var _metric_run_index = 0;
                var _metric_remaining = 0;

                var _metric_font_override = -1;
                var _metric_style = __WW_Text_Glyph_Style.Regular;
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

                    _metric_remaining = (_metric_run0.end_index - _metric_run0.start_index);

                    _metric_font_override = _metric_run0.font_asset;
                    _metric_style = _metric_run0.style;
                    _metric_size_mul = _metric_run0.size_mul;

                    if (_metric_size_mul <= 0) {
                        _metric_size_mul = 1;
                    }
                }

                // Load first visual run
                if (_visual_run_count > 0) {

                    var _run = _visual_runs[0];

                    _visual_remaining = (_run.end_index - _run.start_index);

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
                if (_active_font_height <= 0) {
                    _active_font_height = 1;
                }

				// ---------------------------------
				// Pass 1: build line segments without per-char arrays
				// ---------------------------------

				var _line_segments = [];

				var _line_start_index = 0;
				var _line_width = 0;
				var _line_height = 0;

				var _last_break_pos = -1;

				// Width/height for the remainder AFTER the last break char.
				// This lets us split at the break without rescanning.
				var _width_since_break = 0;
				var _height_since_break = 0;

				var _logical_index = 0;
				while (_logical_index < _text_length) {

				    // Advance metric run if needed
				    while (_metric_remaining <= 0 && _metric_run_index < _metric_run_count - 1) {

				        _metric_run_index += 1;

				        var _metric_runn = _metric_runs[_metric_run_index];

				        _metric_remaining = (_metric_runn.end_index - _metric_runn.start_index);

				        _metric_font_override = _metric_runn.font_asset;
				        _metric_style = _metric_runn.style;
				        _metric_size_mul = _metric_runn.size_mul;

				        if (_metric_size_mul <= 0) {
				            _metric_size_mul = 1;
				        }
				    }

				    // Advance visual run if needed
				    while (_visual_remaining <= 0 && _visual_run_index < _visual_run_count - 1) {

				        _visual_run_index += 1;

				        var _run = _visual_runs[_visual_run_index];

				        _visual_remaining = (_run.end_index - _run.start_index);

				        _visual_color = is_undefined(_run.color) ? color : _run.color;
				        _visual_alpha = is_undefined(_run.alpha) ? alpha : _run.alpha;
				        _visual_underline = is_undefined(_run.underline) ? __WW_Text_Glyph_Underline.None : _run.underline;

				        _visual_back_color = _run[$ "back_color"];
				        _visual_back_alpha = _run[$ "back_alpha"];
				        _visual_strike = _run[$ "strike"] ?? __WW_Text_Glyph_Strike.None;
				    }

				    // Select measurement font (only update caches when font changes)
				    var _want_font = font;

				    if (!is_undefined(_metric_font_override) && _metric_font_override != -1) {
				        _want_font = _metric_font_override;
				    }

				    if (_want_font != _active_font && font_exists(_want_font)) {

				        draw_set_font(_want_font);
				        _active_font = _want_font;

				        _active_space_width = string_width(" ");
				        _active_tab_width = _active_space_width * tab_size_spaces;
				        _active_font_height = string_height("A");

				        if (_active_font_height <= 0) {
				            _active_font_height = 1;
				        }
				    }

				    var _char_val = string_char_at(_str, _logical_index + 1);

				    // Explicit newlines break lines, include newline glyph in segment.
				    if (_char_val == "\n" || _char_val == "\r") {

				        array_push(_line_segments, {
				            start_index: _line_start_index,
				            end_index: _logical_index + 1,
				            force_wrapped: false
				        });

				        _line_start_index = _logical_index + 1;
				        _line_width = 0;
				        _line_height = 0;

				        _last_break_pos = -1;
				        _width_since_break = 0;
				        _height_since_break = 0;

				        _metric_remaining -= 1;
				        _visual_remaining -= 1;
				        _logical_index += 1;
				        continue;
				    }

				    // Measure advance in "layout units" (scaled width)
				    var _advance = 0;

				    if (_char_val == "\t") {

				        if (tab_use_stops) {
				            var _next_stop = ceil((_line_width + 0.001) / _active_tab_width) * _active_tab_width;
				            _advance = _next_stop - _line_width;
				        } else {
				            _advance = _active_tab_width;
				        }

				    } else if (_char_val == " ") {

				        _advance = _active_space_width * _metric_size_mul;

				    } else {

				        _advance = string_width(_char_val) * _metric_size_mul;
				    }

				    var _char_height = _active_font_height * _metric_size_mul;
				    if (_char_height > _line_height) {
				        _line_height = _char_height;
				    }

				    // If we overflow and can wrap, split.
				    if (_wrap_enabled && (_line_width + _advance) > _width_limit && _line_start_index < _logical_index) {

				        if (_last_break_pos >= _line_start_index) {

				            // Split at last break (includes the break char in previous segment)
				            array_push(_line_segments, {
				                start_index: _line_start_index,
				                end_index: _last_break_pos + 1,
				                force_wrapped: true
				            });

				            // New line begins after break char.
				            _line_start_index = _last_break_pos + 1;

				            // Current char becomes the first char on the new line.
				            _line_width = _width_since_break + _advance;

				            var _new_height = _height_since_break;
				            if (_char_height > _new_height) {
				                _new_height = _char_height;
				            }
				            _line_height = _new_height;

				            // No valid break recorded within this new line yet.
				            _last_break_pos = -1;

				            // Since-break now means since the *new* last break, which doesn't exist yet,
				            // so it should equal current line width/height so far.
				            _width_since_break = _line_width;
				            _height_since_break = _line_height;

				            _metric_remaining -= 1;
				            _visual_remaining -= 1;
				            _logical_index += 1;
				            continue;

				        } else {

				            // No break opportunity - force wrap before this char (same behavior as your original fallback)
				            array_push(_line_segments, {
				                start_index: _line_start_index,
				                end_index: _logical_index,
				                force_wrapped: true
				            });

				            _line_start_index = _logical_index;
				            _line_width = 0;
				            _line_height = 0;

				            _last_break_pos = -1;
				            _width_since_break = 0;
				            _height_since_break = 0;

				            continue;
				        }
				    }

				    // Commit the char to the current line
				    _line_width += _advance;

				    // Break opportunities: record last break pos and reset remainder accumulators
				    if (_char_val == " " || _char_val == "\t") {

				        _last_break_pos = _logical_index;

				        // Remainder begins AFTER this break char
				        _width_since_break = 0;
				        _height_since_break = 0;

				    } else {

				        // Track remainder after the last break
				        _width_since_break += _advance;

				        if (_char_height > _height_since_break) {
				            _height_since_break = _char_height;
				        }
				    }

				    _metric_remaining -= 1;
				    _visual_remaining -= 1;
				    _logical_index += 1;
				}

				// Last segment
				if (_line_start_index <= _text_length) {
				    array_push(_line_segments, {
				        start_index: _line_start_index,
				        end_index: _text_length,
				        force_wrapped: false
				    });
				}


                // ---------------------------------
                // Pass 2: emit glyphs and lines
                // ---------------------------------

                var _segment_count = array_length(_line_segments);
                var _segment_index = 0;

                var _current_y = 0;
                var _emit_index = 0;

                // Reset run cursors for emit
                _metric_run_index = 0;
                _metric_remaining = 0;
                _metric_font_override = -1;
                _metric_style = __WW_Text_Glyph_Style.Regular;
                _metric_size_mul = 1;

                _visual_run_index = 0;
                _visual_remaining = 0;
                _visual_color = color;
                _visual_alpha = alpha;
                _visual_underline = __WW_Text_Glyph_Underline.None;
                _visual_back_color = undefined;
                _visual_back_alpha = undefined;
                _visual_strike = __WW_Text_Glyph_Strike.None;

                if (_metric_run_count > 0) {
                    var _mr0 = _metric_runs[0];
                    _metric_remaining = (_mr0.end_index - _mr0.start_index);
                    _metric_font_override = _mr0.font_asset;
                    _metric_style = _mr0.style;
                    _metric_size_mul = _mr0.size_mul;
                    if (_metric_size_mul <= 0) {
                        _metric_size_mul = 1;
                    }
                }

                if (_visual_run_count > 0) {
                    var _vr0 = _visual_runs[0];
                    _visual_remaining = (_vr0.end_index - _vr0.start_index);
                    _visual_color = is_undefined(_vr0.color) ? color : _vr0.color;
                    _visual_alpha = is_undefined(_vr0.alpha) ? alpha : _vr0.alpha;
                    _visual_underline = is_undefined(_vr0.underline) ? __WW_Text_Glyph_Underline.None : _vr0.underline;
                    _visual_back_color = _vr0[$ "back_color"];
                    _visual_back_alpha = _vr0[$ "back_alpha"];
                    _visual_strike = _vr0[$ "strike"] ?? __WW_Text_Glyph_Strike.None;
                }

                repeat (_segment_count) {

                    var _seg = _line_segments[_segment_index];
                    var _seg_start = _seg.start_index;
                    var _seg_end = _seg.end_index;

                    var _cursor_x = 0;
                    var _max_height = 0;

                    // Emit each logical char in this segment
                    var _emit_pos = _seg_start;
                    while (_emit_pos < _seg_end) {

                        while (_metric_remaining <= 0 && _metric_run_index < _metric_run_count - 1) {
                            _metric_run_index += 1;
                            var _mrn = _metric_runs[_metric_run_index];
                            _metric_remaining = (_mrn.end_index - _mrn.start_index);
                            _metric_font_override = _mrn.font_asset;
                            _metric_style = _mrn.style;
                            _metric_size_mul = _mrn.size_mul;
                            if (_metric_size_mul <= 0) {
                                _metric_size_mul = 1;
                            }
                        }

                        while (_visual_remaining <= 0 && _visual_run_index < _visual_run_count - 1) {
                            _visual_run_index += 1;
                            var _vrn = _visual_runs[_visual_run_index];
                            _visual_remaining = (_vrn.end_index - _vrn.start_index);
                            _visual_color = is_undefined(_vrn.color) ? color : _vrn.color;
                            _visual_alpha = is_undefined(_vrn.alpha) ? alpha : _vrn.alpha;
                            _visual_underline = is_undefined(_vrn.underline) ? __WW_Text_Glyph_Underline.None : _vrn.underline;
                            _visual_back_color = _vrn[$ "back_color"];
                            _visual_back_alpha = _vrn[$ "back_alpha"];
                            _visual_strike = _vrn[$ "strike"] ?? __WW_Text_Glyph_Strike.None;
                        }

                        var _want_font2 = font;
                        if (!is_undefined(_metric_font_override) && _metric_font_override != -1) {
                            _want_font2 = _metric_font_override;
                        }

                        if (_want_font2 != _active_font && font_exists(_want_font2)) {
                            draw_set_font(_want_font2);
                            _active_font = _want_font2;
                            _active_space_width = string_width(" ");
                            _active_tab_width = _active_space_width * tab_size_spaces;
                            _active_font_height = string_height("A");
                            if (_active_font_height <= 0) {
                                _active_font_height = 1;
                            }
                        }

                        var _char_emit = string_char_at(_str, _emit_pos + 1);

                        var _base_wid = 0;
                        if (_char_emit == "\t") {
                            if (tab_use_stops) {
                                var _next_stop2 = ceil((_cursor_x + 0.001) / _active_tab_width) * _active_tab_width;
                                _base_wid = _next_stop2 - _cursor_x;
                            } else {
                                _base_wid = _active_tab_width;
                            }
                        } else if (_char_emit == " ") {
                            _base_wid = _active_space_width;
                        } else {
                            _base_wid = string_width(_char_emit);
                        }

                        var _base_hei = _active_font_height;

                        var _scaled_hei = _base_hei * _metric_size_mul;
                        if (_scaled_hei > _max_height) {
                            _max_height = _scaled_hei;
                        }

                        var _span_index = _visual_run_index;

                        __layout_add_glyph__(
                            _char_emit,
                            _emit_index,
                            _cursor_x,
                            _current_y,
                            _base_wid,
                            _base_hei,
                            _span_index
                        );

                        _cursor_x += (_base_wid * _metric_size_mul);

                        _metric_remaining -= 1;
                        _visual_remaining -= 1;

                        _emit_index += 1;
                        _emit_pos += 1;
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

                    __layout_add_line__(
                        _line_text,
                        _seg_start,
                        _seg_end,
                        _cursor_x,
                        _line_height_val,
                        _current_y,
                        _seg.force_wrapped,
                        __WW_Text_Alignment.Left
                    );

                    _current_y += _line_height_val;

                    _segment_index += 1;
                }

                if (font_exists(_old_font) && _old_font != draw_get_font()) {
                    draw_set_font(_old_font);
                }
            };
			
        #endregion

        #region Font render data

			static __font_get_render_data__ = function(_font_asset) {

			    var _cached = __font_cache__[$ _font_asset];
			    if (!is_undefined(_cached)) {
			        return _cached;
			    }

			    // Important: we also want to cache "missing" fonts to avoid repeated work.
			    // We cannot store "undefined" in a struct slot and later distinguish "not present",
			    // so we store a sentinel struct.
			    var _sentinel = __font_cache__[$ ("__missing__" + string(_font_asset))];
			    if (!is_undefined(_sentinel)) {
			        return undefined;
			    }

			    var _info = font_get_info(_font_asset);
			    if (is_undefined(_info)) {
			        __font_cache__[$ ("__missing__" + string(_font_asset))] = { missing: true };
			        return undefined;
			    }

			    var _tex = font_get_texture(_font_asset);
			    var _uvs = font_get_uvs(_font_asset);

			    var _sdf_enabled = (_info.sdfEnabled == true);
			    var _sdf_spread = 0;
			    var _sdf_shader = undefined;

			    if (_sdf_enabled) {
			        _sdf_spread = _info.sdfSpread;
			        _sdf_shader = (asset_has_any_tag(_font_asset, "msdf")) ? shd_ww_msdf : shd_ww_sdf;
			    }

			    var _tex_width = texture_get_width(_tex);
			    var _tex_height = texture_get_height(_tex);

			    // Precompute texel size once per font texture.
			    var _texel_w = texture_get_texel_width(_tex);
			    var _texel_h = texture_get_texel_height(_tex);

			    var _render_data = {
			        info: _info,
			        glyphs: _info.glyphs,

			        tex: _tex,
			        uvs: _uvs,
			        tex_w: _tex_width,
			        tex_h: _tex_height,
			        texel_w: _texel_w,
			        texel_h: _texel_h,

			        sdf_enabled: _sdf_enabled,
			        sdf_spread: _sdf_spread,
			        sdf_shader: _sdf_shader
			    };

			    __font_cache__[$ _font_asset] = _render_data;
			    return _render_data;
			};
			
			static __glyph_resolve_font_data__ = function(_font_asset, _char, _default_font_data) {

			    // Try the requested font first
			    var _data = __font_get_render_data__(_font_asset);
			    if (!is_undefined(_data) && !is_undefined(_data.info.glyphs[$ _char])) {
			        return _data;
			    }

			    // Try renderer default font next (already fetched by caller)
			    if (!is_undefined(_default_font_data) && !is_undefined(_default_font_data.info.glyphs[$ _char])) {
			        return _default_font_data;
			    }

			    // Fallbacks
			    var _fallbacks = font_fallbacks;
			    if (is_array(_fallbacks)) {

			        var _count = array_length(_fallbacks);
			        var _index = 0;

			        repeat (_count) {

			            var _fb = _fallbacks[_index];
			            _index += 1;

			            if (font_exists(_fb)) {
			                var _fb_data = __font_get_render_data__(_fb);
			                if (!is_undefined(_fb_data) && !is_undefined(_fb_data.info.glyphs[$ _char])) {
			                    return _fb_data;
			                }
			            }
			        }
			    }

			    return undefined;
			};

        #endregion

		#region Text State Helpers

			#region jsDoc
			/// @func   __text_state_make_default__()
			/// @desc   Creates a complete default text state from the renderer's current settings.
			/// @returns {Struct}
			#endregion
			static __text_state_make_default__ = function() {
				return {
					font_asset: font,
					style: __WW_Text_Glyph_Style.Regular,
					size_mul: 1,

					color: color,
					alpha: alpha,

					underline: __WW_Text_Glyph_Underline.None,
					strike: __WW_Text_Glyph_Strike.None,

					back_color: 0,
					back_alpha: 0,

					// Layout concern - included in state so all renderers can drive it.
					align_value: 0
				};
			};

			#region jsDoc
			/// @func   __text_state_clone__()
			/// @desc   Clones a complete text state struct (all expected keys must exist).
			/// @param  {Struct} _state
			/// @returns {Struct}
			#endregion
			static __text_state_clone__ = function(_state) {
				return {
					font_asset: _state.font_asset,
					style: _state.style,
					size_mul: _state.size_mul,

					color: _state.color,
					alpha: _state.alpha,

					underline: _state.underline,
					strike: _state.strike,

					back_color: _state.back_color,
					back_alpha: _state.back_alpha,
						
					align_value: _state.align_value
				};
			};

			static __text_state_equals_span__ = function(_state_a, _state_b) {
				return (
				    _state_a.font_asset == _state_b.font_asset
				    && _state_a.style == _state_b.style
				    && _state_a.size_mul == _state_b.size_mul
				    && _state_a.color == _state_b.color
				    && _state_a.alpha == _state_b.alpha
				    && _state_a.underline == _state_b.underline
				    && _state_a.strike == _state_b.strike
				    && _state_a.back_color == _state_b.back_color
				    && _state_a.back_alpha == _state_b.back_alpha
				);
			};

			static __text_state_equals_align__ = function(_state_a, _state_b) {
				return (_state_a.align_value == _state_b.align_value);
			};
				
			#region jsDoc
			/// @func   __text_state_apply_patch__()
			/// @desc   Applies a partial patch struct to an existing complete text state.
			///         Only keys present in _patch are applied.
			/// @param  {Struct} _state
			/// @param  {Struct} _patch
			#endregion
			static __text_state_apply_patch__ = function(_state, _patch) {

				var _value = undefined;

				_value = _patch[$ "font_asset"];
				if (!is_undefined(_value)) _state.font_asset = _value;

				_value = _patch[$ "style"];
				if (!is_undefined(_value)) _state.style = _value;

				_value = _patch[$ "size_mul"];
				if (!is_undefined(_value)) _state.size_mul = _value;

				_value = _patch[$ "color"];
				if (!is_undefined(_value)) _state.color = _value;

				_value = _patch[$ "alpha"];
				if (!is_undefined(_value)) _state.alpha = _value;

				_value = _patch[$ "underline"];
				if (!is_undefined(_value)) _state.underline = _value;

				_value = _patch[$ "strike"];
				if (!is_undefined(_value)) _state.strike = _value;

				_value = _patch[$ "back_color"];
				if (!is_undefined(_value)) _state.back_color = _value;

				_value = _patch[$ "back_alpha"];
				if (!is_undefined(_value)) _state.back_alpha = _value;
					
				_value = _patch[$ "align_value"];
				if (!is_undefined(_value)) _state.align_value = _value;
			};

			#region jsDoc
			/// @func   __text_state_clone_patch__()
			/// @desc   Clones a complete text state then applies a patch.
			/// @param  {Struct} _state
			/// @param  {Struct} _patch
			/// @returns {Struct}
			#endregion
			static __text_state_clone_patch__ = function(_state, _patch) {
				var _result = __text_state_clone__(_state);
				__text_state_apply_patch__(_result, _patch);
				return _result;
			};

			#region jsDoc
			/// @func   __text_span_run_from_state__()
			/// @desc   Converts a complete text state into a layout span run.
			/// @param  {Real} _start_index
            /// @param  {Real} _end_index
			/// @param  {Struct} _state
			/// @returns {Struct}
			#endregion
			static __text_span_run_from_state__ = function(_start_index, _end_index, _state) {
				return {
					start_index: _start_index,
                end_index: _end_index,

					font_asset: _state.font_asset,
					style: _state.style,
					size_mul: _state.size_mul,

					color: _state.color,
					alpha: _state.alpha,

					underline: _state.underline,
					strike: _state.strike,

					back_color: _state.back_color,
					back_alpha: _state.back_alpha
				};
			};
				
			static __text_align_run_from_state__ = function(_start_index, _end_index, _state) {
				return {
				    start_index: _start_index,
                end_index: _end_index,
				    align_value: _state.align_value
				};
			};
				
		#endregion
        
        #region VB emit styled glyph

            static __vb_emit_glyph_styled_to_buffer__ = function(_vb_buffer, _font_data, _char, _pos_x, _pos_y, _col, _alp, _size_mul, _style) {

			    var _glyph_info = _font_data.info.glyphs[$ _char];
			    
			    var _gx = _glyph_info.x;
			    var _gy = _glyph_info.y;
			    var _gw = _glyph_info.w;
			    var _gh = _glyph_info.h;

			    var _uv_w = _font_data.texel_w;
				var _uv_h = _font_data.texel_h;

			    var _u0 = _gx * _uv_w;
			    var _v0 = _gy * _uv_h;
			    var _u1 = (_gx + _gw) * _uv_w;
			    var _v1 = (_gy + _gh) * _uv_h;

			    var _padding = 0;
			    if (_font_data.info.sdfEnabled) {
			        _padding = _font_data.info.sdfSpread * _size_mul;
			    }

			    var _xoff = (_glyph_info.offset * _size_mul) - _padding;
			    var _yoff = (_glyph_info.yoffset * _size_mul) - _padding;

			    var _w = _gw * _size_mul;
			    var _h = _gh * _size_mul;

			    var _x0 = floor(_pos_x + _xoff);
			    var _y0 = floor(_pos_y + _yoff);

				var _w_int = floor(_w);
				var _h_int = floor(_h);
				
				var _x1 = _x0 + _w_int;
				var _y1 = _y0 + _h_int;

			    var _italic = ((_style == __WW_Text_Glyph_Style.Italic) || (_style == __WW_Text_Glyph_Style.Bold_Italic));
				var _bold = ((_style == __WW_Text_Glyph_Style.Bold) || (_style == __WW_Text_Glyph_Style.Bold_Italic));

				var _slant_top = 0;
				var _slant_bottom = 0;

				if (_italic) {
				    _slant_top = floor(2 * _size_mul);
				    _slant_bottom = floor(-1 * _size_mul);
				}

				var _pass_count = 1;
				if (_bold) {
				    _pass_count = 2;
				}

				var _pass_index = 0;
				repeat (_pass_count) {

				    var _x_offset = 0;
				    if (_pass_index == 1) {
				        _x_offset = max(1, ceil(_size_mul));
				    }
					
					
					var _x0_top = _x0 + _slant_top + _x_offset;
			        var _x1_top = _x1 + _slant_top + _x_offset;
			        var _x1_bot = _x1 + _slant_bottom + _x_offset;
			        var _x0_bot = _x0 + _slant_bottom + _x_offset;
					
					vertex_position(_vb_buffer, _x0_top, _y0);
					vertex_texcoord(_vb_buffer, _u0, _v0);
					vertex_colour(_vb_buffer, _col, _alp);

					vertex_position(_vb_buffer, _x1_top, _y0);
					vertex_texcoord(_vb_buffer, _u1, _v0);
					vertex_colour(_vb_buffer, _col, _alp);

					vertex_position(_vb_buffer, _x1_bot, _y1);
					vertex_texcoord(_vb_buffer, _u1, _v1);
					vertex_colour(_vb_buffer, _col, _alp);

					vertex_position(_vb_buffer, _x0_top, _y0);
					vertex_texcoord(_vb_buffer, _u0, _v0);
					vertex_colour(_vb_buffer, _col, _alp);

					vertex_position(_vb_buffer, _x1_bot, _y1);
					vertex_texcoord(_vb_buffer, _u1, _v1);
					vertex_colour(_vb_buffer, _col, _alp);

					vertex_position(_vb_buffer, _x0_bot, _y1);
					vertex_texcoord(_vb_buffer, _u0, _v1);
					vertex_colour(_vb_buffer, _col, _alp);

				    _pass_index += 1;
				}
			};

        #endregion

        #region Underline flush span

            static __ul_flush_span__ = function(_span_state) {

                if (!_span_state.active) {
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

                    var _batch = __vb_get_batch_for_material__(_tex, 0, undefined, 0);
                    var _vb_plain = _batch.buffer;

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

                var _batch = __vb_get_batch_for_material__(_tex, -1, undefined, 0);
                var _vb_ul = _batch.buffer;

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

		#endregion

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

                var _batch = __vb_get_batch_for_material__(_tex, -1, undefined, 0);
                var _vb_bg = _batch.buffer;

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

                    var _batch = __vb_get_batch_for_material__(_tex, 2, undefined, 0);
                    var _vb_plain = _batch.buffer;

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

                var _batch = __vb_get_batch_for_material__(_tex, 2, undefined, 0);
                var _vb_st = _batch.buffer;

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

			    var _glyphs = __layout_glyphs__;
			    var _glyph_count = __layout_glyphs_count__;

			    if (_glyph_count <= 0) {
			        if (font_exists(_old_font) && _old_font != draw_get_font()) {
			            draw_set_font(_old_font);
			        }
			        return;
			    }

			    var _spans = __layout_spans__;

			    var _default_font_data = __font_get_render_data__(font);
			    if (is_undefined(_default_font_data)) {
			        if (font_exists(_old_font) && _old_font != draw_get_font()) {
			            draw_set_font(_old_font);
			        }
			        return;
			    }

			    var _use_formatting = formatting_enabled;
			    var _use_whitespace = whitespace_visible;

			    var _ws_space_marker = whitespace_marker_space;
			    var _ws_tab_marker = whitespace_marker_tab;

			    var _ws_space_width = 0;
			    if (_use_whitespace) {
			        _ws_space_width = string_width(_ws_space_marker);
			    }

			    var _ws_batch_buffer = -1;
			    if (_use_whitespace) {
			        var _ws_batch = __vb_get_batch_for_material__(
			            _default_font_data.tex,
			            1,
			            _default_font_data.sdf_shader,
			            _default_font_data.sdf_spread
			        );
			        _ws_batch_buffer = _ws_batch.buffer;
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

			    var _font_data_by_font = {};

			    var _last_tex = -1;
			    var _last_shader = undefined;
			    var _last_spread = 0;
			    var _last_batch_buffer = -1;

			    var __timer = array_create(11, 0);

			    var _emit_glyph = __vb_emit_glyph_styled_to_buffer__;

			    var _glyph_index = 0;
			    repeat (_glyph_count) {

			        var _base = _glyph_index * __WW_Layout_Glyph.__Size__;

			        var _t = get_timer();
			        var _char = _glyphs[_base + __WW_Layout_Glyph.Char];
			        if (_char == "\n" || _char == "\r") {
			            __bg_flush_span__(_bg_span_state);
			            __st_flush_span__(_st_span_state);
			            __ul_flush_span__(_ul_span_state);
			            _glyph_index += 1;
			            continue;
			        }

			        if (_char == "\t" && !_use_whitespace) {
			            __bg_flush_span__(_bg_span_state);
			            __st_flush_span__(_st_span_state);
			            __ul_flush_span__(_ul_span_state);
			            _glyph_index += 1;
			            continue;
			        }
			        __timer[0] += get_timer() - _t;

			        var _t = get_timer();
			        var _pos_x = _glyphs[_base + __WW_Layout_Glyph.X];
			        var _pos_y = _glyphs[_base + __WW_Layout_Glyph.Y];
			        var _wid = _glyphs[_base + __WW_Layout_Glyph.Width];
			        var _hei = _glyphs[_base + __WW_Layout_Glyph.Height];

						var _span_index = _glyphs[_base + __WW_Layout_Glyph.Span];
			        var _span = _spans[_span_index];

			        // Always allow per-span color/alpha (even when formatting is disabled)
			        var _final_color = _span.color;
			        var _final_alpha = _span.alpha;

			        // Default formatting values when formatting is disabled
			        var _final_font = font;
			        var _final_style = __WW_Text_Glyph_Style.Regular;
			        var _final_size = 1;

			        var _final_under = __WW_Text_Glyph_Underline.None;
			        var _final_strike = __WW_Text_Glyph_Strike.None;

			        var _final_back_col = c_white;
			        var _final_back_alp = 0;

			        if (_use_formatting) {
			            var _span_font = _span.font_asset;
			            if (!is_undefined(_span_font) && _span_font != -1) {
			                _final_font = _span_font;
			            }

			            _final_style = _span.style;
			            _final_size = _span.size_mul;
			            if (_final_size <= 0) { _final_size = 1; }

			            _final_under = _span.underline;
			            _final_strike = _span.strike;

			            _final_back_col = _span.back_color;
			            _final_back_alp = _span.back_alpha;
			        }

			        __timer[1] += get_timer() - _t;


			        var _t = get_timer();
			        if (_use_whitespace) {

			            if (_char == " ") {

			                var _cell_w = _wid * _final_size;

			                var _mark_x = _pos_x;
			                if (_cell_w > 0 && _ws_space_width > 0) {
			                    _mark_x = _pos_x + ((_cell_w - _ws_space_width) * 0.5);
			                }

			                _emit_glyph(
			                    _ws_batch_buffer,
			                    _default_font_data,
			                    _ws_space_marker,
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

			                _emit_glyph(
			                    _ws_batch_buffer,
			                    _default_font_data,
			                    _ws_tab_marker,
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
			        __timer[3] += get_timer() - _t;

			        var _t = get_timer();
			        if (_final_back_alp > 0) {

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
			        __timer[4] += get_timer() - _t;

			        var _t = get_timer();
			        var _font_cache = _font_data_by_font[$ _final_font];
			        if (is_undefined(_font_cache)) {
			            _font_cache = {};
			            _font_data_by_font[$ _final_font] = _font_cache;
			        }

			        var _font_data = _font_cache[$ _char];

			        if (is_undefined(_font_data)) {

			            _font_data = __glyph_resolve_font_data__(_final_font, _char, _default_font_data);

			            if (is_undefined(_font_data)) {
			                _font_cache[$ _char] = 0;
			                _font_data = 0;
			            } else {
			                _font_cache[$ _char] = _font_data;
			            }
			        }

			        if (_font_data == 0) {
			            __bg_flush_span__(_bg_span_state);
			            __st_flush_span__(_st_span_state);
			            __ul_flush_span__(_ul_span_state);
			            _glyph_index += 1;
			            continue;
			        }
			        __timer[5] += get_timer() - _t;

			        var _t = get_timer();
			        var _need_batch = true;

			        if (_font_data.tex == _last_tex &&
			            _font_data.sdf_shader == _last_shader &&
			            _font_data.sdf_spread == _last_spread) {
			            _need_batch = false;
			        }
			        __timer[6] += get_timer() - _t;

			        var _t = get_timer();
			        if (_need_batch) {

			            var _glyph_batch = __vb_get_batch_for_material__(
			                _font_data.tex,
			                1,
			                _font_data.sdf_shader,
			                _font_data.sdf_spread
			            );

			            _last_tex = _font_data.tex;
			            _last_shader = _font_data.sdf_shader;
			            _last_spread = _font_data.sdf_spread;
			            _last_batch_buffer = _glyph_batch.buffer;
			        }
			        __timer[7] += get_timer() - _t;

			        var _t = get_timer();
			        _emit_glyph(
			            _last_batch_buffer,
			            _font_data,
			            _char,
			            _pos_x,
			            _pos_y,
			            _final_color,
			            _final_alpha,
			            _final_size,
			            _final_style
			        );
			        __timer[8] += get_timer() - _t;

			        var _t = get_timer();
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
			        __timer[9] += get_timer() - _t;

			        var _t = get_timer();
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
			        __timer[10] += get_timer() - _t;

			        _glyph_index += 1;
			    }

			    __timer[0] /= 1000;
			    __timer[1] /= 1000;
			    __timer[2] /= 1000;
			    __timer[3] /= 1000;
			    __timer[4] /= 1000;
			    __timer[5] /= 1000;
			    __timer[6] /= 1000;
			    __timer[7] /= 1000;
			    __timer[8] /= 1000;
			    __timer[9] /= 1000;
			    __timer[10] /= 1000;

			    pprint(__timer);

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

            static __draw_selection_highlight__ = function() {

                if (is_undefined(__textbox_parent__)) {
                    return;
                }

                var _cursor = __textbox_parent__.cursor;
                if (is_undefined(_cursor)) {
                    return;
                }

                if (!_cursor.get_highlight_active()) {
                    return;
                }

                var _start_index = _cursor.get_highlight_start_index();
                var _end_index = _cursor.get_highlight_end_index();

                if (_start_index == _end_index) {
                    return;
                }

                __ensure_layout__();

                var _sel_start = min(_start_index, _end_index);
                var _sel_end = max(_start_index, _end_index);

                var _start_line = get_line_from_index(_sel_start);
                var _end_line = get_line_from_index(_sel_end);

                var _pre_color = draw_get_color();
                var _pre_alpha = draw_get_alpha();

                draw_set_color(_cursor.highlight_color);
                draw_set_alpha(1);

                var _line_index = _start_line;
                repeat ((_end_line - _start_line) + 1) {

                    var _line_y = get_line_y_offset(_line_index);
                    var _line_h = get_line_height(_line_index) - 1;
                    if (_line_h < 1) { _line_h = 1; }

                    var _line_w = get_line_width(_line_index);
                    if (_line_w < 0) { _line_w = 0; }

                    var _range_start = 0;
                    var _range_end = _line_w;

                    if (_line_index == _start_line) {
                        _range_start = get_x_from_index(_sel_start);
                    }

                    if (_line_index == _end_line) {
                        _range_end = get_x_from_index(_sel_end);
                    }

                    var _draw_w = _range_end - _range_start;
                    if (_draw_w < 0) { _draw_w = 0; }

                    if (_draw_w > 0) {
                        draw_sprite_stretched_ext(spr_ww_pixel, 0, x + _range_start, y + _line_y, _draw_w, _line_h, draw_get_color(), 1);
                    }

                    _line_index += 1;
                }

                draw_set_alpha(_pre_alpha);
                draw_set_color(_pre_color);
            };
			
            static __draw_text_vb__ = function(_origin_x, _origin_y, _layer_min, _layer_max) {

                __ensure_vb__();

                if (_layer_min == undefined) { _layer_min = -1000000; }
                if (_layer_max == undefined) { _layer_max =  1000000; }

                var _old_mat = matrix_get(matrix_world);
                matrix_set(matrix_world, matrix_build(_origin_x, _origin_y, 0, 0, 0, 0, 1, 1, 1));

                var _old_filt = gpu_get_tex_filter();
                gpu_set_tex_filter(true);

                var _batch_count = array_length(__draw_batches__);
                var _batch_index = 0;

                repeat (_batch_count) {

                    var _batch = __draw_batches__[_batch_index];

                    if (!is_undefined(_batch) && !is_undefined(_batch.material)) {

                        var _batch_layer = _batch.layer;
                        if (_batch_layer == undefined) { _batch_layer = 0; }

                        if (_batch_layer >= _layer_min && _batch_layer <= _layer_max) {
                            _batch.material.draw(_origin_x, _origin_y);
                        }
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
