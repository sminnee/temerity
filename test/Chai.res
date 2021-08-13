type assertions
type result


@module("chai") @scope("assert") @val external assertEqual: ('a, 'a) => unit = "equal"
@module("chai") @scope("assert") @val external assertDeepEqual: ('a, 'a) => unit = "deepEqual"
@module("chai") @scope("assert") @val external assertFail: () => unit = "fail"
@module("chai") @scope("assert") @val external assertTrue: ('a) => unit = "isTrue"
@module("chai") @scope("assert") @val external assertFalse: ('a) => unit = "isFalse"

@val external test: (string, @uncurry (unit => unit)) => unit = "it"
