# Development workflow

## Artifacts

### Inputs

**Owner:** `key-account-manager`

**Definition:** A request for the software to do something new or differently.

**Goal:** Record what is expected from the software by stakeholders, so that requirements are grounded in real needs and nothing is lost, softened, or invented.

**Scope:** Verbatim statements with requester and context; triage status; theme and affected area; severity with its basis; evidence; open questions. In-session only: no files, no registry, no memory across sessions. Handed-over items are forgotten.

**Out of scope:** requirements, rules, tasks, plans, designs, and code.

### Requirements

**Owner:** `requirements-engineer`

**Definition:** A documented representation of a need, capability, or property the software shall have. Business requirements focus on function — what the software shall do. Non-functional requirements (quality requirements) state how well the software must perform the function and are usually described by their importance and quality attributes.

**Goal:** State what the system shall do and how well, in a validated, traceable, consistent form that planning can rely on and verification can test against.

**Scope:** Business requirements (REQ) and non-functional requirements (NFR: quality requirements and constraints), with user story, description, criticality, acceptance criteria, rationale, verification method, references, and labels; includes elicitation, documentation, validation, and traceability.

**Out of scope:** solution design, architecture decisions, tasks, and code.

### Business Rules

**Owner:** `business-analyst`

**Definition:** A rule, formula, or way of deciding an outcome required for the fulfilment of a requirement.

**Goal:** State the decision logic and constraints of the business domain that implementation must obey. Every rule must help fulfil a requirement.

**Scope:** Rule statement, rationale, applicability, exceptions, source requirement traceability, and validation status.

**Out of scope:** requirements themselves, technical validation logic, and UI behavior.

### Business Glossary

**Owner:** `terminologist`

**Definition:** A list of terms and their meanings.

**Goal:** Maintain one canonical meaning per business term, so requirements, rules, domain model, specifications, UI text, tickets, and code use the same language.

**Scope:** Canonical term, definition, synonyms, homonyms, acronyms and abbreviations, cross-references, and deprecated variants.

**Out of scope:** entity and attribute design (domain model) and code identifiers.

### Domain Model

**Owner:** `domain-modeler`

**Definition:** An abstract model of a domain with its contexts, objects, and processes, describing phenomena in an application domain.

**Goal:** Describe the business domain independently of implementation, so requirements are understood in their real context and solutions use consistent concepts.

**Scope:** Context map, business object model, state diagrams, attribute lists, and business process diagrams.

**Out of scope:** technical architecture, code structure, and UI design.

### Architecture

**Owner:** `architect`

**Definition:** The design principles, properties, and evolution strategy of a system.

**Goal:** Fix the fundamental structure and principles of the system so that quality requirements are met and the system can evolve coherently.

**Scope:** Architecture description with context, building-block, runtime, and deployment views; external interfaces and contracts; cross-cutting concepts; NFR coverage; architecture decisions, alternatives, and rationale.

**Out of scope:** requirement content, detailed design, and source code.

### Backlog

**Owner:** `planner` subagent, launched by `orchestrator`

**Definition:** An ordered list of tasks, milestones, and releases planned to reach the expected state of the developed software.

**Goal:** Turn validated requirements into an ordered, dependency-safe delivery plan that the orchestrator can execute without re-planning.

**Scope:** Feature roadmap, feature priority encoded, milestones, releases, high-level feature tickets, dependencies, release assignment, and dependency-graph validation.

**Out of scope:** ticket-level scope and acceptance criteria (task-refiner), execution status and approvals (orchestrator).

### Implementation plan

**Owner:** `task-refiner`

**Definition:** A description of the implementation details of a task.

**Goal:** Make a single ticket self-contained and implementation-ready, so implementation and review need no further clarification. Follow the technical specification and architecture defined.

**Scope:** Ticket scope, user story, behavior, acceptance criteria, affected REQ/NFR IDs, UI and specification references, technical notes, and test expectations.

**Out of scope:** architecture decisions, implementation code, and roadmap order.

**Reference:** IREB — *Acceptance criteria*: "The criteria that a work product must satisfy to be accepted by the stakeholders"; in agile development, the criteria that the implementation of a backlog item must satisfy. *Backlog item*: "An individual element of a backlog."

### UI Specification

**Owner:** `ui-designer`

**Definition:** A systematic description of the expected user interface.

**Goal:** Describe the user interface in words precisely enough that design, implementation, and review work from one shared understanding of screens, layout, navigation, and states.

**Scope:** UI description documents: screen inventory, layout regions, navigation, UI states, interaction behavior, validation and message expectations, and platform differences. Layout only.

**Out of scope:** technology and library choices, production styling assets, backend behavior, and clickable prototypes.

**Reference:** IREB — *Specification* (as a work product): "A systematically represented description of the properties of an item (a system, a device, etc.) that satisfies given criteria."

### UI Mockups

**Owner:** `ui-designer`

**Definition:** A graphical description of the expected user interface.

**Goal:** Provide layout, navigation, and design for the happy-path flow, so they can be agreed and approved before code is written.

**Scope:** One self-contained clickable HTML mockup per affected ticket, covering the current feature's happy path per platform, with a review landing and navigation between screens; approval state.

**Out of scope:** production styling assets, technology choices, backend behavior, and the UI specification itself.

### Source Code and Tests

**Owner:** `android-dev`, `backend-dev`, `frontend-dev`, `rust-dev`

**Definition:** An artifact that can be compiled or interpreted to provide functionality to the user.

**Goal:** Implement the specified behavior and verify it, so acceptance criteria and quality requirements are demonstrably met.

**Scope:** Production code, unit and integration tests, and build and dependency configuration.

**Out of scope:** requirements, plans, design approval, and review verdicts.

### Quality Review Report

**Owner:** `quality-gatekeeper`

**Definition:** An assessment of an implementation and an evaluation of its fulfilment of acceptance criteria and definition of done.

**Goal:** Independently establish whether a completed ticket satisfies its acceptance criteria and definition of done before the user is asked to approve it.

**Scope:** Per-criterion evidence, test and build results, verification of scope, detected gaps or scope creep, and a pass/fail verdict with findings.

**Out of scope:** fixes, requirement changes, and the approval decision itself.

### Security Audit

**Owner:** `security-officer`

**Definition:** An assessment of an implementation and an evaluation of its vulnerability to malicious use and abuse.

**Goal:** Independently assess security risk for a release and give a release recommendation based on evidence rather than assumption.

**Scope:** Secrets, dependency supply chain, authentication and authorization, input handling, data protection, platform-specific risks, and security NFR coverage; severity-ranked findings with owners and a Pass / Pass with findings / Block decision.

**Out of scope:** remediation implementation and functional testing.

### Code Audit

**Owner:** TBD

**Definition:** An evaluation of code and test quality.

**Goal:** Verify that the code and tests are maintainable and clean.

**Scope:** Complexity, duplication, naming, structure, test coverage and quality, style-guide compliance, and maintainability findings with severity.

**Out of scope:** functional verification, security assessment, and fixes.
