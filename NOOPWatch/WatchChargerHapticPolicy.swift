import Foundation

/// The platform-independent transition policy for charger haptics.
///
/// The first observed battery state is intentionally silent. A haptic is emitted only when a known
/// disconnected/connected boundary is crossed, so launching NOOP while the Watch is already charging
/// cannot produce a false "connected" vibration.
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
    static func haptic(for previous: WatchChargerConnection,
                       current: WatchChargerConnection) -> WatchChargerHaptic? {
        switch (previous, current) {
        case (.disconnected, .connected): return .connect
        case (.connected, .disconnected): return .disconnect
        default: return nil
        }
    }
}
