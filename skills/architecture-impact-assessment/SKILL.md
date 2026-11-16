---
name: architecture-impact-assessment
description: 'Run the Phase 4 architecture impact assessment, maintain the Architecture artifact, record architecture decisions, delegate Technical specification sections, and verify specification conformance.'
argument-hint: 'Provide a milestone or architecture task ID. Use the conformance mode to verify a technical specification section before refinement.'
user-invocable: true
disable-model-invocation: false
---

# Architecture Impact Assessment

## Outcome

For one milestone, an assessed architectural impact, an updated Architecture artifact, accepted architecture decisions, delegated Technical specification sections, and a user-verified architecture. In conformance mode, a pass/fail verdict on a Technical specification section's conformance with the architecture and decisions.

## When to use

- The architecture impact assessment task of a milestone is executed in Phase 4.
- The first architecture assessment of a project establishes the architecture baseline.
- The orchestrator asks for Technical specification conformance before refinement.
- A technical improvement or `bug` milestone may affect architecture and the planner included the task.

Do not use this skill to edit requirements, write code, design UI, plan milestones or tasks, or approve a release.

## Prerequisites

- Load `papyrus` and `architecture-decision-record`.
- Read access to `docs/architecture/`, `docs/technical/`, `docs/requirements/`, `docs/business-rules/`, `docs/glossary/`, `docs/domain-model/`, and `decisions/`.
- Available subagent: `tech-writer` for Technical specification sections.

## Architecture artifact

- The Architecture is a plain Markdown set of files under `docs/architecture/`.
- It contains context, building block, runtime, and deployment views; the global solution design; the technology stack; external interfaces and contracts; and cross-cutting concepts.
- Each file carries its own `status: draft | verified` marker. Update it to `verified` only after the user verified the architecture.
- The Architecture never contains requirements, detailed design, source code, acceptance criteria, or building-block specifications (those are the Technical specification).
- Building blocks are the sections of the Technical specification.

## Procedure — impact assessment

1. **Read the task and scope** — read the assigned task, the milestone acceptance criteria, and the changed `REQ`/`NFR` IDs.
2. **Read the baseline** — architecture files, Technical specification, business rules, glossary, domain model, current decisions, and the current stack.
3. **Judge impact** — decide whether the change affects context boundaries, building blocks, runtime or deployment views, technology stack, external interfaces, cross-cutting concepts, or quality attributes. Record the impact as `none` when it does not.
4. **Update the Architecture** — edit only `docs/architecture/`. Keep files marked `draft` until user verification.
5. **Record decisions** — for each non-obvious trade-off, create or update a Decision with `architecture-decision-record`. Status starts `proposed`. Ask the user for explicit validation before setting `accepted`; never auto-accept.
6. **Delegate specification sections** — call `tech-writer` with the affected building blocks, the architecture constraints, the decision IDs, and the requirement references. Require the returned `TECH` section IDs and a draft status. Do not edit the Technical specification yourself.
7. **Present for verification** — present the architecture and the decisions to the user. The gate before dependent design and implementation is the user's verification of the architecture and acceptance of the decisions.
8. **Record the result** — set architecture files to `verified` only after the user verified them. Report the changed files, decision IDs and statuses, affected building blocks, delegated `TECH` sections, and open questions.

## Procedure — specification conformance

Run after `tech-writer` drafted a section and before refinement.

1. Read the Technical specification section, the Architecture, and every referenced decision.
2. Check:
   - the section belongs to a building block of the Architecture;
   - it respects the architecture constraints and accepted decisions;
   - it references `REQ`/`NFR` and decisions instead of restating requirements;
   - it contains behavior, flows and states, data and API-facing attributes, validation and error behavior, interface contracts, and traceability.
3. Report `conformant` or `not conformant` with specific findings and the required corrections. Do not edit the Technical specification yourself.
4. A `not conformant` verdict returns the section to `tech-writer`; refinement does not start.

## Rules

- The architecture impact assessment comes first in every feature and technical-improvement milestone.
- Update only the artifacts you own: Architecture, and Decisions with type `architecture`.
- `tech-writer` owns the Technical specification; delegate its sections and wait for the result.
- The user verifies the architecture and accepts architecture decisions. A positively completed verification approves the artifact.
- When the change is technical but not architectural, record `no architecture impact` with the reason.
- Do not invent user-facing behavior or business rules to fill product gaps; return those to `requirements-engineer` through the orchestrator.
- Do not modify `REQ`/`NFR`, business rules, glossary, domain model, UI, or source code.
- Do not move or rename decision files by hand; use Papyrus. Never create an ADR index.

## Stop conditions

- A required product decision is missing: stop and report.
- The Architecture baseline is missing on a first assessment and cannot be established from requirements and decisions: stop and ask.
- A decision is required but the user has not accepted it: dependent design and implementation do not start.
- A Technical specification section is not conformant: return it to `tech-writer`; do not start refinement.
- A requirement gap is discovered: report it to the orchestrator; do not patch requirements.

## Report format

- **Task/milestone**: ID and title.
- **Impact**: affected views, building blocks, interfaces, stack, cross-cutting concerns, or `none`.
- **Architecture changes**: files and status.
- **Decisions**: `ADR` IDs and status (`proposed` / `accepted` / `superseded`).
- **Delegated specification sections**: `TECH` IDs and draft status.
- **User verification**: pending / verified / changes requested.
- **Conformance** (conformance mode): conformant / not conformant with findings.
- **Open questions**: or `none`.
- **Next action**: who does what next.

## Completion checks

- Impact was assessed and recorded, including the explicit `none` case.
- Architecture files changed only under `docs/architecture/`.
- Every architecture decision was recorded through Papyrus and user acceptance was obtained where required.
- Affected Technical specification sections were delegated to `tech-writer`.
- Architecture and decisions were presented for user verification before dependent work.
- In conformance mode, the verdict is evidence-based and the Technical specification was not edited.
