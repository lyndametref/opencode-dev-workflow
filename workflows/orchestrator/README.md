# Orchestrator workflow

How the orchestrator takes a request from intake to a completed release.

**Status: work in progress.** The artifact model is normative; the phase files implement it. Where a phase and an artifact definition disagree, the artifact definition wins.

Start with [0-End-to-End.md](./0-End-to-End.md) for the whole flow. Each artifact is defined in [artifacts.md](./artifacts.md) and listed under *Artifacts at a glance*. The workflow names artifacts, owners, phases, and states; it does not prescribe storage formats or tools.

## Phases

| Phase | Owner | Output | User gate |
|---|---|---|---|
| [1. Request intake](./1-Request_intake.md) | `orchestrator` (`/new-request`) | Requests | Whether a request is `open` or `parked`, and that its content is faithful |
| [2. Requirements](./2-Requirements.md) | `requirements-engineer` | Requirements; Business Rules, Business Glossary, Domain Model when impacted; Decision (ADRs authored by the user between Phases 1 and 2) | A change of meaning, and the resolution of any conflict with existing requirements |
| [3. Planning](./3-Planning.md) | `orchestrator` (`/plan`) | Backlog; Task; Milestone; Release | Priority and scope |
| [4. Implementation](./4-Implementation.md) | `task-refiner`, `*-dev` agents, `quality-gatekeeper`, `orchestrator` | Technical specification; Decision; UI Specification; UI Mockups; Test Case; Source Code; milestone verification result including the standalone code audit | Mockup and test-case verification by the user |
| [5. Audit](./5-Audit.md) | `quality-gatekeeper` (`release-audit`) | Release audit report (quality, code, security); Audit records (`quality`, `code`, `security`); finding decisions | Every finding: fix or own |
| [6. Release](./6-Release.md) | `orchestrator`, `*-dev` agents, `ops` | Release report; final package under `builds/<version>/`; deployment evidence; completed Release | Scope and findings, then the release itself |

## Artifacts at a glance

| Artifact | Owner |
|---|---|
| [Requests](./artifacts.md#requests) | `orchestrator` |
| [Requirements](./artifacts.md#requirements) | `requirements-engineer` |
| [Business Glossary](./artifacts.md#business-glossary) | `terminologist` |
| [Domain Model](./artifacts.md#domain-model) | `domain-modeler` |
| [Business Rules](./artifacts.md#business-rules) | `business-analyst` |
| [Backlog](./artifacts.md#backlog) | `orchestrator` |
| [Task](./artifacts.md#task) | `orchestrator`; `task-refiner` (refinement and development tasks), assigned actor, `quality-gatekeeper` (verification) |
| [Milestone](./artifacts.md#milestone) | `orchestrator` |
| [Release](./artifacts.md#release) | `orchestrator` |
| [Decision](./artifacts.md#decision) | `user`; `task-refiner` records refinement decisions |
| [Technical specification](./artifacts.md#technical-specification) | `task-refiner` |
| [UI Specification](./artifacts.md#ui-specification) | `task-refiner` |
| [UI Mockups](./artifacts.md#ui-mockups) | `task-refiner`, approved by the user |
| [Test Case](./artifacts.md#test-case) | `task-refiner`, approved by the user |
| [Source Code](./artifacts.md#source-code) | assigned `*-dev` agent |
| [Audit](./artifacts.md#audit) | `quality-gatekeeper` |
| [Release Report](./artifacts.md#release-report) | `orchestrator` |
