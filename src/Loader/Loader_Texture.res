type image

@new external makeImage: unit => image = "Image"
@set external setOnLoad: (image, unit => unit) => unit = "onload"
@set external setOnError: (image, unit => unit) => unit = "onerror"
@set external setSrc: (image, string) => unit = "src"

exception LoadException(string)

let load = url => {
  Js.Promise.make((~resolve, ~reject) => {
    let image = makeImage()

    setOnLoad(image, () => {
      resolve(. image)
    })
    setOnError(image, () => {
      reject(. LoadException("Failed to load texture"))
    })

    setSrc(image, url)
  })
}
