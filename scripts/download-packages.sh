#!/usr/bin/env bash
# Downloads .deb and .rpm artifacts from f-eld-ch/sitrep GitHub releases.
# Env: CHANNEL (stable|testing), KEEP_VERSIONS (newest N releases, 0 = all),
#      GH_TOKEN, SITREP_REPO (default: f-eld-ch/sitrep),
#      RELEASE_CACHE_DIR (default: /tmp/release-cache)
#
# Release assets are immutable once published, so each release is downloaded
# once into RELEASE_CACHE_DIR/<channel>/<tag>/ (persisted between runs by
# actions/cache) and reused afterwards. Cache entries for releases outside the
# retention window are removed. The kept releases are copied into DOWNLOAD_DIR.
set -euo pipefail

SITREP_REPO="${SITREP_REPO:-f-eld-ch/sitrep}"
DOWNLOAD_DIR="${DOWNLOAD_DIR:-/tmp/new-packages/${CHANNEL}}"
CACHE_DIR="${RELEASE_CACHE_DIR:-/tmp/release-cache}/${CHANNEL}"
KEEP_VERSIONS="${KEEP_VERSIONS:-0}"

rm -rf "$DOWNLOAD_DIR"
mkdir -p "$DOWNLOAD_DIR" "$CACHE_DIR"

# Determine which releases belong to this channel (newest first)
if [ "${CHANNEL}" = "testing" ]; then
  FILTER='.[] | select(.isPrerelease) | .tagName'
else
  FILTER='.[] | select(.isPrerelease | not) | .tagName'
fi

TAGS_FILE="/tmp/all-tags-${CHANNEL}.txt"
gh release list \
  --repo "$SITREP_REPO" \
  --exclude-drafts \
  --limit 100 \
  --json tagName,isPrerelease \
  --jq "$FILTER" > "$TAGS_FILE"

if [ "${KEEP_VERSIONS}" != "0" ]; then
  head -n "${KEEP_VERSIONS}" "$TAGS_FILE" > "${TAGS_FILE}.keep"
  mv "${TAGS_FILE}.keep" "$TAGS_FILE"
fi

# Drop cached releases that are no longer kept
for d in "$CACHE_DIR"/*/; do
  [ -d "$d" ] || continue
  grep -qxF "$(basename "$d")" "$TAGS_FILE" || { echo "Removing stale cache entry $(basename "$d")"; rm -rf "$d"; }
done

while read -r tag; do
  [ -n "$tag" ] || continue
  entry="${CACHE_DIR}/${tag}"
  if [ -z "$(ls -A "$entry" 2>/dev/null)" ]; then
    echo "Downloading artifacts for ${tag}..."
    rm -rf "${entry}.tmp"
    mkdir -p "${entry}.tmp"
    if gh release download "$tag" \
        --repo "$SITREP_REPO" \
        --pattern "*.deb" \
        --pattern "*.rpm" \
        --dir "${entry}.tmp"; then
      mv "${entry}.tmp" "$entry"
    else
      echo "Warning: failed to download ${tag}, skipping."
      rm -rf "${entry}.tmp"
      continue
    fi
  else
    echo "Using cached artifacts for ${tag}."
  fi
  cp "$entry"/* "$DOWNLOAD_DIR/" 2>/dev/null || true
done < "$TAGS_FILE"
