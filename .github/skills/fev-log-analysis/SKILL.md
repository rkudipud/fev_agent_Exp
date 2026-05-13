---
name: fev-log-analysis
description: Parse Cadence Conformal / Synopsys Formality logs, build a milestone timeline, and correlate events to report files. Bootstrap catalog — extend signatures over time.
---

# Skill: fev-log-analysis

## When to use

- "Analyze this Formality log."
- "Why did Conformal abort here?"
- "Correlate this log line to the report."

## Inputs

- `log_path` (required) **or** pasted log excerpt.
- Optional: `report_paths` (compare.rpt, cmp.log, etc.), `flow`, `sub_flow`.

## Where to find logs/reports

Defer to `fev-ward-context` skill if path not given — render run-area path from
build/tech/sub_flow, then enumerate known artifacts from
[../../config/ward-paths.yaml](../../config/ward-paths.yaml) `run_area.artifacts:`.

## Procedure

1. **Detect tool** (Conformal vs Formality) from header / banner lines.
2. **Walk the log linearly** and tag each line that matches a signature in the catalog
   (`config/log-signatures.yaml`).
3. **Build a milestone timeline** (timestamps if present, otherwise line numbers).
4. **For each milestone, map to a report artifact** using `correlations:` in the same YAML.
5. **Highlight first error/abort** with surrounding ±10 lines, and propose a next step (search HSDs,
   look up BKM, or check a specific override layer).

## Bootstrap signature catalog

The seed catalog lives at
[../../config/log-signatures.yaml](../../config/log-signatures.yaml) and is intentionally minimal.
It is organized as:

```yaml
conformal:
  milestones: [ ... ]
  errors:     [ ... ]
  correlations:
    "<milestone-id>": "<report file or section>"
formality:
  milestones: [ ... ]
  errors:     [ ... ]
  correlations: { ... }
```

When you see a clearly-important line that **does not** match any catalog entry, do **NOT** drop it.
Instead, append a proposal to your output:

```
🆕 Catalog candidate (please confirm to add):
  tool:        <conformal|formality>
  kind:        <milestone|error>
  pattern:     "<regex or substring>"
  meaning:     "<one-line>"
  correlates:  "<report ref>"
```

## Output template

```
Tool:    <Conformal|Formality>      Result: <PASS|FAIL|ABORT|UNKNOWN>
Log:     <path>
Reports: <listed and ✓/✗ existing>

Timeline:
  L<line>  <milestone-id>   <one-line meaning>           → <report ref>
  L<line>  <milestone-id>   …                             → <report ref>
  L<line>  ❌ <error-id>     <one-line meaning>

First failure context (±10 lines):
  <quoted block>

Likely cause:        <…>
Suggested next step: <…>
Escalate to:         <HSD-Analyst | Jira-Wiki-Researcher | none>
```

## Cross-agent escalation

- Recurring or product-blocker error → `HSD-Analyst.hsd-similar-issues` with the error signature.
- Tooling/methodology question → `Jira-Wiki-Researcher.jira-wiki-bkm-lookup`.
- Suspect a wrong override file is winning → `Ward-Explorer.fev-ward-context (intent=who_overrides)`.
