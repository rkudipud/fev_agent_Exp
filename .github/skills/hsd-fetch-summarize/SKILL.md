---
name: hsd-fetch-summarize
description: Fetch a single HSDES ticket by ID via the mcp-hsd MCP and produce a structured FEV-aware summary.
---

# Skill: hsd-fetch-summarize

## When to use

User supplies an HSD ID (e.g. `22019876543`) or pastes an HSDES URL, and wants the gist.

## Inputs

- `hsd_id` (required) — numeric ID or full HSDES URL. When a URL is supplied, the trailing
  numeric segment is the ticket ID that must be used for `mcp_hsdes_*` calls.
- `depth` (optional) — `summary` | `full` | `with-comments`. Default: `summary`.

## Tool surface (mcp-hsd, 13 tools, prefix `mcp_hsdes_`)

| Depth | Tool to call |
|-------|--------------|
| `summary` | `mcp_hsdes_get_hsd_article` (or `mcp_hsdes_summarize_hsd_article` for a server-side summary) |
| `with-comments` | `mcp_hsdes_get_hsd_article_with_comments` |
| `full` | `mcp_hsdes_get_hsd_article_full` (article + comments + attachments) |

For structured field extraction, prefer the in-server AI skill
`mcp_hsdes_skill_extract_fields` over manual regex.

## Procedure

1. Ensure mcp-hsd tools are loaded. If not, request via
   `tool_search query="hsd article fetch search download"`.
   If the call returns a 401/Negotiate failure, prompt the user to refresh Kerberos
   (`kinit <idsid>@AMR.CORP.INTEL.COM` or `third_party/mcp-suite/tools/mcp-hsd/kinit_hsd.sh`).
2. Normalize `hsd_id` before any MCP call:
   - If the input is already numeric, use it as-is.
   - If the input is an HSDES URL, extract the last contiguous digit run from the URL path or
     fragment.
   - Example: `https://hsdes.intel.com/appstore/article-one/#/14027842487` → `14027842487`.
   - If no numeric ticket ID can be extracted, stop and ask for a valid HSD ID or HSDES URL.
3. Call the matching `mcp_hsdes_get_hsd_article*` tool (per the table above) using only the
   normalized numeric ticket ID. Optionally chain `mcp_hsdes_skill_extract_fields` to get the
   canonical fields directly.
4. If `depth = with-comments`, also pull comments via `mcp_hsdes_get_hsd_article_with_comments`.
5. Extract the canonical fields (see template below). Leave a field blank only if not present;
   never invent.
6. Heuristically extract **FEV signals** for downstream skills:
   - Tool: Conformal | Formality (look for tokens `conformal`, `formality`, `lec_`, `fm_`).
   - Sub-flow / task name.
   - Tech / project tokens.
   - Error/violation signatures (lines that look like `ERROR:`, `non-equivalent`, `unmapped`,
     `compare point`, abort/assertion strings).
7. Cite every quoted value with the source field name.

## Output template

```
HSD <id> — <title>                          (link: <url>)
Status: <status>   Severity: <sev>   Owner: <owner>   Reporter: <reporter>
Component / Path: <component>
Tags: <tags>

Problem statement:
  <quote or tight paraphrase from Description>

Repro:
  <quote from Repro / Steps>

Findings / Root cause:
  <quote from RC field or comments labeled RC>

Resolution:
  <quote from Resolution / Fix field>

Extracted FEV signals (for downstream skills):
  tool:        <conformal|formality|unknown>
  sub_flow:    <…>
  tech:        <…>
  signatures:  [<sig1>, <sig2>, …]
```

## Next-step prompts (always offer)

- "Find similar HSDs to this one." → `hsd-similar-issues`
- "Look up the matching BKM/INote." → `jira-wiki-bkm-lookup`
- "Locate the failing file in the ward." → `fev-ward-context`
