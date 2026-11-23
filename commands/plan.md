---
description: Plan one request or all open requests into milestones and tasks
agent: orchestrator
---

Plan the requests in scope: the `REQUEST-xxx` named above, or every open request when none is given. Follow the `planning` skill.

- Read the verified requirements and user ADRs; do not plan against unverified requirements.
- Create or reuse the release, then create one milestone per enhancement or technical improvement, and one batch milestone per group of available bugs.
- Every milestone gets exactly one refinement task, one or more development tasks, and exactly one verification task, plus its acceptance criteria.
- Set dependencies and ordinals; validate the plan.
- Close the planned requests or reject the declined ones, with reasons.

Do not refine, implement, verify, or audit anything. Report the plan, the request closure, validation result, open decisions, and the next eligible task.
