---
name: milestone-review
description: 'Verify one milestone for quality-gatekeeper in Phase 4: confirm every acceptance criterion with evidence, assess the basic code quality gates, run the standalone code audit on the milestone change set, and define correction tasks for failures. Read-only for code.'
argument-hint: 'Provide the milestone ID and its verification task ID.'
user-invocable: true
disable-model-invocation: false
---

# Milestone Review

## Outcome

An evidence-based milestone verdict: every milestone acceptance criterion marked pass or fail with evidence, the basic code quality gates assessed (build, automated tests, lint/style, critical issues in the changed code), the standalone code audit run on the milestone change set, and precise correction content for every failure. Correction tasks are created inside the milestone when the failure is in development work; a defect in a refinement artifact is reported for reopening.

## When to use

- The verification task of a milestone is opened in Phase 4.
- A correction task was completed and the verification must rerun.

Do not use this skill to fix code, change milestone scope, approve or close a milestone, or run the Phase 5 release audit.

## Prerequisites

- Load `managed-records`; read the milestone, its tasks, requirements, test cases, and source code.
- Read the milestone acceptance criteria from the milestone description.
- Available build and test commands for the stacks present.

## Scope

The milestone's acceptance criteria and the code changed by its development tasks. Pre-existing code outside the milestone is not the subject of this review; the whole-codebase release audit belongs to Phase 5.

## Procedure

1. **Read the milestone** — the acceptance criteria, tasks, change set, requirements, business rules, test cases, and the Technical specification. Confirm the refinement and development tasks are `Done`; if not, stop and return to execution.
2. **Check every acceptance criterion** — mark pass or fail with concrete evidence (test, build output, code path, or document). A criterion without evidence is a fail, not an assumption.
3. **Run the basic quality gates**:
   - the project builds;
   - the automated test suite passes;
   - the project's formatter, linter, and style checks pass;
   - no critical issue remains in the changed code.
4. **Check integration tests** — every approved test case has an implemented integration test, and it passes.
5. **Run the standalone code audit** — load `code-audit` and audit the milestone's change set: complexity, duplication, naming, structure, test coverage, and style. This is the milestone's own code audit, not the Phase 5 release audit. Do not create an audit record.
6. **Classify failures** — severity `low`, `medium`, `high`, or `blocker`; each with the blocked criterion or gate, evidence, location, and required correction.
7. **Create correction tasks** — for a development failure, create a task in the milestone through `manage-tasks`, with:
   - the failure description;
   - the acceptance criterion or quality gate it blocks;
   - the scope needed to fix it;
   - the owning actor.
   Report the correction task IDs. Do not reorder existing tasks; the orchestrator may adjust ordinals and dependencies.
8. **Report refinement defects** — when the failure is in the Technical specification, UI, mockups, or test cases, report the refinement task to reopen, with the evidence. Do not create a development correction task for it.
9. **Report the verdict** — `pass` only when every criterion, gate, and standalone code-audit finding is resolved; otherwise `corrections required`.

## Rules

- Read-only for code, tests, artifacts, and status. The only writes are correction tasks through `manage-tasks`.
- Rerun the build, tests, formatter, and linter; never trust a reported result.
- Every acceptance criterion has an explicit pass or fail with evidence.
- Correction tasks fix the failed criterion within the milestone scope; they never add a feature or change requirements.
- A refinement defect reopens refinement; it is not patched by a development correction task.
- Do not run the Phase 5 release audit or the security/quality audits; those belong to Phase 5.
- Run `code-audit` standalone at every milestone end; it is not the Phase 5 release audit and creates no audit record.
- Do not approve, close, or reorder the milestone.
- Use only project-local `./.tmp/` for transient output and remove it before finishing.

## Stop conditions

- A refinement or development task in scope is not `Done`: return to execution.
- The build or test suite cannot run: record the limitation and treat the gate as failed; do not accept reported evidence.
- An acceptance criterion is ambiguous or unverifiable: stop; its owner fixes it.
- The milestone scope is unclear or the change set cannot be delimited: stop and report.
- A requirement gap is discovered: return it to Phase 2 through the orchestrator.

## Report format

- **Milestone**: ID, title.
- **Change set**: files and development tasks reviewed.
- **Acceptance criteria**: criterion -> pass / fail -> evidence.
- **Quality gates**: build, tests, lint/style, critical-issue result.
- **Standalone code audit**: scope, checks, findings, verdict.
- **Test coverage**: approved test cases -> implemented and passing / missing.
- **Findings**: severity | finding | blocked criterion or gate | evidence | location | correction.
- **Correction tasks**: task IDs created, or `none`.
- **Reopened refinement**: task ID and reason, or `none`.
- **Verdict**: pass / corrections required.
- **Next action**: orchestrator.

## Completion checks

- Every milestone acceptance criterion has a pass/fail with evidence.
- Build, tests, formatter, and linter were run or explicitly marked unavailable.
- The standalone `code-audit` ran on the milestone change set.
- Every approved test case has an implemented, passing integration test, or is reported missing.
- Every development failure has a correction task; every refinement defect is reported for reopening.
- No code, artifact, status, or milestone scope was changed.
- No release audit was run and no audit record was created.
