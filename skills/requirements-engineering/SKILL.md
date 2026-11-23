---
name: requirements-engineering
description: 'Turn an open request artifact into verified, traceable business and non-functional requirements, resolve conflicts with existing requirements together with the user, settle the impact on rules, glossary, and domain model, and report the result for planning. Implements Phase 2 of the orchestrator workflow.'
argument-hint: 'Provide an open request ID (e.g. RE-001) or the /handoff-intake package.'
user-invocable: true
disable-model-invocation: false
---

# Requirements Engineering

## Outcome

A verified requirement change for one request artifact: created or updated `REQ`/`NFR` records, every conflict with an existing requirement resolved with the user, settled impact on business rules, glossary, and domain model, and a report with the changed IDs, validation status, open questions, and impact outcomes. The request stays `in-progress`.

## When to use

- `/handoff-intake` hands an open request artifact to the orchestrator for requirement analysis.
- The user asks to create, change, or validate requirements for a request.

Do not use this skill to plan, prioritize, estimate, create tasks, design solutions, architecture, or UI, perform a technical assessment, write code, or edit rules, glossary, or domain artifacts directly.

## Prerequisites

- Load `managed-records` and the record skills: `manage-requirements` for `REQ`, `manage-nfrs` for `NFR`.
- Read the request artifact via `manage-requests`.
- Read the user's ADRs, if any, via `manage-decisions`.

## Inputs and trigger

- One request artifact with `status: open` and `category: enhancement` or `technical-improvement`.
- A `bug` request bypasses this phase and goes to planning.
- Any Decision record (ADR) the user created between Phases 1 and 2. It fixes a business or technical choice, documents its trade-off, and is a constraint on the requirements.
- The artifact's items, category, open questions, requested outcome, and the user's ADRs. Nothing outside them is added.
- An incomplete or missing request artifact is not worked around: return it to Phase 1.

## Actors and boundaries

| Actor | Role |
|---|---|
| `requirements-engineer` | Owner: elicits, writes, validates, verifies, checks conflicts, assesses impact, delegates, reports. Sole editor of `REQ` and `NFR`. |
| `business-analyst` | Updates business rules when decision logic or constraints are affected. |
| `terminologist` | Updates the glossary when domain language is new or changed. |
| `domain-modeler` | Updates the domain model when concepts, states, attributes, or processes are affected. |
| `orchestrator` | Hands the request over with `/handoff-intake` and receives the result; never edits requirements. |
| User / requester | Owns product decisions, creates ADRs between Phases 1 and 2, and resolves conflicts with existing requirements. |

A requirement change requested elsewhere is routed back to `requirements-engineer`. When a served requirement changes, every business rule that references it returns to `draft` until re-verified.

No architecture work happens in Phase 2. Phase 2 performs no technical assessment and produces no architecture, specification, UI, or test design.

## Procedure

1. **Read the request and ADRs** — open the request artifact and the user's ADRs. Read the items, category, grouping, open questions, and fixed choices. If the artifact is missing, incomplete, or unconfirmed, stop and return it to Phase 1.
2. **Mark the request** — set `status: in-progress` in the request artifact. Only the status and references change.
3. **Resolve open questions** — ask the requester. A product decision is never inferred; record the answer on the request artifact or in the requirement.
4. **Run baseline checks** before drafting, including the conflict check against existing requirements.
5. **Resolve conflicts with the user** — an existing requirement is never silently superseded. The user chooses the resolution and the superseded requirement is recorded.
6. **Elicit** behavior, actors, triggers, data, error cases, and quality attributes for each item.
7. **Draft or update** `REQ`/`NFR` records through `manage-requirements` and `manage-nfrs`. Create the owning group before its first requirement.
8. **Verify** the draft against the verification checklist below.
9. **Assess impact** and delegate affected rules, glossary, and domain artifacts to their owners.
10. **Confirm consistency** between requirements and every delegated artifact. A mismatch returns to drafting.
11. **Trace and report** — add the created/changed `REQ`/`NFR` IDs to the request artifact's `references`, keep it `in-progress`, and report changed IDs, validation status, resolved conflicts, open questions, and impact outcomes.

## Request categories

| Category | Treatment |
|---|---|
| `bug` | Bypasses Phase 2; routed from Phase 1 directly to Phase 3 as a defect. A requirement is created only if the defect exposes unspecified behavior. |
| `enhancement` | New or changed business requirement (`REQ`). |
| `technical-improvement` | `NFR` when a quality attribute changes; otherwise no requirement change, with the reason recorded on the request artifact. |

## Baseline checks

Run before drafting. A failure returns to the requester or the baseline records, never to an assumption.

| Check | Question | If it fails |
|---|---|---|
| Existing conflict | Does an existing requirement state a conflicting behavior, target, or constraint? | Ask the user to resolve the conflict; record which requirement is superseded. |
| Definition gap | Are actor, trigger, behavior, data, error cases, quality attributes, and acceptance criteria stated, or explicitly not applicable? | Ask the requester; record the answer. |
| Overlap | Is the need already covered, fully or partially? | Update the existing requirement instead of creating a duplicate. |
| Group placement | Does an existing requirement group fit the new requirement? | Create a new group with title, scope, and user story before its first requirement. |

## Requirement content

- **Business requirement (atomic):** identifier, title, group, user story, description, acceptance criteria, and references to the request artifact and related requirements. One behavior per requirement; acceptance criteria are testable and unambiguous.
- **Requirement group:** identifier, title, scope description, and user story.
- **Non-functional requirement (atomic):** identifier, group, description with an observable and achievable target, quality attribute or constraint named in the rationale, verification method, and references. A target that cannot be verified is not ready.
- Identifiers are two-level: `REQ-001` / `REQ-001.002` and `NFR-001` / `NFR-001.002`.
- Requirements contain no solution design, architecture choice, technology, task, or estimate.
- Create the group before creating a requirement or NFR in it. Put acceptance criteria in the description text.

## Impact assessment

Assessment is mandatory; "no impact" is an explicit decision, not a silent skip.

| Impact | Artifact | Owner | Gate |
|---|---|---|---|
| New or changed decision logic, formula, or constraint | Business Rules (`BR`) | `business-analyst` | Open business decisions block. |
| New or changed domain term | Business Glossary (`GLO`) | `terminologist` | The term is defined before use in specs, tasks, or UI. |
| New or changed concepts, lifecycle states, attributes, or processes | Domain Model | `domain-modeler` | Conflicts are reported back and resolved with the requester. |
| New or changed behavior | Business Requirements (`REQ`) | `requirements-engineer` | Verified before planning. |
| Quality target, constraint, integration, or cross-cutting concern | Requirements (`NFR`) | `requirements-engineer` | Recorded for Phase 4 refinement, which performs the architecture impact analysis. |
| Trade-off not obvious across stakeholders, in-depth record required | Decision (ADR; Papyrus type `adr` for technical, `bdr` for business) | `user` | Created by the user between Phases 1 and 2; requirements depend on it once accepted. |
| None | — | — | Recorded explicitly as `none`. |

Delegation:

- Call `business-analyst`, `terminologist`, or `domain-modeler` with `subagent`, passing the requirement IDs, the affected artifact, the scope, and the request reference.
- Require the returned IDs, file paths, verification status, and open questions.
- Delegated artifacts return to this phase for a consistency check before the phase closes.
- A technological change is not assessed here: a technical constraint enters through a user ADR, and Phase 4 refinement analyses its architecture impact.
- Do not create or edit decisions. The user owns them.
- NFRs are yours to write; no other agent edits them.
- No agent edits another owner's artifact, except `status` and `references`.

## Verification checklist

The result is `verified` only when all hold:

- every request item is covered by a requirement, or rejected with a reason recorded on the request artifact;
- the new requirements do not contradict an existing requirement, or the user resolved the conflict and the superseded requirement is recorded;
- traceability runs both ways: request -> `REQ`/`NFR`, and `REQ`/`NFR` -> affected rules, glossary terms, and domain objects;
- requirements are atomic, testable, and free of solution design;
- NFR targets are observable and achievable, with defined verification methods;
- no duplicate remains;
- each requirement sits in the correct group, and every new group is scoped and has a user story;
- changed meaning was confirmed by the requester;
- terminology is canonical and the glossary is consistent with the requirement wording;
- requirements and delegated artifacts are consistent;
- all records are retrievable and listable through the manage-requirements, manage-nfrs, and managed-records skills.

Otherwise the result is `gaps` (fixable defects) or `blocked` (a missing decision).

## Exit criteria

Phase 2 is complete when:

- requirements are verified, and impacted rules, glossary, and domain model are settled or explicitly `none`;
- every conflict with an existing requirement is resolved with the user, or the phase is blocked;
- no open product or business decision remains;
- the request artifact references the requirements produced from it and stays `in-progress`; Phase 3 sets it `closed` or `rejected`;
- the orchestrator receives changed and created requirement and group IDs, verification status, resolved conflicts, open questions, impact outcomes, and the artifact status.

## Boundaries

This phase never:

- performs a technical assessment or architecture work;
- decides scope, priority, order, milestones, or releases;
- designs solutions, architecture, interfaces, or UI;
- writes code or tests;
- creates, edits, or supersedes a Decision; ADRs are the user's;
- creates or edits business rules, glossary entries, or domain artifacts directly;
- invents requirements to close a gap, or resolves a conflict by interpretation;
- changes requirement meaning without requester confirmation;
- sets the request artifact to `closed` or `rejected`.

## Stop conditions

- Unresolved product decision: stop before drafting.
- Request artifact missing, incomplete, or unconfirmed: return to Phase 1.
- Conflicting requirements that only a product decision can settle: stop and ask the user.
- Affected rules or terms contradict the intended behavior: return to the owning step; do not patch requirements by implication.
- Meaning change not confirmed: do not apply it.

## Report format

- **Request**: ID, title, category.
- **Changed/created requirements**: `REQ`/`NFR` IDs and groups.
- **Validation status**: `verified` / `gaps` / `blocked`.
- **Conflicts**: existing requirement, resolution, superseded requirement, or `none`.
- **Open questions/blockers**: product decisions still needed, or `none`.
- **Impact**: rules, glossary, domain model, or `none`.
- **User ADRs applied**: IDs, or `none`.
- **Corpus visibility**: confirmed through the `manage-*` skills (yes/no).
- **Request status**: `in-progress`.

## Completion checks

- The request artifact was read and marked `in-progress`.
- Baseline checks ran, including the conflict check, and are reported.
- Every changed `REQ`/`NFR` is verified or explicitly `gaps`/`blocked`.
- Every impacted artifact was delegated, verified for consistency, or explicitly `none`.
- Changed IDs are reported to the orchestrator and visible through the `manage-*` skills.
- No plan, task, milestone, release, architecture, code, or direct rule/glossary/domain edit was made.
