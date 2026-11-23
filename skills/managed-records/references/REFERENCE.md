# Papyrus CLI Reference

Full command reference for Papyrus 0.1.0. Put global options before the subcommand:

```bash
papyrus [--json] [--dir <path>] [--config <file>] [--no-color] <command>
```

- `--json` emits stable, machine-readable JSON.
- `--no-color` disables ANSI output; default output is plain text.
- Papyrus has no `--plain` flag. Do not pass it.
- `--dir` selects the project directory; `--config` selects a configuration file.

## Project and Configuration

| Action | Command |
|---|---|
| Version | `papyrus --version` |
| Show effective configuration | `papyrus config list` |
| Read one value | `papyrus config get statuses` |
| Set one value | `papyrus config set <key> <value>` |
| Remove one value | `papyrus config unset <key>` |
| Search records | `papyrus search "<query>" [--type task\|milestone\|release\|decision\|doc] [--limit <n>]` |
| Documentation browser | `papyrus browser [--host <host>] [--port <port>] [--no-open]` |

The browser is the documentation index. Existing generated `index.html` files are not used.

## Multiline input

Papyrus reads multiline values from stdin when the option documents `Use "-" to read multiline text from standard input`. Pass `-` and a quoted heredoc:

```bash
papyrus milestone create "Checkout" --release REL-001 --description - <<'EOF'
Customers complete checkout in three steps.
- Address
- Payment
- Confirmation
EOF
```

- One stdin-consuming option per command; use a separate `edit` for another field.
- Keep single-line values inline.
- Fields without stdin support stay single-line: `release --description`, `req create-group --description`, `rule --rationale` / `--applicability`, `task --ac` / `--comment`, and all `--story` flags.
- `printf '%s\n' "line one" "line two" | papyrus ... --description -` works when a heredoc is impractical.

## Tasks

| Action | Command |
|---|---|
| List | `papyrus task list [--status <status>] [--milestone <id>] [--release <id>] [--label <label>] [--assignee <name>] [--search <text>] [--limit <n>] [--sort <field>]` |
| View | `papyrus task view <TASK-ID>` |
| Create | `papyrus task create "<title>" [--description <text\|->] [--ac <text>] [--milestone <id>] [--ordinal <n>] [--depends-on <TASK-ID>] [--label <label>] [--reference <ref>] [--documentation <path>] [--type <type>] [--assignee <name>]` |
| Edit | `papyrus task edit <TASK-ID> [--title] [--description <text\|->] [--ac] [--status] [--milestone] [--no-milestone] [--ordinal] [--depends-on] [--label] [--reference] [--documentation] [--type] [--assignee] [--comment] [--comment-author] [--editor]` |
| Archive | `papyrus task archive <TASK-ID>` |
| Restore | `papyrus task restore <TASK-ID>` |
| Delete | `papyrus task delete <TASK-ID>` |

### Task metadata

```json
{
  "id": "TASK-001",
  "title": "Scaffold monorepo",
  "metadata": {
    "status": "ToDo",
    "labels": ["setup"],
    "references": ["REQ-008.001"],
    "assignee": [],
    "milestone": "MS-001",
    "dependencies": [],
    "ordinal": 0,
    "documentation": ["docs/system-overview.md"],
    "type": "feature"
  }
}
```

- There is no `priority` field.
- Use `ordinal` for execution order. Lower runs first.
- `dependencies` contains direct dependency IDs.
- `--ac` adds acceptance criteria; there is no check/uncheck flag. `--ac` and `--comment` are single-line; `--description` accepts `-` for multiline stdin.
- There are no notes, plan, or final-summary fields. Use comments for evidence.
- `task view --json` returns `content` (full Markdown, including acceptance criteria) and `metadata`.

### Task selection and readiness

Papyrus 0.1.0 has no `--ready` flag, and `task list --milestone` / `--release` can return empty even when tasks are assigned. Use JSON:

```bash
papyrus --json task list
papyrus --json task list --status Done
papyrus --json milestone list
```

Resume order: tasks whose `metadata.status` is one of `Initiated`, `Refined`, `Implemented`, `Validated`, ordered by `metadata.ordinal`, then ID.

Ready order: `ToDo` tasks whose every `metadata.dependencies` ID is in the set of `Done` task IDs, ordered by `metadata.ordinal`, then ID.

Example with `jq`:

```bash
# Done task IDs
papyrus --json task list --status Done | jq -r '.[].id'

# In-progress tasks in ordinal order
papyrus --json task list \
  | jq -r '.[] | select(.metadata.status | IN("Initiated","Refined","Implemented","Validated")) | [.metadata.ordinal, .id] | @tsv' \
  | sort -n
```

## Milestones

| Action | Command |
|---|---|
| List | `papyrus milestone list` |
| View | `papyrus milestone view <MS-ID>` |
| Create | `papyrus milestone create "<title>" [--description <text\|->] [--release <REL-ID>] [--label <label>] [--reference <ref>]` |
| Edit | `papyrus milestone edit <MS-ID> [--title] [--description <text\|->] [--release] [--no-release] [--label] [--reference]` |
| Archive | `papyrus milestone archive <MS-ID>` |
| Delete | `papyrus milestone delete <MS-ID>` |

A milestone has a `release` field. Assign it with `--release`. Milestones have no status; completion is derived from their tasks.

## Releases

| Action | Command |
|---|---|
| List | `papyrus release list` |
| View | `papyrus release view <REL-ID>` |
| Create | `papyrus release create "<title>" [--description <text>] [--label <label>] [--reference <ref>]` |
| Edit | `papyrus release edit <REL-ID> [--title] [--description <text>] [--label] [--reference]` |

Release descriptions do not read stdin; keep them single-line.

A release is a first-class `REL` record. It has no status field. Model it as:

- `title`: `Release <version>`.
- `description`: release scope and acceptance criteria.
- milestones: assigned with `papyrus milestone edit <MS-ID> --release <REL-ID>`.
- task scope: tasks in the assigned milestones.
- completion: label `released` plus a completion note in the description.
- audit evidence: `papyrus audit create ... --reference <REL-ID>`.

## Business Requirements and NFRs

| Action | Command |
|---|---|
| Create group | `papyrus req create-group --title "<title>" [--description <text>] [--story <text>]` |
| Create requirement | `papyrus req create "<title>" --group <REQ-GROUP-ID> [--story <text>] [--description <text\|->]` |
| List | `papyrus req list` |
| View | `papyrus req view <REQ-ID>` |
| Edit | `papyrus req edit <REQ-ID> [--title] [--story] [--description <text\|->] [--label] [--reference] [--editor]` |
| Deprecate / restore | `papyrus req deprecate <REQ-ID>` / `papyrus req restore <REQ-ID>` |
| Create NFR | `papyrus nfr create "<title>" --group <NFR-GROUP-ID> [--description <text\|->]` |
| Create NFR group | `papyrus nfr create-group --title "<title>" [--description <text>]` |
| List / view / edit NFRs | `papyrus nfr list`, `papyrus nfr view <NFR-ID>`, `papyrus nfr edit <NFR-ID> ...` |

Create the group first; otherwise Papyrus returns `group not found`.

Requirements and NFRs have no acceptance-criteria flag. Put the criteria in `--description` (use `--description -` for multiline), or use `--editor` when an interactive editor is appropriate.

## Business Rules

| Action | Command |
|---|---|
| Create | `papyrus rule create "<title>" --description "<rule\|->" --rationale "<why>" --applicability "<when and where>" [--requirement <REQ-ID>] [--label <label>] [--reference <ref>]` |
| List | `papyrus rule list` |
| View | `papyrus rule view <BR-ID>` |
| Edit | `papyrus rule edit <BR-ID> [--title] [--description "<rule\|->"] [--requirement <REQ-ID>] [--no-requirement [<REQ-ID>]] [--label] [--reference] [--editor]` |
| Deprecate / restore | `papyrus rule deprecate <BR-ID>` / `papyrus rule restore <BR-ID>` |

## Glossary

| Action | Command |
|---|---|
| Create | `papyrus glossary create --term "<term>" --definition "<definition\|->" [--label <label>] [--reference <ref>]` |
| List | `papyrus glossary list` |
| View | `papyrus glossary view <GLO-ID>` |
| Edit | `papyrus glossary edit <GLO-ID> [--term] [--definition "<definition\|->"] [--label] [--reference] [--editor]` |
| Deprecate / restore | `papyrus glossary deprecate <GLO-ID>` / `papyrus glossary restore <GLO-ID>` |

## Decision Records

| Action | Command |
|---|---|
| Create | `papyrus decision create "<title>" [--decision-type adr\|bdr] [--decision <text\|->] [--context <text\|->] [--consequences <text\|->] [--label <label>] [--reference <ref>]` |
| List | `papyrus decision list` |
| View | `papyrus decision view <ADR-ID>` |
| Edit | `papyrus decision edit <ADR-ID> [--title] [--decision <text\|->] [--context <text\|->] [--consequences <text\|->] [--status <status>] [--superseded-by <ADR-ID>] [--label] [--reference]` |
| Archive | `papyrus decision archive <ADR-ID>` |

Decision statuses used by this workflow: `Proposed`, `Accepted`, `Refused`, `Superseded`, `Deprecated`. Check the project convention if unsure.

## UI and Technical Specifications

| Action | Command |
|---|---|
| Create UI spec | `papyrus ui-spec create "<title>" --view "<view>" --description "<text\|->" [--label <label>] [--reference <ref>]` |
| List / view / edit UI specs | `papyrus ui-spec list`, `papyrus ui-spec view <UI-ID>`, `papyrus ui-spec edit <UI-ID> --view ... --description "<text\|->" [--editor]` |
| Deprecate / restore UI spec | `papyrus ui-spec deprecate <UI-ID>` / `papyrus ui-spec restore <UI-ID>` |
| Create tech spec | `papyrus tech-spec create "<title>" --description "<text\|->" [--label <label>] [--reference <ref>]` |
| List / view / edit tech specs | `papyrus tech-spec list`, `papyrus tech-spec view <TECH-ID>`, `papyrus tech-spec edit <TECH-ID> --title ... --description "<text\|->" [--editor]` |
| Deprecate / restore tech spec | `papyrus tech-spec deprecate <TECH-ID>` / `papyrus tech-spec restore <TECH-ID>` |

The planning roadmap is stored as a technical specification titled `Feature Roadmap` and updated with `papyrus tech-spec edit <TECH-ID> --description -` and the roadmap on stdin.

Technical specifications document code, not delivery. `--description` carries behavior, flows, data, validation, and contracts only. Attach `REQ`/`NFR`, `BR`, `ADR`, glossary, and domain IDs with `--reference`; never reference `TASK`, `MS`, or `REL`, and never write traceability lists into the body.

## UI Mockups

| Action | Command |
|---|---|
| Create | `papyrus ui-mockup create --task <TASK-ID> --spec <UI-ID> "<title>" [--ref <ref>]` |
| List | `papyrus ui-mockup list` |
| View | `papyrus ui-mockup view <MOCK-ID>` |
| Edit | `papyrus ui-mockup edit <MOCK-ID> [--title] [--task <TASK-ID>] [--spec <UI-ID>] [--ref <ref>] [--status <status>] [--superseded-by <MOCK-ID>]` |
| Deprecate / restore | `papyrus ui-mockup deprecate <MOCK-ID>` / `papyrus ui-mockup restore <MOCK-ID>` |

Mockups start as `pending`. Set `--status approved` after explicit user approval. The HTML file is created and owned by Papyrus; do not hand-edit its metadata comments.

## Audit Records

| Action | Command |
|---|---|
| Create | `papyrus audit create --title "<title>" --content "<report\|->" [--audit-type <type>] [--label <label>] [--reference <ref>]` |
| List | `papyrus audit list` |
| View | `papyrus audit view <AUD-ID>` |
| Edit | `papyrus audit edit <AUD-ID> [--title] [--content "<report\|->"] [--audit-type] [--label] [--reference] [--editor]` |
| Deprecate / restore | `papyrus audit deprecate <AUD-ID>` / `papyrus audit restore <AUD-ID>` |

The Phase 5 `release-audit` creates the three Audit records (quality, code, security) with status `issued`.

## Caveats in Papyrus 0.1.0

1. **No priority field.** Use `ordinal` and dependencies. Do not pass `--sort priority`; it returns `unknown sort field: priority`.
2. **No `--ready` filter.** Compute readiness from `metadata.dependencies` and `Done` task IDs.
3. **Milestone/release task filters may return empty.** Cross-check with `papyrus --json task list` and filter on `metadata.milestone`.
4. **No `--plain` flag.** Plain text is the default.
5. **No acceptance-criteria checkbox toggle.** `--ac` adds criteria; review records pass/fail.
6. **No notes/final-summary fields.** Use `--comment` and `--comment-author`.
7. **Status values are exact and case-sensitive:** `ToDo`, `Initiated`, `Refined`, `Implemented`, `Validated`, `Done`.
8. **Mockup statuses:** `pending`, `approved`, `deprecated`. Unknown values fail.
9. **Rule rationale/applicability have no edit flags.** `papyrus rule edit` can change title, description, and requirement links; use `--editor` for rationale/applicability or deprecate and recreate.
10. **Files are written atomically.** A short-lived `.md.tmp` file may appear during a write; do not edit or delete it.
11. **Do not edit managed files directly.** Papyrus owns metadata, IDs, filenames, links, and archive state.
12. **`ui-mockup list --json` may return empty metadata in 0.1.0.** Read the record content with `papyrus ui-mockup view <MOCK-ID>` to see the `status` metadata comment.
13. **`--sort` is limited.** `--sort priority` and `--sort ordinal` can return `unknown sort field`. Use the default order and sort JSON results by `metadata.ordinal` yourself.

## Multi-line Values

Use real newlines inside single-quoted shell arguments, or repeat the command to append. Prefer single quotes when values contain backticks or `$`:

```bash
papyrus task edit TASK-001 --ac 'Run `mvn test` successfully'
```

For a long description, write it to a project-local `./.tmp/` file and pass it with a shell substitution only if the value is safe, or update the field with a quoted multi-line argument. Clean up `./.tmp/` before finishing.
