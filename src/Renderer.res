// Handling the core rendering and WebGL maangement

open Belt

type meshData = {
  positions: WebGL.buffer,
  normals: WebGL.buffer,
  textureCoords: WebGL.buffer,
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

/*
single pixel texture

  // Because images have to be downloaded over the internet
  // they might take a moment until they are ready.
  // Until then put a single pixel in the texture so we can
  // use it immediately. When the image has finished downloading
  // we'll update the texture with the contents of the image.
  const level = 0;
  const internalFormat = gl.RGBA;
  const width = 1;
  const height = 1;
  const border = 0;
  const srcFormat = gl.RGBA;
  const srcType = gl.UNSIGNED_BYTE;
  const pixel = new Uint8Array([0, 0, 255, 255]);  // opaque blue

  WebGL.bindTexture(#Texture2D, texture);
  gl.texImage2D(gl.TEXTURE_2D, level, internalFormat,
                width, height, border, srcFormat, srcType,
                pixel);

*/

@ocaml.doc("Load a texture into the GPU")
let loadTexture = (context, image) => {
  let texture = WebGL.createTexture(context);
  WebGL.bindTexture(context, #Texture2D, texture);
  WebGL.texImage2D(context, #Texture2D, 0, #RGBA, #RGBA, #UnsignedByte, image);
  WebGL.texParameteri(context, #Texture2D, #TextureMagFilter, #Nearest);
  WebGL.texParameteri(context, #Texture2D, #TextureMinFilter, #Nearest);
  texture
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
      let ref = WebGL.getUniformLocation(context, program, name)
      if ref == -1 {
        failwith(`Cannot find GLSL uniform ${name}`)
      }
      handler(context, ref)
    }),
    Array.map(attributes, ((name, handler)) => {
      let ref = WebGL.getAttribLocation(context, program, name)
      if  ref == -1 {
        failwith(`Cannot find GLSL attribute ${name}`)
      }
      handler(context, ref)
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
