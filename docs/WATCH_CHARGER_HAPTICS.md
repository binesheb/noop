# Watch charger haptics

NOOP's watchOS charger feedback is intentionally small and state-based.

## Behavior

- The first observed battery state is recorded silently.
- `.charging` and `.full` are treated as **connected**.
- `.unplugged` is treated as **disconnected**.
- Unknown states do not produce feedback.
- A transition from disconnected → connected plays the `.success` haptic.
- A transition from connected → disconnected plays the `.stop` haptic.
- Repeated observations of the same connection state do not play another haptic.

This keeps an already-charging watch from vibrating when NOOP launches and avoids duplicate feedback when watchOS reports the same state more than once.

## Implementation boundary

`WatchChargerHapticPolicy` contains the pure transition decision. It has no WatchKit dependency, so the state machine can be reasoned about independently from the device observer.

`WatchChargerHaptics` owns the `WKInterfaceDevice` observer, enables battery monitoring, seeds the initial state, and maps the policy result to WatchKit haptics.

The observer is retained by the watch app for its lifetime.

## Manual verification

Physical verification is required before treating this feature as production-ready:

1. Launch NOOP while the watch is **not** connected to its charger.
2. Connect the charger and confirm one `.success` haptic.
3. Leave the charger connected and confirm no repeated haptic from unchanged state notifications.
4. Disconnect the charger and confirm one `.stop` haptic.
5. Reconnect and disconnect again to confirm each real transition produces exactly one haptic.
6. Launch NOOP while the watch is already charging and confirm there is **no** launch-time haptic.
7. Repeat with a watch that reports `.full` while on the charger; it should remain in the connected state.

watchOS may restrict custom haptics while the application is inactive or backgrounded. This feature therefore supplements, rather than replaces, the system charging indication.
