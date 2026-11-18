---
name: manage-glossary
description: 'Manage the business glossary through Papyrus: add and update terms, merge duplicates, and keep wording consistent across docs and backlog. Use for business terminology only.'
argument-hint: 'Examples: add a glossary term; update a term definition; merge duplicate terms'
user-invocable: true
disable-model-invocation: false
---

# Business Glossary Management

## Outcome

Maintain a consistent, traceable business vocabulary by adding, updating, and consolidating Papyrus glossary records across project documentation and backlog.

## When To Use

- Add a new business term to the glossary.
- Update an existing business definition after requirement or domain changes.
- Align business wording between requirements, domain model, architecture, specs, and backlog.
- Remove ambiguity between related terms.
- Detect and resolve duplicate or conflicting definitions.

Do not use this skill for technical/acronym glossary maintenance unrelated to business domain language.

## Canonical Glossary Target

- Papyrus owns glossary records and assigns IDs automatically.
- Create, read, and update through the Papyrus CLI only:
  - `papyrus glossary create --term "<term>" --definition "<definition>"`
  - `papyrus glossary list`
  - `papyrus glossary view <GLO-ID>`
  - `papyrus glossary edit <GLO-ID> --term "<term>" --definition "<definition>"`
  - `papyrus glossary deprecate <GLO-ID>` / `papyrus glossary restore <GLO-ID>`
  - `papyrus search "<term>"` (search the managed corpus)
- The browsable index is `papyrus browser`. Do not create or edit `index.html`.

Secondary references may exist in other docs, but new business glossary entries must be created through Papyrus.

## Canonical Term Content

Papyrus stores a **term** and a **definition**. Include supporting context in the definition:

- definition — one or two sentences stating the meaning of the term;
- aliases — optional; state them in the definition (for example, `Also known as: ...`);
- related terms — optional; state them in the definition or use `--reference`.

### Conventions

- One record per term.
- Definitions do not include business rules, only the meaning of the term.
- Keep definitions short, explicit, and non-circular.
- Use `--label` for classification labels when useful.
- Never choose or renumber a `GLO` ID by hand.

## Procedure

1. **Identify intent and scope** — Determine whether the request is `add`, `update`, `merge`, or `rename`. Capture the target term, preferred wording, and impacted domain context.

2. **Baseline search** — Use `papyrus glossary list`, `papyrus glossary view <GLO-ID>`, and `papyrus search "<term>"` to find existing uses, aliases, abbreviations, and near-synonyms.

3. **Choose action branch**:
   - `add`: `papyrus glossary create --term "<term>" --definition "<definition>"`.
   - `update`: `papyrus glossary edit <GLO-ID> --definition "<definition>"` while preserving term identity.
   - `merge`: keep one preferred term; deprecate the duplicates with `papyrus glossary deprecate`; mention former aliases in the preferred definition.
   - `rename`: `papyrus glossary edit <GLO-ID> --term "<new term>"`; the ID stays stable. Update references.

4. **Edit glossary records** — Keep definitions short, explicit, and non-circular. Prefer one-sentence definitions plus one context clause when needed. Definitions do not include business rules.

5. **Propagate reference updates** — Update impacted Papyrus records through their owning commands:
   - `papyrus req` / `papyrus nfreq`
   - `papyrus rule`
   - `papyrus tech-spec` / `papyrus ui-spec`
   - `papyrus task`
   - `papyrus decision`
   - plain docs (domain model, architecture).

   Do not update skills or agent example files under `.ai/` or `.github/skills/` unless explicitly requested. Preserve requirement IDs and avoid changing intent while updating terminology.

6. **Consistency checks** — Ensure no contradictory definitions remain, capitalization and acronym expansion are consistent, and renamed terms keep traceability from the old wording.

7. **Confirm visibility** — Use `papyrus glossary list` and, when useful, `papyrus browser`.

8. **Completion checks**:
   - The glossary record exists and is visible through Papyrus.
   - References in impacted records are updated.
   - No stale conflicting term variants remain in active docs.
   - The final wording reflects the domain model and requirement intent.
   - No `index.html` was generated or edited.

## Decision Rules

- If the same term has different meanings by context, split into distinct terms with qualifiers.
- If two terms are true synonyms, keep one preferred canonical term and deprecate the other; mention the alias in the preferred definition.
- If the request would change business intent, stop and propose requirement/domain updates first.
- If no glossary record exists and the term is already used in requirements, create the record before further edits.
- New glossary additions must be performed through Papyrus; no ad-hoc manual insertion.

## Quality Bar

- Definitions are precise, testable in usage, and easy for non-technical users.
- Avoid implementation details in glossary text.
- Avoid vague wording like "etc.", "and so on", or "generally".
- Keep term naming stable unless a rename is explicitly requested.

## Output Template

Use this summary after updates:

- **Action**: add/update/merge/rename
- **Canonical term**: `<term>` <ID>
- **Updated records**: list
- **Cross-reference updates**: list
- **Papyrus visibility**: confirmed via `papyrus glossary list`
- **Residual risks**: if any
