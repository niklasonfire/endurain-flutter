# Agent handoff

For local Android APK builds and update builds, use
[android-build](.agents/skills/android-build/SKILL.md) and its linked
[build guide](BUILDING_LOCAL.md).

Building an APK is local work; it does not include pushing, publishing,
or installing it. Upstream contributions follow the workflow below.

## Upstream check for features and fixes

Before implementing a new feature or bug fix, check
`endurain-project/endurain-flutter` for relevant open and closed issues,
open pull requests, and changes already merged on its current default branch.
Do this before implementation even if the local branch already exists.
For related follow-up work, revisit upstream when the scope changes or new
evidence makes the earlier check stale.

Briefly report the links, current status, and implications, including when
no relevant match was found. Prefer adopting an existing upstream solution
or aligning with ongoing work over creating a divergent implementation.
If upstream cannot be reached, report the limitation and label the check
incomplete; continue independent local work without claiming upstream was
checked.

Keep generally applicable fixes separate from fork-specific changes so they
can be contributed back. When a relevant upstream issue exists, retain its
reference and prepare the fix so it can address that issue. Before preparing
an upstream contribution, read upstream's current contribution requirements.

An upstream contribution is allowed when explicitly requested by the user:
push a focused branch to our fork and open a PR targeting
`endurain-project/endurain-flutter`. The initial upstream check is read-only;
it does not authorize posting issues/comments, pushing, or opening a PR.

## Branch workflow

Before editing, inspect the current branch and working tree. Start each new
feature, bug fix, CI change, or documentation task on a focused branch from
up-to-date `origin/main`: `feat/<topic>`, `fix/<topic>`, `ci/<topic>`, or
`docs/<topic>`. Fetch origin before branching; if unavailable, report that
freshness could not be verified. Continue related follow-up work on its
existing branch.

Preserve existing changes. If unrelated work prevents a clean branch from
`origin/main`, use an isolated worktree. Do not move unrelated changes into
the new task or retroactively reorganize work already on `main`.

Integrate through a pull request targeting `main` in
`niklasonfire/endurain-flutter`. Local branch creation is authorized; push,
PR creation, and merging require an explicit user instruction covering that
action. A request to implement or build alone does not authorize them.

## Agent skills

Repository-wide skills live in [`.agents/skills`](.agents/skills/README.md).
This includes Matt Pocock's published engineering and productivity skills,
with their supporting files and pinned source revision. Root agents and
subagents should use these repository-local copies instead of temporary or
machine-specific copies.

Read the relevant `SKILL.md` before using a skill and honor its invocation
rules. Frequently used workflows include [implement](.agents/skills/implement/SKILL.md),
[implement-spec](.agents/skills/implement-spec/SKILL.md),
[tdd](.agents/skills/tdd/SKILL.md), and
[code-review](.agents/skills/code-review/SKILL.md). Existing repository rules
above and the user's instructions take precedence.
