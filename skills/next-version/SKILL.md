---
name: next-version
description: 'Choose a Semantic Version for a verified milestone release candidate (Phase 5) or a final release (Phase 6) from the changes it contains, handling major/minor/patch classification and RC numbering with reset on major increment.'
argument-hint: 'Provide a milestone ID for an RC, or a release ID for the final version. If omitted, resolve from the managed records and ask when ambiguous.'
user-invocable: true
disable-model-invocation: false
---

# Next Version Selection

## Outcome

One recommended version string (`X.Y.Z` or `X.Y.Z-rc.N`) with its rationale, increment class, baseline, RC number, and the changes considered. No backlog state, version file, or Git tag is changed. The recommendation is recorded by the orchestrator in the Phase 5 verification task or on the release in Phase 6.

## When to use

- Phase 5, after a milestone verification passes: choose the milestone RC version.
- Phase 6, after the scope-and-findings approval: choose the final release version.

Do not use this skill to verify a milestone, close a release, or create tags.

## Prerequisites

- Load `manage-releases`.
- Read access to Git tags and the project's version files.
- The milestone or release scope in the managed records.

## Versioning rules

The project follows Semantic Versioning (`MAJOR.MINOR.PATCH`).

- **Breaking** — a change to a public API, file format, or command-line argument (renamed, removed, or changed semantics): **major**.
- **Feature** — a backward-compatible addition (new capability, endpoint, option, field): **minor**.
- **Chore** — documentation, dependency updates, refactors with no behavior change, tests, build changes: **patch**.
- **Pre-1.0.0** — breaking changes are allowed, but the increment rule still applies. When a breaking change is detected on `0.x`, ask the user whether to go to `1.0.0` or `0.(MAJOR+1).0`.
- **Highest wins** — any breaking change makes it major; otherwise any feature makes it minor; otherwise patch.
- **RC** — each verified milestone gets `X.Y.Z-rc.N`. The final `X.Y.Z` is chosen only in Phase 6, after all release milestones are verified and the release audits and approvals pass.
- **RC reset** — when the base version changes from the latest RC's base, the RC number resets to 1. When the base is unchanged, increment the RC number.

## Procedure

### 1. Establish the baseline

1. Read the last released version:
   - `git tag --list 'v*' --sort=-v:refname` and variants without the `v` prefix; take the highest SemVer tag;
   - otherwise list releases via `manage-releases` and take the highest `Release <version>` with the `released` label;
   - otherwise ask the user; do not guess.
2. Cross-check project version files (`package.json`, `Cargo.toml`, `build.gradle*`, `pom.xml`, `pyproject.toml`, `VERSION`, etc.). If they disagree, report the discrepancy and ask which is authoritative.
3. Record `baseline = MAJOR.MINOR.PATCH` from the last final release.

### 2. Resolve the scope

**RC mode (Phase 5):**

1. Read the milestone and its tasks.
2. Consider only the milestone's `Done` tasks and the changes they delivered.

**Release mode (Phase 6):**

1. Read the release and its assigned milestones.
2. Consider every `Done` task in every release milestone.
3. If no `Done` task exists, report it and ask whether to keep the baseline.

### 3. Classify each change

For each considered task, classify `breaking`, `feature`, or `chore` with evidence.

- Evidence: labels (`breaking`, `feature`, `enhancement`, `chore`), acceptance criteria, changed public contracts, schema or format changes, comments.
- Mixed or ambiguous evidence: mark `unknown` and ask the user; never classify silently.
- A task touching a breaking surface and an internal refactor is `breaking`.
- A dependency update that forces an API change is `breaking`; a pure version bump is `chore`.
- Documentation of a new feature is `chore`; the task that adds the capability is `feature`.

Produce a table: Task ID | Title | Class | Evidence.

### 4. Determine the increment

1. If any task is `unknown`, ask the user and stop until answered.
2. Any `breaking` -> major; otherwise any `feature` -> minor; otherwise patch.
3. Apply the increment to the baseline:
   - major: `(MAJOR+1).0.0`;
   - minor: `MAJOR.(MINOR+1).0`;
   - patch: `MAJOR.MINOR.(PATCH+1)`.
4. Pre-1.0.0 breaking change: ask which base to use and stop.

### 5. Determine RC or final

**RC mode:**

1. Find the latest RC for the same base: `git tag --list '*-rc.*' --sort=-v:refname` and managed release titles.
2. Same base -> next RC number = latest + 1. Different base -> 1. No prior RC -> 1.
3. Recommended version = `X.Y.Z-rc.N`.

**Release mode:**

1. Use the RC versions recorded in the verified milestones as inputs.
2. Recommended version = the new base version `X.Y.Z`.
3. If the final version differs from the latest milestone RC base, report why.

### 6. Report

- Baseline and its source.
- Scope: milestone or release, and included tasks.
- Classification table.
- Increment class and reason.
- RC handling (reset or increment).
- **Recommended version**.
- Caveats: non-`Done` work was excluded; a later breaking change may reset the version.

Do not create tags, edit version files, or change managed record state. The orchestrator records the recommendation in the Phase 5 verification task or on the release.

## Stop conditions

- Baseline cannot be determined.
- Scope is ambiguous.
- A change cannot be classified confidently.
- A breaking change is detected on a pre-1.0.0 baseline.
- No `Done` work exists in scope.

## Completion checks

- Baseline identified with its source.
- Scope and included tasks stated.
- Only `Done` work considered; excluded work noted.
- Classification table has evidence for every task.
- Increment justified by the highest-severity change.
- RC numbering explains reset or increment.
- Recommended version is printed separately from the rationale.
- No repository, managed record, tag, or version file was modified.
