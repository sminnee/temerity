// Various utility functions, building on the Belt types

open Belt

// Operations on 2-tuples

@ocaml.doc("In a (value, context) pair, update the value")
let setFst = ((a, b), updater) => (updater(a), b)

@ocaml.doc("In a (value, context) pair, update the context")
let setSnd = ((a, b), updater) => (a, updater(b))

@ocaml.doc("In an option<(a,b)> pair, update a")
let setOptFst = (optPair, default, updater) =>
  switch optPair {
  | None => Some(updater(None), default)
  | Some((a, b)) => Some(updater(Some(a)), b)
  }

@ocaml.doc("In an option<(a,b)> pair, update b")
let setOptSnd = (optPair, default, updater) =>
  switch optPair {
  | None => Some(default, updater(None))
  | Some((a, b)) => Some(a, updater(Some(b)))
  }

@ocaml.doc("Unshift an element on the start of a 2-tuple, producing a 3-tuple")
let pair_unshift = ((a, b), extra) => (extra, a, b)

@ocaml.doc("Unshift an element on the end of a 2-tuple, producing a 3-tuple")
let pair_push = ((a, b), extra) => (a, b, extra)

// Operations on 3-tuples

@ocaml.doc("In a (value, context) pair, update the value")
let triple_setFst = ((a, b, c), updater) => (updater(a), b, c)

@ocaml.doc("In a (value, context) pair, update the context")
let triple_setSnd = ((a, b, c), updater) => (a, updater(b), c)

@ocaml.doc("In a (value, context) pair, update the context")
let triple_setThird = ((a, b, c), updater) => (a, b, updater(c))

@ocaml.doc("Unshift an element on the start of a 3-tuple, producing a 4-tuple")
let triple_unshift = ((a, b, c), extra) => (extra, a, b, c)

@ocaml.doc("Unshift an element on the end of a 3-tuple, producing a 4-tuple")
let triple_push = ((a, b, c), extra) => (a, b, c, extra)

let makePair = (a, b) => (a, b)

// Operations on Options

@ocaml("Lazily evaluate the default if the optional returns None.")
let orElse = (optional: option<'a>, default: unit => option<'a>) =>
  switch optional {
  | Some(x) => Some(x)
  | None => default()
  }

@ocaml("Lazily evaluate the default if the optional returns None.")
let option_withDefault = (optional: option<'a>, default: unit => 'a) =>
  switch optional {
  | Some(x) => x
  | None => default()
  }

@ocaml("Convert a result to an option")
let option_fromResult = res =>
  switch res {
  | Result.Ok(x) => Some(x)
  | Result.Error(_) => None
  }

// Operations on Maps

@ocaml.doc("Remove None options in a map containing options")
let mapString_removeNone = map =>
  Map.String.reduce(map, Map.String.empty, (accum, key, valOpt) =>
    switch valOpt {
    | None => accum
    | Some(val) => Map.String.set(accum, key, val)
    }
  )

@ocaml.doc("Remove Error options in a map containing Results")
let mapString_removeError = map =>
  Map.String.reduce(map, Map.String.empty, (accum, key, resVal) =>
    switch resVal {
    | Result.Error(_) => accum
    | Result.Ok(val) => Map.String.set(accum, key, val)
    }
  )

@ocaml.doc("Turn a map of results into a result of a map. The first error will be returned")
let mapString_bubbleError = map =>
  Map.String.reduce(map, Result.Ok(Map.String.empty), (resAccum, key, resVal) =>
    switch resAccum {
    | Result.Ok(accum) =>
      switch resVal {
      | Result.Error(x) => Result.Error(x)
      | Result.Ok(val) => Result.Ok(Map.String.set(accum, key, val))
      }
    | _ => resAccum
    }
  )

@ocaml.doc("Turn an array of results into a result of an array. The first error will be returned")
let array_bubbleError = map =>
  Array.reduce(map, Result.Ok([]), (resAccum, resVal) =>
    switch resAccum {
    | Result.Ok(accum) =>
      switch resVal {
      | Result.Error(x) => Result.Error(x)
      | Result.Ok(val) => Result.Ok(Array.concat(accum, [val]))
      }
    | _ => resAccum
    }
  )

@ocaml.doc("Generate a Map.String from an array, using a mapping function to generate keys")
let map_fromArray = (arr, keyFn) => Array.map(arr, val => (keyFn(val), val))->Map.String.fromArray

@ocaml.doc(
  "Combine 2 maps with matching keys into a map of tuples. The intersection of keys is used"
)
let map_combine_intersect = (mapA, mapB) =>
  Map.String.reduce(mapA, Map.String.empty, (accum, k, vA) =>
    switch Map.String.get(mapB, k) {
    | Some(vB) => Map.String.set(accum, k, (vA, vB))
    | None => accum
    }
  )

@ocaml.doc(
  "Combine 2 maps with matching keys into a map of tuples. Keys of first map are used; 2nd element is an option"
)
let map_combine = (mapA, mapB) =>
  Map.String.reduce(mapA, Map.String.empty, (accum, k, vA) =>
    Map.String.set(accum, k, (vA, Map.String.get(mapB, k)))
  )

// Operations on Sets

let setMap = (set, mapper, ~id) => Set.toArray(set)->Array.map(mapper)->Set.fromArray(~id)

@ocaml.doc("Return a list of all subsets of the given set, including empty and itself")
let powerSet = set =>
  Set.String.reduce(set, [Set.String.empty], (accum, item) => {
    Array.concat(Array.map(accum, Set.String.add(_, item)), accum)
  })

// Operations on Arrays

@ocaml.doc("Return the a relative value in an array")
let relValue = (arr, offset, val) =>
  switch Array.getIndexBy(arr, x => x == val) {
  | None => None
  | Some(idx) => arr[idx + offset]
  }

@ocaml.doc("Return the previous value in an array")
let prevValue = (arr, val) => relValue(arr, -1, val)

@ocaml.doc("Return the next value in an array")
let nextValue = (arr, val) => relValue(arr, 1, val)

@ocaml.doc("Concat 2 arrays, only adding items from b that don't already appear in a")
let concatUnique = (a, b) =>
  Array.concat(a, Js.Array2.filter(b, bVal => Js.Array2.indexOf(a, bVal) == -1))

@ocaml.doc("Remove None options in an array, containing options")
let array_removeNone = arr =>
  Array.reduce(arr, [], (accum, valOpt) =>
    switch valOpt {
    | None => accum
    | Some(val) => Array.concat(accum, [val])
    }
  )

@ocaml.doc("Remove Error options in an array containing Results")
let array_removeError = arr =>
  Array.reduce(arr, [], (accum, resVal) =>
    switch resVal {
    | Result.Error(_) => accum
    | Result.Ok(val) => Array.concat(accum, [val])
    }
  )

@ocaml.doc("Add an item to the end of the array")
let array_push = (arr, val) => Array.concat(arr, [val])

@ocaml.doc("Immutable array pop")
let array_pop = arr => {
  let len = Array.length(arr)
  arr[len - 1]->Option.mapWithDefault((arr, None), last => (
    Array.slice(arr, ~offset=0, ~len=len - 1),
    Some(last),
  ))
}

@ocaml.doc("Get the last element of an array")
let array_last = arr => {
  let len = Array.length(arr)
  arr[len - 1]
}

@ocaml.doc("Add an item to the start of the array")
let array_unshift = (arr, val) => Array.concat([val], arr)

@ocaml.doc("Remove an item from an array, if it contains it")
let array_remove = (arr, val) => Array.keep(arr, x => x != val)

@ocaml.doc("Remove an item from an array by index")
let array_removeIdx = (arr, idx) =>
  Array.concat(Array.slice(arr, ~offset=0, ~len=idx), Array.sliceToEnd(arr, idx + 1))

@ocaml.doc("Does the array contain the given value")
let array_has = (arr, val) => Array.getIndexBy(arr, x => x == val)->Option.isSome

@ocaml.doc("Remove many items from an array")
let array_diff = (arr, vals) => Array.keep(arr, x => !array_has(vals, x))

@ocaml.doc("Immutable array set")
let array_set = (arr, idx, val) =>
  Array.mapWithIndex(arr, (curIdx, curVal) => idx == curIdx ? val : curVal)

@ocaml.doc("Map over the given array, dropping any value with none")
let array_filterMap = (arr, fn) =>
  Array.reduce(arr, [], (accum, val) =>
    switch fn(val) {
    | None => accum
    | Some(result) => array_push(accum, result)
    }
  )

@ocaml.doc("Simple array formatter for signatures")
let array_sExpr = arr => Array.reduce(arr, "(", (acc, val) => acc ++ " " ++ val) ++ " )"

// Operations on Lists

@ocaml.doc("Form the cartesian join of two lists, returning a list of every pair, in reverse order")
let cartesian = (a: list<'a>, b: list<'b>): list<('a, 'b)> => {
  List.reduce(a, list{}, (accum, aVal) => {
    List.reduce(b, accum, (accum, bVal) => {
      list{(aVal, bVal), ...accum}
    })
  })
}

// Operations on Results

@ocaml.doc("Combine 2 results into a tuple or pass back the existing error lists.")
let result_combine2 = (a, b) =>
  switch (a, b) {
  | (Result.Ok(val1), Result.Ok(val2)) => Ok((val1, val2))
  | (Result.Error(message), Result.Ok(_)) => Result.Error(message)
  | (Result.Ok(_), Result.Error(message)) => Result.Error(message)
  | (Result.Error(message1), Result.Error(message2)) =>
    Result.Error(concatUnique(message1, message2))
  }

@ocaml.doc("Combine 3 results into a tuple or pass back the existing error lists.")
let result_combine3 = (a, b, c) => {
  let errors = result =>
    switch result {
    | Result.Error(x) => x
    | Result.Ok(_) => []
    }
  switch (a, b, c) {
  | (Result.Ok(val1), Result.Ok(val2), Result.Ok(val3)) => Ok((val1, val2, val3))
  | _ => Result.Error(concatUnique(concatUnique(errors(a), errors(b)), errors(c)))
  }
}

let resultOk = x => Result.Ok(x)

let result_fromOption = (optX, err) =>
  switch optX {
  | Some(x) => Result.Ok(x)
  | None => Result.Error(err)
  }

let result_alterMessage = (result, updater) =>
  switch result {
  | Result.Ok(_) => result
  | Result.Error(messages) => Result.Error(Array.map(messages, updater))
  }

let result_log = (result, fn) => switch result {
| Result.Ok(x) => fn(x)
| Result.Error(msg) => Js.log2("Error", msg)
}

// Operations on int

@ocaml.doc("Return the integer into a string such as '+1', '+0' or '-1'")
let int_signedString = val => (val < 0 ? "" : "+") ++ Int.toString(val)

// Other

@ocaml.doc("Log the execution time of an operation to the console")
let logTime = (label, operation: unit => 'a): 'a => {
  let t1 = Js.Date.now()
  let result = operation()
  let t2 = Js.Date.now()
  Js.log4("Execution time", label, (t2 -. t1) /. 1000., "seconds")
  result
}
