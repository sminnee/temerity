open Belt

type t = {
  // Array of vertices, 3 elements per vertex, 3 vertices per triangle
  positions: array<float>,
  // Normals, per vertex
  normals: array<float>,
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
}

let make = (vertices, triangles) => {
  let numTriangles = Array.length(triangles)
  let positions = FloatBuffer.make(numTriangles * 9)
  let normals = FloatBuffer.make(numTriangles * 9)

  let toVec3 = Option.mapWithDefault(_, Vec3.zero, Vec3.fromTuple)

  Array.forEach(triangles, ((a, b, c)) => {
    let vecA = vertices[a]->toVec3
    let vecB = vertices[b]->toVec3
    let vecC = vertices[c]->toVec3

    let normal = Vec3.cross(Vec3.sub(vecB, vecA), Vec3.sub(vecC, vecA))

    FloatBuffer.addVec3(positions, vecA)
    FloatBuffer.addVec3(positions, vecB)
    FloatBuffer.addVec3(positions, vecC)

    FloatBuffer.addVec3(normals, normal)
    FloatBuffer.addVec3(normals, normal)
    FloatBuffer.addVec3(normals, normal)
  })

  {
    positions: positions.data,
    normals: normals.data,
    length: numTriangles * 3,
  }
}
