open Belt

%%raw(`
import _fragmentShaderSrc from "./shaders/fragment.glsl"
import _vertexShaderSrc from "./shaders/vertex.glsl"
`)
let fragmentShaderSrc = %raw(`_fragmentShaderSrc`)
let vertexShaderSrc = %raw(`_vertexShaderSrc`)


//@module external styles: {..} = "./Ui/Global.css"

let mesh = Mesh.make(
  [[0.0, -0.25, -0.50], [0.0, 0.25, 0.00], [0.5, -0.25, 0.25], [-0.5, -0.25, 0.25]],
  [[2, 1, 3], [3, 1, 0], [0, 1, 2], [0, 2, 3]],
)

// Build a renderer to suit the program
let myRenderer = Renderer.makeRenderer(
  ~uniforms = [
    ("u_Color", (context, ref, _) => WebGL.uniform4fv(context, ref, [1., 0., 0., 1.])),
    ("u_Transform", (context, ref, {transform}) => WebGL.uniformMatrix4fv(context, ref, false, transform) ),
  ],
  ~attributes = [
    ("a_Vertex", (context, ref, {mesh}) => Renderer.bufferToAttrib(context, mesh, ref, 3) )
  ],
  ~render = (context, {meshLength}: Renderer.renderInput) => {
    WebGL.drawArrays(context, #Triangles, 0, meshLength/3)
  }
)

let app = context => {
  open Renderer
  loadProgram(context, vertexShaderSrc, fragmentShaderSrc)
  ->Option.map(program => {
      WebGL.useProgram(context, program)
      WebGL.enable(context, #DepthTest)

      // Set up the renderer and the objects
      let render = myRenderer(context, program)
      let objects = Array.map([mesh], mesh => Scene.loadMesh(context, mesh))->Util.array_removeNone

      // Camera transformations
      let projection =
        Camera.perspectiveCamera(45., 1.33, 0.05, 10.)->Option.getWithDefault(Matrix4.identity)
      let view = Camera.lookAtTransform(Vec3.make(-3., 1., -5.), Vec3.zero, Vec3.unitY)

      // Model transformation
      let modelTransform = Transform.rotateY(50.)//->Matrix4.mul(Transform.translate(0., 0., 5.))

      let transform = projection->Matrix4.mul(view)->Matrix4.mul(modelTransform)

      // Render each object
      Array.map(
        objects,
        ((object, length)) => render({
          mesh: object,
          meshLength: length,
          transform: transform
        })
      )
  })
}

Browser.getElementById("canvas")->Option.flatMap(Renderer.makeContext)->Option.map(app)->ignore


// switch ReactDOM.querySelector("#root") {
// | Some(root) => ReactDOM.render(<Ui_GLCanvas content={[mesh.data]} />, root)
// | None => Js.log("Error: could not find react element")
// }
