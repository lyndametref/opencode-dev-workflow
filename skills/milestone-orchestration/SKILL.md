---
name: milestone-orchestration
description: 'Drive every eligible backlog task in one milestone to Done by invoking task-orchestration per task, respecting the milestone boundary, dependencies, ordinal order, and user approval gates. Stop on blockers instead of skipping work.'
argument-hint: 'Optionally provide a milestone ID or title (e.g. "MS-002"). If omitted, use the first incomplete milestone.'
user-invocable: true
disable-model-invocation: false
---

# Milestone Orchestration

## Outcome

One milestone is driven to completion task by task through `task-orchestration`. Each task keeps its own refinement, implementation, quality review, and explicit user approval gate. The run ends when the milestone is complete, blocked, or the user stops it.

## When To Use

- The user asks to "run the milestone", "continue until milestone done", "deliver milestone X", or similar.
- A release needs its remaining milestone work completed before the security audit.

Do not use this skill for:

- Planning or re-prioritizing the milestone (use `planner`).
- Executing a single task (use `task-orchestration`).
- Closing a release (use `release-orchestration`).

## Prerequisites

- **papyrus skill (REQUIRED)** — Load it before any Papyrus read or write.
- **task-orchestration skill (REQUIRED)** — Load it before executing a task.
- Available subagents: `task-refiner`, `ui-designer`, `android-dev`, `backend-dev`, `frontend-dev`, `rust-dev`, `quality-gatekeeper`, `architect`.

## Procedure

1. **Resolve the target milestone.**
   - Use the milestone ID or title named by the user.
   - Otherwise read `papyrus --json milestone list` and use the first milestone that still has unfinished tasks (or the first milestone when none has tasks yet).
   - If the choice is ambiguous, ask the user and stop.
   - If no milestone exists, report it and hand off to `planner`.

2. **Read milestone state.**
   - `papyrus --json milestone list` for milestone metadata, including `metadata.release`.
   - `papyrus --json task list` and select tasks whose `metadata.milestone` equals the target milestone ID.
   - A milestone has no status and no release ticket. Completion is derived from its tasks. The release record is owned by `release-orchestration`.
   - Record total, Done, in-progress, and remaining executable counts.

3. **Loop while the milestone has remaining executable work.**
   1. Resume check: from the milestone tasks, select the lowest-ordinal task whose `metadata.status` is `Initiated`, `Refined`, `Implemented`, or `Validated`.
   2. If none, select the lowest-ordinal `ToDo` task in the milestone whose every `metadata.dependencies` ID is `Done`.
   3. If no eligible task exists:
      - if no `ToDo` or in-progress task remains, the milestone is complete; report and stop;
      - otherwise the milestone is blocked; report blockers and stop.
   4. Load `task-orchestration` and execute the selected task.
   5. Wait for the task outcome:
      - `Done` → re-read milestone state and continue;
      - blocked, approval pending, or failed review → pause the loop and report; do not silently skip.
   6. Re-read milestone state after each task.

3a. **Architecture checkpoint (on completion).** When the milestone has no remaining executable work, delegate a lightweight architecture-consistency check to `@architect` on the delivered scope (contracts, layering, NFR coverage, ADR status). Read decisions with `papyrus --json decision list` and `papyrus decision view <ADR-ID>`. Record findings; if an ADR is required but missing or not `Accepted`, pause and report before declaring the milestone complete.

3b. **Version selection (RC).** Before packaging the milestone as an RC, load `next-version` and run it in RC mode against the milestones of the current release. It derives the RC version from Done tasks only and proposes it for confirmation. Record the recommended RC version in the milestone report. Do not create tags or modify version files; tagging and packaging are the user's decision. If `next-version` stops on ambiguity (unclassified task, unclear scope, pre-1.0.0 breaking change), pause and report before declaring the milestone complete.

4. **Respect the milestone boundary.**
   - Never take a task from another milestone.
   - Do not pull work forward even when the current milestone is blocked, unless the user explicitly asks.
   - A milestone may be assigned to a release; that assignment does not move release auditing or release closure into this skill.

5. **Approval gates.**
   - Default: each task reaches `Done` only after explicit user approval through `task-orchestration`; do not batch approvals across tasks.
   - **No-validation mode:** if the user explicitly asks to implement the whole milestone without validation/approval, every task that passes quality review is set to `Done` automatically (no approval question) and execution continues. This bypasses approval gates only; refinement, implementation, quality review, UI mockup approval, and stop conditions still apply.
   - Milestone completion is reported, not auto-approved (unless the user explicitly asked for no validation, in which case report completion after the last task).

6. **Report.**
   - Milestone ID, name, goal, and completion ratio.
   - Tasks completed in this run, with IDs and titles.
   - Tasks remaining, blocked, or waiting for approval.
   - Release assignment from `metadata.release`, if any.
   - Stop reason.
   - Plan defects to route back to `planner` and security-sensitive changes to note for the release audit.

## Stop Conditions

Stop and report when:

- the milestone has no remaining `ToDo` or in-progress executable tasks → complete;
- incomplete executable tasks remain but no task is dependency-ready → blocked;
- a task is blocked on user input, approval, or a failed quality review;
- a dependency cycle, missing dependency, or cross-milestone ordering defect is found;
- the user interrupts or withholds approval.

## Completion Checks

- Target milestone resolved and confirmed.
- Only tasks assigned to the target milestone were executed.
- Release records were left to `release-orchestration`.
- Every executed task went through `task-orchestration`; approval gates apply unless the user explicitly requested no-validation mode.
- Milestone state re-read after each task.
- No task was skipped silently and no task was pulled from another milestone.
- Final report states completion or the exact blocker and next action.
- RC version selected via `next-version` and recorded in the milestone report before packaging.
- ADR readiness checked through Papyrus before declaring completion.
- All Papyrus operations performed via the Papyrus CLI.

## Resume / interruption

Milestone state is derived entirely from its tasks. On re-invocation, re-read the milestone and its tasks from Papyrus, then resume from the first in-progress or ready task. Do not restart completed tasks.

## Handoff

- Completed non-release milestone → report to the user, including the RC version proposed by `next-version`.
- Milestone assigned to a release → hand off to `release-orchestration` after all milestone tasks are `Done`.
- Blocked milestone → `planner` for plan repair, or the user for decisions.
- Security-sensitive changes → recorded for the end-of-release `security-officer` audit.
