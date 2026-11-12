---
name: task-refinement
description: 'Audit, clarify, and complete a single backlog ticket by removing ambiguity, filling missing structure, and aligning it with specifications. Uses the Papyrus CLI for all ticket reads and modifications.'
argument-hint: 'Provide a task ID and goal (e.g. "TASK-0020: clarify scope and finish acceptance criteria").'
user-invocable: true
disable-model-invocation: false
---

# Task Refinement

## Outcome

A single backlog ticket becomes execution-ready with a clear description, explicit assumptions, tracked dependencies, concrete acceptance criteria, and a well-defined definition of done — all aligned with relevant project documentation.

## Prerequisites

- **papyrus skill (REQUIRED)** — This skill relies on the Papyrus CLI for ALL ticket operations. Load the `papyrus` skill before performing any Papyrus read or write.

## When To Use

- A ticket is vague, ambiguous, or missing key sections (description, AC, assumptions, dependencies, DoD).
- A ticket needs to be checked for alignment with `docs/` specifications before implementation.
- A feature needs an implementation specification and an execution-ready ticket that link the applicable requirements and specifications.
- You need to make a single ticket execution-ready without decomposing it into sub-tasks.

Do not use this skill for:
- Creating new tickets from scratch (use the Papyrus CLI directly).
- Decomposing a ticket into implementation sub-tasks or sprint planning.
- Refining multiple tickets in one pass — focus on one ticket at a time.
- Editing tickets without using the Papyrus CLI (never edit ticket files directly) — you MUST use the `papyrus` skill for all operations.

## Procedure

1. **Read the target ticket** — Use `papyrus task view <TASK-ID> --json`. Read the full `content` and `metadata`. Identify missing or weak sections: scope, assumptions, dependencies, acceptance criteria, and definition of done.

2. **Cross-check relevant requirements and specifications** — Review Papyrus records and linked documentation referenced by the ticket:
   - `papyrus req view` / `papyrus nfreq view` for requirements;
   - `papyrus tech-spec view` for feature/technical specifications;
   - `papyrus ui-spec view` for UI specifications;
   - `papyrus rule view` for business rules;
   - `papyrus decision view` for decisions;
   - `docs/domain-model/` for diagrams and attribute lists.

   Keep the feature specification in Papyrus as a `TECH` record. Link relevant business rules and domain artifacts in their canonical locations.

3. **Check definition of done** — Determine whether the standard DoD applies or if the ticket needs a customized DoD. Papyrus has no dedicated DoD field; put the DoD in the task description as a `## Definition of Done` section or express it as acceptance criteria. If unsure, ask the user.

4. **Interact with the user** — Present findings and ask targeted questions to clarify intent, assumptions, and ambiguous wording. Do not mark the ticket execution-ready until material behavior and verification questions are answered:
   - What exactly needs to be built or done?
   - What are the boundaries (in scope / out of scope)?
   - What dependencies exist?
   - How will completion be verified?

5. **Update the ticket via Papyrus** — Apply all refinements through the Papyrus CLI. Never edit ticket files directly. Ensure the refined ticket has:
   - A clear, unambiguous description: `papyrus task edit <TASK-ID> --description "<scope, assumptions, dependencies, and definition of done>"`.
   - Concrete, testable acceptance criteria: repeat `papyrus task edit <TASK-ID> --ac "<criterion>"`.
   - Tracked dependencies: `papyrus task edit <TASK-ID> --depends-on <TASK-ID>`.
   - Requirement and specification references: `papyrus task edit <TASK-ID> --reference <REQ-ID> --documentation <path>`.
   - Milestone and order: `papyrus task edit <TASK-ID> --milestone <MS-ID> --ordinal <n>`.

   Papyrus has no notes, plan, or final-summary fields. Use `--comment` for working notes and evidence. All implementation-critical scope and behavior must be in the ticket itself; links to requirements and specifications explain context and rationale and are not substitutes for ticket content.

6. **Return a summary** — Provide a summary of changes made, any assumptions that were documented, open questions that remain, and suggested next actions.

## Resume / interruption

If interrupted, re-read the target ticket and linked docs, then continue from the last completed step; do not re-apply already-made edits.

## Example

See `references/` for a before/after refinement demonstration:
- `task-rough.md` — a vague, ambiguously scoped ticket before refinement
- `task-refined.md` — the same ticket after refinement with clear scope, AC, assumptions, and dependencies

The examples are conceptual; the live ticket must be changed through Papyrus.

## Completion Checks

- The target ticket has a clear, unambiguous description with concrete scope.
- Acceptance criteria are specific, testable, and numbered.
- Assumptions are explicitly stated (or noted as "none").
- Dependencies are tracked (or noted as "none").
- A definition of done is present in the description or acceptance criteria.
- All changes were made via the Papyrus CLI — no direct file edits.
- The `papyrus` skill was loaded and used for all Papyrus operations.
- Any requirements invented without traceable documentation sources are flagged as open questions.
- No material ambiguity remains that would force a developer to seek product clarification before beginning implementation.

## Decision Rules

- If a ticket's scope is too broad for a single execution unit, flag it rather than expanding it — recommend splitting but do not perform the split.
- If a ticket references specifications that no longer exist or have changed, flag the inconsistency and ask the user how to proceed.
- If critical information cannot be found in documentation or user input, add it as an open question — never invent untraceable requirements.
- If the standard DoD is insufficient for the ticket type, customize it and explain the custom criteria.
- If the user asks for implementation decomposition, decline and explain this skill only refines the ticket structure.

## Quality Bar

- Descriptions are concise, unambiguous, and self-contained.
- Acceptance criteria are concrete and verifiable (pass/fail), not vague aspirations.
- Assumptions are explicit and noted as assumptions (prefixed with "Assumption:").
- Every claim in the refined ticket is traceable to either project docs, user input, or is marked as an open question.
- No implementation details, code snippets, or technical design decisions appear in the ticket.
- The ticket is in a state where a developer could pick it up and start working without further clarification.

## Output Template

After refining a ticket, provide this summary:

- **Action**: refine
- **Target ticket**: <TASK-ID>
- **Summary of changes**: <concise list of edits made>
- **Assumptions documented**: <list>
- **Open questions**: <list of unresolved items needing stakeholder input>
- **Suggested next actions**: <e.g., "Assign stakeholder to answer open questions before sprint planning">
