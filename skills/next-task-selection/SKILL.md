---
name: next-task-selection
description: 'Select the next task to perform from the backlog based on backlog order (lowest task id among To Do tasks).'
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
- Starting a work session and needing the next backlog item.

Do not use this skill for:
- Coordinating implementation of a task (use `coordination-task`).
- Refining a task (use `task-refinement`).

## Procedure

1. **Load backlog-md** — Ensure the backlog CLI is available.

2. **List tasks by priority** — Use the `backlog-md` skill to run `backlog task list --sort priority --plain` (apply optional filters such as status/label/assignee if provided). Prefer tasks with status `To Do`.

3. **Select by backlog order** — Among candidate `To Do` tasks, select the one with the lowest task id (backlog order). If no `To Do` tasks exist, report that the backlog has no pending tasks.

4. **Read the selected task** — Run `backlog task <id> --plain` to gather title, description, and acceptance criteria.

5. **Report** — Return the selected task id, title, status, and a short summary. Suggest next action (e.g., coordinate implementation or refine).

## Completion Checks

- Selected task is in `To Do` status (or none found reported).
- Selection based on lowest task id among candidates.
- No task files modified.
- Result reported to user.