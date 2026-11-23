---
name: release-management
description: 'Inspect and close one release: confirm the passed release audit, obtain the scope-and-findings approval, choose the final version, run the final build, have the *-dev agents build the final packages, assemble the release report, obtain release approval, deploy through ops, and record completion. Implements Phase 6 of the orchestrator workflow.'
argument-hint: 'Provide a release ID or version (e.g. REL-001 or Release 1.2.0).'
user-invocable: true
disable-model-invocation: false
---

# Release Management

## Outcome

One release is approved, versioned, built, packaged, reported, deployed, and marked complete. Every frozen milestone is verified; the Phase 5 release audit passed and every finding is fixed or owned; the user approved the scope and findings and then the release; the final build and tests passed; the `*-dev` agents built the final packages under the final version; `ops` deployed successfully or the user waived deployment; the release report exists; the `REL` record has the final version and a completion note.

## When to use

- The release audit passed and every frozen milestone is complete and verified.
- The user asks to release, close the release, ship a version, or run the release checklist.

Do not use this skill to verify a milestone, fix a milestone, plan the release scope, or run the Phase 5 release audit.

## Prerequisites

- Load `managed-records`, `manage-audits`, `manage-release-reports`, `next-version`, and `packaging`.
- Read access to the repository, build files, tests, package evidence, the release-audit report, and the three Audit records.
- Available subagents: `*-dev` agents to build their packages and fix work, `ops` to deploy, `task-refiner` for fix refinement, and `quality-gatekeeper` to rerun the release audit.

## Release model

- A release is a managed release record, open until completed. Planning creates it with a working title such as `Release (pending version)`; Phase 6 renames it to `Release <version>` when the final version is chosen.
- Milestones are assigned to a release through the planning step; the release scope is derived from them.
- The final version is chosen after the scope-and-findings approval and immediately before the final build.
- There are no RC versions and no milestone packages. The final package is built in this phase.
- The release has no acceptance criteria of its own; project-wide criteria apply.
- The release report is created and updated via `manage-release-reports`.

## Procedure

### 1. Resolve the release scope

1. Use the release ID or version named by the user.
2. Otherwise read the release list (manage-releases) and use the first release without the `released` label.
3. If several releases are plausible, ask the user and stop.
4. Read the release and milestone lists (manage-releases, manage-milestones); select milestones whose release equals the release ID.
5. If no release or no assigned milestone exists, run `/plan` or report the gap.

### 2. Confirm the freeze and milestones

For every milestone in scope:

- the feature freeze is recorded with the frozen scope;
- the refinement and development tasks are `Done`;
- the milestone verification task is `Done`;
- no correction task or fix task in the milestone is open.

If any check fails, stop; the release is not inspected until every milestone is verified.

### 3. Confirm the release audit

Phase 5 is owned by `quality-gatekeeper`, which runs `release-audit` over the whole frozen codebase and records one Audit record per type (`quality`, `code`, `security`), each status `issued`.

Confirm from the gatekeeper's report and the Audit records:

- the quality, code, and security audits all ran over the whole frozen codebase;
- the three `AUD` records exist, reference the release, and are `issued`;
- the release-audit verdict passed, or every finding has a user decision;
- every finding chosen for fix is resolved and the release audit was rerun;
- every owned finding has an owner and a follow-up.

If the release audit is missing, an Audit record is missing, the audit did not pass, or a finding has no decision, return to Phase 5.

### 4. Present scope and findings for approval

Print the release scope, the audit summaries with their `AUD` IDs, every finding with severity and decision/owner, and the recommendation. Ask a short question: approve the scope and the findings, or reject a finding.

- Approve all findings: continue to step 5.
- Reject a finding or the scope: step 6, fix milestone. No final build runs.
- A finding neither owned nor fixed: the release cannot complete.

### 5. Choose the final version

Load `next-version` in release mode: derive the final version from all included changes. Record the version on the release (manage-releases), replacing the working title. No build runs on an unversioned release.

### 6. Fix work

When the user rejects a finding or the scope, or the final build, packaging, or deployment fails:

1. Create the fix milestone with its refinement, development, and verification tasks, and attach it to the release. The audit or review that reported each finding defines the fix task's content.
2. The fix milestone contains only the fix work needed for the release to be releasable; no new features, no scope expansion.
3. Phase 4 executes it and `quality-gatekeeper` reruns the release audit over the whole codebase.
4. Rerun the release inspection, the scope-and-findings approval, the final build, the packages, and the deployment after the release audit passes.
5. The release cannot complete while a fix task is open or the fix milestone is unfinished.

### 7. Final build and tests

Run after the scope-and-findings approval and after the version is recorded:

- the full build and test suite for every application in scope;
- the project's end-to-end or integration suite when present;
- regression checks for the release change set.

Record command, result, and counts. A failure creates fix work and returns to step 6; the release is not completed.

### 8. Build the final packages

After the tests pass, dispatch each `*-dev` agent with the release ID, the final version, and the `packaging` skill:

- each agent builds its own component with `<component-dir>/scripts/build-package.sh` under the final version;
- the package lives under the git-ignored `builds/<version>/`;
- each agent reports the archive path, size, checksum, and commit SHA.

Then load `packaging` in verification mode to check the component archives, assemble `MANIFEST.txt` and the per-archive `.sha256` files, and record the package evidence. A missing build script or failed build creates fix work and returns to step 6; nothing is published. The user may waive packaging; record the waiver in the release report with its scope, reason, and timestamp (with timezone).

### 9. Assemble the release report

Create the report via `manage-release-reports` with status `draft`, containing:

- version, release scope, and owned milestones;
- implemented requests;
- change log;
- completed tasks and their requirement traceability;
- final test results;
- package evidence: final version, commit SHA, component archives, paths, sizes, and sha256, or the recorded packaging waiver;
- the release-audit results, `AUD` IDs, finding decisions, and severity counts by type;
- owned risks with owners and follow-ups;
- fix milestones and their fix tasks, if any;
- findings, exclusions, and open questions;
- the recommendation: ready for approval or not.

Set status `issued` when the report is presented for release approval.

### 10. Release approval, deployment, and completion

Print the full release report and ask a short approval question. Do not embed the report in the question.

- Withheld or changes requested: return the work to the fix milestone; nothing is deployed.
- Approved: dispatch `ops` with the release ID, the final version, the commit SHA, and the package evidence. `ops` deploys to the release target(s) and returns deployment evidence.
- On successful deployment, add the deployment evidence to the release report, record completion (manage-releases) with the `released` label and a completion note, and report the released version, targets, accepted risks, and follow-ups.
- On a failed deployment, create fix work and do not complete the release.

The user may waive deployment; a waiver is explicit, user-only, and recorded in the release report with its scope, reason, and timestamp (with timezone).

## Rules

- The release starts only from a passed release audit and complete, verified milestones.
- The release-audit findings and decisions are already made in Phase 5; Phase 6 presents and confirms them, it does not rerun the release audit.
- The final build runs only after the scope and findings are approved and the version is recorded.
- Packaging is built from the committed release tree; the commit SHA is recorded. Never use ad-hoc build commands.
- A version directory is immutable; a changed release needs the version decision revisited, never an overwrite.
- Package publication is local under the git-ignored `builds/<version>/`; nothing is staged, committed, tagged, pushed, or uploaded.
- Deployment belongs to `ops`. The orchestrator never deploys.
- Do not approve on the user's behalf and do not complete the release while a fix task is open, the fix milestone is unfinished, or the deployment failed without a waiver.
- Use only project-local `./.tmp/` for scratch work and remove it before finishing.

## Failure handling

| Outcome | Action |
|---|---|
| A frozen milestone is incomplete or unverified | Return to Phase 4; no release inspection. |
| The release audit or an Audit record is missing or did not pass, or a finding has no decision | Return to Phase 5. |
| Scope or findings not approved | Fix milestone; Phase 4 and Phase 5 run; the gate reruns. |
| Final build or tests fail | Fix milestone; Phase 4 and Phase 5 run; the gate and build rerun. |
| A deployable component has no build script | Fix task in the fix milestone for the owning `*-dev` agent; packaging resumes after verification. |
| Final package build fails | Fix task in the fix milestone; nothing is deployed; the release is not completed. |
| Final package directory exists or is not git-ignored | Stop; the user decides the version and the ignore rules; a version is never overwritten. |
| Deployment fails | Fix task in the fix milestone; the release is not completed and deployment is retried after the fix. |
| Release approval withheld | Return the work to the fix milestone; report the reason. |
| Scope creep found | The user decides removal or a requirements change through Phase 2. |

## Stop conditions

- A milestone in scope is incomplete or unverified: stop; no inspection.
- The release audit did not pass or a finding is undecided: stop; return to Phase 5.
- The user does not approve the scope or findings: create fix work; no final build.
- Final build or tests fail: create fix work; the release is not completed.
- The final package fails to build: create fix work; nothing is deployed and the release is not completed.
- Deployment fails: create fix work; the release is not completed.
- Missing evidence for a project-wide criterion: stop; the owning milestone supplies it.
- Release approval withheld: stop and report.

## Report format

- **Release**: `REL` ID, version, scope, milestones.
- **Milestones**: verification result per milestone.
- **Release audit**: `AUD` IDs, quality/code/security verdicts, severity counts, and finding decisions.
- **Findings**: fixed / owned, owner and follow-up.
- **Final build/tests**: commands, results, counts.
- **Final packages**: directory, component archives, sizes, sha256, commit SHA; or the recorded waiver.
- **Deployment**: targets, result, timestamp with timezone; or the recorded waiver.
- **Release report**: path and status.
- **Approvals**: scope/findings and release.
- **Completion**: `released` label, version, note.
- **Next action**: or `none`.

## Completion checks

- Every release milestone is complete and verified.
- The release audit passed and the three Audit records are `issued` and every finding is fixed or owned.
- The user approved the scope and audit findings.
- The final version is chosen and recorded on the release.
- The final build and tests ran after the approval and passed.
- Each `*-dev` agent built its component's package under the final version, and the package evidence is recorded, or the user waived packaging and the waiver is recorded.
- `ops` deployed the final version and the deployment evidence is recorded, or the user waived deployment and the waiver is recorded.
- Every fix task is `Done` and the fix milestone is verified.
- Owned risks and follow-ups have owners.
- The release report is complete and issued.
- The user approved the release and the `REL` record is marked `released`.

## Resume / interruption

Release state is derived from the `REL` record, its milestones, their verification tasks, the release-audit report and its Audit records, the packages, the deployment, and the release report.

On re-invocation, re-read all of them, skip completed steps, and rerun any check whose evidence is stale. If the release already has the `released` label, report it instead of recording completion again. An existing `builds/<version>/` is never overwritten; a rebuilt release needs a new final version.
