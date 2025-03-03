#region jsDoc
/// @func    WWText()
/// @desc    A basic text rendering component with support for alignment, colors, and multi-line text.
/// @return  {Struct.WWText}
#endregion
function WWText() : WWCore() constructor {
    debug_name = "WWText";

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
						x + text.xoff,
						y + text.yoff,
						text.content
					)
					
                }
            });

        #endregion
		
		#region Variables
			
			text = {
					content : "<undefined>",
					font : fGUIDefault,
					
					xoff : 0,
					yoff : 0,
					click_yoff : 0,
					
					width  : 0,
					height : 0,
					
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
				__set_size__(0,0,string_width(text.content), string_height(text.content));
				draw_set_font(_prev);
			}
			
		#endregion
	
	#endregion
}

#region jsDoc
/// @func    WWTextScribble()
/// @desc    A basic text rendering component with support for alignment, colors, and multi-line text.
/// @return  {Struct.WWTextScribble}
#endregion
function WWTextScribble() : WWCore() constructor {
    debug_name = "WWTextScribble";

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
					0,
					0,
					my_scribble.get_right() - my_scribble.get_left(),
					my_scribble.get_bottom() - my_scribble.get_top()
				);
			}
			
		#endregion
	
	#endregion
}


