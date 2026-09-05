#!/usr/bin/env bash
# Downloads .deb and .rpm artifacts from f-eld-ch/sitrep GitHub releases.
# Env: TAG (single release tag), MODE (single|rebuild-all), CHANNEL (stable|testing),
#      GH_TOKEN, SITREP_REPO (default: f-eld-ch/sitrep)
set -euo pipefail

SITREP_REPO="${SITREP_REPO:-f-eld-ch/sitrep}"
DOWNLOAD_DIR="${DOWNLOAD_DIR:-/tmp/new-packages}"
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

if [ "${MODE:-single}" = "rebuild-all" ]; then
  # Clear the channel pool so we rebuild from scratch
  rm -rf "deb/pool/${CHANNEL}" "rpm/${CHANNEL}"

  # Determine which releases belong to this channel
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
    --jq "$FILTER" > /tmp/all-tags.txt

  while read -r t; do
    download_release "$t" || echo "Warning: failed to download ${t}, skipping."
  done < /tmp/all-tags.txt
else
  download_release "$TAG"
fi
