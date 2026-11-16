---
name: release-orchestration
description: 'Close a release: verify all release tasks are Done, run release-level build and test checks, delegate the mandatory end-of-release security audit to security-officer, compile the release report, and record completion only after explicit user approval.'
argument-hint: 'Optionally provide the release ID or version (e.g. "REL-001" or "Release 1.0"). If omitted, use the active release record.'
user-invocable: true
disable-model-invocation: false
---

# Release Orchestration

## Outcome

One release is verified and closed. Every included task is `Done`, release-level checks pass, the `security-officer` audit is complete, the release report is presented, and the release is recorded complete only after explicit user approval. A security `Block` decision stops the release.

## When To Use

- The user asks to "release", "close the release", "ship version X", or "run the release checklist".
- All tasks of the release milestones are expected to be Done and the release must be gated.

Do not use this skill for:

- Planning the release scope or milestones (use `planner`).
- Delivering remaining milestone work (use `milestone-orchestration`).
- Auditing security outside a release (use the `security-officer` agent with `security-audit`).

## Release Model

A release is a Papyrus `REL` record:

- `title`: `Release <version>` (for example `Release 1.0`);
- `description`: release scope and acceptance criteria;
- `labels`: includes `released` only after completion;
- milestones: assigned with `papyrus milestone edit <MS-ID> --release <REL-ID>`;
- tasks: all tasks whose `metadata.milestone` is one of the assigned milestones.

There is no release ticket. The `planner` subagent creates the release record and assigns milestones when the orchestrator delegates it. If the project uses a different convention, the user must state the release scope explicitly before orchestration starts. Do not invent a release structure.

## Prerequisites

- **papyrus skill (REQUIRED)** — Load it before any Papyrus read or write.
- **security-audit** is loaded by `security-officer`, not by this skill.
- Available subagents: `security-officer`; `quality-gatekeeper` for release verification; `architect` for architecture readiness; development agents for fixes.

## Procedure

1. **Resolve the release scope.**
   - Use the release ID or version named by the user.
   - Otherwise read `papyrus --json release list` and use the first release without the `released` label.
   - If several releases are plausible, ask the user and stop.
   - Read `papyrus release view <REL-ID>` and extract the release acceptance criteria from the description.
   - Read `papyrus --json milestone list` and select milestones whose `metadata.release` equals the release ID.
   - If no release or no assigned milestone exists, report the gap and hand off to `planner`; do not create one yourself.

2. **Verify completion.**
   - Read `papyrus --json task list` and select tasks whose `metadata.milestone` is in the release milestone set.
   - Confirm every implementation task is `Done`.
   - If any task is not `Done`, report the remaining work and offer `milestone-orchestration`; stop the release until the user decides.
   - Confirm no task from an unassigned milestone is counted as release scope.

3. **Run release-level checks.**
   - Identify the applications in scope (`apps/android/`, `apps/backend/`, `apps/webFrontend/`, `apps/rust/`).
   - Run the full build and test commands available for each stack.
   - Run the project's end-to-end or integration suite when present.
   - Record command, result, and counts.
   - If checks fail, stop and route each failure to the owning development agent through a task; do not declare the release complete.

3b. **Architecture readiness.** Before the security audit, delegate to `@architect` to verify that every decision record for the release scope is `Accepted` and that NFR architecture constraints are satisfied. Read `papyrus --json decision list` and `papyrus decision view <ADR-ID>`. Require a short report. If a decision is missing/Superseded or a constraint is unmet, stop and route the work before the security audit.

4. **Run the mandatory security audit.**
   - Delegate to `security-officer` with the release ID, its milestones, included tasks, and the application scope.
   - Require the full `security-audit` report: severity-ranked findings, severity counts, NFR coverage, secrets and dependency results, and the release recommendation.
   - `Block` → stop the release, report Critical/High findings, and route remediation to the owning agents and `planner` for follow-up tickets.
   - `Pass with findings` → continue only when no unresolved Critical or High finding remains; record Medium/Low findings with owners.
   - `Pass` → continue.
   - Do not accept a verbal summary without the structured report.
   - Record the report with `papyrus audit create --title "<REL-ID> security audit" --content "<structured report>" --audit-type security --reference <REL-ID>`.

5. **Verify the release.**
   - Delegate to `quality-gatekeeper` with the release description/acceptance criteria, completion evidence, check results, and the security audit record.
   - Require a per-criterion evidence table and a decision. If the release description has no acceptance criteria, state that explicitly and verify its definition of done directly.
   - `Incomplete` → stop, report the missing evidence, and route the work back to the owning agents.
   - Verified → continue.

6. **Compile the release report.**
   - Release name, version, `REL` ID, milestone IDs, and date with timezone.
   - Included tasks (IDs and titles) and requirement coverage.
   - Build and test results.
   - Security decision, severity counts, accepted risks, follow-ups, and the `AUD` ID.
   - Known limitations and deferred work.
   - Recommended Git tag and command, without executing it.

7. **Request approval.**
   - Print the full release report and the security audit summary in the response.
   - Ask a short approval question only; do not embed the report in the question.
   - If the user requests changes, do not close the release. Return the affected work to tasks through the owning agents, then restart from step 2.
   - If the user withholds approval, stop and report.

8. **Record completion.**
   - Only after explicit approval, run `papyrus release edit <REL-ID> --label released --description "<original scope + completion note with date/timezone and approval>"`.
   - Ensure the audit record exists and references the `REL` ID.
   - Do not modify milestone or release files directly.
   - Do not create Git tags or push unless the user explicitly asks and the environment allows it.
   - Report the release and its milestones as complete.

## Stop Conditions

Stop and report when:

- a release task is not `Done`;
- a release record or assigned milestone is missing;
- build or test checks fail;
- the security audit returns `Block` or lacks required evidence;
- the release verification is incomplete or lacks evidence;
- the user requests changes or withholds approval;
- the scope is ambiguous.

## Completion Checks

- Release `REL` ID, scope, and assigned milestones confirmed.
- Every included task is `Done`.
- Release-level build and test checks ran with recorded results.
- `security-officer` audit report received with a severity-ranked findings table and decision.
- Audit report recorded as a Papyrus `AUD` record referencing the release.
- Release verified by `quality-gatekeeper`, or the absence of acceptance criteria stated explicitly.
- No unresolved Critical or High finding remains.
- Release report printed separately from the approval question.
- Release marked complete with the `released` label only after explicit user approval.
- No Git tag created or pushed without explicit user request.
- All Papyrus operations performed via the Papyrus CLI.

## Resume / interruption

Release state is derived from the release record, its assigned milestones, their tasks, and the latest audit record. On re-invocation, re-read all of them, skip completed steps, and rerun any check whose evidence is stale. Do not mark completion again if the release already has the `released` label; report it instead.

## Handoff

- Released → report completion, accepted risks, and follow-up tickets.
- Blocked by incomplete work → `milestone-orchestration` or `planner`.
- Blocked by security findings → owning development agents plus `planner` for remediation tickets; rerun the audit after fixes.
