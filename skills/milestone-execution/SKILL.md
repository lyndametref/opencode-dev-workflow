---
name: milestone-execution
description: 'Execute the planned tasks of one milestone in ordinal order: select tasks, dispatch them to their assigned actors, enforce artifact verification, record fulfilment proof, and stop at the milestone boundary. Implements Phase 4 of the orchestrator workflow.'
argument-hint: 'Provide a milestone ID, or ask to continue execution until a stop boundary.'
user-invocable: true
disable-model-invocation: false
---

# Milestone Execution

## Outcome

One milestone's execution tasks are delivered in ordinal order: architecture impact assessment, optional UI design, test design, refinement, and implementation. Every task is `Done` or explicitly reported as in progress with its blocker. Execution stops at the milestone boundary; the milestone is then handed to Phase 5 verification.

## When to use

- The user asks to execute a milestone, continue development, or reach a stop boundary.
- A release needs remaining milestone work completed before Phase 5/6.

Do not use this skill to plan, reorder, refine scope, verify a milestone, or release.

## Inputs and preconditions

- A prioritized backlog from Phase 3: milestones, tasks, assigned actors, dependencies, ordinals.
- A stop boundary: the last task to complete automatically, or the user can request a stop at any time.
- Task statuses: `To Do`, `In-Progress`, `Done`; `archived` when cleaned up.
- A missing plan, an unassigned task, or an unordered backlog returns to Phase 3.

## Papyrus status mapping

Papyrus has fixed statuses; the workflow uses `To Do`, `In-Progress`, and `Done`. Map them as follows:

| Workflow | Papyrus |
|---|---|
| `To Do` | `ToDo` |
| `In-Progress`, work started | `Initiated` |
| `In-Progress`, refinement complete | `Refined` |
| `In-Progress`, implementation complete | `Implemented` |
| `In-Progress`, acceptance check complete | `Validated` |
| `Done` | `Done` |
| cleaned up | `archived` |

The intermediate status records the stage; the workflow treats every status between `ToDo` and `Done` as `In-Progress`. `Done` means every acceptance criterion is fulfilled and, when the task's artifact requires it, the user's verification is obtained. No other end-of-task approval is requested.

## Actors

| Actor | Role |
|---|---|
| `orchestrator` | Drives execution, selects tasks, sets statuses, prepares the repository, records fulfilment proof, reports. Never edits project content. |
| `architect` | Architecture impact assessment; Technical specification conformance. |
| `ui-designer` | UI design and mockup. |
| `test-manager` | Test design. |
| `task-refiner` | Refinement. |
| `android-dev`, `backend-dev`, `frontend-dev`, `rust-dev` | Implementation. |
| `quality-gatekeeper` | Phase 5 verification only; not selected in Phase 4. |
| `planner` | Plan repairs, priority changes, correction/fix tasks. Never executes. |
| User | Priority, stop boundary, and verification of artifacts that require it. |

## Procedure

### 1. Resolve the milestone

1. Use the milestone named by the user.
2. Otherwise read the milestone list (manage-milestones) and take the first milestone with unfinished execution tasks.
3. If no milestone exists, report it and hand off to `planner`.

### 2. Read state

Read the milestone and task lists (manage-milestones, manage-tasks) and the milestone acceptance criteria. Select only tasks whose milestone equals the target milestone and whose type is an execution kind. The milestone verification task is not selected in Phase 4.

Record total, `Done`, in-progress, and remaining executable counts.

### 3. Select the next task

1. Resume the lowest-ordinal in-progress task first.
2. Otherwise take the lowest-ordinal `ToDo` task whose dependencies are all `Done`.
3. Never ask the user to choose among eligible tasks; ordinal is the priority.
4. Never take a task from another milestone.

If no eligible task exists:

- no `ToDo` or in-progress execution task remains: the milestone's execution tasks are complete; stop at the milestone boundary;
- otherwise the milestone is blocked: report the blockers and stop.

### 3b. Resume by status

- `ToDo`: start at step 4.
- `Initiated`: resume at the next uncompleted task kind.
- `Refined`: skip refinement; continue with implementation or the acceptance check.
- `Implemented`: skip implementation; run the acceptance check.
- `Validated`: skip the checks; complete any required artifact verification and set `Done`.
- `Done`: skip the task.

Never move a status backward. Check the current status before dispatching and skip stages already completed.

### 4. Prepare the repository (once per task branch)

Inspect the working tree before task work.

- If already on `task/<TASK-ID>` or that branch exists, reuse it.
- If uncommitted changes exist, show them and ask whether to clean up or continue. Never commit, stash, discard, or alter them without the user's decision.
- If the user chooses cleanup, wait for confirmation, re-check that the tree is clean, check out the main branch, pull, and create `task/<TASK-ID>` only if it does not exist.
- If Git is denied or fails, stop and ask the user to prepare the branch and tree; never bypass the policy.

### 5. Dispatch the task by kind

Set the task to `Initiated` when work starts. Dispatch with the `subagent` tool to the actor assigned by the planner.

| Task kind (`--type`) | Actor | Skill |
|---|---|---|
| `architecture` | `architect` | `architecture-impact-assessment` |
| `ui-design` | `ui-designer` | `ui-design` |
| `test-design` | `test-manager` | `test-design` |
| `refinement` | `task-refiner` | `task-refinement` |
| `implementation` | `android-dev`, `backend-dev`, `frontend-dev`, or `rust-dev` | `implementation` plus the stack skills |
| `milestone-verification` | `quality-gatekeeper` | not Phase 4; Phase 5 |

Pass the task ID, the milestone acceptance criteria, the linked requirements/specifications, and the expected output. Wait for the actor's report.

Record the task's fulfilment proof as a comment (manage-tasks).

### 6. Check acceptance and artifact verification

The order is fixed: acceptance criteria first, then the required artifact verification.

| Task or artifact | Required user verification | Before |
|---|---|---|
| Architecture impact assessment | Architecture verified by the user; architecture decisions accepted | Dependent design and implementation |
| UI design | Mockup explicitly verified by the user | Implementing the affected UI |
| Test design | Test cases verified by the user | Refinement and implementation |
| Technical specification | Conformance with the architecture and decisions verified by the architect | Refinement |
| Any other task | None beyond its own acceptance criteria | — |

When a verification is required, ask the user to verify the artifact. A pending response holds the task at the ask step. A denial is recorded with its reason; the task stays in progress and returns to rework with the user's feedback; the ask step runs again after rework.

Set the status to `Refined` after refinement, `Implemented` after implementation, and `Validated` after the acceptance check. Tasks with no refinement or implementation stage stay `Initiated` until `Done`; the intermediate statuses record a stage, not a required sequence. Set `Done` only when the acceptance criteria are fulfilled and the required verification is obtained.

After a task is `Done`, merge its `task/<TASK-ID>` branch into the main branch with `--no-ff`: stage and commit any remaining changes first, run `git merge --no-ff task/<TASK-ID>`, and leave the repository on the main branch. Do not push. If the merge fails, stop and report.

### 7. Task outcome and rework

- Acceptance criteria not met: the task stays in progress and work continues. There is no intermediate failure status.
- Missing decision, dependency, or information: stop execution and report. Do not invent the missing input.
- A defect found in the implementation reopens the task and returns it to rework; it does not create unplanned work.
- A denied verification returns the task to rework with the user's feedback; it does not create unplanned work.
- New scope discovered during implementation stops execution and returns to Phase 2 or 3; it is never absorbed silently.
- A correction task created by a Phase 5 reviewer is delivered within the milestone's approved scope; the reviewer defines its content and the planner creates it.

### 8. Stop boundary and milestone boundary

- The user may state, before or during execution, the last task to complete automatically.
- Execution stops after that task is `Done`; the next task is not started.
- Every milestone end is a stop point: execution stops when the last execution task is `Done`, regardless of the boundary.
- On a stop request, finish the current task: if its acceptance criteria are met it becomes `Done`; otherwise it stays in progress and the state is reported.
- The boundary is recorded in the session, not in the backlog.
- Without a boundary, execution continues until the backlog ends, a blocker appears, or a pending verification holds the task.

### 9. Report and hand off

Report:

- milestone ID, title, goal, and completion ratio;
- tasks completed in this run, in order, with fulfillment proof;
- tasks remaining, blocked, or waiting for verification;
- release assignment;
- stop reason and the next action.

When the milestone's execution tasks are complete, hand the milestone to Phase 5 verification: `quality-gatekeeper` runs the quality review and `code-analyzer` runs the code audit on the milestone verification task.

## Priority and re-planning

- Execution order comes from the planned ordinals; the orchestrator never reorders.
- A user priority change recalls Phase 3; execution resumes from the new order once the plan is revalidated.
- Work already `Done` or in progress keeps its place.
- A plan defect (missing dependency, wrong order, missing scope) stops execution and returns to `planner`.

## Exit criteria

Phase 4 is complete when:

- the stop boundary is reached, the milestone's execution tasks complete, the user stops execution, or the backlog is exhausted;
- every executed task is `Done` or explicitly reported as in progress with its blocker;
- every milestone whose execution tasks are `Done` is reported as ready for Phase 5 verification;
- the report states tasks completed in order, fulfilment proof, milestone boundaries reached, remaining work, and the reason execution stopped.

## Boundaries

This skill never:

- refines scope, writes requirements, or reorders tasks;
- changes priority, dependencies, ordinals, or milestone scope;
- starts a task whose dependencies are not `Done`;
- marks a task `Done` with an unmet acceptance criterion or a missing required verification;
- asks for end-of-task approval beyond the defined artifact verifications;
- skips a verification-required artifact;
- absorbs new scope discovered during execution;
- verifies a milestone or runs a release audit.

## Stop conditions

- Dependency not `Done` or a task unassigned: report and stop.
- A required artifact verification is denied: record the denial, keep the task in progress, rework, and ask again; dependent work does not start.
- Acceptance criteria cannot be met with the current information: stop and return to Phase 2 or 3.
- Milestone verification fails and rework does not resolve it: stop and report.
- Priority or scope conflict: stop and return to Phase 3.
- User requests a stop: finish the current task, then stop.

## Completion checks

- Only tasks assigned to the target milestone were executed.
- Interpretation of ordinals, dependencies, and readiness used Papyrus JSON, not guessed fields.
- Every executed task followed its kind's skill and produced evidence recorded on the task.
- Every required artifact verification was obtained before dependent work.
- No task was skipped silently, no task was pulled from another milestone, and no task was marked `Done` without its criteria and verification.
- The milestone boundary was reported, not approved.
