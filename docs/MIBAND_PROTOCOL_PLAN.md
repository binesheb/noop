# Xiaomi Mi Band BLE interoperability plan

This document defines the smallest safe first slice for Issue #11. It is a research and implementation boundary, not a claim that live Mi Band synchronization is already supported.

## First target

Start with **device discovery and capability identification** over BLE. Do not begin with activity-history decoding, cloud login, or broad model support.

The first implementation should be able to:

1. discover a Xiaomi/Mi Band advertisement;
2. identify the model/generation when the advertisement/GATT information makes that possible;
3. establish a GATT connection without modifying device state;
4. enumerate the relevant services and characteristics;
5. expose a capability result such as `supported`, `recognized-but-unsupported`, or `unknown`;
6. disconnect cleanly when discovery is complete.

No health data should be persisted in this first slice.

## Why discovery comes first

Mi Band support is generation-specific. Existing open-source interoperability projects demonstrate support across multiple generations, but the transport and authentication details are not a single stable API. Gadgetbridge documents broad Mi Band support and its developers explicitly treat new-device work as protocol research. The older Mi Band tooling also shows that service/characteristic layouts differ by generation.

Therefore NOOP should not hard-code one guessed UUID set and call every Xiaomi wearable compatible.

## Authentication boundary

Authentication is deliberately out of scope for the discovery slice.

Some Mi Band generations require a device-specific authentication key and an authentication exchange before protected characteristics can be used. NOOP should never log into Xiaomi cloud services merely to obtain device data. Any future authentication flow must be explicit, local, and documented before implementation.

## Clean-room and licensing boundary

Use public protocol observations and independently captured traffic as research inputs. Do **not** copy implementation code from GPL/AGPL projects into NOOP's non-GPL codebase.

Useful research references include Gadgetbridge and historical Mi Band protocol tooling. Their code is reference material only; NOOP's implementation must be independently written and tested.

## Proposed capability model

Keep the transport independent from metric decoding:

```text
BLE discovery
    -> DeviceIdentity
    -> CapabilitySet
    -> authenticated session (future)
    -> protocol frames (future)
    -> metric decoder (future)
    -> NOOP local data model
```

A device that can be discovered but whose protocol is not yet implemented should remain usable as a recognized device with an explicit unsupported capability state.

## Verification gate

Before moving beyond discovery:

- test with at least one real Mi Band;
- capture the advertisement and GATT inventory;
- record the exact model/firmware information;
- verify repeated discovery does not write or alter device state;
- verify disconnect cleanup;
- add deterministic fixtures for the identity/capability parser.

Only after this gate should authentication or metric synchronization be implemented.

## References

- Gadgetbridge documents support for multiple Mi Band generations and a cloudless interoperability approach.
- Historical Mi Band protocol tooling demonstrates generation-specific BLE services and characteristics.

These references are used for research direction only; no source code is copied into NOOP.
