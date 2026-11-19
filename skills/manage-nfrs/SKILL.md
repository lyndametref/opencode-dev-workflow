---
name: manage-nfrs
description: 'Create, update, reorganize, and check consistency of non-functional requirements through the Papyrus nfr commands.'
argument-hint: 'Examples: create a new NFR for authentication timeout; validate all NFRs for consistency; update NFR-001.002'
user-invocable: true
disable-model-invocation: false
---

# Non-Functional Requirements Management

## Outcome

Maintain a consistent, traceable non-functional requirements corpus through Papyrus. Papyrus owns IDs, filenames, grouping, and metadata.

## When To Use

- Create a new non-functional requirement or NFR group.
- Update or validate existing NFRs.
- Check consistency across NFRs.
- Reorganize NFRs within Papyrus constraints.

Do not use this skill for implementation logic (no Kotlin, SQL, Java, etc.), technical specs, domain model definitions, or business requirements (use `manage-requirements`).

## Canonical Format

Papyrus creates and owns the record format. Do not create or edit NFR files directly.

- **Groups** — `papyrus nfr create-group --title "<Group title>" --description "<description>"`. Group descriptions are single-line.
- **Atomic NFRs** — `papyrus nfr create "<title>" --group <NFR-GROUP-ID> --description <text|->`.

An NFR's content should carry:

- title;
- description (performance target, security constraint, usability criterion, etc.);
- rationale — which quality attribute it addresses;
- verification method — how compliance is verified.

Papyrus has no separate rationale or verification fields; include them in the description as labelled sections.

### Naming and numbering

- Papyrus assigns IDs such as `NFR-001` (group) and `NFR-001.001` (atomic).
- Never choose, rename, or renumber an ID by hand.
- IDs are immutable. Do not reuse or renumber a deprecated record.

### Index

The browsable index is `papyrus browser`. Use `papyrus nfr list` / `papyrus nfr view <ID>` for reading. Do not generate or edit `index.html`.

## Procedure

1. **Classify request** — Determine whether the request is `create`, `update`, `validate`, or `reorganize`.

2. **Read baseline** — Use `papyrus nfr list` and `papyrus nfr view <ID>` to understand existing NFRs and grouping.

3. **Identify required changes** — Determine what needs to be created, updated, or reorganized.

4. **For creation** — Create or confirm the group first, then the atomic NFR. The group description stays inline; the NFR description is multiline and comes from stdin:
   ```bash
   papyrus nfr create-group --title "<Group>" --description "<scope>"
   papyrus nfr create "<Title>" --group <NFR-GROUP-ID> --description - <<'EOF'
   Description: <observable target>
   Rationale: <quality attribute>
   Verification: <method>
   EOF
   ```

5. **For updates** — Use `papyrus nfr edit <ID> --title ... --description <text|-> --label ... --reference ...`; pass `--description -` for multiline. Papyrus has no group-change flag; if an NFR must move to another group, do not renumber it. Deprecate the old record and create a replacement referencing it, or ask the user.

6. **For consistency checks** — Check for conflicting performance targets, overlapping security constraints, and untraceable verification claims. Report findings before changing meaning.

7. **For deprecation** — Use `papyrus nfr deprecate <ID>`; restore with `papyrus nfr restore <ID>`.

8. **Report outcome** — Summarize the action, `NFR` IDs, validation status, and any risks. Confirm visibility with `papyrus nfr list`.

## Resume / interruption

NFR edits are multi-record. If interrupted, re-run a validation pass on the affected group before continuing. Do not recreate records that already exist.

## Handoff

After changing NFRs, report the changed `NFR` IDs to the caller (planner / architect / orchestrator) so specs and verification plans can be aligned.

## Completion Checks

- All records follow Papyrus-assigned `NFR-xxx` and `NFR-xxx.yyy` IDs.
- Group numbering is consistent; no manual renumbering.
- Each atomic NFR carries title, description, rationale, and verification method.
- Each group carries a title and description.
- Records are visible through `papyrus nfr list`.
- No `index.html` was generated or edited.
- No implementation code (Kotlin, SQL, Java, etc.) appears in NFR records.

## Decision Rules

- If the user's request is ambiguous, ask clarifying questions before proceeding.
- If an NFR already exists, propose an update rather than creating a duplicate.
- IDs are immutable; do not fill numbering gaps by renumbering.
- If a change would break cross-references (e.g., from technical specs or tasks), flag the impact before updating.
- Use Papyrus records as the source of truth; do not maintain a separate Markdown index.

## Output Template

Use this summary after updates:

- **Action**: create/update/deprecate/check consistency
- **Target**: `NFR` IDs
- **Updated records**: list
- **Cross-reference updates**: list
- **Validation results**: pass/fail with details
- **Papyrus visibility**: confirmed via `papyrus nfr list`
- **Residual risks**: if any
