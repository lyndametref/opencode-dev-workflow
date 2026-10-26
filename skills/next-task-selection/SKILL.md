---
name: next-task-selection
description: 'Select the next task to perform from the backlog based on the ordinal field (lowest ordinal among ready To Do tasks). Task IDs never determine priority.'
argument-hint: 'Optional filters: status, label, or assignee (e.g. "label:backend").'
user-invocable: true
disable-model-invocation: false
---

# Select Next Task

## Outcome

Identify and return the next backlog task to work on, chosen by backlog order, without modifying any task.

## Prerequisites

- **backlog-md skill (REQUIRED)** — All task listing/reading goes through the backlog CLI.

## When To Use

- The user asks which task to do next.
- The use asks to initiate the next step. This is used to choose what it the next step and is followed by `coordination-task`.
- Starting a work session and needing the next backlog item.


Do not use this skill for:
- Coordinating implementation of a task (use `coordination-task`).
- Refining a task (use `task-refinement`).

## Procedure

1. **Load backlog-md** — Ensure the backlog CLI is available.

2. **List candidates** — Use the `backlog-md` skill to run `backlog task list --plain` (apply optional filters such as status/label/assignee if provided). Keep only tasks with status `To Do`. Note: `--sort` accepts only `priority` or `id`; neither is used for selection.

3. **Read ordinals and dependencies** — For each candidate, run `backlog task <id> --plain` and record its `Ordinal`, `Milestone`, and `Dependencies`. A candidate is ready only if every dependency is `Done` (archived Done tasks count as Done).

4. **Select by ordinal** — Among ready `To Do` candidates, select the one with the lowest `ordinal` value (decimal values compare numerically, e.g. 11.5 is before 12). Break exact ties by task id only as a final stable tie-break, and report the tie. Task IDs never determine priority. If no `To Do` tasks exist, report that the backlog has no pending tasks. If candidates exist but none is ready, report the blocking dependencies.

5. **Read the selected task** — Run `backlog task <id> --plain` to gather title, description, and acceptance criteria.

6. **Report** — Return the selected task id, title, status, ordinal, milestone, dependency status, and a short summary. Suggest next action (e.g., coordinate implementation or refine).

## Completion Checks

- Selected task is in `To Do` status (or none found reported).
- Selection based on lowest `ordinal` among ready `To Do` candidates; task IDs are not used to determine priority.
- Every selected task has all dependencies `Done`.
- No task files modified.
- Result reported to user.