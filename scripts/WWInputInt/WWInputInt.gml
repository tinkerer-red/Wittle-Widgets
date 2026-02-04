#region jsDoc
/// @func    WWInputInt()
/// @desc    Integer numeric input with stepper up/down buttons.
/// @returns {Struct.WWInputInt}
#endregion
function WWInputInt() : WWInputNumberBase() constructor {
	debug_name = "WWInputInt";

	__is_int__ = true;
	__decimals__ = 0;
	__step__ = 1;

	// Ensure displayed text matches integer rules.
	set_value(get_value());
}
