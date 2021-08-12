type t = array<float>

@new external makeFloatArray: int => array<float> = "Float32Array"
@new external bufferFromArray: array<float> => array<float> = "Float32Array"

//let make = (el00, el01, el02, el03, el10, el11, el12, el13, el20, el21, el22, el23) => bufferFromArray

@ocaml.doc("Make a new matrix")
let fromArray = values =>
  switch Array.length(values) {
  | 16 => bufferFromArray(values)
  | _ => failwith("Matrix4.fromArray must be passed a 16-element array")
  }

let identity = bufferFromArray([1., 0., 0., 0., 0., 1., 0., 0., 0., 0., 1., 0., 0., 0., 0., 1.])

let el00 = (a: t) => Js.Array.unsafe_get(a, 0)
let el01 = (a: t) => Js.Array.unsafe_get(a, 1)
let el02 = (a: t) => Js.Array.unsafe_get(a, 2)
let el03 = (a: t) => Js.Array.unsafe_get(a, 3)
let el10 = (a: t) => Js.Array.unsafe_get(a, 4)
let el11 = (a: t) => Js.Array.unsafe_get(a, 5)
let el12 = (a: t) => Js.Array.unsafe_get(a, 6)
let el13 = (a: t) => Js.Array.unsafe_get(a, 7)
let el20 = (a: t) => Js.Array.unsafe_get(a, 8)
let el21 = (a: t) => Js.Array.unsafe_get(a, 9)
let el22 = (a: t) => Js.Array.unsafe_get(a, 10)
let el23 = (a: t) => Js.Array.unsafe_get(a, 11)
let el30 = (a: t) => Js.Array.unsafe_get(a, 12)
let el31 = (a: t) => Js.Array.unsafe_get(a, 13)
let el32 = (a: t) => Js.Array.unsafe_get(a, 14)
let el33 = (a: t) => Js.Array.unsafe_get(a, 15)

// let arrSwap = (arr, a, b) => {
//   let tmp = Js.Array.unsafe_get(arr, a)
//   Js.Array.unsafe_get(arr, b)->Js.Array.unsafe_set(arr, a, _)
//   Js.Array.unsafe_set(arr, a, tmp)
// }

@ocaml.doc("Multiply 2 matrices")
let mul = (a, b) => {
  bufferFromArray([
    el00(a) *. el00(b) +. el10(a) *. el01(b) +. el20(a) *. el02(b) +. el30(a) *. el03(b),
    el01(a) *. el00(b) +. el11(a) *. el01(b) +. el21(a) *. el02(b) +. el31(a) *. el03(b),
    el02(a) *. el00(b) +. el12(a) *. el01(b) +. el22(a) *. el02(b) +. el32(a) *. el03(b),
    el03(a) *. el00(b) +. el13(a) *. el01(b) +. el23(a) *. el02(b) +. el33(a) *. el03(b),
    el00(a) *. el10(b) +. el10(a) *. el11(b) +. el20(a) *. el12(b) +. el30(a) *. el13(b),
    el01(a) *. el10(b) +. el11(a) *. el11(b) +. el21(a) *. el12(b) +. el31(a) *. el13(b),
    el02(a) *. el10(b) +. el12(a) *. el11(b) +. el22(a) *. el12(b) +. el32(a) *. el13(b),
    el03(a) *. el10(b) +. el13(a) *. el11(b) +. el23(a) *. el12(b) +. el33(a) *. el13(b),
    el00(a) *. el20(b) +. el10(a) *. el21(b) +. el20(a) *. el22(b) +. el30(a) *. el23(b),
    el01(a) *. el20(b) +. el11(a) *. el21(b) +. el21(a) *. el22(b) +. el31(a) *. el23(b),
    el02(a) *. el20(b) +. el12(a) *. el21(b) +. el22(a) *. el22(b) +. el32(a) *. el23(b),
    el03(a) *. el20(b) +. el13(a) *. el21(b) +. el23(a) *. el22(b) +. el33(a) *. el23(b),
    el00(a) *. el30(b) +. el10(a) *. el31(b) +. el20(a) *. el32(b) +. el30(a) *. el33(b),
    el01(a) *. el30(b) +. el11(a) *. el31(b) +. el21(a) *. el32(b) +. el31(a) *. el33(b),
    el02(a) *. el30(b) +. el12(a) *. el31(b) +. el22(a) *. el32(b) +. el32(a) *. el33(b),
    el03(a) *. el30(b) +. el13(a) *. el31(b) +. el23(a) *. el32(b) +. el33(a) *. el33(b),
  ])
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
