/**
 * @mfe/framework — Typed cross-MFE event bus.
 *
 * Provides a type-safe publish/subscribe mechanism for cross-MFE communication.
 * Events are plain data (serializable for SSR).
 */
/**
 * Create a typed event bus.
 *
 * @example
 * ```ts
 * interface AppEvents {
 *   'basket:updated': { id: number; quantity: number };
 *   'user:login': { userId: string };
 * }
 *
 * const bus = createBus<AppEvents>();
 *
 * // Subscribe
 * const off = bus.on('basket:updated', (payload) => {
 *   console.log('Basket updated:', payload.id, payload.quantity);
 * });
 *
 * // Emit
 * bus.emit('basket:updated', { id: 1, quantity: 5 });
 *
 * // Unsubscribe
 * off();
 * ```
 */
export function createBus() {
    const listeners = new Map();
    return {
        on(type, listener) {
            if (!listeners.has(type)) {
                listeners.set(type, new Set());
            }
            listeners.get(type).add(listener);
            return () => this.off(type, listener);
        },
        off(type, listener) {
            const typeListeners = listeners.get(type);
            if (typeListeners) {
                typeListeners.delete(listener);
            }
        },
        once(type, listener) {
            const wrapped = (payload) => {
                listener(payload);
                this.off(type, wrapped);
            };
            return this.on(type, wrapped);
        },
        emit(type, payload) {
            const typeListeners = listeners.get(type);
            if (typeListeners) {
                // Create a copy to avoid issues if listeners are added/removed during iteration
                const listenersCopy = new Set(typeListeners);
                for (const listener of listenersCopy) {
                    listener?.(payload);
                }
            }
        },
    };
}
//# sourceMappingURL=bus.js.map