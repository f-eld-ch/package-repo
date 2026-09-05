#!/usr/bin/env bash
# Generates APT repository metadata for the given channel and GPG-signs it.
# Env: CHANNEL (stable|testing)
# Prerequisite: GPG key imported and trusted before calling this script.
set -euo pipefail

for arch in amd64 arm64; do
  mkdir -p "deb/dists/${CHANNEL}/main/binary-${arch}"

  (cd deb && dpkg-scanpackages --arch "$arch" "pool/${CHANNEL}/" /dev/null \
    > "dists/${CHANNEL}/main/binary-${arch}/Packages" 2>/dev/null)

  gzip -k -f "deb/dists/${CHANNEL}/main/binary-${arch}/Packages"
done

cat > /tmp/release-"${CHANNEL}".conf <<CONF
APT::FTPArchive::Release {
  Origin "SitRep";
  Label "SitRep";
  Suite "${CHANNEL}";
  Codename "${CHANNEL}";
  Architectures "amd64 arm64";
  Components "main";
  Description "SitRep package repository (${CHANNEL}) – https://github.com/f-eld-ch/sitrep";
};
CONF

(cd deb && apt-ftparchive -c /tmp/release-"${CHANNEL}".conf release "dists/${CHANNEL}/" \
  > "dists/${CHANNEL}/Release")

# Clearsigned InRelease (modern clients)
gpg --batch --yes --clearsign \
  -u "SitRep Package Repository" \
  -o "deb/dists/${CHANNEL}/InRelease" \
  "deb/dists/${CHANNEL}/Release"

# Detached Release.gpg (legacy clients)
gpg --batch --yes --armor --detach-sign \
  -u "SitRep Package Repository" \
  -o "deb/dists/${CHANNEL}/Release.gpg" \
  "deb/dists/${CHANNEL}/Release"

echo "APT metadata generated for channel: ${CHANNEL}"
