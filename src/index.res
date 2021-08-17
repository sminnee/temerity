open Belt
let numObjects = 25000
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
  // mTransform: array<float>,
  vTransform: array<float>,
  pTransform: array<float>,
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

  let withPos = aRef("a_modelPosition")

  (
    // Once
    ({texture, mesh, pTransform, mPositions}) => {
      withSampler(Uniform.bindTexture2D(context, _, #Texture0, texture))
      withVertex(Attribute.bindBuffer(context, _, 3, mesh.positions))
      withNormal(Attribute.bindBuffer(context, _, 3, mesh.normals))
      withTextureCoord(Attribute.bindBuffer(context, _, 2, mesh.textureCoords))
      withP(Uniform.bindMatrix4(context, _, pTransform))
      withColor(Attribute.bind3f(context, _, 1., 0., 1.))
      withPos(Attribute.bindMatrixBufferPerInstance(context, _, mPositions))
    },
    // Once per frame
    ({mesh, vTransform, lightPos}) => {
      withLight(Uniform.bind3f(context, _, lightPos.x, lightPos.y, lightPos.z))
      withV(Uniform.bindMatrix4(context, _, vTransform))

      WebGL.drawArraysInstanced(context, #Triangles, 0, mesh.length, numObjects)
    },
  )
}

type character = {
  transform: Scene.Transform.t,
  ref: array<float>,
  ySpeed: float,
  zSpeed: float,
  mutable zInput: float,
}

let app = (context, object, textureImage) => {
  open Renderer
  open ResGL

  let randRange = (min, max) => Js.Math.random() *. (max -. min) +. min

  // objects calculated into positionInput, loaded into the buffer
  let positionInput = Matrix4.Array.makeBuffer(numObjects)

  // Make objects as a set of transform objects
  let objects = Array.range(0, numObjects - 1)->Array.map(idx => {
    let pos = Vec3.make(randRange(-200., 200.), randRange(-10., 10.), randRange(-400., 400.))
    {
      transform: Scene.Transform.make(~scaleUniform=2., ~rotY=randRange(0., 360.), pos),
      ref: Matrix4.Array.ref(positionInput, idx),
      ySpeed: randRange(0.5, 5.),
      zSpeed: randRange(0.01, 0.03),
      zInput: 0.,
    }
  })

  let updatePositions = (bufferId, objects) => {
    Array.forEach(objects, object => {
      object.zInput = object.zInput +. object.zSpeed
      Scene.Transform.alterRotZ(object.transform, (. _) => Js.Math.sin(object.zInput) *. 270.)
      Scene.Transform.alterRotY(object.transform, (. rot) => rot +. object.ySpeed)
      Scene.Transform.load(object.ref, object.transform)
    })
    ResGL.Buffer.loadBuffer(context, bufferId, positionInput)
  }

  // Process all possibly-failing actions up-front
  result_combine3(
    Program.fromStringPair(context, vertexShaderSrc, fragmentShaderSrc),
    Mesh.fromObject(object)->Scene.loadMesh(context, _)->result_fromOption(["Can't load mesh"]),
    ResGL.Buffer.make(context, ~usage=#DynamicDraw, numObjects * 16)->result_fromOption([
      "Couldn't make buffers",
    ]),
  )->Result.map(((program, loadedMesh, positionBuffer)) => {
    let (renderSetup, renderFrame) = rendererFromProgram(context, program)

    ResGL.Program.use(context, program)
    WebGL.enable(context, #DepthTest)
    WebGL.clearColor(context, 0., 0., 0., 1.)

    // Load mesh texture into texture0
    let texture = ResGL.Texture.fromImage(context, textureImage)

    // Camera transformations
    let projection =
      Camera.perspectiveCamera(45., 1.33, 0.1, 1000.)->Option.getWithDefault(Matrix4.identity)

    let cameraBase = Vec3.make(0., 30., -950.)
    let cameraTransform = Scene.Transform.make(Vec3.zero, ~rotY=0., ~scaleUniform=1.)
    let cameraMatrix = Matrix4.empty()

    let ang = ref(0.)
    let ang2 = ref(0.)

    let light = Vec3.make(0., 50., 0.)
    let lightTransform = Matrix4.empty()

    let vmLight = Vec3.empty()

    renderSetup({
      texture: texture,
      pTransform: projection,
      vTransform: Matrix4.default,
      mPositions: positionBuffer,
      lightPos: vmLight,
      mesh: loadedMesh,
    })

    updatePositions(positionBuffer, objects)

    animate(_ => {
      // Animate camera
      ang := ang.contents +. 0.1
      ang2 := ang2.contents +. 0.005

      Scene.Transform.alterRotY(cameraTransform, (. _) => ang.contents)
      let scale = (Js.Math.sin(ang2.contents) +. 2.) /. 3.
      Scene.Transform.alterScaleX(cameraTransform, (. _) => scale)
      Scene.Transform.alterScaleY(cameraTransform, (. _) => scale)
      Scene.Transform.alterScaleZ(cameraTransform, (. _) => scale)

      Scene.Transform.load(cameraMatrix, cameraTransform)

      let cameraLoc = Matrix4.mulVec3(cameraMatrix, cameraBase)

      let view = Camera.lookAtTransform(cameraLoc, Vec3.zero, Vec3.unitY)

      // Light rotation
      Transform.rotateZInto(lightTransform, ang.contents /. 2.)->ignore
      Matrix4.mulVec3Into(vmLight, lightTransform, light)->ignore
      Matrix4.mulVec3Into(vmLight, view, vmLight)->ignore

      updatePositions(positionBuffer, objects)

      let renderData = {
        texture: texture,
        pTransform: projection,
        vTransform: view,
        mPositions: positionBuffer,
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
  Result.flatMap(result, ((obj, textureImage)) => {
    ResGL.Context.fromElementId("canvas")->Result.flatMap(app(_, obj, textureImage))
  })->result_log
  Js.Promise.resolve()
})
|> ignore
