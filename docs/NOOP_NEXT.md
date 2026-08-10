# NOOP Next — product and engineering direction

NOOP should evolve as a local-first WHOOP companion rather than becoming a second cloud service.
The guiding rule is: **phone events → local policy → WHOOP BLE haptic/data path**.

## vNext goals

### 1. Call alerts that feel native

- Native phone calls are the highest-priority alert source.
- VoIP calls remain a separate source so a Teams/WhatsApp/Zoom call cannot accidentally enable native phone-call permission.
- The call state machine must be idempotent: duplicate `RINGING` events do not multiply buzzes.
- A disconnected strap must not consume a buzz slot. The connection service gets time to recover, then the same alert is retried.
- A missed `IDLE`/notification-removal event must self-heal with a watchdog.
- Default cadence: immediate buzz, then up to 5 reminders at 6-second intervals. This is intentionally finite.
- Respect NOOP master notifications, call master, quiet hours, and wear-gating before sending a haptic.

### 2. WHOOP haptics

Use the existing, hardware-verified haptic path instead of inventing a new BLE command.

WHOOP 4.0 uses `RUN_HAPTICS_PATTERN` (command 79) with the payload
`[patternId, loops, 0, 0, 0]`; NOOP already uses pattern 2 for its graduated alarm-style buzz.
WHOOP 5/MG has a separately remapped haptic path in the BLE client and must retain its family gate.

Do not send destructive/firmware commands from notification code.

### 3. Better UI

The Notifications screen should become an event-control center instead of a long settings list.

Proposed hierarchy:

1. **Wrist Alerts** — one master state and live delivery status.
2. **Calls** — one large card with Phone Calls and VoIP Calls as independent switches.
3. **Test Buzz** — one-tap physical test with the current pattern.
4. **Apps** — grouped apps with search, enabled state, and pattern preview.
5. **Quiet Hours** — a single visual time-range control.
6. **Diagnostics** — last event, last delivery, connection state, and permission state.

The call card should make the important path obvious:

`Phone rings → NOOP detects it → WHOOP connected → 3-pulse buzz`

If any step is unavailable, show the exact blocker and a single action to fix it.

### 4. Notification reliability

Android's `NotificationListenerService` is the correct local mechanism for app notifications.
It receives notification posted/removed callbacks and requires the user to grant Notification Access.
Native phone calls should remain on the phone-state path rather than depending on notification text.

### 5. Privacy

- No notification contents leave the device.
- No phone numbers are uploaded.
- No cloud relay is required for call haptics.
- Store only the minimum state required to make the local event machine reliable.

## Acceptance tests for call haptics

1. Incoming GSM call → WHOOP buzzes immediately.
2. Call remains ringing → reminders occur every 6 seconds, up to the configured finite limit.
3. WHOOP disconnects while ringing → no buzz slot is lost; delivery resumes after reconnection.
4. WHOOP is not worn and wear-gating is enabled → no buzz.
5. Quiet hours are active → no buzz.
6. Call ends → the repeat loop stops immediately.
7. Duplicate `RINGING` broadcasts → no duplicate haptic storm.
8. A missed stop event → watchdog clears the token and the next call can alert.
9. VoIP and GSM calls overlapping → one shared haptic scheduler, not two independent loops.
10. WHOOP 4.0 and WHOOP 5/MG use their existing family-specific haptic transport.

## Research references

- Android `NotificationListenerService`: https://developer.android.com/reference/android/service/notification/NotificationListenerService
- NOOP Android protocol notes: https://github.com/ryanbr/noop/blob/main/docs/ANDROID.md
- WHOOP BLE reverse-engineering notes: https://www.rusheelraj.com/blog/whoop/

These references are used for architecture/protocol validation; the implementation remains in NOOP's local-first codebase.
