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

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.

const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.

vec3 random3( vec3 p ) {
    //return normalize(2. * fract(sin(vec3(dot(p,vec3(127.1,311.7,239.1)),dot(p,vec3(269.5,183.3,329.1)),dot(p,vec3(350.5,270.3,183.1))))*43758.5453) - 1.);
	float j = 4096.0*sin(dot(p,vec3(17.0, 59.4, 15.0)));
	vec3 r = vec3(0.);
	r.z = fract(512.0*j);
	j *= .125;
	r.x = fract(512.0*j);
	j *= .125;
	r.y = fract(512.0*j);
	return r-0.5;
}
float surflet(vec3 P, vec3 gridPoint)
{
    // Compute falloff function by converting linear distance to a polynomial
    float distX = abs(P.x - gridPoint.x);
    float distY = abs(P.y - gridPoint.y);
    float distZ = abs(P.z - gridPoint.z);
    float tX = 1. - 6. * pow(distX, 5.0) + 15. * pow(distX, 4.0) - 10. * pow(distX, 3.0);
    float tY = 1. - 6. * pow(distY, 5.0) + 15. * pow(distY, 4.0) - 10. * pow(distY, 3.0);
    float tZ = 1. - 6. * pow(distZ, 5.0) + 15. * pow(distZ, 4.0) - 10. * pow(distZ, 3.0);

    // Get the random vector for the grid point
    vec3 gradient = random3(gridPoint);
    // Get the vector from the grid point to P
    vec3 diff = P - gridPoint;
    // Get the value of our height field by dotting grid->P with our gradient
    float height = dot(diff, gradient);
    // Scale our height field (i.e. reduce it) by our polynomial falloff function
    return height * tX * tY * tZ;
}

float PerlinNoise(vec3 p)
{
    // Tile the space
    vec3 pXLYLZL = floor(p);
    //top face
    vec3 pXHYLZH = pXLYLZL + vec3(1.,0.,1.);
    vec3 pXHYHZH = pXLYLZL + vec3(1.,1.,1.);
    vec3 pXLYHZH = pXLYLZL + vec3(0.,1.,1.);
    vec3 pXLYLZH = pXLYLZL + vec3(0.,0.,1.);
    //bottom face
    vec3 pXHYLZL = pXLYLZL + vec3(1.,0.,0.);
    vec3 pXHYHZL = pXLYLZL + vec3(1.,1.,0.);
    vec3 pXLYHZL = pXLYLZL + vec3(0.,1.,0.);

    return surflet(p, pXLYLZL) + surflet(p, pXHYLZL) + surflet(p, pXHYHZL) + surflet(p,  pXLYHZL) +
    surflet(p, pXHYLZH) + surflet(p, pXHYHZH) + surflet(p, pXLYHZH) + surflet(p, pXLYLZH);
}

vec3 PixelToGrid(vec3 pixel, float size)
{
    //vec3 uv = pixel.xy / u_Dimensions.xy;
    // Account for aspect ratio
    vec3 uv = vec3(0.);
    vec3 dim = vec3(size);
    uv = pixel;// / dim;
    // Determine number of cells (NxN)
    uv *= size;

    return uv;
}

void main()
{
    vec3 point = PixelToGrid(vs_Pos.xyz,5.0);
    float perlin = PerlinNoise(point);
    vec3 color = vec3(1.0) - vec3(abs(perlin));
   // vec3 c = max(vec3(0.5), color);

    if(color.r < 0.8){
        color = vec3(0.);
    }
    //vec3 color = vec3((perlin + 1.) * 0.5);
    //color.r += step(0.98, fract(point.x)) + step(0.98, fract(point.y)) + step(0.98, fract(point.z));



    mat3 invTranspose = mat3(u_ModelInvTr);

    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);

    vec4 modelposition = u_Model * (vs_Pos + (1.5 * color.r * vs_Nor));  

    fs_LightVec = lightPos - modelposition;   

    gl_Position = u_ViewProj * modelposition;                
    // mat3 invTranspose = mat3(u_ModelInvTr);
    // fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
    //                                                         // Transform the geometry's normals by the inverse transpose of the
    //                                                         // model matrix. This is necessary to ensure the normals remain
    //                                                         // perpendicular to the surface after the surface is transformed by
    //                                                         // the model matrix.


    // vec4 modelposition = u_Model * vs_Pos;   // Temporarily store the transformed vertex positions for use below

    // fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies

    // gl_Position = u_ViewProj * modelposition;// gl_Position is a built-in variable of OpenGL which is
    //                                          // used to render the final positions of the geometry's vertices
}
