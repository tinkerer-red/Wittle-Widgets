#region jsDoc
/// @func    WWTextRenderer()
/// @desc    Unified text renderer component. Responsible for:
///          - Text source (textbox buffer or caption)
///          - Layout build (lines + glyphs)
///          - Metrics + hit testing helpers
///          - Basic VB baking (glyphs only, default style)
///          Does NOT implement markup parsing or diagnostics underlines.
/// @returns {Struct.WWTextRenderer}
#endregion
function WWTextRenderer() : WWCore() constructor {
    debug_name = "WWTextRenderer";
	
    #region Public

        #region Builder Functions

            #region Text Source

                #region jsDoc
                /// @func   set_caption()
                /// @desc   Sets the caption or placeholder string. Used when there
                ///         is no text in the buffer, or when the renderer is used
                ///         for static labels.
                /// @self   WWTextRenderer
                /// @param  {String} text
                /// @returns {Struct.WWTextRenderer}
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
                ///         - { text: String, [spans]: Array, [align_runs]: Array, [widgets]: Array }
                ///         - [String, Array]
                ///         - String (text only, spans will be defaulted)
                ///
                ///         Returning undefined disables processing for this build.
                /// @self   WWTextRenderer
                /// @param  {Function} processor_fn
                /// @returns {Struct.WWTextRenderer}
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
                /// @self   WWTextRenderer
                /// @returns {Struct.WWTextRenderer}
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
                /// @self   WWTextRenderer
                /// @param  {Asset.GMFont} font_asset
                /// @returns {Struct.WWTextRenderer}
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
                /// @self   WWTextRenderer
                /// @param  {Array<Asset.GMFont>} font_array
                /// @returns {Struct.WWTextRenderer}
                #endregion
                static set_font_fallbacks = function(_font_array) {
                    font_fallbacks = _font_array;
                    __mark_dirty__();
                    return self;
                };

                #region jsDoc
                /// @func   set_text_color()
                /// @desc   Sets the color used to render text.
                /// @self   WWTextRenderer
                /// @param  {Constant.Color} color_value
                /// @returns {Struct.WWTextRenderer}
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
                /// @self   WWTextRenderer
                /// @param  {Real} alpha_value
                /// @returns {Struct.WWTextRenderer}
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
                /// @self   WWTextRenderer
                /// @param  {Bool} should_wrap
                /// @returns {Struct.WWTextRenderer}
                #endregion
                static set_wrap_enabled = function(_should_wrap) {
                    should_wrap = _should_wrap;
                    __mark_dirty__();
                    return self;
                };

                #region jsDoc
                /// @func   set_line_sep()
                /// @desc   Sets the extra spacing between wrapped lines (in pixels).
                /// @self   WWTextRenderer
                /// @param  {Real} line_sep_pixels
                /// @returns {Struct.WWTextRenderer}
                #endregion
                static set_line_sep = function(_line_sep_pixels) {
                    line_sep = _line_sep_pixels;
                    __mark_dirty__();
                    return self;
                };

                #region jsDoc
                /// @func   set_tab_size_spaces()
                /// @desc   Sets how many spaces per tab stop (usually 2 or 4).
                /// @self   WWTextRenderer
                /// @param  {Real} space_count
                /// @returns {Struct.WWTextRenderer}
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
                /// @self   WWTextRenderer
                /// @param  {Bool} use_stops
                /// @returns {Struct.WWTextRenderer}
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
                /// @self    WWTextRenderer
                /// @param   {Bool} enabled
                /// @returns {Struct.WWTextRenderer}
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
                    /// @self    WWTextRenderer
                    /// @param   {Bool} visible
	                /// @returns {Struct.WWTextRenderer}
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
                    /// @self    WWTextRenderer
                    /// @param   {String} space_marker
                    /// @param   {String} tab_marker
	                /// @returns {Struct.WWTextRenderer}
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
                    /// @self    WWTextRenderer
                    /// @param   {Constant.Color} color_value
                    /// @param   {Real} alpha_value
	                /// @returns {Struct.WWTextRenderer}
	                #endregion
	                static set_whitespace_color = function(_color_value, _alpha_value=undefined) {

	                    whitespace_color = _color_value;

	                    if (!is_undefined(_alpha_value)) {
	                        whitespace_alpha = _alpha_value;
	                    }

	                    __mark_vb_dirty__();
	                    return self;
	                }

                    #region jsDoc
                    /// @func    set_whitespace_alpha()
                    /// @desc    Sets the alpha used for whitespace marker glyphs.
                    /// @self    WWTextRenderer
                    /// @param   {Real} alpha_value
                    /// @returns {Struct.WWTextRenderer}
                    #endregion
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
                    /// @self    WWTextRenderer
                    /// @param   {Real} offset
	                /// @returns {Struct.WWTextRenderer}
	                #endregion
	                static set_underline_offset = function(_offset) {

	                    underline_y_offset = _offset;
	                    __mark_vb_dirty__();

	                    return self;
	                }

	                #region jsDoc
	                /// @func    set_underline_thickness()
	                /// @desc    Set thickness for plain underline in pixels.
                    /// @self    WWTextRenderer
                    /// @param   {Real} thickness
	                /// @returns {Struct.WWTextRenderer}
	                #endregion
	                static set_underline_thickness = function(_thickness) {

	                    underline_thickness = _thickness;
	                    __mark_vb_dirty__();

	                    return self;
	                }

	                #region jsDoc
	                /// @func    set_underline_sprites()
	                /// @desc    Set sprites used for underline styles.
                    /// @self    WWTextRenderer
                    /// @param   {Asset.GMSprite} sprite_white
                    /// @param   {Asset.GMSprite} sprite_warning
                    /// @param   {Asset.GMSprite} sprite_error
	                /// @returns {Struct.WWTextRenderer}
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
                    /// @self    WWTextRenderer
                    /// @param   {Real} offset
	                /// @returns {Struct.WWTextRenderer}
	                #endregion
	                static set_strike_offset = function(_offset) {

	                    strike_y_offset = _offset;
	                    __mark_vb_dirty__();

	                    return self;
	                }

	                #region jsDoc
	                /// @func    set_strike_thickness()
	                /// @desc    Set thickness for plain strike-through in pixels.
                    /// @self    WWTextRenderer
                    /// @param   {Real} thickness
	                /// @returns {Struct.WWTextRenderer}
	                #endregion
	                static set_strike_thickness = function(_thickness) {

	                    strike_thickness = _thickness;
	                    __mark_vb_dirty__();

	                    return self;
	                }

	                #region jsDoc
	                /// @func    set_strike_sprites()
	                /// @desc    Set sprites used for strike-through styles.
                    /// @self    WWTextRenderer
                    /// @param   {Asset.GMSprite} sprite_white
                    /// @param   {Asset.GMSprite} sprite_warning
                    /// @param   {Asset.GMSprite} sprite_error
	                /// @returns {Struct.WWTextRenderer}
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

            #region jsDoc
            /// @func    on_change()
            /// @desc    Adds a listener for the renderer's change event.
            /// @self    WWTextRenderer
            /// @param   {Function} func
            /// @returns {Struct.WWTextRenderer}
            #endregion
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
				__draw_carets__();
				__draw_widgets_debug__();
            });
			
		#endregion
		
        #region Variables

            // Styling
            caption = "";
            font = undefined;
            font_fallbacks = [];
            color = undefined;
            alpha = undefined;


            // Formatting / diagnostics (optional)
            formatting_enabled = true;

            // VB emission culling (performance)
            // If a GPU scissor is active, only emit glyph geometry for that visible region (plus margin).
            // VB will be rebuilt only when the scissor window moves outside the previously emitted region.
            vb_cull_emits_to_scissor = true;
            vb_scissor_margin = 1;

            // Progressive VB emission ("green threads")
            // Builds the visible scissor region first, then expands the emitted region outward over
            // subsequent frames to avoid emitting all glyphs at once.
            vb_progressive_emit_enabled = true;
            vb_progressive_emit_expand_px = 256;
            vb_progressive_chunk_height_px = 512;
            vb_progressive_chunk_width_px = 1024;
            vb_progressive_chunk_lines = 32;

            // Keep only chunks near the visible region (prevents batch count from exploding)
            vb_progressive_cache_chunk_radius = 2;

            // If glyph count is small, skip culling/chunking and build everything.
            vb_small_text_full_build_glyphs = 2048;

            // Debug overlay for VB culling
            vb_debug_show_cull = false;
            vb_debug_cull_color_cached = c_lime;
            vb_debug_cull_color_desired = c_aqua;
            vb_debug_cull_color_scissor = c_red;

            // Debug overlay: chunk grid boundaries
            vb_debug_show_chunks = true;

            // Debug overlay: progressive/chunk status HUD
            vb_debug_show_progressive = false;

            // Debug overlay: widget rectangles
            widget_debug_show = false;
            widget_debug_color_inline = c_aqua;
            widget_debug_color_block = c_fuchsia;

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
            /// @func   get_caption()
            /// @self   WWTextRenderer
            /// @returns {String}
            #endregion
            static get_caption = function() {
                return caption;
            };

            #region jsDoc
            /// @func   get_text_color()
            /// @self   WWTextRenderer
            /// @returns {Constant.Color}
            #endregion
            static get_text_color = function() {
                return color;
            };

            #region jsDoc
            /// @func   get_text_alpha()
            /// @self   WWTextRenderer
            /// @returns {Real}
            #endregion
            static get_text_alpha = function() {
                return alpha;
            };

            #region jsDoc
            /// @func   get_text_processor()
            /// @desc   Returns the current processor function (or undefined).
            /// @self   WWTextRenderer
            /// @returns {Any}
            #endregion
            static get_text_processor = function() {
                return __text_processor__;
            };

            #region jsDoc
            /// @func   get_font()
            /// @self   WWTextRenderer
            /// @returns {Asset.GMFont}
            #endregion
            static get_font = function() {
                return font;
            };

            #region jsDoc
            /// @func   get_font_fallbacks()
            /// @self   WWTextRenderer
            /// @returns {Array<Asset.GMFont>}
            #endregion
            static get_font_fallbacks = function() {
                return font_fallbacks;
            };

            #region jsDoc
            /// @func   get_wrap_enabled()
            /// @self   WWTextRenderer
            /// @returns {Bool}
            #endregion
            static get_wrap_enabled = function() {
                return should_wrap;
            };

            #region jsDoc
            /// @func   get_line_sep()
            /// @self   WWTextRenderer
            /// @returns {Real}
            #endregion
            static get_line_sep = function() {
                return line_sep;
            };

            #region jsDoc
            /// @func   get_tab_size_spaces()
            /// @self   WWTextRenderer
            /// @returns {Real}
            #endregion
            static get_tab_size_spaces = function() {
                return tab_size_spaces;
            };

            #region jsDoc
            /// @func   get_tab_use_stops()
            /// @self   WWTextRenderer
            /// @returns {Bool}
            #endregion
            static get_tab_use_stops = function() {
                return tab_use_stops;
            };

            #region jsDoc
            /// @func   get_formatting_enabled()
            /// @self   WWTextRenderer
            /// @returns {Bool}
            #endregion
            static get_formatting_enabled = function() {
                return formatting_enabled;
            };

            #region jsDoc
            /// @func   get_whitespace_visible()
            /// @self   WWTextRenderer
            /// @returns {Bool}
            #endregion
            static get_whitespace_visible = function() {
                return whitespace_visible;
            };

            #region jsDoc
            /// @func   get_whitespace_markers()
            /// @self   WWTextRenderer
            /// @returns {Struct}
            #endregion
            static get_whitespace_markers = function() {
                return {
                    space: whitespace_marker_space,
                    tab: whitespace_marker_tab,
                };
            };

            #region jsDoc
            /// @func   get_whitespace_color()
            /// @self   WWTextRenderer
            /// @returns {Real}
            #endregion
            static get_whitespace_color = function() {
                return whitespace_color;
            };

            #region jsDoc
            /// @func   get_whitespace_alpha()
            /// @self   WWTextRenderer
            /// @returns {Real}
            #endregion
            static get_whitespace_alpha = function() {
                return whitespace_alpha;
            };

            #region jsDoc
            /// @func   get_underline_offset()
            /// @self   WWTextRenderer
            /// @returns {Real}
            #endregion
            static get_underline_offset = function() {
                return underline_y_offset;
            };

            #region jsDoc
            /// @func   get_underline_thickness()
            /// @self   WWTextRenderer
            /// @returns {Real}
            #endregion
            static get_underline_thickness = function() {
                return underline_thickness;
            };

            #region jsDoc
            /// @func   get_underline_sprites()
            /// @self   WWTextRenderer
            /// @returns {Struct}
            #endregion
            static get_underline_sprites = function() {
                return {
                    white: underline_sprite_white,
                    warning: underline_sprite_warning,
                    error: underline_sprite_error,
                };
            };

            #region jsDoc
            /// @func   get_strike_offset()
            /// @self   WWTextRenderer
            /// @returns {Real}
            #endregion
            static get_strike_offset = function() {
                return strike_y_offset;
            };

            #region jsDoc
            /// @func   get_strike_thickness()
            /// @self   WWTextRenderer
            /// @returns {Real}
            #endregion
            static get_strike_thickness = function() {
                return strike_thickness;
            };

            #region jsDoc
            /// @func   get_strike_sprites()
            /// @self   WWTextRenderer
            /// @returns {Struct}
            #endregion
            static get_strike_sprites = function() {
                return {
                    white: strike_sprite_white,
                    warning: strike_sprite_warning,
                    error: strike_sprite_error,
                };
            };

            #region jsDoc
            /// @func   get_content_width()
            /// @self   WWTextRenderer
            /// @returns {Real}
            #endregion
            static get_content_width = function() {
                __ensure_layout__();
                return __content_width__;
            };

            #region jsDoc
            /// @func   get_content_height()
            /// @self   WWTextRenderer
            /// @returns {Real}
            #endregion
            static get_content_height = function() {
                __ensure_layout__();
                return __content_height__;
            };

            #region Location Maths

                #region jsDoc
                /// @func   __layout_get_line_x_min__()
                /// @ignore
                /// @desc   Returns the minimum x position for a line in final layout space.
                ///         This is the shared "x origin" used by caret/hit-test/highlight.
                ///         It accounts for alignment shifts and leading inline widget reserved
                ///         space (via widget placements).
                /// @self   WWTextRenderer
                /// @param  {Real} line_index
                /// @returns {Real}
                #endregion
                static __layout_get_line_x_min__ = function(_line_index) {
                    var _line_count = __layout_lines_count__;
                    if (_line_count <= 0) { return 0; }
                    if (_line_index < 0) { _line_index = 0; }
                    if (_line_index >= _line_count) { _line_index = _line_count - 1; }

                    var _lines = __layout_lines__;
                    var _glyphs = __layout_glyphs__;
                    var _glyph_count = __layout_glyphs_count__;
                    if (_glyph_count <= 0) { return 0; }

                    var _lb = _line_index * __WW_Layout_Line.__Size__;
                    var _start_index = _lines[_lb + __WW_Layout_Line.Start_Index];
                    var _end_index = _lines[_lb + __WW_Layout_Line.End_Index];
                    var _line_len = _end_index - _start_index;
                    if (_line_len <= 0) { return 0; }

                    // Start with first drawable glyph x.
                    var _x0 = 0;
                    var _scan = _start_index;
                    repeat (_line_len) {
                        if (_scan >= 0 && _scan < _glyph_count) {
                            var _gb0 = _scan * __WW_Layout_Glyph.__Size__;
                            var _ch0 = _glyphs[_gb0 + __WW_Layout_Glyph.Char];
                            if (_ch0 != "\n" && _ch0 != "\r" && _ch0 != "") {
                                _x0 = _glyphs[_gb0 + __WW_Layout_Glyph.X];
                                break;
                            }
                        }
                        _scan += 1;
                    }

                    // Extend left to include any leading inline widget reserved space.
                    var _pl = __layout_widget_placements__;
                    if (is_array(_pl) && array_length(_pl) > 0) {
                        var _pi = 0;
                        var _pn = array_length(_pl);
                        repeat (_pn) {
                            var _p = _pl[_pi];
                            _pi += 1;
                            if (is_undefined(_p)) { continue; }
                            if (variable_struct_get(_p, "kind") != "inline") { continue; }
                            if (variable_struct_get(_p, "line_index") != _line_index) { continue; }
                            var _wx = variable_struct_get(_p, "x");
                            if (!is_undefined(_wx) && _wx < _x0) {
                                _x0 = _wx;
                            }
                        }
                    }

                    return _x0;
                };

                #region jsDoc
                /// @func   get_x_from_index()
                /// @self   WWTextRenderer
                /// @param  {Real} index
                /// @returns {Real}
                #endregion
                static get_x_from_index = function(_index) {
                    __ensure_layout__();
					
                    var _lines = __layout_lines__;
                    var _glyphs = __layout_glyphs__;
					var _glyph_count = __layout_glyphs_count__;
					
					if (_glyph_count <= 0) return 0;
					if (array_length(_lines) == 0) return 0;
					
                    var _line_index = get_line_from_index(_index);
                    var _line_base = _line_index * __WW_Layout_Line.__Size__;
					
                    var _start_index = _lines[_line_base + __WW_Layout_Line.Start_Index];
                    var _end_index = _lines[_line_base + __WW_Layout_Line.End_Index];
					var _line_width_val = _lines[_line_base + __WW_Layout_Line.Width];
					
                    var _line_len = _end_index - _start_index;
                    if (_line_len <= 0) {
                        return 0;
                    }
					
					var _line_x0 = __layout_get_line_x_min__(_line_index);
					
                    if (_index <= _start_index) {
                        return _line_x0;
                    }
                    if (_index >= _end_index) {
                        return _line_x0 + _line_width_val;
                    }
					
                    // Use the final laid-out x positions (these include alignment + widget shifts).
					var _gi = _index;
					if (_gi < 0) { _gi = 0; }
					if (_gi >= _glyph_count) { _gi = _glyph_count - 1; }
					var _gb = _gi * __WW_Layout_Glyph.__Size__;
                    var _ch = _glyphs[_gb + __WW_Layout_Glyph.Char];
                    if (_ch == "\n" || _ch == "\r" || _ch == "") {
                        return _line_x0 + _line_width_val;
                    }
                    return _glyphs[_gb + __WW_Layout_Glyph.X];
                };
				
                #region jsDoc
                /// @func   get_y_from_index()
                /// @self   WWTextRenderer
                /// @param  {Real} index
                /// @returns {Real}
                #endregion
                static get_y_from_index = function(_index) {
                    __ensure_layout__();

                    var _line_index = get_line_from_index(_index);
                    var _lines = __layout_lines__;
					
					if (array_length(_lines) == 0) return 0;
					
                    var _base = _line_index * __WW_Layout_Line.__Size__;
					
                    return _lines[_base + __WW_Layout_Line.Y_Offset];
                };

                #region jsDoc
                /// @func   get_index_from_xy()
                /// @self   WWTextRenderer
                /// @param  {Real} x
                /// @param  {Real} y
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
                    var _glyph_count = __layout_glyphs_count__;
                    if (_glyph_count <= 0) {
                        return 0;
                    }

					var _line_len = _end_index - _start_index;
					var _line_x0 = __layout_get_line_x_min__(_line_index);
					var _line_x1 = _line_x0 + _line_width_val;

					if (_target_x <= _line_x0) {
                        return _start_index;
                    }

					if (_target_x >= _line_x1) {

                        var _is_forced_wrapped = _lines[_line_base + __WW_Layout_Line.Force_Wraped];
                        var _is_last_line = (_line_index == _line_count - 1);

                        if (_is_forced_wrapped || _is_last_line) {
                            return _end_index;
                        }

                        return max(_start_index, _end_index - 1);
                    }

					// Walk glyphs using final x positions (includes inline widget shifts).
                    var _index_result = _end_index;
                    var _walk_index = _start_index;
                    repeat (max(0, _line_len)) {
                        if (_walk_index < 0 || _walk_index >= _glyph_count) {
                            break;
                        }

                        var _glyph_base = _walk_index * __WW_Layout_Glyph.__Size__;
                        var _ch = _glyphs[_glyph_base + __WW_Layout_Glyph.Char];
                        if (_ch == "\n" || _ch == "\r" || _ch == "") {
                            _walk_index += 1;
                            continue;
                        }

						var _gx = _glyphs[_glyph_base + __WW_Layout_Glyph.X];
                        var _gw = _glyphs[_glyph_base + __WW_Layout_Glyph.Width];
                        var _mid = _gx + (_gw * 0.5);

						if (_target_x < _mid) {
                            _index_result = _walk_index;
                            break;
                        }

                        _index_result = _walk_index + 1;
                        _walk_index += 1;
                    }

                    return _index_result;
                };

                #region jsDoc
                /// @func   get_line_from_index()
                /// @self   WWTextRenderer
                /// @param  {Real} index
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
                /// @self   WWTextRenderer
                /// @param  {Real} index
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
                /// @self   WWTextRenderer
                /// @param  {Real} line
                /// @param  {Real} col
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

                #region jsDoc
                /// @func   get_line_count()
                /// @desc   Returns the number of laid-out (wrapped) lines.
                /// @self   WWTextRenderer
                /// @returns {Real}
                #endregion
                static get_line_count = function() {
                    __ensure_layout__();
                    return __layout_lines_count__;
                };

                #region jsDoc
                /// @func   get_line()
                /// @desc   Returns a line descriptor struct for a laid-out line.
                /// @self   WWTextRenderer
                /// @param  {Real} line_index
                /// @returns {Struct}
                #endregion
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

                #region jsDoc
                /// @func   get_line_text()
                /// @desc   Returns the cached line text for a laid-out line.
                /// @self   WWTextRenderer
                /// @param  {Real} line_index
                /// @returns {String}
                #endregion
                static get_line_text = function(_line_index) {
                    __ensure_layout__();

                    if (_line_index < 0 || _line_index >= __layout_lines_count__) {
                        return "";
                    }

                    var _index = _line_index * __WW_Layout_Line.__Size__;
                    return __layout_lines__[_index + __WW_Layout_Line.Text];
                };

                #region jsDoc
                /// @func   get_line_index_start()
                /// @desc   Returns the start character index for a laid-out line.
                /// @self   WWTextRenderer
                /// @param  {Real} line_index
                /// @returns {Real}
                #endregion
                static get_line_index_start = function(_line_index) {
                    __ensure_layout__();

                    if (_line_index < 0 || _line_index >= __layout_lines_count__) {
                        return 0;
                    }

                    var _index = _line_index * __WW_Layout_Line.__Size__;
                    return __layout_lines__[_index + __WW_Layout_Line.Start_Index];
                };

                #region jsDoc
                /// @func   get_line_index_end()
                /// @desc   Returns the end character index for a laid-out line.
                /// @self   WWTextRenderer
                /// @param  {Real} line_index
                /// @returns {Real}
                #endregion
                static get_line_index_end = function(_line_index) {
                    __ensure_layout__();

                    if (_line_index < 0 || _line_index >= __layout_lines_count__) {
                        return 0;
                    }

                    var _index = _line_index * __WW_Layout_Line.__Size__;
                    return __layout_lines__[_index + __WW_Layout_Line.End_Index];
                };

                #region jsDoc
                /// @func   get_line_width()
                /// @desc   Returns the pixel width of a laid-out line.
                /// @self   WWTextRenderer
                /// @param  {Real} line_index
                /// @returns {Real}
                #endregion
                static get_line_width = function(_line_index) {
                    __ensure_layout__();

                    if (_line_index < 0 || _line_index >= __layout_lines_count__) {
                        return 0;
                    }

                    var _index = _line_index * __WW_Layout_Line.__Size__;
                    return __layout_lines__[_index + __WW_Layout_Line.Width];
                };

                #region jsDoc
                /// @func   get_line_height()
                /// @desc   Returns the pixel height of a laid-out line.
                /// @self   WWTextRenderer
                /// @param  {Real} line_index
                /// @returns {Real}
                #endregion
                static get_line_height = function(_line_index) {
                    __ensure_layout__();

                    if (_line_index < 0 || _line_index >= __layout_lines_count__) {
                        return 0;
                    }

                    var _index = _line_index * __WW_Layout_Line.__Size__;
                    return __layout_lines__[_index + __WW_Layout_Line.Height];
                };

                #region jsDoc
                /// @func   get_line_y_offset()
                /// @desc   Returns the y offset (in pixels) for a laid-out line.
                /// @self   WWTextRenderer
                /// @param  {Real} line_index
                /// @returns {Real}
                #endregion
                static get_line_y_offset = function(_line_index) {
                    __ensure_layout__();

                    if (_line_index < 0 || _line_index >= __layout_lines_count__) {
                        return 0;
                    }

                    var _index = _line_index * __WW_Layout_Line.__Size__;
                    return __layout_lines__[_index + __WW_Layout_Line.Y_Offset];
                };

                #region jsDoc
                /// @func   get_line_forced_wrapped()
                /// @desc   Returns true if the line ended due to forced wrapping.
                /// @self   WWTextRenderer
                /// @param  {Real} line_index
                /// @returns {Bool}
                #endregion
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

                #region jsDoc
                /// @func   get_glyph_count()
                /// @desc   Returns the number of laid-out glyphs.
                /// @self   WWTextRenderer
                /// @returns {Real}
                #endregion
                static get_glyph_count = function() {
                    __ensure_layout__();
                    return __layout_glyphs_count__;
                };

                #region jsDoc
                /// @func   get_glyph()
                /// @desc   Returns a glyph descriptor struct for a laid-out glyph.
                /// @self   WWTextRenderer
                /// @param  {Real} glyph_index
                /// @returns {Struct|Undefined}
                #endregion
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

                #region jsDoc
                /// @func   get_glyph_char()
                /// @desc   Returns the character for a laid-out glyph.
                /// @self   WWTextRenderer
                /// @param  {Real} glyph_index
                /// @returns {String|Undefined}
                #endregion
                static get_glyph_char = function(_glyph_index) {
                    __ensure_layout__();

                    if (_glyph_index < 0 || _glyph_index >= __layout_glyphs_count__) {
                        return undefined;
                    }

                    var _index = _glyph_index * __WW_Layout_Glyph.__Size__;
                    return __layout_glyphs__[_index + __WW_Layout_Glyph.Char];
                };

                #region jsDoc
                /// @func   get_glyph_index()
                /// @desc   Returns the source text index for a laid-out glyph.
                /// @self   WWTextRenderer
                /// @param  {Real} glyph_index
                /// @returns {Real|Undefined}
                #endregion
                static get_glyph_index = function(_glyph_index) {
                    __ensure_layout__();

                    if (_glyph_index < 0 || _glyph_index >= __layout_glyphs_count__) {
                        return undefined;
                    }

                    var _index = _glyph_index * __WW_Layout_Glyph.__Size__;
                    return __layout_glyphs__[_index + __WW_Layout_Glyph.Index];
                };

                #region jsDoc
                /// @func   get_glyph_x()
                /// @desc   Returns the x position (in pixels) for a laid-out glyph.
                /// @self   WWTextRenderer
                /// @param  {Real} glyph_index
                /// @returns {Real}
                #endregion
                static get_glyph_x = function(_glyph_index) {
                    __ensure_layout__();

                    if (_glyph_index < 0 || _glyph_index >= __layout_glyphs_count__) {
                        return 0;
                    }

                    var _index = _glyph_index * __WW_Layout_Glyph.__Size__;
                    return __layout_glyphs__[_index + __WW_Layout_Glyph.X];
                };

                #region jsDoc
                /// @func   get_glyph_y()
                /// @desc   Returns the y position (in pixels) for a laid-out glyph.
                /// @self   WWTextRenderer
                /// @param  {Real} glyph_index
                /// @returns {Real}
                #endregion
                static get_glyph_y = function(_glyph_index) {
                    __ensure_layout__();

                    if (_glyph_index < 0 || _glyph_index >= __layout_glyphs_count__) {
                        return 0;
                    }

                    var _index = _glyph_index * __WW_Layout_Glyph.__Size__;
                    return __layout_glyphs__[_index + __WW_Layout_Glyph.Y];
                };

                #region jsDoc
                /// @func   get_glyph_width()
                /// @desc   Returns the width (in pixels) for a laid-out glyph.
                /// @self   WWTextRenderer
                /// @param  {Real} glyph_index
                /// @returns {Real|Undefined}
                #endregion
                static get_glyph_width = function(_glyph_index) {
                    __ensure_layout__();

                    if (_glyph_index < 0 || _glyph_index >= __layout_glyphs_count__) {
                        return undefined;
                    }

                    var _index = _glyph_index * __WW_Layout_Glyph.__Size__;
                    return __layout_glyphs__[_index + __WW_Layout_Glyph.Width];
                };

                #region jsDoc
                /// @func   get_glyph_height()
                /// @desc   Returns the height (in pixels) for a laid-out glyph.
                /// @self   WWTextRenderer
                /// @param  {Real} glyph_index
                /// @returns {Real|Undefined}
                #endregion
                static get_glyph_height = function(_glyph_index) {
                    __ensure_layout__();

                    if (_glyph_index < 0 || _glyph_index >= __layout_glyphs_count__) {
                        return undefined;
                    }

                    var _index = _glyph_index * __WW_Layout_Glyph.__Size__;
                    return __layout_glyphs__[_index + __WW_Layout_Glyph.Height];
                };

            #endregion

            #region Widget getters

                #region jsDoc
                /// @func   get_widgets()
                /// @desc   Returns the last widget descriptor array emitted by the current
                ///         text processor (or [] if none). Widgets are optional and are
                ///         anchored in processed-text index space.
                /// @self   WWTextRenderer
                /// @returns {Array}
                #endregion
                static get_widgets = function() {
                    __ensure_layout__();
                    return __layout_widgets__;
                };

                #region jsDoc
                /// @func   get_widget_placements()
                /// @desc   Returns computed widget placements in local layout space.
                ///         Placements do not currently affect text layout; they are intended
                ///         for overlay rendering / hit testing.
                /// @self   WWTextRenderer
                /// @returns {Array}
                #endregion
                static get_widget_placements = function() {
                    __ensure_layout__();
                    return __layout_widget_placements__;
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

            // Optional widget descriptors/placements emitted by processor
            __layout_widgets__ = [];
            __layout_widget_placements__ = [];

            // VB cache
            __vb_is_dirty__ = true;
            __vb_format__ = undefined;

            // Optional emit culling region (local coords, relative to draw origin)
            __vb_emit_clip__ = undefined;
            __vb_last_emit_clip__ = undefined;
            __vb_desired_emit_clip__ = { x0: 0, y0: 0, x1: 0, y1: 0 };

            __vb_progressive_active__ = false;
            __vb_progressive_last_step_ms__ = -1;

            // VB render mode: 0=full, 1=scissor-clip, 2=progressive-chunks
            __vb_render_mode__ = 0;

            // Chunk-based progressive build state
            __vb_built_this_frame__ = false;
            __vb_needs_full_rebuild__ = true;
            __vb_force_full_build__ = false;
            __vb_open_buffers__ = [];
            __vb_pending_chunks__ = []; // normal-priority (LIFO)
            __vb_pending_front__ = [];  // high-priority (LIFO)
            __vb_chunk_built__ = [];
            __vb_chunk_queued__ = []; // 0=not queued, 1=normal, 2=front
            __vb_chunk_count__ = 0;
            __vb_visible_chunk_min__ = 0;
            __vb_visible_chunk_max__ = -1;
            __vb_keep_chunk_min__ = 0;
            __vb_keep_chunk_max__ = -1;
            __vb_current_chunk_id__ = -1;
            __vb_current_chunk_bounds__ = { x0: 0, y0: 0, x1: 0, y1: 0 };

            __vb_dbg_last_total_glyphs__ = 0;
            __vb_dbg_last_emitted_glyphs__ = 0;

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

            #region jsDoc
            /// @func   __mark_dirty__()
            /// @ignore
            /// @desc   Marks the renderer layout as dirty and also marks the VB cache dirty.
            /// @self   WWTextRenderer
            /// @returns {Undefined}
            #endregion
            static __mark_dirty__ = function() {
                __is_dirty__ = true;
                __mark_vb_dirty__();
            };

            #region jsDoc
            /// @func   __mark_vb_dirty__()
            /// @ignore
            /// @desc   Marks the VB cache as dirty and resets progressive chunk-build state.
            /// @self   WWTextRenderer
            /// @returns {Undefined}
            #endregion
            static __mark_vb_dirty__ = function() {
                __vb_is_dirty__ = true;
                __vb_needs_full_rebuild__ = true;
                __vb_force_full_build__ = false;
                __vb_pending_chunks__ = [];
                __vb_pending_front__ = [];
                __vb_chunk_built__ = [];
                __vb_chunk_queued__ = [];
                __vb_chunk_count__ = 0;
                __vb_visible_chunk_min__ = 0;
                __vb_visible_chunk_max__ = -1;
                __vb_keep_chunk_min__ = 0;
                __vb_keep_chunk_max__ = -1;
            };

        #endregion

        #region VB batch helpers

            #region jsDoc
            /// @func   __vb_queue_chunk_unique__()
            /// @ignore
            /// @desc   Queues a chunk id for VB building (normal priority) if not already queued/built.
            /// @self   WWTextRenderer
            /// @param  {Real} chunk_id
            /// @returns {Undefined}
            #endregion
            static __vb_queue_chunk_unique__ = function(_chunk_id) {
                if (is_undefined(_chunk_id) || _chunk_id < 0) {
                    return;
                }

                // Fast-path: use queued flags instead of scanning arrays.
                if (array_length(__vb_chunk_queued__) == __vb_chunk_count__) {
                    if (_chunk_id >= __vb_chunk_count__) { return; }
                    if (__vb_chunk_built__[_chunk_id]) { return; }
                    if (__vb_chunk_queued__[_chunk_id] != 0) { return; }
                    __vb_chunk_queued__[_chunk_id] = 1;
                    array_push(__vb_pending_chunks__, _chunk_id);
                    return;
                }

                // Avoid duplicates in the pending queue
                var _i = 0;
                var _n = array_length(__vb_pending_chunks__);
                repeat (_n) {
                    if (__vb_pending_chunks__[_i] == _chunk_id) {
                        return;
                    }
                    _i += 1;
                }

                array_push(__vb_pending_chunks__, _chunk_id);
            };

            #region jsDoc
            /// @func   __vb_queue_chunk_unique_front__()
            /// @ignore
            /// @desc   Queues a chunk id for VB building with high priority.
            /// @self   WWTextRenderer
            /// @param  {Real} chunk_id
            /// @returns {Undefined}
            #endregion
            static __vb_queue_chunk_unique_front__ = function(_chunk_id) {
                if (is_undefined(_chunk_id) || _chunk_id < 0) {
                    return;
                }

                // Fast-path: promote via queued flags (no array insert/delete).
                if (array_length(__vb_chunk_queued__) == __vb_chunk_count__) {
                    if (_chunk_id >= __vb_chunk_count__) { return; }
                    if (__vb_chunk_built__[_chunk_id]) { return; }
                    var _q = __vb_chunk_queued__[_chunk_id];
                    if (_q == 2) { return; }
                    __vb_chunk_queued__[_chunk_id] = 2;
                    array_push(__vb_pending_front__, _chunk_id);
                    return;
                }

                // Fallback (should rarely happen): just push onto the front list.
                array_push(__vb_pending_front__, _chunk_id);
            };

            #region jsDoc
            /// @func   __vb_pop_next_pending_chunk__()
            /// @ignore
            /// @desc   Pops the next pending chunk id (prefers high priority, respects keep range).
            /// @self   WWTextRenderer
            /// @returns {Real} chunk_id
            #endregion
            static __vb_pop_next_pending_chunk__ = function() {

                if (__vb_chunk_count__ <= 0) {
                    return -1;
                }

                var _keep_min = __vb_keep_chunk_min__;
                var _keep_max = __vb_keep_chunk_max__;

                // Prefer high-priority pending.
                while (array_length(__vb_pending_front__) > 0) {
                    var _cid = array_pop(__vb_pending_front__);
                    if (is_undefined(_cid) || _cid < 0 || _cid >= __vb_chunk_count__) { continue; }
                    if (_cid < _keep_min || _cid > _keep_max) {
                        if (array_length(__vb_chunk_queued__) == __vb_chunk_count__) { __vb_chunk_queued__[_cid] = 0; }
                        continue;
                    }
                    if (__vb_chunk_built__[_cid]) {
                        if (array_length(__vb_chunk_queued__) == __vb_chunk_count__) { __vb_chunk_queued__[_cid] = 0; }
                        continue;
                    }
                    if (array_length(__vb_chunk_queued__) == __vb_chunk_count__) { __vb_chunk_queued__[_cid] = 0; }
                    return _cid;
                }

                // Then normal pending.
                while (array_length(__vb_pending_chunks__) > 0) {
                    var _cid2 = array_pop(__vb_pending_chunks__);
                    if (is_undefined(_cid2) || _cid2 < 0 || _cid2 >= __vb_chunk_count__) { continue; }
                    if (_cid2 < _keep_min || _cid2 > _keep_max) {
                        if (array_length(__vb_chunk_queued__) == __vb_chunk_count__) { __vb_chunk_queued__[_cid2] = 0; }
                        continue;
                    }
                    if (__vb_chunk_built__[_cid2]) {
                        if (array_length(__vb_chunk_queued__) == __vb_chunk_count__) { __vb_chunk_queued__[_cid2] = 0; }
                        continue;
                    }
                    if (array_length(__vb_chunk_queued__) == __vb_chunk_count__) { __vb_chunk_queued__[_cid2] = 0; }
                    return _cid2;
                }

                return -1;
            };

            #region jsDoc
            /// @func   __vb_pick_unbuilt_visible_chunk__()
            /// @ignore
            /// @desc   Picks an unbuilt chunk id within the current visible chunk window.
            /// @self   WWTextRenderer
            /// @returns {Real} chunk_id
            #endregion
            static __vb_pick_unbuilt_visible_chunk__ = function() {

                if (__vb_chunk_count__ <= 0) {
                    return -1;
                }

                var _vis_min = __vb_visible_chunk_min__;
                var _vis_max = __vb_visible_chunk_max__;

                if (_vis_max < _vis_min) {
                    return clamp(_vis_min, 0, __vb_chunk_count__ - 1);
                }

                if (array_length(__vb_chunk_built__) != __vb_chunk_count__) {
                    return clamp(_vis_min, 0, __vb_chunk_count__ - 1);
                }

                var _c = _vis_min;
                while (_c <= _vis_max) {
                    if (!__vb_chunk_built__[_c]) {
                        return _c;
                    }
                    _c += 1;
                }

                return -1;
            };

            #region jsDoc
            /// @func   __vb_queue_visible_chunk_now__()
            /// @ignore
            /// @desc   Picks a visible unbuilt chunk and queues it at high priority.
            /// @self   WWTextRenderer
            /// @returns {Real} chunk_id
            #endregion
            static __vb_queue_visible_chunk_now__ = function() {
                var _picked = __vb_pick_unbuilt_visible_chunk__();
                if (_picked >= 0) {
                    __vb_queue_chunk_unique_front__(_picked);
                }
                return _picked;
            };

            #region jsDoc
            /// @func   __vb_build_visible_chunks_now__()
            /// @ignore
            /// @desc   Builds queued visible chunks immediately (progressive mode only).
            /// @self   WWTextRenderer
            /// @returns {Undefined}
            #endregion
            static __vb_build_visible_chunks_now__ = function() {

                if (__vb_render_mode__ != 2 || !vb_progressive_emit_enabled || !vb_cull_emits_to_scissor) {
                    return;
                }

                var _vis_min = __vb_visible_chunk_min__;
                var _vis_max = __vb_visible_chunk_max__;

                // Safety cap to avoid pathological stalls if something goes wrong.
                var _max_builds = (_vis_max - _vis_min) + 1;
                if (_max_builds < 0) { _max_builds = 0; }
                if (_max_builds > 32) { _max_builds = 32; }

                var _built_count = 0;
                while (_built_count < _max_builds) {

                    var _picked = __vb_queue_visible_chunk_now__();
                    if (_picked < 0) {
                        break;
                    }

                    if (array_length(__vb_pending_front__) <= 0 && array_length(__vb_pending_chunks__) <= 0) {
                        break;
                    }

                    __build_vb__();
                    _built_count += 1;
                }
            };

            #region jsDoc
            /// @func   __vb_delete_batches_for_chunk__()
            /// @ignore
            /// @desc   Frees draw batches (materials + vertex buffers) associated with a given chunk.
            /// @self   WWTextRenderer
            /// @param  {Real} chunk_id
            /// @returns {Undefined}
            #endregion
            static __vb_delete_batches_for_chunk__ = function(_chunk_id) {
                if (is_undefined(_chunk_id) || _chunk_id < 0) {
                    return;
                }

                var _b = array_length(__draw_batches__) - 1;
                while (_b >= 0) {
                    var _batch = __draw_batches__[_b];
                    if (!is_undefined(_batch) && _batch.chunk_id == _chunk_id) {
                        if (!is_undefined(_batch.material) && is_callable(_batch.material.destroy)) {
                            _batch.material.destroy();
                        }
                        if (!is_undefined(_batch.buffer)) {
                            vertex_delete_buffer(_batch.buffer);
                        }
                        array_delete(__draw_batches__, _b, 1);
                    }
                    _b -= 1;
                }
            };

			#region jsDoc
			/// @func   __vb_get_batch_for_material__()
            /// @ignore
            /// @self   WWTextRenderer
            /// @param  {Id.Texture} tex
            /// @param  {Real} layer
            /// @param  {Id.Shader|Undefined} shader
            /// @param  {Real} spread
            /// @param  {Real} chunk_id
			/// @returns {Struct} batch
			#endregion
            static __vb_get_batch_for_material__ = function(_tex, _layer, _shader, _spread, _chunk_id) {

                // Normalize keys so comparisons are stable (avoid undefined equality edge-cases)
                var _shader_key = _shader;
                if (is_undefined(_shader_key) || _shader_key == -1) { _shader_key = -1; }

                var _spread_key = _spread;
                if (is_undefined(_spread_key)) { _spread_key = 0; }

			    var _batch_count = array_length(__draw_batches__);
			    var _batch_index = 0;

                repeat (_batch_count) {
			        var _batch = __draw_batches__[_batch_index];

                    if (_batch.layer == _layer && _batch.chunk_id == _chunk_id) {

			            var _material = _batch.material;

			            if (!is_undefined(_material)) {
                            // Spread is numeric; shader can be undefined in some paths, so compare normalized key.
                            if (_material.tex == _tex && _material.shader == _shader_key && _material.spread == _spread_key) {
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
                    shader: _shader_key,
                    spread: _spread_key
			    };

                var _draw_fn = method(_closure, function(_x, _y) {
                    if (shader != -1) {
                        shader_set(shader);
                        vertex_submit(vb, pr_trianglelist, tex);
                        shader_reset();
                    } else {
                        vertex_submit(vb, pr_trianglelist, tex);
                    }
                });

			    var _new_material = new WWMaterial(_draw_fn);
			    _new_material.tex = _tex;
                _new_material.shader = _shader_key;
                _new_material.spread = _spread_key;

			    var _new_batch = {
			        material: _new_material,
			        buffer: _vertex_buffer,
			        format: __vb_format__,
                    layer: _layer,
                    chunk_id: _chunk_id,
                    bounds: __vb_current_chunk_bounds__
			    };

			    array_push(__draw_batches__, _new_batch);
			    vertex_begin(_new_batch.buffer, _new_batch.format);
                array_push(__vb_open_buffers__, _new_batch.buffer);

			    return _new_batch;
			};

                #region jsDoc
                /// @func   __vb_ensure_format__()
                /// @ignore
                /// @desc   Lazily creates the vertex format used for text draw batches.
                /// @self   WWTextRenderer
                /// @returns {Undefined}
                #endregion
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

            #region jsDoc
            /// @func   __tab_advance__()
            /// @ignore
            /// @desc   Returns the pixel advance for a tab at the given cursor x position.
            /// @self   WWTextRenderer
            /// @param  {Real} cursor_x
            /// @returns {Real}
            #endregion
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

            #region jsDoc
            /// @func   __measure_line_width_tabs__()
            /// @ignore
            /// @desc   Measures the width of a line of text, accounting for tab stops.
            /// @self   WWTextRenderer
            /// @param  {String} line_text
            /// @returns {Real}
            #endregion
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

            #region jsDoc
            /// @func   __set_textbox__()
            /// @ignore
            /// @desc   Binds this renderer to a textbox-like parent component.
            /// @self   WWTextRenderer
            /// @param  {Struct|Undefined} comp
            /// @returns {Struct.WWTextRenderer}
            #endregion
            static __set_textbox__ = function(_comp) {
                __textbox_parent__ = _comp;
                return self;
            };

            #region jsDoc
            /// @func   __string_split_and_retain__()
            /// @ignore
            /// @desc   Splits a string by delimiter while retaining the delimiter on each segment except the last.
            /// @self   WWTextRenderer
            /// @param  {String} str
            /// @param  {String} delim
            /// @returns {Array<String>}
            #endregion
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

            #region jsDoc
            /// @func   __ensure_layout__()
            /// @ignore
            /// @desc   Builds the internal layout (lines + glyphs) if marked dirty.
            /// @self   WWTextRenderer
            /// @returns {Undefined}
            #endregion
            static __ensure_layout__ = function() {
                if (!__is_dirty__) {
                    return;
                }

				var _t = wwThemeGet();
				var _style = struct_get_chained(_t, "typography", "text_styles", "body");
				var _style_font = (is_struct(_style))
					? ((_style[$ "font_asset"] != undefined) ? _style[$ "font_asset"] : _style[$ "font"])
					: undefined;
				var _style_paint = (is_struct(_style))
					? ((_style[$ "paint"] != undefined) ? _style[$ "paint"] : _style[$ "color"])
					: undefined;
				var _font = font ?? _style_font;
				var _color = color ?? (is_struct(_style_paint) ? _style_paint.color : c_white);
				var _alpha = alpha ?? (is_struct(_style_paint) ? _style_paint.alpha : 1);
				
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
                var _processed_widgets = undefined;
				
				if (!is_undefined(__text_processor__)) {
					
					var _default_state = {
					    color: _color,
					    alpha: _alpha,
					    font_asset: _font,
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
					    _processed_spans = _result[$ "spans"];
						_processed_align_runs = _result[$ "align_runs"];
                        _processed_widgets = _result[$ "widgets"];
					} else {
					    throw "return of text processor must be a struct";
					}
				}


                __display_text__ = _processed_text;
                
                if (!is_array(_processed_spans)) {

                    var _processed_len = string_length(_processed_text);

                    _processed_spans = [{
                        start_index: 0,
                        end_index: _processed_len,
                        font_asset: _font,
                        color: _color,
                        alpha: _alpha,
                        style: __WW_Text_Glyph_Style.Regular,
                        underline: __WW_Text_Glyph_Underline.None,
                        strike: __WW_Text_Glyph_Strike.None,
                        back_color: c_white,
                        back_alpha: 0,
                        size_mul: 1
                    }];
                }

                __build_layout__(_processed_text, _processed_spans);

                // Store widgets and apply layout reservation (line heights + line widths)
                __layout_widgets__ = (is_array(_processed_widgets)) ? _processed_widgets : [];
                __layout_prepare_widgets__(__layout_widgets__);

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

                // Apply inline widget x-shifts and build final widget placements (post-alignment)
                __layout_apply_inline_widgets_and_build_placements__(__layout_widgets__);

                __content_width__ = __layout_content_width__;
                __content_height__ = __layout_content_height__;

                __is_dirty__ = false;
            };

            #region jsDoc
            /// @func   __layout_find_line_for_index__()
            /// @ignore
            /// @desc   Returns the line index that contains a given processed-text index.
            /// @self   WWTextRenderer
            /// @param  {Real} char_index
            /// @returns {Real}
            #endregion
            static __layout_find_line_for_index__ = function(_char_index) {
                var _lines = __layout_lines__;
                var _line_count = __layout_lines_count__;
                if (_line_count <= 0) { return 0; }
                if (_char_index < 0) { _char_index = 0; }
                var _li = 0;
                repeat (_line_count) {
                    var _lb = _li * __WW_Layout_Line.__Size__;
                    var _ls = _lines[_lb + __WW_Layout_Line.Start_Index];
                    var _le = _lines[_lb + __WW_Layout_Line.End_Index];
                    // End_Index is exclusive throughout the layout system.
                    // Using <= here incorrectly maps boundary indices (at the start of the next
                    // line) to the previous line, which breaks widget anchoring and shifting.
                    if (_char_index >= _ls && _char_index < _le) {
                        return _li;
                    }
                    _li += 1;
                }
                return _line_count - 1;
            };

            #region jsDoc
            /// @func   __layout_prepare_widgets__()
            /// @ignore
            /// @desc   Applies widget effects that must be known before alignment:
            ///         - block widgets: increase line height + push following lines down
            ///         - inline widgets: add reserved width to line widths (but do not shift glyph X yet)
            /// @self   WWTextRenderer
            /// @param  {Array} widgets
            /// @returns {Undefined}
            #endregion
            static __layout_prepare_widgets__ = function(_widgets) {
                if (!is_array(_widgets)) { return; }
                var _widget_count = array_length(_widgets);
                if (_widget_count <= 0) { return; }

                var _lines = __layout_lines__;
                var _line_count = __layout_lines_count__;
                if (_line_count <= 0) { return; }

                var _inline_add = array_create(_line_count, 0);
                var _block_target_h = array_create(_line_count, 0);

                // Collect per-line desired changes
                var _wi = 0;
                repeat (_widget_count) {
                    var _w = _widgets[_wi];
                    _wi += 1;
                    if (!is_struct(_w)) { continue; }

                    var _start_index = variable_struct_get(_w, "start_index");
                    if (is_undefined(_start_index)) { continue; }
                    _start_index = real(_start_index);
                    var _line_index = __layout_find_line_for_index__(_start_index);

                    var _kind = (variable_struct_exists(_w, "kind") ? _w.kind : "inline");
                    var _want_w = (variable_struct_exists(_w, "width") ? real(_w.width) : 0);
                    var _want_h = (variable_struct_exists(_w, "height") ? real(_w.height) : 0);

                    var _lb = _line_index * __WW_Layout_Line.__Size__;
                    var _line_h = _lines[_lb + __WW_Layout_Line.Height];

                    if (_kind == "block") {
                        if (_want_h <= 0 && variable_struct_exists(_w, "height_lines")) {
                            var _hl = real(_w.height_lines);
                            if (_hl > 0) { _want_h = _hl * _line_h; }
                        }
                        if (_want_h > _block_target_h[_line_index]) {
                            _block_target_h[_line_index] = _want_h;
                        }
                    } else {
                        if (_want_w > 0) {
                            _inline_add[_line_index] += _want_w;
                        }
                    }
                }

                // Apply inline reserved width to line widths
                var _li = 0;
                repeat (_line_count) {
                    var _lb2 = _li * __WW_Layout_Line.__Size__;
                    _lines[_lb2 + __WW_Layout_Line.Width] = _lines[_lb2 + __WW_Layout_Line.Width] + _inline_add[_li];
                    _li += 1;
                }

                // Apply block line height overrides and y-offset pushes
                var _line_dy = array_create(_line_count, 0);
                var _acc_y = 0;
                _li = 0;
                repeat (_line_count) {
                    _line_dy[_li] = _acc_y;
                    var _lb3 = _li * __WW_Layout_Line.__Size__;
                    _lines[_lb3 + __WW_Layout_Line.Y_Offset] = _lines[_lb3 + __WW_Layout_Line.Y_Offset] + _acc_y;

                    var _old_h = _lines[_lb3 + __WW_Layout_Line.Height];
                    var _target_h = _block_target_h[_li];
                    if (_target_h > _old_h) {
                        _lines[_lb3 + __WW_Layout_Line.Height] = _target_h;
                        _acc_y += (_target_h - _old_h);
                    }

                    _li += 1;
                }

                // Shift glyph Y positions by the line delta
                var _glyphs = __layout_glyphs__;
                var _glyph_count = __layout_glyphs_count__;
                if (_glyph_count > 0) {
                    var _line_cursor = 0;
                    var _line_end = _lines[__WW_Layout_Line.End_Index];
                    var _gi = 0;
                    repeat (_glyph_count) {
                        var _gb = _gi * __WW_Layout_Glyph.__Size__;
                        var _g_index = _glyphs[_gb + __WW_Layout_Glyph.Index];
                        while (_line_cursor < _line_count - 1 && _g_index >= _line_end) {
                            _line_cursor += 1;
                            var _lb4 = _line_cursor * __WW_Layout_Line.__Size__;
                            _line_end = _lines[_lb4 + __WW_Layout_Line.End_Index];
                        }
                        _glyphs[_gb + __WW_Layout_Glyph.Y] = _glyphs[_gb + __WW_Layout_Glyph.Y] + _line_dy[_line_cursor];
                        _gi += 1;
                    }
                }

                // Recompute content bounds from updated line data
                __layout_content_width__ = 0;
                __layout_content_height__ = 0;
                _li = 0;
                repeat (_line_count) {
                    var _lb5 = _li * __WW_Layout_Line.__Size__;
                    var _lw = _lines[_lb5 + __WW_Layout_Line.Width];
                    var _ly = _lines[_lb5 + __WW_Layout_Line.Y_Offset];
                    var _lh2 = _lines[_lb5 + __WW_Layout_Line.Height];
                    if (_lw > __layout_content_width__) { __layout_content_width__ = _lw; }
                    var _bot = _ly + _lh2;
                    if (_bot > __layout_content_height__) { __layout_content_height__ = _bot; }
                    _li += 1;
                }
            };

            #region jsDoc
            /// @func   __layout_apply_inline_widgets_and_build_placements__()
            /// @ignore
            /// @desc   Applies inline widget x-shifts (post-alignment) and builds placements.
            ///         Block widget placements are also emitted here.
            /// @self   WWTextRenderer
            /// @param  {Array} widgets
            /// @returns {Undefined}
            #endregion
            static __layout_apply_inline_widgets_and_build_placements__ = function(_widgets) {
                __layout_widget_placements__ = [];
                if (!is_array(_widgets)) { return; }
                var _widget_count = array_length(_widgets);
                if (_widget_count <= 0) { return; }

                var _lines = __layout_lines__;
                var _line_count = __layout_lines_count__;
                if (_line_count <= 0) { return; }

                var _glyphs = __layout_glyphs__;
                var _glyph_count = __layout_glyphs_count__;
                if (_glyph_count <= 0) {
                    // Still emit block placements if possible
                    var _wi0 = 0;
                    repeat (_widget_count) {
                        var _w0 = _widgets[_wi0];
                        _wi0 += 1;
                        if (!is_struct(_w0)) { continue; }
                        var _kind0 = (variable_struct_exists(_w0, "kind") ? _w0.kind : "inline");
                        if (_kind0 != "block") { continue; }
                        var _si0 = variable_struct_get(_w0, "start_index");
                        if (is_undefined(_si0)) { continue; }
                        var _li0 = __layout_find_line_for_index__(real(_si0));
                        var _lb0 = _li0 * __WW_Layout_Line.__Size__;
                        var _y0 = _lines[_lb0 + __WW_Layout_Line.Y_Offset];
                        var _h0 = (variable_struct_exists(_w0, "height") ? real(_w0.height) : 0);
                        if (_h0 <= 0 && variable_struct_exists(_w0, "height_lines")) {
                            var _hl0 = real(_w0.height_lines);
                            if (_hl0 > 0) { _h0 = _hl0 * _lines[_lb0 + __WW_Layout_Line.Height]; }
                        }
                        if (_h0 <= 0) { _h0 = _lines[_lb0 + __WW_Layout_Line.Height]; }
                        array_push(__layout_widget_placements__, {
                            widget: _w0,
                            widget_index: (_wi0 - 1),
                            kind: "block",
                            start_index: real(_si0),
                            line_index: _li0,
                            x: 0,
                            y: _y0,
                            width: (variable_struct_exists(_w0, "width") ? real(_w0.width) : 0),
                            height: _h0
                        });
                    }
                    return;
                }

                // Build per-line widget buckets
                var _inline_by_line = array_create(_line_count);
                var _li1 = 0;
                repeat (_line_count) {
                    _inline_by_line[_li1] = [];
                    _li1 += 1;
                }

                var _wi = 0;
                repeat (_widget_count) {
                    var _w = _widgets[_wi];
                    _wi += 1;
                    if (!is_struct(_w)) { continue; }
                    var _start_index = variable_struct_get(_w, "start_index");
                    if (is_undefined(_start_index)) { continue; }
                    _start_index = real(_start_index);
                    var _line_index = __layout_find_line_for_index__(_start_index);
                    var _kind = (variable_struct_exists(_w, "kind") ? _w.kind : "inline");

                    if (_kind == "block") {
                        var _lb = _line_index * __WW_Layout_Line.__Size__;
                        var _y = _lines[_lb + __WW_Layout_Line.Y_Offset];
                        var _line_h = _lines[_lb + __WW_Layout_Line.Height];
                        var _want_h = (variable_struct_exists(_w, "height") ? real(_w.height) : 0);
                        if (_want_h <= 0 && variable_struct_exists(_w, "height_lines")) {
                            var _hl = real(_w.height_lines);
                            if (_hl > 0) { _want_h = _hl * _line_h; }
                        }
                        if (_want_h <= 0) { _want_h = _line_h; }
                        array_push(__layout_widget_placements__, {
                            widget: _w,
                            widget_index: (_wi - 1),
                            kind: "block",
                            start_index: _start_index,
                            line_index: _line_index,
                            x: 0,
                            y: _y,
                            width: (variable_struct_exists(_w, "width") ? real(_w.width) : 0),
                            height: _want_h
                        });
                    } else {
                        array_push(_inline_by_line[_line_index], {
                            widget: _w,
                            widget_index: (_wi - 1),
                            start_index: _start_index,
                            width: (variable_struct_exists(_w, "width") ? real(_w.width) : 0),
                            height: (variable_struct_exists(_w, "height") ? real(_w.height) : 0)
                        });
                    }
                }

                // Compute glyph index ranges per line (single pass)
                var _line_g0 = array_create(_line_count, 0);
                var _line_g1 = array_create(_line_count, 0);
                var _lc = 0;
                var _line_end = _lines[__WW_Layout_Line.End_Index];
                _line_g0[0] = 0;
                var _gi = 0;
                repeat (_glyph_count) {
                    var _gb = _gi * __WW_Layout_Glyph.__Size__;
                    var _g_index = _glyphs[_gb + __WW_Layout_Glyph.Index];
                    while (_lc < _line_count - 1 && _g_index >= _line_end) {
                        _line_g1[_lc] = _gi;
                        _lc += 1;
                        _line_g0[_lc] = _gi;
                        var _lb2 = _lc * __WW_Layout_Line.__Size__;
                        _line_end = _lines[_lb2 + __WW_Layout_Line.End_Index];
                    }
                    _gi += 1;
                }
                _line_g1[_lc] = _glyph_count;
                while (_lc < _line_count - 1) {
                    _lc += 1;
                    _line_g0[_lc] = _glyph_count;
                    _line_g1[_lc] = _glyph_count;
                }

                // Apply inline widgets left-to-right per line
                var _line_index = 0;
                repeat (_line_count) {
                    var _list = _inline_by_line[_line_index];
                    var _n = array_length(_list);
                    if (_n > 1) {
                        // Simple insertion sort by start_index (no closures)
                        var _i = 1;
                        while (_i < _n) {
                            var _key = _list[_i];
                            var _j = _i - 1;
                            while (_j >= 0 && _list[_j].start_index > _key.start_index) {
                                _list[_j + 1] = _list[_j];
                                _j -= 1;
                            }
                            _list[_j + 1] = _key;
                            _i += 1;
                        }
                    }

                    if (_n > 0) {
                        var _g0 = _line_g0[_line_index];
                        var _g1 = _line_g1[_line_index];
                        var _lb3 = _line_index * __WW_Layout_Line.__Size__;
                        var _y_line = _lines[_lb3 + __WW_Layout_Line.Y_Offset];
                        var _line_h = _lines[_lb3 + __WW_Layout_Line.Height];

                        var _k = 0;
                        repeat (_n) {
                            var _it = _list[_k];
                            _k += 1;
                            var _start = _it.start_index;
                            var _w = _it.widget;
                            var _shift = _it.width;
                            if (_shift <= 0) { continue; }

                            // Find first glyph at/after start within this line
                            var _anchor_g = _g1;
                            var _scan = _g0;
                            while (_scan < _g1) {
                                var _gb2 = _scan * __WW_Layout_Glyph.__Size__;
                                var _idx2 = _glyphs[_gb2 + __WW_Layout_Glyph.Index];
                                if (_idx2 >= _start) {
                                    _anchor_g = _scan;
                                    break;
                                }
                                _scan += 1;
                            }

                            var _x = 0;
                            var _y = _y_line;
                            var _gh = _line_h;
                            if (_anchor_g < _g1) {
                                var _gb3 = _anchor_g * __WW_Layout_Glyph.__Size__;
                                _x = _glyphs[_gb3 + __WW_Layout_Glyph.X];
                                _y = _glyphs[_gb3 + __WW_Layout_Glyph.Y];
                                _gh = _glyphs[_gb3 + __WW_Layout_Glyph.Height];
                            }

                            var _ph = _it.height;
                            if (_ph <= 0) { _ph = _gh; }

                            array_push(__layout_widget_placements__, {
                                widget: _w,
                                widget_index: _it.widget_index,
                                kind: "inline",
                                start_index: _start,
                                line_index: _line_index,
                                x: _x,
                                y: _y,
                                width: _shift,
                                height: _ph
                            });

                            // Shift glyphs at/after anchor within this line
                            _scan = _anchor_g;
                            while (_scan < _g1) {
                                var _gb4 = _scan * __WW_Layout_Glyph.__Size__;
                                var _ch = _glyphs[_gb4 + __WW_Layout_Glyph.Char];
                                if (_ch != "\n" && _ch != "\r" && _ch != "") {
                                    _glyphs[_gb4 + __WW_Layout_Glyph.X] = _glyphs[_gb4 + __WW_Layout_Glyph.X] + _shift;
                                }
                                _scan += 1;
                            }
                        }
                    }

                    _line_index += 1;
                }
            };

            #region jsDoc
            /// @func   __layout_build_widget_placements__()
            /// @ignore
            /// @desc   Computes widget placement rectangles from the current layout.
            ///         Placements are in local layout space (same as glyph x/y).
            /// @self   WWTextRenderer
            /// @param  {Array} widgets
            /// @returns {Undefined}
            #endregion
            // (old overlay-only widget placement builder removed; widgets now participate in layout)
			
            #region jsDoc
            /// @func   __layout_reset__()
            /// @ignore
            /// @desc   Resets all layout arrays and sets the active span list.
            /// @self   WWTextRenderer
            /// @param  {Array} spans
            /// @returns {Undefined}
            #endregion
			static __layout_reset__ = function(_spans) {

                __layout_lines__ = [];
                __layout_glyphs__ = [];
                __layout_spans__ = _spans;

                __layout_lines_count__ = 0;
                __layout_glyphs_count__ = 0;

                __layout_content_width__ = 0;
                __layout_content_height__ = 0;

				__layout_widgets__ = [];
				__layout_widget_placements__ = [];
            };

            #region jsDoc
            /// @func   __draw_widgets_debug__()
            /// @ignore
            /// @desc   Draws a simple debug overlay showing widget rectangles.
            /// @self   WWTextRenderer
            /// @returns {Undefined}
            #endregion
            static __draw_widgets_debug__ = function() {
                if (!widget_debug_show) { return; }
                __ensure_layout__();
                var _pl = __layout_widget_placements__;
                if (!is_array(_pl) || array_length(_pl) <= 0) { return; }

                var _pre_col = draw_get_color();
                var _pre_alp = draw_get_alpha();
                draw_set_alpha(0.8);

                var _wcount = array_length(_pl);
                var _i = 0;
                repeat (_wcount) {
                    var _p = _pl[_i];
                    _i += 1;
                    if (is_undefined(_p)) { continue; }

                    var _kind = variable_struct_get(_p, "kind");
                    if (_kind == "block") { draw_set_color(widget_debug_color_block); }
                    else { draw_set_color(widget_debug_color_inline); }

                    var _px = x + variable_struct_get(_p, "x");
                    var _py = y + variable_struct_get(_p, "y");
                    var _pw = variable_struct_get(_p, "width");
                    var _ph = variable_struct_get(_p, "height");
                    if (is_undefined(_pw) || _pw <= 0) {
                        if (!is_undefined(__textbox_parent__)) {
                            _pw = __textbox_parent__.width;
                        } else {
                            _pw = __layout_content_width__;
                        }
                    }
                    if (is_undefined(_ph) || _ph <= 0) {
                        _ph = 12;
                    }

                    draw_rectangle(_px, _py, _px + _pw, _py + _ph, true);
                }

                draw_set_alpha(_pre_alp);
                draw_set_color(_pre_col);
            };

            #region jsDoc
            /// @func   __layout_add_line__()
            /// @ignore
            /// @desc   Appends a line record to the layout storage.
            /// @self   WWTextRenderer
            /// @param  {String} text
            /// @param  {Real} start_ind
            /// @param  {Real} end_ind
            /// @param  {Real} width
            /// @param  {Real} height
            /// @param  {Real} yoff
            /// @param  {Bool} force_wrapped
            /// @param  {Real} alignment
            /// @returns {Real} line_index
            #endregion
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

            #region jsDoc
            /// @func   __layout_add_glyph__()
            /// @ignore
            /// @desc   Appends a glyph record to the layout storage.
            /// @self   WWTextRenderer
            /// @param  {String} char
            /// @param  {Real} index
            /// @param  {Real} x
            /// @param  {Real} y
            /// @param  {Real} width
            /// @param  {Real} height
            /// @param  {Real} span_index
            /// @returns {Real} glyph_index
            #endregion
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

            #region jsDoc
            /// @func   __layout_get_line_x_offset__()
            /// @ignore
            /// @desc   Computes horizontal x-offset for a line based on its alignment and available width.
            /// @self   WWTextRenderer
            /// @param  {Real} line_index
            /// @param  {Real} available_width
            /// @returns {Real}
            #endregion
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

            #region jsDoc
            /// @func   __layout_apply_line_alignment__()
            /// @ignore
            /// @desc   Applies per-line horizontal alignment by shifting glyph x positions.
            /// @self   WWTextRenderer
            /// @param  {Real} available_width
            /// @returns {Undefined}
            #endregion
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

            #region jsDoc
            /// @func   __layout_apply_inline_align_runs__()
            /// @ignore
            /// @desc   Applies alignment segments within lines by shifting glyph ranges.
            /// @self   WWTextRenderer
            /// @param  {Array} align_runs
            /// @param  {Real} available_width
            /// @returns {Undefined}
            #endregion
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

            #region jsDoc
            /// @func   __layout_apply_xoff_range__()
            /// @ignore
            /// @desc   Applies an x offset to glyph positions within a glyph index range.
            /// @self   WWTextRenderer
            /// @param  {Array} glyphs
            /// @param  {Real} glyph_count
            /// @param  {Real} start_ind
            /// @param  {Real} end_ind
            /// @param  {Real} xoff
            /// @returns {Undefined}
            #endregion
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
            /// @func   __build_layout__()
            /// @ignore
            /// @self   WWTextRenderer
            /// @param  {String} str
            /// @param  {Array|Undefined} spans
            /// @returns {Undefined}
            #endregion
            static __build_layout__ = function(_str, _spans=undefined) {
				
                static __empty_arr = [];
				static __layout_in_buff = buffer_create(0, buffer_grow, 1);

                _spans ??= __empty_arr;
				
                __layout_reset__(_spans);

                if (_str == "") {
                    return;
                }
				
				var _t = wwThemeGet();
				var _style = struct_get_chained(_t, "typography", "text_styles", "body");
				var _style_font = (is_struct(_style))
					? ((_style[$ "font_asset"] != undefined) ? _style[$ "font_asset"] : _style[$ "font"])
					: undefined;
				var _style_paint = (is_struct(_style))
					? ((_style[$ "paint"] != undefined) ? _style[$ "paint"] : _style[$ "color"])
					: undefined;
				var _font = font ?? _style_font;
				var _color = color ?? (is_struct(_style_paint) ? _style_paint.color : c_white);
				var _alpha = alpha ?? (is_struct(_style_paint) ? _style_paint.alpha : 1);
				
                // Buffer input for fast scanning (UTF-8) + sentinel
                var _byte_len = string_byte_length(_str);
                buffer_resize(__layout_in_buff, _byte_len + 8);
                buffer_seek(__layout_in_buff, buffer_seek_start, 0);
                buffer_write(__layout_in_buff, buffer_text, _str);
                buffer_write(__layout_in_buff, buffer_u64, 0);
                buffer_seek(__layout_in_buff, buffer_seek_start, 0);

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

                var _visual_color = _color;
                var _visual_back_color = undefined;
                var _visual_back_alpha = undefined;
                var _visual_strike = __WW_Text_Glyph_Strike.None;
                var _visual_alpha = _alpha;
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

                    _visual_color = _run.color ?? _color;
                    _visual_alpha = _run.alpha ?? _alpha;
                    _visual_underline = _run.underline ?? __WW_Text_Glyph_Underline.None;

                    _visual_back_color = _run.back_color;
                    _visual_back_alpha = _run.back_alpha;
                    _visual_strike = _run.strike ?? __WW_Text_Glyph_Strike.None;
                }

                // ---------------------------------
                // Font cache for measurement
                // ---------------------------------

                var _old_font = draw_get_font();

                var _active_font = -1;
                var _active_space_width = 0;
                var _active_tab_width = 0;
                var _active_font_height = 1;
				var _active_font_scale = 1;
				
				// Select initial font = renderer font
                if (font_exists(_font)) {
                    draw_set_font(_font);
                    _active_font = _font;
                } else {
                    _active_font = draw_get_font();
                }

				var _active_font_data0 = __font_get_render_data__(_active_font);
                if (_active_font_data0 != undefined) {
                    _active_font_scale = _active_font_data0.size_mul_default;
                }
                else {
                    _active_font_scale = 1;
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
                var _byte_pos = 0;
                var _line_start_byte = 0;
                var _last_break_byte_end = -1;

                while (_byte_pos < _byte_len) {

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
                        var _active_font_data1 = __font_get_render_data__(_active_font);
                        if (_active_font_data1 != undefined) {
                            _active_font_scale = _active_font_data1.size_mul_default;
                        }
                        else {
                            _active_font_scale = 1;
                        }
                        
				        if (_active_font_height <= 0) {
				            _active_font_height = 1;
				        }
				    }


                    // Read one UTF-8 codepoint from buffer (forward-only)
                    var _char_byte_start = _byte_pos;
                    var _b0 = buffer_read(__layout_in_buff, buffer_u8);
                    _byte_pos += 1;

                    var _cp = _b0;
                    if ((_b0 & $80) != 0) {
                        // 2-byte: 110xxxxx 10xxxxxx
                        if ((_b0 & $E0) == $C0) {
                            var _b1 = (_byte_pos < _byte_len) ? buffer_read(__layout_in_buff, buffer_u8) : 0;
                            _byte_pos += 1;
                            _cp = ((_b0 & $1F) << 6) | (_b1 & $3F);
                        }
                        // 3-byte: 1110xxxx 10xxxxxx 10xxxxxx
                        else if ((_b0 & $F0) == $E0) {
                            var _b2 = (_byte_pos < _byte_len) ? buffer_read(__layout_in_buff, buffer_u8) : 0;
                            _byte_pos += 1;
                            var _b3 = (_byte_pos < _byte_len) ? buffer_read(__layout_in_buff, buffer_u8) : 0;
                            _byte_pos += 1;
                            _cp = ((_b0 & $0F) << 12) | ((_b2 & $3F) << 6) | (_b3 & $3F);
                        }
                        // 4-byte: 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
                        else if ((_b0 & $F8) == $F0) {
                            var _b4 = (_byte_pos < _byte_len) ? buffer_read(__layout_in_buff, buffer_u8) : 0;
                            _byte_pos += 1;
                            var _b5 = (_byte_pos < _byte_len) ? buffer_read(__layout_in_buff, buffer_u8) : 0;
                            _byte_pos += 1;
                            var _b6 = (_byte_pos < _byte_len) ? buffer_read(__layout_in_buff, buffer_u8) : 0;
                            _byte_pos += 1;
                            _cp = ((_b0 & $07) << 18) | ((_b4 & $3F) << 12) | ((_b5 & $3F) << 6) | (_b6 & $3F);
                        }
                    }

                    var _char_byte_end = _byte_pos;

                    // Explicit newlines break lines, include newline glyph in segment.
                    if (_cp == 10 || _cp == 13) {

				        array_push(_line_segments, {
				            start_index: _line_start_index,
				            end_index: _logical_index + 1,
                            start_byte: _line_start_byte,
                            end_byte: _char_byte_end,
                            text_end_byte: _char_byte_start,
				            force_wrapped: false
				        });

				        _line_start_index = _logical_index + 1;
                        _line_start_byte = _char_byte_end;
				        _line_width = 0;
				        _line_height = 0;

				        _last_break_pos = -1;
                        _last_break_byte_end = -1;
				        _width_since_break = 0;
				        _height_since_break = 0;

				        _metric_remaining -= 1;
				        _visual_remaining -= 1;
				        _logical_index += 1;
				        continue;
				    }

                    // Measure advance in "layout units" (scaled width)
                    var _metric_size_mul_eff = _metric_size_mul * _active_font_scale;
                    if (_metric_size_mul_eff <= 0) { _metric_size_mul_eff = 1; }
                    var _advance = 0;

                    if (_cp == 9) {

                        var _tab_w_scaled = _active_tab_width * _metric_size_mul_eff;
                        if (_tab_w_scaled <= 0) { _tab_w_scaled = 1; }

                        if (tab_use_stops) {
                            var _next_stop = ceil((_line_width + 0.001) / _tab_w_scaled) * _tab_w_scaled;
                            _advance = _next_stop - _line_width;
                        } else {
                            _advance = _tab_w_scaled;
                        }

                    } else if (_cp == 32) {

                        _advance = _active_space_width * _metric_size_mul_eff;

				    } else {
                        var _char_val = chr(_cp);
                        _advance = string_width(_char_val) * _metric_size_mul_eff;
				    }

                    var _char_height = _active_font_height * _metric_size_mul_eff;
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
                                start_byte: _line_start_byte,
                                end_byte: _last_break_byte_end,
                                text_end_byte: _last_break_byte_end,
				                force_wrapped: true
				            });

				            // New line begins after break char.
				            _line_start_index = _last_break_pos + 1;
                            _line_start_byte = _last_break_byte_end;

				            // Current char becomes the first char on the new line.
				            _line_width = _width_since_break + _advance;

				            var _new_height = _height_since_break;
				            if (_char_height > _new_height) {
				                _new_height = _char_height;
				            }
				            _line_height = _new_height;

				            // No valid break recorded within this new line yet.
				            _last_break_pos = -1;
                            _last_break_byte_end = -1;

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
                                start_byte: _line_start_byte,
                                end_byte: _char_byte_start,
                                text_end_byte: _char_byte_start,
				                force_wrapped: true
				            });

				            _line_start_index = _logical_index;
                            _line_start_byte = _char_byte_start;
				            _line_width = 0;
				            _line_height = 0;

				            _last_break_pos = -1;
                            _last_break_byte_end = -1;
				            _width_since_break = 0;
				            _height_since_break = 0;

                            // Now fall through and commit this char to the new line.
				        }
				    }

				    // Commit the char to the current line
				    _line_width += _advance;

                    // Break opportunities: record last break pos and reset remainder accumulators
                    if (_cp == 32 || _cp == 9) {

				        _last_break_pos = _logical_index;
                        _last_break_byte_end = _char_byte_end;

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
                if (_line_start_index <= _logical_index) {
				    array_push(_line_segments, {
				        start_index: _line_start_index,
                        end_index: _logical_index,
                        start_byte: _line_start_byte,
                        end_byte: _byte_len,
                        text_end_byte: _byte_len,
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
					var _seg_start_byte = _seg.start_byte;
					var _seg_end_byte = _seg.end_byte;
					var _seg_text_end_byte = _seg.text_end_byte;

                    var _cursor_x = 0;
                    var _max_height = 0;

                    // Emit each logical char in this segment
                    var _emit_pos = _seg_start;
					buffer_seek(__layout_in_buff, buffer_seek_start, _seg_start_byte);
					var _emit_byte_pos = _seg_start_byte;

                    while (_emit_pos < _seg_end && _emit_byte_pos < _seg_end_byte) {

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

                        var _want_font2 = _font;
                        if (!is_undefined(_metric_font_override) && _metric_font_override != -1) {
                            _want_font2 = _metric_font_override;
                        }

                        if (_want_font2 != _active_font && font_exists(_want_font2)) {
                            draw_set_font(_want_font2);
                            _active_font = _want_font2;
                            _active_space_width = string_width(" ");
                            _active_tab_width = _active_space_width * tab_size_spaces;
                            _active_font_height = string_height("A");

							var _active_font_data2 = __font_get_render_data__(_active_font);
							if (_active_font_data2 != undefined) {
							    _active_font_scale = _active_font_data2.size_mul_default;
							}
                            else {
							    _active_font_scale = 1;
							}

                            if (_active_font_height <= 0) {
                                _active_font_height = 1;
                            }
                        }

                        // Decode next UTF-8 codepoint for emission
                        var _b0e = buffer_read(__layout_in_buff, buffer_u8);
                        _emit_byte_pos += 1;

                        var _cpe = _b0e;
                        if ((_b0e & $80) != 0) {
                            if ((_b0e & $E0) == $C0) {
                                var _b1e = (_emit_byte_pos < _seg_end_byte) ? buffer_read(__layout_in_buff, buffer_u8) : 0;
                                _emit_byte_pos += 1;
                                _cpe = ((_b0e & $1F) << 6) | (_b1e & $3F);
                            }
                            else if ((_b0e & $F0) == $E0) {
                                var _b2e = (_emit_byte_pos < _seg_end_byte) ? buffer_read(__layout_in_buff, buffer_u8) : 0;
                                _emit_byte_pos += 1;
                                var _b3e = (_emit_byte_pos < _seg_end_byte) ? buffer_read(__layout_in_buff, buffer_u8) : 0;
                                _emit_byte_pos += 1;
                                _cpe = ((_b0e & $0F) << 12) | ((_b2e & $3F) << 6) | (_b3e & $3F);
                            }
                            else if ((_b0e & $F8) == $F0) {
                                var _b4e = (_emit_byte_pos < _seg_end_byte) ? buffer_read(__layout_in_buff, buffer_u8) : 0;
                                _emit_byte_pos += 1;
                                var _b5e = (_emit_byte_pos < _seg_end_byte) ? buffer_read(__layout_in_buff, buffer_u8) : 0;
                                _emit_byte_pos += 1;
                                var _b6e = (_emit_byte_pos < _seg_end_byte) ? buffer_read(__layout_in_buff, buffer_u8) : 0;
                                _emit_byte_pos += 1;
                                _cpe = ((_b0e & $07) << 18) | ((_b4e & $3F) << 12) | ((_b5e & $3F) << 6) | (_b6e & $3F);
                            }
                        }

                        var _char_emit = chr(_cpe);

                        var _metric_size_mul_eff2 = _metric_size_mul * _active_font_scale;
                        if (_metric_size_mul_eff2 <= 0) { _metric_size_mul_eff2 = 1; }

                        var _base_wid = 0;
                        var _advance_scaled2 = 0;
						if (_cpe == 9) {
                            var _tab_w_scaled2 = _active_tab_width * _metric_size_mul_eff2;
                            if (_tab_w_scaled2 <= 0) { _tab_w_scaled2 = 1; }

                            if (tab_use_stops) {
                                var _next_stop2 = ceil((_cursor_x + 0.001) / _tab_w_scaled2) * _tab_w_scaled2;
                                _advance_scaled2 = _next_stop2 - _cursor_x;
                            } else {
                                _advance_scaled2 = _tab_w_scaled2;
                            }

                            _base_wid = _advance_scaled2 / _metric_size_mul_eff2;
						} else if (_cpe == 32) {
                            _base_wid = _active_space_width;
                            _advance_scaled2 = _base_wid * _metric_size_mul_eff2;
                        } else {
                            _base_wid = string_width(_char_emit);
                            _advance_scaled2 = _base_wid * _metric_size_mul_eff2;
                        }

                        var _base_hei = _active_font_height;

                        var _scaled_hei = _base_hei * _metric_size_mul_eff2;
                        if (_scaled_hei > _max_height) {
                            _max_height = _scaled_hei;
                        }

                        var _span_index = _visual_run_index;

                        __layout_add_glyph__(
                            _char_emit,
                            _emit_index,
                            _cursor_x,
                            _current_y,
                            _advance_scaled2,
                            _scaled_hei,
                            _span_index
                        );

                        _cursor_x += _advance_scaled2;

                        _metric_remaining -= 1;
                        _visual_remaining -= 1;

                        _emit_index += 1;
                        _emit_pos += 1;
                    }

					// Line text for storage: use byte range and exclude trailing newline if present
					var _line_text = "";
					if (_seg_text_end_byte > _seg_start_byte) {
						_line_text = regex__buffer_read_text_range(__layout_in_buff, _seg_start_byte, _seg_text_end_byte);
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

				buffer_resize(__layout_in_buff, 0);
            };
			
        #endregion

        #region Font render data

            #region jsDoc
            /// @func   __font_get_render_data__()
            /// @ignore
            /// @desc   Fetches and caches render data for a font asset (texture, uvs, glyphs, SDF settings).
            /// @self   WWTextRenderer
            /// @param  {Asset.GMFont} font_asset
            /// @returns {Struct|Undefined}
            #endregion
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

                // Optional per-font default scale via asset tag: font_size:<value>
                // Example: font_size:2 => render at 1/2 scale (atlas is 2x)
                var _size_mul_default = 1;
                var _tags = asset_get_tags(_font_asset);
                var _ti = 0;
                repeat (array_length(_tags)) {
                    var _tag_text = _tags[_ti];
                    _ti += 1;
                    if (string_pos("font_size:", _tag_text) == 1) {
                        // "font_size:" is 10 characters
                        var _value_text = string_delete(_tag_text, 1, 10);
                        var _v = real(_value_text);
                        if (_v > 0) {
                            _size_mul_default = 1 / _v;
                        }
                        break;
                    }
                }
                
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
                    sdf_shader: _sdf_shader,
                    size_mul_default: _size_mul_default
			    };

			    __font_cache__[$ _font_asset] = _render_data;
			    return _render_data;
			};
			
            #region jsDoc
            /// @func   __glyph_resolve_font_data__()
            /// @ignore
            /// @desc   Resolves font render data for a given glyph, trying requested font then fallbacks.
            /// @self   WWTextRenderer
            /// @param  {Asset.GMFont} font_asset
            /// @param  {String} char
            /// @param  {Struct|Undefined} default_font_data
            /// @returns {Struct|Undefined}
            #endregion
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
            /// @ignore
			/// @desc   Creates a complete default text state from the renderer's current settings.
            /// @self   WWTextRenderer
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
            /// @ignore
			/// @desc   Clones a complete text state struct (all expected keys must exist).
            /// @self   WWTextRenderer
            /// @param  {Struct} state
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

            #region jsDoc
            /// @func   __text_state_equals_span__()
            /// @ignore
            /// @desc   Returns true if two complete text states are span-equivalent (ignores alignment keys).
            /// @self   WWTextRenderer
            /// @param  {Struct} state_a
            /// @param  {Struct} state_b
            /// @returns {Bool}
            #endregion
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

            #region jsDoc
            /// @func   __text_state_equals_align__()
            /// @ignore
            /// @desc   Returns true if two complete text states are alignment-equivalent.
            /// @self   WWTextRenderer
            /// @param  {Struct} state_a
            /// @param  {Struct} state_b
            /// @returns {Bool}
            #endregion
            static __text_state_equals_align__ = function(_state_a, _state_b) {
				return (_state_a.align_value == _state_b.align_value);
			};
				
			#region jsDoc
			/// @func   __text_state_apply_patch__()
            /// @ignore
			/// @desc   Applies a partial patch struct to an existing complete text state.
            ///         Only keys present in patch are applied.
            /// @self   WWTextRenderer
            /// @param  {Struct} state
            /// @param  {Struct} patch
            /// @returns {Undefined}
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
            /// @ignore
			/// @desc   Clones a complete text state then applies a patch.
            /// @self   WWTextRenderer
            /// @param  {Struct} state
            /// @param  {Struct} patch
			/// @returns {Struct}
			#endregion
			static __text_state_clone_patch__ = function(_state, _patch) {
				var _result = __text_state_clone__(_state);
				__text_state_apply_patch__(_result, _patch);
				return _result;
			};

			#region jsDoc
			/// @func   __text_span_run_from_state__()
            /// @ignore
			/// @desc   Converts a complete text state into a layout span run.
            /// @self   WWTextRenderer
            /// @param  {Real} start_index
            /// @param  {Real} end_index
            /// @param  {Struct} state
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
				
            #region jsDoc
            /// @func   __text_align_run_from_state__()
            /// @ignore
            /// @desc   Converts a complete text state into an alignment run.
            /// @self   WWTextRenderer
            /// @param  {Real} start_index
            /// @param  {Real} end_index
            /// @param  {Struct} state
            /// @returns {Struct}
            #endregion
            static __text_align_run_from_state__ = function(_start_index, _end_index, _state) {
				return {
				    start_index: _start_index,
                end_index: _end_index,
				    align_value: _state.align_value
				};
			};
				
		#endregion
        
        #region VB emit styled glyph

            #region jsDoc
            /// @func   __vb_emit_glyph_styled_to_buffer__()
            /// @ignore
            /// @desc   Emits a single glyph quad (with optional bold/italic styling) into the given vertex buffer.
            /// @self   WWTextRenderer
            /// @param  {Id.VertexBuffer} vb_buffer
            /// @param  {Struct} font_data
            /// @param  {String} char
            /// @param  {Real} pos_x
            /// @param  {Real} pos_y
            /// @param  {Constant.Color} col
            /// @param  {Real} alp
            /// @param  {Real} size_mul
            /// @param  {Real} style
            /// @returns {Bool}
            #endregion
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

                // Fast emission culling: if we have a cached clip rect, skip emitting quads outside it.
                // NOTE: This uses local glyph coordinates; the clip is also stored in local coords.
                var _clip = __vb_emit_clip__;
                if (vb_cull_emits_to_scissor && !is_undefined(_clip)) {
                    var _min_slant = min(_slant_top, _slant_bottom);
                    var _max_slant = max(_slant_top, _slant_bottom);

                    // Bold does a second pass with a small +X offset.
                    var _bold_off = 0;
                    if (_bold) {
                        _bold_off = max(1, ceil(_size_mul));
                    }

                    var _cx0 = _x0 + _min_slant;
                    var _cx1 = _x1 + _max_slant + _bold_off;
                    var _cy0 = _y0;
                    var _cy1 = _y1;

                    var _clip_x0 = variable_struct_get(_clip, "x0");
                    var _clip_y0 = variable_struct_get(_clip, "y0");
                    var _clip_x1 = variable_struct_get(_clip, "x1");
                    var _clip_y1 = variable_struct_get(_clip, "y1");

                    if (_cx1 < _clip_x0 || _cx0 > _clip_x1 || _cy1 < _clip_y0 || _cy0 > _clip_y1) {
                        return false;
                    }
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

                return true;
			};

        #endregion

        #region Underline flush span

            #region jsDoc
            /// @func   __ul_flush_span__()
            /// @ignore
            /// @desc   Emits underline geometry for the current underline span state, then deactivates it.
            /// @self   WWTextRenderer
            /// @param  {Struct} span_state
            /// @returns {Undefined}
            #endregion
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

                    var _batch = __vb_get_batch_for_material__(_tex, 0, undefined, 0, __vb_current_chunk_id__);
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

                var _batch = __vb_get_batch_for_material__(_tex, -1, undefined, 0, __vb_current_chunk_id__);
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

            #region jsDoc
            /// @func   __bg_flush_span__()
            /// @ignore
            /// @desc   Emits background geometry for the current background span state, then deactivates it.
            /// @self   WWTextRenderer
            /// @param  {Struct} span_state
            /// @returns {Undefined}
            #endregion
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

                var _batch = __vb_get_batch_for_material__(_tex, -1, undefined, 0, __vb_current_chunk_id__);
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

            #region jsDoc
            /// @func   __st_flush_span__()
            /// @ignore
            /// @desc   Emits strike-through geometry for the current strike span state, then deactivates it.
            /// @self   WWTextRenderer
            /// @param  {Struct} span_state
            /// @returns {Undefined}
            #endregion
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

                    var _batch = __vb_get_batch_for_material__(_tex, 2, undefined, 0, __vb_current_chunk_id__);
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

                var _batch = __vb_get_batch_for_material__(_tex, 2, undefined, 0, __vb_current_chunk_id__);
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

            #region jsDoc
            /// @func   __ensure_vb__()
            /// @ignore
            /// @desc   Ensures VB draw batches exist for the current layout (builds if dirty).
            /// @self   WWTextRenderer
            /// @returns {Undefined}
            #endregion
            static __ensure_vb__ = function() {

                if (!__vb_is_dirty__) {
                    return;
                }

                // Only build once per frame; __draw_text_vb__ is called twice (pre/post).
                if (__vb_built_this_frame__) {
                    return;
                }

                __ensure_layout__();
                __vb_ensure_format__();

                // Full rebuild: layout/content changed or clip mode toggled.
                if (__vb_needs_full_rebuild__) {
                    __vb_free__();
                    __vb_needs_full_rebuild__ = false;
                }

                // Progressive-chunk mode: build everything visible immediately, then leave
                // offscreen/nearby chunks to the normal per-frame progressive queue.
                if (__vb_render_mode__ == 2 && vb_progressive_emit_enabled && vb_cull_emits_to_scissor) {
                    __vb_build_visible_chunks_now__();
                } else {
                    __build_vb__();
                }

                // If we still have queued chunks, stay dirty so next frame builds another.
                if (vb_progressive_emit_enabled && vb_cull_emits_to_scissor) {
                    __vb_is_dirty__ = (array_length(__vb_pending_front__) > 0 || array_length(__vb_pending_chunks__) > 0);
                } else {
                    __vb_is_dirty__ = false;
                }

                __vb_built_this_frame__ = true;
            };

            #region jsDoc
            /// @func   __vb_update_emit_clip_for_draw__()
            /// @ignore
            /// @desc   Updates the VB emission clip/mode based on current GPU scissor and draw origin.
            /// @self   WWTextRenderer
            /// @param  {Real} origin_x
            /// @param  {Real} origin_y
            /// @returns {Undefined}
            #endregion
            static __vb_update_emit_clip_for_draw__ = function(_origin_x, _origin_y) {

                // Small-text fast path: always build full VB.
                __ensure_layout__();
                var _glyph_count_total = __layout_glyphs_count__;
                var _small_thresh = vb_small_text_full_build_glyphs;
                if (is_undefined(_small_thresh) || _small_thresh < 0) { _small_thresh = 2048; }

                var _target_mode = 0;

                // Decide target mode.
                if (_glyph_count_total > _small_thresh && vb_cull_emits_to_scissor) {

                    var _sc = gpu_get_scissor();
                    var _sc_w = is_undefined(_sc) ? undefined : variable_struct_get(_sc, "w");
                    var _sc_h = is_undefined(_sc) ? undefined : variable_struct_get(_sc, "h");

                    if (!is_undefined(_sc) && !is_undefined(_sc_w) && !is_undefined(_sc_h) && _sc_w > 0 && _sc_h > 0) {
                        _target_mode = (vb_progressive_emit_enabled == true) ? 2 : 1;
                    } else {
                        _target_mode = 0;
                    }
                }

                // Handle mode switch (do a full rebuild once).
                if (_target_mode != __vb_render_mode__) {
                    __vb_render_mode__ = _target_mode;
                    __vb_needs_full_rebuild__ = true;
                    __vb_is_dirty__ = true;
                    __vb_force_full_build__ = (_target_mode == 0);

                    __vb_pending_chunks__ = [];
                    __vb_pending_front__ = [];
                    __vb_chunk_built__ = [];
                    __vb_chunk_queued__ = [];
                    __vb_chunk_count__ = 0;
                    __vb_visible_chunk_min__ = 0;
                    __vb_visible_chunk_max__ = -1;
                    __vb_keep_chunk_min__ = 0;
                    __vb_keep_chunk_max__ = -1;
                    __vb_progressive_active__ = false;
                    __vb_last_emit_clip__ = undefined;
                }

                if (_target_mode == 0) {
                    __vb_emit_clip__ = undefined;
                    __vb_progressive_active__ = false;
                    return;
                }

                // At this point we know scissor is valid.
                var _sc = gpu_get_scissor();
                var _sc_w = variable_struct_get(_sc, "w");
                var _sc_h = variable_struct_get(_sc, "h");

                var _m = vb_scissor_margin;
                if (is_undefined(_m) || _m < 0) { _m = 0; }

                // Quantize to integer pixels to avoid clip jitter causing rebuild thrash
                var _ox = floor(_origin_x);
                var _oy = floor(_origin_y);

                // Convert scissor (draw-space) -> renderer-local-space by subtracting draw origin.
                var _sc_x = floor(variable_struct_get(_sc, "x"));
                var _sc_y = floor(variable_struct_get(_sc, "y"));

                var _x0 = floor((_sc_x - _ox) - _m);
                var _y0 = floor((_sc_y - _oy) - _m);
                var _x1 = ceil((_sc_x + _sc_w - _ox) + _m);
                var _y1 = ceil((_sc_y + _sc_h - _oy) + _m);

                var _desired = __vb_desired_emit_clip__;
                if (is_undefined(_desired)) {
                    _desired = { x0: 0, y0: 0, x1: 0, y1: 0 };
                    __vb_desired_emit_clip__ = _desired;
                }
                variable_struct_set(_desired, "x0", _x0);
                variable_struct_set(_desired, "y0", _y0);
                variable_struct_set(_desired, "x1", _x1);
                variable_struct_set(_desired, "y1", _y1);

                // Progressive chunk build scheduling (pixel-based).
                if (__vb_render_mode__ == 2) {

                    var _chunk_h = vb_progressive_chunk_height_px;
                    if (is_undefined(_chunk_h) || _chunk_h <= 0) { _chunk_h = 256; }

                    // Full bounds in local coords
                    var _full_y0 = -_m;
                    var _full_y1 = __layout_content_height__ + _m;

                    var _full_h = max(1, _full_y1 - _full_y0);
                    __vb_chunk_count__ = ceil(_full_h / _chunk_h);
                    if (__vb_chunk_count__ < 1) { __vb_chunk_count__ = 1; }

                    if (array_length(__vb_chunk_built__) != __vb_chunk_count__) {
                        __vb_chunk_built__ = array_create(__vb_chunk_count__, false);
                        __vb_chunk_queued__ = array_create(__vb_chunk_count__, 0);
                        __vb_pending_chunks__ = [];
                        __vb_pending_front__ = [];
                    }

                    // Expand visible min by 1 chunk to account for lines that start in the previous
                    // chunk but extend downward into the visible region.
                    var _vis_chunk_min = floor((_y0 - _full_y0) / _chunk_h) - 1;
                    var _vis_chunk_max = floor((_y1 - _full_y0) / _chunk_h);
                    _vis_chunk_min = clamp(_vis_chunk_min, 0, __vb_chunk_count__ - 1);
                    _vis_chunk_max = clamp(_vis_chunk_max, 0, __vb_chunk_count__ - 1);

                    __vb_visible_chunk_min__ = _vis_chunk_min;
                    __vb_visible_chunk_max__ = _vis_chunk_max;

                    // Keep only a bounded window of chunks near the view.
                    var _radius = vb_progressive_cache_chunk_radius;
                    if (is_undefined(_radius) || _radius < 0) { _radius = 6; }

                    var _keep_min = max(0, _vis_chunk_min - _radius);
                    var _keep_max = min(__vb_chunk_count__ - 1, _vis_chunk_max + _radius);
                    __vb_keep_chunk_min__ = _keep_min;
                    __vb_keep_chunk_max__ = _keep_max;

                    // Evict batches outside keep window (prevents batch breaks from exploding over time).
                    var _b = array_length(__draw_batches__) - 1;
                    while (_b >= 0) {
                        var _batch = __draw_batches__[_b];
                        if (!is_undefined(_batch)) {
                            var _cid = _batch.chunk_id;
                            if (!is_undefined(_cid) && _cid != -1) {
                                if (_cid < _keep_min || _cid > _keep_max) {
                                    if (!is_undefined(_batch.material) && is_callable(_batch.material.destroy)) {
                                        _batch.material.destroy();
                                    }
                                    if (!is_undefined(_batch.buffer)) {
                                        vertex_delete_buffer(_batch.buffer);
                                    }
                                    array_delete(__draw_batches__, _b, 1);
                                }
                            }
                        }
                        _b -= 1;
                    }

                    // Mark evicted chunks as not built (and clear pending that falls outside window).
                    if (array_length(__vb_chunk_built__) == __vb_chunk_count__) {
                        var _i = 0;
                        repeat (__vb_chunk_count__) {
                            if (_i < _keep_min || _i > _keep_max) {
                                __vb_chunk_built__[_i] = false;
                            }
                            _i += 1;
                        }
                    }

                    // Don't physically delete pending entries (which shifts arrays and produces garbage).
                    // Popper will skip out-of-window entries and clear queued flags opportunistically.

                    // Queue visible chunks (so visible area appears ASAP).
                    var _c = _vis_chunk_min;
                    while (_c <= _vis_chunk_max) {
                        if (!__vb_chunk_built__[_c]) {
                            __vb_queue_chunk_unique_front__(_c);
                        }
                        _c += 1;
                    }

                    __vb_progressive_active__ = true;

                    if (array_length(__vb_pending_front__) > 0 || array_length(__vb_pending_chunks__) > 0) {
                        __vb_is_dirty__ = true;
                    }

                    // In chunk mode we don't do per-glyph scissor tests.
                    __vb_emit_clip__ = undefined;
                    __vb_last_emit_clip__ = undefined;
                    return;
                }

                // Non-progressive cull path (legacy): keep current behavior.
                __vb_progressive_active__ = false;

                var _last = __vb_last_emit_clip__;
                if (is_undefined(_last)) {
                    __vb_last_emit_clip__ = _desired;
                    __vb_emit_clip__ = _desired;
                    __vb_is_dirty__ = true;
                    return;
                }

                // If the new desired clip doesn't fit inside the previously emitted region, rebuild.
                var _lx0 = variable_struct_get(_last, "x0");
                var _ly0 = variable_struct_get(_last, "y0");
                var _lx1 = variable_struct_get(_last, "x1");
                var _ly1 = variable_struct_get(_last, "y1");

                if (_x0 < _lx0 || _y0 < _ly0 || _x1 > _lx1 || _y1 > _ly1) {
                    __vb_last_emit_clip__ = _desired;
                    __vb_emit_clip__ = _desired;
                    __vb_is_dirty__ = true;
                } else {
                    // Keep the larger cached region to avoid rebuild thrashing.
                    __vb_emit_clip__ = _last;
                }
            };

            #region jsDoc
            /// @func   __vb_progressive_emit_step__()
            /// @ignore
            /// @desc   Schedules additional offscreen chunks for progressive VB emission.
            /// @self   WWTextRenderer
            /// @returns {Undefined}
            #endregion
            static __vb_progressive_emit_step__ = function() {

                if (!vb_progressive_emit_enabled || !vb_cull_emits_to_scissor) {
                    __vb_progressive_active__ = false;
                    return;
                }

                if (!__vb_progressive_active__) {
                    return;
                }

                // Avoid doing this twice per frame (pre_draw + post_draw)
                var _now_ms = current_time;
                if (_now_ms == __vb_progressive_last_step_ms__) {
                    return;
                }
                __vb_progressive_last_step_ms__ = _now_ms;

                // If a build is already queued, wait until next frame.
                if (__vb_is_dirty__) {
                    return;
                }

                if (__vb_chunk_count__ <= 0 || array_length(__vb_chunk_built__) != __vb_chunk_count__) {
                    __vb_progressive_active__ = false;
                    return;
                }

                var _minc = __vb_visible_chunk_min__;
                var _maxc = __vb_visible_chunk_max__;
                if (_minc < 0) { _minc = 0; }
                if (_maxc < _minc) { _maxc = _minc; }
                if (_maxc >= __vb_chunk_count__) { _maxc = __vb_chunk_count__ - 1; }

                // Expand outward from visible chunk range.
                var _left = _minc - 1;
                var _right = _maxc + 1;

                var _keep_min = __vb_keep_chunk_min__;
                var _keep_max = __vb_keep_chunk_max__;
                if (_keep_max < _keep_min) {
                    _keep_min = 0;
                    _keep_max = __vb_chunk_count__ - 1;
                }

                var _picked = -1;
                while (_left >= _keep_min || _right <= _keep_max) {
                    if (_left >= _keep_min && !__vb_chunk_built__[_left]) { _picked = _left; break; }
                    if (_right <= _keep_max && !__vb_chunk_built__[_right]) { _picked = _right; break; }
                    _left -= 1;
                    _right += 1;
                }

                if (_picked < 0) {
                    __vb_progressive_active__ = false;
                    return;
                }

                __vb_queue_chunk_unique__(_picked);
                __vb_is_dirty__ = true;
            };

            #region jsDoc
            /// @func   __build_vb__()
            /// @ignore
            /// @desc   Builds VB geometry into draw batches (full or chunked depending on mode).
            /// @self   WWTextRenderer
            /// @returns {Undefined}
            #endregion
			static __build_vb__ = function() {
				var _t = wwThemeGet();
				var _style = struct_get_chained(_t, "typography", "text_styles", "body");
				var _style_font = (is_struct(_style))
					? ((_style[$ "font_asset"] != undefined) ? _style[$ "font_asset"] : _style[$ "font"])
					: undefined;
				var _style_paint = (is_struct(_style))
					? ((_style[$ "paint"] != undefined) ? _style[$ "paint"] : _style[$ "color"])
					: undefined;
				var _font = font ?? _style_font;
				var _color = color ?? (is_struct(_style_paint) ? _style_paint.color : c_white);
				var _alpha = alpha ?? (is_struct(_style_paint) ? _style_paint.alpha : 1);

				
			    var _old_font = draw_get_font();
			    if (font_exists(_font)) {
			        draw_set_font(_font);
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

                // Decide between full build vs single-chunk build.
                var _chunk_mode = false;
                var _chunk_id = -1;
                var _glyph_start = 0;
                var _glyph_end = _glyph_count;

                if (__vb_force_full_build__) {
                    _chunk_mode = false;
                    __vb_force_full_build__ = false;
                } else if (vb_progressive_emit_enabled && vb_cull_emits_to_scissor) {
                    if (array_length(__vb_pending_front__) > 0 || array_length(__vb_pending_chunks__) > 0) {
                        _chunk_mode = true;
                    }
                }

                // Safety: If we're in progressive-chunk render mode but nothing is queued yet,
                // force-build a visible chunk rather than returning a blank frame.
                if (__vb_render_mode__ == 2 && !_chunk_mode) {
                    __vb_queue_visible_chunk_now__();
                    _chunk_mode = (array_length(__vb_pending_front__) > 0 || array_length(__vb_pending_chunks__) > 0);
                }

                // IMPORTANT: In progressive-chunk render mode, never fall back to a full build when
                // there is no queued chunk. Doing so causes the whole document to be drawn in addition
                // to already-built chunks (bold/double-draw).
                if (__vb_render_mode__ == 2 && !_chunk_mode) {
                    return;
                }

                if (_chunk_mode) {
                    _chunk_id = __vb_pop_next_pending_chunk__();
                    if (_chunk_id < 0) {
                        return;
                    }

                    // If this chunk is being rebuilt, delete prior batches for this chunk id.
                    __vb_delete_batches_for_chunk__(_chunk_id);

                    __ensure_layout__();
                    var _line_count = __layout_lines_count__;
                    if (_line_count > 0) {
                        var _lines = __layout_lines__;
                        var _lsz = __WW_Layout_Line.__Size__;

                        var _m = vb_scissor_margin;
                        if (is_undefined(_m) || _m < 0) { _m = 0; }

                        var _chunk_h = vb_progressive_chunk_height_px;
                        if (is_undefined(_chunk_h) || _chunk_h <= 0) { _chunk_h = 256; }

                        var _full_y0 = -_m;
                        var _full_y1 = __layout_content_height__ + _m;

                        var _cy0 = _full_y0 + (_chunk_id * _chunk_h);
                        var _cy1 = min(_full_y0 + ((_chunk_id + 1) * _chunk_h), _full_y1);

                        // Non-overlapping chunk assignment: include lines whose TOP (y_offset) is inside
                        // [chunk_y0, chunk_y1). This prevents the same glyphs appearing in multiple chunks.
                        var _y0v = _cy0;
                        var _y1v = _cy1;

                        // min_line = first line with y_offset >= chunk_y0
                        var _lo = 0;
                        var _hi = _line_count - 1;
                        while (_lo < _hi) {
                            var _mid = (_lo + _hi) div 2;
                            var _b = _mid * _lsz;
                            var _yy = _lines[_b + __WW_Layout_Line.Y_Offset];
                            if (_yy < _y0v) {
                                _lo = _mid + 1;
                            } else {
                                _hi = _mid;
                            }
                        }
                        var _min_line = _lo;

                        // max_line = last line with y_offset < chunk_y1
                        _lo = 0;
                        _hi = _line_count - 1;
                        while (_lo < _hi) {
                            var _mid2 = (_lo + _hi + 1) div 2;
                            var _b2 = _mid2 * _lsz;
                            var _yy2 = _lines[_b2 + __WW_Layout_Line.Y_Offset];
                            if (_yy2 >= _y1v) {
                                _hi = _mid2 - 1;
                            } else {
                                _lo = _mid2;
                            }
                        }
                        var _max_line = _lo;

                        _min_line = clamp(_min_line, 0, _line_count - 1);
                        _max_line = clamp(_max_line, 0, _line_count - 1);

                        // If this chunk contains no line tops, build nothing.
                        var _b_min = _min_line * _lsz;
                        var _y_min = _lines[_b_min + __WW_Layout_Line.Y_Offset];
                        if (_y_min < _y0v || _y_min >= _y1v) {
                            _glyph_start = 0;
                            _glyph_end = 0;
                        } else {
                            var _b0 = _min_line * _lsz;
                            var _b1 = _max_line * _lsz;
                            _glyph_start = _lines[_b0 + __WW_Layout_Line.Start_Index];
                            _glyph_end = _lines[_b1 + __WW_Layout_Line.End_Index];
                        }

                        var _bnd = __vb_current_chunk_bounds__;
                        if (!is_struct(_bnd)) {
                            _bnd = { x0: 0, y0: 0, x1: 0, y1: 0 };
                            __vb_current_chunk_bounds__ = _bnd;
                        }
                        variable_struct_set(_bnd, "x0", 0);
                        variable_struct_set(_bnd, "y0", _cy0);
                        variable_struct_set(_bnd, "x1", __layout_content_width__);
                        variable_struct_set(_bnd, "y1", _cy1);
                        __vb_current_chunk_bounds__ = _bnd;
                    } else {
                        _chunk_mode = false;
                        _chunk_id = -1;
                    }
                }

                // Scissor-clip build: restrict to visible line range (cuts Y collision checks).
                if (!_chunk_mode && __vb_render_mode__ == 1 && !is_undefined(__vb_emit_clip__)) {
                    __ensure_layout__();
                    var _line_count2 = __layout_lines_count__;
                    if (_line_count2 > 0) {
                        var _lines2 = __layout_lines__;
                        var _lsz2 = __WW_Layout_Line.__Size__;

                        var _clip = __vb_emit_clip__;
                        var _y0c = variable_struct_get(_clip, "y0");
                        var _y1c = variable_struct_get(_clip, "y1");

                        var _lo2 = 0;
                        var _hi2 = _line_count2 - 1;
                        while (_lo2 < _hi2) {
                            var _mid3 = (_lo2 + _hi2) div 2;
                            var _b3 = _mid3 * _lsz2;
                            var _yy3 = _lines2[_b3 + __WW_Layout_Line.Y_Offset];
                            var _hh3 = _lines2[_b3 + __WW_Layout_Line.Height];
                            if (_yy3 + _hh3 < _y0c) {
                                _lo2 = _mid3 + 1;
                            } else {
                                _hi2 = _mid3;
                            }
                        }
                        var _min_line2 = _lo2;

                        _lo2 = 0;
                        _hi2 = _line_count2 - 1;
                        while (_lo2 < _hi2) {
                            var _mid4 = (_lo2 + _hi2 + 1) div 2;
                            var _b4 = _mid4 * _lsz2;
                            var _yy4 = _lines2[_b4 + __WW_Layout_Line.Y_Offset];
                            if (_yy4 > _y1c) {
                                _hi2 = _mid4 - 1;
                            } else {
                                _lo2 = _mid4;
                            }
                        }
                        var _max_line2 = _lo2;

                        _min_line2 = clamp(_min_line2, 0, _line_count2 - 1);
                        _max_line2 = clamp(_max_line2, 0, _line_count2 - 1);

                        var _bb0 = _min_line2 * _lsz2;
                        var _bb1 = _max_line2 * _lsz2;
                        _glyph_start = _lines2[_bb0 + __WW_Layout_Line.Start_Index];
                        _glyph_end = _lines2[_bb1 + __WW_Layout_Line.End_Index];
                    }
                }

                __vb_current_chunk_id__ = _chunk_id;
                __vb_open_buffers__ = [];

                var _saved_emit_clip = __vb_emit_clip__;
                if (_chunk_mode) {
                    // Chunk selection already culls, avoid per-glyph clip checks.
                    __vb_emit_clip__ = undefined;
                }

			    var _default_font_data = __font_get_render_data__(_font);
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

                var _ws_marker_scale = 1;
			    var _ws_space_width = 0;
			    if (_use_whitespace) {
                    _ws_marker_scale = _default_font_data.size_mul_default;
                    if (is_undefined(_ws_marker_scale) || _ws_marker_scale <= 0) { _ws_marker_scale = 1; }
                    _ws_space_width = string_width(_ws_space_marker) * _ws_marker_scale;
			    }

			    var _ws_batch_buffer = -1;
			    if (_use_whitespace) {
                    var _ws_shader = _default_font_data.sdf_shader;
                    if (is_undefined(_ws_shader) || _ws_shader == -1) { _ws_shader = -1; }
                    var _ws_spread = _default_font_data.sdf_spread;
                    if (is_undefined(_ws_spread)) { _ws_spread = 0; }

                    var _ws_batch = __vb_get_batch_for_material__(
			            _default_font_data.tex,
			            1,
                        _ws_shader,
                        _ws_spread,
                        __vb_current_chunk_id__
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

                // Debug counters reflect the last build segment.
                __vb_dbg_last_total_glyphs__ = max(0, _glyph_end - _glyph_start);
                __vb_dbg_last_emitted_glyphs__ = 0;

                var _last_tex = -1;
                var _last_shader = -1;
                var _last_spread = 0;
			    var _last_batch_buffer = -1;

			    var _emit_glyph = __vb_emit_glyph_styled_to_buffer__;

                var _build_count = max(0, _glyph_end - _glyph_start);
                var _glyph_index = _glyph_start;
                repeat (_build_count) {

			        var _base = _glyph_index * __WW_Layout_Glyph.__Size__;

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
			        var _final_font = _font;
			        var _final_style = __WW_Text_Glyph_Style.Regular;
			        var _final_size = 1;
					
			        var _final_under = __WW_Text_Glyph_Underline.None;
			        var _final_strike = __WW_Text_Glyph_Strike.None;
					
			        var _final_back_col = _color;
			        var _final_back_alp = _alpha;

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

                    // Apply per-font default scale (font_size:<value>) to the span's size multiplier.
                    var _span_font_scale = 1;
                    var _span_font_data = __font_get_render_data__(_final_font);
                    if (!is_undefined(_span_font_data)) {
                        _span_font_scale = _span_font_data.size_mul_default;
                        if (is_undefined(_span_font_scale) || _span_font_scale <= 0) { _span_font_scale = 1; }
                    }
                    var _final_size_scaled = _final_size * _span_font_scale;
                    if (_final_size_scaled <= 0) { _final_size_scaled = 1; }
                    
			        if (_use_whitespace) {

			            if (_char == " ") {

                            // Layout glyph width is already in final scaled pixels.
                            var _cell_w = _wid;

			                var _mark_x = _pos_x;
			                if (_cell_w > 0 && _ws_space_width > 0) {
			                    _mark_x = _pos_x + ((_cell_w - _ws_space_width) * 0.5);
			                }

                            var _did_emit_ws = _emit_glyph(
			                    _ws_batch_buffer,
			                    _default_font_data,
			                    _ws_space_marker,
			                    _mark_x,
			                    _pos_y,
			                    whitespace_color,
			                    whitespace_alpha,
                                _ws_marker_scale,
			                    __WW_Text_Glyph_Style.Regular
                            );

                            if (_did_emit_ws) {
                                __vb_dbg_last_emitted_glyphs__ += 1;
                            }

			                _glyph_index += 1;
			                continue;
			            }

			            if (_char == "\t") {

                            var _did_emit_ws2 = _emit_glyph(
			                    _ws_batch_buffer,
			                    _default_font_data,
			                    _ws_tab_marker,
			                    _pos_x,
			                    _pos_y,
			                    whitespace_color,
			                    whitespace_alpha,
                                _ws_marker_scale,
			                    __WW_Text_Glyph_Style.Regular
                            );

                            if (_did_emit_ws2) {
                                __vb_dbg_last_emitted_glyphs__ += 1;
                            }

			                _glyph_index += 1;
			                continue;
			            }
			        }
			        if (_final_back_alp > 0) {

			            var _bg_x0 = _pos_x;
                            var _bg_x1 = _pos_x + _wid;
			            var _bg_y0 = _pos_y;
                            var _bg_y1 = _pos_y + _hei;

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
			        var _need_batch = true;

                    var _shader_key = _font_data.sdf_shader;
                    if (is_undefined(_shader_key) || _shader_key == -1) { _shader_key = -1; }
                    var _spread_key = _font_data.sdf_spread;
                    if (is_undefined(_spread_key)) { _spread_key = 0; }

			        if (_font_data.tex == _last_tex &&
                        _shader_key == _last_shader &&
                        _spread_key == _last_spread) {
			            _need_batch = false;
			        }
			        if (_need_batch) {

                        var _glyph_batch = __vb_get_batch_for_material__(
			                _font_data.tex,
			                1,
                            _shader_key,
                            _spread_key,
                            __vb_current_chunk_id__
			            );

			            _last_tex = _font_data.tex;
                        _last_shader = _shader_key;
                        _last_spread = _spread_key;
			            _last_batch_buffer = _glyph_batch.buffer;
			        }
                    var _did_emit = _emit_glyph(
			            _last_batch_buffer,
			            _font_data,
			            _char,
			            _pos_x,
			            _pos_y,
			            _final_color,
			            _final_alpha,
                        _final_size_scaled,
			            _final_style
			        );

                    if (_did_emit) {
                        __vb_dbg_last_emitted_glyphs__ += 1;
                    }
			        if (_final_under != __WW_Text_Glyph_Underline.None) {

                            var _underline_y = _pos_y + _hei + underline_y_offset;

			            if (!_ul_span_state.active) {

			                _ul_span_state.active = true;
			                _ul_span_state.under = _final_under;
			                _ul_span_state.x0 = _pos_x;
                                    _ul_span_state.x1 = _pos_x + _wid;
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
                                        _ul_span_state.x1 = _pos_x + _wid;
			                    _ul_span_state.y = _underline_y;
			                    _ul_span_state.col = _final_color;
			                    _ul_span_state.alp = _final_alpha;

			                } else {

                                        _ul_span_state.x1 = _pos_x + _wid;
			                }
			            }

			        } else {

			            __ul_flush_span__(_ul_span_state);
			        }
			        if (_final_strike != __WW_Text_Glyph_Strike.None) {

                            var _strike_y = _pos_y + floor(_hei * 0.5) + strike_y_offset;

			            if (!_st_span_state.active) {

			                _st_span_state.active = true;
			                _st_span_state.kind = _final_strike;
			                _st_span_state.x0 = _pos_x;
                                    _st_span_state.x1 = _pos_x + _wid;
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
                                        _st_span_state.x1 = _pos_x + _wid;
			                    _st_span_state.y = _strike_y;
			                    _st_span_state.col = _final_color;
			                    _st_span_state.alp = _final_alpha;

			                } else {

                                        _st_span_state.x1 = _pos_x + _wid;
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


                // End only the buffers created in this build.
                var _buf_count = array_length(__vb_open_buffers__);
                var _bi = 0;
                repeat (_buf_count) {
                    vertex_end(__vb_open_buffers__[_bi]);
                    _bi += 1;
                }
                __vb_open_buffers__ = [];

                if (_chunk_mode && _chunk_id >= 0 && _chunk_id < __vb_chunk_count__) {
                    __vb_chunk_built__[_chunk_id] = true;
                }

                __vb_emit_clip__ = _saved_emit_clip;
                __vb_current_chunk_id__ = -1;

			    if (font_exists(_old_font) && _old_font != draw_get_font()) {
			        draw_set_font(_old_font);
			    }
			};

            #region jsDoc
            /// @func   __draw_selection_highlight__()
            /// @ignore
            /// @desc   Draws selection highlights for the bound textbox cursors (if any).
            /// @self   WWTextRenderer
            /// @returns {Undefined}
            #endregion
            static __draw_selection_highlight__ = function() {

                if (is_undefined(__textbox_parent__)) {
                    return;
                }
				if (!is_struct(__textbox_parent__)) {
					return;
				}

                var _cursors = __textbox_parent__.__cursors__;
                if (is_undefined(_cursors) || array_length(_cursors) <= 0) return;

                __ensure_layout__();

                var _pre_color = draw_get_color();
                var _pre_alpha = draw_get_alpha();

                var _hl = __textbox_parent__.__highlight_color__;
                if (is_undefined(_hl)) _hl = c_aqua;

                draw_set_color(_hl);
                draw_set_alpha(1);

                var _ci = 0;
                var _cn = array_length(_cursors);
                repeat (_cn) {
                    var _c = _cursors[_ci];
                    if (!is_undefined(_c) && _c.highlight_active) {
                        var _start_index = _c.highlight_start_index;
                        var _end_index = _c.highlight_end_index;
                        if (_start_index != _end_index) {
                            var _sel_start = min(_start_index, _end_index);
                            var _sel_end = max(_start_index, _end_index);
                            var _start_line = get_line_from_index(_sel_start);
                            var _end_line = get_line_from_index(_sel_end);
                            var _line_index = _start_line;
                            repeat ((_end_line - _start_line) + 1) {
                                var _line_y = get_line_y_offset(_line_index);
                                var _line_h = get_line_height(_line_index) - 1;
                                if (_line_h < 1) { _line_h = 1; }

                                var _line_w = get_line_width(_line_index);
                                if (_line_w < 0) { _line_w = 0; }

                                // Use the same absolute x coordinate space as glyph rendering.
                                var _ls = get_line_index_start(_line_index);
                                var _le = get_line_index_end(_line_index);
                                var _line_x0 = __layout_get_line_x_min__(_line_index);

                                var _range_start = _line_x0;
                                var _range_end = _line_x0 + _line_w;

                                if (_line_index == _start_line) {
                                    // If selection starts at the line boundary, keep full-line start (incl. widgets).
                                    if (_sel_start > _ls) {
                                        _range_start = get_x_from_index(_sel_start);
                                    }
                                }
                                if (_line_index == _end_line) {
                                    // If selection ends before the line end, clamp; otherwise keep full-line end.
                                    if (_sel_end < _le) {
                                        _range_end = get_x_from_index(_sel_end);
                                    }
                                }

                                var _draw_w = _range_end - _range_start;
                                if (_draw_w < 0) { _draw_w = 0; }
                                if (_draw_w > 0) {
                                    draw_sprite_stretched_ext(spr_ww_pixel, 0, x + _range_start, y + _line_y, _draw_w, _line_h, draw_get_color(), 1);
                                }
                                _line_index += 1;
                            }
                        }
                    }
                    _ci += 1;
                }

                draw_set_alpha(_pre_alpha);
                draw_set_color(_pre_color);
            };

            #region jsDoc
            /// @func   __draw_carets__()
            /// @ignore
            /// @desc   Draws caret(s) for the bound textbox cursors (if any).
            /// @self   WWTextRenderer
            /// @returns {Undefined}
            #endregion
            static __draw_carets__ = function() {
                if (is_undefined(__textbox_parent__)) return;
                if (!is_struct(__textbox_parent__)) return;
                var _cursors = __textbox_parent__.__cursors__;
                if (is_undefined(_cursors) || array_length(_cursors) <= 0) return;
                if (!__textbox_parent__.__cursor_visible__) return;
				
                var _period_ms = __textbox_parent__.__cursor_blink_period_ms__;
                var _show_ms = __textbox_parent__.__cursor_blink_show_ms__;
                var _start_ms = __textbox_parent__.__cursor_blink_start_ms__;
                if (is_undefined(_period_ms) || _period_ms <= 0) {
                    // Always visible when period is invalid.
                }
                else if (is_undefined(_show_ms) || _show_ms <= 0) {
                    return;
                }
                else if (_show_ms >= _period_ms) {
                    // Always visible when show window covers period.
                }
                else {
                    if (is_undefined(_start_ms)) _start_ms = 0;
                    var _t = current_time - _start_ms;
                    if (_t < 0) _t = 0;
                    if ((_t mod _period_ms) >= _show_ms) return;
                }
				
                __ensure_layout__();
				
                var _pre_color = draw_get_color();
                var _pre_alpha = draw_get_alpha();
                var _cc = __textbox_parent__.__cursor_color__;
                if (is_undefined(_cc)) _cc = c_white;
                draw_set_color(_cc);
                draw_set_alpha(1);
				
                var _ci = 0;
                var _cn = array_length(_cursors);
                repeat (_cn) {
                    var _c = _cursors[_ci];
                    if (!is_undefined(_c)) {
                        var _idx = _c.index;
                        var _line = get_line_from_index(_idx);
                        var _cx = get_x_from_index(_idx);
                        var _cy = get_line_y_offset(_line);
                        var _h = get_line_height(_line);
                        if (_h < 1) _h = 1;
                        draw_sprite_stretched_ext(spr_ww_pixel, 0, x + _cx, y + _cy, 1, _h, draw_get_color(), 1);
                    }
                    _ci += 1;
                }
				
                draw_set_alpha(_pre_alpha);
                draw_set_color(_pre_color);
            };
			
            #region jsDoc
            /// @func   __draw_text_vb__()
            /// @ignore
            /// @desc   Submits built VB draw batches, optionally filtering by layer.
            /// @self   WWTextRenderer
            /// @param  {Real} origin_x
            /// @param  {Real} origin_y
            /// @param  {Real|Undefined} layer_min
            /// @param  {Real|Undefined} layer_max
            /// @returns {Undefined}
            #endregion
            static __draw_text_vb__ = function(_origin_x, _origin_y, _layer_min, _layer_max) {

                if (_layer_min < 0) {
                    // Reset per-frame gate on the pre_draw call.
                    __vb_built_this_frame__ = false;
                }

                __vb_update_emit_clip_for_draw__(_origin_x, _origin_y);
                __ensure_vb__();

                // Safety: avoid transient blank frames if something caused the chunk queue to be
                // empty while no batches exist yet (e.g. large view jumps + eviction ordering).
                if (__vb_render_mode__ == 2 && __layout_glyphs_count__ > 0 && array_length(__draw_batches__) <= 0) {
                    __vb_is_dirty__ = true;
                    __vb_built_this_frame__ = false;
                    __vb_build_visible_chunks_now__();
                }

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

                if (vb_debug_show_cull) {
                    var _pre_col = draw_get_color();
                    var _pre_alp = draw_get_alpha();

                    // Draw raw scissor rect in local coords (red)
                    var _sc = gpu_get_scissor();
                    if (!is_undefined(_sc)) {
                        var _sx = variable_struct_get(_sc, "x") - _origin_x;
                        var _sy = variable_struct_get(_sc, "y") - _origin_y;
                        var _sw = variable_struct_get(_sc, "w");
                        var _sh = variable_struct_get(_sc, "h");
                        if (!is_undefined(_sw) && !is_undefined(_sh) && _sw > 0 && _sh > 0) {
                            draw_set_color(vb_debug_cull_color_scissor);
                            draw_set_alpha(0.9);
                            draw_rectangle(_sx, _sy, _sx + _sw, _sy + _sh, true);
                        }
                    }

                    // Desired (aqua) vs cached/emitted (lime)
                    var _desired = __vb_desired_emit_clip__;
                    if (!is_undefined(_desired)) {
                        var _dx0 = variable_struct_get(_desired, "x0");
                        var _dy0 = variable_struct_get(_desired, "y0");
                        var _dx1 = variable_struct_get(_desired, "x1");
                        var _dy1 = variable_struct_get(_desired, "y1");
                        draw_set_color(vb_debug_cull_color_desired);
                        draw_set_alpha(0.7);
                        draw_rectangle(_dx0, _dy0, _dx1, _dy1, true);
                    }

                    var _cached = __vb_last_emit_clip__;
                    if (!is_undefined(_cached)) {
                        var _cx0 = variable_struct_get(_cached, "x0");
                        var _cy0 = variable_struct_get(_cached, "y0");
                        var _cx1 = variable_struct_get(_cached, "x1");
                        var _cy1 = variable_struct_get(_cached, "y1");
                        draw_set_color(vb_debug_cull_color_cached);
                        draw_set_alpha(0.7);
                        draw_rectangle(_cx0, _cy0, _cx1, _cy1, true);
                    }

                    // Chunk boundaries (grid) in local coords, aligned with the same matrix as glyphs.
                    if (vb_debug_show_chunks) {

                        var _chunk_x = vb_progressive_chunk_width_px;
                        if (is_undefined(_chunk_x) || _chunk_x <= 0) { _chunk_x = 512; }

                        var _chunk_y = vb_progressive_chunk_height_px;
                        if (is_undefined(_chunk_y) || _chunk_y <= 0) { _chunk_y = 256; }

                        if (_chunk_x > 0 && _chunk_y > 0) {

                            // Prefer cached bounds (what's actually emitted), fallback to desired.
                            var _bx0 = 0;
                            var _by0 = 0;
                            var _bx1 = __layout_content_width__;
                            var _by1 = __layout_content_height__;

                            if (!is_undefined(_cached)) {
                                _bx0 = variable_struct_get(_cached, "x0");
                                _by0 = variable_struct_get(_cached, "y0");
                                _bx1 = variable_struct_get(_cached, "x1");
                                _by1 = variable_struct_get(_cached, "y1");
                            } else if (!is_undefined(_desired)) {
                                _bx0 = variable_struct_get(_desired, "x0");
                                _by0 = variable_struct_get(_desired, "y0");
                                _bx1 = variable_struct_get(_desired, "x1");
                                _by1 = variable_struct_get(_desired, "y1");
                            }

                            // Snap to grid
                            var _gx0 = floor(_bx0 / _chunk_x) * _chunk_x;
                            var _gy0 = floor(_by0 / _chunk_y) * _chunk_y;
                            var _gx1 = ceil(_bx1 / _chunk_x) * _chunk_x;
                            var _gy1 = ceil(_by1 / _chunk_y) * _chunk_y;

                            draw_set_color(c_yellow);
                            draw_set_alpha(0.25);

                            var _x = _gx0;
                            while (_x <= _gx1) {
                                draw_line(_x, _gy0, _x, _gy1);
                                _x += _chunk_x;
                            }

                            var _y = _gy0;
                            while (_y <= _gy1) {
                                draw_line(_gx0, _y, _gx1, _y);
                                _y += _chunk_y;
                            }
                        }
                    }

                    // Quick numeric proof
                    draw_set_color(c_white);
                    draw_set_alpha(1);
                    var _cx = vb_progressive_chunk_width_px;
                    if (is_undefined(_cx) || _cx <= 0) { _cx = 512; }
                    var _cy = vb_progressive_chunk_height_px;
                    if (is_undefined(_cy) || _cy <= 0) { _cy = 256; }
                    draw_text(4, 4, "VB emit " + string(__vb_dbg_last_emitted_glyphs__) + "/" + string(__vb_dbg_last_total_glyphs__) + " | chunk " + string(_cx) + "x" + string(_cy));

                    if (vb_debug_show_progressive) {

                        var _queue_len = 0;
                        if (!is_undefined(__vb_pending_front__)) { _queue_len += array_length(__vb_pending_front__); }
                        if (!is_undefined(__vb_pending_chunks__)) { _queue_len += array_length(__vb_pending_chunks__); }
                        var _batches = array_length(__draw_batches__);

                        var _chunk_h = vb_progressive_chunk_height_px;
                        if (is_undefined(_chunk_h) || _chunk_h <= 0) { _chunk_h = 256; }

                        var _m = vb_scissor_margin;
                        if (is_undefined(_m) || _m < 0) { _m = 0; }

                        var _total_chunks = __vb_chunk_count__;
                        if (is_undefined(_total_chunks) || _total_chunks <= 0) {
                            _total_chunks = ceil((__layout_content_height__ + (_m * 2)) / _chunk_h);
                        }
                        if (is_undefined(_total_chunks) || _total_chunks < 0) { _total_chunks = 0; }

                        var _built_total = 0;
                        var _built_keep = 0;
                        var _keep_min = __vb_keep_chunk_min__;
                        var _keep_max = __vb_keep_chunk_max__;
                        var _keep_span = 0;
                        if (!is_undefined(_keep_min) && !is_undefined(_keep_max) && _keep_max >= _keep_min) {
                            _keep_span = (_keep_max - _keep_min + 1);
                        }

                        var _built_arr = __vb_chunk_built__;
                        if (!is_undefined(_built_arr)) {
                            var _n = array_length(_built_arr);
                            var _i = 0;
                            repeat (_n) {
                                if (_built_arr[_i]) {
                                    _built_total += 1;
                                    if (_keep_span > 0 && _i >= _keep_min && _i <= _keep_max) {
                                        _built_keep += 1;
                                    }
                                }
                                _i += 1;
                            }
                        }

                        var _vis_min = __vb_visible_chunk_min__;
                        var _vis_max = __vb_visible_chunk_max__;

                        var _y = 18;
                        draw_text(4, _y,
                            "mode " + string(__vb_render_mode__) +
                            " | curChunk " + string(__vb_current_chunk_id__) +
                            " | q " + string(_queue_len) +
                            " | batches " + string(_batches)
                        );
                        _y += 14;

                        draw_text(4, _y,
                            "builtKeep " + string(_built_keep) + "/" + string(_keep_span) +
                            " | built " + string(_built_total) + "/" + string(_total_chunks)
                        );
                        _y += 14;

                        draw_text(4, _y,
                            "keep " + string(_keep_min) + ".." + string(_keep_max) +
                            " | vis " + string(_vis_min) + ".." + string(_vis_max) +
                            " | dirty " + string(__vb_is_dirty__) +
                            " | active " + string(__vb_progressive_active__)
                        );
                        _y += 14;

                        draw_text(4, _y,
                            "glyphsBuilt " + string(__vb_dbg_last_total_glyphs__) +
                            " | glyphsEmitted " + string(__vb_dbg_last_emitted_glyphs__) +
                            " | glyphsTotal " + string(__layout_glyphs_count__)
                        );
                    }

                    draw_set_color(_pre_col);
                    draw_set_alpha(_pre_alp);
                }

                // Run progressive expansion once per frame (avoid pre_draw doubling)
                if (_layer_min >= 0) {
                    __vb_progressive_emit_step__();
                }

                gpu_set_tex_filter(_old_filt);
                matrix_set(matrix_world, _old_mat);
            };

        #endregion
		
        #region Cleanup

            #region jsDoc
            /// @func   __cleanup__()
            /// @ignore
            /// @desc   Releases renderer GPU resources (batches and vertex format).
            /// @self   WWTextRenderer
            /// @returns {Undefined}
            #endregion
            static __cleanup__ = function() {
                __vb_free__();

                if (!is_undefined(__vb_format__)) {
                    vertex_format_delete(__vb_format__);
                    __vb_format__ = undefined;
                }
            };
			
            #region jsDoc
            /// @func   __vb_free__()
            /// @ignore
            /// @desc   Frees all VB draw batches and resets progressive emission state.
            /// @self   WWTextRenderer
            /// @returns {Undefined}
            #endregion
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

                __vb_open_buffers__ = [];
                __vb_pending_chunks__ = [];
                __vb_chunk_built__ = [];
                __vb_chunk_count__ = 0;
                __vb_visible_chunk_min__ = 0;
                __vb_visible_chunk_max__ = -1;
                __vb_keep_chunk_min__ = 0;
                __vb_keep_chunk_max__ = -1;
                __vb_current_chunk_id__ = -1;
                __vb_current_chunk_bounds__ = undefined;
            };

        #endregion

    #endregion
	
}
