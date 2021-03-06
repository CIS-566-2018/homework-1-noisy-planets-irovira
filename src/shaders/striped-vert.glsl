#version 300 es

//This is a vertex shader. While it is called a "shader" due to outdated conventions, this file
//is used to apply matrix transformations to the arrays of vertex data passed to it.
//Since this code is run on your GPU, each vertex is transformed simultaneously.
//If it were run on your CPU, each vertex would have to be processed in a FOR loop, one at a time.
//This simultaneous transformation allows your program to run much faster, especially when rendering
//geometry with millions of vertices.

uniform mat4 u_Model;       // The matrix that defines the transformation of the
                            // object we're rendering. In this assignment,
                            // this will be the result of traversing your scene graph.

uniform mat4 u_ModelInvTr;  // The inverse transpose of the model matrix.
                            // This allows us to transform the object's normals properly
                            // if the object has been non-uniformly scaled.

uniform mat4 u_ViewProj;    // The matrix that defines the camera's transformation.
                            // We've written a static matrix for you to use for HW2,
                            // but in HW3 you'll have to generate one yourself

uniform float u_WorleyScale;

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.
out vec3 fs_Pos;

const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.
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

void main()
{
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation
    fs_Pos = vs_Pos.xyz;                    //pass vertex position to fragment shader

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.
    
    vec3 st = vs_Pos.xyz;
    vec3 worleyFactor = vec3(.0);

    // Scale
    st *= u_WorleyScale;

    if(u_WorleyScale ==2.0){
        st /= u_WorleyScale;
        st *= 2.;
    }

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
    worleyFactor += m_dist;

    // Draw cell center
    worleyFactor += 1.-step(.02, m_dist); 

    float wF = 1. - length(worleyFactor); //zebra fish
    //float wF = length(worleyFactor); //a very interesting...glass...sculpture..?


    vec4 modelposition = u_Model * (vs_Pos + (wF * vs_Nor));   // Temporarily store the transformed vertex positions for use below

    fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies

    gl_Position = u_ViewProj * modelposition;// gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices
}
