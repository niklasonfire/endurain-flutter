#!/usr/bin/env bash
# Generate an add-to-app module from the current Endurain source, then publish
# its Flutter AAR and plugin AARs to an ignored local Maven repository.
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
toolchain_root="${ENDURAIN_TOOLCHAIN_ROOT:-/home/nilius/Documents/Codex/2026-10-18-ich-nutze-endurain-seit-einiger-zeit/.local-toolchain}"
export FLUTTER_HOME="${FLUTTER_HOME:-$toolchain_root/flutter}"
export JAVA_HOME="${JAVA_HOME:-/home/nilius/sdks/jdk17}"
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$toolchain_root/android-sdk}"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
export GRADLE_USER_HOME="${GRADLE_USER_HOME:-$toolchain_root/gradle-home}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$toolchain_root/flutter-config}"
export PATH="$FLUTTER_HOME/bin:$JAVA_HOME/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
module_root="$repo_root/build/osmand-poc/flutter_module"
[[ -x "$FLUTTER_HOME/bin/flutter" ]] || { echo 'Missing Flutter SDK; see BUILDING_LOCAL.md' >&2; exit 1; }
[[ -d "$ANDROID_SDK_ROOT" ]] || { echo 'Missing Android SDK; see BUILDING_LOCAL.md' >&2; exit 1; }
mkdir -p "$(dirname "$module_root")"
if [[ ! -f "$module_root/.metadata" ]]; then
  flutter create --template=module --org dev.endurain.osmand \
    --project-name endurain_frontend --no-pub "$module_root"
fi
# Keep generated platform metadata and build caches. Refresh only the source
# snapshot, including generated translations and the pinned dependency lock.
python3 - "$repo_root" "$module_root" <<'PY'
from pathlib import Path
import shutil
import sys
repo, module = map(Path, sys.argv[1:])
for name in ('lib', 'assets'):
    destination = module / name
    if destination.exists():
        shutil.rmtree(destination)
    shutil.copytree(repo / name, destination)
for name in ('pubspec.lock', 'l10n.yaml', 'analysis_options.yaml'):
    shutil.copy2(repo / name, module / name)
(module / 'test').mkdir(exist_ok=True)
# flutter create's sample tests refer to its sample app rather than ours.
for sample in (module / 'test').glob('*'):
    if sample.is_file():
        sample.unlink()
spec = (repo / 'pubspec.yaml').read_text()
spec = spec.replace('\nflutter:\n', '''
flutter:
  module:
    androidX: true
    androidPackage: dev.endurain.osmand.frontend
    iosBundleIdentifier: dev.endurain.osmand.frontend
''', 1)
(module / 'pubspec.yaml').write_text(spec)
PY
cd "$module_root"
flutter pub get --enforce-lockfile
if [[ "${1:-}" == '--prepare-only' ]]; then
  echo "Prepared $module_root"
  exit 0
fi
flutter build aar --no-debug --no-profile --build-number=1.0 \
  --target-platform="${ENDURAIN_OSMAND_TARGET_PLATFORMS:-android-arm64}" \
  --dart-define=ENDURAIN_OSMAND_HOST=true
printf 'Flutter Maven repository: %s/build/host/outputs/repo\n' "$module_root"
