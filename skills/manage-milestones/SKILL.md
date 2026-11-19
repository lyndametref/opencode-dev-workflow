---
name: manage-milestones
description: 'Create, read, update, assign to a release, and archive milestones through the management tool.'
argument-hint: 'Examples: create a milestone; assign a milestone to a release; archive a milestone.'
user-invocable: true
disable-model-invocation: false
---

# Milestone Management

## Outcome

Milestones are created, read, updated, assigned to a release, and archived through the management tool, so scope, release assignment, and references stay consistent.

## When to use

- Create or edit a milestone, its title, scope, release assignment, labels, or references.
- Archive or restore a milestone.
- Read milestone state for planning, execution, or verification.

## Commands

- List: `papyrus milestone list`
- View: `papyrus milestone view <MS-ID>`
- Create: `papyrus milestone create "<title>" --description <text|-> --release <REL-ID> --label <label> --reference <ref>`
- Edit: `papyrus milestone edit <MS-ID> --title "<title>" --description <text|-> --release <REL-ID> --label <label> --reference <ref>`
- Archive: `papyrus milestone archive <MS-ID>`

## Rules

- A milestone has no status; completion is derived from its tasks and confirmed by Phase 5 verification.
- Assign a milestone to a release with `papyrus milestone edit <MS-ID> --release <REL-ID>`.
- Milestone acceptance criteria are written in the description, each with an identifier and a testable statement. Multiline descriptions use `--description -` and stdin:
  ```bash
  papyrus milestone edit <MS-ID> --description - <<'EOF'
  AC-1: <testable statement>
  AC-2: <testable statement>
  EOF
  ```
- Never edit managed milestone files directly.

## References

Full syntax and caveats: `skills/managed-records/references/REFERENCE.md`.
