/**
 * Create a fresh, empty registry instance. One registry should be created per
 * app shell and passed to {@link reconcile} on every render so that mounted
 * MFE state survives navigation.
 */
export function createRegistry() {
    const map = new Map();
    return {
        get(name) {
            return map.get(name);
        },
        set(entry) {
            map.set(entry.name, entry);
        },
        delete(name) {
            return map.delete(name);
        },
        has(name) {
            return map.has(name);
        },
        names() {
            return [...map.keys()];
        },
        entries() {
            return [...map.values()];
        },
        clear() {
            map.clear();
        },
        get size() {
            return map.size;
        },
    };
}
//# sourceMappingURL=registry.js.map