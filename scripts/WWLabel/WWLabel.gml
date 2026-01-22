/*
#region jsDoc
/// @func    WWLabel()
/// @desc    A basic text rendering component with support for alignment, colors, and multi-line text.
/// @return  {Struct.WWLabel}
#endregion
function WWLabel() : WWCore() constructor {
    debug_name = "WWLabel";

    #region Public
		
		#region Builder
			
			#region Text
			#region jsDoc
			/// @func    set_text()
			/// @desc    Sets the variables for text drawing
			/// @self    WWButtonText
			/// @param   {String} text : The text to write on the button.
			/// @returns {Struct.WWButtonText}
			#endregion
			static set_text = function(_text="DefaultText") {
				text.content = _text
				__update_region_from_text__();
				return self;
			}
			#region jsDoc
			/// @func    set_text_font()
			/// @desc    Sets the font which will be used for drawing the text
			/// @self    WWButtonText
			/// @param   {Asset.GMFont} font : The font to use when drawing the text
			/// @returns {Struct.WWButtonText}
			#endregion
			static set_text_font = function(_font=fGUIDefault) {
				text.font = _font;
				__update_region_from_text__();
				return self;
			}
			#region jsDoc
			/// @func    set_text_color()
			/// @desc    Sets the colors for the text.
			/// @self    WWScrollingText
			/// @param   {Real} color : The color to draw the text
			/// @returns {Struct.WWScrollingText}
			#endregion
			static set_text_color = function(_color=c_white) {
				text.color = _color;
				
				return self;
			}
			static set_color = set_text_color;
			#endregion
			
		#endregion
		
        #region Events
            
            on_pre_draw(function() {
                if (visible) {
                    //set font color
					draw_set_font(text.font);
					draw_set_color(text.color);
					draw_set_alpha(text.alpha);
					
					draw_text(
						x,
						y,
						text.content
					)
					
                }
            });

        #endregion
		
		#region Variables
			
			text = {
					content : "<undefined>",
					font : fnt_ww_default_small,
					alpha : 1,
					color : c_white,
				}
			
		#endregion

    #endregion
	
	#region Private
	
		#region Functions
			
			static __update_region_from_text__ = function() {
				var _prev = draw_get_font();
				draw_set_font(text.font);
				__set_size__(string_width(text.content), string_height(text.content));
				draw_set_font(_prev);
			}
			
		#endregion
	
	#endregion
}
//*/

#region jsDoc
/// @func    WWLabelScribble()
/// @desc    A basic text rendering component with support for alignment, colors, and multi-line text.
/// @return  {Struct.WWLabelScribble}
#endregion
function WWLabelScribble() : WWCore() constructor {
    debug_name = "WWLabelScribble";

    #region Public
		
		#region Builder
			
			static set_scribble = function(_scrib) {
				my_scribble = _scrib;
				__update_region_from_text__()
				return self;
			}
			static set_scribble_typist = function(_typist) {
				my_typist = _typist;
				__update_region_from_text__()
				return self;
			}
			
		#endregion
		
        #region Events
            
            on_pre_draw(function() {
                if (visible) {
                    //set font color
					my_scribble.draw(
						x - my_scribble.get_left(),
						y - my_scribble.get_top(),
						my_typist
					)
					
                }
            });

        #endregion
		
		#region variables
			
			my_scribble = scribble("");
			my_typist   = undefined;
			
		#endregion
		
		#region Functions
		
		static get_scribble = function() {
			return my_scribble;
		}
		static get_typist = function() {
			return my_typist;
		}
		
		#endregion
		
    #endregion
	
	#region Private
	
		#region Functions
			
			static __update_region_from_text__ = function() {
				__set_size__(
					my_scribble.get_right() - my_scribble.get_left(),
					my_scribble.get_bottom() - my_scribble.get_top()
				);
			}
			
		#endregion
	
	#endregion
}


#region jsDoc
/// @func    WWLabelRenderer()
/// @desc    Lightweight, size-dynamic label built on top of WWTextRendererBase.
///          Internally it is the same renderer pipeline, but:
///          - exposes only basic configuration
///          - automatically updates its own size when rendered content changes
/// @return  {Struct.WWLabelRenderer}
#endregion
function WWLabel() : WWTextRendererBase() constructor {

    debug_name = "WWLabelRenderer";

    #region Public

        #region Builder

            #region jsDoc
            /// @func   set_text()
            /// @desc   Sets caption text. Label auto-sizes to content.
            /// @param  {String} _text
            /// @returns {Struct.WWLabelRenderer}
            #endregion
            static set_text = function(_text) {
                set_caption(_text);
                __label_update_size__();
                return self;
            };

            #region jsDoc
            /// @func   set_text_font()
            /// @desc   Sets font. Label auto-sizes to content.
            /// @param  {Asset.GMFont} _font
            /// @returns {Struct.WWLabelRenderer}
            #endregion
            static set_text_font = function(_font) {
                set_font(_font);
                __label_update_size__();
                return self;
            };
			
            #region jsDoc
            /// @func   set_text_alpha()
            /// @desc   Sets alpha. Does not affect size.
            /// @param  {Real} _alpha
            /// @returns {Struct.WWLabelRenderer}
            #endregion
            static set_text_alpha = function(_alpha) {
                set_alpha(_alpha);
                return self;
            };

            #region jsDoc
            /// @func   set_renderer()
            /// @desc   Swap the active renderer implementation (processor/render style),
            ///         then auto-size to content. This assumes your base has a setter for it.
            /// @param  {Any} _renderer_id_or_kind
            /// @returns {Struct.WWLabelRenderer}
            #endregion
            static set_text_processor = function(_proc_or_name) {
				if (is_string(_proc_or_name)) {
					var _name = string_lower(_proc_or_name);
					switch (_name) {
					    case "bbcode":   set_text_processor(_proc_or_name); break;
					    case "md":
						case "markdown": set_text_processor(_proc_or_name); break;
					    case "css":      set_text_processor(_proc_or_name); break;
					    default: clear_text_processor(); break;
					}
				}
				else {
					set_text_processor(_proc_or_name);
				}

                __label_update_size__();
                return self;
            };

        #endregion

        #region Events

            on_change(function() {
                __label_update_size__();
            });

        #endregion

    #endregion

    #region Private

        #region Functions

            static __label_update_size__ = function() {
				__ensure_layout__();

                var _width = get_content_width();
                var _height = get_content_height();

                __set_size__(_width, _height);
            };

        #endregion

    #endregion
}
