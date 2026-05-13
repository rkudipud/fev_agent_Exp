---
name: mcp-discovery
description: Proactively enumerate what the HSDES and wiki-jira MCPs can do, with example prompts the user can copy. Pluggable via config/mcp-registry.yaml.
---

# Skill: mcp-discovery

## When to use

- User asks "what can you do?", "what can I query?", "options?", "capabilities".
- **Always at the start of any sub-agent's first turn**, in a compressed one-liner.

## Inputs

- `mcp` (optional) — `hsdes`, `wiki-jira`, or `all`. Default: `all`.
- `verbosity` (optional) — `compact` (one-liner) or `full` (sections). Default: `compact`.

## Source of truth

[../../config/mcp-registry.yaml](../../config/mcp-registry.yaml). Each MCP entry has:

```yaml
- id: hsdes
  display: "Intel HSDES MCP"
  reference: "https://wiki.ith.intel.com/spaces/ITScedf/pages/4705390469/HSDES+MCP"
  tools:
    - name: <tool name>
      what: <what it does>
      example: <example natural-language prompt>
  scopes_or_spaces: [...]
```

To extend: edit the YAML; no code change needed.

## Procedure

1. Load the YAML.
2. Filter by `mcp` param.
3. Render per `verbosity`.

## Compact rendering

```
HSDES MCP:    fetch by ID • search by keywords • list comments • related articles
wiki-jira:    confluence_search/get_page/get_children • Jira search/read • widen with "search all spaces"
Type "capabilities" for examples.
```

## Full rendering

```
### Intel HSDES MCP
Reference: <url>
Tools:
  • <tool>        — <what>
    e.g. "<example>"
  • …

### Intel wiki-jira MCP
Default spaces: <list>
Tools:
  • confluence_search       — search the configured spaces
    e.g. "search 'FEV blackbox modeling BKM' in cheetah space"
  • confluence_get_page     — fetch a page by ID/title
  • confluence_get_page_children — browse hierarchy
  • Jira search/read        — find/issue read
  • "search all spaces"     — widen scope
```

## Guardrails

- Never claim a tool exists that isn't in the YAML.
- If the YAML is missing for an MCP the user mentions, say so and point to where to add it.
