---
name: code-audit
description: 'Run the Phase 5 change-scoped code audit or the Phase 6 release-wide code audit: review complexity, duplication, naming, structure, coverage, and style, record the code audit, and report corrections.'
argument-hint: 'Provide a milestone ID or a release ID.'
user-invocable: true
disable-model-invocation: false
---

# Code Audit

## Outcome

An evidence-based code audit for one assessed scope: the code and tests changed in a milestone (Phase 5), or the whole codebase and test suite (Phase 6). The audit is recorded as a Papyrus `AUD` record of type `code` with status `issued`, severity-ranked findings, and correction/fix content.

## When to use

- Phase 5: after the quality review of the milestone passes.
- Phase 6: the release-wide code audit runs over the whole codebase.

Do not use this skill to fix code, approve, or release.

## Prerequisites

- Load `papyrus`.
- Read access to the source, tests, build files, and specification.
- Available build and test commands for the stacks present.

## Scopes

| Mode | Scope |
|---|---|
| Milestone code audit (Phase 5) | Only the code and tests created or modified in the milestone. Pre-existing code is not audited here. |
| Release code audit (Phase 6) | The whole codebase and test suite, including code unchanged in this release. |

## Checks

- **Complexity** — functions/classes that are hard to understand or test.
- **Duplication** — repeated logic that should be shared.
- **Naming** — unclear, misleading, or inconsistent names.
- **Structure** — boundary violations, misplaced responsibilities, dead code, unintended coupling.
- **Test coverage** — changed behavior has tests; integration tests implement the approved test cases; tests are meaningful, not superficial.
- **Style-guide compliance** — the stack's style guide, formatter, and linter.
- **Security-relevant code patterns** — only as code-quality observations; the security audit is Phase 6.

## Procedure

1. **Resolve the scope** — read the milestone or release and its change set. Confirm every task in scope is `Done`.
2. **Read the evidence** — read the changed files, tests, build output, and specification. Do not trust a summary.
3. **Run the checks** — run the build, test suite, formatter check, and linter; inspect the changed code and tests against the checks above.
4. **Classify findings** — severity `low`, `medium`, `high`, or `blocker`, each with evidence and location.
5. **Decide** — `pass` when no finding blocks the scope; otherwise `corrections required`.
6. **Record the audit** — create the audit record (manage-audits), type `code`, with the `issued` label. Only one code audit may be `issued` or `approved` per assessed scope at a time; a rerun after corrections replaces the previous audit, which is archived.
7. **Report corrections** — define the failure description and the acceptance criteria it blocks. Do not create tasks; the orchestrator routes the content to `planner`.
8. **Report** — audit ID, verdict, checks, severity counts, findings, corrections, and next action.

## Rules

- Auditors are independent of implementation and read-only.
- Phase 5 audits only the milestone's change set; Phase 6 audits the whole codebase.
- Every finding is severity-ranked with evidence and location.
- Accepted findings require an owner and a follow-up task.
- A reviewer never fixes what it finds and never approves or closes a release.
- Do not write reports outside the audit record and the response.

## Stop conditions

- A task in scope is not `Done`: return to Phase 4.
- The build or test suite fails: record the failure and require corrections.
- The change set cannot be delimited for the milestone: stop and report; the scope is fixed by the orchestrator/planner.
- A finding has no owner: stop; a finding is never carried without an owner.

## Report format

- **Scope**: milestone or release ID, change set, files inspected.
- **Checks run**: commands and results.
- **Findings**: severity | finding | evidence | location | recommendation.
- **Severity counts**: blocker / high / medium / low.
- **Verdict**: pass / corrections required.
- **Audit record**: `AUD` ID, type `code`, status `issued`.
- **Corrections**: failure description and blocked criteria, or `none`.
- **Next action**: who does what next.

## Completion checks

- Scope and change set are stated and complete.
- Build, tests, formatter, and linter were run or explicitly marked unavailable.
- Every finding has severity, evidence, and location.
- The `AUD` record exists, references the scope, and is `issued`.
- No fix, approval, task creation, or release action was performed.
