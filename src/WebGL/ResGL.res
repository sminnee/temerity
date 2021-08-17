// Mid-level API on top of WebGL, designed for ReScript

open Belt
open Util

module Canvas = {
  @ocaml.doc("Update the size of the canvas to match its DOM element")
  let resize = canvas => {
    Browser.getClientWidth(canvas)->Browser.setWidth(canvas, _)
    Browser.getClientHeight(canvas)->Browser.setHeight(canvas, _)
  }
}

module Context = {
  @ocaml.doc("Create a WebGL conent for the given DOM element")
  let fromCanvas = canvas => {
    Canvas.resize(canvas)
    WebGL.getContext(canvas, "webgl2")->result_fromOption(["Can't create a WebGL2 context"])
  }

  @ocaml.doc("Create a WebGL conent for the given DOM ID")
  let fromElementId = id =>
    Browser.getElementById(id)
    ->result_fromOption(["Can't find DO element #canvas"])
    ->Result.flatMap(fromCanvas)
}

@ocaml.doc("Represents arrays of float data loaded into the GPU")
module Buffer = {
  @ocaml.doc("Load an array into a WebGL array buffer")
  let fromArray = (context: WebGL.t, ~usage=#StaticDraw, data) =>
    WebGL.createBuffer(context)->Option.map(id => {
      WebGL.bindBuffer(context, #ArrayBuffer, id)
      WebGL.bufferData(context, #ArrayBuffer, data, usage)
      id
    })

  let make = (context, ~usage=#StaticDraw, length) =>
    WebGL.createBuffer(context)->Option.map(id => {
      WebGL.bindBuffer(context, #ArrayBuffer, id)
      WebGL.bufferDataInt(context, #ArrayBuffer, length, usage)
      id
    })

  let loadBuffer = (context: WebGL.t, ~usage=#StaticDraw, id, data) => {
    WebGL.bindBuffer(context, #ArrayBuffer, id)
    WebGL.bufferDataBuffer(context, #ArrayBuffer, data, usage)
  }
}

@ocaml.doc("Represents arrays of index load data loaded into the GPU")
module ElementBuffer = {
  @ocaml.doc("Load an array into a WebGL array buffer")
  let fromArray = (context: WebGL.t, ~usage=#StaticDraw, data) =>
    WebGL.createBuffer(context)->Option.map(id => {
      WebGL.bindBuffer(context, #ElementArrayBuffer, id)
      WebGL.bufferData(context, #ArrayBuffer, data, usage)
      id
    })
}

@ocaml.doc("Represents a texture")
module Texture = {
  @ocaml.doc("Load a texture into the GPU")
  let fromImage = (context, image) => {
    let texture = WebGL.createTexture(context)
    WebGL.bindTexture(context, #Texture2D, texture)
    WebGL.texImage2D(context, #Texture2D, 0, #RGBA, #RGBA, #UnsignedByte, image)
    WebGL.texParameteri(context, #Texture2D, #TextureMagFilter, #Nearest)
    WebGL.texParameteri(context, #Texture2D, #TextureMinFilter, #Nearest)
    texture
  }
}

@ocaml.doc("Represents a compiled shader that forms part of a GPU program")
module Shader = {
  @ocaml.doc("Load a shader")
  let fromString = (context, shaderType, src) =>
    WebGL.createShader(context, shaderType)
    ->Util.result_fromOption(["Can't create shader"])
    ->Result.flatMap(shader => {
      WebGL.shaderSource(context, shader, src)
      WebGL.compileShader(context, shader)
      if WebGL.getShaderParameterBool(context, shader, #CompileStatus) {
        Result.Ok(shader)
      } else {
        Result.Error(["Shader compile error: " ++ WebGL.getShaderInfoLog(context, shader)])
      }
    })
}

@ocaml.doc("Represents a complete GPU program linked from a texture and a fragment shader")
module Program = {
  @ocaml.doc("Create a program from an array of compiled shaders")
  let fromShaders = (context, shaders) => {
    WebGL.createProgram(context)
    ->Util.result_fromOption(["Can't create program"])
    ->Result.flatMap(program => {
      Array.forEach(shaders, WebGL.attachShader(context, program, _))
      WebGL.linkProgram(context, program)
      if WebGL.getProgramParameterBool(context, program, #LinkStatus) {
        Result.Ok(program)
      } else {
        Result.Error(["Program link error: " ++ WebGL.getProgramInfoLog(context, program)])
      }
    })
  }

  @ocaml.doc("Create a program from a single compiled shaders")
  let fromShader = (context, shader) => fromShaders(context, [shader])

  @ocaml.doc("Create a program from a pair of shader source strings")
  let fromStringPair = (context, vertexSrc, fragmentSrc) => {
    result_combine2(
      Shader.fromString(context, #VertexShader, vertexSrc),
      Shader.fromString(context, #FragmentShader, fragmentSrc),
    )->Result.flatMap(((vertex, fragment)) => fromShaders(context, [vertex, fragment]))
  }

  @ocaml.doc("Enable the given program for use")
  let use = (context, program) => WebGL.useProgram(context, program)
}

@ocaml.doc("Load uniform values into the shader")
module Uniform = {
  let ref = WebGL.getUniformLocation

  @ocaml.doc(
    "Returns an 'apply' function that will call its argument passing the ref, if it exists"
  )
  let applyRef = (context, program, name) => {
    switch ref(context, program, name) {
    | Some(ref) => fn => fn(ref)
    | None => _ => ()
    }
  }

  let bind1f = WebGL.uniform1f
  let bind2f = WebGL.uniform2f
  let bind3f = WebGL.uniform3f
  let bind4f = WebGL.uniform4f
  let bind1i = WebGL.uniform1i
  let bind2i = WebGL.uniform2i
  let bind3i = WebGL.uniform3i
  let bind4i = WebGL.uniform4i

  let bindMatrix4 = (context, ref, matrix) => WebGL.uniformMatrix4fv(context, ref, false, matrix)

  let bindTexture2D = (context, ref, bindingPoint, texture) => {
    WebGL.activeTexture(context, bindingPoint)
    WebGL.bindTexture(context, #Texture2D, texture)
    bind1i(context, ref, WebGL.textureBindingPoint(bindingPoint))
  }
}

@ocaml.doc("Load attribute values into the shader")
module Attribute = {
  let ref = WebGL.getAttribLocation

  @ocaml.doc(
    "Returns an 'apply' function that will call its argument passing the ref, if it exists"
  )
  let applyRef = (context, program, name) => {
    switch ref(context, program, name) {
    | Some(ref) => fn => fn(ref)
    | None => _ => ()
    }
  }

  let bind1f = WebGL.vertexAttrib1f
  let bind2f = WebGL.vertexAttrib2f
  let bind3f = WebGL.vertexAttrib3f
  let bind4f = WebGL.vertexAttrib4f

  @ocaml.doc("Bind the content of a buffer to an attribute for a render operation")
  let bindBuffer = (context, ref, itemLength, buffer) => {
    // Activate the model's vertex Buffer Object
    WebGL.enableVertexAttribArray(context, ref)
    WebGL.bindBuffer(context, #ArrayBuffer, buffer)
    WebGL.vertexAttribPointer(context, ref, itemLength, #Float, false, 0, 0)
  }

  @ocaml.doc("bindBuffer() with a buffer item per-instance, rather than per-vertex")
  let bindBufferPerInstance = (context, ref, itemLength, buffer) => {
    bindBuffer(context, ref, itemLength, buffer)
    WebGL.vertexAttribDivisor(context, ref, 1)
  }

  @ocaml.doc("Bind the content of a buffer to a matrix attribute for a render operation")
  let bindMatrixBuffer = (context, ref, buffer) => {
    // Activate the model's vertex Buffer Object
    WebGL.enableVertexAttribArray(context, ref)
    WebGL.enableVertexAttribArray(context, ref + 1)
    WebGL.enableVertexAttribArray(context, ref + 2)
    WebGL.enableVertexAttribArray(context, ref + 3)

    WebGL.bindBuffer(context, #ArrayBuffer, buffer)

    WebGL.vertexAttribPointer(context, ref, 4, #Float, false, 16 * 4, 0)
    WebGL.vertexAttribPointer(context, ref + 1, 4, #Float, false, 16 * 4, 4 * 4)
    WebGL.vertexAttribPointer(context, ref + 2, 4, #Float, false, 16 * 4, 8 * 4)
    WebGL.vertexAttribPointer(context, ref + 3, 4, #Float, false, 16 * 4, 12 * 4)
  }

  @ocaml.doc("bindMatrixBuffer() with a buffer item per-instance, rather than per-vertex")
  let bindMatrixBufferPerInstance = (context, ref, buffer) => {
    bindMatrixBuffer(context, ref, buffer)
    WebGL.vertexAttribDivisor(context, ref, 1)
    WebGL.vertexAttribDivisor(context, ref + 1, 1)
    WebGL.vertexAttribDivisor(context, ref + 2, 1)
    WebGL.vertexAttribDivisor(context, ref + 3, 1)
  }
}
