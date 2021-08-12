// https://developer.mozilla.org/en-US/docs/Web/API/WebGLRenderingContext
type t
type contextAttributes
type buffer
type shader
type program
type attribRef
type uniformRef

type activeInfo = {
  name: string,
  size: int,
  // type
}

@send @return(nullable) external getContext: (Dom.element, string) => option<t> = "getContext"

// The WebGL context
@get @return(nullable) external getCanvas: t => option<Dom.element> = "canvas"
@send external commit: t => unit = "commit"
@get external getDrawingBufferWidth: t => int = "drawingBufferWidth"
@get external getDrawingBufferHeight: t => int = "drawingBufferHeight"
@send external getContextAttributes: t => contextAttributes = "getContextAttributes"
@send external isContextLost: t => bool = "isContextLost"
@send external makeXRCompatible: t => Js.Promise.t<'a> = "makeXRCompatible"

// Viewing and clipping
@send external scissor: (t, int, int, int, int) => unit = "scissor"

@send external viewport: (t, int, int, int, int) => unit = "viewport"

// State information
@send
external activeTexture: (
  t,
  @int
  [
    | @as(33985) #Texture1
    | #Texture2
    | #Texture3
    | #Texture4
    | #Texture5
    | #Texture6
    | #Texture7
  ],
) => unit = "activeTexture"

@send external blendColor: (t, float, float, float, float) => unit = "blendColor"

@send
external blendEquation: (
  t,
  @int
  [
    | @as(32774) #FuncAdd
    | @as(32778) #FuncSubtract
    | @as(32779) #FuncReverseSubtract
  ],
) => unit = "blendEquation"

@send
external blendEquationSeparate: (
  t,
  @int
  [
    | @as(32774) #FuncAdd
    | @as(32778) #FuncSubtract
    | #FuncReverseSubtract
  ],
  @int
  [
    | @as(32774) #FuncAdd
    | @as(32778) #FuncSubtract
    | #FuncReverseSubtract
  ],
) => unit = "blendEquationSeparate"

@send
external blendFunc: (
  t,
  @int
  [
    | @as(0) #Zero
    | #One
    | @as(768) #SrcColor
    | #OneMinusSrcColor
    | #SrcAlpha
    | #OneMinusSrcAlpha
    | #DstAlpha
    | #OneMinusDstAlpha
    | #DstColor
    | #OneMinusDstColor
    | #SrcAlphaSaturate
    | @as(32769) #ConstantColor
    | #OneMinusConstantColor
    | #ConstantAlpha
    | @as(37222) #OneMinusConstantAlpha
  ],
  @int
  [
    | @as(0) #Zero
    | #One
    | @as(768) #SrcColor
    | #OneMinusSrcColor
    | #SrcAlpha
    | #OneMinusSrcAlpha
    | #DstAlpha
    | #OneMinusDstAlpha
    | #DstColor
    | #OneMinusDstColor
    | #SrcAlphaSaturate
    | @as(32769) #ConstantColor
    | #OneMinusConstantColor
    | #ConstantAlpha
    | @as(37222) #OneMinusConstantAlpha
  ],
) => unit = "blendFunc"

@send
external blendFuncSeparate: (
  t,
  @int
  [
    | @as(0) #Zero
    | #One
    | @as(768) #SrcColor
    | #OneMinusSrcColor
    | #SrcAlpha
    | #OneMinusSrcAlpha
    | #DstAlpha
    | #OneMinusDstAlpha
    | #DstColor
    | #OneMinusDstColor
    | #SrcAlphaSaturate
    | @as(32769) #ConstantColor
    | #OneMinusConstantColor
    | #ConstantAlpha
    | @as(37222) #OneMinusConstantAlpha
  ],
  @int
  [
    | @as(0) #Zero
    | #One
    | @as(768) #SrcColor
    | #OneMinusSrcColor
    | #SrcAlpha
    | #OneMinusSrcAlpha
    | #DstAlpha
    | #OneMinusDstAlpha
    | #DstColor
    | #OneMinusDstColor
    | #SrcAlphaSaturate
    | @as(32769) #ConstantColor
    | #OneMinusConstantColor
    | #ConstantAlpha
    | @as(37222) #OneMinusConstantAlpha
  ],
  @int
  [
    | @as(0) #Zero
    | #One
    | @as(768) #SrcColor
    | #OneMinusSrcColor
    | #SrcAlpha
    | #OneMinusSrcAlpha
    | #DstAlpha
    | #OneMinusDstAlpha
    | #DstColor
    | #OneMinusDstColor
    | #SrcAlphaSaturate
    | @as(32769) #ConstantColor
    | #OneMinusConstantColor
    | #ConstantAlpha
    | @as(37222) #OneMinusConstantAlpha
  ],
  @int
  [
    | @as(0) #Zero
    | #One
    | @as(768) #SrcColor
    | #OneMinusSrcColor
    | #SrcAlpha
    | #OneMinusSrcAlpha
    | #DstAlpha
    | #OneMinusDstAlpha
    | #DstColor
    | #OneMinusDstColor
    | #SrcAlphaSaturate
    | @as(32769) #ConstantColor
    | #OneMinusConstantColor
    | #ConstantAlpha
    | @as(37222) #OneMinusConstantAlpha
  ],
) => unit = "blendFuncSeparate"

@send external clearColor: (t, float, float, float, float) => unit = "clearColor"

@send external clearDepth: (t, float) => unit = "clearDepth"

@send external clearStencil: (t, int) => unit = "clearStencil"

@send external colorMask: (t, bool, bool, bool, bool) => unit = "colorMask"

@send
external cullFace: (
  t,
  @int
  [
    | @as(1028) #Front
    | @as(1029) #Back
    | @as(1032) #FrontAndBack
  ],
) => unit = "cullFace"

@send
external depthFunc: (
  t,
  @int
  [
    | @as(512) #Never
    | @as(513) #Less
    | @as(514) #Equal
    | @as(515) #LEqual
    | @as(516) #Greater
    | @as(517) #NotEqual
    | @as(518) #GEqual
    | @as(519) #Always
  ],
) => unit = "depthFunc"

@send external depthMask: (t, bool) => unit = "depthMask"

@send external depthRange: (t, float, float) => unit = "depthRange"

@send
external disable: (
  t,
  @int
  [
    | @as(3042) #Blend
    | @as(2884) #CullFace
    | @as(2929) #DepthTest
    | @as(3024) #Dither
    | @as(32823) #PolygonOffsetFill
    | @as(32926) #SampleAlphaToCoverage
    | @as(32928) #SampleCoverage
    | @as(3089) #ScissorTest
    | @as(2960) #StencilTest
  ],
) => unit = "disable"

@send
external enable: (
  t,
  @int
  [
    | @as(3042) #Blend
    | @as(2884) #CullFace
    | @as(2929) #DepthTest
    | @as(3024) #Dither
    | @as(32823) #PolygonOffsetFill
    | @as(32926) #SampleAlphaToCoverage
    | @as(32928) #SampleCoverage
    | @as(3089) #ScissorTest
    | @as(2960) #StencilTest
  ],
) => unit = "enable"

// Buffers

@send
external bindBuffer: (t, @int [@as(34962) #ArrayBuffer | #ElementArrayBuffer], buffer) => unit =
  "bindBuffer"

@send
external bufferData: (
  t,
  @int [@as(34962) #ArrayBuffer | #ElementArrayBuffer],
  array<float>,
  @int [@as(35044) #StaticDraw | @as(35048) #DynamicDraw | @as(35040) #StreamDraw],
) => unit = "bufferData"

@send
external bufferSubData: (
  t,
  @int [@as(34962) #ArrayBuffer | #ElementArrayBuffer],
  int,
  array<float>,
) => unit = "bufferSubData"

@send @return(nullable) external createBuffer: t => option<buffer> = "createBuffer"

@send external deleteBuffer: (t, buffer) => unit = "deleteBuffer"

@send external getBufferParameterSize: (t, @int [@as(34962) #ArrayBuffer | #ElementArrayBuffer],   @as(34660) _) => int = "getBufferParameter"

@send
external getBufferParameterUsage: (
  t,
  buffer,
  @as(34661) _,
) => @int [@as(35044) #StaticDraw | @as(35048) #DynamicDraw | @as(35040) #StreamDraw] =
  "getBufferParameter"

// Programs and shaders
@send external attachShader: (t, program, shader) => unit = "attachShader"

@send external bindAttribLocation: (t, program, int, string) => unit = "bindAttribLocation"

@send external compileShader: (t, shader) => unit = "compileShader"

@send @return(nullable) external createProgram: t => option<program> = "createProgram"

@send @return(nullable)
external createShader: (
  t,
  @int
  [
    | @as(35633) #VertexShader
    | @as(35632) #FragmentShader
  ],
) => option<shader> = "createShader"

@send external deleteProgram: (t, program) => unit = "deleteProgram"

@send external deleteShader: (t, shader) => unit = "deleteShader"

@send external detachShader: (t, program, shader) => unit = "detachShader"

@send
external getAttachedShaders: (t, program) => array<shader> = "getAttachedShaders"

@send
external getProgramParameterBool: (
  t,
  program,
  @int
  [
    | @as(35712) #DeleteStatus
    | @as(35714) #LinkStatus
    | @as(35715) #ValidateStatus
  ],
) => bool = "getProgramParameter"

@send
external getProgramParameterInt: (
  t,
  program,
  @int
  [
    | @as(35717) #AttachedShaders
    | @as(35721) #ActiveAttributes
    | @as(35718) #ActiveUniforms
  ],
) => int = "getProgramParameter"

@send external getProgramInfoLog: (t, program) => string = "getProgramInfoLog"

@send
external getShaderParameterBool: (
  t,
  shader,
  @int
  [
    | @as(35712) #DeleteStatus
    | @as(35713) #CompileStatus
  ],
) => bool = "getShaderParameter"

@send
external getShaderParameterShaderType: (
  t,
  shader,
  @as(35663) _,
) => @int
[
  | @as(35633) #VertexShader
  | @as(35632) #FragmentShader
] = "getShaderParameter"

@send
external getShaderPrecisionFormat: (
  t,
  @int
  [
    | @as(35633) #VertexShader
    | @as(35632) #FragmentShader
  ],
  @int
  [
    | @as(36336) #LowFloat
    | @as(36337) #MediumFloat
    | @as(36338) #HighFloat
    | @as(36339) #LowInt
    | @as(36340) #MediumInt
    | @as(36341) #HighInt
  ],
) => WebGLPrecisionFormat.t = "getShaderPrecisionFormat"

@send external getShaderInfoLog: (t, shader) => string = "getShaderInfoLog"

@send external getShaderSource: (t, shader) => string = "getShaderSource"

@send external isProgram: (t, program) => bool = "isProgram"

@send external isShader: (t, shader) => bool = "isShader"

@send external linkProgram: (t, program) => unit = "linkProgram"

@send external shaderSource: (t, shader, string) => unit = "shaderSource"

@send external useProgram: (t, program) => unit = "useProgram"

@send external validateProgram: (t, program) => unit = "validateProgram"

// Unforms and attributes

@send external disableVertexAttribArray: (t, attribRef) => unit = "disableVertexAttribArray"

@send external enableVertexAttribArray: (t, attribRef) => unit = "enableVertexAttribArray"

@send external getActiveAttrib: (t, program, attribRef) => activeInfo = "getActiveAttrib"

@send external getActiveUniform: (t, program, uniformRef) => activeInfo = "getActiveUniform"

@send external getAttribLocation: (t, program, string) => attribRef = "getAttribLocation"

@send external getUniformBool: (t, program, uniformRef) => bool = "getUniform"

@send external getUniformInt: (t, program, uniformRef) => int = "getUniform"

@send external getUniformFloat: (t, program, uniformRef) => float = "getUniform"

@send external getUniformFloatVec: (t, program, uniformRef) => array<float> = "getUniform"

@send external getUniformIntVec: (t, program, uniformRef) => array<int> = "getUniform"

@send external getUniformLocation: (t, program, string) => uniformRef = "getUniformLocation"

// getVertexAttrib

// getVertexAttribOffset

@send external uniform1f: (t, uniformRef, float) => unit = "uniform1f"
@send external uniform2f: (t, uniformRef, float, float) => unit = "uniform2f"
@send external uniform3f: (t, uniformRef, float, float, float) => unit = "uniform3f"
@send external uniform4f: (t, uniformRef, float, float, float, float) => unit = "uniform4f"

@send external uniform1fv: (t, uniformRef, array<float>) => unit = "uniform1fv"
@send external uniform2fv: (t, uniformRef, array<float>) => unit = "uniform2fv"
@send external uniform3fv: (t, uniformRef, array<float>) => unit = "uniform3fv"
@send external uniform4fv: (t, uniformRef, array<float>) => unit = "uniform4fv"

@send external uniform1i: (t, uniformRef, int) => unit = "uniform1i"
@send external uniform2i: (t, uniformRef, int, int) => unit = "uniform2i"
@send external uniform3i: (t, uniformRef, int, int, int) => unit = "uniform3i"
@send external uniform4i: (t, uniformRef, int, int, int, int) => unit = "uniform4i"

@send external uniform1iv: (t, uniformRef, array<int>) => unit = "uniform1iv"
@send external uniform2iv: (t, uniformRef, array<int>) => unit = "uniform2iv"
@send external uniform3iv: (t, uniformRef, array<int>) => unit = "uniform3iv"
@send external uniform4iv: (t, uniformRef, array<int>) => unit = "uniform4iv"

@send
external uniformMatrix2fv: (t, uniformRef, bool, array<float>) => unit = "uniformMatrix2fv"
@send
external uniformMatrix3fv: (t, uniformRef, bool, array<float>) => unit = "uniformMatrix3fv"
@send
external uniformMatrix4fv: (t, uniformRef, bool, array<float>) => unit = "uniformMatrix4fv"

// vertexAttrib[1234][fi]v?

// vertexAttribPointer
@send
external vertexAttribPointer: (
  t,
  attribRef,
  int,
  @int [@as(5120) #Byte | #UnsignedByte | #Short | #UnsignedShort | @as(5126) #Float],
  bool,
  int,
  int,
) => unit = "vertexAttribPointer"

// Drawing buffers

// To do: link bitwise OR mask
@send external clear: t => unit = "clear"

@send
external drawArrays: (
  t,
  @int [#Points | #Lines | #LineLoop | #LineStrip | #Triangles | #TriangleStrip | #TriangleFan],
  int,
  int,
) => unit = "drawArrays"

@send
external drawElements: (
  t,
  @int [#Points | #Lines | #LineLoop | #LineStrip | #Triangles | #TriangleStrip | #TriangleFan],
  int,
  @int [@as(5121) #UnsignedByte | @as(5123) #UnsignedShort],
  int,
) => unit = "drawElements"

@send external finish: t => unit = "finish"

@send external flush: t => unit = "flush"
