open Belt

@ocaml.doc("Load a mesh's data into the GPU, providing a buffer reference")
let loadMesh = (context, mesh: Mesh.t): option<Renderer.meshData> => {
  let positions = WebGL.createBuffer(context)->Option.map(id => {
    WebGL.bindBuffer(context, #ArrayBuffer, id)
    WebGL.bufferData(context, #ArrayBuffer, mesh.positions, #StaticDraw)
    id
  })
  let normals = WebGL.createBuffer(context)->Option.map(id => {
    WebGL.bindBuffer(context, #ArrayBuffer, id)
    WebGL.bufferData(context, #ArrayBuffer, mesh.normals, #StaticDraw)
    id
  })
  switch (positions, normals) {
  | (Some(positions), Some(normals)) =>
    Some({positions: positions, normals: normals, length: mesh.length})
  | _ => None
  }
}
