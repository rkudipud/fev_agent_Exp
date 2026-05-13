---
mode: agent
description: 'Summarize a single HSDES ticket into a FEV-aware structured summary.'
---

Summarize HSDES ticket **${input:hsd_id:HSD ID or URL}**.

Use the `HSD-Analyst` sub-agent with skill `hsd-fetch-summarize`. Depth: `${input:depth:summary|full|with-comments}`.

Output must follow the template in `skills/hsd-fetch-summarize/SKILL.md`, including the
**Extracted FEV signals** block. End with the standard "Next-step prompts" list.
