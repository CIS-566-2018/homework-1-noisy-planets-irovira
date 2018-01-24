// Add a Cube class that inherits from Drawable
//  and at the very least implement a constructor
//   and its create function.Then, add a Cube instance to the scene to be rendered.

// Read the documentation for dat.GUI below. 
// Update the existing GUI in main.ts with a parameter to alter the color passed to u_Color in the Lambert shader.
// Write a custom shader of your choosing and add a GUI element that allows the user to switch shaders. 
// Your custom shader must use a trig function to modify vertex position or fragment color non-uniformly. 
// If your custom shader is particularly interesting, you'll earn some bonus points.

import {vec3, vec4} from 'gl-matrix';
import Drawable from '../rendering/gl/Drawable';
import {gl} from '../globals';

class Cube extends Drawable {
  indices: Uint32Array;
  positions: Float32Array;
  normals: Float32Array;
  center: vec4;

  constructor(center: vec3) {
    super(); // Call the constructor of the super class. This is required.
    this.center = vec4.fromValues(center[0], center[1], center[2], 1);
  }

  create() {

  this.indices = new Uint32Array([0,1,3,
                                  1,3,2,
                                  4,5,7,
                                  5,7,6,
                                  8,9,11,
                                  9,11,10,
                                  12,13,15,
                                  13,15,14,
                                  16,17,19,
                                  17,19,18,
                                  20,21,23,
                                  21,23,22]);
  this.normals = new Float32Array([0, 0, 1, 0,
                                   0, 0, 1, 0,
                                   0, 0, 1, 0,
                                   0, 0, 1, 0,
                                   0, 1, 0, 0,
                                   0, 1, 0, 0,
                                   0, 1, 0, 0,
                                   0, 1, 0, 0,
                                   0, 0, -1, 0,
                                   0, 0, -1, 0,
                                   0, 0, -1, 0,
                                   0, 0, -1, 0,
                                   0, -1, 0, 0,
                                   0, -1, 0, 0,
                                   0, -1, 0, 0,
                                   0, -1, 0, 0,
                                   -1, 0, 0, 0,
                                   -1, 0, 0, 0,
                                   -1, 0, 0, 0,
                                   -1, 0, 0, 0,
                                   1, 0, 0, 0,
                                   1, 0, 0, 0,
                                   1, 0, 0, 0,
                                   1, 0, 0, 0,]);
  this.positions = new Float32Array([0, 1, 0, 1,
                                     1, 1, 0, 1,
                                     1, 0, 0, 1,
                                     0, 0, 0, 1,
                                     0, 1, -1, 1,
                                     1,1,-1,1,
                                     1,1,0,1,
                                     0,1,0,1,
                                     1,1,-1,1,
                                     0,1,-1,1,
                                     0,0,-1,1,
                                     1,0,-1,1,
                                     0,0,-1,1,
                                     1,0,-1,1,
                                     1,0,0,1,
                                     0,0,0,1,
                                     0,1,-1,1,
                                     0,1,0,1,
                                     0,0,0,1,
                                     0,0,-1,1,
                                     1,1,0,1,
                                     1,1,-1,1,
                                     1,0,-1,1,
                                     1,0,0,1]);

    this.generateIdx();
    this.generatePos();
    this.generateNor();

    this.count = this.indices.length;
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.bufIdx);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, this.indices, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufNor);
    gl.bufferData(gl.ARRAY_BUFFER, this.normals, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufPos);
    gl.bufferData(gl.ARRAY_BUFFER, this.positions, gl.STATIC_DRAW);

    console.log(`Created square`);
  }
};

export default Cube;
