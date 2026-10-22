"""Trusted Android release pipeline. No credentials are embedded in app metadata."""

import argparse
import base64
import datetime
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import urllib.request

REPOSITORY = "niklasonfire/endurain-flutter"
APPLICATION_ID = "com.endurain.endurain.local"
CERTIFICATE = "3341bbf406214b746b6f893d12a353652df6c9215feb6b2e58e541c2bb9dfb6e"
REQUIRED_STEPS = {
    "Check formatting", "Analyze", "Tests and coverage", "Android unit tests",
    "Build debug APK",
}


class SkipBuild(ValueError):
    """Successful automatic CI did not produce a publishable candidate."""


class GitHub:
    def request(self, path, method="GET", data=None, binary=None):
        url = path if path.startswith("https://") else f"https://api.github.com/repos/{REPOSITORY}/{path}"
        if not url.startswith((f"https://api.github.com/repos/{REPOSITORY}/", f"https://uploads.github.com/repos/{REPOSITORY}/")):
            raise ValueError("Untrusted GitHub endpoint")
        headers = {"Authorization": f"Bearer {os.environ['GH_TOKEN']}",
                   "Accept": "application/vnd.github+json", "X-GitHub-Api-Version": "2022-11-28"}
        body = binary if binary is not None else (json.dumps(data).encode() if data is not None else None)
        headers["Content-Type"] = "application/octet-stream" if binary is not None else "application/json"
        with urllib.request.urlopen(urllib.request.Request(url, data=body, headers=headers, method=method), timeout=60) as response:
            payload = response.read()
            return json.loads(payload) if payload else None

    def pages(self, path, key=None):
        result = []
        for page in range(1, 1001):
            data = self.request(f"{path}{'&' if '?' in path else '?'}per_page=100&page={page}")
            rows = data[key] if key else data
            result.extend(rows)
            if len(rows) < 100:
                return result
        raise ValueError("GitHub pagination limit exceeded")

    def manifest(self, release):
        assets = self.pages(f"releases/{release['id']}/assets")
        matches = [asset for asset in assets if asset['name'] == 'update.json']
        if not matches:
            if any(asset['name'].endswith('.apk') for asset in assets):
                raise ValueError("Existing APK release has no update.json; audit its build code first")
            return None
        # Draft assets require the API. Strip credentials at GitHub's asset redirect.
        class AssetRedirect(urllib.request.HTTPRedirectHandler):
            def redirect_request(self, request, *args, **kwargs):
                redirected = super().redirect_request(request, *args, **kwargs)
                if redirected:
                    redirected.remove_header('Authorization')
                return redirected

        request = urllib.request.Request(
            f"https://api.github.com/repos/{REPOSITORY}/releases/assets/{matches[0]['id']}",
            headers={'Authorization': f"Bearer {os.environ['GH_TOKEN']}",
                     'Accept': 'application/octet-stream'})
        with urllib.request.build_opener(AssetRedirect()).open(request, timeout=60) as response:
            return json.loads(response.read(1024 * 1024))


def validate_ci(run, jobs, sha):
    if not (run.get('head_sha') == sha and run.get('head_branch') == 'main'
            and run.get('head_repository', {}).get('full_name') == REPOSITORY
            and run.get('event') == 'push' and run.get('conclusion') == 'success'
            and run.get('path') == '.github/workflows/ci-self-hosted.yml'):
        raise ValueError("Commit has no successful trusted main push CI")
    checks = [job for job in jobs if job['name'] == 'Flutter and Android checks']
    if len(checks) != 1 or checks[0].get('conclusion') != 'success':
        raise ValueError("Full Android checks did not succeed")
    passed = {step['name'] for step in checks[0].get('steps', [])
              if step.get('status') == 'completed' and step.get('conclusion') == 'success'}
    if not REQUIRED_STEPS <= passed:
        raise ValueError("Required checks were skipped or failed")


def release_codes(api):
    codes = []
    for release in api.pages('releases'):
        manifest = api.manifest(release)
        if manifest is not None:
            code = manifest.get('versionCode')
            if type(code) is not int or code < 1:
                raise ValueError("Invalid published versionCode")
            codes.append(code)
    return codes


def prepare(api, event, channel, sha, version, run_number, attempt):
    if attempt != 1:
        raise ValueError("Reruns cannot rebuild or publish an allocated versionCode; start a new run")
    if channel not in ('stable', 'nightly', 'check'):
        raise ValueError("Invalid channel")
    automatic = event.get('workflow_run')
    if automatic:
        if channel != 'nightly':
            raise ValueError("Automatic builds must use nightly")
        sha = automatic['head_sha']
        runs = [api.request(f"actions/runs/{automatic['id']}")]
    else:
        if not re.fullmatch(r'[0-9a-f]{40}', sha):
            raise ValueError("source_commit must be a full lowercase commit SHA")
        runs = api.pages(f"actions/workflows/ci-self-hosted.yml/runs?head_sha={sha}&branch=main&event=push", 'workflow_runs')
    if not re.fullmatch(r'[0-9a-f]{40}', sha):
        raise ValueError("Invalid commit SHA")
    valid = False
    for run in runs:
        try:
            validate_ci(run, api.pages(f"actions/runs/{run['id']}/jobs", 'jobs'), sha)
            valid = True
            break
        except ValueError:
            continue
    if not valid:
        raise (SkipBuild if automatic else ValueError)("No complete successful main CI for this exact commit")
    if channel == 'nightly' and api.request('git/ref/heads/main')['object']['sha'] != sha:
        raise (SkipBuild if automatic else ValueError)("Stale nightly candidate")
    code = 100000 + run_number
    if not 100000 < code <= 2100000000 or code <= max(release_codes(api), default=21):
        raise ValueError("Build number is not newer than every published channel")
    if channel == 'nightly':
        contents = api.request(f'contents/pubspec.yaml?ref={sha}')
        pubspec = base64.b64decode(contents['content']).decode()
        base = re.search(r'^version: ([0-9]+\.[0-9]+\.[0-9]+)', pubspec, re.M)
        if not base:
            raise ValueError("Cannot read source version from pubspec")
        version = f"{base[1]}-nightly.{code}"
    elif not re.fullmatch(r'[0-9]+\.[0-9]+\.[0-9]+', version):
        raise ValueError("Stable/check version must be X.Y.Z")
    return {'BUILD_REQUIRED': 'true', 'SOURCE_SHA': sha, 'VERSION_NAME': version, 'VERSION_CODE': str(code), 'UPDATE_CHANNEL': channel}


def manifest_from_apk(apk, aapt, apksigner, channel, version, code, sha):
    facts = subprocess.check_output([aapt, 'dump', 'badging', str(apk)], text=True)
    signature = subprocess.check_output([apksigner, 'verify', '--print-certs', str(apk)], text=True)
    package = re.search(r"^package: name='([^']+)' versionCode='([^']+)' versionName='([^']+)'", facts, re.M)
    sdk = re.search(r"^sdkVersion:'([0-9]+)'", facts, re.M)
    abi = re.search(r"^native-code: (.+)$", facts, re.M)
    certs = re.findall(r'Signer #[0-9]+ certificate SHA-256 digest: ([a-fA-F0-9:]+)', signature)
    if not package or package.groups() != (APPLICATION_ID, str(code), version):
        raise ValueError("APK package/version does not match release inputs")
    if not sdk or not abi or abi.group(1).strip() != "'arm64-v8a'":
        raise ValueError("APK SDK or ABI metadata invalid")
    if len(certs) != 1 or certs[0].replace(':', '').lower() != CERTIFICATE:
        raise ValueError("APK certificate does not match installed distribution")
    name = f'endurain-local-{code}-arm64-v8a.apk'
    with apk.open('rb') as source:
        digest = hashlib.file_digest(source, 'sha256').hexdigest()
    return {'schemaVersion': 1, 'channel': channel, 'versionName': package[3],
            'versionCode': int(package[2]), 'commit': sha,
            'builtAt': datetime.datetime.now(datetime.timezone.utc).isoformat().replace('+00:00', 'Z'),
            'applicationId': package[1], 'minSdk': int(sdk[1]),
            'assets': [{'abi': 'arm64-v8a', 'name': name, 'size': apk.stat().st_size,
                        'sha256': digest}]}


def publish(api, manifest, apk):
    channel, code, sha = manifest['channel'], manifest['versionCode'], manifest['commit']
    asset = manifest['assets'][0]
    with apk.open('rb') as source:
        digest = hashlib.file_digest(source, 'sha256').hexdigest()
    if apk.stat().st_size != asset['size'] or digest != asset['sha256']:
        raise ValueError('APK bytes no longer match verified metadata')
    if channel not in ('stable', 'nightly'):
        raise ValueError("Check builds cannot publish")
    if code <= max(release_codes(api), default=21):
        raise ValueError("A newer or equal build was published while building")
    if channel == 'nightly' and api.request('git/ref/heads/main')['object']['sha'] != sha:
        raise ValueError("Nightly became stale during build")
    tag = 'nightly' if channel == 'nightly' else f"v{manifest['versionName']}+{code}"
    releases = api.pages('releases')
    existing = [release for release in releases if release['tag_name'] == tag]
    if channel == 'stable' and existing:
        raise ValueError("Stable tag already exists; never overwrite it")
    # Generate the changelog before moving the rolling tag.
    previous = next((item for item in releases if not item.get('draft') and
                     (item['tag_name'] == 'nightly' if channel == 'nightly'
                      else not item.get('prerelease'))), None)
    notes_input = {'tag_name': f"v{manifest['versionName']}+{code}", 'target_commitish': sha}
    if previous:
        notes_input['previous_tag_name'] = previous['tag_name']
    notes = api.request('releases/generate-notes', 'POST', notes_input)['body']
    body = f"Android {manifest['versionName']} ({code})\n\nSource: {sha}\n\n{notes}"
    release = existing[0] if existing else api.request('releases', 'POST', {
        'tag_name': tag, 'target_commitish': sha, 'name': 'Nightly' if channel == 'nightly' else tag,
        'draft': channel == 'stable', 'prerelease': channel == 'nightly', 'make_latest': 'false',
        'body': body})
    if channel == 'nightly' and (release.get('draft') or not release.get('prerelease')):
        raise ValueError("nightly must be a public prerelease")
    upload = release['upload_url'].split('{', 1)[0]
    name = manifest['assets'][0]['name']
    api.request(f'{upload}?name={name}', 'POST', binary=apk.read_bytes())
    if channel == 'nightly':
        api.request('git/refs/tags/nightly', 'PATCH', {'sha': sha, 'force': True})
    # Previous APKs remain downloadable. Only the pointer is replaced, last.
    for asset in api.pages(f"releases/{release['id']}/assets"):
        if asset['name'] == 'update.json':
            api.request(f"releases/assets/{asset['id']}", 'DELETE')
    api.request(f'{upload}?name=update.json', 'POST', binary=json.dumps(manifest, indent=2).encode())
    if channel == 'stable':
        api.request(f"releases/{release['id']}", 'PATCH', {'draft': False, 'make_latest': 'true'})
    else:
        api.request(f"releases/{release['id']}", 'PATCH', {'body': body, 'make_latest': 'false'})


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('command', choices=['prepare', 'manifest', 'publish'])
    parser.add_argument('--apk', type=Path, default=Path('build/app/outputs/flutter-apk/app-release.apk'))
    parser.add_argument('--manifest', type=Path, default=Path('build/update.json'))
    args = parser.parse_args()
    if args.command == 'prepare':
        event = json.loads(Path(os.environ['GITHUB_EVENT_PATH']).read_text())
        try:
            values = prepare(GitHub(), event, os.environ['CHANNEL'], os.environ.get('SOURCE_COMMIT', ''),
                             os.environ.get('INPUT_VERSION_NAME', ''), int(os.environ['GITHUB_RUN_NUMBER']), int(os.environ['GITHUB_RUN_ATTEMPT']))
        except SkipBuild as reason:
            print(f"Skipping automatic Android build: {reason}")
            values = {'BUILD_REQUIRED': 'false'}
        with open(os.environ['GITHUB_OUTPUT'], 'a') as output:
            output.writelines(f'{key}={value}\n' for key, value in values.items())
    elif args.command == 'manifest':
        metadata = manifest_from_apk(args.apk, os.environ['AAPT'], os.environ['APKSIGNER'],
                                    os.environ['UPDATE_CHANNEL'], os.environ['VERSION_NAME'],
                                    int(os.environ['VERSION_CODE']), os.environ['SOURCE_SHA'])
        args.manifest.write_text(json.dumps(metadata, indent=2) + '\n')
    else:
        publish(GitHub(), json.loads(args.manifest.read_text()), args.apk)


if __name__ == '__main__':
    main()
