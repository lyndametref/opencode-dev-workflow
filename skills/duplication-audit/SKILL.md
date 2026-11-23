---
name: duplication-audit
description: 'Measure code duplication over a specified scope: clone count, duplicated lines/tokens, duplication percentage, and the largest clone groups. Read-only; reports severity-ranked findings.'
argument-hint: 'Provide the scope to measure; the whole codebase when none is given.'
user-invocable: true
disable-model-invocation: false
---

# Duplication Audit

## Outcome

A measured duplication report for the specified scope: clone count, duplicated lines and tokens, duplication percentage, the largest clone groups, and severity-ranked findings with locations. The skill never refactors or merges code.

## When to use

- The `code-audit` skill needs its duplication check.
- The user asks for duplicated-code analysis.

Do not use this skill for complexity (use `complexity-audit`), coverage (use `coverage-audit`), naming, structure, or style.

## Prerequisites

- Read access to the source in scope.
- A duplication tool for the stacks present. Prefer the project's configured tool; otherwise a multi-language clone detector such as `jscpd` when available.
- The build files needed to identify languages and modules.

## Scope

The scope provided in the instruction. When none is given, measure the whole codebase.

Exclude by default:

- generated code, build output, `dist/`, `build/`, `target/`;
- vendored dependencies and `node_modules/`;
- minified bundles and lock files;
- migrations and schema dumps, unless the instruction includes them.

Report duplication in tests separately from production code; test duplication is not automatically a defect.

## Metrics

| Metric | Meaning |
|---|---|
| Duplication percentage | Duplicated lines or tokens divided by the measured total |
| Clone count | Number of clone pairs/groups detected |
| Duplicated lines | Lines involved in clones |
| Duplicated tokens | Tokens involved in clones |
| Largest clone groups | Largest clones by lines/tokens, with locations |

Default thresholds; a project configuration overrides them:

| Severity | Duplication |
|---|---|
| Low | < 3% |
| Medium | 3–5% |
| High | > 5–10% |
| Blocker | > 10%, or duplicated security-, money-, or authorization-critical logic |

A small clone can still be a blocker when it duplicates a critical rule that must stay single-sourced. Severity follows impact, not percentage alone.

## Procedure

1. **Confirm the scope** — resolve the files/directories to measure. Do not guess.
2. **Detect the stacks** — list languages and modules from the build files.
3. **Run the duplication tool** — use the project tool first; otherwise a multi-language detector. Example with `jscpd`:
   ```bash
   npx jscpd <scope> --min-tokens 50 --reporters console,json --output ./.tmp/jscpd
   ```
   Use the project's ignore file or explicit excludes for generated, build, and vendored paths. Record the exact command and tool version.
4. **Normalize the results** — file pairs/locations, duplicated lines, tokens, and total measured lines.
5. **Compute the percentage** — duplicated lines or tokens divided by the measured total, stated consistently.
6. **Inspect the largest clone groups** — read each one and decide whether it is harmful duplication or acceptable boilerplate.
7. **Classify findings** — severity from the table above plus impact; each finding names both locations, the duplicated behavior, and a recommendation.
8. **Report** — percentage, clone count, duplicated lines/tokens, largest groups, and findings.

If a language cannot be parsed, record the limitation and manually review repeated blocks in that scope. Never invent a duplication percentage.

## Rules

- Read-only: never extract a shared function, merge files, or change code.
- Evidence first: every finding names both locations, the duplicated behavior, and the measured size.
- Measure the scope you were given; do not silently expand or shrink it.
- Exclude generated, vendored, build, and minified files and state the exclusions.
- Percentages are not the only signal: duplicated business rules, validation, authorization, or money logic can be a blocker at any percentage.
- Do not report formatting-only or import-only repetition as meaningful duplication.
- Use only project-local `./.tmp/` for tool output and remove it before finishing.

## Stop conditions

- The scope is unclear or empty: stop and ask.
- No duplication tool is available and the scope is too large for a manual review: stop and report the limitation.
- A language in scope is unsupported by every available tool: record the language as unmeasured.

## Report format

- **Scope**: paths, modules, languages, exclusions.
- **Tooling**: tool, version, exact command, minimum token size.
- **Metrics**: duplication percentage, clone count, duplicated lines/tokens, measured total.
- **Largest clone groups**: locations, size, duplicated behavior.
- **Findings**: severity | locations | duplicated behavior | size | recommendation.
- **Test duplication**: reported separately or `none`.
- **Limitations**: unmeasured languages or unavailable metrics.
- **Verdict**: `pass` / `findings reported` for this check.

## Completion checks

- The scope, languages, and exclusions are stated.
- A tool ran or the manual limitation is recorded.
- The duplication percentage and clone count are reported.
- Duplicated lines/tokens are reported.
- The largest clone groups were inspected and classified.
- Every finding has severity, both locations, and evidence.
- No code was modified and no task was created.
