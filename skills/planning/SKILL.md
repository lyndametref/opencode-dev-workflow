---
name: planning
description: 'Turn verified requirements and bug requests into an ordered, dependency-safe backlog of milestones, releases, and tasks. Implements Phase 3 of the orchestrator workflow.'
argument-hint: 'Provide verified REQ/NFR IDs or bug request IDs, or ask to re-plan, re-prioritize, or add a fix milestone.'
user-invocable: true
disable-model-invocation: false
---

# Planning

## Outcome

A valid, ordered plan in the managed records: the roadmap, one milestone per enhancement or technical improvement, one batch milestone per `bug` batch, the required task sequence, dependencies, ordinals, release assignment, milestone acceptance criteria, and exactly one milestone verification task per milestone. Planned requests are `closed`; declined requests are `rejected`.

## When to use

- Verified requirements arrive from Phase 2.
- A `bug` request arrives from Phase 1.
- The user changes priority, scope, or release composition.
- A plan defect is reported during execution.
- A release audit, rejected finding, or failed final test requires a fix milestone.

Do not use this skill to execute, refine, implement, review, audit, or change task status.

## Prerequisites

- Load the `manage-*` skills for the artifacts involved (requests, requirements, NFRs, roadmap/TECH, milestones, releases, tasks) before any read or write.
- Read the request artifacts via `manage-requests`.
- Planning starts only when requirements are `verified`, no product or business decision is open, and the priority needed for ordering is known. Otherwise report the blocker.

## Inputs

- Verified requirements with changed and created `REQ`/`NFR` IDs and impact flags.
- `bug` request artifacts with `status: open`.
- User priority: the order in which the user wants requests and requirements delivered.
- Current roadmap, milestones, releases, tasks, dependencies, and ordinals.

## Planning elements

| Element | Definition | Rule |
|---|---|---|
| Roadmap | Ordered feature list with source requirement references and rationale | Stored as a managed technical specification titled `Feature Roadmap` (`TECH`). One position per feature; changes are recorded, never silent. |
| Milestone | One enhancement, one technical improvement, or a batch of `bug` tasks, delivered as a usable increment | Has no status; completion is derived from its tasks and confirmed by Phase 5 verification. |
| Release | A managed release record, open until completed | Owns one or more milestones. Create it with a working title such as `Release (pending version)`; RC versioning happens in Phase 5 and the final version is chosen in Phase 6. |
| Task | A task inside a milestone, traceable to requirements or the `bug` request | Outcome-level; assigned to the actor able to fulfil it; refinement completes its fields. |
| Dependency | A hard ordering constraint declared on a task | Never a suggestion; cycles are defects. |
| Ordinal | Position inside a milestone, lower runs first | Encodes user priority when dependencies allow. |

## Milestone composition

Every milestone uses the same ordered task kinds, in this order. Architecture and UI tasks are optional per the rules below.

| Order | Task kind | `--type` | Purpose | Owner |
|---|---|---|---|---|
| 1 | Architecture impact assessment | `architecture` | Judge architectural impact, update Architecture and Decisions, delegate affected Technical specification sections to `tech-writer`; blocks dependent work when unresolved. | `architect` |
| 2 | UI design | `ui-design` | UI specification and at most one mockup for the milestone, only when the feature has UI impact. | `ui-designer` |
| 3 | Test design | `test-design` | Gherkin test cases for every changed requirement and business rule; done when the user verified them. | `test-manager` |
| 4 | Refinement | `refinement` | Confirm all information for development is available and complete the task's refinement fields. | `task-refiner` |
| 5 | Implementation | `implementation` | Code and automated tests, including the integration tests that implement the test cases. | `android-dev`, `backend-dev`, `frontend-dev`, or `rust-dev` |
| 6 | Milestone verification | `milestone-verification` | Verify the increment against the milestone acceptance criteria, publish the versioned RC package, and close the milestone. Not part of Phase 4 execution. | `quality-gatekeeper` |

Rules:

- One milestone per enhancement, one per technical improvement, one batch milestone per group of available `bug` tasks. Plan `bug` fixes as tasks tagged `bug` (`--label bug`).
- The architecture impact assessment is first in every feature and technical-improvement milestone. For a bug milestone, include it only when the planner decides architecture is affected.
- Include a UI design task only when the feature has UI impact.
- Test design is required whenever a requirement or a business rule is created or edited.
- The milestone verification task belongs to the milestone, is not selected during Phase 4, and is executed at the milestone boundary in Phase 5. The milestone is not complete until it is `Done`.
- Milestone acceptance criteria are written on the milestone when planned, each with an identifier and a testable statement, traceable to `REQ`/`NFR` or to the `bug` request(s).
- Task-level acceptance criteria belong to refinement, not planning.
- The planner may split a task before refinement. `task-refiner` may split implementation tasks during refinement; any split that changes dependencies, ordinals, or milestone scope returns to the planner.
- After every addition or split, adjust dependencies and ordinals until the milestone is ordered and dependency-safe.
- The first architecture impact assessment of a project establishes the architecture baseline and the building blocks of the Technical specification.

## Procedure

1. **Read the baseline** — verified requirements, impact flags, bug requests, roadmap, milestones, releases, and current tasks through the manage-* skills (manage-tasks, manage-milestones, manage-releases, manage-requirements, manage-nfrs).
2. **Confirm priority** — for the incoming work. Stop and ask when it is unknown. Never invent priority, business value, or capacity.
3. **Update the roadmap** — feature order, source requirement references, rationale. Create or edit the `Feature Roadmap` technical specification.
4. **Ensure the release** — create a `REL` record with a working title such as `Release (pending version)` if none is active, or reuse the open release. Do not assign a version yet; Phase 5/6 do that.
5. **Create the milestone** — title, kind (`bug`, `enhancement`, `technical-improvement`), release assignment, and acceptance criteria in the description.
6. **Add the tasks in order** — create the required task kinds, assign each to the actor able to fulfil it, and set the task's type, milestone, ordinal, dependencies, references, and documentation where known; `manage-tasks` defines the exact fields. Keep tasks outcome-level.
7. **Add exactly one milestone verification task** per milestone, with `--type milestone-verification`, assigned to `quality-gatekeeper`, and dependent on the last execution task.
8. **Set dependencies and ordinals** so execution order matches the roadmap: dependencies first, then user priority. Use `--ordinal`, never a priority field.
9. **Validate the plan** against the checklist below. Correct and revalidate until valid.
10. **Close or reject request artifacts**:
    - set a `bug` request to `in-progress` when its planning starts;
    - set `status: closed` when the work is planned, and record the planned requirement and task IDs in `references`;
    - set `status: rejected` with the reason when the remaining items are declined;
    - never close or reject before the work is planned or the items are rejected.
11. **Report** the plan, the first eligible item, the release composition, and any open decisions.

## Prioritisation rules

Applied in this order:

1. **Dependencies first.** Never schedule work before a declared dependency.
2. **User priority.** Among dependency-ready work, lower ordinals go to what the user asked for first.
3. **No unusable increments.** Never schedule a capability before the capability that makes it usable.
4. **Risk and readiness.** Prefer lower-risk, well-understood work that keeps the milestone demonstrable.
5. **Tie-breaker.** Ask the user; never fall back to identifier order.

## Plan validation

A plan is valid only when:

- every milestone is one enhancement, one technical improvement, or a batch of `bug` tasks, and has the required task sequence;
- every milestone has acceptance criteria and exactly one milestone verification task;
- the dependency graph is acyclic;
- every dependency exists and is scheduled earlier;
- no dependency points forward across milestones;
- every verified requirement maps to at least one task, or to an explicit recorded decision;
- every task references a requirement, a `bug` request, or a `technical-improvement` request with the recorded reason when no requirement is produced;
- every task is assigned to an actor able to fulfil it;
- release assignment and milestone scope are complete;
- ordinals are unambiguous inside each milestone;
- no in-progress task was reordered or re-scoped.

## Re-planning

- A plan defect found during execution — missing dependency, wrong order, missing milestone scope, priority conflict — returns to the planner.
- Correct only what the defect requires, revalidate the plan, and report the correction or `no change needed`.
- Refinement splits that change dependencies, ordinals, or milestone scope return to the planner.
- Reordering or re-scoping an in-progress task requires the user's agreement first.
- A failed release audit, a rejected finding, or a failed final build adds a **fix milestone** to the release: create it if missing, add only fix tasks scoped to what the release needs to become releasable, and assign each to the owning actor. The auditor who reported the finding defines the fix task's content.
- A deployable component reported without its `<component-dir>/scripts/build-package.sh` at packaging gets a task for the owning `*-dev` agent: in the milestone being verified in Phase 5, or in the fix milestone in Phase 6. The task asks for the script per `build-package-script`; nothing else is bundled into it.

## Priority change

- A priority change is a planning input, not an execution change.
- Update the roadmap and recalculate ordinals and dependencies for work that has not started.
- Completed and in-progress work keeps its order.
- Revalidate the plan and report the new order and the next eligible task.

## Boundaries

This phase never:

- plans task execution in detail, writes task-level acceptance criteria, or defines task-level scope;
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
- Every incoming requirement or bug request is planned or explicitly rejected.
- Every milestone has the required task kinds, acceptance criteria, and exactly one milestone verification task.
- Request artifacts are closed or rejected with references.
- The orchestrator holds the backlog, the first eligible item, and any open decisions.
