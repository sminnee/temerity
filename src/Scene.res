open Belt

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
  @ocaml.doc("A developer-friendly, mutable set of transformations")
  type t = array<float>

  let _tmp = Matrix4.empty()

  let make = (~scale=?, ~scaleUniform=?, ~rotX=?, ~rotY=?, ~rotZ=?, pos: Vec3.t) => {
    let new = Mesh.FloatBuffer.makeArray(9)

    let set = Js.Array.unsafe_set

    set(new, 0, pos.x)
    set(new, 1, pos.y)
    set(new, 2, pos.z)

    switch (scaleUniform, scale) {
    | (Some(scale), _) => {
        set(new, 3, scale)
        set(new, 4, scale)
        set(new, 5, scale)
      }
    | (None, Some({x, y, z}: Vec3.t)) => {
        set(new, 3, x)
        set(new, 4, y)
        set(new, 5, z)
      }
    | (None, None) => {
        set(new, 3, 1.)
        set(new, 4, 1.)
        set(new, 5, 1.)
      }
    }

    set(new, 6, rotX->Option.getWithDefault(0.))
    set(new, 7, rotY->Option.getWithDefault(0.))
    set(new, 8, rotZ->Option.getWithDefault(0.))

    new
  }

  let _tmp1 = Matrix4.makeIdentity()
  let _tmp2 = Matrix4.makeIdentity()
  let _tmp3 = Matrix4.makeIdentity()
  let _tmp4 = Matrix4.makeIdentity()
  let _tmp5 = Matrix4.makeIdentity()

  let load = (matrix, t: t) => {
    let get = Js.Array.unsafe_get

    Matrix4.mul5Into(
      matrix,
      Transform.scaleInto(_tmp1, get(t, 3), get(t, 4), get(t, 5)),
      Transform.translateInto(_tmp2, get(t, 0), get(t, 1), get(t, 2)),
      Transform.rotateZInto(_tmp3, get(t, 8)),
      Transform.rotateXInto(_tmp4, get(t, 6)),
      Transform.rotateYInto(_tmp5, get(t, 7)),
    )
  }

  @inline
  let alter = (idx, t: t, fn: (. float) => float) => {
    let get = Js.Array.unsafe_get
    let set = Js.Array.unsafe_set

    set(t, idx, fn(. get(t, idx)))
  }

  let alterPosX = alter(0)
  let alterPosY = alter(1)
  let alterPosZ = alter(2)

  let alterScaleX = alter(3)
  let alterScaleY = alter(4)
  let alterScaleZ = alter(5)

  let alterRotX = alter(6)
  let alterRotY = alter(7)
  let alterRotZ = alter(8)
}
