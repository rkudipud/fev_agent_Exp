---
applyTo: '**'
description: 'How to use the HSDES (mcp-hsd) and wiki-jira MCPs proactively, including the real tool names and the in-server AI skills.'
---

# MCP usage instructions (FEV agent)

Two MCPs are expected. The pluggable, authoritative capability list is in
[config/mcp-registry.yaml](../config/mcp-registry.yaml).

| MCP id | Server registration | Tool prefix | Source |
|--------|---------------------|-------------|--------|
| HSD MCP (mcp-hsd) | `hsdes` (in [.vscode/mcp.json](../../.vscode/mcp.json)) | `mcp_hsdes_*` | <https://github.com/intel-sandbox/mcp-suite/tree/master/tools/mcp-hsd> |
| wiki-jira MCP | `wiki-jira-mcp` | `mcp_wiki-jira-mcp_*` | configured at workspace level |

## HSD MCP (mcp-hsd) — what's there (verified from server.py)

**13 tools** total. Run locally from
[third_party/mcp-suite/tools/mcp-hsd/server.py](../../third_party/mcp-suite/tools/mcp-hsd/server.py)
via the workspace venv. Requires a valid Kerberos TGT (`kinit <idsid>@AMR.CORP.INTEL.COM` or
`third_party/mcp-suite/tools/mcp-hsd/kinit_hsd.sh`).

Article tools:
- `mcp_hsdes_get_hsd_article` — fetch by numeric ID (optional `fields` filter)
- `mcp_hsdes_get_hsd_article_with_comments` — article + comment thread
- `mcp_hsdes_get_hsd_article_full` — article + comments + attachments
- `mcp_hsdes_get_hsd_article_images` — embedded images
- `mcp_hsdes_summarize_hsd_article` — server-side summary
- `mcp_hsdes_download_hsd_attachments` — pull attachments to disk
- `mcp_hsdes_download_hsd_url` — download an authenticated HSDES URL

Search / query:
- `mcp_hsdes_search_hsd` — keyword/field search
- `mcp_hsdes_run_saved_hsd_query` — run a saved query ID

In-server AI skills (no separate publish step — they're @mcp.tool decorators):
- `mcp_hsdes_skill_extract_fields` — extract canonical fields
- `mcp_hsdes_skill_summarize` — narrative summary
- `mcp_hsdes_skill_classify` — type / severity / domain classification
- `mcp_hsdes_skill_root_cause` — root-cause hypothesis

> The wheel-only skills described on the wiki (`hsdes-issue-investigator`,
> `hsdes-quality-scorer`, `hsdes-query-eql`, `hsdes-orchestrator`, `hsdes-issue-manager`,
> `hsdes-debug-orchestrator`) are **NOT** available — they belong to a different package. Use the
> project-local `.github/skills/hsd-fetch-summarize`, `.github/skills/hsd-similar-issues`, and
> `.github/skills/mcp-discovery` workflows that wrap the 13 tools above.

Canonical example prompts (the server interprets natural language too):
- "Summarize HSDES ticket 14027842487"
- "Find tickets similar to 14027842487"
- "Search HSDES for fev_rtl2syn non-equivalent in last 90 days"
- "Download attachments from HSD 14027842487"
- "Run HSDES query 16012345678"

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

> HSD MCP (mcp-hsd, 13 tools): get_hsd_article / search_hsd / run_saved_hsd_query /
> download_hsd_attachments + 4 in-server AI skills (extract_fields, summarize, classify,
> root_cause). wiki-jira: `confluence_search` (default + cheetah for FEV) • `get_page` •
> `get_page_children` • diff/history. Say "capabilities" for full list.

## Tool loading

If a tool fails because it's deferred, run `tool_search` first:

- `tool_search query="hsd article fetch search download attachments"`
- `tool_search query="confluence search get page children labels"`

If `tool_search` returns nothing for an MCP the user mentions, do **not** improvise — explain it's
unavailable and offer the closest fallback (e.g. fall back to `confluence_search` when HSD is
absent, or remind the user to `kinit` if HSD tools fail to authenticate).

## Citations

- Every Confluence quote: `Title — URL` (and page ID when known — IDs are in
  [config/knowledge-base.yaml](../config/knowledge-base.yaml)).
- Every HSDES quote: `HSD-<id> — <field name>`.
- Never paraphrase a status, resolution, or root cause without quoting the source field.
