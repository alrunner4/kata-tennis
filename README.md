# Tennis Kata

_Inspired by_ [CodingDojo.org](https://codingdojo.org/kata/Tennis/)
_and_ [Jonas Follesø](https://github.com/follesoe/TennisKataJava)

## Functional Programming Highlights

I suggest viewing [my tennis implementation](Tennis.idr) alongside [the object-oriented Java
version](https://github.com/follesoe/TennisKataJava/blob/master/src/TennisGame.java) for comparison:
which of them do you think does a better job of communicating the rules of tennis as commonly
expressed? In the object-oriented style, there are fundamentally three types of expressions present:
mutation of object-member variables, predicates, and return statements. The object-oriented
arrangement relies on a collection of internal predicates: hasWinner, hasAdvantage, and isDeuce;
notably, these are all mutually-exclusive predicates. In my opinion, choosing to represent such
mutually exclusive predicates with a sum type is much clearer: the mutual exclusivity is hence
apparent to the reader simply by their syntactic relation rather than relying on knowledge of the
implementations of these respective predicates.

While the kata process is typically expected to be driven by tests, I found that the natural sum
type representation of mutually-exclusive tennis game states led me to expose a rather glaring
oversight in the object-oriented implementation: as written, it's willing to allow the object-user
to interleave `playerOneScores` and `playerTwoScores` in ways that a real game of tennis cannot.
Take the [tester's](https://github.com/follesoe/TennisKataJava/blob/master/src/TennisGameTest.java)
`createScore` method: in order to put the object into the state with the test-expected score, it
repeatedly calls `playerOneScores` for as many points as requested, and only then proceeds to
`playerTwoScores`. Any score greater than three given to for the first player by `createScore` hence
puts the object into an invalid state. Even though state and mutation have been chosen for the
implementation approach (as a fish chooses water, so too the object-oriented practitioner chooses
mutation) the implemented action-at-a-time interface -- `playerOneScores`, `playerTwoScores` --
fails to recognize the statefulness of whether that action should be allowed at all. This, to me,
clearly arises from the mismatch in implementation and testing style: the tests pretend that the
TennisGame class is declarative when it's not because declarative tests are easier to read.

### Dependent Types

My solution in Idris makes one addition that similar languages supporting sum types can't do as
simply: a type-level indicator for game completion. If you look closely at the type of my `point`
function, its signature tells us that it can only be used on a `PlayingState` which excludes the
possibility of the function being called on a `WinnerState` at compile time. This design choice may
not always be reasonable in general; the additional type-level complexity requires use of a
corresponding `AnyState` dependent pair in order for the caller to receive the result, one layer
more complex than simply using a `Maybe GameState` as a return type, but it does force the caller to
grapple with the non-continuability of the `WinnerState`. The `runGame` function is provided to
handle chaining multiple calls to `point`, and as an example of the `AnyState` dependent pair usage.
