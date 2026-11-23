---
name: build-package-script
description: 'Create or update the component build script that produces a deployable artifact from a given version, so packaging can build it without ad-hoc commands. Defines the script path, interface, behavior, and per-technology examples.'
argument-hint: 'Provide the component directory (`apps/<app>` in a multi-app repository, or the repository root for a single-app project), its technology, and the version format to inject.'
user-invocable: true
disable-model-invocation: false
---

# Component Build Script

## Outcome

One executable, committed script per deployable component:

```text
<component-dir>/scripts/build-package.sh
```

In a multi-app repository `<component-dir>` is `apps/<app>`; in a single-app repository whose deployable component is the repository root, the script is `scripts/build-package.sh` at the repository root.

It builds that component's deliverables for a given version into a given output directory. Packaging runs it in Phase 6 for the final release; nobody has to reconstruct the build command by hand.

## When to use

- A task explicitly asks to create or update a component's build script.
- Packaging reported a missing or failing build script, and the orchestrator created the corresponding task.

Do not use this skill to package a release, choose versions, change requirements, or edit code outside the assigned component.

## Ownership

- The `*-dev` agent of the component's technology owns the script: `android-dev` for Kotlin/Android, `backend-dev` for the backend stack, `frontend-dev` for web front ends, `rust-dev` for Rust.
- The script lives inside the owning agent's own component folder, so that agent can create and maintain it; components never share one script.
- The script is source code: it is committed, reviewed, and changed only through a task.
- Packaging never writes or patches scripts; it only runs them.

## Contract

Path and permissions:

- `<component-dir>/scripts/build-package.sh`, mode `755`.
- Shebang `#!/usr/bin/env bash`; `set -euo pipefail`.

Interface:

```bash
<component-dir>/scripts/build-package.sh --version <X.Y.Z> --out <dir>
<component-dir>/scripts/build-package.sh --help
```

- `--version` is the final release version exactly as packaging received it.
- `--out` is the directory that receives the deliverables.
- `--help` prints usage without building; exit 0.
- Unknown or missing arguments: clear error on stderr, non-zero exit.

Behavior:

- Resolve the repository root from the script's own path, so it works from any working directory.
- Detect the required toolchain and fail with a clear message when it is missing.
- Inject the version without editing tracked files: build properties, CLI flags, generated manifests, or environment variables.
- Clean the destination for this component before writing, so reruns are idempotent.
- Write only under `--out` plus the tool's normal cache (`target/`, `.gradle/`, `node_modules/`).
- Print one produced file path per line on stdout; all diagnostics go to stderr.
- Exit non-zero when the build fails; never exit 0 with missing outputs.
- Be non-interactive: no prompts, no pagers, no color-dependent output.

Prohibited:

- Committing, tagging, pushing, or uploading.
- Writing outside `--out` and the tool cache.
- Embedding secrets, credentials, machine-specific absolute paths, or environment assumptions.
- Downloading tools at build time beyond the normal dependency resolution of the project.
- Reading the version from Git tags instead of the `--version` argument.

## Procedure

1. **Read the component** — its directory, technology, build tool, and the artifact it must produce (from the Technical specification and existing build files).
2. **Write the script** — implement the contract above for that technology. Keep it thin: delegate to the build tool, do not reimplement it.
3. **Self-check** — run `--help`; then run `--version 0.0.0-test --out ./.tmp/script-check/<component>/`; confirm the expected files appear, are non-empty, and carry the injected version where applicable; rerun to confirm idempotency.
4. **Clean up** — remove `./.tmp/script-check/`.
5. **Commit** — commit the script with the task's branch and report the path and commit.
6. **Report** — script path, technology, toolchain requirements, produced artifacts, self-check result, and any known limitation.

## Per-technology examples

Cargo (Rust):

- `cargo build --release --locked` with `CARGO_PKG_VERSION` or a build-time environment variable;
- copy the binary to `--out`; fail if the target triple is unsupported.

Gradle (Android):

- `./gradlew :app:assembleRelease` with `-PversionName="$version"`;
- copy the APK/AAB to `--out`; require a signing configuration supplied by the environment, never hardcoded.

Gradle or Maven (backend):

- `./mvnw -q -Drevision="$version" package -DskipTests` or `./gradlew bootJar -Pversion="$version"`;
- copy the jar/war to `--out`; tests remain the caller's responsibility, not the packaging script's.

npm/Vite (frontend):

- `npm ci --omit=dev` or `npm ci`, then `VITE_APP_VERSION="$version" npm run build`;
- copy the `dist/` contents or a `dist` archive to `--out`.

Adapt the exact commands to the component; the contract, not the tool, is fixed.

## Rules

- One script per deployable component; shared libraries do not need one.
- The script replaces ad-hoc packaging commands; packaging never runs anything else.
- A breaking change to the interface requires user agreement, because packaging depends on it.
- Tests are not run by the script; the release final build and tests run separately.
- Keep the script deterministic where the tool allows it.

## Failure handling

| Outcome | Action |
|---|---|
| Toolchain missing | Fail with an actionable message; do not install tools silently. |
| Version injection would edit tracked files | Use a generated or flag-based mechanism instead. |
| Outputs missing or empty | Non-zero exit; the task is not complete. |
| Signing or credentials required | Read them from the environment; fail clearly when absent; never hardcode. |

## Stop conditions

- The component is not a deployable building block.
- The build cannot produce an artifact without a product or technical decision.
- The required version format is unknown.
- The build requires credentials the task does not provide.

## Report format

- **Component**: directory and technology.
- **Script**: path, mode, commit.
- **Toolchain**: required tools and versions.
- **Artifacts**: produced file names and where the version appears.
- **Self-check**: commands run and results.
- **Limitations**: signing, platform constraints, or `none`.

## Completion checks

- The script exists at the contracted path, is executable, and is committed.
- `--help` works; `--version` and `--out` are honored.
- A run produces the expected artifacts with the injected version.
- Reruns are idempotent; no tracked file is modified.
- No secret or machine-specific path is embedded.
- The self-check output was cleaned up.
