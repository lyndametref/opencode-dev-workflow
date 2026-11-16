---
name: requirements-engineering
description: 'Turn an open request artifact into verified, traceable business and non-functional requirements, settle the impact on rules, glossary, and domain model, and report the result for planning. Implements Phase 2 of the orchestrator workflow.'
argument-hint: 'Provide an open request ID (e.g. REQUEST-001) or an intake summary.'
user-invocable: true
disable-model-invocation: false
---

# Requirements Engineering

## Outcome

A verified requirement change for one request artifact: created or updated `REQ`/`NFR` records, settled impact on business rules, glossary, domain model, and decisions, and a report with the changed IDs, validation status, open questions, and impact flags. The request stays `in-progress`.

## When to use

- The orchestrator starts requirement intake for an open request artifact.
- The user asks to create, change, or validate requirements for a request.

Do not use this skill to plan, prioritize, estimate, create tasks, design solutions or UI, write code, or edit rules, glossary, or domain artifacts directly.

## Prerequisites

- Load `managed-records` and the record skills: `manage-requirements` for `REQ`, `manage-nfrs` for `NFR`.
- Read access to `docs/requests/` for the request artifact.

## Inputs and trigger

- One request artifact with `status: open` and `category: enhancement` or `technical-improvement`.
- A `bug` request bypasses this phase and goes to planning.
- The artifact's items, category, open questions, and requested outcome. Nothing outside it is added.
- An incomplete or missing request artifact is not worked around: return it to Phase 1.

## Actors and boundaries

| Actor | Role |
|---|---|
| `requirements-engineer` | Owner: elicits, writes, validates, verifies, assesses impact, delegates, reports. Sole editor of `REQ` and `NFR`. |
| `business-analyst` | Updates business rules when decision logic or constraints are affected. |
| `terminologist` | Updates the glossary when domain language is new or changed. |
| `domain-modeler` | Updates the domain model when concepts, states, attributes, or processes are affected. |
| `architect` | Consumes requirements as constraints; owns architecture and architecture decisions, not here. |
| `orchestrator` | Starts the phase and receives the result; never edits requirements. |
| User / requester | Owns product decisions and confirms a change of meaning. |

A requirement change requested elsewhere is routed back to `requirements-engineer`. When a served requirement changes, every business rule that references it returns to `draft` until re-verified.

## Procedure

1. **Read the request** — open the request artifact, read its items, category, grouping, and open questions. If the artifact is missing, incomplete, or unconfirmed, stop and return it to Phase 1.
2. **Mark the request** — set `status: in-progress` in the request artifact. Only the status and references change.
3. **Resolve open questions** — ask the requester. A product decision is never inferred; record the answer on the request artifact or in the requirement.
4. **Run baseline checks** before drafting.
5. **Elicit** behavior, actors, triggers, data, error cases, and quality attributes for each item.
6. **Draft or update** `REQ`/`NFR` records through the Papyrus `req`/`nfreq` commands. Create the owning group before its first requirement.
7. **Verify** the draft against the verification checklist below.
8. **Assess impact** and delegate affected artifacts to their owners.
9. **Confirm consistency** between requirements and every delegated artifact. A mismatch returns to drafting.
10. **Trace and report** — add the created/changed `REQ`/`NFR` IDs to the request artifact's `references`, keep it `in-progress`, and report changed IDs, validation status, open questions, and impact flags.

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
| Contradiction | Does an existing requirement, rule, or specification state a conflicting behavior, target, or constraint? | Ask for a product decision. Never silently supersede; record which requirement is replaced. |
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
| Quality target, constraint, integration, or cross-cutting concern | Requirements (`NFR`) | `requirements-engineer` | Flagged for the Phase 4 architecture impact assessment. |
| Trade-off not obvious across stakeholders | Decision (type `business`) | `user` | The user decides; requirements depend on it once accepted. |
| Technological change | Architecture (impact flag only) | `architect` | Record the reason and report the flag; no architecture work here. |
| None | — | — | Recorded explicitly as `none`. |

Delegation:

- Call `business-analyst`, `terminologist`, or `domain-modeler` with `subagent`, passing the requirement IDs, the affected artifact, the scope, and the request reference.
- Require the returned IDs, file paths, verification status, and open questions.
- Delegated artifacts return to this phase for a consistency check before the phase closes.
- A technological change is not delegated to `architect` here. Record the reason and report an architecture impact flag to the orchestrator; Phase 3 schedules the architecture work.
- Business decisions are recorded by you as `BDR` records; the user accepts them.
- NFRs are yours to write; no other agent edits them.
- No agent edits another owner's artifact, except `status` and `references`.

## Business decisions

When a trade-off is not obvious across stakeholders and an in-depth record is required:

1. Ask the user to make the decision; only the user triggers a decision.
2. Record it as a business decision (manage-decisions, type `bdr`).
3. Keep the status `proposed` until the user accepts it. A proposed decision blocks the dependent requirement from `verified`.
4. Reference the decision from the requirement. Do not restate the decision as requirement text.

## Verification checklist

The result is `verified` only when all hold:

- every request item is covered by a requirement, or rejected with a reason recorded on the request artifact;
- traceability runs both ways: request -> `REQ`/`NFR`, and `REQ`/`NFR` -> affected rules, glossary terms, and domain objects;
- requirements are atomic, testable, and free of solution design;
- NFR targets are observable and achievable, with defined verification methods;
- no duplicate or contradiction remains, or the conflict is escalated as a decision;
- each requirement sits in the correct group, and every new group is scoped and has a user story;
- changed meaning was confirmed by the requester;
- terminology is canonical and the glossary is consistent with the requirement wording;
- requirements and delegated artifacts are consistent;
- all records are retrievable and listable through the manage-requirements, manage-nfrs, and managed-records skills.

Otherwise the result is `gaps` (fixable defects) or `blocked` (a missing decision).

## Exit criteria

Phase 2 is complete when:

- requirements are verified, and impacted rules, glossary, domain model, and decisions are settled or explicitly `none`;
- no open product or business decision remains;
- the request artifact references the requirements produced from it and stays `in-progress`; Phase 3 sets it `closed` or `rejected`;
- the orchestrator receives changed and created requirement and group IDs, verification status, open questions, impact flags, and the artifact status.

## Boundaries

This phase never:

- decides scope, priority, order, milestones, or releases;
- designs solutions, architecture, interfaces, or UI;
- writes code or tests;
- creates or edits business rules, glossary entries, or domain artifacts directly;
- invents requirements to close a gap, or resolves a conflict by interpretation;
- changes requirement meaning without requester confirmation;
- plans or schedules architecture analysis or UI design;
- sets the request artifact to `closed` or `rejected`.

## Stop conditions

- Unresolved product decision: stop before drafting.
- Request artifact missing, incomplete, or unconfirmed: return to Phase 1.
- Conflicting requirements that only a product decision can settle: stop.
- Affected rules or terms contradict the intended behavior: return to the owning step; do not patch requirements by implication.
- Meaning change not confirmed: do not apply it.

## Report format

- **Request**: ID, title, category.
- **Changed/created requirements**: `REQ`/`NFR` IDs and groups.
- **Validation status**: `verified` / `gaps` / `blocked`.
- **Open questions/blockers**: product decisions still needed, or `none`.
- **Impact**: rules, glossary, domain model, decisions, architecture flag, or `none`.
- **Corpus visibility**: confirmed through Papyrus (yes/no).
- **Request status**: `in-progress`.

## Completion checks

- The request artifact was read and marked `in-progress`.
- Baseline checks ran and are reported.
- Every changed `REQ`/`NFR` is verified or explicitly `gaps`/`blocked`.
- Every impacted artifact was delegated, verified for consistency, or explicitly `none`.
- Changed IDs are reported to the orchestrator and visible through Papyrus.
- No plan, task, milestone, release, code, or direct rule/glossary/domain edit was made.
