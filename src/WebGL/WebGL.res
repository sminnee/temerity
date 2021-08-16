// https://developer.mozilla.org/en-US/docs/Web/API/WebGLRenderingContext
// https://developer.mozilla.org/en-US/docs/Web/API/WebGL2RenderingContext

type t

type contextAttributes
type buffer
type shader
type program
type attribRef = int
type uniformRef = int
type texture
type precisionFormat

// to do: more clarity on this
type index = int

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
    | @as(33984) #Texture0
    | #Texture1
    | #Texture2
    | #Texture3
    | #Texture4
    | #Texture5
    | #Texture6
    | #Texture7
    | #Texture8
    | #Texture9
    | #Texture10
    | #Texture11
    | #Texture12
    | #Texture13
    | #Texture14
    | #Texture15
  ],
) => unit = "activeTexture"

@send
external textureBindingPointRaw: @int
[
  | @as(33984) #Texture0
  | #Texture1
  | #Texture2
  | #Texture3
  | #Texture4
  | #Texture5
  | #Texture6
  | #Texture7
  | #Texture8
  | #Texture9
  | #Texture10
  | #Texture11
  | #Texture12
  | #Texture13
  | #Texture14
  | #Texture15
] => int = "%identity"

let textureBindingPoint = val => textureBindingPointRaw(val) - 33984

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
external bindBuffer: (
  t,
  @int
  [
    | @as(34962) #ArrayBuffer
    | #ElementArrayBuffer
    | @as(36662) #CopyReadBuffer
    | #CopyWriteBuffer
    | @as(35982) #TransformFeedbackBuffer
    | @as(35345) #UniformBuffer
    | @as(35051) #PixelPackBuffer
    | #PixelUnpackBuffer
  ],
  buffer,
) => unit = "bindBuffer"

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

@send
external getBufferParameterSize: (
  t,
  @int [@as(34962) #ArrayBuffer | #ElementArrayBuffer],
  @as(34660) _,
) => int = "getBufferParameter"

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
) => precisionFormat = "getShaderPrecisionFormat"

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

@send external vertexAttrib1f: (t, attribRef, float) => unit = "vertexAttrib1f"
@send external vertexAttrib2f: (t, attribRef, float, float) => unit = "vertexAttrib2f"
@send external vertexAttrib3f: (t, attribRef, float, float, float) => unit = "vertexAttrib3f"
@send external vertexAttrib4f: (t, attribRef, float, float, float, float) => unit = "vertexAttrib4f"

@send external vertexAttrib1fv: (t, attribRef, array<float>) => unit = "vertexAttrib1fv"
@send external vertexAttrib2fv: (t, attribRef, array<float>) => unit = "vertexAttrib2fv"
@send external vertexAttrib3fv: (t, attribRef, array<float>) => unit = "vertexAttrib3fv"
@send external vertexAttrib4fv: (t, attribRef, array<float>) => unit = "uniform4fv"

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
@send external clear: (t, @as(0) _) => unit = "clear"

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

// Textures

@send
external bindTexture: (
  t,
  @int [@as(3553) #Texture2D | @as(34067) #TextureCubeMap],
  texture,
) => unit = "bindTexture"

// compressedTexImage2D
// compressedTexSubImage2D

@send
external copyTexImage2D: (
  t,
  [
    | @as(3553) #Texture2D
    | @as(34069) #TextureCubeMapPositiveX
    | #TextureCubeMapNegativeX
    | #TextureCubeMapPositiveY
    | #TextureCubeMapNegativeY
    | #TextureCubeMapPositiveZ
    | #TextureCubeMapNegativeZ
  ],
  int,
  int,
  int,
  int,
  int,
  int,
  int,
) => unit = "copyTexImage2D"

@send
external copyTexSubImage2D: (
  t,
  [
    | @as(3553) #Texture2D
    | @as(34069) #TextureCubeMapPositiveX
    | #TextureCubeMapNegativeX
    | #TextureCubeMapPositiveY
    | #TextureCubeMapNegativeY
    | #TextureCubeMapPositiveZ
    | #TextureCubeMapNegativeZ
  ],
  int,
  int,
  int,
  int,
  int,
  int,
  int,
) => unit = "copyTexImage2D"

@send
external createTexture: t => texture = "createTexture"

@send
external deleteTexture: (t, texture) => unit = "deleteTexture"

@send
external generateMipMap: (t, @int [@as(3553) #Texture2D | @as(34067) #TextureCubeMap]) => unit =
  "generateMipMap"

// getTexParameter

@send
external isTexture: (t, texture) => bool = "isTexture"

@send
external texImage2D: (
  t,
  @int
  [
    | @as(3553) #Texture2D
    | @as(34069) #TextureCubeMapPositiveX
    | #TextureCubeMapNegativeX
    | #TextureCubeMapPositiveY
    | #TextureCubeMapNegativeY
    | #TextureCubeMapPositiveZ
    | #TextureCubeMapNegativeZ
  ],
  int,
  @int [@as(6406) #Alpha | #RGB | #RGBA | #Luminance | #LuminanceAlpha],
  @int [@as(6406) #Alpha | #RGB | #RGBA | #Luminance | #LuminanceAlpha],
  @int
  [
    | @as(5121) #UnsignedByte
    | @as(33635) #UnsignedShort_565
    | @as(32819) #UsignedShort_4444
    | #UsignedShort_5551
  ],
  'a,
) => unit = "texImage2D"

// texSubImage2D

@send
external texParameteri: (
  t,
  @int [@as(3553) #Texture2D | @as(34067) #TextureCubeMap],
  @int
  [
    | @as(10240) #TextureMagFilter
    | #TextureMinFilter
    | #TextureWrapS
    | #TextureWrapT
  ],
  @int
  [
    | @as(9729) #Nearest
    | #Linear
    | @as(9984) #NearestMipmapNearest
    | #LinearMipmapNearest
    | #NearestMipmapLinear
    | #LinearMipmapLinear
    | @as(10497) #Repeat
    | @as(33071) #ClampToEdge
    | @as(33648) #MirroredRepeat
  ],
) => unit = "texParameteri"

// WebGL2

// Drawing buffers

@send external vertexAttribDivisor: (t, attribRef, int) => unit = "vertexAttribDivisor"

@send
external drawArraysInstanced: (
  t,
  @int [#Points | #Lines | #LineLoop | #LineStrip | #Triangles | #TriangleStrip | #TriangleFan],
  int,
  int,
  int,
) => unit = "drawArraysInstanced"

@send
external drawElementsInstance: (
  t,
  @int [#Points | #Lines | #LineLoop | #LineStrip | #Triangles | #TriangleStrip | #TriangleFan],
  int,
  @int [@as(5121) #UnsignedByte | @as(5123) #UnsignedShort],
  int,
  int,
) => unit = "drawArraysInstanced"

@send
external drawRangeElements: (
  t,
  @int [#Points | #Lines | #LineLoop | #LineStrip | #Triangles | #TriangleStrip | #TriangleFan],
  int,
  int,
  int,
  @int [@as(5121) #UnsignedByte | @as(5123) #UnsignedShort],
  int,
) => unit = "drawArraysInstanced"

@send
external drawBuffers: (
  t,
  @int
  [
    | @as(0) #None
    | @as(1029) #Back
    | @as(36064) #ColorAttachment0
    | #ColorAttachment1
    | #ColorAttachment2
    | #ColorAttachment3
    | #ColorAttachment4
    | #ColorAttachment5
    | #ColorAttachment6
    | #ColorAttachment7
    | #ColorAttachment8
    | #ColorAttachment9
    | #ColorAttachment10
    | #ColorAttachment11
    | #ColorAttachment12
    | #ColorAttachment13
    | #ColorAttachment14
    | #ColorAttachment15
  ],
) => unit = "drawBuffers"

@send
external clearBufferfv: (t, int, @int [@as(6144) #Color | #Depth], array<float>) => unit =
  "clearBufferfv"
@send
external clearBufferiv: (t, int, @int [@as(6144) #Color | #Depth | #Stencil], array<int>) => unit =
  "clearBufferiv"
@send
external clearBufferfuiv: (t, int, @int [#Color | #Depth | #Stencil], array<int>) => unit =
  "clearBufferfuiv"
@send
external clearBufferfi: (t, int, @int [@as(34041) #DepthStencil], float, int) => unit =
  "clearBufferfi"

// Uniform buffer objects

@send external bindBufferBase: (t, uniformRef, buffer) => unit = "bindBufferBase"

@send external bindBufferRange: (t, uniformRef, buffer, int, int) => unit = "bindBufferRange"

@send
external getUniformIndices: (t, program, array<string>) => array<uniformRef> = "getUniformIndices"

@send
external getActiveUniformsType: (t, program, array<uniformRef>, @as(35383) _) => array<int> =
  "getActiveUniforms"

@send
external getActiveUniformsInt: (
  t,
  program,
  array<uniformRef>,
  @int
  [
    | @as(35384) #UniformSize
    | @as(35386) #UniformBlockIndex
    | #UniformOffset
    | #UniformArrayStride
    | #UniformMatrixStride
  ],
) => array<int> = "getActiveUniforms"

@send
external getActiveUniformsBool: (
  t,
  program,
  array<uniformRef>,
  @int [@as(35390) #UniformIsRowMajor],
) => array<int> = "getActiveUniforms"

@send external getUniform: (t, program, uniformRef) => 'a = "getUniform"

@send external getUniformBlockIndex: (t, program, string) => uniformRef = "getUniformBlockIndex"

@send
external getActiveUniformBlockParameterInt: (
  t,
  program,
  uniformRef,
  @int
  [
    | @as(35391) #UniformBlockBinding
    | #UniformBlockDataSize
    | @as(35394) #UniformBlockActiveUniforms
  ],
) => int = "getActiveUniformBlockParameter"

@send
external getActiveUniformBlockParameterArray: (
  t,
  program,
  uniformRef,
  @int [@as(35395) #UniformBlockActiveUniformIncides],
) => array<int> = "getActiveUniformBlockParameter"

@send
external getActiveUniformBlockParameterBool: (
  t,
  program,
  uniformRef,
  @int
  [
    | @as(35396) #UniformBlockReferencedByVertexShader
    | @as(35398) #UniformBlockReferencedByFragmentShader
  ],
) => bool = "getActiveUniformBlockParameter"

@send
external getActiveUnifomBlockName: (t, program, uniformRef) => string = "getActiveUnifomBlockName"

@send
external uniformBlockBinding: (t, program, uniformRef, uniformRef) => string = "uniformBlockBinding"
