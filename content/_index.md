---
title: SitRep Package Repository
---

Official APT and RPM packages for [sitrep](https://github.com/f-eld-ch/sitrep) — an open-source
incident management tool by [f-eld.ch](https://f-eld.ch).

---

## Quick Install — Debian / Ubuntu

Import the signing key:

```bash
curl -fsSL https://packages.sitrep.ch/sitrep-signing.asc \
  | sudo gpg --dearmor -o /usr/share/keyrings/sitrep.gpg
```

Add the repository and install:

```bash
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/sitrep.gpg] \
  https://packages.sitrep.ch/deb stable main" \
  | sudo tee /etc/apt/sources.list.d/sitrep.list
sudo apt-get update && sudo apt-get install sitrep
```

> **arm64:** replace `arch=amd64` with `arch=arm64`.

---

## Quick Install — Fedora / RHEL / Rocky / AlmaLinux

```bash
sudo dnf config-manager --add-repo https://packages.sitrep.ch/rpm/sitrep.repo
sudo dnf install sitrep
```

---

## Testing / Pre-release Channel

> **Warning:** Testing packages are pre-releases and may be unstable.
> Add this alongside the stable repository — the package manager will select the highest
> available version. To revert to stable after installing a pre-release, remove the testing
> source and run `sudo apt install sitrep=<stable-version>` (Debian/Ubuntu) or
> `sudo dnf downgrade sitrep` (Fedora/RHEL).

**Debian / Ubuntu:**

```bash
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/sitrep.gpg] \
  https://packages.sitrep.ch/deb testing main" \
  | sudo tee /etc/apt/sources.list.d/sitrep-testing.list
sudo apt-get update
```

**Fedora / RHEL:**

```bash
sudo dnf config-manager --add-repo https://packages.sitrep.ch/rpm/sitrep-testing.repo
```

---

## GPG Signing Key

All packages and repository metadata are signed with a dedicated GPG key.

Download: [sitrep-signing.asc](/sitrep-signing.asc)

Fingerprint: `5082 9DB2 FE3D 96B9 F544  7FA2 3B5D 817E F801 41FA` (expires 2028-09-04)

When the signing key rotates, download the updated key and re-run the `gpg --dearmor` import
step. Systems running unattended updates should monitor key expiry.

---

## All Releases

See [github.com/f-eld-ch/sitrep/releases](https://github.com/f-eld-ch/sitrep/releases) for
release notes and changelog.
