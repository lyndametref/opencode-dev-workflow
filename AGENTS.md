# AGENTS

## Papyrus-managed artifacts

The following are managed by the Papyrus CLI. Never edit their files directly, except the body of a Papyrus-created mockup HTML file, which the UI designer authors while leaving the Papyrus metadata comments intact.

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

Plain (non-Papyrus) documents remain normal Markdown files: architecture narratives, domain-model diagrams, attribute lists, business-process diagrams, and the workflow records below.

| Workflow record | ID prefix | Directory | Owner |
|---|---|---|---|
| Requests | `REQUEST` | `docs/requests/` | `key-account-manager` |
| Test cases | `TC` | `docs/test-cases/` | `test-manager` |
| Release reports | — | `docs/release-reports/` | `orchestrator` |

## Instructions

- Papyrus is the only backlog and managed-document tool: all task, milestone, release, requirement, NFR, rule, glossary, decision, specification, mockup, and audit reads and writes MUST use the Papyrus CLI via the `papyrus` skill. Never edit Papyrus-managed files directly. Exception: the UI designer authors the body of Papyrus-created mockup HTML files; the Papyrus metadata comments in those files remain Papyrus-owned.
- Task statuses are exactly `ToDo`, `Initiated`, `Refined`, `Implemented`, `Validated`, `Done`. The orchestrator workflow uses `To Do`, `In-Progress`, and `Done`; map `In-Progress` to the stage reached (`Initiated`, `Refined`, `Implemented`, or `Validated`). `Done` means every acceptance criterion is fulfilled and, when the task's artifact requires it, the user's verification is obtained; no other end-of-task approval is requested.
- Papyrus has no priority field. Execution order is encoded with `ordinal` (lower first) and `dependencies`. Report user priority through ordinal assignment, not a `priority` field.
- Workflow ownership: `orchestrator` is the primary entry point and owns execution across Phases 1-6. `key-account-manager` owns request intake; `requirements-engineer` owns requirements; `planner` owns planning; `architect`, `ui-designer`, `test-manager`, `task-refiner`, `tech-writer`, and the `*-dev` agents own Phase 4 artifacts; `quality-gatekeeper` and `code-analyzer` own Phase 5 verification; `security-officer` audits every release in Phase 6.
- New feature/requirement intake: `key-account-manager` captures a request artifact under `docs/requests/`. `orchestrator` routes it through `intake-routing`: `requirements-engineer` first (except for a `bug`), then `planner`. Architecture impact is reported as a flag and scheduled by planning as a Phase 4 task. Never send a new feature directly to `planner`, and never bypass `requirements-engineer` for a non-bug request. `key-account-manager` never delegates to `requirements-engineer` or `planner` directly.
- Orchestration workflow: `workflows/orchestrator/` is the canonical description of the six phases (start at `artifacts.md`, then phases `1-`…`6-` and `0-End-to-End.md`). Where an agent or skill conflicts with it, the workflow wins.
- Milestone execution (`orchestrator`): load `milestone-execution`. Resume the lowest-ordinal in-progress task; otherwise take the first ready `ToDo` task whose dependencies are `Done`. Read state with `papyrus --json task list` and compute readiness from `metadata.dependencies`. Stop at the milestone boundary.
- Planning (`planner`): plan and sequence only; do not execute tasks. Keep in-progress tasks stable unless the user asks to re-plan them. Store the roadmap as a Papyrus technical specification titled `Feature Roadmap`.
- Verification: Phase 5 runs one milestone verification task with a `quality-gatekeeper` quality audit and a `code-analyzer` code audit. Milestones are not complete until the verification task is `Done`. Security is not assessed per milestone.
- Release gate: every release ends with release quality, code, and security audits. The user approves the scope and audit findings before the final build, then approves the release report. A security `Block` decision (unresolved Critical or High finding) prevents release completion; `Pass with findings` requires documented owners for remaining findings.
- Release convention: a release is a Papyrus `REL` record created with a working title such as `Release (pending version)` and renamed to `Release <version>` in Phase 6; milestones are assigned with `papyrus milestone edit <MS-ID> --release <REL-ID>`. The orchestrator delegates creation to `planner` and records completion with the `released` label plus a completion note and the release report under `docs/release-reports/`.
- UI mockups: every created or materially revised mockup must be explicitly approved by the user (`approved` in Papyrus) before implementation. At most one mockup is produced per milestone.
- Documentation indexes: use `papyrus browser` (or `papyrus search`) to browse and search the documentation corpus. Never generate or hand-edit `index.html` files; index generators are not used.
- Never write anything to `/tmp`, `/var/tmp`, or any system temporary directory. All temporary files and scratchpads MUST be created in the project-local `./.tmp/` directory (the `.tmp` folder in the folder where the agent is running), and MUST always be cleaned up/removed before the task ends, including on failure or when blocked.
- When working on a project's root `README.md`, ensure an AI notice is present at the end of the file (e.g., a short statement that the content was generated or assisted by AI).

## Temporary Files and Scratchpads

- Scope: any intermediate, scratch, or temporary file produced while working, including scratchpads, drafts, dumps, and working notes.
- Location: MUST be written only under `./.tmp/` relative to the folder where the agent is running. Never use `/tmp`, `/var/tmp`, or other system temp locations.
- Cleanup: remove all such files from `./.tmp/` before finishing, even if the task fails or is blocked; do not leave artifacts behind.
- Agents and skills must interpret `./.tmp/` as the sole permitted temporary/scratchpad location.
