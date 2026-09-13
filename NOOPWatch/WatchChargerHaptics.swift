import WatchKit

/// Watches the Apple Watch's own charging state and gives a short haptic when the magnetic
/// charger is connected or disconnected.
///
/// The first observed state is seeded silently. This prevents opening/restarting NOOP while the
/// watch is already charging from being mistaken for a new charger connection. Subsequent battery
/// state transitions are mapped through `WatchChargerHapticPolicy`, keeping the hardware callback thin.
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
        // WatchKit batteryState is Unknown until battery monitoring is explicitly enabled.
        device.isBatteryMonitoringEnabled = true

        // Read the state before observing so the initial state can never create a false transition.
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
        guard let haptic = WatchChargerHapticPolicy.haptic(for: previousState, current: current) else {
            previousState = current
            return
        }

        previousState = current
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
