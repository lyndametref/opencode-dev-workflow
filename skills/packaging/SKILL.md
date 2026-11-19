---
name: packaging
description: 'Publish a versioned deliverable package: build every deployable component through its own scripts/build-package.sh with the recorded version, assemble per-component archives plus a manifest and checksums under builds/<version>/, gate on the directory being git-ignored, and record the evidence without committing, tagging, pushing, or uploading. Used for the RC package at the end of Phase 5 and the final package in Phase 6.'
argument-hint: 'Provide the milestone ID and its recorded RC version, or the release ID and its recorded final version.'
user-invocable: true
disable-model-invocation: false
---

# Versioned Packaging

## Outcome

One published package for the recorded version, on the local machine only:

- `builds/<version>/` inside the project, containing one archive per deployable component, `MANIFEST.txt`, and a `.sha256` file per archive;
- the directory confirmed git-ignored, staged nowhere, committed nowhere, tagged nowhere, pushed nowhere, uploaded nowhere;
- package evidence (version, commit SHA, scripts run, component list, absolute paths, sizes, checksums) recorded in the Phase 5 verification task or in the Phase 6 release report.

## When to use

- **Phase 5 RC mode**, after the milestone verification passed and `next-version` delivered the RC version.
- **Phase 6 final mode**, after the final build and tests passed and `next-version` delivered the final version.

Do not use this skill to verify a milestone, fix code, choose versions, tag, push, upload, or deploy.

## Prerequisites

- The version is recorded: the RC version in the verification task, or the final version on the release. Take the version string verbatim from `next-version`; never re-derive it here.
- All source changes of the scope are committed: `git status --porcelain` is empty. Record the commit SHA with `git rev-parse HEAD`.
- Every deployable component has an executable `<component-dir>/scripts/build-package.sh` at the commit. The script is created and owned by the technology's `*-dev` agent.
- The project's `.gitignore` contains the package directory (`builds/`). If it does not, ask the user to add it before building; never build into a tracked path.

If a build script is missing, stop and report it. The planner creates a task for the owning `*-dev` agent: in the milestone during Phase 5, in the release's fix milestone in Phase 6. This skill never writes or patches the build itself.

## Package layout

```text
builds/<version>/
  <project>-<version>-<component>.<ext>
  <project>-<version>-<component>.<ext>.sha256
  MANIFEST.txt
  .build/<component>/            # raw script output, ignored and not distributed
```

- `<version>` is exactly the recorded version, e.g. `1.2.0-rc.2` or `1.2.0`.
- `<component>` is the architecture building block, e.g. `android`, `backend`, `frontend`.
- Component names and archive formats come from the architecture's deployment view, not from assumptions.

`MANIFEST.txt` contains:

- project name and description;
- version, and base version for an RC;
- commit SHA the package was built from;
- build time in UTC with the timezone (`2026-11-19T10:20:30Z`);
- toolchain versions reported by the scripts;
- component list with script path, version argument, archive file name, size, and sha256.

## Procedure

1. **Confirm the version and the tree** — read the recorded version and the commit SHA. Stop if the tree is dirty, the version is missing, or `builds/<version>/` already exists.
2. **Resolve the deployable components** — read the architecture's deployment view and list every deployable building block with its directory.
3. **Require the build scripts** — for each one, confirm `<component-dir>/scripts/build-package.sh` exists and is executable. A missing script is a stop condition; report it for a task. If the user waived packaging for this scope, stop here and record the waiver; nothing is built or published.
4. **Confirm the destination is ignored** — run `git check-ignore -q builds/<version>`. Stop if it fails.
5. **Build each component with its script** — run `scripts/build-package.sh --version <version> --out builds/<version>/.build/<component>` from the repository root. Capture stdout (produced paths), stderr, exit status, and the script path. Never fall back to ad-hoc build commands.
6. **Assemble the archives** — archive only the produced deliverables. Exclude build intermediates, dependency caches, VCS metadata, IDE files, environment files, secrets, credentials, logs, and local databases.
7. **Validate the contents** — list every archive: every entry is an intended deliverable, no file outside the verified scope, no secret material.
8. **Write the manifest and checksums** — write `MANIFEST.txt`, then a `.sha256` next to every archive.
9. **Gate on git** — `git check-ignore -q builds/<version>` passes; `git status --porcelain` shows nothing from `builds/`. Never run `git add` on it.
10. **Record the evidence** — version, commit SHA, script paths and commands, component list, absolute directory path, per-file size and sha256, validation result; or the recorded waiver.
11. **Report** — the version, directory path, component list, checksums, scripts used, and that nothing was committed, tagged, pushed, uploaded, or deployed.

## Rules

- The package is a deliverable, not scratch: it lives in the git-ignored `builds/` directory and is never cleaned up like `./.tmp/`.
- Local publication only. This skill never tags, pushes, uploads, or deploys; those need explicit user approval outside this skill.
- Every deployable component is built by its own `scripts/build-package.sh`; the orchestrator never improvises commands.
- A version is immutable: never overwrite or rebuild into an existing `builds/<version>/`. A rebuild after corrections requires a new RC version; a changed release requires a new final version.
- A packaging waiver is explicit and user-only. Without one, a missing script blocks the scope; no skipping, no partial package.
- Build from the recorded commit SHA; the manifest must let someone else reproduce the package.
- Do not change source, tests, configuration, version files, or build scripts to make packaging succeed.
- `builds/` is git-ignored in every project; if the ignore rules would track it, stop and report.

## Failure handling

| Outcome | Action |
|---|---|
| Dirty working tree or a change outside the scope | Stop; package only a committed, verified tree. |
| A deployable component has no build script | Stop; report it; the planner creates a task for the owning `*-dev` agent. |
| A build script fails | Stop; report the script, command, and exit status; the failure becomes correction or fix work; the scope is not complete. |
| Package directory not ignored | Stop; ask the user to ignore `builds/`; never package into a tracked path. |
| Version directory already exists | Stop; the version is immutable; changed content needs a new version. |
| Secret or unintended file found in an archive | Stop; report it; the package is not published and the finding is recorded. |
| Unclear deployable components | Stop; return to the architecture or the planner; never guess. |

## Stop conditions

- The version is not recorded or is ambiguous.
- The working tree is dirty or the commit SHA cannot be determined.
- A deployable component has no executable build script and no recorded user waiver.
- A build script fails or violates its contract.
- The destination is not git-ignored.
- The version directory already exists.
- An archive contains files outside the scope or any secret material.

## Report format

- **Version**: string and source (verification task or release record).
- **Commit**: SHA the package was built from.
- **Directory**: path to `builds/<version>/`.
- **Components**: script path, command, archive file name, size, sha256.
- **Validation**: archive contents checked, excluded patterns confirmed.
- **Git state**: directory ignored, nothing staged or committed.
- **Waiver**: recorded waiver and reason, or `none`.

## Completion checks

- The package exists under `builds/<version>/` and matches the recorded version.
- Every deployable component in the architecture has an archive with a checksum, built by its own script.
- `MANIFEST.txt` is complete and reproducible.
- The archive contents were validated; no secret or unintended file is present.
- `git check-ignore` passes and nothing from the package is staged, committed, tagged, pushed, or uploaded.
- The evidence or the user waiver is recorded in the verification task or release report.

## Resume / interruption

Packaging state is derived from `builds/<version>/`, the manifest, and the recorded evidence. On re-invocation, re-read them and skip completed steps. A partially written directory for the same version is never reused: report it and require a new version decision.
