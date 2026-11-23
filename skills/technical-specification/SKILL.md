---
name: technical-specification
description: 'Maintain the project-wide Technical specification as managed TECH sections organized by building blocks, traceable to requirements, rules, and decisions. Owned and verified by task-refiner during Phase 4 refinement.'
argument-hint: 'Provide the affected building block, requirements, and decisions.'
user-invocable: true
disable-model-invocation: false
---

# Technical Specification

## Outcome

An implementation-consumable Technical specification, organized in sections per building block, updated for the milestone's requirements and decisions, traceable through references, and `verified` by its owner before the development tasks start.

## When to use

- The refinement task of a milestone creates or updates a Technical specification section.
- A milestone changes behavior, interfaces, data, validation, error handling, or cross-cutting concepts.
- The first milestone of a project establishes the specification baseline.

Do not use this skill to write requirements, acceptance criteria, business rules, UI design, or source code.

## Specification model

- One specification for the whole project, stored and accessed via `manage-tech-specs`.
- Organized in sections per building block. The first refinement establishes the building blocks; later milestones add sections only when a new building block appears.
- A feature does not get its own specification: it updates the sections it affects.
- Section identifier `SPEC-001`; subsection identifier `SPEC-001.01`.
- The specification documents the code: behavior; flows and states; data and API-facing attributes; validation and error behavior; interface contracts. The body carries nothing else.
- Traceability is metadata, not prose: `REQ`/`NFR`, `BR`, `ADR`, glossary, and domain IDs are attached as references, never written into the body.
- The body never lists traceability, requirements text, acceptance criteria, or Task/Milestone/Release IDs. Links are one-way: a task references the `TECH` section; the section never references the task.
- Status: `draft` -> `verified` by the owner when the section is complete and consistent with the decisions; `archived` when cleaned up. No versioning.

## Procedure

1. **Read the baseline** — read the changed `REQ`/`NFR`, `BR`, glossary terms, domain artifacts, the milestone's technical decisions, and existing `TECH` sections.
2. **Map the change to sections** — identify the building blocks and subsections the change affects. Do not create a feature-specific document.
3. **Draft the sections** — create or update `TECH` records (manage-tech-specs). Cover behavior, flows and states, data and API-facing attributes, validation and error behavior, and interface contracts. Keep status `draft`.
4. **Attach references, do not write them** — attach every traced `REQ`/`NFR`, `BR`, `ADR`, glossary, and domain ID as a reference through `manage-tech-specs`. Never copy requirement text, acceptance criteria, traceability lists, or planning IDs into the body.
5. **Self-verify** — check that the section is complete, consistent with the decisions and the requirements, and free of traceability prose; then set it to `verified`.
6. **Report** — section IDs, changed content, references, status, and open questions.

## Rules

- You are the sole editor of the Technical specification. Other agents report required changes to you.
- The owner verifies the specification; no separate approval role exists.
- Do not change decisions; report a needed decision change to the milestone's refinement.
- Do not edit requirements, business rules, glossary, domain model, UI specifications, mockups, or source code.
- Do not generate or edit `index.html`; use the managed-records skill.
- If behavior is unclear, report the gap instead of inventing it.
- The body documents behavior only. Traceability and planning links never appear in it.
- Use only project-local `./.tmp/` for drafts; remove them before finishing.

## Stop conditions

- The building blocks are missing: establish them in the first refinement, or stop and ask.
- Requirements are missing or contradictory: report to the orchestrator; do not invent behavior.
- A decision contradicts a user ADR: stop; the user decides.
- A required decision is still `proposed`: the section cannot be marked complete.

## Report format

- **Sections**: `TECH`/`SPEC` IDs and titles.
- **Content changed**: behavior, flows, data, validation, contracts.
- **References (metadata)**: `REQ`/`NFR`, `BR`, `ADR`, glossary, domain.
- **Status**: draft / verified.
- **Open questions**: or `none`.

## Completion checks

- Every affected building block has a section or subsection.
- The section contains the required behavior content and no traceability, requirement text, acceptance criteria, or planning IDs.
- Every traced `REQ`/`NFR`, `BR`, `ADR`, glossary, and domain ID is attached as a reference.
- The section is `verified` before the dependent development tasks start.
- No code, UI, requirement, rule, glossary, or domain artifact was written.
