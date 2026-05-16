<!-- markdownlint-disable -->
# Agent Engineering 101 — a 20-minute tour

> Speaker notes are in `> blockquotes`. Each `---` is a slide break.
> Running example: **teach Copilot to read & triage a FEV log**.

---

## Slide 1 — Why are we here?

You've used Copilot Chat. It's smart, but:

- It doesn't know what `fev_rtl2syn` means.
- It re-asks the same questions every session.
- It hallucinates paths because it has never seen our ward layout.

**Agent engineering** = teaching Copilot your domain *once*, in files that live next to your code, so every engineer on the team gets the same expert behavior.

> Goal of this talk: by the end, you can build a mini FEV log-triage agent from scratch. We'll skip Intel-specific deployment — that's in the handbook.

---

## Slide 2 — What you'll walk away with

1. The **five files** that make an agent (and what each is for).
2. The **folder layout** Copilot expects.
3. How the files **interlink** — why splitting matters.
4. A working mini-agent: `fev-log-mini` — parses a Conformal/Formality log.
5. The most common **good-way vs bad-way** mistakes.

---

## Slide 3 — Mental model: 5 primitives

| Primitive | File | Job | Loaded when |
|---|---|---|---|
| **Instructions** | `*.instructions.md` | Always-on domain primer | Every turn (if `applyTo` matches) |
| **Skill** | `SKILL.md` | A reusable *procedure* | Model auto-loads by description match |
| **Agent** | `*.agent.md` | A persona with tools + a role | User picks it, or master delegates |
| **Sub-agent** | `*.agent.md` with `user-invocable: false` | A specialist the master calls | Master invokes via `runSubagent` |
| **Prompt** | `*.prompt.md` | A one-click user-facing recipe | User types `/promptname` |

> One sentence each: *instructions teach, skills do, agents are personas, prompts are shortcuts.*

---

## Slide 4 — The folder layout

```
.github/
├── copilot-instructions.md      # base layer, always on
├── instructions/                # auto-attached primers (by applyTo)
│   └── fev-domain.instructions.md
├── skills/                      # reusable procedures
│   └── fev-log-analysis/
│       └── SKILL.md
├── agents/                      # personas
│   ├── fev-lead.agent.md        # the master (user-invocable)
│   └── log-analyzer.agent.md    # a sub-agent
├── prompts/                     # one-click recipes
│   └── analyze-fev-log.prompt.md
└── config/                      # data your agents read
    └── log-signatures.yaml
```

> Copilot only auto-discovers files under `.github/`. Anything else, you must point to.

---

## Slide 5 — Running example: "Parse this FEV log"

A FEV engineer pastes:

```
Comparing... compare points = 1234
Non-equivalent points = 7
ERROR: abort in flatten_model
```

Without an agent, Copilot says: *"It looks like there's an error."*
With an agent, it says:

> Conformal run, hit `flatten_model` abort after detecting 7 non-equivalent points.
> Likely cause: missing UPF or guidance file. Check `ivar($task,guidance_file_path)`
> in your ward's `vars.tcl`. See `reports/compare.rpt` line N for the 7 mismatches.

That difference = **5 small files** working together. Let's build them.

---

## Slide 6 — File #1: the instruction file (the *primer*)

Path: `.github/instructions/fev-domain.instructions.md`

```markdown
---
applyTo: '**'
description: 'FEV vocabulary — always loaded.'
---

# FEV domain primer

- Conformal LEC log → `logs/lec.log`. Formality log → `logs/fm.log`.
- Run-area pattern: `$ward/runs/$block/$tech/$flow/$task`
- "Non-equivalent" = a compare point where golden ≠ revised.
- "Abort" = tool gave up. Always look at the line *before* the abort.
- iVAR `ivar($task,guidance_file_path)` = vsdc (Conformal) or SVF (Formality).
```

**Purpose**: this is always in context. Copilot now *knows what we mean* by `lec.log`, `abort`, `iVAR` — without us re-explaining.

> Rule of thumb: short, dense facts. Not tutorials.

---

## Slide 7 — Good vs bad: instruction files

| ✅ Good | ❌ Bad |
|---|---|
| 50 lines of dense domain vocab + 5–10 hard rules. | 800-line essay copy-pasted from the wiki. |
| `applyTo: '**'` for true global facts. | `applyTo: '**'` for project-specific stuff (bloats every turn). |
| Names the canonical paths (`logs/lec.log`). | Vague: "logs are usually somewhere in the build dir." |
| One file per topic (`fev-domain`, `ward-layout`, `mcp-usage`). | One mega-file mixing 6 topics. |

**Why it matters**: instructions are loaded *every turn*. Bloat = slower, dumber answers.

---

## Slide 8 — File #2: the skill (a reusable *procedure*)

Path: `.github/skills/fev-log-analysis/SKILL.md`

```markdown
---
name: fev-log-analysis
description: Parse Conformal/Formality logs, build a timeline,
             find first abort, correlate to reports.
---

# Skill: fev-log-analysis

## When to use
- "Analyze this lec.log."
- "Why did Formality abort?"

## Inputs
- `log_path` (required) or pasted log excerpt.

## Procedure
1. Detect tool from header (Conformal banner vs Formality banner).
2. Match each line against signatures in `config/log-signatures.yaml`.
3. Build a milestone timeline (line numbers).
4. Find the first ERROR / abort; show ±10 lines.
5. Suggest the next move (check iVAR, search HSD, etc.).
```

**Purpose**: any agent that has the right tools can auto-invoke this. Copilot picks it because the `description:` matches the user's question.

> The description is a search key. Write it like an index entry, not marketing.

---

## Slide 9 — Good vs bad: skills

| ✅ Good | ❌ Bad |
|---|---|
| Description names the **trigger phrases**: "parse log", "find abort". | Description says "helps with FEV stuff." |
| Numbered procedure — deterministic steps. | Vague: "use your judgment to analyze the log." |
| Points to **data files** (`log-signatures.yaml`) so the catalog can grow without editing the skill. | Hardcodes 200 regexes inline. |
| One skill = one job. | One skill that "parses logs, opens HSDs, writes BKMs". |

**Why it matters**: skills are *auto-discovered by description match*. Bad descriptions = your skill never fires.

---

## Slide 10 — File #3: the master agent

Path: `.github/agents/fev-lead.agent.md`

```markdown
---
description: 'FEV-Lead — entry point for FEV triage. Routes to specialists.'
tools: [read/readFile, search/codebase, agent/runSubagent]
agents: [log-analyzer]      # allow-list of sub-agents
user-invocable: true
---

# FEV-Lead

You are the entry point. On the first turn, greet and list capabilities.
On every turn:
1. Classify the user's intent.
2. Announce which sub-agent will handle it.
3. Call `runSubagent(name="log-analyzer", prompt="<scoped task>")`.
4. Cite results.

## Available sub-agents
- `log-analyzer` — when user says "log / abort / non-equivalent / failure".
```

**Purpose**: the one visible persona. It does no real work — it **routes**.

---

## Slide 11 — File #4: the sub-agent

Path: `.github/agents/log-analyzer.agent.md`

```markdown
---
description: 'Log-Analyzer — parses lec.log / fm.log. Triggers: "log", "abort", "non-equivalent", "ERROR".'
tools: [read/readFile, search/textSearch, search/fileSearch]
user-invocable: false
---

# Log-Analyzer

You analyze FEV logs using the `fev-log-analysis` skill.

## Output contract
TOOL:        conformal | formality
TIMELINE:    <line numbered milestones>
FIRST_FAIL:  <line N + ±10 context>
NEXT_STEP:   <suggested action>
```

**Purpose**: narrow specialist. `user-invocable: false` means it never shows up in the chat picker — only `FEV-Lead` can call it.

> Sub-agents are **stateless**. One prompt in, one structured answer out. Design accordingly.

---

## Slide 12 — Good vs bad: agents

| ✅ Good | ❌ Bad |
|---|---|
| Master = router with 1–2 tools. Sub-agents = specialists with focused tool sets. | One mega-agent with every tool, doing everything. |
| Sub-agent `description:` reads like a **trigger list**. | Sub-agent description is generic ("a helpful assistant for FEV"). |
| Master has an `agents:` allow-list. | Master can call anything — including agents from other projects. |
| Output contract is explicit (`TOOL:`, `TIMELINE:`...). | Free-form prose output that breaks downstream parsing. |

**The trap**: giving an agent *too many tools* is worse than too few. Pick the minimum.

---

## Slide 13 — File #5: the prompt (one-click recipe)

Path: `.github/prompts/analyze-fev-log.prompt.md`

```markdown
---
mode: agent
description: 'Analyze a FEV log: timeline + first failure + next step.'
---

Log: **${input:log_path_or_excerpt}**

Invoke `FEV-Lead` and ask it to analyze the log above using the
`fev-log-analysis` skill. Render:
- timeline
- first failure block (±10 lines)
- one suggested next step
```

**Purpose**: the user types `/analyze-fev-log`, gets prompted for a log path, and the whole machinery fires. Bookmark-able workflow.

> Prompts are *user-facing*. Sub-agents cannot run prompts. If you want a reusable script for a sub-agent, make it a **skill**.

---

## Slide 14 — How they interlink

```
User types /analyze-fev-log
        │
        ▼
┌─────────────────────────┐
│  analyze-fev-log.prompt │  (the recipe)
└──────────┬──────────────┘
           │ "invoke FEV-Lead"
           ▼
┌─────────────────────────┐
│  FEV-Lead (agent)       │  (the router)
└──────────┬──────────────┘
           │ runSubagent("log-analyzer", ...)
           ▼
┌─────────────────────────┐
│  Log-Analyzer (sub)     │  (the specialist)
└──────────┬──────────────┘
           │ auto-loads
           ▼
┌─────────────────────────┐    reads
│  fev-log-analysis SKILL │ ───────► config/log-signatures.yaml
└─────────────────────────┘

ALWAYS in context (every turn):
   fev-domain.instructions.md   (the primer)
```

**Key insight**: each file does ONE thing. They compose via descriptions, not imports.

---

## Slide 15 — Discovery: how Copilot finds your stuff

| File | How it gets loaded |
|---|---|
| `copilot-instructions.md` | Always, no matching needed. |
| `*.instructions.md` | Auto-attached if `applyTo` glob matches the open file. |
| `SKILL.md` | Model picks it when its `description` matches the user's task. |
| `*.agent.md` (user-invocable) | User picks from chat agent menu. |
| `*.agent.md` (sub-agent) | Master agent calls it by name via `runSubagent`. |
| `*.prompt.md` | User types `/promptname`. |
| `config/*.yaml` | Only loaded when an agent/skill explicitly reads the file. |

> Mental rule: **descriptions are the API**. They're how Copilot decides what to load.

---

## Slide 16 — The two killer mistakes

### Mistake A: **Overfitting**

You write a 500-line agent that knows your exact ward, your exact block, your exact tag.
→ Anyone else on the team can't use it. You've built a script, not an agent.

**Fix**: parameterize via inputs and config files. Keep the agent generic; put project-specific data in `config/`.

### Mistake B: **Underfitting**

Your agent says: *"You are a helpful FEV assistant. Help the user."*
→ It does nothing the base Copilot wouldn't already do.

**Fix**: hard rules, concrete vocabulary, explicit output contracts. Tell it what NOT to do, not just what to do.

> Both mistakes look like "the agent doesn't work". Diagnose by reading the agent's body aloud — would *you* know what to do?

---

## Slide 17 — Good vs bad: prompts

| ✅ Good | ❌ Bad |
|---|---|
| One job: "analyze this log". Asks for the inputs it needs. | "Do all FEV things." |
| Delegates to an agent, doesn't redo its work. | Re-implements the skill inline. |
| Names the agent + skill it expects. | Hopes Copilot guesses. |

---

## Slide 18 — Build it live (10 minutes)

In your repo:

```bash
mkdir -p .github/{instructions,skills/fev-log-mini,agents,prompts,config}
```

Then create these 5 files (copy from slides 6, 8, 10, 11, 13).

Smoke tests:

1. Open chat → pick **FEV-Lead** → ask "what can you do?"
   → It should greet and list `log-analyzer`.
2. Paste a fake log with `ERROR: abort` → it should route to `Log-Analyzer` and produce a timeline.
3. Type `/analyze-fev-log` → it should prompt for a path.

If any smoke test fails, the **description** of the relevant file is your prime suspect.

---

## Slide 19 — Why this matters in FEV specifically

FEV is a **vocabulary-heavy** domain. Words like:

- `non-equivalent`, `abort`, `compare point`, `flatten_model`
- `lec.log`, `fm.log`, `vsdc`, `svf`
- `ivar`, `hook file`, `run-area`, `override layer`

…carry exact meaning to us, but nothing to vanilla Copilot. An instruction file of **30 lines** changes Copilot from a generalist into a teammate. That's the whole pitch.

> Every domain has its own vocabulary. The first agent you build for any new domain should always be an `instructions.md`.

---

## Slide 20 — Recap

You now know:

- The **5 primitives** (instruction, skill, agent, sub-agent, prompt) and the job each one does.
- The **`.github/` folder layout** Copilot auto-discovers.
- How they **interlink via descriptions**, not imports.
- The two failure modes: **overfit** (too narrow) and **underfit** (too vague).
- A working pattern: **prompt → master agent → sub-agent → skill → config data**.

### Your homework

1. Pick one pain you hit this week (a log, a script, a report).
2. Write a 30-line `*.instructions.md` for it.
3. Add ONE skill that does the recurring task.
4. Ship it as a PR. Iterate from there.

Questions?
