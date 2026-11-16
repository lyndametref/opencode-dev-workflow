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

- List: `milestone list`
- View: `milestone view <MS-ID>`
- Create: `milestone create "<title>" --description "<scope>" --release <REL-ID> --label <label> --reference <ref>`
- Edit: `milestone edit <MS-ID> --title "<title>" --description "<scope>" --release <REL-ID> --label <label> --reference <ref>`
- Archive: `milestone archive <MS-ID>`

## Rules

- A milestone has no status; completion is derived from its tasks and confirmed by Phase 5 verification.
- Assign a milestone to a release with `milestone edit <MS-ID> --release <REL-ID>`.
- Milestone acceptance criteria are written in the description, each with an identifier and a testable statement.
- Never edit managed milestone files directly.

## References

Full syntax and caveats: `skills/managed-records/references/REFERENCE.md`.
