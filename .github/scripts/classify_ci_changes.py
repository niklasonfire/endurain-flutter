"""Select expensive CI jobs; uncertainty always runs verification."""

import json
import os
from pathlib import PurePosixPath
import subprocess


def documentation(path):
    file = PurePosixPath(path)
    return file.suffix.lower() == ".md" or (
        path.startswith("docs/screenshots/")
        and file.suffix.lower() in {".png", ".jpg", ".jpeg", ".webp", ".gif", ".svg"}
    )


def select_checks(event_name, paths):
    # Manual runs remain an escape hatch, even without a file comparison.
    if event_name == "workflow_dispatch" or paths is None:
        return True, True
    code = [path for path in paths if not documentation(path)]
    if event_name == "push":
        return bool(code), bool(code)
    if event_name == "pull_request":
        ios = any(
            path.startswith(("ios/", ".github/actions/"))
            or path in {
                "pubspec.yaml",
                "pubspec.lock",
                ".github/workflows/ios.yml",
                ".github/workflows/classify-ci-changes.yml",
                ".github/scripts/classify_ci_changes.py",
            }
            for path in code
        )
        return bool(code), ios
    return True, True


def git(*args):
    return subprocess.check_output(["git", *args])


def changed_paths(event_name, event):
    try:
        if event_name == "pull_request":
            base = event["pull_request"]["base"]["sha"]
            head = event["pull_request"]["head"]["sha"]
            # Compare the full PR against its merge base, not just its last push.
            base = git("merge-base", base, head).decode().strip()
        elif event_name == "push":
            base, head = event["before"], event["after"]
        else:
            return None
        # Disabling rename detection includes both the old and new path.
        # A code -> docs rename must still trigger verification.
        return git("diff", "--no-renames", "--name-only", "-z", base, head, "--").decode(
            "utf-8", errors="surrogateescape"
        ).split("\0")[:-1]
    except (KeyError, subprocess.CalledProcessError):
        print("Cannot determine changed files; running all checks.")
        return None


def main():
    event_name = os.environ["GITHUB_EVENT_NAME"]
    with open(os.environ["GITHUB_EVENT_PATH"], encoding="utf-8") as source:
        event = json.load(source)
    run_ci, run_ios = select_checks(event_name, changed_paths(event_name, event))
    with open(os.environ["GITHUB_OUTPUT"], "a", encoding="utf-8") as output:
        output.write(f"run_ci={str(run_ci).lower()}\nrun_ios={str(run_ios).lower()}\n")
    print(f"Run Flutter/Android: {run_ci}; run iOS: {run_ios}")


if __name__ == "__main__":
    main()
