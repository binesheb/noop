import Foundation

/// The small, platform-independent state machine behind charger haptics.
/// Keeping the transition decision pure makes the important behaviour testable without
/// requiring a physical Apple Watch or a simulator battery-state override.
enum WatchChargerConnection: Equatable {
    case unknown
    case disconnected
    case connected
}

enum WatchChargerHaptic: Equatable {
    case connect
    case disconnect
}

enum WatchChargerHapticPolicy {
    /// Returns a haptic only for a real transition after an initial state has been observed.
    /// `.unknown -> connected/disconnected` is intentionally silent so launching NOOP while the
    /// watch is already on its charger does not produce a surprise vibration.
    static func haptic(for previous: WatchChargerConnection,
                       current: WatchChargerConnection) -> WatchChargerHaptic? {
        switch (previous, current) {
        case (.disconnected, .connected): return .connect
        case (.connected, .disconnected): return .disconnect
        default: return nil
        }
    }
}
