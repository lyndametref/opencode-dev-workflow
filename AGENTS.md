# AGENTS

## Purpose

This file list available agents and give general rules for the agents.

## Available Agents

- `agent-manager`: Create, update, rename, validate, convert, and export agent and skill definitions across clients.
- `android-dev`: Implement and improve Android/Kotlin code with emphasis on maintainability, testability, and security.
- `architect`: Define and evolve system architecture, boundaries, and technical design decisions.
- `business-analyst`: Analyze business needs, clarify business rules, and align deliverables with stakeholder intent.
- `project-planner`: Plan milestones, sequencing, and delivery strategy for the Geep ecosystem.
- `quality-gatekeeper`: Review completed work for correctness, completeness, risk, and acceptance-criteria compliance.
- `requirements-engineer`: Produce and maintain clear, traceable, and consistent requirements artifacts.
- `tech-writer`: Write and maintain technical documentation, specifications, and architecture guidance.
- `terminologist`: Maintain canonical business terminology and enforce wording consistency across docs and backlog.

## Available Skills

- `agent-interoperability`: Manage agent definitions across multiple clients (Claude, OpenCode, GitHub Copilot, Gemini) by importing/exporting agents to/from the canonical .ai/agents format.
- `agent-management`: Create, update, and validate canonical agent definitions in .ai/agents/<slug>/AGENT.md and keep `.ai/AGENTS.md` up to date. Use when adding a new home-format agent, refactoring an existing one, or enforcing canonical structure and metadata.
- `agent-skill-conversion`: Convert agent definitions to skill definitions and vice versa.
- `architecture-decision-record`: Create and manage Architecture Decision Records (ADRs) in the architecture documentation folder.
- `attribute-list-definition`: Create a structured attribute list for a business object or event, documenting each attribute with name, type, optionality, constraint, and requirement traceability. Stored in docs/domain-model/object-model/<entity-name>-attributes.md.
- `backlog-md`: Manage project tasks, docs, and decisions using the Backlog.md CLI tool. Create, edit, search, and track tasks with full metadata support.
- `business-glossary-management`: Manage the business glossary: add and update business terms, merge duplicates, and keep wording consistent across docs and backlog. Use for business terminology only.
- `business-process-diagramming`
- `business-requirements-management`: Create, update, reorganize and check consistency of business requirements under docs/requirements/.
- `business-rules-management`: Create, update, and validate business rules in the canonical format. Each business rule is a self-contained file under docs/business-rules/BR-XXX-short-name.md with unique BR-XXX ID, description, rationale grounded in requirements, and applicability statement.
- `business-terminology-consistency-check`: Check docs and backlog for non-canonical business terms, conflicting term variants, and missing glossary alignment. Use when validating wording consistency before or after glossary changes.
- `domain-modeling`: Create and maintain the semantic domain model of the project: Business Object Models, context maps, and business object documentation.
- `lilypond-piano`: Use for creating and editing LilyPond piano scores. Handles multi-staff layout with right and left hands, master .ly file with includes, measure numbering synchronization, breaks in right hand only, and piano-specific score block with optional layout (staff size) and MIDI.
- `lilypond-single-voice`: Use for creating and editing single-voice LilyPond scores (e.g. recorder, flute, violin, clarinet, trumpet, harp, etc.). Simple single-file layout (no split, no master, no .ily includes), one measure per line with measure number comments, and appropriate score/MIDI/layout setup.
- `markdown-move`: Move a markdown file to a new location and update all relative links within it to reflect the new path.
- `non-functional-requirements-management`: Create, update, reorganize and check consistency of non-functional     requirements under docs/requirements/non-functional/.
- `reverse-engineering`: Read existing source code and produce the business (REQ) and non-functional (NFR) requirements that correspond to the implemented behavior.
- `state-diagram-creation`: Create Mermaid state diagrams for domain objects with lifecycle states, statuses, and transitions. Each diagram is stored in docs/domain-model/ and shows valid states, transitions, and the conditions that trigger them.
- `task-refinement`: Audit, clarify, and complete a single backlog ticket by removing ambiguity, filling missing structure, and aligning it with specifications. Uses the backlog CLI for all ticket modifications.

## Instructions

- Always be concise. Use as few words as possible.
- Clear headings and concise bullets.
- No ambiguous status language (use explicit states like planned, in-progress, blocked, completed).
- If information is missing, list assumptions instead of inventing silent details.
- never use timestamps without timezone. 

