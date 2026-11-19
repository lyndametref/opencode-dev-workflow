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

- List: `papyrus audit list`
- View: `papyrus audit view <AUD-ID>`
- Create: `papyrus audit create --title "<title>" --content <report|-> --audit-type <quality|code|security> --reference <MS/REL-ID>` then `papyrus audit status <AUD-ID> issued` (approval is tracked by status, not labels)
- Edit: `papyrus audit edit <AUD-ID> --title "<title>" --content <report|-> --audit-type <type> --label <label> --reference <ref>`
- Deprecate/restore: `papyrus audit deprecate <AUD-ID>`, `papyrus audit restore <AUD-ID>`

Audit reports are multiline; pass `-` and the report on stdin.

```bash
papyrus audit create --title "Quality audit MS-001" --audit-type quality \
  --reference MS-001 --content - <<'EOF'
## Checks
- Acceptance criteria: pass
## Findings
- low: duplicate validation
EOF
```

## Rules

- The auditor reports; the orchestrator records the audit.
- Audit approval is documented by the `status` field (`issued`/`approved`), not by labels. Use `papyrus audit status <AUD-ID> issued|approved`; labels are not used for approval.
- Only one audit of a type may be `issued` or `approved` within a single assessed scope at a time.
- Never edit managed audit files directly.

## References

Full syntax and caveats: `skills/managed-records/references/REFERENCE.md`.
