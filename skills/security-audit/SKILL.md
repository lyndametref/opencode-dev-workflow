---
name: security-audit
description: 'Run the Phase 5 security audit over the whole frozen codebase: secrets, dependency supply chain, authentication and authorization, input handling, data protection, platform-specific and cross-feature risks, and security NFR coverage. Produces a read-only, severity-ranked Audit artifact for the user fix-or-own decision.'
argument-hint: 'Provide the release ID and the feature freeze.'
user-invocable: true
disable-model-invocation: false
---

# Security Audit

## Outcome

One security audit of the frozen codebase, recorded as a managed audit record of type `security` with status `issued`, severity-ranked findings, and a recommendation. The user decides for every finding whether it is fixed or owned. The audit is read-only; the orchestrator records it and owns approval and release closure.

## When to use

- Phase 5, after the user declares the feature freeze.
- The user asks for a security audit, security review, or security gate at the freeze.

Do not use this skill for:

- Fixing vulnerabilities or writing code/configuration.
- Style, accessibility, or general code-quality review (use `code-audit` or `quality-audit`).
- Delivering milestone work (use `milestone-execution`) or closing a release (use `release-management`).
- Auditing one milestone; Phase 5 audits the whole frozen codebase.

## Prerequisites

- **managed-records skill (REQUIRED)** — load it before any managed read. All release, milestone, task, requirement, decision, and specification reads go through the management tool.
- Read access to requirements, Technical specification, decisions, and application source.
- Available scanners and test commands for the stacks present, when possible.

## Constraints

- Read-only: do not modify code, configuration, requirements, tasks, decisions, or status.
- Never edit managed files directly; read through the matching `manage-*` skills.
- The orchestrator runs this skill and records the audit (manage-audits). Never create or edit the audit record yourself.
- Never reveal secrets, credentials, tokens, personal data, or exploit-ready payloads. Redact values and give the location.
- Report only findings traceable to evidence. Mark unverifiable controls as `not verified`, not as passed.
- Do not invent threats unrelated to the audited scope.
- Do not ask the user for approval and do not close the release; the orchestrator owns that.
- Do not create persistent reports. Return the report in the response. Use only project-local `./.tmp/` for transient scanner output and delete it before finishing, including when the audit is blocked.

## Procedure

### 1. Establish scope

1. Load `manage-audits`; read the release, its frozen milestones, and tasks through the `manage-*` skills.
2. Confirm the feature freeze is recorded and every frozen milestone's verification task is `Done`; report any exception.
3. Read linked requirements and security/privacy NFRs (manage-requirements, manage-nfrs), the Technical specification (manage-tech-specs), UI specifications, and decisions (manage-decisions).
4. Record the baseline commit, scope boundaries, and anything explicitly out of scope.
5. Identify cross-feature risks: combinations of features that create a risk no single milestone reveals (combined permissions, shared data flows, chained integrations, cumulative attack surface).

### 2. Inventory the attack surface

Identify, per application in `apps/`:

- languages, frameworks, and runtime versions;
- entry points: HTTP endpoints, CLI commands, background jobs, message consumers, deep links, exported Android components, WebView bridges, IPC/FFI;
- authentication and authorization mechanisms;
- data stores and data flows, including personal or sensitive data;
- secrets and configuration sources;
- third-party dependencies and build plugins;
- file upload, download, import, and export paths;
- network egress and external integrations.

### 3. Run checks

Run every check that applies. Use available tools; if a tool is unavailable, record the limitation and perform a manual review.

**Secrets and configuration**
- Search tracked files and, when history access is available, repository history for hardcoded credentials, API keys, tokens, private keys, and connection strings. If history access is unavailable, record the limitation and audit the current tree.
- Verify secrets come from environment or a secret manager and are not committed.
- Verify debug flags, verbose errors, and test backdoors are disabled for release.

**Dependency and supply chain**
- Run the ecosystem audit tool when available: `npm audit`, `cargo audit`, `pip-audit`, Gradle dependency verification or OWASP dependency-check, or the project's equivalent.
- Flag known-vulnerable direct and transitive dependencies, unmaintained critical libraries, and unpinned or untrusted sources.

**Authentication and authorization**
- Verify authentication is required on every non-public entry point.
- Verify authorization is enforced server-side per object and per action, not only in the UI.
- Check session/token lifetime, rotation, revocation, storage, and transport.
- Check password and credential handling; verify no plaintext storage.
- Verify privilege boundaries between roles and tenants.

**Input handling and injection**
- Verify server-side validation and canonicalization for every external input.
- Check SQL/JPQL/native query construction for injection.
- Check OS command, shell, path, template, LDAP, XPath, and expression-language injection.
- Check deserialization of untrusted data.
- Check file upload type, size, name, and storage-path handling; block path traversal and executable content.
- Check SSRF and unsafe outbound requests.
- Check XML parsing for external entity expansion.

**Output and client-side**
- Check HTML/JS/CSS output encoding and DOM sinks for XSS.
- Check CSRF protection for state-changing requests.
- Check CORS policy and allowed origins.
- Check security headers: CSP, HSTS, X-Content-Type-Options, frame ancestors, referrer policy.
- Check client-side storage of tokens and sensitive data.

**Data protection and privacy**
- Verify transport encryption and certificate validation.
- Verify sensitive data at rest is protected where required.
- Verify logs, errors, analytics, and crash reports do not leak secrets or personal data.
- Verify data minimization, retention, and deletion behavior against requirements.

**Platform specifics**

- Android: exported components, intent handling, permissions, storage modes, WebView settings, network security config, backup rules, root/debug detection where required, and hardcoded secrets in resources.
- Backend: Spring Security configuration, endpoint exposure, actuator endpoints, JPA query construction, multipart handling, and error responses.
- Frontend: DOM XSS, Alpine.js expression injection, unsafe `innerHTML`, token storage, CSP compatibility, and third-party scripts.
- Rust: `unsafe` blocks, FFI boundaries, integer overflow in release mode, panic exposure, command/path handling, and TLS configuration.

**Security NFR coverage**
- Map each referenced security/privacy NFR to evidence.
- Flag NFRs with no implementation evidence as gaps.

**Cross-feature risks**
- Assess risks created by combining the features: privilege composition, shared secrets or sessions, data crossing feature boundaries, and cumulative exposure of entry points.

### 4. Verify

- Reproduce or confirm each finding with a concrete command, test, or code path.
- Run the project's security-relevant tests when available.
- Do not mark a finding confirmed based only on a comment or a specification claim.
- Separate confirmed findings from observations and unverified controls.

### 5. Classify and decide

Assign severity:

- **Blocker** — exploitable now with severe impact: auth bypass, remote code execution, exposed production secrets, unauthenticated sensitive-data access.
- **High** — serious impact requiring limited preconditions: stored XSS, SQL injection behind authentication, missing object-level authorization, vulnerable critical dependency.
- **Medium** — meaningful risk with mitigating preconditions or limited scope.
- **Low** — hardening issue with low impact.

Decision:

- `findings reported` — any unresolved Blocker or High finding prevents a passing audit.
- `pass` — no findings, or only Medium/Low findings documented with recommendations.

### 6. Report

Produce the report in the response and hand it to the orchestrator. The orchestrator records the `AUD` record. Do not change status, close the release, or request approval.

## Output Format

- **Audit target**: release, freeze, baseline commit.
- **Scope covered**: applications, components, entry points, requirement IDs, and exclusions.
- **Method**: checks and scanners run, commands, and limitations.
- **Findings**: table with severity | finding | evidence | impact | recommendation.
- **Severity counts**: blocker / high / medium / low.
- **NFR security coverage**: addressed / not applicable / gaps.
- **Secrets check**: result and redacted locations.
- **Dependency and supply-chain check**: result.
- **Verdict**: `pass` / `findings reported`, with rationale.
- **Suggested fix or ownership**: for each finding.
- **Open questions**: missing context or unverifiable controls.
- **Next required action**: orchestrator records the audit and collects the user's fix-or-own decision.

Use `none` when a section does not apply.

## Completion Checks

- Target scope, freeze, and exclusions stated.
- Every frozen milestone is complete and verified.
- All applicable check families attempted or explicitly marked as not applicable/unavailable.
- Every finding has severity and concrete evidence.
- Secrets are redacted in the report.
- Security/privacy NFRs mapped to evidence or reported as gaps.
- The verdict follows the severity rule; any unresolved Blocker/High is reported as a finding.
- No file, managed record, status, or release was modified by the auditor.
- Temporary artifacts under `./.tmp/` removed.

## Resume / interruption

The audit is a single pass over a fixed scope. If interrupted, restart from scope establishment; no persistent state is kept.
