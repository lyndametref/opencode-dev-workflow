# AGENTS

## Papyrus Management

All backlog and managed documentation records are created, read, and changed through the Papyrus CLI, invoked only through the corresponding `manage-*` artifact skill, so IDs, files, links, statuses, and the browser view stay consistent.

### Golden rule

Never edit Papyrus-managed files directly. Agents and skills access and change managed records only through the matching `manage-*` skill; only those skills contain Papyrus commands. Plain (non-Papyrus) records are normal Markdown (requests, release reports, architecture, domain model).

### Tool commands

All tool commands live in the `manage-*` artifact skills. In case you need it use the `papyrus --help` to understand how it works. Every command has an help option
