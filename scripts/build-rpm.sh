#!/usr/bin/env bash
# Generates RPM repository metadata for the given channel and signs repomd.xml.
# Env: CHANNEL (stable|testing)
# Prerequisite: GPG key imported and trusted before calling this script.
set -euo pipefail

for arch in x86_64 aarch64; do
  dir="rpm/${CHANNEL}/${arch}"

  if [ ! -d "$dir" ] || [ -z "$(ls -A "$dir"/*.rpm 2>/dev/null)" ]; then
    echo "No RPMs found in ${dir}, skipping."
    continue
  fi

  createrepo_c --update "$dir/"

  gpg --batch --yes --armor --detach-sign \
    -u "SitRep Package Repository" \
    "${dir}/repodata/repomd.xml"
done

echo "RPM metadata generated for channel: ${CHANNEL}"
