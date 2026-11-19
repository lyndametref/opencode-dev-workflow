## 3. Planning

Phase 3 turns verified requirements, and `bug` requests, into an **ordered, dependency-safe backlog**. Each new or changed enhancement is packed into its own milestone; each technical improvement gets its own milestone; `bug` fixes are packed into one milestone per batch. Planning closes the request artifacts it planned and rejects those it declines.

Phase position: `Phase 2 → Phase 3 → Phase 4 Implementation`. The `Backlog` artifact is defined in [artifacts.md](./artifacts.md).

### Inputs and preconditions

- **Verified requirements** from Phase 2, with changed and created requirement and group IDs, plus impact flags (architecture, specification, UI, NFR, integration).
- **Bug request artifacts** with status `open`, routed directly from Phase 1.
- **User priority**: the order in which the user wants requests and requirements delivered.
- **Current plan state**: roadmap, milestones, releases, tasks, dependencies, ordinals.

Planning does not start when requirements are not `verified`, a product or business decision is open, or the priority needed for ordering is unknown. The planner reports the blocker instead of inventing order or scope.

### Actors

| Actor                                                  | Role in Phase 3                                                           |
| ------------------------------------------------------ | ------------------------------------------------------------------------- |
| `planner`                                              | Owner: roadmap, milestones, releases, tasks, dependencies, ordinals       |
| `orchestrator`                                         | Starts planning and receives the ordered backlog; never plans or reorders |
| User                                                   | Supplies priority, scope trade-offs, and milestone/release decisions      |
| `requirements-engineer`                                | Supplies verified requirements; does not plan                            |
| `architect`, `ui-designer`, `task-refiner`, dev agents | Execute their task kinds inside a milestone; do not plan the milestone    |

### Flow

```mermaid
%%{init: {"flowchart": {"nodeSpacing": 10, "rankSpacing": 18}}}%%
flowchart LR
    IN([Verified requirements<br/>or bug request]) --> READ["Read baseline:<br/>requirements, roadmap, backlog"]
    READ --> PRIO{"User priority<br/>known?"}
    PRIO -->|"No"| ASK["Ask the user"]
    ASK --> PRIO
    PRIO -->|"Yes"| ROAD["Update roadmap:<br/>features, references, rationale"]
    ROAD --> WORK["Decide the work:<br/>one milestone per feature,<br/>tasks and order"]
    WORK --> VALID["Validate dependencies,<br/>coverage, placement"]
    VALID --> VOK{"Valid?"}
    VOK -->|"No"| WORK
    VOK -->|"Yes"| CLOSE["Close planned<br/>request artifacts"]
    CLOSE --> OUT["Report the plan;<br/>hand the backlog over"]
```

### Planning elements

| Element    | Definition                                                                             | Rule                                                                                                             |
| ---------- | -------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| Roadmap    | Ordered feature list with source requirement references and rationale                  | One position per feature; changes are recorded, never silent                                                     |
| Milestone  | One enhancement, one technical improvement, or a batch of `bug` tasks, delivered as a usable increment | Has no status; completion is derived from its tasks and confirmed by verification          |
| Release    | A version record, open until completed, owning one or more milestones                  | Created by the planner and stays open to new milestones; RC versioning happens in Phase 5 and the final version is chosen in Phase 6 |
| Task       | A task inside a milestone, traceable to requirements or the `bug` request              | Outcome-level; assigned to the actor able to fulfill it; refinement completes the task's fields                  |
| Dependency | A hard ordering constraint declared on a task                                          | Never a suggestion; cycles are defects                                                                           |
| Ordinal    | Position inside a milestone, lower runs first                                          | Encodes user priority when dependencies allow                                                                    |

### Milestone composition

Every milestone uses the same ordered task kinds, in this order, with optional architecture and UI tasks. Planning decides that the tasks exist and in which order; it does not plan their execution. Tasks 1 to 5 are executed in Phase 4; task 6 is the milestone check, executed at the milestone boundary, and the milestone cannot close until it passes.

| Order | Task                           | Purpose                                                                                            | Owner                |
| ----- | ------------------------------ | -------------------------------------------------------------------------------------------------- | -------------------- |
| 1     | Architecture impact assessment | Judge architectural impact and resolve the findings by updating the Architecture and the Decisions, and delegating affected Technical specification sections to `tech-writer`; blocks dependent work when unresolved | `architect`          |
| 2     | UI design                      | UI specification entries and at most one mockup for the milestone, only when the planner decides it is needed | `ui-designer`        |
| 3     | Test design                    | Write the Gherkin test cases for the changed requirements and business rules; done when every changed requirement or rule has its test cases and the user has verified them | `test-manager`       |
| 4     | Refinement                     | Confirm that all information needed for development is available, and complete the task's refinement fields | `task-refiner`       |
| 5     | Implementation                 | Development and automated tests, implementing the code and the test cases                          | Any `*-dev` agent    |
| 6     | Milestone verification         | Verify the increment against the milestone acceptance criteria, publish the versioned RC package, and close the milestone | `quality-gatekeeper` |

Rules:

- The architecture impact assessment comes first in every feature and technical-improvement milestone; its findings are resolved by updating the affected artifact, including any Decision; Technical specification edits are delegated to `tech-writer`.
- The UI design task exists only when the planner decides the feature has UI impact.
- Refinement does not start before the architecture impact is settled, the technical specification conformance is verified by the `architect`, any UI task is planned, and the test cases are verified by the user; the test cases are input to the implementation plan.
- Implementation does not start before refinement has completed the task.
- The milestone verification task is the only check of the milestone.
- Milestone acceptance criteria are written on the milestone when it is planned; task-level acceptance criteria belong to refinement.
- Test design is required whenever a requirement or a business rule is created or edited; its test cases are written as Gherkin scenarios (`GIVEN` / `WHEN` / `THEN`).
- The planner may split a task before refinement; `task-refiner` may split implementation tasks during refinement.
- After every addition or split, dependencies and ordinals are adjusted until the milestone is ordered and dependency-safe.
- Bugs are planned as tasks tagged `bug`; when several are available they are packed into one milestone and follow the same sequence, with architecture and UI tasks only when the planner decides they apply.
- A new project's first architecture impact assessment establishes the architecture baseline and the building blocks the Technical specification is organized by.
- The planner creates exactly one milestone verification task per milestone. It belongs to the milestone, is not part of the Phase 4 execution sequence, and is run independently in Phase 5; the milestone is not complete until it is `Done`.

### Prioritisation rules

Applied in this order:

1. **Dependencies first.** Never schedule work before a declared dependency.
2. **User priority.** Among dependency-ready work, lower ordinals go to what the user asked for first.
3. **No unusable increments.** Never schedule a capability before the capability that makes it usable.
4. **Risk and readiness.** Prefer lower-risk, well-understood work that keeps the milestone demonstrable.
5. **Tie-breaker.** Ask the user; never fall back to identifier order.

The planner never invents priority, business value, or capacity.

### Steps

1. **Read the baseline**: verified requirements, impact flags, bug requests, roadmap, milestones, releases, and current tasks.
2. **Confirm priority** for the incoming work; stop and ask when it is unknown.
3. **Update the roadmap**: feature order, requirement references, rationale.
4. **Decide the work**: pack each new or changed enhancement into its own milestone, pack available `bug` tasks into a shared milestone, add the tasks in the required sequence including the milestone verification task, assign each to the actor able to fulfill it, split where useful, and set dependencies and ordinals.
5. **Validate** the plan.
6. **Close the planned request artifacts**: status `closed`, referencing the requirements and tasks produced. Set `rejected` on artifacts whose remaining items are declined, with the reason.
7. **Report** the plan and hand the backlog to the orchestrator, including the first eligible item.

### Plan validation

A plan is valid only when:

- every milestone is one enhancement, one technical improvement, or a batch of `bug` tasks, and has the required task sequence;
- every milestone has its acceptance criteria and exactly one milestone verification task, executed at the milestone boundary;
- the dependency graph is acyclic;
- every dependency exists and is scheduled earlier;
- no dependency points forward across milestones;
- every verified requirement maps to at least one task, or to an explicit recorded decision;
- every task references a requirement, a `bug` request, or a `technical-improvement` request with the recorded reason when no requirement is produced;
- every task is assigned to an actor able to fulfill it;
- release assignment and milestone scope are complete;
- ordinals are unambiguous inside each milestone;
- no in-progress task was reordered or re-scoped.

### Request artifact closure

- A request artifact is closed **when its work is planned**, not when requirements are written.
- Closing records the planned requirements and tasks on the artifact.
- Planning sets a `bug` request `in-progress` when its planning starts; it is closed the same way as any request: planned, then close.
- An artifact whose remaining items are rejected becomes `rejected`, with the reason.
- A request artifact is never closed or rejected before its work is planned or its items are rejected.

### Re-planning

A plan defect found during execution — missing dependency, wrong order, missing milestone scope, priority conflict — returns to the planner for a repair. The planner corrects only what the defect requires, revalidates the plan, and reports the correction or `no change needed`.

Refinement may split a task within the plan. Any split that changes dependencies, ordinals, or milestone scope goes back to the planner.

Reordering or re-scoping an in-progress task requires the user's agreement first.

A failed release audit adds a **fix milestone** to the release: the planner creates the fix milestone and its fix tasks, scoped only to what the release needs to become releasable. A deployable component reported without a `scripts/build-package.sh` during packaging gets a task for its `*-dev` agent, in the milestone being verified or in the fix milestone.

### Priority change

The user may change priority at any time, including during implementation.

- A priority change is a planning input, not an execution change: it recalls Phase 3.
- The planner updates the roadmap and recalculates ordinals and dependencies for work that has not started.
- Completed and in-progress work keeps its order.
- The planner revalidates the plan and reports the new order and the next eligible task.
- Implementation resumes from the new order; the stop boundary is restated if it was expressed against the old order.

### Exit criteria

Phase 3 is complete when:

- a valid plan exists, ordered and dependency-ready;
- every incoming requirement or bug request is planned or explicitly rejected;
- every milestone carries its architecture impact assessment, optional UI design, test design, refinement, implementation, and verification tasks, with its acceptance criteria on the milestone;
- the request artifacts are closed with their references;
- the orchestrator holds the backlog, the first eligible item, and any open decisions.

No implementation, refinement, or status transition happens here.

### Boundaries

Phase 3 never:

- plans task execution in detail, writes task-level acceptance criteria, or defines task-level scope; milestone acceptance criteria belong on the milestone and task-level criteria to refinement;
- implements, designs UI, writes specifications, or edits requirements;
- invents priority, capacity, or business value;
- changes requirement meaning or adds scope not covered by Phase 2;
- executes work, changes task status, or marks a task `Done`;
- closes or rejects a request artifact before its work is planned or its items are rejected;
- reorders in-progress work without the user's agreement.

### Stop conditions

- Requirements not `verified` or a decision open: stop, return to Phase 2.
- Priority unknown and needed for ordering: ask; do not guess.
- Dependency cycle, missing dependency, or forward cross-milestone dependency: stop the affected plan.
- In-progress work affected by the new scope: ask before reordering or re-scoping.
- Bug request without a traceable requirement or a clear defect description: return it to Phase 1.
- Milestone or release scope conflict: ask the user.
