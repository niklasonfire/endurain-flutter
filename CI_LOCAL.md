# GitHub Actions on the local runner

The fork `niklasonfire/endurain-flutter` uses a separate repository-scoped,
ephemeral Docker runner on this PC. The existing organization and
`wildfire_monitor` pools remain independent. Its labels are
`self-hosted, linux, x64, dind, endurain-flutter`.

## Workflows

`Local runner CI` runs on pushes to `main`, `feat/**`, `fix/**`, and `ci/**`,
on pull requests originating in this fork, and by manual dispatch. A single
job runs formatting, analysis, tests and coverage, native Android unit tests,
and an arm64 debug APK build in sequence. The APK is uploaded as a workflow
artifact. Set `smoke_only=true` on a manual dispatch to verify the runner,
Flutter version, JDK, Android build tools, and Docker without running the suite.

The inherited `CI` jobs are skipped in this fork because their private upstream
builder image is unavailable here. `Build Android` also selects this local
runner in the fork, without the upstream job container. Its existing release
version validation, signing checks, and artifact/release upload remain in place.
It requires the repository secrets `ANDROID_KEYSTORE_BASE64`,
`ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, and
`ANDROID_UPLOAD_CERT_SHA256`. No signing secrets are installed by runner setup.
The local APK signing key is never mounted into CI.

`Build CI builder image` uses this runner in the fork and publishes only to
`ghcr.io/niklasonfire/endurain-flutter-ci`. The GitLab mirror job is restricted
to the original repository. The lightweight contributor checks continue to
use GitHub-hosted runners.

## Host installation

The source configuration is in `tool/ci-runner/`. Installation is an explicit
persistent host change:

```bash
bash tool/ci-runner/install.sh
```

This copies the launch scripts to `~/ci-runners/endurain-flutter/`, installs
`~/.config/systemd/user/gh-runner-endurain.service`, enables user lingering for
startup without an interactive login, and enables the service. It requires
the existing `teqsas/ci-runner:latest` image, `ci-net` network, Docker access,
and the saved `niklasonfire` GitHub CLI credential with repository admin rights.
It does not switch the CLI's active account.

Installation builds `endurain/ci-runner:2.338.0` from the existing host image,
updating only the Actions runner to the pinned official release with its
SHA256 verified. The existing runner pools keep their original image. Update
the pinned version/checksum and image references here when GitHub retires it.

The launcher obtains a short-lived repository registration token for each
container; the long-lived GitHub credential stays on the host. Each runner
accepts one job and is then replaced by systemd. Containers are privileged
for the existing Docker-in-Docker setup, without the host Docker socket.
Only this fork's trusted code should run here. Foreign fork PRs do not select
this runner in the provided workflow.

On first start, `init.sh` copies the existing Flutter, Android SDK and JDK17
from read-only host mounts into separate Docker volumes. Jobs cannot modify
the host SDKs. The exact host source paths are recorded in `run.sh` and
[BUILDING_LOCAL.md](BUILDING_LOCAL.md). SDK volumes are seeded once; changing
the toolchain requires deliberately reseeding these volumes while stopped.
The runner uses the existing local Actions cache server. Flutter pub, Gradle,
SDKs and the inner Docker image store have dedicated persistent volumes.

```bash
systemctl --user status gh-runner-endurain.service
journalctl --user -u gh-runner-endurain.service -n 50 --no-pager
systemctl --user stop gh-runner-endurain.service
systemctl --user start gh-runner-endurain.service
```

Stop only when no job is running. To disable this runner permanently:

```bash
systemctl --user disable --now gh-runner-endurain.service
```

This preserves caches and the other runner pools. User lingering is shared
with all user services; do not disable it without checking those services.

Verify the online runner at
<https://github.com/niklasonfire/endurain-flutter/settings/actions/runners>,
then run `Local runner CI` on the desired branch. Workflow changes must be
pushed to this fork before GitHub can execute them. Workflows in this checkout
must never be pushed to `endurain-project/endurain-flutter`.
