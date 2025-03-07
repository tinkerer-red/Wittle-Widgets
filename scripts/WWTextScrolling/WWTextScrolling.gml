#region jsDoc
/// @func    WWLabelScrolling()
/// @desc    Creates a scrolling text component
/// @self    WWLabelScrolling
/// @param   {Real} x : The x possition of the component on screen.
/// @param   {Real} y : The y possition of the component on screen.
/// @return {Struct.WWLabelScrolling}
#endregion
function WWLabelScrolling() : WWScrollingCanvas() constructor {
	debug_name = "WWLabelScrolling"
	
	#region Public
		
		#region Builder functions
			
			#region jsDoc
			/// @func    set_text()
			/// @desc    Sets the variables for text drawing
			/// @self    WWScrollingText
			/// @param   {String} text : The text to write on the button
			/// @param   {Real} text.click_yoff : How much the text should be moved when the mouse button is held down on the button
			/// @returns {Struct.WWScrollingText}
			#endregion
			static set_text = function(_text="DefaultText") {
				canvas.set_text(_text)
				
				if (!__size_set__) {
					__update_viewport_from_canvas__();
				}
				
				return self;
			}
			#region jsDoc
			/// @func    set_text_font()
			/// @desc    Sets the font which will be used for drawing the text
			/// @self    WWScrollingText
			/// @param   {Asset.GMFont} font : The font to use when drawing the text
			/// @returns {Struct.WWScrollingText}
			#endregion
			static set_text_font = function(_font=fGUIDefault) {
				canvas.set_text_font(_font)
				
				if (!__size_set__) {
					__update_viewport_from_canvas__();
				}
				
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
				canvas.set_text_color(_color)
				
				return self;
			}
			#region jsDoc
			/// @func    set_text_alpha()
			/// @desc    Sets the alpha for the text.
			/// @self    WWScrollingText
			/// @param   {Real} alpha : The alpha to draw the text
			/// @returns {Struct.WWScrollingText}
			#endregion
			static set_text_alpha = function(_alpha=1) {
				canvas.set_text_alpha(_alpha)
				
				return self;
			}
			
		#endregion
		
		#region Components
			
			// Automatically set up a WWLabel canvas
			set_canvas(new WWLabel());
			
		#endregion
		
		
	#endregion
	
}

function WWLabelScribbleScrolling() : WWLabelScrolling() constructor {
	
	#region Public
		
		#region Builder functions
			
			static set_scribble = function(_scrib) {
				canvas.set_scribble(_scrib)
				
				if (!__size_set__) {
					__update_viewport_from_canvas__()
				}
				return self;
			}
			static set_scribble_typist = function(_typist) {
				canvas.set_scribble_typist(_typist);
				
				if (!__size_set__) {
					__update_viewport_from_canvas__()
				}
				return self;
			}
			
		#endregion
		
		#region Components
			
			// Automatically set up a WWLabelScribble canvas
			set_canvas(new WWLabelScribble());
			
		#endregion
		
	#endregion
	
}


