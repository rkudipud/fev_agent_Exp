---
name: hsd-similar-issues
description: Given a seed HSD (or a raw failure signature), find similar HSDES tickets and aggregate their proposed fixes.
---

# Skill: hsd-similar-issues

## When to use

- "Has anyone hit this before?"
- "Find tickets like HSD-<id>."
- "Similar issues" / "prior occurrences" / "known issue".

## Inputs

- Either `seed_hsd_id` (numeric ID or full HSDES URL) **or** a `signature` blob (error string,
  stack, or log excerpt).
- Optional filters: `tool` (`conformal`|`formality`), `tech`, `component`.

## Procedure

1. **Normalize HSD seed when present.**
  - If `seed_hsd_id` is already numeric, use it as-is.
  - If `seed_hsd_id` is an HSDES URL, extract the last contiguous digit run from the URL path or
    fragment and treat that as the canonical ticket ID.
  - Example: `https://hsdes.intel.com/appstore/article-one/#/14027842487` → `14027842487`.
  - If a supposed HSD URL has no numeric ticket ID, stop and ask for a valid HSD ID or HSDES URL.
2. **Build signal set.**
  - If `seed_hsd_id` given: run `hsd-fetch-summarize` with the normalized ticket ID and copy its
    `Extracted FEV signals` block.
  - If `signature` given: extract distinctive substrings (file/module names, error codes,
     `unmapped/non-equiv/abort` tokens). Drop generic words.
3. **Query mcp-hsd** via `mcp_hsdes_search_hsd(query, limit)` with progressively broader queries:
   - Pass 1: exact unique substring(s) AND tool AND tech.
   - Pass 2: drop tech.
   - Pass 3: drop tool, keep core signature only.
   For each ranked candidate, fetch the body with `mcp_hsdes_get_hsd_article_with_comments` to
   read the Resolution/RC field. Stop early if Pass 1 already returns 5+ relevant hits.
4. **De-dupe** by ticket ID and by near-identical titles.
5. **Score** each candidate: +1 per matching signal (tool, sub_flow, tech, signature substring,
   component). Show top 5 by score.
6. For each survivor, extract the **proposed fix** from Resolution / RC / last meaningful comment.
   Quote, do not paraphrase.
7. **Aggregate**: list distinct fix strategies across the candidates, with counts.

## Output template

```
Seed: HSD-<id> | signature: "<short>"
Signals used: tool=<…> tech=<…> sub_flow=<…> sigs=[…]

Top similar HSDs:
  1. HSD-<id> (score N) — <title>  [<status>]
     Why it matches: <signals>
     Proposed fix (quoted): "<…>"
  2. …

Aggregated fix strategies seen:
  - <strategy A>  (3 tickets: HSD-…, HSD-…, HSD-…)
  - <strategy B>  (2 tickets: …)

Recommendation:
  <best-fit strategy and why>

No HSDES match? → suggest handing off to Jira-Wiki-Researcher for a BKM/INote search.
```

## Guardrails

- Never claim "no prior occurrences" without showing the three query passes you tried.
- Mark closed/duplicate/won't-fix tickets explicitly — their fixes may be stale.
- Never pass a raw HSDES URL to `mcp_hsdes_*` tools when a numeric ticket ID can be extracted
  from it. (`mcp_hsdes_download_hsd_url` is the only exception — it expects a full URL.)
- If `mcp_hsdes_search_hsd` returns nothing across all three passes, surface that explicitly
  before handing off to the Jira-Wiki-Researcher.
