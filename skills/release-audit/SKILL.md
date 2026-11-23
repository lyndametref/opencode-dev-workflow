---
name: release-audit
description: 'Run the Phase 5 release audit over the whole frozen codebase by quality-gatekeeper: run the quality, code, and security audit skills, record one Audit record per audit, and report severity-ranked findings for the user fix-or-own decision.'
argument-hint: 'Provide the release ID, the feature freeze, and the baseline commit; the whole frozen codebase is always in scope.'
user-invocable: true
disable-model-invocation: false
---

# Release Audit

## Outcome

One release-audit report for the whole frozen codebase plus three Audit records: one of type `quality`, one of type `code`, and one of type `security`, each with status `issued`. The user decides for every finding whether it is fixed or owned. No approval status is set.

## When to use

- Phase 5, after the user declares the feature freeze.
- The frozen milestone scope and baseline commit are recorded.
- A fix milestone completed after a finding was chosen for fix.

Do not use this skill for a milestone. The milestone's standalone code audit belongs to Phase 4 milestone verification and creates no audit record.

## Prerequisites

- Load `managed-records`, `manage-audits`, and read the release, its frozen milestones, tasks, and evidence through their `manage-*` skills.
- The feature freeze is recorded, every frozen milestone's verification task is `Done`, and the baseline commit is known.
- Available subagents: none. `quality-gatekeeper` runs this skill directly.
- Load the audit skills as needed: `quality-audit`, `code-audit`, `security-audit`.

## Scope

The whole frozen codebase and test suite, at the baseline commit. There is no partial or milestone-scoped release audit.

## Procedure

1. **Confirm the freeze and baseline** — read the release, its frozen milestone scope, and the baseline commit. Confirm every frozen milestone's verification task is `Done`. Stop if the freeze is missing or a milestone is incomplete.
2. **Run and record the quality audit** — load `quality-audit` and audit the whole frozen codebase. Create an Audit record via `manage-audits`, type `quality`, reference the release, content = the audit report, then set status `issued`. Keep the `AUD` ID.
3. **Run and record the code audit** — load `code-audit` and audit the whole frozen codebase and test suite. Create an Audit record type `code`, reference the release, content = the report, status `issued`. This is the release-wide code audit; the standalone code audit at the end of a milestone is a separate Phase 4 check.
4. **Run and record the security audit** — load `security-audit` and audit the whole frozen codebase. Create an Audit record type `security`, reference the release, content = the report, status `issued`.
5. **Combine the findings** — group findings by audit type (`quality`, `code`, `security`), keep evidence and location, and remove duplicates only when they are the same defect with the same evidence. Count severities.
6. **Decide the release-audit verdict** — `pass` when no finding requires action; otherwise `findings reported`. Any unresolved `blocker` or `high` finding prevents a pass.
7. **Report** — scope, freeze, baseline, the three `AUD` IDs, per-audit results, combined findings, severity counts, verdict, and recommendation per finding.
8. **Stop** — the user decides `fix` or `own` for every finding. Do not approve, close, or fix.

## Rules

- The release audit is whole-codebase and read-only. It never fixes what it finds.
- Exactly three Audit records are created per release audit: `quality`, `code`, and `security`, each status `issued`.
- No approval status is set. The user's fix-or-own decisions are recorded by the orchestrator; the Audit records stay the evidence.
- A rerun after a fix issues new Audit records and archives the previous ones of the same type.
- Each of the three audit skills keeps its own checks and severity scale; this skill combines their results without weakening them.
- A finding the user chooses to fix becomes a fix milestone executed in Phase 4; after it passes, rerun this release audit.
- A finding the user chooses to own is documented with an owner and a follow-up; it is reported in the release report.
- Do not audit a single milestone, sample the codebase, or replace the standalone milestone code audit.
- Do not approve, version, package, deploy, or close the release.
- Use only project-local `./.tmp/` for transient output and remove it before finishing.

## Stop conditions

- No recorded feature freeze: stop; the release audit does not run.
- A frozen milestone is incomplete or its verification task is not `Done`: return to Phase 4.
- An audit skill cannot run or lacks evidence: stop and report; do not accept reported evidence.
- A finding has no evidence: stop; a finding is never carried without evidence.
- A requirement gap is discovered rather than an implementation defect: report it; the user decides whether to lift the freeze and route it through Phase 2.

## Report format

- **Scope**: release ID, feature freeze, baseline commit, frozen milestones.
- **Quality audit**: `AUD` ID, verdict, and check results.
- **Code audit**: `AUD` ID, verdict, and check results.
- **Security audit**: `AUD` ID, verdict, and check results.
- **Findings**: severity | type | finding | evidence | location | recommendation.
- **Severity counts**: blocker / high / medium / low.
- **Verdict**: pass / findings reported.
- **Finding decisions**: pending / fix / own.
- **Next action**: the user's fix-or-own decision.

## Completion checks

- The freeze, baseline, and frozen milestone scope were confirmed.
- The quality, code, and security audits all covered the whole frozen codebase.
- One `AUD` record per type exists, references the release, and is `issued`.
- Findings are combined without losing evidence or location.
- Every finding has severity and evidence.
- The verdict follows the severity rule.
- No approval status, fix, task, or release action was created.
