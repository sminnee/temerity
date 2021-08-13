open Belt

%%raw(`
import _fragmentShaderSrc from "./shaders/fragment.glsl"
import _vertexShaderSrc from "./shaders/vertex.glsl"
`)
let fragmentShaderSrc = %raw(`_fragmentShaderSrc`)
let vertexShaderSrc = %raw(`_vertexShaderSrc`)

//@module external styles: {..} = "./Ui/Global.css"

let mesh = Mesh.make(
  [(0.0, -0.25, -0.50), (0.0, 0.25, 0.00), (0.5, -0.25, 0.25), (-0.5, -0.25, 0.25)],
  [(2, 1, 3), (3, 1, 0), (0, 1, 2), (0, 2, 3)],
)

type renderData = {
  vmTransform: array<float>,
  pvmTransform: array<float>,
  viewTransform: array<float>,
  lightPos: Vec3.t
}

// Build a renderer to suit the GLSL program
let myRenderer = Renderer.makeRenderer(
  ~uniforms=[
    ("u_Light_position", (context, ref, _, {lightPos}) => {
      WebGL.uniform3f(context, ref, lightPos.x, lightPos.y, lightPos.z)
    }),
    (
      "u_PVM_transform",
      (context, ref, _, {pvmTransform}) =>
        WebGL.uniformMatrix4fv(context, ref, false, pvmTransform),
    ),
    // to do: custom properties to the Renderer
    (
      "u_VM_transform",
      (context, ref, _, {vmTransform}) => WebGL.uniformMatrix4fv(context, ref, false, vmTransform),
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
  ],
  ~render=(context, {length}, _) => {
    WebGL.drawArrays(context, #Triangles, 0, length)
  },
)

let app = context => {
  open Renderer
  loadProgram(context, vertexShaderSrc, fragmentShaderSrc)->Option.map(program => {
    WebGL.useProgram(context, program)
    WebGL.enable(context, #DepthTest)

    // Set up the renderer and the objects
    let render = myRenderer(context, program)
    let meshes = Array.map([mesh], mesh => Scene.loadMesh(context, mesh))->Util.array_removeNone

    let randRange = (min, max) => Js.Math.random() *. (max -. min) +. min

    let scene =
      meshes[0]->Option.mapWithDefault([], mesh =>
        Array.range(0, 10000)->Array.map(_ =>
          Scene.makeObject(
            mesh,
            ~pos=Vec3.make(randRange(-40.,40.), -10., randRange(10.,200.)),
            ~color=Vec3.make(1., 0., 0.),
          )
        )
      )

    // Camera transformations
    let projection =
      Camera.perspectiveCamera(45., 1.33, 0.1, 200.)->Option.getWithDefault(Matrix4.identity)
    let view = Camera.lookAtTransform(Vec3.make(0., 2., -7.), Vec3.zero, Vec3.unitY)

    let ang = ref(0.)
    let ang2 = ref(0.)

    let rotY = Matrix4.empty()
    let rotZ = Matrix4.empty()
    let rotBoth = Matrix4.empty()
    let modelTransform = Matrix4.empty()
    let vmTransform = Matrix4.empty()
    let pvmTransform = Matrix4.empty()

    let light = Vec3.make(0., 10., -20.)
    let vmLight = Matrix4.mulVec3(view, light)
    Js.log2("vmLight", vmLight)

    animate(_ => {
      // Animate
      ang := ang.contents +. 5.
      ang2 := ang2.contents +. 0.05

      // Combined rotation
      Transform.rotateZInto(rotZ, Js.Math.sin(ang2.contents) *. 30.)->ignore
      Transform.rotateYInto(rotY, ang.contents)->ignore
      Matrix4.mulInto(rotBoth, rotZ, rotY)->ignore

      // Render each object
      Array.forEach(scene, item => {
        Scene.loadObjectTransform(modelTransform, item)->ignore
        Matrix4.mulInto(modelTransform, modelTransform, rotBoth)->ignore

        // Transform to camera space
        Matrix4.mulInto(vmTransform, view, modelTransform)->ignore
        Matrix4.mulInto(pvmTransform, projection, vmTransform)->ignore

        render(
          item.mesh,
          {
            pvmTransform: pvmTransform,
            vmTransform: vmTransform,
            viewTransform: view,
            lightPos: vmLight
          },
        )
      })
    })
  })
}

Browser.getElementById("canvas")->Option.flatMap(Renderer.makeContext)->Option.map(app)->ignore
