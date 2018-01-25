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
in vec3 fs_Pos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

//  Function from Iñigo Quiles
//  https://www.shadertoy.com/view/MsS3Wc
vec3 random3( vec3 p ) {
    return fract(sin(vec3(dot(p,vec3(127.1,311.7,239.1)),dot(p,vec3(269.5,183.3,329.1)),dot(p,vec3(350.5,270.3,183.1))))*43758.5453);//sin(vec3(dot(p,vec3(127.1,311.7,239.1))),);
    //fract(sin(vec3(dot(p,vec3(127.1,311.7,239.1)),dot(p,vec3(269.5,183.3,329.1),dot(p,vec3(350.5,270.3,183.1))))*43758.5453);
}


void main()
{
    vec3 st = fs_Pos;//vec2 st = gl_FragCoord.xy/u_Resolution.xy;
    //st.x *= u_Resolution.x/u_Resolution.y;
    vec3 color = vec3(.0);

    // Scale
    st *= 1.;

    // Tile the space
    vec3 i_st = floor(st);//vec2 i_st = floor(st);
    vec3 f_st = fract(st);//vec2 f_st = fract(st);

    float m_dist = 1.;  // minimun distance

    for (int y= -1; y <= 1; y ++) {
        for (int x= -1; x <= 1; x ++) {
            for(int z = -1; z<=1; z++){
                vec3 neighbor = vec3(float(x),float(y),float(z));
             // Random position from current + neighbor place in the grid
                vec3 point = random3(i_st + neighbor);
            // Vector between the pixel and the point
                vec3 diff = neighbor + point - f_st;
            // Distance to the point
                float dist = length(diff);
            // Keep the closer distance
                m_dist = min(m_dist, dist);
            }
        }
    }
    
    // Draw the min distance (distance field)
    color += m_dist;

    // Draw cell center
    color += 1.-step(.02, m_dist);

//     // Draw grid
    //color.r += step(.98, f_st.x) + step(.98, f_st.y);

    // Show isolines
    color -= step(.7,abs(sin(27.0*m_dist)))*.5;
    // Calculate the diffuse term for Lambert shading
    float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
    float ambientTerm = 0.2;

    float lightIntensity = diffuseTerm + ambientTerm; 

    vec3 stripe = vec3(0.);
    if(length(color) >= 0.5){
        //lime green = 50-205-50
        stripe = vec3(50. / 255.,205. / 255.,50. / 255.);
    } else {
        //dark violet = 	148-0-211
        stripe = vec3(148. / 255.,0. / 255.,211. / 255.);
    }
    out_Col = vec4(stripe.rgb * lightIntensity, 1.0);
    
}

