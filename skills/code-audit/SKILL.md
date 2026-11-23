---
name: code-audit
description: 'Run the Phase 5 code audit over the whole frozen codebase: review complexity, duplication, naming, structure, test coverage, and style, record the Audit artifact, and report findings for the user fix-or-own decision.'
argument-hint: 'Provide the release ID and the feature freeze; no milestone mode exists.'
user-invocable: true
disable-model-invocation: false
---

# Code Audit

## Outcome

An evidence-based code audit of the whole frozen codebase and test suite, recorded as a managed audit record of type `code` with status `issued`, severity-ranked findings, and a recommendation. The user decides for every finding whether it is fixed or owned. The audit never fixes, approves, or releases.

## When to use

- Phase 5, after the user declares the feature freeze.
- The frozen milestone scope and baseline commit are recorded.

Do not use this skill for a single milestone (use `milestone-review`), for feature completeness (use `quality-audit`), or for exploitability (use `security-audit`).

## Prerequisites

- Load `manage-audits`; read releases, milestones, and tasks through their `manage-*` skills.
- Read access to the source, tests, build files, and Technical specification.
- Available build and test commands for the stacks present.

## Scope

The whole codebase and test suite, including code unchanged in the frozen milestones. There is no milestone-scoped code audit in Phase 5.

## Checks

- **Complexity** — functions/classes that are hard to understand or test.
- **Duplication** — repeated logic that should be shared.
- **Naming** — unclear, misleading, or inconsistent names.
- **Structure** — boundary violations, misplaced responsibilities, dead code, unintended coupling.
- **Test coverage** — changed and unchanged behavior has meaningful tests; integration tests implement the approved test cases.
- **Style-guide compliance** — the stack's style guide, formatter, and linter.
- **Security-relevant code patterns** — only as code-quality observations; exploitability belongs to `security-audit`.

## Procedure

1. **Confirm the freeze and baseline** — read the release, its frozen milestone scope, the baseline commit, and the complete milestones. If the freeze is missing or a milestone is incomplete, stop.
2. **Read the evidence** — source, tests, build output, and the Technical specification. Do not trust a summary.
3. **Run the checks** — build, full test suite, formatter check, and linter; inspect the whole codebase and tests against the checks above.
4. **Classify findings** — severity `low`, `medium`, `high`, or `blocker`, each with evidence and location.
5. **Decide the verdict** — `pass` when no finding blocks the release; otherwise `findings reported`.
6. **Record the audit** — create the record via `manage-audits`, type `code`, reference the release, and set status `issued`. Only one code audit may be `issued` or `approved` in the release scope at a time; a rerun replaces the previous audit, which is archived.
7. **Report findings** — every finding with its severity, evidence, and recommendation, ready for the user's `fix` or `own` decision.
8. **Report** — audit ID, verdict, checks, severity counts, findings, and next action.

## Rules

- The audit is independent and read-only. It never fixes what it finds.
- The scope is the whole frozen codebase; never sample or audit a single milestone.
- Every finding is severity-ranked with evidence and location.
- A finding the user chooses to fix becomes a fix milestone executed in Phase 4; the audit reruns after it passes. The previous audit is archived.
- A finding the user chooses to own is documented with an owner and a follow-up note; the audit can then be `approved`.
- The audit does not create tasks, change scope, approve the release, version, package, or deploy.
- Do not write reports outside the audit record and the response.

## Stop conditions

- No recorded feature freeze: stop; the audit does not run.
- A frozen milestone is incomplete: return to Phase 4.
- The build or test suite fails: record the failure as a finding; the audit does not pass.
- A finding has no evidence: stop; a finding is never carried without evidence.

## Report format

- **Scope**: release ID, freeze, baseline commit, files and test suites inspected.
- **Checks run**: commands and results.
- **Findings**: severity | finding | evidence | location | recommendation.
- **Severity counts**: blocker / high / medium / low.
- **Verdict**: pass / findings reported.
- **Audit record**: `AUD` ID, type `code`, status `issued`.
- **Next action**: user fix-or-own decision.

## Completion checks

- The freeze and baseline were confirmed.
- Build, tests, formatter, and linter were run or explicitly marked unavailable.
- The whole codebase and test suite were covered.
- Every finding has severity, evidence, and location.
- The `AUD` record exists, references the release, and is `issued`.
- No fix, task creation, approval, or release action was performed.
