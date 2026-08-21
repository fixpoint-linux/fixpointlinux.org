# fixpointlinux.org

The landing page for **fixpoint-linux** — a Linux system that is a fixed point.

Built as a **plain Elm app** (`Browser.element`) that is **statically pre-rendered** (SSG) and then
loaded as a **single micro-frontend** by the `@mfe/framework` thin shell. No iframes.

Served by Caddy on `[REDACTED]` from `[REDACTED]`. This repo is the source of record.

- Live: https://fixpointlinux.org
- Orgs: https://github.com/fixpoint-linux

## Architecture

```
index.html                  ← SSG build output (generated; gitignored)
src/Main.elm                ← the Elm Browser.element app (the landing page)
scripts/ssg.mjs             ← SSG: elm make + happy-dom pre-render → index.html
shell/index.html            ← thin shell entry (import map + CSS + slot)
shell/shell.js              ← boots @mfe/framework createApp
shell/templates/fixpoint.html ← route template with the [data-mfe] slot
shell/mfe/fixpoint-landing.js ← the Elm app as an @mfe MFE module (mount/unmount/update)
vendor/@mfe/*               ← vendored @mfe/core + @mfe/framework ESM dist
LEGACY-index.html           ← the original single-file page (content reference)
```

The Elm app renders the full landing page (nav + components dropdown, hero, idea/time/stack/
principles/design sections, footer). At build time `scripts/ssg.mjs` runs the compiled Elm bundle
under happy-dom, serializes the rendered view, and injects it into the shell's `[data-mfe]` slot —
so the page loads with content already present (no-JS / SEO friendly). On the client the shell's
`createApp` rehydrates and the Elm MFE takes over, mounting directly into the slot.

## Build

```sh
npm install          # elm, happy-dom, elm-format, playwright (devDeps)
npm run build        # elm make src/Main.elm --output=dist/elm.js --optimize
                     #   && node scripts/ssg.mjs   (writes index.html)
```

`vendor/@mfe/` is produced by `npm run build` in `~/projects/mfe-framework` and copied here:

```sh
cp ~/projects/mfe-framework/packages/core/dist/*.js      vendor/@mfe/core/
cp ~/projects/mfe-framework/packages/framework/dist/*.js vendor/@mfe/framework/
```

## Deploy

Copy the built bundle to `[REDACTED]` (preserving the `caddy:caddy` owner):

```sh
sudo cp index.html [REDACTED]/
sudo cp -r shell vendor dist [REDACTED]/
sudo chown -R caddy:caddy [REDACTED]
```

Caddy serves everything statically (no Node runtime at request time). URL map:

- `/`                      → shell (import map + `shell.js` bootstraps `createApp`)
- `/shell/mfe/fixpoint-landing.js` + `/vendor/@mfe/*` → the framework + Elm MFE ESM
- `/dist/elm.js`           → the compiled Elm bundle (fetched by the MFE)
