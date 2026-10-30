---
name: coordination-task
description: 'Coordinate a backlog task through Initiated, Refined, Implemented, Validated, and user-approved Done statuses, delegating refinement, implementation, and quality review.'
argument-hint: 'Optionally provide a task id or path to coordinate (e.g. "task-0042" or "backlog/tasks/task-0042"). If omitted, the next task is taken from the backlog.'
user-invocable: true
disable-model-invocation: false
---

# Coordination Task

## Outcome

A single backlog task moves through `Initiated`, `Refined`, `Implemented`, and `Validated`, then reaches `Done` only after explicit user approval. Refinement, implementation, and quality review are delegated to the appropriate agents, with status tracked through the backlog CLI.

## Resume / restart support

Task state lives in the backlog (task status) and the repository (branch). If a run is interrupted, re-invoking this skill must not restart from scratch or lose progress:

- Read the current task status first (`backlog task <id> --plain`); resume from the step matching that status (see Procedure).
- Do not recreate a branch or discard changes if already on `task/<id>` or if the branch exists; preserve existing changes.
- Each step is idempotent: check status before acting and skip phases already completed.

For a user-facing explanation and workflow diagram, see [Coordination Task Workflow](references/workflow.md).

## Prerequisites

- **backlog-md skill (REQUIRED)** — All ticket reads and status changes go through the backlog CLI.
- Available subagents: `@business-analyst`, `@ui-designer`, `@android-dev`, `@backend-dev`, `@frontend-dev`, `@quality-gatekeeper`.

## When To Use

- The user asks to coordinate implementation of a backlog task end to end.
- A task needs refinement, implementation, and quality review in sequence.

Do not use this skill for:
- Refining a single ticket without implementation (use `task-refinement`).
- Verifying a ticket in isolation (use `quality-verification`).

## Procedure

**Resume check (run first).** Read the current status of the target task (`backlog task <id> --plain`). Map it to the starting step and skip any phase already completed:
- `To Do` (never started) → start at step 1.
- `Initiated` (repo already prepared) → skip to step 3 (do NOT re-run step 2).
- `Refined` → skip to step 4.
- `Implemented` → skip to step 5.
- `Validated` → skip to step 6 (request approval; do not re-run review unless requested).
- `Done` → step 7 (Report) and stop; nothing to do.

On any resume, repository preparation (step 2) is skipped.

1. **Resolve target task** — If the prompt provides a task id or path, use it. Otherwise, run `backlog task list --ready --plain` to list dependency-ready tasks (default order: ordinal, then priority, then ID). If exactly one is returned, use it. If several are returned, apply the project-planner prioritization rules (stakeholder-visible outcomes first; never a task that cannot be used before its enabler) and, if still ambiguous, present the candidates to the user and ask which to coordinate. If the list is empty, report that the backlog is empty and stop.

2. **Prepare repository** — Skip this step if the task status is already `Initiated` or later (resume). Otherwise inspect the working tree before any task work. If already on branch `task/<task-id>` or that branch exists, reuse it and do not recreate it. If there are uncommitted changes, show them to the user and ask whether they want to clean up or explicitly approve continuing in the current repository state. Never commit, stash, discard, or otherwise alter those changes. If the user chooses cleanup, wait for confirmation and re-check that the working tree is clean; then checkout `main`, pull from `origin`, and create a branch named `task/<task-id>` (only if it does not already exist). If the user approves the current state, preserve the changes and continue on the current branch. In this case, do not checkout `main`, pull from `origin`, or create a branch.

3. **Initiate and refine** — After repository preparation, if the status is not yet `Initiated` or later, set it to `Initiated` via the backlog CLI. If the status is already `Refined` or later, skip refinement. Otherwise call the `task` tool with subagent `business-analyst`, passing the task id/path and the goal of refining it (scope, assumptions, dependencies, acceptance criteria, definition of done). Wait for completion, then set the status to `Refined`.

4. **Delegate implementation** — Review the refined task (and any sub-tasks created by `@business-analyst`). For each implementation unit, call the `task` tool with subagent `android-dev`, `backend-dev`, or `frontend-dev` based on the goals of that unit (Android/Kotlin work → `android-dev`; server/backend work → `backend-dev`; web/frontend work → `frontend-dev`). Run independent units in parallel where possible. Capture each subagent's evidence report from its response. When all implementation units are complete, set the task status to `Implemented`.

5. **Delegate quality review** — Once implementation is complete, call the `task` tool with subagent `quality-gatekeeper`, passing the task id/path, the acceptance criteria, and the captured implementation evidence reports. The gatekeeper reruns tests and decides.

6. **Validate and request approval** — If the review is incomplete, set the task back to `Refined` and send the quality-gatekeeper's findings to the appropriate development agent for further work. After implementation resumes, set the task to `Implemented` and repeat the quality review. Once the gatekeeper confirms that all acceptance criteria and definition-of-done items pass:
   1. Set the status to `Validated`.
   2. Re-read the task using `backlog task <id> --plain` and extract every acceptance criterion from the task itself. Do not rely only on the gatekeeper's summary or omit criteria for brevity.
   3. Ask for approval using the required format below. Include every criterion verbatim or faithfully, with its pass status and concise evidence from the review. Include the task ID/title and quality-gatekeeper decision.
   4. Set the status to `Done` only after the user explicitly approves. If the user requests changes or withholds approval, gather actionable feedback and set the task back to `Initiated`. Depending on the feedback, repeat refinement or proceed directly to implementation, then resume implementation, quality review, and approval.

   **Required user approval prompt** (do not replace with a generic “Do you approve?”):

   ```markdown
   ## Approval requested: <task-id> — <task title>

   Quality review: **Passed**

   Acceptance criteria:
   - [x] <criterion 1> — Evidence: <review evidence>
   - [x] <criterion 2> — Evidence: <review evidence>
   <!-- Include every acceptance criterion from the task. -->

   All listed criteria passed quality review. Do you approve closing this task as Done?
   ```

   If the task has no explicit acceptance criteria, do not imply that it does. State that none are listed and ask whether the user wants to approve based on the task's definition of done, or return it for refinement.

7. **Report** — Summarize the goal of this task (list of Acceptance criteria), actions taken, agents invoked, and the quality-gatekeeper decision. If incomplete, list open items.

## Completion Checks

- Repository prepared before work: either clean, on `main`, pulled, and on a task branch, or continuing on the current branch with existing changes explicitly approved by the user and preserved.
- Task refined by `@business-analyst` before implementation.
- Task status follows `Initiated` after repository preparation, `Refined` after analyst refinement, and `Implemented` after implementation.
- Each implementation unit assigned to `@android-dev`, `@backend-dev`, or `@frontend-dev` per its goals.
- `@quality-gatekeeper` review completed with a decision.
- A passing quality review sets the task to `Validated` and is presented to the user for explicit approval.
- The approval request includes the task ID/title and the complete acceptance-criteria list from the task, with pass status and review evidence for each criterion; it is not a generic approval question.
- If review is incomplete, the task returns to `Refined` while development resumes; set it to `Implemented` again after the changes are complete.
- If the user requests changes or withholds approval, gather actionable feedback and return the task to `Initiated`; refine again or proceed directly to implementation depending on the feedback.
- Task status is set to `Done` only after explicit user approval; a successful review alone is not approval.
- Target task resolved (provided or selected via prioritization rules from the backlog) before repository preparation.
- All backlog operations performed via the backlog CLI.
