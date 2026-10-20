#!/usr/bin/env bash
# Exercise the CI probe with disposable keystores and fixture-only passwords.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
signing_fixture_dir="$(mktemp -d)"
trap 'rm -rf "$signing_fixture_dir"' EXIT
java_command="${JAVA_HOME:+$JAVA_HOME/bin/}java"
keytool_command="${JAVA_HOME:+$JAVA_HOME/bin/}keytool"

export ANDROID_KEYSTORE_PASSWORD=fixture-store-password
export ANDROID_KEY_ALIAS=fixture
for signing_format in PKCS12 JKS; do
  export ANDROID_KEY_PASSWORD=fixture-store-password
  if [[ "$signing_format" == JKS ]]; then
    export ANDROID_KEY_PASSWORD=fixture-distinct-key-password
  fi
  signing_fixture="$signing_fixture_dir/$signing_format.keystore"
  "$keytool_command" -genkeypair -storetype "$signing_format" \
    -keystore "$signing_fixture" \
    -storepass:env ANDROID_KEYSTORE_PASSWORD \
    -keypass:env ANDROID_KEY_PASSWORD \
    -alias "$ANDROID_KEY_ALIAS" -keyalg RSA -keysize 2048 -validity 1 \
    -dname 'CN=Disposable signing probe fixture' -noprompt >/dev/null 2>&1

  "$java_command" "$script_dir/VerifyAndroidSigning.java" "$signing_fixture"
  echo "PASS: $signing_format accepts matching signing credentials."

  if ANDROID_KEY_PASSWORD=incorrect-fixture-password \
    "$java_command" "$script_dir/VerifyAndroidSigning.java" "$signing_fixture" >/dev/null 2>&1; then
    echo "FAIL: $signing_format accepted an incorrect key password." >&2
    exit 1
  fi
  echo "PASS: $signing_format rejects an incorrect key password."

  if ANDROID_KEYSTORE_PASSWORD=incorrect-fixture-password \
    "$java_command" "$script_dir/VerifyAndroidSigning.java" "$signing_fixture" >/dev/null 2>&1; then
    echo "FAIL: $signing_format accepted an incorrect store password." >&2
    exit 1
  fi
  echo "PASS: $signing_format rejects an incorrect store password."
done
