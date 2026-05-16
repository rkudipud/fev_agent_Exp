---
name: fev-regression-compare
description: >
  Compare two FEV regression runs (Conformal or Formality) by diffing every
  block's *.stats file across a reference tag and a candidate tag under a shared
  regression root.  Writes a Python comparison script to /tmp, runs it,
  reads the raw output, converts it to a clean Markdown qualification report,
  and synthesises an inline root cause callout for every non-clean block.
  Saved to the user's current working directory.
---

# Skill: fev-regression-compare

## When to use

- "Compare REL_2026.03 vs REL_2026.03_p100 across all blocks."
- "Qualify Conformal 26.10-p100 against the reference run."
- "Qualify Formality 2025.06 against the reference run."
- "Run a regression comparison and give me a report."
- "Did the new tool version change any FEV results?"
- "Analyze the report and explain the root cause for each block."
- "Add inline root cause explanations to the qualification report."

## Inputs

| Parameter | Required | Description |
|---|---|---|
| `reg_root` | ✅ | Absolute path to the shared regression root (e.g. `/nfs/site/disks/ddi_r2g_13/cfm_regressions`) |
| `ref_tag` | ✅ | Reference directory name under each project (e.g. `REL_2026.03`) |
| `new_tag` | ✅ | Candidate directory name under each project (e.g. `REL_2026.03_p100`) |
| `ref_version` | optional | Human-readable tool version for REF (e.g. `25.20-s200`). Used in report header only. |
| `new_version` | optional | Human-readable tool version for candidate (e.g. `26.10-p100`). |
| `tool` | optional | `conformal` \| `formality` \| `auto`. Default: `auto` (detected from stats content). |
| `output_name` | optional | Stem for the output MD file. Default: `regression_compare_report`. |
| `extra_skip_fields` | optional | Additional field names to suppress from the diff (comma-separated). |
| `extra_waive_rules` | optional | Additional `field=allowed_delta` pairs (comma-separated), e.g. `MyIvar=2`. |
| `projects` | optional | Comma-separated list of project sub-dirs to restrict comparison to. Default: all. |

## Directory layout expected

```
<reg_root>/
  <project1>/
    <ref_tag>/
      <block1>/
        regression/
          <block1>.stats      ← primary location
      <new_tag>/
        <block1>/
          regression/
            <block1>.stats
  <project2>/
    ...
```

If `<block>.stats` is absent, any `*.stats` in `regression/` is used as fallback.

## Stats file format

One record per line:  `<task_section>  <field>  <value>`

Example:
```
fev_rtl2apr_Compare   Non_equivalent   108
fev_rtl2apr_Compare   Equivalent       25
fev_rtl2apr_InspectFEV  ReportUserIvarsOverride  3
fevChecker   Status   PASS
```

The same format is used by both Conformal (`fev_*`) and Formality (`fev_fm_*`) tasks.

## Skip / waive / environ rules (defaults — user may extend)

| Category | Fields | Treatment |
|---|---|---|
| **Skip** (never shown) | `stats_generated_time`, `Run_dir`, `Conformal_version`, `FM_version`, `splunk_upload`, `Runtime_secs`, `Memory`, `IF_time`, `Runtime`, `Total_CPU_time` | Omitted completely |
| **Env-change** (shown, not failed) | `PDK_dir`, `Std_cell_version` | 🔵 ENV-CHANGE tag |
| **Waived** (shown, not failed) | `ReportUserIvarsOverride` bump of exactly **+1** | 🟡 WAIVED tag |
| **Real diff** | Everything else that changes | 🔴 DIFF tag |
| **New field** | Present in candidate, absent in REF | 🟢 MISSING→NEW tag |
| **Dropped field** | Present in REF, absent in candidate | ⚫ PRESENT→DROPPED tag |

## Procedure

### Step 1 — Gather inputs

Ask for any missing required parameters before proceeding.  If `reg_root` is not provided,
consult `config/ward-paths.yaml → ward_root` as a hint.

### Step 2 — Write comparison script to /tmp

Write the self-contained Python 3 comparison script to:

```
/tmp/fev_regcomp/compare_regression.py
```

The script must implement all skip/waive/environ rules above, accept the following CLI flags,
and write its raw output to:

```
/tmp/fev_regcomp/raw_report.json
```

CLI flags for the generated script:
```
--root      <reg_root>
--ref       <ref_tag>
--new       <new_tag>
--ref-ver   <ref_version>   (default "REF")
--new-ver   <new_version>   (default "NEW")
--projects  <comma-list>    (default: all)
--skip      <comma-list>    (additional fields to skip)
--waive     <field=delta,…> (additional waive rules)
```

The script output JSON schema:

```json
{
  "meta": {
    "root": "...",  "ref_tag": "...",  "new_tag": "...",
    "ref_ver": "...",  "new_ver": "...",  "generated": "ISO8601"
  },
  "projects": [
    {
      "name": "...",
      "only_ref": ["block", ...],
      "only_new": ["block", ...],
      "blocks": [
        {
          "name": "...",
          "status": "CLEAN | CLEAN-WAIVED | DIFF | PENDING",
          "pending_reason": "...",
          "diffs": [
            {
              "task_section": "...",
              "field": "...",
              "ref": "...",
              "new": "...",
              "tag": "DIFF | WAIVED | ENV-CHANGE | MISSING→NEW | PRESENT→DROPPED"
            }
          ]
        }
      ]
    }
  ],
  "summary": {
    "total_blocks": 0,
    "clean": 0,
    "diff_blocks": 0,
    "pending": 0,
    "real_diff_rows": 0
  }
}
```

### Step 3 — Run the script

Execute via `run_in_terminal`:

```bash
python3 /tmp/fev_regcomp/compare_regression.py \
  --root <reg_root> --ref <ref_tag> --new <new_tag> \
  [--ref-ver <ref_version>] [--new-ver <new_version>] \
  [--projects <proj_list>] [--skip <fields>] [--waive <rules>]
```

Confirm exit code 0 and that `/tmp/fev_regcomp/raw_report.json` exists.

### Step 4 — Read JSON and synthesize the Markdown report

Read `/tmp/fev_regcomp/raw_report.json` and produce a Markdown document using the template
below.  Do **not** echo the raw JSON to the user.

### Step 5 — Write final MD to user's CWD

Save the rendered Markdown to:

```
<user_cwd>/<output_name>.md
```

where `<user_cwd>` is obtained by running `pwd` in the terminal before step 3.

Confirm the path to the user.

---

## Output Markdown template

```markdown
# FEV Regression Comparison Report

| | |
|---|---|
| **Reference** | `<ref_tag>` — tool version `<ref_version>` |
| **Candidate** | `<new_tag>` — tool version `<new_version>` |
| **Root** | `<reg_root>` |
| **Tool** | Conformal / Formality / Both |
| **Generated** | <ISO8601> |

> **Legend:**
> 🔴 DIFF = real change · 🟡 WAIVED = allowed delta · 🔵 ENV-CHANGE = PDK/lib ·
> 🟢 MISSING→NEW = new field in candidate · ⚫ PRESENT→DROPPED = field removed

---

## Grand Summary

| Project | Blocks | ✅ Clean | ❌ DIFF | ⏳ Pending | DIFF rows |
|---|---|---|---|---|---|
| `proj1` | N | N | N | N | N |
| **TOTAL** | **N** | **N** | **N** | **N** | **N** |

### Verdict

<✅ PASS | ❌ NEEDS REVIEW | ⏳ INCOMPLETE>

---

## Project: `<name>`

> ⚠️ Blocks only in REF (not run in candidate): `b1`, `b2`
> ℹ️ New blocks only in candidate: `b3`

#### `<block>` &nbsp; <✅ CLEAN | ❌ DIFF (N real) | ⏳ PENDING>

> **Status:** ...
> **Changes:** N DIFF · N waived · N env · N new-field · N dropped-field

| task_section | field | REF `<ref_ver>` | candidate `<new_ver>` | status |
|---|---|---|---|---|
| `task_fev_xxx` | `field_name` | `ref_value` | `new_value` | 🔴 DIFF |

_Repeat for every project / block._

---
```

## Diff interpretation hints (embed in report as callouts when present)

| Pattern | Callout to include |
|---|---|
| `fevChecker Status` changed to `ERROR` | > ⚠️ **fevChecker ERROR** — run `cat regression/regression.log` in the p100 block dir and check for traceback. |
| `exit_code` changed | > ⚠️ **Exit code changed** `<ref>` → `<new>` for task `<task>`. Review compare results. |
| `Non_equivalent` increased | > ❌ **Non-equivalent count increased** — regression in compare results. |
| `Non_equivalent` unchanged, only `Gate_count_*` differs by < 0.1% | > ℹ️ **Gate count noise** — sub-0.1% variation; FEV results unaffected. |
| `CheckforGeneralError` decreased | > ✅ **CheckforGeneralError improved** (`<ref>` → `<new>`). |
| Task entirely absent in REF (all fields MISSING→NEW) | > ℹ️ **New task in candidate** — `<task>` did not exist in REF. Review results independently. |
| `FEV_iDATA` / `LEC_result` PRESENT→DROPPED in eco sections | > ℹ️ **Stats schema change** — `FEV_iDATA`/`LEC_result` removed from eco_Rest in new version. Not a correctness issue; confirm with stats generation owner. |

## Reusability notes (Conformal vs Formality)

- Conformal tasks are prefixed `fev_*`; Formality tasks are prefixed `fev_fm_*`.
- Stats file location and format are identical — the same script handles both.
- For Formality, `Conformal_version` becomes `FM_version` in the stats; both are in `SKIP_FIELDS`.
- If a project runs both tools, each tool's task sections will appear in the same `.stats` file
  and will be diff'd together.

---

## Formality / VCLP regression specifics

When the regression root is `fm_regressions` (or contains Formality LP flows), the layout and
procedure differ from the Conformal path in two ways:

### 1. Stats file path

Formality blocks use a **steps-based stats file** at:

```
<block>/regression/steps/stats.stats
```

rather than the Conformal path `regression/<block>.stats`.  The agent must look for
`regression/steps/stats.stats` first; fall back to `regression/*.stats` if absent.

### 2. VCLP-specific fields

When a VCLP (VC Low Power) version change is involved, the following extra
classification rules apply:

| Category | Fields | Treatment |
|---|---|---|
| **Skip** (add to default skip list) | `VCLP_version`, `Formality_version`, `FM_version`, `promote_auto` | 🔵 VERSION-CHANGE (shown, not failed) |
| **LP-DIFF** (critical, shown red) | `LP_VIOL`, `CheckLPViolations` | 🔴 LP-DIFF |
| **ENV-CHANGE** (as usual) | `PDK_dir`, `Std_cell_version` | 🔵 ENV-CHANGE |

VCLP version fields should be shown as `🔵 VERSION-CHANGE`, not silently omitted — they are
the root cause of the comparison and help confirm which blocks actually switched versions.

### 3. fm.log warning analysis

For any block with LP-DIFF or DIFF, extract the diagnostic summary line from the FM log:

```
fm.log path:  <block>/runs/<block>/<tech>/fev_formality/<task>/logs/fm.log
```

The summary line looks like:
```
Diagnostics summary: N warnings, M informationals
```

Include REF vs NEW warning counts in the report for each diffing task.  Identical warning counts
mean the Formality engine ran identically — the FEV change is driven purely by VCLP.

### 4. Interpreting VCLP-driven changes

| Pattern | Interpretation |
|---|---|
| `LP_VIOL` decreased | ✅ LP improvement — direct benefit of new VCLP |
| `LP_VIOL` increased | ❌ LP regression — needs root cause |
| `Failing`/`NonEquivalent` increased, fm warnings unchanged | 🔴 FEV regression (VCLP supply/domain mapping change) |
| `Failing` decreased / `Passing` increased | ✅ FEV improvement |
| `Passing` → `Unverified` shift (passing count drops, unverified rises, Failing unchanged) | 🔴 Regression — previously proved-equivalent points now unresolvable under new VCLP constraints |
| `Unverified` → `Abort` shift (Abort rises, Unverified drops) | 🔴 Regression — Formality hit a tool abort; worse than Unverified (compare engine stopped entirely) |
| Total compare count conserved but distribution shifts (Failing ↓, Unverified ↑) | 🟡 Mixed — LP domain redistribution; net Failing may improve but provability loss needs review |
| ECO `exit_code` 1 → 0 | ✅ ECO improvement — VCLP fixed an ECO constraint that was previously failing |
| ECO `exit_code` 1 → 3 | 🟡 Review — exit 3 = InspectFEV post-compare issue (not a compare failure); check `VtoKErrgen` and `NonEquivalent` flags |
| ECO `exit_code` unchanged, `ECO_Added_*` delta ±small | 🟡 ECO cell-count variation — VCLP's updated LP guidance changed synthesis optimization; check QoR impact |
| ECO tasks all `MISSING→NEW` | 🟢 New task now running — VCLP enabled previously-blocked ECO steps; review results independently |
| `fubstatus=Aborted` (stats file missing in NEW) | ⏳ Pending — run did not complete; re-run when ready |
| Block absent in REF only (ONLY-NEW) | 🟢 New block added to suite — not a VCLP regression |
| Failing increased, patterns are `auto_vector_*_MBIT_*` DFFs | 🔴 VCLP changed LP domain for MBIT-merged scan/latch groups — escalate to VCLP tool team |

### 5. Canonical scripts for Formality/VCLP comparisons

These scripts live persistently at `/tmp/fev_regcomp/` (written once per session):

| Script | Purpose |
|---|---|
| `compare_fm_regression.py` | Full comparison: handles `steps/stats.stats`, LP fields, fm.log extraction |
| `vclp_block_report.py` | Reads `fm_raw_report.json`, renders the final VCLP qualification MD |
| `run_fm_compare.sh` | Shell wrapper to invoke `compare_fm_regression.py` |
| `run_vclp_report.sh` | Shell wrapper to invoke `vclp_block_report.py` |

CLI for `compare_fm_regression.py`:
```bash
python3 /tmp/fev_regcomp/compare_fm_regression.py \
  --root /nfs/site/disks/ddi_r2g_13/fm_regressions \
  --ref  REL_2026.03 \
  --new  vclp_x_sp2_1a \
  --ref-ver "V-2023.12-SP2-8" \
  --new-ver "X-2025.06-SP2-1a" \
  --out  /tmp/fev_regcomp/fm_raw_report.json
```

Output JSON is read by `vclp_block_report.py` to produce the Markdown qualification report.

### 6. tcsh / bash compatibility note

The regression environment uses **tcsh**.  All Python and bash scripts must be written to files
and invoked as `bash /path/script.sh` — never use `bash -c "..."` with embedded newlines in tcsh;
they fail with "Unmatched" or `for: No match.` errors.

Output redirections (`>`, `>>`) must also be inside the `.sh` file, not on the tcsh command line.

### 7. Filtering pandora housekeeping entries

The regression root contains hidden pandora files/dirs (`.activeSetup`, `.allfubs.status`,
`.email.log*.tmp`, `.monitor-<UUID>`, `.progress.status`, `.reg_config`, `.reg_runid`,
`.steps`, `.success.status`).  The comparison script must filter these with:

```python
def is_real_block(path, name):
    if name.startswith('.'):
        return False
    return os.path.isdir(path)
```

### 8. Inline root cause callout synthesis

After generating the qualification report, synthesise a `> **Root cause —`block`:**` blockquote
callout for **every non-clean block** and insert it directly into the report (immediately after
the block's fm.log diagnostics table, or after the stats table if no fm.log table is present).

#### Callout format

```markdown
> <emoji> **Root cause — `<block>`:** <one-sentence mechanism>. <fm.log context>.
> **Action:** <next step> — OR — **No action needed.**
```

Use a multi-line blockquote for HIGH-risk regressions:

```markdown
> <emoji> **Root cause — `<block>`:** <mechanism>.
>
> **Affected:** <module / count>. fm.log: <N warnings> (same both runs).
>
> **Action:** <specific step for block owner>. **Risk: <LOW|MEDIUM|HIGH>.**
```

#### Emoji / severity mapping

| Emoji | When to use |
|---|---|
| ✅ | LP improvement (`LP_VIOL` decreased) or ECO improved (exit_code 1 → 0) |
| 🔍 | Negligible change (±1 boundary, new task entries, ECO cell-count ±small) |
| 🟡 | Mixed result — some improvement, some degradation; or ECO exit_code 3 |
| 🔴 | FEV regression: Failing increased, Abort increased, Passing→Unverified >100 pts |
| 🕐 | Pending (fubstatus=Aborted, stats missing) |
| ℹ️ | New block / informational only |

#### Key anchor rule

The fm.log warning count is the **litmus test**: if REF and NEW warning counts are identical, the
Formality engine ran identically and any FEV change is driven **purely by VCLP**.  Always state
this explicitly in the callout.

#### MBIT-vectorized scan/latch DFF pattern

When failing_points contain `auto_vector_*_MBIT_*` DFFs, identify the affected module hierarchy
and report the count.  This pattern is a VCLP LP domain assignment change on scan-vectorized
groups and requires escalation to the VCLP tool team.

#### Where to anchor the callout in the report

1. If a `**fm.log diagnostics summary:**` table is present → insert after the last `| ... |` row.
2. If no fm.log table → insert after the last table row of the stats diff table.
3. For PENDING blocks → insert as a second line under the existing `> ⏳ stats missing` line.

## Cleanup

Temp files at `/tmp/fev_regcomp/` may be left for re-use within the same session.
They are never committed to the workspace.

## Example invocation prompts

```
"Compare REL_2026.03 vs REL_2026.03_p100 under /nfs/site/disks/ddi_r2g_13/cfm_regressions"
"Qualify Formality 2025.12-sp1 — ref=REL_FM_2025.12, new=REL_FM_2025.12_sp1 in /nfs/fmv_regressions"
"Regression compare with extra skip: LEC_result; extra waive: MyCustomIvar=2"
"Re-run the regression compare for projects dmr,n3 only"
```
