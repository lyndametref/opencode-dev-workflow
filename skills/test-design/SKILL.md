---
name: test-design
description: 'Run the Phase 4 test design task: write integration test cases for changed requirements and business rules, trace them, and obtain the user verification that approves them.'
argument-hint: 'Provide a test design task ID or the changed requirement/business-rule IDs.'
user-invocable: true
disable-model-invocation: false
---

# Test Design

## Outcome

One integration test case per verification scenario for every changed requirement and business rule, written as a Gherkin scenario (`GIVEN` / `WHEN` / `THEN`), stored and accessed via `manage-test-cases`, traced to its requirement and rules, and `approved` after the user verified it. The approved test cases are input to refinement and implementation.

## When to use

- The test design task of a milestone is executed in Phase 4.
- A requirement or business rule is created or edited.

Do not use this skill to write test implementation code, requirements, architecture decisions, or verification evidence.

## Prerequisites

- Load `managed-records` for read-only reads of requirements, rules, and tasks.
- Use `manage-test-cases` for every test case read and write (list/view/create/edit/status).

## Test case artifact

Create and update each test case via `manage-test-cases`.

- **File** — naming and path are owned by `manage-test-cases`.
- **Identifier** — auto-assigned by `manage-test-cases`, unique and stable.
- **Owner** — `test-manager` is the sole editor. The user verifies the test case; a positive verification approves it.
- **Title** — short scenario title.
- **Description** — one Gherkin scenario and traceability.
- **References** — covered requirement and business rule IDs.

Body:

```markdown
## Scenario: <title, identical to the frontmatter title>

GIVEN <initial context, state, and data>
  AND <further context>
WHEN <the action or event that triggers the behavior>
  AND <further action>
THEN <observable, testable outcome>
  AND <further outcome>

## Traceability
- Requirement: REQ-001.001
- Business rules: BR-001
```

How to write a Gherkin scenario:

- One test case holds exactly one `Scenario` and one `WHEN` block; extra trigger steps use `AND` inside that block.
- `GIVEN` carries every precondition: roles, state, and data. `WHEN` carries the steps that trigger the behavior. `THEN` carries the observable outcome.
- Every step starts with a keyword followed by a third-person, present-tense statement of behavior; keep one behavior per step and no blank steps.
- Keywords are uppercase `GIVEN`, `WHEN`, `THEN`, and `AND`.
- Steps stay at the behavior level: no internal functions, tables, endpoints, selectors, or other implementation detail.
- Do not add `Feature`, `Background`, `Scenario Outline`, or `Examples`; variants and boundary outcomes get their own test case.
- Write scenarios that can fail: name a concrete outcome, not "it works".

Example:

```markdown
## Scenario: Reject a transfer above the account limit

GIVEN an account with a balance of 100 EUR
  AND a transfer limit of 50 EUR per transaction
WHEN the customer requests a transfer of 75 EUR
THEN the transfer is rejected
  AND the account balance remains 100 EUR
  AND the rejection states that the transfer limit was exceeded

## Traceability
- Requirement: REQ-001.001
- Business rules: BR-001
```

## Procedure

1. **Read the change set** — read the changed `REQ`/`NFR` and `BR` records, the milestone acceptance criteria, and the affected tasks.
2. **Enumerate scenarios** — one test case per verification scenario. A test case covers one requirement and the business rules attached to it. Cover the changed behavior and its relevant error and boundary outcomes.
3. **Write the test cases** — create or update test cases via `manage-test-cases`. Formulate each one as a Gherkin scenario: `GIVEN` the preconditions, `WHEN` the trigger, `THEN` the observable outcome. Keep the scenario and outcome unambiguous. Do not write test code.
4. **Trace** — every test case names its covered requirement and business rules. Every changed requirement or rule must be covered by at least one test case.
5. **Present for verification** — show the test cases, their `GIVEN` / `WHEN` / `THEN` scenario, and traceability to the caller for user review. Keep `status: draft` until explicit approval.
6. **Record approval** — after the caller reports explicit user approval, set `status: approved` in the test case file. On requested changes, revise and present again.
7. **Report** — test case IDs, files, covered requirements/rules, coverage gaps, and approval status.

## Rules

- A test case describes an integration test: does the feature still work. Low-level tests live with the code and are not described here.
- Every test case is written as one Gherkin scenario with `GIVEN`, `WHEN`, and `THEN`; a test case in another format is not ready for verification.
- Every changed requirement and business rule needs at least one test case. A changed item without a test case is a coverage gap and blocks refinement.
- Do not invent requirements or rules to fill a gap; report the gap.
- Do not edit requirements, business rules, the Technical specification, or source code.
- Do not write test implementation code. Implementation tasks implement the approved test cases as integration tests.
- When the implemented test passes in Phase 5, its status becomes `verified`; the actor recording the result may update only the status.

## Stop conditions

- A changed requirement or rule has no testable expected outcome: stop and report; the requirement or rule owner fixes it.
- A behavior cannot be expressed as a single `GIVEN` / `WHEN` / `THEN` scenario: stop and report; split it into separate test cases instead of merging scenarios.
- The requirement or rule is unclear: ask; do not guess.
- The user denies a test case: record the requested changes, revise, and present again. Refinement and implementation of the affected behavior do not start.

## Report format

- **Task/milestone**: ID and title.
- **Test cases**: `TC` IDs, titles, files.
- **Coverage**: changed `REQ`/`NFR` and `BR` IDs -> covered / missing.
- **User verification**: pending / approved / changes requested.
- **Open questions**: or `none`.

## Completion checks

- Every changed requirement and business rule has at least one test case.
- Every test case is a Gherkin scenario with `GIVEN`, `WHEN`, `THEN`, a covered requirement, and covered rules.
- Each test case holds exactly one scenario and one `WHEN` block, and every step is observable behavior.
- No test implementation code was written.
- The test cases were presented to the user and are `approved` only after explicit approval.
