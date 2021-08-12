// Matrices representing transformation operations

let translate = (x, y, z) =>
  Matrix4.fromArray([1., 0., 0., 0., 0., 1., 0., 0., 0., 0., 1., 0., x, y, z, 1.])

let scale = (x, y, z) =>
  Matrix4.fromArray([x, 0., 0., 0., 0., y, 0., 0., 0., 0., z, 0., 0., 0., 0., 1.])

let rotateX = angle => {
  let radians = Matrix4.toRadians(angle)
  let s = Js.Math.sin(radians)
  let c = Js.Math.cos(radians)

  Matrix4.fromArray([1., 0., 0., 0., 0., c, s, 0., 0., -.s, c, 0., 0., 0., 0., 1.])
}

let rotateY = angle => {
  let radians = Matrix4.toRadians(angle)
  let s = Js.Math.sin(radians)
  let c = Js.Math.cos(radians)
  Matrix4.fromArray([c, 0., -.s, 0., 0., 1., 0., 0., s, 0., c, 0., 0., 0., 0., 1.])
}

let rotateZ = angle => {
  let radians = Matrix4.toRadians(angle)
  let s = Js.Math.sin(radians)
  let c = Js.Math.cos(radians)
  Matrix4.fromArray([c, s, 0., 0., -.s, c, 0., 0., 0., 0., 1., 0., 0., 0., 0., 1.])
}

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
