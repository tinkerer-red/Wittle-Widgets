#macro GUI_IMAGE_ENABLED 0
#macro GUI_IMAGE_HOVER 1
#macro GUI_IMAGE_CLICKED 2
#macro GUI_IMAGE_DISABLED 3

#region jsDoc
/// @func    __anchor__()
/// @desc    Defines an anchor for Components to make use of when GUI or windows are resized. This will help ensure GUI elements in the top right stay in the top right.
/// @param   {Real} x : The starting x position of the component
/// @param   {Real} y : The starting y position of the component
/// @param   {Constant.HAlign} halign : Horizontal alignment.
/// @param   {Constant.VAlign} valign : Vertical alignment.
#endregion
function __anchor__(_x, _y, _halign=fa_center, _valign=fa_middle) constructor {
	var _calling_inst = other;
	var _vecx, _vecy;
	
	with (_calling_inst) {
		_vecx = __get_controller_archor_x__(_halign)
		_vecy = __get_controller_archor_y__(_valign)
	}
	
	var _xx = _x - (_calling_inst.x+_vecx)
	var _yy = _y - (_calling_inst.y+_vecy)
	
	x = _xx;
	y = _yy;
	halign = _halign;
	valign = _valign;
}

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
	//var _calling_inst = other;
	//with (_calling_inst) {
		switch (_halign) {
			default:
			case fa_left:{
				 return region.left;
			}
			case fa_center:{
				 return floor(region.get_width()/2 + 0.5);
			}
			case fa_right:{
				 return region.right;
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
	//var _calling_inst = other;
	//with (_calling_inst) {
		switch (_valign) {
			default:
			case fa_top:{
				 return region.top;
			}
			case fa_middle:{
				 return floor((region.get_height())/2 + 0.5);
			}
			case fa_bottom:{
				 return region.bottom;
			}
		}
	//}
}

function variable_struct_inherite(_struct) {
	var _calling_inst, _names, _key, _val, _size, _i, _temp_struct;
	
	_calling_inst = self;
	_names = variable_struct_get_names(_struct);
	
	//non static variables
	_size = array_length(_names);
	_i=0; repeat(_size) {
		_key = _names[_i];
		_val = _struct[$ _key];
		
		if (is_method(_val)) {
			//convert functions to their callable IDs
			_val = asset_get_index(script_get_name(_val));
			_calling_inst[$ _key] = method(_calling_inst, _val);
		}
		else if (is_struct(_val)) {
			_temp_struct = {};
			with (_temp_struct) {
				variable_struct_inherite(_val);
			}
			_calling_inst[$ _key] = _temp_struct
		}
		else {
			_calling_inst[$ _key] = _val;
		}
	_i+=1;}//end repeat loop
	
	//static variables
	var _statics = static_get(_struct)
	_names = variable_struct_get_names(_statics);
	
	_size = array_length(_names);
	_i=0; repeat(_size) {
		_key = _names[_i];
		_val = _statics[$ _key];
		
		if (is_method(_val)) {
			//convert functions to their callable IDs
			_val = asset_get_index(script_get_name(_val));
			_calling_inst[$ _key] = method(_calling_inst, _val);
		}
		else if (is_struct(_val)) {
			_temp_struct = {};
			with (_temp_struct) {
				variable_struct_inherite(_val);
			}
			_calling_inst[$ _key] = _temp_struct
		}
		else {
			_calling_inst[$ _key] = _val;
		}
	_i+=1;}//end repeat loop
	
}
