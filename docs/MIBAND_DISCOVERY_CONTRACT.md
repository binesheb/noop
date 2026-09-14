# Mi Band discovery contract

This document turns the first Mi Band interoperability slice into a small, testable contract. It intentionally does not implement a BLE client or claim support for a specific Mi Band generation.

## Result model

A discovery attempt should produce one of these outcomes:

| Result | Meaning | Persist device data? |
|---|---|---:|
| `supported` | The model is recognized and the required local protocol surface is implemented. | No |
| `recognized-but-unsupported` | The device is identified, but NOOP does not yet implement its protocol. | No |
| `unknown` | The advertisement/GATT evidence is insufficient to identify the model. | No |

The result should also carry:

- a stable transport identifier for the current BLE peripheral;
- an optional human-readable model identifier;
- discovered service/characteristic UUIDs needed for capability classification;
- a capability set describing what NOOP can actually do;
- an explicit reason when a device is unsupported or unknown.

## Invariants

1. Discovery is read-only. It must not write to a characteristic, pair, authenticate, or start synchronization.
2. Unknown evidence must remain `unknown`; it must never be upgraded to a guessed model.
3. Recognized hardware without an implemented protocol must remain `recognized-but-unsupported`.
4. Capabilities describe implemented behavior, not hardware marketing features.
5. A failed GATT connection must be recoverable without leaving a retained peripheral/session reference.
6. Disconnect cleanup must be idempotent.
7. No health/activity payloads are persisted by discovery.

## Capability examples

Keep capabilities coarse and implementation-oriented for the first slice:

```text
bleDiscovery
modelIdentification
serviceInventory
heartRate
activityHistory
sleepHistory
battery
```

Only `bleDiscovery`, `modelIdentification`, and `serviceInventory` are candidates for the discovery milestone. Metric capabilities stay absent until their protocol paths are implemented and verified.

## Parser fixture shape

Identity/capability parsing should be testable without Bluetooth hardware. A fixture should contain only the protocol evidence needed by the parser, for example:

```json
{
  "advertisement": {
    "localName": "<captured-name>",
    "manufacturerData": "<captured-bytes>"
  },
  "gatt": {
    "services": ["<captured-service-uuid>"],
    "characteristics": ["<captured-characteristic-uuid>"]
  },
  "expected": {
    "model": "<known-model-or-null>",
    "result": "unknown",
    "capabilities": ["bleDiscovery", "serviceInventory"]
  }
}
```

Do not put real authentication keys, user identifiers, or unrelated biometric data into fixtures.

## Required tests before device support is declared

- known advertisement + known GATT evidence identifies the expected model;
- incomplete evidence returns `unknown`;
- recognized-but-unsupported hardware does not receive metric capabilities;
- duplicate services do not change the capability result;
- malformed manufacturer data fails closed;
- connection failure releases the active peripheral/session reference;
- repeated disconnect is harmless;
- discovery produces no persisted health/activity records.

## Hardware verification gate

For one real device, record the model and firmware version, capture the advertisement/GATT inventory, run discovery repeatedly, and verify that the device state is unchanged afterward. Keep the capture separate from source code and redact authentication material before sharing fixtures.

This contract is the boundary between BLE transport work and future protocol/metric implementation. It is deliberately small so the first real-device implementation can be reviewed and tested independently.
