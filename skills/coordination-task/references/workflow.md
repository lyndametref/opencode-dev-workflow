# Coordination Task Workflow

This overview explains what happens when `coordination-task` is used. The `SKILL.md` contains the instructions followed by the coordinating agent; this page is a user-facing guide.

```mermaid
flowchart TD
    A([Start: task ID provided]) --> B[Inspect repository state]
    B --> C{Uncommitted changes?}
    C -- Yes --> D[Stop and ask user to clean up repository]
    D --> X([Wait for user confirmation that cleanup is done])
    X --> B
    C -- No --> E[Checkout main]
    E --> F[Pull latest from origin]
    F --> G[Create branch task/&lt;task-id&gt;]
    G --> H[Business analyst refines task]
    H --> I[Set task In Progress]
    I --> J{Subtasks created?}
    J -- Yes --> K[Choose implementation agent per subtask goal]
    J -- No --> L[Choose implementation agent for task]
    K --> M[Implement with android-dev or backend-dev]
    L --> M
    M --> N[Quality gatekeeper reviews implementation]
    N --> O{Review is OK?}
    O -- No --> P[Set task In Progress and send review findings to development]
    P --> M
    O -- Yes --> Q[Set task Done]
    Q --> R[Ask user whether they are satisfied]
    R --> S{User is satisfied?}
    S -- No --> T[Gather actionable user feedback]
    T --> U[Set task In Progress and send feedback plus review findings to development]
    U --> M
    S -- Yes --> V([User may mark task complete])
```

## What to expect

1. The working tree is checked first. If it has uncommitted changes, coordination stops and the user is asked to clean up the repository and confirm when done; those changes are not committed, stashed, or discarded by the skill. After the user's confirmation, the working tree is checked again. Once clean, the repository is prepared on a task-specific branch before refinement or implementation.
2. The business analyst clarifies the task and may split it into implementation subtasks.
3. The task is moved to `In Progress`; implementation is delegated per task/subtask to the appropriate development agent. Independent subtasks may proceed in parallel.
4. The quality gatekeeper checks the result against the refined task's acceptance criteria and definition of done.
5. An incomplete review returns the task to `In Progress` and its findings go to development. An OK review sets the task to `Done`, after which the user is explicitly asked whether they are satisfied. If not, actionable feedback is gathered before the task returns to `In Progress` and development resumes with both that feedback and the review findings. The user decides when to mark it complete.

Task reads and status changes use the `backlog-md` skill and backlog CLI.
