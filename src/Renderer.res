// Handling the core rendering and WebGL maangement

open Belt

@ocaml.doc("Update the size of the canvas to match its DOM element")
let resizeCanvas = canvas => {
  Browser.getClientWidth(canvas)->Browser.setWidth(canvas, _)
  Browser.getClientHeight(canvas)->Browser.setHeight(canvas, _)
}

let makeContext = canvas => {
  resizeCanvas(canvas)
  WebGL.getContext(canvas, "webgl")
}

@ocaml.doc("Load a shader")
let loadShader = (shaderType, context, src) =>
  WebGL.createShader(context, shaderType)->Option.map(shader => {
    WebGL.shaderSource(context, shader, src)
    WebGL.compileShader(context, shader)
    shader
  })

@ocaml.doc("Load a program based on the 2 shader-sources provided")
let loadProgram = (context, vertexSrc, fragmentSrc) => {
  switch (
    loadShader(#VertexShader, context, vertexSrc),
    loadShader(#FragmentShader, context, fragmentSrc),
  ) {
  | (Some(vertex), Some(fragment)) =>
    WebGL.createProgram(context)->Option.flatMap(program => {
      WebGL.attachShader(context, program, vertex)
      WebGL.attachShader(context, program, fragment)
      WebGL.linkProgram(context, program)
      if WebGL.getProgramParameterBool(context, program, #LinkStatus) {
        Some(program)
      } else {
        None
      }
    })
  | _ => None
  }
}

@ocaml.doc("Bind the content of a buffer to an attribute for a render operation")
let bufferToAttrib = (context, buffer, attrib, itemLength) => {
  // Activate the model's vertex Buffer Object
  WebGL.bindBuffer(context, #ArrayBuffer, buffer)
  WebGL.vertexAttribPointer(context, attrib, itemLength, #Float, false, 0, 0)
  WebGL.enableVertexAttribArray(context, attrib)
}

type renderInput = {
  mesh: WebGL.buffer,
  meshLength: int,
  transform: array<float>,
}

@ocaml.doc("Build a renderer, initialising value references & returning a render function")
let makeRenderer = (context, program, ~uniforms, ~attributes, ~render) => {
  Js.log("makeRenderer")
  let handlers = Array.concat( Array.map(uniforms, ((name, handler)) => {
    handler(context, WebGL.getUniformLocation(context, program, name))
  }),
   Array.map(attributes, ((name, handler)) => {
    handler(context, WebGL.getAttribLocation(context, program, name))
  }))

  (input: renderInput) => {
    Js.log("render")
    Array.forEach(handlers, handler => handler(input))
    render(context, input)
  }
}


// let render = (context, transform, refs) => {
//   // Set the transform for all the triangle vertices
//   WebGL.uniformMatrix4fv(context, refs.transform, false, transform)

//   // Set the color for all of the triangle faces
//   let model_color = [1., 0., 0., 1.]
//   WebGL.uniform4fv(context, refs.color, model_color)

//   bufferToAttrib(context, refs.mesh, refs.vertex, 3)

//   // Draw all of the triangles
//   let number_triangles = 4
//   WebGL.drawArrays(context, #Triangles, 0, number_triangles * 3)
// }
