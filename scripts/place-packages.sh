#!/usr/bin/env bash
# Places downloaded packages into the channel-specific pool directories.
# Env: CHANNEL (stable|testing), DOWNLOAD_DIR (default: /tmp/new-packages)
set -euo pipefail

DOWNLOAD_DIR="${DOWNLOAD_DIR:-/tmp/new-packages}"

mkdir -p "deb/pool/${CHANNEL}/main/s/sitrep"
mkdir -p "rpm/${CHANNEL}/x86_64"
mkdir -p "rpm/${CHANNEL}/aarch64"

# .deb files — all go into the pool; dpkg-scanpackages filters by arch field inside the package
cp "$DOWNLOAD_DIR"/*.deb "deb/pool/${CHANNEL}/main/s/sitrep/" 2>/dev/null || true

# .rpm files — split by arch at placement time (goreleaser uses amd64/arm64 naming)
for f in "$DOWNLOAD_DIR"/*_linux_amd64.rpm; do
  [ -f "$f" ] && cp "$f" "rpm/${CHANNEL}/x86_64/"
done
for f in "$DOWNLOAD_DIR"/*_linux_arm64.rpm; do
  [ -f "$f" ] && cp "$f" "rpm/${CHANNEL}/aarch64/"
done

echo "Packages placed into channel: ${CHANNEL}"
