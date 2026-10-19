# Agent handoff

For local Android APK builds and update builds, use
[android-build](.agents/skills/android-build/SKILL.md) and its linked
[build guide](BUILDING_LOCAL.md).

Never push to `endurain-project/endurain-flutter` or create a pull request
targeting that original repository. Building an APK is local work; it does not
include pushing, publishing, or installing it.

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
