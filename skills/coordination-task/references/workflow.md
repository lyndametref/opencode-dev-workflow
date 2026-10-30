# Coordination Task Workflow

This overview explains the workflow implemented by `SKILL.md`. Backlog task reads and status changes use the Backlog.md CLI; agent delegation uses OpenCode's `subagent` tool.

## Resume and task selection

- If a task ID/path is supplied, coordinate that task.
- Otherwise, first run `backlog task list --status "Initiated,Refined,Implemented,Validated" --sort priority --plain` and resume the first (highest-priority) in-progress task.
- If no task is in progress, run `backlog task list --ready --plain` and take the first returned item. Do not reorder the list or ask the user to pick among candidates.
- On resume, read the selected task status and skip completed phases. **Repository preparation is only for a new `To Do` task; never run it when resuming `Initiated` or later.**

```mermaid
flowchart TD
    START([Start]) --> HASID{"Task ID or path provided?"}
    HASID -->|"Yes"| USEID["Use provided task"]
    HASID -->|"No"| ACTIVE["List in-progress tasks by priority"]
    ACTIVE --> ACTIVEQ{"Any in-progress task?"}
    ACTIVEQ -->|"Yes"| PICKACTIVE["Resume first in-progress task"]
    ACTIVEQ -->|"No"| TODO["List ready To Do tasks"]
    TODO --> TODOQ{"Eligible task found?"}
    TODOQ -->|"No"| EMPTY["Report no eligible task and stop"]
    TODOQ -->|"Yes"| PICKTODO["Take first ready task"]

    USEID --> STATUS
    PICKACTIVE --> STATUS
    PICKTODO --> STATUS
    STATUS{"Task status?"}
    STATUS -->|"To Do: new task"| PREP["Prepare repository"]
    PREP --> INIT["Set Initiated"]
    INIT --> REFINE["business-analyst refines"]
    STATUS -->|"Initiated: resume; skip repository prep"| REFINE
    REFINE --> UIGATE["UI mockups (ui-designer) user-approved, if needed"]
    UIGATE --> SETREFINED["Set Refined"]
    STATUS -->|"Refined"| IMPLEMENT
    SETREFINED --> IMPLEMENT["Implement with android-dev, backend-dev, or frontend-dev"]
    IMPLEMENT --> SETIMPLEMENTED["Set Implemented"]
    SETIMPLEMENTED --> REVIEW["quality-gatekeeper reruns tests and reviews"]
    STATUS -->|"Implemented"| REVIEW
    REVIEW --> PASS{"Review passes?"}
    PASS -->|"No"| SETREFINED
    PASS -->|"Yes"| VALIDATED["Set Validated; print report separately"]
    STATUS -->|"Validated"| APPROVAL["Print report; ask short approval question"]
    VALIDATED --> APPROVAL
    APPROVAL --> APPROVED{"User approves?"}
    APPROVED -->|"Yes"| DONE["Set Done"]
    APPROVED -->|"No; refinement needed"| INIT
    APPROVED -->|"No; implementation can resume"| SETREFINED
    STATUS -->|"Done"| REPORT["Report complete and stop"]
    DONE --> REPORT
```

## Workflow steps

1. **Resolve task.** Follow the selection rules above. `backlog task` is the Backlog.md CLI command for task operations; it does not launch agents.
2. **Prepare repository (new tasks only).** For `To Do`, inspect the working tree and follow `SKILL.md` safeguards. For any resumed status (`Initiated` or later), skip repository preparation entirely and preserve the current branch and changes.
3. **Refine.** Delegate to `business-analyst`; set status to `Refined` when complete. Skip if already `Refined` or later. If UI design is needed, delegate to `ui-designer` and obtain explicit user approval for every referenced `MOCK-XXXX` before `Refined`.
4. **Implement.** Delegate units to `android-dev`, `backend-dev`, or `frontend-dev`. Capture each agent's structured evidence response; set status to `Implemented` when complete.
5. **Review.** Delegate to `quality-gatekeeper` using OpenCode's `subagent` tool. It independently reruns relevant tests, verifies the ticket, and returns a per-criterion evidence table. If incomplete, set status to `Refined`, address findings, and review again.
6. **Approve.** A passing review sets status to `Validated`. Print the gatekeeper report and the acceptance-criteria checklist separately, then ask a short approval question. Set status to `Done` only after explicit approval. If changes are requested, use `Initiated` if refinement is needed, otherwise `Refined` to resume implementation without repository preparation.

All backlog reads and writes use the Backlog.md CLI via the `backlog-md` skill. Subagent launches use OpenCode's `subagent` tool, not the Backlog CLI's `task` command.
