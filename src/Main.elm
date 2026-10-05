module Main exposing (main)

{-| The fixpoint-linux landing page as a plain `Browser.element` app.

This module renders the _entire_ landing page content — a single-purpose
QEMU quickstart: nav, hero, and the `#get` / `#boot` / `#inside` / `#build`
sections plus footer — into whatever node it is mounted in, using the shared
`Fixpoint.*` design package (`design/src` is a source-directory in this
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
interactivity: everything that looks interactive (the blinking cursor) is pure
CSS. Keeping it this simple makes the SSR seam trivial and robust.

-}

import Browser
import Fixpoint.Callout
import Fixpoint.Card
import Fixpoint.Code
import Fixpoint.Footer
import Fixpoint.Grid
import Fixpoint.Hero
import Fixpoint.Nav
import Fixpoint.Section
import Fixpoint.Style
import Html exposing (Html, a, b, div, em, p, span, text)
import Html.Attributes exposing (class, href)


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
        , getSection
        , bootSection
        , insideSection
        , buildSection
        , footerView
        ]



-- Top nav (brand + anchor links + the org `home` link)


navView : Html Msg
navView =
    Fixpoint.Nav.view
        { brand =
            span []
                [ span [ class "fx" ] [ text "fx" ]
                , text "://fixpoint-linux"
                ]
        , links =
            [ Fixpoint.Nav.link "#get" "get"
            , Fixpoint.Nav.link "#boot" "boot"
            , Fixpoint.Nav.link "#inside" "inside"
            , Fixpoint.Nav.link "#build" "build"
            ]
        , extra =
            [ Fixpoint.Nav.homeLink
                "https://github.com/fixpoint-linux/fixpoint-linux"
                "home"
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
            , text " qemu-system-x86_64 -drive file=fixpoint.raw"
            , Fixpoint.Hero.blink
            ]
        , title =
            [ text "Boot "
            , Fixpoint.Hero.fx [ text "fixpoint-linux" ]
            , text " — land in the shell."
            ]
        , tagline =
            [ text "one download, one command — "
            , b [] [ text "from zero to a booting system" ]
            , text "."
            ]
        }



-- Section: #get


getSection : Html Msg
getSection =
    Fixpoint.Section.view
        { id = "get"
        , title = "Get the image"
        , hint = "// curl · gunzip · sha256sum"
        , children =
            [ getCommands
            , p []
                [ text "That is a 128 MiB raw disk image (the download is ~32.5 MB gzipped). The partition is blank until first boot — see "
                , a [ href "#inside" ] [ text "what just happened" ]
                , text ". The release lives at "
                , a [ href "https://github.com/fixpoint-linux/fx-init/releases/tag/image-m2" ]
                    [ text "fx-init · image-m2" ]
                , text "."
                ]
            , shaBlock
            ]
        }


{-| The download + gunzip block.
-}
getCommands : Html Msg
getCommands =
    Fixpoint.Code.block
        [ Fixpoint.Code.k "$"
        , text " "
        , Fixpoint.Code.g "curl"
        , text " -fL -o fixpoint.raw.gz \\\n"
        , text "  https://github.com/fixpoint-linux/fx-init/releases/download/image-m2/fixpoint-m2-x86_64.raw.gz\n"
        , Fixpoint.Code.k "$"
        , text " "
        , Fixpoint.Code.g "gunzip"
        , text " fixpoint.raw.gz"
        ]


{-| The checksum block: the uncompressed image's sha256.
-}
shaBlock : Html Msg
shaBlock =
    Fixpoint.Code.block
        [ Fixpoint.Code.k "$"
        , text " "
        , Fixpoint.Code.g "sha256sum"
        , text " fixpoint.raw\n"
        , text "1dea1346530d2c85b784d20ba49540779bd8f4fccd656ba428c01e49c4eed66e  fixpoint.raw"
        ]



-- Section: #boot


bootSection : Html Msg
bootSection =
    Fixpoint.Section.view
        { id = "boot"
        , title = "Boot it"
        , hint = "// qemu-system-x86_64 · serial console · virtio"
        , children =
            [ p []
                [ text "Boot the image under QEMU, with the serial console attached."
                ]
            , qemuBlock
            , Fixpoint.Callout.warn
                [ text "You need "
                , Fixpoint.Code.inline "qemu-system-x86_64"
                , text " plus hardware virtualization ("
                , Fixpoint.Code.inline "/dev/kvm"
                , text ") — the image is x86_64 and boots under "
                , Fixpoint.Code.inline "-accel kvm"
                , text "."
                ]
            , Fixpoint.Callout.note
                [ text "Leave QEMU with "
                , Fixpoint.Code.inline "Ctrl-A X"
                , text "."
                ]
            , p []
                [ text "The serial console ends at an interactive prompt — you land in the fixpoint shell:"
                ]
            , transcriptBlock
            ]
        }


{-| The QEMU command block.
-}
qemuBlock : Html Msg
qemuBlock =
    Fixpoint.Code.block
        [ Fixpoint.Code.k "$"
        , text " "
        , Fixpoint.Code.g "qemu-system-x86_64"
        , text " -machine q35 -accel kvm -cpu host -m 2048 -nographic \\\n"
        , text "  -drive file=fixpoint.raw,format=raw,if=virtio"
        ]


{-| The boot transcript: the lines the serial console actually ends with
(SeaBIOS, the kernel banner, fx-init's handover, then the `fxsh` prompt).
-}
transcriptBlock : Html Msg
transcriptBlock =
    Fixpoint.Code.block
        [ text "SeaBIOS ...\n"
        , text "Linux version 6.12.19 ...\n"
        , Fixpoint.Code.c "...\n"
        , text "Run /fx/store/<hash>-fx-init/fx-init as init process\n"
        , text "fx-init: disk store mounted (current v3)\n"
        , text "fx-init: pivoted to tmpfs root (magic 0x1021994)\n"
        , Fixpoint.Code.g "fx-init: boot-ok v3"
        , text "\n"
        , Fixpoint.Code.g "fx>"
        ]



-- Section: #inside


insideSection : Html Msg
insideSection =
    Fixpoint.Section.view
        { id = "inside"
        , title = "What just happened"
        , hint = "// fx-init · dhake · datalog"
        , children =
            [ Fixpoint.Grid.grid
                [ Fixpoint.Card.view
                    { n = "01"
                    , title = "fx-init is PID1"
                    , body =
                        [ Fixpoint.Code.inline "fx-init"
                        , text " reads the current store generation, materializes the rootfs with "
                        , Fixpoint.Code.inline "dhake"
                        , text ", supervises services, and maintains a live Datalog DB — the sole writer of runtime state. The prompt it hands you is "
                        , Fixpoint.Code.inline "fxsh"
                        , text ", fx-core's own shell — the real "
                        , Fixpoint.Code.inline "fx-*"
                        , text " commands from the image ("
                        , Fixpoint.Code.inline "fx-seq 1 5 | fx-sort -r"
                        , text ", "
                        , Fixpoint.Code.inline "fx-cat /etc/hostname"
                        , text ")."
                        ]
                    }
                , Fixpoint.Card.view
                    { n = "02"
                    , title = "A content-addressed store"
                    , body =
                        [ text "A Dhall config activates to a generation; each generation is one atomic snapshot of the whole system."
                        ]
                    }
                , Fixpoint.Card.view
                    { n = "03"
                    , title = "Time travel"
                    , body =
                        [ text "The timeline is the system's complete history; a rollback is recorded as history and is itself undoable."
                        ]
                    }
                , Fixpoint.Card.view
                    { n = "04"
                    , title = "First boot formats"
                    , body =
                        [ text "The image ships a blank primary partition, formatted by the guest on first boot."
                        ]
                    }
                ]
            , Fixpoint.Callout.note
                [ text "This is an early milestone: it boots and lands you at a prompt — "
                , em [] [ text "not yet a general-purpose desktop." ]
                ]
            ]
        }



-- Section: #build


buildSection : Html Msg
buildSection =
    Fixpoint.Section.view
        { id = "build"
        , title = "Build it yourself"
        , hint = "// fx-init · zig · dhall"
        , children =
            [ p []
                [ text "The same image can be built from source instead of downloaded."
                ]
            , buildBlock
            , p []
                [ text "The result is the same "
                , Fixpoint.Code.inline "fixpoint.raw"
                , text " — boot it with the same "
                , a [ href "#boot" ] [ text "QEMU command above" ]
                , text "."
                ]
            ]
        }


{-| The source-build block: clone fx-init (with submodules), build the image
tool, and assemble the image from its Dhall config / package set / kernel pin.
-}
buildBlock : Html Msg
buildBlock =
    Fixpoint.Code.block
        [ Fixpoint.Code.k "$"
        , text " "
        , Fixpoint.Code.g "git"
        , text " clone https://github.com/fixpoint-linux/fx-init && "
        , Fixpoint.Code.g "cd"
        , text " fx-init\n"
        , Fixpoint.Code.k "$"
        , text " "
        , Fixpoint.Code.g "git"
        , text " submodule update --init --recursive\n"
        , Fixpoint.Code.k "$"
        , text " ("
        , Fixpoint.Code.g "cd"
        , text " zig && "
        , Fixpoint.Code.g "zig"
        , text " build -Doptimize=ReleaseSafe)\n"
        , Fixpoint.Code.k "$"
        , text " ./zig/zig-out/bin/fx-image \\\n"
        , text "  --config m3/config-console.dhall \\\n"
        , text "  --package-set m3/package-set.dhall \\\n"
        , text "  --pin scripts/kernel-pin.txt \\\n"
        , text "  --out fixpoint.raw"
        ]



-- Footer


footerView : Html Msg
footerView =
    Fixpoint.Footer.view
        [ a [ href "https://github.com/fixpoint-linux" ]
            [ text "github.com/fixpoint-linux" ]
        , Fixpoint.Footer.sep
        , text "a fixed point, built from source, by itself"
        ]
