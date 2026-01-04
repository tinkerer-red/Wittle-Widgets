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
				/// @func   set_font_fallbacks()
				/// @desc   Sets an ordered list of fallback fonts (highest priority first).
				///         Used when the active glyph font or renderer font does not contain a glyph.
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
				
				#region Syntax Highlight
				
					#region jsDoc
					/// @func   set_format_range()
					/// @desc   Applies formatting directly into glyph records for the logical index range.
					///         This mutates the current layout glyphs. If the layout is dirty, it will be rebuilt first.
					///         Range is [start_index, end_index) 0-based.
					///         Pass undefined for any field you do not want to change.
					/// @param  {Real} _start_index
					/// @param  {Real} _end_index
					/// @param  {Constant.Color|Undefined} _color_value
					/// @param  {Real|Undefined} _alpha_value
					/// @param  {Asset.GMFont|Real|Undefined} _font_asset_or_minus1
					/// @param  {Real|Undefined} _style_value
					/// @param  {Real|Undefined} _size_mul
					/// @param  {Real|Undefined} _underline_value
					/// @returns {Struct.WWTextRendererBase}
					#endregion
					static set_format_range = function(
					    _start_index,
					    _end_index,
					    _color_value,
					    _alpha_value,
					    _font_asset_or_minus1,
					    _style_value,
					    _size_mul,
					    _underline_value
					) {
					    __ensure_layout__();

					    if (_end_index <= _start_index) {
					        return self;
					    }

					    var _data = __layout__.get_layout_data();
					    var _glyphs = _data.glyphs;
					    var _glyph_count = _data.glyphs_count;

					    // Fast reject if no glyphs
					    if (_glyph_count <= 0) {
					        return self;
					    }

					    // Clamp
					    if (_start_index < 0) { _start_index = 0; }

					    // Walk packed glyph records and mutate only those whose logical index is in range.
					    var _base = 0;
					    var _gi = 0;
					    repeat (_glyph_count) {

					        var _logical_index = _glyphs[_base + __WW_Layout_Glyph.Index];

					        if (_logical_index >= _end_index) {
					            break;
					        }

					        if (_logical_index >= _start_index) {

					            if (!is_undefined(_color_value)) {
					                _glyphs[_base + __WW_Layout_Glyph.Color] = _color_value;
					            }

					            if (!is_undefined(_alpha_value)) {
					                _glyphs[_base + __WW_Layout_Glyph.Alpha] = _alpha_value;
					            }

					            if (!is_undefined(_font_asset_or_minus1)) {
					                _glyphs[_base + __WW_Layout_Glyph.Font] = _font_asset_or_minus1;
					            }

					            if (!is_undefined(_style_value)) {
					                _glyphs[_base + __WW_Layout_Glyph.Style] = _style_value;
					            }

					            if (!is_undefined(_size_mul)) {
					                var _size_val = _size_mul;
					                if (_size_val <= 0) { _size_val = 1; }
					                _glyphs[_base + __WW_Layout_Glyph.Size_Mul] = _size_val;
					            }

					            if (!is_undefined(_underline_value)) {
					                _glyphs[_base + __WW_Layout_Glyph.Underline] = _underline_value;
					            }
					        }

					        _base += __WW_Layout_Glyph.__Size__;
					        _gi++;
					    }

					    __mark_vb_dirty__();
					    return self;
					};
					
					#region jsDoc
					/// @func   set_glyph_color_range()
					/// @desc   Sets per-glyph color for the logical index range [start,end).
					/// @param  {Real} _start_index
					/// @param  {Real} _end_index
					/// @param  {Constant.Color} _color_value
					/// @returns {Struct.WWTextRendererBase}
					#endregion
					static set_glyph_color_range = function(_start_index, _end_index, _color_value) {
					    return set_format_range(_start_index, _end_index, _color_value, undefined, undefined, undefined, undefined, undefined);
					};

					#region jsDoc
					/// @func   set_glyph_alpha_range()
					/// @desc   Sets per-glyph alpha for the logical index range [start,end).
					/// @param  {Real} _start_index
					/// @param  {Real} _end_index
					/// @param  {Real} _alpha_value
					/// @returns {Struct.WWTextRendererBase}
					#endregion
					static set_glyph_alpha_range = function(_start_index, _end_index, _alpha_value) {
					    return set_format_range(_start_index, _end_index, undefined, _alpha_value, undefined, undefined, undefined, undefined);
					};

					#region jsDoc
					/// @func   set_glyph_font_range()
					/// @desc   Sets per-glyph font override for [start,end).
					///         Use -1 to clear override and use renderer font.
					/// @param  {Real} _start_index
					/// @param  {Real} _end_index
					/// @param  {Asset.GMFont|Real} _font_asset_or_minus1
					/// @returns {Struct.WWTextRendererBase}
					#endregion
					static set_glyph_font_range = function(_start_index, _end_index, _font_asset_or_minus1) {
					    return set_format_range(_start_index, _end_index, undefined, undefined, _font_asset_or_minus1, undefined, undefined, undefined);
					};

					#region jsDoc
					/// @func   set_glyph_style_range()
					/// @desc   Sets per-glyph style enum for [start,end).
					/// @param  {Real} _start_index
					/// @param  {Real} _end_index
					/// @param  {Real} _style_value
					/// @returns {Struct.WWTextRendererBase}
					#endregion
					static set_glyph_style_range = function(_start_index, _end_index, _style_value) {
					    return set_format_range(_start_index, _end_index, undefined, undefined, undefined, _style_value, undefined, undefined);
					};

					#region jsDoc
					/// @func   set_glyph_size_range()
					/// @desc   Sets per-glyph size multiplier for [start,end).
					///         Values <= 0 clamp to 1.
					/// @param  {Real} _start_index
					/// @param  {Real} _end_index
					/// @param  {Real} _size_mul
					/// @returns {Struct.WWTextRendererBase}
					#endregion
					static set_glyph_size_range = function(_start_index, _end_index, _size_mul) {
					    return set_format_range(_start_index, _end_index, undefined, undefined, undefined, undefined, _size_mul, undefined);
					};

					#region jsDoc
					/// @func   set_glyph_underline_range()
					/// @desc   Sets per-glyph underline enum for [start,end).
					/// @param  {Real} _start_index
					/// @param  {Real} _end_index
					/// @param  {Real} _underline_value
					/// @returns {Struct.WWTextRendererBase}
					#endregion
					static set_glyph_underline_range = function(_start_index, _end_index, _underline_value) {
					    return set_format_range(_start_index, _end_index, undefined, undefined, undefined, undefined, undefined, _underline_value);
					};

				#endregion
				
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
			font_fallbacks = [];
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
            
			#region jsDoc
			/// @func   clear_format_range()
			/// @desc   Resets glyph formatting back to renderer defaults for [start,end).
			/// @param  {Real} _start_index
			/// @param  {Real} _end_index
			/// @returns {Struct.WWTextRendererBase}
			#endregion
			static clear_format_range = function(_start_index, _end_index) {
			    return set_format_range(
			        _start_index,
			        _end_index,
			        color,
			        alpha,
			        -1,
			        __WW_Text_Glyph_Style.Regular,
			        1,
			        __WW_Text_Glyph_Underline.None
			    );
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
				
				var _glyph_count = __layout__.get_glyph_count();
				var _last_glyph_index = _glyph_count - 1;
				var _last_glyph_buffer_start = __layout__.get_glyph_buffer_index(_last_glyph_index);
				//essentially free to check this so might as well
				if (_buffer_index = _last_glyph_buffer_start) { return _last_glyph_index; };
				var _last_glyph_buffer_end = _last_glyph_buffer_start + __layout__.get_glyph_buffer_size(_last_glyph_index);
				//if at the end, return index+1
				if (_buffer_index >= _last_glyph_buffer_end) { return _last_glyph_index+1; };
				
				
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

			// Unified draw batches (glyphs + underlines + anything else later).
			// Each entry: { material, buffer, format, layer }
			__draw_batches__ = [];
			
			
            // Per-font glyph info cache
            __glyph_cache_font__ = undefined;
            __glyph_cache__ = {};
			
			// A solid 1x1 white sprite is recommended for straight underline.
			// You can set these from outside (or default them if you already have a white pixel sprite).
			underline_sprite_white = spr_ww_pixel;
			underline_sprite_warning = spr_ww_squiggle_underline_yellow;
			underline_sprite_error = spr_ww_squiggle_underline_red;
			
			// Underline tuning
			underline_thickness = 1;     // pixels
			underline_y_offset = -1;     // relative to glyph bottom (negative pulls it up)
			
			// Per-font info cache (avoid rebuilding maps per glyph)
			__font_info_cache__ = {};
			__font_uv_cache__ = {};
			__font_tex_cache__ = {};
			__font_texw_cache__ = {};
			__font_texh_cache__ = {};
			
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
			/// @func   __vb_get_batch_for_material__()
			/// @desc   Returns a VB batch for the given texture+uvs+layer, creating it if needed.
			///         Ensures a single vertex buffer references a single texture page.
			/// @param  {Id.Texture} _tex
			/// @param  {Array} _uvs
			/// @param  {Real} _layer
			/// @returns {Struct} { batch, created }
			#endregion
			static __vb_get_batch_for_material__ = function(_tex, _uvs, _layer) {

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

				var _count = array_length(__draw_batches__);
				var _indx = 0;
				repeat (_count) {
					var _batch = __draw_batches__[_indx];
					if (_batch.layer == _layer) {
						var _m = _batch.material;
						if (!is_undefined(_m) && _m.tex == _tex) {
							var _muv = _m.uvs;
							if (is_array(_muv) && array_length(_muv) >= 4) {
								if (_muv[0] == _u0 && _muv[1] == _v0 && _muv[2] == _u1 && _muv[3] == _v1) {
									return { batch: _batch, created: false };
								}
							}
						}
					}
					_indx++;
				}

				var _vb = vertex_create_buffer();
				var _closure = { vb: _vb, tex: _tex };
				var _draw_fn = method(_closure, function(_x, _y) {
					vertex_submit(vb, pr_trianglelist, tex);
				});
				var _material = new WWMaterial(_draw_fn);
				_material.tex = _tex;
				_material.uvs = _uvs;

				var _new_batch = {
					material : _material,
					buffer   : _vb,
					format   : __vb_format__,
					layer    : _layer
				};

				array_push(__draw_batches__, _new_batch);
				vertex_begin(_new_batch.buffer, _new_batch.format);
				return { batch: _new_batch, created: true };
			};

			#region jsDoc
			/// @func   __glyph_resolve_font_data__()
			/// @desc   Resolves which font should render a glyph, following:
			///         1) explicit override (if valid)
			///         2) renderer font
			///         3) fallback chain (ordered)
			///         Returns a font render data struct from __font_get_render_data__(), or undefined.
			/// @param  {Asset.GMFont|Real|Undefined} _font_override_or_minus1
			/// @param  {String} _char
			/// @returns {Struct|Undefined}
			#endregion
			static __glyph_resolve_font_data__ = function(_font_override_or_minus1, _char) {
				// 1) explicit override
				if (!is_undefined(_font_override_or_minus1) && _font_override_or_minus1 != -1 && font_exists(_font_override_or_minus1)) {
					var _d = __font_get_render_data__(_font_override_or_minus1);
					if (!is_undefined(_d) && !is_undefined(_d.info.glyphs[$ _char])) {
						return _d;
					}
				}

				// 2) renderer font
				if (font_exists(font)) {
					var _d2 = __font_get_render_data__(font);
					if (!is_undefined(_d2) && !is_undefined(_d2.info.glyphs[$ _char])) {
						return _d2;
					}
				}

				// 3) fallbacks
				var _arr = font_fallbacks;
				if (is_array(_arr)) {
					var _n = array_length(_arr);
					var _i = 0;
					repeat (_n) {
						var _fb = _arr[_i];
						if (!is_undefined(_fb) && font_exists(_fb)) {
							var _d3 = __font_get_render_data__(_fb);
							if (!is_undefined(_d3) && !is_undefined(_d3.info.glyphs[$ _char])) {
								return _d3;
							}
						}
						_i++;
					}
				}

				return undefined;
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
				__build_vb__();
				
				__vb_is_dirty__ = false;
			};

			#region jsDoc
			/// @func   __vb_emit_glyph_styled_to_buffer__()
			/// @desc   Emits a styled glyph quad. Handles:
			///         - size multiplier
			///         - italic slant
			///         - bold (double draw with slight offset)
			/// @param  {Id.VertexBuffer} _vb_buffer
			/// @param  {Struct} _font_data : from __font_get_render_data__()
			/// @param  {String} _char
			/// @param  {Real} _pos_x
			/// @param  {Real} _pos_y
			/// @param  {Constant.Color} _col
			/// @param  {Real} _alp
			/// @param  {Real} _size_mul
			/// @param  {Real} _style
			/// @returns {Bool}
			#endregion
			static __vb_emit_glyph_styled_to_buffer__ = function(_vb_buffer, _font_data, _char, _pos_x, _pos_y, _col, _alp, _size_mul, _style) {

			    if (_char == "" || is_undefined(_font_data)) {
			        return false;
			    }

			    if (_size_mul <= 0) {
			        return false;
			    }

			    // Glyph lookup (still uses your existing __glyph_get_info__ cache)
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

			    var _uvs = _font_data.uvs;
			    var _uv_left = _uvs[0];
			    var _uv_top = _uvs[1];
			    var _uv_right = _uvs[2];
			    var _uv_bottom = _uvs[3];

			    var _uv_w = texture_get_texel_width(_font_data.tex);
			    var _uv_h = texture_get_texel_height(_font_data.tex);
				
                var _u0 = _gx * _uv_w;
			    var _v0 = _gy * _uv_h;
			    var _u1 = (_gx + _gw) * _uv_w;
			    var _v1 = (_gy + _gh) * _uv_h;

			    var _xoff = _glyph_info.offset * _size_mul;
			    var _yoff = _glyph_info.yoffset * _size_mul;

			    var _w = _gw * _size_mul;
			    var _h = _gh * _size_mul;

			    var _x0 = _pos_x + _xoff;
			    var _y0 = _pos_y + _yoff;
			    var _x1 = _x0 + _w;
			    var _y1 = _y0 + _h;

			    // Italic slant: top vertices +1, bottom vertices -1
			    var _italic = ((_style == __WW_Text_Glyph_Style.Italic) || (_style == __WW_Text_Glyph_Style.Bold_Italic));
			    var _slant_top = 0;
			    var _slant_bottom = 0;

			    if (_italic) {
			        _slant_top = 1;
			        _slant_bottom = -1;
			    }
				
			    // Normal draw
			    // Triangle 1
			    vertex_position(_vb_buffer, _x0 + _slant_top, _y0);
			    vertex_texcoord(_vb_buffer, _u0, _v0);
			    vertex_colour(_vb_buffer, _col, _alp);
				
			    vertex_position(_vb_buffer, _x1 + _slant_top, _y0);
			    vertex_texcoord(_vb_buffer, _u1, _v0);
			    vertex_colour(_vb_buffer, _col, _alp);
				
			    vertex_position(_vb_buffer, _x1 + _slant_bottom, _y1);
			    vertex_texcoord(_vb_buffer, _u1, _v1);
			    vertex_colour(_vb_buffer, _col, _alp);
				
			    // Triangle 2
			    vertex_position(_vb_buffer, _x0 + _slant_top, _y0);
			    vertex_texcoord(_vb_buffer, _u0, _v0);
			    vertex_colour(_vb_buffer, _col, _alp);
				
			    vertex_position(_vb_buffer, _x1 + _slant_bottom, _y1);
			    vertex_texcoord(_vb_buffer, _u1, _v1);
			    vertex_colour(_vb_buffer, _col, _alp);
				
			    vertex_position(_vb_buffer, _x0 + _slant_bottom, _y1);
			    vertex_texcoord(_vb_buffer, _u0, _v1);
			    vertex_colour(_vb_buffer, _col, _alp);
				
			    // Bold: redraw up-right by 1 pixel (your proposed approach)
			    var _bold = ((_style == __WW_Text_Glyph_Style.Bold) || (_style == __WW_Text_Glyph_Style.Bold_Italic));
			    if (_bold) {
			        // Triangle 1
			        vertex_position(_vb_buffer, _x0 + _slant_top + 1, _y0 + -1);
			        vertex_texcoord(_vb_buffer, _u0, _v0);
			        vertex_colour(_vb_buffer, _col, _alp);

			        vertex_position(_vb_buffer, _x1 + _slant_top + 1, _y0 + -1);
			        vertex_texcoord(_vb_buffer, _u1, _v0);
			        vertex_colour(_vb_buffer, _col, _alp);

			        vertex_position(_vb_buffer, _x1 + _slant_bottom + 1, _y1 + -1);
			        vertex_texcoord(_vb_buffer, _u1, _v1);
			        vertex_colour(_vb_buffer, _col, _alp);

			        // Triangle 2
			        vertex_position(_vb_buffer, _x0 + _slant_top + 1, _y0 + -1);
			        vertex_texcoord(_vb_buffer, _u0, _v0);
			        vertex_colour(_vb_buffer, _col, _alp);

			        vertex_position(_vb_buffer, _x1 + _slant_bottom + 1, _y1 + -1);
			        vertex_texcoord(_vb_buffer, _u1, _v1);
			        vertex_colour(_vb_buffer, _col, _alp);

			        vertex_position(_vb_buffer, _x0 + _slant_bottom + 1, _y1 + -1);
			        vertex_texcoord(_vb_buffer, _u0, _v1);
			        vertex_colour(_vb_buffer, _col, _alp);
			    }

			    return true;
			};
			
			#region jsDoc
/// @func   __ul_flush_span__()
/// @desc   Flushes the current underline span into the correct underline batch.
///         Underline batches are partitioned by sprite texture.
///         This implementation tiles by GEOMETRY (multiple quads) instead of trying to
///         "repeat" by extending UVs past the sprite region (which clamps on atlases).
/// @param  {Struct} _span_state : {active, under, x0, x1, y, col, alp}
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

    // Pick sprite by underline type
    var _spr = underline_sprite_white;
    if (_span_state.under == __WW_Text_Glyph_Underline.Warning) {
        _spr = underline_sprite_warning;
    } else if (_span_state.under == __WW_Text_Glyph_Underline.Error) {
        _spr = underline_sprite_error;
    }

    var _spr_w = sprite_get_width(_spr);
    if (_spr_w <= 0) { _spr_w = 1; }

    var _spr_h = sprite_get_height(_spr);
    if (_spr_h <= 0) { _spr_h = 1; }

	var _tex = sprite_get_texture(_spr, 0);
	var _spr_uvs = sprite_get_uvs(_spr, 0);

	// Layer 0 for underlines
			var _res = __vb_get_batch_for_material__(_tex, _spr_uvs, 0);
	var _ul_vb_buffer = _res.batch.buffer;
    var _u0 = _spr_uvs[0];
    var _v0 = _spr_uvs[1];
    var _u1 = _spr_uvs[2];
    var _v1 = _spr_uvs[3];

    var _du = (_u1 - _u0);

    var _x0 = _span_state.x0;
    var _y0 = _span_state.y;
    var _y1 = _span_state.y + _spr_h;

    // How many segments do we need?
    // full_count = floor(width / spr_w)
    // rem_width  = width - full_count * spr_w
    var _full_count = floor(_width / _spr_w);
    var _rem_width = _width - (_full_count * _spr_w);

    // Emit full tiles
    var _tile_index = 0;
    repeat (_full_count) {

        var _sx0 = _x0 + (_tile_index * _spr_w);
        var _sx1 = _sx0 + _spr_w;

        // Tri 1
        vertex_position(_ul_vb_buffer, _sx0, _y0);
        vertex_texcoord(_ul_vb_buffer, _u0, _v0);
        vertex_colour(_ul_vb_buffer, _span_state.col, _span_state.alp);

        vertex_position(_ul_vb_buffer, _sx1, _y0);
        vertex_texcoord(_ul_vb_buffer, _u1, _v0);
        vertex_colour(_ul_vb_buffer, _span_state.col, _span_state.alp);

        vertex_position(_ul_vb_buffer, _sx1, _y1);
        vertex_texcoord(_ul_vb_buffer, _u1, _v1);
        vertex_colour(_ul_vb_buffer, _span_state.col, _span_state.alp);

        // Tri 2
        vertex_position(_ul_vb_buffer, _sx0, _y0);
        vertex_texcoord(_ul_vb_buffer, _u0, _v0);
        vertex_colour(_ul_vb_buffer, _span_state.col, _span_state.alp);

        vertex_position(_ul_vb_buffer, _sx1, _y1);
        vertex_texcoord(_ul_vb_buffer, _u1, _v1);
        vertex_colour(_ul_vb_buffer, _span_state.col, _span_state.alp);

        vertex_position(_ul_vb_buffer, _sx0, _y1);
        vertex_texcoord(_ul_vb_buffer, _u0, _v1);
        vertex_colour(_ul_vb_buffer, _span_state.col, _span_state.alp);

        _tile_index++;
    }

    // Emit remainder tile (partial width)
    if (_rem_width > 0) {

        var _sx0r = _x0 + (_full_count * _spr_w);
        var _sx1r = _sx0r + _rem_width;

        var _ratio = _rem_width / _spr_w;
        if (_ratio < 0) { _ratio = 0; }
        if (_ratio > 1) { _ratio = 1; }

        var _ur1 = _u0 + (_du * _ratio);

        // Tri 1
        vertex_position(_ul_vb_buffer, _sx0r, _y0);
        vertex_texcoord(_ul_vb_buffer, _u0, _v0);
        vertex_colour(_ul_vb_buffer, _span_state.col, _span_state.alp);

        vertex_position(_ul_vb_buffer, _sx1r, _y0);
        vertex_texcoord(_ul_vb_buffer, _ur1, _v0);
        vertex_colour(_ul_vb_buffer, _span_state.col, _span_state.alp);

        vertex_position(_ul_vb_buffer, _sx1r, _y1);
        vertex_texcoord(_ul_vb_buffer, _ur1, _v1);
        vertex_colour(_ul_vb_buffer, _span_state.col, _span_state.alp);

        // Tri 2
        vertex_position(_ul_vb_buffer, _sx0r, _y0);
        vertex_texcoord(_ul_vb_buffer, _u0, _v0);
        vertex_colour(_ul_vb_buffer, _span_state.col, _span_state.alp);

        vertex_position(_ul_vb_buffer, _sx1r, _y1);
        vertex_texcoord(_ul_vb_buffer, _ur1, _v1);
        vertex_colour(_ul_vb_buffer, _span_state.col, _span_state.alp);

        vertex_position(_ul_vb_buffer, _sx0r, _y1);
        vertex_texcoord(_ul_vb_buffer, _u0, _v1);
        vertex_colour(_ul_vb_buffer, _span_state.col, _span_state.alp);
    }

    _span_state.active = false;
    return;
};

            #region jsDoc
			/// @func   __build_vb__()
			/// @desc   Converts the current layout glyphs into:
			///         1) Glyph VB (single draw call on the active font texture)
			///         2) Underline VB (single draw call on an underline sprite texture)
			///         Notes:
			///         - '\n' and '\r' are not rendered.
			///         - '\t' is not rendered unless whitespace_visible is enabled.
			///         - Whitespace markers render using default font styling.
			///         - All formatting is read directly from glyph records (no highlight runs).
			///         - Underlines are grouped into spans for solid/warn/error.
			///         - Underline VB uses sprites and must be submitted separately.
			///         Limitations (current design):
			///         - If glyph fonts come from different texture pages, this will fall back to default font
			///           for those glyphs (single texture submit constraint).
			#endregion
			static __build_vb__ = function() {
				
			    // Ensure string_width() for marker centering matches the rendered font.
			    var _old_font = draw_get_font();
			    if (font_exists(font)) {
			        draw_set_font(font);
			    }

			    var _layout_data = __layout__.get_layout_data();
			    var _glyphs = _layout_data.glyphs;
			    var _glyph_count = _layout_data.glyphs_count;

			    // Nothing to build
			    if (_glyph_count <= 0) {
			        if (font_exists(_old_font) && _old_font != draw_get_font()) {
			            draw_set_font(_old_font);
			        }
			        return;
			    }

			    // Default font render data (required)
			    var _default_font = font;
			    var _default_font_data = __font_get_render_data__(_default_font);
			    if (is_undefined(_default_font_data)) {
			        if (font_exists(_old_font) && _old_font != draw_get_font()) {
			            draw_set_font(_old_font);
			        }
			        return;
			    }

			    // Batches are created lazily by material+layer as glyphs/spans are emitted.

			    // Underline span state (we build spans as we walk glyphs)
				var _span_state = {
					active : false,
					under : __WW_Text_Glyph_Underline.None,
					x0 : 0,
					x1 : 0,
					y : 0,
					col : color,
					alp : alpha,
				}

				// Walk packed glyph records
				var _glyph_index = 0;
				repeat (_glyph_count) {

					var _base = _glyph_index * __WW_Layout_Glyph.__Size__;
					var _char = _glyphs[_base + __WW_Layout_Glyph.Char];

					// Skip explicit line breaks
					if (_char == "\n" || _char == "\r" || _char == "") {

					    __ul_flush_span__(_span_state);
					    
					    _glyph_index++;
					    continue;
					}

					// Skip tabs unless visualized
					if (_char == "\t" && !whitespace_visible) {

					    __ul_flush_span__(_span_state);
					    
					    _glyph_index++;
					    continue;
					}

					var _pos_x = _glyphs[_base + __WW_Layout_Glyph.X];
					var _pos_y = _glyphs[_base + __WW_Layout_Glyph.Y];
					var _wid = _glyphs[_base + __WW_Layout_Glyph.Width];
					var _hei = _glyphs[_base + __WW_Layout_Glyph.Height];

					// Whitespace visualization (marker glyphs only, no underline)
					if (whitespace_visible) {

					    if (_char == " ") {

					        __ul_flush_span__(_span_state);
					        
					        var _cell_w = _wid;
					        var _mark_char = whitespace_marker_space;
					        var _mark_w = string_width(_mark_char);

					        var _mark_x = _pos_x;
					        if (_cell_w > 0 && _mark_w > 0) {
					            _mark_x = _pos_x + ((_cell_w - _mark_w) * 0.5);
					        }

							var _rws = __vb_get_batch_for_material__(_default_font_data.tex, _default_font_data.uvs, 1);
							__vb_emit_glyph_styled_to_buffer__(
							    _rws.batch.buffer,
							    _default_font_data,
					            _mark_char,
					            _mark_x,
					            _pos_y,
					            whitespace_color,
					            whitespace_alpha,
					            1,
					            __WW_Text_Glyph_Style.Regular
					        );

					        _glyph_index++;
					        continue;
					    }

					    if (_char == "\t") {

					        __ul_flush_span__(_span_state);
					        
					        var _mark_char2 = whitespace_marker_tab;

							var _rws2 = __vb_get_batch_for_material__(_default_font_data.tex, _default_font_data.uvs, 1);
							__vb_emit_glyph_styled_to_buffer__(
							    _rws2.batch.buffer,
							    _default_font_data,
					            _mark_char2,
					            _pos_x,
					            _pos_y,
					            whitespace_color,
					            whitespace_alpha,
					            1,
					            __WW_Text_Glyph_Style.Regular
					        );

					        _glyph_index++;
					        continue;
					    }
					}

					// Resolve per-glyph formatting with sane fallbacks
					var _final_color = _glyphs[_base + __WW_Layout_Glyph.Color];
					var _final_alpha = _glyphs[_base + __WW_Layout_Glyph.Alpha];
					var _final_font  = _glyphs[_base + __WW_Layout_Glyph.Font];
					var _final_style = _glyphs[_base + __WW_Layout_Glyph.Style];
					var _final_size  = _glyphs[_base + __WW_Layout_Glyph.Size_Mul];
					var _final_under = _glyphs[_base + __WW_Layout_Glyph.Underline];
					
					if (is_undefined(_final_color)) { _final_color = color; }
					if (is_undefined(_final_alpha)) { _final_alpha = alpha; }
					if (is_undefined(_final_style)) { _final_style = __WW_Text_Glyph_Style.Regular; }
					if (is_undefined(_final_size) || _final_size <= 0) { _final_size = 1; }
					if (is_undefined(_final_under)) { _final_under = __WW_Text_Glyph_Underline.None; }

					// Resolve which font actually contains this glyph (override -> renderer -> fallbacks).
					var _font_data = __glyph_resolve_font_data__(_final_font, _char);
					if (is_undefined(_font_data)) {
						// No font contains this glyph: break underline span and skip.
						__ul_flush_span__(_span_state);
						_glyph_index++;
						continue;
					}

					// Layer 1 for glyphs (draw after underlines)
					var _rg = __vb_get_batch_for_material__(_font_data.tex, _font_data.uvs, 1);
					__vb_emit_glyph_styled_to_buffer__(
					    _rg.batch.buffer,
					    _font_data,
					    _char,
					    _pos_x,
					    _pos_y,
					    _final_color,
					    _final_alpha,
					    _final_size,
					    _final_style
					);

					// Underline span logic
					if (_final_under != __WW_Text_Glyph_Underline.None) {

					    var _underline_y = _pos_y + (_hei * _final_size) + underline_y_offset;

						if (!_span_state.active) {
							_span_state.active = true;
							_span_state.under = _final_under;
							_span_state.x0 = _pos_x;
							_span_state.x1 = _pos_x + _wid;
							_span_state.y = _underline_y;
							_span_state.col = _final_color;
							_span_state.alp = _final_alpha;
						} else {
							var _same_type = (_span_state.under == _final_under);
							var _same_col = (_span_state.col == _final_color);
							var _same_alp = (_span_state.alp == _final_alpha);
							var _same_y = (_span_state.y == _underline_y);

							if (!_same_type || !_same_col || !_same_alp || !_same_y) {
								__ul_flush_span__(_span_state);
								_span_state.active = true;
								_span_state.under = _final_under;
								_span_state.x0 = _pos_x;
								_span_state.x1 = _pos_x + _wid;
								_span_state.y = _underline_y;
								_span_state.col = _final_color;
								_span_state.alp = _final_alpha;
							} else {
								_span_state.x1 = _pos_x + _wid;
							}
						}

					}
					else {

					    __ul_flush_span__(_span_state);
					}

					_glyph_index++;
				}

				// Flush trailing underline span
				__ul_flush_span__(_span_state);


				// Finalize all batches
				var _indx = 0;
				var _count = array_length(__draw_batches__);
				repeat (_count) {
					vertex_end(__draw_batches__[_indx].buffer);
					_indx++;
				}

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

                // Apply translation without rebuilding the VB.
                var _old_mat = matrix_get(matrix_world);
                matrix_set(matrix_world, matrix_build(_origin_x, _origin_y, 0, 0, 0, 0, 1, 1, 1));
				// Apply texture filtering for better text rendering
				var _old_filt = gpu_get_tex_filter();
				gpu_set_tex_filter(true);
				
				// Pass 0: underlines (layer 0)
				var _indx = 0;
				var _count = array_length(__draw_batches__);
				repeat (_count) {
					var _batch = __draw_batches__[_indx];
					if (_batch.layer == 0) {
						_batch.material.draw(_origin_x, _origin_y);
					}
					_indx++;
				}

				// Pass 1: glyphs (layer 1)
				_indx = 0;
				_count = array_length(__draw_batches__);
				repeat (_count) {
					var _batch2 = __draw_batches__[_indx];
					if (_batch2.layer == 1) {
						_batch2.material.draw(_origin_x, _origin_y);
					}
					_indx++;
				}
				
				// Restore previous world matrix.
                matrix_set(matrix_world, _old_mat);
				// Restore the previous texture filtering
				gpu_set_tex_filter(_old_filt);
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
				
				log("building layout")
				
                var _width_limit = (should_wrap) ? __textbox_parent__.width : infinity;
                
				// -1 means "use renderer font" (so per glyph can override later)
				var _default_font = font;
				
                var _layout = new WWTextLayout();
                
                var _old_font = draw_get_font();
                draw_set_font(_default_font);

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
						    _base_height,

						    undefined,
						    undefined,
						    undefined,
						    undefined,
						    undefined,
						    undefined
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
			/// @func   __font_get_render_data__()
			/// @desc   Returns cached render data for a font:
			///         { tex, uvs, tex_w, tex_h, info }
			/// @param  {Asset.GMFont} _font_asset
			/// @returns {Struct|Undefined}
			#endregion
			static __font_get_render_data__ = function(_font_asset) {

			    if (is_undefined(__font_info_cache__[$ _font_asset])) {

			        var _info = font_get_info(_font_asset);
			        if (is_undefined(_info)) {
			            __font_info_cache__[$ _font_asset] = undefined;
			            return undefined;
			        }

			        var _tex = font_get_texture(_font_asset);
			        var _uvs = font_get_uvs(_font_asset);

			        __font_info_cache__[$ _font_asset] = _info;
			        __font_uv_cache__[$ _font_asset] = _uvs;
			        __font_tex_cache__[$ _font_asset] = _tex;
			        __font_texw_cache__[$ _font_asset] = texture_get_width(_tex);
			        __font_texh_cache__[$ _font_asset] = texture_get_height(_tex);
			    }

			    // Build a tiny struct view (no allocations beyond this struct; if you want zero structs,
			    // you can return multiple values via globals, but this is usually fine.)
			    return {
			        info: __font_info_cache__[$ _font_asset],
			        tex: __font_tex_cache__[$ _font_asset],
			        uvs: __font_uv_cache__[$ _font_asset],
			        tex_w: __font_texw_cache__[$ _font_asset],
			        tex_h: __font_texh_cache__[$ _font_asset]
			    };
			};
			
			#region Cleanup
			
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
			
			#region jsDoc
            /// @func   __vb_free__()
            /// @desc   Frees the owned vertex buffer, if any.
            #endregion
            static __vb_free__ = function() {
				var _indx = 0;
				var _count = array_length(__draw_batches__);
				repeat (_count) {
					var _batch = __draw_batches__[_indx];
					if (!is_undefined(_batch)) {
						if (!is_undefined(_batch.material) && is_callable(_batch.material.destroy)) {
							_batch.material.destroy();
						}
						if (!is_undefined(_batch.buffer)) {
							vertex_delete_buffer(_batch.buffer);
						}
					}
					_indx++;
				}
				__draw_batches__ = [];
            };

			
			#endregion
			
        #endregion
        
    #endregion
    
}


#region jsDoc
/// @enum   __WW_Text_Glyph_Style
/// @desc   Font style override for a run.
///         BOLD is implemented by re-drawing the glyph slightly offset.
///         ITALIC is implemented by slanting vertices.
///         NOTE: These are render-only overrides unless layout is updated too.
#endregion
enum __WW_Text_Glyph_Style {
    Regular,
    Bold,
    Italic,
    Bold_Italic,
	__SIZE__
}

#region jsDoc
/// @enum   __WW_Text_Glyph_Underline
/// @desc   Underline type for a run.
///         None: no underline
///         Line: straight underline
///         Warning/Error: squiggly underline using sprites (separate VB submit)
#endregion
enum __WW_Text_Glyph_Underline {
    None,
    Line,
    Warning,
    Error,
	__SIZE__
}
