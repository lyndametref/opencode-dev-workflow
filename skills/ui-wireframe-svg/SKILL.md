---
name: ui-wireframe-svg
description: 'Render a UI mockup as a wireframe SVG image (static layout) saved as MOCK-XXXX-<slug>.svg under docs/specifications/ui/mockups/. Use when a view/screen layout must be visualized as a numbered wireframe image.'
argument-hint: 'render a wireframe SVG mockup for the order list view (MOCK-0002); create a wireframe for the dashboard screen'
user-invocable: true
disable-model-invocation: false
---

# UI Wireframe SVG Mockup

## Outcome

Produce a static wireframe image of a UI view/screen as an SVG file, numbered `MOCK-XXXX`, saved under `docs/specifications/ui/mockups/` . The mockup shows the layout and every active element (buttons, inputs, links, tables, menus, tabs, etc.) in its final position, in a neutral wireframe style. It conveys no library, framework, or technology choice.

## When To Use

- A requirement or specification describes a view/screen whose layout must be visualized for stakeholders or implementers.
- A ticket needs a concrete visual reference for a single screen state.
- The `@ui-designer` agent is asked to design a view mockup.

Do not use this skill for:
- Interactive, multi-screen flows or scenarios (use `ui-clickable-mockup`).
- Business process flows or state machines (use `business-process-diagramming` / `state-diagram-creation`).
- Final visual design, branding, colors, or component library selection.

## Location

- All mockups live in `docs/specifications/ui/mockups/`.
- File naming convention: `MOCK-XXXX-<kebab-case-slug>.svg`, where `XXXX` is a zero-padded 4-digit unique number.
  - Examples: `MOCK-0001-order-list.svg`, `MOCK-0002-order-list-empty.svg`
- A shared registry is maintained at `docs/specifications/ui/mockups/README.md` (see Registry).

## Format

Each SVG MUST follow this structure:

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1440 900" width="1440" height="900" role="img" aria-labelledby="t d">
  <title id="t">MOCK-XXXX — <Name> — <State></title>
  <desc id="d"><source refs: REQ-..; docs/specifications/..; ticket id></desc>
  <rect width="1440" height="900" fill="#ffffff"/>
  <!-- wireframe elements -->
</svg>
```

Conventions:
- Canvas: 1440×900 (desktop) unless the requirement specifies a different target; note the size in the title if non-default.
- Neutral grayscale only: strokes `#9ca3af`/`#6b7280`, fills `#e5e7eb`/`#f3f4f6`/`#ffffff`. No brand colors.
- Text is represented by rectangles or `<text>` placeholders; keep labels short.
- Every interactive element (button, input, link, select, checkbox, tab, menu item, table row action) MUST be drawn and positioned where it will be implemented.
- Containers use dashed or light-gray rectangles; spacing must reflect the intended layout (grid/flex regions).
- No CSS classes, no external references, no scripts, no data attributes beyond `aria-*`.
- The `<desc>` lists the source requirement/spec/ticket references.

## Numbering

- Numbers are global across both SVG and HTML mockups (a MOCK id identifies one mockup artifact set).
- Determine the next free number with `skills/ui-wireframe-svg/scripts/next_mock_id.sh [mockups-dir]`, or by scanning existing `MOCK-*.svg` / `MOCK-*.html` files and taking max+1.
- Never reuse a number; never renumber existing mockups.

## Registry

Maintain `docs/specifications/ui/mockups/README.md` as a table:

```markdown
# UI Mockup Registry

| ID | Type | Name | Slug | Artifacts | Covers | Status | Source |
| --- | --- | --- | --- | --- | --- | --- | --- |
| MOCK-0001 | view | Order list | order-list | svg | — | draft | REQ-02.001; docs/specifications/orders.md |
```

- `Type`: `view` (single screen) or `scenario` (flow, usually HTML).
- `Artifacts`: `svg`, `html`, or `svg+html`.
- `Covers`: comma-separated MOCK ids this mockup depends on or supersedes, or `—`.
- `Status`: `draft` / `reviewed` / `approved`.
- Update the registry row whenever a mockup is created, revised, or has its status changed.

## Procedure

1. **Read sources** — Read the requirement(s), feature specification, and ticket to understand the screen, its states, active elements, and layout constraints.
2. **Decide scope** — Confirm with the caller which single screen state this mockup represents; split distinct states into separate MOCK ids.
3. **Allocate id** — Run `next_mock_id.sh` (or scan) to get the next `MOCK-XXXX`.
4. **Design layout** — Sketch regions (header, nav, content, sidebar, footer) and place every active element with realistic spacing.
5. **Render SVG** — Write `MOCK-XXXX-<slug>.svg` following the Format, drawing all elements.
6. **Register** — Add/update the row in `docs/specifications/ui/mockups/README.md`.
7. **Reference** — Record the MOCK id in the feature specification and (via `backlog-md`) in the ticket's references/acceptance criteria. Do not edit ticket files directly.
8. **Report** — Return the MOCK id, file path, and references.

## Resume / interruption

If interrupted, re-read the sources and the partial SVG; the file on disk plus the registry row are the source of truth. Continue from the last completed step.

## Completion Checks

- [ ] File exists at `docs/specifications/ui/mockups/MOCK-XXXX-<slug>.svg`.
- [ ] ID is unique and follows `MOCK-XXXX`.
- [ ] SVG canvas and all active elements are drawn and positioned.
- [ ] No technology/library/brand information is conveyed.
- [ ] `<title>` and `<desc>` present with source references.
- [ ] Registry row added/updated.
- [ ] `validate_mockups.sh` reports no errors.
- [ ] MOCK id referenced in the spec and ticket.
## Output Template

After creation, summarize:

- **Mockup**: MOCK-XXXX — <name> (<state>)
- **File**: `docs/specifications/ui/mockups/MOCK-XXXX-<slug>.svg`
- **Sources**: <REQs, specs, tickets>
- **Elements drawn**: <short list>
- **Registry**: updated / not updated
