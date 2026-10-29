---
name: ui-clickable-mockup
description: 'Generate a clickable HTML mockup that simulates a UI scenario/flow in wireframe style, saved as MOCK-XXXX-<slug>.html under docs/specifications/ui/mockups/, using a shared wireframe.css. Use for multi-screen flows and interactive scenarios.'
argument-hint: 'generate a clickable mockup for the create-order flow (MOCK-0010); simulate the checkout scenario'
user-invocable: true
disable-model-invocation: false
---

# UI Clickable Mockup

## Outcome

Produce an interactive, wireframe-styled HTML mockup that simulates a UI scenario (multi-screen flow, navigation, modal, form steps). Saved as `MOCK-XXXX-<slug>.html` under `docs/specifications/ui/mockups/`, sharing `wireframe.css`. It demonstrates layout and interaction flow only; it conveys no library, framework, or technology choice.

## When To Use

- A requirement or specification describes a multi-step flow or scenario that must be clickable for review.
- A ticket needs an interactive reference for navigation, states, and active elements.
- The `@ui-designer` agent is asked to design a scenario mockup.

Do not use this skill for:
- Single static screen images (use `ui-wireframe-svg`).
- Business process/state diagrams (use `business-process-diagramming` / `state-diagram-creation`).
- Production frontend implementation (use `frontend-dev`).

## Location

- All mockups live in `docs/specifications/ui/mockups/` .
- File naming convention: `MOCK-XXXX-<kebab-case-slug>.html`.
- Shared stylesheet: `docs/specifications/ui/mockups/wireframe.css`.
- Base template: `skills/ui-clickable-mockup/templates/mockup.html`.

## Format

Each HTML file MUST follow this structure:

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'self' file: 'unsafe-inline'; script-src 'unsafe-inline'; img-src data:; base-uri 'none'; form-action 'none'">
<title>MOCK-XXXX — <Name></title>
<link rel="stylesheet" href="wireframe.css">
</head>
<body data-mock-id="MOCK-XXXX">
  <section class="wf-screen" data-screen="<screen-id>" data-mock-id="MOCK-XXXX">
    <!-- wireframe elements; use data-goto="<screen-id>" on clickable elements -->
  </section>
  <!-- one section per screen/state -->
<script>/* navigation: show screen by data-screen; click handler for [data-goto] */</script>
</body>
</html>
```

Conventions:
- One `<section class="wf-screen">` per screen/state, with a unique `data-screen` id.
- Clickable elements carry `data-goto="<target-screen-id>"`; the shared script swaps the visible screen.
- Every active element (buttons, inputs, links, tabs, table actions, modals) MUST be drawn and positioned where it will be implemented.
- Use the wireframe CSS classes (`wf-*`) for layout; no inline styles for colors beyond the wireframe palette.
- No external resources, no network calls, no form submission (`form-action 'none'`).
- Neutral grayscale only; no brand colors, fonts, or component library hints.
- The `<title>` includes the MOCK id and name.

## Numbering

- Numbers are global across SVG and HTML mockups. Allocate via `skills/ui-wireframe-svg/scripts/next_mock_id.sh` or `skills/ui-clickable-mockup/scripts/next_mock_id.sh`.

## Registry

Update `docs/specifications/ui/mockups/README.md` (see `ui-wireframe-svg` skill) with `Artifacts: html` (or `svg+html` if both exist).

## Procedure

1. **Read sources** — Read requirements, spec, and ticket to understand the scenario, screens, states, and active elements.
2. **Allocate id** — Get the next `MOCK-XXXX`.
3. **Ensure stylesheet** — Run `scripts/ensure_wireframe_css.sh [mockups-dir]`.
4. **Design screens** — Enumerate screens/states and transitions; map each clickable element to its target screen.
5. **Build HTML** — Use the base template; add one `wf-screen` section per screen with all elements positioned; wire `data-goto` navigation; include modal markup if needed.
6. **Register** — Add/update the registry row.
7. **Reference** — Record the MOCK id in the spec and ticket (via `backlog-md`).
8. **Verify** — Open the HTML in a browser (optional) to confirm navigation works; no console errors.

## Resume / interruption

If interrupted, the HTML file plus registry row are the source of truth. Re-read them and continue.

## Completion Checks

- [ ] File exists at `docs/specifications/ui/mockups/MOCK-XXXX-<slug>.html`.
- [ ] ID is unique and follows `MOCK-XXXX`.
- [ ] All screens/states of the scenario are present.
- [ ] All active elements are drawn and clickable elements navigate.
- [ ] `wireframe.css` present in mockups dir.
- [ ] No external resources / no technology hints.
- [ ] Registry row added/updated.
- [ ] MOCK id referenced in spec and ticket.

## Output Template

After creation, summarize:

- **Mockup**: MOCK-XXXX — <name> (scenario)
- **File**: `docs/specifications/ui/mockups/MOCK-XXXX-<slug>.html`
- **Screens**: <list of screen ids>
- **Sources**: <REQs, specs, tickets>
- **Registry**: updated / not updated
