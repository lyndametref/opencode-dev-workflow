---
name: agent-skill-conversion
description: 'Convert agent definitions to skill definitions and vice versa.'
argument-hint: 'Optional: agent-to-skill <source-slug> <target-skill-name>, skill-to-agent <source-skill-name> <target-slug>, or validate conversion.'
user-invocable: true
disable-model-invocation: false
---

# Agent ↔ Skill Conversion

## Purpose
Convert agent definitions to skill definitions and vice versa.

## When to use
Use this skill when you need to:
- Convert an agent definition into a reusable skill for use across the ecosystem
- Convert a skill definition into a standalone agent
- Migrate functionality from agent form to skill form or vice versa

## Workflow

### Agent → Skill Conversion
1. Read the source agent AGENT.md from `.ai/agents/<slug>/AGENT.md`
2. Identify the agent's core instructions, purpose, and workflow
3. Create a skill file at `.ai/skills/<skill-name>/SKILL.md` with:
   - Purpose section (from agent's purpose)
   - When to use section (from agent's trigger/description)
   - Workflow section (from agent's instructions)
4. Reference any bundled resources (examples, templates, scripts) in the skill

### Skill → Agent Conversion
1. Read the source skill SKILL.md from `.ai/skills/<skill-name>/SKILL.md`
2. Extract the purpose, workflow, and usage instructions
3. Create an agent definition at `.ai/agents/<slug>/AGENT.md` using the canonical agent format
4. Create client-specific agent definitions:
   - `.ai/agents/<slug>.md`
   - `.github/agents/<slug>.md`
   - `.claude/agents/<slug>.json`
5. Create example files if applicable

### Validation
- Verify the converted file follows the target format conventions
- For agent files: check for required metadata (slug, name, description, tools, instructions)
- For skill files: check for required sections (Purpose, When to use, Workflow)
