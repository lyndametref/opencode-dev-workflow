---
name: deployment
description: 'Deploy an approved release from its built packages in Phase 6: resolve the recorded target, verify the package and version, run the project deployment procedure, verify the result, and report deployment evidence. Project-specific targets and procedures.'
argument-hint: 'Provide the release ID, final version, and target environment(s).'
user-invocable: true
disable-model-invocation: false
---

# Deployment

## Outcome

The release's final version is deployed to the recorded target environment(s) from the packages under `builds/<version>/`, and the deployment evidence is reported: version, commit SHA, targets, result, verification performed, and timestamp with timezone. If deployment cannot proceed, it stops and reports the blocker.

## When to use

- Phase 6, after the user approves the release and authorizes deployment.
- A failed deployment was fixed and the deployment is retried.

Do not use this skill to build, rebuild, repackage, test, verify a milestone, or audit.

## Prerequisites

- The release is approved and records the final version and commit SHA.
- The final packages exist under `builds/<version>/` with a manifest and checksums, or packaging is explicitly waived by the user.
- The release names the target environment(s).
- The deployment procedure for the project is known. If it is not, stop and ask; never improvise a deployment.

## Inputs

- Release ID, final version, commit SHA.
- Package evidence: component archives, paths, sizes, sha256.
- Target environment(s), from the release record.
- The project's deployment procedure and required credentials, supplied through the environment or secret manager.

## Procedure

1. **Confirm approval and version** — read the release. Confirm the user approved the release, the final version is recorded, and the target is named. If not, stop.
2. **Verify the package** — confirm each component archive exists under `builds/<version>/` and its checksum matches. Confirm the manifest version and commit SHA. If packaging is waived, deploy only when the project defines an alternate artifact source and the user authorized it; otherwise stop. Never invent an artifact.
3. **Preflight the target** — confirm the target environment, access method, and required secrets are available without exposing them. Confirm the deployment procedure is defined. A missing procedure or credential is a blocker.
4. **Deploy** — run the project's deployment procedure for the recorded version and target(s), using the built packages. Do not build from source, edit tracked files, or substitute a different artifact.
5. **Verify** — run the project's post-deployment check: version endpoint, health check, smoke test, or equivalent. Record the command and result.
6. **Report evidence** — version, commit SHA, target environment(s), artifact paths and checksums, deployment command or procedure, result, post-deployment verification, and timestamp with timezone. Redact secrets.
7. **Stop** — do not retry with an improvised procedure. A failed deployment is reported for fix work.

## Rules

- Deployment is the only point in the workflow that changes a live environment.
- Deploy only an approved release, under its recorded final version, to its recorded target(s).
- Use the built packages; never rebuild, repackage, or pull a different artifact.
- Never change requirements, code, configuration under version control, scope, or version.
- Never reveal secrets, credentials, tokens, or personal data; redact values and give the location.
- Do not commit, tag, push, or upload.
- Rollback is project-specific. Use it only when the project defines it and the user authorizes it; otherwise stop and report.
- Use only project-local `./.tmp/` for transient output and remove it before finishing.

## Failure handling

| Outcome | Action |
|---|---|
| Release not approved or version missing | Stop; nothing is deployed. |
| Package missing or checksum mismatch | Stop; report the artifact; nothing is deployed. |
| Target missing or ambiguous | Stop; ask the user; never guess an environment. |
| Deployment procedure or credential missing | Stop; report the blocker; do not improvise. |
| Deployment command fails | Report the command, exit status, and evidence; do not retry with an improvised procedure. |
| Post-deployment verification fails | Report the failure; the release is not complete. |
| Rollback needed and defined | Follow the project rollback procedure only with the user's authorization. |

## Stop conditions

- The release is not approved or the final version is not recorded.
- The package is missing, incomplete, or fails its checksum.
- The target environment is missing or ambiguous.
- The deployment procedure or a required credential is unavailable.
- A deployment or verification step fails.
- Completing the deployment would require changing source, configuration, or artifacts.

## Report format

- **Release**: ID, final version, commit SHA.
- **Target**: environment(s) and access method (redacted).
- **Artifacts**: component archives, paths, sizes, sha256.
- **Procedure**: command or documented procedure.
- **Result**: success / failure, with exit status and evidence.
- **Post-deployment verification**: check, command, result.
- **Timestamp**: with timezone.
- **Waiver**: recorded waiver, or `none`.
- **Blockers / next action**: or `none`.

## Completion checks

- Approval, version, and target were confirmed before deployment.
- The deployed artifacts match the recorded version and checksums.
- The project deployment procedure was followed; nothing was improvised.
- Post-deployment verification ran and is reported.
- No build, repackage, source change, commit, tag, push, or upload happened.
- Secrets are redacted.
- Deployment evidence is reported with a timestamp that includes its timezone.
