---
mode: agent
description: 'Search Intel Confluence (+ Jira) for a FEV BKM, INote, or project wiki page on a topic.'
---

Topic: **${input:topic}**
Scope: ${input:scope:default|all}    Kind: ${input:kind:bkm|inote|any}

Invoke `Jira-Wiki-Researcher` with skill `jira-wiki-bkm-lookup`. Start with preferred spaces from
`config/knowledge-base.yaml`. If nothing useful, ask before widening to "search all spaces".

End by prompting the user to add any newly useful page URL to
`config/knowledge-base.yaml → confluence.curated_pages:`.
