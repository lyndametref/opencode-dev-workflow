---
name: quality-audit
description: 'Run the Phase 5 milestone quality review or the Phase 6 release quality audit: verify acceptance criteria, completeness, tests, scope, and NFR coverage, record the quality audit, and report findings and corrections.'
argument-hint: 'Provide a milestone ID, its milestone-verification task ID, or a release ID.'
user-invocable: true
disable-model-invocation: false
---

# Quality Audit

## Outcome

An evidence-based quality audit for one assessed scope: a milestone at its Phase 5 boundary, or the whole release in Phase 6. The audit is recorded as a Papyrus `AUD` record of type `quality` with status `issued`, severity-ranked findings, and either a pass or the correction/fix content the reviewer defines.

## When to use

- Phase 5: the milestone verification task is opened after every execution task is `Done`.
- Phase 6: the release quality audit runs over the whole release.

Do not use this skill to fix, rework, approve, or release.

## Prerequisites

- Load `papyrus`.
- Read access to the milestone/release, its tasks, requirements, specifications, UI, tests, and source code.

## Scopes

| Mode | Scope | Reference |
|---|---|---|
| Milestone quality review (Phase 5) | Only the milestone's change set and the behavior it touches | Milestone `MS` and its verification task |
| Release quality audit (Phase 6) | The whole release: all milestones, the cumulative change set, integration, regression, consistency, and NFR coverage | Release `REL` |

## Procedure

1. **Resolve the scope** — read the milestone or release, its tasks, and the acceptance criteria. A release has no acceptance criteria of its own; project-wide criteria apply. Confirm every task in scope is `Done`; if not, stop and return the scope to Phase 4.
2. **Read the evidence** — read the fulfilment proof, test results, requirements, specifications, UI, and the change set. Do not accept reported evidence on trust; rerun the checks.
3. **Run the checks**:
   - every acceptance criterion is met, with evidence per criterion;
   - required fields and artifacts are complete;
   - the test suite is rerun and passes;
   - the change set stays inside the approved scope (scope creep);
   - referenced NFRs are addressed;
   - in release mode: milestones are complete and verified, the change set is consistent across milestones, integration and regression pass, and cumulative change is covered.
4. **Classify findings** — severity `low`, `medium`, `high`, or `blocker`, each with evidence, location, and recommendation.
5. **Decide** — `pass` when no finding blocks the scope; otherwise `corrections required`. In release mode, a `blocker` or an unresolved `high` finding blocks the release.
6. **Record the audit** — `papyrus audit create --title "<MS/REL> quality audit" --content "<structured report>" --audit-type quality --reference <MS/REL-ID> --label issued`. The workflow audit status is recorded by the `issued` and `approved` labels; use `papyrus audit deprecate` when an audit is archived. Only one quality audit may be `issued` or `approved` per assessed scope at a time; when the check is rerun after corrections, the new audit replaces the previous one, which is archived.
7. **Report corrections** — define the correction content: the failure description and the acceptance criteria it blocks. Do not create tasks; the orchestrator routes the content to `planner`, who creates the correction or fix task in the owning milestone.
8. **Report** — the audit ID, verdict, per-criterion results, severity counts, findings, corrections, and the next action.

## Rules

- Reviewers are independent of implementation and read-only.
- Scope is exactly one milestone or one release per pass; never batch.
- Rerun tests and re-read evidence; never trust a summary.
- In Phase 5, changes are correction tasks inside the milestone's approved scope; scope, dependency, or ordinal changes go to `planner`.
- In Phase 6, rejected findings or failed checks become fix tasks in the release's fix milestone.
- A reviewer never fixes what it finds and never approves or closes a release.
- A finding the user does not accept becomes correction or fix work; after the correction a new audit is issued and the old one is archived.
- Accepted findings require an owner and a follow-up task.
- Do not write reports outside the audit record and the response.

## Stop conditions

- A task in scope is not `Done`: return to Phase 4.
- Tests fail or cannot be run: record the failure and require corrections; do not accept reported evidence.
- An acceptance criterion is ambiguous or unverifiable: stop; the criterion is fixed by its owner.
- A finding has no owner: stop; a finding is never carried without an owner.
- A reviewer discovers a requirement gap rather than an implementation defect: return to Phase 2.

## Report format

- **Scope**: milestone or release ID, title, change set.
- **Checks run**: commands and evidence.
- **Acceptance criteria**: criterion -> pass/fail -> evidence (release mode: project-wide criteria).
- **Findings**: severity | finding | evidence | location | recommendation.
- **Severity counts**: blocker / high / medium / low.
- **Verdict**: pass / corrections required.
- **Audit record**: `AUD` ID, type `quality`, status `issued`.
- **Corrections**: failure description and blocked criteria, or `none`.
- **Next action**: who does what next.

## Completion checks

- Scope and change set are stated and complete.
- Every check was rerun or re-read, not trusted.
- Every acceptance criterion has a pass/fail and evidence.
- Every finding has severity, evidence, and an owner or required correction.
- The `AUD` record exists, references the scope, and is `issued`.
- No fix, approval, task creation, or release action was performed.
