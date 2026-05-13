---
applyTo: '**'
description: 'FEV domain primer — vocabulary, tools, layered overrides, run-area, iVARs, hook files, audit. Auto-applied to every chat in this workspace.'
---

# FEV domain primer

You are assisting an Intel FEV (Formal Equivalence Verification) engineer working in the **CTH
(Cheetah) Tool Flow Methodology**. The facts below are verified against the Cheetah FEV wiki.
See [AGENTS.md](../AGENTS.md) for the canonical page IDs and URLs.

## Tools and flow ids

| Tool | Vendor | CTH flow id | FEV shell | ECO shell | Default log |
|------|--------|-------------|-----------|-----------|-------------|
| Conformal LEC | Cadence | `fev_conformal` | `Ifev_shell` | `Ieco_shell` | `logs/lec.log` |
| Formality | Synopsys | `fev_formality` | `Ifev_fm_shell` | `Ieco_fm_shell` | `logs/fm.log` |

Flow Tracer GUI: `eouMGR --block <BLOCK> --design <DESIGN> --flow <fev_stack_name> --gui &`.

## CTH layered override (most-specific wins)

```
user  >  project  >  addon (≡ design_class)  >  tech  >  global
```

Applies to **both scripts and source code**. A file at `user` shadows the same file at any lower
layer. When debugging, walk the stack top-down to find the winning copy.

## Source-code roots

```
$ward/<layer>/cdns/fev_conformal      # Conformal templates / procs / vars.tcl
$ward/<layer>/snps/fev_formality      # Formality templates / procs / vars.tcl
$ward/global/intel/inspect_fev/inspectFEV.tcl
$ward/global/common/threshold_cfg/threshold_fev*.csv
```

## Run-area pattern (note plural `runs`)

```
$ward/runs/$block/$tech/$flow/$task
```

`$block` = build name (`-B`), `$task` = FEV task (`-T`), `$tech` = tech node (`-X`).
Inside a run-area: `logs/`, `reports/`, `scripts/` (hooks + proc overrides). InspectFEV creates
`IF_<block>_<task>/` at PWD.

## Tasks (must-know names)

- **Conformal**: `fev_rtl2syn`, `fev_rtl2apr`, `fev_rtl2flp`, `fev_fcl`,
  `fev_rtl2syn_quick_febe`, `fev_rtl2syn_full_febe`, `fev_rtl2map`,
  `fev_map2syn`, `fev_syn2apr`, `fev_syn2apr_cdns`,
  `fev_rtl2rtl`, `fev_sim2syn`, `fev_lite`, `fev_hier2flat_upf`, `fev_ctechverif`,
  `eco`, `eco_verify`.
- **Formality**: same intent prefixed `fev_fm_*` (e.g. `fev_fm_rtl2syn`, `fev_fm_rtl2rtl`,
  `fev_fm_lite`, `fev_fm_syn2apr`, `fev_fm_sim2syn`, `fev_fm_hier2flat_upf`, `fev_fm_ctechverif`,
  `fev_fm_rtl2logicopto`).

New task → `set ivar($new_task_name,template_map) "<base_template>"`.

## iVAR system (cheat-sheet)

| Concern | iVAR |
|--------|------|
| Golden RTL filelist | `ivar($task,rtl_list_golden)` |
| Revised RTL filelist | `ivar($task,rtl_list_revised)` |
| Golden / revised netlist | `ivar($task,golden_gate)` / `ivar($task,revised_gate)` |
| Golden / revised UPF | `ivar($task,golden_upf)` / `ivar($task,revised_upf)` |
| Synthesis guidance | `ivar($task,guidance_file_path)` — vsdc (Conformal) or SVF (Formality) |
| Child modules | `ivar($block,child_modules)` / `ivar($block,child_instances)` |
| Blackbox list | `ivar($task,$ivar(design_name),black_box)` |
| Tool version | `ivar($task,lec_path)` / `ivar($task,fm_path)` |
| Bscript archive | `ivar(bscript_dir)` |

Defaults: `<layer>/cdns/fev_conformal/vars.tcl`, `<layer>/snps/fev_formality/vars.tcl`. Override
at the highest-priority layer you control.

## Hook files (extend a run without forking the template)

Place under `<run_area>/scripts/`. Move to `$ivar(bscript_dir)/$task/` for central runs.

- **Conformal (8)**: `fev_setup_commands.tcl`, `fev_pre_lib.tcl`, `fev_pre_read_upf.tcl`,
  `fev_post_read_upf.tcl`, `fev_post_setup.tcl`, `fev_mapping.tcl`, `fev_pre_flatcompare.tcl`,
  `fev_post_compare.tcl`.
- **Formality (7)**: `fev_fm_pre_read_lib.tcl`, `fev_fm_pre_read_design.tcl`,
  `fev_fm_post_read_upf.tcl`, `fev_fm_post_setup.tcl`, `fev_fm_pre_compare.tcl`,
  `user_fm_vclp_waivers.tcl`, `fev_fm_post_compare.tcl`.

Proc overrides: `scripts/user_procs.tcl` (Conformal) / `scripts/user_fm_procs.tcl` (Formality).
Defaults live in `default_procs.tcl` / `default_fm_procs.tcl` under the respective source root.

## Audit & sign-off

- **InspectFEV** runs automatically after a successful FEV run unless `-skipaudit`. Outputs in
  `IF_<block>_<task>/`. Pre-waiver summary: `results/InspectFEV_SUMMARY.rpt`. Post-waiver:
  `results/Greenstone_summary.rpt`.
- **Greenstone** waiver GUI: `source greenstone.csh`. Non-greenstone mode: pass
  `-nogreenstone_mode` to the shell; waivers go through cth_waiver / Finale.
- **Milestone check**:
  `eouMGR --block <block> --checker --flow fev --threshold_config <csv> --milestone 0p3`.

## Hard rules

1. **Plural `runs`** — never write `$ward/run/...` in a real run-area path.
2. **Use the override stack** to localize files. Never `Get-ChildItem -Recurse $ward`.
3. **Prefer hook files** over editing `default_procs.tcl`.
4. **Cite Confluence page title + URL + page ID** when quoting wiki. Use IDs from
   [config/knowledge-base.yaml](../config/knowledge-base.yaml).
5. **Cite HSD ID + field name** when quoting tickets.
6. If a CTH-internal term is new (e.g. a project's `design_class`), **ask once** and persist via
   [config/ward-paths.yaml → terminology](../config/ward-paths.yaml).
