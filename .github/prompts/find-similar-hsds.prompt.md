---
mode: agent
description: 'Find HSDES tickets similar to a seed HSD or a raw signature and aggregate the proposed fixes.'
---

Seed: **${input:seed:HSD ID, URL, or raw error signature}**
Optional filters: tool=${input:tool:conformal|formality|}, tech=${input:tech:}, component=${input:component:}

Invoke `HSD-Analyst` with skill `hsd-similar-issues`. Follow the three-pass query plan in the skill
and produce the ranked similar-HSDs table plus the **Aggregated fix strategies** section.

If the seed is a full HSDES URL, first extract the trailing numeric ticket ID from the path or
fragment (for example `https://hsdes.intel.com/appstore/article-one/#/14027842487` →
`14027842487`) and use that numeric ID as the HSD seed.

If HSDES returns nothing useful, hand off to `Jira-Wiki-Researcher.jira-wiki-bkm-lookup` with the
same signature.
