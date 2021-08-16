// Handling the core rendering and WebGL maangement

type meshData = {
  positions: WebGL.buffer,
  normals: WebGL.buffer,
  textureCoords: WebGL.buffer,
  length: int,
}

type frameRenderer<'a> = ('a => unit, 'a => unit)

type objectRenderer<'a, 'b> = ('a => unit, 'a => unit, ('a, 'b) => unit)

/*
single pixel texture

  // Because images have to be downloaded over the internet
  // they might take a moment until they are ready.
  // Until then put a single pixel in the texture so we can
  // use it immediately. When the image has finished downloading
  // we'll update the texture with the contents of the image.
  const level = 0;
  const internalFormat = gl.RGBA;
  const width = 1;
  const height = 1;
  const border = 0;
  const srcFormat = gl.RGBA;
  const srcType = gl.UNSIGNED_BYTE;
  const pixel = new Uint8Array([0, 0, 255, 255]);  // opaque blue

  WebGL.bindTexture(#Texture2D, texture);
  gl.texImage2D(gl.TEXTURE_2D, level, internalFormat,
                width, height, border, srcFormat, srcType,
                pixel);

*/

// type cameraInput = {
//   mesh: WebGL.buffer,
//   meshLength: int,
//   transform: array<float>,
// }

type animData = {
  mutable lastLog: float,
  mutable frames: int,
}

let animate = handler => {
  let animData = {frames: 0, lastLog: 0.}

  let rec go = now => {
    animData.frames = animData.frames + 1
    if now -. animData.lastLog > 2000. {
      Js.log2("Frame-rate", animData.frames / 2)
      animData.frames = 0
      animData.lastLog = now
    }

    Browser.requestAnimationFrame(go)->ignore
    handler(now)
  }

  go(0.)
}
