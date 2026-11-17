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

## Notes

- For grouped documents: create the group before creating a requirement or NFR in it.
- Put acceptance criteria in the description text; Papyrus has no dedicated acceptance-criteria field.
- Use `--editor` only when an interactive editor is appropriate.
- Use only project-local `./.tmp/` for scratch work and remove it before finishing.
