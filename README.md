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

1. `f-eld-ch/sitrep` fires a `repository_dispatch` event on each release.
2. The `update-repo.yml` workflow rebuilds the **whole** site from the sitrep GitHub releases:
   it downloads the newest `.deb`/`.rpm` artifacts per channel, signs the RPMs, regenerates and
   signs the APT and RPM metadata, builds the Hugo landing page, and deploys the result with
   GitHub Pages (`actions/deploy-pages`).
3. Nothing is committed to a `gh-pages` branch, so package binaries never enter git history.
   Pages must be set to Settings → Pages → Source: **GitHub Actions**.

A Pages site is limited to 1 GB, so only the newest `keep_versions` releases per channel
(default 5) are published; the workflow fails if the site exceeds 950 MB.

## Manual operations

```bash
# Rebuild and redeploy, keeping the newest 3 releases per channel
gh workflow run update-repo.yml --repo f-eld-ch/package-repo -f keep_versions=3

# Watch progress
gh run watch --repo f-eld-ch/package-repo
```

## Signing key

See [KEYS.md](KEYS.md) for key fingerprint, expiry, and rotation instructions.
