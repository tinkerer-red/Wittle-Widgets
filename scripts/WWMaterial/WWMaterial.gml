#region jsDoc
/// @func    WWMaterial(draw, pre_draw, post_draw, cleanup)
/// @desc    Minimal backend material wrapper.
/// @param   {Function}                          draw
/// @param   {Asset.GMShader|Function|undefined} pre_draw
/// @param   {Function|undefined}                post_draw
/// @param   {Function}                          cleanup
#endregion
function WWMaterial(_draw, _pre_draw=undefined, _post_draw=undefined, _cleanup=undefined) constructor
{
    static __noop = function(){};

    draw_step = is_callable(_draw) ? _draw : __noop;
    draw_pre  = _pre_draw;
    draw_post = _post_draw;
    cleanup   = is_callable(_cleanup) ? _cleanup : __noop;

    static draw = function(_x, _y)
    {
        // pre
        if (is_callable(draw_pre)) {
            draw_pre(_x, _y);
        }
        else if (draw_pre != undefined) {
            shader_set(draw_pre);
        }

        // draw
        draw_step(_x, _y);

        // post
        if (is_callable(draw_post)) {
            draw_post(_x, _y);
        }
        else if (!is_callable(draw_pre) && draw_pre != undefined) {
            shader_reset();
        }
    };
	
	#region jsDoc
    /// @func    destroy()
    /// @desc    Invoke material cleanup (lifecycle only).
    #endregion
    static destroy = function()
    {
        cleanup();
    };
}
