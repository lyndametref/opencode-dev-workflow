---
name: manage-tech-specs
description: 'Create, read, update, and deprecate technical specification sections through the management tool.'
argument-hint: 'Examples: create a technical specification; update a section; deprecate a section.'
user-invocable: true
disable-model-invocation: false
---

# Technical Specification Management

## Outcome

Technical specification sections are created, read, updated, and deprecated through the management tool, so section IDs, content, references, and status stay consistent.

## When to use

- Create or edit a technical specification section: title, description, reference.
- Deprecate a technical specification.
- Read technical specifications for design, implementation, or verification.

## Commands

- List: `papyrus tech-spec list`
- View: `papyrus tech-spec view <TECH-ID>`
- Create: `papyrus tech-spec create "<title>" --description <text|-> --reference <REQ-ID>`
- Edit: `papyrus tech-spec edit <TECH-ID> --title "<title>" --description <text|-> --reference <REQ-ID>`

Multiline content uses `--description -`; traceability uses `--reference`:
```bash
papyrus tech-spec create "<title>" --reference REQ-001 --reference ADR-001 --description - <<'EOF'
## Behavior
...
EOF
```
- Deprecate: `papyrus tech-spec deprecate <TECH-ID>`

## Rules

- Papyrus owns the `TECH` ID and metadata. Never edit managed technical specification files directly.
- Section identifier `SPEC-001`; subsection identifier `SPEC-001.01`.
- Content is code documentation only: behavior, flows and states, data and API-facing attributes, validation and error behavior, interface contracts.
- Traceability is metadata: attach `REQ`/`NFR`, `BR`, `ADR`, glossary, and domain IDs with `--reference`. Never write them, requirement text, acceptance criteria, or Task/Milestone/Release IDs into the description.
- `--reference` accepts only `REQ`/`NFR`, `BR`, `ADR`, glossary, and domain IDs. Never reference a `TASK`, `MS`, or `REL`.
- Status: `draft` → `verified` (self-verified by `task-refiner` when complete and consistent with the decisions) → `archived`.

## References

Full syntax and caveats: `skills/managed-records/references/REFERENCE.md`.
