#!/usr/bin/env bash
# Repository-scoped ephemeral runner; the PAT stays outside the job container.
set -euo pipefail
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"
export DBUS_SESSION_BUS_ADDRESS=unix:path=/nonexistent
runner_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
toolchain=/home/nilius/Documents/Codex/2026-10-18-ich-nutze-endurain-seit-einiger-zeit/.local-toolchain
for source_dir in "$toolchain/flutter" "$toolchain/android-sdk" /home/nilius/sdks/jdk17; do
  test -d "$source_dir"
done
docker image inspect teqsas/ci-runner:latest >/dev/null
docker network inspect ci-net >/dev/null

# Use the explicitly selected existing account without changing gh's active user.
GH_TOKEN="$(gh auth token --hostname github.com --user niklasonfire)"
export GH_TOKEN
RUNNER_TOKEN="$(gh api --method POST repos/niklasonfire/endurain-flutter/actions/runners/registration-token --jq .token)"
export RUNNER_TOKEN
unset GH_TOKEN

exec docker run --rm --init --name gh-runner-endurain-1 \
  --privileged --network ci-net \
  -e RUNNER_TOKEN -e RUNNER_SCOPE=repo \
  -e REPO_URL=https://github.com/niklasonfire/endurain-flutter \
  -e RUNNER_NAME_PREFIX=endurain-local \
  -e LABELS=self-hosted,linux,x64,dind,endurain-flutter \
  -e EPHEMERAL=1 -e DISABLE_AUTOMATIC_DEREGISTRATION=true \
  -e START_DOCKER_SERVICE=true -e RUN_AS_ROOT=true \
  -e ACTIONS_RESULTS_URL=http://gha-cache:3000/ \
  -e FLUTTER_HOME=/opt/flutter -e ANDROID_SDK_ROOT=/opt/android-sdk \
  -e ANDROID_HOME=/opt/android-sdk -e JAVA_HOME=/opt/jdk17 \
  -e GRADLE_USER_HOME=/opt/gradle-home -e XDG_CONFIG_HOME=/opt/flutter-config \
  --mount "type=bind,src=$toolchain/flutter,dst=/seed/flutter,readonly" \
  --mount "type=bind,src=$toolchain/android-sdk,dst=/seed/android-sdk,readonly" \
  --mount type=bind,src=/home/nilius/sdks/jdk17,dst=/seed/jdk17,readonly \
  --mount "type=bind,src=$runner_dir/init.sh,dst=/endurain-init.sh,readonly" \
  -v endurain-flutter-sdk:/opt/flutter \
  -v endurain-android-sdk:/opt/android-sdk \
  -v endurain-jdk17:/opt/jdk17 \
  -v endurain-gradle:/opt/gradle-home \
  -v endurain-pub:/root/.pub-cache \
  -v ci-dind-endurain-1:/var/lib/docker \
  --entrypoint /bin/bash teqsas/ci-runner:latest /endurain-init.sh
