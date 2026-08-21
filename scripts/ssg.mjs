#!/usr/bin/env node
/**
 * scripts/ssg.mjs — static-site-generator build step for the fixpoint-linux
 * landing page.
 *
 * Pipeline:
 *
 *   1.  Expects the Elm app already compiled to `dist/elm.js`:
 *         elm make src/Main.elm --output=dist/elm.js --optimize
 *   2.  Boots a happy-dom `Window`, installs its browser globals onto
 *       globalThis (via `defineProperty`, so getter-only globals like
 *       `navigator` / `location` can be overridden), then loads the compiled
 *       Elm bundle with an *indirect eval* `(0, eval)(code)` — the bundle is a
 *       classic IIFE whose `this` binds to globalThis, so `Elm` lands on
 *       `globalThis.Elm` (exactly the seam the probe validated).
 *   3.  Creates a detached root `<div>`, calls `Elm.Main.init({ node })`, waits
 *       a couple of macrotask ticks for the initial render to flush, and reads
 *       back `node.innerHTML` — the pre-rendered landing markup.
 *   4.  Reads `shell/index.html` (the shell SSG template), injects the
 *       rendered markup into its `[data-mfe="fixpoint-landing"]` slot, and
 *       writes the final `index.html`.
 *
 * The output page loads with content already present (no-JS / SEO) and the Elm
 * MFE takes over client-side via the shell's `ssr` rehydration. Fits Caddy's
 * static hosting — no Node server at request time.
 *
 * Run from the repo root:
 *   node scripts/ssg.mjs
 */

import { readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { Window } from 'happy-dom';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, '..');
const DIST = join(ROOT, 'dist');
const ELM_BUNDLE = join(DIST, 'elm.js');
const SHELL_TEMPLATE = join(ROOT, 'shell', 'index.html');
const OUTPUT = join(ROOT, 'index.html');

const SLOT_SELECTOR = '[data-mfe="fixpoint-landing"]';

function log(msg) {
  console.log(`[ssg] ${msg}`);
}

/**
 * Install happy-dom's window-backed values onto globalThis so the compiled Elm
 * bundle and its runtime see a browser-shaped global object.
 *
 * `navigator` and `location` already exist on Node's globalThis as getter-only
 * properties, so they cannot be plain-assigned — `defineProperty` with
 * `configurable: true` replaces them. The remaining names either don't exist
 * in Node or are harmless to shadow, so the same call is used uniformly.
 */
function installGlobals(window) {
  const globals = [
    'window',
    'document',
    'navigator',
    'location',
    'history',
    'customElements',
    'performance',
    'requestAnimationFrame',
    'cancelAnimationFrame',
    'HTMLElement',
    'HTMLDivElement',
    'HTMLSpanElement',
    'HTMLAnchorElement',
    'HTMLButtonElement',
    'HTMLTableElement',
    'Element',
    'Node',
    'Document',
    'DocumentFragment',
    'Text',
    'Comment',
    'NodeList',
    'HTMLCollection',
    'Event',
    'CustomEvent',
    'MouseEvent',
    'KeyboardEvent',
    'UIEvent',
    'EventTarget',
    'MutationObserver',
    'getComputedStyle',
    'matchMedia',
  ];
  for (const name of globals) {
    const value = window[name];
    if (value === undefined) continue;
    Object.defineProperty(globalThis, name, {
      value,
      configurable: true,
      writable: true,
    });
  }
}

/**
 * Load the compiled Elm bundle, mount it into a fresh container and return the
 * pre-rendered HTML of the landing page.
 */
async function renderLanding(window) {
  const code = readFileSync(ELM_BUNDLE, 'utf8');
  // eslint-disable-next-line no-eval -- indirect eval runs in global scope, so
  // the bundle's IIFE `(this)` binds to globalThis and defines globalThis.Elm.
  (0, eval)(code);

  const Elm = globalThis.Elm;
  if (!Elm || !Elm.Main || typeof Elm.Main.init !== 'function') {
    throw new Error('dist/elm.js did not expose Elm.Main.init on globalThis');
  }

  const root = window.document.createElement('div');
  root.setAttribute('id', 'landing-root');
  window.document.body.appendChild(root);

  Elm.Main.init({ node: root });

  // Let Elm's initial render flush. Browser.element schedules its first paint
  // through the virtual DOM, which Elm drives with requestAnimationFrame /
  // macrotasks. Flushing happy-dom's async task manager covers both; fall back
  // to a couple of macrotask ticks for robustness on any happy-dom version.
  const flush = window.happyDOM && typeof window.happyDOM.whenAsyncComplete === 'function'
    ? () => window.happyDOM.whenAsyncComplete()
    : () => new Promise((resolve) => setTimeout(resolve, 0));
  await flush();
  await flush();

  return root.innerHTML;
}

/**
 * Inject the pre-rendered landing markup into the shell template's slot and
 * return the final, complete HTML document.
 */
function injectRendered(shellHtml, rendered) {
  const win = new Window();
  const doc = win.document;
  doc.write(shellHtml);
  doc.close();

  const slot = doc.querySelector(SLOT_SELECTOR);
  if (!slot) {
    throw new Error(
      `shell/index.html has no ${SLOT_SELECTOR} element to inject the rendered landing into`,
    );
  }
  slot.innerHTML = rendered;

  return `<!DOCTYPE html>\n${doc.documentElement.outerHTML}\n`;
}

async function main() {
  if (!existsSync(ELM_BUNDLE)) {
    console.error(
      `[ssg] missing ${ELM_BUNDLE}. Build it first:\n` +
        '  elm make src/Main.elm --output=dist/elm.js --optimize',
    );
    process.exit(1);
  }

  const window = new Window();
  installGlobals(window);

  log('rendering Elm landing under happy-dom …');
  const rendered = await renderLanding(window);
  log(`rendered ${rendered.length} bytes of landing markup`);

  const shellHtml = readFileSync(SHELL_TEMPLATE, 'utf8');
  const finalHtml = injectRendered(shellHtml, rendered);

  mkdirSync(DIST, { recursive: true });
  writeFileSync(OUTPUT, finalHtml);
  log(`wrote ${OUTPUT} (${finalHtml.length} bytes)`);
}

main().catch((err) => {
  console.error('[ssg] failed:', err);
  process.exit(1);
});
