---
name: non-functional-requirements-management
description: 'Create, update, reorganize and check consistency of non-functional requirements under docs/requirements/non-functional/.'
argument-hint: 'Examples: create a new NFR for authentication timeout; validate all NFRs for consistency; reorganize NFR structure; update NFR-01.002'
user-invocable: true
disable-model-invocation: false
---

# Non-Functional Requirements Management

## Outcome

Maintain a consistent, traceable non-functional requirements corpus under `docs/requirements/non-functional/` following strict NFR-XX/NFR-XX.XXX naming and structure.

## When To Use

- Create a new non-functional requirement or NFR group
- Update, reorganize, or rename existing NFRs
- Validate all NFRs for structure, naming, and content compliance
- Reorganize NFR structure

Do not use this skill for implementation logic (no Kotlin, SQL, Java, etc.), technical specs, domain model definitions, or business requirements (use `business-requirements-management` for those).

## Canonical Format

Non-functional requirements live in `docs/requirements/non-functional/` following this structure:

### Group Files (NFR-XX.md)

```markdown
# NFR-XX Group Name

## Description
A few sentences describing the non-functional requirement group.
```

### Atomic NFR Files (NFR-XX.XXX.md)

```markdown
# NFR-XX.XXX Requirement Title

## Description
A few sentences describing the non-functional requirement (e.g., performance target, security constraint, usability criteria).

## Rationale
Why this requirement exists and which quality attribute it addresses (performance, security, usability, maintainability, etc.).

## Verification Method
How compliance with this requirement will be verified (testing, review, measurement, audit, etc.).
```

### Naming Rules

- Group files: `NFR-XX.md` where XX is the group number (01, 02, 03, etc.)
- Atomic files: `NFR-XX.XXX.md` where XXX is the atomic requirement number within the group
- Numbering must be consistent: NFR-01.001, NFR-01.002, NFR-01.003, etc.
- All files stored in: `docs/requirements/non-functional/`

### Index

The index is at `docs/requirements/non-functional/INDEX.md` containing an overview table with columns: `NFR ID | Title | Verification Method`. The index MUST be updated when adding, removing, or changing NFR files. NFR files are the source of truth — the index is derived from them.

## Procedure

1. **Classify request** — Determine whether the request is: `create`, `update`, `validate`, or `reorganize`.

2. **Read baseline** — Read the current structure under `docs/requirements/non-functional/` including the INDEX.md to understand existing NFRs and grouping.

3. **Identify required changes** — Determine what needs to be created, updated, or reorganized based on the request.

4. **For creation/update** — Assign next NFR-XX or NFR-XX.XXX number by finding the highest existing number in the index and incrementing.

5. **For consistency check** — Check if the NFR creates an inconsistency with other NFRs (e.g., conflicting performance targets, overlapping security constraints).

6. **Make corrections** — Edit files as needed. Validate consistency of numbering, naming, and structure after changes.

7. **Update INDEX.md** — Add or update the row in the index table at `docs/requirements/non-functional/INDEX.md` to reflect the change.

8. **Report outcome** — Summarize the action, files changed, and any risks.

## Example

See `references/example-NFR-01-system-performance.md` for a well-formed NFR group example.
See `references/example-NFR-01.001-api-response-time.md` for a well-formed atomic NFR example.

## Completion Checks

- All files follow NFR-XX and NFR-XX.XXX naming pattern
- Group numbering is consistent and sequential
- Atomic numbering aligns with parent groups
- Each atomic file has: title, description, rationale, verification method
- Each group file has: title, description
- Files are in the correct location: `docs/requirements/non-functional/`
- INDEX.md at `docs/requirements/non-functional/INDEX.md` is updated with the new/updated entry
- No implementation code (Kotlin, SQL, Java, etc.) in NFR files

## Decision Rules

- If the user's request is ambiguous, ask clarifying questions before proceeding.
- If an NFR number already exists, propose an update rather than creating a duplicate.
- Numbering gaps exist as the numbering is immutable.
- If a change would break cross-references (e.g., from technical specs), flag the impact before updating.
- If an NFR file exists but is missing from the INDEX.md, add it to the index rather than removing the file.

## Output Template

Use this summary after updates:

- **Action**: create/update/reorganize/check consistency
- **Target**: <list of NFR files>
- **Updated files**: <list>
- **Cross-reference updates**: <list>
- **Validation results**: <pass/fail with details>
- **Residual risks**: <if any>
