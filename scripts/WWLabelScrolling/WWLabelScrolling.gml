#region jsDoc
/// @func    WWLabelScrolling()
/// @desc    Creates a scrolling text component
/// @self    WWLabelScrolling
/// @returns {Struct.WWLabelScrolling}
#endregion
function WWLabelScrolling() : WWViewScrollAuto() constructor {
	debug_name = "WWLabelScrolling"
	
	#region Public
		
		#region Builder functions
			
			#region jsDoc
			/// @func    set_text()
			/// @desc    Sets the label text displayed by the internal canvas.
			/// @self    WWLabelScrolling
			/// @param   {String} text : The text to display.
			/// @returns {Struct.WWLabelScrolling}
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
			/// @desc    Sets the font used for drawing the label text.
			/// @self    WWLabelScrolling
			/// @param   {Asset.GMFont} font : The font to use when drawing the text.
			/// @returns {Struct.WWLabelScrolling}
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
			/// @desc    Sets the color used for drawing the label text.
			/// @self    WWLabelScrolling
			/// @param   {Real} color : The color to draw the text.
			/// @returns {Struct.WWLabelScrolling}
			#endregion
			static set_text_color = function(_color=c_white) {
				canvas.set_text_color(_color)
				
				return self;
			}
			static set_color = set_text_color;
			#region jsDoc
			/// @func    set_text_alpha()
			/// @desc    Sets the alpha used for drawing the label text.
			/// @self    WWLabelScrolling
			/// @param   {Real} alpha : The alpha to draw the text.
			/// @returns {Struct.WWLabelScrolling}
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
		
		#region Variables
			
		#endregion
		
		#region Functions
		
			#region Getters
				#region jsDoc
				/// @func    get_text()
				/// @desc    Returns the current label text.
				/// @self    WWLabelScrolling
				/// @returns {String}
				#endregion
				static get_text = function() {
					return canvas.get_text();
				}
				#region jsDoc
				/// @func    get_text_font()
				/// @desc    Returns the font currently used by the label.
				/// @self    WWLabelScrolling
				/// @returns {Asset.GMFont}
				#endregion
				static get_text_font = function() {
					return canvas.get_text_font();
				}
				#region jsDoc
				/// @func    get_text_color()
				/// @desc    Returns the current label text color.
				/// @self    WWLabelScrolling
				/// @returns {Real}
				#endregion
				static get_text_color = function() {
					return canvas.get_text_color();
				}
				static get_color = get_text_color;
				#region jsDoc
				/// @func    get_text_alpha()
				/// @desc    Returns the current label text alpha.
				/// @self    WWLabelScrolling
				/// @returns {Real}
				#endregion
				static get_text_alpha = function() {
					return canvas.get_text_alpha();
				}
			#endregion
			
			
		#endregion
		
		
	#endregion
	
}

function WWLabelScribbleScrolling() : WWLabelScrolling() constructor {
	
	#region Public
		
		#region Builder functions
			
			#region jsDoc
			/// @func    set_scribble()
			/// @desc    Sets the scribble instance used to render text.
			/// @self    WWLabelScribbleScrolling
			/// @param   {Any} scribble
			/// @returns {Struct.WWLabelScribbleScrolling}
			#endregion
			static set_scribble = function(_scrib) {
				canvas.set_scribble(_scrib)
				
				if (!__size_set__) {
					__update_viewport_from_canvas__()
				}
				return self;
			}
			#region jsDoc
			/// @func    set_scribble_typist()
			/// @desc    Sets the scribble typist instance used for typewriter/animated text.
			/// @self    WWLabelScribbleScrolling
			/// @param   {Any} typist
			/// @returns {Struct.WWLabelScribbleScrolling}
			#endregion
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


