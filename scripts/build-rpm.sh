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

  # Skip regeneration if the RPM files are unchanged — avoids invalidating
  # client caches when a rebuild-all re-downloads the same packages.
  tracked_changed=$(git diff --name-only HEAD -- "${dir}/"*.rpm 2>/dev/null || true)
  untracked=$(git ls-files --others --exclude-standard "${dir}/" 2>/dev/null | grep '\.rpm$' || true)
  if [ -z "$tracked_changed" ] && [ -z "$untracked" ]; then
    echo "RPM pool unchanged for ${dir}, skipping metadata rebuild."
    continue
  fi

  createrepo_c --update "$dir/"

  gpg --batch --yes --armor --detach-sign \
    -u "SitRep Package Repository" \
    "${dir}/repodata/repomd.xml"
done

echo "RPM metadata generated for channel: ${CHANNEL}"
