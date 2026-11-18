---
name: check-terminology
description: 'Check docs and backlog for non-canonical business terms, conflicting term variants, and missing glossary alignment. Use when validating wording consistency before or after glossary changes.'
argument-hint: 'Examples: check term consistency for intervention; audit terminology in docs and backlog'
user-invocable: true
disable-model-invocation: false
---

# Business Terminology Consistency Check

## Outcome
Detect inconsistent business terminology and propose precise replacements aligned with the canonical business glossary.

## When To Use
- After adding or updating a business glossary entry
- Before renaming or merging glossary terms
- During requirement/domain refactors that touch business wording
- Before release documentation reviews

## Canonical Source
- Glossary records can be accessed with the `manage-glossary` skill (list/view).
- Records can be accessed with the `manage-glossary` skill; it owns the IDs and files.

## Scope
- Include:
  - Requirements and NFRs, read through `manage-requirements` and `manage-nfrs`
  - Business rules, read through `manage-business-rules`
  - Specifications and mockups, read through `manage-tech-specs`, `manage-ui-specs`, and `manage-ui-mockups`
  - Tasks, milestones, releases, decisions, and audits, read through `manage-tasks`, `manage-milestones`, `manage-releases`, `manage-decisions`, and `manage-audits`
  - `docs/domain-model/`
  - `docs/architecture/`
- Exclude by default:
  - `.ai/`
  - `.github/skills/`
  - agent examples and skill internals

## Procedure
1. Collect canonical terms.
- Read glossary records via `manage-glossary` (list/view).
- Build preferred labels and allowed aliases from the definitions.

2. Scan for variants.
- Find case variants, plural variants, legacy names, and near-synonyms.
- Use the search operation of `manage-glossary` for the managed corpus and repository search for plain docs.
- Detect terms used without a glossary record when they appear repeatedly.

3. Classify findings.
- `conflict`: same term used with different meanings.
- `variant`: different labels for same meaning.
- `orphan`: repeated term not present in the glossary.
- `drift`: wording diverges from the current glossary definition.

4. Propose fixes.
- Provide record-level or file-level replacements that preserve requirement intent.
- Prefer minimal wording edits over broad rewrites.
- Do not apply edits unless explicitly requested.

5. Validate after apply (if requested).
- Re-scan target records and files.
- Confirm conflicts and variants are resolved.
- Confirm updates are visible via `manage-glossary` (list).

## Completion Checks
- All conflicts and variants are listed with evidence.
- Proposed canonical replacement is provided for each issue.
- High-risk changes (could alter requirement intent) are explicitly flagged.

## Output Template
- Canonical term set reviewed: <count>
- Files scanned: <count>
- Findings:
  - conflict: <n>
  - variant: <n>
  - orphan: <n>
  - drift: <n>
- Proposed replacements: <list>
- High-risk items requiring approval: <list>
