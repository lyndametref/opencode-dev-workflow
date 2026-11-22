# Orchestrator workflow

How the orchestrator takes a request from intake to a completed release.

**Status: work in progress.** The artifact model is normative; the phase files implement it. Where a phase and an artifact definition disagree, the artifact definition wins.

Start with [0-End-to-End.md](./0-End-to-End.md) for the whole flow. Each artifact is defined in [artifacts.md](./artifacts.md) and listed under *Artifacts at a glance*. The workflow names artifacts, owners, phases, and states; it does not prescribe storage formats or tools.

## Phases

| Phase | Owner | Output | User gate |
|---|---|---|---|
| [1. Request intake](./1-Request_intake.md) | `key-account-manager` | Requests | Whether a request is `open` or `parked`, and that its content is faithful |
| [2. Requirements](./2-Requirements.md) | `requirements-engineer` | Requirements; Business Rules, Business Glossary, Domain Model, Decision (type `business`) when impacted | A change of meaning, and any decision opened by a trade-off |
| [3. Planning](./3-Planning.md) | `planner` | Backlog; Task; Milestone; Release | Priority and scope |
| [4. Implementation](./4-Implementation.md) | `architect`, `ui-designer`, `test-manager`, `task-refiner`, `tech-writer`, `*-dev` agents, `orchestrator` | Architecture; Decision (type `architecture`); Technical specification; UI Specification; UI Mockups; Test Case; Source Code; RC package under `builds/<version>/` | Architecture, mockup, and test-case verification by the user |
| [5. Verification](./5-Verification.md) | `quality-gatekeeper`, `code-analyzer`, `security-officer`, `orchestrator` | Audit (types `quality`, `code`, `security`); release verification task | None: findings become fix tasks; the user accepts them at the Phase 6 release gate |
| [6. Release](./6-Release.md) | `orchestrator`, `quality-gatekeeper`, `planner` | Release report; final package under `builds/<version>/`; completed Release | Scope and findings, then the release itself |

## Artifacts at a glance

| Artifact | Owner |
|---|---|
| [Requests](./artifacts.md#requests) | `key-account-manager` |
| [Requirements](./artifacts.md#requirements) | `requirements-engineer` |
| [Business Glossary](./artifacts.md#business-glossary) | `terminologist` |
| [Domain Model](./artifacts.md#domain-model) | `domain-modeler` |
| [Business Rules](./artifacts.md#business-rules) | `business-analyst` |
| [Backlog](./artifacts.md#backlog) | `planner` |
| [Task](./artifacts.md#task) | `planner`, `task-refiner`, assigned actor, `orchestrator` |
| [Milestone](./artifacts.md#milestone) | `planner` |
| [Release](./artifacts.md#release) | `planner` and `orchestrator` |
| [Architecture](./artifacts.md#architecture) | `architect` |
| [Decision](./artifacts.md#decision) | `user`, documented by the affected owner |
| [Technical specification](./artifacts.md#technical-specification) | `tech-writer`, approved by `architect` |
| [UI Specification](./artifacts.md#ui-specification) | `ui-designer` |
| [UI Mockups](./artifacts.md#ui-mockups) | `ui-designer`, approved by the user |
| [Test Case](./artifacts.md#test-case) | `test-manager`, approved by the user |
| [Source Code](./artifacts.md#source-code) | assigned `*-dev` agent |
| [Audit](./artifacts.md#audit) | `quality-gatekeeper`, `code-analyzer`, `security-officer` |
| [Release Report](./artifacts.md#release-report) | `orchestrator` |
