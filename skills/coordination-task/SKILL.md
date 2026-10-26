---
name: coordination-task
description: 'Coordinate a backlog task through Initiated, Refined, Implemented, Validated, and user-approved Done statuses, delegating refinement, implementation, and quality review.'
argument-hint: 'Provide a task id or path to coordinate (e.g. "task-0042" or "backlog/tasks/task-0042").'
user-invocable: true
disable-model-invocation: false
---

# Coordination Task

## Outcome

A single backlog task moves through `Initiated`, `Refined`, `Implemented`, and `Validated`, then reaches `Done` only after explicit user approval. Refinement, implementation, and quality review are delegated to the appropriate agents, with status tracked through the backlog CLI.

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

1. **Prepare repository** — Inspect the working tree before any task work. If there are uncommitted changes, show them to the user and ask whether they want to clean up or explicitly approve continuing in the current repository state. Never commit, stash, discard, or otherwise alter those changes. If the user chooses cleanup, wait for confirmation and re-check that the working tree is clean; then checkout `main`, pull from `origin`, and create a branch named `task/<task-id>`. If the user approves the current state, preserve the changes and continue on the current branch. In this case, do not checkout `main`, pull from `origin`, or create a branch.

2. **Initiate and refine** — After repository preparation, use the `backlog-md` skill and CLI to set the task status to `Initiated`. Call the `task` tool with subagent `business-analyst`, passing the task id/path and the goal of refining it (scope, assumptions, dependencies, acceptance criteria, definition of done). Wait for completion, then set the status to `Refined`.

3. **Delegate implementation** — Review the refined task (and any sub-tasks created by `@business-analyst`). For each implementation unit, call the `task` tool with subagent `android-dev` or `backend-dev` based on the goals of that unit (Android/Kotlin work → `android-dev`; server/backend work → `backend-dev`). Run independent units in parallel where possible. When all implementation units are complete, set the task status to `Implemented`.

4. **Delegate quality review** — Once implementation is complete, call the `task` tool with subagent `quality-gatekeeper` to review and validate the implementation against the task's acceptance criteria and definition of done.

5. **Validate and request approval** — If the review is incomplete, set the task back to `Refined` and send the quality-gatekeeper's findings to the appropriate development agent for further work. After implementation resumes, set the task to `Implemented` and repeat the quality review. Once the gatekeeper confirms that all acceptance criteria and definition-of-done items pass, set the status to `Validated`, present the review result, and ask the user for explicit approval. Set the status to `Done` only after the user approves. If the user requests changes or withholds approval, gather actionable feedback and set the task back to `Initiated`. Depending on the feedback, repeat refinement or proceed directly to implementation, then resume implementation, quality review, and approval.

6. **Report** — Summarize the goal of this task (list of Acceptance criteria), actions taken, agents invoked, and the quality-gatekeeper decision. If incomplete, list open items.

## Completion Checks

- Repository prepared before work: either clean, on `main`, pulled, and on a task branch, or continuing on the current branch with existing changes explicitly approved by the user and preserved.
- Task refined by `@business-analyst` before implementation.
- Task status follows `Initiated` after repository preparation, `Refined` after analyst refinement, and `Implemented` after implementation.
- Each implementation unit assigned to `@android-dev` or `@backend-dev` per its goals.
- `@quality-gatekeeper` review completed with a decision.
- A passing quality review sets the task to `Validated` and is presented to the user for explicit approval.
- If review is incomplete, the task returns to `Refined` while development resumes; set it to `Implemented` again after the changes are complete.
- If the user requests changes or withholds approval, gather actionable feedback and return the task to `Initiated`; refine again or proceed directly to implementation depending on the feedback.
- Task status is set to `Done` only after explicit user approval; a successful review alone is not approval.
- All backlog operations performed via the backlog CLI.
