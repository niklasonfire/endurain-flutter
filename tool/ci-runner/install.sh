#!/usr/bin/env bash
# Explicitly installs a persistent privileged runner for this fork on this host.
set -euo pipefail
source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
test "$(id -un)" = nilius
docker image inspect teqsas/ci-runner:latest >/dev/null
docker network inspect ci-net >/dev/null
install -d "$HOME/ci-runners/endurain-flutter" "$HOME/.config/systemd/user"
install -m 0755 "$source_dir/run.sh" "$source_dir/init.sh" "$HOME/ci-runners/endurain-flutter/"
install -m 0644 "$source_dir/gh-runner-endurain.service" "$HOME/.config/systemd/user/"
loginctl enable-linger "$(id -un)"
systemctl --user daemon-reload
systemctl --user enable --now gh-runner-endurain.service
systemctl --user status gh-runner-endurain.service --no-pager --lines=5
