# Fork maintenance

`binesheb/noop` is a working fork of [`ryanbr/noop`](https://github.com/ryanbr/noop), not a mirror. The fork intentionally carries local interoperability work and may diverge from upstream.

## Safe manual upstream sync

Before syncing, review upstream changes and make sure local Mi Band/protocol work is not overwritten.

```bash
git fetch upstream
git checkout main
git pull --ff-only origin main
git log --oneline --decorate -20 upstream/main
git diff --stat main..upstream/main
```

If the upstream changes are wanted, merge them explicitly and run the full repository CI before publishing or distributing a build:

```bash
git merge --no-ff upstream/main
```

If the fork has local commits that should be rebased instead, stop and review the conflict set before using a rebase. Do not force-push `main` as part of routine maintenance.

## Remote setup

For a fresh clone, configure the upstream remote once:

```bash
git remote add upstream https://github.com/ryanbr/noop.git
git remote -v
```

Keep `origin` pointing at `binesheb/noop` so pushes cannot accidentally target upstream.

## Why there is no automatic updater

This fork is an actively diverging application fork with protocol and hardware-safety work. Automatic upstream synchronization could overwrite locally validated behavior or introduce unsupported device claims. Upstream changes should therefore be reviewed and merged deliberately.
