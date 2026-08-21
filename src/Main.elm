module Main exposing (main)

{-| The fixpoint-linux landing page as a plain `Browser.element` app.

This module renders the *entire* landing page content (top nav + components
dropdown, hero, and the `#idea` / `#time` / `#stack` / `#principles` /
`#design` sections plus footer) into whatever node it is mounted in, using the
exact CSS class names from the legacy static page (`LEGACY-index.html`) so the
shared stylesheet in the shell just works.

It is used in two places with identical rendering:

  - At build time, `scripts/ssg.mjs` loads the compiled bundle under happy-dom
    and calls `Elm.Main.init({ node })` to pre-render the page to static HTML.
  - At run time, `shell/mfe/fixpoint-landing.js` mounts it into the
    `[data-mfe="fixpoint-landing"]` slot via the same `Elm.Main.init({ node })`.

Because the model is unit and there are no messages, the app has no
interactivity: everything that looks interactive (the hover dropdown, the
blinking cursor) is pure CSS. Keeping it this simple makes the SSR seam
trivial and robust.

-}

import Browser
import Html exposing (Html, a, b, button, code, div, em, footer, h1, h2, h3, header, li, nav, p, pre, section, span, table, tbody, td, text, th, thead, tr, ul)
import Html.Attributes exposing (attribute, class, href, id)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    ()


type Msg
    = NoOp


init : () -> ( Model, Cmd Msg )
init _ =
    ( (), Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view _ =
    div []
        [ navView
        , headerView
        , ideaSection
        , timeSection
        , stackSection
        , principlesSection
        , designSection
        , footerView
        ]



-- Top nav (brand + anchor links + "components" hover dropdown)


navView : Html Msg
navView =
    nav []
        [ div [ class "wrap" ]
            [ span [ class "brand" ]
                [ span [ class "fx" ] [ text "fx" ]
                , text "://fixpoint-linux"
                ]
            , span [ class "links" ]
                [ a [ href "#idea" ] [ text "idea" ]
                , a [ href "#time" ] [ text "time" ]
                , a [ href "#stack" ] [ text "stack" ]
                , a [ href "#principles" ] [ text "principles" ]
                , a [ href "#design" ] [ text "design" ]
                , span [ class "dropdown" ]
                    [ button [ class "toggle", attribute "aria-haspopup" "true" ]
                        [ text "components ▾" ]
                    , span [ class "menu", attribute "role" "menu" ]
                        [ a [ href "https://fixpoint-linux.github.io/datalog-dafsa/" ]
                            [ span [ class "fx" ] [ text "datalog-dafsa" ], text " →" ]
                        , a [ class "ddhake", href "https://fixpoint-linux.github.io/dhake/" ]
                            [ text "dhake →" ]
                        , a [ href "https://github.com/fixpoint-linux/dhall-c" ]
                            [ text "dhall-c" ]
                        , a [ href "https://github.com/fixpoint-linux/dafsa" ]
                            [ text "dafsa" ]
                        , a [ href "https://github.com/fixpoint-linux/compendium" ]
                            [ text "compendium" ]
                        , a [ href "https://github.com/fixpoint-linux/visage" ]
                            [ text "visage" ]
                        , a [ href "https://github.com/fixpoint-linux/shen-meta" ]
                            [ text "shen-meta" ]
                        , a [ href "https://github.com/fixpoint-linux/fixpoint-linux" ]
                            [ text "fixpoint-linux" ]
                        ]
                    ]
                ]
            ]
        ]



-- Hero


headerView : Html Msg
headerView =
    header []
        [ div [ class "wrap" ]
            [ div [ class "prompt" ]
                [ span [ class "hash" ] [ text "#" ]
                , text " fixpoint-linux "
                , span [ class "dollar" ] [ text "$" ]
                , text " fx build --self-host"
                , span [ class "blink" ] [ text "▊" ]
                ]
            , h1 []
                [ text "A Linux system that is "
                , span [ class "fx" ] [ text "a fixed point" ]
                , text "."
                ]
            , div [ class "tagline" ]
                [ text "deterministically built, "
                , b [] [ text "from source, by itself" ]
                , text "."
                ]
            ]
        ]



-- Section: #idea


ideaSection : Html Msg
ideaSection =
    section [ id "idea" ]
        [ div [ class "wrap" ]
            [ h2 [] [ text "The idea" ]
            , div [ class "hint" ] [ text "// least_fixed_point(datalog) + dafsa" ]
            , p []
                [ code [] [ text "fixpoint-linux" ]
                , text " is a collection of small, self-contained components written in "
                , b [] [ text "C11" ]
                , text " that assemble into a coherent Linux userspace. Every binary is compiled with "
                , a [ href "https://github.com/jart/cosmopolitan" ] [ code [] [ text "cosmocc" ] ]
                , text " into a single portable "
                , a [ href "https://justine.lol/ape.html" ] [ code [] [ text "Actually Portable Executable" ] ]
                , text " (APE) — one file that runs on Linux, macOS, Windows, and the BSDs with "
                , b [] [ text "no VM, no runtime, no interpreter, no dependencies" ]
                , text "."
                ]
            , p []
                [ text "Everything is configured in "
                , a [ href "https://dhall-lang.org/" ] [ code [] [ text "Dhall" ] ]
                , text ", a strongly-typed, total configuration language. Configs are typechecked, normalized, and "
                , em [] [ text "terminate" ]
                , text " — they are programs, not property files."
                ]
            , p []
                [ text "The name comes from the two ideas at the heart of the stack:" ]
            , div [ class "grid" ]
                [ div [ class "card" ]
                    [ span [ class "n" ] [ text "01" ]
                    , h3 [] [ text "Fixpoint" ]
                    , p []
                        [ text "The least-fixed-point semantics of "
                        , a [ href "https://en.wikipedia.org/wiki/Datalog" ] [ text "Datalog" ]
                        , text "; a system is its own build artifact, deterministic and reproducible."
                        ]
                    ]
                , div [ class "card" ]
                    [ span [ class "n" ] [ text "02" ]
                    , h3 [] [ text "DAFSA" ]
                    , p []
                        [ text "The "
                        , a [ href "https://en.wikipedia.org/wiki/Deterministic_acyclic_finite_state_automaton" ]
                            [ text "minimal acyclic finite-state automaton" ]
                        , text " that backs the data stores: compact, exact, fast."
                        ]
                    ]
                ]
            ]
        ]



-- Section: #time


timeSection : Html Msg
timeSection =
    section [ id "time" ]
        [ div [ class "wrap" ]
            [ h2 [] [ text "A system that never forgets itself" ]
            , div [ class "hint" ] [ text "// dl_publish_snapshot · dl_snapshot_versions · dl_query_version" ]
            , p []
                [ code [] [ text "fixpoint-linux" ]
                , text " is "
                , b [] [ text "content-addressed by construction and time-travelling by default" ]
                , text ". Every change is one atomic snapshot of the whole system; the timeline is the system's complete history. Inspect any past state with an as-of query, roll back to any earlier point, and undo the rollback itself — without ever losing the record of what happened."
                ]
            , pre [ class "timeline" ]
                ([ text "$ fx status\n" ]
                    ++ timelineLine "v042" "2026-08-18 09:12:41 · activated · ok"
                    ++ timelineLine "v041" "2026-08-17 22:04:09 · activated · ok"
                    ++ timelineLine "v040" "2026-08-17 18:55:31 · rolled-forward to v042"
                    ++ timelineLine "v039" "2026-08-16 11:02:17 · activated · ok"
                    ++ [ text "...\n$ fx rollback v039   "
                       , span [ class "dim" ] [ text "# record it as history, always undoable" ]
                       ]
                )
            , ul [ class "checks" ]
                [ li []
                    [ b [] [ text "Roll-forward rollbacks" ]
                    , text " — the timeline is an append-only ledger; going back is recorded as history and always undoable."
                    ]
                , li []
                    [ b [] [ text "Boot rollback" ]
                    , text " — if the latest activation fails to come up, init rolls back to the last good state automatically."
                    ]
                , li []
                    [ b [] [ text "Generation GC" ]
                    , text " — keep N bootable generations, prune the rest, done."
                    ]
                ]
            , p []
                [ text "Powered by "
                , code [] [ text "datalog-dafsa" ]
                , text "'s native snapshot time-travel."
                ]
            ]
        ]


{-| One line of the `fx status` timeline: the version (accent) + trailing
space + the note (dim), each terminated by a newline.
-}
timelineLine : String -> String -> List (Html Msg)
timelineLine version note =
    [ span [ class "c" ] [ text version ]
    , text " "
    , span [ class "dim" ] [ text note ]
    , text "\n"
    ]



-- Section: #stack (component table)


stackSection : Html Msg
stackSection =
    section [ id "stack" ]
        [ div [ class "wrap" ]
            [ h2 [] [ text "The stack" ]
            , div [ class "hint" ] [ text "// self-contained · portable · reproducible" ]
            , table [ class "stack" ]
                [ thead []
                    [ tr []
                        [ th [] [ text "Component" ]
                        , th [] [ text "What it is" ]
                        ]
                    ]
                , tbody []
                    [ stackRow "fixpoint-linux"
                        "https://github.com/fixpoint-linux/fixpoint-linux"
                        [ b [] [ text "The system itself" ]
                        , text " — a Dhall-specified, self-hosting Linux distro. Like Nix's "
                        , em [] [ text "model" ]
                        , text " (pure derivations, content-addressed store, hermetic builds) without the Nix language. Time-travelling — the whole system remembers and rolls back. "
                        , a [ href "https://github.com/fixpoint-linux/fixpoint-linux/blob/main/DESIGN.md" ]
                            [ text "Read the design →" ]
                        ]
                    , stackRow "dhall-c"
                        "https://github.com/fixpoint-linux/dhall-c"
                        [ text "A subset interpreter for Dhall, in C. "
                        , code [] [ text "typecheck" ]
                        , text ", "
                        , code [] [ text "normalize" ]
                        , text ", "
                        , code [] [ text "to-json" ]
                        , text "/"
                        , code [] [ text "toml" ]
                        , text "/"
                        , code [] [ text "yaml" ]
                        , text ". The typed-config foundation everything builds on."
                        ]
                    , stackRow "datalog-dafsa"
                        "https://github.com/fixpoint-linux/datalog-dafsa"
                        [ text "A DAFSA-backed Datalog engine in C. Facts into an on-disk minimal-acyclic-DAFSA store, rules to a small VM, reads from an mmap'd snapshot. "
                        , b [] [ text "Native time travel" ]
                        , text " — immutable versioned snapshots and as-of queries as a first-class feature. "
                        , a [ href "https://fixpoint-linux.github.io/datalog-dafsa/" ] [ text "Docs →" ]
                        ]
                    , stackRow "dhake"
                        "https://github.com/fixpoint-linux/dhake"
                        [ text "A Make-like build tool whose buildfile is a Dhall program ("
                        , code [] [ text "Dhakefile.dhall" ]
                        , text "). Typed actions, incremental checks, phony targets, "
                        , code [] [ text "-j" ]
                        , text " parallel builds. "
                        , b [] [ text "Self-hosting" ]
                        , text " — it builds itself. "
                        , a [ href "https://fixpoint-linux.github.io/dhake/" ] [ text "Docs →" ]
                        ]
                    , stackRow "compendium"
                        "https://github.com/fixpoint-linux/compendium"
                        [ text "A small, self-contained authoritative DNS server (UDP, RFC 1035), configured in Dhall, shipped as a single APE binary."
                        ]
                    , stackRow "visage"
                        "https://github.com/fixpoint-linux/visage"
                        [ text "A compact email alias & forwarding server — disposable "
                        , code [] [ text "alias@domain" ]
                        , text " addresses backed by a DAFSA store. Daemon and store in one small APE binary."
                        ]
                    , stackRow "dafsa"
                        "https://github.com/fixpoint-linux/dafsa"
                        [ text "The Carrasco–Forcada incremental DAFSA — minimal automaton with add/delete/lookup, persistence and DOT export."
                        ]
                    , stackRow "shen-meta"
                        "https://github.com/fixpoint-linux/shen-meta"
                        [ text "A self-hosted Shen implementation — a "
                        , b [] [ text "sequent-calculus Lisp" ]
                        , text ". Evaluates itself, compiles itself to native bytecode, runs on a native C VM with a custom GC."
                        ]
                    ]
                ]
            ]
        ]


{-| One row of the stack table: the monospace name link + the description cell.
-}
stackRow : String -> String -> List (Html Msg) -> Html Msg
stackRow name url descChildren =
    tr []
        [ td [ class "name" ] [ a [ href url ] [ text name ] ]
        , td [ class "desc" ] descChildren
        ]



-- Section: #principles (α–ζ cards)


principlesSection : Html Msg
principlesSection =
    section [ id "principles" ]
        [ div [ class "wrap" ]
            [ h2 [] [ text "Design principles" ]
            , div [ class "hint" ] [ text "// ethos" ]
            , div [ class "grid" ]
                [ principleCard "α" "One binary, zero deps"
                    [ text "Cosmocc + APE means each tool is self-contained and portable across OSes."
                    ]
                , principleCard "β" "Config is typed code"
                    [ text "Dhall gives typechecking, imports, and reusable functions — and it always terminates."
                    ]
                , principleCard "γ" "Logic is declarative"
                    [ text "Datalog + DAFSA keep the data plane compact and exact."
                    ]
                , principleCard "δ" "Self-hosting"
                    [ text "Tools build themselves — see "
                    , code [] [ text "dhake" ]
                    , text "'s self-hosting buildfile."
                    ]
                , principleCard "ε" "Content-addressed"
                    [ text "Every artifact's store path is a hash of its inputs — the closure is the identity, so the same spec always builds the same thing."
                    ]
                , principleCard "ζ" "Small and legible"
                    [ text "Each component fits in your head; none pulls in a framework or heavyweight runtime."
                    ]
                ]
            ]
        ]


principleCard : String -> String -> List (Html Msg) -> Html Msg
principleCard n title bodyChildren =
    div [ class "card" ]
        [ span [ class "n" ] [ text n ]
        , h3 [] [ text title ]
        , p [] bodyChildren
        ]



-- Section: #design


designSection : Html Msg
designSection =
    section [ id "design" ]
        [ div [ class "wrap" ]
            [ h2 [] [ text "The system — read the design" ]
            , div [ class "hint" ] [ text "// apex · spec + builds + store, all Dhall + Datalog + DAFSA" ]
            , p []
                [ text "The org's apex is the "
                , code [] [ text "fixpoint-linux" ]
                , text " distro itself: a self-hosting Linux system whose spec, builds, and store are all Dhall + Datalog + DAFSA — content-addressed by construction."
                ]
            , pre [ class "code" ]
                [ span [ class "c" ] [ text "# build the Dhall interpreter, then the self-hosting build tool" ]
                , text "\n"
                , span [ class "k" ] [ text "$" ]
                , text " "
                , span [ class "g" ] [ text "cd" ]
                , text " dhall-c && make && make test   "
                , span [ class "c" ] [ text "# builds dhall.com (APE) + runs the test suite" ]
                , text "\n"
                , span [ class "k" ] [ text "$" ]
                , text " "
                , span [ class "g" ] [ text "cd" ]
                , text " dhake   && make                "
                , span [ class "c" ] [ text "# self-hosting: builds dhake.com from its Dhakefile.dhall" ]
                ]
            , p []
                [ a [ href "https://github.com/fixpoint-linux/fixpoint-linux/blob/main/DESIGN.md" ]
                    [ text "👉 Read the full architecture design" ]
                ]
            ]
        ]



-- Footer


footerView : Html Msg
footerView =
    footer []
        [ div [ class "wrap" ]
            [ a [ href "https://github.com/fixpoint-linux" ]
                [ text "github.com/fixpoint-linux" ]
            , span [ class "sep" ] [ text " · " ]
            , text "built with ❤️ and a single "
            , code [] [ text "cosmocc" ]
            , text " invocation"
            ]
        ]
