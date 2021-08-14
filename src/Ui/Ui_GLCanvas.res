//open Util

// @ocaml.doc("Canvas tag with a WebGL context") @react.component
// let make = () => {
//   let setCanvasRef = _ => {
//     ()
// switch canvas
// ->Js.Nullable.toOption
// ->Option.flatMap(canvas => {
//   Browser.getClientWidth(canvas)->Browser.setWidth(canvas, _)
//   Browser.getClientHeight(canvas)->Browser.setHeight(canvas, _)
//   WebGL.getContext(canvas, "webgl")
// }) {
// | None => Js.log("No WebGL context could be found.")
// | Some(context) =>
//   loadProgram(context)
//   ->Option.map(program => {
//     WebGL.useProgram(context, program)
//     WebGL.enable(context, #DepthTest)
//     //WebGL.clearColor(context, 0.9, 0.3, 0.3, 1.)

//     let projection =
//       Camera.perspectiveCamera(45., 1.33, 0.05, 10.)->Option.getWithDefault(Matrix4.identity)
//     let view = Camera.lookAtTransform(Vec3.make(-3., 1., -5.), Vec3.zero, Vec3.unitY)
//     let modelTransform = Transform.rotateY(50.)->Matrix4.mul(Transform.translate(0., 0., 5.))

//     let transform = projection->Matrix4.mul(view)->Matrix4.mul(modelTransform)

//     Array.map(content, mesh =>
//       Scene.loadMesh(context, mesh)->Option.map(x =>
//         refs(context, program, x)->render(context, transform, _)
//       )
//     )
//   })
//   ->ignore
// }
//   }

//   <canvas ref={ReactDOM.Ref.callbackDomRef(setCanvasRef)}>
//     {React.string("Canvas not supported")}
//   </canvas>
// }

