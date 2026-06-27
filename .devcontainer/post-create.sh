#!/usr/bin/env bash
# Runs once after the container is created. The connect-iq-sdk feature has
# already installed the SDK (anonymous download). The two things left need a
# Garmin login: the per-device compiler files, and a signing key for builds.
set -euo pipefail

cd "$(dirname "$0")/.."

# --- Developer signing key (monkeyc -y) -------------------------------------
# Private key; never committed. Generated once per container.
if [ ! -f developer_key.der ]; then
    echo "Generating Connect IQ developer signing key..."
    openssl genrsa -out developer_key.pem 4096
    openssl pkcs8 -topk8 -inform PEM -outform DER \
        -in developer_key.pem -out developer_key.der -nocrypt
    rm -f developer_key.pem
fi

# --- Per-device compiler files (needs Garmin login) -------------------------
if [ -n "${GARMIN_USERNAME:-}" ] && [ -n "${GARMIN_PASSWORD:-}" ]; then
    echo "Logging in to Garmin and downloading device files for the manifest..."
    connect-iq-sdk-manager login
    connect-iq-sdk-manager device download --manifest manifest.xml
    echo "Device files ready. Build with: ./build.sh"
else
    cat >&2 <<'EOF'

  GARMIN_USERNAME / GARMIN_PASSWORD are not set, so device files were not
  downloaded and the app cannot be built yet.

  Export them on the host (or add them as Codespaces/repo secrets) and rebuild
  the container, or run inside the container:

      export GARMIN_USERNAME=you@example.com GARMIN_PASSWORD=...
      connect-iq-sdk-manager login
      connect-iq-sdk-manager device download --manifest manifest.xml

  Then: ./build.sh

EOF
fi
