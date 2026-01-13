varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 texcol = texture2D(gm_BaseTexture, v_vTexcoord);

    float distval;

    if (all(equal(texcol.rgb, vec3(1.0))))
    {
        distval = texcol.a;
    }
    else
    {
        float min_rg = min(texcol.r, texcol.g);
        float max_rg = max(texcol.r, texcol.g);
        distval = max(min_rg, min(max_rg, texcol.b));
    }

    float spread = fwidth(distval);
    spread = max(spread * 0.75, 0.001);

    float alphaval = smoothstep(0.5 - spread, 0.5 + spread, distval);

    vec4 combinedcol = vec4(v_vColour.rgb, v_vColour.a * alphaval);
	DoAlphaTest(combinedcol);
    gl_FragColor = combinedcol;
}
