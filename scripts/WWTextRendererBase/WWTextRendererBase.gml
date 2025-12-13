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
                __ensure_layout__();
                __draw_text__(x, y);
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
			    
			    var _line_count = __layout__.get_line_count();
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
			        var _last_line_index = _line_count - 1;
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
            
            __layout__         = undefined; // WWTextLayout instance
            
        #endregion
        
        #region Functions
            
            #region jsDoc
            /// @func   __mark_dirty__()
            /// @desc   Marks the layout as needing recomputation.
            #endregion
            static __mark_dirty__ = function() {
                __is_dirty__ = true;
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
                
				//convert string to array of lines, retaining their `\n`
				var _input_lines = __string_split_and_retain__(_str, "\n");
				
					
                if (_width_limit < 0 || _width_limit == infinity) {
                    var _wrapped_lines = _input_lines;
					
                }
				else {
                    var _space_width = string_width(" ");
                    var _input_line_count = array_length(_input_lines);
                    
                    var _output_arr = [];
                    
                    var _line_index = 0;
                    repeat (_input_line_count) {
                        var _raw_line = _input_lines[_line_index];
                        
                        if (_raw_line == "" || string_width(_raw_line) <= _width_limit) {
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
                            var _word_width_val = string_width(_word);
                            
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
                                    var _char_width_val = string_width(_char);
                                    
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
                        var _char_width2 = string_width(_char2);
                        
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
            
        #endregion
        
    #endregion
    
}
