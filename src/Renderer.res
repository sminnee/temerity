// Handling the core rendering and WebGL maangement

open Belt

type meshData = {
  positions: WebGL.buffer,
  normals: WebGL.buffer,
  length: int,
}

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
  WebGL.enableVertexAttribArray(context, attrib)
  WebGL.bindBuffer(context, #ArrayBuffer, buffer)
  WebGL.vertexAttribPointer(context, attrib, itemLength, #Float, false, 0, 0)
}

type cameraInput = {
  mesh: WebGL.buffer,
  meshLength: int,
  transform: array<float>,
}

@ocaml.doc("Build a renderer, initialising value references & returning a render function")
let makeRenderer = (context, program, ~uniforms, ~attributes, ~render) => {
  Js.log("makeRenderer")
  let handlers = Array.concat(
    Array.map(uniforms, ((name, handler)) => {
      handler(context, WebGL.getUniformLocation(context, program, name))
    }),
    Array.map(attributes, ((name, handler)) => {
      handler(context, WebGL.getAttribLocation(context, program, name))
    }),
  )

  (mesh: meshData, camera) => {
    Array.forEach(handlers, handler => handler(mesh, camera))
    render(context, mesh, camera)
  }
}

type animData = {
  mutable lastLog: float,
  mutable frames: int,
}

let animate = handler => {
  let animData = {frames: 0, lastLog: 0.}

  let rec go = now => {
    animData.frames = animData.frames + 1
    if (now -. animData.lastLog > 10000.) {
      Js.log2("Frame-rate", animData.frames/10)
      animData.frames = 0
      animData.lastLog = now
    }

    Browser.requestAnimationFrame(go)->ignore
    handler(now)
  }

  go(0.)
}
