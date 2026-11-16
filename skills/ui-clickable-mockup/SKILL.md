---
name: ui-clickable-mockup
description: 'Generate a single self-contained HTML review package for a milestone UI design task: a review landing and clickable per-platform prototypes, saved as one Papyrus MOCK record under docs/specifications/ui/mockups/, using a shared wireframe.css.'
argument-hint: 'generate the review package for the create-order flow (MOCK-0010); simulate the checkout scenario'
user-invocable: true
disable-model-invocation: false
---

# UI Clickable Mockup

## Outcome

Produce **one** interactive, wireframe-styled HTML file per MOCK record that a reviewer can open and review without navigating between files. The file contains two review contents:

1. **Review landing** — the affected task under review, plus one button per platform prototype.
2. **Platform prototypes** — one clickable prototype per platform, so usability can be tested view by view.

Saved as a Papyrus `MOCK` record under `docs/specifications/ui/mockups/`, sharing `wireframe.css`. It demonstrates layout and interaction flow only; it conveys no library, framework, or technology choice. Papyrus owns the MOCK id and metadata comments; the designer authors the HTML body.

## When To Use

- A requirement or specification describes a view/screen whose layout must be visualized for stakeholders or implementers.
- A requirement or specification describes a multi-step flow or scenario that must be clickable for review.
- A UI design task needs one review artifact covering several views and several platforms.
- The `@ui-designer` agent is asked to design a mockup.

Do not use this skill for:
- Business process/state diagrams (use `business-process-diagramming` / `state-diagram-creation`).
- Production frontend implementation (use `frontend-dev`).
- Design rationale decks: this skill produces landing + prototypes only.

## Location

- All mockups live in `docs/specifications/ui/mockups/`.
- Papyrus creates the record and file with `papyrus ui-mockup create --task <TASK-ID> --spec <UI-ID> "<title>"`.
- Papyrus owns the MOCK id, filename, and metadata comments. The designer fills the HTML body.
- Shared stylesheet: `docs/specifications/ui/mockups/wireframe.css` (copied from the skill assets).
- Base template: `skills/ui-clickable-mockup/templates/mockup.html`.
- Stylesheet helper: `skills/ui-clickable-mockup/scripts/ensure_wireframe_css.sh [mockups-dir]`.

## Single-file rule

- **One HTML file is exactly one MOCK id, and one MOCK id is exactly one file.** Never put several MOCK ids in one file, and never split one MOCK id across files or platforms.
- At most one mockup per milestone: one MOCK record and one file/id. Every view of the current feature goes in that file; never split a milestone across files or IDs.
- All platforms of a mockup live inside its single file; the landing page exposes one button per platform.
- The reviewer never needs to open another HTML file to review that MOCK id.

## Format

Each file follows this structure:

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'self' file: 'unsafe-inline'; script-src 'unsafe-inline'; img-src data:; base-uri 'none'; form-action 'none'">
<title>MOCK-xxx — <Name></title>
<link rel="stylesheet" href="wireframe.css">
</head>
<body data-mock-id="MOCK-xxx">
  <header class="wf-chrome">Review links: Overview, one per platform</header>

  <!-- 1. Review landing: task + one card/button per platform prototype -->
  <section class="wf-review wf-index" data-review="index" data-screen="index">...</section>

  <!-- 2. One prototype block per platform, each with its own screens -->
  <div class="wf-proto" data-platform="web">
    <nav class="wf-proto-nav">one link per view</nav>
    <section class="wf-screen" data-platform="web" data-screen="list">...</section>
    ...
  </div>

  <script>/* hash router, screen switcher */</script>
</body>
</html>
```

Conventions:
- Navigation is hash-based: `#index`, `#<platform>`, `#<platform>/<view>` (for example `#web/order-list`). Use plain `<a href="#...">` links for review navigation so browser back/forward works.
- Within a prototype, in-app actions carry `data-goto="<view-id>"`; they switch to that view of the current platform.
- View ids are platform-scoped: the same id (`list`, `detail`) may exist once per platform.
- Every active element (buttons, inputs, links, tabs, table actions, modals) MUST be drawn and positioned where it will be implemented.
- Use the wireframe CSS classes (`wf-*`) for layout; no inline styles for colors beyond the wireframe palette.
- No external resources, no network calls, no form submission (`form-action 'none'`).
- Neutral grayscale only; no brand colors, fonts, or component library hints.
- The `<title>` includes the MOCK id and name.
- Keep the Papyrus metadata comments at the top of the file unchanged. They are the record link; update them through `papyrus ui-mockup edit`, not by hand.

## 1. Review landing

- Header block shows the **affected task** (id and title) and the sources (REQ ids, specifications).
- One card/button per platform prototype — shows the platform and its view count, and opens the first view of that platform.
- The landing is scaffolding for review, not part of the design.

## 2. Platform prototypes

- One `.wf-proto` block per platform (`data-platform`), each with a view navigation band (`.wf-proto-nav`) listing every view of that platform.
- One `.wf-screen` per happy-path view, with `data-platform` and `data-screen`; the first view is shown by default.
- Wrap the views in a platform-appropriate frame: `.wf-frame--mobile` (phone), `.wf-frame--tablet`, or `.wf-frame--desktop`.
- Draw all elements and wire interactions between views with `data-goto`.
- Platforms in the landing, the top navigation, and the prototype blocks MUST match.

### Prototype scope

- A prototype shows **only the current feature** described by the task; do not redraw unrelated parts of the application.
- If the feature builds on a previous mockup, keep only that mockup's **basic views** as minimal context: no extra detail, no variants, and no re-design of the earlier feature.
- Show the **happy path only**: one primary success flow through the feature. Do not add alternate states, edge cases, error/empty states, or design variations.
- Draw only the elements needed to walk that happy path; every active element on those views must still be drawn where it will be implemented.

## Reviewer chrome (top control band)

- Render a `<header class="wf-chrome">` with links to the Overview and each platform.
- The chrome is **scaffolding for reviewers, NOT part of the mockup design**: style it distinctly (dark band) and label it as review scaffolding.
- Do not count the chrome toward layout spacing of the designed screens; it sits above them.

## Numbering

- Papyrus allocates the next `MOCK-xxx` id and filename. Never choose, reuse, or renumber an id by hand.
- One file is exactly one MOCK id. Never split an id across files or platforms, and never put two ids in one file.
- At most one mockup per milestone: one MOCK record and one review file. Include every view of the current feature in that single file; do not create additional MOCK records for the same milestone.

## Registry

Papyrus is the registry. Do not create or maintain `README.md` registry tables.

- List and inspect records with `papyrus ui-mockup list` and `papyrus ui-mockup view <MOCK-ID>`.
- Status starts at `pending`. Set `approved` only after explicit user approval.
- Use `papyrus ui-mockup edit <MOCK-ID> --status approved` or `--status deprecated`.
- Record task and specification references at creation time with `--task` and `--spec`; update them with `papyrus ui-mockup edit`.

## Procedure

1. **Read sources** — Read requirements, specification, and affected task to understand the feature, its happy path, screens, active elements, and target platform(s).
2. **Enumerate views** — List the views/screens of the current feature per platform that the happy path passes through; these become prototype screens and chrome links. For a feature built on an earlier mockup, list only that mockup's basic context views.
3. **Create the Papyrus record** — If no `UI` specification exists for the view, create one with `papyrus ui-spec create`. Then run `papyrus ui-mockup create --task <TASK-ID> --spec <UI-ID> "<title>"`. Capture the returned `MOCK-xxx` id and file path.
4. **Prepare the file** — Run `scripts/ensure_wireframe_css.sh`. Keep the Papyrus metadata comments at the top of the created HTML file unchanged; replace only the body content with the review landing and platform prototypes from the template.
5. **Fill the landing** — Replace the task and source placeholders; add one card per platform.
6. **Build the prototypes** — One `.wf-proto` per platform with the happy-path views, a view navigation band, a device frame, and working `data-goto`/hash links.
7. **Validate** — Run `scripts/validate_mockups.sh` and open the file to confirm landing and prototype navigation work with no console errors.
8. **Reference** — Report the MOCK id to the caller. The orchestrator records it on the affected task with `papyrus task edit <TASK-ID> --documentation <mockup-path>` or a task comment; the specification owner links it.
9. **Review** — Present the single file to the user; keep Papyrus status `pending` until explicit approval.
10. **Approve** — After explicit user approval, run `papyrus ui-mockup edit <MOCK-ID> --status approved`.

Do not hand-edit the Papyrus metadata comments (`<!-- mockup-id: ... -->`, `<!-- status: ... -->`, `<!-- task: ... -->`, `<!-- specs: ... -->`, `<!-- refs: ... -->`). Update them through Papyrus.

### Migrating per-platform files

If a milestone already has one file per platform, merge them into a single file under the existing lowest MOCK id: move every platform's screens into it, deprecate the extra Papyrus `MOCK` records with `papyrus ui-mockup edit <ID> --status deprecated`, and note the merged IDs in the surviving record's references. Do not keep a separate index page.

### Removing a design deck

If an existing mockup still contains a design deck (`data-review="deck"`), delete the deck section, its slide controls, its inline paging script, and its chrome/landing links when the file is next revised. The file must contain only the review landing and the platform prototypes.

## Completion Checks

- [ ] The MOCK record exists in Papyrus and is linked to the task and UI specification.
- [ ] Each MOCK id is exactly one file, and each file carries exactly one MOCK id.
- [ ] The Papyrus metadata comments are intact.
- [ ] Landing shows the affected task and one button per platform prototype.
- [ ] No design deck section is present in the file.
- [ ] Every platform has a clickable prototype with its happy-path views and a view navigation band.
- [ ] The prototype shows only the current feature; earlier-mockup views appear only as basic context, with no details or variants.
- [ ] All active elements are drawn; prototype actions navigate.
- [ ] `wireframe.css` present and up to date in the mockups dir.
- [ ] No external resources, no network calls, no technology hints.
- [ ] Papyrus status is `pending` before approval and `approved` only after explicit user approval.
- [ ] `validate_mockups.sh` reports no errors.
- [ ] MOCK id reported for the feature specification and added to the affected task.

## Output Template

After creation, summarize:

- **Mockup**: MOCK-xxx — <name>
- **File**: path returned by Papyrus
- **Platforms**: <web / android / ...>
- **Prototype views**: <platform: views>
- **Scope**: current feature happy path; earlier-mockup context views (if any)
- **Sources**: <REQs, specs, tasks>
- **Papyrus status**: pending / approved
- **Approval**: pending / approved
