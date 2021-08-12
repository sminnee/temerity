open Belt

@ocaml.doc("Load a mesh's data into the GPU, providing a buffer reference")
let loadMesh = (context, mesh: Mesh.FloatBuffer.t) => {
  WebGL.createBuffer(context)->Option.map(id => {
    WebGL.bindBuffer(context, #ArrayBuffer, id)
    WebGL.bufferData(context, #ArrayBuffer, mesh.data, #StaticDraw)
    (id, mesh.length)
  })
}
