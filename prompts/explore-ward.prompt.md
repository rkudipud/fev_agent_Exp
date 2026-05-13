---
mode: agent
description: 'Resolve a FEV file or run-area location in a CTH ward using the override hierarchy — no full grep.'
---

Intent: ${input:intent:find_source|find_run_artifact|who_overrides|build_run_path}

Parameters (fill what you have, leave others blank — the agent will ask):
- flow:         ${input:flow:fev_conformal|fev_formality|}
- filename:     ${input:filename:}
- build_name:   ${input:build_name:}
- tech:         ${input:tech:}
- sub_flow:     ${input:sub_flow:}
- design_class: ${input:design_class:}
- project:      ${input:project:}

Invoke `Ward-Explorer` with skill `fev-ward-context`. Print the layered candidate paths in
priority order, then run existence checks if `$ward` is reachable.
