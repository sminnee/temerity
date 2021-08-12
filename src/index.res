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

type cameraData = {vmTransform: array<float>,pvmTransform: array<float>}

// Build a renderer to suit the program
let myRenderer = Renderer.makeRenderer(
  ~uniforms=[
    ("u_Light_position", (context, ref, _, _) => WebGL.uniform3fv(context, ref, [-1., 5., 0.])),
    (
      "u_PVM_transform",
      (context, ref, _, {pvmTransform}) => WebGL.uniformMatrix4fv(context, ref, false, pvmTransform),
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
    (
      "a_Color",
      (context, ref, _, _) => WebGL.vertexAttrib3f(context, ref, 1., 0., 1.),
    ),
    (
      "a_Vertex_normal",
      (context, ref, {normals}, _) => Renderer.bufferToAttrib(context, normals, ref, 3),
    ),
  ],
  ~render=(context, {length}, _) => {
    WebGL.drawArrays(context, #Triangles, 0,length)
  },
)

let app = context => {
  open Renderer
  loadProgram(context, vertexShaderSrc, fragmentShaderSrc)->Option.map(program => {
    WebGL.useProgram(context, program)
    WebGL.enable(context, #DepthTest)

    // Set up the renderer and the objects
    let render = myRenderer(context, program)
    let objects = Array.map([mesh], mesh => Scene.loadMesh(context, mesh))->Util.array_removeNone

    // Camera transformations
    let projection =
      Camera.perspectiveCamera(45., 1.33, 0.05, 10.)->Option.getWithDefault(Matrix4.identity)
    let view = Camera.lookAtTransform(Vec3.make(-1., 0.5, -3.), Vec3.zero, Vec3.unitY)

    let ang = ref(0.)
    let ang2 = ref(0.)

    animate(_ => {
      // Model transformation
      let modelTransform = Matrix4.mul(
        Transform.rotateZ(Js.Math.sin(ang2.contents) *. 30.),
        Transform.rotateY(ang.contents),
      )
      let pvmTransform = projection->Matrix4.mul(view)->Matrix4.mul(modelTransform)
      let vmTransform = Matrix4.mul(view, modelTransform)

      ang := ang.contents +. 5.
      ang2 := ang2.contents +. 0.05

      // Render each object
      Array.forEach(objects, meshData =>
        render(
          meshData,
          {
            pvmTransform: pvmTransform,
            vmTransform: vmTransform,
          },
        )
      )
    })
  })
}

Browser.getElementById("canvas")->Option.flatMap(Renderer.makeContext)->Option.map(app)->ignore

// switch ReactDOM.querySelector("#root") {
// | Some(root) => ReactDOM.render(<Ui_GLCanvas content={[mesh.data]} />, root)
// | None => Js.log("Error: could not find react element")
// }
