import {vec3, vec2} from 'gl-matrix';
import {vec4} from 'gl-matrix';
import * as Stats from 'stats-js';
import * as DAT from 'dat-gui';
import Icosphere from './geometry/Icosphere';
import Square from './geometry/Square';
import Cube from './geometry/Cube';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  tesselations: 5,
  'Load Scene': loadScene, // A function pointer, essentially
  //'test' : test, 
  color: [255.0,0.0,0.0,1.0],
  time: 0.0,
  shader: 'lambert',
};

let icosphere: Icosphere;
let square: Square;
let cube: Cube;


function loadScene() {
  icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, controls.tesselations);
  icosphere.create();

  square = new Square(vec3.fromValues(0, 0, 0));
  square.create();

  cube = new Cube(vec3.fromValues(0, 0, 0));
  cube.create();
  
}

function main() {
  // Initial display for framerate
  const stats = Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

  // GUI CONTROLS
  const gui = new DAT.GUI();
  gui.add(controls, 'tesselations', 0, 8).step(1);
  gui.add(controls, 'Load Scene');

  gui.addColor(controls, 'color');
  // Choose from accepted values
  gui.add(controls, 'shader', [ 'lambert', 'rainbow', 'noise', 'perlin'] );

  // get canvas and webgl context
  const canvas = <HTMLCanvasElement> document.getElementById('canvas');
  const gl = <WebGL2RenderingContext> canvas.getContext('webgl2');
  if (!gl) {
    alert('WebGL 2 not supported!');
  }
  // `setGL` is a function imported above which sets the value of `gl` in the `globals.ts` module.
  // Later, we can import `gl` from `globals.ts` to access it
  setGL(gl);

  // Initial call to load scene
  loadScene();

  const camera = new Camera(vec3.fromValues(0, 0, 5), vec3.fromValues(0, 0, 0));

  const renderer = new OpenGLRenderer(canvas);
  renderer.setClearColor(0.2, 0.2, 0.2, 1);
  gl.enable(gl.DEPTH_TEST);

  const lambert = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/lambert-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/lambert-frag.glsl')),
  ]);

  const rainbow = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/test-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/test-frag.glsl')),
  ]);

  const noise = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/noise-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/noise-frag.glsl')),
  ]);

  const perlin = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/perlin-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/perlin-frag.glsl')),
  ]);

  rainbow.setResolution(vec2.fromValues(window.innerWidth, window.innerHeight));
  noise.setResolution(vec2.fromValues(window.innerWidth, window.innerHeight));
  perlin.setResolution(vec2.fromValues(window.innerWidth, window.innerHeight));

  // const rainbow = new ShaderProgram([
  //   new Shader(gl.VERTEX_SHADER, require('./shaders/rainbow-vert.glsl')),
  //   new Shader(gl.FRAGMENT_SHADER, require('./shaders/rainbow-frag.glsl')),
  // ]);

  let currColor: vec4;
  // This function will be called every frame
  function tick() {
    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();
    currColor = vec4.fromValues(controls.color[0] / 255.0, controls.color[1] / 255.0, controls.color[2] / 255.0, controls.color[3]);
    //test.setGeometryColor(currColor);
    if(controls.shader === 'rainbow'){
      rainbow.setTime(controls.time);
      rainbow.setGeometryColor(currColor);
      renderer.render(camera, rainbow, [
      //icosphere,
      //square,
      cube,
    ]);
    } else if(controls.shader === 'lambert'){
      lambert.setGeometryColor(currColor);
      renderer.render(camera, lambert, [
      icosphere,
      //square,
      //cube,
      ]);
    } else if(controls.shader === 'noise'){
      noise.setGeometryColor(currColor);
      renderer.render(camera, noise, [
      icosphere,
      //square,
      //cube,
      ]);
    } else if(controls.shader === 'perlin'){
      perlin.setGeometryColor(currColor);
      renderer.render(camera, perlin, [
      icosphere,
      //square,
      //cube,
      ]);
    }
    
    stats.end();

    controls.time += 0.01;

    // Tell the browser to call `tick` again whenever it renders a new frame
    requestAnimationFrame(tick);
  }

  window.addEventListener('resize', function() {
    renderer.setSize(window.innerWidth, window.innerHeight);
    rainbow.setResolution(vec2.fromValues(window.innerWidth, window.innerHeight));
    noise.setResolution(vec2.fromValues(window.innerWidth, window.innerHeight));
    perlin.setResolution(vec2.fromValues(window.innerWidth, window.innerHeight));
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();
  }, false);

  //setGeometryColor(color: vec4)

  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();

  // Start the render loop
  tick();
}

main();
