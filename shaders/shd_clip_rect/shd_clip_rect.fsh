//
// Simple shader to set alpha to 0 outside bounds. 
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vPosition;
uniform vec4 u_clips;

void main()
{
    gl_FragColor = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
    if (v_vPosition.x < u_clips.x || 
		v_vPosition.y < u_clips.y ||
		v_vPosition.x > u_clips.z || 
		v_vPosition.y > u_clips.w) {
        gl_FragColor.a = 0.;
    };
}
