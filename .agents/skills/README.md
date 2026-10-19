# Repository agent skills

The directories here are the canonical, repository-local skill installation.
Codex discovers `.agents/skills/` throughout this repository, including work by
subagents. Agents can also follow this catalog from the root `AGENTS.md`.
Read a skill's `SKILL.md` and its linked resources before applying it. Preserve
its invocation rules, including `disable-model-invocation` where present.

## Matt Pocock's published bundle

All 27 skills from the official plugin manifest are installed with their
supporting files. Source: [mattpocock/skills](https://github.com/mattpocock/skills),
plugin version `1.3.1`, pinned commit
[`5beb35b040e3de97e54fa9e386d7e42d15c295c2`](https://github.com/mattpocock/skills/tree/5beb35b040e3de97e54fa9e386d7e42d15c295c2).
The upstream skill files are unmodified. The published bundle includes
engineering and productivity skills; upstream experimental and miscellaneous
folders are not part of that bundle.

Provenance is recorded in [matt-pocock-source.json](matt-pocock-source.json).
The upstream [MIT license](MATT_POCOCK_LICENSE) is included.

| Skill | Purpose |
| --- | --- |
| [ask-matt](ask-matt/SKILL.md) | Ask which skill or flow fits your situation. A router over the skills in this repo. |
| [diagnosing-bugs](diagnosing-bugs/SKILL.md) | Diagnosis loop for hard bugs and performance regressions. Use when the user says "diagnose"/"debug this", or reports something broken/throwing/failing/slow. |
| [grill-with-docs](grill-with-docs/SKILL.md) | A relentless interview to sharpen a plan or design, which also creates docs (ADR's and glossary) as we go. |
| [triage](triage/SKILL.md) | Move issues and external PRs through a state machine of triage roles, categorise, verify, grill if needed, and write agent-ready briefs. |
| [improve-codebase-architecture](improve-codebase-architecture/SKILL.md) | Scan a codebase for deepening opportunities, present them as a visual HTML report, then grill through whichever one you pick. |
| [setup-matt-pocock-skills](setup-matt-pocock-skills/SKILL.md) | Configure this repo for the engineering skills: set up its issue tracker, triage label vocabulary, and domain doc layout. Run once before first use of the other engineering skills. |
| [tdd](tdd/SKILL.md) | Test-driven development. Use when the user wants to build features or fix bugs test-first, mentions "red-green-refactor", or wants integration tests. |
| [to-spec](to-spec/SKILL.md) | Turn the current conversation into a spec and publish it to the project issue tracker: no interview, just synthesis of what you've already discussed. |
| [to-tickets](to-tickets/SKILL.md) | Break a plan, spec, or the current conversation into a set of tracer-bullet tickets, each declaring its blocking edges, published to the configured tracker (edges as text in one file per ticket locally, or native blocking links on a real tracker). |
| [wayfinder](wayfinder/SKILL.md) | Plan a huge chunk of work (more than one agent session can hold) as a shared map of decision tickets on your issue tracker, and resolve them one at a time until the way to the destination is clear. |
| [implement](implement/SKILL.md) | Implement a piece of work based on a spec or set of tickets. |
| [implement-spec](implement-spec/SKILL.md) | Implement the result of /to-spec and /to-tickets in code. |
| [prototype](prototype/SKILL.md) | Build a throwaway prototype to answer a design question. Use when the user wants to sanity-check whether a state model or logic feels right, or explore what a UI should look like. |
| [research](research/SKILL.md) | Investigate a question against high-trust primary sources and capture the findings as a Markdown file in the repo. Use when the user wants a topic researched, docs or API facts gathered, or reading legwork delegated to a background agent. |
| [domain-modeling](domain-modeling/SKILL.md) | Build and sharpen a project's domain model. Use when discussing codebase terminology, writing or editing a GLOSSARY.md, or recording or editing an ADR. |
| [codebase-design](codebase-design/SKILL.md) | Shared vocabulary for designing deep modules. Use when the user wants to design or improve a module's interface, find deepening opportunities, decide where a seam goes, make code more testable or AI-navigable, or when another skill needs the deep-module vocabulary. |
| [code-review](code-review/SKILL.md) | Review the changes since a fixed point (commit, branch, tag, or merge-base) along two axes: Standards (does the code follow this repo's documented coding standards?) and Spec (does the code match what the originating issue/spec asked for?). Runs both reviews in parallel sub-agents and reports them side by side. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to "review since X". |
| [pr](pr/SKILL.md) | Use when writing a PR body. |
| [retro](retro/SKILL.md) | Conduct a retrospective on a coding session. |
| [wizard](wizard/SKILL.md) | Generate an interactive bash wizard that walks a human through steps only they can perform. Use when provisioning infrastructure, setting up credentials or CI secrets, walking an unfamiliar third-party dashboard, or running a one-off migration or cutover. Don't invoke this for steps the agent can perform itself. |
| [grill-me](grill-me/SKILL.md) | A relentless interview to sharpen a plan or design. |
| [grilling](grilling/SKILL.md) | Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases. |
| [handoff](handoff/SKILL.md) | Compact the current conversation into a handoff document for another agent to pick up. |
| [teach](teach/SKILL.md) | Teach the user a new skill or concept, within this workspace. |
| [to-questionnaire](to-questionnaire/SKILL.md) | Turn a decision you can't fully answer into a questionnaire for someone else to fill in. |
| [wait-what](wait-what/SKILL.md) | Stop. That last message did not land: re-pitch it. |
| [writing-for-agents](writing-for-agents/SKILL.md) | Writing documents for agents. Use when creating or editing skills, or modifying AGENTS.md or CLAUDE.md. |

## Repository-specific skill

[android-build](android-build/SKILL.md) remains the established workflow for
local Android APK builds and update builds.

## Setup and updates

The skills are available on the next agent turn. They are checked into the
repository so new checkouts receive the same pinned installation.

`setup-matt-pocock-skills` is installed for an explicitly requested setup of
issue tracking, triage labels and domain documentation. Installing this bundle
does not choose a tracker or create remote issues or labels.

To update, inspect the official plugin manifest at the desired upstream commit,
replace its listed skill directories including supporting files, and update the
source manifest, catalog and license together. Preserve `android-build` and
repository-specific instructions. Do not install a second plugin copy alongside
this bundle for the same agent, since that duplicates the skills.
