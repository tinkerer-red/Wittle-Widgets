#region jsDoc
/// @func    WWWindow()
/// @desc    A floating container for dialogs, modals, or application windows with draggable, closable, minimizable, and maximizable functionality.
///         Additionally, a custom content/viewport can be provided so that a single component may be treated as the canvas.
/// @returns {Struct.WWWindow}
#endregion
function WWWindow() : WWCore() constructor {
    debug_name = "WWWindow";
    
    #region Public
        
        #region Builder Functions
            #region jsDoc
            /// @func    set_size()
            /// @desc    Sets the component's size (i.e., its interactive boundaries) as specified by the user.
            ///          This updates the region and marks the size as user–preferred so that future internal updates won’t override it.
            /// @self    WWCore
            /// @param   {real} width : The new width.
            /// @param   {real} height : The new height.
            /// @returns {Struct.WWCore}
            #endregion
            static set_size = function(_width, _height) {
                __size_set__ = true;
                __set_size__(_width, _height);
                titleBar.set_size(self.width, 30);
                // If content is set, update its size or reposition if needed.
                if(content) {
                    // For instance, we might want content to fill the remaining window area.
                    content.set_offset(0, 30);
                    content.set_size(self.width, self.height - 30);
                }
                return self;
            }
            
            #region jsDoc
            /// @func    set_title()
            /// @desc    Sets the window's title text.
            /// @self    WWWindow
            /// @param   {String} _title : The title text.
            /// @returns {Struct.WWWindow}
            #endregion
            static set_title = function(_title) {
                titleLabel.set_text(_title);
                return self;
            }
            
            #region jsDoc
            /// @func    set_content()
            /// @desc    Sets the content (viewport) of the window. This component should be a WWCore (or derivative).
            /// @self    WWWindow
            /// @param   {Struct.WWCore} _content : The content component.
            /// @returns {Struct.WWWindow}
            #endregion
            static set_content = function(_content) {
                // If a previous content exists, remove it.
                if(content) {
                    self.remove(content);
                }
                content = _content;
                // Position the content below the titleBar.
                content.set_offset(0, 30);
                // Fill the remaining area of the window.
                content.set_size(self.width, self.height - 30);
                self.add(content);
                return self;
            }
        #endregion
        
        #region Components
        // Create a Title Bar with close, minimize, and maximize buttons, plus a title label.
        titleBar = new WWButton()
            .set_offset(0, 0)
            .set_size(self.width, 30)
            .set_background_color(c_dkgray);
        
        // Minimize Button (positioned next to maximize)
        minimizeButton = new WWButtonText()
            .set_alignment(fa_right, fa_top)
            .set_offset(-105, 0)
            .set_size(30, 30)
            .set_text("_")
            .set_callback(function() {
                if (!minimized) {
                    // Save current height then minimize.
                    originalSize.height = self.height;
                    self.set_size(self.width, titleBar.height);
                    minimized = true;
                } else {
                    // Restore previous height.
                    self.set_size(self.width, originalSize.height);
                    minimized = false;
                }
                update_component_positions();
            });
        
        // Maximize Button (positioned next to minimize)
        maximizeButton = new WWButtonText()
            .set_alignment(fa_right, fa_top)
            .set_offset(-70, 0)
            .set_size(30, 30)
            .set_text("[ ]")
            .set_callback(function() {
                if (!maximized) {
                    // Save current size and position.
                    originalSize = { width: self.width, height: self.height };
                    originalOffset = { x: self.x, y: self.y };
                    // Maximize to full screen (or desired maximum size).
                    self.set_offset(0, 0);
                    self.set_size(1280, 720);
                    maximized = true;
                } else {
                    // Restore original size and position.
                    self.set_offset(originalOffset.x, originalOffset.y);
                    self.set_size(originalSize.width, originalSize.height);
                    maximized = false;
                }
                update_component_positions();
            });
        
        // Close Button (positioned at the far right)
        closeButton = new WWButtonText()
            .set_alignment(fa_right, fa_top)
            .set_offset(-35, 0)
            .set_size(30, 30)
            .set_text("X")
            .set_callback(function() {
                __parent__.remove(self);
            });
        
        // Title Label
        titleLabel = new WWLabel()
            .set_offset(10, 5)
            .set_text("Window");
        
        // Add control buttons and label to the title bar.
        titleBar.add(maximizeButton);
        titleBar.add(minimizeButton);
        titleBar.add(closeButton);
        titleBar.add(titleLabel);
        self.add(titleBar);
        #endregion
        
        #region Events
        // Use titleBar's events to handle dragging.
        titleBar.on_pressed(function(_input) {
            // Record initial drag offset.
            dragOffsetX = device_mouse_x_to_gui(0) - self.x;
            dragOffsetY = device_mouse_y_to_gui(0) - self.y;
        });
        titleBar.on_interact(function(_input) {
            // Update window position based on current mouse position.
            self.set_offset(device_mouse_x_to_gui(0) - dragOffsetX, device_mouse_y_to_gui(0) - dragOffsetY);
        });
		#endregion
        
        #region Variables
        // State variables for dragging, minimizing, and maximizing.
        dragOffsetX = 0;
        dragOffsetY = 0;
        minimized = false;
        maximized = false;
        originalSize = { width: self.width, height: self.height };
        originalOffset = { x: self.x, y: self.y };
        // Content variable to hold custom viewport.
        content = undefined;
        #endregion
        
        #region Functions
        static center = function() {
            self.set_offset((1280 - self.width) / 2, (720 - self.height) / 2);
            return self;
        }
        #endregion
        
    #endregion
        
    #region Private
        #region Variables
        // Private variables can be added here if needed.
        #endregion
        
        #region Functions
        // Private helper functions can be added here.
        #endregion
    #endregion
}
