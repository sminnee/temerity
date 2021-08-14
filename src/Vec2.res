type t = {mutable x: float, mutable y: float}

let make = (x, y) => {x: x, y: y}
let load = (dest, x, y) => {
  dest.x = x
  dest.y = y
  dest
}
let empty = () => {x: 0., y: 0.}

let fromTuple = ((x, y)) => {x: x, y: y}

let zero = make(0., 0.)
let unitX = make(1., 0.)
let unitY = make(0., 1.)

@ocaml.doc("Sum or 2 vectors")
let add = (a, b) => make(a.x +. b.x, a.y +. b.y)

@ocaml.doc("Difference of 2 vectors")
let sub = (a, b) => make(a.x -. b.x, a.y -. b.y)

@ocaml.doc("Dot product of 2 vectors")
let dot = (a, b) => a.x *. b.x +. a.y *. b.y

@ocaml.doc("Multiply a vector by a scalar")
let scale = ({x, y}, scale) => make(x *. scale, y *. scale)

let len = vec => dot(vec, vec)->Js.Math.sqrt

let normalize = vec => scale(vec, 1.0 /. len(vec))
