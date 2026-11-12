---
description: Hand the KAM feedback package to the orchestrator for requirement intake
agent: orchestrator
---

Run the new feature / requirement intake flow for the "Feedback handoff" package above.

Treat that package as the captured request; do not ask me to repeat it. Follow your
"New feature or requirement intake" section:

1. `requirements-engineer` — create or change REQ/NFR records and validate them.
2. `architect` — only if the intake touches NFRs or introduces new integrations,
   cross-cutting scope, or a new module/stack.
3. `planner` — check and correct roadmap coverage, milestones, dependencies, and task order.

Stop before implementation. Report created/changed REQ/NFR IDs, validation status and open
product decisions, architecture decisions, plan corrections (or `no change needed`), and the
next eligible task.
