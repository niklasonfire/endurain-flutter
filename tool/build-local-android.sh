#!/usr/bin/env bash
# Local APK only. Generates a persistent, ignored signing key on first use.
set -euo pipefail
app_dir="$(cd "$(dirname "$0")/.." && pwd)"
workspace_dir="$(dirname "$app_dir")"
export FLUTTER_HOME="${FLUTTER_HOME:-$workspace_dir/.local-toolchain/flutter}"
export JAVA_HOME="${JAVA_HOME:-/home/nilius/sdks/jdk17}"
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$workspace_dir/.local-toolchain/android-sdk}"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
# Isolate Flutter settings so an existing global android-sdk override cannot win.
export XDG_CONFIG_HOME="$workspace_dir/.local-toolchain/flutter-config"
export GRADLE_USER_HOME="${GRADLE_USER_HOME:-$workspace_dir/.local-toolchain/gradle-home}"
export PATH="$FLUTTER_HOME/bin:$JAVA_HOME/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
cd "$app_dir"
if [[ ! -f android/key.properties ]]; then
  umask 077
  mkdir -p android/.local-signing
  if [[ -e android/.local-signing/local.jks ]]; then
    echo 'Existing signing key found without key.properties; restore the properties file before building.' >&2
    exit 1
  fi
  local_password="$(python3 -c 'import secrets; print(secrets.token_hex(24))')"
  export ENDURAIN_LOCAL_KEY_PASSWORD="$local_password"
  keytool -genkeypair -keystore android/.local-signing/local.jks \
    -storepass:env ENDURAIN_LOCAL_KEY_PASSWORD -keypass:env ENDURAIN_LOCAL_KEY_PASSWORD \
    -alias endurain-local -keyalg RSA -keysize 3072 -validity 10000 \
    -dname 'CN=Endurain Local' -noprompt
  cat > android/key.properties <<PROPERTIES
storeFile=../.local-signing/local.jks
storePassword=$local_password
keyAlias=endurain-local
keyPassword=$local_password
PROPERTIES
  unset ENDURAIN_LOCAL_KEY_PASSWORD local_password
fi
if [[ "${1:-}" == "--setup-only" ]]; then
  echo "Local signing ready; credentials remain in ignored android/key.properties."
  exit 0
fi
# The local fork never receives an upstream diagnostics DSN.
flutter build apk --release --dart-define=ENDURAIN_CRASH_REPORTING_DSN= "$@"
