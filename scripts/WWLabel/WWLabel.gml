#region jsDoc
/// @func    WWLabel()
/// @desc    Lightweight, size-dynamic label built on top of WWTextRenderer.
///          Internally it is the same renderer pipeline, but:
///          - exposes only basic configuration
///          - automatically updates its own size when rendered content changes
/// @returns  {Struct.WWLabel}
#endregion
function WWLabel() : WWTextRenderer() constructor {

    debug_name = "WWLabel";

    #region Public

        #region Builder
			
			static set_color = set_text_color;
            static get_color = get_text_color;

            #region jsDoc
            /// @func   get_text()
            /// @desc   Returns caption text.
            /// @self   WWLabel
            /// @returns {String}
            #endregion
            static get_text = function() {
                return get_caption();
            };

            #region jsDoc
            /// @func   get_text_font()
            /// @desc   Returns the font currently used by the label.
            /// @self   WWLabel
            /// @returns {Asset.GMFont}
            #endregion
            static get_text_font = function() {
                return get_font();
            };
			
            #region jsDoc
            /// @func   set_text()
            /// @desc   Sets caption text. Label auto-sizes to content.
            /// @self   WWLabel
            /// @param  {String} text
            /// @returns {Struct.WWLabel}
            #endregion
            static set_text = function(_text) {
                set_caption(_text);
                __label_update_size__();
                return self;
            };

            #region jsDoc
            /// @func   set_text_font()
            /// @desc   Sets font. Label auto-sizes to content.
            /// @self   WWLabel
            /// @param  {Asset.GMFont} font
            /// @returns {Struct.WWLabel}
            #endregion
            static set_text_font = function(_font) {
                set_font(_font);
                __label_update_size__();
                return self;
            };
			
            #region jsDoc
            /// @func   set_text_processor()
            /// @desc   Sets the text processor (bbcode/markdown/css/etc) for this label,
            ///         then auto-sizes to content.
            /// @self   WWLabel
            /// @param  {Any} proc_or_name
            /// @returns {Struct.WWLabel}
            #endregion
            static set_text_processor = function(_proc_or_name) {
				static __base_set_text_processor__ = WWTextRenderer.set_text_processor;
				static __base_clear_text_processor__ = WWTextRenderer.clear_text_processor;
				
				var _proc = _proc_or_name;
				if (is_string(_proc_or_name)) {
					var _name = string_lower(string_trim(_proc_or_name));
					switch (_name) {
						case "bbcode":
							_proc = asset_get_index("WWTextProcessorBBCode");
							break;
						case "md":
						case "markdown":
							_proc = asset_get_index("WWTextProcessorMarkdown");
							break;
						case "css":
							_proc = asset_get_index("WWTextProcessorCss");
							break;
						default:
							_proc = undefined;
							break;
					}
				}
				
				if (is_callable(_proc)) {
					__base_set_text_processor__(_proc);
				}
				else {
					__base_clear_text_processor__();
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

            #region jsDoc
            /// @func    __label_update_size__()
            /// @desc    Internal: ensures layout and syncs this label's size to its rendered content.
            /// @self    WWLabel
            /// @returns {Undefined}
            /// @ignore
            #endregion
            static __label_update_size__ = function() {
				__ensure_layout__();

                var _width = get_content_width();
                var _height = get_content_height();

                __set_size__(_width, _height);
            };

        #endregion

    #endregion
}
