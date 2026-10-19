FROM teqsas/ci-runner:latest

# Update only this fork's runner; leave the existing host pools unchanged.
ARG RUNNER_VERSION=2.338.0
ARG RUNNER_SHA256=af4b794c1bc41d73d40535e3fe092a39f9679cd8d965954c2aca25a05ca41d32
USER root
RUN curl --fail --location --retry 3 \
      "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" \
      --output /tmp/runner.tar.gz \
    && echo "${RUNNER_SHA256}  /tmp/runner.tar.gz" | sha256sum --check - \
    && rm -rf /actions-runner/bin /actions-runner/externals \
    && tar -xzf /tmp/runner.tar.gz -C /actions-runner \
    && rm /tmp/runner.tar.gz

# Preserve this host's existing local actions/cache redirection.
RUN python3 - <<'PY'
from pathlib import Path
worker = Path('/actions-runner/bin/Runner.Worker.dll')
old = 'ACTIONS_RESULTS_URL'.encode('utf-16le')
new = 'ACTIONS_RESULTS_ORL'.encode('utf-16le')
data = worker.read_bytes()
assert data.count(old) == 1, 'Review the cache patch for this runner version'
worker.write_bytes(data.replace(old, new))
PY
