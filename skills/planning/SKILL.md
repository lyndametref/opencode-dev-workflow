---
name: planning
description: 'Turn verified requirements and bug requests into an ordered, dependency-safe backlog of milestones, releases, and tasks. Implements Phase 3 of the orchestrator workflow: /plan REQUEST-xxx for one request, /plan for all open requests.'
argument-hint: 'Run /plan REQUEST-xxx, /plan, or ask to re-plan, re-prioritize, or add a fix milestone.'
user-invocable: true
disable-model-invocation: false
---

# Planning

## Outcome

A valid, ordered plan in the managed records: the roadmap, one milestone per enhancement or technical improvement, one batch milestone per `bug` batch, and for each milestone exactly one refinement task, one or more development tasks, and exactly one verification task, with dependencies, ordinals, release assignment, and milestone acceptance criteria. Planned requests are `closed`; declined requests are `rejected`.

## When to use

- `/plan REQUEST-xxx` is invoked for one request, or `/plan` for every open request.
- A `bug` request is ready for planning.
- The user changes priority, scope, or release composition.
- A plan defect is reported during execution.
- An audit finding is chosen for fix, or a release build or deployment fails.

Do not use this skill to execute, refine, implement, review, audit, or change task status.

## Prerequisites

- Load the `manage-*` skills for the artifacts involved (requests, requirements, NFRs, roadmap/TECH, milestones, releases, tasks) before any read or write.
- Read the request artifacts via `manage-requests`.
- Planning starts only when requirements are `verified`, no product or business decision is open, and the priority needed for ordering is known. Otherwise report the blocker.

## Inputs

- The planning scope: the request named in `/plan REQUEST-xxx`, or every open request when none is named.
- Verified requirements with changed and created `REQ`/`NFR` IDs.
- `bug` request artifacts with `status: open`.
- User ADRs created between Phases 1 and 2, as fixed business or technical constraints.
- User priority: the order in which the user wants requests and requirements delivered.
- Current roadmap, milestones, releases, tasks, dependencies, and ordinals.

## Planning elements

| Element | Definition | Rule |
|---|---|---|
| Roadmap | Ordered feature list with source requirement references and rationale | Stored as a managed technical specification titled `Feature Roadmap` (`TECH`). One position per feature; changes are recorded, never silent. |
| Milestone | One enhancement, one technical improvement, or a batch of `bug` tasks, delivered as a usable increment | Contains exactly one refinement task, one or more development tasks, and exactly one verification task; completion is derived from the verification task. |
| Release | A managed release record, open until completed | Owns one or more milestones. Create it with a working title such as `Release (pending version)`; the final version is chosen in Phase 6. |
| Task | A task inside a milestone, traceable to requirements or the `bug` request | Outcome-level; assigned to the actor able to fulfil it; refinement completes the development tasks' fields. |
| Dependency | A hard ordering constraint declared on a task | Never a suggestion; cycles are defects. |
| Ordinal | Position inside a milestone, lower runs first | Encodes user priority when dependencies allow. |

## Milestone composition

Every milestone uses the same ordered task kinds.

| Order | Task kind | `--type` | Purpose | Owner |
|---|---|---|---|---|
| 1 | Refinement | `refinement` | Architecture impact analysis, Technical specification, technical decisions, UI design and mockups when needed, Gherkin test cases, and the development tasks with precise acceptance criteria. | `task-refiner` |
| 2..n | Development | `development` | Implement one development task and fulfil its acceptance criteria. | `android-dev`, `backend-dev`, `frontend-dev`, or `rust-dev` |
| last | Verification | `verification` | Check every milestone acceptance criterion, assess the basic code quality gates, and create correction tasks when needed. | `quality-gatekeeper` |

Rules:

- One milestone per enhancement, one per technical improvement, one batch milestone per group of available `bug` tasks. Plan `bug` fixes as tasks tagged `bug` (`--label bug`).
- Every milestone has exactly one refinement task, one or more development tasks, and one verification task. There is no milestone build task and no RC package; final packages are built in Phase 6. Verification may add development correction tasks or reopen refinement without changing this composition.
- Refinement comes first. It produces the Technical specification, the technical decisions, the UI design and mockups when the milestone needs them, the test cases, and the development tasks.
- Planning creates the milestone's main development tasks; refinement completes them and may add or split development tasks. Their precise acceptance criteria are written by refinement.
- Development starts only after the refinement task is `Done`.
- Verification runs last, after every planned development task is `Done`. It checks all milestone acceptance criteria and the basic code quality gates, and creates correction tasks for failures. The milestone is not complete until the verification task passes.
- Milestone acceptance criteria are written on the milestone when planned, each with an identifier and a testable statement, traceable to `REQ`/`NFR` or to the `bug` request(s).
- Development task acceptance criteria belong to refinement, not planning.
- Test cases are written as Gherkin scenarios (`GIVEN` / `WHEN` / `THEN`) for the changed requirements and business rules.
- The first milestone of a project establishes the Technical specification baseline and the building blocks it is organized by.
- The orchestrator may split a task before refinement. `task-refiner` may add or split development tasks during refinement; any split that changes dependencies, ordinals, or milestone scope returns to planning.
- After every addition or split, adjust dependencies and ordinals until the milestone is ordered and dependency-safe.
- Exactly one verification task is planned per milestone. It is the last task planned with the milestone; correction tasks created by it are added after it.

## Procedure

1. **Resolve the scope** — `/plan REQUEST-xxx` plans that request; `/plan` plans every open request. Stop and ask when the scope is ambiguous.
2. **Read the baseline** — verified requirements, user ADRs, bug requests, roadmap, milestones, releases, and current tasks through the `manage-*` skills.
3. **Confirm priority** — for the incoming work. Stop and ask when it is unknown. Never invent priority, business value, or capacity.
4. **Update the roadmap** — feature order, source requirement references, rationale. Create or edit the `Feature Roadmap` technical specification.
5. **Ensure the release** — create a `REL` record with a working title such as `Release (pending version)` if none is active, or reuse the open release. Do not assign a version yet.
6. **Create the milestone** — title, kind (`bug`, `enhancement`, `technical-improvement`), release assignment, and acceptance criteria in the description.
7. **Add the refinement task** — `--type refinement`, assigned to `task-refiner`, ordinal 1.
8. **Add the main development tasks** — `--type development`, assigned to the `*-dev` actor able to fulfil them, with milestone, ordinal, dependencies, references, and documentation where known. Keep them outcome-level; refinement writes their precise acceptance criteria.
9. **Add exactly one verification task** — `--type verification`, assigned to `quality-gatekeeper`, dependent on the last development task.
10. **Set dependencies and ordinals** so execution order matches the roadmap: dependencies first, then user priority. Use `--ordinal`, never a priority field.
11. **Validate the plan** against the checklist below. Correct and revalidate until valid.
12. **Close or reject request artifacts**:
    - set a `bug` request to `in-progress` when its planning starts;
    - set `status: closed` when the work is planned, and record the planned requirement and task IDs in `references`;
    - set `status: rejected` with the reason when the remaining items are declined;
    - never close or reject before the work is planned or the items are rejected.
13. **Report** the plan, the first eligible item, the release composition, and any open decisions.

## Prioritisation rules

Applied in this order:

1. **Dependencies first.** Never schedule work before a declared dependency.
2. **User priority.** Among dependency-ready work, lower ordinals go to what the user asked for first.
3. **No unusable increments.** Never schedule a capability before the capability that makes it usable.
4. **Risk and readiness.** Prefer lower-risk, well-understood work that keeps the milestone demonstrable.
5. **Tie-breaker.** Ask the user; never fall back to identifier order.

## Plan validation

A plan is valid only when:

- every milestone is one enhancement, one technical improvement, or a batch of `bug` tasks;
- every milestone has acceptance criteria, exactly one refinement task, one or more development tasks, and exactly one verification task, with the verification task last;
- the dependency graph is acyclic;
- every dependency exists and is scheduled earlier;
- no dependency points forward across milestones;
- every verified requirement maps to at least one milestone or task, or to an explicit recorded decision;
- every task references a requirement, a `bug` request, or a `technical-improvement` request with the recorded reason when no requirement is produced;
- every task is assigned to an actor able to fulfil it;
- release assignment and milestone scope are complete;
- ordinals are unambiguous inside each milestone;
- no in-progress task was reordered or re-scoped.

## Re-planning

- A plan defect found during execution — missing dependency, wrong order, missing milestone scope, priority conflict — returns to planning.
- Correct only what the defect requires, revalidate the plan, and report the correction or `no change needed`.
- Refinement splits that change dependencies, ordinals, or milestone scope return to planning.
- Reordering or re-scoping an in-progress task requires the user's agreement first.
- A failed audit, a finding the user chose to fix, a rejected scope, or a failed final build, package, or deployment adds a **fix milestone** to the release: create it with its refinement, development, and verification tasks, scoped only to what the release needs to become releasable. The audit or review that reported the finding defines the fix task's content.
- A deployable component reported without its `<component-dir>/scripts/build-package.sh` at packaging gets a task for the owning `*-dev` agent: in the fix milestone, or in the milestone being built. The task asks for the script per `build-package-script`; nothing else is bundled into it.

## Priority change

- A priority change is a planning input, not an execution change.
- Update the roadmap and recalculate ordinals and dependencies for work that has not started.
- Completed and in-progress work keeps its order.
- Revalidate the plan and report the new order and the next eligible task.

## Boundaries

This phase never:

- plans task execution in detail, writes development task acceptance criteria, or defines development task scope;
- implements, designs UI, writes specifications, or edits requirements;
- invents priority, capacity, or business value;
- changes requirement meaning or adds scope not covered by Phase 2;
- executes work, changes task status, or marks a task `Done`;
- closes or rejects a request before its work is planned or its items are rejected;
- reorders in-progress work without the user's agreement.

## Stop conditions

- Requirements not `verified` or a decision open: stop, return to Phase 2.
- Priority unknown and needed for ordering: ask; do not guess.
- Dependency cycle, missing dependency, or forward cross-milestone dependency: stop the affected plan.
- In-progress work affected by new scope: ask before reordering or re-scoping.
- Bug request without a traceable requirement or a clear defect description: return it to Phase 1.
- Milestone or release scope conflict: ask the user.

## Report format

- **Scope**: request IDs planned, or all open requests.
- **Roadmap**: ordered features, source requirement IDs, milestone, rationale, `TECH` ID.
- **Release**: `REL` ID, title, owned milestones.
- **Milestones**: ID, kind, goal, acceptance criteria, release.
- **Task order**: task ID, title, kind, actor, milestone, dependencies, ordinal.
- **Request closure**: request ID -> `closed`/`rejected`, references.
- **Validation**: result and any defects.
- **Next eligible task**.
- **Open decisions**: or `none`.

## Completion checks

- A valid plan exists, ordered and dependency-ready.
- Every open request in scope is planned or explicitly rejected.
- Every milestone has exactly one refinement task, one or more development tasks, and exactly one verification task, plus its acceptance criteria.
- Request artifacts are closed or rejected with references.
- The orchestrator holds the backlog, the first eligible item, and any open decisions.
