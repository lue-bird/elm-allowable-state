> allow/forbid a state at the type level

# [allowable state](https://package.elm-lang.org/packages/lue-bird/elm-allowable-state/latest/)

There are many types that promise non-emptiness. One example: [MartinSStewart's `NonemptyString`](https://dark.elm.dmy.fr/packages/MartinSStewart/elm-nonempty-string/latest/).

`fromInt`, `char`, ... promise to return a filled string at compile-time.

→ `head`, `tail`, ... are guaranteed to succeed.
No `Maybe`s have to be carried throughout your program. Cool.

How about operations that **work on non-empty and emptiable** strings, like
```elm
length : Text canBeNonEmptyOrEmptiable -> Int

toUpper :
    Text canBeNonEmptyOrEmptiable
    -> Text canBeNonEmptyOrEmptiable
...
```
or ones that can **pass** the **(im)possibility of a state** from one data structure to the other?
```elm
toChars :
    Text nonEmptyOrEmptiable
    -> Stack Char nonEmptyOrEmptiable
```

All this is very much possible 🔥

Let's experiment and see where we end up.

```elm
type TextThatCan unitOrNever beEmpty
    = TextEmpty unitOrNever
    | TextFilled Char String

type BeEmpty
    = BeEmptyTag Never

char : Char -> TextThatCan Never BeEmpty
char onlyChar =
    TextFilled onlyChar ""

top : TextThatCan Never BeEmpty -> Char
top =
    \text ->
        case text of
            TextFilled headChar _ ->
                headChar
            
            TextEmpty possiblyOrNever ->
                possiblyOrNever |> never --! neat

top (char 'E') -- 'E'
top (TextEmpty ()) -- error
```

→ The type `TextThatCan Never BeEmpty` limits arguments to just `TextFilled`.

Lets make the type `TextThatCan ()/Never BeEmpty` handier:

```elm
type Text possiblyOrNever emptyTag

type alias Possibly =
    ()

type Empty
    = EmptyTag Never

empty : Text Possibly Empty
top : Text Never Empty -> Char
```

To avoid misuse like `empty : Text () Empty`,
we'll wrap the tag `()` in a `type` 🌯

```elm
type Possibly
    = O

top : Text Never Empty -> Char

empty : Text Possibly Empty
empty =
    TextEmpty O
```

👌. Now the fun part: Carrying emptiness-information over:

```elm
import Stack exposing (Stack)

toChars :
    Text possiblyOrNever Empty
    -> Stack Char possiblyOrNever Empty
toChars string =
    case string of
        TextEmpty possiblyOrNever ->
            StackEmpty possiblyOrNever

        TextFilled headChar tailString ->
            StackFilled headChar (tailString |> String.toList)
```

The type information gets carried over, so
```elm
Text Never Empty -> Stack Char Never Empty
Text Possibly Empty -> Stack Char Possibly Empty
```

I hope you got the idea:
You can allow of forbid a variant by adding a type argument that is either `Never` or [`Possibly`](Possibly)

Take a look at [data structures that build on this idea](https://package.elm-lang.org/packages/lue-bird/elm-emptiness-typed/latest/). They really make life easier.
