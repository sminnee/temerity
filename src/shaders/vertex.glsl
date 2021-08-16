// Vertex Shader
precision mediump int;
precision mediump float;

// Scene transformations
uniform mat4 u_PV_transform; // Projection, view, model transform
uniform mat4 u_V_transform;  // View, model transform
uniform mat4 u_M_transform;  // Transformation common to all instances

// Light model
uniform vec3 u_Light_position;

// Loaded per-instance
attribute mat4 u_Pos_transform;

// Original model data
attribute vec3 a_Vertex;
attribute vec3 a_Color;
attribute vec3 a_Vertex_normal;
attribute vec2 a_Texture_coordinate;

// Data (to be interpolated) that is passed on to the fragment shader
varying vec3 v_Vertex;
varying vec4 v_Color;
varying vec3 v_Normal;
varying vec2 v_Texture_coordinate;

void main() {
  mat4 vm;
  mat4 pvm;

  vm = u_V_transform * u_Pos_transform * u_M_transform;
  pvm = u_PV_transform * u_Pos_transform * u_M_transform;

  // Perform the model and view transformations on the vertex and pass this
  // location to the fragment shader.
  v_Vertex = vec3( vm * vec4(a_Vertex, 1.0) );

  // Perform the model and view transformations on the vertex's normal vector
  // and pass this normal vector to the fragment shader.
  v_Normal = vec3( vm * vec4(a_Vertex_normal, 0.0) );

  // Pass the vertex's color to the fragment shader.
  v_Color = vec4(a_Color, 1.0);

  v_Texture_coordinate = a_Texture_coordinate;

  // Transform the location of the vertex for the rest of the graphics pipeline
  gl_Position = pvm * vec4(a_Vertex, 1.0);
}
