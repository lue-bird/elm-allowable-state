module Possibly exposing (Possibly(..))

{-| In short:

  - `Never` marks states as impossible

        empty : Is Possibly Empty filling_

  - [`Possibly`](#Possibly) marks states as possible

        top : Is Never Empty (StackFilled element) -> element

  - → you can carry over non-emptiness-information

        import Fillable exposing (Is(..), toFillingOrIfEmpty)

        type Focus item possiblyOrNever hole
            = Item item
            | Hole possiblyOrNever

        type Hole
            = HoleTag Never

        toFocus :
            Is possiblyOrNever Empty value
            -> Focus value possiblyOrNever Hole
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

    fromMaybe : Maybe value -> Is value Possibly Empty

    fromList : List element -> Is (StackFilled element) Possibly Empty


#### in type declarations

    type alias Model =
        WithoutConstructorFunction
            { selected : Is Choice Possibly Empty
            , planets : Is (StackFilled Planet) Possibly Empty
            , searchKeyWords : Is (StackFilled String) Never Empty
            }

    type alias WithoutConstructorFunction record =
        record

where `WithoutConstructorFunction` stops the compiler from creating a positional constructor function for `Model`.

Read more about the general idea in the
[module documentation](https://dark.elm.dmy.fr/packages/lue-bird/elm-allowable-state/latest/Possible).
or [readme](https://dark.elm.dmy.fr/packages/lue-bird/elm-allowable-state/latest/).

-}
type Possibly
    = -- should resemble ()
      O
