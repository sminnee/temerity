// Provides a reduce on a multi-line string that doesn't require first building an array

// Mutable state for reduce
type reduceState<'a> = {
  mutable start: int,
  mutable accum: 'a,
}

let reduce = (input, start, fn) => {
  let state = {start: 0, accum: start}
  let len = String.length(input)

  while state.start < len {
    let next = Js.String2.indexOfFrom(input, "\n", state.start)
    let string = if next == -1 {
      Js.String.substringToEnd(input, ~from=state.start)
    } else {
      Js.String.substring(input, ~from=state.start, ~to_=next)
    }
    state.accum = fn(state.accum, string)
    state.start = next == -1 ? len : next + 1
  }

  state.accum
}
