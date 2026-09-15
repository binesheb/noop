# Mi Band protocol capture template

Use this template when collecting **lawfully obtained** BLE evidence for Mi Band interoperability work.

The capture is evidence for a future protocol fixture; it does not by itself enable production support.

## Device

- Model / marketed name:
- Generation (if known):
- Firmware version:
- Hardware revision (if exposed):
- Capture date:
- Capture environment:

## Discovery evidence

- Advertised local name:
- Manufacturer data:
- Service UUIDs:
- Characteristic UUIDs:
- Other stable identifiers:

## Traffic

Record only the minimum traffic needed to reproduce the observed behavior.

- Transport: BLE / other
- Pairing/authentication observed:
- Read operations:
- Write operations:
- Notifications/indications:
- Payload encoding/endianness:

Do not include credentials, account identifiers, or unrelated personal data.

## Metric evidence

For each candidate metric, record how the value was independently verified.

| Metric | Source characteristic | Encoding | Independent verification | Confidence |
| --- | --- | --- | --- | --- |
| | | | | |

## Reproduction fixture

A fixture should contain only deterministic protocol evidence required by the test.

- Fixture identifier:
- Input sequence:
- Expected discovery result:
- Expected decoded values:
- Required authentication/session state:

## Acceptance checklist

- [ ] Evidence was obtained lawfully and with appropriate consent.
- [ ] No secrets or personal identifiers are included.
- [ ] The device identity is reproducible from stable evidence.
- [ ] At least one protocol interaction is deterministic.
- [ ] At least one metric has independent verification.
- [ ] Unsupported generations remain fail-closed.
- [ ] A production registry entry is **not** added until the evidence is reviewed and hardware-verified.

See [`MIBAND_SUPPORT.md`](./MIBAND_SUPPORT.md) for the current support boundary.