---
name: hsd-fetch-summarize
description: Fetch a single HSDES ticket by ID via the HSDES MCP and produce a structured FEV-aware summary.
---

# Skill: hsd-fetch-summarize

## When to use

User supplies an HSD ID (e.g. `22019876543`) or pastes an HSDES URL, and wants the gist.

## Inputs

- `hsd_id` (required) — numeric or full URL.
- `depth` (optional) — `summary` | `full` | `with-comments`. Default: `summary`.

## Procedure

1. Ensure HSDES MCP tools are loaded. If not, request via `tool_search query="hsdes ticket fetch"`.
2. Call the HSDES MCP fetch tool for `hsd_id`.
3. If `depth = with-comments`, also pull comments/article history.
4. Extract the canonical fields (see template below). Leave a field blank only if not present;
   never invent.
5. Heuristically extract **FEV signals** for downstream skills:
   - Tool: Conformal | Formality (look for tokens `conformal`, `formality`, `lec_`, `fm_`).
   - Sub-flow / task name.
   - Tech / project tokens.
   - Error/violation signatures (lines that look like `ERROR:`, `non-equivalent`, `unmapped`,
     `compare point`, abort/assertion strings).
6. Cite every quoted value with the source field name.

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
