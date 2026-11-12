---
name: papyrus
description: 'Manage tasks, milestones, releases, requirements, NFRs, business rules, glossary terms, decisions, specifications, mockups, and audit records with the Papyrus CLI. Use for all backlog and Papyrus-managed document operations.'
argument-hint: 'Optional: create or edit a task, milestone, release, requirement, rule, glossary term, decision, specification, mockup, or audit record.'
user-invocable: true
disable-model-invocation: false
---

# Papyrus Management

## Outcome

All backlog and managed documentation records are created, read, and changed through the Papyrus CLI, so IDs, files, links, statuses, and the browser view stay consistent.

## When To Use

- Create, view, list, search, or update tasks.
- Change task status, milestone assignment, ordinal, dependencies, labels, or acceptance criteria.
- Create or update milestones and releases.
- Create or update business requirements, non-functional requirements, business rules, glossary terms, decision records, UI/technical specifications, UI mockups, or audit records.
- Preview or search the documentation corpus with `papyrus browser` or `papyrus search`.

## Golden Rule

Never edit Papyrus-managed files directly. Use the CLI for every read and write.

| DO | DON'T |
|---|---|
| `papyrus task edit TASK-004 --status Refined` | Edit `backlog/tasks/TASK-004.md` |
| `papyrus req edit REQ-001.001 --description "..."` | Edit a requirement Markdown file |
| `papyrus decision edit ADR-0001-... --status Accepted` | Edit an ADR file |
| `papyrus ui-mockup edit MOCK-001 --status approved` | Edit a mockup HTML file |
| `papyrus audit create ...` | Create an audit record by hand |

Plain (non-Papyrus) documents — architecture narratives, domain-model diagrams, business-process diagrams — remain normal Markdown files owned by their respective agents.

**Mockup exception:** Papyrus owns the `MOCK` ID, filename, and metadata comments in mockup HTML files. The UI designer authors the HTML body (landing and prototypes) but must not hand-edit the Papyrus metadata comments. Change the record's task/spec/status through `papyrus ui-mockup edit`.

## Managed Artifacts and Directories

| Artifact | ID prefix | Directory |
|---|---|---|
| Tasks | `TASK` | `backlog/tasks/` |
| Milestones | `MS` | `backlog/milestones/` |
| Releases | `REL` | `backlog/releases/` |
| Business requirements | `REQ` | `docs/requirements/business/` |
| Non-functional requirements | `NFR` | `docs/requirements/non-functional/` |
| Business rules | `RUL` | `docs/business-rules/` |
| Glossary terms | `GLO` | `docs/glossary/` |
| Decision records | `ADR` / `BDR` | `decisions/` |
| UI specifications | `UI` | `docs/specifications/ui/` |
| UI mockups | `MOCK` | `docs/specifications/ui/mockups/` |
| Technical specifications | `TECH` | `docs/technical/` |
| Audit records | `AUD` | `docs/audit-records/` |

## Task Statuses

Use these exact values:

```text
ToDo → Initiated → Refined → Implemented → Validated → Done
```

- `default_status` is `ToDo`.
- `Done` requires explicit user approval unless no-validation mode was requested.
- Never skip backward to `ToDo`; use `Initiated` or `Refined` when work returns to an earlier phase.

## Command Cheat Sheet

All commands accept the global `--json`, `--dir <path>`, `--config <file>`, and `--no-color` options. Put global options before the subcommand:

```bash
papyrus --json --no-color task list
```

### Tasks

```bash
papyrus task list [--status <status>] [--milestone <id>] [--release <id>] [--label <label>] [--search <text>] [--limit <n>]
papyrus task view <TASK-ID>
papyrus task create "<title>" --description "<text>" --ac "<criterion>" --milestone <MS-ID> --ordinal <n> --depends-on <TASK-ID> --label <label> --reference <ref> --documentation <path> --type <type>
papyrus task edit <TASK-ID> --status <status> --title "<title>" --description "<text>" --ac "<criterion>" --depends-on <TASK-ID> --milestone <MS-ID> --ordinal <n> --label <label> --reference <ref> --documentation <path> --comment "<text>" --comment-author <agent>
papyrus task archive <TASK-ID>
papyrus task restore <TASK-ID>
```

- Papyrus has no priority field. Use `--ordinal` (lower runs first) and dependencies to encode order.
- Papyrus has no `--ready` flag. Read `--json task list --status ToDo` and select the first task whose `metadata.dependencies` are all `Done`.
- `--ac` adds acceptance criteria. There is no checkbox toggle; the quality review records pass/fail per criterion.
- There are no notes or final-summary fields. Record evidence and decisions with `--comment`.

### Milestones and releases

```bash
papyrus milestone list
papyrus milestone create "<title>" --description "<scope>" --release <REL-ID> --label <label> --reference <ref>
papyrus milestone view <MS-ID>
papyrus milestone edit <MS-ID> --title "<title>" --description "<scope>" --release <REL-ID> --label <label> --reference <ref>
papyrus milestone archive <MS-ID>

papyrus release list
papyrus release create "<title>" --description "<scope and acceptance criteria>" --label <label> --reference <ref>
papyrus release view <REL-ID>
papyrus release edit <REL-ID> --title "<title>" --description "<scope>" --label <label> --reference <ref>
```

A release is a first-class `REL` record. Assign milestones to it with `papyrus milestone edit <MS-ID> --release <REL-ID>`. Release scope is derived from the assigned milestones and their tasks. Record release completion by adding the label `released` and a completion note to the release description.

### Requirements, NFRs, rules, and glossary

```bash
papyrus req create-group --title "<group title>" --description "<text>" --story "<user story>"
papyrus req create "<title>" --group <REQ-GROUP-ID> --story "<user story>" --description "<description and acceptance criteria>"
papyrus req list
papyrus req view <REQ-ID>
papyrus req edit <REQ-ID> --title "<title>" --story "<user story>" --description "<text>" --label <label> --reference <ref>
papyrus req deprecate <REQ-ID>
papyrus req restore <REQ-ID>

papyrus nfreq create-group --title "<group title>" --description "<text>"
papyrus nfreq create "<title>" --group <NFR-GROUP-ID> --description "<description and acceptance criteria>"
papyrus nfreq list
papyrus nfreq view <NFR-ID>
papyrus nfreq edit <NFR-ID> --title "<title>" --description "<text>" --label <label> --reference <ref>

papyrus rule create "<title>" --description "<rule>" --rationale "<why>" --applicability "<when and where>" --requirement <REQ-ID>
papyrus rule list
papyrus rule view <RUL-ID>
papyrus rule edit <RUL-ID> --title "<title>" --description "<rule>" --requirement <REQ-ID>
papyrus rule deprecate <RUL-ID>

papyrus glossary create --term "<term>" --definition "<definition>"
papyrus glossary list
papyrus glossary view <GLO-ID>
papyrus glossary edit <GLO-ID> --term "<term>" --definition "<definition>"
papyrus glossary deprecate <GLO-ID>
```

- Create the group before creating a requirement or NFR in it.
- Requirements and NFRs have no dedicated acceptance-criteria flag. Put acceptance criteria in the `--description` text, or use `--editor` for the document body.
- Use `--editor` only when an interactive editor is appropriate; agents should prefer `--description` or `--editor` with a prepared file when supported.

### Decisions, specifications, mockups, and audits

```bash
papyrus decision create "<title>" --decision-type adr --decision "<decision>" --context "<context>" --consequences "<consequences>" --reference <REQ-ID>
papyrus decision list
papyrus decision view <ADR-ID>
papyrus decision edit <ADR-ID> --status Accepted --decision "<decision>" --context "<context>" --consequences "<consequences>" --superseded-by <ADR-ID>
papyrus decision archive <ADR-ID>

papyrus ui-spec create "<title>" --view "<view>" --description "<description>" --reference <REQ-ID>
papyrus ui-spec list
papyrus ui-spec view <UI-ID>
papyrus ui-spec edit <UI-ID> --view "<view>" --description "<description>" --reference <REQ-ID>
papyrus ui-spec deprecate <UI-ID>

papyrus tech-spec create "<title>" --description "<description>" --reference <REQ-ID>
papyrus tech-spec list
papyrus tech-spec view <TECH-ID>
papyrus tech-spec edit <TECH-ID> --title "<title>" --description "<description>" --reference <REQ-ID>
papyrus tech-spec deprecate <TECH-ID>

papyrus ui-mockup create --task <TASK-ID> --spec <UI-ID> "<title>"
papyrus ui-mockup list
papyrus ui-mockup view <MOCK-ID>
papyrus ui-mockup edit <MOCK-ID> --status approved
papyrus ui-mockup edit <MOCK-ID> --status deprecated
papyrus ui-mockup deprecate <MOCK-ID>

papyrus audit create --title "<title>" --content "<report>" --audit-type security --reference <REL-ID> --label <label>
papyrus audit list
papyrus audit view <AUD-ID>
papyrus audit edit <AUD-ID> --title "<title>" --content "<report>" --audit-type security
```

- UI mockups start in `pending`. Required mockups must be `approved` before implementation. `ui-mockup list --json` may omit metadata in 0.1.0; use `papyrus ui-mockup view <MOCK-ID>` to read the status comment.
- Valid mockup statuses used by this workflow: `pending`, `approved`, `deprecated`.
- The security officer is read-only and does not create the audit record; the orchestrator records the security officer's report with `papyrus audit create`.

### Search and browser

```bash
papyrus search "<query>" --type task --type decision
papyrus browser
papyrus browser --no-open --port 6420
```

`papyrus browser` is the documentation index. Do not generate or hand-edit `index.html` files.

### Configuration

```bash
papyrus config list
papyrus config get statuses
papyrus config set <key> <value>
papyrus config unset <key>
```

## Reading Readiness and Release Scope

Papyrus 0.1.0 does not reliably filter tasks by milestone or release in `task list`, and it has no `--ready` flag. Use JSON and filter explicitly:

```bash
# All tasks, then inspect metadata.status, metadata.milestone, metadata.dependencies, metadata.ordinal
papyrus --json task list

# Milestones assigned to a release
papyrus --json milestone list

# Done task IDs (dependency satisfaction)
papyrus --json task list --status Done
```

Selection rule:

1. Build the set of `Done` task IDs.
2. A `ToDo` task is ready when every ID in `metadata.dependencies` is in that set.
3. Order candidates by `metadata.ordinal`, then ID.

Use `jq` when available; otherwise parse the JSON directly.

## Records and Evidence

- Task evidence, review outcomes, and decisions: `papyrus task edit <id> --comment "<text>" --comment-author <agent>`.
- Release audit summary: `papyrus audit create ...` by the orchestrator, referencing the `REL` record.
- Release completion: `papyrus release edit <REL-ID> --label released --description "<scope + completion note>"`.
- Never change task scope, acceptance criteria, or dependencies outside `task-refiner` or `planner`.

## References

See [references/REFERENCE.md](references/REFERENCE.md) for the full command reference, JSON shapes, and caveats.
