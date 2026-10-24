---
name: project-initialization
description: 'Use ONLY from @project-planner when asked to initialize a new or existing project: gather specialist intake needs, create an approved base folder structure, and verify Backlog.md CLI readiness.'
user-invocable: false
disable-model-invocation: false
---

# Project Initialization

## Outcome

Prepare a project for the requirements → planning → feature specification → implementation workflow by gathering project context, consulting the documentation owners, creating only the authorized missing base folders, and confirming that Backlog.md can operate in the target project.

This skill is owned and used only by `@project-planner`. It is for project bootstrap, not ordinary backlog planning. It does not create substantive requirements, feature specifications, business rules, architecture decisions, milestones, or feature tickets.

## Required safeguards

- Identify the target project root before making changes. If the current working directory is clearly the target repository root, state that assumption; otherwise ask the user for the path.
- Inspect the target read-only before creating anything, including hidden entries, repository state, existing documentation, and backlog configuration. Preserve all existing, untracked, ignored, or modified content.
- Before creating each folder, inspect every existing component of its path. If any component is a file, symlink, or unexpected path, stop on that path and ask before proceeding.
- Reuse existing folders and conventions. Create only missing, authorized paths. Never overwrite, move, rename, delete, or normalize existing project content.
- Do not create stack-specific source folders until the platform and technology are known and the user wants that scaffold.
- Do not invent project scope, business priorities, requirements, technical choices, or architecture decisions. Mark unknowns and blockers explicitly.
- Use the `backlog-md` skill and Backlog.md CLI for all backlog initialization and operations. Never hand-create or edit Backlog-managed files or configuration.
- Do not install software or run dependency setup commands. If the Backlog.md CLI is unavailable, report the blocker and ask the user how to proceed.

## Procedure

### 1. Confirm the initialization target and scope

Confirm the target root and whether this is a new, existing, or partially initialized project. Ask whether the user also expects a delivery plan now or only project bootstrap. Do not create any folders or run modifying setup commands until the user approves the proposed structure in step 4. Do not create milestones or feature tickets as part of bootstrap unless separately requested and a validated planning baseline exists.

### 2. Inspect the project before proposing changes

Inventory the project root, including hidden entries and repository metadata. Review `git status --short` when it is a Git repository, and inspect ignored entries under paths proposed for initialization where needed to avoid collisions. Record the existing presence and status of all planned target paths. Do not read potentially sensitive file contents merely because they are ignored or untracked. Identify existing source, documentation, conventions, project manifests, and Backlog.md files/configuration. Classify the project as:

- **New/empty:** no existing project-specific structure beyond repository metadata.
- **Existing:** project source, documentation, configuration, or backlog artifacts are present.
- **Partial/ambiguous:** conventions or initialization state are mixed or unclear.

Do not call a repository empty just because it has no application source. If the target is partial or ambiguous, preserve its conventions and ask before resolving conflicts.

### 3. Ask documentation owners what they need

Use the `task` tool to consult these agents separately; request intake needs only, not file changes. The project-planner agent is configured to delegate and ask the user. If delegation is unavailable or denied, stop and report which specialist consultation is blocked; do not claim it was completed or substitute assumptions:

1. `requirements-engineer` — ask what project information and sources are needed to draft and validate business requirements and NFRs.
2. `business-analyst` — ask what product/domain, user, workflow, UI, data, and integration context is needed for future feature specifications and ticket refinement.
3. `architect` — ask what system-boundary, technology, integration, quality-attribute, deployment, and decision-authority information is needed for architecture documentation.

Combine their responses into one concise questionnaire for the user. Ask only for information not already established by reliable project artifacts or their answers. At minimum, clarify:

- Project purpose, target users/stakeholders, intended first outcome, scope, and explicit exclusions.
- Main user/business needs and known workflows, rules, and exceptions; source/owner for each input where known.
- Priority or criticality and important quality attributes, measurable targets, and verification expectations when available.
- Platforms/channels, data/API needs, known systems to integrate, and solution boundaries.
- Required or prohibited technologies, compatibility, legal/policy, deployment, operations, and other constraints; distinguish decisions from preferences.
- Existing decisions and documents, decision/approval owners, unresolved questions, and whether any unknown blocks requirements or architecture work.

Wait for the user's answers before creating folders or running `backlog init`. Record which answers are confirmed, undecided, or still open. If material questions remain, pause and ask whether the user wants to proceed with those explicitly listed unknowns; do not treat silence or a partial response as approval.

Keep initialization-level questions separate from detailed feature questions. The business analyst should elicit screen-level behavior, complete API payloads, error cases, and testable feature acceptance criteria during feature refinement. Route API-contract specifications and multi-solution integration decisions to the architect.

### 4. Propose and get approval for the base folder structure

Use project conventions where they exist. Otherwise propose the shared documentation structure used by this workflow:

```text
docs/
├── requirements/
│   └── non-functional/
├── specifications/
├── business-rules/
├── domain-model/
│   └── object-model/
├── business-processes/
└── architecture/
```

The Backlog.md CLI owns its own folder and configuration structure. Do not create those paths manually. Propose stack-specific source folders only after platform choices are confirmed.

Before writing, show the user the proposed structure adapted to the inspected project. For every path, identify whether it will be **reused**, **created**, or **deferred**, and state why. Ask the user to approve the proposal. Wait for explicit approval before creating any folders; if the user requests changes, revise the proposal and obtain approval for the revised structure. If approval is not given, make no filesystem changes.

After approval, create only the missing paths the user approved. Recheck each path and its ancestors immediately before creation. Do not create placeholder requirement/specification/ADR files or `.gitkeep` files unless the approved proposal or repository convention calls for them. The specialist agents own their substantive documentation and generated indexes.

### 5. Check and prepare Backlog.md

Load the `backlog-md` skill before any Backlog operation. From the confirmed project root:

1. Check CLI availability and version with `backlog --version`; inspect supported commands with `backlog --help`. Consult `backlog help <command>` for exact command details rather than guessing flags.
2. Check whether Backlog.md already works in this project using read-only commands: `backlog task list --plain` and `backlog milestone list --plain`. An empty result is acceptable; successful project-scoped queries are readiness evidence.
3. If already initialized and those reads succeed, leave its configuration and backlog contents unchanged.
4. If the CLI is installed but the project is not initialized, inspect the documented `backlog init` behavior. Explain the setup and any files/configuration it will create or change, then obtain explicit approval before running `backlog init` in the confirmed project root. Do not rerun it when an existing configuration works.
5. After initialization, repeat both read-only list commands and verify they succeed. Do not create milestones, tasks, or docs merely to make the checks non-empty.
6. If the CLI is unavailable or setup/read checks fail, report Backlog.md as **blocked** with the command and error. Do not install the CLI, switch tools, or modify Backlog-managed files without user approval.

Report readiness accurately: distinguish **ready** (CLI available and both project-scoped reads succeed), **initialized but unverified** (setup completed but checks fail), and **blocked** (CLI or setup unavailable). Do not claim readiness based only on the executable or version.

### 6. Handoff and report

After scaffolding, re-check every planned path and confirm that only the intended missing folders were added. If using Git, compare `git status --short` and ignored entries under the planned paths with the pre-initialization state. Investigate any unexpected changes; preserve pre-existing untracked, ignored, and modified files. Do not try to revert unexpected changes automatically.

Report:

- Target root and project classification.
- Specialist agents consulted and their outstanding input needs.
- Folders created, reused, or intentionally deferred.
- Backlog.md version, setup action (if any), and results of both readiness checks.
- Decisions still needed, blockers, and clear next handoffs to requirements-engineer, business-analyst, and architect.
- Whether a separate project-planning step can begin. Do not mark requirements validated simply because initialization inputs were collected.

## Completion checks

- Target root was explicit or confirmed before any writes.
- Existing project content and conventions were inspected and preserved.
- Each documentation owner was consulted for its intake needs.
- The user approved the proposed structure before implementation; only approved, missing shared folders were created, with no specialist-owned substantive documents invented by the planner.
- Backlog.md was verified through successful project-scoped read commands, or clearly reported as blocked/unverified.
- Any planned milestones or feature tickets are deferred unless separately requested and supported by validated requirements.
