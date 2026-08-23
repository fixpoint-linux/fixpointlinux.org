// shell/shell.js — @mfe/framework thin-shell entry.
//
// Boots a single-route app ('/' -> template 'fixpoint') and mounts the Elm
// landing MFE into the [data-mfe="fixpoint-landing"] slot of that template.
//
// The page ships statically pre-rendered (see scripts/ssg.mjs): the #app root
// carries an `ssr` attribute, so createApp rehydrates the existing DOM in
// place instead of wiping it and re-fetching the template on first paint.

import { createApp } from '@mfe/framework';

const app = await createApp({
  root: document.getElementById('app'),
  routes: [
    { path: '/', template: 'fixpoint', name: 'home' },
    { path: '/dafsa', template: 'dafsa', name: 'dafsa' },
    { path: '/dhake', template: 'dhake', name: 'dhake' },
    { path: '/fxstore', template: 'fxstore', name: 'fxstore' },
    { path: '/datalog-dafsa', template: 'dafsa-landing', name: 'dafsa-landing' },
    { path: '/datalog-dafsa/language', template: 'dafsa-language', name: 'dafsa-language' },
    { path: '/datalog-dafsa/cli', template: 'dafsa-cli', name: 'dafsa-cli' },
    { path: '/datalog-dafsa/api', template: 'dafsa-api', name: 'dafsa-api' },
    { path: '/datalog-dafsa/architecture', template: 'dafsa-architecture', name: 'dafsa-architecture' },
    { path: '/datalog-dafsa/time-travel', template: 'dafsa-time-travel', name: 'dafsa-time-travel' },
    { path: '/datalog-dafsa/vector-search', template: 'dafsa-vector-search', name: 'dafsa-vector-search' },
    { path: '/datalog-dafsa/order-statistics', template: 'dafsa-order-statistics', name: 'dafsa-order-statistics' },
    { path: '/datalog-dafsa/typed-projects', template: 'dafsa-typed-projects', name: 'dafsa-typed-projects' },
    { path: '/datalog-dafsa/playground', template: 'dafsa-playground', name: 'dafsa-playground' },
    { path: '/visage', template: 'visage-landing', name: 'visage-landing' },
    { path: '/visage/compactness', template: 'visage-compactness', name: 'visage-compactness' },
    { path: '/visage/security', template: 'visage-security', name: 'visage-security' },
    { path: '/visage/config', template: 'visage-config', name: 'visage-config' },
    { path: '/visage/cli', template: 'visage-cli', name: 'visage-cli' },
    { path: '/visage/playground', template: 'visage-playground', name: 'visage-playground' },
    { path: '/shen', template: 'shen-landing', name: 'shen-landing' },
    { path: '/shen/architecture', template: 'shen-architecture', name: 'shen-architecture' },
    { path: '/shen/build', template: 'shen-build', name: 'shen-build' },
    { path: '/shen/primitives', template: 'shen-primitives', name: 'shen-primitives' },
    { path: '/shen/playground', template: 'shen-playground', name: 'shen-playground' },
    { path: '/fx-init', template: 'fx-init-landing', name: 'fx-init-landing' },
    { path: '/fx-init/boot', template: 'fx-init-boot', name: 'fx-init-boot' },
    { path: '/fx-init/supervise', template: 'fx-init-supervise', name: 'fx-init-supervise' },
    { path: '/fx-init/activate', template: 'fx-init-activate', name: 'fx-init-activate' },
    { path: '/fx-init/fxctl', template: 'fx-init-fxctl', name: 'fx-init-fxctl' },
    { path: '/fx-init/logs', template: 'fx-init-logs', name: 'fx-init-logs' },
  ],
  baseURL: '/shell/templates',
  // The SSG output only pre-renders the home route; a deep link/refresh on a
  // remote route must do a fresh client render instead of rehydrating the
  // pre-rendered home DOM into the wrong route.
  ssr: window.location.pathname === '/',
});

// Expose the app handle so the shell/host can inspect or drive it later.
window.__fixpointApp = app;

// ---------------------------------------------------------------------------
// fx-init live demo under the hero — embed the terminal MFE from the fx-init
// site (same origin) into the landing page's #fx-demo-mount container.
//
// The demo (deployed at /fx-init/shell/mfe/fx-init-demo.js) is a non-Elm @mfe
// module: its default export implements the @mfe lifecycle, injects its own
// CSS/DOM into the container, and boots the REAL fxstore / fx-activate /
// fxctl / dhall CLIs (compiled to wasm) in an xterm.js terminal.
//
// The container is rendered by the Elm landing MFE — and that MFE is
// re-created on every SPA navigation back to '/' (reconcile mounts a fresh
// Elm render into each new template clone), so a one-shot mount on load would
// leave the demo empty after a round-trip. A MutationObserver on the app root
// re-mounts the demo whenever a fresh, EMPTY #fx-demo-mount appears:
//
//   - an empty container gets the demo mounted into it; a container that
//     already has children holds a live terminal (e.g. after reconcile's
//     update() moved the live Elm subtree for a re-render of the home route)
//     and is left alone;
//   - a per-element in-flight flag closes the await-import window against a
//     double mount (the MFE's own `live` guard only engages after its boot
//     sequence finishes);
//   - every failure is caught and logged: the landing page must keep working
//     even if the demo cannot load.
// ---------------------------------------------------------------------------

const FX_DEMO_MOUNT_ID = 'fx-demo-mount';
const FX_DEMO_MODULE_URL = '/fx-init/shell/mfe/fx-init-demo.js';

// Cached so the demo module is imported at most once per page session.
let fxDemoModulePromise = null;

function loadFxDemoModule() {
  if (!fxDemoModulePromise) {
    fxDemoModulePromise = import(FX_DEMO_MODULE_URL)
      .then((mod) => {
        const mfe = mod.default;
        if (!mfe || typeof mfe.mount !== 'function') {
          throw new Error('fx-init demo module does not export default.mount()');
        }
        return mfe;
      })
      .catch((err) => {
        fxDemoModulePromise = null; // allow a later mount attempt to retry
        throw err;
      });
  }
  return fxDemoModulePromise;
}

function mountFxDemo(element) {
  // Set synchronously — before any await — so observer re-entry during the
  // dynamic import cannot start a second mount on the same element.
  element.__fxDemoMounting = true;
  loadFxDemoModule()
    .then((mfe) => mfe.mount(element))
    .catch((err) => {
      element.__fxDemoMounting = false; // nothing mounted — a retry is safe
      console.error('fx-init demo mount failed:', err);
    });
}

// Mount into #fx-demo-mount if it is present and still empty. Its presence
// implies the home route — only the landing view renders it.
function ensureFxDemoMounted() {
  const el = document.getElementById(FX_DEMO_MOUNT_ID);
  if (!el || el.firstChild || el.__fxDemoMounting) return;
  mountFxDemo(el);
}

// Initial render: createApp has already mounted (SSR rehydrate) or rendered
// the landing MFE, so the container — if this is the home route — is in the
// DOM right now.
ensureFxDemoMounted();

// Later renders: watch the app root for template swaps / re-mounts. childList
// + subtree also fires for the demo's own DOM (xterm churn included); the
// ensureFxDemoMounted check is a cheap id lookup and mounting is guarded per
// element, so the extra callbacks are harmless.
const appRoot = document.getElementById('app');
if (appRoot) {
  new MutationObserver(ensureFxDemoMounted).observe(appRoot, {
    childList: true,
    subtree: true,
  });
}
