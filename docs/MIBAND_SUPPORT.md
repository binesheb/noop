# Mi Band support status

NOOP has an experimental Mi Band discovery boundary, but it does **not** currently claim support for any Mi Band generation.

## Current behavior

- Mi Band discovery is routed through the verified-generation registry.
- The production registry is intentionally empty until a generation has a verified device signature.
- An unknown or unverified device is reported as recognized-but-unsupported rather than being treated as compatible.
- No Mi Band metric import is enabled by this status document alone.

This is deliberate: advertising a generation as supported before its BLE identity and protocol behavior have been verified would make device detection unreliable and could lead to incorrect data interpretation.

## Identity evidence

A production registry entry must be based on stable, generation-specific evidence. Do **not** treat a marketed name, RSSI value, or other transient advertisement field as sufficient proof of generation identity. If multiple generations share an identifier, keep them unresolved until additional verified evidence distinguishes them.

## What is still needed

Before registering a Mi Band generation, the implementation should have:

1. A lawful, reproducible BLE capture or fixture identifying the generation.
2. Deterministic tests for the identity/signature matching behavior.
3. A documented protocol/transport boundary for that generation.
4. At least one metric whose decoded value can be validated against the device or another trusted source.
5. Clear generation-specific capability and limitation documentation.

Only verified signatures should be added to the production registry.

## Development rule

Keep the production registry fail-closed. Test fixtures may exercise explicit signatures without making those signatures part of production support.
