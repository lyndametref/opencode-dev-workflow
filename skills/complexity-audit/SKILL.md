---
name: complexity-audit
description: 'Measure code complexity over a specified scope: cyclomatic complexity, cognitive complexity where the stack reports it, and function-length distribution (mean, max, p95). Read-only; reports severity-ranked findings.'
argument-hint: 'Provide the scope to measure; the whole codebase when none is given.'
user-invocable: true
disable-model-invocation: false
---

# Complexity Audit

## Outcome

A measured complexity report for the specified scope: per-function cyclomatic complexity, cognitive complexity where available, and function-length statistics (mean, max, p95), with severity-ranked findings and locations. Measurements are evidence; the skill never refactors code.

## When to use

- The `code-audit` skill needs its complexity check.
- The user asks for complexity metrics or hotspot analysis.

Do not use this skill for duplication (use `duplication-audit`), coverage (use `coverage-audit`), naming, structure, or style.

## Prerequisites

- Read access to the source in scope.
- A measurement tool for the stacks present. Prefer the project's configured tool; fall back to a multi-language tool such as `lizard` when available.
- The build files needed to identify languages and modules.

## Scope

The scope provided in the instruction. When none is given, measure the whole codebase. Exclude generated code, vendored dependencies, build output, and migration/schema dumps unless the instruction includes them.

## Metrics

| Metric | What it measures | Source |
|---|---|---|
| Cyclomatic complexity | Independent paths through a function | Lizard, detekt, ESLint `complexity`, rust-code-analysis, or the project tool |
| Cognitive complexity | Human difficulty from nesting and control flow | detekt `CognitiveComplexMethod`, Sonar, or the project tool; if unavailable, record `not available` |
| Function length | Lines per function | Lizard, detekt `LongMethod`, ESLint `max-lines-per-function`, or the project tool |
| Distribution | Mean, maximum, p95 function length | Computed from the per-function rows |

Default thresholds; a project configuration overrides them:

| Severity | Cyclomatic | Cognitive | Function length |
|---|---|---|---|
| Low | ≤ 10 | ≤ 15 | ≤ 40 lines |
| Medium | 11–15 | 16–25 | 41–80 lines |
| High | 16–20 | 26–35 | 81–120 lines |
| Blocker | > 20 | > 35 | > 120 lines |

Also report when the distribution itself is unhealthy: mean length > 30 lines, p95 > 80 lines, or a single function > 150 lines.

## Procedure

1. **Confirm the scope** — resolve the files/directories to measure. Do not guess.
2. **Detect the stacks** — list languages and modules from the build files.
3. **Run the measurement** — use the project tool first; otherwise a multi-language tool. Examples, adapted to what is installed:
   - JVM/Kotlin: the project's detekt task or `detekt --input <scope> --report txt:<file>`.
   - JavaScript: `npx eslint <scope> --format json` with `complexity` and `max-lines-per-function` enabled, or the project lint task.
   - Rust: `rust-code-analysis-cli -m -p <scope> -O json` when installed.
   - Multi-language fallback: `lizard <scope>` and capture the per-function output.
   Record the exact command and tool version.
4. **Normalize the rows** — function, file, line, cyclomatic, cognitive (or `not available`), length.
5. **Compute the distribution** — mean, max, and p95 function length for the scope.
6. **Classify findings** — severity from the table above, with the function, file, line, metric value, and recommendation.
7. **Report the top offenders** — the highest complex and longest functions, plus the distribution summary.

If a tool cannot measure a language, record the limitation and do a manual review of the largest functions. Never invent a metric.

## Rules

- Read-only: never refactor, rename, or change code to improve a metric.
- Evidence first: every finding names the function, file, line, metric, and measured value.
- Measure the scope you were given; do not silently expand or shrink it.
- Do not count generated, vendored, build, or minified files.
- Cognitive complexity is reported only when the tool provides it; otherwise `not available`.
- Do not use line count alone to call a function bad; pair it with complexity.
- Use only project-local `./.tmp/` for tool output and remove it before finishing.

## Stop conditions

- The scope is unclear or empty: stop and ask.
- No measurement tool is available and the scope is too large for a manual review: stop and report the limitation.
- A language in scope is unsupported by every available tool: record the language as unmeasured.

## Report format

- **Scope**: paths, modules, languages, exclusions.
- **Tooling**: tool, version, exact command.
- **Distribution**: mean, max, p95 function length; function count.
- **Findings**: severity | function | file:line | cyclomatic | cognitive | length | recommendation.
- **Top offenders**: highest complexity and longest functions.
- **Limitations**: unmeasured languages or unavailable metrics.
- **Verdict**: `pass` / `findings reported` for this check.

## Completion checks

- The scope and languages are stated.
- A tool ran or the manual limitation is recorded.
- Cyclomatic complexity and function length are reported for the scope.
- Cognitive complexity is reported or marked not available.
- The distribution (mean, max, p95) is computed.
- Every finding has severity, location, metric value, and evidence.
- No code was modified and no task was created.
