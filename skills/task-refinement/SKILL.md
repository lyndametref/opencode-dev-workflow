---
name: task-refinement
description: 'Refine a whole milestone in Phase 4: analyse architecture impact, produce the Technical specification and technical decisions, design the UI and mockups when needed, write the Gherkin test cases, and create the development tasks with precise acceptance criteria. Fulfilled by task-refiner with multiple skills.'
argument-hint: 'Provide the refinement task ID or the milestone ID (e.g. MS-001).'
user-invocable: true
disable-model-invocation: false
---

# Task Refinement

## Outcome

One milestone is implementation-ready: the affected Technical specification sections and technical decisions exist, the UI specifications and at most one approved mockup exist or the no-UI outcome is recorded, the Gherkin test cases are approved, and one or more development tasks carry precise, testable acceptance criteria. The refinement task is `Done`, or reported as blocked with the open questions.

## When to use

- The refinement task of a milestone is executed in Phase 4.
- The milestone covers architecture impact, UI design, test-case design, and development task creation.

Do not use this skill to implement code, plan milestones, verify the milestone, audit the release, or change milestone scope.

## Prerequisites

Load `manage-tasks`; read linked artifacts through their `manage-*` skills. Refinement does not start before all hold:

- the requirements are `verified` and the milestone acceptance criteria are recorded;
- the user's ADRs are read and accepted as constraints;
- no product or business decision needed by the milestone is open;
- the milestone has exactly one refinement task and at least one planned development task.

If a prerequisite is missing, stop and report.

## Inputs

- The milestone, its acceptance criteria, and its planned tasks.
- The changed `REQ`/`NFR`, `BR`, glossary terms, domain artifacts, and user ADRs.
- The existing Technical specification, UI specifications, mockups, test cases, and decisions.

## Procedure

### 1. Read the milestone

Read the milestone and its refinement task (manage-milestones, manage-tasks). Read the changed requirements, business rules, glossary, domain artifacts, user ADRs, Technical specification, UI specifications, mockups, and test cases.

### 2. Analyse the architecture impact

Load `architecture-impact-assessment`. For the milestone as a whole:

- decide the technical approach and its impact;
- create or update the affected `TECH` sections through `technical-specification`;
- record technical decisions as `ADR` records through `manage-decisions`;
- record `no architecture impact` explicitly with the reason when that is the outcome.

The user's ADRs are binding; a technical decision may refine them but never supersede them.

### 3. Design the UI, when needed

Load `ui-design` when the milestone has UI impact:

- create or update the UI specifications;
- produce at most one mockup for the milestone;
- present the mockup for the user's verification; the mockup is `approved` only after explicit approval.

When the milestone has no UI impact, record that explicitly instead of producing UI artifacts.

### 4. Design the test cases

Load `test-design`:

- write one Gherkin scenario per verification scenario for every changed requirement and business rule;
- trace every test case to its requirement and rules;
- present the test cases for the user's verification; they are `approved` only after explicit approval.

### 5. Create the development tasks

From the architecture impact analysis, the Technical specification, the test cases, and the milestone acceptance criteria:

1. Complete the planned development tasks and create additional tasks when the milestone needs them.
2. Give every development task a self-contained scope, behavior, references, and precise acceptance criteria through `manage-tasks`.
3. Link each task to its `TECH` subsections, `REQ`/`NFR`, `BR`, test cases, and decisions.
4. Set dependencies and ordinals inside the milestone. Any change to milestone scope, or any dependency or ordinal change that alters the plan, is reported to the orchestrator for planning.

### 6. Confirm the milestone is ready

Refinement is `Done` only when all hold:

- the affected Technical specification sections and technical decisions exist;
- the UI artifacts exist and the mockup is approved, or the no-UI outcome is recorded;
- the test cases exist and are approved;
- at least one development task exists, with precise acceptance criteria and references;
- every open material question is answered or reported as a blocker.

### 7. Report

Report the `TECH`/`SPEC` IDs, `ADR` IDs and statuses, `UI`/`MOCK` IDs and approval status, `TC` IDs and approval status, created or updated development task IDs, open questions, and readiness.

## Rules

- The milestone is the unit of refinement; a development task alone is not.
- The Technical specification, UI specifications, mockups, and test cases are yours to write through their `manage-*` skills. Never edit requirements, business rules, glossary, domain model, or source code.
- Every technical decision goes through `manage-decisions`; never edit decision files by hand.
- Every development task acceptance criterion is specific, testable, and traceable to a requirement, rule, or milestone criterion.
- Do not change the milestone acceptance criteria or scope.
- Do not implement, review, audit, or change task status; the orchestrator owns status.
- Do not turn assumptions into requirements. Ask targeted questions; a material open question means refinement is not ready.
- Use only project-local `./.tmp/` for scratch work and remove it before finishing.

## Stop conditions

- A prerequisite artifact is missing or unapproved: stop and report.
- A material behavior, scope, or verification question is unanswered: refinement is not ready.
- A requirement or rule inconsistency is found: report it; do not resolve it by guessing.
- The change requires milestone scope, dependency, or ordinal changes outside refinement: report it to the orchestrator.
- A user ADR is contradicted by the technical approach: stop; the user decides.

## Report format

- **Milestone / refinement task**: IDs and titles.
- **Architecture impact**: affected building blocks and `TECH` IDs, technical `ADR` IDs and statuses, or `none` with the reason.
- **UI**: `UI` IDs, `MOCK` ID and approval status, or `no UI impact`.
- **Test cases**: `TC` IDs, coverage of changed requirements and rules, approval status.
- **Development tasks**: task IDs, scope, acceptance criteria count, dependencies, ordinals.
- **Blocked**: open questions or `none`.
- **Refinement task**: ready / blocked.

## Completion checks

- The milestone was refined as a whole.
- Architecture impact was assessed and recorded, including the explicit `none` case.
- Technical decisions are recorded as ADR decisions and respect the user's ADRs.
- UI artifacts exist and are approved, or no UI impact is recorded.
- Every changed requirement and rule has an approved Gherkin test case.
- Every development task has precise, testable acceptance criteria and references.
- No code was written, no milestone scope changed, and no task status was set.
