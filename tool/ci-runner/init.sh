#!/usr/bin/env bash
set -euo pipefail
# Seed independent persistent SDK volumes once. Host SDKs remain read-only.
for sdk in flutter android-sdk jdk17; do
  if [[ ! -f "/opt/$sdk/.endurain-seeded" ]]; then
    echo "Seeding isolated $sdk volume"
    cp -a "/seed/$sdk/." "/opt/$sdk/"
    touch "/opt/$sdk/.endurain-seeded"
  fi
done
export PATH="/opt/flutter/bin:/opt/jdk17/bin:/opt/android-sdk/platform-tools:/opt/android-sdk/cmdline-tools/latest/bin:$PATH"
git config --global --add safe.directory /opt/flutter
exec /entrypoint.sh ./bin/Runner.Listener run --startuptype service
