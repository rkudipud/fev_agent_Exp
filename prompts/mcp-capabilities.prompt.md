---
mode: agent
description: 'Show what the HSDES and wiki-jira MCPs can do, with example prompts to copy.'
---

MCP: ${input:mcp:all|hsdes|wiki-jira}
Verbosity: ${input:verbosity:compact|full}

Invoke skill `mcp-discovery`. Source of truth: `config/mcp-registry.yaml`. Suggest where to extend
the YAML if the user mentions an MCP not yet registered.
