# Development workflow

## Artifacts

Every artifact is defined with the same fields, in the same order, so definitions can be compared and reviewed one artifact at a time.

| Field            | Meaning                                                                                             |
| ---------------- | --------------------------------------------------------------------------------------------------- |
| Definition       | What the artifact is, without policy or process                                                     |
| Goal             | Why the artifact exists and what it is for                                                          |
| Granularity      | The unit an instance is created for (request, feature, milestone, work item, release, change)       |
| Owner / approver | Who owns the content and who approves it                                                            |
| Produced by      | The phase and task kind that creates or updates it                                                  |
| Lifecycle        | The states an instance moves through                                                                |
| Required fields  | The content every instance must carry; an artifact is complete when every required field is present |
| Relations        | The artifacts it links to, with direction                                                           |
| Never contains   | The content that belongs to another artifact                                                        |
| Verified by      | The check and phase that prove it is met                                                            |

`*not defined*` marks a field the workflow does not yet specify. A `Notes` row appears only where existing text is not yet classified as one of the fields above. Both are review targets, not omissions by accident.

### Requests

| Field            | Content                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Definition       | A stakeholder's need for the software to do something new or differently, summarized in canonical business terminology before analysis and kept as a persistent record.                                                                                                                                                                                                                                                                                                                                                             |
| Goal             | Record what is expected from the software by stakeholders, so that requirements are grounded in real needs and nothing is lost, softened, or invented.                                                                                                                                                                                                                                                                                                                                                                              |
| Granularity      | One per request. A request is described by one or more items; an item is an aspect of the request, and the items of one request are handled only together, never split into separate requests.                                                                                                                                                                                                                                                                                                                                      |
| Owner / approver | `key-account-manager` (all content) / requester (confirms the content is faithful at creation). `status` and `references` are the only fields another actor may update, each from the step that records it.                                                                                                                                                                                                                                                                                                                         |
| Produced by      | Phase 1 Request intake, `key-account-manager`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| Lifecycle        | `open` → `in-progress` (requirements work, or planning for a `bug`, has started)<br/>`open` → `parked` (the requester agrees to hold the need for later)<br/>`parked` → `in-progress` (intake reactivates it when its time has come)<br/>`open`, `parked`, `in-progress` → `closed` (the work is planned)<br/>`open`, `parked`, `in-progress` → `rejected` (the need will not be fulfilled, with a reason)<br/>`closed` and `rejected` are terminal. Before creation the request exists only in the session and is not an artifact. |
| Required fields  | Artifact: identifier, title, category (`bug`, `enhancement`, `technical-improvement`), requested outcome, status (`open`, `parked`, `in-progress`, `closed`, `rejected`), references, requester confirmation.<br/>Item: item number, statement with requester and context, theme and affected area, open questions, references.<br/>Grouping: theme group, with cross-cutting quality concerns in a separate group.                                                                                                                 |
| Relations        | Outbound: requirements created or modified, recorded on the affected item.<br/>Outbound: work items, once a `bug` request is planned.<br/>Peer: overlapping requests considered for merging.<br/>Inbound: none.                                                                                                                                                                                                                                                                                                                     |
| Never contains   | Requirements, acceptance criteria, user stories, business rules, priority, scope, solution, architecture, design, estimates, work items, milestones, and releases.                                                                                                                                                                                                                                                                                                                                                                  |
| Verified by      | Phase 1 creation criteria, before creation; Phase 2 input check, which returns an incomplete or missing artifact to Phase 1; Phase 3 closure check, which confirms the status and the references.                                                                                                                                                                                                                                                                                                                                   |
| Notes            | `bug` requests go directly to planning.<br/>Open requests are listable on demand; parked requests are listed separately and reactivated by intake when their time has come.<br/>Items are aspects of one need and are handled together; a request is never partially closed.                                                                                                                                                                                                                                                        |

### Requirements

| Field            | Content                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| ---------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Definition       | A documented representation of a need, capability, or property the software shall have. A business requirement states what the software shall do; a non-functional requirement states how well it must do it, as an observable and achievable quality attribute or constraint.                                                                                                                                                                                                                                                                                                                                                     |
| Goal             | State what the system shall do and how well, verified and traceable, so planning can rely on it and verification can test against it.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| Granularity      | Two levels in one artifact: requirement groups, and atomic requirements that belong to exactly one group. Grouping is structural — the coarser level of the same artifact. An atomic requirement states one behavior, or one quality attribute target.                                                                                                                                                                                                                                                                                                                                                                             |
| Owner / approver | `requirements-engineer` (sole editor and verifier; self-verification is accepted) / requester or user, for a change of meaning                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| Produced by      | Phase 2 Requirements, `requirements-engineer`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| Lifecycle        | `draft` → `verified`; a requirement that is removed is `archived`. A failed verification leaves it `draft` and records the result as `gaps` or `blocked`. No version history: a change replaces the current text.                                                                                                                                                                                                                                                                                                                                                                                                                  |
| Required fields  | Requirement group: identifier, title, scope description, user story.<br/>Business requirement (REQ): identifier, group, title, user story, description, acceptance criteria (testable and unambiguous), references to the request and related requirements.<br/>Non-functional requirement (NFR): identifier, group, description with an observable and achievable target, quality attribute or constraint named in the rationale, verification method, references.<br/>All: status (`draft`, `verified`, `archived`). Identifiers are two-level: group `REQ-001` or `NFR-001`; atomic requirement `REQ-001.002` or `NFR-001.002`. |
| Relations        | Containment: every requirement belongs to exactly one group.<br/>Inbound: request item it fulfills.<br/>Outbound: business rules, glossary terms, domain objects, specification sections, work items, tests.                                                                                                                                                                                                                                                                                                                                                                                                                       |
| Never contains   | Solution design, architecture decisions, technology, business rule statements, UI design, tasks, task-level acceptance criteria, execution evidence, estimates, and code.                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| Verified by      | Phase 2 verification, per requirement; Phase 5 verification against the requirement acceptance criteria, which may be satisfied across several tasks; Phase 6 release quality audit, for NFR coverage.                                                                                                                                                                                                                                                                                                                                                                                                                             |
| Notes            | Corpus-level verification in Phase 2 (no duplicates or contradictions, terminology consistency, listability) applies to the set of requirements, not to a single requirement.<br/>Priority and timing are not requirement fields: whether and when a need is fulfilled is decided through the request lifecycle and planning.<br/>No versioning: the corpus is the current truth for the task at hand; a correction replaces the text.                                                                                                                                                                                             |

### Business Rules

| Field            | Content                                                                                                                                    |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| Definition       | A rule, formula, or way of deciding an outcome required for the fulfillment of a requirement.                                              |
| Goal             | State the decision logic and constraints of the business domain that implementation must obey. Every rule must help fulfill a requirement. |
| Granularity      | *not defined*                                                                                                                              |
| Owner / approver | `business-analyst` / *not defined*                                                                                                         |
| Produced by      | Phase 2 Requirements, delegated to `business-analyst`                                                                                      |
| Lifecycle        | *not defined*                                                                                                                              |
| Required fields  | Rule statement, rationale, applicability, exceptions, source requirement traceability, and verification status                             |
| Relations        | Source requirement; other relations *not defined*                                                                                          |
| Never contains   | Requirements themselves, technical validation logic, and UI behavior.                                                                      |
| Verified by      | *not defined*                                                                                                                              |

### Business Glossary

| Field            | Content                                                                                                                                                   |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Definition       | A list of terms and their meanings.                                                                                                                       |
| Goal             | Maintain one canonical meaning per business term, so requirements, rules, domain model, specifications, UI text, tickets, and code use the same language. |
| Granularity      | *not defined*                                                                                                                                             |
| Owner / approver | `terminologist` / *not defined*                                                                                                                           |
| Produced by      | Phase 2 Requirements, delegated to `terminologist`                                                                                                        |
| Lifecycle        | *not defined*                                                                                                                                             |
| Required fields  | Canonical term, definition, synonyms, homonyms, acronyms and abbreviations, cross-references, and deprecated variants                                     |
| Relations        | Cross-references; targets *not defined*                                                                                                                   |
| Never contains   | Entity and attribute design (domain model) and code identifiers.                                                                                          |
| Verified by      | *not defined*                                                                                                                                             |

### Domain Model

| Field            | Content                                                                                                                                                   |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Definition       | An abstract model of a domain with its contexts, objects, and processes, describing phenomena in an application domain.                                   |
| Goal             | Describe the business domain independently of implementation, so requirements are understood in their real context and solutions use consistent concepts. |
| Granularity      | *not defined*                                                                                                                                             |
| Owner / approver | `domain-modeler` / *not defined*                                                                                                                          |
| Produced by      | Phase 2 Requirements, delegated to `domain-modeler`; project bootstrap                                                                                    |
| Lifecycle        | *not defined*                                                                                                                                             |
| Required fields  | Context map, business object model, state diagrams, attribute lists, and business process diagrams                                                        |
| Relations        | *not defined*                                                                                                                                             |
| Never contains   | Technical architecture, code structure, and UI design.                                                                                                    |
| Verified by      | *not defined*                                                                                                                                             |

### Architecture

| Field            | Content                                                                                                                                                                                                                                                                                                                   |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Definition       | The design principles, properties, and evolution strategy of a system.                                                                                                                                                                                                                                                    |
| Goal             | Fix the fundamental structure, global solution design, and technology stack so that quality requirements are met and the system can evolve coherently.                                                                                                                                                                    |
| Granularity      | *not defined*                                                                                                                                                                                                                                                                                                             |
| Owner / approver | `architect` / *not defined*                                                                                                                                                                                                                                                                                               |
| Produced by      | Phase 4, architecture impact assessment task kind; no task kind for the project baseline                                                                                                                                                                                                                                  |
| Lifecycle        | *not defined*                                                                                                                                                                                                                                                                                                             |
| Required fields  | Architecture description with context, building-block, runtime, and deployment views; global solution design; technology stack selection (languages, frameworks, platforms, infrastructure); external interfaces and contracts; cross-cutting concepts; NFR coverage; architecture decisions, alternatives, and rationale |
| Relations        | NFR coverage; architecture decisions (artifact *not defined*)                                                                                                                                                                                                                                                             |
| Never contains   | Requirement content, detailed design, and source code.                                                                                                                                                                                                                                                                    |
| Verified by      | *not defined*                                                                                                                                                                                                                                                                                                             |

### Technical specification

| Field            | Content                                                                                                                                                           |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Definition       | A systematically represented description of the properties of the feature to be implemented, covering behavior, flows, states, data, interfaces, and constraints. |
| Goal             | Turn verified requirements and architecture decisions into an implementation-consumable specification that implementation and verification can rely on.           |
| Granularity      | *not defined*                                                                                                                                                     |
| Owner / approver | `architect`, `tech-writer` / *not defined*                                                                                                                        |
| Produced by      | Phase 4; no task kind defined                                                                                                                                     |
| Lifecycle        | *not defined*                                                                                                                                                     |
| Required fields  | Feature behavior, flows and states, data and API-facing attributes, validation and error behavior, interface contracts, and traceability to REQ/NFR and decisions |
| Relations        | Requirements (REQ/NFR); architecture decisions (artifact *not defined*)                                                                                           |
| Never contains   | Business requirements, roadmap order, and source code.                                                                                                            |
| Verified by      | *not defined*                                                                                                                                                     |

### Backlog

| Field            | Content                                                                                                                                                        |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Definition       | An ordered list of tasks, milestones, and releases planned to reach the expected state of the developed software.                                              |
| Goal             | Turn verified requirements into an ordered, dependency-safe delivery plan that the orchestrator can execute without re-planning.                               |
| Granularity      | *not defined*                                                                                                                                                  |
| Owner / approver | `planner` / *not defined*                                                                                                                                      |
| Produced by      | Phase 3 Planning, `planner`                                                                                                                                    |
| Lifecycle        | *not defined*                                                                                                                                                  |
| Required fields  | Feature roadmap, feature priority encoded, milestones, releases, high-level feature tickets, dependencies, release assignment, and dependency-graph validation |
| Relations        | Milestones, releases, dependencies; requirement references *not defined*                                                                                       |
| Never contains   | Ticket-level scope and acceptance criteria (`task-refiner`), execution status and approvals (`orchestrator`).                                                  |
| Verified by      | *not defined*                                                                                                                                                  |

### Release

| Field            | Content                                                                                                                                     |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| Definition       | A version record with acceptance criteria that owns one or more milestones.                                                                 |
| Goal             | Group verified milestones into one releasable scope, and record the final version and its completion after user approval.                   |
| Granularity      | *not defined*                                                                                                                               |
| Owner / approver | `planner` (creates and assigns milestones); `orchestrator` (chooses the final version and completes it) / *not defined*                     |
| Produced by      | Phase 3 Planning, `planner`                                                                                                                 |
| Lifecycle        | *not defined*                                                                                                                               |
| Required fields  | Acceptance criteria, owned milestones and release scope, RC versions from Phase 5, the final version, completion note, and completion state |
| Relations        | Owned milestones; RC versions from milestone verification                                                                                   |
| Never contains   | Release report content, audit findings, and the approval decision itself.                                                                   |
| Verified by      | *not defined*                                                                                                                               |

### Implementation plan

| Field            | Content                                                                                                                                                                                |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Definition       | A description of the implementation details of a task.                                                                                                                                 |
| Goal             | Make a single ticket self-contained and implementation-ready, so implementation and review need no further clarification. Follow the technical specification and architecture defined. |
| Granularity      | One per ticket, by the goal; "task" by the definition                                                                                                                                  |
| Owner / approver | `task-refiner` / *not defined*                                                                                                                                                         |
| Produced by      | Phase 4, refinement task kind                                                                                                                                                          |
| Lifecycle        | *not defined*                                                                                                                                                                          |
| Required fields  | Ticket scope, user story, behavior, acceptance criteria, affected REQ/NFR IDs, UI and specification references, technical notes, and test expectations                                 |
| Relations        | Requirements (REQ/NFR); UI and specification references                                                                                                                                |
| Never contains   | Architecture decisions, implementation code, and roadmap order.                                                                                                                        |
| Verified by      | *not defined*                                                                                                                                                                          |
| Notes            | "User story", "behavior", and "acceptance criteria" duplicate requirement content; "task" and "ticket" are used for the same unit.                                                     |

### UI Specification

| Field            | Content                                                                                                                                                                              |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Definition       | A systematic description of the expected user interface.                                                                                                                             |
| Goal             | Describe the user interface in words precisely enough that design, implementation, and review work from one shared understanding of screens, layout, navigation, and states.         |
| Granularity      | *not defined*                                                                                                                                                                        |
| Owner / approver | `ui-designer` / *not defined*                                                                                                                                                        |
| Produced by      | Phase 4, UI design task kind                                                                                                                                                         |
| Lifecycle        | *not defined*                                                                                                                                                                        |
| Required fields  | UI description documents: screen inventory, layout regions, navigation, UI states, interaction behavior, validation and message expectations, and platform differences. Layout only. |
| Relations        | *not defined*                                                                                                                                                                        |
| Never contains   | Technology and library choices, production styling assets, backend behavior, and clickable prototypes.                                                                               |
| Verified by      | *not defined*                                                                                                                                                                        |
| Notes            | "Layout only" contradicts the listed interaction, validation, and UI state content.                                                                                                  |

### UI Mockups

| Field            | Content                                                                                                                                                                                    |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Definition       | A graphical description of the expected user interface.                                                                                                                                    |
| Goal             | Provide layout, navigation, and design for the happy-path flow, so they can be agreed and approved before code is written.                                                                 |
| Granularity      | One per affected ticket, per platform                                                                                                                                                      |
| Owner / approver | `ui-designer` / user                                                                                                                                                                       |
| Produced by      | Phase 4, UI design task kind                                                                                                                                                               |
| Lifecycle        | Approval state; values *not defined*                                                                                                                                                       |
| Required fields  | One self-contained clickable HTML mockup per affected ticket, covering the current feature's happy path per platform, with a review landing and navigation between screens; approval state |
| Relations        | Affected ticket; UI specification (*not defined*)                                                                                                                                          |
| Never contains   | Production styling assets, technology choices, backend behavior, and the UI specification itself.                                                                                          |
| Verified by      | *not defined*                                                                                                                                                                              |

### Source Code and Tests

| Field            | Content                                                                                                               |
| ---------------- | --------------------------------------------------------------------------------------------------------------------- |
| Definition       | An artifact that can be compiled or interpreted to provide functionality to the user.                                 |
| Goal             | Implement the specified behavior and verify it, so acceptance criteria and quality requirements are demonstrably met. |
| Granularity      | *not defined*                                                                                                         |
| Owner / approver | `android-dev`, `backend-dev`, `frontend-dev`, `rust-dev` / *not defined*                                              |
| Produced by      | Phase 4, implementation task kind                                                                                     |
| Lifecycle        | *not defined*                                                                                                         |
| Required fields  | Production code, unit and integration tests, and build and dependency configuration                                   |
| Relations        | *not defined*                                                                                                         |
| Never contains   | Requirements, plans, design approval, and review verdicts.                                                            |
| Verified by      | *not defined*                                                                                                         |

### Milestone Verification Task

| Field            | Content                                                                                                                                |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| Definition       | The record of the independent verification of one milestone at its boundary.                                                           |
| Goal             | Establish, with evidence, whether a milestone's changes satisfy their acceptance criteria and quality requirements before the release. |
| Granularity      | One per milestone                                                                                                                      |
| Owner / approver | `planner` (creates); `orchestrator` (executes); `quality-gatekeeper`, Code Audit owner TBD (checks) / *not defined*                    |
| Produced by      | Phase 3 Planning, `planner`                                                                                                            |
| Lifecycle        | `To Do` → `In-Progress` → `Done`; `Done` only when verification passes, and the milestone cannot close before it.                      |
| Required fields  | Milestone and change set, checks run, evidence, findings, correction tasks, RC version, and final result                               |
| Relations        | Milestone; findings; correction tasks                                                                                                  |
| Never contains   | Fixes, new requirements, and release approval.                                                                                         |
| Verified by      | *not defined*                                                                                                                          |

### Audit

| Field            | Content                                                                                                                                                                            |
| ---------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Definition       | An assessment of a work product against defined criteria, recorded with a type: quality, code, or security.                                                                        |
| Goal             | Give an evidence-based, severity-ranked verdict on the assessed scope, so the user can decide acceptance rather than rely on assumption.                                           |
| Granularity      | One per check per assessed scope: change-scoped in Phase 5, release-wide in Phase 6                                                                                                |
| Owner / approver | `quality-gatekeeper` (quality), Code Audit owner TBD (code), `security-officer` (security) / user accepts findings                                                                 |
| Produced by      | Phase 5 (type: code); Phase 6 (types: quality, code, security)                                                                                                                     |
| Lifecycle        | *not defined*                                                                                                                                                                      |
| Required fields  | Audit type; scope inspected; criteria and checks run; severity-ranked findings with evidence, location, owner, and recommendation; the user's acceptance decision for each finding |
| Relations        | Work product under audit; findings; follow-up work items                                                                                                                           |
| Never contains   | Remediation implementation and functional testing.                                                                                                                                 |
| Verified by      | *not defined*                                                                                                                                                                      |
| Notes            | Always read-only.                                                                                                                                                                  |

### Release Report

| Field            | Content                                                                                                                                                                                                                                                  |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Definition       | A consolidated account of a release, built from verification evidence.                                                                                                                                                                                   |
| Goal             | Give the user one complete, evidence-backed basis for approving or withholding a release.                                                                                                                                                                |
| Granularity      | One per release                                                                                                                                                                                                                                          |
| Owner / approver | `orchestrator` / *not defined*                                                                                                                                                                                                                           |
| Produced by      | Phase 6 Release, `orchestrator`                                                                                                                                                                                                                          |
| Lifecycle        | *not defined*                                                                                                                                                                                                                                            |
| Required fields  | Version, scope, milestones, completed tasks and traceability, release acceptance evidence, build and final test results, per-milestone verification, audit severity counts by type, accepted risks with owners, findings, follow-ups, and recommendation |
| Relations        | Release; milestones; verification tasks; audits                                                                                                                                                                                                          |
| Never contains   | New verification, fixes, and the approval decision itself.                                                                                                                                                                                               |
| Verified by      | *not defined*                                                                                                                                                                                                                                            |

## Audit types

- quality audit, checks:
  - acceptance criteria
  - definition of done
  - scope creep
  - NFR coverage
- code audit, checks:
  - complexity
  - duplication
  - naming
  - structure
  - test coverage
  - style-guide compliance
- security audit, checks:
  - secrets
  - dependency supply chain
  - authentication and authorization
  - input handling
  - data protection
  - platform-specific risks
  - cross-feature risks

## Acceptance criteria

"The criteria that a work product must satisfy to be accepted by the stakeholders"; in agile development, the criteria that the implementation of a backlog item must satisfy.
