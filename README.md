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
type TextThatCanBeEmpty unitOrNever
    = TextEmpty unitOrNever
    | TextFilled Char String

char : Char -> TextThatCanBeEmpty Never
char onlyChar =
    TextFilled onlyChar ""

top : TextThatCanBeEmpty Never -> Char
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

→ The type `TextThatCanBeEmpty Never` limits arguments to just `TextFilled`.

Lets make the type `TextThatCanBeEmpty ()/Never` handier:

```elm
type TextEmpty possiblyOrNever

type alias Possibly =
    ()

empty : TextEmpty Possibly
top : TextEmpty Never -> Char
```

To avoid misuse like `empty : Text () Empty`,
we'll represent the `()` tag as a `type`:

```elm
type Possibly
    = Possible

top : Text Never Empty -> Char

empty : Text Possibly Empty
empty =
    TextEmpty Possible
```

👌. Now the fun part: Carrying emptiness-information over:

```elm
toChars :
    TextEmpty possiblyOrNever
    -> StackEmpty possiblyOrNever Char
toChars string =
    case string of
        TextEmpty possiblyOrNever ->
            StackEmpty possiblyOrNever

        TextFilled headChar tailString ->
            StackFilled headChar (tailString |> String.toList)
```
so
```elm
TextEmpty Never -> StackEmpty Never Char
TextEmpty Possibly -> StackEmpty Possibly Char
```

I hope you got the idea:
You can allow of forbid a variant by adding a type argument that is either `Never` or [`Possibly`](Possibly)

Take a look at [data structures that build on this idea](https://package.elm-lang.org/packages/lue-bird/elm-emptiness-typed/latest/).
They really make life easier.

----

## phantom builder pattern replacement

Want to know about the phantom builder pattern?
- [talk "The phantom builder pattern" by Jeroen Engels](https://www.youtube.com/watch?v=Trp3tmpMb-o)
    - [presentation slides](https://slides.com/jfmengels/phantom-builder-pattern/)
- [article "Phantom builder pattern in Elm" by Josh Bebbington](https://medium.com/carwow-product-engineering/phantom-builder-pattern-in-elm-2fcb950a4e36)
- [podcast "Phantom Builder Pattern" in elm-radio](https://elm-radio.com/episode/phantom-builder/)

`Never`/[`Possibly`](#Possibly) type arguments
cover guarantees the phantom builder pattern can promise, but through narrowing the actual type.
No information lost. The API will always be airtight.

Examples ↓

- [at least one builder required](#at-least-one-builder-required)
- [exactly one builder of a kind required](#exactly-one-builder-of-a-kind-required)
- [duplicate optional builders forbidden](#duplicate-optional-builders-forbidden)

### at least one builder required

similar to our chosen example:
- [`jfmengels/elm-review` rule visitors](https://dark.elm.dmy.fr/packages/jfmengels/elm-review/latest/Review-Rule#fromModuleRuleSchema)
- [`MartinSStewart/elm-serialize` `CustomTypeCodec` variants](https://dark.elm.dmy.fr/packages/MartinSStewart/elm-serialize/latest/Serialize#CustomTypeCodec)
    - technically not record phantom builder style. Only one constraint enforced by removing

Let's run with the [`textAdd` example from the talk "The phantom builder pattern" by Jeroen Engels](https://slides.com/jfmengels/phantom-builder-pattern/#/6/3)

```elm
type Button event constraints
    = Button
        { texts : List String
        }

default : Button event {}

textAdd :
    String
    -> (Button event constraints
        -> Button event { constraints | hasText : () }
       )

ui :
    Button event { constraints | hasText : () }
    -> Html event
```

Here's the same with `Never`/[`Possibly`](#Possibly) type arguments

```elm
type Button event noTextTag_ noTextPossiblyOrNever
    = Button
        { texts : Emptiable (Stacked String) noTextPossiblyOrNever
        }

type NoText
    = NoTextTag Never

default : Button event NoText Possibly

textAdd :
    String
    -> (Button event NoText noTextPossiblyOrNever_
        -> Button event NoText noTextNever_
       )

ui :
    Button event NoText Never
    -> Html event
```

### exactly one builder of a kind required

Let's run with the [`interactivity` example from the talk "The phantom builder pattern" by Jeroen Engels](https://slides.com/jfmengels/phantom-builder-pattern/#/6/3)

```elm
type Button event constraints
    = Button
        { interactivity : Maybe (Interactivity event)
        }

type Interactivity event
    = Disabled
    | Clickable event

default : Button event { needsInteractivity : () }

withDisabled :
    Button event { constraints | needsInteractivity : () }
 -> Button event { constraints | hasInteractivity : () }

ui :
    Button event { constraints | hasInteractivity : () }
    -> Html event
```

Here's the same with `Never`/[`Possibly`](#Possibly) type arguments

```elm
type Button event constraints noInteractivityTag_ noInteractivityPossiblyOrNever
    = Button
        { interactivity :
            Emptiable (Interactivity event) noInteractivityPossiblyOrNever
        }

type Interactivity event
    = Disabled
    | Clickable event

type NoInteractivity
    = NoInteractivityTag Never

default : Button event NoInteractivity Possibly

withDisabled :
    Button event NoInteractivity noInteractivityPossiblyOrNever_
    -> Button event NoInteractivity noInteractivityNever_

ui :
    Button event NoInteractivity Never
    -> Html event
```


### duplicate optional builders forbidden

example given in
- [article "Phantom builder pattern in Elm" by Josh Bebbington](https://medium.com/carwow-product-engineering/phantom-builder-pattern-in-elm-2fcb950a4e36)
- [gist "Phantom Builder Pattern with Elm" by ni-ko-o-kin](https://gist.github.com/ni-ko-o-kin/1baf6e5e91e1ad811a15242de7a605a1)

```elm
default |> withIcon "arrow-left" |> withIcon "arrow-right"
```
> Maybe our button will show the arrow-left icon or the arrow-right icon,
> or maybe two icons will appear!
> The truth is that we can't know without digging into the implementation of `withIcon`.

I'd say that terminology should be consistent to make this clear:
`iconAdd` for multiple, `iconSet`/`withIcon` to override.

Anyway: here's the phantom builder API

```elm
type Button constraints
    = Button
        { icon : Maybe String
        }

default : Button { canHaveIcon : () }

withIcon :
    String
    -> (Button { constraints | canHaveIcon : () }
        -> Button constraints
       )

default |> withIcon "arrow-left" |> withIcon "arrow-right"
```
> `withIcon "arrow-right"`
> expected `Button { canHaveIcon : () }`, found `Button {}`

Here's the same with `Never`/[`Possibly`](#Possibly) type arguments

```elm
type Button iconPresentTag_ iconPresentPossiblyOrNever =
    Button
        { icon :
            Maybe
                { reference : String
                , present : iconPresentPossiblyOrNever
                }
        }

type IconPresent
    = IconPresentTag Never

default : Button IconPresent iconPresentNever_

withIcon :
    String
    -> (Button IconPresent Never
        -> Button IconPresent Possibly
       )

init |> withIcon "arrow-left" |> withIcon "arrow-right"
-- 
```
> `withIcon "arrow-right"`
> expected `Button IconPresent Never`, found `Button IconPresent Possibly`


### benefits vs phantom builder pattern

As should be obvious by now, having a `Button { constraints | hasInteractivity : () }`
**doesn't actually allow anyone to access what interactivity has been selected**,
making it kind of... useless?

Additionally, it's possible to **forget to require or provide the right constraints**.
Misjudging extensible phantom record type behavior can happen – the bad part is:
**no one will remind you** if it's possible to sneak by the constraints
– by annotating the builder a certain way,
by calling an accidentally exposed constructor,
by calling builders in an unanticipated manner, ...

`Never`/[`Possibly`](#Possibly) type arguments like in `Button NoInteractivity Never`
[**make impossible states impossible**](https://www.youtube.com/watch?v=IcgmSRJHu_8) – not just _unconstructable_.
Values can be [extracted safely](https://dark.elm.dmy.fr/packages/elm/core/latest/Basics#never)
without any shenanigans like throwing stack-overflows on unexpected representable states.
The compiler will
- warn if constraints aren't enforced
- always infer constraints and promises correctly

One last thing, which you might call "minor": You're allowed to expose the constructor of a type with
`Never`/[`Possibly`](#Possibly) type arguments.
Can't do that with phantom-typed values since construction is always "unsafe".

### drawbacks vs phantom builder pattern

- internal field type changes → record update shortcut unavailable
- `NoInteractivity Never` is double-negation and harder to read
- all constraints a builder doesn't care about have to be listed as variables
