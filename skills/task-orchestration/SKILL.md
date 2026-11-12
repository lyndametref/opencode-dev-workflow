---
name: task-orchestration
description: 'Orchestrate a single backlog task through ToDo, Initiated, Refined, Implemented, Validated, and user-approved Done statuses, delegating refinement, implementation, and quality review.'
argument-hint: 'Optionally provide a task ID to orchestrate (e.g. "TASK-0042"). If omitted, resume the lowest-ordinal in-progress task, otherwise take the first ready ToDo task from Papyrus.'
user-invocable: true
disable-model-invocation: false
---

# Task Orchestration

## Outcome

A single backlog task moves through `ToDo`, `Initiated`, `Refined`, `Implemented`, and `Validated`, then reaches `Done` only after explicit user approval. Refinement, implementation, and quality review are delegated to the appropriate agents, with status tracked through Papyrus.

## Resume / restart support

Task state lives in Papyrus (task status and metadata) and the repository (branch). If a run is interrupted, re-invoking this skill must not restart from scratch or lose progress:

- Read the current task status first (`papyrus task view <id>`); resume from the step matching that status (see Procedure).
- Do not recreate a branch or discard changes if already on `task/<id>` or if the branch exists; preserve existing changes.
- Each step is idempotent: check status before acting and skip phases already completed.

This skill is invoked by the `orchestrator` agent, which owns execution, status transitions, and approval requests. For the task, milestone, and release workflows and diagrams, see [Orchestrator Workflow](../../workflows/orchestrator/README.md).

## Prerequisites

- **papyrus skill (REQUIRED)** — All task reads, status changes, and evidence comments go through the Papyrus CLI.
- Available subagents: `@task-refiner`, `@ui-designer`, `@android-dev`, `@backend-dev`, `@frontend-dev`, `@rust-dev`, `@quality-gatekeeper`.

## When To Use

- The orchestrator needs to drive a single backlog task end to end.
- A task needs refinement, implementation, and quality review in sequence.

Do not use this skill for:
- Refining a single ticket without implementation (use `task-refinement`).
- Verifying a ticket in isolation (use `quality-verification`).

## Procedure

**Resume check (run after step 1 resolves the target).** Read the current status of the target task (`papyrus task view <id>`). Map it to the starting step and skip any phase already completed:
- `ToDo` (never started) → start at step 1.
- `Initiated` (repo already prepared) → skip to step 3 (do NOT re-run step 2).
- `Refined` → skip to step 4.
- `Implemented` → skip to step 5.
- `Validated` → skip to step 6 (request approval; do not re-run review unless requested).
- `Done` → step 7 (Report) and stop; nothing to do.

On any resume, repository preparation (step 2) is skipped.

1. **Resolve target task** — If the prompt provides a task ID, use it. Otherwise:
   - Run `papyrus --json task list`. Select tasks whose `metadata.status` is `Initiated`, `Refined`, `Implemented`, or `Validated`; order by `metadata.ordinal`, then ID. If any exist, resume the first.
   - Only when no task is in progress, run `papyrus --json task list --status ToDo`, build the set of `Done` task IDs with `papyrus --json task list --status Done`, and take the first `ToDo` task whose every `metadata.dependencies` ID is `Done`, ordered by `metadata.ordinal`, then ID.
   - Do not choose a different item, reorder the list, or ask the user to pick among equivalents.
   - If no eligible task exists, report that no eligible task is available and stop.
   - Papyrus has no `--ready`, `--sort priority`, or `--plain` flags. Compute readiness from JSON.

2. **Prepare repository** — Skip this step if the task status is already `Initiated` or later (resume). Otherwise inspect the working tree before any task work. If already on branch `task/<task-id>` or that branch exists, reuse it and do not recreate it. If there are uncommitted changes, show them to the user and ask whether they want to clean up or explicitly approve continuing in the current repository state. Never commit, stash, discard, or otherwise alter those changes. If the user chooses cleanup, wait for confirmation and re-check that the working tree is clean; then checkout `main`, pull from `origin`, and create a branch named `task/<task-id>` (only if it does not already exist). If the user approves the current state, preserve the changes and continue on the current branch. In this case, do not checkout `main`, pull from `origin`, or create a branch. If Git operations are denied by policy or fail, stop and ask the user to prepare the branch and working tree; never bypass the policy.

3. **Initiate and refine** — After repository preparation, if the status is not yet `Initiated` or later, set it with `papyrus task edit <id> --status Initiated`. If the status is already `Refined` or later, skip refinement. Otherwise call the `subagent` tool with agent `task-refiner`, passing the task ID and the goal of refining it (scope, assumptions, dependencies, acceptance criteria, definition of done). Require the refiner to report the updated artifacts and whether the ticket is execution-ready. Wait for completion, then set `papyrus task edit <id> --status Refined`.
   - **UI mockups**: if the refined task needs UI design or changes to a view/screen, call the `subagent` tool with agent `ui-designer` before setting `Refined`. Require the `MOCK` id(s), Papyrus status, and the reported `UI`/task references. `ui-designer` creates or resolves the `UI` specification, then creates the `MOCK` record with `papyrus ui-mockup create --task <id> --spec <UI-ID> "<title>"`; the specification owner records it in the technical specification.
   - **UI approval gate**: before setting the status to `Refined`, inspect the refined task/specification for referenced mockups (`MOCK-xxx`). For each, read `papyrus ui-mockup view <MOCK-ID>`; if its status is not `approved`, present it to the user and request explicit approval; approve with `papyrus ui-mockup edit <MOCK-ID> --status approved`; do not proceed to implementation until it is `approved`.

4. **Delegate implementation** — Review the refined task (and any sub-tasks created by `@task-refiner`). Verify that any referenced mockups are `approved` in Papyrus before delegating; if not, pause for approval. For each implementation unit, call the `subagent` tool with agent `android-dev`, `backend-dev`, `frontend-dev`, or `rust-dev` based on the goals of that unit (Android/Kotlin work → `android-dev`; server/backend work → `backend-dev`; web/frontend work → `frontend-dev`; Rust work → `rust-dev`). Run independent units in parallel where possible. Require each subagent to return the structured evidence block defined in its agent instructions (ticket, scope/ACs covered, files changed, tests, static/security checks, NFR coverage, gaps); reject or re-run a unit that omits it. Record each unit's evidence with `papyrus task edit <id> --comment "<evidence>" --comment-author <agent>`. When all implementation units are complete, set `papyrus task edit <id> --status Implemented`.

5. **Delegate quality review** — Once implementation is complete, call the `subagent` tool with agent `quality-gatekeeper`, passing the task ID, the acceptance criteria, and the recorded implementation evidence. Require the gatekeeper to return the per-acceptance-criterion evidence table (criterion | result | evidence). The gatekeeper reruns tests and decides. Reject or repeat the review if any criterion lacks evidence.

6. **Validate and request approval** — If the review is incomplete, set the task back to `Refined` (`papyrus task edit <id> --status Refined`) and send the quality-gatekeeper's findings to the appropriate development agent for further work. After implementation resumes, set the task to `Implemented` and repeat the quality review. Once the gatekeeper confirms that all acceptance criteria and definition-of-done items pass:
   1. Set the status to `Validated`.
   2. Re-read the task using `papyrus task view <id>` and extract every acceptance criterion from the task content. Do not rely only on the gatekeeper's summary or omit criteria for brevity.
   3. Print the quality-gatekeeper report in the response, followed by a compact acceptance-criteria checklist with pass/fail and concise evidence for each criterion. Keep this in the printed report, not inside the approval question.
   4. **No-validation mode:** if the user explicitly asked to implement the whole milestone without validation/approval, set the status to `Done` now (no approval question) and continue to step 6b.
   5. Otherwise, ask for approval with a short question only (e.g. "Approve closing <task-id> — <task title> as Done? (yes/no)"). Do not paste the full report or criterion list into the question text.
   6. Set the status to `Done` only after the user explicitly approves. If the user requests changes or withholds approval, gather actionable feedback and set the task back to `Initiated` when refinement is needed, otherwise `Refined` to resume implementation. Then resume implementation, quality review, and approval.

   The quality-gatekeeper only produces reports; the orchestrator is responsible for presenting the report and requesting approval. Do not ask the quality-gatekeeper to ask for approval or to close the ticket.

   If the task has no explicit acceptance criteria, do not imply that it does. State in the printed report that none are listed and ask in the short approval question whether the user wants to approve based on the task's definition of done, or return it for refinement.

6b. **Merge on completion** — Once the task is `Done`, merge its branch into `main` with `--no-ff` before finishing: if uncommitted changes remain on `task/<task-id>`, stage and commit them first; then checkout `main`, pull, run `git merge --no-ff task/<task-id>`, and leave the repository on `main`. Do not push. Skip this step if the task is not `Done`.

7. **Report** — Summarize the goal of this task (list of acceptance criteria), actions taken, agents invoked, and the quality-gatekeeper decision. If incomplete, list open items. Include the merge result and the Papyrus evidence comments.

## Completion Checks

- Repository prepared before work: either clean, on `main`, pulled, and on a task branch, or continuing on the current branch with existing changes explicitly approved by the user and preserved.
- Task refined by `@task-refiner` before implementation.
- If the task needs UI design, mockups created by `@ui-designer` and every referenced `MOCK-xxx` is `approved` in Papyrus before implementation.
- Task status follows `Initiated` after repository preparation, `Refined` after refinement, `Implemented` after implementation, `Validated` after review, and `Done` only after approval.
- Each implementation unit assigned to `@android-dev`, `@backend-dev`, `@frontend-dev`, or `@rust-dev` per its goals.
- Structured evidence received from each implementation subagent and recorded as Papyrus comments.
- `@quality-gatekeeper` review completed with a decision and a per-acceptance-criterion evidence table.
- A passing quality review sets the task to `Validated` and is presented to the user for explicit approval.
- The acceptance-criteria report is printed separately and includes the task ID/title, every acceptance criterion from the task, its pass status, and review evidence.
- The approval question is short and does not embed the full report or criterion list.
- If review is incomplete, the task returns to `Refined` while development resumes; set it to `Implemented` again after the changes are complete.
- If the user requests changes or withholds approval, gather actionable feedback and return the task to `Initiated` when refinement is needed, otherwise `Refined`.
- Task status is set to `Done` only after explicit user approval (or automatically in no-validation mode); a successful review alone is not approval outside that mode.
- After `Done`, the task branch is merged into `main` with `--no-ff` (uncommitted changes committed first); no push is performed.
- Target task resolved first from in-progress tasks, then as the first ready `ToDo` task, before repository preparation.
- All Papyrus operations performed via the Papyrus CLI.
