---
name: manage-test-cases
description: 'Create, read, update, approve, verify, and archive integration test cases as plain Markdown files under docs/test-cases/.'
argument-hint: 'Examples: create a test case; set status to approved; mark verified.'
user-invocable: true
disable-model-invocation: false
---

# Test Case Management

## Outcome

Test cases are created, read, updated, approved, verified, and archived as plain Markdown files under `docs/test-cases/`, so identifiers, coverage, status, and traceability stay consistent.

## When to use

- Create or edit a test case: scenario, preconditions, steps, expected outcome, traceability.
- Set a test case to `approved` after explicit user verification.
- Set a test case to `verified` when its implemented integration test passes.
- Archive a test case.
- Read test cases for implementation or verification.

## Record format

- **Directory** — `docs/test-cases/`.
- **File** — `TC-<nnn>-<slug>.md`.
- **Identifier** — `TC-001`, unique and stable. Allocate the next free number by listing `docs/test-cases/`.

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

Body: scenario, preconditions, steps, expected outcome, traceability.

## Status values

| Status | Meaning |
|---|---|
| `draft` | Written, awaiting user verification. |
| `approved` | User verified the test case. |
| `verified` | The implemented integration test passes. |
| `archived` | Cleaned up. |

- `approved` only after explicit user verification. Never treat silence or another reviewer's approval as approval.
- `verified` is set when the implemented test passes in Phase 5.

## Rules

- A test case describes an integration test: does the feature still work. Low-level tests live with the code.
- Every test case has a scenario, expected outcome, covered requirement, and covered rules.
- Never edit requirements, business rules, or source code here.
- Use only project-local `./.tmp/` for scratch work and remove it before finishing.

## References

The test design procedure and coverage rules: `test-design` skill.
