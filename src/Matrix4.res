type t = array<float>

@new external makeFloatArray: int => array<float> = "Float32Array"
@new external bufferFromArray: array<float> => array<float> = "Float32Array"

let set = Js.Array.unsafe_set
let get = Js.Array.unsafe_get

let empty = () => makeFloatArray(16)

@ocaml.doc("Load all values into an existing matrix")
let load = (
  dst,
  e00,
  e01,
  e02,
  e03,
  e10,
  e11,
  e12,
  e13,
  e20,
  e21,
  e22,
  e23,
  e30,
  e31,
  e32,
  e33,
) => {
  set(dst, 0, e00)
  set(dst, 1, e01)
  set(dst, 2, e02)
  set(dst, 3, e03)
  set(dst, 4, e10)
  set(dst, 5, e11)
  set(dst, 6, e12)
  set(dst, 7, e13)
  set(dst, 8, e20)
  set(dst, 9, e21)
  set(dst, 10, e22)
  set(dst, 11, e23)
  set(dst, 12, e30)
  set(dst, 13, e31)
  set(dst, 14, e32)
  set(dst, 15, e33)
  dst
}

@ocaml.doc("Make a new matrix")
let make = (e00, e01, e02, e03, e10, e11, e12, e13, e20, e21, e22, e23, e30, e31, e32, e33) => {
  let dst = makeFloatArray(16)
  load(dst, e00, e01, e02, e03, e10, e11, e12, e13, e20, e21, e22, e23, e30, e31, e32, e33)
}

@ocaml.doc("Make a new matrix")
let fromArray = values =>
  switch Array.length(values) {
  | 16 => bufferFromArray(values)
  | _ => failwith("Matrix4.fromArray must be passed a 16-element array")
  }

let identity = bufferFromArray([1., 0., 0., 0., 0., 1., 0., 0., 0., 0., 1., 0., 0., 0., 0., 1.])

let el00 = (a: t) => get(a, 0)
let el02 = (a: t) => get(a, 2)
let el01 = (a: t) => get(a, 1)
let el03 = (a: t) => get(a, 3)
let el10 = (a: t) => get(a, 4)
let el11 = (a: t) => get(a, 5)
let el12 = (a: t) => get(a, 6)
let el13 = (a: t) => get(a, 7)
let el20 = (a: t) => get(a, 8)
let el21 = (a: t) => get(a, 9)
let el22 = (a: t) => get(a, 10)
let el23 = (a: t) => get(a, 11)
let el30 = (a: t) => get(a, 12)
let el31 = (a: t) => get(a, 13)
let el32 = (a: t) => get(a, 14)
let el33 = (a: t) => get(a, 15)

// let arrSwap = (arr, a, b) => {
//   let tmp = Js.Array.unsafe_get(arr, a)
//   Js.Array.unsafe_get(arr, b)->Js.Array.unsafe_set(arr, a, _)
//   Js.Array.unsafe_set(arr, a, tmp)
// }

@ocaml.doc("Multiply 2 matrices")
let mulInto = (dst, a, b) => {
  set(dst, 0, el00(a) *. el00(b) +. el10(a) *. el01(b) +. el20(a) *. el02(b) +. el30(a) *. el03(b))
  set(dst, 1, el01(a) *. el00(b) +. el11(a) *. el01(b) +. el21(a) *. el02(b) +. el31(a) *. el03(b))
  set(dst, 2, el02(a) *. el00(b) +. el12(a) *. el01(b) +. el22(a) *. el02(b) +. el32(a) *. el03(b))
  set(dst, 3, el03(a) *. el00(b) +. el13(a) *. el01(b) +. el23(a) *. el02(b) +. el33(a) *. el03(b))
  set(dst, 4, el00(a) *. el10(b) +. el10(a) *. el11(b) +. el20(a) *. el12(b) +. el30(a) *. el13(b))
  set(dst, 5, el01(a) *. el10(b) +. el11(a) *. el11(b) +. el21(a) *. el12(b) +. el31(a) *. el13(b))
  set(dst, 6, el02(a) *. el10(b) +. el12(a) *. el11(b) +. el22(a) *. el12(b) +. el32(a) *. el13(b))
  set(dst, 7, el03(a) *. el10(b) +. el13(a) *. el11(b) +. el23(a) *. el12(b) +. el33(a) *. el13(b))
  set(dst, 8, el00(a) *. el20(b) +. el10(a) *. el21(b) +. el20(a) *. el22(b) +. el30(a) *. el23(b))
  set(dst, 9, el01(a) *. el20(b) +. el11(a) *. el21(b) +. el21(a) *. el22(b) +. el31(a) *. el23(b))
  set(dst, 10, el02(a) *. el20(b) +. el12(a) *. el21(b) +. el22(a) *. el22(b) +. el32(a) *. el23(b))
  set(dst, 11, el03(a) *. el20(b) +. el13(a) *. el21(b) +. el23(a) *. el22(b) +. el33(a) *. el23(b))
  set(dst, 12, el00(a) *. el30(b) +. el10(a) *. el31(b) +. el20(a) *. el32(b) +. el30(a) *. el33(b))
  set(dst, 13, el01(a) *. el30(b) +. el11(a) *. el31(b) +. el21(a) *. el32(b) +. el31(a) *. el33(b))
  set(dst, 14, el02(a) *. el30(b) +. el12(a) *. el31(b) +. el22(a) *. el32(b) +. el32(a) *. el33(b))
  set(dst, 15, el03(a) *. el30(b) +. el13(a) *. el31(b) +. el23(a) *. el32(b) +. el33(a) *. el33(b))
  dst
}

let mul = (a, b) => {
  mulInto(empty(), a, b)
}

@ocaml.doc("Transpose a matrix")
let transpose = a => {
  bufferFromArray([
    el00(a),
    el10(a),
    el20(a),
    el30(a),
    el01(a),
    el11(a),
    el21(a),
    el31(a),
    el02(a),
    el12(a),
    el22(a),
    el32(a),
    el03(a),
    el13(a),
    el23(a),
    el33(a),
  ])
}

let toRadians = angleInDegrees => angleInDegrees *. 0.017453292519943295

let toDegrees = angleInRadians => angleInRadians *. 57.29577951308232 // 180 / Math.PI
