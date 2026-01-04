Dbuild_ui_discord = function(){
	// 🌟 Root GUI (Discord Window)
	root = new WWCore()
	    .set_offset(0, 0)
	    .set_size(1280, 720)
	    .set_enabled(true);

	// 🌟 Left Sidebar: Servers
	serverSidebar = new WWCore()
	    .set_offset(0, 0)
	    .set_size(80, 720)
	    .set_background_color(c_dkgray);

	// Add several server icons (using button sprites for interactivity)
	var serverIcons = ["🟣", "🟢", "🔵", "🟠", "🔴"];
	var srvY = 20;
	for (var i = 0; i < array_length(serverIcons); i++) {
	    var serverButton = new WWButtonText()
	        .set_offset(10, srvY)
	        .set_size(60, 60)
	        .set_text(serverIcons[i])
	        .set_callback(function() { log("Server clicked!"); });
	    serverSidebar.add(serverButton);
	    srvY += 80;
	}
	root.add(serverSidebar);

	// 🌟 Body Left Sidebar: Channels and Categories
	channelSidebar = new WWCore()
	    .set_offset(80, 0)
	    .set_size(240, 720)
	    .set_background_color(c_gray);

	// Category: Text Channels
	var textCategory = new WWLabel()
	    .set_offset(10, 20)
	    .set_text("TEXT CHANNELS")
	    .set_text_color(c_ltgray);
	channelSidebar.add(textCategory);

	// Add some text channels
	var textChannels = ["general", "random", "music", "coding"];
	var chanY = 50;
	for (var i = 0; i < array_length(textChannels); i++) {
	    var chanButton = new WWButtonText()
	        .set_offset(10, chanY)
	        .set_size(220, 30)
	        .set_text("# " + textChannels[i])
	        .set_callback(function() { log("Channel selected!"); });
	    channelSidebar.add(chanButton);
	    chanY += 40;
	}

	// Category: Voice Channels
	var voiceCategory = new WWLabel()
	    .set_offset(10, chanY + 10)
	    .set_text("VOICE CHANNELS")
	    .set_text_color(c_ltgray);
	channelSidebar.add(voiceCategory);
	chanY += 50;
	var voiceChannels = ["General", "Gaming", "Study"];
	for (var i = 0; i < array_length(voiceChannels); i++) {
	    var voiceButton = new WWButtonText()
	        .set_offset(10, chanY)
	        .set_size(220, 30)
	        .set_text("🔊 " + voiceChannels[i])
	        .set_callback(function() { log("Voice channel selected!"); });
	    channelSidebar.add(voiceButton);
	    chanY += 40;
	}
	root.add(channelSidebar);

	// 🌟 Header (Top Bar of Chat Area)
	header = new WWCore()
	    .set_offset(320, 0)
	    .set_size(680, 60)
	    .set_background_color(c_dkgray);

	// Channel name
	channelName = new WWLabel()
	    .set_offset(20, 15)
	    .set_text("# general")
	    .set_text_color(c_white);
	header.add(channelName);

	// Pinned post icon
	pinnedIcon = new WWButtonText()
	    .set_offset(300, 15)
	    .set_size(30, 30)
	    .set_text("📌")
	    .set_callback(function() { log("Pinned clicked"); });
	header.add(pinnedIcon);

	// Threads icon
	threadsIcon = new WWButtonText()
	    .set_offset(340, 15)
	    .set_size(30, 30)
	    .set_text("🧵")
	    .set_callback(function() { log("Threads clicked"); });
	header.add(threadsIcon);

	// Notification icon
	notificationIcon = new WWButtonText()
	    .set_offset(380, 15)
	    .set_size(30, 30)
	    .set_text("🔔")
	    .set_callback(function() { log("Notifications clicked"); });
	header.add(notificationIcon);

	// Pin icon
	pinIcon = new WWButtonText()
	    .set_offset(420, 15)
	    .set_size(30, 30)
	    .set_text("📌")
	    .set_callback(function() { log("Pin toggled"); });
	header.add(pinIcon);

	// Hide member list icon
	hideMembersIcon = new WWButtonText()
	    .set_offset(460, 15)
	    .set_size(30, 30)
	    .set_text("👤")
	    .set_callback(function() { log("Member list toggled"); });
	header.add(hideMembersIcon);

	root.add(header);

	// 🌟 Main Document: Chat Messages Area
	chatArea = new WWCore()
	    .set_offset(320, 60)
	    .set_size(680, 540)
	    .set_background_color(c_black);

	// Add some sample messages
	var messages = [
	    { user: "Alice", time: "10:01 AM", content: "Hello everyone!" },
	    { user: "Bob", time: "10:02 AM", content: "Hi Alice! How's it going?" },
	    { user: "Charlie", time: "10:03 AM", content: "Good morning all!" }
	];
	var msgY = 10;
	for (var i = 0; i < array_length(messages); i++) {
	    var msgBox = new WWCore()
	        .set_offset(10, msgY)
	        .set_size(660, 80)
	        .set_background_color(c_dkgray);
    
	    // User picture (placeholder)
	    var userPic = new WWCore()
	        .set_offset(10, 10)
	        .set_size(60, 60)
	        .set_background_color(c_gray);
	    msgBox.add(userPic);
    
	    // Username and time
	    var userInfo = new WWLabel()
	        .set_offset(80, 10)
	        .set_text(messages[i].user + "  •  " + messages[i].time)
	        .set_text_color(c_white);
	    msgBox.add(userInfo);
    
	    // Message content
	    var msgContent = new WWLabel()
	        .set_offset(80, 40)
	        .set_text(messages[i].content)
	        .set_text_color(c_ltgray);
	    msgBox.add(msgContent);
    
	    chatArea.add(msgBox);
	    msgY += 90;
	}
	root.add(chatArea);

	// 🌟 Right Sidebar: Activities & Online Members
	rightSidebar = new WWCore()
	    .set_offset(1000, 60)
	    .set_size(280, 540)
	    .set_background_color(c_dkgray);

	// Header for online members
	membersHeader = new WWLabel()
	    .set_offset(10, 10)
	    .set_text("ONLINE")
	    .set_text_color(c_white);
	rightSidebar.add(membersHeader);

	// List of members (sample)
	var members = [
	    { name: "Alice", status: "Online" },
	    { name: "Bob", status: "Idle" },
	    { name: "Charlie", status: "Do Not Disturb" }
	];
	var memY = 40;
	for (var i = 0; i < array_length(members); i++) {
	    var memberEntry = new WWButtonText()
	        .set_offset(10, memY)
	        .set_size(260, 40)
	        .set_text(members[i].name + " - " + members[i].status)
	        .set_callback(function() { log("Member clicked"); });
	    rightSidebar.add(memberEntry);
	    memY += 50;
	}
	root.add(rightSidebar);

	// 🌟 Footer: Message Input & Emotes
	footer = new WWCore()
	    .set_offset(320, 600)
	    .set_size(960, 120)
	    .set_background_color(c_dkgray);

	// Message input box
	messageInput = new WWCore()
	    .set_offset(20, 20)
	    .set_size(700, 40)
	    .set_background_color(c_white);
	footer.add(messageInput);

	// Gift button
	giftButton = new WWButtonText()
	    .set_offset(740, 20)
	    .set_size(40, 40)
	    .set_text("🎁")
	    .set_callback(function() { log("Gift sent!"); });
	footer.add(giftButton);

	// Emotes button
	emotesButton = new WWButtonText()
	    .set_offset(790, 20)
	    .set_size(40, 40)
	    .set_text("😀")
	    .set_callback(function() { log("Emotes opened!"); });
	footer.add(emotesButton);

	root.add(footer);

}

build_ui_youtube = function(){
	// 🌟 Root GUI
	root = new WWCore()
	    .set_offset(0, 0)
	    .set_size(1280, 720)
	    .set_enabled(true);

	// 🌟 Top Navigation Bar
	navBar = new WWCore()
	    .set_offset(0, 0)
	    .set_size(1280, 60)
	    .set_background_color(c_black);

	    // 📌 Logo
	    logo = new WWLabel()
	        .set_offset(20, 15)
	        .set_text("YouTube")
	        .set_text_color(c_red)
	        //.set_font_size(24);
	    navBar.add(logo);

	    // 📌 Search Bar
	    searchBox = new WWCore()
	        .set_offset(400, 15)
	        .set_size(400, 30)
	        //.set_placeholder("Search")
	        .set_background_color(c_white);
	    navBar.add(searchBox);

	    // 📌 Profile Button
	    profileButton = new WWButtonText()
	        .set_offset(1150, 10)
	        .set_size(100, 40)
	        .set_text("Profile")
	        .set_callback(function() { log("Profile clicked!"); });
	    navBar.add(profileButton);

	root.add(navBar);

	// 🌟 Sidebar Menu
	sideBar = new WWCore()
	    .set_offset(0, 60)
	    .set_size(200, 660)
	    .set_background_color(c_dkgray);

	    menuItems = [
	        "🏠 Home",
	        "🔥 Trending",
	        "📺 Subscriptions",
	        "📚 Library",
	        "🕒 History",
	        "🎵 Music",
	        "🎮 Gaming",
	        "📺 Live"
	    ];

	    var yOffset = 20;
	    for (var i = 0; i < array_length(menuItems); i++) {
	        var menuButton = new WWButtonText()
	            .set_offset(10, yOffset)
	            .set_size(180, 40)
	            .set_text(menuItems[i])
	            .set_callback(function() { log(menuItems[i] + " clicked!"); });

	        sideBar.add(menuButton);
	        yOffset += 50;
	    }

	root.add(sideBar);

	// 🌟 Main Content Area (Videos)
	videoGrid = new WWCore()
	    .set_offset(220, 80)
	    .set_size(1040, 600);

	var videoTitles = [
	    "How to Make a Game in GML",
	    "Top 10 Blender Tips",
	    "GameMaker Studio 2 Advanced Tricks",
	    "How to Optimize Your Code",
	    "Let's Build a GUI Framework!",
	    "The Secret to Smooth Animations",
	    "Why Game Development is Hard",
	    "How I Built My Own Compiler"
	];

	var channelNames = [
	    "Code Master",
	    "Blender Guru",
	    "GML Dev",
	    "Performance Tips",
	    "Game Dev Lab",
	    "UI/UX Hacks",
	    "Indie Dev Life",
	    "Compiler Genius"
	];

	var yOffset = 0;
	for (var i = 0; i < array_length(videoTitles); i++) {
	    var videoBox = new WWCore()
	        .set_offset((i % 2) * 500, yOffset)
	        .set_size(480, 150)
	        .set_background_color(c_dkgray);

	        // Thumbnail
	        var thumbnail = new WWCore()
	            .set_offset(10, 10)
	            .set_size(200, 120)
	            .set_background_color(c_black);
	        videoBox.add(thumbnail);

	        // Title
	        var titleText = new WWLabel()
	            .set_offset(220, 10)
	            .set_size(250, 50)
	            .set_text(videoTitles[i])
	            .set_text_color(c_white);
	        videoBox.add(titleText);

	        // Channel Name
	        var channelText = new WWLabel()
	            .set_offset(220, 70)
	            .set_text(channelNames[i])
	            .set_text_color(c_ltgray);
	        videoBox.add(channelText);

	    videoGrid.add(videoBox);

	    if (i % 2 == 1) yOffset += 160; // Move to next row every 2 videos
	}

	root.add(videoGrid);

}

build_ui_window_test = function(){
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

}

build_ui_inline_test = function(){
	// ROOT GUI (Main Application Window)
	root = new WWCore()
	    .set_offset(0, 0)
	    .set_size(1280, 720)
	    .set_background_color(c_black)
	    .set_enabled(true);
	
	// Define the inline operator marker (instance of a dummy WWInline object)
	var inline_op = new WWInline();
	
	// Add components inline to the root container.
	root.add_inline([ 
	    new WWLabel().set_text("Dashboard Title").set_background_color(c_dkgray).set_color(c_white),
	    new WWLabel().set_text("A brief description goes here.").set_background_color(c_gray).set_color(c_white),
	    new WWDivider().set_color(c_ltgray),
	    new WWButtonText().set_text("Option 1").set_background_color(c_blue),
	    inline_op,
	    new WWButtonText().set_text("Option 2").set_background_color(c_blue),
	    inline_op,
	    new WWButtonText().set_text("Option 3").set_background_color(c_blue),
	    new WWDivider().set_color(c_ltgray),
	    new WWButtonText().set_text("Confirm").set_background_color(c_blue),
	    inline_op,
	    new WWButtonText().set_text("Cancel").set_background_color(c_blue)
	], 10, 10, true); // 10 pixels spacing horizontally and vertically, scale components to fill the line.
	
}

build_ui_text_boxes = function(){
	// Root GUI
	root = new WWCore()
	    .set_offset(0, 0)
	    .set_size(1280, 720)
	    .set_background_color(c_black)
	    .set_enabled(true);

	// -------------------------------------------------------------
	// Theme (higher contrast, less "flat grey")
	// -------------------------------------------------------------
	var _page_bg = make_color_rgb(16, 16, 18);

	var _card_bg = make_color_rgb(46, 46, 52);
	var _card_hdr = make_color_rgb(34, 34, 38);

	var _textbox_bg = make_color_rgb(24, 24, 26);

	var _subtitle_color = make_color_rgb(180, 180, 190);
	var _caption_color = make_color_rgb(220, 220, 230);

	var _footer_bg = make_color_rgb(34, 34, 38);
	var _footer_color = make_color_rgb(200, 200, 210);

	// -------------------------------------------------------------
	// Page backdrop
	// -------------------------------------------------------------
	var _page_backdrop = new WWCore()
	    .set_offset(12, 12)
	    .set_size(1256, 696)
	    .set_background_color(_page_bg);
	root.add(_page_backdrop);

	// -------------------------------------------------------------
	// Title + Subheader
	// -------------------------------------------------------------
	var _title_label = new WWLabel()
	    .set_offset(24, 14)
	    .set_size(1232, 30)
	    .set_text("WWTextBoxV3 Demo - 4 configurations")
	    .set_text_color(c_white)
	    .set_text_font(fGUIDefaultBig);
	root.add(_title_label);

	var _subtitle_label = new WWLabel()
	    .set_offset(24, 46)
	    .set_size(1232, 20)
	    .set_text("Selection, wrapping, fonts, and color themes. Each box is interactive.")
	    .set_text_color(_subtitle_color);
	root.add(_subtitle_label);

	// -------------------------------------------------------------
	// Layout constants
	// -------------------------------------------------------------
	var _margin_left = 24;
	var _margin_top = 88;
	var _gap_x = 18;
	var _gap_y = 18;

	var _panel_width = 600;
	var _panel_height = 300;

	var _panel1_x = _margin_left;
	var _panel1_y = _margin_top;

	var _panel2_x = _margin_left + _panel_width + _gap_x;
	var _panel2_y = _margin_top;

	var _panel3_x = _margin_left;
	var _panel3_y = _margin_top + _panel_height + _gap_y;

	var _panel4_x = _margin_left + _panel_width + _gap_x;
	var _panel4_y = _margin_top + _panel_height + _gap_y;

	// Card geometry
	var _card_pad = 12;
	var _header_height = 26;
	var _textbox_inset = 12;

	var _card_width = _panel_width + (_card_pad * 2);
	var _card_height = _panel_height + (_card_pad * 2);

	var _textbox_xoff = _textbox_inset;
	var _textbox_yoff = _header_height + _textbox_inset;

	var _textbox_width = _card_width - (_textbox_inset * 2);
	var _textbox_height = _card_height - _header_height - (_textbox_inset * 2);

	// -------------------------------------------------------------
	// Panel 1
	// -------------------------------------------------------------
	var _card1 = new WWCore()
	    .set_offset(_panel1_x - _card_pad, _panel1_y - _card_pad)
	    .set_size(_card_width, _card_height)
	    .set_background_color(_card_bg);
	root.add(_card1);

	var _card1_hdr = new WWCore()
	    .set_offset(_panel1_x - _card_pad, _panel1_y - _card_pad)
	    .set_size(_card_width, _header_height)
	    .set_background_color(_card_hdr);
	root.add(_card1_hdr);

	var _caption_1 = new WWLabel()
	    .set_offset(_panel1_x - _card_pad + 10, _panel1_y - _card_pad + 5)
	    .set_size(_card_width - 20, _header_height)
	    .set_text("1) No wrap - short text, fast caret movement")
	    .set_text_color(_caption_color);
	root.add(_caption_1);

	var _text_1 =
		"Quick input, no wrapping.\n" +
		"Try arrow keys, selection, and backspace.\n\n" +
		"Tip: This is perfect for chat or command bars";

	var _textbox_1 = new WWTextBoxV3()
	    .set_offset(_panel1_x - _card_pad + _textbox_xoff, _panel1_y - _card_pad + _textbox_yoff)
	    .set_size(_textbox_width, _textbox_height)
	    .set_background_color(_textbox_bg)
	    .set_text(_text_1)
	    .set_text_color(c_white)
	    .set_highlight_color(c_aqua)
	    .set_cursor_color(c_white)
	    .set_wrap_enabled(false);
	root.add(_textbox_1);

	// -------------------------------------------------------------
	// Panel 2
	// -------------------------------------------------------------
	var _card2 = new WWCore()
	    .set_offset(_panel2_x - _card_pad, _panel2_y - _card_pad)
	    .set_size(_card_width, _card_height)
	    .set_background_color(_card_bg);
	root.add(_card2);

	var _card2_hdr = new WWCore()
	    .set_offset(_panel2_x - _card_pad, _panel2_y - _card_pad)
	    .set_size(_card_width, _header_height)
	    .set_background_color(_card_hdr);
	root.add(_card2_hdr);

	var _caption_2 = new WWLabel()
	    .set_offset(_panel2_x - _card_pad + 10, _panel2_y - _card_pad + 5)
	    .set_size(_card_width - 20, _header_height)
	    .set_text("2) Wrap enabled - paragraph formatting")
	    .set_text_color(_caption_color);
	root.add(_caption_2);

	var _text_2 =
		"Word wrap is enabled here. Type a long sentence and watch the layout rebuild.\n\n" +
		"This mode is ideal for notes, rich text, and long descriptions.";

	var _textbox_2 = new WWTextBoxV3()
	    .set_offset(_panel2_x - _card_pad + _textbox_xoff, _panel2_y - _card_pad + _textbox_yoff)
	    .set_size(_textbox_width, _textbox_height)
	    .set_background_color(_textbox_bg)
	    .set_text(_text_2)
	    .set_text_color(c_white)
	    .set_highlight_color(c_lime)
	    .set_cursor_color(c_white)
	    .set_wrap_enabled(true);
	root.add(_textbox_2);

	// -------------------------------------------------------------
	// Panel 3
	// -------------------------------------------------------------
	var _card3 = new WWCore()
	    .set_offset(_panel3_x - _card_pad, _panel3_y - _card_pad)
	    .set_size(_card_width, _card_height)
	    .set_background_color(_card_bg);
	root.add(_card3);

	var _card3_hdr = new WWCore()
	    .set_offset(_panel3_x - _card_pad, _panel3_y - _card_pad)
	    .set_size(_card_width, _header_height)
	    .set_background_color(_card_hdr);
	root.add(_card3_hdr);
	
	var _caption_3 = new WWLabel()
	    .set_offset(_panel3_x - _card_pad + 10, _panel3_y - _card_pad + 5)
	    .set_size(_card_width - 20, _header_height)
	    .set_text("3) Code editor - wrap off, tabs, indentation")
	    .set_text_color(_caption_color);
	root.add(_caption_3);
	
	var _text_3 =
	    "function demo_example() {\n" +
	    "\tvar _counter_value = 0;          //underline this line uses a normal underline\n" +
	    "\tvar _message_text = \"Hello from WWTextBoxV3\";\n\n" +
	    "\tif (_counter_value == 0) {        //warn this branch is suspicious\n" +
	    "\t\t_message_text += \" - ready\";\n" +
	    "\t}\n\n" +
	    "\tif (_counter_value < 0) {         //error this should never happen\n" +
	    "\t\t_message_text = undefined;\n" +
	    "\t}\n\n" +
	    "\t// Try selecting across lines and deleting.\n" +
	    "\treturn _message_text;             //err forced error underline test\n" +
	    "}\n";
	
	var _textbox_3 = new WWTextBoxV3()
	    .set_offset(_panel3_x - _card_pad + _textbox_xoff, _panel3_y - _card_pad + _textbox_yoff)
	    .set_size(_textbox_width, _textbox_height)
	    .set_background_color(#222222)
	    .set_text_font(fnt_consolas_10)
	    .set_text(_text_3)
	    .set_text_color(c_white)
	    .set_highlight_color(#78848A)
	    .set_cursor_color(c_white)
	    .set_wrap_enabled(false);
	
	ww_apply_demo_syntax_to_textbox(_textbox_3);
	
	root.add(_textbox_3);
	
	
	// -------------------------------------------------------------
	// Panel 4
	// -------------------------------------------------------------
	var _card4 = new WWCore()
	    .set_offset(_panel4_x - _card_pad, _panel4_y - _card_pad)
	    .set_size(_card_width, _card_height)
	    .set_background_color(_card_bg);
	root.add(_card4);

	var _card4_hdr = new WWCore()
	    .set_offset(_panel4_x - _card_pad, _panel4_y - _card_pad)
	    .set_size(_card_width, _header_height)
	    .set_background_color(_card_hdr);
	root.add(_card4_hdr);

	var _caption_4 = new WWLabel()
	    .set_offset(_panel4_x - _card_pad + 10, _panel4_y - _card_pad + 5)
	    .set_size(_card_width - 20, _header_height)
	    .set_text("4) Styled - different font/theme, wrap on")
	    .set_text_color(_caption_color);
	root.add(_caption_4);

	var _text_4 =
		"Styled demo:\n" +
		"- Different highlight color\n" +
		"- Different background color\n" +
		"- Wrap enabled for comfortable reading\n\n" +
		"Lorem ipsum dolor sit amet, consectetur adipiscing elit. " +
		"Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\n\n" +
		"Try pasting a big chunk of text here.";

	var _textbox_4 = new WWTextBoxV3()
	    .set_offset(_panel4_x - _card_pad + _textbox_xoff, _panel4_y - _card_pad + _textbox_yoff)
	    .set_size(_textbox_width, _textbox_height)
	    .set_background_color(make_color_rgb(22, 22, 30))
	    .set_text(_text_4)
	    .set_text_color(c_white)
	    .set_highlight_color(c_fuchsia)
	    .set_cursor_color(c_white)
	    .set_wrap_enabled(true);
	root.add(_textbox_4);

	// -------------------------------------------------------------
	// Footer
	// -------------------------------------------------------------
	var _footer_back = new WWCore()
	    .set_offset(24, 684)
	    .set_size(1232, 24)
	    .set_background_color(_footer_bg);
	root.add(_footer_back);

	var _footer_label = new WWLabel()
	    .set_offset(34, 688)
	    .set_size(1212, 18)
	    .set_text("Hint: Shift+Arrow selects. Test Backspace/Delete near wraps. Tabs are preserved in the code sample.")
	    .set_text_color(_footer_color);
	root.add(_footer_label);
};


