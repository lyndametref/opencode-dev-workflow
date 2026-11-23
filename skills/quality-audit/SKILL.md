---
name: quality-audit
description: 'Run the Phase 5 quality audit over the whole frozen codebase: verify feature completeness against requirements, business rules, milestone acceptance criteria, NFRs, scope, and tests, record the Audit artifact, and report findings for the user fix-or-own decision.'
argument-hint: 'Provide the release ID and the feature freeze; no milestone mode exists.'
user-invocable: true
disable-model-invocation: false
---

# Quality Audit

## Outcome

An evidence-based quality audit of the whole frozen codebase, recorded as a managed audit record of type `quality` with status `issued`, severity-ranked findings, and a recommendation. The user decides for every finding whether it is fixed or owned. The audit never fixes, approves, or releases.

## When to use

- Phase 5, after the user declares the feature freeze.
- The frozen milestone scope and baseline commit are recorded.

Do not use this skill for a single milestone (use `milestone-review`), for code style (use `code-audit`), or for exploitability (use `security-audit`).

## Prerequisites

- Load `manage-audits`; read releases, milestones, tasks, and requirements through their `manage-*` skills.
- Read access to the frozen codebase, test suite, requirements, business rules, Technical specification, UI specifications, test cases, and task evidence.
- The baseline commit of the last completed milestone.

## Scope

The whole frozen codebase, including code unchanged since the last release. There is no milestone-scoped quality audit in Phase 5.

## Checks

- **Requirement coverage** — every verified `REQ`/`NFR` is implemented and traceable to a milestone and task.
- **Acceptance criteria** — every milestone acceptance criterion is fulfilled in the frozen build, with evidence.
- **Business rules** — every rule is exercised by a test and behaves as stated.
- **NFR coverage** — each quality target or constraint has evidence.
- **Scope creep** — no unjustified behavior outside the frozen scope.
- **Tests** — the full suite is rerun and passes; every approved test case has an implemented integration test.
- **Integration** — features delivered by different milestones work together.
- **Consistency** — requirements, Technical specification, UI specifications, and code do not contradict each other.

## Procedure

1. **Confirm the freeze and baseline** — read the release, its frozen milestone scope, the baseline commit, and the complete milestones. If the freeze is missing or a milestone is incomplete, stop.
2. **Read the evidence** — tasks, fulfilment proof, requirements, rules, specifications, test cases, and the change set. Do not trust reported results; rerun the checks.
3. **Run every check above** over the frozen codebase.
4. **Classify findings** — severity `low`, `medium`, `high`, or `blocker`, each with evidence, location, and recommendation.
5. **Decide the verdict** — `pass` when no finding blocks the release; otherwise `findings reported`. A `blocker` or unresolved `high` finding prevents a passing audit.
6. **Record the audit** — create the record via `manage-audits`, type `quality`, reference the release, and set status `issued`. Only one quality audit may be `issued` or `approved` in the release scope at a time; a rerun replaces the previous audit, which is archived.
7. **Report findings** — every finding with its severity, evidence, and recommendation, ready for the user's `fix` or `own` decision.
8. **Report** — audit ID, verdict, per-check results, severity counts, findings, and the next action.

## Rules

- The audit is independent and read-only. It never fixes what it finds.
- The scope is the whole frozen codebase; never sample or audit a single milestone.
- Every finding is traceable to evidence; unverifiable checks are reported as gaps, not passes.
- A finding the user chooses to fix becomes a fix milestone executed in Phase 4; the audit reruns after it passes. The previous audit is archived.
- A finding the user chooses to own is documented with an owner and a follow-up note; the audit can then be `approved`.
- The audit does not create tasks, change scope, approve the release, version, package, or deploy.
- Do not write reports outside the audit record and the response.

## Stop conditions

- No recorded feature freeze: stop; the audit does not run.
- A frozen milestone is incomplete or its verification task is not `Done`: return to Phase 4.
- Tests fail or cannot be run: record the failure as a finding; do not accept reported evidence.
- An acceptance criterion is ambiguous or unverifiable: stop; its owner fixes it.
- A finding has no evidence: stop; a finding is never carried without evidence.
- A requirement gap is discovered rather than an implementation defect: the user lifts the freeze and the gap goes through Phase 2.

## Report format

- **Scope**: release ID, freeze, baseline commit, frozen milestones.
- **Checks run**: commands and evidence.
- **Requirement coverage**: `REQ`/`NFR` -> implemented / missing.
- **Acceptance criteria**: criterion -> pass / fail -> evidence.
- **Test results**: suite result, counts, coverage gaps.
- **Findings**: severity | finding | evidence | location | recommendation.
- **Severity counts**: blocker / high / medium / low.
- **Verdict**: pass / findings reported.
- **Audit record**: `AUD` ID, type `quality`, status `issued`.
- **Next action**: user fix-or-own decision.

## Completion checks

- The freeze and baseline were confirmed.
- The checks covered the whole frozen codebase.
- Every requirement and milestone acceptance criterion has a result with evidence.
- Every finding has severity, evidence, location, and recommendation.
- The `AUD` record exists, references the release, and is `issued`.
- No fix, task creation, approval, or release action was performed.
