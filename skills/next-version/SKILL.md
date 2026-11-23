---
name: next-version
description: 'Choose the final Semantic Version of a release from the changes it contains, handling major/minor/patch classification. There are no RC versions in this workflow.'
argument-hint: 'Provide a release ID. If omitted, resolve from the managed records and ask when ambiguous.'
user-invocable: true
disable-model-invocation: false
---

# Final Version Selection

## Outcome

One recommended final version string (`X.Y.Z`) with its rationale, increment class, baseline, and the changes considered. No backlog state, version file, or Git tag is changed. The orchestrator records the recommendation on the release in Phase 6.

## When to use

- Phase 6, after the scope-and-findings approval and before the final build.
- The user asks which version the release should carry.

Do not use this skill to verify a milestone, close a release, or create tags.

## Prerequisites

- Load `manage-releases`.
- Read access to Git tags and the project's version files.
- The release scope in the managed records: its milestones and their `Done` tasks.

## Versioning rules

The project follows Semantic Versioning (`MAJOR.MINOR.PATCH`).

- **Breaking** — a change to a public API, file format, or command-line argument (renamed, removed, or changed semantics): **major**.
- **Feature** — a backward-compatible addition (new capability, endpoint, option, field): **minor**.
- **Chore** — documentation, dependency updates, refactors with no behavior change, tests, build changes: **patch**.
- **Pre-1.0.0** — breaking changes are allowed, but the increment rule still applies. When a breaking change is detected on `0.x`, ask the user whether to go to `1.0.0` or `0.(MINOR+1).0`.
- **Highest wins** — any breaking change makes it major; otherwise any feature makes it minor; otherwise patch.
- **No RC versions** — milestones have no release-candidate version and no package. The final version is chosen once in Phase 6.

## Procedure

### 1. Establish the baseline

1. Read the last released version:
   - `git tag --list 'v*' --sort=-v:refname` and variants without the `v` prefix; take the highest SemVer tag;
   - otherwise list releases via `manage-releases` and take the highest `Release <version>` with the `released` label;
   - otherwise ask the user; do not guess.
2. Cross-check project version files (`package.json`, `Cargo.toml`, `build.gradle*`, `pom.xml`, `pyproject.toml`, `VERSION`, etc.). If they disagree, report the discrepancy and ask which is authoritative.
3. Record `baseline = MAJOR.MINOR.PATCH` from the last final release.

### 2. Resolve the scope

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

### 5. Report

- Baseline and its source.
- Scope: release and included tasks.
- Classification table.
- Increment class and reason.
- **Recommended final version**.
- Caveats: non-`Done` work was excluded; a later breaking change may invalidate the choice.

Do not create tags, edit version files, or change managed record state. The orchestrator records the recommendation on the release.

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
- Recommended final version is printed separately from the rationale.
- No repository, managed record, tag, or version file was modified.
