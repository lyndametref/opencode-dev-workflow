---
name: coverage-audit
description: 'Measure test coverage over a specified scope and verify that approved test cases have implemented integration tests. Reports line/branch/function coverage, changed-code coverage, and severity-ranked gaps. Read-only.'
argument-hint: 'Provide the scope to measure; the whole codebase when none is given.'
user-invocable: true
disable-model-invocation: false
---

# Coverage Audit

## Outcome

A measured coverage report for the specified scope: line, branch, and function coverage; changed-code coverage when it can be computed; a mapping from approved test cases to implemented integration tests; and severity-ranked findings with locations. The skill never writes tests or changes coverage configuration.

## When to use

- The `code-audit` skill needs its test-coverage check.
- The user asks whether the scope is adequately tested.

Do not use this skill for complexity (use `complexity-audit`), duplication (use `duplication-audit`), naming, structure, or style.

## Prerequisites

- Read access to the source, tests, build files, coverage configuration, and Technical specification.
- Read the approved test cases through `manage-test-cases`.
- The project's test and coverage tasks, or a coverage tool that can run them.
- The baseline commit or diff range for changed-code coverage.

## Scope

The scope provided in the instruction. When none is given, measure the whole codebase. Report test and production coverage separately when the tool provides both.

## Metrics

| Metric | Meaning |
|---|---|
| Line coverage | Executed lines divided by measured lines |
| Branch coverage | Executed branches divided by measured branches |
| Function coverage | Executed functions divided by measured functions |
| Changed-code coverage | Coverage over the lines changed in the scope |
| Test-case coverage | Approved test cases with an implemented, passing integration test |

Default targets; a project configuration overrides them:

| Severity | Condition |
|---|---|
| Blocker | Changed behavior has no test; an approved test case has no implemented integration test; a critical path is untested |
| High | Changed-code coverage < 70%, or line coverage < 60% |
| Medium | Line coverage < 80%, or branch coverage < 60% |
| Low | Below the project target but not in the high/blocker bands |

Coverage percentage is not a quality verdict: a high percentage with weak assertions or skipped tests is still a finding.

## Procedure

1. **Confirm the scope and baseline** — resolve the files/modules and the diff range. Do not guess.
2. **Identify the coverage setup** — from the build files and CI config, find the test task and coverage report. If none exists, record `not available`; do not invent a percentage.
3. **Run tests with coverage** — use the project's configured task. Examples, adapted to what exists:
   - JVM/Kotlin: `./gradlew test jacocoTestReport`, then read the JaCoCo XML (`build/reports/jacoco/test/jacocoTestReport.xml`).
   - Android: the project's unit-test coverage task (for example `./gradlew testDebugUnitTest jacocoTestReport`), then its report.
   - Rust: `cargo llvm-cov --workspace --summary-only`, or `cargo tarpaulin --out Xml`.
   - JavaScript: `npx c8 --reporter=text --reporter=lcov <test-command>`, or the project's coverage task.
   Record the exact command, tool, and report path.
4. **Parse the report** — record line, branch, and function coverage for the scope; per module when available.
5. **Compute changed-code coverage** — use `diff-cover <coverage-file> --compare-branch=<base>` when available; otherwise identify changed lines and check them against the report. If neither is possible, record `not computed` and say why.
6. **Map approved test cases** — read the `TC` IDs and covered requirements. Find the integration tests that implement each one by tags, names, or explicit references. Report every test case with no implemented integration test.
7. **Inspect test quality** — look for skipped/disabled tests, tests without assertions, tests that only exercise mocks, and flaky or timing-dependent tests. Coverage alone never clears a gap.
8. **Classify findings** — severity from the table above plus impact; each finding names the file/line or test case, the missing behavior, and a recommendation.
9. **Report** — coverage summary, changed-code coverage, test-case mapping, findings, and limitations.

If the suite fails, record the failure as a finding; coverage from a failing run is not accepted as evidence.

## Rules

- Read-only: never write tests, change coverage configuration, or modify source.
- Evidence first: report the command, tool, report path, and measured numbers.
- Do not count generated, vendored, build, or minified files.
- Do not accept a reported percentage without rerunning or reading the report.
- Coverage is necessary but not sufficient: weak assertions, skipped tests, and mock-only integration tests are findings.
- Report unavailable metrics as `not available`; never estimate them.
- Use only project-local `./.tmp/` for tool output and remove it before finishing.

## Stop conditions

- The scope is unclear or empty: stop and ask.
- The test suite fails: record the failure; do not treat the run as valid coverage evidence.
- No coverage tool or report exists: record the limitation; do not invent numbers.
- The baseline or diff range is missing for changed-code coverage: report it as `not computed`.
- An approved test case has no traceable integration test: report the gap; do not guess a mapping.

## Report format

- **Scope**: paths, modules, languages, exclusions, diff range.
- **Tooling**: task, tool, version, exact command, report path.
- **Coverage**: line / branch / function, overall and per module.
- **Changed-code coverage**: percentage and method, or `not computed` with the reason.
- **Test-case coverage**: `TC` ID -> implemented and passing / missing.
- **Findings**: severity | location or test case | gap | evidence | recommendation.
- **Test quality**: skipped, assertion-free, mock-only, or flaky tests.
- **Limitations**: unavailable metrics or reports.
- **Verdict**: `pass` / `findings reported` for this check.

## Completion checks

- The scope, diff range, and exclusions are stated.
- The coverage command and report were identified and run, or the limitation is recorded.
- Line, branch, and function coverage are reported or marked not available.
- Changed-code coverage is computed or explicitly not computed.
- Every approved test case is mapped to a passing integration test or reported missing.
- Test quality was inspected, not inferred from the percentage.
- Every finding has severity, location, evidence, and recommendation.
- No code or test was modified and no task was created.
