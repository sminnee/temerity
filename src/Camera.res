let frustum = (left, right, bottom, top, near, far) =>
  // Make sure there is no division by zero
  if left === right || bottom === top || near === far || near <= 0. || far <= 0. {
    None
  } else {
    let sx = 2. *. near /. (right -. left)
    let sy = 2. *. near /. (top -. bottom)

    let c2 = -.(far +. near) /. (far -. near)
    let c1 = 2. *. near *. far /. (near -. far)

    let tx = -.near *. (left +. right) /. (right -. left)
    let ty = -.near *. (bottom +. top) /. (top -. bottom)

    Some(Matrix4.fromArray([sx, 0., 0., 0., 0., sy, 0., 0., 0., 0., c2, -1., tx, ty, c1, 0.]))
  }

/* * -----------------------------------------------------------------
 * Create a perspective projection matrix using a field-of-view and an aspect ratio.
 * @param fovy  Number The angle between the upper and lower sides of the viewing frustum.
 * @param aspect Number The aspect ratio of the view window. (width/height).
 * @param near Number  Distance to the near clipping plane along the -Z axis.
 * @param far  Number  Distance to the far clipping plane along the -Z axis.
 * @return Float32Array The perspective transformation matrix.
 */
let perspectiveCamera = (fovy, aspect, near, far) =>
  if fovy <= 0. || fovy >= 180. || aspect <= 0. || near >= far || near <= 0. {
    None
  } else {
    let halfFovy = Matrix4.toRadians(fovy) /. 2.

    let top = near *. Js.Math.tan(halfFovy)
    let bottom = -.top
    let right = top *. aspect
    let left = -.right

    frustum(left, right, bottom, top, near, far)
  }

/* * -----------------------------------------------------------------
 * Set a camera matrix.
 * @param M Float32Array The matrix to contain the camera transformation.
 * @param eye_x Number The x component of the eye point.
 * @param eye_y Number The y component of the eye point.
 * @param eye_z Number The z component of the eye point.
 * @param center_x Number The x component of a point being looked at.
 * @param center_y Number The y component of a point being looked at.
 * @param center_z Number The z component of a point being looked at.
 * @param up_dx Number The x component of a vector in the up direction.
 * @param up_dy Number The y component of a vector in the up direction.
 * @param up_dz Number The z component of a vector in the up direction.
 */
let lookAtTransform = (eye, center, up) => {
  open Vec3

  // Local coordinate system for the camera:
  //   u maps to the x-axis
  //   v maps to the y-axis
  //   n maps to the z-axis

  let n = sub(eye, center)->normalize
  let u = cross(up, n)->normalize
  let v = cross(n, u)->normalize

  let tx = -.dot(u, eye)
  let ty = -.dot(v, eye)
  let tz = -.dot(n, eye)

  Matrix4.make(u.x, v.x, n.x, 0., u.y, v.y, n.y, 0., u.z, v.z, n.z, 0., tx, ty, tz, 1.)
}
