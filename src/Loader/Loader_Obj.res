open Belt
// Loader for Obj files

// ignore(Fetch.fetch("vox/famling1-talk.vox")
// |> Js.Promise.then_(Fetch.Response.arrayBuffer)
// |> Js.Promise.then_(x => {
//   VoxLoader.fromArrayBuffer(x)->createMesh(scene, _, true)
//   Js.Promise.resolve(())
// }))

type t = {
  vertices: array<(float, float, float)>,
  normals: array<(float, float, float)>,
  faces: array<(int, int, int)>,
  textureCoords: array<(float, float)>,
  faceNormals: array<(int, int, int)>,
  faceTextures: array<(int, int, int)>,
}

let objAddVertex = (obj, val) => {
  Js.Array2.push(obj.vertices, val)->ignore
  obj
}

let objAddNormal = (obj, val) => {
  Js.Array2.push(obj.normals, val)->ignore
  obj
}

let objAddFace = (obj, val) => {
  Js.Array2.push(obj.faces, val)->ignore
  obj
}

let objAddTextureCoord = (obj, val) => {
  Js.Array2.push(obj.textureCoords, val)->ignore
  obj
}

let objAddFaceNormal = (obj, val) => {
  Js.Array2.push(obj.faceNormals, val)->ignore
  obj
}

let objAddFaceTexture = (obj, val) => {
  Js.Array2.push(obj.faceTextures, val)->ignore
  obj
}

type row =
  | Vertex(array<float>)
  | VertexNormal(array<float>)
  | Face(array<(int, int, int)>)
  | ObjectGroup
  | MaterialFile(string)
  | UseMaterial(string)
  | TextureCoord(array<float>)
  | BlankLine

let empty = () => {
  vertices: [],
  normals: [],
  faces: [],
  textureCoords: [],
  faceNormals: [],
  faceTextures: [],
}

let parseFace = faceRef => {
  open Js.String2
  switch faceRef->split("/")->Array.map(Int.fromString) {
  | [Some(a)] => Some(a - 1, -1, -1)
  | [Some(a), Some(b)] => Some(a - 1, b - 1, -1)
  | [Some(a), Some(b), Some(c)] => Some(a - 1, b - 1, c - 1)
  | _ => failwith(`Bad face reference in .obj file: ${faceRef}`)
  }
}

let parseRow = row => {
  open Js.String2

  let list =
    row->replaceByRe(%re("/#.*$/"), "")->trim->splitByRe(%re("/[ \t]+/"))->Util.array_removeNone
  let data = list->Array.sliceToEnd(1)
  let mapData = fn => data->Array.map(fn)->Util.array_removeNone
  switch list[0] {
  | Some("v") => Vertex(mapData(Float.fromString))
  | Some("f") => Face(mapData(parseFace))
  | Some("o") => ObjectGroup
  | Some("vn") => VertexNormal(mapData(Float.fromString))
  | Some("vt") => TextureCoord(mapData(Float.fromString))
  | Some("mtllib") => MaterialFile(data[0]->Option.getWithDefault(""))
  | Some("usemtl") => UseMaterial(data[0]->Option.getWithDefault(""))
  | Some("") => BlankLine
  | _ =>
    failwith(`Bad .obj file row "${row}" - "${list[0]->Option.getWithDefault("")}" not recognised`)
  }
}
let fromString = content => {
  LineWalker.reduce(content, empty(), (obj, row) =>
    switch parseRow(row) {
    | Vertex([x, y, z]) => objAddVertex(obj, (x, y, z))
    | Face([(a, aTex, aN), (b, bTex, bN), (c, cTex, cN)]) =>
      objAddFace(obj, (a, b, c))
      ->objAddFaceNormal((aN, bN, cN))
      ->objAddFaceTexture((aTex, bTex, cTex))
    | TextureCoord([u, v]) => objAddTextureCoord(obj, (u, v))
    | VertexNormal([x, y, z]) => objAddNormal(obj, (x, y, z))

    | Vertex(_) => failwith(`Obj vertices must be 3D: "${row}"`)
    | TextureCoord(_) => failwith(`Obj text coords must be 2D: "${row}"`)
    | VertexNormal(_) => failwith(`Obj vertex normals must be 3D: "${row}"`)
    | Face(_) => failwith(`Faces must be trianges: "${row}"`)

    // Noop
    | ObjectGroup => obj
    | MaterialFile(_) => obj
    | UseMaterial(_) => obj
    | BlankLine => obj
    }
  )
}

let load = url => {
  open Js.Promise
  Fetch.fetch(url) |> then_(x => x->Fetch.Response.text) |> then_(x => x->fromString->resolve)
}
