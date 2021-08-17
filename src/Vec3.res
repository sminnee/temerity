type t = {mutable x: float, mutable y: float, mutable z: float}

let make = (x, y, z) => {x: x, y: y, z: z}

let makeUniform = val => {x: val, y: val, z: val}

let load = (dest, x, y, z) => {
  dest.x = x
  dest.y = y
  dest.z = z
  dest
}
let empty = () => {x: 0., y: 0., z: 0.}

let fromTuple = ((x, y, z)) => {x: x, y: y, z: z}

let zero = make(0., 0., 0.)
let unitX = make(1., 0., 0.)
let unitY = make(0., 1., 0.)
let unitZ = make(1., 0., 1.)

@ocaml.doc("Sum or 2 vectors")
let add = (a, b) => make(a.x +. b.x, a.y +. b.y, a.z +. b.z)

@ocaml.doc("Difference of 2 vectors")
let sub = (a, b) => make(a.x -. b.x, a.y -. b.y, a.z -. b.z)

@ocaml.doc("Dot product of 2 vectors")
let dot = (a, b) => a.x *. b.x +. a.y *. b.y +. a.z *. b.z

@ocaml.doc("Cross-product of 2 vectors")
let cross = (a, b) =>
  make(a.y *. b.z -. a.z *. b.y, a.z *. b.x -. a.x *. b.z, a.x *. b.y -. a.y *. b.x)

@ocaml.doc("Multiply a vector by a scalar")
let scale = ({x, y, z}, scale) => make(x *. scale, y *. scale, z *. scale)

let len = vec => dot(vec, vec)->Js.Math.sqrt

let normalize = vec => scale(vec, 1.0 /. len(vec))
