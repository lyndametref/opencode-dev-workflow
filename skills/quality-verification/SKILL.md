---
name: quality-verification
description: 'Verify a completed backlog ticket against its acceptance criteria, definition of done, and implementation plan. Detects scope creep, gathers evidence from the repository, and produces a completion report with a close/incomplete decision. Use when validating that an implemented ticket is ready to close.'
argument-hint: 'Provide a ticket name or path (e.g. "task-0029" or "backlog/tasks/task-0020").'
user-invocable: true
disable-model-invocation: false
---

# Quality Verification

## Outcome

One backlog ticket receives an explicit verification decision: `Ready to close` or `Incomplete`, backed by a per-criterion completion table with evidence, a scope-creep check, and — after user confirmation — closure via the backlog CLI.

## When To Use

- A ticket claims to be implemented and must be validated before closing.
- The user asks to verify, gate, or review a specific ticket's completion state.
- Scope creep must be checked against the ticket's implementation plan and acceptance criteria.

Do not use this skill for:

- Verifying multiple tickets in one pass — focus on one ticket at a time.
- Producing implementation, code, or configuration changes.
- Editing files other than the ticket itself (and only via the backlog CLI).

## Prerequisites

- **backlog-md skill (REQUIRED)** — Load the `backlog-md` skill before any backlog read or write operation. All ticket status and AC updates go through the backlog CLI.

## Inputs

- Ticket name or path provided by the user.
- Repository files where the ticket's changes should have been made.

## Constraints

- DO NOT invent requirements or acceptance criteria not traceable to the target ticket.
- DO NOT produce any implementation, code, or configuration.
- DO NOT modify any file outside the ticket explicitly provided by the user.
- DO NOT edit ticket files directly — use the backlog CLI only.
- **Scope creep detection**: Flag any feature, component, or code change that goes beyond what is documented in the ticket's implementation plan, acceptance criteria, and Definition of Done.

## Procedure

1. **Read the target ticket** — Use the backlog CLI to read the full ticket. Extract scope, acceptance criteria, dependencies, definition of done, and the implementation plan.
2. **Gather evidence** — Search the repository for the files, features, and configuration the ticket's changes should have produced.
3. **Scope creep check** — Cross-reference the implementation plan against the actual changes. Verify that every file, feature, component, and configuration change is traceable to a documented AC, DoD item, or implementation-plan entry. Flag any additions not justified by the plan.
4. **Validate each acceptance criterion** — Mark each AC pass/fail/inconclusive with evidence references. If a criterion cannot be assessed unambiguously, ask the user.
5. **Validate definition of done** — Mark each DoD item pass/fail/inconclusive with evidence references. If a point cannot be assessed unambiguously, ask the user.
6. **Report** — Produce the Decision and Completion summary table (see Output Format).
7. **Ask for confirmation** — Ask the user whether the ticket can be closed. Do not close it unilaterally.
8. **Close the ticket** — After user confirmation, verify all ACs are checked and mark the ticket done via the backlog CLI.

## Output Format

- **Decision**: `Ready to close` or `Incomplete`.
- **Completion summary table**: one row per acceptance criterion with columns:
  - acceptance criteria id and title
  - completion: ok or not ok (with color)
  - Evidences/Findings: completion evidence / what is missing
- **Scope creep findings**: any unjustified changes (or "none").
- **Open questions**: ambiguous criteria or missing evidence awaiting user input.

## Examples

Review the examples in `agents/quality-gatekeeper/examples/` to understand the expected review format:

- `task-incomplete.md` — a review where some ACs and DoD items fail (decision: Incomplete)
- `task-ready.md` — a review where all criteria pass (decision: Ready to close)
