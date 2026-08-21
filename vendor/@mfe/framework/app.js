/**
 * @mfe/framework — app shell layer.
 *
 * Wires together router, template loader, and @mfe/core's reconcile
 * to provide a complete micro-frontend app shell.
 */
import { reconcile, createRegistry } from '@mfe/core';
import { createRouter } from './router.js';
import { createTemplateLoader } from './template-loader.js';
import { createBus } from './bus.js';
import { createStore } from './store.js';
/**
 * Default host implementation with bus and store.
 */
function createDefaultHost(opts = {}) {
    const bus = createBus();
    const store = createStore(opts.initialState ?? {});
    return {
        addHeadTag(node) {
            document.head.appendChild(node);
            return () => {
                document.head.removeChild(node);
            };
        },
        bus,
        store,
    };
}
/**
 * Default module loader using dynamic import.
 * Relies on the browser's import map to resolve module specifiers.
 */
async function defaultImportModule(name) {
    // eslint-disable-next-line @typescript-eslint/no-dynamic-delete
    const module = await import(/* @vite-ignore */ name);
    return module.default || module;
}
/**
 * Normalize a module loader result into an MFE instance. Handles the ESM
 * interop shape where dynamic import resolves to `{ default: mfe }`, whether
 * the loader is the built-in import or a user-supplied one (e.g. a test stub
 * or import-map loader returning `{ default: mfe }`).
 */
function normalizeLoader(loader) {
    const inner = loader ?? defaultImportModule;
    return async (name) => {
        const mod = (await inner(name));
        if (mod && typeof mod === 'object' && 'default' in mod && mod.default) {
            return mod.default;
        }
        return mod;
    };
}
/**
 * Create a micro-frontend app shell.
 *
 * Wires together:
 * - Router: handles navigation and URL matching
 * - Template loader: loads and caches HTML templates
 * - Reconcile: diffs templates and manages MFE lifecycle
 *
 * The app handles SSR rehydration automatically when the root element
 * has an 'ssr' attribute (indicating server-rendered content).
 */
export async function createApp(opts) {
    const { root, routes: routesOrUrl, importModule, loadTemplate: customLoadTemplate, host: customHost, baseURL = '', ssr = true, busEvents, initialState } = opts;
    const loadModule = normalizeLoader(importModule);
    // Create host with bus and store if not provided
    const defaultHost = createDefaultHost({ busEvents, initialState });
    // Ensure host always has bus and store, merging with custom host properties
    const host = {
        ...defaultHost,
        ...(customHost || {}),
        // Ensure bus and store are always present
        bus: defaultHost.bus,
        store: defaultHost.store,
    };
    // Resolve routes (either inline or from URL)
    let routes;
    if (typeof routesOrUrl === 'string') {
        const response = await fetch(routesOrUrl);
        if (!response.ok) {
            throw new Error(`Failed to fetch routes from ${routesOrUrl}`);
        }
        routes = await response.json();
    }
    else {
        routes = routesOrUrl;
    }
    // Create template loader if not provided
    const templateLoader = customLoadTemplate
        ? { load: customLoadTemplate, clearCache: () => { }, preload: () => { } }
        : createTemplateLoader({ baseURL });
    // Create registry for mounted MFEs
    const registry = createRegistry();
    // Track if we're in SSR rehydration mode
    let isSsrMode = ssr && root.hasAttribute('ssr');
    // Create router
    const router = createRouter({
        routes: routes.map((r) => ({ path: r.path, name: r.name })),
        interceptClicks: true,
        // createApp awaits its own initial render below, so the router must not
        // also fire onNavigate at creation (would double-render / race).
        renderOnInit: false,
        onNavigate: async (event) => {
            await renderRoute(event.pathname, event.params);
        },
    });
    // Find the route matching a pathname
    function findRoute(pathname) {
        for (const route of routes) {
            const params = matchPattern(pathname, route.path);
            if (params !== null) {
                return { route, params };
            }
        }
        return null;
    }
    // Render a specific route
    async function renderRoute(pathname, routeParams = {}) {
        const match = findRoute(pathname);
        if (!match) {
            // No route matched - clear the root
            while (root.firstChild) {
                root.removeChild(root.firstChild);
            }
            return;
        }
        const { route, params } = match;
        const mergedParams = { ...routeParams, ...params };
        // Load the template
        const template = await templateLoader.load(route.template);
        // Merge route props with URL params
        const props = { ...route.props, ...mergedParams };
        // For SSR mode, we need to handle rehydration differently
        if (isSsrMode) {
            // In SSR mode, the root already has server-rendered content
            // We need to reconcile against the existing DOM
            await reconcile(root, {
                loadModule,
                host,
                registry,
                onError: (err) => {
                    console.error('Reconciliation error:', err);
                },
            });
            isSsrMode = false; // Only rehydrate once
            return;
        }
        // Clone the template for mutation
        const clone = template.cloneNode(true);
        // Apply props to the template's slots
        const slots = clone.querySelectorAll('[data-mfe]');
        for (const slot of slots) {
            // Merge props into data-mfe-props.
            const existingProps = slot.getAttribute('data-mfe-props');
            const slotProps = existingProps ? JSON.parse(existingProps) : {};
            const merged = { ...slotProps, ...props };
            slot.setAttribute('data-mfe-props', JSON.stringify(merged));
        }
        // Reconcile the new template against the registry
        await reconcile(clone, {
            loadModule,
            host,
            registry,
            onError: (err) => {
                console.error('Reconciliation error:', err);
            },
        });
        // Replace the root content
        while (root.firstChild) {
            root.removeChild(root.firstChild);
        }
        root.appendChild(clone);
    }
    // Initial render — awaited so createApp resolves only after the first route
    // is mounted (the router's renderOnInit is disabled to avoid a double render).
    await renderRoute(window.location.pathname);
    return {
        router,
        templateLoader,
        registry,
        routes,
        bus: host.bus,
        store: host.store,
        navigate(path) {
            router.navigate(path);
        },
        replace(path) {
            router.replace(path);
        },
        async reload() {
            await renderRoute(window.location.pathname);
        },
        destroy() {
            router.destroy();
            registry.clear();
            templateLoader.clearCache();
        },
    };
}
/**
 * Match a pathname against a pattern and extract params.
 * Pattern segments starting with `:` are param placeholders.
 */
function matchPattern(pathname, pattern) {
    const patternParts = pattern.split('/').filter(Boolean);
    const pathParts = pathname.split('/').filter(Boolean);
    if (patternParts.length !== pathParts.length) {
        return null;
    }
    const params = {};
    for (let i = 0; i < patternParts.length; i++) {
        const part = patternParts[i];
        if (part.startsWith(':')) {
            params[part.slice(1)] = pathParts[i];
        }
        else if (part !== pathParts[i]) {
            return null;
        }
    }
    return params;
}
//# sourceMappingURL=app.js.map