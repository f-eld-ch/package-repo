# package-repo

APT and RPM package repository for [sitrep](https://github.com/f-eld-ch/sitrep), served at
[packages.sitrep.ch](https://packages.sitrep.ch).

## Channels

| Channel | Purpose | APT suite | RPM path |
|---------|---------|-----------|----------|
| `stable` | Production releases | `stable` | `rpm/stable/$basearch` |
| `testing` | Pre-releases only | `testing` | `rpm/testing/$basearch` |

The `testing` channel is additive — operators add both `stable` and `testing` repos to receive
pre-releases alongside stable packages.

## How it works

1. `f-eld-ch/sitrep` fires a `repository_dispatch` event on each release, carrying the tag name
   and channel (`stable` or `testing`).
2. The `update-repo.yml` workflow downloads the `.deb` and `.rpm` artifacts from that release,
   signs the RPMs, regenerates APT and RPM metadata, and pushes the result to the `gh-pages`
   branch.
3. GitHub Pages serves the `gh-pages` branch at `packages.sitrep.ch`.

## Manual operations

Trigger a rebuild via `gh`:

```bash
# Add a single release to the stable channel
gh workflow run update-repo.yml \
  --repo f-eld-ch/package-repo \
  -f tag=v1.2.3 \
  -f channel=stable

# Rebuild all stable packages from scratch
gh workflow run update-repo.yml \
  --repo f-eld-ch/package-repo \
  -f channel=stable

# Watch progress
gh run watch --repo f-eld-ch/package-repo
```

## Signing key

See [KEYS.md](KEYS.md) for key fingerprint, expiry, and rotation instructions.
