---
name: release-management
description: 'Inspect and close one release: verify milestones, run the release quality, code, and security audits, obtain the scope-and-findings and release approvals, choose the final version, run the final build, assemble the release report, and record completion. Implements Phase 6 of the orchestrator workflow.'
argument-hint: 'Provide a release ID or version (e.g. REL-001 or Release 1.2.0).'
user-invocable: true
disable-model-invocation: false
---

# Release Management

## Outcome

One release is inspected, audited, approved, versioned, built, reported, and marked complete. Every milestone is complete and verified; the release quality, code, and security audits are recorded; the user approved the scope and findings and then the release; the final build and tests passed; the release report exists; the `REL` record has the final version and a completion note.

## When to use

- All milestones of a release are complete and verified.
- The user asks to release, close the release, ship a version, or run the release checklist.

Do not use this skill to verify a milestone again, fix a milestone, plan the release scope, or audit security outside a release.

## Prerequisites

- Load `managed-records`, `manage-release-reports`, and `next-version`.
- Read access to the repository, build files, tests, and release evidence.
- Available subagents: `quality-gatekeeper`, `code-analyzer`, `security-officer`, `planner`, and the owning `*-dev` agents for fixes.

## Release model

- A release is a managed release record, open until completed. Planner creates it with a working title such as `Release (pending version)`; Phase 6 renames it to `Release <version>` when the final version is chosen.
- Milestones are assigned to a release through the manage-milestones skill; the release scope is derived from them.
- The final version is chosen after the scope-and-findings approval and immediately before the final build.
- The release has no acceptance criteria of its own; project-wide criteria apply.
- The release report is created and updated via `manage-release-reports`.

## Procedure

### 1. Resolve the release scope

1. Use the release ID or version named by the user.
2. Otherwise read the release list (manage-releases) and use the first release without the `released` label.
3. If several releases are plausible, ask the user and stop.
4. Read the release and milestone lists (manage-releases, manage-milestones); select milestones whose release equals the release ID.
5. If no release or no assigned milestone exists, report the gap and hand off to `planner`.

### 2. Verify milestones

For every milestone in scope:

- every execution task is `Done`;
- the milestone verification task is `Done`;
- the Phase 5 quality and code audits are `issued` or `approved`;
- no correction task or fix task in the milestone is open.

If any check fails, stop; the release is not inspected until the milestone is complete and verified. Return the work to Phase 4/5.

### 3. Run the release audits

Run the three audits over the whole release. No milestone is taken on trust.

| Audit | Owner | Scope | Output |
|---|---|---|---|
| Release quality audit | `quality-gatekeeper` | Milestones complete/verified, whole change set, consistency across milestones, integration, scope creep, NFR coverage | `AUD` type `quality` |
| Release code audit | `code-analyzer` | Whole codebase and test suite, including code unchanged in this release | `AUD` type `code` |
| Security audit | `security-officer` | Whole release, cross-feature risks, risks created by combining features | Report; orchestrator records `AUD` type `security` |

For each audit, require the structured report with severity-ranked findings and an owner or required fix. The security officer reports; the orchestrator records the security audit (manage-audits).

### 4. Present scope and findings for approval

Print the release scope, the audit summaries, every finding with severity and owner, and the recommendation. Ask a short question: approve the scope and the findings, or reject a finding.

- Approve all findings: continue to step 5.
- Reject a finding or the scope: step 6, fix milestone. No final build runs.
- Security finding neither accepted nor fixed: the release cannot complete.

Accepted findings are documented in the audit of their type with an owner and a follow-up task. Add the `approved` label to each accepted audit (manage-audits); only one audit of a type may be `issued` or `approved` in the release scope at a time.

### 5. Choose the final version

Load `next-version` in release mode: derive the final version from all included changes and the RC versions of the verified milestones. Record the version on the release (manage-releases), replacing the working title. No build runs on an unversioned release.

### 6. Fix work

When an audit fails, the user rejects a finding or the scope, or the final tests fail:

1. Ask `planner` to create the fix tasks in the release's fix milestone, creating the milestone if it does not exist. The auditor who reported each finding defines the fix task's content.
2. The fix milestone contains only the fix work needed for the release to be releasable; no new features, no scope expansion.
3. Phase 4 executes it and Phase 5 verifies it like any milestone.
4. Rerun the release inspection and the scope-and-findings approval after the fix milestone is verified.
5. The release cannot complete while a fix task is open or the fix milestone is unfinished.

### 7. Final build and tests

Run after the scope-and-findings approval and after the version is recorded:

- the full build and test suite for every application in scope;
- the project's end-to-end or integration suite when present;
- regression checks for the release change set.

Record command, result, and counts. A failure creates fix work and returns to step 6; the release is not completed.

### 8. Assemble the release report

Create the report via `manage-release-reports` with status `draft`, containing:

- version, release scope, and owned milestones;
- implemented requests;
- change log;
- completed tasks and their requirement traceability;
- final test results;
- per-milestone verification, and audit severity counts by type;
- accepted risks with owners and follow-ups;
- fix milestone and its fix tasks, if any;
- findings, exclusions, and open questions;
- the recommendation: ready for approval or not.

Set status `issued` when the report is presented for release approval.

### 9. Release approval and completion

Print the full release report and ask a short approval question. Do not embed the report in the question.

- Withheld or changes requested: return the work to the owning milestones or the fix milestone; nothing is recorded as released.
- Approved: set the report status `issued`, record completion (manage-releases) with the `released` label and a completion note, and report the released version, milestones, accepted risks, and follow-ups.

Do not tag or push unless the user explicitly asks.

## Failure handling

| Outcome | Action |
|---|---|
| A milestone is incomplete or unverified | Return to Phase 4/5; no release inspection. |
| A release audit fails | Fix tasks in the fix milestone; execute, verify, rerun the inspection. |
| Security finding not accepted | Fix tasks in the fix milestone; the release cannot complete while it remains. |
| Security finding accepted | Document it with an owner and follow-up; the release proceeds. |
| Scope or findings not approved | Fix tasks in the fix milestone; no final build. |
| Final build or tests fail | Fix tasks in the fix milestone; rerun inspection, approval, and build after verification. |
| Release approval withheld | Return the work to the owning milestones or fix milestone; report the reason. |
| Scope creep found | The user decides removal or a requirements change through Phase 2. |

## Boundaries

This skill never:

- fixes, reworks, or re-verifies a single milestone;
- changes requirements, criteria, scope, or the plan;
- approves on the user's behalf;
- records completion while a fix task is open or the fix milestone is unfinished;
- records completion without a full release inspection and explicit approval;
- runs the final build before the scope and findings are approved;
- publishes, tags, or deploys unless the user explicitly asks.

## Stop conditions

- A milestone in scope is incomplete or unverified: stop; no inspection.
- A release audit fails: create fix work; no final build.
- The user does not approve the scope or findings: create fix work; no final build.
- Final build or tests fail: create fix work; the release is not completed.
- A security finding is neither accepted nor fixed: the release cannot complete.
- Missing evidence for a project-wide criterion: stop; the owning milestone supplies it.
- Release approval withheld: stop and report.

## Report format

- **Release**: `REL` ID, version, scope, milestones.
- **Milestones**: verification result per milestone.
- **Audits**: quality, code, security `AUD` IDs, verdicts, severity counts.
- **Findings accepted/rejected**: owner and follow-up.
- **Final build/tests**: commands, results, counts.
- **Release report**: path and status.
- **Approvals**: scope/findings and release.
- **Completion**: `released` label, version, note.
- **Next action**: or `none`.

## Completion checks

- Every release milestone is complete and verified.
- The whole release passed the quality, code, and security audits.
- The user approved the scope and audit findings.
- The final version is chosen and recorded on the release.
- The final build and tests ran after the approval and passed.
- Every security finding is accepted and documented, or fixed with the fix milestone finished.
- Every fix task is `Done` and the fix milestone is verified.
- Accepted risks and follow-ups have owners.
- The release report is complete and issued.
- The user approved the release and the `REL` record is marked `released`.

## Resume / interruption

Release state is derived from the `REL` record, its milestones, their verification tasks, the audits, and the release report.

On re-invocation, re-read all of them, skip completed steps, and rerun any check whose evidence is stale. If the release already has the `released` label, report it instead of recording completion again.
