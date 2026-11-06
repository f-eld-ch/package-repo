#!/usr/bin/env bash
# Downloads .deb and .rpm artifacts from f-eld-ch/sitrep GitHub releases.
# Env: CHANNEL (stable|testing), KEEP_VERSIONS (newest N releases, 0 = all),
#      GH_TOKEN, SITREP_REPO (default: f-eld-ch/sitrep)
set -euo pipefail

SITREP_REPO="${SITREP_REPO:-f-eld-ch/sitrep}"
DOWNLOAD_DIR="${DOWNLOAD_DIR:-/tmp/new-packages/${CHANNEL}}"
mkdir -p "$DOWNLOAD_DIR"

download_release() {
  local tag="$1"
  echo "Downloading artifacts for ${tag}..."
  gh release download "$tag" \
    --repo "$SITREP_REPO" \
    --pattern "*.deb" \
    --pattern "*.rpm" \
    --dir "$DOWNLOAD_DIR" \
    --clobber
}

KEEP_VERSIONS="${KEEP_VERSIONS:-0}"

# Determine which releases belong to this channel (newest first)
if [ "${CHANNEL}" = "testing" ]; then
  FILTER='.[] | select(.isPrerelease) | .tagName'
else
  FILTER='.[] | select(.isPrerelease | not) | .tagName'
fi

gh release list \
  --repo "$SITREP_REPO" \
  --exclude-drafts \
  --limit 100 \
  --json tagName,isPrerelease \
  --jq "$FILTER" > "/tmp/all-tags-${CHANNEL}.txt"

if [ "${KEEP_VERSIONS}" != "0" ]; then
  head -n "${KEEP_VERSIONS}" "/tmp/all-tags-${CHANNEL}.txt" > "/tmp/keep-tags-${CHANNEL}.txt"
  mv "/tmp/keep-tags-${CHANNEL}.txt" "/tmp/all-tags-${CHANNEL}.txt"
fi

while read -r t; do
  download_release "$t" || echo "Warning: failed to download ${t}, skipping."
done < "/tmp/all-tags-${CHANNEL}.txt"
