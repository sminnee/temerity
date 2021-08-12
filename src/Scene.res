open Belt

let loadMesh = (context, meshData) => {
  WebGL.createBuffer(context)->Option.map(id => {
    WebGL.bindBuffer(context, #ArrayBuffer, id)
    WebGL.bufferData(context, #ArrayBuffer, meshData, #StaticDraw)
    id
  })
}
