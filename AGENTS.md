# AGENTS.md — FEV Agent project context (wiki-infused)

This workspace defines a multi-agent assistant for **FEV (Formal Equivalence Verification)**
engineers using Intel's **CTH (Cheetah)** Tool Flow Methodology. Facts below were fetched live
from the Cheetah FEV wiki and the HSDES MCP wiki via the `wiki-jira-mcp` server.

## Authoritative source pages (verified)

| Page | URL | Page ID |
|------|-----|---------|
| FEV root | <https://wiki.ith.intel.com/display/cheetah/FEV> | 2288898439 |
| FEV_CONFORMAL flow | <https://wiki.ith.intel.com/display/cheetah/FEV_CONFORMAL> | 2376013930 |
| FEV_FORMALITY flow | <https://wiki.ith.intel.com/display/cheetah/FEV_FORMALITY> | 2376013928 |
| FEV_CONFORMAL BKMs | <https://wiki.ith.intel.com/display/cheetah/FEV_CONFORMAL+BKMs> | 2288898444 |
| FEV_FORMALITY BKMs | <https://wiki.ith.intel.com/display/cheetah/FEV_FORMALITY+BKMs> | 2967972768 |
| FEV_CONFORMAL ECO | <https://wiki.ith.intel.com/display/cheetah/FEV_CONFORMAL+ECO> | 2288898442 |
| FEV_FORMALITY ECO | <https://wiki.ith.intel.com/display/cheetah/FEV_FORMALITY+ECO> | 2376014240 |
| FEV_CONFORMAL Paranoia | <https://wiki.ith.intel.com/display/cheetah/FEV_CONFORMAL+Paranoia> | 2288898447 |
| FEV_Formality Signoff & Paranoia runs | <https://wiki.ith.intel.com/pages/viewpage.action?pageId=2799577214> | 2799577214 |
| debugFEV | <https://wiki.ith.intel.com/pages/viewpage.action?pageId=2591606319> | 2591606319 |
| InspectFEV | <https://wiki.ith.intel.com/pages/viewpage.action?pageId=2716142730> | 2716142730 |
| FEV Indicators | <https://wiki.ith.intel.com/pages/viewpage.action?pageId=4112071888> | 4112071888 |
| Compare Recipe Finder | <https://wiki.ith.intel.com/pages/viewpage.action?pageId=3205930885> | 3205930885 |
| RTL2RTL FEV Utility | <https://wiki.ith.intel.com/pages/viewpage.action?pageId=2602665916> | 2602665916 |
| FEV CONFORMAL ANALYZER | <https://wiki.ith.intel.com/pages/viewpage.action?pageId=2602671432> | 2602671432 |
| CLP — Conformal Low Power | <https://wiki.ith.intel.com/pages/viewpage.action?pageId=3413688249> | 3413688249 |
| FEV_LITE in Formality | <https://wiki.ith.intel.com/pages/viewpage.action?pageId=3518272648> | 3518272648 |
| FEV_CONFORMAL Testcase Extraction | <https://wiki.ith.intel.com/pages/viewpage.action?pageId=2579192892> | 2579192892 |
| FEV_CONFORMAL Training | <https://wiki.ith.intel.com/display/cheetah/FEV_CONFORMAL+Training> | 2397482922 |
| FEV_FORMALITY Training | <https://wiki.ith.intel.com/display/cheetah/FEV_FORMALITY+Training> | 2517804040 |
| FEV Release Notes | <https://wiki.ith.intel.com/display/cheetah/FEV+Release+Notes> | 3086369633 |
| Deleted Sequentials flow | <https://wiki.ith.intel.com/pages/viewpage.action?pageId=2798153420> | 2798153420 |
| sim2syn FEV | <https://wiki.ith.intel.com/pages/viewpage.action?pageId=3003274855> | 3003274855 |
| Formality→Conformal Feedthru Conversion | <https://wiki.ith.intel.com/pages/viewpage.action?pageId=3771117942> | 3771117942 |
| CTH2 Waiver Flow Cheatsheet | <https://wiki.ith.intel.com/display/cheetah/CTH2+Waiver+Flow+Cheatsheet> | — |
| HSDES MCP guide | <https://wiki.ith.intel.com/spaces/ITScedf/pages/4705390469/HSDES+MCP> | 4705390469 |
| mcp-hsd source (installed) | <https://github.com/intel-sandbox/mcp-suite/tree/master/tools/mcp-hsd> | — |

Pluggable pointer list: [config/knowledge-base.yaml](config/knowledge-base.yaml). When the agent
finds new pages worth remembering, it asks the user to append them there. Inside that file:

- `curated_pages:` — flat tagged index of all FEV / Cheetah2 pages.
- `fev_root_tree:` / `fev_conformal_subtree:` / `fev_formality_subtree:` — full sub-page trees
  with page IDs and `last_seen_version` for drift detection.
- `cheetah2_pages:` — Cheetah2 platform pages (R2G releases, test waivers, BKM/FAQs, deployment).
- `highly_ranked:` — top-20 entry points the agent suggests first.
- `maintenance:` — refresh procedure (run `confluence_get_page_children` on each subtree root,
  bump versions, append new children).

## Domain map (verified)

### Tools and flows

- **Cadence Conformal LEC** — CTH flow id `fev_conformal`. Shells: `Ifev_shell` (FEV),
  `Ieco_shell` (ECO). Default log: `logs/lec.log`.
- **Synopsys Formality** — CTH flow id `fev_formality`. Shells: `Ifev_fm_shell` (FEV),
  `Ieco_fm_shell` (ECO). Default log: `logs/fm.log`.
- **Flow Tracer GUI**:
  `eouMGR --block <BLOCK> --design <DESIGN> --flow <fev_stack_name> --gui &`.

### CTH layered override (most-specific wins)

```
user  >  project  >  addon (a.k.a. design_class)  >  tech  >  global
```

Applies to both **scripts** and **source code**. Wiki phrasing: *"Global templates can be
overridden in design_class/project and user layer."* `addon` and `design_class` are treated as the
same slot.

### Source code roots (verified)

```
$ward/<layer>/cdns/fev_conformal     # Conformal templates / procs / vars.tcl
$ward/<layer>/snps/fev_formality     # Formality templates / procs / vars.tcl
```

Key files:
- `global/cdns/fev_conformal/vars.tcl` — Conformal default iVARs.
- `global/cdns/fev_conformal/default_procs.tcl` — default Conformal procs.
- `global/cdns/fev_conformal/promote.tcl` — promotion script.
- `global/snps/fev_formality/vars.tcl` — Formality default iVARs.
- `global/snps/fev_formality/default_fm_procs.tcl` — default Formality procs.
- `global/snps/fev_formality/promote.tcl` — promotion script.
- `global/intel/inspect_fev/inspectFEV.tcl` — audit tool entry point.
- `global/common/threshold_cfg/threshold_fev*.csv` — milestone threshold configs.

### Run-area pattern (verified — note plural `runs`)

```
$ward/runs/$block/$tech/$flow/$task

$flow ∈ {fev_conformal, fev_formality}
$block = block / build name (-B switch on shells)
$task  = FEV task name      (-T switch)
$tech  = tech node          (-X switch)
$tag   = release tag        (-G switch)
```

Inside a run-area:
- Logs: `logs/lec.log` (Conformal) or `logs/fm.log` (Formality). Old runs rotated to
  `logs/<task>_lec.log.<timestamp>` / `<task>_fm.log.<timestamp>`.
- Reports: `reports/`.
- Hook scripts + proc overrides: `scripts/`.
- Audit (InspectFEV) creates `IF_<block>_<task>/` at PWD, with:
  - `logs/InspectFEV.log`
  - `outputs/violation_rpts/` (per-rule violations)
  - `outputs/InspectFEV_indicator_stats.txt`
  - `outputs/<block>.<task>.violations.xml`
  - `results/InspectFEV_SUMMARY.rpt` (pre-waiver)
  - `results/Greenstone_summary.rpt` (post-waiver)
  - `greenstone.csh` (open Greenstone GUI: `source greenstone.csh`).

Release input collaterals (from wiki, paths used by the templates):

```
$env(ward)/runs/$block/$env(tech)/release/$env(tag)/fe_collateral/rtl_list_2stage.tcl
$env(ward)/runs/$block/$env(tech)/release/$env(tag)/fe_collateral/$ivar(design_name).upf
$env(ward)/runs/$block/$env(tech)/release/$env(tag)/finish/$ivar(design_name).pt.v
$env(ward)/runs/$block/$env(tech)/release/$env(tag)/finish/$ivar(design_name).vsdc      # Conformal guidance
$env(ward)/runs/$block/$env(tech)/release/$env(tag)/finish/$ivar(design_name).svf       # Formality guidance
$env(ward)/runs/$block/$env(tech)/release/$env(tag)/compile_initial_opto/$ivar(design_name).pt.v
```

### Tasks (verified — complete list)

**Conformal** (`fev_conformal`):

| Task | Template | Purpose |
|------|----------|---------|
| `fev_rtl2syn` | fev_rtl2gate | RTL2GATE vs Syn `compile_initial_opto` |
| `fev_rtl2apr` | fev_rtl2gate | RTL2GATE vs APR `finish` |
| `fev_rtl2flp` | fev_rtl2gate | RTL2GATE vs floorplan |
| `fev_fcl` | fev_rtl2gate | spec FEV |
| `fev_rtl2syn_quick_febe` / `fev_rtl2syn_full_febe` | fev_rtl2gate | quick/full febe collaterals |
| `fev_rtl2map` | fev_rtl2gate | RTL2GATE vs CDNS Genus `genus_map` |
| `fev_map2syn` | fev_gate2gate | Genus `genus_map` ↔ `genus_dft` |
| `fev_syn2apr` | fev_gate2gate | Syn `compile_initial_opto` ↔ APR `finish` |
| `fev_syn2apr_cdns` | fev_gate2gate | CDNS-Genus syn ↔ apr |
| `fev_rtl2rtl` | fev_rtl2rtl | RTL2RTL FEV |
| `fev_sim2syn` | fev_rtl2rtl | sim-RTL ↔ syn-RTL |
| `fev_lite` | fev_rtl2rtl | FEV Lite |
| `fev_hier2flat_upf` | fev_rtl2rtl | hier-UPF ↔ merged-UPF |
| `fev_ctechverif` | fev_rtl2rtl | FE-ctech ↔ BE-ctech (alias map gen) |
| `eco`, `eco_verify` | (ECO) | Logic ECO + verify |

**Formality** (`fev_formality`):

| Task | Template |
|------|----------|
| `fev_fm_rtl2syn`, `fev_fm_rtl2apr`, `fev_fm_rtl2logicopto`, `fev_fm_fcl`, `fev_fm_quick_febe`, `fev_fm_full_febe` | fev_fm_rtl2gate |
| `fev_fm_rtl2rtl`, `fev_fm_lite`, `fev_fm_sim2syn`, `fev_fm_ctechverif`, `fev_fm_hier2flat_upf` | fev_fm_rtl2rtl |
| `fev_fm_syn2apr` | fev_fm_gate2gate |

Adding a new task requires `set ivar($new_task_name,template_map) "<base_template>"`. All FEV task
names start with `fev_`.

### iVAR system (most-used handles)

- **Collateral pointers**: `ivar($task,rtl_list_golden)`, `ivar($task,rtl_list_revised)`,
  `ivar($task,golden_gate)`, `ivar($task,revised_gate)`, `ivar($task,golden_upf)`,
  `ivar($task,revised_upf)`, `ivar($task,guidance_file_path)` (vsdc for Conformal, SVF for Formality).
- **Hierarchy / child collaterals**: `ivar($block,child_modules)`,
  `ivar($block,child_instances)` (Formality), `ivar($task,child,${side}_netlist_extn)`,
  `ivar($task,child,${side}_upf_extn)`, `ivar($task,all,${side}_path)`,
  `ivar($task,$child,${side}_path)`.
- **Blackbox**: `ivar($task,$ivar(design_name),black_box)`.
- **Tool version**: `ivar($task,lec_path)` (Conformal), `ivar($task,fm_path)` (Formality).
- **Feature flags (Conformal)**: `lp`, `smart`, `hier`, `dynamic_hier`, `analyze_datapath`,
  `seq_const_check`, `specified_setup`, `scan_constraints`, `lcp_constraints`, `td_constraints`,
  `keep_unreach`, `map_unreach`, `customized_mapping`, `alias_mapping`, `gen_sig_table`,
  `mapping_options`, `syn_tool`.
- **Feature flags (Formality)**: `lp`, `enable_compare_lp`, `read_svf_info`, `map_clk_dops`,
  `enable_meta_check`, `verify_unread_meta`, `seq_const_check`, `gen_sig_table`,
  `lcp_constraints`, `td_constraints`, `scan_constraints`, `v2k_config`.
- **ECO (Conformal)**: `ivar(eco,pre_eco_gate)`, `ivar(eco,post_eco_gate)`,
  `ivar(eco,fev_dot_tcl_path)`.
- **ECO (Formality)**: `ivar($task,orig_rtl)`, `ivar($task,orig_net1)`, `ivar($task,orig_upf)`,
  `ivar($task,orig_ndm)`, `ivar($task,fed_file_path)`, `ivar($task,eco_rtl)`,
  `ivar($task,targ_syn_svf)`, `ivar($task,targ_syn_gate)`, `ivar($task,targ_syn_ndm)`.
- **Archival**: `ivar(bscript_dir)` — central runs read user procs/waivers from
  `$ivar(bscript_dir)/$task/`.

Defaults: `global/cdns/fev_conformal/vars.tcl`, `global/snps/fev_formality/vars.tcl`. Override at
addon/project/user layer.

### Hook files (extend a run without forking the template)

Drop under `<run_area>/scripts/`. Archive at `$ivar(bscript_dir)/$task/` for central runs.

**Conformal (8):** `fev_setup_commands.tcl`, `fev_pre_lib.tcl`, `fev_pre_read_upf.tcl`,
`fev_post_read_upf.tcl`, `fev_post_setup.tcl`, `fev_mapping.tcl`, `fev_pre_flatcompare.tcl`,
`fev_post_compare.tcl`.

**Formality (7):** `fev_fm_pre_read_lib.tcl`, `fev_fm_pre_read_design.tcl`,
`fev_fm_post_read_upf.tcl`, `fev_fm_post_setup.tcl`, `fev_fm_pre_compare.tcl`,
`user_fm_vclp_waivers.tcl`, `fev_fm_post_compare.tcl`.

Proc overrides: `scripts/user_procs.tcl` (Conformal), `scripts/user_fm_procs.tcl` (Formality).

### Audit & sign-off

- **InspectFEV** runs automatically after a successful FEV run unless `-skipaudit` is given.
  Standalone:
  `inspectFEV.tcl -B <block> -T <task> -fev_type {r2g|g2g|r2r|fev_lite} -fev_run_dir <dir> -tool {conformal|formality}`.
- **Greenstone** = waiver GUI: `source greenstone.csh` (from `IF_<block>_<task>/`). Disable with
  `-nogreenstone_mode` on the shell; waivers then flow through cth_waiver/Finale.
- **Milestone check (cth_waiver)**:
  `eouMGR --block <block> --checker --flow fev --threshold_config <csv> --milestone 0p3`. CSVs:
  - `threshold_fev.csv` — Conformal greenstone
  - `threshold_fev_nogreenstone_mode.csv` — Conformal non-greenstone
  - `threshold_fev_fm.csv` — Formality greenstone
  - `threshold_fev_fm_nogreenstone_mode.csv` — Formality non-greenstone
  - `threshold_fev2step.csv` — 2-step FEV sign-off

## Agents in this workspace

| Agent | Role |
|-------|------|
| [`FEV-Lead`](agents/fev-lead.agent.md) | Orchestrator. Routes intent to specialists. |
| [`HSD-Analyst`](agents/hsd-analyst.agent.md) | HSDES ticket lookup, summary, similar-issue mining. Chains to HSDES-shipped AI skills (`hsdes-issue-investigator`, `hsdes-quality-scorer`, `hsdes-query-eql`, `hsdes-debug-orchestrator`). |
| [`Jira-Wiki-Researcher`](agents/jira-wiki-researcher.agent.md) | Confluence + Jira BKM / INote research using `mcp_wiki-jira-mcp_*`. |
| [`Ward-Explorer`](agents/ward-explorer.agent.md) | Ward layout, override hierarchy, run-area + iVAR + hook-file awareness. |
| [`Log-Analyzer`](agents/log-analyzer.agent.md) | `lec.log` / `fm.log` parsing, InspectFEV/Greenstone correlation. |
| [`FEV-CoEngineer`](agents/fev-coengineer.agent.md) | Pair-debugging persona — senior FEV engineer + devil's advocate. |

## Skills in this workspace

| Skill | Purpose |
|-------|---------|
| [`fev-log-analysis`](.github/skills/fev-log-analysis/SKILL.md) | Parse `lec.log` / `fm.log` for non-equiv, abort, InspectFEV failures. |
| [`fev-ward-context`](.github/skills/fev-ward-context/SKILL.md) | Resolve ward override stack and iVAR values. |
| [`fev-regression-compare`](.github/skills/fev-regression-compare/SKILL.md) | Compare two FEV regression tags (Conformal **or** Formality/VCLP) block-by-block via `.stats` diffs + `fm.log` warning analysis. Writes canonical Python to `/tmp/fev_regcomp/`, produces JSON, renders final MD to user CWD. |
| [`hsd-fetch-summarize`](.github/skills/hsd-fetch-summarize/SKILL.md) | Fetch an HSD ticket and produce a structured summary. |
| [`hsd-similar-issues`](.github/skills/hsd-similar-issues/SKILL.md) | Search for prior HSD sightings similar to a given ticket. |
| [`jira-wiki-bkm-lookup`](.github/skills/jira-wiki-bkm-lookup/SKILL.md) | Search Confluence + Jira for BKMs, INotes, training pages. |
| [`mcp-discovery`](.github/skills/mcp-discovery/SKILL.md) | Enumerate available MCP tools and describe capabilities. |

## House rules

1. **Be proactive about MCP capabilities.** First turn of any sub-agent emits a one-line capability
   summary from [config/mcp-registry.yaml](config/mcp-registry.yaml).
2. **Cite real source.** Confluence page title + URL + page ID; HSD ID + field; iVAR name + layer.
3. **Use the override hierarchy** to localize files before any grep. Never `grep -r $ward`.
4. **Honor `$ward/runs/$block/$tech/$flow/$task` verbatim** — plural `runs`.
5. **Ask before destructive actions** (file deletes, ward edits, ticket writes).
6. **Persist new vocabulary** — when the user introduces a new term, append it to
   [config/ward-paths.yaml → terminology](config/ward-paths.yaml).
