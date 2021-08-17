open Belt
open Util

@ocaml.doc("Load a mesh's data into the GPU, providing a buffer reference")
let loadMesh = (context, mesh: Mesh.t): option<Renderer.meshData> => {
  let positions = ResGL.Buffer.fromArray(context, mesh.positions)
  let normals = ResGL.Buffer.fromArray(context, mesh.normals)
  let textureCoords = ResGL.Buffer.fromArray(context, mesh.textureCoords)

  switch (positions, normals, textureCoords) {
  | (Some(positions), Some(normals), Some(textureCoords)) =>
    Some({
      positions: positions,
      normals: normals,
      textureCoords: textureCoords,
      length: mesh.length,
    })
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

module Transform = {
  let _tmp = Matrix4.empty()

  @ocaml.doc("A developer-friendly, mutable set of transformations")
  type t = {
    mutable pos: Vec3.t,
    mutable scale: option<Vec3.t>,
    mutable rotX: option<float>,
    mutable rotY: option<float>,
    mutable rotZ: option<float>,
  }

  let make = (~scale=?, ~scaleUniform=?, ~rotX=?, ~rotY=?, ~rotZ=?, pos) => {
    {
      pos: pos,
      scale: Option.mapWithDefault(scaleUniform,  scale, x=>Some(Vec3.makeUniform(x))),
      rotX: rotX,
      rotY: rotY,
      rotZ: rotZ,
    }
  }

  let load = (matrix, {pos, scale, rotX, rotY, rotZ}) => {
    Transform.translateInto(matrix, pos.x, pos.y, pos.z)->ignore

    option_if(scale, scale => {
      Transform.scaleInto(_tmp, scale.x, scale.y, scale.z)->ignore
      Matrix4.mulInto(matrix, matrix, _tmp)->ignore
    })

    // Rot order = ZXY

    option_if(rotZ, rotZ => {
      Transform.rotateZInto(_tmp, rotZ)->ignore
      Matrix4.mulInto(matrix, matrix, _tmp)->ignore
    })

    option_if(rotX, rotX => {
      Transform.rotateXInto(_tmp, rotX)->ignore
      Matrix4.mulInto(matrix, matrix, _tmp)->ignore
    })

    option_if(rotY, rotY => {
      Transform.rotateYInto(_tmp, rotY)->ignore
      Matrix4.mulInto(matrix, matrix, _tmp)->ignore
    })
  }
}
