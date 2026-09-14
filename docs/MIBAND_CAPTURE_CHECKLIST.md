# Mi Band BLE capture checklist

Use this checklist for the first real-device interoperability capture. The goal is to collect enough evidence to identify one generation and describe its read-only discovery surface without guessing protocol details.

## Before capture

- Record the exact retail model name and hardware/model number if printed on the device or packaging.
- Record firmware version and the phone OS version used for capture.
- Record whether the band is already paired with another app.
- Use a dedicated test account/device where practical; do not capture personal health history.
- Confirm the capture is lawful and authorized for the device being tested.

## Discovery capture

Record, without writing to the device:

- BLE advertised/local name.
- Manufacturer data bytes.
- Advertised service UUIDs.
- GATT service UUIDs after connection.
- Characteristic UUIDs under each relevant service.
- Characteristic properties (read/write/notify/indicate) where visible.
- Whether connection succeeds without authentication.
- Any authentication challenge/response observed during a separate protocol investigation; do **not** commit keys or tokens.

Discovery itself must remain read-only. Do not enable notifications or write characteristics merely to identify a device unless the behavior is already known to be part of the minimal discovery handshake and is explicitly documented.

## Fixture preparation

Before adding repository fixtures:

1. Keep the raw capture outside the source tree.
2. Remove account identifiers, device addresses, authentication keys, tokens, and biometric payloads.
3. Preserve byte ordering and UUID spelling exactly for protocol evidence.
4. Keep only the minimum advertisement/GATT evidence needed by the parser.
5. Add the expected result as `supported`, `recognized-but-unsupported`, or `unknown` only when the evidence justifies it.
6. Do not infer a model from a display name alone when the available evidence is ambiguous.

## Acceptance gate

A generation is not marked `supported` until all of these are true:

- repeated discovery identifies the same model deterministically;
- malformed or incomplete evidence fails closed;
- the capability set contains only behavior actually implemented by NOOP;
- discovery leaves the device unchanged;
- disconnect cleanup is repeatable;
- deterministic fixtures cover the captured evidence.

This checklist is intentionally limited to discovery. Authentication, metric reads, historical sync, and notification subscriptions require their own evidence and tests before being added to the capability set.
