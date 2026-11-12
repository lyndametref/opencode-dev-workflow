# Orchestrator Workflow

This document describes how the `orchestrator` agent runs software delivery. All backlog and managed-document reads and writes use the Papyrus CLI via the `papyrus` skill. Agent delegation uses OpenCode's `subagent` tool.

## Ownership

| Concern | Owner |
|---|---|
| Requirement creation, update, validation, traceability | `requirements-engineer` (Papyrus `req`/`nfreq`) |
| Roadmap, feature priority, milestone/task order, dependencies | `planner` subagent, launched by `orchestrator` |
| Task, milestone, and release execution; status transitions; approval requests | `orchestrator` |
| Ticket refinement and feature specification | `task-refiner` |
| Domain model artifacts (state diagrams, attribute lists, process diagrams) | `domain-modeler` |
| UI specifications and mockups | `ui-designer` (Papyrus `ui-spec`/`ui-mockup`) |
| Business rules and glossary | `business-analyst`, `terminologist` (Papyrus `rule`/`glossary`) |
| Architecture decisions | `architect` (Papyrus `decision`) |
| Implementation | `android-dev`, `backend-dev`, `frontend-dev`, `rust-dev` |
| Quality review | `quality-gatekeeper` |
| End-of-release security audit | `security-officer` |
| Audit record and release completion record | `orchestrator` (Papyrus `audit`/`release`) |

The orchestrator is the primary entry point. It executes the plan and delegates planning or plan changes to the `planner` subagent; it does not plan itself. It is read-only with respect to project source and documentation content: it never edits source, docs, requirements, or managed records directly. Its only writes are Papyrus status/metadata operations, evidence comments, audit records, release completion records, and git operations limited to branch creation/switching, staging, commit, merge, rebase, and pull (no push, stash, reset, clean, or discard).

## End-to-end flow

```mermaid
flowchart TD
    START([User request]) --> KIND{"Request type"}
    KIND -->|"New feature / requirement"| REQ["requirements-engineer: create/update REQ/NFR via Papyrus"]
    REQ --> REQOK{"Requirements validated?"}
    REQOK -->|"No"| REQBLOCK["Report blockers; ask user"]
    REQOK -->|"Yes"| PLAN["planner subagent: check/correct roadmap and task order"]
    KIND -->|"Plan / re-prioritize"| PLAN
    KIND -->|"Execute"| SELECT{"Orchestration level"}
    PLAN --> READY["Papyrus: ordered, dependency-ready tasks"]
    READY --> SELECT
    SELECT -->|"One task"| TASK["task-orchestration"]
    SELECT -->|"Milestone"| MILESTONE["milestone-orchestration"]
    SELECT -->|"Release"| RELEASE["release-orchestration"]
    TASK --> DONE["Task Done after user approval"]
    MILESTONE --> TASK
    MILESTONE --> MDONE["Milestone complete or blocked"]
    RELEASE --> ALLDONE{"All release work Done?"}
    ALLDONE -->|"No"| MILESTONE
    ALLDONE -->|"Yes"| AUDIT["security-officer: release security audit"]
    AUDIT --> DECISION{"Security decision"}
    DECISION -->|"Block"| STOP["Stop; report findings"]
    DECISION -->|"Pass / Pass with findings"| GATE["quality-gatekeeper verifies release evidence"]
    GATE --> RAPPROVE["Print release report; request approval"]
    RAPPROVE -->|"Approved"| RDONE["Release marked released"]
    RAPPROVE -->|"Changes requested"| MILESTONE
```

## New feature or requirement intake

This flow is mandatory whenever the user requests a new feature, a new requirement, or a change to an existing requirement.

```mermaid
flowchart TD
    REQ([New feature / requirement request]) --> CAPTURE["orchestrator: capture scope and product intent"]
    CAPTURE --> ENGINEER["requirements-engineer: create/update REQ/NFR in Papyrus, validate"]
    ENGINEER --> STATUS{"Requirements validated?"}
    STATUS -->|"No"| BLOCK["Report blockers and open product questions; stop"]
    STATUS -->|"Yes"| PLAN["planner subagent: check roadmap coverage, milestones, dependencies, task order"]
    PLAN --> CHANGE{"Plan change needed?"}
    CHANGE -->|"No"| REPORT["Report requirement changes and 'no change needed'"]
    CHANGE -->|"Yes"| CORRECT["planner corrects roadmap and task order"]
    CORRECT --> REPORT
    REPORT --> NEXT["Next eligible task or user decision"]
```

Rules:

- Never send a new feature or requirement directly to `planner`.
- `requirements-engineer` owns requirement records, validation, and traceability.
- `planner` owns roadmap and task-order corrections; it reports `no change needed` when the existing plan remains valid.
- Do not start implementation until requirements are validated and the plan is checked.
- If the change affects an in-progress task, pause and ask the user before reordering or re-scoping it.
- Open product decisions stop the flow; do not guess requirements.

## Planning workflow

The orchestrator launches the `planner` subagent when the user asks to:

- create or update the roadmap and feature order;
- change feature priority;
- create or reorder milestones and tasks;
- create or repair releases and milestone assignments;
- repair dependencies or validate the dependency graph;
- check and correct the roadmap/task order after `requirements-engineer` reports changed requirements.

The planner works through Papyrus and returns the roadmap, milestone/release plan, task order, dependency validation, issues, and open questions. The orchestrator reports that result to the user and continues with execution only when the plan is actionable.

The roadmap is a Papyrus technical specification titled `Feature Roadmap`. Papyrus has no priority field; the planner encodes user priority through `ordinal` (lower runs first) and `dependencies`.

For a new project, the planner includes early bootstrap tasks (domain modeling: context map and business object model, delegated to `domain-modeler`; technical-stack definition, delegated to `architect`) before feature tickets.

If execution reveals a plan defect (missing dependency, wrong order, missing milestone scope, priority conflict), the orchestrator pauses and delegates a plan repair to the `planner` subagent.

For a new feature or requirement, the orchestrator follows the intake flow above: `requirements-engineer` first, then `planner` to check and correct the plan. The planner must report `no change needed` when the existing plan remains valid.

## Task workflow

The orchestrator loads `task-orchestration` and follows its procedure. The workflow below is the user-facing summary.

### Resume and task selection

- If a task ID is supplied, orchestrate that task.
- Otherwise, read all tasks with `papyrus --json task list` and resume the lowest-ordinal task whose status is `Initiated`, `Refined`, `Implemented`, or `Validated`.
- If no task is in progress, read `papyrus --json task list --status ToDo`, build the set of `Done` task IDs with `papyrus --json task list --status Done`, and take the lowest-ordinal ready task whose dependencies are all `Done`. Do not reorder the list or ask the user to pick among candidates.
- On resume, read the selected task status and skip completed phases. **Repository preparation is only for a new `ToDo` task; never run it when resuming `Initiated` or later.**
- Papyrus has no `--ready`, `--sort priority`, or `--plain` flags.

```mermaid
flowchart TD
    START([Start]) --> HASID{"Task ID provided?"}
    HASID -->|"Yes"| USEID["Use provided task"]
    HASID -->|"No"| ACTIVE["List tasks; select in-progress by ordinal"]
    ACTIVE --> ACTIVEQ{"Any in-progress task?"}
    ACTIVEQ -->|"Yes"| PICKACTIVE["Resume lowest-ordinal in-progress task"]
    ACTIVEQ -->|"No"| TODO["List ToDo tasks; compute dependency readiness"]
    TODO --> TODOQ{"Eligible task found?"}
    TODOQ -->|"No"| EMPTY["Report no eligible task and stop"]
    TODOQ -->|"Yes"| PICKTODO["Take lowest-ordinal ready task"]

    USEID --> STATUS
    PICKACTIVE --> STATUS
    PICKTODO --> STATUS
    STATUS{"Task status?"}
    STATUS -->|"ToDo: new task"| PREP["Prepare repository"]
    PREP --> INIT["Set Initiated"]
    INIT --> REFINE["task-refiner refines"]
    STATUS -->|"Initiated: resume; skip repository prep"| REFINE
    REFINE --> UIGATE["UI mockups by ui-designer, user-approved, if needed"]
    UIGATE --> SETREFINED["Set Refined"]
    STATUS -->|"Refined"| IMPLEMENT
    SETREFINED --> IMPLEMENT["Implement with android-dev, backend-dev, frontend-dev, or rust-dev"]
    IMPLEMENT --> SETIMPLEMENTED["Set Implemented"]
    SETIMPLEMENTED --> REVIEW["quality-gatekeeper reruns tests and reviews"]
    STATUS -->|"Implemented"| REVIEW
    REVIEW --> PASS{"Review passes?"}
    PASS -->|"No"| SETREFINED
    PASS -->|"Yes"| VALIDATED["Set Validated; print report separately"]
    STATUS -->|"Validated"| APPROVAL["Print report; ask short approval question"]
    VALIDATED --> APPROVAL
    APPROVAL --> APPROVED{"User approves?"}
    APPROVED -->|"Yes"| DONE["Set Done; merge task branch"]
    APPROVED -->|"No; refinement needed"| INIT
    APPROVED -->|"No; implementation can resume"| SETREFINED
    STATUS -->|"Done"| REPORT["Report complete and stop"]
    DONE --> REPORT
```

### Task steps

1. **Resolve task.** Follow the selection rules above. `papyrus task` is the CLI command for task operations; it does not launch agents.
2. **Prepare repository (new tasks only).** For `ToDo`, inspect the working tree and prepare the task branch using git (status, checkout `main`, pull, create `task/<task-id>` if it does not already exist). Reuse an existing branch and preserve existing changes rather than recreating them. Never commit, stash, discard, or otherwise alter uncommitted changes without explicit user approval. If git operations are denied or fail, stop and ask the user to prepare the branch and working tree; never bypass the policy. For any resumed status (`Initiated` or later), skip repository preparation entirely and preserve the current branch and changes.
3. **Refine.** Delegate to `task-refiner`; set status to `Refined` when complete. Skip if already `Refined` or later. If UI design is needed, delegate to `ui-designer` and obtain explicit user approval for every referenced `MOCK` record before `Refined`.
4. **Implement.** Delegate units to `android-dev`, `backend-dev`, `frontend-dev`, or `rust-dev` according to the unit's goals. Record each agent's structured evidence as a Papyrus task comment; set status to `Implemented` when complete.
5. **Review.** Delegate to `quality-gatekeeper` using OpenCode's `subagent` tool. It independently reruns relevant tests, verifies the ticket, and returns a per-criterion evidence table. If incomplete, set status to `Refined`, address findings, and review again.
6. **Approve.** A passing review sets status to `Validated`. Print the gatekeeper report and the acceptance-criteria checklist separately, then ask a short approval question. Set status to `Done` only after explicit approval (or automatically in no-validation mode). If changes are requested, use `Initiated` if refinement is needed, otherwise `Refined` to resume implementation without repository preparation.
7. **Merge.** Once the task is `Done`, merge its branch into `main` with `--no-ff` (commit any uncommitted changes on `task/<task-id>` first; checkout `main`, pull, `git merge --no-ff task/<task-id>`; leave on `main`). Do not push.

## Milestone workflow

The orchestrator loads `milestone-orchestration`. A milestone is a coherent, usable delivery increment defined by `planner`.

```mermaid
flowchart TD
    MS([Milestone orchestration]) --> RESOLVE["Resolve target milestone"]
    RESOLVE --> LOOP{"Remaining executable work?"}
    LOOP -->|"No"| VERSION["next-version: propose RC version for this milestone"]
    VERSION --> COMPLETE["Report milestone complete or blocked"]
    LOOP -->|"Yes"| ACTIVE{"Any in-progress task in milestone?"}
    ACTIVE -->|"Yes"| RESUME["Resume lowest-ordinal in-progress task"]
    ACTIVE -->|"No"| READY["Lowest-ordinal ready ToDo task in milestone"]
    READY --> ELIGIBLE{"Eligible task?"}
    ELIGIBLE -->|"No"| BLOCKED["Report blockers; do not cross milestone"]
    ELIGIBLE -->|"Yes"| TASKORCH["task-orchestration"]
    RESUME --> TASKORCH
    TASKORCH --> OUTCOME{"Task outcome"}
    OUTCOME -->|"Done"| LOOP
    OUTCOME -->|"Blocked / approval pending / review failed"| PAUSE["Pause and report"]
    COMPLETE --> END([Stop])
    BLOCKED --> END
    PAUSE --> END
```

Rules:

- Never take tasks from another milestone.
- A milestone is complete when it has no remaining `ToDo` or in-progress tasks. Milestones have no status; completion is derived from their tasks.
- A milestone may be assigned to a release (`metadata.release`); release auditing and closure still belong to `release-orchestration`.
- If incomplete tasks remain but none is dependency-ready, report blockers and stop.
- Pause for every user approval gate; milestone execution does not bypass task approval, unless the user explicitly requested no-validation mode.
- Before declaring a milestone complete, delegate a lightweight architecture-consistency check to `@architect` (contracts, layering, NFR coverage, ADR status); pause if an ADR is missing or not `Accepted`.
- Before packaging the milestone as an RC, run `next-version` in RC mode to propose the RC version from Done tasks; record it in the milestone report. Do not create tags or modify version files.
- Re-read milestone state after each task.

## Release workflow

The orchestrator loads `release-orchestration`.

**Release definition:** a release is a Papyrus `REL` record titled `Release <version>` (for example `Release 1.0`). Its description carries the release acceptance criteria, and milestones are assigned with `papyrus milestone edit <MS-ID> --release <REL-ID>`. There is no release ticket. `planner` creates the record and assignments. If the project uses a different convention, the release scope must be stated explicitly by the user before orchestration starts.

```mermaid
flowchart TD
    REL([Release orchestration]) --> SCOPE["Resolve release record and assigned milestones"]
    SCOPE --> CHECK{"Every release task Done?"}
    CHECK -->|"No"| INCOMPLETE["Report incomplete tasks; run milestone-orchestration or stop"]
    CHECK -->|"Yes"| CHECKS["Run release-level build and test checks"]
    CHECKS --> TESTS{"Checks pass?"}
    TESTS -->|"No"| FAIL["Stop; report failing checks and owners"]
    TESTS -->|"Yes"| ARCH["architect: ADR/NFR readiness"]
    ARCH --> ARCHOK{"Architecture ready?"}
    ARCHOK -->|"No"| ABLOCK["Stop; report missing ADRs/constraints"]
    ARCHOK -->|"Yes"| SEC["security-officer: security audit"]
    SEC --> SDEC{"Security decision"}
    SDEC -->|"Block"| SBLOCK["Stop; report Critical/High findings"]
    SDEC -->|"Pass / Pass with findings"| VERIFY["quality-gatekeeper verifies release evidence"]
    VERIFY --> VDEC{"Release verified?"}
    VDEC -->|"No"| GBLOCK["Stop; report missing evidence"]
    VDEC -->|"Yes"| NOTES["Record audit; compile release notes"]
    NOTES --> APPROVE["Print report; ask short approval question"]
    APPROVE -->|"Not approved"| CHANGES["Return work to the owning tasks; stop"]
    APPROVE -->|"Approved"| CLOSE["Label release released; report complete"]
    CLOSE --> END([Stop])
```

Rules:

- A release cannot start until every task in its assigned milestones is `Done`.
- A release cannot complete while the security decision is `Block`.
- `Pass with findings` is allowed only when no unresolved Critical or High finding remains; Medium and Low findings are reported with owners and follow-up tickets.
- The release evidence is verified by `quality-gatekeeper` after the audit, with the audit report as evidence. If the release description has no acceptance criteria, state that explicitly and verify its definition of done directly.
- The orchestrator records the audit with `papyrus audit create --title "<REL-ID> security audit" --content "<report>" --audit-type security --reference <REL-ID>`.
- The release report includes: release scope, completed tasks, test/build results, security decision with severity counts, accepted risks, and open follow-ups.
- The orchestrator records completion with `papyrus release edit <REL-ID> --label released --description "<scope + completion note>"`.
- The orchestrator does not create Git tags unless the user explicitly asks and the environment allows it; it reports the recommended tag and command instead.

## Documentation and indexes

- `papyrus browser` is the documentation index for tasks, milestones, releases, requirements, NFRs, rules, glossary terms, decisions, specifications, mockups, and audits.
- `papyrus search "<query>"` searches the corpus.
- Never generate or hand-edit `index.html`; index generator scripts are not used.
- Plain documentation (architecture narratives, domain-model diagrams, business-process diagrams) remains Markdown owned by its agents.

## Resume and interruption

- Task state lives in the Papyrus task status and the repository branch.
- Milestone state is derived from its tasks; no separate milestone state is stored.
- Release state is derived from the release record, its assigned milestones, their tasks, and the latest audit record.
- Re-invoking any orchestration skill reads current state first and resumes from the matching step. Do not recreate branches, discard changes, or restart completed phases.
- Each step is idempotent: check the current status before acting.

## Approval gates

- **Task:** `Done` requires explicit user approval after a passing quality review.
- **Milestone:** each task approval gate applies; milestone completion is reported, not auto-approved.
- **UI mockups:** every referenced `MOCK` record must be `approved` in Papyrus before implementation.
- **Release:** completion requires a passing security audit and explicit user approval.
- A passing review or audit is evidence, not approval.
- **No-validation mode:** when the user explicitly asks to implement a whole milestone without validation/approval, task approval gates are bypassed (a passing review sets `Done` automatically) and execution continues; refinement, implementation, quality review, UI mockup approval, security audit, and stop conditions still apply.
- **Task completion merge:** when a task reaches `Done`, merge its branch into `main` with `--no-ff` (commit pending changes first) and leave the repository on `main`. No push is performed.

## Stop conditions

Always stop and report when:

- no eligible task exists;
- the milestone is empty or blocked;
- a new feature or requirement has unresolved requirements or validation gaps;
- a task is blocked on user input or approval;
- quality review fails without a clear fix;
- the security audit returns `Block`;
- a dependency cycle or cross-milestone ordering defect is found;
- the user interrupts or withholds approval.

## Papyrus and delegation

- All backlog and managed-document reads and writes use the Papyrus CLI via the `papyrus` skill.
- Subagent launches use OpenCode's `subagent` tool, not the Papyrus CLI's `task` command.
- The orchestrator never edits `backlog/` files, managed document files, or project source/docs directly.
- Plan changes (scope, priority, milestone order, dependencies) are routed to `planner`; ticket scope changes are routed to `task-refiner`.
- New features and new or changed requirements are routed to `requirements-engineer` first; `planner` is called only after requirements are validated.
- Papyrus has no priority field and no `--ready` flag. Use `ordinal`, `dependencies`, and JSON state reads.

## References

- [task-orchestration skill](../../skills/task-orchestration/SKILL.md)
- [milestone-orchestration skill](../../skills/milestone-orchestration/SKILL.md)
- [release-orchestration skill](../../skills/release-orchestration/SKILL.md)
- [security-audit skill](../../skills/security-audit/SKILL.md)
- [next-version skill](../../skills/next-version/SKILL.md)
- [papyrus skill](../../skills/papyrus/SKILL.md)
