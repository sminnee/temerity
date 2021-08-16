// Vertex Shader
precision mediump int;
precision mediump float;

// Scene transformations
uniform mat4 u_cameraProjection; // Projection, view, model transform
uniform mat4 u_cameraView;  // View, model transform
uniform mat4 u_modelTransform;  // Transformation common to all instances

// Light model
uniform vec3 u_lightPosition;

// Loaded per-instance
attribute mat4 a_modelPosition;

// Original model data
attribute vec3 a_vtx;
attribute vec3 a_vtxColor;
attribute vec3 a_vtxNormal;
attribute vec2 a_vtxTextureCoord;

// Data (to be interpolated) that is passed on to the fragment shader
varying vec3 v_position;
varying vec4 v_color;
varying vec3 v_normal;
varying vec2 v_textureCoord;

void main() {
  mat4 vm;
  mat4 pvm;

  vm = u_cameraView * a_modelPosition * u_modelTransform;
  pvm = u_cameraProjection * vm;

  // Perform the model and view transformations on the vertex and pass this
  // location to the fragment shader.
  v_position = vec3( vm * vec4(a_vtx, 1.0) );

  // Perform the model and view transformations on the vertex's normal vector
  // and pass this normal vector to the fragment shader.
  v_normal = vec3( vm * vec4(a_vtxNormal, 0.0) );

  // Pass the vertex's color to the fragment shader.
  v_color = vec4(a_vtxColor, 1.0);

  v_textureCoord = a_vtxTextureCoord;

  // Transform the location of the vertex for the rest of the graphics pipeline
  gl_Position = pvm * vec4(a_vtx, 1.0);
}
