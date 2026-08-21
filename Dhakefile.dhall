-- Dhakefile.dhall — build the fixpointlinux.org static site with dhake.
--
-- The site is an Elm app (src/Main.elm) rendered against the shared
-- Fixpoint.* design package (the `design` submodule) plus the mfe-framework
-- (the `mfe-framework` submodule).  The pipeline:
--
--    1. build mfe-framework (tsc) -> its dist JS
--    2. copy mfe-framework dist JS into vendor/@mfe/  (served here)
--    3. elm make src/Main.elm -> dist/elm.js
--    4. node scripts/ssg.mjs   -> index.html  (SSG render of the landing MFE)
--
-- Run with:  ./dhake/dhake.com        (or any dhake binary: `dhake`)
-- Target `index.html` is the default (the deploy unit's main artifact).

let Action =
      < Shell : Text
      | Copy : { from : Text, to : Text }
      | Mkdir : Text
      | Rm : Text
      | Touch : Text
      | Move : { from : Text, to : Text }
      | Symlink : { from : Text, to : Text }
      | Chmod : { path : Text, mode : Text }
      | Echo : Text
      | Env : { key : Text, value : Text }
      | Run : { argv : List Text }
      >

let Target = { deps : List Text, phony : Bool, recipe : List Action }

-- mfe-framework submodule source that, when touched, forces a rebuild.
-- phony: the mfe-framework build is a plain `npm ci && npm run build`; its
-- outputs live inside the submodule (packages/*/dist), not at a stable
-- top-level path, so treat it as always-rebuild (like the old npm one-liner).
let mfe = "mfe-framework"

in  { targets =
        [ { mapKey = "mfe-framework"
          , mapValue =
              { deps = []
              , phony = True
              , recipe =
                  [ < Shell = "cd mfe-framework && npm ci && npm run build" >
                  ]
              }
          }
        , { mapKey = "vendor-mfe"
          , mapValue =
              { deps = [ "mfe-framework" ]
              , phony = True
              , recipe =
                  -- dhake.com is a cosmopolitan APE: its system() uses a
                  -- restricted mini-shell whose builtin `rm` lacks -r (and
                  -- the Rm action is remove(3), non-recursive). Use the real
                  -- GNU rm by absolute path to clear the populated tree.
                  [ < Shell = "/bin/rm -rf vendor/@mfe" >
                  , < Mkdir = "vendor/@mfe" >
                  , < Mkdir = "vendor/@mfe/core" >
                  , < Mkdir = "vendor/@mfe/framework" >
                  , < Shell =
                        "cp mfe-framework/packages/core/dist/*.js vendor/@mfe/core/"
                    >
                  , < Shell =
                        "cp mfe-framework/packages/framework/dist/*.js vendor/@mfe/framework/"
                    >
                  ]
              }
          }
        , { mapKey = "dist/elm.js"
          , mapValue =
              { deps = [ "src/Main.elm", "elm.json", "design/src" ]
              , phony = False
              , recipe =
                  -- elm is a vendored ELF at node_modules/elm/bin/elm; npm's
                  -- script runner injects node_modules/.bin onto PATH, but a
                  -- plain dhake Shell action does not, so use the real path.
                  [ < Shell =
                        "node_modules/elm/bin/elm make src/Main.elm --output=dist/elm.js --optimize"
                    >
                  ]
              }
          }
        , { mapKey = "index.html"
          , mapValue =
              { deps =
                  [ "dist/elm.js"
                  , "vendor-mfe"
                  , "shell/index.html"
                  , "scripts/ssg.mjs"
                  ]
              , phony = False
              , recipe = [ < Shell = "node scripts/ssg.mjs" > ]
              }
          }
        ]
      , default = "index.html"
      }
