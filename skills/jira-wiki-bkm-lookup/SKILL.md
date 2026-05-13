---
name: jira-wiki-bkm-lookup
description: Search Intel Confluence + Jira for FEV BKMs, INotes, and project-specific guidance via the wiki-jira MCP. Prompts user to register useful pages into the pluggable KB.
---

# Skill: jira-wiki-bkm-lookup

## When to use

- "Find FEV BKM for <topic>."
- "Is there an INote on <issue>?"
- "What does the wiki say about <thing>?"
- "Any Jira on this in the FEV project?"

## Inputs

- `query` (required) — natural-language topic or symptom.
- `scope` (optional) — `default` (preferred spaces) or `all` (whole wiki). Default: `default`.
- `kind` (optional) — `bkm` | `inote` | `any`. Default: `any`.

## Preferred spaces

Pull from [../../config/knowledge-base.yaml](../../config/knowledge-base.yaml) under
`confluence.preferred_spaces:`. Always include:

- `cheetah` (FEV root: <https://wiki.ith.intel.com/display/cheetah/FEV>)
- whatever the user has added to the YAML for their project.

## Procedure

1. **Capability ping** (proactive, one line): list `confluence_search`, `confluence_get_page`,
   `confluence_get_page_children`, Jira search/read, and how to widen scope.
2. **Plan queries** before issuing them:
   - Title-likely-contains terms (BKM, INote, modeling, blackbox, hier_match, etc.).
   - Synonyms / tool-specific tokens (Conformal vs Formality).
3. **Search Confluence** in preferred spaces first.
4. If `kind=bkm`, additionally filter title `~ "BKM"` or labels include `bkm`.
5. **Search Jira** for issues matching the same query in FEV-relevant projects (config-driven).
6. For each hit, fetch enough body to produce a 1–2 sentence relevance quote.
7. **Prompt the user** to record any newly useful page URL into
   `config/knowledge-base.yaml` under `confluence.curated_pages:` so future sessions are scoped tighter.

## Output template

```
Searched: <spaces or "all">  | kind=<…>
Confluence hits:
  1. <Title>  [<space>]
     URL: <url>
     Relevance: "<quote>"  ← <1-line why>
  2. …
Jira hits:
  1. <KEY> — <title>  [<status>]
     URL: <url>
     Relevance: "<quote>"
  2. …

If nothing useful:
  - Tried queries: <q1>, <q2>, <q3>
  - Suggest: search all spaces? rephrase to "<…>"? hand off to HSD-Analyst?

➕ Add to KB?  Paste any of these into config/knowledge-base.yaml → confluence.curated_pages:
   - title: "<…>"
     url: "<…>"
     tags: [bkm, modeling, …]
```

## Cross-agent escalation

If wiki/Jira return nothing but the topic looks operational (a failing run), hand off to
`HSD-Analyst.hsd-similar-issues` with the same query as a signature.
