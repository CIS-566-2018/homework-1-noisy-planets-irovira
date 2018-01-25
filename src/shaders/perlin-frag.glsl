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

void main()
{
    // Material base color (before shading)

    //Rainbow Shader based on Book of Shaders
    //https://thebookofshaders.com/06/
    
        vec3 color = vec3(0.0);
        vec2 st = gl_FragCoord.xy /u_Resolution;
        vec2 center = vec2(0.5);
        vec2 toCenter = vec2(0.5) - st;
        float angle = atan(toCenter.y,toCenter.x) + u_Time; //added time animation
        float radius = length(toCenter)*2.0;

        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        color = hsb2rgb(vec3((angle/TWO_PI)+0.5,radius,1.0));
        float ambientTerm = 0.2;

        float lightIntensity = diffuseTerm + ambientTerm; 
        out_Col = vec4(color * lightIntensity,1.0);
}
