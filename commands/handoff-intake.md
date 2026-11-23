---
description: Hand captured requests to Phase 2 requirement analysis
agent: orchestrator
---

Run the requirement handoff for the request artifact(s) referenced above. Follow the `intake-routing` skill.

- Read the referenced request artifact(s) via `manage-requests`. Do not ask me to repeat the request content.
- Delegate to `requirements-engineer`; never write requirements yourself.
- A request with category `bug` goes directly to planning; it bypasses requirements.
- Stop on an unresolved product decision, an unresolved conflict with an existing requirement, or a validation gap.

Stop before planning. Report created/changed REQ/NFR IDs, validation status, resolved conflicts, open product decisions, impact outcomes, and the next action (`/plan REQUEST-xxx` or `/plan`).
