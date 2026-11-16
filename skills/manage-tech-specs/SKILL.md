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

- List: `tech-spec list`
- View: `tech-spec view <TECH-ID>`
- Create: `tech-spec create "<title>" --description "<description>" --reference <REQ-ID>`
- Edit: `tech-spec edit <TECH-ID> --title "<title>" --description "<description>" --reference <REQ-ID>`
- Deprecate: `tech-spec deprecate <TECH-ID>`

## Rules

- Papyrus owns the `TECH` ID and metadata. Never edit managed technical specification files directly.
- Section identifier `SPEC-001`; subsection identifier `SPEC-001.01`.
- The specification references requirements and decisions; it never restates them.
- Status: `draft` → `verified` (conformance approved by architect) → `archived`.

## References

Full syntax and caveats: `skills/managed-records/references/REFERENCE.md`.
