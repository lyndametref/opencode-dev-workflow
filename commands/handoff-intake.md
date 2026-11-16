---
description: Hand a captured request artifact to the orchestrator for requirement intake
agent: orchestrator
---

Run the requirement intake flow for the request artifact(s) referenced above.

- If a `REQUEST-xxx` ID is present, read that artifact under `docs/requests/`.
- If no request ID is present, ask me for it. Do not ask me to repeat the request content.
- A request with category `bug` goes directly to planning; it bypasses requirements.
- Follow the `intake-routing` skill.

Stop before implementation. Report created/changed REQ/NFR IDs, validation status and open
product decisions, architecture impact flags, plan corrections (or `no change needed`),
request closure, and the next eligible task.
