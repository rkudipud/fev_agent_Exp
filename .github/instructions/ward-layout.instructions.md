---
applyTo: '**'
description: 'Ward layout, override-resolution algorithm, and run-area conventions used by every FEV agent here. Sourced from the Cheetah FEV wiki.'
---

# Ward layout & run-area instructions

Source-of-truth: [config/ward-paths.yaml](../config/ward-paths.yaml). Wiki citations in
[AGENTS.md](../AGENTS.md).

## Override resolution algorithm

```
for layer in [user, project, addon, tech, global]:
    candidate = expand("$ward/<layer>/<tool_root>/<file>")
    if exists(candidate):
        return candidate            # winning layer
    record(candidate)               # for transparency
```

`<tool_root>` = `cdns/fev_conformal` or `snps/fev_formality`.

When debugging an unexpected override, list **all** existing candidates, not just the winning one
— a stale higher-layer copy is a common cause of "the wrong dofile is running."

## Run-area resolution

```
$ward/runs/$block/$tech/$flow/$task
$flow ∈ {fev_conformal, fev_formality}
```

Inside the run-area:
- `logs/lec.log` (Conformal) or `logs/fm.log` (Formality). Rotated copies:
  `logs/<task>_lec.log.<timestamp>` / `<task>_fm.log.<timestamp>`.
- `reports/` — final reports.
- `scripts/` — hook files + `user_procs.tcl` / `user_fm_procs.tcl`.

InspectFEV outputs land in `IF_<block>_<task>/` at PWD (NOT inside the run-area):
`results/InspectFEV_SUMMARY.rpt` (pre-waiver), `results/Greenstone_summary.rpt` (post-waiver),
`outputs/violation_rpts/`, `outputs/<block>.<task>.violations.xml`, `greenstone.csh`.

## Release-collateral path template (verified)

```
$env(ward)/runs/$block/$env(tech)/release/$env(tag)/
  fe_collateral/rtl_list_2stage.tcl
  fe_collateral/$ivar(design_name).upf
  finish/$ivar(design_name).pt.v
  finish/$ivar(design_name).vsdc      # Conformal guidance
  finish/$ivar(design_name).svf       # Formality guidance
  compile_initial_opto/$ivar(design_name).pt.v
  compile_initial_opto/$ivar(design_name).upf
```

## What to ask before guessing

Persist answers in `config/ward-paths.yaml → terminology:`.

- `$ward` root (absolute path)
- `project` name and any `addon` (design_class) name
- `tech`
- `block` / build name
- `flow` (Conformal or Formality)
- `task` (must be a recognized fev_* name — see the YAML's `run_area.tasks:` list)
- `tag` (latest by default)

## Don't full-grep

Never `Get-ChildItem -Recurse $ward` for a file when override hierarchy + flow can pin it down. If
you must grep, scope to one `<layer>/<tool_root>` at a time and explain why.

## Quick discovery

Use `scripts/discover-ward.ps1 -WardRoot <ward>` for a JSON map of which layers/flows exist and
which `runs/<block>/<tech>/<flow>/<task>` paths have content.
