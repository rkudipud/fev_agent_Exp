---
mode: agent
description: 'Analyze a Conformal/Formality log: build a milestone timeline and correlate to reports.'
---

Log: **${input:log_path_or_excerpt}**
Reports (optional, space-separated paths): ${input:reports:}
Flow:  ${input:flow:fev_conformal|fev_formality|}
Sub-flow: ${input:sub_flow:}

Invoke `Log-Analyzer` with skill `fev-log-analysis`. Use the catalog in
`config/log-signatures.yaml`. Render the timeline + first-failure context block.

If `Log-Analyzer` proposes "🆕 Catalog candidate" entries, confirm with me before I paste them
into `config/log-signatures.yaml`.

Escalate as needed:
- recurring error → `HSD-Analyst.hsd-similar-issues`
- methodology question → `Jira-Wiki-Researcher.jira-wiki-bkm-lookup`
- unexpected override winning → `Ward-Explorer (intent=who_overrides)`
