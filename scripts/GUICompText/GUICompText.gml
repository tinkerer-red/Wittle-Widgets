#region jsDoc
/// @func    GUICompText()
/// @desc    A basic text rendering component with support for alignment, colors, and multi-line text.
/// @return  {Struct.GUICompText}
#endregion
function GUICompText() : GUICompCore() constructor {
    debug_name = "GUICompText";

    #region Public
		
		#region Builder
			
			#region jsDoc
			/// @func    set_text_color()
			/// @desc    Sets the colors for the text.
			/// @self    GUICompScrollingText
			/// @param   {Real} color : The color to draw the text
			/// @returns {Struct.GUICompScrollingText}
			#endregion
			static set_text_color = function(_color=c_white) {
				text.color = _color;
				
				return self;
			}
			
		#endregion
		
        #region Events
            
            on_pre_draw(function() {
                if (visible) {
                    //set font color
					
					draw_set_font(text.font);
					draw_set_color(text.color);
					draw_set_alpha(text.alpha);
					draw_set_halign(text.halign);
					draw_set_valign(text.valign);
					
					draw_text(
						x + text.xoff,
						y + text.yoff,
						text.content
					)
					
                }
            });

        #endregion
		
		#region variables
			
			text.color = c_white;
			
		#endregion

    #endregion
}

#region jsDoc
/// @func    GUICompTextScribble()
/// @desc    A basic text rendering component with support for alignment, colors, and multi-line text.
/// @return  {Struct.GUICompTextScribble}
#endregion
function GUICompTextScribble() : GUICompCore() constructor {
    debug_name = "GUICompTextScribble";

    #region Public
		
		#region Builder
			
			static set_scribble = function(_scrib) {
				my_scribble = _scrib;
				return self;
			}
			static set_scribble_typist = function(_typist) {
				my_typist = _typist;
				return self;
			}
			
		#endregion
		
        #region Events
            
            on_pre_draw(function() {
                if (visible) {
                    //set font color
					my_scribble.draw(
						x + text.xoff,
						y + text.yoff,
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
}
