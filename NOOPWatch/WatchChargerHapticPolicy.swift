import Foundation

/// Reduces two observed charger states to an optional haptic transition.
///
/// The first observed state is represented by `.unknown` and intentionally produces no haptic. Keeping
/// this decision independent of WatchKit makes the transition rules small and deterministic.
enum WatchChargerConnection: Equatable, Sendable {
    case unknown
    case disconnected
    case connected
}

enum WatchChargerHaptic: Equatable, Sendable {
    case connect
    case disconnect
}

enum WatchChargerHapticPolicy {
    static func haptic(for previous: WatchChargerConnection,
                       current: WatchChargerConnection) -> WatchChargerHaptic? {
        switch (previous, current) {
        case (.disconnected, .connected): return .connect
        case (.connected, .disconnected): return .disconnect
        default: return nil
        }
    }
}
