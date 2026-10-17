---
name: agent-management
description: 'Create, update, and validate canonical agent definitions in .ai/agents/<slug>/AGENT.md and keep `.ai/AGENTS.md` up to date. Use when adding a new home-format agent, refactoring an existing one, or enforcing canonical structure and metadata.'
argument-hint: 'Examples: create project-planner, update terminologist constraints, validate all canonical agents, sync project-planner to clients.'
user-invocable: true
disable-model-invocation: false
---

# Canonical Agent Home Format

## Outcome
Produce and maintain canonical agent definitions under `.ai/agents/<slug>/AGENT.md` using the project home format, with consistent structure, constraints, and metadata.
Each time  agents are created, deleted, or modified, keep `.ai/AGENTS.md` synchronized with the current list of available agents under the section `## Available Agents` and a list of available skills under `## Available Skills`. Describe in those sections what each agent/skill should do and what they should be used for.

## When To Use
- You need to create a new canonical agent in `.ai/agents`.
- You need to update an existing canonical agent while preserving home-format conventions.
- You need to audit canonical agents for structure, wording consistency, and metadata completeness.
- You need to prepare canonical agents for cross-client export after updates.

## Canonical Contract
Each canonical agent file MUST be located at `.ai/agents/<slug>/AGENT.md` and follow this structure:
1. H1 title naming the agent.
2. `## Mission statement`.
3. `## Metadata` with:
   - Allowed actions
   - Preferred Model (optional)
   - Preferred skills
   - Hints on arguments the user can provide
4. `## Inputs`.
5. `## Constraints`.
6. `## Approach` as ordered steps.
7. `## Output format`.
8. `## Completion checks`.

## Procedure
1. **Classify request type**
   - Map the prompt to one of: `create`, `update`, `delete`, `sync`.

2. **Baseline read**
   - Read `.ai/agents/<slug>/AGENT.md` if it exists.
   - If creating a new agent, inspect at least one existing canonical example, such as `.ai/agents/terminologist/AGENT.md`.

3. **Define scope and boundaries**
   - Confirm what this agent owns and what it must explicitly avoid.
   - Ensure constraints forbid out-of-scope edits or unsafe behavior.

4. **Write or revise canonical sections**
   - Keep section order from the Canonical Contract.
   - Keep wording concise, imperative, and testable.
   - Make `Preferred skills` explicit and minimal.
   - Ensure `Approach` is an executable step sequence, not abstract guidance.

5. **Apply decision logic**
   - If request is `create`: scaffold full file from scratch with all required sections.
   - If request is `update`: perform minimal edits; preserve stable behavior unless change is requested.
   - If request is `delete`: remove the canonical agent definition and any stale references that would misrepresent available agents.
   - If request is `sync`: after canonical updates, run client export via the agent interoperability workflow.

6. **Update agent index documentation**
   - For `create`, `update`, and `delete` requests, update `AGENTS.md` to reflect:
     - The full list of available agents.
     - A concise statement of what each agent should be used for.
   - Ensure removed agents are removed from `AGENTS.md` and renamed agents are updated consistently.

7. **Validate quality gates**
   - Path correctness: file exists at `.ai/agents/<slug>/AGENT.md`.
   - Structure correctness: all required sections present and ordered.
   - Metadata quality: actions and skills align with mission and constraints.
   - Safety quality: constraints clearly block forbidden operations.
   - Clarity quality: argument hints are concrete and user-oriented.
   - Index quality: `AGENTS.md` reflects the current canonical agent inventory and intended usage.

8. **Report outcome**
   - Summarize action (`create`/`update`/`audit`/`sync`), files changed, and any open assumptions.

## Decision Points
- If mission overlaps significantly with an existing agent, prefer updating that agent instead of creating a duplicate.
- If preferred skills are missing for required responsibilities, stop and request skill selection before finalizing.
- If requested behavior conflicts with constraints, keep constraints strict and ask for explicit policy override.
- If sync is requested without canonical validation, validate first, then export.

## Completion Checks
- Canonical file exists in `.ai/agents/<slug>/AGENT.md`.
- All canonical sections are present and in required order.
- Mission, metadata, constraints, and approach are mutually consistent.
- Agent responsibilities are specific, testable, and non-overlapping where possible.
- `AGENTS.md` is updated after any agent create, update, or delete action.
- Any assumptions or unresolved ambiguities are explicitly listed.
