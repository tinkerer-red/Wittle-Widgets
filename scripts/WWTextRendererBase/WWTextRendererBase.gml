#region jsDoc
/// @func    WWTextRendererBase()
/// @desc    Base text renderer component. Responsible for converting the
///          buffer content (or caption) into drawable text, handling font,
///          color, alpha, and optional word wrapping. It owns no input logic
///          and does not mutate the text buffer.
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
                /// @desc   Sets the font used for rendering. Also marks layout dirty
                ///         so cached dimensions are recomputed.
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
                /// @desc   Sets if word wrapping is enabled, true will wrap words to next line.
                /// @param  {Bool} should_wrap
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
                ///         This affects both fixed tabs and tab stop alignment.
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

                    // Tabs affect layout width and glyph placement, so rebuild layout.
                    __mark_dirty__();
                    return self;
                };

                #region jsDoc
                /// @func   set_tab_use_stops()
                /// @desc   If enabled, a tab advances to the next tab stop (tab stops mode).
                ///         If disabled, a tab always advances by a fixed width (fixed mode).
                /// @param  {Bool} _use_stops
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_tab_use_stops = function(_use_stops) {
                    if (tab_use_stops == _use_stops) {
                        return self;
                    }

                    tab_use_stops = _use_stops;

                    // Tab policy affects layout width and glyph placement.
                    __mark_dirty__();
                    return self;
                };

                #region jsDoc
                /// @func   set_whitespace_visible()
                /// @desc   If enabled, draws visible markers for spaces and tabs.
                /// @param  {Bool} _is_visible
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_whitespace_visible = function(_is_visible) {
                    if (whitespace_visible == _is_visible) {
                        return self;
                    }

                    whitespace_visible = _is_visible;

                    // Visibility affects only the baked vertices (what we draw), not layout.
                    __mark_vb_dirty__();
                    return self;
                };

                #region jsDoc
                /// @func   set_whitespace_color()
                /// @desc   Sets marker color for visible whitespace.
                /// @param  {Constant.Color} _color_value
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_whitespace_color = function(_color_value) {
                    if (whitespace_color == _color_value) {
                        return self;
                    }

                    whitespace_color = _color_value;
                    __mark_vb_dirty__();
                    return self;
                };

                #region jsDoc
                /// @func   set_whitespace_alpha()
                /// @desc   Sets marker alpha for visible whitespace.
                /// @param  {Real} _alpha_value
                /// @returns {Struct.WWTextRendererBase}
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

            #region Syntax Highlight

                #region jsDoc
                /// @func   set_highlight_runs()
                /// @desc   Provide ordered highlight runs for syntax coloring.
                ///         Each run is an Array:
                ///         [start_index, end_index, color, alpha_optional]
                ///         Indices are logical text indices (same domain as get_index_from_xy()).
                ///         Runs must be sorted and non-overlapping (assumed).
                ///         Any glyph not inside a run uses default text color/alpha.
                /// @param  {Array} _runs_array
                /// @returns {Struct.WWTextRendererBase}
                #endregion
                static set_highlight_runs = function(_runs_array) {
                    // Allow clearing by passing [] or undefined.
                    if (is_undefined(_runs_array)) {
                        _runs_array = [];
                    }

                    __highlight_runs__ = _runs_array;
                    __highlight_count__ = array_length(_runs_array);

                    // Highlighting changes vertex colors only -> rebuild VB, not layout.
                    __mark_vb_dirty__();
                    return self;
                };
            
            #endregion
        
        #endregion
        
        #region Events
            
            events.text_change = variable_get_hash("text_change");
            static on_text_change = function(_func) {
                add_event_listener(events.text_change, _func);
                return self;
            }
            
            on_text_change(function(_input) {
                __mark_dirty__();
            });
            
            on_post_step(function(_input) {
                __ensure_layout__();
            });
            
			on_post_draw(function(_input) {
                __draw_text_vb__(x, y);
            });
            
        #endregion
        
        #region Variables
            
            // Styling
            caption     = "";
            font        = fGUIDefault;
            color       = c_white;
            alpha       = 1;
            
            // Layout
            should_wrap  = false;
            line_sep    = -1;

            // Tabs
            tab_size_spaces = 4;
            tab_use_stops = true;

            // Whitespace visibility
            whitespace_visible = false;
            whitespace_color = c_gray;
            whitespace_alpha = 0.35;
            whitespace_marker_space = ".";
            whitespace_marker_tab = ">";
            
            __textbox_parent__ = undefined;
            
        #endregion
        
        #region Functions
            
            #region jsDoc
            /// @func   get_font()
            /// @desc   Returns the current font asset.
            /// @returns {Asset.GMFont}
            #endregion
            static get_font = function() {
                return font;
            };
            
            #region jsDoc
            /// @func   get_width()
            /// @desc   Returns the width of the rendered text content in pixels.
            ///         This does not include padding.
            /// @returns {Real}
            #endregion
            static get_width = function() {
                __ensure_layout__();
                return __content_width__;
            };
            
            #region jsDoc
            /// @func   get_height()
            /// @desc   Returns the height of the rendered text content in pixels.
            ///         This does not include padding.
            /// @returns {Real}
            #endregion
            static get_height = function() {
                __ensure_layout__();
                return __content_height__;
            };
            
            #region Location Maths
            
            #region jsDoc
            /// @func   get_x_from_index()
            /// @desc   Convert a logical text index into a local x coordinate.
            /// @param  {Real} _index
            /// @returns {Real}
            #endregion
            static get_x_from_index = function(_index) {
                __ensure_layout__();
                
                var _line = get_line_from_index(_index);
                var _start = __layout__.get_line_index_start(_line);
                var _end = __layout__.get_line_index_end(_line);
                var _line_width_val = __layout__.get_line_width(_line);
                var _line_len = _end - _start;
                
                if (_line_len <= 0) {
                    return 0;
                }
                
                if (_index <= _start) {
                    return 0;
                }
                if (_index >= _end) {
                    return _line_width_val;
                }
                
                // Sum glyph widths within this line up to the given index
                var _target_index = _index;
                var _glyph_count = __layout__.get_glyph_count();
                var _sum = 0;
                
                var _g = 0;
                repeat (_glyph_count) {
                    var _gi = __layout__.get_glyph_index(_g);
                    if (_gi < _start) {
                        _g++;
                        continue;
                    }
                    if (_gi >= _target_index) {
                        break;
                    }
                    
                    _sum += __layout__.get_glyph_width(_g);
                    _g++;
                }
                
                return _sum;
            };
            
            #region jsDoc
            /// @func   get_y_from_index()
            /// @desc   Convert a logical text index into a local y coordinate.
            /// @param  {Real} _index
            /// @returns {Real}
            #endregion
            static get_y_from_index = function(_index) {
                __ensure_layout__();
                var _line = get_line_from_index(_index);
                return __layout__.get_line_y_offset(_line);
            };
            
            #region jsDoc
            /// @func   get_index_from_xy()
            /// @desc   Convert gui x,y coordinates into the nearest logical text index.
            /// @param  {Real} _x
            /// @param  {Real} _y
            /// @returns {Real}
            #endregion
            static get_index_from_xy = function(_x, _y) {
                __ensure_layout__();
                
				var _layout = __layout__;
				
                // Convert GUI to clamped local
                var _target_x = _x - x;
                var _target_y = clamp(_y - y, 0, get_height());
                
				// Find line by target y
				var _line_count = _layout.get_line_count();
                var _line = 0;
                var _i = 0;
                repeat (_line_count) {
                    
					var _y_off = __layout__.get_line_y_offset(_i);
                    var _h = __layout__.get_line_height(_i);
                    _line = _i;
					
					if (_target_y >= _y_off && _target_y < _y_off + _h) {
                        break;
                    }
					
                    _i++;
                }
                
				var _start = __layout__.get_line_index_start(_line);
                var _end = __layout__.get_line_index_end(_line);
				var _line_width_val = __layout__.get_line_width(_line);
                
				if (_target_x <= 0) { return _start; }
                if (_target_x >= _line_width_val) {
					
				    var _is_forced_wrapped = _layout.get_line_forced_wrapped(_line);
				    var _is_last_line = (_line == _line_count - 1);
					
				    // Forced wrap has no literal '\n' glyph to skip.
				    // Last line often has no trailing '\n' either.
				    if (_is_forced_wrapped || _is_last_line) {
				        return _end;
				    }
					
				    // Normal line break: ignore the literal '\n' at the end of the line.
				    return max(_start, _end - 1);
				}

                var _index_result = _end;
                var _sum = 0;
                
				var _line_len = _end - _start;
                _i = _start;
                repeat (_line_len) {
                    var _glyph_width = __layout__.get_glyph_width(_i);
                    var _mid = _sum + (_glyph_width * 0.5);
                    
                    if (_target_x < _mid) {
                        _index_result = _i;
                        break;
                    }
                    
                    _sum += _glyph_width;
                    _index_result = _i + 1;
                    _i++;
                }
                
                return _index_result;
            };
            
            #region jsDoc
            /// @func   get_line_from_index()
            /// @desc   Convert a logical text index into a line number. Lines are 0-based.
            /// @param  {Real} _index
            /// @returns {Real}
            #endregion
            static get_line_from_index = function(_index) {
                __ensure_layout__();
                
                var _line_count = __layout__.get_line_count();
                if (_line_count <= 0) {
                    return 0;
                }
                
                var _result = 0;
                var _i = 0;
                repeat (_line_count) {
                    var _start = __layout__.get_line_index_start(_i);
                    var _end = __layout__.get_line_index_end(_i);
                    
                    if (_index >= _start && _index < _end) {
                        return _i;
                    }
                    
                    if (_index >= _end) {
                        _result = _i;
                    }
                    
                    _i++;
                }
                
                return _result;
            };
            
            #region jsDoc
            /// @func   get_col_from_index()
            /// @desc   Convert a logical text index into a column number. Columns are 0-based.
            /// @param  {Real} _index
            /// @returns {Real}
            #endregion
            static get_col_from_index = function(_index) {
                __ensure_layout__();
                
                var _line = get_line_from_index(_index);
                var _start = __layout__.get_line_index_start(_line);
                var _col = _index - _start;
                if (_col < 0) _col = 0;
                return _col;
            };
            
            #region jsDoc
            /// @func   get_index_from_line_col()
            /// @desc   Convert a line and column (0-based) into a logical text index.
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
                
                if (_line < 0) _line = 0;
                if (_line >= _line_count) _line = _line_count - 1;
                
                var _start = __layout__.get_line_index_start(_line);
                var _end = __layout__.get_line_index_end(_line);
                var _line_len = _end - _start;
                
                if (_col < 0) _col = 0;
                if (_col > _line_len) _col = _line_len;
                
                return _start + _col;
            };
            
            #endregion
            
			#region Line getters
			
			#region jsDoc
			/// @func    get_line_count()
			/// @desc    Returns how many lines exist in the layout.
			/// @returns {Real}
			#endregion
			static get_line_count = function() {
			    __ensure_layout__();
				return __layout__.get_line_count();
			};
	
			#region jsDoc
			/// @func    get_line(_line_index)
			/// @desc    Returns a new struct representing the requested line.
			/// @param   {Real} _line_index : Zero-based line index.
			/// @returns {Struct}
			#endregion
			static get_line = function(_line_index) {
				__ensure_layout__();
				return __layout__.get_line(_line_index);
			};
	
			#region jsDoc
			/// @func    get_line_text(_line_index)
			/// @desc    Returns the raw text content of the given line.
			/// @param   {Real} _line_index : Zero-based line index.
			/// @returns {String}
			#endregion
			static get_line_text = function(_line_index) {
			    __ensure_layout__();
				return __layout__.get_line_text(_line_index);
			};
	
			#region jsDoc
			/// @func    get_line_index_start(_line_index)
			/// @desc    Returns the text index that begins this line.
			/// @param   {Real} _line_index : Zero-based line index.
			/// @returns {Real}
			#endregion
			static get_line_index_start = function(_line_index) {
			    __ensure_layout__();
				return __layout__.get_line_index_start(_line_index);
			};
	
			#region jsDoc
			/// @func    get_line_index_end(_line_index)
			/// @desc    Returns the text index immediately after the last char of the line.
			/// @param   {Real} _line_index : Zero-based line index.
			/// @returns {Real}
			#endregion
			static get_line_index_end = function(_line_index) {
			    __ensure_layout__();
				return __layout__.get_line_index_end(_line_index);
			};
	
			#region jsDoc
			/// @func    get_line_width(_line_index)
			/// @desc    Returns the width of the given line.
			/// @param   {Real} _line_index : Zero-based line index.
			/// @returns {Real}
			#endregion
			static get_line_width = function(_line_index) {
			    __ensure_layout__();
				return __layout__.get_line_width(_line_index);
			};
	
			#region jsDoc
			/// @func    get_line_height(_line_index)
			/// @desc    Returns the height of the given line.
			/// @param   {Real} _line_index : Zero-based line index.
			/// @returns {Real}
			#endregion
			static get_line_height = function(_line_index) {
			    __ensure_layout__();
				return __layout__.get_line_height(_line_index);
			};
	
			#region jsDoc
			/// @func    get_line_y_offset(_line_index)
			/// @desc    Returns the vertical offset of the line relative to layout top.
			/// @param   {Real} _line_index : Zero-based line index.
			/// @returns {Real}
			#endregion
			static get_line_y_offset = function(_line_index) {
			    __ensure_layout__();
				return __layout__.get_line_y_offset(_line_index);
			};
	
			#region jsDoc
			/// @func    get_line_forced_wrapped(_line_index)
			/// @desc    Returns 1 if the line was soft-wrapped, 0 if an explicit break.
			/// @param   {Real} _line_index : Zero-based line index.
			/// @returns {Real}
			#endregion
			static get_line_forced_wrapped = function(_line_index) {
			    __ensure_layout__();
				return __layout__.get_line_forced_wrapped(_line_index);
			};
	
			#endregion
			
			#region Glyph getters
	
			#region jsDoc
			/// @func    get_glyph_count()
			/// @desc    Returns how many glyphs are recorded in the layout.
			/// @returns {Real}
			#endregion
			static get_glyph_count = function() {
			    __ensure_layout__();
				return __layout__.get_glyph_count();
			};

			#region jsDoc
			/// @func    get_glyph(_glyph_index)
			/// @desc    Returns a new struct representing this glyph.
			/// @param   {Real} _glyph_index
			/// @returns {Struct}
			#endregion
			static get_glyph = function(_glyph_index) {
				__ensure_layout__();
				return __layout__.get_glyph(_glyph_index);
			};

			#region jsDoc
			/// @func    get_glyph_char(_glyph_index)
			/// @desc    Returns the displayed character or Unicode cluster.
			/// @param   {Real} _glyph_index
			/// @returns {String}
			#endregion
			static get_glyph_char = function(_glyph_index) {
				__ensure_layout__();
				return __layout__.get_glyph_char(_glyph_index);
			};

			#region jsDoc
			/// @func    get_glyph_index(_glyph_index)
			/// @desc    Returns the logical text index (cluster index) for this glyph.
			/// @param   {Real} _glyph_index
			/// @returns {Real}
			#endregion
			static get_glyph_index = function(_glyph_index) {
				__ensure_layout__();
				return __layout__.get_glyph_index(_glyph_index);
			};

			#region jsDoc
			/// @func    get_glyph_buffer_index(_glyph_index)
			/// @desc    Returns the buffer offset where this glyph begins.
			/// @param   {Real} _glyph_index
			/// @returns {Real}
			#endregion
			static get_glyph_buffer_index = function(_glyph_index) {
				__ensure_layout__();
				return __layout__.get_glyph_buffer_index(_glyph_index);
			};

			#region jsDoc
			/// @func    get_glyph_buffer_size(_glyph_index)
			/// @desc    Returns how many buffer units this glyph consumes.
			/// @param   {Real} _glyph_index
			/// @returns {Real}
			#endregion
			static get_glyph_buffer_size = function(_glyph_index) {
				__ensure_layout__();
				return __layout__.get_glyph_buffer_size(_glyph_index);
			};

			#region jsDoc
			/// @func    get_glyph_x(_glyph_index)
			/// @desc    Returns the glyph's x position in layout space.
			/// @param   {Real} _glyph_index
			/// @returns {Real}
			#endregion
			static get_glyph_x = function(_glyph_index) {
				__ensure_layout__();
				return __layout__.get_glyph_x(_glyph_index);
			};

			#region jsDoc
			/// @func    get_glyph_y(_glyph_index)
			/// @desc    Returns the glyph's y position in layout space.
			/// @param   {Real} _glyph_index
			/// @returns {Real}
			#endregion
			static get_glyph_y = function(_glyph_index) {
				__ensure_layout__();
				return __layout__.get_glyph_y(_glyph_index);
			};

			#region jsDoc
			/// @func    get_glyph_width(_glyph_index)
			/// @desc    Returns the width of this glyph.
			/// @param   {Real} _glyph_index
			/// @returns {Real}
			#endregion
			static get_glyph_width = function(_glyph_index) {
				__ensure_layout__();
				return __layout__.get_glyph_width(_glyph_index);
			};

			#region jsDoc
			/// @func    get_glyph_height(_glyph_index)
			/// @desc    Returns the height of this glyph.
			/// @param   {Real} _glyph_index
			/// @returns {Real}
			#endregion
			static get_glyph_height = function(_glyph_index) {
				__ensure_layout__();
				return __layout__.get_glyph_height(_glyph_index);
			};

			#endregion
			
			#region Buffer region
			
			#region jsDoc
			/// @func   get_buffer_index_from_index()
			/// @desc   Convert a logical text index into a buffer byte offset.
			///         This uses the line’s glyph range to avoid scanning all glyphs.
			/// @param  {Real} _index
			/// @returns {Real}
			#endregion
			static get_buffer_index_from_index = function(_index) {
				__ensure_layout__();
				return __layout__.get_glyph_buffer_index(_index);
			};
			
			#region jsDoc
			/// @func   get_index_from_buffer_index()
			/// @desc   Convert a buffer byte offset into the nearest logical text index.
			///         First narrows to a line using that line’s glyph buffer range, then
			///         searches only the glyphs in that line.
			/// @param  {Real} _buffer_index
			/// @returns {Real}
			#endregion
			static get_index_from_buffer_index = function(_buffer_index) {
			    __ensure_layout__();
			    
				if (_buffer_index <= 0) { return 0; }
				
				var _line_count = __layout__.get_line_count();
				var _last_line_index = _line_count - 1;
			    var _last_glyph_index = __layout__.get_line_index_end(_last_line_index);
				var _last_glyph_buffer_start = __layout__.get_glyph_buffer_index(_last_glyph_index);
				//essentially free to check this so might as well
				if (_buffer_index = _last_glyph_buffer_start) { return _last_glyph_index; };
				var _last_glyph_buffer_end = _last_glyph_buffer_start + __layout__.get_glyph_buffer_size(_last_glyph_index);
				//if at the end, return index+1
				if (_buffer_index >= _last_glyph_buffer_end) { return _last_glyph_index+1; };
				
				
			    if (_line_count <= 0) {
			        return 0;
			    }
    
			    var _target_line_index = 0;
			    var _found_line = false;
    
			    // First pass: find which line this buffer offset belongs to
			    var _line = 0;
			    repeat (_line_count) {
			        var _glyph_start = __layout__.get_line_index_start(_line);
			        var _glyph_end   = __layout__.get_line_index_end(_line);
			        var _glyph_count_line = _glyph_end - _glyph_start;
        
			        if (_glyph_count_line > 0) {
			            var _first_buf_start    = __layout__.get_glyph_buffer_index(_glyph_start);
			            var _last_glyph_in_line = _glyph_end - 1;
			            var _last_buf_start     = __layout__.get_glyph_buffer_index(_last_glyph_in_line);
			            var _last_buf_size      = __layout__.get_glyph_buffer_size(_last_glyph_in_line);
			            var _line_buf_end       = _last_buf_start + _last_buf_size;
            
			            if (_buffer_index < _first_buf_start) {
			                // Before this line's first glyph: caret is at the start of this line
			                _target_line_index = _line;
			                _found_line = true;
			                break;
			            }
            
			            if (_buffer_index >= _first_buf_start && _buffer_index < _line_buf_end) {
			                // Within this line's glyph buffer range
			                _target_line_index = _line;
			                _found_line = true;
			                break;
			            }
            
			            // Otherwise, buffer index is beyond this line; keep scanning
			            _target_line_index = _line;
			        }
        
			        _line++;
			    }
    
			    // If we never matched inside or before a line, clamp to just after last glyph overall
			    if (!_found_line) {
			        var _last_glyph_start = __layout__.get_line_index_start(_last_line_index);
			        var _last_glyph_end   = __layout__.get_line_index_end(_last_line_index);
			        if (_last_glyph_end > _last_glyph_start) {
			            var _last_glyph = _last_glyph_end - 1;
			            var _last_logical_index = __layout__.get_glyph_index(_last_glyph);
			            return _last_logical_index + 1;
			        }
			        return 0;
			    }
    
			    // Second pass: search within the chosen line's glyph range
			    var _line_start_index = __layout__.get_line_index_start(_target_line_index);
    
			    var _glyph_start_line = __layout__.get_line_index_start(_target_line_index);
			    var _glyph_end_line   = __layout__.get_line_index_end(_target_line_index);
			    var _glyph_count_line2 = _glyph_end_line - _glyph_start_line;
    
			    if (_glyph_count_line2 <= 0) {
			        // Line has no glyphs: caret is at line start
			        return _line_start_index;
			    }
    
			    var _first_buf_start_line = __layout__.get_glyph_buffer_index(_glyph_start_line);
			    if (_buffer_index <= _first_buf_start_line) {
			        return _line_start_index;
			    }
    
			    var _closest_index = _line_start_index;
			    var _g2 = _glyph_start_line;
			    repeat (_glyph_count_line2) {
			        var _buf_start = __layout__.get_glyph_buffer_index(_g2);
			        var _buf_size  = __layout__.get_glyph_buffer_size(_g2);
			        var _buf_end   = _buf_start + _buf_size;
			        var _logical_index = __layout__.get_glyph_index(_g2);
        
			        if (_buffer_index >= _buf_start && _buffer_index < _buf_end) {
			            // Inside this glyph's byte region
			            return _logical_index;
			        }
        
			        if (_buffer_index < _buf_start) {
			            // Before this glyph: caret is at this glyph's index
			            return _logical_index;
			        }
        
			        _closest_index = _logical_index + 1;
			        _g2++;
			    }
    
			    // Beyond all glyphs in this line: caret at end of line
			    return _closest_index;
			};

			#endregion
			
		#endregion
    
    #endregion
    
    #region Private
        
        #region Variables
            
            __is_dirty__       = true;
            __display_text__   = "";
            __content_width__  = 0;
            __content_height__ = 0;
            
            __layout__ = __build_layout__(""); // WWTextLayout instance

            // VB cache (separate from layout cache)
            __vb_is_dirty__ = true;
            __vb_format__ = undefined;
            __vb_buffer__ = undefined;
            __vb_texture__ = undefined;
            
            // Per-font glyph info cache
            __glyph_cache_font__ = undefined;
            __glyph_cache__ = {};
			
            // Tab metrics cached per rebuild
            __space_width__ = 0;
            __tab_width__ = 0;

            // Syntax highlight runs (ordered)
            // Each run: [start_index, end_index, color, alpha_optional]
            __highlight_runs__  = [];
            __highlight_count__ = 0;
            
        #endregion
        
        #region Functions
            
            #region jsDoc
            /// @func   __mark_dirty__()
            /// @desc   Marks the layout as needing recomputation.
            #endregion
            static __mark_dirty__ = function() {
                __is_dirty__ = true;
                // Layout changes invalidate the cached vertex buffer too.
                __mark_vb_dirty__();
            };

            #region jsDoc
            /// @func   __mark_vb_dirty__()
            /// @desc   Marks the vertex buffer as needing a rebuild.
            ///         Use this when appearance changes (color/alpha/whitespace display),
            ///         but layout positions have not changed.
            #endregion
            static __mark_vb_dirty__ = function() {
                __vb_is_dirty__ = true;
            };

            #region jsDoc
            /// @func   __vb_free__()
            /// @desc   Frees the owned vertex buffer, if any.
            #endregion
            static __vb_free__ = function() {
                if (!is_undefined(__vb_buffer__)) {
                    vertex_delete_buffer(__vb_buffer__);
                    __vb_buffer__ = undefined;
                }
            };

            #region jsDoc
            /// @func   __vb_ensure_format__()
            /// @desc   Creates the vertex format used for glyph rendering, if needed.
            ///         Format: position + texcoord + colour.
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
			
            #region jsDoc
            /// @func   __tab_advance__()
            /// @desc   Returns how many pixels a tab should advance from _cursor_x.
            ///         In tab stops mode, this advances to the next multiple of __tab_width__.
            ///         In fixed mode, this always advances exactly __tab_width__ pixels.
            /// @param  {Real} _cursor_x
            /// @returns {Real}
            #endregion
            static __tab_advance__ = function(_cursor_x) {
                var _tab_width_local = __tab_width__;
                if (_tab_width_local <= 0) {
                    return 0;
                }

                // Fixed width mode.
                if (!tab_use_stops) {
                    return _tab_width_local;
                }

                // Tab stops mode: advance to the next stop.
                // This makes tab width vary between 1..tab_width depending on current x.
                var _pos_mod = _cursor_x mod _tab_width_local;

                // Exactly on a stop -> advance one full stop.
                if (_pos_mod == 0) {
                    return _tab_width_local;
                }

                return _tab_width_local - _pos_mod;
            };

            #region jsDoc
            /// @func   __measure_line_width_tabs__()
            /// @desc   Measures line width treating tabs using the configured tab policy.
            ///         This is used for early-out decisions like "does the raw line already fit".
            /// @param  {String} _line_text
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
                        // Explicit line breaks don't contribute to width.
                    } else {
                        _cursor_x_local += string_width(_char_val);
                    }

                    _char_index++;
                }

                return _cursor_x_local;
            };
            
            #region jsDoc
            /// @func   __ensure_layout__()
            /// @desc   If layout is dirty, recompute layout (lines + glyphs) and
            ///         update cached width/height. Uses buffer text if present;
            ///         otherwise falls back to caption.
            #endregion
            static __ensure_layout__ = function() {
                if (!__is_dirty__) {
                    return;
                }
                
                var _str = "";
                if (!is_undefined(__textbox_parent__)) {
                    _str = __textbox_parent__.get_text();
                }
                
                if (_str == "") {
                    _str = caption;
                }
                
                __display_text__ = _str;
                
                __layout__ = __build_layout__(_str);
                
                __content_width__ = __layout__.get_content_width();
                __content_height__ = __layout__.get_content_height();
                
                __is_dirty__ = false;
            };

            #region jsDoc
            /// @func   __ensure_vb__()
            /// @desc   Rebuilds the vertex buffer if dirty and layout is ready.
            ///         This is the "single batched draw call" cache.
            ///         It is safe to call every frame.
            #endregion
            static __ensure_vb__ = function() {
                if (!__vb_is_dirty__) {
                    return;
                }
				
                __ensure_layout__();
				
                __vb_ensure_format__();
                __vb_free__();
				
                // Font texture + UV rectangle (handles atlas layouts).
                __vb_texture__ = font_get_texture(font);
                __vb_buffer__ = vertex_create_buffer();
                __build_vb__();
				
                __vb_is_dirty__ = false;
            };

            #region jsDoc
            /// @func   __vb_emit_glyph__()
            /// @desc   Emits a single glyph quad into the active vertex buffer.
            ///         This assumes vertex_begin(...) is already active.
            ///         Returns true if a glyph was emitted, false if it could not be.
            /// @param  {Struct} _font_info
            /// @param  {String} _char
            /// @param  {Real} _pos_x
            /// @param  {Real} _pos_y
            /// @param  {Constant.Color} _col
            /// @param  {Real} _alp
            /// @returns {Bool}
            #endregion
            static __vb_emit_glyph__ = function(_font_info, _char, _pos_x, _pos_y, _col, _alp) {
                if (_char == "" || is_undefined(_font_info)) {
                    return false;
                }
				
                // Ensure the glyph is present on the font atlas (important for runtime fonts).
                var _glyph_info = _font_info.glyphs[$ _char];
				
				
				// Glyph rect in texels on the font texture page.
                var _gx = _glyph_info.x;
                var _gy = _glyph_info.y;
                var _gw = _glyph_info.w;
                var _gh = _glyph_info.h;
				
                // Some glyphs may not have a bitmap.
                if (_gx < 0 || _gy < 0 || _gw <= 0 || _gh <= 0) {
                    return false;
                }
				
                // Convert glyph texels -> normalized page UVs using texel size.
                var _texel_w = texture_get_texel_width(__vb_texture__);
                var _texel_h = texture_get_texel_height(__vb_texture__);
				
                var _u0 = _gx * _texel_w;
                var _v0 = _gy * _texel_h;
                var _u1 = _u0 + (_gw * _texel_w);
                var _v1 = _v0 + (_gh * _texel_h);
				
                // offset accounts for glyph bearings.
                var _xoff = _glyph_info.offset;
                var _yoff = _glyph_info.yoffset;
				
                var _x0 = _pos_x + _xoff;
                var _y0 = _pos_y + _yoff;
                var _x1 = _x0 + _gw;
                var _y1 = _y0 + _gh;
				
                // Triangle 1
                vertex_position(__vb_buffer__, _x0, _y0);
                vertex_texcoord(__vb_buffer__, _u0, _v0);
                vertex_colour(__vb_buffer__, _col, _alp);
				
                vertex_position(__vb_buffer__, _x1, _y0);
                vertex_texcoord(__vb_buffer__, _u1, _v0);
                vertex_colour(__vb_buffer__, _col, _alp);
				
                vertex_position(__vb_buffer__, _x1, _y1);
                vertex_texcoord(__vb_buffer__, _u1, _v1);
                vertex_colour(__vb_buffer__, _col, _alp);
				
                // Triangle 2
                vertex_position(__vb_buffer__, _x0, _y0);
                vertex_texcoord(__vb_buffer__, _u0, _v0);
                vertex_colour(__vb_buffer__, _col, _alp);
				
                vertex_position(__vb_buffer__, _x1, _y1);
                vertex_texcoord(__vb_buffer__, _u1, _v1);
                vertex_colour(__vb_buffer__, _col, _alp);
				
                vertex_position(__vb_buffer__, _x0, _y1);
                vertex_texcoord(__vb_buffer__, _u0, _v1);
                vertex_colour(__vb_buffer__, _col, _alp);
				
                return true;
            };

            #region jsDoc
            /// @func   __build_vb__()
            /// @desc   Converts the current layout glyphs into a single triangle list VB.
            ///         Notes:
            ///         - '\n' and '\r' are not rendered.
            ///         - '\t' is not rendered unless whitespace_visible is enabled, in which
            ///           case we render a marker glyph.
            ///         - spaces can optionally render a marker glyph when enabled.
            ///         Everything still submits as one draw call.
            #endregion
            static __build_vb__ = function() {
                var _font_info = font_get_info(font);
                if (is_undefined(_font_info)) {
                    return;
                }
                
                // Ensure string_width() for marker centering matches the rendered font.
                var _old_font = draw_get_font();
                if (font_exists(font)) {
                    draw_set_font(font);
                }
                
                var _glyph_count = __layout__.get_glyph_count();

                // Highlight run iterator state
                var _run_array = __highlight_runs__;
                var _run_count = __highlight_count__;
                var _run_index = 0;

                // Current run cached values (valid only if _run_index < _run_count)
                var _run_start = 0;
                var _run_end = 0;
                var _run_color = c_white;
                var _run_alpha = 1;

                if (_run_count > 0) {
                    var _run0 = _run_array[0];
                    _run_start = _run0[0];
                    _run_end = _run0[1];
                    _run_color = _run0[2];

                    // Optional alpha
                    if (array_length(_run0) >= 4) {
                        _run_alpha = _run0[3];
                    } else {
                        _run_alpha = alpha;
                    }
                }

                vertex_begin(__vb_buffer__, __vb_format__);

                var _glyph_index = 0;
                repeat (_glyph_count) {
                    var _char = __layout__.get_glyph_char(_glyph_index);

                    // Always skip explicit line breaks.
                    if (_char == "\n" || _char == "\r" || _char == "") {
                        _glyph_index++;
                        continue;
                    }

                    // Skip tabs unless visualized; layout already advanced x.
                    if (_char == "\t" && !whitespace_visible) {
                        _glyph_index++;
                        continue;
                    }

                    var _pos_x = __layout__.get_glyph_x(_glyph_index);
                    var _pos_y = __layout__.get_glyph_y(_glyph_index);

                    // Whitespace visualization replaces whitespace with marker glyphs.
                    if (whitespace_visible) {

                        if (_char == " ") {
                            var _cell_w = __layout__.get_glyph_width(_glyph_index);

                            // Center "." inside the space cell for readability.
                            var _mark_char = whitespace_marker_space;
                            var _mark_w = string_width(_mark_char);

                            var _mark_x = _pos_x;
                            if (_cell_w > 0 && _mark_w > 0) {
                                _mark_x = _pos_x + ((_cell_w - _mark_w) * 0.5);
                            }

                            __vb_emit_glyph__(_font_info, _mark_char, _mark_x, _pos_y, whitespace_color, whitespace_alpha);

                            _glyph_index++;
                            continue;
                        }

                        if (_char == "\t") {
                            // Draw a ">" at the start of the tab cell.
                            var _mark_char2 = whitespace_marker_tab;
                            __vb_emit_glyph__(_font_info, _mark_char2, _pos_x, _pos_y, whitespace_color, whitespace_alpha);

                            _glyph_index++;
                            continue;
                        }
                    }

                    // Decide final color for this glyph based on highlight runs.
                    // NOTE: We use the glyph's logical text index, not the glyph array index.
                    var _final_color = color;
                    var _final_alpha = alpha;

                    if (_run_index < _run_count) {

                        var _logical_index = __layout__.get_glyph_index(_glyph_index);

                        // Advance runs if this glyph is beyond the current run.
                        // Runs are ordered, so once we pass a run, we never revisit it.
                        if (_logical_index >= _run_end) {

                            var _remaining = _run_count - _run_index - 1;
                            var _step = 0;
                            repeat (_remaining) {

                                _run_index++;

                                var _run_next = _run_array[_run_index];
                                _run_start = _run_next[0];
                                _run_end = _run_next[1];
                                _run_color = _run_next[2];

                                if (array_length(_run_next) >= 4) {
                                    _run_alpha = _run_next[3];
                                } else {
                                    _run_alpha = alpha;
                                }

                                // If this run ends after our glyph starts, stop advancing.
                                if (_logical_index < _run_end) {
                                    break;
                                }

                                _step++;
                            }
                        }

                        // If still within a valid run, apply it.
                        if (_run_index < _run_count) {
                            if (_logical_index >= _run_start && _logical_index < _run_end) {
                                _final_color = _run_color;
                                _final_alpha = _run_alpha;
                            }
                        }
                    }

                    // Normal glyph
                    __vb_emit_glyph__(_font_info, _char, _pos_x, _pos_y, _final_color, _final_alpha);

                    _glyph_index++;
                }

                vertex_end(__vb_buffer__);

                // Freeze since this buffer is reused until something changes.
                vertex_freeze(__vb_buffer__);
                
                if (font_exists(_old_font) && _old_font != draw_get_font()) {
                    draw_set_font(_old_font);
                }

            };

            #region jsDoc
            /// @func   __draw_text_vb__()
            /// @desc   Submits the cached VB with a single draw call.
            ///         Uses a world-matrix translation so we don't rebuild vertices per draw.
            /// @param  {Real} _origin_x
            /// @param  {Real} _origin_y
            #endregion
            static __draw_text_vb__ = function(_origin_x, _origin_y) {
                __ensure_vb__();

                if (is_undefined(__vb_buffer__) || is_undefined(__vb_texture__)) {
                    return;
                }

                // Apply translation without rebuilding the VB.
                var _old_mat = matrix_get(matrix_world);
                matrix_set(matrix_world, matrix_build(_origin_x, _origin_y, 0, 0, 0, 0, 1, 1, 1));
				// Apply texture filtering for better text rendering
				var _old_filt = gpu_get_tex_filter();
				gpu_set_tex_filter(true);
				
                vertex_submit(__vb_buffer__, pr_trianglelist, __vb_texture__);
				
				// Restore previous world matrix.
                matrix_set(matrix_world, _old_mat);
				// Restore the previous texture filtering
				gpu_set_tex_filter(_old_filt);
            };
            
            #region jsDoc
            /// @func   __draw_text__()
            /// @desc   Draws the current layout at the given GUI position,
            ///         using the configured font, color, alpha.
            /// @param  {Real} _origin_x
            /// @param  {Real} _origin_y
            #endregion
            static __draw_text__ = function(_origin_x, _origin_y) {
                if (font_exists(font)) {
                    draw_set_font(font);
                }
                
                var _data = __layout__.get_layout_data();
                var _lines = _data.lines;
                var _line_count = _data.lines_count;
                
                var _li = 0;
                var _base_index = 0;
                repeat (_line_count) {
                    var _text = _lines[_base_index + __WW_Layout_Line.Text];
                    var _y_off = _lines[_base_index + __WW_Layout_Line.Y_Offset];
                    
                    if (_text != "") {
                        draw_text_color(
                            _origin_x,
                            _origin_y + _y_off,
                            _text,
                            color, color, color, color,
                            alpha
                        );
                    }
                    
                    _base_index += __WW_Layout_Line.__Size__;
                    _li++;
                }
            };
            
            static __set_textbox__ = function(_comp) {
                __textbox_parent__ = _comp;
                return self;
            };
			
            static __string_split_and_retain__ = function(_str, _delim) {
				static __closure = {};
				static __fn = method(__closure, function(_value, _index) {
					if (last_index == _index) return _value;
					
					return _value + delim;
				});
				
				var _arr = string_split(_str, _delim);
				__closure.delim = _delim;
				__closure.last_index = array_length(_arr) - 1;
				array_map_ext(_arr, __fn)
				return _arr;
			}
			
            #region jsDoc
            /// @func   __build_layout__(_str)
            /// @desc   Build a WWTextLayout instance (lines + glyphs) for the given string.
            /// @param  {String} _str
            /// @returns {Struct.WWTextLayout}
            #endregion
            static __build_layout__ = function(_str) {
                var _width_limit = (should_wrap) ? __textbox_parent__.width : infinity;
                var _font_id = font;
                
                var _layout = new WWTextLayout();
                
                var _old_font = draw_get_font();
                draw_set_font(_font_id);

                // Cache tab metrics for this rebuild.
                __space_width__ = string_width(" ");
                __tab_width__ = __space_width__ * tab_size_spaces;
                
				//convert string to array of lines, retaining their `\n`
				var _input_lines = __string_split_and_retain__(_str, "\n");
				
					
                if (_width_limit < 0 || _width_limit == infinity) {
                    var _wrapped_lines = _input_lines;
					
                }
				else {
                    var _space_width = __space_width__;
                    var _input_line_count = array_length(_input_lines);
                    
                    var _output_arr = [];
                    
                    var _line_index = 0;
                    repeat (_input_line_count) {
                        var _raw_line = _input_lines[_line_index];

                        var _raw_width = __measure_line_width_tabs__(_raw_line);

                        if (_raw_line == "" || _raw_width <= _width_limit) {
                            array_push(_output_arr, _raw_line);
                            _line_index++;
                            continue;
                        }
                        
                        var _words = __string_split_and_retain__(_raw_line, " ");
                        var _word_count = array_length(_words);
                        
                        var _start_index = 0;
                        var _segment_word_count = 0;
                        var _current_width_val = 0;
                        
                        var _word_index = 0;
                        repeat (_word_count) {
                            var _word = _words[_word_index];
                            var _word_width_val = __measure_line_width_tabs__(_word);
                            
                            if (_word_width_val < _width_limit) {
                                var _new_width_val = _current_width_val + _word_width_val;
                                
                                if (_new_width_val < _width_limit) {
                                    _current_width_val = _new_width_val + _space_width;
                                    _segment_word_count++;
                                }
								else {
                                    if (_segment_word_count > 0) {
                                        var _segment_str_flush = string_concat_ext(_words, _start_index, _segment_word_count);
                                        array_push(_output_arr, _segment_str_flush);
                                        _start_index += _segment_word_count;
                                    }
                                    
                                    _current_width_val = _word_width_val + ((_word_index + 1 < _word_count) ? _space_width : 0);
                                    _segment_word_count = 1;
                                }
                                
                                if (_current_width_val >= _width_limit) {
                                    var _segment_str_flush2 = string_concat_ext(_words, _start_index, _segment_word_count);
                                    array_push(_output_arr, _segment_str_flush2);
                                    _current_width_val = 0;
                                    _start_index += _segment_word_count;
                                    _segment_word_count = 0;
                                }
                            }
							else {
                                if (_segment_word_count > 0) {
                                    var _segment_str_flush3 = string_concat_ext(_words, _start_index, _segment_word_count);
                                    array_push(_output_arr, _segment_str_flush3);
                                    _start_index += _segment_word_count;
                                    _segment_word_count = 0;
                                    _current_width_val = 0;
                                }
                                
                                var _word_len = string_length(_word);
                                var _segment_start_char_index = 1;
                                var _segment_width_chars = 0;
                                
                                var _char_index = 1;
                                repeat (_word_len) {
                                    var _char = string_char_at(_word, _char_index);
                                    var _char_width_val = (_char == "\t") ? __tab_advance__(_segment_width_chars) : string_width(_char);
                                    
                                    if (_segment_width_chars > 0 && (_segment_width_chars + _char_width_val) > _width_limit) {
                                        var _segment_length_chars = _char_index - _segment_start_char_index;
                                        if (_segment_length_chars <= 0) {
                                            var _single_char_str = _char;
                                            array_push(_output_arr, _single_char_str);
                                            _segment_start_char_index = _char_index + 1;
                                            _segment_width_chars = 0;
                                            _char_index++;
                                            continue;
                                        }
                                        
                                        var _segment_str = string_copy(_word, _segment_start_char_index, _segment_length_chars);
                                        array_push(_output_arr, _segment_str);
                                        
                                        _segment_start_char_index = _char_index;
                                        _segment_width_chars = 0;
                                    }
                                    
                                    _segment_width_chars += _char_width_val;
                                    _char_index++;
                                }
                                
                                if (_segment_width_chars > 0 && _segment_start_char_index <= _word_len) {
                                    var _segment_length_final = (_word_len + 1) - _segment_start_char_index;
                                    var _segment_str_final = string_copy(_word, _segment_start_char_index, _segment_length_final);
                                    array_push(_output_arr, _segment_str_final);
                                }
                                
                                _start_index = _word_index + 1;
                                _current_width_val = 0;
                                _segment_word_count = 0;
                            }
                            
                            _word_index++;
                        }
                        
                        if (_segment_word_count > 0) {
                            var _segment_str_flush4 = string_concat_ext(_words, _start_index, _segment_word_count);
                            array_push(_output_arr, _segment_str_flush4);
                        }
                        
                        _line_index++;
                    }
                    
                    var _wrapped_lines = _output_arr;
                }
                
                var _line_count_final = array_length(_wrapped_lines);
                var _global_index = 0;
                var _line_offset_y = 0;
                
                var _line_iter_index = 0;
                repeat (_line_count_final) {
                    var _line_text = _wrapped_lines[_line_iter_index];
                    var _line_len = string_length(_line_text);
                    
                    var _cursor_x = 0;
                    var _base_height = (_line_len > 0) ? string_height(_line_text) : string_height(" ");
                    var _extra_sep = (line_sep > 0) ? line_sep : 0;
                    var _line_height_val = _base_height + _extra_sep;
                    
                    var _char_index2 = 1;
                    repeat (_line_len) {
                        var _char2 = string_char_at(_line_text, _char_index2);
                        var _char_width2 = (_char2 == "\t") ? __tab_advance__(_cursor_x) : string_width(_char2);
                        
                        var _index = _global_index + (_char_index2 - 1);
                        var _buffer_index = _index;
                        var _buffer_size = 1;
                        
                        _layout.add_glyph(
                            _char2,
                            _index,
                            _buffer_index,
                            _buffer_size,
                            _cursor_x,
                            _line_offset_y,
                            _char_width2,
                            _base_height
                        );
                        
                        _cursor_x += _char_width2;
                        _char_index2++;
                    }
                    
                    var _line_width_val = _cursor_x;
                    var _line_index_start = _global_index;
                    var _line_index_end = _line_index_start + _line_len;
                    var _force_wrapped = 0;
                    
                    _layout.add_line(
                        _line_text,
                        _line_index_start,
                        _line_index_end,
                        _line_width_val,
                        _line_height_val,
                        _line_offset_y,
                        _force_wrapped
                    );
                    
                    _global_index += _line_len;
                    _line_offset_y += _line_height_val;
                    _line_iter_index++;
                }
                
                if (font_exists(_old_font) && _old_font != draw_get_font()) {
                    draw_set_font(_old_font);
                }
                
                return _layout;
            };

            #region jsDoc
            /// @func   __cleanup__()
            /// @desc   Called by WWCore teardown flow. Frees VB resources owned by this renderer.
            #endregion
            static __cleanup__ = function() {
                __vb_free__();

                if (!is_undefined(__vb_format__)) {
                    vertex_format_delete(__vb_format__);
                    __vb_format__ = undefined;
                }
            };

            
        #endregion
        
    #endregion
    
}
