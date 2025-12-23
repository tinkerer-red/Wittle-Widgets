#region jsDoc
/// @func   regex()
/// @desc   Namespace-style function that mimics Python's `re` module shape.
//////
//////  Public entry points:
//////      - regex.compile(pattern) -> returns RegexPattern
//////      - Convenience wrappers mirroring Python's module-level helpers:
//////          regex.match(pattern_obj, input)
//////          regex.search(pattern_obj, input, start_byte)
//////          regex.finditer(pattern_obj, input, start_byte)
//////          regex.findall(pattern_obj, input, start_byte)
//////          regex.sub(pattern_obj, input, replacement, start_byte)
//////
//////  Notes:
//////      - In this library, the module-level helpers expect a compiled pattern object,
//////        not a raw pattern string. This keeps compilation explicit and avoids hidden caching.
//////      - Internal helpers live in separate scripts (regex__*), and are not part of this namespace.
//////
//////  Usage:
//////      var _pat = regex.compile(@"[a-zA-Z_]\w*");
//////      var _m0  = regex.match(_pat, "hello_world");
//////      var _m1  = regex.search(_pat, "xx hello_world", 0);
//////      var _arr = regex.findall(_pat, "a b c", 0);
//////      var _out = regex.sub(_pat, "a b c", "_", 0);
//////
//////      // Or call methods directly:
//////      var _m2 = _pat.search("xx hello_world", 0);
//////
////// @returns {Struct} regex namespace (static methods)
#endregion
function regex() {
    #region Public API

        #region jsDoc
        /// @func   compile()
        /// @desc   Compile a raw-string regex pattern into a reusable Pattern object.
        /// @param  {String} _pattern
        /// @returns {Struct.RegexPattern}
        #endregion
        static compile = function(_pattern) {
            return new RegexPattern(_pattern);
        };

        #region jsDoc
        /// @func   match()
        /// @desc   Convenience wrapper - match only at the start (byte 0).
        /// @param  {Struct.RegexPattern} _pattern
        /// @param  {String} _input
        /// @returns {Struct} { found: Bool, start: Real, end: Real }
        #endregion
        static match = function(_pattern, _input) {
            return _pattern.match(_input);
        };

        #region jsDoc
        /// @func   search()
        /// @desc   Convenience wrapper - find first match anywhere starting from _start_byte.
        /// @param  {Struct.RegexPattern} _pattern
        /// @param  {String} _input
        /// @param  {Real} _start_byte
        /// @returns {Struct} { found: Bool, start: Real, end: Real }
        #endregion
        static search = function(_pattern, _input, _start_byte = 0) {
            return _pattern.search(_input, _start_byte);
        };

        #region jsDoc
        /// @func   finditer()
        /// @desc   Convenience wrapper - iterate matches. Returns an iterator object with next().
        ///         Each next() returns { found, start, end }.
        /// @param  {Struct.RegexPattern} _pattern
        /// @param  {String} _input
        /// @param  {Real} _start_byte
        /// @returns {Struct} iterator
        #endregion
        static finditer = function(_pattern, _input, _start_byte = 0) {
            return _pattern.finditer(_input, _start_byte);
        };

        #region jsDoc
        /// @func   findall()
        /// @desc   Convenience wrapper - return array of match strings (non-capturing).
        /// @param  {Struct.RegexPattern} _pattern
        /// @param  {String} _input
        /// @param  {Real} _start_byte
        /// @returns {Array<String>}
        #endregion
        static findall = function(_pattern, _input, _start_byte = 0) {
            return _pattern.findall(_input, _start_byte);
        };

        #region jsDoc
        /// @func   sub()
        /// @desc   Convenience wrapper - replace all matches with a replacement string.
        /// @param  {Struct.RegexPattern} _pattern
        /// @param  {String} _input
        /// @param  {String} _replacement
        /// @param  {Real} _start_byte
        /// @returns {String}
        #endregion
        static sub = function(_pattern, _input, _replacement, _start_byte = 0) {
            return _pattern.sub(_input, _replacement, _start_byte);
        };

    #endregion
}
// initialize statics
regex();
