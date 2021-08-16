open Belt

type t = {
  // Array of vertices, 3 elements per vertex, 3 vertices per triangle
  positions: array<float>,
  // Normals, 3 per vertex
  normals: array<float>,
  // Texture coordinaes, 2 per vertex
  textureCoords: array<float>,
  // Number of points
  length: int,
}

module FloatBuffer = {
  @ocaml.doc("A fixed-size buffer that can be accumulated")
  type t = {
    data: array<float>,
    next: ref<int>,
  }

  @new external makeArray: int => array<float> = "Float32Array"

  @ocaml.doc("Make a float buffer of the given number of items")
  let make = count => {
    data: makeArray(count),
    next: ref(0),
  }

  let add3 = (buffer, items) => {
    ignore(buffer.data[buffer.next.contents] = Js.Array.unsafe_get(items, 0))
    ignore(buffer.data[buffer.next.contents + 1] = Js.Array.unsafe_get(items, 1))
    ignore(buffer.data[buffer.next.contents + 2] = Js.Array.unsafe_get(items, 2))
    ignore(buffer.next := buffer.next.contents + 3)
  }

  let addVec3 = (buffer, vec: Vec3.t) => {
    ignore(buffer.data[buffer.next.contents] = vec.x)
    ignore(buffer.data[buffer.next.contents + 1] = vec.y)
    ignore(buffer.data[buffer.next.contents + 2] = vec.z)
    ignore(buffer.next := buffer.next.contents + 3)
  }

  let addVec2 = (buffer, vec: Vec2.t) => {
    ignore(buffer.data[buffer.next.contents] = vec.x)
    ignore(buffer.data[buffer.next.contents + 1] = vec.y)
    ignore(buffer.next := buffer.next.contents + 2)
  }

  let addMatrix4 = (buffer, matrix) => {
    Array.blit(~src=matrix, ~srcOffset=0, ~dst=buffer.data, ~dstOffset=buffer.next.contents, ~len=16)
    ignore(buffer.next := buffer.next.contents + 16)
  }

  let repeat = (buffer, count, value) => {
    for i in 0 to count - 1 {
      ignore(buffer.data[buffer.next.contents + i] = value)
    }
    ignore(buffer.next := buffer.next.contents + count)
  }
}

let fromObject = (obj: Loader_Obj.t) => {
  let numTriangles = Array.length(obj.faces)
  let positions = FloatBuffer.make(numTriangles * 9)
  let normals = FloatBuffer.make(numTriangles * 9)
  let textureCoords = FloatBuffer.make(numTriangles * 6)

  let toVec2 = Option.mapWithDefault(_, Vec2.zero, Vec2.fromTuple)
  let toVec3 = Option.mapWithDefault(_, Vec3.zero, Vec3.fromTuple)

  Array.forEachWithIndex(obj.faces, (idx, (a, b, c)) => {
    let vecA = obj.vertices[a]->toVec3
    let vecB = obj.vertices[b]->toVec3
    let vecC = obj.vertices[c]->toVec3

    FloatBuffer.addVec3(positions, vecA)
    FloatBuffer.addVec3(positions, vecB)
    FloatBuffer.addVec3(positions, vecC)

    switch obj.faceNormals[idx] {
    // Normals provided
    | Some((nA, nB, nC)) =>
      obj.normals[nA]->toVec3->FloatBuffer.addVec3(normals, _)
      obj.normals[nB]->toVec3->FloatBuffer.addVec3(normals, _)
      obj.normals[nC]->toVec3->FloatBuffer.addVec3(normals, _)

    // Generate default normal
    | None =>
      let normal = Vec3.cross(Vec3.sub(vecB, vecA), Vec3.sub(vecC, vecA))
      FloatBuffer.addVec3(normals, normal)
      FloatBuffer.addVec3(normals, normal)
      FloatBuffer.addVec3(normals, normal)
    }

    switch obj.faceTextures[idx] {
    // Textures provided
    | Some(tA, tB, tC) =>
      obj.textureCoords[tA]->toVec2->FloatBuffer.addVec2(textureCoords, _)
      obj.textureCoords[tB]->toVec2->FloatBuffer.addVec2(textureCoords, _)
      obj.textureCoords[tC]->toVec2->FloatBuffer.addVec2(textureCoords, _)

    // Empty texture refernces
    | None => FloatBuffer.repeat(textureCoords, 6, 0.)
    }
  })

  {
    positions: positions.data,
    normals: normals.data,
    textureCoords: textureCoords.data,
    length: numTriangles * 3,
  }
}
