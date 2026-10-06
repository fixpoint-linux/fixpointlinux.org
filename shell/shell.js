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


// --- hero live demo: click-to-boot -----------------------------------------
//
// The panel this wires up is pre-rendered from `demoPanel` in src/Main.elm:
// an explanation plus a boot link that is readable (and usable, as a plain
// navigation to the demo) with no JavaScript at all. Nothing here fetches the
// demo's assets — creating the <iframe> is what pulls in the kernel, initrd
// and emulator (~3.7 MB), so it happens only on click.
const DEMO_URL = '/fx-demo/';

// Held in a module variable rather than on the DOM: the Elm MFE clears and
// re-renders the pre-rendered markup during rehydration, so a click that lands
// before that swap must still end with a frame in the *new* panel.
let demoBooted = false;

function bootDemo() {
  demoBooted = true;
  ensureDemoFrame();
}

/**
 * Make the panel show the demo, idempotently: add the booting state, then the
 * frame + iframe for /fx-demo/ if they are not already there.
 */
function ensureDemoFrame() {
  if (!demoBooted) return;
  const stage = document.querySelector('[data-fx-demo]');
  if (!stage) return;
  stage.classList.add('is-booting');

  let frame = stage.querySelector('[data-fx-demo-frame]');
  if (frame && frame.querySelector('iframe')) return; // already live

  const status = stage.querySelector('[data-fx-demo-status]');
  if (status) {
    status.textContent = 'booting… fetching the kernel, initrd and emulator (~3.7 MB)';
  }

  if (!frame) {
    frame = document.createElement('div');
    frame.className = 'fx-demo-frame';
    frame.setAttribute('data-fx-demo-frame', '');
    stage.appendChild(frame);
  }

  const iframe = document.createElement('iframe');
  iframe.title = 'fixpoint-linux running in the browser (v86 / WebAssembly)';
  iframe.src = DEMO_URL;
  // Deliberately NOT sandboxed: the demo is same-origin, and its terminal
  // needs real keyboard focus plus its own WASM/asset fetches.
  iframe.addEventListener('load', () => {
    if (status) {
      status.textContent =
        'guest booting — click the terminal and type at the fx> prompt';
    }
  });
  frame.appendChild(iframe);
}

// Delegated from the document so the handler survives the Elm MFE's
// client-side re-render of the pre-rendered markup.
document.addEventListener('click', (event) => {
  const boot = event.target.closest && event.target.closest('[data-fx-boot]');
  if (!boot) return;
  // The href stays as the no-JS / plain-navigation fallback.
  event.preventDefault();
  bootDemo();
});

// createApp awaits its own first mount, so the Elm MFE has already replaced
// the pre-rendered panel by this point — re-assert a boot that raced the swap
// (and stay a no-op when nothing was clicked).
ensureDemoFrame();
