import WatchKit

/// Observes the Watch's charging state and gives a short haptic when the charger is connected/disconnected.
///
/// Battery monitoring is enabled before the first state read. The first state is seeded silently so an
/// already-charging Watch does not look like a new connection. Subsequent state changes are reduced to the
/// pure policy in `WatchChargerHapticPolicy` before touching the haptic engine.
final class WatchChargerHaptics {
    private let device: WKInterfaceDevice
    private var previousState: WatchChargerConnection = .unknown
    private var observer: NSObjectProtocol?

    init(device: WKInterfaceDevice = .current()) {
        self.device = device
        start()
    }

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func start() {
        device.isBatteryMonitoringEnabled = true
        previousState = connection(for: device.batteryState)

        observer = NotificationCenter.default.addObserver(
            forName: WKInterfaceDevice.batteryStateDidChangeNotification,
            object: device,
            queue: .main,
        ) { [weak self] _ in
            self?.batteryStateChanged()
        }
    }

    private func batteryStateChanged() {
        let current = connection(for: device.batteryState)
        defer { previousState = current }

        guard let haptic = WatchChargerHapticPolicy.haptic(for: previousState, current: current) else {
            return
        }

        switch haptic {
        case .connect:
            device.play(.success)
        case .disconnect:
            device.play(.stop)
        }
    }

    private func connection(for state: WKInterfaceDeviceBatteryState) -> WatchChargerConnection {
        switch state {
        case .charging, .full:
            return .connected
        case .unplugged:
            return .disconnected
        case .unknown:
            return .unknown
        @unknown default:
            return .unknown
        }
    }
}
