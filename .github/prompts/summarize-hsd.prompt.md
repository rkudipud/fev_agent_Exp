---
mode: agent
description: 'Summarize a single HSDES ticket into a FEV-aware structured summary.'
---

Summarize HSDES ticket **${input:hsd_id:HSD ID or URL}**.

Use the `HSD-Analyst` sub-agent with skill `hsd-fetch-summarize`. Depth: `${input:depth:summary|full|with-comments}`.

If the input is a full HSDES URL, first extract the trailing numeric ticket ID from the path or
fragment (for example `https://hsdes.intel.com/appstore/article-one/#/14027842487` →
`14027842487`) and use that numeric ID for the `mcp_hsdes_get_hsd_article*` call.

Output must follow the template in `skills/hsd-fetch-summarize/SKILL.md`, including the
**Extracted FEV signals** block. End with the standard "Next-step prompts" list.
