"""Policy and Git-diff regressions for the CI change classifier."""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

from classify_ci_changes import changed_paths, select_checks


class SelectionTests(unittest.TestCase):
    def test_documentation_skips_builds(self):
        for event in ("push", "pull_request"):
            for paths in (["README.md"], ["AGENTS.md", "docs/screenshots/home.png"], []):
                with self.subTest(event=event, paths=paths):
                    self.assertEqual(select_checks(event, paths), (False, False))

    def test_mixed_and_unknown_files_trigger_verification(self):
        for path in ("lib/main.dart", "android/app/build.gradle", "assets/icon.png",
                     "docs/example.dart", "new-config.json"):
            with self.subTest(path=path):
                paths = ["README.md", path]
                self.assertEqual(select_checks("push", paths), (True, True))
                self.assertEqual(select_checks("pull_request", paths), (True, False))

    def test_ios_pr_scope(self):
        for path in ("ios/Runner/AppDelegate.swift", "pubspec.yaml", "pubspec.lock",
                     ".github/actions/setup-flutter/action.yml",
                     ".github/workflows/ios.yml",
                     ".github/workflows/classify-ci-changes.yml",
                     ".github/scripts/classify_ci_changes.py"):
            with self.subTest(path=path):
                self.assertEqual(select_checks("pull_request", [path]), (True, True))

    def test_manual_and_uncertain_comparisons_run_all_checks(self):
        self.assertEqual(select_checks("workflow_dispatch", ["README.md"]), (True, True))
        for event in ("push", "pull_request"):
            self.assertEqual(select_checks(event, None), (True, True))


class GitComparisonTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.previous = os.getcwd()
        os.chdir(self.temp.name)
        self.git("init", "-q")
        self.git("config", "user.name", "CI test")
        self.git("config", "user.email", "ci@example.invalid")
        Path("app.dart").write_text("code\n")
        self.base = self.commit()

    def tearDown(self):
        os.chdir(self.previous)
        self.temp.cleanup()

    def git(self, *args):
        return subprocess.check_output(["git", *args], stderr=subprocess.DEVNULL).decode().strip()

    def commit(self):
        self.git("add", ".")
        self.git("commit", "-qm", "test")
        return self.git("rev-parse", "HEAD")

    def test_code_renamed_to_markdown_still_runs_checks(self):
        Path("app.dart").rename("README.md")
        head = self.commit()
        paths = changed_paths("push", {"before": self.base, "after": head})
        self.assertEqual(set(paths), {"app.dart", "README.md"})
        self.assertEqual(select_checks("push", paths), (True, True))

    def test_pr_includes_code_from_earlier_commits(self):
        Path("app.dart").write_text("updated\n")
        self.commit()
        Path("README.md").write_text("docs\n")
        head = self.commit()
        paths = changed_paths("pull_request", {"pull_request": {
            "base": {"sha": self.base}, "head": {"sha": head}}})
        self.assertEqual(set(paths), {"app.dart", "README.md"})

    def test_pr_uses_merge_base_when_target_branch_has_advanced(self):
        Path("README.md").write_text("PR documentation\n")
        head = self.commit()
        self.git("checkout", "-q", self.base)
        Path("app.dart").write_text("target branch code\n")
        target = self.commit()
        paths = changed_paths("pull_request", {"pull_request": {
            "base": {"sha": target}, "head": {"sha": head}}})
        self.assertEqual(paths, ["README.md"])
        self.assertEqual(select_checks("pull_request", paths), (False, False))

    def test_cli_writes_github_outputs(self):
        Path("README.md").write_text("docs\n")
        head = self.commit()
        Path("event.json").write_text(json.dumps({"before": self.base, "after": head}))
        output = Path("outputs")
        env = dict(os.environ, GITHUB_EVENT_NAME="push",
                   GITHUB_EVENT_PATH=str(Path("event.json").resolve()),
                   GITHUB_OUTPUT=str(output.resolve()))
        script = Path(__file__).resolve().with_name("classify_ci_changes.py")
        subprocess.run(["python3", str(script)], env=env, check=True, capture_output=True)
        self.assertEqual(output.read_text(), "run_ci=false\nrun_ios=false\n")

    def test_missing_before_commit_falls_back_to_full_ci(self):
        paths = changed_paths("push", {"before": "0" * 40, "after": self.base})
        self.assertEqual(select_checks("push", paths), (True, True))


if __name__ == "__main__":
    unittest.main()
