---
name: milestone-verification
description: 'Run Phase 5 for one milestone: open the milestone verification task, dispatch the quality review and code audit, drive corrections through the planner, record the RC version, publish the versioned RC package with each component's own script, and close the task only when every check passes.'
argument-hint: 'Provide a milestone ID whose execution tasks are Done.'
user-invocable: true
disable-model-invocation: false
---

# Milestone Verification

## Outcome

One milestone verification task is `Done`. It records the change set, checks run, evidence, findings, the quality and code audits, correction tasks, deferred findings with owners, the RC version, the package evidence, and the final result. One versioned RC package is published locally. The milestone is then complete and ready for Phase 6.

## When to use

- Every execution task of a milestone is `Done` and the milestone boundary was reached in Phase 4.
- A correction task was completed and verification must rerun.

Do not use this skill to fix code, change milestone scope, verify more than one milestone, or run release audits.

## Prerequisites

- Load the `manage-*` skills for the artifacts under verification (tasks, milestones, releases, audits), `next-version`, and `packaging`.
- Read the milestone, its tasks, acceptance criteria, and the verification task.
- Available subagents: `quality-gatekeeper`, `code-analyzer`, `planner`.

## Procedure

1. **Confirm the boundary** — read the milestone and its tasks. Every architecture, UI, test-design, refinement, and implementation task must be `Done`. If not, return to Phase 4.
2. **Open the verification task** — find the milestone's one verification task (`--type milestone-verification`) and set it to `Initiated`. The criteria are the milestone acceptance criteria.
3. **Run the quality review** — dispatch `quality-gatekeeper` with the milestone ID, the change set, and the acceptance criteria. Require the `quality-audit` report and the `AUD` record.
4. **Run the code audit** — dispatch `code-analyzer` with the milestone ID and the change set. Require the `code-audit` report and the `AUD` record.
5. **Handle corrections** — if either audit reports corrections required:
   - the reviewer defines the correction content: the failure description and the acceptance criteria it blocks;
   - ask `planner` to create the correction tasks inside the milestone's approved scope;
   - execute them through `milestone-execution`;
   - rerun the failed check. The new audit replaces the previous one, which is archived.
6. **Handle deferred findings** — a deferred finding is recorded with an owner and a follow-up task created by `planner`. The user accepts or rejects it at the Phase 6 scope-and-findings review. The milestone may proceed with the risk documented.
7. **Determine the RC version** — load `next-version` in RC mode for the verified milestone. Record the recommended version in the verification task.
8. **Publish the RC package** — load `packaging` and build the recorded version from the committed tree into the git-ignored `builds/<version>/` by running each deployable component's `<component-dir>/scripts/build-package.sh --version <version> --out builds/<version>/.build/<component>` (e.g. `apps/<app>/scripts/...`, or `scripts/...` for a repository-root component). Stop if the tree is dirty, the directory already exists, or `builds/` is not git-ignored. A missing or failing script becomes a task for the owning `*-dev` agent; do not patch or improvise the build. If the user waived packaging, record the waiver and publish nothing.
9. **Record the result** — write the change set, checks run, evidence, findings, `AUD` IDs, correction tasks, deferred findings, RC version, package evidence (commit SHA, scripts, component archives, paths, sizes, sha256) or the waiver, and final result into the verification task description or comments (manage-tasks).
10. **Close the verification task** — set it to `Done` only when:
    - the milestone scope is complete and all execution tasks are `Done`;
    - the whole change set is covered by the checks;
    - every correction task is `Done` and verification reran and passed;
    - deferred findings have an owner and a follow-up task;
    - the quality and code audits are recorded as `AUD` records with the `issued` label;
    - the RC version is recorded;
    - the RC package for that version is published, or the user waiver is recorded.
11. **Report** — the verification result, `AUD` IDs, correction tasks, deferred findings, RC version, package path and checksums (or waiver), and readiness for Phase 6.

## Rules

- Verification is change-scoped: only the milestone's change set and the behavior it touches.
- Security is not assessed here; it is a Phase 6 audit.
- Reviewers are independent and read-only. They never fix what they find.
- Every check reruns or re-reads its evidence; reported results are not trusted.
- Findings are severity-ranked with evidence, location, and recommendation; the scale is `low`, `medium`, `high`, `blocker`.
- Only one audit of a type may be `issued` or `approved` within the milestone scope at a time. A rerun after corrections issues a new audit and archives the previous one.
- A Phase 5 audit stays `issued` until the user accepts or rejects its findings at the Phase 6 review.
- Scope, dependency, and ordinal changes go to `planner`; verification never changes them.
- The milestone verification task is the only check of the milestone. The milestone is not complete before it is `Done`.
- The RC package is built from the committed, verified tree with each component's own script and published only to the git-ignored `builds/<version>/`; it is never staged, committed, tagged, pushed, uploaded, or deployed.
- A version is immutable: an existing `builds/<version>/` is never overwritten; changed content needs a new RC version.
- A missing or failing build script is task work, not a lowered criterion. The quality review does not run the script; packaging does.

## Failure handling

| Outcome | Action |
|---|---|
| Quality review fails | Correction tasks with the failure description; Phase 4 executes; verification reruns. |
| Code audit finds defects | Correction tasks with the failure description; Phase 4 executes; verification reruns. |
| RC package build fails or a build script is missing | Task for the owning `*-dev` agent with the failure description; Phase 4 executes; verification reruns; package again with the new RC version. |
| Package directory exists or is not git-ignored | Stop; the user fixes the ignore rules; changed content needs a new RC version. |
| Deferred finding | Owner and follow-up task; the user decides at the Phase 6 review; the milestone proceeds with the risk documented. |
| Scope creep | Report the unjustified change; the user decides removal or a requirements change through Phase 2. |

## Stop conditions

- A task in the milestone is not `Done`: return to Phase 4.
- Tests fail or cannot be run: record the failure and create correction tasks; do not accept reported evidence.
- An acceptance criterion is ambiguous or unverifiable: stop; its owner fixes it.
- An unresolved finding has no owner: stop; a finding is never carried without an owner.
- A reviewer discovers a requirement gap: return to Phase 2.
- The tree is dirty or `builds/` is not git-ignored: stop; package only a committed, verified tree into an ignored directory.
- A build script is missing or fails: no package is published; the failure becomes task work.

## Report format

- **Milestone**: ID, title, acceptance criteria.
- **Change set**: files, behavior, tasks.
- **Quality audit**: `AUD` ID, verdict, severity counts.
- **Code audit**: `AUD` ID, verdict, severity counts.
- **Corrections**: task IDs and status, or `none`.
- **Deferred findings**: finding, owner, follow-up task.
- **RC version**: recommended version and rationale.
- **RC package**: directory, each component's script path, archives, sizes, sha256, commit SHA; or the recorded waiver.
- **Verification task**: ID and status.
- **Next action**: Phase 6 release management.

## Completion checks

- The milestone boundary was confirmed before verification started.
- Both audits were run on the milestone change set and recorded as `issued`.
- Every correction task is `Done` and the checks reran.
- Deferred findings have an owner and a follow-up task.
- The RC version is recorded in the verification task.
- The RC package is published for that version under `builds/<version>/` with checksums and evidence recorded, or the user waiver is recorded.
- The verification task is `Done` and the milestone is reported ready for Phase 6.

## Resume / interruption

Verification state is derived from the milestone, its tasks, the verification task, and the latest audits.

On re-invocation, re-read them, skip completed checks, and rerun any check whose evidence is stale. A rerun after corrections issues a new audit and archives the previous one; do not reuse the old evidence. A package for a superseded RC stays on disk, is marked superseded in the verification task, and is never reused as current.
