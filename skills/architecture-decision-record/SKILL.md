---
name: architecture-decision-record
description: 'Create and manage Architecture Decision Records (ADRs) as Papyrus decision records in decisions/.'
argument-hint: 'ADR title or description of the architectural decision to record.'
user-invocable: true
disable-model-invocation: false
---

# Architecture Decision Record (ADR) Management

## Outcome

Create, revise, and manage Architecture Decision Records (ADRs) as Papyrus `decision` records in `decisions/`. Once an ADR reaches a final status (`Accepted`, `Refused`), its body becomes immutable — only status transitions to `Deprecated` or `Superseded` are permitted. The Papyrus browser is the ADR index; no `index.html` is generated.

## When To Use

- Record a significant architectural decision with rationale.
- Propose a new architectural approach for discussion.
- Supersede or deprecate a previously accepted/refused decision.
- Document the context, trade-offs, and consequences of a decision.

Do not use this skill for:
- Business or project management decisions (use the Papyrus `decision` command with type `bdr`).
- Implementation notes or task-level choices.
- Casual discussions that do not impact architecture.

## ADR Location and Discovery

- ADRs are Papyrus decision records stored in `decisions/`.
- Papyrus assigns the ID and filename (`ADR-NNNN-<kebab-case-title>`). Never choose, rename, or move an ADR file by hand.
- Read records with `papyrus decision list` and `papyrus decision view <ADR-ID>`.
- The browsable index is `papyrus browser`; never create or hand-edit an ADR index.

## ADR Format

A Papyrus decision record has these fields:

- **Title** — short, descriptive noun phrase.
- **Status** — `Proposed`, `Accepted`, `Refused`, `Deprecated`, or `Superseded`.
- **Decision** — the decision, including a reference to the superseded ADR when applicable.
- **Context** — the problem, forces at play, background, and options considered.
- **Consequences** — positive and negative consequences, trade-offs, and migration notes.
- **References** — requirement IDs and related records.

### Status lifecycle

- `Proposed` — initial state, open for discussion.
- `Accepted` — decision adopted (immutable body).
- `Refused` — decision rejected (immutable body).
- `Deprecated` — still valid but no longer recommended.
- `Superseded` — replaced by another ADR (must reference the new ADR).

Allowed transitions:

- `Proposed` → `Accepted` | `Refused`
- `Accepted` → `Deprecated` | `Superseded`
- `Refused` → `Deprecated` | `Superseded`
- `Deprecated` → `Superseded`

Any other status change is prohibited without creating a new ADR.

## Procedure

Every procedure ends by confirming the record is visible through `papyrus decision list` / `papyrus browser`. Do not generate an index.

### 1. Create a new ADR (Proposed)

1. **Resolve the title** — short, descriptive noun phrase.
2. **Create through Papyrus**:
   ```bash
   papyrus decision create "<Title>" --decision-type adr \
     --context "<problem, forces, options>" \
     --decision "<decision>" \
     --consequences "<positive, negative, migration>" \
     --reference <REQ-ID>
   ```
3. **Confirm status** — the new record is `Proposed`; if not, set it with `papyrus decision edit <ADR-ID> --status Proposed`.
4. **Confirm visibility** with `papyrus decision list`.

### 2. Accept or Refuse a Proposed ADR

1. **Validate** that current status is `Proposed` with `papyrus decision view <ADR-ID>`.
2. **Ask for user validation** — present the ADR (title, context, decision, consequences) and ask the user to confirm acceptance or refusal. Do not change the status without explicit user approval.
3. **Change status** with `papyrus decision edit <ADR-ID> --status Accepted` or `--status Refused` only after user confirmation.
4. **Immutable lock** — once set to `Accepted` or `Refused`, the body fields (Context, Decision, Consequences) MUST NOT be edited further.
5. **Confirm visibility** with `papyrus decision list`.

### 3. Supersede a Final ADR

1. **Validate** that current status is `Accepted` or `Refused`.
2. **Create the replacement ADR** through step 1. Its context MUST reference the old ADR (`Supersedes ADR-NNNN`).
3. **Mark the old record**:
   ```bash
   papyrus decision edit <OLD-ADR-ID> --status Superseded --superseded-by <NEW-ADR-ID>
   ```
4. Only status and supersession are editable — body remains frozen.
5. **Confirm visibility** with `papyrus decision list`; both records must appear.

### 4. Deprecate an ADR

1. **Validate** that current status is `Proposed`, `Accepted`, or `Refused`.
2. **Change status** to `Deprecated` with `papyrus decision edit <ADR-ID> --status Deprecated`.
3. State the deprecation rationale in the response and, when needed, in the release or audit notes. Do not rewrite the frozen body.
4. **Confirm visibility** with `papyrus decision list`.

### 5. Revise a Proposed ADR (Before Final Status)

1. Any field may be edited while the status is `Proposed`:
   ```bash
   papyrus decision edit <ADR-ID> --title "<title>" --context "<context>" \
     --decision "<decision>" --consequences "<consequences>" --reference <ref>
   ```
2. **Confirm visibility** with `papyrus decision list`.

## Immutability Rules

| Status | Body Editable | Status Editable To |
|--------|:---:|:---:|
| Proposed | Yes | Accepted, Refused |
| Accepted | **No** | Deprecated, Superseded |
| Refused | **No** | Deprecated, Superseded |
| Deprecated | **No** | Superseded |
| Superseded | **No** | — |

- "Body" = the context, decision, and consequences fields.
- The status is always editable within the allowed transitions.
- The title is editable only while status is `Proposed`.

## Completion Checks

- [ ] The ADR exists as a Papyrus `decision` record with an `ADR` ID.
- [ ] The record has title, status, decision, context, and consequences.
- [ ] Status is valid and transitions are legal.
- [ ] No generated `index.html` was edited or regenerated; visibility is confirmed through Papyrus.
- [ ] No managed ADR file was edited, renamed, or moved by hand.
- [ ] If superseding, the old ADR links to the new one and vice versa.

## Output Template

After any operation, summarize:

- **Action**: create / accept / refuse / deprecate / supersede
- **ADR**: `ADR-NNNN` – Title
- **Status**: OldStatus → NewStatus
- **Record**: confirmation that it is visible through `papyrus decision list`
- **Transitions validated**: yes/no
- **Index**: `papyrus browser` (no generated file)
