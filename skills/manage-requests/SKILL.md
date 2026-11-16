---
name: manage-requests
description: 'Create, read, update, list, park, reactivate, close, and reject request artifacts as plain Markdown files under docs/requests/.'
argument-hint: 'Examples: create a request; list open requests; park or reactivate a request; close or reject a request.'
user-invocable: true
disable-model-invocation: false
---

# Request Management

## Outcome

Request artifacts are created, read, updated, listed, parked, reactivated, closed, and rejected as plain Markdown files under `docs/requests/`, so identifiers, status, references, and history stay consistent.

## When to use

- Capture, list, park, reactivate, close, or reject a request artifact.
- Read request state for intake, requirements, or planning.

## Record format

- **Directory** — `docs/requests/`.
- **File** — `REQUEST-<nnn>-<slug>.md`.
- **Identifier** — `REQUEST-001`, unique and stable. Allocate the next free number by listing `docs/requests/`. Never reuse or renumber.

Frontmatter:

```yaml
---
id: REQUEST-001
title: Short request title
status: open            # open | parked | in-progress | closed | rejected
category: enhancement   # bug | enhancement | technical-improvement
requested_outcome: requirement-intake  # requirement-intake | defect-planning
requester: <name or role>
created: YYYY-MM-DD
references: []          # REQ/NFR/TASK IDs, filled later
---
```

Body: items, grouping, open questions, history.

## Status values

| Status | Meaning |
|---|---|
| `open` | Ready for Phase 2, or for Phase 3 when the category is `bug`. |
| `parked` | The need is approved but held; intake reactivates it when its time has come. |
| `in-progress` | Requirements work, or planning for a `bug`, has started. |
| `closed` | The work is planned. |
| `rejected` | The need will not be fulfilled, with a reason. |

- `closed` and `rejected` are terminal.
- Only `status` and `references` may be updated by the actor that owns the step recording them. All other fields belong to `key-account-manager`.

## Rules

- Create the artifact only after the requester confirms it is faithful.
- Never persist before confirmation.
- One request artifact per request; items of one request are handled together.
- Never merge, clean up, or reclassify a statement to make it easier to specify.
- Use only project-local `./.tmp/` for scratch work and remove it before finishing.

## References

The request artifact format and intake procedure: `request-intake` skill.
