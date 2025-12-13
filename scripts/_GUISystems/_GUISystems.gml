#macro GUI_IMAGE_ENABLED 0
#macro GUI_IMAGE_HOVER 1
#macro GUI_IMAGE_PRESSED 2
#macro GUI_IMAGE_DISABLED 3

function __surface_rebuild__(_surface, _w, _h) {
	if (!is_undefined(_surface))
	&& (surface_exists(_surface)) {
		if (surface_get_width(_surface) != floor(_w))
		|| (surface_get_height(_surface) != floor(_h)) {
			surface_free(_surface);
			_surface = surface_create(floor(_w),floor(_h));
		}
	} else {
		_surface = surface_create(floor(_w),floor(_h));
	}
	
	return _surface;
}

#region jsDoc
/// @func    __get_controller_archor_x__()
/// @desc    Get's the anchor's desired location from the controller region.
/// @param   {Constant.HAlign} halign : Horizontal alignment.
/// @returns {Real}
#endregion
function __get_controller_archor_x__(_halign=fa_center) {
	gml_pragma("forceinline");
	//var _calling_inst = other;
	//with (_calling_inst) {
		switch (_halign) {
			default:
			case fa_left:{
				 return 0;
			}
			case fa_center:{
				 return floor(width/2 + 0.5);
			}
			case fa_right:{
				 return width;
			}
		}
	//}
}

#region jsDoc
/// @func    __get_controller_archor_y__()
/// @desc    Get's the anchor's desired location from the controller region.
/// @param   {Constant.VAlign} valign : Vertical alignment.
/// @returns {Real}
#endregion
function __get_controller_archor_y__(_valign=fa_middle) {
	gml_pragma("forceinline");
	//var _calling_inst = other;
	//with (_calling_inst) {
		switch (_valign) {
			default:
			case fa_top:{
				 return 0;
			}
			case fa_middle:{
				 return floor(height/2 + 0.5);
			}
			case fa_bottom:{
				 return height;
			}
		}
	//}
}


//todo: add these functions when html5's static_get(statig_get(self)) is no longer broken
function js_clipboard_get_text(){return clipboard_get_text()};
function js_clipboard_set_text(s){return clipboard_set_text(s)};
function js_clipboard_has_text(){return clipboard_has_text()};
function js_set_cursor(c){return window_set_cursor(c)};