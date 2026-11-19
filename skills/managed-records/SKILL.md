---
name: managed-records
description: 'Manage tasks, milestones, releases, requirements, NFRs, business rules, glossary terms, decisions, specifications, mockups, and audit records with the Papyrus CLI. Use for all backlog and Papyrus-managed document operations.'
argument-hint: 'Optional: create or edit a task, milestone, release, requirement, rule, glossary term, decision, specification, mockup, or audit record.'
user-invocable: true
disable-model-invocation: false
---

# Papyrus Management

## Outcome

All backlog and managed documentation records are created, read, and changed through the Papyrus CLI, so IDs, files, links, statuses, and the browser view stay consistent.

## Golden rule

Never edit Papyrus-managed files directly. Use the CLI for every read and write. Plain (non-Papyrus) records are normal Markdown (requests, test cases, release reports, architecture, domain model).

## Tool commands

All tool commands live in the `manage-*` artifact skills. This skill holds only the tool-agnostic rules.

Full syntax, JSON shapes, and caveats: `skills/managed-records/references/REFERENCE.md`.

Help about papyrus is available with `papyrus --help`

## Multiline input

Papyrus reads multiline field values from stdin. Pass `-` for the option and feed the value with a quoted heredoc; never inline multiline text.

```bash
papyrus audit create --title "Quality audit MS-001" \
  --audit-type quality --reference MS-001 --content - <<'EOF'
## Findings
- low: duplicate validation in the checkout handler
EOF
```

- One stdin-consuming option per command. For more multiline fields, run a separate `edit` with its own heredoc.
- The option must document `Use "-" to read multiline text from standard input`. Fields without it stay single-line (for example `release --description`).
- Quote the heredoc delimiter (`<<'EOF'`) so `$`, backticks, and quotes stay literal.
- `printf '%s\n' "line one" "line two" | papyrus ... --description -` is the fallback when a heredoc is impractical.

## Notes

- For grouped documents: create the group before creating a requirement or NFR in it.
- Put acceptance criteria in the description text; Papyrus has no dedicated acceptance-criteria field.
- Use `--editor` only when an interactive editor is appropriate.
- Use only project-local `./.tmp/` for scratch work and remove it before finishing.
