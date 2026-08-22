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
  ],
  baseURL: '/shell/templates',
  // The SSG output only pre-renders the home route; a deep link/refresh on a
  // remote route must do a fresh client render instead of rehydrating the
  // pre-rendered home DOM into the wrong route.
  ssr: window.location.pathname === '/',
});

// Expose the app handle so the shell/host can inspect or drive it later.
window.__fixpointApp = app;
