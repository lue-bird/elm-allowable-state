module Possibly exposing (Possibly(..))

{-| In short:

  - `Never` marks states as impossible

        top : Empty Never (StackFilled element) -> element

  - [`Possibly`](#Possibly) marks states as possible

        empty : Empty Possibly filling_

  - → you can carry over non-emptiness-information

        import Fillable exposing (Empty(..), toFillingOrIfEmpty)

        type FocusHole possiblyOrNever item
            = Item item
            | Hole possiblyOrNever

        toFocus :
            Empty possiblyOrNever value
            -> FocusHole possiblyOrNever value
        toFocus =
            \fillable ->
                case fillable of
                    Empty possiblyOrNever ->
                        Hole possiblyOrNever

                    Filled value ->
                        value |> Item

    or

        toFocus =
            \fillable ->
                fillable
                    |> Fillable.map Item
                    |> toFillingOrIfEmpty Hole

@docs Possibly

If you still have questions, check out the [readme](https://dark.elm.dmy.fr/packages/lue-bird/elm-allowable-state/latest/).

-}


{-| Marks a state as possible to occur.


#### in results

    fromMaybe : Maybe value -> Empty Possibly value

    fromList : List element -> Empty Possibly (StackFilled element)


#### in type declarations

    type alias Model =
        WithoutConstructorFunction
            { selected : Empty Possibly Choice
            , planets : Empty Possibly (StackFilled Planet)
            , searchKeyWords : Empty Never (StackFilled String)
            }

    type alias WithoutConstructorFunction record =
        record

where `WithoutConstructorFunction` stops the compiler from creating a positional constructor function for `Model`.

Read more about the general idea in the
[module documentation](https://dark.elm.dmy.fr/packages/lue-bird/elm-allowable-state/latest/Possible).
or [readme](https://dark.elm.dmy.fr/packages/lue-bird/elm-allowable-state/latest/).

-}
type Possibly
    = Possible
