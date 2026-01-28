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
            /// @returns {String}
            #endregion
            static get_text = function() {
                return get_caption();
            };

            #region jsDoc
            /// @func   get_text_font()
            /// @desc   Returns the font currently used by the label.
            /// @returns {Asset.GMFont}
            #endregion
            static get_text_font = function() {
                return get_font();
            };
			
            #region jsDoc
            /// @func   set_text()
            /// @desc   Sets caption text. Label auto-sizes to content.
            /// @param  {String} _text
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
            /// @param  {Asset.GMFont} _font
            /// @returns {Struct.WWLabel}
            #endregion
            static set_text_font = function(_font) {
                set_font(_font);
                __label_update_size__();
                return self;
            };
			
            #region jsDoc
            /// @func   set_renderer()
            /// @desc   Swap the active renderer implementation (processor/render style),
            ///         then auto-size to content. This assumes your base has a setter for it.
            /// @param  {Any} _renderer_id_or_kind
            /// @returns {Struct.WWLabel}
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
