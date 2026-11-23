---
name: packaging
description: 'Build and publish the final release packages in Phase 6, separately from development: each *-dev agent builds its own component with <component-dir>/scripts/build-package.sh under the final version, and the orchestrator verifies the archives, manifest, and checksums under the git-ignored builds/<version>/. No RC mode.'
argument-hint: 'Provide the release ID and its recorded final version. Dev agents also provide their component and artifact path.'
user-invocable: true
disable-model-invocation: false
---

# Final Packaging

## Outcome

One final package for the recorded version, on the local machine only:

- `builds/<version>/` inside the project, containing one archive per deployable component, `MANIFEST.txt`, and a `.sha256` file per archive;
- the directory confirmed git-ignored, staged nowhere, committed nowhere, tagged nowhere, pushed nowhere, uploaded nowhere;
- package evidence (version, commit SHA, scripts run, component list, absolute paths, sizes, checksums) recorded in the release report.

## When to use

- **Component mode** — a `*-dev` agent is dispatched in Phase 6 to build its component's package.
- **Verification mode** — the orchestrator checks the component archives, assembles `MANIFEST.txt` and the checksums, and records the evidence.

Do not use this skill to verify a milestone, implement a development task, fix code, choose versions, tag, push, upload, or deploy. Development work uses `implementation`.

## Prerequisites

- The final version is provided by the orchestrator and recorded on the release. Use the provided version string verbatim; never re-derive it here.
- All source changes are committed: `git status --porcelain` is empty. Record the commit SHA with `git rev-parse HEAD`.
- Every deployable component has an executable `<component-dir>/scripts/build-package.sh` at the commit, inside the owning `*-dev` agent's own folder. In a multi-app repository `<component-dir>` is `apps/<app>`; in a single-app repository whose deployable component is the repository root, the script is `scripts/build-package.sh` at the repository root. The script is created and owned by that agent; components never share one script.
- The project's `.gitignore` contains the package directory (`builds/`). If it does not, ask the user to add it before building; never build into a tracked path.

If a build script is missing, stop and report it. The orchestrator creates a fix task for the owning `*-dev` agent. This skill never writes or patches the build itself.

## Package layout

```text
builds/<version>/
  <project>-<version>-<component>.<ext>
  <project>-<version>-<component>.<ext>.sha256
  MANIFEST.txt
  .build/<component>/            # raw script output, ignored and not distributed
```

- `<version>` is exactly the recorded final version, e.g. `1.2.0`.
- `<component>` is the building block, e.g. `android`, `backend`, `frontend`.
- Component names and archive formats come from the Technical specification and the project's build scripts, not from assumptions.

`MANIFEST.txt` contains:

- project name and description;
- version;
- commit SHA the package was built from;
- build time in UTC with the timezone (`2026-11-19T10:20:30Z`);
- toolchain versions reported by the scripts;
- component list with script path, version argument, archive file name, size, and sha256.

## Procedure — component mode (`*-dev`)

1. **Confirm the version and the tree** — use the final version provided by the orchestrator and the commit SHA. Stop if the tree is dirty, the version is missing, or your component archive already exists.
2. **Confirm your script** — your `<component-dir>/scripts/build-package.sh` exists and is executable. A missing script is a stop condition; report it.
3. **Build your component** — run `<component-dir>/scripts/build-package.sh --version <version> --out builds/<version>/.build/<component>` from the repository root. Capture stdout (produced paths), stderr, exit status, and the script path. Never fall back to ad-hoc build commands.
4. **Package your component** — archive only the produced deliverables as `builds/<version>/<project>-<version>-<component>.<ext>`. Exclude build intermediates, dependency caches, VCS metadata, IDE files, environment files, secrets, credentials, logs, and local databases.
5. **Report** — component, version, commit SHA, script path and command, archive path, size, checksum, and result. Do not build another component's package.

## Procedure — verification mode (orchestrator)

1. **Confirm the version and the tree** — read the release's final version and the commit SHA. Stop if the tree is dirty, the version is missing, or `builds/<version>/` contains a previous complete package.2. **Resolve the deployable components** — read the Technical specification and the release milestones; list every deployable building block with its directory.
3. **Confirm the archives** — each component archive reported by its `*-dev` agent exists under `builds/<version>/`. A missing component is a stop condition; report it for a fix task.
4. **Confirm the destination is ignored** — run `git check-ignore -q builds/<version>`. Stop if it fails.
5. **Validate the contents** — list every archive: every entry is an intended deliverable, no file outside the verified scope, no secret material, no build intermediates, dependency caches, VCS metadata, IDE files, environment files, credentials, logs, or local databases.
6. **Write the manifest and checksums** — write `MANIFEST.txt`, then a `.sha256` next to every archive.
7. **Gate on git** — `git check-ignore -q builds/<version>` passes; `git status --porcelain` shows nothing from `builds/`. Never run `git add` on it.
8. **Record the evidence** — version, commit SHA, script paths and commands, component list, absolute directory path, per-file size and sha256, validation result; or the recorded waiver.
9. **Report** — the version, directory path, component list, checksums, scripts used, and that nothing was committed, tagged, pushed, uploaded, or deployed.

## Rules

- The package is a deliverable, not scratch: it lives in the git-ignored `builds/` directory and is never cleaned up like `./.tmp/`.
- Local publication only. This skill never tags, pushes, uploads, or deploys.
- Every deployable component is built by its own `<component-dir>/scripts/build-package.sh`; never improvise commands.
- A version is immutable: never overwrite or rebuild into an existing `builds/<version>/`. A changed release needs a new final version.
- A packaging waiver is explicit and user-only. Without one, a missing script blocks the scope; no skipping, no partial package.
- Build from the recorded commit SHA; the manifest must let someone else reproduce the package.
- Do not change source, tests, configuration, version files, or build scripts to make packaging succeed.
- `builds/` is git-ignored in every project; if the ignore rules would track it, stop and report.
- Use only project-local `./.tmp/` for transient work; the package itself is a deliverable.

## Failure handling

| Outcome | Action |
|---|---|
| Dirty working tree or a change outside the scope | Stop; package only a committed, verified tree. |
| A deployable component has no build script | Stop; report it; the orchestrator creates a fix task for the owning `*-dev` agent. |
| A build script fails | Stop; report the script, command, and exit status; the failure becomes fix work. |
| Package directory not ignored | Stop; ask the user to ignore `builds/`; never package into a tracked path. |
| Version directory already exists | Stop; the version is immutable; changed content needs a new version. |
| Secret or unintended file found in an archive | Stop; report it; the package is not published and the finding is recorded. |
| Unclear deployable components | Stop; return to the Technical specification or the orchestrator; never guess. |

## Stop conditions

- The version is not recorded or is ambiguous.
- The working tree is dirty or the commit SHA cannot be determined.
- A deployable component has no executable build script and no recorded user waiver.
- A build script fails or violates its contract.
- The destination is not git-ignored.
- The version directory already exists.
- An archive contains files outside the scope or any secret material.

## Report format

- **Version**: string and source (release record, or the version passed by the orchestrator).
- **Commit**: SHA the package was built from.
- **Directory**: path to `builds/<version>/`.
- **Components**: script path, command, archive file name, size, sha256.
- **Validation**: archive contents checked, excluded patterns confirmed.
- **Git state**: directory ignored, nothing staged or committed.
- **Waiver**: recorded waiver and reason, or `none`.

## Completion checks

- The package exists under `builds/<version>/` and matches the recorded version.
- Every deployable component has an archive with a checksum, built by its own script.
- `MANIFEST.txt` is complete and reproducible.
- The archive contents were validated; no secret or unintended file is present.
- `git check-ignore` passes and nothing from the package is staged, committed, tagged, pushed, or uploaded.
- The evidence or the user waiver is recorded in the release report.

## Resume / interruption

Packaging state is derived from `builds/<version>/`, the manifest, the component reports, and the recorded evidence. On re-invocation, re-read them and skip completed steps. A partially written directory for the same version is never reused: report it and require a new version decision.
