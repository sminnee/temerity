open Belt

//@module external styles: {..} = "./Ui/Global.css"

let mesh = Mesh.make(
  [[0.0, -0.25, -0.50], [0.0, 0.25, 0.00], [0.5, -0.25, 0.25], [-0.5, -0.25, 0.25]],
  [[2, 1, 3], [3, 1, 0], [0, 1, 2], [0, 2, 3]],
)

switch ReactDOM.querySelector("#root") {
| Some(root) => ReactDOM.render(<Ui_GLCanvas content={[mesh.data]} />, root)
| None => Js.log("Error: could not find react element")
}
