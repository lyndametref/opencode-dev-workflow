---
name: manage-test-cases
description: 'Create, read, update, approve, verify, and archive integration test cases through the Papyrus test-case commands.'
argument-hint: 'Examples: create a test case; set status to approved; mark verified.'
user-invocable: true
disable-model-invocation: false
---

# Test Case Management

## Outcome

Test cases are created, read, updated, approved, verified, and archived through the Papyrus `test-case` commands, so identifiers, coverage, status, and traceability stay consistent.

## When to use

- Create or edit a test case: Gherkin scenario, traceability.
- Set a test case to `approved` after explicit user verification.
- Set a test case to `verified` when its implemented integration test passes.
- Archive a test case.
- Read test cases for implementation or verification.

## Record format

Papyrus owns the `TC` identifier, filename, and metadata. Do not choose an ID or name a file by hand.

| Field        | Content                                                              |
| ------------ | -------------------------------------------------------------------- |
| Title        | Short scenario title.                                                |
| Description  | One Gherkin scenario and its traceability, supplied via `--description <text\|->` or `--editor`. |
| References   | Covered requirement and business rule IDs, supplied with `--reference`. |
| Status       | `draft`, `approved`, `verified`, or `archived`.                      |

Body: one Gherkin scenario and traceability.

```markdown
## Scenario: <title, identical to the test case title>

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

- Keywords are uppercase `GIVEN`, `WHEN`, `THEN`, and `AND`.
- One test case holds exactly one scenario and one `WHEN` block; further variants get their own test case.
- Steps stay at the behavior level: no functions, tables, endpoints, or selectors.

## Commands

- Create: `papyrus test-case create "<title>" --description <gherkin|-> --reference <REQ-ID> [--reference <BR-ID>] [--label <label>]`
- List: `papyrus test-case list`
- View: `papyrus test-case view <TC-ID>`
- Edit: `papyrus test-case edit <TC-ID> [--title <title>] [--description <gherkin|->] [--reference <ref>] [--editor]`
- Status: `papyrus test-case status <TC-ID> <value>`
- Archive: `papyrus test-case archive <TC-ID>`

Gherkin is multiline: pass `-` and the scenario on stdin.

```bash
papyrus test-case create "<title>" --reference REQ-001.001 --description - <<'EOF'
## Scenario: <title>

GIVEN <context>
WHEN <action>
THEN <outcome>

## Traceability
- Requirement: REQ-001.001
EOF
```

## Status values

| Status | Meaning |
|---|---|
| `draft` | Written, awaiting user verification. |
| `approved` | User verified the test case. |
| `verified` | The implemented integration test passes. |
| `archived` | Cleaned up. |

- `approved` only after explicit user verification. Never treat silence or another reviewer's approval as approval.
- `verified` is set when the implemented test passes in Phase 4 milestone verification.

## Rules

- A test case describes an integration test: does the feature still work. Low-level tests live with the code.
- Every test case has a Gherkin scenario with `GIVEN`, `WHEN`, and `THEN`, a covered requirement, and covered rules.
- Papyrus owns the `TC` ID, metadata, filename, and archive state. Never edit managed test case files directly.
- Never edit requirements, business rules, or source code here.
- Use only project-local `./.tmp/` for scratch work and remove it before finishing.

## References

The test design procedure and coverage rules: `test-design` skill.
