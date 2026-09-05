# Signing Key

The repository signing key is a dedicated GPG key used to sign package metadata and individual
RPM packages. It is distinct from the cosign key used to sign release artifacts on GitHub.

## Current Key

| Field       | Value                        |
|-------------|------------------------------|
| Name        | SitRep Package Repository    |
| Email       | packages@sitrep.ch           |
| Fingerprint | `5082 9DB2 FE3D 96B9 F544  7FA2 3B5D 817E F801 41FA` |
| Created     | 2026-09-05                   |
| Expires     | 2028-09-04                   |

## Rotation Plan

1. At month 21 (3 months before expiry), generate a new key.
2. Export the new public key as `static-assets/sitrep-signing-new.asc` and commit it.
3. Update the `REPO_SIGNING_KEY` secret in the `package-repo` GitHub Actions settings.
4. New packages will be signed with the new key from this point.
5. Old packages remain valid — they were signed when the old key was still valid.
6. At expiry, remove the old public key from the site and update install instructions.

## Key Generation Command

```bash
gpg --batch --gen-key <<'EOF'
%echo Generating SitRep repo signing key
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: SitRep Package Repository
Name-Email: packages@sitrep.ch
Expire-Date: 2y
%no-protection
%commit
EOF

gpg --armor --export packages@sitrep.ch > sitrep-signing.asc
gpg --armor --export-secret-keys packages@sitrep.ch > sitrep-signing-private.asc
gpg --fingerprint packages@sitrep.ch
```

Store `sitrep-signing-private.asc` in GitHub Actions secrets as `REPO_SIGNING_KEY`.
Commit `sitrep-signing.asc` as `static-assets/sitrep-signing.asc` in this repo.
Delete `sitrep-signing-private.asc` from disk after uploading the secret.
