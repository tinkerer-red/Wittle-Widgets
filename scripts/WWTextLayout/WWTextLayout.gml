/// @func    WWTextLayout()
/// @desc    Layout handler that owns a ds_map-based text layout.
function WWTextLayout() constructor
{
    // Root layout map
    layout_data = {};
    
    // Owned lists: when layout_data is destroyed, these lists are also destroyed.
    layout_data.lines  = [];
    layout_data.glyphs = [];
    
	layout_data.lines_count  = 0;
    layout_data.glyphs_count = 0;
    
    // Aggregate content bounds (in local space)
    layout_data.content_width = 0;
    layout_data.content_height = 0;
    
    /// @func add_line(_text, _start_ind, _end_ind, _width, _height, _yoff, _force_wrapped)
    /// @desc Record a single laid-out line in the layout.
    static add_line = function(_text, _start_ind, _end_ind, _width, _height, _yoff, _force_wrapped) {
        var _data = layout_data;
		var _lines = _data.lines;
        
		array_push(_lines,
			_text,
			_start_ind,
			_end_ind,
			_width,
			_height,
			_yoff,
			_force_wrapped
		)
		
        // Update content bounds
        var _content_width = _data.content_width;
        var _content_height = _data.content_height;
        var _line_bottom = _yoff + _height;
        
        if (_width > _content_width) _content_width = _width;
        if (_line_bottom > _content_height) _content_height = _line_bottom;
        
        _data.content_width  = _content_width;
        _data.content_height = _content_height;
        
		var _line_index = _data.lines_count;
		_data.lines_count++;
		
        // Return index of this line if you want to keep a handle
        return _line_index;
    };
    enum __WW_Layout_Line {
		Text,
		Start_Index,
		End_Index,
		Width,
		Height,
		Y_Offset,
		Force_Wraped,
		__Size__
	}
	
	#region jsDoc
	/// @func    add_glyph(_char, _index, _buffer_index, _buffer_size, _x, _y, _width, _height)
	/// @desc    Adds a glyph record to the layout. This glyph may represent a full Unicode cluster.
	/// @param   {String} _char          : Representative character or cluster.
	/// @param   {Real}   _index         : Logical text index (cluster index).
	/// @param   {Real}   _buffer_index  : Offset in the underlying buffer.
	/// @param   {Real}   _buffer_size   : Number of buffer units consumed by this glyph.
	/// @param   {Real}   _x             : X position in layout space.
	/// @param   {Real}   _y             : Y position in layout space.
	/// @param   {Real}   _width         : Glyph width.
	/// @param   {Real}   _height        : Glyph height.
	/// @returns {Real}                  : Glyph slot index.
	#endregion
	static add_glyph = function(_char, _index, _buffer_index, _buffer_size, _x, _y, _width, _height)
	{
	    var _data = layout_data;
	    var _glyphs = _data.glyphs;
		
		array_push(_glyphs,
			_char,
			_index,
			_buffer_index,
			_buffer_size,
			_x,
			_y,
			_width,
			_height
		);
		
	    // update content bounds
	    var _r = _x + _width;
	    var _b = _y + _height;
		
	    if (_r > _data.content_width)  _data.content_width = _r;
	    if (_b > _data.content_height) _data.content_height = _b;
		
		
		var _glyph_index = _data.glyphs_count;
		_data.glyphs_count++;
		
        // Return index of this line if you want to keep a handle
        return _glyph_index;
	};
	enum __WW_Layout_Glyph {
		Char,
		Index,
		Buffer_Index,
		Buffer_Size,
		X,
		Y,
		Width,
		Height,
		__Size__
	}
	
	#region Basic layout getters
	
	#region jsDoc
	/// @func    get_layout_data()
	/// @desc    Returns the root data containing all layout information.
	/// @returns {Struct}
	#endregion
	static get_layout_data = function() {
	    return layout_data;
	};
	
	#region jsDoc
	/// @func    get_content_width()
	/// @desc    Returns the full content width (max line or glyph x extent).
	/// @returns {Real}
	#endregion
	static get_content_width = function() {
	    return layout_data.content_width;
	};
	
	#region jsDoc
	/// @func    get_content_height()
	/// @desc    Returns the full content height (max line or glyph y extent).
	/// @returns {Real}
	#endregion
	static get_content_height = function() {
	    return layout_data.content_height;
	};
	
	#endregion
	
	#region Line getters
	
	#region jsDoc
	/// @func    get_line_count()
	/// @desc    Returns how many lines exist in the layout.
	/// @returns {Real}
	#endregion
	static get_line_count = function() {
	    return layout_data.lines_count;
	};
	
	#region jsDoc
	/// @func    get_line(_line_index)
	/// @desc    Returns a new struct representing the requested line.
	/// @param   {Real} _line_index : Zero-based line index.
	/// @returns {Struct}
	#endregion
	static get_line = function(_line_index) {
		var _data = layout_data;
		
		if (_line_index < 0 || _line_index >= layout_data.lines_count) {
	        return undefined;
	    }
	    
		var _lines = _data.lines;
		var _index = _line_index * __WW_Layout_Line.__Size__;
		var _line = {
			text         : _lines[_index + __WW_Layout_Line.Text],
			start_index  : _lines[_index + __WW_Layout_Line.Start_Index],
			end_index    : _lines[_index + __WW_Layout_Line.End_Index],
			width        : _lines[_index + __WW_Layout_Line.Width],
			height       : _lines[_index + __WW_Layout_Line.Height],
			y_offset     : _lines[_index + __WW_Layout_Line.Y_Offset],
			force_wraped : _lines[_index + __WW_Layout_Line.Force_Wraped]
		}
	    
	    return _line;
	};
	
	#region jsDoc
	/// @func    get_line_text(_line_index)
	/// @desc    Returns the raw text content of the given line.
	/// @param   {Real} _line_index : Zero-based line index.
	/// @returns {String}
	#endregion
	static get_line_text = function(_line_index) {
	    var _data = layout_data;
		
		if (_line_index < 0 || _line_index >= _data.lines_count) {
	        return undefined;
	    }
	    
		var _index = _line_index * __WW_Layout_Line.__Size__;
		return _data.lines[_index + __WW_Layout_Line.Text]
	};
	
	#region jsDoc
	/// @func    get_line_index_start(_line_index)
	/// @desc    Returns the text index that begins this line.
	/// @param   {Real} _line_index : Zero-based line index.
	/// @returns {Real}
	#endregion
	static get_line_index_start = function(_line_index) {
	    var _data = layout_data;
		
		if (_line_index < 0 || _line_index >= _data.lines_count) {
	        return undefined;
	    }
	    
		var _index = _line_index * __WW_Layout_Line.__Size__;
		return _data.lines[_index + __WW_Layout_Line.Start_Index]
	};
	
	#region jsDoc
	/// @func    get_line_index_end(_line_index)
	/// @desc    Returns the text index immediately after the last char of the line.
	/// @param   {Real} _line_index : Zero-based line index.
	/// @returns {Real}
	#endregion
	static get_line_index_end = function(_line_index) {
	    var _data = layout_data;
		
		if (_line_index < 0 || _line_index >= _data.lines_count) {
	        return undefined;
	    }
	    
		var _index = _line_index * __WW_Layout_Line.__Size__;
		return _data.lines[_index + __WW_Layout_Line.End_Index]
	};
	
	#region jsDoc
	/// @func    get_line_width(_line_index)
	/// @desc    Returns the width of the given line.
	/// @param   {Real} _line_index : Zero-based line index.
	/// @returns {Real}
	#endregion
	static get_line_width = function(_line_index) {
	    var _data = layout_data;
		
		if (_line_index < 0 || _line_index >= _data.lines_count) {
	        return undefined;
	    }
	    
		var _index = _line_index * __WW_Layout_Line.__Size__;
		return _data.lines[_index + __WW_Layout_Line.Width]
	};
	
	#region jsDoc
	/// @func    get_line_height(_line_index)
	/// @desc    Returns the height of the given line.
	/// @param   {Real} _line_index : Zero-based line index.
	/// @returns {Real}
	#endregion
	static get_line_height = function(_line_index) {
	    var _data = layout_data;
		
		if (_line_index < 0 || _line_index >= _data.lines_count) {
	        return undefined;
	    }
	    
		var _index = _line_index * __WW_Layout_Line.__Size__;
		return _data.lines[_index + __WW_Layout_Line.Height]
	};
	
	#region jsDoc
	/// @func    get_line_y_offset(_line_index)
	/// @desc    Returns the vertical offset of the line relative to layout top.
	/// @param   {Real} _line_index : Zero-based line index.
	/// @returns {Real}
	#endregion
	static get_line_y_offset = function(_line_index) {
	    var _data = layout_data;
		
		if (_line_index < 0 || _line_index >= _data.lines_count) {
	        return undefined;
	    }
	    
		var _index = _line_index * __WW_Layout_Line.__Size__;
		return _data.lines[_index + __WW_Layout_Line.Y_Offset]
	};
	
	#region jsDoc
	/// @func    get_line_forced_wrapped(_line_index)
	/// @desc    Returns 1 if the line was soft-wrapped, 0 if an explicit break.
	/// @param   {Real} _line_index : Zero-based line index.
	/// @returns {Real}
	#endregion
	static get_line_forced_wrapped = function(_line_index) {
	    var _data = layout_data;
		
		if (_line_index < 0 || _line_index >= _data.lines_count) {
	        return undefined;
	    }
	    
		var _index = _line_index * __WW_Layout_Line.__Size__;
		return _data.lines[_index + __WW_Layout_Line.Force_Wraped]
	};
	
	#endregion
	
	#region Glyph getters
	
	#region jsDoc
	/// @func    get_glyph_count()
	/// @desc    Returns how many glyphs are recorded in the layout.
	/// @returns {Real}
	#endregion
	static get_glyph_count = function() {
	    return layout_data.glyphs_count;
	};

	#region jsDoc
	/// @func    get_glyph(_glyph_index)
	/// @desc    Returns a new struct representing this glyph.
	/// @param   {Real} _glyph_index
	/// @returns {Struct}
	#endregion
	static get_glyph = function(_glyph_index)
	{
	    var _data = layout_data;
	    if (_glyph_index < 0 || _glyph_index >= _data.glyphs_count) {
	        return undefined;
	    }
	    
		var _glyphs = _data.glyphs;
	    var _index = _glyph_index * __WW_Layout_Glyph.__Size__;
		var _line = {
			text         : _glyphs[_index + __WW_Layout_Glyph.Char],
			index        : _glyphs[_index + __WW_Layout_Glyph.Index],
			buffer_index : _glyphs[_index + __WW_Layout_Glyph.Buffer_Index],
			buffer_size  : _glyphs[_index + __WW_Layout_Glyph.Buffer_Size],
			x            : _glyphs[_index + __WW_Layout_Glyph.X],
			y            : _glyphs[_index + __WW_Layout_Glyph.Y],
			width        : _glyphs[_index + __WW_Layout_Glyph.Width],
			height       : _glyphs[_index + __WW_Layout_Glyph.Height],
		}
	    
	    return _line;
	};

	#region jsDoc
	/// @func    get_glyph_char(_glyph_index)
	/// @desc    Returns the displayed character or Unicode cluster.
	/// @param   {Real} _glyph_index
	/// @returns {String}
	#endregion
	static get_glyph_char = function(_glyph_index)
	{
	    var _data = layout_data;
		
		if (_glyph_index < 0 || _glyph_index >= _data.glyphs_count) {
	        return undefined;
	    }
	    
		var _index = _glyph_index * __WW_Layout_Glyph.__Size__;
		return _data.glyphs[_index + __WW_Layout_Glyph.Char]
	};

	#region jsDoc
	/// @func    get_glyph_index(_glyph_index)
	/// @desc    Returns the logical text index (cluster index) for this glyph.
	/// @param   {Real} _glyph_index
	/// @returns {Real}
	#endregion
	static get_glyph_index = function(_glyph_index)
	{
	    var _data = layout_data;
		
		if (_glyph_index < 0 || _glyph_index >= _data.glyphs_count) {
	        return undefined;
	    }
	    
		var _index = _glyph_index * __WW_Layout_Glyph.__Size__;
		return _data.glyphs[_index + __WW_Layout_Glyph.Index]
	};

	#region jsDoc
	/// @func    get_glyph_buffer_index(_glyph_index)
	/// @desc    Returns the buffer offset where this glyph begins.
	/// @param   {Real} _glyph_index
	/// @returns {Real}
	#endregion
	static get_glyph_buffer_index = function(_glyph_index)
	{
	    var _data = layout_data;
		
		if (_glyph_index < 0 || _glyph_index >= _data.glyphs_count) {
	        return undefined;
	    }
	    
		var _index = _glyph_index * __WW_Layout_Glyph.__Size__;
		return _data.glyphs[_index + __WW_Layout_Glyph.Buffer_Index]
	};

	#region jsDoc
	/// @func    get_glyph_buffer_size(_glyph_index)
	/// @desc    Returns how many buffer units this glyph consumes.
	/// @param   {Real} _glyph_index
	/// @returns {Real}
	#endregion
	static get_glyph_buffer_size = function(_glyph_index)
	{
	    var _data = layout_data;
		
		if (_glyph_index < 0 || _glyph_index >= _data.glyphs_count) {
	        return undefined;
	    }
	    
		var _index = _glyph_index * __WW_Layout_Glyph.__Size__;
		return _data.glyphs[_index + __WW_Layout_Glyph.Buffer_Size]
	};

	#region jsDoc
	/// @func    get_glyph_x(_glyph_index)
	/// @desc    Returns the glyph's x position in layout space.
	/// @param   {Real} _glyph_index
	/// @returns {Real}
	#endregion
	static get_glyph_x = function(_glyph_index)
	{
	    var _data = layout_data;
		
		if (_glyph_index < 0 || _glyph_index >= _data.glyphs_count) {
	        return undefined;
	    }
	    
		var _index = _glyph_index * __WW_Layout_Glyph.__Size__;
		return _data.glyphs[_index + __WW_Layout_Glyph.X]
	};

	#region jsDoc
	/// @func    get_glyph_y(_glyph_index)
	/// @desc    Returns the glyph's y position in layout space.
	/// @param   {Real} _glyph_index
	/// @returns {Real}
	#endregion
	static get_glyph_y = function(_glyph_index)
	{
	    var _data = layout_data;
		
		if (_glyph_index < 0 || _glyph_index >= _data.glyphs_count) {
	        return undefined;
	    }
	    
		var _index = _glyph_index * __WW_Layout_Glyph.__Size__;
		return _data.glyphs[_index + __WW_Layout_Glyph.Y]
	};

	#region jsDoc
	/// @func    get_glyph_width(_glyph_index)
	/// @desc    Returns the width of this glyph.
	/// @param   {Real} _glyph_index
	/// @returns {Real}
	#endregion
	static get_glyph_width = function(_glyph_index)
	{
	    var _data = layout_data;
		
		if (_glyph_index < 0 || _glyph_index >= _data.glyphs_count) {
	        return undefined;
	    }
	    
		var _index = _glyph_index * __WW_Layout_Glyph.__Size__;
		return _data.glyphs[_index + __WW_Layout_Glyph.Width]
	};

	#region jsDoc
	/// @func    get_glyph_height(_glyph_index)
	/// @desc    Returns the height of this glyph.
	/// @param   {Real} _glyph_index
	/// @returns {Real}
	#endregion
	static get_glyph_height = function(_glyph_index)
	{
	    var _data = layout_data;
		
		if (_glyph_index < 0 || _glyph_index >= _data.glyphs_count) {
	        return undefined;
	    }
	    
		var _index = _glyph_index * __WW_Layout_Glyph.__Size__;
		return _data.glyphs[_index + __WW_Layout_Glyph.Height]
	};

	#endregion
	
	#region High-level helpers (cursor / hit-testing)
	
	#region jsDoc
	/// @func    get_glyph_for_buffer_index(_buffer_index)
	/// @desc    Returns the glyph slot whose buffer span covers _buffer_index.
	/// @param   {Real} _buffer_index
	/// @returns {Real}
	#endregion
	static get_glyph_for_buffer_index = function(_buffer_index)
	{
	    var _glyphs = layout_data.glyphs;
	    var _count = layout_data.glyphs_count;
		
	    var _i = 0;
		repeat (_count) {
	        
			var _start = _glyphs[_i + __WW_Layout_Glyph.Buffer_Index];
	        var _end = _start + _glyphs[_i + __WW_Layout_Glyph.Buffer_Size] - 1;
			
			if (_buffer_index >= _start)
			&& (_buffer_index <= _end) {
				return _i div __WW_Layout_Glyph.__Size__;
			}
			
			_i += __WW_Layout_Glyph.__Size__;
			
		}
	    return -1;
	};

	#endregion
	
}
