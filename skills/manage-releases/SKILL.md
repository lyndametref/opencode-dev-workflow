---
name: manage-releases
description: 'Create, read, update, assign milestones to, and complete releases through the management tool.'
argument-hint: 'Examples: create a release; assign a milestone; record completion.'
user-invocable: true
disable-model-invocation: false
---

# Release Management (records)

## Outcome

Releases are created, read, updated, assigned milestones, and completed through the management tool, so composition, version, and completion state stay consistent.

## When to use

- Create or edit a release, its title, scope, labels, or references.
- Assign a milestone to a release.
- Record release completion with the `released` label and a completion note.

## Commands

- List: `papyrus release list`
- View: `papyrus release view <REL-ID>`
- Create: `papyrus release create "<title>" --description "<scope and acceptance criteria>" --label <label> --reference <ref>`
- Edit: `papyrus release edit <REL-ID> --title "<title>" --description "<scope>" --label <label> --reference <ref>`

## Rules

- A release is a first-class `REL` record. Assign milestones with `papyrus milestone edit <MS-ID> --release <REL-ID>`.
- An open release may carry a working title such as `Release (pending version)`; Phase 6 renames it to `Release <version>`.
- Record completion by adding the label `released` and a completion note to the description.
- Never edit managed release files directly.

## References

Full syntax and caveats: `skills/managed-records/references/REFERENCE.md`.
