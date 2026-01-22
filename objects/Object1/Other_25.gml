build_ui_discord = function(){
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

	#region Theme

		var _page_bg = make_color_rgb(16, 16, 18);

		var _card_bg = make_color_rgb(46, 46, 52);
		var _card_hdr = make_color_rgb(34, 34, 38);

		var _textbox_bg = make_color_rgb(24, 24, 26);

		var _subtitle_color = make_color_rgb(180, 180, 190);
		var _caption_color = make_color_rgb(220, 220, 230);

		var _footer_bg = make_color_rgb(34, 34, 38);
		var _footer_color = make_color_rgb(200, 200, 210);

	#endregion

	#region Page backdrop

		var _page_backdrop = new WWCore()
		    .set_offset(12, 12)
		    .set_size(1256, 696)
		    .set_background_color(_page_bg);
		root.add(_page_backdrop);

	#endregion

	#region Title + Subheader

		var _title_label = new WWLabel()
		    .set_offset(24, 14)
		    .set_size(1232, 30)
		    .set_text("WWTextBoxV3 Demo - Renderer Pairs")
		    .set_text_color(c_white)
		    .set_text_font(fnt_ww_default_big);
		root.add(_title_label);

		var _subtitle_label = new WWLabel()
		    .set_offset(24, 46)
		    .set_size(1232, 20)
		    .set_text("Each panel: left is Base (input), right is a target renderer. Checkboxes toggle each box.")
		    .set_text_color(_subtitle_color);
		root.add(_subtitle_label);

	#endregion

	#region Layout constants

		var _margin_left = 24;
		var _margin_top = 88;
		var _gap_x = 18;
		var _gap_y = 18;

		var _panel_width = 600;
		var _panel_height = 190;

		var _card_pad = 12;
		var _header_height = 26;
		var _textbox_inset = 12;

		var _card_width = _panel_width + (_card_pad * 2);
		var _card_height = _panel_height + (_card_pad * 2);

		var _textbox_xoff = _textbox_inset;
		var _textbox_yoff = _header_height + _textbox_inset;

		var _content_width = _card_width - (_textbox_inset * 2);
		var _content_height = _card_height - _header_height - (_textbox_inset * 2);

		var _textbox_gap = 10;
		var _half_width = floor((_content_width - _textbox_gap) * 0.5);

	#endregion

	#region Panel positions (3 rows x 2 cols)

		var _panel1_x = _margin_left;
		var _panel1_y = _margin_top;

		var _panel2_x = _margin_left + _panel_width + _gap_x;
		var _panel2_y = _margin_top;

		var _panel3_x = _margin_left;
		var _panel3_y = _margin_top + _panel_height + _gap_y;

		var _panel4_x = _margin_left + _panel_width + _gap_x;
		var _panel4_y = _margin_top + _panel_height + _gap_y;

		var _panel5_x = _margin_left;
		var _panel5_y = _margin_top + (_panel_height + _gap_y) * 2;

		var _panel6_x = _margin_left + _panel_width + _gap_x;
		var _panel6_y = _margin_top + (_panel_height + _gap_y) * 2;

	#endregion

	#region Demo texts

		var _text_base =
			"Base input on the left.\n" +
			"Type here and the right side mirrors.\n\n" +
			"Try selection, backspace, and multi-line edits.\n";

		var _text_advanced =
			"Advanced demo input:\n" +
			"Tabs:\n" +
			"\tOne\n" +
			"\tTwo\n\n" +
			"Whitespace markers and underline runs should be visible on the right.\n";

		var _text_scribble =
			"Scribble-ish input idea:\n" +
			"[color=#ffcc00]Colored[/color] [b]Bold[/b] [i]Italic[/i]\n" +
			"Underlines: [u]line[/u]\n";
		
		#region BBCode
		var _text_bbcode =
		    "Godot-style BBCode demo:\n" +
		    "\n" +
		    "[b]Bold text[/b]\n" +
		    "[i]Italic text[/i]\n" +
		    "[u]Underlined text[/u]\n" +
		    "[warn]Warning underline[/warn]\n" +
		    "[err]Error underline[/err]\n" +
		    "\n" +
		    "[color=#66ccff]Colored text (#66ccff)[/color]\n" +
		    "[color=#ff6666]Another color (#ff6666)[/color]\n" +
		    "[alpha=0.5]Half alpha text[/alpha]\n" +
		    "[size=1.5]Scaled text (1.5x)[/size]\n" +
		    "\n" +
		    "[url]URL styled text[/url]\n" +
		    "[url=https://example.com]URL with target[/url]\n" +
		    "\n" +
		    "[code]var x = 10;\nvar y = x * 2;[/code]\n" +
		    "\n" +
		    "Line break test:[br]Second line after br\n" +
		    "\n" +
		    "Paragraph test:[p]New paragraph starts here\n" +
		    "\n" +
		    "[left]Left aligned text[/left]\n" +
		    "[center]Centered text[/center]\n" +
		    "[right]Right aligned text[/right]\n";
		#endregion
		
		#region Markdown
		var _text_markdown =
			"Markdown feature demo:\n" +
			"\n" +
			"# H1 Heading\n" +
			"## H2 Heading\n" +
			"### H3 Heading\n" +
			"\n" +
			"Normal text with **bold**, *italic*, **bold *italic inside* bold**, and ~~strikethrough~~.\n" +
			"\n" +
			"> Blockquote line 1\n" +
			"> Blockquote line 2\n" +
			">\n" +
			"> Blockquote with **bold** and `inline_code`.\n" +
			"\n" +
			"Ordered list:\n" +
			"1. First item\n" +
			"2. Second item\n" +
			"3. Third item\n" +
			"\n" +
			"Unordered list:\n" +
			"- First item\n" +
			"- Second item\n" +
			"- Third item\n" +
			"\n" +
			"Task list:\n" +
			"- [x] Write the press release\n" +
			"- [ ] Update the website\n" +
			"- [ ] Contact the media\n" +
			"\n" +
			"Link: [Example](https://www.example.com)\n" +
			"Image: ![Alt text](image.jpg)\n" +
			"\n" +
			"---\n" +
			"\n" +
			"Table:\n" +
			"| Syntax | Description |\n" +
			"| ----------- | ----------- |\n" +
			"| Header | Title |\n" +
			"| Paragraph | Text |\n" +
			"\n" +
			"Fenced code block:\n" +
			"```\n" +
			"{\n" +
			"  \"firstName\": \"John\",\n" +
			"  \"lastName\": \"Smith\",\n" +
			"  \"age\": 25\n" +
			"}\n" +
			"```\n";
		#endregion

		#region CSS
		var _text_css = string_replace_all(@'<style>
/* Theme-like rules */
.root        { color:#d8dee9; opacity:1; font-size:1em; font-family:ui; }
.muted       { color:#9aa4b2; opacity:0.85; }
.strong      { font-weight:bold; }
.emph        { font-style:italic; }
.link        { color:#7aa2f7; text-decoration:underline; }
.warn        { color:#ffcc66; text-decoration:underline; background-color:#332a10; opacity:0.95; }
.error       { color:#ff5c5c; text-decoration:underline; background-color:#3a1010; opacity:1; }
.strike      { text-decoration:line-through; opacity:0.9; }
.code        { font-family:mono; background-color:#1b1f2a; opacity:1; }
.pill        { background-color:#203049; color:#cde8ff; opacity:1; font-weight:bold; }
.hi_green    { background-color:#103a22; color:#b6ffcf; }
.hi_pink     { background-color:#3a1030; color:#ffd1f0; }
.big         { font-size:1.35em; }
.small       { font-size:0.85em; }
</style><span class="root">CSS Renderer Demo - inline styles + classes + decorations + backgrounds

<span class="muted">This is muted text (class rule: color + opacity).</span>
<span class="strong">This is bold (class rule).</span>
<span class="emph">This is italic (class rule).</span>
<span class="strong emph">This is bold+italic (combined classes).</span>

Inline override beats class:
<span class="muted" style="color:#ffffff; opacity:1">Muted class but forced to bright white with opacity 1.</span>

Underline and strike are independent:
<span class="link">Underlined like a link</span> and
<span class="strike">strike-through for edits</span> and
<span class="link strike">underline + strike together at the same time</span>.

Background highlights:
<span class="hi_green">green highlight</span>,
<span class="hi_pink">pink highlight</span>,
<span class="pill">PILL TAG</span>,
and <span class="code">inline code with mono font + background</span>.

Opacity demo (same color, different opacity):
<span style="color:#7aa2f7; opacity:1">100%</span>
<span style="color:#7aa2f7; opacity:0.7">70%</span>
<span style="color:#7aa2f7; opacity:0.4">40%</span>

Warning / Error style blocks:
<span class="warn">WARNING: This is a warning span with underline + background.</span>
<span class="error">ERROR: This is an error span with underline + background.</span>

Font size demo:
<span class="small">Small text (0.85em)</span>,
<span class="root">Normal text (1.0em)</span>,
<span class="big">Big text (1.35em)</span>.

Tabs (if your parser keeps literal tabs):
	Column A	Column B	Column C
	Alpha		Bravo		Charlie
	One		Two		Three

Wrapping stress test:
This line contains a veryLongIdentifierThatShouldWrapOnlyIfItCannotFitInsideTheWidthOfTheTextbox and also a URL-like token:
https://example.com/some/really/really/really/long/path/that/keeps/going/forever

Nested spans (stack behavior):
Normal <span class="strong">bold <span class="code">bold+code</span> back to bold</span> back to normal.

End of demo.
</span>', "\r", "");
		#endregion
		
		var _text_gml =
			"function demo_example() {\n" +
			"\tvar _counter_value = 0;\n" +
			"\tvar _message_text = \"Hello\";\n\n" +
			"\tif (_counter_value == 0) {\n" +
			"\t\t_message_text += \" - ready\";\n" +
			"\t}\n\n" +
			"\treturn _message_text;\n" +
			"}\n";

	#endregion

	#region Panel helper context

		var _panel_ctx = {
			root_ref: root,

			card_bg: _card_bg,
			card_hdr: _card_hdr,
			caption_color: _caption_color,
			text_bg: _textbox_bg,

			card_pad: _card_pad,
			card_width: _card_width,
			card_height: _card_height,

			header_height: _header_height,
			text_xoff: _textbox_xoff,
			text_yoff: _textbox_yoff,

			content_height: _content_height,
			half_width: _half_width,
			text_gap: _textbox_gap
		};

		#region jsDoc
		/// @func   _panel_make_pair(_panel_x, _panel_y, _title_text, _left_text, _left_setup_fn, _right_setup_fn)
		/// @desc   Builds one panel containing two textboxes (left + right) and two checkboxes.
		///         Left drives right via on_change.
		///         Renderers are assigned explicitly via set_renderer().
		#endregion
		var _panel_make_pair = method(_panel_ctx, function(
			_panel_x,
			_panel_y,
			_title_text,
			_left_text,
			_left_setup_fn,
			_right_setup_fn
		) {
			var root = root_ref;

			var _card_back = new WWCore()
			    .set_offset(_panel_x - card_pad, _panel_y - card_pad)
			    .set_size(card_width, card_height)
			    .set_background_color(card_bg);
			root.add(_card_back);

			var _card_hdr_back = new WWCore()
			    .set_offset(_panel_x - card_pad, _panel_y - card_pad)
			    .set_size(card_width, header_height)
			    .set_background_color(card_hdr);
			root.add(_card_hdr_back);

			var _caption_label = new WWLabel()
			    .set_offset(_panel_x - card_pad + 10, _panel_y - card_pad + 5)
			    .set_size(card_width - 20, header_height)
			    .set_text(_title_text)
			    .set_text_color(caption_color);
			root.add(_caption_label);

			var _left_x = _panel_x - card_pad + text_xoff;
			var _left_y = _panel_y - card_pad + text_yoff;

			var _right_x = _left_x + half_width + text_gap;
			var _right_y = _left_y;

			var _textbox_left = new WWTextBoxV3()
			    .set_offset(_left_x, _left_y)
			    .set_size(half_width, content_height)
			    .set_background_color(text_bg)
			    .set_text(_left_text)
			    .set_text_color(c_white)
			    .set_highlight_color(#78848A)
			    .set_cursor_color(c_white)
			    .set_wrap_enabled(true);

			var _textbox_right = new WWTextBoxV3()
			    .set_offset(_right_x, _right_y)
			    .set_size(half_width, content_height)
			    .set_background_color(text_bg)
			    .set_text(_left_text)
			    .set_text_color(c_white)
			    .set_highlight_color(#78848A)
			    .set_cursor_color(c_white)
			    .set_wrap_enabled(true);
			
			//_textbox_right.__is_focusable__ = false;
			
			if (is_callable(_left_setup_fn)) {
				_left_setup_fn(_textbox_left);
			}
			if (is_callable(_right_setup_fn)) {
				_right_setup_fn(_textbox_right);
			}
			
			// Live mirroring: left -> right
			_textbox_left.on_change(method({ left_ref: _textbox_left, right_ref: _textbox_right }, function() {
				right_ref.set_text(left_ref.get_text());
			}));
			
			root.add(_textbox_left);
			root.add(_textbox_right);

			var _checkbox_size = 18;

			var _checkbox_left = new WWCheckbox()
			    .set_offset((_panel_x - card_pad) + (card_width - 10 - (_checkbox_size * 2) - 8), (_panel_y - card_pad) + 4)
			    .set_size(_checkbox_size, _checkbox_size)
			    .set_value(true)
			    .set_callback(method({ textbox_ref: _textbox_left }, function(_is_checked) {
			    	textbox_ref.set_active(_is_checked);
			    }));

			var _checkbox_right = new WWCheckbox()
			    .set_offset((_panel_x - card_pad) + (card_width - 10 - _checkbox_size), (_panel_y - card_pad) + 4)
			    .set_size(_checkbox_size, _checkbox_size)
			    .set_value(true)
			    .set_callback(method({ textbox_ref: _textbox_right }, function(_is_checked) {
			    	textbox_ref.set_active(_is_checked);
			    }));

			root.add(_checkbox_left);
			root.add(_checkbox_right);
			
			return {
				text_left: _textbox_left,
				text_right: _textbox_right,
				check_left: _checkbox_left,
				check_right: _checkbox_right
			};
		});

	#endregion

	#region Panels

		// Panel 2: Base -> Advanced (renderer owns advanced-only features)
		_panel_make_pair(
			_panel1_x,
			_panel1_y,
			"1) Base -> Advanced (whitespace, font, underline demo)",
			_text_advanced,
			function(_textbox_instance) {
				_textbox_instance.set_renderer(WWTextRendererBase);
				_textbox_instance.set_wrap_enabled(false);
			},
			function(_textbox_instance) {
				
				_textbox_instance.set_renderer(WWTextRendererBase);
				_textbox_instance.set_wrap_enabled(true);
				
				// Font is a textbox concern, keep it here
				_textbox_instance.set_text_font(fnt_ww_consolas_10);
				
				// Advanced-only toggles live on the renderer instance now
				var _renderer = _textbox_instance.get_renderer();
				_renderer.set_whitespace_visible(true);
				_renderer.set_whitespace_alpha(0.45);
			}
		);

		// Panel 2: Base -> BBCode
		_panel_make_pair(
			_panel2_x,
			_panel2_y,
			"2) Base -> BBCode",
			_text_bbcode,
			function(_textbox_instance) {
				_textbox_instance.set_renderer(WWTextRendererBase);
				_textbox_instance.set_wrap_enabled(false);
			},
			function(_textbox_instance) {
				_textbox_instance.set_renderer(WWTextProcessorBBCode);
				_textbox_instance.set_wrap_enabled(true);
			}
		);

		// Panel 3: Base -> Markdown
		_panel_make_pair(
			_panel3_x,
			_panel3_y,
			"3) Base -> Markdown",
			_text_markdown,
			function(_textbox_instance) {
				_textbox_instance.set_renderer(WWTextRendererBase);
				_textbox_instance.set_wrap_enabled(false);
			},
			function(_textbox_instance) {
				_textbox_instance.set_renderer(WWTextProcessorMarkdown);
				_textbox_instance.set_wrap_enabled(true);
				_textbox_instance.set_text_font(fnt_ww_default_small_msdf);
			}
		);

		// Panel 4: Base -> CSS
		_panel_make_pair(
			_panel4_x,
			_panel4_y,
			"4) Base -> CSS",
			_text_css,
			function(_textbox_instance) {
				_textbox_instance.set_renderer(WWTextRendererBase);
				_textbox_instance.set_wrap_enabled(true);
				_textbox_instance.set_text_font(fnt_ww_consolas_msdf);
			},
			function(_textbox_instance) {
				_textbox_instance.set_renderer(WWTextProcessorCSS);
				_textbox_instance.set_wrap_enabled(true);
				_textbox_instance.set_text_font(fnt_ww_consolas_msdf);
			}
		);

		// Panel 5: Base -> Scribble (wire renderer when ready)
		_panel_make_pair(
			_panel5_x,
			_panel5_y,
			"5) Base -> Scribble",
			_text_scribble,
			function(_textbox_instance) {
				_textbox_instance.set_renderer(WWTextRendererBase);
				_textbox_instance.set_wrap_enabled(false);
			},
			function(_textbox_instance) {
				//_textbox_instance.set_renderer(WWTextRendererScribble);
				//_textbox_instance.set_wrap_enabled(true);
			}
		);

		// Panel 6: Base -> GML (wire renderer when ready)
		_panel_make_pair(
			_panel6_x,
			_panel6_y,
			"6) Base -> GML",
			_text_gml,
			function(_textbox_instance) {
				_textbox_instance.set_renderer(WWTextRendererBase);
				_textbox_instance.set_wrap_enabled(false);
				_textbox_instance.set_text_font(fnt_ww_default_small);
			},
			function(_textbox_instance) {
				//_textbox_instance.set_renderer(WWTextRendererGML);
				_textbox_instance.set_wrap_enabled(false);
				_textbox_instance.set_text_font(fnt_ww_default_small_msdf);
			}
		);

	#endregion

	#region Footer

		var _footer_back = new WWCore()
		    .set_offset(24, 684)
		    .set_size(1232, 24)
		    .set_background_color(_footer_bg);
		root.add(_footer_back);

		var _footer_label = new WWLabel()
		    .set_offset(34, 688)
		    .set_size(1212, 18)
		    .set_text("Left drives right. Renderers are assigned explicitly via set_renderer().")
		    .set_text_color(_footer_color);
		root.add(_footer_label);

	#endregion
};

build_ui_folder_demo = function() {
	ww_demo_folder_item_callback = function() {
		var _button = self;

		if (!variable_struct_exists(_button, "__demo_folder_context__")) { exit; }
		if (!variable_struct_exists(_button, "__demo_folder_label__")) { exit; }

		var _context = _button.__demo_folder_context__;
		var _label_text = _button.__demo_folder_label__;

		if (is_struct(_context) && variable_struct_exists(_context, "title_label")) {
			_context.title_label.set_text("Selected: " + _label_text);
		}
	};
	ww_demo_folder_make_item_button = function(_context, _label_text, _width_value, _height_value, _color_text, _color_panel) {
		var _button = new WWButtonText()
			.set_size(_width_value, _height_value)
			.set_text(_label_text)
			.set_text_color(_color_text)
			.set_background_color(_color_panel)
			.set_text_font(fnt_ww_consolas_msdf);

		// No closures: store context + label on the instance.
		_button.__demo_folder_context__ = _context;
		_button.__demo_folder_label__ = _label_text;

		// Shared callback reads from self.
		_button.set_callback(ww_demo_folder_item_callback);

		return _button;
	};

	// ============================================================
	// ROOT
	// ============================================================
	root = new WWCore()
		.set_offset(0, 0)
		.set_size(1280, 720)
		.set_background_color(c_black)
		.set_enabled(true);

	// ============================================================
	// THEME
	// ============================================================
	var _color_page = make_color_rgb(16, 16, 18);
	var _color_panel = make_color_rgb(32, 32, 36);
	var _color_panel_alt = make_color_rgb(40, 40, 46);
	var _color_header = make_color_rgb(26, 26, 30);
	var _color_text = make_color_rgb(230, 230, 235);
	var _color_text_dim = make_color_rgb(170, 170, 180);

	// Page backdrop
	var _page_backdrop = new WWCore()
		.set_offset(10, 10)
		.set_size(1260, 700)
		.set_background_color(_color_page);
	root.add(_page_backdrop);

	// ============================================================
	// LEFT NAV PANEL (FOLDER TREE)
	// ============================================================
	var _nav_panel = new WWCore()
		.set_offset(20, 20)
		.set_size(360, 680)
		.set_background_color(_color_panel);
	root.add(_nav_panel);

	var _nav_header = new WWCore()
		.set_offset(20, 20)
		.set_size(360, 44)
		.set_background_color(_color_header);
	root.add(_nav_header);

	var _nav_title = new WWLabel()
		.set_offset(34, 32)
		.set_size(332, 24)
		.set_text("Navigation")
		.set_text_color(_color_text);
	root.add(_nav_title);

	// This is the container that holds the folder tree
	var _tree_container = new WWFolder()
		.set_offset(20, 64)
		.set_size(0, 0)
		.set_background_color(_color_panel_alt);
	_nav_panel.add(_tree_container);

	// ============================================================
	// RIGHT CONTENT PANEL
	// ============================================================
	var _content_panel = new WWCore()
		.set_offset(400, 20)
		.set_size(860, 680)
		.set_background_color(_color_panel);
	root.add(_content_panel);

	var _content_header = new WWCore()
		.set_offset(400, 20)
		.set_size(860, 44)
		.set_background_color(_color_header);
	root.add(_content_header);

	var _content_title = new WWLabel()
		.set_offset(414, 32)
		.set_size(832, 24)
		.set_text("Selected: (none)")
		.set_text_color(_color_text);
	root.add(_content_title);

	var _content_hint = new WWLabel()
		.set_offset(414, 62)
		.set_size(832, 18)
		.set_text("Click items in the folder tree to update the selection.")
		.set_text_color(_color_text_dim);
	root.add(_content_hint);

	// A simple "log" panel area (just a visual block for now)
	var _log_panel = new WWCore()
		.set_offset(414, 92)
		.set_size(832, 590)
		.set_background_color(_color_panel_alt);
	root.add(_log_panel);

	var _log_header = new WWLabel()
		.set_offset(426, 104)
		.set_size(800, 18)
		.set_text("Content area placeholder")
		.set_text_color(_color_text_dim);
	root.add(_log_header);

	// ============================================================
	// CONTEXT (NO CAPTURED LOCALS)
	// ============================================================
	var _selection_context = {
		title_label: _content_title
	};

	// ============================================================
	// BUILD TREE USING WWFolder
	// ============================================================
	var _folder_basic = new WWFolder()
		.set_offset(10, 10)
				.set_size(340, 0)
		.set_text("Basic")
		.set_children_offsets(18, 4)
		.set_open(true);

	_folder_basic.add(ww_demo_folder_make_item_button(_selection_context, "Bullets", 320, 26, _color_text, _color_panel));
	_folder_basic.add(ww_demo_folder_make_item_button(_selection_context, "Collapsing Headers", 320, 26, _color_text, _color_panel));
	_folder_basic.add(ww_demo_folder_make_item_button(_selection_context, "Combo", 320, 26, _color_text, _color_panel));
	_folder_basic.add(ww_demo_folder_make_item_button(_selection_context, "Color and Picker Widgets", 320, 26, _color_text, _color_panel));
	_folder_basic.add(ww_demo_folder_make_item_button(_selection_context, "Data Types", 320, 26, _color_text, _color_panel));
	_folder_basic.add(ww_demo_folder_make_item_button(_selection_context, "Disable Blocks", 320, 26, _color_text, _color_panel));
	_folder_basic.add(ww_demo_folder_make_item_button(_selection_context, "Drag and Drop", 320, 26, _color_text, _color_panel));
	_folder_basic.add(ww_demo_folder_make_item_button(_selection_context, "Drag and Slider Flags", 320, 26, _color_text, _color_panel));
	_folder_basic.add(ww_demo_folder_make_item_button(_selection_context, "Fonts", 320, 26, _color_text, _color_panel));
	_folder_basic.add(ww_demo_folder_make_item_button(_selection_context, "Images", 320, 26, _color_text, _color_panel));
	_folder_basic.add(ww_demo_folder_make_item_button(_selection_context, "List Boxes", 320, 26, _color_text, _color_panel));
	_folder_basic.add(ww_demo_folder_make_item_button(_selection_context, "Multi-component Widgets", 320, 26, _color_text, _color_panel));
	_folder_basic.add(ww_demo_folder_make_item_button(_selection_context, "Plotting", 320, 26, _color_text, _color_panel));
	_folder_basic.add(ww_demo_folder_make_item_button(_selection_context, "Progress Bars", 320, 26, _color_text, _color_panel));
	_folder_basic.add(ww_demo_folder_make_item_button(_selection_context, "Querying Item Status", 320, 26, _color_text, _color_panel));
	_folder_basic.add(ww_demo_folder_make_item_button(_selection_context, "Querying Window Status", 320, 26, _color_text, _color_panel));
	_folder_basic.add(ww_demo_folder_make_item_button(_selection_context, "Selectables", 320, 26, _color_text, _color_panel));
	_folder_basic.add(ww_demo_folder_make_item_button(_selection_context, "Selection State and Multi-Select", 320, 26, _color_text, _color_panel));
	_folder_basic.add(ww_demo_folder_make_item_button(_selection_context, "Tabs", 320, 26, _color_text, _color_panel));
	_folder_basic.add(ww_demo_folder_make_item_button(_selection_context, "Text", 320, 26, _color_text, _color_panel));
	_folder_basic.add(ww_demo_folder_make_item_button(_selection_context, "Text Filter", 320, 26, _color_text, _color_panel));
	_folder_basic.add(ww_demo_folder_make_item_button(_selection_context, "Text Input", 320, 26, _color_text, _color_panel));
	_folder_basic.add(ww_demo_folder_make_item_button(_selection_context, "Tooltips", 320, 26, _color_text, _color_panel));
	_folder_basic.add(ww_demo_folder_make_item_button(_selection_context, "Tree Nodes", 320, 26, _color_text, _color_panel));
	_folder_basic.add(ww_demo_folder_make_item_button(_selection_context, "Vertical Sliders", 320, 26, _color_text, _color_panel));

	// ------------------------------------------------------------
	// Folder: Layout and Scrolling
	// ------------------------------------------------------------
	var _folder_layout = new WWFolder()
		.set_offset(10, 10)
		.set_size(340, 0)
		.set_text("Layout and Scrolling")
		.set_children_offsets(18, 4)
		.set_open(false);

	_folder_layout.add(ww_demo_folder_make_item_button(_selection_context, "Child windows", 320, 26, _color_text, _color_panel));
	_folder_layout.add(ww_demo_folder_make_item_button(_selection_context, "Widgets Width", 320, 26, _color_text, _color_panel));
	_folder_layout.add(ww_demo_folder_make_item_button(_selection_context, "Basic Horizontal Layout", 320, 26, _color_text, _color_panel));
	_folder_layout.add(ww_demo_folder_make_item_button(_selection_context, "Groups", 320, 26, _color_text, _color_panel));
	_folder_layout.add(ww_demo_folder_make_item_button(_selection_context, "Text Baseline Alignment", 320, 26, _color_text, _color_panel));
	_folder_layout.add(ww_demo_folder_make_item_button(_selection_context, "Scrolling", 320, 26, _color_text, _color_panel));
	_folder_layout.add(ww_demo_folder_make_item_button(_selection_context, "Text Clipping", 320, 26, _color_text, _color_panel));
	_folder_layout.add(ww_demo_folder_make_item_button(_selection_context, "Overlap Mode", 320, 26, _color_text, _color_panel));

	// ------------------------------------------------------------
	// Folder: Popups and Modal Windows
	// ------------------------------------------------------------
	var _folder_popups = new WWFolder()
		.set_offset(10, 10)
		.set_size(340, 0)
		.set_text("Popups and Modal Windows")
		.set_children_offsets(18, 4)
		.set_open(false);

	_folder_popups.add(ww_demo_folder_make_item_button(_selection_context, "Popups", 320, 26, _color_text, _color_panel));
	_folder_popups.add(ww_demo_folder_make_item_button(_selection_context, "Context Menus", 320, 26, _color_text, _color_panel));
	_folder_popups.add(ww_demo_folder_make_item_button(_selection_context, "Modals", 320, 26, _color_text, _color_panel));
	_folder_popups.add(ww_demo_folder_make_item_button(_selection_context, "Menus inside a regular window", 320, 26, _color_text, _color_panel));

	// ============================================================
	// STACK ROOT FOLDERS (EXPLICIT, NO STACK CONTROLLER)
	// ============================================================
	_tree_container.add(_folder_basic);
	_tree_container.add(_folder_layout);
	_tree_container.add(_folder_popups);

	var _stack_y = 10;
	var _stack_gap = 8;

	_folder_basic.set_offset(10, _stack_y);
	_folder_basic.update_component_positions();
	_folder_basic.__update_group_region__();
	_stack_y += _folder_basic.__group__.height + _stack_gap;

	_folder_layout.set_offset(10, _stack_y);
	_folder_layout.update_component_positions();
	_folder_layout.__update_group_region__();
	_stack_y += _folder_layout.__group__.height + _stack_gap;

	_folder_popups.set_offset(10, _stack_y);
	_folder_popups.update_component_positions();
	_folder_popups.__update_group_region__();
	_stack_y += _folder_popups.__group__.height + _stack_gap;

	// ============================================================
	// FINALIZE
	// ============================================================
	root.update_component_positions();
	root.__update_group_region__();
};



