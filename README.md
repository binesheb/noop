<p align="center">
  <img src="docs/assets/logo-v3.png" alt="NOOP" width="72">
</p>

<h1 align="center">NOOP</h1>

<p align="center"><b>Your strap. Your data. Your machine.</b></p>
<p align="center"><sub>Offline-first, local, transparent and account-free.</sub></p>

<p align="center">
  <img alt="Platforms" src="https://img.shields.io/badge/platforms-macOS%20%C2%B7%20Android%20%C2%B7%20iOS-E8B84B?style=flat-square">
  <img alt="Local first" src="https://img.shields.io/badge/local-first-E8B84B?style=flat-square">
  <img alt="Account free" src="https://img.shields.io/badge/account-free-C8902F?style=flat-square">
  <img alt="WHOOP 4 and 5" src="https://img.shields.io/badge/works%20with-WHOOP%204.0%20%26%205.0-6B737B?style=flat-square">
  <a href="LICENSE"><img alt="License: PolyForm Noncommercial 1.0.0" src="https://img.shields.io/badge/license-PolyForm%20Noncommercial%201.0.0-6B737B?style=flat-square"></a>
</p>

<p align="center">
  <a href="https://github.com/binesheb/noop/releases/latest">Releases</a> ·
  <a href="https://github.com/binesheb/noop/wiki/FAQ">FAQ</a> ·
  <a href="https://github.com/binesheb/noop/issues">Issues</a> ·
  <a href="https://github.com/binesheb/noop/discussions">Discussions</a> ·
  <a href="docs/PROTOCOL.md">Protocol</a>
</p>

<p align="center">
  <img src="docs/assets/hero-v8.jpg" alt="NOOP on iPhone, Mac and Android" width="820">
</p>

---

## What is NOOP?

NOOP is an independent, source-available companion for **WHOOP 4.0 and 5.0** hardware.
It communicates directly with hardware you own, stores the resulting data on your own device,
and performs analysis locally instead of depending on a WHOOP account or WHOOP cloud service.

The project is built around a simple principle:

> **Your hardware. Your biometric data. Your machine.**

NOOP is not a replacement for a medical device, and its derived metrics are not clinical measurements.
It is an experimental interoperability and personal-data project.

**NOOP is not affiliated with, endorsed by, or connected to WHOOP, Inc.** WHOOP is referenced only to
identify the hardware and ecosystem with which NOOP interoperates.

---

## Core principles

### Local first

The normal data path stays on the device:

**Wearable → Bluetooth → NOOP → local database → local analysis → local UI**

There is no required account, cloud sync, telemetry service, or remote analytics backend.

### Your history stays useful

NOOP can import existing data so your historical record does not have to remain locked inside another
application. Supported import paths include WHOOP CSV exports, Apple Health exports, and nutrition CSVs
from supported applications.

### Transparent computation

Derived metrics are implemented in source and documented rather than presented as an opaque score.
Where appropriate, the project uses established methods such as Task Force HRV conventions, Karvonen
heart-rate reserve, TRIMP-style training load, Tanaka HRmax estimation, and related sports-science
methods. These are **approximations**, not reproductions of proprietary WHOOP algorithms.

### Offline by default

The application does not need the internet for normal wearable communication, storage, analysis,
visualization, imports, or exports.

The optional **AI Coach** is the exception. It remains off until configured and uses a provider or
local/self-hosted model selected by the user.

---

## Features

| Area | Capability |
|---|---|
| **Today** | Recovery, strain, sleep, HRV, RHR, SpO₂, respiratory rate, activity and other key metrics in one dashboard. |
| **Readiness** | Local readiness synthesis using your own baselines, recovery signals and training-load context. |
| **Live** | Real-time heart-rate and wearable frame data. |
| **Breathe** | HRV-focused breathing sessions with haptic pacing and pre/post session comparison. |
| **Intervals** | Hands-free interval timer with haptic transition cues and visual fallback. |
| **Explore** | Browse individual metrics and their historical trends. |
| **Compare** | Compare two metrics over a common timeline. |
| **Insights** | Behavioral and correlation-based insights derived from your own history, including Activity Cost. |
| **Sleep** | Sleep sessions, stages, hypnograms, efficiency, resting HR and HRV with historical browsing. |
| **Trends** | Long-range recovery, strain, sleep and biometric trends plus a local one-page PDF report. |
| **Workouts** | Detected/manual workouts, heart-rate curves, zones, duration, average/max HR and effort. |
| **Health** | HR, HRV, SpO₂, skin temperature, respiratory rate and related biometrics. |
| **Stress** | Day-level stress/autonomic-load visualization. |
| **Mind** | Non-clinical daily mood check-ins correlated with personal recovery, sleep and HRV history. |
| **Apple Health** | Import and reconcile Apple Health data. |
| **Data Sources** | WHOOP CSV, Apple Health XML and supported nutrition CSV imports plus live strap status. |
| **Notifications** | Local notifications and configurable thresholds. |
| **Automations** | On-device reactions to strap events and live biometrics, including Mac actions and Shortcuts. |
| **Coach** | Optional AI-assisted questions about your own recent metrics. Supports remote APIs and local/self-hosted models. |
| **Settings** | Profile, units, preferences, step calibration, What's New and experimental protocol controls. |

---

## Wearable interaction

NOOP is more than a dashboard. The strap can become an interaction surface.

Current haptic-oriented capabilities include:

- **Breathe:** haptic breathing cues while HRV is being measured.
- **Intervals:** haptic work/rest and completion cues for hands-free training.
- **Automations:** configurable haptic coaching for selected heart-rate and inactivity conditions.
- **Smart alarm:** support for the strap's own firmware alarm where the hardware/protocol permits it.

### Watch hardware roadmap

The project is also being extended toward deeper Apple Watch/watchOS hardware interaction.
One planned/active feature is **charger-state haptics**: a short vibration when a supported Watch
charger connection is detected and another when it is disconnected. This feature is being developed
separately from the stable mainline feature set and will be documented here when merged and verified.

---

## Platform status

| Platform | Status | Notes |
|---|---|---|
| **macOS** | Reference platform | Full local application, analysis, imports, exports, automations and optional AI Coach. |
| **Android** | Supported | Full application with local storage, wearable communication, analysis and imports. `minSdk 26` (Android 8+). |
| **iOS** | Supported | Native iOS application using the shared project architecture and local data model. Build/signing instructions are in `docs/IOS.md`. |
| **watchOS** | Experimental / active development | Hardware interaction is being developed incrementally. Features are only listed as stable after verification on the target platform. |

Platform parity is a goal, not a claim that every screen or hardware capability is identical on every
platform. Hardware APIs, background execution and distribution requirements differ between Apple,
Android and macOS.

---

## Data architecture

At a high level, NOOP follows this architecture:

```text
                         ┌─────────────────────┐
                         │   WHOOP / Oura      │
                         │   wearable hardware │
                         └──────────┬──────────┘
                                    │ Bluetooth
                                    ▼
                         ┌─────────────────────┐
                         │   Device transport  │
                         │ protocol / decoder  │
                         └──────────┬──────────┘
                                    ▼
                         ┌─────────────────────┐
                         │   Local data model  │
                         │      SQLite/GRDB    │
                         └──────────┬──────────┘
                                    ▼
              ┌────────────────────┴────────────────────┐
              │                                         │
              ▼                                         ▼
   ┌─────────────────────┐                   ┌─────────────────────┐
   │  Local analyzers    │                   │  Import / reconcile │
   │ HRV / sleep / load  │                   │ WHOOP / Health /   │
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

The macOS reference application is organized around `Strand/`, with data, analysis, screens, system
integration and platform-specific code separated into focused modules. Android and iOS reuse the
shared concepts while adapting to their native platform APIs.

---

## Repository structure

```text
.
├── Strand/                    # macOS reference application
│   ├── App/                   # application shell and navigation
│   ├── Data/                  # database, imports and metric catalog
│   ├── Screens/               # user-facing screens
│   ├── System/                # notifications, automations and Mac actions
│   └── MenuBar/               # macOS menu-bar experience
├── Packages/                  # shared Swift packages and analyzers
├── android/                   # Android application
├── docs/                      # protocol, build, privacy and project documentation
├── scripts/                   # development/build helpers
├── DISCLAIMER.md              # non-medical and project limitations
├── ATTRIBUTION.md             # attribution and interoperability sources
├── NOTICE                     # third-party component notices
└── LICENSE                    # PolyForm Noncommercial License 1.0.0
```

The exact tree evolves as platform implementations mature; source code is the authoritative reference
for implementation details.

---

## Quickstart — macOS

### Requirements

- macOS with a supported Xcode toolchain
- Swift/Xcode dependencies resolved by the project
- A compatible wearable for live hardware testing

### Build

See [`docs/BUILD.md`](docs/BUILD.md) for the maintained build procedure.

A typical source workflow is:

```bash
git clone https://github.com/binesheb/noop.git
cd noop
```

Then open/generate the appropriate Xcode project as described in `docs/BUILD.md` and build the macOS
application from Xcode.

For iOS and Android, follow their platform-specific documentation rather than assuming the macOS
commands apply unchanged.

---

## Android

Pre-built Android releases are distributed through GitHub Releases when available.

- Minimum SDK: **26 / Android 8+**
- Distribution may require sideloading because NOOP is not distributed through Google Play.
- The application is designed around local storage and does not require a WHOOP account.

See [`docs/BUILD.md`](docs/BUILD.md) for source builds and platform details.

---

## iOS

NOOP can be built from source with Xcode. Release builds may also be distributed as an unsigned IPA
or through AltStore/SideStore where configured by the project.

See [`docs/IOS.md`](docs/IOS.md) for current installation and signing instructions.

---

## Privacy

NOOP's default design is intentionally local:

- No required NOOP account.
- No required WHOOP account.
- No required cloud database.
- No routine upload of raw wearable streams.
- Historical imports remain on the user's device.
- Analysis is performed locally.
- AI Coach is optional and disabled until configured.
- When a remote AI provider is configured, only the information required by the selected AI feature
  is sent; raw wearable streams and device identifiers are not required by the normal Coach flow.

For the detailed security and data-flow model, see [`docs/PRIVACY_SECURITY.md`](docs/PRIVACY_SECURITY.md).

---

## Protocol and interoperability

NOOP documents the wearable protocol information used by the project, including packet structure,
services, characteristics, commands, events and decoding details where known.

See [`docs/PROTOCOL.md`](docs/PROTOCOL.md).

Protocol documentation describes factual interoperability information about data appearing on a wire.
It should not be confused with ownership of the original hardware, firmware or proprietary software.

---

## Medical and safety disclaimer

**NOOP is not a medical device.**

Heart rate, HRV, SpO₂, respiratory rate, sleep, stress, recovery and other derived values are for
personal information, experimentation and wellness-oriented visualization. They may be inaccurate,
incomplete or affected by sensor quality, movement, fit, firmware behavior and algorithmic assumptions.

Do not use NOOP to diagnose, treat, monitor or rule out a medical condition. Do not rely on it for an
emergency decision. If you have a health concern, use appropriate medical care and qualified clinical
advice.

See [`DISCLAIMER.md`](DISCLAIMER.md) for the complete project disclaimer.

---

## Attribution

NOOP builds on prior community interoperability research and third-party open-source components.
Their respective licenses and notices remain applicable.

See [`ATTRIBUTION.md`](ATTRIBUTION.md) and [`NOTICE`](NOTICE).

---

## License

NOOP's original source code and documentation are licensed under the
**PolyForm Noncommercial License 1.0.0**.

In practical terms, the project is source-available and intended to be free for personal and other
permitted non-commercial use. **Commercial use is not granted by this license.**

Protocol facts documented by the project are treated separately as factual interoperability
information as described in the repository's license and notices.

Read the complete [`LICENSE`](LICENSE) before redistributing or using the project.

---

## Contributing

Small, focused contributions are preferred.

Before opening a pull request:

1. Start from the latest `main`.
2. Understand the existing architecture before changing it.
3. Keep platform-specific behavior behind platform boundaries where practical.
4. Prefer deterministic, testable logic.
5. Do not add cloud dependencies to local-first functionality.
6. Do not turn wellness-derived metrics into clinical claims.
7. Update documentation when behavior changes.
8. Run the applicable tests/build gates before claiming a feature is verified.

For protocol changes, include the evidence and device context used to establish the behavior.

---

## Project direction

NOOP is being developed incrementally. The priority is not to add every possible feature at once,
but to build a dependable local platform around hardware the user already owns.

Current development themes include:

- deeper wearable protocol coverage;
- stronger local analytics and validation;
- better import/reconciliation tooling;
- richer haptic and hardware interaction;
- platform parity across macOS, iOS and Android;
- experimental watchOS capabilities;
- deterministic exports and reports;
- privacy/security hardening;
- automated testing and build verification;
- optional local AI integrations.

The repository's source, tests, issues and release notes are the authoritative record of what is
actually implemented.

---

<p align="center"><b>NOOP</b><br><sub>Your strap. Your data. Your machine.</sub></p>
