---
name: coordination-task
description: 'Coordinate the end-to-end implementation of a backlog task: prepare repo, refine it, move it in progress, delegate implementation to the right dev agent per sub-task, then gate with quality review.'
argument-hint: 'Provide a task id or path to coordinate (e.g. "task-0042" or "backlog/tasks/task-0042").'
user-invocable: true
disable-model-invocation: false
---

# Coordination Task

## Outcome

A single backlog task is refined, moved to in progress, implemented by the appropriate development agent(s), and validated by the quality gatekeeper, with status tracked through the backlog CLI.

For a user-facing explanation and workflow diagram, see [Coordination Task Workflow](references/workflow.md).

## Prerequisites

- **backlog-md skill (REQUIRED)** — All ticket reads and status changes go through the backlog CLI.
- Available subagents: `@business-analyst`, `@android-dev`, `@backend-dev`, `@quality-gatekeeper`.

## When To Use

- The user asks to coordinate implementation of a backlog task end to end.
- A task needs refinement, implementation, and quality review in sequence.

Do not use this skill for:
- Refining a single ticket without implementation (use `task-refinement`).
- Verifying a ticket in isolation (use `quality-verification`).

## Procedure

1. **Prepare repository** — Inspect the working tree before any task work. If there are uncommitted changes, stop and ask the user to clean up the repository; do not commit, stash, discard, or otherwise alter those changes. Wait for the user to confirm that cleanup is done, then re-check that the working tree is clean before continuing. Checkout `main`, pull from `origin` to get the latest state, and create a branch named `task/<task-id>` for the task.

2. **Delegate refinement** — Call the `task` tool with subagent `business-analyst`, passing the task id/path and the goal of refining it (scope, assumptions, dependencies, acceptance criteria, definition of done). Wait for completion.

3. **Move to in progress** — Use the `backlog-md` skill to set the task status to `in progress`.

4. **Delegate implementation** — Review the refined task (and any sub-tasks created by `@business-analyst`). For each implementation unit, call the `task` tool with subagent `android-dev` or `backend-dev` based on the goals of that unit (Android/Kotlin work → `android-dev`; server/backend work → `backend-dev`). Run independent units in parallel where possible.

5. **Delegate quality review** — Once implementation is complete, call the `task` tool with subagent `quality-gatekeeper` to review and validate the implementation against the task's acceptance criteria and definition of done.

6. **Set status and get user feedback** — If the review is incomplete, set the task to `in progress` and send the quality-gatekeeper's findings to the appropriate development agent for further work. If the review is ready to close, set the task to `done` via the backlog CLI, present the review result to the user, and ask whether they are satisfied. If the user is satisfied, finish and let them decide whether to mark it complete. If not, gather their actionable feedback before proceeding, set the task back to `in progress`, and pass both the feedback and review findings to the appropriate development agent. After further implementation, repeat the quality review and user-feedback steps.

7. **Report** — Summarize actions taken, agents invoked, and the quality-gatekeeper decision. If incomplete, list open items.

## Completion Checks

- Repository prepared (clean, on main, pulled, task branch created) before work.
- Task refined by `@business-analyst` before implementation.
- Task status set to `in progress`.
- Each implementation unit assigned to `@android-dev` or `@backend-dev` per its goals.
- `@quality-gatekeeper` review completed with a decision.
- User explicitly asked whether they are satisfied after a successful review.
- If unsatisfied, actionable user feedback is gathered before returning work to development, and the task is set back to `in progress`.
- Task status set to `done` on successful review, or back to `in progress` if review is incomplete or the user is unsatisfied.
- All backlog operations performed via the backlog CLI.
