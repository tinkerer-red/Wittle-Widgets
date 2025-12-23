#region jsDoc
/// @func   regex__pattern_finditer()
/// @desc   Iterate matches. Returns iterator with next().
/// @param  {Struct} _program
/// @param  {String} _input
/// @param  {Real} _start_byte
/// @returns {Struct} iterator
#endregion
function regex__pattern_finditer(_program, _input, _start_byte) {
    return new RegexIterator(_program, _input, _start_byte);
}
