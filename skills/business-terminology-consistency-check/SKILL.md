---
name: business-terminology-consistency-check
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
- Papyrus glossary records, read with `papyrus glossary list` and `papyrus glossary view <GLO-ID>`.
- Records live in `docs/glossary/`; Papyrus owns the IDs and files.

## Scope
- Include:
  - Papyrus requirements (`papyrus req list`, `papyrus nfreq list`)
  - Papyrus rules (`papyrus rule list`)
  - Papyrus specifications (`papyrus tech-spec list`, `papyrus ui-spec list`, `papyrus ui-mockup list`)
  - Papyrus tasks, milestones, releases, decisions, and audits
  - `docs/domain-model/`
  - `docs/architecture/`
- Exclude by default:
  - `.ai/`
  - `.github/skills/`
  - agent examples and skill internals

## Procedure
1. Collect canonical terms.
- Read `papyrus glossary list` and `papyrus glossary view <GLO-ID>`.
- Build preferred labels and allowed aliases from the definitions.

2. Scan for variants.
- Find case variants, plural variants, legacy names, and near-synonyms.
- Use `papyrus search "<term>"` for the Papyrus corpus and repository search for plain docs.
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
- Confirm updates are visible through Papyrus.

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
