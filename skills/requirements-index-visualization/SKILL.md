---
name: requirements-index-visualization
description: 'Regenerate index.html — a tree + detail visualization of the requirements corpus — by running this skill bundled scripts/generate_index.sh against the project docs/requirements. Use after any change to REQ/NFR files (create, update, reorganize, validate) to keep the visual index in sync with the markdown sources.'
argument-hint: 'Run after requirement changes, e.g. "regenerate the requirements index" or "refresh index.html".'
user-invocable: true
disable-model-invocation: false
---

# Requirements Index Visualization

## Outcome

`docs/requirements/index.html` is regenerated from the current REQ/NFR markdown corpus and its timestamp is newer than the requirement files it visualizes.

## When To Use

- After creating, updating, renaming, or reorganizing any requirement file under `docs/requirements/business/` or `docs/requirements/non-functional/`.
- After validation corrections that changed requirement content.
- On explicit request to regenerate or refresh the requirements index.

Do not use for projects whose requirements do not use the canonical atomic structure (group files `REQ-XX.md`/`NFR-XX.md`, atomic files `REQ-XX.XXX.md`/`NFR-XX.XXX.md`, plus `INDEX.md` per directory).

## Prerequisites

- This skill bundles its generator at `scripts/generate_index.sh` (POSIX sh + awk; no other dependencies, no network). It is the single source of truth — there is no project-local copy.
- The target project has `<requirements-dir>/business/` and `<requirements-dir>/non-functional/` with their `INDEX.md` files.

If the bundled script is missing, stop and report it — do not create a replacement silently.

## Procedure

1. From the target project root, run the bundled script:

   ```
   ~/.config/opencode/skills/requirements-index-visualization/scripts/generate_index.sh
   ```

   It defaults to `docs/requirements` relative to the current directory. Pass a directory to override:

   ```
   ~/.config/opencode/skills/requirements-index-visualization/scripts/generate_index.sh path/to/requirements
   ```

2. On success the script prints `wrote <dir>/index.html: N requirements (M groups)` and exits 0. Report that summary.
3. On failure the script removes its partial output and exits non-zero. Read stderr and fix the reported cause before retrying (see Failure Modes).
4. Never hand-edit `<requirements-dir>/index.html` — it is a generated artifact; always regenerate it.

## What the Script Does

- Parses every group and atomic requirement file (files are the source of truth; `INDEX.md` is only cross-checked).
- Verifies `INDEX.md` lists exactly the atomic files present in the directory.
- Emits a self-contained `index.html`: left pane = collapsible tree (Business REQ groups → requirements, Non-Functional NFR groups → requirements) with a filter box; right pane = full requirement detail (criticality, user story, description, acceptance criteria for REQ; description, rationale, verification method for NFR).
- Output has no external resources (works offline via `file://`), uses no temp files outside the requirements directory, and is deterministic.

## Failure Modes

| Message | Cause | Fix |
|---|---|---|
| `requirements directory not found: <dir>` | No `docs/requirements` in the current directory and no directory argument given | Run from the project root or pass the directory explicitly |
| `INDEX.md out of sync with files` | An atomic file was added/removed/renamed but `INDEX.md` was not updated (or vice versa) | Update `INDEX.md` (use the business/non-functional requirements management skills) and rerun |
| `group <ID> not seen before <atomic-ID>` | An atomic file exists whose group file is missing or not named `REQ-XX.md`/`NFR-XX.md` | Create or rename the group file, then rerun |
| `bad title: ...` | An `# ` heading does not match `REQ-XX[.XXX] Title` / `NFR-XX[.XXX] Title` | Fix the heading, then rerun |
| `placeholder not replaced` / `expected N id entries` / `id ... missing from output` | Script or template problem | Report the details; do not edit `index.html` by hand |

## Completion Checks

- Script exited 0 and printed the `wrote <dir>/index.html: N requirements (M groups)` summary.
- `N` equals the number of atomic REQ files plus atomic NFR files.
- `<requirements-dir>/index.html` exists and is newer than the requirement files.
- No manual edits were made to `index.html`.
