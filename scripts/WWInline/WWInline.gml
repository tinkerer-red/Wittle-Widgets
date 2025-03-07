#region jsDoc
/// @func    WWInline()
/// @desc    A placeholder component whose sole purpose is to act as an inline layout operator. 
///          When used in an add_inline() call, it signals that the following component should be placed on the same horizontal line
///          as the previous one rather than starting a new line. This component does not render any visible output and is never added
///          to the display; it simply serves as a marker for layout purposes.
/// @return  {Struct.WWInline}
#endregion
function WWInline() : WWCore() constructor {
    debug_name = "WWInline";
}
