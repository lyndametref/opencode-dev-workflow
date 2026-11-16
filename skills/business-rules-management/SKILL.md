---
name: business-rules-management
description: 'Create, update, and validate business rules through Papyrus. Each rule is a RUL record with a unique ID, precise description, rationale grounded in requirements, and applicability statement.'
argument-hint: 'Examples: create a new business rule; update RUL-005; validate all business rules for format compliance; check RUL-003 against requirements'
user-invocable: true
disable-model-invocation: false
---

# Business Rules Management

## Outcome

Maintain a consistent, traceable set of business rules by creating, updating, and validating Papyrus `rule` records, each grounded in requirements.

## When To Use

- Create a new business rule with a unique `RUL` ID.
- Update an existing business rule (description, rationale, or applicability).
- Validate all business rules for canonical format compliance.
- Check a specific business rule against its referenced requirements.
- List business rules and their source requirements.

Do not use this skill for implementation logic (no Kotlin, SQL, XML, etc.), technical specs, or domain model definitions.

## Workflow alignment

- The rule is created or updated in Phase 2 when `requirements-engineer` delegates an impact assessment to `business-analyst`.
- A rule exists only to help fulfil a requirement; every rule references at least one `REQ`.
- When a served requirement changes, every rule that references it must be re-validated against the new requirement before Phase 3 planning. If the rule no longer holds, update or deprecate it; never leave it silently inconsistent.
- The rule is not an acceptance criterion, a specification, or a test. Those belong to their own artifacts.

## Canonical Format

Papyrus owns the record format. Do not create or edit business-rule files directly.

- **Title** — short descriptive name.
- **Description** — one unambiguous statement of the business rule.
- **Rationale** — why the rule exists, grounded in at least one requirement.
- **Applicability** — when and where the rule applies (creation time, state transitions, entity types).
- **Requirement references** — at least one `REQ-xxx` / `REQ-xxx.yyy`.

### Conventions

- Papyrus assigns IDs such as `RUL-001`.
- Never choose, rename, or renumber an ID by hand.
- Every rule MUST reference at least one requirement.
- Rationale MUST explain WHY based on requirement text, not just WHAT.
- Description is a single, precise statement of what the rule IS.
- Applicability describes WHEN and WHERE the rule applies.
- The browsable index is `papyrus browser`. Do not generate or edit `index.html`.
- DO NOT generate implementation code (no Kotlin, SQL, Java, XML, etc.).

## Procedure

1. **Classify request** — Determine whether the request is `create`, `update`, `validate`, or `list`.

2. **Read baseline** — Use `papyrus rule list` and `papyrus rule view <ID>` to understand current rules and avoid duplication.

3. **Check for duplicates** — Search existing rules for the same topic to avoid overlap.

4. **Create or update through Papyrus**:
   ```bash
   papyrus rule create "<Title>" \
     --description "<rule>" \
     --rationale "Based on REQ-xxx.yyy — <reason>" \
     --applicability "<when and where>" \
     --requirement REQ-xxx.yyy
   papyrus rule edit <RUL-ID> --title "<title>" --description "<rule>" \
     --requirement REQ-xxx.yyy
   ```
   Ensure the description is a single precise statement, the rationale references at least one requirement, and the applicability states when and where the rule applies.

   Papyrus 0.1.0 has no `--rationale` or `--applicability` flag on `rule edit`. Change those fields with `papyrus rule edit <RUL-ID> --editor` when an interactive editor is available, or deprecate the record and create a corrected replacement that references it.

5. **Validate/Review** — Check each `RUL` record via `papyrus rule view <ID>`:
   - title is present;
   - description is a single, precise statement;
   - rationale contains at least one `REQ-` reference;
   - applicability is present and specific;
   - no implementation code (code blocks only for illustrative examples, never production-ready).

6. **Deprecate when obsolete** — Use `papyrus rule deprecate <ID>`; restore with `papyrus rule restore <ID>`. Do not delete or renumber.

7. **Report outcome** — Summarize the action, `RUL` IDs, validation status, and any risks. Confirm visibility with `papyrus rule list`.

## Resume / interruption

Business-rule edits are multi-record. If interrupted, re-run a validation pass on the affected rules before continuing. Do not recreate records that already exist.

## Handoff

After changing business rules, report the changed `RUL` IDs and affected requirement references to the caller (business-analyst / requirements-engineer) so specs and tasks can align.

## Completion Checks

- The rule exists as a Papyrus record with a `RUL` ID.
- The record has title, description, rationale, and applicability.
- The rationale references at least one `REQ-xxx` / `REQ-xxx.yyy`.
- The record is visible through `papyrus rule list`.
- No `index.html` was generated or edited.
- All existing rules still have valid format if a validation pass was requested.
- No implementation code was generated.

## Decision Rules

- If a proposed rule duplicates an existing rule, do not create it — suggest updating the existing one.
- If a rule references no requirement, stop and identify the missing requirement before proceeding.
- If the request mixes business rules with implementation details, split them — business rules stay in Papyrus, implementation code stays out.
- If the request changes business intent, flag the requirement-level impact before updating the rule.
- IDs are immutable; do not renumber or reuse deprecated IDs.

## Quality Bar

- Descriptions are single-sentence, unambiguous, and self-contained.
- Rationale always explains WHY based on requirement text, not just WHAT.
- Applicability is precise (entity types, lifecycle phases, data conditions).
- No implementation code, pseudo-code, or framework-specific language.
- IDs never skip or get renumbered by hand.
- The Papyrus browser shows the current rule corpus.

## Output Template

Use this summary after updates:

- **Action**: create/update/deprecate/validate/list
- **Target rule**: `RUL-xxx` — Title
- **Updated records**: list
- **Cross-reference updates**: list
- **Validation results**: pass/fail with details
- **Papyrus visibility**: confirmed via `papyrus rule list`
- **Residual risks**: if any
