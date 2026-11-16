---
name: task-refinement
description: 'Refine one planned task into a self-contained, implementation-ready work item after the architecture, specification, UI, and test cases are settled. Implements the refinement task kind of Phase 4.'
argument-hint: 'Provide a task ID (e.g. TASK-0042).'
user-invocable: true
disable-model-invocation: false
---

# Task Refinement

## Outcome

One task has a complete, self-contained description, explicit assumptions, tracked dependencies, testable acceptance criteria, and a definition of done. The task is execution-ready, or reported as blocked with the open questions.

## When to use

- The refinement task of a milestone is executed in Phase 4.
- A planned task is ambiguous, incomplete, or missing structure before implementation.

Do not use this skill to create tasks, plan milestones, write implementation code, or change dependencies/ordinals.

## Prerequisites

Load `papyrus`. Refinement does not start before all hold:

- the architecture impact assessment is settled and the architecture is user-verified;
- the Technical specification conformance is verified by `architect`;
- the UI design task, when planned, is `Done` and its mockup is `approved`;
- the test design task is `Done` and its test cases are `approved`;
- the task's dependencies are `Done`.

If a prerequisite is missing, stop and report.

## Procedure

1. **Read the target task** — `papyrus task view <TASK-ID>`. Read the full description, acceptance criteria, references, dependencies, and milestone.
2. **Read the inputs** — the linked `REQ`/`NFR`, `RUL`, Technical specification, UI specification, approved mockups, approved test cases, decisions, and domain artifacts.
3. **Audit the task** — identify missing or weak scope, behavior, assumptions, dependencies, acceptance criteria, and definition of done. Check that the task is traceable to its requirement or request.
4. **Ask targeted questions** — clarify user-visible behavior, boundaries, data, validation, errors, and verification. Do not mark the task execution-ready while a material question is open. Do not turn assumptions into requirements.
5. **Complete the task fields** through Papyrus:
   - `papyrus task edit <TASK-ID> --description "<scope, assumptions, dependencies, and definition of done>"`;
   - `papyrus task edit <TASK-ID> --ac "<criterion>"` for each testable acceptance criterion;
   - `papyrus task edit <TASK-ID> --reference <REQ-ID> --documentation <path>` for traceability;
   - `papyrus task edit <TASK-ID> --depends-on <TASK-ID>` for dependencies.
6. **Split only when needed** — if the task is too broad for one implementation unit, propose an implementation split. Do not change dependencies, ordinals, or milestone scope yourself; report the proposed split to the orchestrator so `planner` can update the plan.
7. **Report readiness** — execution-ready yes/no, changes made, assumptions, open questions, and any proposed split.

## Rules

- The task and its acceptance criteria are the implementation contract. Requirement and specification links provide context and rationale; they do not substitute for task content.
- Papyrus has no notes, plan, or definition-of-done field. Put the definition of done in the description or express it as acceptance criteria.
- Do not change the task's milestone, ordinal, dependencies, or scope beyond refinement. Scope, dependency, and ordinal changes go to `planner`.
- Do not delegate UI design, test design, domain artifacts, or architecture work; those are separate milestone tasks. Report a missing input instead.
- Do not edit requirements, rules, glossary, domain model, architecture, Technical specification, UI specifications, mockups, test cases, or source code.
- All task changes go through the Papyrus CLI; never edit task records directly.
- Flag any requirement or behavior not traceable to documentation as an open question.

## Stop conditions

- A prerequisite artifact is missing or unapproved: stop and report.
- A material behavior, scope, or verification question is unanswered: the task is not execution-ready.
- A specification or requirement inconsistency is found: report it; do not resolve it by guessing.
- The task needs a dependency, ordinal, or milestone change: report it to the orchestrator for `planner`.

## Report format

- **Task**: ID and title.
- **Execution-ready**: yes / no, with blockers.
- **Changes made**: description, acceptance criteria, references, dependencies.
- **Assumptions**: list or `none`.
- **Open questions**: list or `none`.
- **Proposed split**: tasks and dependencies, or `none`.
- **Next action**: who does what next.

## Completion checks

- The task has a clear, self-contained description with concrete scope.
- Acceptance criteria are specific, testable, and numbered.
- Assumptions and dependencies are explicit.
- A definition of done is present.
- Every claim is traceable to documentation, user input, or an open question.
- No implementation detail, dependency change, ordinal change, or milestone change was made.
- All changes were made through the Papyrus CLI.
