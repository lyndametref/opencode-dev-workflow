---
name: manage-audits
description: 'Create, read, update, and deprecate the three Phase 5 release Audit records through the management tool.'
argument-hint: 'Examples: create an audit record; read an audit.'
user-invocable: true
disable-model-invocation: false
---

# Audit Record Management

## Outcome

Audit records are created, read, updated, and deprecated through the management tool, so IDs, type, scope, content, references, and status stay consistent.

## When to use

- Create the three Phase 5 release Audit records (quality, code, security) from the `release-audit` skill.
- Read an audit record's content, type, or status.
- Update an audit record's content or status when the release audit reruns.
- Deprecate a superseded audit.

## Commands

- List: `papyrus audit list`
- View: `papyrus audit view <AUD-ID>`
- Create: `papyrus audit create --title "<title>" --content <report|-> --audit-type <quality|code|security> --reference <REL-ID>` then `papyrus audit status <AUD-ID> issued`
- Edit: `papyrus audit edit <AUD-ID> --title "<title>" --content <report|-> --audit-type <type> --label <label> --reference <ref>`
- Deprecate/restore: `papyrus audit deprecate <AUD-ID>`, `papyrus audit restore <AUD-ID>`

Audit reports are multiline; pass `-` and the report on stdin.

```bash
papyrus audit create --title "Quality audit REL-001" --audit-type quality \
  --reference REL-001 --content - <<'EOF'
## Checks
- Acceptance criteria: pass
## Findings
- low: duplicate validation
EOF
```

## Rules

- `quality-gatekeeper` runs `release-audit` and records one Audit record per type: `quality`, `code`, `security`.
- Each record is created with status `issued`; no approval status is set in the current workflow.
- Only one audit of a type may be `issued` within the release scope at a time.
- A rerun after a fix creates new records and archives the previous ones of the same type.
- Never edit managed audit files directly.

## References

Full syntax and caveats: `skills/managed-records/references/REFERENCE.md`.
