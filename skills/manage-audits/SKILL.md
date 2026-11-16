---
name: manage-audits
description: 'Create, read, update, and deprecate audit records through the management tool.'
argument-hint: 'Examples: create an audit record; read an audit.'
user-invocable: true
disable-model-invocation: false
---

# Audit Record Management

## Outcome

Audit records are created, read, updated, and deprecated through the management tool, so IDs, type, scope, content, references, and labels stay consistent.

## When to use

- Create an audit record for a milestone or release.
- Read an audit record's content, type, or labels.
- Update an audit record's content or labels.
- Deprecate an archived audit.

## Commands

- List: `audit list`
- View: `audit view <AUD-ID>`
- Create: `audit create --title "<title>" --content "<report>" --audit-type <quality|code|security> --reference <MS/REL-ID> --label <label>`
- Edit: `audit edit <AUD-ID> --title "<title>" --content "<report>" --audit-type <type> --label <label> --reference <ref>`
- Deprecate/restore: `audit deprecate <AUD-ID>`, `audit restore <AUD-ID>`

## Rules

- The auditor reports; the orchestrator records the audit.
- Audit status is tracked by labels (`issued`, `approved`) and deprecation (`archived`).
- Only one audit of a type may be `issued` or `approved` within a single assessed scope at a time.
- Never edit managed audit files directly.

## References

Full syntax and caveats: `skills/managed-records/references/REFERENCE.md`.
