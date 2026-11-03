---
name: ui-clickable-mockup
description: 'Generate a single self-contained HTML review package per ticket: a review landing, a design deck with view rationale, and clickable per-platform prototypes, saved as MOCK-XXXX-<slug>.html under docs/specifications/ui/mockups/, using a shared wireframe.css.'
argument-hint: 'generate the review package for the create-order flow (MOCK-0010); simulate the checkout scenario'
user-invocable: true
disable-model-invocation: false
---

# UI Clickable Mockup

## Outcome

Produce **one** interactive, wireframe-styled HTML file per ticket that a reviewer can open and review without navigating between files. The file contains three review contents:

1. **Review landing** — the ticket under review, plus one button per review content item.
2. **Design deck** — slides presenting every view, what it shows, and why it was designed this way.
3. **Platform prototypes** — one clickable prototype per platform, so usability can be tested view by view.

Saved as `MOCK-XXXX-<slug>.html` under `docs/specifications/ui/mockups/`, sharing `wireframe.css`. It demonstrates layout and interaction flow only; it conveys no library, framework, or technology choice.

## When To Use

- A requirement or specification describes a view/screen whose layout must be visualized for stakeholders or implementers.
- A requirement or specification describes a multi-step flow or scenario that must be clickable for review.
- A ticket needs one review artifact covering several views and several platforms.
- The `@ui-designer` agent is asked to design a mockup.

Do not use this skill for:
- Business process/state diagrams (use `business-process-diagramming` / `state-diagram-creation`).
- Production frontend implementation (use `frontend-dev`).

## Location

- All mockups live in `docs/specifications/ui/mockups/`.
- File naming convention: `MOCK-XXXX-<kebab-case-slug>.html`, one file per ticket.
- Shared stylesheet: `docs/specifications/ui/mockups/wireframe.css` (copied from the skill assets).
- Base template: `skills/ui-clickable-mockup/templates/mockup.html`.
- Scaffold: `skills/ui-clickable-mockup/scripts/new_mockup.sh [mockups-dir] [slug] [name] [platform]`.

## Single-file rule

- **One HTML file is exactly one MOCK id, and one MOCK id is exactly one file.** Never put several MOCK ids in one file, and never split one MOCK id across files or platforms.
- By default a ticket has **one** mockup, so one ticket maps to one file/id. If a ticket genuinely needs several distinct design packages, each package gets its own file and its own MOCK id.
- All platforms of a mockup live inside its single file; the landing page exposes one button per platform, plus one button for the design deck.
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
<title>MOCK-XXXX — <Name></title>
<link rel="stylesheet" href="wireframe.css">
</head>
<body data-mock-id="MOCK-XXXX">
  <header class="wf-chrome">Review links: Overview, Design deck, one per platform</header>

  <!-- 1. Review landing: ticket + one card/button per content item -->
  <section class="wf-review wf-index" data-review="index" data-screen="index">...</section>

  <!-- 2. Design deck: slides; cover + one per view + decisions -->
  <section class="wf-review wf-deck" data-review="deck" data-screen="deck">
    <article class="wf-slide" data-slide="1">...</article>
    ...
  </section>

  <!-- 3. One prototype block per platform, each with its own screens -->
  <div class="wf-proto" data-platform="web">
    <nav class="wf-proto-nav">one link per view</nav>
    <section class="wf-screen" data-platform="web" data-screen="list">...</section>
    ...
  </div>

  <script>/* hash router, deck pager, screen switcher */</script>
</body>
</html>
```

Conventions:
- Navigation is hash-based: `#index`, `#deck`, `#deck/<n>`, `#<platform>`, `#<platform>/<view>` (for example `#web/order-list`). Use plain `<a href="#...">` links for review navigation so browser back/forward works.
- Within a prototype, in-app actions carry `data-goto="<view-id>"`; they switch to that view of the current platform.
- View ids are platform-scoped: the same id (`list`, `detail`) may exist once per platform.
- Every active element (buttons, inputs, links, tabs, table actions, modals) MUST be drawn and positioned where it will be implemented.
- Use the wireframe CSS classes (`wf-*`) for layout; no inline styles for colors beyond the wireframe palette.
- No external resources, no network calls, no form submission (`form-action 'none'`).
- Neutral grayscale only; no brand colors, fonts, or component library hints.
- The `<title>` includes the MOCK id and name.

## 1. Review landing

- Header block shows the **ticket** (id and title) and the sources (REQ ids, specifications).
- One card/button per review content item:
  - **Design deck** — shows the slide count.
  - **One card per platform** — shows the platform and its view count, and opens the first view of that platform.
- The landing is scaffolding for review, not part of the design.

## 2. Design deck

- Render slides (`article.wf-slide`) in a stage with Previous/Next controls, a slide counter, and keyboard support (left/right arrows).
- Slide order: cover (ticket, design goal) → one slide per view → cross-cutting decisions (navigation, empty/error states, responsive behavior) → open questions/assumptions.
- Each view slide presents two columns:
  - **What it shows** — contents, active elements, states.
  - **Why this way** — the rationale and the alternative that was rejected.
- Each view slide links directly to its prototype view (`#<platform>/<view>`).
- One idea per slide; no implementation technology, libraries, or visual-design decisions.

## 3. Platform prototypes

- One `.wf-proto` block per platform (`data-platform`), each with a view navigation band (`.wf-proto-nav`) listing every view of that platform.
- One `.wf-screen` per view/state, with `data-platform` and `data-screen`; the first view is shown by default.
- Wrap the views in a platform-appropriate frame: `.wf-frame--mobile` (phone), `.wf-frame--tablet`, or `.wf-frame--desktop`.
- Draw all elements and wire interactions between views with `data-goto`.
- Platforms in the landing, the top navigation, and the prototype blocks MUST match.

## Reviewer chrome (top control band)

- Render a `<header class="wf-chrome">` with links to the Overview, the Design deck, and each platform.
- The chrome is **scaffolding for reviewers, NOT part of the mockup design**: style it distinctly (dark band) and label it as review scaffolding.
- Do not count the chrome toward layout spacing of the designed screens; it sits above them.

## Numbering

- Numbers are global across HTML mockups, one id per file. Allocate via `skills/ui-clickable-mockup/scripts/next_mock_id.sh`.
- Never reuse or renumber an id, never split an id across files, never put two ids in one file.

## Registry

Maintain `docs/specifications/ui/mockups/README.md` as a table:

```markdown
# UI Mockup Registry

| ID | Type | Name | Slug | Artifacts | Platform | Views | Covers | Status | Source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| MOCK-0001 | scenario | Order flow | order-flow | html | web,android | web:list,detail; android:list | — | draft | REQ-02.001; docs/specifications/orders.md |
```

- `Type`: `view` (single screen) or `scenario` (flow).
- `Artifacts`: `html` (one file per ticket).
- `Platform`: comma-separated platforms covered by the single file.
- `Views`: platform-scoped view ids exposed by the landing prototype buttons.
- `Covers`: comma-separated MOCK ids this mockup depends on or supersedes, or `—`.
- `Status`: `draft` / `reviewed` / `approved`.
- Update the registry row whenever a mockup is created, revised, or has its status changed.

## Procedure

1. **Read sources** — Read requirements, spec, and ticket to understand the scenario, screens, states, active elements, and target platform(s).
2. **Enumerate views** — List every distinct view/screen/state per platform; these become prototype screens, deck slides, and chrome links.
3. **Allocate id** — Get the next `MOCK-XXXX` (one id per file; by default one file/id per ticket).
4. **Scaffold** — Run `scripts/new_mockup.sh` to create the file, or copy the template. Run `scripts/ensure_wireframe_css.sh` to create/update the shared stylesheet.
5. **Fill the landing** — Replace the ticket and source placeholders; add one card per platform.
6. **Build the deck** — Replace the intro; add one slide per view with "What it shows" and "Why this way"; add a decisions slide.
7. **Build the prototypes** — One `.wf-proto` per platform with all views, a view navigation band, a device frame, and working `data-goto`/hash links.
8. **Register** — Add/update the registry row (platforms + views).
9. **Reference** — Report the MOCK id to the caller for recording in the feature specification (owner: task-refiner or tech-writer); add it to the ticket via `backlog-md`.
10. **Verify** — Run `scripts/validate_mockups.sh` and open the file to confirm landing, deck, and prototype navigation work with no console errors.
11. **Review** — Present the single file to the user; keep status `draft` until explicit approval.

### Migrating per-platform files

If a ticket already has one file per platform, merge them into a single file under the existing lowest MOCK id: move every platform's screens and slides into it, delete the extra files, remove their registry rows, and note the merged ids in `Covers`. Do not keep a separate index page.

## Completion Checks

- [ ] Each MOCK id is exactly one file, and each file carries exactly one MOCK id.
- [ ] The ticket's mockup file exists at `MOCK-XXXX-<slug>.html` (one file per mockup).
- [ ] Landing shows the ticket and one button per content item (deck + one per platform).
- [ ] Design deck has a cover, one slide per view with rationale, and a decisions slide.
- [ ] Every platform has a clickable prototype with all views and a view navigation band.
- [ ] All active elements are drawn; prototype actions navigate.
- [ ] `wireframe.css` present and up to date in the mockups dir.
- [ ] No external resources, no network calls, no technology hints.
- [ ] Registry row updated (platforms + views) and status is correct.
- [ ] `validate_mockups.sh` reports no errors.
- [ ] MOCK id reported for the feature specification and added to the ticket.

## Output Template

After creation, summarize:

- **Mockup**: MOCK-XXXX — <name>
- **File**: `docs/specifications/ui/mockups/MOCK-XXXX-<slug>.html`
- **Platforms**: <web / android / ...>
- **Deck slides**: <count; view slides list>
- **Prototype views**: <platform: views>
- **Sources**: <REQs, specs, tickets>
- **Registry**: updated / not updated
- **Approval**: draft / approved
