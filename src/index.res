open Belt
let numObjects = 67000// 23000

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

type renderOnceData = {
  texture: WebGL.texture,
  positions: WebGL.buffer,
}

type renderData = {
  mTransform: array<float>,
  vTransform: array<float>,
  pvTransform: array<float>,
  viewTransform: array<float>,

  mPositions: WebGL.buffer,
  lightPos: Vec3.t,
}

// // Build a renderer to suit the GLSL program
// let myRenderer = Renderer.makeRenderer(
//   ~uniforms=[
//     (
//       "u_Light_position",
//       (context, ref, _, {lightPos}) => {
//         ResGL.Uniform.bind3f(context, ref, lightPos.x, lightPos.y, lightPos.z)
//       },
//     ),
//     (
//       "u_PVM_transform",
//       (context, ref, _, {pvmTransform}) =>
//         ResGL.Uniform.bindMatrix4(context, ref, pvmTransform),
//     ),
//     (
//       "u_VM_transform",
//       (context, ref, _, {vmTransform}) => ResGL.Uniform.bindMatrix4(context, ref,  vmTransform),
//     ),
//     // (
//     //   "u_Sampler",
//     //   (context, ref, _, _) => {
//     //     WebGL.uniform1i(context, ref, 0)
//     //   },
//     // ),
//   ],
//   ~attributes=[
//     (
//       "a_Vertex",
//       (context, ref, {positions}, _) => ResGL.Attribute.bindBuffer(context, ref, 3, positions),
//     ),
//     ("a_Color", (context, ref, _, _) => ResGL.Attribute.bind3f(context, ref, 1., 0., 1.)),
//     (
//       "a_Vertex_normal",
//       (context, ref, {normals}, _) => ResGL.Attribute.bindBuffer(context, ref, 3, normals),
//     ),
//     (
//       "a_Texture_coordinate",
//       (context, ref, {textureCoords}, _) => ResGL.Attribute.bindBuffer(context, ref, 2, textureCoords),
//     )
//   ],
//   ~render=(context, {length}, _) => {
//     WebGL.drawArrays(context, #Triangles, 0, length)
//   },
// )

let hardCodedRenderer = (context, program) => {
  open ResGL

  let uRef = Uniform.ref(context, program)
  let aRef = Attribute.ref(context, program)

  let lightRef = uRef("u_Light_position")
  let pvRef = uRef("u_PV_transform")
  let vRef = uRef("u_V_transform")
  let mRef = uRef("u_M_transform")
  let samplerRef = uRef("u_Sampler")

  let posRef = aRef("u_Pos_transform")

  let vertexRef = aRef("a_Vertex")
  let colorRef = aRef("a_Color")
  let normalRef = aRef("a_Vertex_normal")
  let textureCoordRef = aRef("a_Texture_coordinate")

  (
    // Once
    ({texture}) => {
      Uniform.bindTexture2D(context, samplerRef, #Texture0, texture)
//      Uniform.bindBuffer(context, samplerRef, #Texture0, texture)
    },

    // Once per frame
    ({textureCoords, normals, positions, length}: Renderer.meshData, {lightPos, pvTransform, vTransform, mTransform, mPositions}) => {
      Attribute.bindBuffer(context,vertexRef, 3, positions)
      Attribute.bind3f(context, colorRef, 1., 0., 1.)
      Attribute.bindBuffer(context, normalRef, 3, normals)
      Attribute.bindBuffer(context, textureCoordRef, 2, textureCoords)

      Uniform.bindMatrix4(context, pvRef, pvTransform)
      Uniform.bindMatrix4(context, vRef, vTransform)
      Uniform.bindMatrix4(context, mRef, mTransform)

      Uniform.bind3f(context, lightRef, lightPos.x, lightPos.y, lightPos.z)

      Attribute.bindMatrixBufferPerInstance(context, posRef,  mPositions)

      WebGL.drawArraysInstanced(context, #Triangles, 0, length, numObjects)
    },
    // Once per object
    (_, _) => (),
  )
}

let app = (context, mesh, textureImage) => {
  open Renderer
  open ResGL
  Program.fromStringPair(context, vertexShaderSrc, fragmentShaderSrc)->Util.result_log(program => {
    Program.use(context, program)
    WebGL.enable(context, #DepthTest)
    WebGL.clearColor(context, 0., 0., 0., 1.)

    let meshes = Array.map([mesh], mesh => Scene.loadMesh(context, mesh))->Util.array_removeNone

    // Load mesh texture into texture0
    let texture = ResGL.Texture.fromImage(context, textureImage)

    // Set up the renderer and the objects
    let (renderOnce, renderFrame, renderObject) = hardCodedRenderer(context, program)

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
    //let vmTransform = Matrix4.empty()
    let pvTransform = Matrix4.empty()
    let modelScale = Transform.scale(2., 2., 2.)

    let light = Vec3.make(0., 50., 0.)
    let lightMarker = Vec3.make(0., 30., 0.)
    let lightTransform = Matrix4.empty()

    let vmLight = Vec3.empty()


    // Turn each
    let buffer = Mesh.FloatBuffer.make(numObjects * 16)
    Array.forEach(scene, item => {
      Scene.loadObjectTransform(modelTransform, item)->ignore
      Mesh.FloatBuffer.addMatrix4(buffer, modelTransform)
    })

    Js.log2("position data", buffer.data)

    ResGL.Buffer.fromArray(context, buffer.data)->Option.map(positions => {
      renderOnce({texture, positions})

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

        Matrix4.mulInto(pvTransform, projection, view)->ignore

        let renderData = {
          pvTransform: pvTransform,
          vTransform: view,
          mTransform: rotBoth,
          mPositions: positions,
          viewTransform: view,
          lightPos: vmLight,
        }

        renderFrame(Js.Array.unsafe_get(scene, 0).mesh, renderData)

        scene[0]->Option.map(item => {
          renderObject(item.mesh, renderData)
        })->ignore


        // // Render each object
        // Array.forEachWithIndex(scene, (idx, item) => {
        //   if idx == 0 {
        //     Matrix4.mulVec3Into(item.pos, lightTransform, lightMarker)->ignore
        //   }
        //   Scene.loadObjectTransform(modelTransform, item)->ignore

        //   Matrix4.mulInto(modelTransform, modelTransform, rotBoth)->ignore

        //   // // Transform to camera space
        //   Matrix4.mulInto(vmTransform, view, modelTransform)->ignore
        //   Matrix4.mulInto(pvmTransform, projection, vmTransform)->ignore

        //   renderObject(item.mesh, renderData)
        // })
      })
    })->ignore
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
