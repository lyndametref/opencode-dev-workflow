---
name: implementation
description: 'Execute one refined implementation task in Phase 4: verify prerequisites, implement the complete task with tests, run the checks, commit on the task branch, and report fulfilment evidence.'
argument-hint: 'Provide the refined implementation task ID.'
user-invocable: true
disable-model-invocation: false
---

# Implementation

## Outcome

A refined implementation task is delivered: code and low-level tests, integration tests implementing the approved test cases, a green build, and a structured evidence block. The task is ready for the orchestrator's acceptance check.

## When to use

- The implementation task of a milestone is assigned to a `*-dev` agent in Phase 4.

Do not use this skill to refine scope, change requirements, plan tasks, review the milestone, or audit the release.

## Prerequisites

Before starting, confirm all hold:

- the task exists and is refined, with a complete description and acceptance criteria;
- the architecture impact assessment is settled and the architecture is user-verified;
- the relevant Technical specification section is conformant and `verified`;
- every `MOCK` referenced by the task is `approved`;
- the test cases for the changed requirements and rules are `approved` and linked to the task;
- the task's dependencies are `Done`.

If any prerequisite is missing, stop and report; do not invent it.

## Procedure

1. **Read the task and context** — read the refined task, its acceptance criteria, the linked `REQ`/`NFR`, `BR`, Technical specification, UI specification, mockups, test cases, and decisions.
2. **Map acceptance criteria** — list every acceptance criterion and the implementation and verification that will satisfy it.
3. **Work on the prepared branch** — the orchestrator has prepared `task/<TASK-ID>`. If you are not on it, stop and report; do not create, switch, or clean branches. Preserve existing changes; never discard work.
4. **Load the stack skills** — `tdd` first, then the language/framework skills relevant to the stack.
5. **Write failing tests** — write or update low-level tests and the integration tests that implement the approved test cases. Tests come before implementation.
6. **Implement the complete scope** — implement the smallest change that fulfils every acceptance criterion and test case. Do not stop at a partial scope.
7. **Refactor** — improve clarity and maintainability without changing the required behavior or breaking boundaries.
8. **Run the checks** — build, full test suite, lint/static checks, and the stack's security checks. Reconcile the results against every acceptance criterion.
9. **Commit** — commit the changes on the task branch. Do not push, stash, reset, clean, or discard.
10. **Report evidence** — return the evidence block below. Do not change the task status; the orchestrator owns status and acceptance.

## Evidence block

- **Task**: ID and title.
- **Acceptance criteria covered**: each criterion and how it is met.
- **Test cases implemented**: `TC` IDs and the integration tests that implement them.
- **Files changed**: created and modified paths.
- **Tests run**: command, pass/fail, counts, and test files/classes added or updated.
- **Static checks**: lint/compile result.
- **Security checks**: input validation, authorization, data exposure, and other relevant mitigations.
- **NFR coverage**: referenced NFRs and how they are addressed, or `none`.
- **Architecture/spec conformance**: any deviation and its resolution.
- **Branch and commit**.
- **Gaps/open items**: anything not completed or needing follow-up.

## Rules

- Implement the complete task scope; the task and its acceptance criteria are the contract.
- Do not change the task, its scope, acceptance criteria, dependencies, or ordinal.
- Do not edit requirements, rules, glossary, domain model, architecture, Technical specification, UI specifications, or mockups.
- Stay inside the application paths allowed for the stack.
- Keep the build green and all tests passing.
- Be security-aware: validate inputs, avoid injection, enforce authorization, and never expose sensitive data in responses, logs, errors, or client storage.
- Do not create scratch files outside `./.tmp/`; remove them before finishing.

## Stop conditions

- A prerequisite is missing or an artifact is not approved/verified: stop and report.
- An acceptance criterion is ambiguous or cannot be met with the available information: stop and report; do not guess.
- A required architecture, specification, or requirement change is discovered: stop; it returns to Phase 2/3, never absorbed silently.
- Tests fail and the fix requires scope outside the task: stop and report.
- A security issue requires a design change: stop and report to the architect.

## Completion checks

- Every acceptance criterion is mapped to implementation and verification.
- Every approved test case has an implemented integration test.
- The full test suite and static checks pass.
- The commit is on the task branch and no forbidden git operation was used.
- The evidence block is complete and returned to the orchestrator.
- No artifact outside the allowed application paths was modified.
