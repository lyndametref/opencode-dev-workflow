---
name: manage-tasks
description: 'Create, read, update, archive, and restore backlog tasks through the management tool: status, milestone, ordinal, dependencies, references, documentation, and evidence comments.'
argument-hint: 'Examples: create a task; set status to Done; add an acceptance criterion; record evidence.'
user-invocable: true
disable-model-invocation: false
---

# Task Management

## Outcome

Tasks are created, read, updated, archived, and restored through the management tool, so IDs, status, milestone assignment, dependencies, ordinals, and evidence stay consistent.

## When to use

- Create or edit a task, its status, milestone, ordinal, dependencies, references, documentation, acceptance criteria, or evidence comments.
- Archive or restore a task.
- Read task state for execution, verification, or reporting.

## Commands

- List: `papyrus task list [--status <status>] [--milestone <id>] [--release <id>] [--label <label>] [--search <text>] [--limit <n>]`
- View: `papyrus task view <TASK-ID>`
- Create: `papyrus task create "<title>" --description <text|-> --ac "<criterion>" --milestone <MS-ID> --ordinal <n> --depends-on <TASK-ID> --label <label> --reference <ref> --documentation <path> --type <type>`
- Edit: `papyrus task edit <TASK-ID> --status <status> --title "<title>" --description <text|-> --ac "<criterion>" --depends-on <TASK-ID> --milestone <MS-ID> --ordinal <n> --label <label> --reference <ref> --documentation <path> --comment "<text>" --comment-author <agent>`
- Archive/restore: `papyrus task archive <TASK-ID>`, `papyrus task restore <TASK-ID>`

## Status values

Exact and case-sensitive: `ToDo`, `Initiated`, `Refined`, `Implemented`, `Validated`, `Done`.

- Default is `ToDo`. Never skip backward to `ToDo`; use `Initiated` or `Refined` when work returns.
- Workflow uses `To Do`, `In-Progress`, `Done`: map `To Do`→`ToDo`, `In-Progress`→the stage reached, `Done`→`Done`.
- `Done` means every acceptance criterion is fulfilled and, when the task's artifact requires it, the user's verification is obtained.

## Rules

- No priority field. Use `--ordinal` (lower first) and dependencies.
- No `--ready` flag. Compute readiness from `metadata.dependencies` and the `Done` set.
- `--ac` adds acceptance criteria. There is no checkbox toggle; milestone verification records pass/fail.
- `--description` is multiline: pass `-` and the text on stdin. `--ac` and `--comment` are single-line and stay inline.
- No notes or final-summary fields. Record evidence and decisions with `--comment`.
- Never change task scope, acceptance criteria, or dependencies outside `task-refiner` or planning.
- Never edit managed task files directly.

## Evidence

Record fulfilment proof and review outcomes: `papyrus task edit <id> --comment "<text>" --comment-author <agent>`. Comments are single-line.

## References

Full syntax, JSON shapes, and caveats: `skills/managed-records/references/REFERENCE.md`.
