---
name: ui-design
description: 'Run the Phase 4 UI design task: maintain UI specifications, create at most one clickable mockup per milestone, and obtain the user verification that approves the mockup.'
argument-hint: 'Provide a UI design task or milestone ID.'
user-invocable: true
disable-model-invocation: false
---

# UI Design

## Outcome

Updated UI specification entries and at most one approved clickable mockup for the milestone, associated with the affected task, showing the current feature's happy path per platform. The mockup is `approved` only after the user verified it.

## When to use

- The UI design task of a milestone is executed in Phase 4.
- A view, screen, navigation, or layout changes.

Do not use this skill to define requirements, business rules, validation semantics, backend behavior, production styling, or implementation technology.

## Prerequisites

- Load `managed-records` and `manage-ui-mockups`.
- Read the changed requirements, business rules, glossary, domain model, and the affected task.

## Artifacts

- **UI Specification** — `UI` records accessed via `manage-ui-specs`. Each entry has identifier, title, status, and body. The body describes layout regions, navigation, UI states, interaction behavior, presentation of validation and messages, and platform differences. It never contains technology or library choices.
- **UI Mockup** — `MOCK` records accessed via `manage-ui-mockups`. At most one mockup per milestone, as a single self-contained HTML review file. It is associated with the affected task and one or more UI specifications.
- A mockup does not exist for an interface no specification describes.
- Approval happens on the mockup, not on the UI specification text.

## Procedure

1. **Read the scope** — read the changed `REQ`/`NFR`, business rules, glossary terms, domain artifacts, the affected task, and existing UI specifications.
2. **Resolve the UI specification** — create or update the `UI` records that describe the views in scope (manage-ui-specs). Keep entries `draft` until the user verified the mockup.
3. **Enumerate the happy path** — list the views/screens the current feature's happy path passes through, per platform. When the feature builds on an earlier mockup, include only that mockup's basic views as minimal context.
4. **Create the MOCK record** — create the mockup record (manage-ui-mockups). Capture the returned `MOCK` ID and file path. Never choose, reuse, or renumber an ID by hand, and never split one ID across files or platforms.
5. **Build the review file** — load `manage-ui-mockups` and follow its format: a review landing (task plus one button per platform) and one clickable prototype per platform. Keep the metadata comments intact; author only the HTML body.
6. **Validate** — run `skills/manage-ui-mockups/scripts/ensure_wireframe_css.sh` and `skills/manage-ui-mockups/scripts/validate_mockups.sh`; fix every reported issue.
7. **Present for verification** — show the single review file, its sources, and its platform/view coverage to the caller for user review. Keep the managed status `pending`. Do not treat silence, another reviewer, or approval of another mockup as approval.
8. **Record approval** — after the caller reports explicit user approval, set the mockup to `approved` (manage-ui-mockups). On requested changes, revise the file and present it again.
9. **Report** — MOCK ID, file path, platforms, happy-path views, active elements, `UI` IDs, references, validation result, and approval status.

## Rules

- Layout only: no libraries, frameworks, CSS frameworks, component libraries, or implementation technology.
- Every active element (buttons, inputs, links, tabs, menus, table actions, modals) must be drawn and positioned as it must be developed.
- Neutral wireframes: grayscale, no brand colors, no final visual design.
- One mockup per milestone, even when it spans multiple platforms. The reviewer never opens a second file.
- A prototype shows only the current feature's happy path. No variants, alternate states, or error states.
- Do not implement production frontend code.
- Do not modify requirements, business rules, or the Technical specification.
- `manage-ui-mockups` owns the `MOCK` ID, filename, and metadata comments. Do not hand-edit the metadata comments.
- Do not create a mockup README table; use the manage-ui-mockups skill.

## Stop conditions

- Layout, states, or active elements are unclear: ask targeted questions before designing.
- No UI specification describes the interface: write the specification first.
- The user denies the mockup: record the requested changes, revise, and present again. Implementation of the affected UI does not start.

## Report format

- **Task/milestone**: ID and title.
- **UI specifications**: `UI` IDs and status.
- **Mockup**: `MOCK` ID, single file path, status.
- **Review contents**: landing and one prototype per platform.
- **Platforms and views**: per platform.
- **Active elements drawn**.
- **Sources**: `REQ`/`NFR`, rules, task IDs.
- **Validation**: script result.
- **User verification**: pending / approved / changes requested.
- **Open questions**: or `none`.

## Completion checks

- Every affected view has a UI specification.
- At most one mockup exists for the milestone, with one `MOCK` ID and one file.
- The happy path is covered per platform and every active element is drawn.
- Validation scripts pass.
- The mockup was presented to the user and is `approved` only after explicit approval.
- No technology, library, production styling, or backend behavior was specified.
