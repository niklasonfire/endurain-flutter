"""Android publisher contract at its CI, APK-tool and GitHub boundaries."""

import base64
import copy
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from android_updates import (
    CERTIFICATE, REPOSITORY, SkipBuild, manifest_from_apk, prepare, publish,
)

SHA = 'a' * 40
STEPS = ['Check formatting', 'Analyze', 'Tests and coverage',
         'Android unit tests', 'Build debug APK']


def metadata(channel='stable', code=100042):
    return {
        'schemaVersion': 1, 'channel': channel, 'versionName': '0.12.0',
        'versionCode': code, 'commit': SHA, 'builtAt': '2026-10-22T10:00:00Z',
        'applicationId': 'com.endurain.endurain.local', 'minSdk': 26,
        'assets': [{'name': f'endurain-local-{code}-arm64-v8a.apk',
                    'abi': 'arm64-v8a', 'size': 3,
                    'sha256': 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad'}],
    }


class GitHubFixture:
    """A GitHub API boundary double, recording publicly observable states."""

    def __init__(self):
        self.releases = []
        self.head = SHA
        self.comparison = {'status': 'ahead', 'files': [{'filename': 'lib/main.dart', 'status': 'modified'}]}
        self.run = {'id': 1, 'head_sha': SHA, 'head_branch': 'main',
                    'head_repository': {'full_name': REPOSITORY},
                    'event': 'push', 'conclusion': 'success',
                    'path': '.github/workflows/ci-self-hosted.yml'}
        self.jobs = [{'name': 'Flutter and Android checks', 'conclusion': 'success',
                      'steps': [{'name': step, 'status': 'completed',
                                 'conclusion': 'success'} for step in STEPS]}]
        self.snapshots = []
        self.tag = None
        self.fail_apk = False

    def pages(self, path, key=None):
        if path == 'releases':
            return copy.deepcopy(self.releases)
        if path.endswith('/jobs'):
            return copy.deepcopy(self.jobs)
        if path.startswith('actions/workflows/'):
            return [copy.deepcopy(self.run)]
        if path.endswith('/assets'):
            return copy.deepcopy(self.releases[0]['assets'])
        raise AssertionError(path)

    def manifest(self, release):
        found = [asset for asset in release['assets'] if asset['name'] == 'update.json']
        return json.loads(found[0]['bytes']) if found else None

    def request(self, path, method='GET', data=None, binary=None):
        if method == 'GET':
            if path.startswith('actions/runs/'):
                return copy.deepcopy(self.run)
            if path == 'git/ref/heads/main':
                return {'object': {'sha': self.head}}
            if path.startswith('compare/'):
                return copy.deepcopy(self.comparison)
            if path.startswith('contents/pubspec.yaml'):
                return {'content': base64.b64encode(b'version: 0.12.0+21\n').decode()}
        if path == 'releases/generate-notes':
            return {'body': '## Changes\n* Improve recording'}
        if path == 'releases' and method == 'POST':
            release = dict(data, id=7, assets=[], upload_url=(
                f'https://uploads.github.com/repos/{REPOSITORY}/releases/7/assets{{?name}}'))
            self.releases.append(release)
            self.tag = data['target_commitish']
            result = copy.deepcopy(release)
        elif '?name=' in path:
            name = path.split('?name=')[1]
            if self.fail_apk and name.endswith('.apk'):
                raise OSError('upload interrupted')
            self.releases[0]['assets'].append({'id': len(self.releases[0]['assets']) + 1,
                                                'name': name, 'bytes': binary})
            result = {}
        elif path == 'git/refs/tags/nightly':
            self.tag = data['sha']
            result = {}
        elif path.startswith('releases/assets/') and method == 'DELETE':
            asset_id = int(path.rsplit('/', 1)[1])
            self.releases[0]['assets'] = [asset for asset in self.releases[0]['assets']
                                           if asset['id'] != asset_id]
            result = None
        elif path == 'releases/7' and method == 'PATCH':
            self.releases[0].update(data)
            result = copy.deepcopy(self.releases[0])
        else:
            raise AssertionError((path, method))
        self.snapshots.append(copy.deepcopy(self.releases))
        return result


class PublisherContractTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.apk = Path(self.temp.name) / 'app.apk'
        self.apk.write_bytes(b'abc')
        self.api = GitHubFixture()

    def test_changed_apk_is_rejected_before_touching_release(self):
        self.apk.write_bytes(b'bad')
        with self.assertRaisesRegex(ValueError, 'APK bytes'):
            publish(self.api, metadata(), self.apk)
        self.assertEqual(self.api.releases, [])

    def test_stable_becomes_public_only_with_both_assets(self):
        publish(self.api, metadata(), self.apk)
        public = [state[0] for state in self.api.snapshots if not state[0]['draft']]
        self.assertTrue(public)
        for release in public:
            self.assertEqual({asset['name'] for asset in release['assets']},
                             {'endurain-local-100042-arm64-v8a.apk', 'update.json'})
            self.assertFalse(release['prerelease'])
            self.assertEqual(release['tag_name'], 'v0.12.0+100042')
            self.assertIn('Improve recording', release['body'])

    def test_nightly_pointer_always_references_an_uploaded_apk(self):
        old = metadata('nightly', 100041)
        self.api.releases = [{'id': 7, 'tag_name': 'nightly', 'draft': False,
                              'prerelease': True, 'assets': [
                                  {'id': 1, 'name': old['assets'][0]['name'], 'bytes': b'abc'},
                                  {'id': 2, 'name': 'update.json', 'bytes': json.dumps(old).encode()}],
                              'upload_url': f'https://uploads.github.com/repos/{REPOSITORY}/releases/7/assets{{?name}}'}]
        self.api.tag = 'b' * 40
        publish(self.api, metadata('nightly'), self.apk)
        for snapshot in self.api.snapshots:
            release = snapshot[0]
            pointer = self.api.manifest(release)
            if pointer is not None:
                self.assertIn(pointer['assets'][0]['name'],
                              {asset['name'] for asset in release['assets']})
        final = self.api.releases[0]
        self.assertEqual(self.api.manifest(final)['versionCode'], 100042)
        self.assertIn(old['assets'][0]['name'], {asset['name'] for asset in final['assets']})
        self.assertTrue(final['prerelease'])
        self.assertEqual(self.api.tag, SHA)

    def test_failed_upload_leaves_stable_private(self):
        self.api.fail_apk = True
        with self.assertRaises(OSError):
            publish(self.api, metadata(), self.apk)
        self.assertTrue(all(release['draft'] for release in self.api.releases))

    def test_existing_higher_code_in_either_channel_blocks_publication(self):
        for channel in ('stable', 'nightly'):
            with self.subTest(channel=channel):
                self.api.releases = [{'id': 7, 'tag_name': 'previous', 'assets': [
                    {'name': 'update.json', 'bytes': json.dumps(metadata(channel, 100043)).encode()}]}]
                before = copy.deepcopy(self.api.releases)
                with self.assertRaisesRegex(ValueError, 'newer or equal'):
                    publish(self.api, metadata(), self.apk)
                self.assertEqual(self.api.releases, before)

    def test_nightly_that_became_stale_is_not_published(self):
        self.api.head = 'b' * 40
        with self.assertRaisesRegex(ValueError, 'stale'):
            publish(self.api, metadata('nightly'), self.apk)
        self.assertEqual(self.api.releases, [])


class BuildGateTests(unittest.TestCase):
    def setUp(self):
        self.api = GitHubFixture()

    def prepare(self, channel='stable', attempt=1, automatic=False):
        event = {'workflow_run': {'id': 1, 'head_sha': SHA}} if automatic else {}
        return prepare(self.api, event, channel, SHA, '0.12.0', 42, attempt)

    def test_manual_stable_and_automatic_nightly_share_the_same_code(self):
        stable = self.prepare()
        nightly = self.prepare('nightly', automatic=True)
        self.assertEqual(stable['VERSION_CODE'], '100042')
        self.assertEqual(nightly['VERSION_CODE'], '100042')
        self.assertEqual(nightly['VERSION_NAME'], '0.12.0-nightly.100042')
        self.assertEqual(nightly['SOURCE_SHA'], SHA)

    def test_every_required_check_must_actually_have_run(self):
        for index in range(len(STEPS)):
            with self.subTest(step=STEPS[index]):
                self.api = GitHubFixture()
                self.api.jobs[0]['steps'][index]['conclusion'] = 'skipped'
                with self.assertRaises(SkipBuild):
                    self.prepare('nightly', automatic=True)
        self.api.jobs = []
        with self.assertRaises(ValueError):
            self.prepare()

    def test_wrong_sha_branch_repository_event_or_workflow_cannot_authorize_signing(self):
        mutations = [('head_sha', 'b' * 40), ('head_branch', 'feature'),
                     ('head_repository', {'full_name': 'someone/other'}),
                     ('event', 'pull_request'), ('path', '.github/workflows/other.yml'),
                     ('conclusion', 'failure')]
        for field, value in mutations:
            with self.subTest(field=field):
                self.api = GitHubFixture()
                self.api.run[field] = value
                with self.assertRaises(ValueError):
                    self.prepare()

    def test_documentation_advance_preserves_verified_nightly_source(self):
        self.api.head = 'b' * 40
        self.api.comparison = {'status': 'ahead', 'files': [
            {'filename': 'docs/updates.md', 'status': 'modified'},
            {'filename': 'docs/screenshots/update.png', 'status': 'added'}]}
        result = self.prepare('nightly', automatic=True)
        self.assertEqual(result['SOURCE_SHA'], SHA)
        with tempfile.TemporaryDirectory() as directory:
            apk = Path(directory) / 'app.apk'
            apk.write_bytes(b'abc')
            publish(self.api, metadata('nightly'), apk)
        self.assertEqual(self.api.tag, SHA)

    def test_code_changes_nonancestors_and_incomplete_comparisons_stay_stale(self):
        comparisons = [
            {'status': 'ahead', 'files': [{'filename': 'lib/main.dart'}]},
            {'status': 'behind', 'files': [{'filename': 'README.md'}]},
            {'status': 'diverged', 'files': [{'filename': 'README.md'}]},
            {'status': 'ahead'},
            {'status': 'ahead', 'files': [{'filename': 'README.md'}] * 300},
            {'status': 'ahead', 'files': [{'filename': 'README.md',
                                           'previous_filename': 'lib/main.dart'}]},
        ]
        for comparison in comparisons:
            with self.subTest(comparison=comparison):
                self.api.head = 'b' * 40
                self.api.comparison = comparison
                with self.assertRaises(SkipBuild):
                    self.prepare('nightly', automatic=True)
                with tempfile.TemporaryDirectory() as directory:
                    apk = Path(directory) / 'app.apk'
                    apk.write_bytes(b'abc')
                    with self.assertRaisesRegex(ValueError, 'stale'):
                        publish(self.api, metadata('nightly'), apk)
                self.assertEqual(self.api.releases, [])

    def test_stale_automatic_candidate_skips_and_reruns_refuse_new_build(self):
        self.api.head = 'b' * 40
        with self.assertRaises(SkipBuild):
            self.prepare('nightly', automatic=True)
        with self.assertRaisesRegex(ValueError, 'Reruns'):
            self.prepare(attempt=2)

    def test_allocation_must_exceed_every_published_or_draft_code(self):
        for channel in ('nightly', 'stable'):
            with self.subTest(channel=channel):
                self.api.releases = [{'id': 7, 'draft': True, 'assets': [
                    {'name': 'update.json', 'bytes': json.dumps(metadata(channel, 100042)).encode()}]}]
                with self.assertRaisesRegex(ValueError, 'not newer'):
                    self.prepare()


class ApkManifestTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.apk = Path(self.temp.name) / 'app.apk'
        self.apk.write_bytes(b'abc')
        self.facts = ("package: name='com.endurain.endurain.local' versionCode='100042' "
                      "versionName='0.12.0' platformBuildVersionName='16'\n"
                      "sdkVersion:'26'\nnative-code: 'arm64-v8a'\n")
        self.signature = f'Signer #1 certificate SHA-256 digest: {CERTIFICATE}\n'

    def manifest(self):
        # APK tooling is the external boundary. Metadata validation stays real.
        with patch('subprocess.check_output', side_effect=[self.facts, self.signature]):
            return manifest_from_apk(self.apk, 'aapt', 'apksigner', 'stable',
                                     '0.12.0', 100042, SHA)

    def test_manifest_uses_verified_apk_facts_and_bytes(self):
        actual = self.manifest()
        expected = metadata()
        expected['builtAt'] = actual['builtAt']
        self.assertEqual(actual, expected)
        self.assertTrue(actual['builtAt'].endswith('Z'))

    def test_package_version_code_and_abi_mismatches_fail(self):
        baseline = self.facts
        for old, replacement in [('com.endurain.endurain.local', 'com.other.app'),
                                 ('100042', '100041'), ('0.12.0', '0.11.0'),
                                 ('arm64-v8a', 'x86_64')]:
            with self.subTest(field=old):
                self.facts = baseline.replace(old, replacement)
                with self.assertRaises(ValueError):
                    self.manifest()

    def test_another_certificate_or_multiple_signers_fail(self):
        for signature in ['Signer #1 certificate SHA-256 digest: ' + '0' * 64,
                          self.signature + self.signature.replace('#1', '#2')]:
            with self.subTest(signature=signature):
                self.signature = signature
                with self.assertRaisesRegex(ValueError, 'certificate'):
                    self.manifest()


if __name__ == '__main__':
    unittest.main()
