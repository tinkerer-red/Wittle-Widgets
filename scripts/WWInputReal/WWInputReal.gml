#region jsDoc
/// @func    WWInputReal()
/// @desc    Real numeric input with stepper up/down buttons.
///          Use set_decimals() and set_step() to tune behavior.
/// @returns {Struct.WWInputReal}
#endregion
function WWInputReal() : WWInputNumberBase() constructor {
	debug_name = "WWInputReal";

	__is_int__ = false;
	__decimals__ = 2;
	__step__ = 0.1;

	set_value(get_value());
}
