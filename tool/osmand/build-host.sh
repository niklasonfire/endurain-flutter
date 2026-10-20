#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
export ENDURAIN_TOOLCHAIN_ROOT=${ENDURAIN_TOOLCHAIN_ROOT:-/home/nilius/Documents/Codex/2026-10-18-ich-nutze-endurain-seit-einiger-zeit/.local-toolchain}
export FLUTTER_HOME=${FLUTTER_HOME:-$ENDURAIN_TOOLCHAIN_ROOT/flutter}
export JAVA_HOME=${JAVA_HOME:-/home/nilius/sdks/jdk17}
export ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT:-$ENDURAIN_TOOLCHAIN_ROOT/android-sdk}
export ANDROID_HOME=$ANDROID_SDK_ROOT
export GRADLE_USER_HOME=${GRADLE_USER_HOME:-$ENDURAIN_TOOLCHAIN_ROOT/gradle-home}
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$ENDURAIN_TOOLCHAIN_ROOT/flutter-config}
export PATH="$FLUTTER_HOME/bin:$JAVA_HOME/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
export ENDURAIN_FLUTTER_REPO=${ENDURAIN_FLUTTER_REPO:-$repo/build/osmand-poc/flutter_module/build/host/outputs/repo}
export ENDURAIN_SIGNING_PROPERTIES=${ENDURAIN_SIGNING_PROPERTIES:-/home/nilius/Documents/Codex/2026-10-18-ich-nutze-endurain-seit-einiger-zeit/endurain-flutter/android/key.properties}
python3 "$repo/tool/osmand/prepare.py"
python3 - "$repo" <<'PY'
import os
from pathlib import Path
import subprocess
import sys
repo = Path(sys.argv[1])
props_path = Path(os.environ['ENDURAIN_SIGNING_PROPERTIES']).resolve()
if not props_path.is_file():
    raise SystemExit('Existing signing properties are missing: ' + str(props_path))
props = {}
for line in props_path.read_text().splitlines():
    line = line.strip()
    if line and not line.startswith(('#', '!')):
        key, value = line.split('=', 1)
        props[key.strip()] = value.strip()
key = Path(props['storeFile'])
if not key.is_absolute():
    key = props_path.parent / 'app' / key
key = key.resolve()
if not key.is_file():
    raise SystemExit('Existing signing keystore is missing')
env = dict(os.environ, ANDROID_KEYSTORE_PATH=str(key),
           ANDROID_KEYSTORE_PASSWORD=props['storePassword'], ANDROID_KEY_ALIAS=props['keyAlias'],
           ANDROID_KEY_PASSWORD=props['keyPassword'])
subprocess.run(['bash', './gradlew', ':OsmAnd:assembleAndroidFullOpenglArm64Release',
                '--console=plain', '--max-workers=4', '-Dorg.gradle.jvmargs=-Xmx5g'],
               cwd=repo / 'poc/osmand/upstream', env=env, check=True)
PY
