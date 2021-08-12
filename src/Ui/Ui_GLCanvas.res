open Belt
//open Util

%%raw(`
import _fragmentShaderSrc from "../shaders/fragment.glsl"
import _vertexShaderSrc from "../shaders/vertex.glsl"
`)

let fragmentShaderSrc = %raw(`_fragmentShaderSrc`)
let vertexShaderSrc = %raw(`_vertexShaderSrc`)

@get external getClientWidth: Dom.element => int = "clientWidth"
@get external getClientHeight: Dom.element => int = "clientHeight"
@get external getWidth: Dom.element => int = "width"
@get external getHeight: Dom.element => int = "height"
@set external setWidth: (Dom.element, int) => unit = "width"
@set external setHeight: (Dom.element, int) => unit = "height"

type refs = {
  color: WebGL.uniformRef,
  transform: WebGL.uniformRef,
  vertex: WebGL.attribRef,
  mesh: WebGL.buffer,
}
let refs = (context, program, mesh) => {
  color: WebGL.getUniformLocation(context, program, "u_Color"),
  transform: WebGL.getUniformLocation(context, program, "u_Transform"),
  vertex: WebGL.getAttribLocation(context, program, "a_Vertex"),
  mesh: mesh,
}

let loadProgram = context => {
  let vertex = WebGL.createShader(context, #VertexShader)->Option.map(shader => {
    Js.log2("vertex", vertexShaderSrc)
    WebGL.shaderSource(context, shader, vertexShaderSrc)
    WebGL.compileShader(context, shader)
    shader
  })
  let fragment = WebGL.createShader(context, #FragmentShader)->Option.map(shader => {
    Js.log2("fragment", fragmentShaderSrc)
    WebGL.shaderSource(context, shader, fragmentShaderSrc)
    WebGL.compileShader(context, shader)
    shader
  })
  switch (vertex, fragment) {
  | (Some(vertex), Some(fragment)) =>
    WebGL.createProgram(context)->Option.flatMap(program => {
      WebGL.attachShader(context, program, vertex)
      WebGL.attachShader(context, program, fragment)
      WebGL.linkProgram(context, program)
      if WebGL.getProgramParameterBool(context, program, #LinkStatus) {
        Some(program)
      } else {
        None
      }
    })
  | _ => None
  }
}

let render = (context, transform, refs) => {
  Js.log2("refs", refs)
  // Set the transform for all the triangle vertices
  WebGL.uniformMatrix4fv(context, refs.transform, false, transform)

  // Set the color for all of the triangle faces
  let model_color = [1., 0., 0., 1.]
  WebGL.uniform4fv(context, refs.color, model_color)

  // Activate the model's vertex Buffer Object
  WebGL.bindBuffer(context, #ArrayBuffer, refs.mesh)
  Js.log2("Buffer size", WebGL.getBufferParameterSize(context, #ArrayBuffer))

  // Bind the vertices Buffer Object to the 'a_Vertex' shader variable
  WebGL.vertexAttribPointer(context, refs.vertex, 3, #Float, false, 0, 0)
  WebGL.enableVertexAttribArray(context, refs.vertex)

  // Draw all of the triangles
  let number_triangles = 4
  WebGL.drawArrays(context, #Triangles, 0, number_triangles * 3)

  // // 2. Render the edges around each triangle:

  // // Set the color for all of the edges
  // WebGL.uniform4fv(context, colorRef, edge_color);

  // // Draw a line_loop around each of the triangles
  // for (j = 0, start = 0; j < number_triangles; j += 1, start += 3) {
  //   gl.drawArrays(gl.LINE_LOOP, start, 3);
  // }
}

@ocaml.doc("Canvas tag with a WebGL context") @react.component
let make = (~content) => {
  let setCanvasRef = canvas => {
    switch canvas->Js.Nullable.toOption->Option.flatMap(canvas => {
      getClientWidth(canvas)->setWidth(canvas, _)
      getClientHeight(canvas)->setHeight(canvas, _)
      WebGL.getContext(canvas, "webgl")
    }) {
    | None => Js.log("No WebGL context could be found.")
    | Some(context) =>
      loadProgram(context)
      ->Option.map(program => {
        WebGL.useProgram(context, program)
        WebGL.enable(context, #DepthTest)
        //WebGL.clearColor(context, 0.9, 0.3, 0.3, 1.)

        let projection = Camera.perspectiveCamera(45., 1.33, 0.05, 10.)->Option.getWithDefault(Matrix4.identity)
        let view = Camera.lookAtTransform(Vec3.make(-3., 1., -5.), Vec3.zero, Vec3.unitY)
        let modelTransform = Transform.rotateY(50.)

        let transform =
          projection->Matrix4.mul(view)->Matrix4.mul(modelTransform)


        //Js.log2("viewport", WebGL.viewport(context,0,0, 400, 500))

        Array.map(content, mesh =>
          Scene.loadMesh(context, mesh)->Option.map(x =>
            refs(context, program, x)->render(context, transform, _)
          )
        )
      })
      ->ignore
    }
  }

  <canvas ref={ReactDOM.Ref.callbackDomRef(setCanvasRef)}>
    {React.string("Canvas not supported")}
  </canvas>
}
