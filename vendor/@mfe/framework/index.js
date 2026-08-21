/**
 * @mfe/framework — Micro-frontend framework layer.
 *
 * Public API:
 *   createRouter    — Native client-side router (replaces `page` npm dep)
 *   createTemplateLoader — Template loader with in-memory cache
 *   createApp       — App shell that wires router → loader → reconcile
 *   createBus       — Typed cross-MFE event bus
 *   createStore     — Shared state store with shallow diffing
 *
 * Types:
 *   Router, CreateRouterOptions, RouterNavigateEvent, Route
 *   TemplateLoader, CreateTemplateLoaderOptions
 *   App, CreateAppOptions, AppRoute
 *   Bus, Store
 */
export { createRouter, } from './router.js';
export { createTemplateLoader, } from './template-loader.js';
export { createApp, } from './app.js';
export { createBus, } from './bus.js';
export { createStore, } from './store.js';
//# sourceMappingURL=index.js.map