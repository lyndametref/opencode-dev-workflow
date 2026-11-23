---
name: milestone-execution
description: 'Execute the planned tasks of one milestone in ordinal order: refinement, development, and verification, with correction tasks until verification passes. Implements Phase 4 of the orchestrator workflow.'
argument-hint: 'Provide a milestone ID, or ask to continue execution until a stop boundary.'
user-invocable: true
disable-model-invocation: false
---

# Milestone Execution

## Outcome

One milestone is delivered in ordinal order: its refinement, one or more development tasks, and its verification task. Every task is `Done` or explicitly reported as in progress with its blocker. Correction tasks created by verification run inside the same milestone. Execution stops at the milestone boundary.

## When to use

- The user asks to execute a milestone, continue development, or reach a stop boundary.
- A fix milestone must be executed after an audit finding or a release failure.

Do not use this skill to plan, reorder, refine scope, run the Phase 5 release audit, or release.

## Inputs and preconditions

- A prioritized backlog from Phase 3: milestones, tasks, assigned actors, dependencies, ordinals.
- A stop boundary: the last task to complete automatically, or the user can request a stop at any time.
- Task statuses: `To Do`, `In-Progress`, `Done`; `archived` when cleaned up.
- A missing plan, an unassigned task, or an unordered backlog returns to Phase 3.

## Task statuses

The workflow uses `To Do`, `In-Progress`, and `Done`. The tool-specific status values and their mapping live in `manage-tasks`.

`Done` means every acceptance criterion is fulfilled and, when the task's artifact requires it, the user's verification is obtained. No other end-of-task approval is requested.

## Actors

| Actor | Role |
|---|---|
| `orchestrator` | Drives execution, selects tasks, sets statuses, prepares the repository, records fulfilment proof, reports. Never edits project content. |
| `task-refiner` | Refinement: architecture impact, Technical specification, technical decisions, UI/mockups, test cases, development tasks. |
| `android-dev`, `backend-dev`, `frontend-dev`, `rust-dev` | Development tasks. |
| `quality-gatekeeper` | Milestone verification task and correction definitions. |
| User | Stop boundary, and verification of mockups and test cases. |

## Procedure

### 1. Resolve the milestone

1. Use the milestone named by the user.
2. Otherwise read the milestone list (manage-milestones) and take the first milestone with unfinished tasks.
3. If no milestone exists, run `/plan` or report the gap.

### 2. Read state

Read the milestone and task lists (manage-milestones, manage-tasks) and the milestone acceptance criteria. Select only tasks whose milestone equals the target milestone.

Record total, `Done`, in-progress, and remaining counts.

### 3. Select the next task

1. Resume the lowest-ordinal in-progress task first, except a failed verification task, which waits until its correction tasks are `Done`.
2. Otherwise take the lowest-ordinal `ToDo` task whose dependencies are all `Done`.
3. Never ask the user to choose among eligible tasks; ordinal is the priority.
4. Never take a task from another milestone.
5. Correction tasks are ordered after the verification task that created them and before its rerun.

If no eligible task exists:

- no `ToDo` or in-progress task remains: the milestone is complete; report the boundary;
- otherwise the milestone is blocked: report the blockers and stop.

### 3b. Resume by status

- `ToDo`: start at step 4.
- `Initiated`: resume at the next uncompleted task kind.
- `Refined`: skip refinement; continue with development or the acceptance check.
- `Implemented`: skip development; run the acceptance check.
- `Validated`: skip the checks; complete any required artifact verification and set `Done`.
- `Done`: skip the task.

Never move a status backward. Check the current status before dispatching and skip stages already completed.

### 4. Prepare the repository (once per task branch)

Skip this step for a `verification` task; it is read-only and works on the current tree.

Inspect the working tree before task work.

- If already on `task/<TASK-ID>` or that branch exists, reuse it.
- If uncommitted changes exist, show them and ask whether to clean up or continue. Never commit, stash, discard, or alter them without the user's decision.
- If the user chooses cleanup, wait for confirmation, re-check that the tree is clean, check out the main branch, run `git pull --ff-only` (never a pull that could create a merge), and create `task/<TASK-ID>` only if it does not exist.
- If Git is denied or fails, stop and ask the user to prepare the branch and tree; never bypass the policy.

### 5. Dispatch the task by kind

Set the task to `Initiated` when work starts. Dispatch with the `subagent` tool to the actor assigned by planning.

| Task kind (`--type`) | Actor | Skill |
|---|---|---|
| `refinement` | `task-refiner` | `task-refinement` (loads `architecture-impact-assessment`, `technical-specification`, `ui-design`, and `test-design`) |
| `development` | `android-dev`, `backend-dev`, `frontend-dev`, or `rust-dev` | `implementation` plus the stack skills |
| `verification` | `quality-gatekeeper` | `milestone-review`; the orchestrator drives the task with `milestone-verification` |

For a `verification` task, load `milestone-verification`, which opens the task, dispatches `quality-gatekeeper`, and drives corrections before closing it.

Pass the task ID, the milestone acceptance criteria, the linked requirements/specifications, and the expected output. Wait for the actor's report.

Record the task's fulfilment proof as a comment (manage-tasks).

### 6. Check acceptance and artifact verification

The order is fixed: acceptance criteria first, then the required artifact verification.

| Task or artifact | Required user verification | Before |
|---|---|---|
| UI design (inside refinement) | Mockup explicitly verified by the user | Development of the affected UI |
| Test cases (inside refinement) | Test cases verified by the user | Development of the milestone |
| Any other task | None beyond its own acceptance criteria | — |

When a verification is required, ask the user to verify the artifact. A pending response holds the task at the ask step. A denial is recorded with its reason; the task stays in progress and returns to rework with the user's feedback; the ask step runs again after rework.

Set the status to `Refined` after refinement, `Implemented` after development, and `Validated` after the acceptance check. Tasks with no refinement or development stage stay `Initiated` until `Done`; the intermediate statuses record a stage, not a required sequence. Set `Done` only when the acceptance criteria are fulfilled and the required verification is obtained.

After a task is `Done`, merge its `task/<TASK-ID>` branch into the main branch with `--no-ff`: stage and commit any remaining changes first, run `git merge --no-ff task/<TASK-ID>`, and leave the repository on the main branch. Do not push. If the merge fails, stop and report. A `verification` task has no branch; skip the merge for it.

- `--no-ff` is mandatory: every task branch integration creates a merge commit, even when a fast-forward is possible.
- Never run `git merge` without `--no-ff`, and never use `--ff`, `--ff-only`, or a plain fast-forward.
- Never let a pull create a merge commit: use `git pull --ff-only` or `git pull --rebase`.
- The orchestrator performs the merge; no task owner or reviewer merges branches.

### 7. Task outcome and rework

- Acceptance criteria not met: the task stays in progress and work continues. There is no intermediate failure status.
- Missing decision, dependency, or information: stop execution and report. Do not invent the missing input.
- A defect found in the development work reopens the task and returns it to rework; it does not create unplanned work.
- A denied verification returns the task to rework with the user's feedback; it does not create unplanned work.
- New scope discovered during execution stops execution and returns to Phase 2 or 3; it is never absorbed silently.
- A failed milestone verification creates correction tasks or reopens refinement inside the milestone's approved scope; the verification task yields until they are `Done`.
- A defect in a refinement artifact reopens the refinement task instead of creating a correction task.

### 8. Stop boundary and milestone boundary

- The user may state, before or during execution, the last task to complete automatically.
- Execution stops after that task is `Done`; the next task is not started.
- Every milestone end is a stop point: execution stops when the verification task is `Done`, regardless of the boundary.
- On a stop request, finish the current task: if its acceptance criteria are met it becomes `Done`; otherwise it stays in progress and the state is reported.
- The boundary is recorded in the session, not in the backlog.
- Without a boundary, execution continues until the backlog ends, a blocker appears, or a pending verification holds the task.

### 9. Report and hand off

Report:

- milestone ID, title, goal, and completion ratio;
- tasks completed in this run, in order, with fulfilment proof;
- tasks remaining, blocked, or waiting for verification;
- release assignment;
- stop reason and the next action.

When the verification task is `Done`, the milestone is complete. Report it and continue with the next milestone until the user stops execution or declares the feature freeze. Do not run the release audit; the milestone's standalone code audit is part of verification.

## Feature freeze

- The user declares the freeze; execution finishes the current task and stops.
- No new refinement, development, or verification work starts, except in a fix milestone created after the freeze.
- The orchestrator records the frozen milestone scope; `quality-gatekeeper` runs the Phase 5 release audit over the whole codebase.

## Priority and re-planning

- Execution order comes from the planned ordinals; the orchestrator never reorders during execution.
- A user priority change recalls Phase 3; execution resumes from the new order once the plan is revalidated.
- Work already `Done` or in progress keeps its place.
- A plan defect (missing dependency, wrong order, missing scope) stops execution and returns to planning.

## Exit criteria

Phase 4 is complete when:

- the stop boundary is reached, a milestone completes, the user stops execution, the feature freeze is declared, or the backlog is exhausted;
- every executed task is `Done` or explicitly reported as in progress with its blocker;
- every completed milestone has its verification task `Done`, or is reported as incomplete with the failing criterion;
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
- merges a task branch without `--no-ff` or delegates a merge to another agent;
- runs the Phase 5 release audit or builds a milestone package.

## Stop conditions

- Dependency not `Done` or a task unassigned: report and stop.
- A required artifact verification is denied: record the denial, keep the task in progress, rework, and ask again; dependent work does not start.
- Acceptance criteria cannot be met with the current information: stop and return to Phase 2 or 3.
- Milestone verification fails and correction work does not resolve it within scope: stop and report; the user decides on scope.
- Priority or scope conflict: stop and return to Phase 3.
- User declares the feature freeze: finish the current task and stop; `quality-gatekeeper` runs the release audit.
- User requests a stop: finish the current task, then stop.

## Completion checks

- Only tasks assigned to the target milestone were executed.
- Interpretation of ordinals, dependencies, and readiness used the management tool's JSON, not guessed fields.
- Every executed task followed its kind's skill and produced evidence recorded on the task.
- Every required artifact verification was obtained before dependent work.
- No task was skipped silently, no task was pulled from another milestone, and no task was marked `Done` without its criteria and verification.
- Every completed task branch was integrated into the main branch with `git merge --no-ff`.
- The milestone boundary was reported, not approved.
