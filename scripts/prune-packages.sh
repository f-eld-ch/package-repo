#!/usr/bin/env bash
# Removes package files for versions outside the retention window.
# Env: CHANNEL (stable|testing), KEEP_VERSIONS (0 = keep all), GH_TOKEN,
#      SITREP_REPO (default: f-eld-ch/sitrep)
set -euo pipefail

KEEP_VERSIONS="${KEEP_VERSIONS:-0}"
SITREP_REPO="${SITREP_REPO:-f-eld-ch/sitrep}"

if [ "${KEEP_VERSIONS}" = "0" ]; then
  echo "KEEP_VERSIONS=0, skipping pruning."
  exit 0
fi

echo "Pruning ${CHANNEL} channel to last ${KEEP_VERSIONS} versions..."

if [ "${CHANNEL}" = "testing" ]; then
  FILTER='.[] | select(.isPrerelease) | .tagName'
else
  FILTER='.[].tagName'
fi

gh release list \
  --repo "$SITREP_REPO" \
  --limit 500 \
  --json tagName,isPrerelease \
  --jq "$FILTER" > /tmp/all-tags.txt

# Tags beyond the retention window
tail -n "+$((KEEP_VERSIONS + 1))" /tmp/all-tags.txt > /tmp/prune-tags.txt || true

if [ ! -s /tmp/prune-tags.txt ]; then
  echo "Nothing to prune."
  exit 0
fi

while read -r t; do
  VER="${t#v}"
  echo "Pruning version ${VER} from ${CHANNEL}..."
  find "deb/pool/${CHANNEL}" "rpm/${CHANNEL}" \
    -name "sitrep_${VER}_*" -delete 2>/dev/null || true
done < /tmp/prune-tags.txt
