open Belt

module FloatBuffer = {
  @ocaml.doc("A fixed-size buffer that can be accumulated")
  type t = {
    data: array<float>,
    length: int,
    next: ref<int>,
  }

  @new external makeArray: int => array<float> = "Float32Array"

  @ocaml.doc("Make a float buffer of the given number of items")
  let make = count => {
    data: makeArray(count),
    length: count,
    next: ref(0),
  }

  let add3 = (buffer, items) => {
    ignore(buffer.data[buffer.next.contents] = Js.Array.unsafe_get(items, 0))
    ignore(buffer.data[buffer.next.contents + 1] = Js.Array.unsafe_get(items, 1))
    ignore(buffer.data[buffer.next.contents + 2] = Js.Array.unsafe_get(items, 2))
    ignore(buffer.next := buffer.next.contents + 3)
  }
}

let make = (vertices, triangles) => {
  let buffer = FloatBuffer.make(Array.length(triangles) * 9)

  Array.forEach(triangles, tri => {
    switch tri {
    | [a, b, c] => {
        vertices[a]->Option.getWithDefault([0., 0., 0.])->FloatBuffer.add3(buffer, _)
        vertices[b]->Option.getWithDefault([0., 0., 0.])->FloatBuffer.add3(buffer, _)
        vertices[c]->Option.getWithDefault([0., 0., 0.])->FloatBuffer.add3(buffer, _)
      }
    | _ => failwith("Triangle needs exactly 3 vertex refs")
    }
  })

  buffer
}
