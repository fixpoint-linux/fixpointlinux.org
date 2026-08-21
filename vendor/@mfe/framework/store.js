/**
 * @mfe/framework — Shared state store with shallow/immutable diffing.
 *
 * Provides a simple, observable state container for cross-MFE shared state.
 * State is plain data (serializable for SSR).
 */
/**
 * Shallow equality check for objects.
 * Returns true if all top-level keys have the same values (by reference).
 */
function shallowEqual(a, b) {
    if (a === b)
        return true;
    if (typeof a !== 'object' || a === null || typeof b !== 'object' || b === null) {
        return false;
    }
    const keysA = Object.keys(a);
    const keysB = Object.keys(b);
    if (keysA.length !== keysB.length)
        return false;
    for (const key of keysA) {
        if (a[key] !== b[key]) {
            return false;
        }
    }
    return true;
}
/**
 * Create a store with initial state.
 *
 * @example
 * ```ts
 * interface AppState {
 *   basket: Array<{ id: number; quantity: number }>;
 *   user?: { id: string; name: string };
 * }
 *
 * const store = createStore<AppState>({ basket: [] });
 *
 * // Get state
 * const current = store.getState();
 *
 * // Update with partial
 * store.setState({ basket: [{ id: 1, quantity: 5 }] });
 *
 * // Update with updater function
 * store.setState((prev) => ({
 *   ...prev,
 *   basket: [...prev.basket, { id: 2, quantity: 3 }],
 * }));
 *
 * // Subscribe
 * const off = store.subscribe((state) => {
 *   console.log('State changed:', state);
 * });
 *
 * // Unsubscribe
 * off();
 * ```
 */
export function createStore(initial) {
    let state = { ...initial };
    const subscribers = new Set();
    return {
        getState() {
            // Return a shallow copy to prevent mutation of internal state
            return { ...state };
        },
        setState(updater) {
            const newState = typeof updater === 'function'
                ? updater(state)
                : { ...state, ...updater };
            // Only notify if state actually changed
            if (!shallowEqual(state, newState)) {
                state = newState;
                // Notify all subscribers with a copy
                const stateCopy = { ...state };
                for (const listener of subscribers) {
                    listener(stateCopy);
                }
            }
        },
        subscribe(listener) {
            subscribers.add(listener);
            // Immediately notify with current state
            listener({ ...state });
            return () => subscribers.delete(listener);
        },
    };
}
//# sourceMappingURL=store.js.map