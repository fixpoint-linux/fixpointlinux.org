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
    { path: '/dhake', template: 'dhake', name: 'dhake' },
    { path: '/fxstore', template: 'fxstore', name: 'fxstore' },
  ],
  baseURL: '/shell/templates',
  // The SSG output only pre-renders the home route; a deep link/refresh on a
  // remote route must do a fresh client render instead of rehydrating the
  // pre-rendered home DOM into the wrong route.
  ssr: window.location.pathname === '/',
});

// Expose the app handle so the shell/host can inspect or drive it later.
window.__fixpointApp = app;
