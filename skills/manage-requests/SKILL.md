---
name: manage-requests
description: 'Create, read, update, and deprecate request artifacts through the Papyrus request commands.'
argument-hint: 'Examples: create a request; update a request description; set request status.'
user-invocable: true
disable-model-invocation: false
---

# Request Management

## Outcome

Request artifacts are created, read, updated, listed, parked, reactivated, closed, rejected, archived, and deleted through the Papyrus `request` commands, so identifiers, files, statuses, references, and the browser view stay consistent.

## When to use

- Capture, list, park, reactivate, close, reject, archive, or delete a request artifact.
- Read request state for intake, requirements, or planning.

## Record format

- **Directory** — managed by Papyrus under `docs/requests/` (see `papyrus.config.yml`).
- **File** — `RE-<nnn>.md`, owned by Papyrus.
- **Identifier** — `RE-001`, unique and stable. Allocate the next free number with `papyrus request list`. Never reuse or renumber.
- **Status values** — `open`, `parked`, `in-progress`, `closed`, `rejected`, `archived` (and `active` where configured).

Frontmatter and body are Papyrus-owned. Multi-line content is supplied through `--description` or `papyrus request edit <id> --editor`.

## Commands

- List: `papyrus request list`
- View: `papyrus request view <RE-ID>`
- Create: `papyrus request create "<title>" -d "<description>" [--label <label>] [--reference <ref>]`
- Edit: `papyrus request edit <RE-ID> [--title <title>] [-d <description>] [--label <label>] [--reference <ref>] [--editor]`
- Status: `papyrus request status <RE-ID> <value>`
- Archive: `papyrus request archive <RE-ID>`
- Delete: `papyrus request delete <RE-ID> [--force]`

## Rules

- Papyrus owns the `RE` ID, metadata, filename, and archive state. Never edit managed request files directly.
- Use `--editor` only when an interactive editor is appropriate; all writes still go through Papyrus.
- Only `status` and `references` may be updated by the actor that owns the step recording them. All other fields belong to `key-account-manager`.
- Use only project-local `./.tmp/` for scratch work and remove it before finishing.

## References

The request artifact format and intake procedure: `request-intake` skill.
Papyrus syntax and caveats: `managed-records` skill and its `REFERENCE.md`.
