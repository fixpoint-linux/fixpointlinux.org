module Main exposing (main)

{-| The fixpoint-linux landing page as a plain `Browser.element` app.

This module renders the _entire_ landing page content (top nav + components
dropdown, hero, and the `#idea` / `#time` / `#stack` / `#principles` /
`#design` sections plus footer) into whatever node it is mounted in, using the
shared `Fixpoint.*` design package (`design/src` is a source-directory in this
application's `elm.json`).

The first child of the view is `Fixpoint.Style.stylesheet`, which emits the
full brand stylesheet as a single `<style>` node. Because the page is
pre-rendered under happy-dom by `scripts/ssg.mjs`, that `<style>` node is
carried into the static HTML — the styling ships with the page instead of
living in the shell's inline stylesheet.

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
import Fixpoint.Card
import Fixpoint.Checks
import Fixpoint.Code
import Fixpoint.Footer
import Fixpoint.Grid
import Fixpoint.Hero
import Fixpoint.Nav
import Fixpoint.Section
import Fixpoint.Style
import Html exposing (Html, a, b, div, em, li, p, pre, span, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (attribute, class, href)


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
        [ Fixpoint.Style.stylesheet
        , navView
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
    Fixpoint.Nav.view
        { brand =
            span []
                [ span [ class "fx" ] [ text "fx" ]
                , text "://fixpoint-linux"
                ]
        , links =
            [ Fixpoint.Nav.link "#idea" "idea"
            , Fixpoint.Nav.link "#time" "time"
            , Fixpoint.Nav.link "#stack" "stack"
            , Fixpoint.Nav.link "#principles" "principles"
            , Fixpoint.Nav.link "#design" "design"
            ]
        , extra =
            [ Fixpoint.Nav.dropdown
                { toggle = "components ▾"
                , items =
                    [ a [ class "ddafsa", href "https://fixpointlinux.org/datalog-dafsa/", attribute "data-mfe-route" "/datalog-dafsa" ]
                        [ text "datalog-dafsa →" ]
                    , a [ class "ddhake", href "https://fixpointlinux.org/dhake/", attribute "data-mfe-route" "/dhake" ]
                        [ text "dhake →" ]
                    , a [ class "dfxstore", href "https://fixpointlinux.org/fxstore/", attribute "data-mfe-route" "/fxstore" ]
                        [ text "fxstore →" ]
                    , a [ class "ddhallc", href "https://fixpointlinux.org/dhall-c/", attribute "data-mfe-route" "/dhall-c" ]
                        [ text "dhall-c →" ]
                    , a [ class "ddafsa", href "https://fixpointlinux.org/dafsa/", attribute "data-mfe-route" "/dafsa" ]
                        [ text "dafsa →" ]
                    , a [ class "dcompendium", href "https://fixpointlinux.org/compendium/", attribute "data-mfe-route" "/compendium" ]
                        [ text "compendium →" ]
                    , a [ class "dvisage", href "https://fixpointlinux.org/visage/", attribute "data-mfe-route" "/visage" ]
                        [ text "visage →" ]
                    , a [ class "dshen", href "https://fixpointlinux.org/shen/", attribute "data-mfe-route" "/shen" ]
                        [ text "shen-meta →" ]
                    , Fixpoint.Nav.menuItem "https://github.com/fixpoint-linux/fixpoint-linux" "fixpoint-linux"
                    ]
                }
            ]
        }



-- Hero


headerView : Html Msg
headerView =
    Fixpoint.Hero.view
        { prompt =
            [ Fixpoint.Hero.hash
            , text " fixpoint-linux "
            , Fixpoint.Hero.dollar
            , text " fx build --self-host"
            , Fixpoint.Hero.blink
            ]
        , title =
            [ text "A Linux system that is "
            , Fixpoint.Hero.fx [ text "a fixed point" ]
            , text "."
            ]
        , tagline =
            [ text "deterministically built, "
            , b [] [ text "from source, by itself" ]
            , text "."
            ]
        }



-- Section: #idea


ideaSection : Html Msg
ideaSection =
    Fixpoint.Section.view
        { id = "idea"
        , title = "The idea"
        , hint = "// least_fixed_point(datalog) + dafsa"
        , children =
            [ p []
                [ Fixpoint.Code.inline "fixpoint-linux"
                , text " is a collection of small, self-contained components written in "
                , b [] [ text "C11" ]
                , text " that assemble into a coherent Linux userspace. Every binary is compiled with "
                , a [ href "https://github.com/jart/cosmopolitan" ] [ Fixpoint.Code.inline "cosmocc" ]
                , text " into a single portable "
                , a [ href "https://justine.lol/ape.html" ] [ Fixpoint.Code.inline "Actually Portable Executable" ]
                , text " (APE) — one file that runs on Linux, macOS, Windows, and the BSDs with "
                , b [] [ text "no VM, no runtime, no interpreter, no dependencies" ]
                , text "."
                ]
            , p []
                [ text "Everything is configured in "
                , a [ href "https://dhall-lang.org/" ] [ Fixpoint.Code.inline "Dhall" ]
                , text ", a strongly-typed, total configuration language. Configs are typechecked, normalized, and "
                , em [] [ text "terminate" ]
                , text " — they are programs, not property files."
                ]
            , p []
                [ text "The name comes from the two ideas at the heart of the stack:" ]
            , Fixpoint.Grid.grid
                [ Fixpoint.Card.view
                    { n = "01"
                    , title = "Fixpoint"
                    , body =
                        [ text "The least-fixed-point semantics of "
                        , a [ href "https://en.wikipedia.org/wiki/Datalog" ] [ text "Datalog" ]
                        , text "; a system is its own build artifact, deterministic and reproducible."
                        ]
                    }
                , Fixpoint.Card.view
                    { n = "02"
                    , title = "DAFSA"
                    , body =
                        [ text "The "
                        , a [ href "https://en.wikipedia.org/wiki/Deterministic_acyclic_finite_state_automaton" ]
                            [ text "minimal acyclic finite-state automaton" ]
                        , text " that backs the data stores: compact, exact, fast."
                        ]
                    }
                ]
            ]
        }



-- Section: #time


timeSection : Html Msg
timeSection =
    Fixpoint.Section.view
        { id = "time"
        , title = "A system that never forgets itself"
        , hint = "// dl_publish_snapshot · dl_snapshot_versions · dl_query_version"
        , children =
            [ p []
                [ Fixpoint.Code.inline "fixpoint-linux"
                , text " is "
                , b [] [ text "content-addressed by construction and time-travelling by default" ]
                , text ". Every change is one atomic snapshot of the whole system; the timeline is the system's complete history. Inspect any past state with an as-of query, roll back to any earlier point, and undo the rollback itself — without ever losing the record of what happened."
                ]
            , timelineBlock
            , Fixpoint.Checks.view
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
                , Fixpoint.Code.inline "datalog-dafsa"
                , text "'s native snapshot time-travel."
                ]
            ]
        }


{-| The `fx status` timeline pre block. There is no shared `Fixpoint` helper
for the `.timeline` block (only `pre.code`), so it stays as hand-written Html
using the `.timeline` classes from `Fixpoint.Style.stylesheet`.
-}
timelineBlock : Html Msg
timelineBlock =
    pre [ class "timeline" ]
        ([ text "$ fx status\n" ]
            ++ timelineLine "v042" "2026-08-18 09:12:41 · activated · ok"
            ++ timelineLine "v041" "2026-08-17 22:04:09 · activated · ok"
            ++ timelineLine "v040" "2026-08-17 18:55:31 · rolled-forward to v042"
            ++ timelineLine "v039" "2026-08-16 11:02:17 · activated · ok"
            ++ [ text "...\n$ fx rollback v039   "
               , span [ class "dim" ] [ text "# record it as history, always undoable" ]
               ]
        )


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
    Fixpoint.Section.view
        { id = "stack"
        , title = "The stack"
        , hint = "// self-contained · portable · reproducible"
        , children =
            [ table [ class "stack" ]
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
                        , Fixpoint.Code.inline "typecheck"
                        , text ", "
                        , Fixpoint.Code.inline "normalize"
                        , text ", "
                        , Fixpoint.Code.inline "to-json"
                        , text "/"
                        , Fixpoint.Code.inline "toml"
                        , text "/"
                        , Fixpoint.Code.inline "yaml"
                        , text ". The typed-config foundation everything builds on. "
                        , a [ href "https://fixpointlinux.org/dhall-c/", attribute "data-mfe-route" "/dhall-c" ] [ text "Docs →" ]
                        ]
                    , stackRow "datalog-dafsa"
                        "https://github.com/fixpoint-linux/datalog-dafsa"
                        [ text "A DAFSA-backed Datalog engine in C. Facts into an on-disk minimal-acyclic-DAFSA store, rules to a small VM, reads from an mmap'd snapshot. "
                        , b [] [ text "Native time travel" ]
                        , text " — immutable versioned snapshots and as-of queries as a first-class feature. "
                        , a [ href "https://fixpointlinux.org/datalog-dafsa/", attribute "data-mfe-route" "/datalog-dafsa" ] [ text "Docs →" ]
                        ]
                    , stackRow "dhake"
                        "https://github.com/fixpoint-linux/dhake"
                        [ text "A Make-like build tool whose buildfile is a Dhall program ("
                        , Fixpoint.Code.inline "Dhakefile.dhall"
                        , text "). Typed actions, incremental checks, phony targets, "
                        , Fixpoint.Code.inline "-j"
                        , text " parallel builds. "
                        , b [] [ text "Self-hosting" ]
                        , text " — it builds itself. "
                        , a [ href "https://fixpointlinux.org/dhake/" ] [ text "Docs →" ]
                        ]
                    , stackRow "fxstore"
                        "https://github.com/fixpoint-linux/fxstore"
                        [ b [] [ text "content-addressed build store" ]
                        , text " — reads a Dhall package set, computes the dependency closure as a least fixed point with "
                        , Fixpoint.Code.inline "datalog-dafsa"
                        , text ", and builds each package's typed recipe into "
                        , Fixpoint.Code.inline "/fx/store/<hash>-<name>"
                        , text ". Crash-consistent, bwrap-sandboxed. "
                        , a [ href "https://fixpointlinux.org/fxstore/" ] [ text "Docs →" ]
                        ]
                    , stackRow "compendium"
                        "https://github.com/fixpoint-linux/compendium"
                        [ text "A small, self-contained authoritative DNS server (UDP, RFC 1035), configured in Dhall, shipped as a single APE binary. "
                        , a [ href "https://fixpointlinux.org/compendium/", attribute "data-mfe-route" "/compendium" ] [ text "Docs →" ]
                        ]
                    , stackRow "visage"
                        "https://github.com/fixpoint-linux/visage"
                        [ text "A compact email alias & forwarding server — disposable "
                        , Fixpoint.Code.inline "alias@domain"
                        , text " addresses backed by a DAFSA store. Daemon and store in one small APE binary. "
                        , a [ href "https://fixpointlinux.org/visage/", attribute "data-mfe-route" "/visage" ] [ text "Docs →" ]
                        ]
                    , stackRow "dafsa"
                        "https://github.com/fixpoint-linux/dafsa"
                        [ text "The Carrasco–Forcada incremental DAFSA — minimal automaton with add/delete/lookup, persistence and DOT export. "
                        , a [ href "https://fixpointlinux.org/dafsa/", attribute "data-mfe-route" "/dafsa" ] [ text "Docs →" ]
                        ]
                    , stackRow "shen-meta"
                        "https://github.com/fixpoint-linux/shen-meta"
                        [ text "A self-hosted Shen implementation — a "
                        , b [] [ text "sequent-calculus Lisp" ]
                        , text ". Evaluates itself, compiles itself to native bytecode, runs on a native C VM with a custom GC."
                        , a [ href "https://fixpointlinux.org/shen/", attribute "data-mfe-route" "/shen" ] [ text "Docs →" ]
                        ]
                    ]
                ]
            ]
        }


{-| One row of the stack table: the monospace name link + the description cell.
There is no shared `Fixpoint` helper for the `.stack` table, so it stays as
hand-written Html using the `.stack` classes from `Fixpoint.Style.stylesheet`.
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
    Fixpoint.Section.view
        { id = "principles"
        , title = "Design principles"
        , hint = "// ethos"
        , children =
            [ Fixpoint.Grid.grid
                [ Fixpoint.Card.view
                    { n = "α"
                    , title = "One binary, zero deps"
                    , body = [ text "Cosmocc + APE means each tool is self-contained and portable across OSes." ]
                    }
                , Fixpoint.Card.view
                    { n = "β"
                    , title = "Config is typed code"
                    , body = [ text "Dhall gives typechecking, imports, and reusable functions — and it always terminates." ]
                    }
                , Fixpoint.Card.view
                    { n = "γ"
                    , title = "Logic is declarative"
                    , body = [ text "Datalog + DAFSA keep the data plane compact and exact." ]
                    }
                , Fixpoint.Card.view
                    { n = "δ"
                    , title = "Self-hosting"
                    , body =
                        [ text "Tools build themselves — see "
                        , Fixpoint.Code.inline "dhake"
                        , text "'s self-hosting buildfile."
                        ]
                    }
                , Fixpoint.Card.view
                    { n = "ε"
                    , title = "Content-addressed"
                    , body = [ text "Every artifact's store path is a hash of its inputs — the closure is the identity, so the same spec always builds the same thing." ]
                    }
                , Fixpoint.Card.view
                    { n = "ζ"
                    , title = "Small and legible"
                    , body = [ text "Each component fits in your head; none pulls in a framework or heavyweight runtime." ]
                    }
                ]
            ]
        }



-- Section: #design


designSection : Html Msg
designSection =
    Fixpoint.Section.view
        { id = "design"
        , title = "The system — read the design"
        , hint = "// apex · spec + builds + store, all Dhall + Datalog + DAFSA"
        , children =
            [ p []
                [ text "The org's apex is the "
                , Fixpoint.Code.inline "fixpoint-linux"
                , text " distro itself: a self-hosting Linux system whose spec, builds, and store are all Dhall + Datalog + DAFSA — content-addressed by construction."
                ]
            , Fixpoint.Code.block
                [ Fixpoint.Code.c "# build the Dhall interpreter, then the self-hosting build tool"
                , text "\n"
                , Fixpoint.Code.k "$"
                , text " "
                , Fixpoint.Code.g "cd"
                , text " dhall-c && make && make test   "
                , Fixpoint.Code.c "# builds dhall.com (APE) + runs the test suite"
                , text "\n"
                , Fixpoint.Code.k "$"
                , text " "
                , Fixpoint.Code.g "cd"
                , text " dhake   && make                "
                , Fixpoint.Code.c "# self-hosting: builds dhake.com from its Dhakefile.dhall"
                ]
            , p []
                [ a [ href "https://github.com/fixpoint-linux/fixpoint-linux/blob/main/DESIGN.md" ]
                    [ text "👉 Read the full architecture design" ]
                ]
            ]
        }



-- Footer


footerView : Html Msg
footerView =
    Fixpoint.Footer.view
        [ a [ href "https://github.com/fixpoint-linux" ]
            [ text "github.com/fixpoint-linux" ]
        , Fixpoint.Footer.sep
        , text "built with ❤️ and a single "
        , Fixpoint.Code.inline "cosmocc"
        , text " invocation"
        ]
