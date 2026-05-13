---
name: fev-ward-context
description: Resolve FEV-related paths in a CTH ward using the layered override hierarchy and run-area pattern. Avoid full-ward greps.
---

# Skill: fev-ward-context

## When to use

- "Where is the dofile / setup file / constraint / log / report for …?"
- "Which layer is overriding X?"
- "Build the run-area path for build=… tech=… sub_flow=…"

## Canonical facts (do not invent — load from config)

Authoritative reference:
[../../config/ward-paths.yaml](../../config/ward-paths.yaml). It contains:

- The override layer list.
- Source-code root patterns for Conformal and Formality.
- Run-area pattern and known artifacts.
- A `terminology:` section the user fills in over time (ward, rundir, sub_flow names, etc.).

Bootstrap defaults (already in the YAML):

```
override_layers:    [user, project, design_class, tech, global]
source_roots:
  conformal: "$ward/<layer>/cdns/fev_conformal"
  formality: "$ward/<layer>/snps/fev_formality"
run_area:
  pattern: "$ward/run/$build_name/$tech/$flow/$sub_flow"
  flows:   [fev_conformal, fev_formality]
```

## Inputs

- `intent` — one of: `find_source`, `find_run_artifact`, `who_overrides`, `build_run_path`.
- Plus the relevant parameters: `flow`, `layer`, `build_name`, `tech`, `sub_flow`, `filename`,
  `design_class`, `project`.

## Procedure — `find_source`

1. Require `flow` and `filename`. Ask if missing.
2. Iterate layers **user → project → design_class → tech → global** substituting into the source
   root pattern.
3. Print all candidate absolute paths.
4. If the workspace is the ward, run a quick existence check via `runCommands` (`Test-Path` /
   `Get-ChildItem`) and mark the first existing path as the **winning layer**.
5. Stop at the first existing layer (override semantics) — but still print lower-priority paths
   commented out, for transparency.

## Procedure — `who_overrides`

Given a `filename`, list **all** layers that contain that file (even those shadowed). This is the
debug view — useful when an unexpected version is winning.

## Procedure — `build_run_path`

Render `$ward/run/$build_name/$tech/$flow/$sub_flow`. Then list the artifact files expected in that
directory using `run_area.artifacts:` from the YAML. Mark which exist.

## Output template

```
Intent: <intent>
Inputs: flow=<…> tech=<…> build=<…> sub_flow=<…> file=<…>

Candidate paths (most-specific first):
  [ ✓ ] $ward/user/cdns/fev_conformal/<file>         ← winning
  [   ] $ward/project/cdns/fev_conformal/<file>
  [   ] $ward/design_class/cdns/fev_conformal/<file>
  [   ] $ward/tech/cdns/fev_conformal/<file>
  [   ] $ward/global/cdns/fev_conformal/<file>

Run-area (if applicable):
  $ward/run/<build>/<tech>/fev_conformal/<sub_flow>/
    [ ? ] dofile         → <name from yaml>
    [ ? ] setup          → …
    [ ? ] compare.rpt    → …
    [ ? ] cmp.log        → …
```

## Asking before guessing

If `tech`, `design_class`, `project`, `sub_flow`, or `build_name` are unknown, **ask**. Add learned
terms to `config/ward-paths.yaml → terminology:` and confirm with the user.
