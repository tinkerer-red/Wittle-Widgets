// Feather disable all

function MsdfUpdateAllFonts()
{
    var _time = get_timer();
    
    __MsdfTrace("Calling `MsdfUpdateAllFonts()`");
    
    var _warnings = 0;
    var _zeroSubstring = ["0"];
    var _batchFilePath = game_save_id + "run.bat";
    
    var _projectDirectory = filename_dir(GM_project_filename) + "/";
    var _fontsDirectory   = _projectDirectory + "fonts/";
    var _msdfGenDirectory = _projectDirectory + "msdf-atlas-gen/";
    var _msdfGenExe       = "msdf-atlas-gen.exe";
    var _exePath          = _msdfGenDirectory + _msdfGenExe;
    var _imageOutPath     = _msdfGenDirectory + "__image.png";
    var _jsonOutPath      = _msdfGenDirectory + "__json.json";
    
    //Check configuration
    if (os_type != os_windows)
    {
        __MsdfError("MSDF generation only works on Windows.\n(Though MSDF rendering at runtime works on every platform.)");
    }
    
    if (not extension_exists("execute_shell_simple_ext"))
    {
        __MsdfError("Add YellowAfterlife's \"execute_shell_simple\" extension to proceed.\nThis can be found at https://yellowafterlife.itch.io/gamemaker-execute-shell-simple\nPlease also consider making a donation to him.");
    }
    
    if (GM_is_sandboxed)
    {
        __MsdfError("Please disable file system sandbox for the Windows platform before running `MsdfUpdateAllFonts()`.\nYou can turn it back on again afterwards.");
    }
    
    var _sacrificialFont = asset_get_index("__MsdfSacrificialAsset");
    if (not font_exists(_sacrificialFont))
    {
        __MsdfError("Please disable \"Automatically remove unused assets when compiling\" before running `MsdfUpdateAllFonts()`.\nYou can turn it back on again afterwards.");
    }
    
    //Report which fonts we're going to be processing
    var _fontArray = asset_get_ids(asset_font);
    var _msdfFontArray = tag_get_asset_ids("msdf", asset_font);
    
    var _i = 0;
    repeat(array_length(_fontArray))
    {
        var _font = _fontArray[_i];
        var _fontName = font_get_name(_font);
        
        if (string_copy(_fontName, 1, 9) == "__newfont")
        {
            __MsdfTrace($"Font \"{font_get_name(_font)}\" ({_font}) was added at runtime and will be ignored");
        }
        else if (not font_get_sdf_enabled(_font)) //We're not worried about SDF fonts
        {
            if (array_get_index(_msdfFontArray, _font) >= 0)
            {
                __MsdfTrace($"Warning! Font \"{font_get_name(_font)}\" ({_font}) is *not* an SDF font but is tagged with \"msdf\". This font will be ignored");
                ++_warnings;
            }
            else
            {
                __MsdfTrace($"Font \"{font_get_name(_font)}\" ({_font}) is not an SDF font and will be ignored");
            }
        }
        else if (array_get_index(_msdfFontArray, _font) < 0)
        {
            __MsdfTrace($"Warning! Font \"{font_get_name(_font)}\" ({_font}) is an SDF font but is *not* tagged with \"msdf\". This font will be ignored");
            ++_warnings;
        }
        else
        {
            __MsdfTrace($"Font \"{font_get_name(_font)}\" ({_font}) will be converted");
        }
        
        ++_i;
    }
    
    //Clean up any resources that are left on disk after last time
    var _batchPreexisting = false;
    if (file_exists(_batchFilePath))
    {
        __MsdfTrace($"Cleaning up batch file from previous attempts");
        __MsdfTrace($"This may indicate an error occurred last time; inserting `pause` command for debugging this time round");
        file_delete(_batchFilePath);
        
        _batchPreexisting = true;
    }
    
    if (file_exists(_imageOutPath))
    {
        __MsdfTrace($"Cleaning up image from previous attempts");
        file_delete(_imageOutPath);
    }
    
    if (file_exists(_jsonOutPath))
    {
        __MsdfTrace($"Cleaning up JSON from previous attempts");
        file_delete(_jsonOutPath);
    }
    
    //Create some reusable buffers
    var _stringBuffer = buffer_create(1024, buffer_grow, 1);
    var _batchBuffer = buffer_create(1024, buffer_grow, 1);
    
    //Start converting fonts...
    var _i = 0;
    repeat(array_length(_msdfFontArray))
    {
        var _font = _msdfFontArray[_i];
        var _fontName = font_get_name(_font);
        var _fontInfo = font_get_info(_font);
        
        __MsdfTrace($"Converting font \"{_fontName}\" to Msdf");
        
        var _fontPointSize = _fontInfo.size;
        __MsdfTrace($"GameMaker point size is {_fontPointSize}");
        
        var _writePointSize = __MSDF_DPI_GM_TO_NORMATIVE*_fontPointSize;
        __MsdfTrace($"Equivalent normative point size is {_writePointSize}");
        
        var _gmAscender = _fontInfo.ascender;
        __MsdfTrace($"GameMaker ascender is {_gmAscender}");
        
        var _fontOriginName = _fontInfo.name;
        __MsdfTrace($"Font name is \"{_fontOriginName}\"");
        
        var _cleanFontOriginName = filename_name(_fontOriginName);
        var _ttfPath = $"{_msdfGenDirectory}{_cleanFontOriginName}.ttf";
        var _path0 = _ttfPath;
        if (not file_exists(_ttfPath))
        {
            __MsdfTrace($"Could not find .ttf at \"{_ttfPath}\"");
            
            _ttfPath = $"{_msdfGenDirectory}{string_replace_all(_cleanFontOriginName, " ", "_")}.ttf";
            var _path1 = _ttfPath;
            if (not file_exists(_ttfPath))
            {
                _ttfPath = $"{_msdfGenDirectory}{string_replace_all(_cleanFontOriginName, "_", " ")}.ttf";
                var _path2 = _ttfPath;
                if (not file_exists(_ttfPath))
                {
                    __MsdfError($"Could not find .ttf in \"{_msdfGenDirectory}\". Looked for:\n- {_path0}\n- {_path1}\n- {_path2}\nPlease rename the source .ttf file accordingly.");
                }
            }
        }
        
        __MsdfTrace($"Found .ttf at \"{_ttfPath}\"");
        
        var _fontDirectory = $"{_fontsDirectory}{_fontName}/";
        var _yyPath = $"{_fontDirectory}{_fontName}.yy";
        __MsdfTrace($"Looking for .yy at \"{_yyPath}\"");
        
        if (not file_exists(_yyPath))
        {
            __MsdfError($"Expected .yy file not found at \"{_yyPath}\"");
        }
        
        var _yyBuffer = buffer_load(_yyPath);
        if (_yyBuffer < 0)
        {
            __MsdfError($"Failed to load \"{_yyPath}\"");
        }
        
        __MsdfTrace($".yy size is {buffer_get_size(_yyBuffer)} bytes");
        
        var _yyString = buffer_read(_yyBuffer, buffer_text);
        buffer_delete(_yyBuffer);
        
        try
        {
            var _yyJSON = json_parse(_yyString);
        }
        catch(_error)
        {
            __MsdfError($"Failed to parse JSON found in \"{_yyPath}\"");
        }
        
        var _fontSdfSpread = _yyJSON.sdfSpread;
        __MsdfTrace($"GameMaker SDF spread is {_fontSdfSpread}");
        
        var _writePxRange = 2*_fontSdfSpread;
        __MsdfTrace($"Equivalent MSDF spread is {_writePxRange}");
        
        buffer_seek(_stringBuffer, buffer_seek_start, 0);
        
        var _gmGlyphsDict = _fontInfo.glyphs;
        var _gmGlyphsArray = struct_get_names(_gmGlyphsDict);
        __MsdfTrace($"Found {array_length(_gmGlyphsArray)} glyphs, building hexcode arguments");
        
        var _i = 0;
        repeat(array_length(_gmGlyphsArray))
        {
            var _glyphChar = _gmGlyphsArray[_i];
            buffer_write(_stringBuffer, buffer_text, "0x");
            buffer_write(_stringBuffer, buffer_text, string_trim_start(string(ptr(ord(_glyphChar))), _zeroSubstring));
            buffer_write(_stringBuffer, buffer_text, ",");
            ++_i;
        }
        
        buffer_poke(_stringBuffer, buffer_tell(_stringBuffer)-1, buffer_u8, 0x00);
        buffer_seek(_stringBuffer, buffer_seek_relative, -1);
        
        __MsdfTrace($"Building batch file");
        buffer_seek(_batchBuffer, buffer_seek_start, 0);
        buffer_write(_batchBuffer, buffer_text, $"pushd \"{filename_dir(_exePath)}\"\r\n");
        buffer_write(_batchBuffer, buffer_text, $"{_msdfGenExe} -font \"{_ttfPath}\" -size {_writePointSize} -pxrange {_writePxRange} -format png -imageout \"{_imageOutPath}\" -json \"{_jsonOutPath}\" -type mtsdf -yorigin top -chars ");
        buffer_copy(_stringBuffer, 0, buffer_tell(_stringBuffer), _batchBuffer, buffer_tell(_batchBuffer));
        buffer_seek(_batchBuffer, buffer_seek_relative, buffer_tell(_stringBuffer));
        
        if (_batchPreexisting)
        {
            buffer_write(_batchBuffer, buffer_text, $"\r\npause");
        }
        
        buffer_save_ext(_batchBuffer, _batchFilePath, 0, buffer_tell(_batchBuffer));
        
        if (not file_exists(_batchFilePath))
        {
            __MsdfError("\"{_batchFilePath}\" failed to save");
        }
        
        __MsdfTrace($"Executing batch file");
        execute_shell_simple(_batchFilePath);
        
        __MsdfTrace($"Waiting for batch file to finish ...");
        var _time = current_time;
        while((not file_exists(_jsonOutPath)) || (not file_exists(_imageOutPath)))
        {
            if (current_time - _time > 10_000)
            {
                __MsdfError("Batch file timed out");
            }
        }
        
		var _time = current_time;
		while (current_time - _time < 1_000) {
			var waste_time = true;
		}
		
        __MsdfTrace($"Loading MSDF JSON");
        var _newYYString = _yyString;
        
        if (not file_exists(_jsonOutPath))
        {
            __MsdfError($"Expected .json file not found at \"{_jsonOutPath}\"");
        }
        
		var _msdfJSONString = ""
		var file = file_text_open_read(_jsonOutPath);
		while (!file_text_eof(file)) {
		    _msdfJSONString += file_text_readln(file);
		}
		file_text_close(file);
		
        //var _msdfJSONBuffer = buffer_create(_jsonOutPath);
        //if (_msdfJSONBuffer < 0)
        //{
        //    __MsdfError($"Failed to load \"{_jsonOutPath}\"");
        //}
        
        //__MsdfTrace($".json size is {buffer_get_size(_msdfJSONBuffer)} bytes");
        
        //var _msdfJSONString = buffer_read(_msdfJSONBuffer, buffer_text);
        //buffer_delete(_msdfJSONBuffer);
        
        try
        {
            var _msdfJSON = json_parse(_msdfJSONString);
        }
        catch(_error)
        {
            pprint(string_length(_msdfJSONString))
			__MsdfError($"Failed to parse JSON found in \"{_jsonOutPath}\"");
        }
        
        var _msdfPointSize = _msdfJSON.atlas.size;
        var _msdfRange     = _msdfJSON.atlas.distanceRange;
        var _msdfAscender  = -ceil(_fontPointSize*_msdfJSON.metrics.ascender);
        __MsdfTrace($"MSDF point size is {_msdfPointSize}");
        __MsdfTrace($"MSDF range is {_msdfRange}");
        __MsdfTrace($"MSDF ascender is {_msdfAscender}");
        
        __MsdfTrace($"Loading existing GameMaker texture");
        
        var _sprite = sprite_add($"{_fontDirectory}{_fontName}.png", 0, false, false, 0, 0);
        var _surface = surface_create(sprite_get_width(_sprite), sprite_get_height(_sprite));
        
        sprite_delete(_sprite);
        var _sprite = sprite_add(_imageOutPath, 0, false, false, 0, 0);
        
        __MsdfTrace($"Replacing GameMaker glyph textures");
        
        var _msdGlyphArray = _msdfJSON.glyphs;
        var _yyGlyphDict = _yyJSON.glyphs;
        
        surface_set_target(_surface);
        draw_clear_alpha(c_black, 0);
        gpu_set_blendmode_ext(bm_one, bm_zero);
        
        var _i = 0;
        repeat(array_length(_msdGlyphArray))
        {
            var _msdfData    = _msdGlyphArray[_i];
            var _msdfUnicode = _msdfData.unicode;
            var _msdfAtlas   = _msdfData[$ "atlasBounds"];
            var _msdfPlane   = _msdfData[$ "planeBounds"];
            
            var _gmData = _yyGlyphDict[$ _msdfUnicode];
            var _gmX      = _gmData.x;
            var _gmY      = _gmData.y;
            var _gmWidth  = _gmData.w;
            var _gmHeight = _gmData.h;
            
            if ((_gmWidth > 0) && (_msdfAtlas != undefined) && (_msdfPlane != undefined)) //whitespace or non-printable
            {
                var _gmBaselineY = _gmY + _fontSdfSpread + _gmAscender;
                var _msdfY = floor(_msdfPointSize*_msdfPlane.top) + _gmBaselineY;
                
                draw_sprite_part(_sprite, 0,
                                 _msdfAtlas.left, _msdfAtlas.top,
                                 _msdfAtlas.right - _msdfAtlas.left, _msdfAtlas.bottom - _msdfAtlas.top,
                                 _gmX, _msdfY);
            }
            
            ++_i;
        }
        
        gpu_set_blendmode(bm_normal);
        surface_reset_target();
        
        __MsdfTrace($"Saving new texture");
        surface_save(_surface, $"{_fontDirectory}{_fontName}.png");
        
        __MsdfTrace($"Cleaning up");
        file_delete(_batchFilePath);
        file_delete(_imageOutPath);
        file_delete(_jsonOutPath);
        surface_free(_surface);
        sprite_delete(_sprite);
        
        __MsdfTrace($"Finished converting font \"{font_get_name(_font)}\"");
    
        ++_i;
    }
    
    //Clean up temporary buffers
    buffer_delete(_stringBuffer);
    buffer_delete(_batchBuffer);
    
    //Report state
    if (_warnings > 0)
    {
        __MsdfLoud($"`MsdfUpdateAllFonts()` finished ({(get_timer() - _time) / 1000} ms) but with {_warnings} warning(s), please review your debug log");
    }
    else
    {
        __MsdfLoud($"`MsdfUpdateAllFonts()` finished ({(get_timer() - _time) / 1000} ms) successfully with no warnings");
    }
    
    game_end();
}