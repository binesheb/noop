# Update and Upgrade Policy

NOOP is released as versioned builds. Updates should preserve local biometric data and never silently replace an app while it is running.

## Automatic update paths

- **iOS:** The recommended AltStore/SideStore source can surface new releases and handle the normal refresh/update flow after the source has been added.
- **macOS:** Use the app's release/update path when provided by the installed build. If an installed build does not expose an updater, update manually from a versioned GitHub Release.
- **Android:** Update with the newer signed/package-compatible release build. If the installed build does not support in-app updating, download the matching newer release and install it over the existing app only when Android accepts the signing identity; otherwise follow the release notes for a clean migration.

Automatic checks must be **opt-in or clearly user-visible**, must identify the target version, and must not delete local data. A failed download or validation must leave the currently installed version untouched.

## Manual update

### Release builds

1. Back up or export any data you do not want to risk losing.
2. Read the target release notes and compatibility notes.
3. Download the platform-specific artifact from the GitHub Releases page.
4. Install it using the normal platform mechanism.
5. Confirm that the app opens and that local data is present before removing the previous installation or backup.

### Source checkout

For a clean source checkout:

```bash
git fetch --tags --prune
git pull --ff-only
```

To pin a known version:

```bash
git checkout v10.5.0
```

Replace `v10.5.0` with the release tag you intend to build. To return to the default development branch:

```bash
git switch main
git pull --ff-only
```

## Rollback

Keep the previous release artifact until the new build has been validated. For source users, return to the previous known-good tag and rebuild from that revision. Do not downgrade or uninstall blindly when local storage compatibility is uncertain; check the release notes first.

## Release rules

NOOP uses Semantic Versioning for user-facing releases:

- **PATCH** for backward-compatible fixes.
- **MINOR** for backward-compatible features.
- **MAJOR** for incompatible platform, data, or API changes.

Every meaningful release should have a tag and release notes that describe user-visible changes, upgrade considerations, and any rollback or data-migration constraints.
