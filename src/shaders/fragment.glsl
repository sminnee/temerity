// Fragment shader program
precision mediump int;
precision mediump float;

// Light model
uniform vec3 u_lightPosition;

// Data coming from the vertex shader
varying vec3 v_position;
varying vec4 v_color;
varying vec3 v_normal;
varying vec2 v_textureCoord;

uniform sampler2D u_textureSampler;

void main() {

  vec3 toLight;
  vec3 normal;
  float cosAngle;

  // Calculate a vector from the fragment location to the light source
  toLight = u_lightPosition - v_position;
  toLight = normalize( toLight );

  // The vertex's normal vector is being interpolated across the primitive
  // which can make it un-normalized. So normalize the vertex's normal vector.
  normal = normalize( v_normal );

  // Calculate the cosine of the angle between the vertex's normal vector
  // and the vector going to the light.
  cosAngle = dot(normal, toLight);
  cosAngle = clamp(cosAngle, 0.0, 1.0);

  // Scale the color of this fragment based on its angle to the light.
  //gl_FragColor = vec4(vec3(v_Color) * cos_angle, v_Color.a);
  gl_FragColor = texture2D(u_textureSampler, v_textureCoord) * cosAngle;
}
