---
name: architecture-impact-assessment
description: 'Analyse the architecture impact of a milestone during Phase 4 refinement: decide the technical approach, update the Technical specification, record technical decisions, and record an explicit no-impact outcome when that is the case.'
argument-hint: 'Provide the milestone or refinement task ID.'
user-invocable: true
disable-model-invocation: false
---

# Architecture Impact Assessment

## Outcome

For one milestone, an assessed architecture impact, the technical approach for the milestone as a whole, the affected Technical specification sections, and the technical decisions that fix non-obvious choices. When the change has no architecture impact, that outcome is recorded explicitly with its reason.

## When to use

- The refinement task of a milestone is executed in Phase 4.
- A milestone changes behavior, interfaces, data, validation, error handling, cross-cutting concepts, quality attributes, or the technology stack.

Do not use this skill to edit requirements, write code, design UI, plan milestones or tasks, or approve a release.

## Prerequisites

- The user's ADRs are read and accepted as constraints.
- The Technical specification baseline exists; on the first milestone of a project, establish it.
- The changed `REQ`/`NFR`, business rules, glossary, and domain artifacts are available.

## Technical record

There is no separate Architecture artifact. The technical record is:

- the project-wide Technical specification, organized in sections per building block;
- the Decision records (ADRs) that fix technical choices, including the user's ADRs and the technical decisions recorded in refinement; Papyrus records them with decision type `adr`.

The user's ADRs created between Phases 1 and 2 are binding. A refinement decision may refine them but never supersedes them.

## Procedure

1. **Read the scope** — read the milestone, its acceptance criteria, the changed `REQ`/`NFR`, the Technical specification, business rules, glossary, domain artifacts, and all user ADRs.
2. **Judge the impact** — decide whether the milestone affects building blocks, interfaces, runtime or deployment structure, technology stack, cross-cutting concepts, or quality attributes. Record `no architecture impact` with the reason when it does not.
3. **Decide the technical approach** — describe how the milestone will be implemented as a whole: building blocks touched, contracts, data, validation, error behavior, and cross-cutting concerns.
4. **Update the Technical specification** — load `technical-specification` and create or update the affected `TECH` sections. The specification is the implementation contract.
5. **Record technical decisions** — for each non-obvious trade-off, create an `ADR` through `manage-decisions`, with context, decision, trade-offs and their resolution, and consequences. Status starts `proposed`; set it to `accepted` only with the user's validation when the decision fixes a direction the user did not already set.
6. **Confirm the baseline** — on the first milestone, establish the building blocks the Technical specification is organized by.
7. **Report** — impact, affected building blocks, `TECH` IDs, decision IDs and statuses, open questions, and readiness.

## Rules

- The assessment covers the milestone as a whole; it is not a per-development-task design step.
- Update only the Technical specification and the technical decisions. Never edit requirements, business rules, glossary, domain model, UI, or source code.
- Never create or maintain a separate Architecture artifact.
- Never supersede a user ADR; report the conflict to the orchestrator.
- Do not invent user-facing behavior or business rules to fill product gaps; report the gap.
- Every decision goes through `manage-decisions`; never edit decision files by hand.
- The Technical specification body documents behavior only; traceability is attached as references.
- Use only project-local `./.tmp/` for drafts; remove them before finishing.

## Stop conditions

- A required product decision is missing: stop and report.
- The Technical specification baseline is missing on a first milestone and cannot be established: stop and ask.
- A needed decision contradicts a user ADR: stop; the user decides.
- Requirements are missing or contradictory: report to the orchestrator; do not invent behavior.

## Report format

- **Milestone / refinement task**: IDs and titles.
- **Impact**: affected building blocks, interfaces, stack, quality attributes, or `none` with the reason.
- **Technical approach**: summary for the milestone as a whole.
- **Technical specification**: `TECH`/`SPEC` IDs and status.
- **Decisions**: `ADR` IDs and status (`proposed` / `accepted` / `superseded`).
- **Open questions**: or `none`.
- **Next action**: who does what next.

## Completion checks

- Impact was assessed and recorded, including the explicit `none` case.
- The technical approach covers the milestone as a whole.
- Affected `TECH` sections were created or updated.
- Every technical decision is recorded as an ADR and respects the user's ADRs.
- No separate Architecture artifact, code, UI, or requirement was written.
