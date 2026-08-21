/**
 * @mfe/framework — template loader with in-memory cache.
 *
 * Wraps @mfe/core's loadTemplate with caching and optional baseURL.
 */
import { loadTemplate as coreLoadTemplate } from '@mfe/core';
/**
 * Create a template loader with in-memory caching.
 *
 * Templates are fetched from `${baseURL}/${name}.html` by default.
 * Uses @mfe/core's loadTemplate for parsing HTML strings into Elements.
 */
export function createTemplateLoader(opts = {}) {
    const { baseURL = '', fetchImpl = fetch } = opts;
    const cache = new Map();
    return {
        async load(name) {
            let html = cache.get(name);
            if (!html) {
                let url;
                if (baseURL) {
                    // Join baseURL + name with an explicit slash so the last path segment
                    // of baseURL is kept (plain `new URL(name, base)` would drop it).
                    const joined = `${baseURL.replace(/\/$/, '')}/${name}.html`;
                    url = new URL(joined, window.location.href);
                }
                else {
                    // Default: resolve relative to current location.
                    url = new URL(`${name}.html`, window.location.href);
                }
                const response = await fetchImpl(url.toString());
                if (!response.ok) {
                    throw new Error(`Template loader: failed to fetch template "${name}" from ${url}`);
                }
                html = await response.text();
                cache.set(name, html);
            }
            return coreLoadTemplate(html);
        },
        clearCache() {
            cache.clear();
        },
        preload(name, html) {
            cache.set(name, html);
        },
    };
}
//# sourceMappingURL=template-loader.js.map