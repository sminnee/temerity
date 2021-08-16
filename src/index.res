open Belt
let numObjects = 23000
open Util

%%raw(`
import _fragmentShaderSrc from "./shaders/fragment.glsl"
import _vertexShaderSrc from "./shaders/vertex.glsl"
`)
let fragmentShaderSrc = %raw(`_fragmentShaderSrc`)
let vertexShaderSrc = %raw(`_vertexShaderSrc`)

type renderData = {
  texture: WebGL.texture,
  mesh: Renderer.meshData,
  mTransform: array<float>,
  vTransform: array<float>,
  pTransform: array<float>,
  viewTransform: array<float>,
  mPositions: WebGL.buffer,
  lightPos: Vec3.t,
}

let rendererFromProgram = (context, program) => {
  open ResGL

  let uRef = Uniform.applyRef(context, program)
  let aRef = Attribute.applyRef(context, program)

  let withLight = uRef("u_lightPosition")

  let withP = uRef("u_cameraProjection")
  let withV = uRef("u_cameraView")

  let withSampler = uRef("u_textureSampler")
  let withVertex = aRef("a_vtx")
  let withColor = aRef("a_vtxColor")
  let withNormal = aRef("a_vtxNormal")
  let withTextureCoord = aRef("a_vtxTextureCoord")

  let withM = uRef("u_modelTransform")
  let withPos = aRef("a_modelPosition")

  (
    // Once
    ({texture, mesh, pTransform, vTransform, mPositions}) => {
      withSampler(Uniform.bindTexture2D(context, _, #Texture0, texture))
      withVertex(Attribute.bindBuffer(context, _, 3, mesh.positions))
      withNormal(Attribute.bindBuffer(context, _, 3, mesh.normals))
      withTextureCoord(Attribute.bindBuffer(context, _, 2, mesh.textureCoords))
      withP(Uniform.bindMatrix4(context, _, pTransform))
      withV(Uniform.bindMatrix4(context, _, vTransform))
      withColor(Attribute.bind3f(context, _, 1., 0., 1.))
      withPos(Attribute.bindMatrixBufferPerInstance(context, _, mPositions))
    },
    // Once per frame
    ({mTransform, mesh, lightPos}) => {
      withM(Uniform.bindMatrix4(context, _, mTransform))
      withLight(Uniform.bind3f(context, _, lightPos.x, lightPos.y, lightPos.z))
      WebGL.drawArraysInstanced(context, #Triangles, 0, mesh.length, numObjects)
    },
  )
}

let app = (context, mesh, textureImage) => {
  open Renderer
  open ResGL

  // Create a buffer with matrix positions for all objects
  let bufferPositions = () => {
    let randRange = (min, max) => Js.Math.random() *. (max -. min) +. min

    let modelTransform = Matrix4.empty()
    let buffer = Mesh.FloatBuffer.make(numObjects * 16)

    Array.range(0, numObjects)->Array.forEach(_ => {
      let pos = Vec3.make(randRange(-100., 100.), 0., randRange(-200., 200.))
      Transform.translateInto(modelTransform, pos.x, pos.y, pos.z)->ignore
      Mesh.FloatBuffer.addMatrix4(buffer, modelTransform)
    })
    ResGL.Buffer.fromArray(context, buffer.data)->result_fromOption(["Couldn't make buffers"])
  }

  // Process all possibly-failing actions up-front
  result_combine3(
    Program.fromStringPair(context, vertexShaderSrc, fragmentShaderSrc),
    Scene.loadMesh(context, mesh)->result_fromOption(["Can't load mesh"]),
    bufferPositions(),
  )->Result.map(((program, loadedMesh, positions)) => {
    let (renderSetup, renderFrame) = rendererFromProgram(context, program)

    ResGL.Program.use(context, program)
    WebGL.enable(context, #DepthTest)
    WebGL.clearColor(context, 0., 0., 0., 1.)

    // Load mesh texture into texture0
    let texture = ResGL.Texture.fromImage(context, textureImage)

    // Camera transformations
    let projection =
      Camera.perspectiveCamera(45., 1.33, 0.1, 1000.)->Option.getWithDefault(Matrix4.identity)
    let view = Camera.lookAtTransform(Vec3.make(0., 25., -100.), Vec3.zero, Vec3.unitY)

    let ang = ref(0.)
    let ang2 = ref(0.)

    let rotY = Matrix4.empty()
    let rotZ = Matrix4.empty()
    let rotBoth = Matrix4.empty()
    let modelScale = Transform.scale(2., 2., 2.)

    let light = Vec3.make(0., 50., 0.)
    let lightTransform = Matrix4.empty()

    let vmLight = Vec3.empty()

    renderSetup({
      texture: texture,
      pTransform: projection,
      vTransform: view,
      mTransform: rotBoth,
      mPositions: positions,
      viewTransform: view,
      lightPos: vmLight,
      mesh: loadedMesh,
    })

    animate(_ => {
      // Animate
      ang := ang.contents +. 1.
      ang2 := ang2.contents +. 0.005

      // Light rotation
      Transform.rotateZInto(lightTransform, ang.contents /. 2.)->ignore
      Matrix4.mulVec3Into(vmLight, lightTransform, light)->ignore
      Matrix4.mulVec3Into(vmLight, view, vmLight)->ignore

      // Combined rotation
      Transform.rotateZInto(rotZ, Js.Math.sin(ang2.contents) *. 270.)->ignore
      Transform.rotateYInto(rotY, ang.contents)->ignore
      Matrix4.mul3Into(rotBoth, modelScale, rotZ, rotY)->ignore

      let renderData = {
        texture: texture,
        pTransform: projection,
        vTransform: view,
        mTransform: rotBoth,
        mPositions: positions,
        viewTransform: view,
        lightPos: vmLight,
        mesh: loadedMesh,
      }

      renderFrame(renderData)
    })
  })
}

// Load external files
Js.Promise.all2((
  Loader_Obj.load("obj/famling1-talk.vox.obj"),
  Loader_Texture.load("obj/famling1-talk.vox.png"),
))
|> result_fromPromise
// Start app when they are all loaded
|> Js.Promise.then_(result => {
  Result.flatMap(result, ((obj: Loader_Obj.t, textureImage)) => {

    Browser.getElementById("canvas")
    ->result_fromOption(["Can't find DO element #canvas"])
    ->Result.flatMap(ResGL.Context.fromCanvas)
    ->Result.flatMap(app(_, Mesh.fromObject(obj), textureImage))

  })->result_log
  Js.Promise.resolve()
})
|> ignore
