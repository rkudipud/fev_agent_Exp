---
applyTo: '**'
description: 'How to use the HSDES and wiki-jira MCPs proactively, including the real tool names and the AI skills shipped with the HSDES MCP.'
---

# MCP usage instructions (FEV agent)

Two MCPs are expected. The pluggable, authoritative capability list is in
[config/mcp-registry.yaml](../config/mcp-registry.yaml).

| MCP id | Tool prefix | Source |
|--------|-------------|--------|
| HSDES MCP | `mcp_hsdes_*` | <https://wiki.ith.intel.com/spaces/ITScedf/pages/4705390469/HSDES+MCP> |
| wiki-jira MCP | `mcp_wiki-jira-mcp_*` | configured at workspace level |

## HSDES MCP — what's there (verified from the wiki)

- **62 tools** total. Common examples (paste verbatim into chat — the MCP interprets natural
  language):
  - "Summarize HSDES ticket 14012345678"
  - "Find tickets similar to 14012345678"
  - "Analyze ticket 14012345678 for root cause"
  - "Score the quality of ticket 14012345678"
  - "Find all open sightings owned by <idsid>"
  - "Add comment to 14012345678: <text>"
  - "Set ticket 14012345678 status to resolved"
  - "Download <attachment> from ticket 14012345678"
  - "Run HSDES query 16012345678"
- **Bundled AI skills** (install with `hsdes-mcp publish-skills`). When a request fits one of these,
  **delegate to the bundled skill instead of reimplementing the workflow**:
  - `hsdes-orchestrator` — routes HSDES questions to the right specialist.
  - `hsdes-issue-investigator` — multi-round deep ticket investigation.
  - `hsdes-issue-manager` — dashboards / SLA / aging.
  - `hsdes-quality-scorer` — quality scoring + auto-fix.
  - `hsdes-query-eql` — EQL builder with correct field prefixes.
  - `hsdes-debug-orchestrator` — domain debug (PCIe / Memory / Core / UPI); not FEV-primary.

## wiki-jira MCP — what's there (verified)

Core Confluence tools (already loaded in this workspace):

- `mcp_wiki-jira-mcp_confluence_search` — search; pass `spaces_filter="cheetah"` for FEV scope.
- `mcp_wiki-jira-mcp_confluence_get_page` — fetch a page by ID or `(space_key, title)`.
- `mcp_wiki-jira-mcp_confluence_get_page_children` — list child pages (with `include_content=true`).
- `mcp_wiki-jira-mcp_confluence_get_space_page_tree` — flat hierarchy of a whole space.
- `mcp_wiki-jira-mcp_confluence_get_comments` — page comments.
- `mcp_wiki-jira-mcp_confluence_get_page_history` / `confluence_get_page_diff` — version diffs.
- `mcp_wiki-jira-mcp_confluence_get_attachments` / `confluence_download_attachment` /
  `confluence_download_content_attachments` / `confluence_get_page_images`.
- `mcp_wiki-jira-mcp_confluence_get_labels` — page labels (use to filter BKM-tagged pages).

The workspace's wiki-jira MCP is preconfigured with default spaces `oksdebug, fvcommon, SIPGSLD,
XPIVSHCoVal`. **For FEV, always add `cheetah`** explicitly (or use `spaces_filter="cheetah"`).
To widen beyond defaults, set `spaces_filter=""` (the user phrase: *"search all spaces"*).

## Proactivity rule

On the **first turn** of any sub-agent, emit a compact one-liner like:

> HSDES MCP (62 tools): summarize / find similar / score / search / comment / EQL.
> wiki-jira: `confluence_search` (default + cheetah for FEV) • `get_page` • `get_page_children` •
> diff/history. Say "capabilities" for full list.

## Tool loading

If a tool fails because it's deferred, run `tool_search` first:

- `tool_search query="hsdes ticket fetch search similar comment"`
- `tool_search query="confluence search get page children labels"`

If `tool_search` returns nothing for an MCP the user mentions, do **not** improvise — explain it's
unavailable and offer the closest fallback (e.g. fall back to `confluence_search` when HSDES is
absent).

## Citations

- Every Confluence quote: `Title — URL` (and page ID when known — IDs are in
  [config/knowledge-base.yaml](../config/knowledge-base.yaml)).
- Every HSDES quote: `HSD-<id> — <field name>`.
- Never paraphrase a status, resolution, or root cause without quoting the source field.
