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
uniform float u_WorleyScale;



// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec3 fs_Pos;
in float fs_Type;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

//  Function from Iñigo Quiles
//  https://www.shadertoy.com/view/MsS3Wc
vec3 random3( vec3 p ) {
    float j = 4096.0*sin(dot(p,vec3(17.0, 59.4, 15.0)));
	vec3 r = vec3(0.);
	r.z = fract(512.0*j);
	j *= .125;
	r.x = fract(512.0*j);
	j *= .125;
	r.y = fract(512.0*j);
	return r-0.5;
}

#define FLOWER
//#define STRIPED
//#define VORONOI
void main()
{
    vec3 st = fs_Pos;//vec2 st = gl_FragCoord.xy/u_Resolution.xy;
    //st.x *= u_Resolution.x/u_Resolution.y;
    vec3 color = vec3(.0);

    // Scale
    st *= u_WorleyScale;
    // Tile the space
    vec3 i_st = floor(st);//vec2 i_st = floor(st);
    vec3 f_st = fract(st);//vec2 f_st = fract(st);

    float m_dist = 1.;  // minimun distance
    vec3 minNeighbor = vec3(0.);
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
                if(dist < m_dist){
                    minNeighbor = neighbor;
                }
                m_dist = min(m_dist, dist);

            }
        }
    }
    
    // Draw the min distance (distance field)
    color += m_dist;

    // Draw cell center
    color += 1.-step(.02, m_dist);

    #ifdef VORONOI
    out_Col = vec4(minNeighbor, 1.0);
    #endif

    // Draw grid
    //color.r += step(.98, f_st.x) + step(.98, f_st.y);
    #ifdef FLOWER
    color = vec3(1.) - color;
    vec3 colorM = vec3(0.);
    //out_Col = vec4(1.);
    if (fs_Type == 2.){
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        // diffuseTerm = clamp(diffuseTerm, 0, 1);

        float ambientTerm = 0.2;

        float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.

        // Compute final shaded color
        out_Col = vec4(vec3(0.,1.,0.) * lightIntensity, 1.);
    } else {
        colorM = vec3(0.,1.,2.0);
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        // diffuseTerm = clamp(diffuseTerm, 0, 1);

        float ambientTerm = 0.2;

        float lightIntensity = diffuseTerm + ambientTerm;  
        vec3 newColor = vec3(min(colorM.r * color.r,1.0),min(colorM.g * color.g,1.), min(colorM.b * color.b, 1.));
        out_Col = vec4(newColor * lightIntensity,1.0);
    }

    #endif

    #ifdef STRIPED
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

    out_Col = vec4(stripe.rgb, 1.0);
    #endif
    
}

