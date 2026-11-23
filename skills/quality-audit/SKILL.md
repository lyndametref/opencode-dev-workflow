---
name: quality-audit
description: 'Run the quality audit over the specified code base: verify feature completeness against requirements, business rules, acceptance criteria, NFRs, scope, and tests, and report findings.'
argument-hint: 'Provide the scope to audit; the whole codebase when none is given.'
user-invocable: true
disable-model-invocation: false
---

# Quality Audit

## Outcome

An evidence-based quality audit of the specified code base, with severity-ranked findings and a recommendation. The audit never fixes or approves.

## When to use

- Verify the code does what it is supposed to do

## Prerequisites

- Read the acceptance criteria for the scope, plus the business and non-functional requirements.

## Scope

The scope provided in the instruction. When none is given, audit the whole codebase.

## Checks

- **Requirement coverage** — every verified `REQ`/`NFR` in scope is implemented and traceable to its source.
- **Acceptance criteria** — every acceptance criterion in scope is fulfilled, with evidence.
- **Business rules** — every rule is exercised by a test and behaves as stated.
- **NFR coverage** — each quality target or constraint has evidence.
- **Scope creep** — no unjustified behavior outside the specified scope.
- **Integration** — all features in scope work together.
- **Consistency** — requirements, Technical specification, UI specifications, and code do not contradict each other.

## Procedure

1. **Confirm scope** — depending on the instruction choose the code part (or whole) to review.
2. **Read the evidence** — tasks, fulfilment proof, requirements, rules, specifications, test cases, and the change set. Do not trust reported results; rerun the checks.
3. **Run every check above** over the specified scope.
4. **Classify findings** — severity `low`, `medium`, `high`, or `blocker`, each with evidence, location, and recommendation.
5. **Decide the verdict** — `pass` when no finding requires action; otherwise `findings reported`. A `blocker` or unresolved `high` finding prevents a passing audit.
6. **Report findings** — every finding with its severity, evidence, and recommendation.

## Rules

- The audit is independent and read-only. It never fixes what it finds.
- Every finding is traceable to evidence; unverifiable checks are reported as gaps, not passes.
- The audit does not create tasks, change scope, approve, version, package, or deploy.

## Stop conditions

- Tests fail or cannot be run: record the failure as a finding; do not accept reported evidence.
- An acceptance criterion is ambiguous or unverifiable: stop; its owner fixes it.
- A finding has no evidence: stop; a finding is never carried without evidence.
- A requirement gap is discovered rather than an implementation defect. Report as finding.

## Report format

- **Scope**: the scope and baseline commit, files and test suites inspected.
- **Checks run**: commands and evidence.
- **Requirement coverage**: `REQ`/`NFR` -> implemented / missing.
- **Acceptance criteria**: criterion -> pass / fail -> evidence.
- **Findings**: severity | finding | evidence | location | recommendation.
- **Severity counts**: blocker / high / medium / low.
- **Verdict**: pass / findings reported.

## Completion checks

- The scope was confirmed.
- Every requirement and acceptance criterion in scope has a result with evidence.
- Every finding has severity, evidence, location, and recommendation.
- No fix, task creation, or approval action was performed.
