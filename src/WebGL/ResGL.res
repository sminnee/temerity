// Mid-level API on top of WebGL, designed for ReScript

open Belt

@ocaml.doc("Represents arrays of float data loaded into the GPU")
module Buffer = {
  @ocaml.doc("Load an array into a WebGL array buffer")
  let fromArray = (context: WebGL.t, ~purpose=#StaticDraw, data) =>
    WebGL.createBuffer(context)->Option.map(id => {
      WebGL.bindBuffer(context, #ArrayBuffer, id)
      WebGL.bufferData(context, #ArrayBuffer, data, purpose)
      id
    })
}

@ocaml.doc("Represents arrays of index load data loaded into the GPU")
module ElementBuffer = {
  @ocaml.doc("Load an array into a WebGL array buffer")
  let fromArray = (context: WebGL.t, ~purpose=#StaticDraw, data) =>
    WebGL.createBuffer(context)->Option.map(id => {
      WebGL.bindBuffer(context, #ElementArrayBuffer, id)
      WebGL.bufferData(context, #ArrayBuffer, data, purpose)
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
    WebGL.createShader(context, shaderType)->Option.map(shader => {
      WebGL.shaderSource(context, shader, src)
      WebGL.compileShader(context, shader)
      shader
    })
}

@ocaml.doc("Represents a complete GPU program linked from a texture and a fragment shader")
module Program = {
  @ocaml.doc("Create a program from a pair of compiled shaders")
  let fromShaderPair = (context, vertexShader, fragmentShader) => {
    WebGL.createProgram(context)->Option.flatMap(program => {
      WebGL.attachShader(context, program, vertexShader)
      WebGL.attachShader(context, program, fragmentShader)
      WebGL.linkProgram(context, program)
      if WebGL.getProgramParameterBool(context, program, #LinkStatus) {
        Some(program)
      } else {
        None
      }
    })
  }

  @ocaml.doc("Create a program from a pair of shader source strings")
  let fromStringPair = (context, vertexSrc, fragmentSrc) => {
    switch (
      Shader.fromString(context, #VertexShader, vertexSrc),
      Shader.fromString(context, #FragmentShader, fragmentSrc),
    ) {
    | (Some(vertex), Some(fragment)) => fromShaderPair(context, vertex, fragment)
    | _ => None
    }
  }

  @ocaml.doc("Enable the given program for use")
  let use = (context, program) => WebGL.useProgram(context, program)
}

@ocaml.doc("Load uniform values into the shader")
module Uniform = {
  let ref = WebGL.getUniformLocation

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

  let bind1f = WebGL.vertexAttrib1f
  let bind2f = WebGL.vertexAttrib2f
  let bind3f = WebGL.vertexAttrib3f
  let bind4f = WebGL.vertexAttrib4f

  @ocaml.doc("Bind the content of a buffer to an attribute for a render opera tion")
  let bindBuffer = (context, attrib, itemLength, buffer) => {
    // Activate the model's vertex Buffer Object
    WebGL.enableVertexAttribArray(context, attrib)
    WebGL.bindBuffer(context, #ArrayBuffer, buffer)
    WebGL.vertexAttribPointer(context, attrib, itemLength, #Float, false, 0, 0)
  }
}