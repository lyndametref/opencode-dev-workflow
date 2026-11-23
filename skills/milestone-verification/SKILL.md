---
name: milestone-verification
description: 'Run the Phase 4 verification task of one milestone: dispatch quality-gatekeeper, run the standalone code audit, drive correction tasks or reopened refinement, and close the verification task only when every milestone acceptance criterion, basic code quality gate, and code-audit finding passes.'
argument-hint: 'Provide a milestone ID whose refinement and development tasks are Done.'
user-invocable: true
disable-model-invocation: false
---

# Milestone Verification

## Outcome

One milestone verification task is `Done`. It records the milestone acceptance criteria checked with evidence, the basic code quality gates, the standalone code audit on the milestone change set, correction tasks or a reopened refinement task, and the final verdict. The milestone is then complete. No RC version and no milestone package are produced.

## When to use

- Every refinement and development task of a milestone is `Done`.
- A correction task was completed and verification must rerun.

Do not use this skill to fix code, change milestone scope, verify more than one milestone, or run the Phase 5 release audit.

## Prerequisites

- Read the milestone, its tasks, acceptance criteria, and verification task.
- The milestone has exactly one task of type `verification`, assigned to `quality-gatekeeper`.
- Available subagent: `quality-gatekeeper`.

## Procedure

1. **Confirm the boundary** — read the milestone and its tasks. The refinement task and every development task must be `Done`. If not, return to Phase 4 execution.
2. **Open the verification task** — find the milestone's verification task (`--type verification`) and set it to `Initiated`. Its criteria are the milestone acceptance criteria.
3. **Run the verification** — dispatch `quality-gatekeeper` with the milestone ID, the milestone acceptance criteria, and the change set. Require the `milestone-review` report: per-criterion pass/fail, quality-gate results, the standalone `code-audit` findings, and correction content.
4. **Handle corrections** — if verification reports failures:
   - a failed milestone criterion or code quality gate becomes a correction task with its failure description and the criterion it blocks; the orchestrator assigns and orders it inside the milestone;
   - a defect in a refinement artifact reopens the refinement task instead;
   - execute the correction work through `milestone-execution`;
   - rerun verification after every correction task is `Done`.
5. **Close the verification task** — set it to `Done` only when:
   - every milestone acceptance criterion passes with evidence;
   - the build succeeds, the automated test suite passes, the project's lint/style checks pass, and no critical issue remains in the changed code;
   - the standalone `code-audit` ran and every finding is resolved;
   - every correction task is `Done` or none was needed;
   - the result and evidence are recorded as comments on the verification task.
6. **Report** — the verification result, per-criterion summary, quality-gate results, correction tasks or reopened refinement, and the milestone boundary.

## Rules

- Verification is milestone-scoped: the milestone's acceptance criteria and its changed code.
- Security is not assessed here; it belongs to the Phase 5 release audit at the feature freeze.
- The verifier is independent and read-only. It never fixes what it finds.
- Every check reruns or re-reads its evidence; reported results are not trusted.
- Findings are severity-ranked with evidence, location, and recommendation; the scale is `low`, `medium`, `high`, `blocker`.
- Scope, dependency, and ordinal changes go to planning; verification never changes them.
- The verification task is the only check of the milestone. The milestone is not complete before it is `Done`.
- There is no RC version and no milestone package. Final packages are built in Phase 6.
- Each milestone runs `code-audit` standalone. That is not the Phase 5 release audit, and no audit record is created.
- The verification task does not approve the release and does not run the security or quality audits.

## Failure handling

| Outcome | Action |
|---|---|
| A milestone acceptance criterion fails | Correction task with the failure description and the blocked criterion; Phase 4 executes; verification reruns. |
| A basic quality gate fails (build, tests, lint/style, critical issue) | Correction task with the failure description; Phase 4 executes; verification reruns. |
| A standalone code-audit finding is unresolved | Correction task with the finding, evidence, and location; Phase 4 executes; the code audit reruns. |
| The defect is in a refinement artifact | Reopen the refinement task; refine again; verification reruns. |
| Scope creep | Report the unjustified change; the user decides removal or a requirements change through Phase 2. |
| Verification cannot run | Stop and report; supply the missing evidence before continuing. |

## Stop conditions

- A refinement or development task in the milestone is not `Done`: return to Phase 4 execution.
- Tests fail or cannot be run: record the failure and create correction tasks; do not accept reported evidence.
- An acceptance criterion is ambiguous or unverifiable: stop; its owner fixes it.
- A correction needs a scope, dependency, or ordinal change: stop and return to planning.
- A reviewer discovers a requirement gap: return to Phase 2.

## Report format

- **Milestone**: ID, title, acceptance criteria.
- **Change set**: files, behavior, tasks.
- **Acceptance criteria**: criterion -> pass / fail -> evidence.
- **Quality gates**: build, tests, lint/style, critical-issue result.
- **Standalone code audit**: scope, findings, verdict.
- **Corrections**: task IDs and status, or reopened refinement task, or `none`.
- **Verification task**: ID and status.
- **Next action**: next milestone or feature freeze.

## Completion checks

- The milestone boundary was confirmed before verification started.
- Every milestone acceptance criterion has a pass/fail with evidence.
- Every basic code quality gate was run or explicitly marked unavailable.
- The standalone `code-audit` ran on the milestone change set and its findings are resolved.
- Every correction task is `Done` or none was needed, and verification reran.
- The verification task is `Done` with its evidence recorded.
- No RC version, package, release audit, audit record, or scope change was made.

## Resume / interruption

Verification state is derived from the milestone, its tasks, and the verification task.

On re-invocation, re-read them, skip completed checks, and rerun any check whose evidence is stale. Correction tasks created earlier are not duplicated; a rerun uses the same verification task and the current milestone scope.
