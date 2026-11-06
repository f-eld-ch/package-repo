#!/usr/bin/env bash
# Signs all RPM packages in the channel with the imported GPG key.
# Env: CHANNEL (stable|testing)
# Prerequisite: GPG key imported and trusted before calling this script.
set -euo pipefail

# Use rpm's built-in gpg signing command (its definition differs between rpm
# versions, so don't override it); only select the key. The key has no
# passphrase and gpg runs non-interactively.
cat > ~/.rpmmacros <<'MACROS'
%_gpg_name SitRep Package Repository
%_gpg_sign_cmd_extra_args --batch
MACROS

RPMS=$(find "rpm/${CHANNEL}/x86_64" "rpm/${CHANNEL}/aarch64" -name '*.rpm' 2>/dev/null)

if [ -z "$RPMS" ]; then
  echo "No RPM packages found in channel ${CHANNEL}, skipping signing."
  exit 0
fi

echo "$RPMS" | xargs -r rpmsign --addsign
echo "RPM signing complete for channel: ${CHANNEL}"
