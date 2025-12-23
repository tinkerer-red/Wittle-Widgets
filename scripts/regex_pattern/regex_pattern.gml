#region jsDoc
/// @func   RegexPattern()
/// @desc   Compiled regex pattern object (like Python's compiled Pattern).
///         Stores the compiled program and exposes execution methods.
/// @param  {String} _pattern
/// @returns {Struct.RegexPattern}
#endregion
function RegexPattern(_pattern) constructor {
    // Compiled Thompson program bundle
    program = regex_build_program(_pattern);

    #region Public Methods

        #region jsDoc
        /// @func   match()
        /// @desc   Match only at the start (byte 0).
        /// @param  {String} _input
        /// @returns {Struct} { found: Bool, start: Real, end: Real }
        #endregion
        static match = function(_input) {
            // Internal runner is intentionally not in this namespace file.
            return regex__pattern_match(program, _input);
        };

        #region jsDoc
        /// @func   search()
        /// @desc   Find first match anywhere starting from _start_byte.
        /// @param  {String} _input
        /// @param  {Real} _start_byte
        /// @returns {Struct} { found: Bool, start: Real, end: Real }
        #endregion
        static search = function(_input, _start_byte = 0) {
            return regex__pattern_search(program, _input, _start_byte);
        };

        #region jsDoc
        /// @func   finditer()
        /// @desc   Iterate matches. Returns an iterator object with next().
        ///         Each next() returns { found, start, end }.
        /// @param  {String} _input
        /// @param  {Real} _start_byte
        /// @returns {Struct} iterator
        #endregion
        static finditer = function(_input, _start_byte = 0) {
            return regex__pattern_finditer(program, _input, _start_byte);
        };

        #region jsDoc
        /// @func   findall()
        /// @desc   Return array of match strings (like Python re.findall, non-capturing).
        /// @param  {String} _input
        /// @param  {Real} _start_byte
        /// @returns {Array<String>}
        #endregion
        static findall = function(_input, _start_byte = 0) {
            return regex__pattern_findall(program, _input, _start_byte);
        };

        #region jsDoc
        /// @func   sub()
        /// @desc   Replace all matches with a replacement string.
        /// @param  {String} _input
        /// @param  {String} _replacement
        /// @param  {Real} _start_byte
        /// @returns {String}
        #endregion
        static sub = function(_input, _replacement, _start_byte = 0) {
            return regex__pattern_sub(program, _input, _replacement, _start_byte);
        };

    #endregion
}


