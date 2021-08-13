open Belt
open Chai

test("reduce calls a function on each line", () => {
  let input = "This has a few lines\nReduce will be passed them one at a time\nLet's go!"

  LineWalker.reduce(input, [], (accum, next) => {
    Array.concat(accum, [next])
  })
  ->assertDeepEqual([
    "This has a few lines",
    "Reduce will be passed them one at a time",
    "Let's go!"
  ])
})
