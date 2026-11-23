---
name: code-audit
description: 'Run the code audit over the specified code base: review complexity, duplication, naming, structure, test coverage, and style, and report findings.'
argument-hint: 'Provide the scope to audit; the whole codebase when none is given.'
user-invocable: true
disable-model-invocation: false
---

# Code Audit

## Outcome

An evidence-based code audit of the specified code base and test suite, severity-ranked findings, and a recommendation. The audit never fixes or approves.

## When to use

- Assess the code quality

## Prerequisites

- Read access to the source, tests, build files, and Technical specification.
- Available build and test commands for the stacks present.

## Scope

The scope provided in the instruction. When none is given, audit the whole codebase.

## Checks

- **Complexity** — functions/classes that are hard to understand or test. Expressed with cyclomatic complexity, cognitive complexity, mean max and p95 function length metrics. ...need skill...
- **Duplication** — repeated logic that should be shared. ...need skill...
- **Test coverage** — changed and unchanged behavior has meaningful tests; integration tests implement the approved test cases. ...need skill...
- **Naming** — unclear, misleading, or inconsistent names.
- **Structure** — boundary violations, misplaced responsibilities, dead code, unintended coupling.
- **Style-guide compliance** — the stack's style guide, formatter, and linter.

## Procedure

1. **Confirm scope** — depending on the instruction choose the code part (or whole) to review.
2. **Read the evidence** — source, tests, build output. Do not trust a summary.
3. **Run the checks** — build, full test suite, formatter check, and linter; inspect the scope and its tests against the checks above.
4. **Classify findings** — severity `low`, `medium`, `high`, or `blocker`, each with evidence and location.
5. **Decide the verdict** — `pass` when no finding requires action; otherwise `findings reported`.
6. **Report findings** — every finding with its severity, evidence, and recommendation.

## Rules

- The audit is independent and read-only. It never fixes what it finds.
- Every finding is severity-ranked with evidence and location.
- The audit does not create tasks, change scope, approve, version, package, or deploy.

## Stop conditions

- Scope not clear. Don't guess the scope.
- The build or test suite fails: record the failure as a finding; the audit does not pass.
- A finding has no evidence: stop; a finding is never carried without evidence.

## Report format

- **Scope**: the scope and baseline commit, files and test suites inspected.
- **Checks run**: commands and results.
- **Findings**: severity | finding | evidence | location | recommendation.
- **Severity counts**: blocker / high / medium / low.
- **Verdict**: pass / findings reported.

## Completion checks

- The scope was confirmed.
- Build, tests, formatter, and linter were run or explicitly marked unavailable.
- The whole scope and its test suite were covered.
- Every finding has severity, evidence, and location.
- No fix, task creation, or approval action was performed.
