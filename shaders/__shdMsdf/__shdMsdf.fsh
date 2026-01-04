varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_atlas_size;
uniform float u_pxrange;
uniform float u_smoothness;

float median3(vec3 _value)
{
    return max(min(_value.x, _value.y), min(max(_value.x, _value.y), _value.z));
}

void main()
{
    vec3 _msdf_sample = texture2D(gm_BaseTexture, v_vTexcoord).rgb;

    /* Signed distance in normalized MSDF space: 0 is the edge */
    float _signed_distance_norm = median3(_msdf_sample) - 0.5;

    /* Convert UV derivatives into texels per screen pixel */
    vec2 _dx_texels = dFdx(v_vTexcoord) * u_atlas_size;
    vec2 _dy_texels = dFdy(v_vTexcoord) * u_atlas_size;

    float _texels_per_pixel = max(length(_dx_texels), length(_dy_texels));
    _texels_per_pixel = max(_texels_per_pixel, 0.00001);

    /* pxRange (in texels) converted into "screen pixels of range" */
    float _screen_pixel_range = u_pxrange / _texels_per_pixel;

    /* Apply smoothing control */
    float _range = max(_screen_pixel_range * u_smoothness, 0.00001);

    /* Map signed distance to coverage */
    float _alpha = clamp(_signed_distance_norm * _range + 0.5, 0.0, 1.0);

    gl_FragColor = vec4(v_vColour.rgb, _alpha * v_vColour.a);
}
