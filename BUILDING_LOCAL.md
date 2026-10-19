# Local Android build handoff

This checkout belongs to `niklasonfire/endurain-flutter`. The local Home,
activity cards, recording, graphs, and upload-message changes are on
`feat/local-home-activity-recording`, not the fork's default `main`.

```bash
git status --short
git branch --show-current
# On a clean default clone, if the local-feature branch is not yet checked out:
git switch --track origin/feat/local-home-activity-recording
```

Do not switch away from uncommitted work or overwrite another agent's changes.
No upstream push or PR is part of this workflow.

## Verified toolchain on this machine

These existing paths are intentional. The original workspace is used only as a
local SDK/cache/signing-input source; build the code in the current checkout.
No dependency on the backend repository is needed.

```bash
export ENDURAIN_TOOLCHAIN_ROOT=/home/nilius/Documents/Codex/2026-10-18-ich-nutze-endurain-seit-einiger-zeit/.local-toolchain
export FLUTTER_HOME="$ENDURAIN_TOOLCHAIN_ROOT/flutter"
export JAVA_HOME=/home/nilius/sdks/jdk17
export ANDROID_SDK_ROOT="$ENDURAIN_TOOLCHAIN_ROOT/android-sdk"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
export GRADLE_USER_HOME="$ENDURAIN_TOOLCHAIN_ROOT/gradle-home"
export XDG_CONFIG_HOME="$ENDURAIN_TOOLCHAIN_ROOT/flutter-config"
export PATH="$FLUTTER_HOME/bin:$JAVA_HOME/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
```

Verified: Flutter3.47.3/Dart3.13.3, JDK17, Android platform37.0,
build-tools36.0.0, NDK28.2, Gradle9.3.1. Existing native Gradle wrapper/settings
select the required versions. Check path existence once; do not install a
second Flutter or run `flutter upgrade`/`flutter pub upgrade` for a rebuild.
Use this same SDK for any `pub get`, tests, analyzer, and build. The normal
`flutter build` resolves dependencies when needed; do not add `--no-pub` to a
fresh clone without a matching package configuration.

## Persistent private signing

The existing installed local app uses package **com.endurain.endurain.local**
and launcher **Endurain Local**, separate from the original app. Updates require
its original signing key. Private files are deliberately absent from Git.

On this host, the original app's ignored signing properties are at:

```bash
export ENDURAIN_SIGNING_PROPERTIES=/home/nilius/Documents/Codex/2026-10-18-ich-nutze-endurain-seit-einiger-zeit/endurain-flutter/android/key.properties
```

That is a private input reference, not a file to publish or copy into source.
The existing helper `tool/build-local-android.sh` is appropriate only after
this checkout already has the correct local signing configuration; without
`android/key.properties` it generates a new identity. The direct build below
avoids that fresh-clone behavior and leaves existing signing files untouched.
It reads the known helper-generated properties privately, resolves their
relative keystore path against the **original android/app directory**, and
passes values only to the child build environment. It supports that local
simple `key=value` format, not arbitrary escaped Java-properties files.

If the key/properties are unavailable, identify the missing private input and
ask for its authorized existing location. Do not generate a new key for an
update, echo passwords, or change the globally active GitHub account. If this
checkout already contains `android/key.properties`, verify its identity first:
Gradle gives it precedence over environment signing values.

## Build the APK

Run from the intended app checkout, for example
`/home/nilius/chadrc-home/endurain-flutter`. This command requires an authorized
existing signing input and does not copy it. Select a version for the requested
build. The last delivered APK was **0.11.1+21**; an update to it must use a
versionCode **greater than21**. The values below reproduce that known version;
change both variables deliberately for the next update. Source `pubspec.yaml`
can still show0.10.2+19 because delivered versions used build overrides.

```bash
export ENDURAIN_BUILD_NAME=0.11.1
export ENDURAIN_BUILD_NUMBER=21
mkdir -p build/local-artifacts
python3 - <<'PY'
import os
from pathlib import Path
import subprocess

repo = Path.cwd()
assert (repo / 'tool/build-local-android.sh').is_file(), 'Use the local-feature app checkout'
props_path = Path(os.environ['ENDURAIN_SIGNING_PROPERTIES']).expanduser().resolve()
props = {}
for line in props_path.read_text().splitlines():
    line = line.strip()
    if line and not line.startswith(('#', '!')):
        key, value = line.split('=', 1)
        props[key.strip()] = value.strip()
keystore = Path(props['storeFile'])
if not keystore.is_absolute():
    keystore = props_path.parent / 'app' / keystore
keystore = keystore.resolve()
assert keystore.is_file(), 'Existing update keystore is missing'
assert not (repo / 'android/key.properties').exists(), 'Verify existing local signing config before using this external-signing example'
env = dict(os.environ,
    ANDROID_KEYSTORE_PATH=str(keystore),
    ANDROID_KEYSTORE_PASSWORD=props['storePassword'],
    ANDROID_KEY_ALIAS=props['keyAlias'],
    ANDROID_KEY_PASSWORD=props['keyPassword'])
name = env['ENDURAIN_BUILD_NAME']
number = env['ENDURAIN_BUILD_NUMBER']
assert int(number) > 0
log = repo / 'build/local-artifacts' / f'release-build-{name}+{number}.log'
with log.open('wb') as output:
    result = subprocess.run([
        str(Path(env['FLUTTER_HOME']) / 'bin/flutter'), 'build', 'apk', '--release',
        '--dart-define=ENDURAIN_CRASH_REPORTING_DSN=',
        f'--build-name={name}', f'--build-number={number}'],
        cwd=repo, env=env, stdout=output, stderr=subprocess.STDOUT)
print(f'Build exit: {result.returncode}; log: {log}')
raise SystemExit(result.returncode)
PY
```

For an already configured checkout, the shorter existing-helper command is
`./tool/build-local-android.sh --build-name=… --build-number=…`, with the SDK/JDK/
Android/Gradle environment above. That helper overrides `XDG_CONFIG_HOME` to its
checkout parent's `.local-toolchain/flutter-config`; inspect that difference
before choosing it. Prefer the direct external-signing example for this fresh
clone. Neither route should bake in a remote crash-reporting DSN.

The new APK is `build/app/outputs/flutter-apk/app-release.apk`. Check the exit
status and modification time: an old APK may remain after a failed build.
A prior cached release took about174 seconds; duration varies. Tail the build
log for progress; the known Health plugin/Kotlin migration warning is not a
failure. Investigate an actual error before cleaning caches or replacing SDKs.

## Preserve and verify the actual output

With the environment/version variables still set:

```bash
artifact="build/local-artifacts/endurain-local-${ENDURAIN_BUILD_NAME}+${ENDURAIN_BUILD_NUMBER}-release.apk"
cp build/app/outputs/flutter-apk/app-release.apk "$artifact"
stat -c '%y %s %n' "$artifact"
"$ANDROID_SDK_ROOT/build-tools/36.0.0/aapt" dump badging "$artifact"
"$ANDROID_SDK_ROOT/build-tools/36.0.0/apksigner" verify --verbose --print-certs "$artifact"
sha256sum "$artifact"
git rev-parse HEAD
git status --short
```

Verify package `com.endurain.endurain.local`, requested name/code, release mode,
launcher `Endurain Local`, and certificate against the prior installed local
APK. Its public certificate SHA256 is
`3341bbf406214b746b6f893d12a353652df6c9215feb6b2e58e541c2bb9dfb6e`.
Prior builds have minSdk26/targetSdk36 and isolated SSO callback
`endurain://local-auth/sso/callback`. For manifest checks use
`$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/apkanalyzer manifest print "$artifact"`.
Record the SHA256, source commit/working changes, version and byte size. Keep
versioned older APKs; `build/local-artifacts` is Git-ignored but would be removed
by `flutter clean`. Do not commit keys, APKs or build logs.

The last code verification (19October2026) was **1577 tests passed,1 existing
skip**, analyzer clean,476 Dart files formatted. Coverage90.31%; its gate failed
only on the unchanged BLE adapter at7.69%. These are historical results, not a
fresh run in this clone. For an unchanged-source APK rebuild, do not rerun them
automatically. For code changes, follow CONTRIBUTING.md and run focused checks
plus integration checks appropriate to that change. APK verification does not
substitute for native GPS/restart/server tests on a real device.

Old verified APKs and detailed logs remain under
`/home/nilius/Documents/Codex/2026-10-18-ich-nutze-endurain-seit-einiger-zeit/artifacts/`.
No device installation or publication is part of a build-only request.
