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

Plain (non-Papyrus) documents remain normal Markdown files: architecture narratives, domain-model diagrams, attribute lists, and business-process diagrams.

## Instructions

- Papyrus is the only backlog and managed-document tool: all task, milestone, release, requirement, NFR, rule, glossary, decision, specification, mockup, and audit reads and writes MUST use the Papyrus CLI via the `papyrus` skill. Never edit Papyrus-managed files directly. Exception: the UI designer authors the body of Papyrus-created mockup HTML files; the Papyrus metadata comments in those files remain Papyrus-owned.
- Task statuses are exactly `ToDo`, `Initiated`, `Refined`, `Implemented`, `Validated`, `Done`. `Done` is reserved for explicit user approval unless no-validation mode was requested.
- Papyrus has no priority field. Execution order is encoded with `ordinal` (lower first) and `dependencies`. Report user priority through ordinal assignment, not a `priority` field.
- Workflow ownership: `orchestrator` is the primary entry point and owns task, milestone, and release execution; it delegates planning to the `planner` subagent. `quality-gatekeeper` reviews tickets; `security-officer` audits every release.
- New feature/requirement intake: `orchestrator` sends the request to `requirements-engineer` first. After requirements are validated, it calls the `planner` subagent to check and correct the roadmap and task order. Never send a new feature directly to `planner`.
- Orchestration workflow: `workflows/orchestrator/README.md` is the canonical description of task, milestone, and release orchestration.
- Task execution selection (orchestrator): before new work, resume the lowest-ordinal in-progress task. Otherwise take the first ready `ToDo` task, where ready means every dependency is `Done`. Read state with `papyrus --json task list` and compute readiness from `metadata.dependencies`.
- Planning (`planner` subagent): plan and sequence only; do not execute tasks. Keep in-progress tasks stable unless the user asks to re-plan them. Store the roadmap as a Papyrus technical specification titled `Feature Roadmap`.
- Release gate: every release ends with a `security-officer` audit. A `Block` decision (unresolved Critical or High finding) prevents release completion; `Pass with findings` requires documented owners for remaining findings.
- Release convention: a release is a Papyrus `REL` record titled `Release <version>`; milestones are assigned with `papyrus milestone edit <MS-ID> --release <REL-ID>`. The orchestrator delegates creation to the `planner` subagent and records completion with the `released` label plus a completion note.
- UI mockups: every created or materially revised mockup must be explicitly approved by the user (`approved` in Papyrus) before implementation.
- Documentation indexes: use `papyrus browser` (or `papyrus search`) to browse and search the documentation corpus. Never generate or hand-edit `index.html` files; index generators are not used.
- Never write anything to `/tmp`, `/var/tmp`, or any system temporary directory. All temporary files and scratchpads MUST be created in the project-local `./.tmp/` directory (the `.tmp` folder in the folder where the agent is running), and MUST always be cleaned up/removed before the task ends, including on failure or when blocked.
- When working on a project's root `README.md`, ensure an AI notice is present at the end of the file (e.g., a short statement that the content was generated or assisted by AI).

## Temporary Files and Scratchpads

- Scope: any intermediate, scratch, or temporary file produced while working, including scratchpads, drafts, dumps, and working notes.
- Location: MUST be written only under `./.tmp/` relative to the folder where the agent is running. Never use `/tmp`, `/var/tmp`, or other system temp locations.
- Cleanup: remove all such files from `./.tmp/` before finishing, even if the task fails or is blocked; do not leave artifacts behind.
- Agents and skills must interpret `./.tmp/` as the sole permitted temporary/scratchpad location.
