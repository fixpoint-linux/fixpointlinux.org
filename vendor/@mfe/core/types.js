/**
 * @mfe/core — public types shared across the framework.
 *
 * These types define the *contract* between an app (which owns the page
 * shell, the router and the template sources) and a micro-frontend module
 * (a single `data-mfe` slot implementation).
 *
 * @mfe/core itself is app-agnostic: it never fetches templates, never
 * imports MFE modules, and never touches a specific host. All of that is
 * injected through `reconcile`'s options (see reconcile.ts).
 */
export {};
//# sourceMappingURL=types.js.map