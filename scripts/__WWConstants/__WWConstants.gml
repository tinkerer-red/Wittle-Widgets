#macro WW_VERSION    "2.0.0"   // Used for version checking.
#macro WW_EXISTS     true      // Used for checking if the library exists.

// Platforms
#macro WW_ON_WINDOWS  (os_type == os_windows)
#macro WW_ON_MACOS    (os_type == os_macosx)
#macro WW_ON_LINUX    (os_type == os_linux)
#macro WW_ON_DESKTOP  (WW_ON_WINDOWS || WW_ON_MACOS || WW_ON_LINUX)
#macro WW_ON_IOS      (os_type == os_ios || os_type == os_tvos)
#macro WW_ON_ANDROID  (os_type == os_android)
#macro WW_ON_MOBILE   (WW_ON_IOS || WW_ON_ANDROID)
#macro WW_ON_XBOX     ((os_type == os_xboxone) || (os_type == os_xboxseriesxs))
#macro WW_ON_PS4      (os_type == os_ps4)
#macro WW_ON_PS5      (os_type == os_ps5)
#macro WW_ON_PS       (WW_ON_PS4 || WW_ON_PS5)
#macro WW_ON_SWITCH   (os_type == os_switch)
#macro WW_ON_CONSOLE  (WW_ON_XBOX || WW_ON_PS || WW_ON_SWITCH)
#macro WW_ON_APPLE    (WW_ON_MACOS || WW_ON_IOS)
#macro WW_ON_OPERAGX  (os_type == os_operagx)
#macro WW_ON_WEB      ((os_browser != browser_not_a_browser) || WW_ON_OPERAGX)
#macro WW_ON_JS       (WW_ON_WEB && !WW_ON_OPERAGX)

// Optional Dependancies
#macro WW_Scribble_Deluxe_Exists __WWConstants.Scribble_Deluxe_Exists
#macro WW_Scribble_Jr_Exists     __WWConstants.Scribble_Jr_Exists
#macro WW_Emobble_Exists         __WWConstants.Emobble_Exists

function __WWConstants(){
	static Scribble_Deluxe_Exists = false;
	try {
		Scribble_Deluxe_Exists = is_string(SCRIBBLE_VERSION);
	} catch(e) { }
	
	
	static Scribble_Jr_Exists = false;
	try {
		Scribble_Jr_Exists = is_string(SCRIBBLEJR_VERSION);
	} catch(e) { }
	
	
	static Emobble_Exists = false;
	try {
		Emobble_Exists = script_exists(__Emobble_Config);
	} catch(e) { }
	
}
__WWConstants();
