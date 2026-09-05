#!/usr/bin/env bash
# Signs all RPM packages in the channel with the imported GPG key.
# Env: CHANNEL (stable|testing)
# Prerequisite: GPG key imported and trusted before calling this script.
set -euo pipefail

cat > ~/.rpmmacros <<'MACROS'
%_gpg_name SitRep Package Repository
%_signature gpg
%__gpg /usr/bin/gpg
%__gpg_sign_cmd %{__gpg} gpg --batch --no-verbose --no-armor \
  -u "%{_gpg_name}" \
  -sbo %{__signature_filename} \
  --digest-algo sha256 \
  %{__plaintext_filename}
MACROS

RPMS=$(find "rpm/${CHANNEL}/x86_64" "rpm/${CHANNEL}/aarch64" -name '*.rpm' 2>/dev/null)

if [ -z "$RPMS" ]; then
  echo "No RPM packages found in channel ${CHANNEL}, skipping signing."
  exit 0
fi

echo "$RPMS" | xargs -r rpmsign --addsign
echo "RPM signing complete for channel: ${CHANNEL}"
