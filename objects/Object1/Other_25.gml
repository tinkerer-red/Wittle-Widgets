/// @description Insert description here
// You can write your code in this editor
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
	var textCategory = new WWText()
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
	var voiceCategory = new WWText()
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
	channelName = new WWText()
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
	    var userInfo = new WWText()
	        .set_offset(80, 10)
	        .set_text(messages[i].user + "  •  " + messages[i].time)
	        .set_text_color(c_white);
	    msgBox.add(userInfo);
    
	    // Message content
	    var msgContent = new WWText()
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
	membersHeader = new WWText()
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
	    logo = new WWText()
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
	        var titleText = new WWText()
	            .set_offset(220, 10)
	            .set_size(250, 50)
	            .set_text(videoTitles[i])
	            .set_text_color(c_white);
	        videoBox.add(titleText);

	        // Channel Name
	        var channelText = new WWText()
	            .set_offset(220, 70)
	            .set_text(channelNames[i])
	            .set_text_color(c_ltgray);
	        videoBox.add(channelText);

	    videoGrid.add(videoBox);

	    if (i % 2 == 1) yOffset += 160; // Move to next row every 2 videos
	}

	root.add(videoGrid);

}