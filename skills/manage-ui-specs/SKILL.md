---
name: manage-ui-specs
description: 'Create, read, update, and deprecate UI specification entries through the management tool.'
argument-hint: 'Examples: create a UI specification; update a view description.'
user-invocable: true
disable-model-invocation: false
---

# UI Specification Management

## Outcome

UI specification entries are created, read, updated, and deprecated through the management tool, so identifiers, views, status, and references stay consistent.

## When to use

- Create or edit a UI specification entry: title, view, description, reference.
- Deprecate a UI specification.
- Read UI specifications for design or implementation.

## Commands

- List: `papyrus ui-spec list`
- View: `papyrus ui-spec view <UI-ID>`
- Create: `papyrus ui-spec create "<title>" --view "<view>" --description "<description>" --reference <REQ-ID>`
- Edit: `papyrus ui-spec edit <UI-ID> --view "<view>" --description "<description>" --reference <REQ-ID>`
- Deprecate: `papyrus ui-spec deprecate <UI-ID>`

## Rules

- Papyrus owns the `UI` ID and metadata. Never edit managed UI specification files directly.
- The body describes layout regions, navigation, UI states, interaction behavior, presentation of validation and messages, and platform differences.
- The specification never contains technology or library choices.

## References

Full syntax and caveats: `skills/managed-records/references/REFERENCE.md`.
