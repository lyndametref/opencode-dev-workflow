---
name: manage-requirements
description: 'Create, update, reorganize, and check consistency of business requirements through the Papyrus req commands.'
argument-hint: 'Examples: create a new requirement for recipe scaling; validate all requirements for consistency; update REQ-001.002'
user-invocable: true
disable-model-invocation: false
---

# Business Requirements Management

## Outcome

Maintain a consistent, traceable business requirements corpus through Papyrus. Papyrus owns IDs, filenames, grouping, and metadata under `docs/requirements/business/`.

## When To Use

- Create a new requirement or requirement group.
- Update or validate existing requirements.
- Check consistency across requirements.
- Reorganize requirements within Papyrus constraints.

Do not use this skill for implementation logic (no Kotlin, SQL, Java, etc.), technical specs, or domain model definitions.

## Canonical Format

Papyrus creates and owns the record format. Do not create or edit requirement files directly.

- **Groups** — `papyrus req create-group --title "<Group title>" --description "<description>" --story "<user story>"`.
- **Atomic requirements** — `papyrus req create "<title>" --group <REQ-GROUP-ID> --story "<user story>" --description "<description and acceptance criteria>"`.

A requirement's content should carry:

- title;
- user story (when applicable);
- group reference;
- criticality (MoSCoW) — include it in the description or as a label;
- description;
- acceptance criteria — include them in the description because Papyrus has no AC flag for requirements.

### Naming and numbering

- Papyrus assigns IDs such as `REQ-001` (group) and `REQ-001.001` (atomic).
- Never choose, rename, or renumber an ID by hand.
- IDs are immutable. Do not reuse or renumber a deprecated record.

### Index

The browsable index is `papyrus browser`. Use `papyrus req list` / `papyrus req view <ID>` for reading. Do not generate or edit `index.html`.

## Procedure

1. **Classify request** — Determine whether the request is `create`, `update`, `validate`, or `reorganize`.

2. **Read baseline** — Use `papyrus req list` and `papyrus req view <ID>` to understand existing requirements and grouping.

3. **Identify required changes** — Determine what needs to be created, updated, or reorganized.

4. **For creation** — Create or confirm the group first, then the atomic requirement:
   ```bash
   papyrus req create-group --title "<Group>" --description "<scope>" --story "<story>"
   papyrus req create "<Title>" --group <REQ-GROUP-ID> --story "<story>" \
     --description "<description; Criticality: Must have; Acceptance Criteria: ...>"
   ```

5. **For updates** — Use `papyrus req edit <ID> --title ... --story ... --description ... --label ... --reference ...`. Papyrus has no group-change flag; if a requirement must move to another group, do not renumber it. Deprecate the old record and create a replacement referencing it, or ask the user.

6. **For consistency checks** — Check for conflicts, gaps, and untraceable claims across the corpus. Report findings before changing meaning.

7. **For deprecation** — Use `papyrus req deprecate <ID>`; restore with `papyrus req restore <ID>`.

8. **Report outcome** — Summarize the action, `REQ` IDs, validation status, and any risks. Confirm visibility with `papyrus req list`.

## Resume / interruption

Requirements edits are multi-record. If interrupted, re-run a validation pass on the affected group before continuing. Do not recreate records that already exist.

## Handoff

After changing requirements, report the changed `REQ` IDs to the caller (planner / business-analyst / orchestrator) so specs, tasks, and business rules can be aligned.

## Completion Checks

- All records follow Papyrus-assigned `REQ-xxx` and `REQ-xxx.yyy` IDs.
- Group numbering is consistent; no manual renumbering.
- Each atomic requirement carries title, user story, group, criticality, description, and acceptance criteria.
- Each group carries a title, user story, and description.
- Records are visible through `papyrus req list`.
- No `index.html` was generated or edited.
- No implementation code (Kotlin, SQL, Java, etc.) appears in requirement records.

## Decision Rules

- If the user's request is ambiguous, ask clarifying questions before proceeding.
- If a requirement already exists, propose an update rather than creating a duplicate.
- IDs are immutable; do not fill numbering gaps by renumbering.
- If a change would break cross-references (e.g., from business rules or tasks), flag the impact before updating.
- Use Papyrus records as the source of truth; do not maintain a separate Markdown index.

## Output Template

Use this summary after updates:

- **Action**: create/update/deprecate/check consistency
- **Target**: `REQ` IDs
- **Updated records**: list
- **Cross-reference updates**: list
- **Validation results**: pass/fail with details
- **Papyrus visibility**: confirmed via `papyrus req list`
- **Residual risks**: if any
