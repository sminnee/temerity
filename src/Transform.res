// Matrices representing transformation operations

let set = Js.Array.unsafe_set

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

// Mutable forms

let translateInto = (dest, x, y, z) =>
  load(dest, 1., 0., 0., 0., 0., 1., 0., 0., 0., 0., 1., 0., x, y, z, 1.)

let scaleInto = (dest, x, y, z) =>
  load(dest, x, 0., 0., 0., 0., y, 0., 0., 0., 0., z, 0., 0., 0., 0., 1.)

let rotateXInto = (dest, angle) => {
  let radians = Matrix4.toRadians(angle)
  let s = Js.Math.sin(radians)
  let c = Js.Math.cos(radians)

  load(dest, 1., 0., 0., 0., 0., c, s, 0., 0., -.s, c, 0., 0., 0., 0., 1.)
}

let rotateYInto = (dest, angle) => {
  let radians = Matrix4.toRadians(angle)
  let s = Js.Math.sin(radians)
  let c = Js.Math.cos(radians)
  load(dest, c, 0., -.s, 0., 0., 1., 0., 0., s, 0., c, 0., 0., 0., 0., 1.)
}

let rotateZInto = (dest, angle) => {
  let radians = Matrix4.toRadians(angle)
  let s = Js.Math.sin(radians)
  let c = Js.Math.cos(radians)
  load(dest, c, s, 0., 0., -.s, c, 0., 0., 0., 0., 1., 0., 0., 0., 0., 1.)
}

// Immutable forms

let translate = (x, y, z) =>
  translateInto(Matrix4.empty(), x, y, z)

let scale = (x, y, z) =>
  scaleInto(Matrix4.empty(), x, y, z)

let rotateX = (angle) =>
  rotateXInto(Matrix4.empty(), angle)

let rotateY = (angle) =>
  rotateYInto(Matrix4.empty(), angle)

let rotateZ = (angle) =>
  rotateZInto(Matrix4.empty(), angle)


// let rotate = (angle, )

//   self.rotate = function (M, angle, x_axis, y_axis, z_axis) {
//     var s, c, c1, xy, yz, zx, xs, ys, zs, ux, uy, uz;

//     angle = self.toRadians(angle);

//     s = Math.sin(angle);
//     c = Math.cos(angle);
//       // Rotation around any arbitrary axis
//       axis_of_rotation[0] = x_axis;
//       axis_of_rotation[1] = y_axis;
//       axis_of_rotation[2] = z_axis;
//       V.normalize(axis_of_rotation);
//       ux = axis_of_rotation[0];
//       uy = axis_of_rotation[1];
//       uz = axis_of_rotation[2];

//       c1 = 1 - c;

//       M[0] = c + ux * ux * c1;
//       M[1] = uy * ux * c1 + uz * s;
//       M[2] = uz * ux * c1 - uy * s;
//       M[3] = 0;

//       M[4] = ux * uy * c1 - uz * s;
//       M[5] = c + uy * uy * c1;
//       M[6] = uz * uy * c1 + ux * s;
//       M[7] = 0;

//       M[8] = ux * uz * c1 + uy * s;
//       M[9] = uy * uz * c1 - ux * s;
//       M[10] = c + uz * uz * c1;
//       M[11] = 0;

//       M[12] = 0;
//       M[13] = 0;
//       M[14] = 0;
//       M[15] = 1;
//     }
//   };
