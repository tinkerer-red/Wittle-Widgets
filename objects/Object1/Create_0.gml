// ============================================================
// ROOT GUI (Main Application Window)
root = new WWCore()
    .set_offset(0, 0)
    .set_size(1280, 720)
    .set_background_color(c_black)
    .set_enabled(true);

// ============================================================
// SETTINGS WINDOW
// ============================================================
settingsWindow = new WWWindow()
    .set_offset(50, 50)
    .set_size(600, 500)
    .set_title("Settings")
    .set_background_color(c_dkgray)
    .center();

// -- General Settings Panel --
generalPanel = new WWPanel()
    .set_offset(20, 60)
    .set_size(560, 180)
    .set_background_color(c_gray);

// Header Label
generalLabel = new WWLabel()
    .set_offset(10, 10)
    .set_text("General Settings")
    .set_color(c_white)
    .set_background_color(c_gray);
generalPanel.add(generalLabel);

// Divider for visual separation
generalDivider = new WWDivider()
    .set_offset(10, 40)
    .set_size(540, 2)
    .set_thickness(2)
    .set_color(c_ltgray);
generalPanel.add(generalDivider);

// Progress Bar (simulate installation or load progress)
progressBar = new WWProgressBar()
    .set_offset(10, 130)
    .set_size(540, 20)
    .set_background_color(c_ltgray)
    .set_value(0.65);  // 65% complete
generalPanel.add(progressBar);

// Clickable Button (using WWButtonText) to reset settings.
resetButton = new WWButtonText()
    .set_offset(10, 80)
    .set_size(200, 30)
    .set_background_color(c_blue)
    .set_text("Reset Settings")
    .set_callback(function() {
        // When clicked, show a toast notification on the Settings window.
        toast = new WWToast()
            .set_offset(200, 300)
            .set_background_color(c_dkgray)
            .set_message("Settings have been reset!")
            .set_duration(120);
        settingsWindow.add(toast);
    });
// Attach a tooltip to the reset button.
resetTooltip = new WWTooltip()
    .set_offset(0, -30)  // Position above the button
    .set_background_color(c_ltgray)
    .set_text("Click to reset settings to defaults")
    .set_delay(30);
resetButton.add(resetTooltip);
generalPanel.add(resetButton);

// Add General Panel to Settings Window
settingsWindow.add(generalPanel);

// -- Advanced Settings Panel --
advancedPanel = new WWPanel()
    .set_offset(20, 260)
    .set_size(560, 200)
    .set_background_color(c_gray);

// Header Label for Advanced Settings
advancedLabel = new WWLabel()
    .set_offset(10, 10)
    .set_text("Advanced Settings")
    .set_color(c_white)
    .set_background_color(c_gray);
advancedPanel.add(advancedLabel);

// Divider
advancedDivider = new WWDivider()
    .set_offset(10, 40)
    .set_size(540, 2)
    .set_thickness(2)
    .set_color(c_ltgray);
advancedPanel.add(advancedDivider);

// Add some descriptive labels
descLabel1 = new WWLabel()
    .set_offset(10, 60)
    .set_text("Feature X: Enabled")
    .set_color(c_white)
    .set_background_color(c_gray);
advancedPanel.add(descLabel1);

descLabel2 = new WWLabel()
    .set_offset(10, 90)
    .set_text("Feature Y: Disabled")
    .set_color(c_white)
    .set_background_color(c_gray);
advancedPanel.add(descLabel2);

// Add Advanced Panel to Settings Window
settingsWindow.add(advancedPanel);

// Add Settings Window to Root
root.add(settingsWindow);

// ============================================================
// DASHBOARD WINDOW
// ============================================================
dashboardWindow = new WWWindow()
    .set_offset(700, 50)
    .set_size(500, 600)
    .set_title("Dashboard")
    .set_background_color(c_dkgray)
    .center();

// -- Statistics Panel --
statsPanel = new WWPanel()
    .set_offset(20, 60)
    .set_size(460, 150)
    .set_background_color(c_gray);

// Header Label for Stats
statsLabel = new WWLabel()
    .set_offset(10, 10)
    .set_text("Statistics")
    .set_color(c_white)
    .set_background_color(c_gray);
statsPanel.add(statsLabel);

// Divider
statsDivider = new WWDivider()
    .set_offset(10, 40)
    .set_size(440, 2)
    .set_thickness(2)
    .set_color(c_ltgray);
statsPanel.add(statsDivider);

// Multiple statistic labels
stat1 = new WWLabel()
    .set_offset(10, 60)
    .set_text("Users Online: 123")
    .set_color(c_white)
    .set_background_color(c_gray);
statsPanel.add(stat1);

stat2 = new WWLabel()
    .set_offset(10, 90)
    .set_text("Messages Today: 456")
    .set_color(c_white)
    .set_background_color(c_gray);
statsPanel.add(stat2);

stat3 = new WWLabel()
    .set_offset(10, 120)
    .set_text("Server Load: 75%")
    .set_color(c_white)
    .set_background_color(c_gray);
statsPanel.add(stat3);

// Add Stats Panel to Dashboard Window
dashboardWindow.add(statsPanel);

// -- Activity Panel --
activityPanel = new WWPanel()
    .set_offset(20, 230)
    .set_size(460, 200)
    .set_background_color(c_gray);

// Header Label for Activity
activityLabel = new WWLabel()
    .set_offset(10, 10)
    .set_text("Recent Activity")
    .set_color(c_white)
    .set_background_color(c_gray);
activityPanel.add(activityLabel);

// Divider
activityDivider = new WWDivider()
    .set_offset(10, 40)
    .set_size(440, 2)
    .set_thickness(2)
    .set_color(c_ltgray);
activityPanel.add(activityDivider);

// Simulated activity messages
activityMsg1 = new WWLabel()
    .set_offset(10, 60)
    .set_text("Server rebooted at 12:01 PM")
    .set_color(c_white)
    .set_background_color(c_gray);
activityPanel.add(activityMsg1);

activityMsg2 = new WWLabel()
    .set_offset(10, 90)
    .set_text("New user registered: JohnDoe")
    .set_color(c_white)
    .set_background_color(c_gray);
activityPanel.add(activityMsg2);

activityMsg3 = new WWLabel()
    .set_offset(10, 120)
    .set_text("Backup completed at 11:45 AM")
    .set_color(c_white)
    .set_background_color(c_gray);
activityPanel.add(activityMsg3);

// Add Activity Panel to Dashboard Window
dashboardWindow.add(activityPanel);

// -- Item List Panel with Scrollbar Buttons --
// This panel simulates a list of items that exceeds the viewport height.
itemListViewport = new WWPanel()
    .set_offset(20, 450)
    .set_size(420, 150)
    .set_background_color(c_gray);

// The content panel (with a larger height than the viewport)
itemListContent = new WWPanel()
    .set_offset(0, 0)
    .set_size(420, 300)  // Content is taller than viewport
    .set_background_color(c_dkgray);

// Populate the content with items.
var itemY = 10;
for (var i = 0; i < 10; i++) {
    var itemLabel = new WWLabel()
        .set_offset(10, itemY)
        .set_text("Item " + string(i + 1))
        .set_color(c_white)
        .set_background_color(c_dkgray);
    itemListContent.add(itemLabel);
    itemY += 30;
}
itemListViewport.add(itemListContent);

// Create the scrollbar with buttons.
itemListScrollbar = new WWScrollbarButtons()
    .set_offset(440, 450)  // Positioned to the right of the viewport
    .set_size(40, 150)
    .set_background_color(c_gray)
    .set_canvas_size(300)      // Full content height of itemListContent
    .set_coverage_size(150)    // Visible area equals viewport height
    .on_interact(function() {
        // Map the slider's normalized value (0 to 1) to a scroll offset.
        var normalized = itemListScrollbar.slider.get_value();
        var maxScroll = 300 - 150; // Content height - viewport height.
        var newOffset = -normalized * maxScroll;
        itemListContent.set_offset(0, newOffset);
    });

// Add the item list viewport and scrollbar to the Dashboard Window.
dashboardWindow.add(itemListViewport);
dashboardWindow.add(itemListScrollbar);

// Add Dashboard Window to Root
root.add(dashboardWindow);

// ============================================================
// GLOBAL STARTUP TOAST NOTIFICATION
// ============================================================
startupToast = new WWToast()
    .set_offset(600, 10)
    .set_background_color(c_dkgray)
    .set_message("Welcome to the Application Dashboard!")
    .set_duration(180);
root.add(startupToast);
