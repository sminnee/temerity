open Belt

@module external styles: {..} = "./Ui/Global.css"

switch ReactDOM.querySelector("#root") {
| Some(root) => ReactDOM.render(<Ui_App />, root)
| None => Js.log("Error: could not find react element")
}

