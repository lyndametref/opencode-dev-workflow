# Deprecated

Agents and skills removed from the active orchestrator workflow.

OpenCode loads `agents/` and `skills/` only; this directory is reference-only.

## Agents

| Agent | Reason |
|---|---|
| `encyclopedist` | Outside the six-phase software workflow. |

## Skills

| Skill | Reason |
|---|---|
| `key-account-management` | Replaced by `request-intake` (Phase 1 request artifacts). |
| `reverse-engineering` | Not part of the orchestrator workflow. |
| `quality-verification` | Replaced by `quality-audit` (Phase 5/6). |
| `task-orchestration` | Replaced by `milestone-execution` (Phase 4). |
| `milestone-orchestration` | Replaced by `milestone-execution` and `milestone-verification` (Phases 4-5). |
| `release-orchestration` | Replaced by `release-management` (Phase 6). |
| `markdown-move` | Not used by any active agent. |
