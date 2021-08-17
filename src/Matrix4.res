type t = array<float>

@new external makeArrayBuffer: int => Js.TypedArray2.ArrayBuffer.t = "ArrayBuffer"
@new external makeFloatArray: int => array<float> = "Float32Array"
@new external bufferFromArray: array<float> => array<float> = "Float32Array"

@new
external makeSubArray: (Js.TypedArray2.ArrayBuffer.t, int, int) => array<float> = "Float32Array"
@new external arrayFromBuffer: Js.TypedArray2.ArrayBuffer.t => array<float> = "Float32Array"

let empty = () => makeFloatArray(16)

let default = empty()

@inline @ocaml.doc("Load all values into an existing matrix")
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
  let set = Js.Array.unsafe_set

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

let makeIdentity = () =>
  bufferFromArray([1., 0., 0., 0., 0., 1., 0., 0., 0., 0., 1., 0., 0., 0., 0., 1.])

let identity = bufferFromArray([1., 0., 0., 0., 0., 1., 0., 0., 0., 0., 1., 0., 0., 0., 0., 1.])

let get = Js.Array.unsafe_get

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

let copy = (src, dst) => {
  let set = Js.Array.unsafe_set

  // Using load allows dst to be the same as a or b
  set(dst, 0, el00(src))
  set(dst, 1, el01(src))
  set(dst, 2, el02(src))
  set(dst, 3, el03(src))
  set(dst, 4, el10(src))
  set(dst, 5, el11(src))
  set(dst, 6, el12(src))
  set(dst, 7, el13(src))
  set(dst, 8, el20(src))
  set(dst, 9, el21(src))
  set(dst, 10, el22(src))
  set(dst, 11, el23(src))
  set(dst, 12, el30(src))
  set(dst, 13, el31(src))
  set(dst, 14, el32(src))
  set(dst, 15, el33(src))
  dst
}

let _tmp1 = empty()
let _tmp2 = empty()

let mulInto = (dst, a, b) => {
  if a === dst || b === dst {
    failwith("mulInto must have separate dst and src args")
  }

  let set = Js.Array.unsafe_set

  // Using load allows dst to be the same as a or b
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
}

let mul3Into = (dst, a, b, c) => {
  mulInto(_tmp1, a, b)->ignore
  mulInto(dst, _tmp1, c)
}

let mul4Into = (dst, a, b, c, d) => {
  mulInto(_tmp1, a, b)->ignore
  mulInto(_tmp2, _tmp1, c)->ignore
  mulInto(dst, _tmp2, d)
}

let mul5Into = (dst, a, b, c, d, e) => {
  mulInto(_tmp1, a, b)->ignore
  mulInto(_tmp2, _tmp1, c)->ignore
  mulInto(_tmp1, _tmp2, d)->ignore
  mulInto(dst, _tmp1, e)
}

let mul = (a, b) => {
  mulInto(empty(), a, b)
}

let mul3 = (a, b, c) => {
  mul3Into(empty(), a, b, c)
}

let mul4 = (a, b, c, d) => {
  mul4Into(empty(), a, b, c, d)
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

/* * -----------------------------------------------------------------
 * r = M * v (M is a 4x4 matrix, v is a 3-component vector)
 */
let mulVec3Into = (dest, mat: t, vec: Vec3.t) => {
  Vec3.load(
    dest,
    el00(mat) *. vec.x +. el10(mat) *. vec.y +. el20(mat) *. vec.z,
    el01(mat) *. vec.x +. el11(mat) *. vec.y +. el21(mat) *. vec.z,
    el02(mat) *. vec.x +. el12(mat) *. vec.y +. el22(mat) *. vec.z,
  )
}

let mulVec3 = (mat, vec) => mulVec3Into(Vec3.empty(), mat, vec)

module Array = {
  open Js.TypedArray2

  @ocaml.doc("Make an array of matrices")
  let makeBuffer = num => ArrayBuffer.make(16 * 4 * num)
  let fromBuffer = arrayFromBuffer

  @ocaml.doc("Bind a reference to one matrix in the array of matrices")
  let ref = (arr, idx) => {
    makeSubArray(arr, idx * 16 * 4, 16)
  }
}
