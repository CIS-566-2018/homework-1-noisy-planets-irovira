#version 300 es

#define TWO_PI 6.28318530718

// This is a fragment shader. If you've opened this file first, please
// open and read lambert.vert.glsl before reading on.
// Unlike the vertex shader, the fragment shader actually does compute
// the shading of geometry. For every pixel in your program's output
// screen, the fragment shader is run for every bit of geometry that
// particular pixel overlaps. By implicitly interpolating the position
// data passed into the fragment shader by the vertex shader, the fragment shader
// can compute what color to apply to its pixel based on things like vertex
// position, light position, and vertex color.
precision highp float;


uniform vec4 u_Color; // The color with which to render this instance of geometry.
uniform float u_Time;
uniform vec2 u_Resolution;
// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

//  Function from Iñigo Quiles
//  https://www.shadertoy.com/view/MsS3Wc
vec3 hsb2rgb( in vec3 c ){
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
                             6.0)-3.0)-1.0,0.0,1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix( vec3(1.0), rgb, c.y);
}

vec2 random2( vec2 p ) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}


void main()
{
    vec2 st = gl_FragCoord.xy/u_Resolution.xy;
    st.x *= u_Resolution.x/u_Resolution.y;
    vec3 color = vec3(.0);

    // Scale
    st *= 3.;

    // Tile the space
    vec2 i_st = floor(st);
    vec2 f_st = fract(st);

    float m_dist = 1.;  // minimun distance

    for (int y= -1; y <= 1; y ++) {
        for (int x= -1; x <= 1; x ++) {
            vec2 neighbor = vec2(float(x),float(y));
             // Random position from current + neighbor place in the grid
            vec2 point = random2(i_st + neighbor);
            // Vector between the pixel and the point
            vec2 diff = neighbor + point - f_st;
            // Distance to the point
            float dist = length(diff);
            // Keep the closer distance
            m_dist = min(m_dist, dist);
        }
    }
    
    // Draw the min distance (distance field)
    color += m_dist;

    // Draw cell center
    color += 1.-step(.02, m_dist);

//     // Draw grid
    color.r += step(.98, f_st.x) + step(.98, f_st.y);

    // Show isolines
    color -= step(.7,abs(sin(27.0*m_dist)))*.5;
    out_Col = vec4(color,1.0);
}

