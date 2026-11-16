---
name: test-design
description: 'Run the Phase 4 test design task: write integration test cases for changed requirements and business rules, trace them, and obtain the user verification that approves them.'
argument-hint: 'Provide a test design task ID or the changed requirement/business-rule IDs.'
user-invocable: true
disable-model-invocation: false
---

# Test Design

## Outcome

One integration test case per verification scenario for every changed requirement and business rule, stored as plain Markdown under `docs/test-cases/`, traced to its requirement and rules, and `approved` after the user verified it. The approved test cases are input to refinement and implementation.

## When to use

- The test design task of a milestone is executed in Phase 4.
- A requirement or business rule is created or edited.

Do not use this skill to write test implementation code, requirements, architecture decisions, or verification evidence.

## Prerequisites

- Load `managed-records` for read-only reads of requirements, rules, and tasks.
- Use `manage-test-cases` for test case file operations.
- Read access to `docs/test-cases/`.

## Test case artifact

Store each test case as a plain Markdown file under `docs/test-cases/`.

- **File** — `docs/test-cases/TC-<nnn>-<slug>.md`.
- **Identifier** — `TC-001`, unique and stable. Allocate the next free number by listing `docs/test-cases/`.
- **Owner** — `test-manager` is the sole editor. The user verifies the test case; a positive verification approves it.

Frontmatter:

```yaml
---
id: TC-001
title: Short scenario title
status: draft          # draft | approved | verified | archived
covered_requirement: REQ-001.001
covered_rules: [RUL-001]
---
```

Body:

```markdown
## Scenario
<the integration scenario to exercise>

## Preconditions
<state, data, roles>

## Steps
1. ...

## Expected outcome
<observable, testable result>

## Traceability
- Requirement: REQ-001.001
- Business rules: RUL-001
```

## Procedure

1. **Read the change set** — read the changed `REQ`/`NFR` and `RUL` records, the milestone acceptance criteria, and the affected tasks.
2. **Enumerate scenarios** — one test case per verification scenario. A test case covers one requirement and the business rules attached to it. Cover the changed behavior and its relevant error and boundary outcomes.
3. **Write the test cases** — create or update files under `docs/test-cases/`. Keep the scenario and expected outcome observable and unambiguous. Do not write test code.
4. **Trace** — every test case names its covered requirement and business rules. Every changed requirement or rule must be covered by at least one test case.
5. **Present for verification** — show the test cases, their scenario, expected outcome, and traceability to the caller for user review. Keep `status: draft` until explicit approval.
6. **Record approval** — after the caller reports explicit user approval, set `status: approved` in the test case file. On requested changes, revise and present again.
7. **Report** — test case IDs, files, covered requirements/rules, coverage gaps, and approval status.

## Rules

- A test case describes an integration test: does the feature still work. Low-level tests live with the code and are not described here.
- Every changed requirement and business rule needs at least one test case. A changed item without a test case is a coverage gap and blocks refinement.
- Do not invent requirements or rules to fill a gap; report the gap.
- Do not edit `docs/requirements/`, `docs/business-rules/`, the Technical specification, or source code.
- Do not write test implementation code. Implementation tasks implement the approved test cases as integration tests.
- When the implemented test passes in Phase 5, its status becomes `verified`; the actor recording the result may update only the status.

## Stop conditions

- A changed requirement or rule has no testable expected outcome: stop and report; the requirement or rule owner fixes it.
- The requirement or rule is unclear: ask; do not guess.
- The user denies a test case: record the requested changes, revise, and present again. Refinement and implementation of the affected behavior do not start.

## Report format

- **Task/milestone**: ID and title.
- **Test cases**: `TC` IDs, titles, files.
- **Coverage**: changed `REQ`/`NFR` and `RUL` IDs -> covered / missing.
- **User verification**: pending / approved / changes requested.
- **Open questions**: or `none`.

## Completion checks

- Every changed requirement and business rule has at least one test case.
- Every test case has a scenario, expected outcome, covered requirement, and covered rules.
- No test implementation code was written.
- The test cases were presented to the user and are `approved` only after explicit approval.
