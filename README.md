<p align="center">
  <img src="docs/assets/logo-v3.png" alt="NOOP" width="72">
</p>

<h1 align="center">NOOP</h1>

<p align="center"><b>Your strap. Your data. Your machine.</b></p>
<p align="center"><sub>Offline-first · local · transparent · account-free</sub></p>

<p align="center">
  <img alt="Platforms" src="https://img.shields.io/badge/macOS%20%C2%B7%20iOS%20%C2%B7%20Android%20%C2%B7%20watchOS-E8B84B?style=flat-square">
  <img alt="Local first" src="https://img.shields.io/badge/local--first-E8B84B?style=flat-square">
  <img alt="Account free" src="https://img.shields.io/badge/account--free-C8902F?style=flat-square">
  <a href="LICENSE"><img alt="License: PolyForm Noncommercial 1.0.0" src="https://img.shields.io/badge/license-PolyForm%20Noncommercial%201.0.0-6B737B?style=flat-square"></a>
</p>

<p align="center">
  <a href="https://github.com/binesheb/noop/releases">Releases</a> ·
  <a href="https://github.com/binesheb/noop/issues">Issues</a> ·
  <a href="https://github.com/binesheb/noop/discussions">Discussions</a> ·
  <a href="docs/PROTOCOL.md">Protocol</a> ·
  <a href="CHANGELOG.md">Changelog</a>
</p>

<p align="center">
  <img src="docs/assets/hero-v8.jpg" alt="NOOP on Apple and Android devices" width="820">
</p>

---

## What is NOOP?

NOOP is an independent, source-available companion for wearable hardware, with **WHOOP 4.0 and 5.0**
as the primary supported ecosystem.

It communicates directly with hardware you own, keeps your data on your own devices, and performs
analysis locally instead of requiring a vendor account or cloud analytics service.

> **Your hardware. Your biometric data. Your machine.**

NOOP is an experimental interoperability, personal-data and wellness-visualization project. It is **not
a medical device** and its derived metrics are not clinical measurements.

**NOOP is not affiliated with, endorsed by, or connected to WHOOP, Inc.** WHOOP is referenced only to
identify the hardware and ecosystem with which NOOP interoperates.

---

## Core principles

### Local first

The intended data path is:

**Wearable → Bluetooth → NOOP → local database → local analysis → local UI**

There is no required NOOP account, cloud sync, telemetry service, or remote analytics backend.

### Keep your history useful

NOOP supports importing existing records so your history does not have to remain locked inside another
application. Import paths include WHOOP CSV exports, Apple Health exports and supported nutrition CSVs.

### Transparent computation

Derived metrics live in source code and are documented. Where appropriate, NOOP uses established
methods such as Task Force HRV conventions, Karvonen heart-rate reserve, TRIMP-style training load and
Tanaka HRmax estimation.

These methods are approximations and are **not reproductions of proprietary vendor algorithms**.

### Offline by default

Normal wearable communication, storage, analysis, visualization, imports and exports do not require the
internet. The optional AI Coach is the deliberate exception and remains disabled until configured.

---

## Feature map

| Area | Capability | Status |
|---|---|---|
| **Today** | Recovery, strain, sleep, HRV, RHR, SpO₂, respiratory rate and activity dashboard. | Implemented |
| **Readiness** | Local readiness synthesis using personal baselines and training context. | Implemented |
| **Live** | Real-time heart-rate and wearable frame data. | Implemented |
| **Breathe** | HRV-focused breathing sessions with haptic pacing and comparison. | Implemented |
| **Intervals** | Hands-free interval timer with haptic transition cues. | Implemented |
| **Explore / Compare** | Historical metric browsing and two-metric comparison. | Implemented |
| **Insights** | Behavioral/correlation insights from personal history, including Activity Cost. | Implemented |
| **Sleep** | Sessions, stages, hypnograms, efficiency, resting HR and HRV. | Implemented |
| **Trends** | Long-range trends and local one-page PDF reporting. | Implemented |
| **Workouts** | Detected/manual workouts, HR curves, zones, duration and effort. | Implemented |
| **Health** | HR, HRV, SpO₂, skin temperature, respiratory rate and related biometrics. | Implemented |
| **Stress / Mind** | Stress visualization and non-clinical mood check-ins. | Implemented |
| **Apple Health** | Import and reconcile Apple Health data. | Implemented |
| **Imports** | WHOOP CSV, Apple Health XML and supported nutrition CSVs. | Implemented |
| **Notifications** | Local notifications and configurable thresholds. | Implemented |
| **Automations** | Local reactions to strap events and live biometrics, including Mac actions and Shortcuts. | Implemented |
| **AI Coach** | Optional questions about personal metrics using remote or local/self-hosted models. | Optional |
| **Wearable protocols** | WHOOP plus experimental protocol modules for additional hardware. | Active development |
| **watchOS** | Apple Watch companion, live/workout experiences and hardware interaction. | Experimental |

**Status is deliberately conservative.** A feature is only described as stable when its implementation is
actually present in the source and applicable tests/build gates have been considered. Platform parity is
a goal, not a claim that every feature behaves identically everywhere.

---

## Wearable interaction

NOOP treats wearable hardware as an interaction surface, not just a sensor.

Current haptic-oriented experiences include:

- **Breathe** — haptic breathing cues during HRV sessions.
- **Intervals** — haptic work/rest and completion cues.
- **Automations** — configurable haptic coaching for selected conditions.
- **Smart alarm** — support for the strap's own firmware alarm where the hardware/protocol permits it.
- **Apple Watch** — experimental watchOS interaction.

### Charger-state haptics

The watchOS implementation is being extended with charger-state feedback: a short vibration when a
supported Apple Watch charger connection is detected and another when it is disconnected.

This remains an **experimental feature until the implementation is merged and verified on a real target**.
watchOS also restricts custom haptics while an app is inactive/backgrounded, so NOOP cannot replace Apple's
system charging feedback.

---

## Platform status

| Platform | Status | Current baseline |
|---|---|---|
| **macOS** | Reference platform | macOS 13+ |
| **iOS** | Supported | iOS 17+ |
| **Android** | Supported | Android 8+ / API 26+ |
| **watchOS** | Experimental | Companion and hardware features under active development |

The macOS application is the reference implementation. iOS and Android adapt the same concepts to their
native APIs, while watchOS is developed as a focused companion experience.

---

## Architecture

NOOP is organized around a local-first pipeline:

```text
                    ┌─────────────────────┐
                    │   Wearable hardware │
                    │  WHOOP + experiments│
                    └──────────┬──────────┘
                               │ Bluetooth / import
                               ▼
                    ┌─────────────────────┐
                    │ Protocol / transport│
                    │      decoders       │
                    └──────────┬──────────┘
                               ▼
                    ┌─────────────────────┐
                    │    Local storage    │
                    │     SQLite/GRDB     │
                    └──────────┬──────────┘
                               ▼
          ┌────────────────────┴────────────────────┐
          ▼                                         ▼
┌─────────────────────┐                   ┌─────────────────────┐
│   Local analyzers   │                   │ Import / reconcile  │
│ HRV / sleep / load  │                   │ WHOOP / Health /    │
│ recovery / trends   │                   │ nutrition history   │
└──────────┬──────────┘                   └──────────┬──────────┘
           └────────────────────┬────────────────────┘
                                ▼
                    ┌─────────────────────┐
                    │   Local application │
                    │ UI / reports /      │
                    │ notifications /     │
                    │ automations         │
                    └─────────────────────┘
```

The macOS reference application is centered on `Strand/`. Shared Swift packages isolate protocol,
persistence, analytics, import and design concerns. iOS, Android and watchOS add native platform
integration around those concepts.

---

## Repository structure

```text
.
├── Strand/                    # macOS reference application
├── StrandiOS/                # iOS application shell and integration
├── StrandiOSShared/          # shared iOS/widget contracts
├── NOOPWatch/                # experimental watchOS companion
├── Packages/                  # shared Swift packages
├── android/                   # Android application
├── docs/                      # build, protocol, privacy and project documentation
├── scripts/                   # development/build helpers
├── DISCLAIMER.md              # non-medical and project limitations
├── ATTRIBUTION.md             # attribution and interoperability sources
├── CHANGELOG.md               # project history
├── NOTICE                     # third-party notices
└── LICENSE                    # PolyForm Noncommercial License 1.0.0
```

The tree evolves with the project. **Source code and tests are the authoritative implementation reference.**

---

## Build from source

### macOS

Requirements:

- macOS 13 or newer
- A supported Xcode/Swift toolchain
- Compatible wearable hardware for live testing

```bash
git clone https://github.com/binesheb/noop.git
cd noop
```

Follow [`docs/BUILD.md`](docs/BUILD.md) for project generation, configuration and build instructions.

### iOS

NOOP targets **iOS 17+**. Build and signing instructions are maintained in [`docs/IOS.md`](docs/IOS.md).

### Android

NOOP targets **Android API 26+**. Follow [`docs/BUILD.md`](docs/BUILD.md) for the current source-build
procedure. Releases, when available, are published through GitHub Releases.

---

## Privacy and data flow

NOOP is designed to keep personal data local:

- No required NOOP account.
- No required WHOOP account.
- No required cloud database.
- No routine upload of raw wearable streams.
- Imported history remains on the user's device.
- Core analysis runs locally.
- AI Coach is optional and disabled until configured.
- A configured remote AI provider receives only the information required by the selected AI feature.

See [`docs/PRIVACY_SECURITY.md`](docs/PRIVACY_SECURITY.md) for the detailed data-flow and security model.

> **Local-first does not mean every optional integration is network-free.** Configure external services
> only when you understand and accept their data path.

---

## Protocol and interoperability

NOOP documents wearable protocol information used by the project, including packet structures, services,
characteristics, commands, events and decoding details where known.

See [`docs/PROTOCOL.md`](docs/PROTOCOL.md).

Protocol documentation describes factual interoperability information. It does not transfer ownership of
hardware, firmware or proprietary software.

---

## Medical and safety disclaimer

**NOOP is not a medical device.**

Heart rate, HRV, SpO₂, respiratory rate, sleep, stress, recovery and other derived values are intended for
personal information, experimentation and wellness-oriented visualization. They may be inaccurate,
incomplete, or affected by sensor quality, movement, fit, firmware behavior and algorithmic assumptions.

Do not use NOOP to diagnose, treat, monitor or rule out a medical condition. Do not rely on NOOP for an
emergency decision. If you have a health concern, use appropriate medical care and qualified clinical advice.

See [`DISCLAIMER.md`](DISCLAIMER.md) for the complete project disclaimer.

---

## Attribution and license

NOOP builds on prior community interoperability research and third-party open-source components. Their
respective licenses and notices remain applicable.

See [`ATTRIBUTION.md`](ATTRIBUTION.md) and [`NOTICE`](NOTICE).

NOOP's original source code and documentation are licensed under the **PolyForm Noncommercial License
1.0.0**. Commercial use is not granted by that license.

Read [`LICENSE`](LICENSE) before redistributing or using the project.

---

## Contributing

Small, focused contributions are preferred.

1. Start from the latest `main`.
2. Understand the existing architecture before changing it.
3. Keep platform-specific behavior behind platform boundaries where practical.
4. Prefer deterministic, testable logic.
5. Do not add cloud dependencies to local-first functionality.
6. Do not turn wellness-derived metrics into clinical claims.
7. Update documentation when behavior changes.
8. Run the applicable tests/build gates before claiming a feature is verified.

For protocol changes, include the evidence and device context used to establish the behavior.

See [`CONTRIBUTING.md`](CONTRIBUTING.md) and [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md).

---

## Project direction

NOOP is being built incrementally around a simple goal: **a dependable local platform for hardware the
user already owns**.

Current development priorities:

- deeper wearable protocol coverage;
- stronger local analytics and validation;
- better import/reconciliation tooling;
- richer haptic and hardware interaction;
- platform parity across macOS, iOS and Android;
- experimental watchOS capabilities;
- deterministic exports and reports;
- privacy and security hardening;
- automated testing and build verification;
- optional local AI integrations.

The repository's **source, tests, issues, changelog and releases** are the authoritative record of what is
actually implemented.

---

<p align="center"><b>NOOP</b><br><sub>Your strap. Your data. Your machine.</sub></p>
