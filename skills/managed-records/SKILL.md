---
name: managed-records
description: 'Manage tasks, milestones, releases, requirements, NFRs, business rules, glossary terms, decisions, specifications, mockups, and audit records with the Papyrus CLI. Use for all backlog and Papyrus-managed document operations.'
argument-hint: 'Optional: create or edit a task, milestone, release, requirement, rule, glossary term, decision, specification, mockup, or audit record.'
user-invocable: true
disable-model-invocation: false
---

# Papyrus Management

## Outcome

All backlog and managed documentation records are created, read, and changed through the Papyrus CLI, so IDs, files, links, statuses, and the browser view stay consistent.

## Golden rule

Never edit Papyrus-managed files directly. Use the CLI for every read and write. Plain (non-Papyrus) records are normal Markdown (requests, test cases, release reports, architecture, domain model).

## Managed artifacts

| Artifact | ID prefix | Directory |
|---|---|---|
| Tasks | `TASK` | `backlog/tasks/` |
| Milestones | `MS` | `backlog/milestones/` |
| Releases | `REL` | `backlog/releases/` |
| Business requirements | `REQ` | `docs/requirements/business/` |
| Non-functional requirements | `NFR` | `docs/requirements/non-functional/` |
| Business rules | `RUL` | `docs/business-rules/` |
| Glossary terms | `GLO` | `docs/glossary/` |
| Decision records | `ADR` / `BDR` | `decisions/` |
| UI specifications | `UI` | `docs/specifications/ui/` |
| UI mockups | `MOCK` | `docs/specifications/ui/mockups/` |
| Technical specifications | `TECH` | `docs/technical/` |
| Audit records | `AUD` | `docs/audit-records/` |

## Task statuses

Exact values: `ToDo → Initiated → Refined → Implemented → Validated → Done`.

- Default is `ToDo`. Never skip backward to `ToDo`; use `Initiated` or `Refined` when work returns.
- Workflow uses `To Do`, `In-Progress`, `Done`: map `To Do`→`ToDo`, `In-Progress`→the stage reached, `Done`→`Done`.
- `Done` means every acceptance criterion is fulfilled and, when the task's artifact requires it, the user's verification is obtained. No other end-of-task approval is requested.
- No `--ready` flag. Compute readiness from `metadata.dependencies` and the `Done` set.
- No priority field. Use `--ordinal` (lower first) and dependencies.

## Plain workflow records

| Record | ID prefix | Directory | Owner |
|---|---|---|---|
| Requests | `REQUEST` | `docs/requests/` | `key-account-manager` |
| Test cases | `TC` | `docs/test-cases/` | `test-manager` |
| Release reports | — | `docs/release-reports/` | `orchestrator` |

Read and write these as normal files, not through Papyrus.

## Tool commands

All tool commands live in the `manage-*` artifact skills. This skill holds only the tool-agnostic rules.

Full syntax, JSON shapes, and caveats: `skills/managed-records/references/REFERENCE.md`.

## Records and evidence

- Task evidence, review outcomes: record as a comment (manage-tasks).
- Release audit summary: create an audit record (manage-audits).
- Release completion: record completion (manage-releases).
- Never change task scope, acceptance criteria, or dependencies outside `task-refiner` or `planner`.
- Mockups start `pending`; set `approved` only after explicit user approval. Do not hand-edit metadata comments.
- The security officer reports; the orchestrator records the audit.
- Use the documentation browser (managed-records) as the documentation index. Never generate or edit `index.html`.

## Notes

- Create the group before creating a requirement or NFR in it.
- Put acceptance criteria in the description text; Papyrus has no dedicated acceptance-criteria field.
- Use `--editor` only when an interactive editor is appropriate.
- Use only project-local `./.tmp/` for scratch work and remove it before finishing.
