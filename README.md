# FEV Agent — Capabilities Expo

> A multi-agent VS Code Copilot assistant for Intel **FEV (Formal Equivalence Verification)** in
> the **Cheetah (CTH) TFM** — Cadence Conformal, Synopsys Formality, InspectFEV / Greenstone audit,
> HSDES tickets, and the cheetah Confluence wiki — wired together so an engineer never has to
> context-switch between MCP, wiki, ward, log, and ticket.

---

## TL;DR — what you actually get

- **A welcome face.** Start a chat with `@FEV-Lead` and you'll see a mascot, a 7-item menu, and an
  open invitation to ask anything FEV / CTH / Cheetah2 related.
- **6 specialist agents** that talk to each other.
- **6 reusable skills** wired into those agents.
- **2 MCPs** integrated proactively: Intel **HSDES** (62 tools + 6 bundled AI skills) and the
  **wiki-jira** Confluence/Jira MCP.
- **~60 cheetah-space FEV wiki pages** indexed by page ID with a documented refresh procedure.
- **Pluggable YAML configs** — add an MCP, a page, a task, a log signature, a hook file
  *without touching any agent code*.
- **One pair-debug persona** that fuses a senior FEV engineer with a devil's advocate to
  pressure-test every hypothesis you bring.

---

## 1 · Meet the cast

```
                                ┌────────────────┐
                                │   FEV-Lead     │   Orchestrator + welcome face
                                │ (routes work)  │
                                └────────┬───────┘
                                         │
        ┌────────────────┬───────────────┼───────────────┬────────────────┐
        ▼                ▼               ▼               ▼                ▼
┌──────────────┐ ┌────────────────┐ ┌───────────┐ ┌──────────────┐ ┌──────────────────┐
│ HSD-Analyst  │ │ Jira-Wiki-     │ │ Ward-     │ │ Log-Analyzer │ │ FEV-CoEngineer   │
│              │ │ Researcher     │ │ Explorer  │ │              │ │  🧠 Senior +     │
│ HSDES MCP    │ │ wiki-jira MCP  │ │ override  │ │ lec.log /    │ │  😈 Devil's Adv. │
│ 62 tools     │ │ cheetah space  │ │ stack +   │ │ fm.log +     │ │  pair-debug      │
│ 6 AI skills  │ │ ~60 pages      │ │ iVARs +   │ │ InspectFEV   │ │  persona         │
│              │ │ indexed        │ │ hooks     │ │ correlation  │ │                  │
└──────────────┘ └────────────────┘ └───────────┘ └──────────────┘ └──────────────────┘
```

| Agent | One-liner | Lives at |
|-------|-----------|----------|
| `FEV-Lead` | Routes intent to the right specialist; emits the welcome screen on turn 1. | [agents/fev-lead.agent.md](agents/fev-lead.agent.md) |
| `HSD-Analyst` | Fetch, summarize, find-similar, and triage Intel HSDES tickets. Delegates to HSDES MCP's bundled AI skills. | [agents/hsd-analyst.agent.md](agents/hsd-analyst.agent.md) |
| `Jira-Wiki-Researcher` | Confluence + Jira specialist. Knows the FEV wiki tree by page ID. | [agents/jira-wiki-researcher.agent.md](agents/jira-wiki-researcher.agent.md) |
| `Ward-Explorer` | Resolves "which file wins?" across user > project > addon > tech > global. iVAR + hook aware. | [agents/ward-explorer.agent.md](agents/ward-explorer.agent.md) |
| `Log-Analyzer` | Parses Conformal `lec.log` / Formality `fm.log` + correlates to `reports/` and `IF_<block>_<task>/`. | [agents/log-analyzer.agent.md](agents/log-analyzer.agent.md) |
| `FEV-CoEngineer` | Pair-debug persona: senior FEV engineer + devil's advocate, on every reply. | [agents/fev-coengineer.agent.md](agents/fev-coengineer.agent.md) |

---

## 2 · What FEV-Lead can do — the menu

When you open a chat with `@FEV-Lead` you get this welcome (excerpt):

```
╭──────────────────────────────────────────────────────────────────────────────╮
│  (•_•)   FEV-Lead at your service                                            │
│ <)   )╯  CTH FEV assistant — Conformal · Formality · InspectFEV · HSDES      │
│  /   \                                                                       │
╰──────────────────────────────────────────────────────────────────────────────╯
```

Common things it's asked (jump-starts, **not limits**):

| # | Capability | Example prompt |
|---|------------|----------------|
| 1 | 🎫 Summarize an HSDES ticket and its repro / resolution | `summarize HSD 14012345678` |
| 2 | 🔁 Find HSDs similar to yours and aggregate proposed fixes | `find HSDs similar to 14012345678` |
| 3 | 📚 Look up FEV BKMs / INotes / training | `BKM for SVF guidance mismatch` |
| 4 | 🗂️ Resolve "which file wins?" across the override stack | `where does vars.tcl come from in $ward?` |
| 5 | 📋 Triage `lec.log` / `fm.log` + InspectFEV outputs | `analyze logs in $ward/runs/b001/p1278/fev_conformal/fev_rtl2syn` |
| 6 | 🧠😈 Pair-debug mode (senior FEV + devil's advocate) | `debug with me — non-equiv on regfile after RTL change` |
| 7 | 🧭 Show MCP capabilities (62 HSDES tools, 12 wiki tools, 6 AI skills) | `capabilities` |

…and the welcome explicitly invites off-menu questions: methodology, weird errors, half-formed
theories, hook-file review, UPF / CLP confusion, feedthrough cross-checks, sim2syn oddities, ECO
triage, waiver strategy — all fair game.

---

## 3 · The two MCPs, surfaced proactively

Every sub-agent emits a one-line capability banner on its first turn. The pluggable source of
truth is [config/mcp-registry.yaml](config/mcp-registry.yaml).

### HSDES MCP

- **62 tools**, prefix `mcp_hsdes_*`.
- Ships **6 bundled AI skills** (install with `hsdes-mcp publish-skills`):
  `hsdes-orchestrator`, `hsdes-issue-investigator`, `hsdes-issue-manager`,
  `hsdes-debug-orchestrator`, `hsdes-quality-scorer`, `hsdes-query-eql`.
- `HSD-Analyst` **delegates** to these bundled skills rather than reimplementing them.
- Canonical example prompts (verbatim from the wiki):
  - `Summarize HSDES ticket 14012345678`
  - `Find tickets similar to 14012345678`
  - `Analyze ticket 14012345678 for root cause`
  - `Score the quality of ticket 14012345678`
  - `Find all open sightings owned by <idsid>`
  - `Run HSDES query 16012345678`

### wiki-jira MCP

- **12 verified Confluence tools**, prefix `mcp_wiki-jira-mcp_*`:
  `confluence_search` · `get_page` · `get_page_children` · `get_space_page_tree` ·
  `get_comments` · `get_page_history` / `get_page_diff` · attachments × 4 · `get_labels`.
- Default workspace spaces are non-FEV (`oksdebug, fvcommon, SIPGSLD, XPIVSHCoVal`) — for FEV
  the agents **always add `cheetah`**. Say *"search all spaces"* to widen.

---

## 4 · The FEV wiki, pre-indexed (~60 pages)

[config/knowledge-base.yaml](config/knowledge-base.yaml) stores the live wiki structure so agents
hit a page directly instead of guessing search terms.

| Section | Contents |
|---------|----------|
| `curated_pages:` | ~30 tagged entries (root pages, BKMs, ECO, paranoia, debug, audit, sub-flows, training, releases). |
| `fev_root_tree:` | All 9 direct children of FEV root (page `2288898439`) with `last_seen_version` + `last_updated`. |
| `fev_conformal_subtree:` | All 15 children of FEV_CONFORMAL (`2376013930`). |
| `fev_formality_subtree:` | All 7 children of FEV_FORMALITY (`2376013928`). |
| `cheetah2_pages:` | 16 Cheetah2 platform pages (R2G flow, yearly Test Waivers 2020→2026, integration cycles, deployment, BKM/FAQs). |
| `highly_ranked:` | Top-20 entry points ranked with "why" rationale. |
| `maintenance:` | Refresh procedure (run `confluence_get_page_children`, bump versions, append new children). |

Add a page → it's appended to `curated_pages` (and the matching subtree). No agent change.

---

## 5 · The ward, demystified

[config/ward-paths.yaml](config/ward-paths.yaml) encodes everything the agent needs to navigate a
CTH ward — sourced from the Cheetah FEV wiki, not assumptions.

```
$ward/<layer>/cdns/fev_conformal      # Conformal source (templates, procs, vars.tcl)
$ward/<layer>/snps/fev_formality      # Formality source
$ward/runs/$block/$tech/$flow/$task   # Run-area (note plural `runs`)
$ward/global/intel/inspect_fev/inspectFEV.tcl
```

| What it captures | Why it matters |
|------------------|----------------|
| Override layers `user > project > addon > tech > global` | `Ward-Explorer` walks this stack instead of `Get-ChildItem -Recurse` |
| 17 Conformal tasks + 12 Formality tasks (by name) | Agents recognize `fev_rtl2syn`, `fev_fm_rtl2rtl`, `eco`, … without asking |
| Full iVAR cheat-sheet | `ivar($task,rtl_list_golden)`, `ivar($task,$ivar(design_name),black_box)`, `ivar(bscript_dir)`, … |
| 8 Conformal + 7 Formality hook files | Agents propose hooks instead of editing `default_procs.tcl` |
| Shell flags for `Ifev_shell`/`Ieco_shell`/`Ifev_fm_shell`/`Ieco_fm_shell` | Suggestions stay runnable |
| InspectFEV output layout (`IF_<block>_<task>/results/...`) | `Log-Analyzer` correlates pre-/post-waiver verdicts |
| Release-collateral paths | Cross-tag promotion is unambiguous |

---

## 6 · Log triage built in

[config/log-signatures.yaml](config/log-signatures.yaml) — extensible catalog of milestones and
errors with correlations.

- **Conformal `logs/lec.log`** — 10 milestones (setup → lib → golden → revised → upf → modeling →
  mapping → compare_started → compare_done → hier_compare_done), 7 error classes (non_equiv,
  unmapped, abort, not_compared, blackbox_missing, lib_missing, parse_error).
- **Formality `logs/fm.log`** — 8 milestones (setup, lib, ref, impl, upf, svf, match, verify),
  6 error classes (failed_points, unmatched, aborted_points, blackbox_missing, parse_error,
  lib_missing).
- **InspectFEV** — `results/InspectFEV_SUMMARY.rpt` (pre-waiver), `results/Greenstone_summary.rpt`
  (post-waiver), `outputs/violation_rpts/`, indicator stats, violations XML.
- `Log-Analyzer` proposes new signatures back into the catalog whenever it spots an unknown
  important line — **paste-ready YAML** in every triage output.

Triage produces a fixed structure: timeline → errors with verbatim excerpts → InspectFEV verdict
→ ranked hypotheses → next probe → new-signature candidates.

---

## 7 · The pair-debug persona

[agents/fev-coengineer.agent.md](agents/fev-coengineer.agent.md) — invoked automatically on words
like *debug, why, root cause, regression*, on pasted logs, or on stated beliefs.

Every reply holds two personas simultaneously:

- **🧠 Senior FEV Engineer** — pattern-matches symptom to root cause, cites a log line / iVAR /
  hook / BKM page ID / HSD for every claim.
- **😈 Devil's Advocate** — argues *against* the leading hypothesis at least once per turn, asks
  "what would falsify this?", names alternatives.

Plus a **🔗 Hidden relationships** section that forces both user and LLM to look for correlations
being missed (e.g., *"non-equiv on retiming-candidate flops AND recent SVF change — same cause?"*).

Closes with a single, decision-changing follow-up question — never a multiple-choice barrage.

Hands back to `FEV-Lead` with a `✅ Resolution proposal` (root cause / fix / blast radius /
verify / document) once the Devil's tests converge.

---

## 8 · Skills — the composable pieces

| Skill | What it does |
|-------|--------------|
| [hsd-fetch-summarize](skills/hsd-fetch-summarize/SKILL.md) | Pull an HSD and produce a structured summary with FEV signals extracted. |
| [hsd-similar-issues](skills/hsd-similar-issues/SKILL.md) | 2–3 progressively broader HSDES searches; rank top-5 by signal overlap; aggregate fixes. |
| [jira-wiki-bkm-lookup](skills/jira-wiki-bkm-lookup/SKILL.md) | 2-phrasing Confluence search scoped to `cheetah`; cite page title + URL + page ID. |
| [fev-ward-context](skills/fev-ward-context/SKILL.md) | Walk the 5-layer override stack for a file; show all candidates, mark the winner. |
| [fev-log-analysis](skills/fev-log-analysis/SKILL.md) | Match log lines against `log-signatures.yaml`; emit timeline + hypotheses + new-signature YAML. |
| [mcp-discovery](skills/mcp-discovery/SKILL.md) | Render the live MCP capability banner. |

---

## 9 · Slash-style prompts

Quick entry points under [prompts/](prompts/) — `mode: agent` Copilot prompts:

- [summarize-hsd.prompt.md](prompts/summarize-hsd.prompt.md)
- [find-similar-hsds.prompt.md](prompts/find-similar-hsds.prompt.md)
- [lookup-fev-bkm.prompt.md](prompts/lookup-fev-bkm.prompt.md)
- [explore-ward.prompt.md](prompts/explore-ward.prompt.md)
- [analyze-fev-log.prompt.md](prompts/analyze-fev-log.prompt.md)
- [mcp-capabilities.prompt.md](prompts/mcp-capabilities.prompt.md)

---

## 10 · Auto-applied instructions

Three `.instructions.md` files with `applyTo: '**'` give every chat in this workspace the FEV
context without you typing anything:

- [instructions/fev-domain.instructions.md](instructions/fev-domain.instructions.md) — domain
  primer: tools, flows, override layers, run-area, iVARs, hook files, audit, hard rules.
- [instructions/ward-layout.instructions.md](instructions/ward-layout.instructions.md) — override
  resolution algorithm + run-area resolution + "what to ask before guessing."
- [instructions/mcp-usage.instructions.md](instructions/mcp-usage.instructions.md) — real MCP
  tool prefixes, proactivity rule, citation rules, default scope = `cheetah`.

---

## 11 · Bootstrap scripts

| Script | Purpose |
|--------|---------|
| [scripts/discover-ward.ps1](scripts/discover-ward.ps1) | JSON map of which override layers exist and which `runs/<block>/<tech>/<flow>/<task>` paths have content. |
| [scripts/collect-fev-logs.ps1](scripts/collect-fev-logs.ps1) | Bundle `logs/lec.log` or `logs/fm.log` + `reports/` + `scripts/` for a given run-area for offline analysis. |

Both honor the verified `$ward/runs/$block/$tech/$flow/$task` pattern.

---

## 12 · Try it — 60-second tour

In a VS Code chat in this workspace:

```text
@FEV-Lead                                   # see the welcome face + menu

@FEV-Lead capabilities                      # full MCP toolbelt

@FEV-Lead summarize HSD 14012345678         # HSD-Analyst → HSDES MCP

@FEV-Lead BKM for SVF guidance mismatch     # Jira-Wiki-Researcher → cheetah space

@FEV-Lead where does default_procs.tcl come from in $ward?
                                            # Ward-Explorer walks the 5-layer stack

@FEV-Lead analyze logs in $ward/runs/b001/p1278/fev_conformal/fev_rtl2syn
                                            # Log-Analyzer + InspectFEV correlation

@FEV-Lead why is my non-equiv only showing on retimed flops?
                                            # Auto-routes to FEV-CoEngineer
                                            #   🧠 Senior says X · 😈 Devil challenges with Y
                                            #   🔗 Hidden relationship: retiming + SVF
                                            #   ❓ One focused question back to you
```

---

## 13 · Extending without writing code

| To add… | Edit only this YAML | Picked up by |
|---------|---------------------|--------------|
| A new MCP | `config/mcp-registry.yaml` | `mcp-discovery` skill + every sub-agent's banner |
| A new wiki page or BKM | `config/knowledge-base.yaml` → `curated_pages:` (and subtree) | `Jira-Wiki-Researcher` |
| A new FEV task | `config/ward-paths.yaml` → `run_area.tasks:` + recognized vocabulary | `Ward-Explorer`, `Log-Analyzer`, `FEV-Lead` |
| A new log signature | `config/log-signatures.yaml` | `Log-Analyzer` |
| A new hook file | `config/ward-paths.yaml` → `artifacts.hook_files:` | `Ward-Explorer` (suggests it before `default_procs.tcl`) |
| A new sub-agent | drop `agents/<name>.agent.md`, register in `agents/fev-lead.agent.md` routing table | `FEV-Lead` |
| A new skill | drop `skills/<name>/SKILL.md`, list it in the owning agent | the owning agent |

---

## 14 · House rules (every agent honors them)

1. **Cite or it didn't happen.** Confluence quotes get `Title — URL (page_id=…)`. HSDES quotes
   get `HSD-<id> — <field>`.
2. **Never full-grep the ward.** Walk the 5-layer override stack.
3. **Plural `runs/`**, `$block` not `$build_name`, `$task` not `$sub_flow`.
4. **Default Confluence scope = `cheetah`** for FEV. Widen only on "search all spaces."
5. **Propose hook files**, never edit `default_procs.tcl` / `default_fm_procs.tcl`.
6. **One disambiguation question max**, then make the best-guess call and say so.
7. **Pair-debug = both personas on every turn.** No happy-path-only answers.

---

## 15 · Layout cheat-sheet

```
fev-agent/
├── README.md                       ← you are here
├── AGENTS.md                       ← repo-level agent context (auto-loaded)
├── agents/
│   ├── fev-lead.agent.md           ← orchestrator + welcome face
│   ├── fev-coengineer.agent.md     ← 🧠 senior + 😈 devil's advocate
│   ├── hsd-analyst.agent.md
│   ├── jira-wiki-researcher.agent.md
│   ├── ward-explorer.agent.md
│   └── log-analyzer.agent.md
├── skills/<name>/SKILL.md          ← 6 composable capabilities
├── instructions/*.instructions.md  ← auto-applied (applyTo: '**')
├── prompts/*.prompt.md             ← slash-style entry points
├── config/                         ← PLUGGABLE YAML
│   ├── mcp-registry.yaml           ← HSDES + wiki-jira capabilities
│   ├── knowledge-base.yaml         ← ~60 wiki pages, subtrees, highly-ranked, maintenance
│   ├── ward-paths.yaml             ← override layers, tasks, iVARs, hooks, shells, audit
│   └── log-signatures.yaml         ← lec.log + fm.log catalogs + InspectFEV index
└── scripts/                        ← discover-ward.ps1 · collect-fev-logs.ps1
```

---

## 16 · FAQ

**Q. Do I have to install anything?**
The HSDES MCP must be installed and verified (`pip install hsdes_mcp_server-<ver>-py3-none-any.whl`
then `hsdes-mcp verify`; optionally `hsdes-mcp publish-skills` for the 6 bundled AI skills). The
wiki-jira MCP is pre-configured in this workspace.

**Q. What if a tool isn't available?**
Agents detect deferred tools and load them via `tool_search`. If an MCP is genuinely missing,
they say so and fall back (e.g., HSDES missing → Confluence-only answer).

**Q. How do I keep the wiki index fresh?**
Follow the `maintenance:` procedure in [config/knowledge-base.yaml](config/knowledge-base.yaml) —
run `confluence_get_page_children` on each subtree root, bump the `last_seen_version` fields,
append new children. The `Jira-Wiki-Researcher` prompts you whenever it sees a useful unindexed
page.

**Q. Can I run this outside VS Code Copilot?**
The agents/skills/instructions/prompts use the VS Code Copilot customization format. The
**configs and scripts** are portable.

---

**Built around verified Cheetah FEV wiki content (~60 pages, page IDs cited throughout) — no
placeholder content where wiki data exists.**
