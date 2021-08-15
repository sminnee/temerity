
@ocaml.doc("Load a mesh's data into the GPU, providing a buffer reference")
let loadMesh = (context, mesh: Mesh.t): option<Renderer.meshData> => {
  let positions = ResGL.Buffer.fromArray(context, mesh.positions)
  let normals = ResGL.Buffer.fromArray(context, mesh.normals)
  let textureCoords = ResGL.Buffer.fromArray(context, mesh.textureCoords)

  switch (positions, normals, textureCoords) {
  | (Some(positions), Some(normals), Some(textureCoords)) =>
    Some({positions: positions, normals: normals, textureCoords: textureCoords, length: mesh.length})
  | _ => None
  }
}

type object = {
  mesh: Renderer.meshData,
  pos: Vec3.t,
  color: Vec3.t,
}

let makeObject = (mesh, ~pos, ~color) => {
  {
    mesh: mesh,
    pos: pos,
    color: color,
  }
}


let loadObjectTransform = (dest, {pos}) => {
  Transform.translateInto(dest, pos.x, pos.y, pos.z)
}
