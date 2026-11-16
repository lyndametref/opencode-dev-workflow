---
name: technical-specification
description: 'Maintain the project-wide Technical specification as Papyrus TECH sections organized by architecture building blocks, traceable to requirements, rules, and decisions and approved by the architect.'
argument-hint: 'Provide the affected building block, requirements, or milestone/task ID.'
user-invocable: true
disable-model-invocation: false
---

# Technical Specification

## Outcome

An implementation-consumable Technical specification in Papyrus, organized in sections per architecture building block, updated for the changed requirements and decisions, traceable, and approved by the architect for conformance.

## When to use

- After the architecture impact assessment, when a Technical specification section must be created or updated.
- A milestone changes behavior, interfaces, data, validation, error handling, or cross-cutting concepts.
- The architect delegated affected specification sections.

Do not use this skill to write requirements, acceptance criteria, architecture decisions, UI design, or source code.

## Prerequisites

- Load `papyrus`.
- Read access to `docs/architecture/`, `docs/requirements/`, `docs/business-rules/`, `docs/glossary/`, `docs/domain-model/`, and `decisions/`.

## Specification model

- One specification for the whole project, stored as Papyrus `TECH` records under `docs/technical/`.
- Organized in sections per building block of the Architecture. At least one section per building block.
- A feature does not get its own specification: it updates the sections it affects.
- Section identifier `SPEC-001`; subsection identifier `SPEC-001.01`.
- Required content: behavior; flows and states; data and API-facing attributes; validation and error behavior; interface contracts; traceability to `REQ`/`NFR` and architecture decisions.
- The specification references requirements and decisions; it never restates them.
- Status: `draft` -> `verified` (conformance approved by `architect`); `archived` when cleaned up. No versioning.

## Procedure

1. **Read the baseline** — read the architecture building blocks, changed `REQ`/`NFR`, `BR`, glossary terms, domain artifacts, decisions, and existing `TECH` sections.
2. **Map the change to sections** — identify the building blocks and subsections the change affects. Do not create a feature-specific document.
3. **Draft the sections** — create or update `TECH` records (manage-tech-specs). Cover behavior, flows and states, data and API-facing attributes, validation and error behavior, interface contracts, and traceability. Keep status `draft`.
4. **Link, do not restate** — reference `REQ`/`NFR`, `BR`, glossary terms, domain objects, and decision IDs. Never copy requirement text or acceptance criteria.
5. **Request conformance** — report the draft to the caller with the affected building blocks and decision references, and state that architect conformance is required before refinement. Do not mark the section `verified` yourself.
6. **Apply corrections** — after the architect reports `not conformant`, update the section and request conformance again.
7. **Record verification** — set the section to `verified` only after the architect reports `conformant`.
8. **Report** — section IDs, files, changed content, references, status, and open questions.

## Rules

- You are the sole editor of the Technical specification. Do not let other agents edit it; they report required changes to you.
- The `architect` approves conformance; the user does not approve the specification in this phase.
- Do not change the architecture or decisions; report a needed architecture change to the architect.
- Do not edit requirements, business rules, glossary, domain model, UI specifications, mockups, or source code.
- Do not generate or edit `index.html`; use the managed-records skill.
- If behavior is unclear, report the gap instead of inventing it.
- Use only project-local `./.tmp/` for drafts; remove them before finishing.

## Stop conditions

- The architecture baseline or building blocks are missing: stop and ask the architect.
- A required decision is not `accepted`: stop; the specification cannot be verified.
- Requirements are missing or contradictory: report to the orchestrator; do not invent behavior.
- The architecture reports `not conformant`: revise and resubmit; refinement does not start.

## Report format

- **Task/milestone**: ID and title.
- **Sections**: `TECH`/`SPEC` IDs and titles.
- **Content changed**: behavior, flows, data, validation, contracts, traceability.
- **References**: `REQ`/`NFR`, `BR`, `ADR`, glossary, domain.
- **Status**: draft / verified.
- **Conformance**: requested / conformant / not conformant.
- **Open questions**: or `none`.

## Completion checks

- Every affected building block has a section or subsection.
- The section contains the required content and references.
- Requirements and decisions are referenced, not restated.
- Architect conformance is recorded before the section is `verified`.
- No code, UI, requirement, rule, glossary, or domain artifact was written.
