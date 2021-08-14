open Belt
let numObjects = 10000

%%raw(`
import _fragmentShaderSrc from "./shaders/fragment.glsl"
import _vertexShaderSrc from "./shaders/vertex.glsl"
`)
let fragmentShaderSrc = %raw(`_fragmentShaderSrc`)
let vertexShaderSrc = %raw(`_vertexShaderSrc`)

//@module external styles: {..} = "./Ui/Global.css"

// let mesh = Mesh.make(
//   [(0.0, -0.25, -0.50), (0.0, 0.25, 0.00), (0.5, -0.25, 0.25), (-0.5, -0.25, 0.25)],
//   [(2, 1, 3), (3, 1, 0), (0, 1, 2), (0, 2, 3)],
// )

type renderData = {
  vmTransform: array<float>,
  pvmTransform: array<float>,
  viewTransform: array<float>,
  lightPos: Vec3.t,
}

// Build a renderer to suit the GLSL program
let myRenderer = Renderer.makeRenderer(
  ~uniforms=[
    (
      "u_Light_position",
      (context, ref, _, {lightPos}) => {
        WebGL.uniform3f(context, ref, lightPos.x, lightPos.y, lightPos.z)
      },
    ),
    (
      "u_PVM_transform",
      (context, ref, _, {pvmTransform}) =>
        WebGL.uniformMatrix4fv(context, ref, false, pvmTransform),
    ),
    (
      "u_VM_transform",
      (context, ref, _, {vmTransform}) => WebGL.uniformMatrix4fv(context, ref, false, vmTransform),
    ),
    (
      "u_Sampler",
      (context, ref, _, _) => {
        WebGL.uniform1i(context, ref, 0)
      },
    ),
  ],
  ~attributes=[
    (
      "a_Vertex",
      (context, ref, {positions}, _) => Renderer.bufferToAttrib(context, positions, ref, 3),
    ),
    ("a_Color", (context, ref, _, _) => WebGL.vertexAttrib3f(context, ref, 1., 0., 1.)),
    (
      "a_Vertex_normal",
      (context, ref, {normals}, _) => Renderer.bufferToAttrib(context, normals, ref, 3),
    ),
    (
      "a_Texture_coordinate",
      (context, ref, {textureCoords}, _) => Renderer.bufferToAttrib(context, textureCoords, ref, 2),
    ),
  ],
  ~render=(context, {length}, _) => {
    WebGL.drawArrays(context, #Triangles, 0, length)
  },
)

let hardCodedRenderer = (context, program) => {
  let lightRef = WebGL.getUniformLocation(context, program, "u_Light_position")
  let pvmRef = WebGL.getUniformLocation(context, program, "u_PVM_transform")
  let vmRef = WebGL.getUniformLocation(context, program, "u_VM_transform")
  let samplerRef = WebGL.getUniformLocation(context, program, "u_Sampler")

  let vertexRef = WebGL.getAttribLocation(context, program, "a_Vertex")
  let colorRef = WebGL.getAttribLocation(context, program, "a_Color")
  let normalRef = WebGL.getAttribLocation(context, program, "a_Vertex_normal")
  let textureCoordRef = WebGL.getAttribLocation(context, program, "a_Texture_coordinate")

  (
    // Once per frame
    ({textureCoords, normals, positions}: Renderer.meshData, {lightPos}) => {
      Renderer.bufferToAttrib(context, positions, vertexRef, 3)
      WebGL.vertexAttrib3f(context, colorRef, 1., 0., 1.)
      Renderer.bufferToAttrib(context, normals, normalRef, 3)
      Renderer.bufferToAttrib(context, textureCoords, textureCoordRef, 2)

      WebGL.uniform3f(context, lightRef, lightPos.x, lightPos.y, lightPos.z)
      WebGL.uniform1i(context, samplerRef, 0)
    },
    // Once per object
    ({length}: Renderer.meshData, {vmTransform, pvmTransform}) => {
      WebGL.uniformMatrix4fv(context, pvmRef, false, pvmTransform)
      WebGL.uniformMatrix4fv(context, vmRef, false, vmTransform)

      WebGL.drawArrays(context, #Triangles, 0, length)
    },
  )
}

let app = (context, mesh, textureImage) => {
  open Renderer
  loadProgram(context, vertexShaderSrc, fragmentShaderSrc)->Option.map(program => {
    WebGL.useProgram(context, program)
    WebGL.enable(context, #DepthTest)
    WebGL.clearColor(context, 0., 0., 0., 1.)

    // Set up the renderer and the objects
    let (renderFrame, renderObject) = hardCodedRenderer(context, program)
    let meshes = Array.map([mesh], mesh => Scene.loadMesh(context, mesh))->Util.array_removeNone

    // Load mesh texture into texture0
    let texture = Renderer.loadTexture(context, textureImage)
    WebGL.activeTexture(context, #Texture0)
    WebGL.bindTexture(context, #Texture2D, texture)

    let randRange = (min, max) => Js.Math.random() *. (max -. min) +. min

    let scene =
      meshes[0]->Option.mapWithDefault([], mesh =>
        Array.range(0, numObjects)->Array.map(_ =>
          Scene.makeObject(
            mesh,
            ~pos=Vec3.make(randRange(-100., 100.), 0., randRange(-200., 200.)),
            ~color=Vec3.make(1., 0., 0.),
          )
        )
      )

    // Camera transformations
    let projection =
      Camera.perspectiveCamera(45., 1.33, 0.1, 1000.)->Option.getWithDefault(Matrix4.identity)
    let view = Camera.lookAtTransform(Vec3.make(0., 25., -100.), Vec3.zero, Vec3.unitY)

    let ang = ref(0.)
    let ang2 = ref(0.)

    let rotY = Matrix4.empty()
    let rotZ = Matrix4.empty()
    let rotBoth = Matrix4.empty()
    let modelTransform = Matrix4.empty()
    let vmTransform = Matrix4.empty()
    let pvmTransform = Matrix4.empty()
    let modelScale = Transform.scale(2., 2., 2.)

    let light = Vec3.make(0., 50., 0.)
    let lightMarker = Vec3.make(0., 30., 0.)
    let lightTransform = Matrix4.empty()

    let vmLight = Vec3.empty()

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
        pvmTransform: pvmTransform,
        vmTransform: vmTransform,
        viewTransform: view,
        lightPos: vmLight,
      }

      renderFrame(Js.Array.unsafe_get(scene, 0).mesh, renderData)

      // Render each object
      Array.forEachWithIndex(scene, (idx, item) => {
        if idx == 0 {
          Matrix4.mulVec3Into(item.pos, lightTransform, lightMarker)->ignore
        }
        Scene.loadObjectTransform(modelTransform, item)->ignore

        Matrix4.mulInto(modelTransform, modelTransform, rotBoth)->ignore

        // // Transform to camera space
        Matrix4.mulInto(vmTransform, view, modelTransform)->ignore
        Matrix4.mulInto(pvmTransform, projection, vmTransform)->ignore

        renderObject(item.mesh, renderData)
      })
    })
  })
}

Js.Promise.all2((
  Loader_Obj.load("obj/famling1-talk.vox.obj"),
  Loader_Texture.load("obj/famling1-talk.vox.png"),
))
|> Js.Promise.then_(((obj: Loader_Obj.t, textureImage)) => {
  let mesh = Mesh.fromObject(obj)

  Browser.getElementById("canvas")
  ->Option.flatMap(Renderer.makeContext)
  ->Option.map(app(_, mesh, textureImage))
  ->ignore

  Js.Promise.resolve()
})
|> ignore
