---
description: Start Phase 1 request intake with the orchestrator
agent: orchestrator
---

Start request intake now. Follow the `request-intake` skill.

- Capture the request from this conversation or the reference above; do not ask me to repeat what is already in context.
- Summarize in canonical business terminology, collect only obvious gaps, check existing records, and group the items.
- Create or update request artifacts only via `manage-requests`. Never author requirements, priority, scope, architecture, tasks, milestones, or releases.
- Ask me whether the request is `open` or `parked`, and confirm the content is faithful before persisting it.
- Stop after intake. Do not start requirement analysis or planning.

Report the request IDs, category, status, open-question count, and whether to run `/handoff-intake` for requirements or `/plan` for a bug.
