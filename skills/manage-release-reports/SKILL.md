---
name: manage-release-reports
description: 'Create, read, update, issue, and archive release reports as plain Markdown files under docs/release-reports/.'
argument-hint: 'Examples: create a release report; set status to issued; archive a report.'
user-invocable: true
disable-model-invocation: false
---

# Release Report Management

## Outcome

Release reports are created, read, updated, issued, and archived as plain Markdown files under `docs/release-reports/`, so version, scope, evidence, and approval state stay consistent.

## When to use

- Create a release report for a release.
- Update a report with build/test results, audit severity counts, accepted risks, findings, or the recommendation.
- Set a report to `issued` when presented for release approval.
- Archive a report.

## Record format

- **Directory** — `docs/release-reports/`.
- **File** — `<REL-ID>-<version>-report.md`.
- **Owner** — `orchestrator`.

Frontmatter:

```yaml
---
id: <REL-ID>-report
title: Release report for <REL-ID>
version: <version>
status: draft          # draft | issued | archived
release: <REL-ID>
milestones: [<MS-ID>, ...]
---
```

Body (per the Release Report artifact): version, release scope, owned milestones, implemented requests, change log, completed tasks with traceability, final test results, per-milestone verification, audit severity counts, accepted risks, findings, follow-ups, fix milestone and its fix tasks, exclusions and open questions, recommendation.

## Status values

| Status | Meaning |
|---|---|
| `draft` | Being assembled. |
| `issued` | Presented for release approval. |
| `archived` | Superseded or cleaned up. |

## Rules

- The report is assembled from verification evidence; it creates no new verification.
- Set `issued` only when the report is presented for release approval.
- Never edit Papyrus-managed files here.
- Use only project-local `./.tmp/` for scratch work and remove it before finishing.

## References

The release procedure and report contents: `release-management` skill.
