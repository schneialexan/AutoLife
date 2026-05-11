---
name: plan
description: Turn a goal into an execution-ready, scoped implementation plan with risks, dependencies, and acceptance criteria.
---

# /plan

Use this skill when the user needs a clear implementation plan before coding.

## When to use
- New feature spans multiple files/modules
- Requirements are ambiguous
- There are architecture tradeoffs
- User wants effort/risk clarity before build

## Mode + model
- Default: **Plan + Model Depeding on User-Needs**
- If scope is tiny and obvious: **Plan + Auto**

## Inputs required
- Goal
- In-scope vs out-of-scope
- Constraints (stack, deadlines, security/perf)
- Acceptance criteria
- Any known blockers/dependencies

If missing, ask 1-2 focused questions only.

## Planning workflow

### 1) Scope lock
- Restate objective in plain language
- List explicit exclusions to prevent scope creep

### 2) Dependency map
- Identify prerequisite tasks and ordering
- Surface external dependencies (APIs, infra, approvals)

### 3) Implementation steps
- Produce an ordered checklist
- Keep each step independently testable/reviewable

### 4) Risk + mitigation
- List top 3-5 risks
- Pair each risk with a concrete mitigation

### 5) Definition of Done
- Convert acceptance criteria into measurable checks

## Output format (always)
- Objective
- Scope (in/out)
- Ordered plan steps
- Risks and mitigations
- Definition of Done checklist
- **Next Step** (see mandatory section below)

---

## Next Step (MANDATORY — always include at end of output)

Every plan output MUST end with a `## Next Step` block containing all three fields below. Choose values by matching the situation to the guidance table.

### Format

```
## Next Step

**Mode:** <Agent | Plan | Ask | Debug | Multitask>
**Model:** <Auto | Premium | Sonnet | Opus 4.6 | GPT-5 | Gemini 3.1 Pro | DeepSeek R1 | Local>
**Skill:** <plan | implement | debug | none>
**Prompt (ready to paste):**

> <one-shot prompt the user can copy-paste into the next chat turn>
```

### Decision guide

| Situation after planning | Mode | Model | Skill |
|---|---|---|---|
| Plan is approved, ready to build | Agent | Auto | `implement` |
| Plan is approved, work is parallelisable with low file overlap | Multitask | Auto | `implement` |
| Plan has open architecture/tradeoff questions | Ask | Opus 4.6 | none |
| Plan needs further breakdown (sub-milestones) | Plan | Opus 4.6 | `plan` |
| Existing failures need fixing before plan can proceed | Debug | Auto (escalate to Opus 4.6 if stuck) | `debug` |

### Model selection reference

| Model | When to pick |
|---|---|
| **Auto** | Default; choose if no strong reason to override |
| **Premium** | Default “best available” tier when quality matters and latency/cost are acceptable |
| **Sonnet** | Fast iteration, simple edits, well-scoped changes |
| **Opus 4.6** | Complex reasoning, architecture decisions, ambiguous requirements |
| **GPT-5** | Strong at structured plans, refactors, and tooling-heavy work; pick for broad codebase changes |
| **Gemini 3.1 Pro** | Strong at long-context synthesis and multi-doc reasoning; pick for large specs/plans and cross-file understanding |
| **DeepSeek R1** | Strong at step-by-step reasoning with explicit constraints; pick for tricky logic/planning when you want thoroughness |
| **Local** | Offline/private contexts; pick when external model use is constrained |

### Prompt rules
- The prompt must be self-contained (no "see above" references).
- Include the goal, scope, and acceptance criteria from the plan.
- If a skill applies, start the prompt with the skill's trigger phrase (e.g. "Implement:" for `/implement`, "Debug this issue end-to-end." for `/debug`).
- Reference specific files/modules from the plan when possible.

## Prompt template

Plan this work only (no implementation yet):

Goal:
- [target outcome]

In scope:
- [items]

Out of scope:
- [items]

Constraints:
- [technical/business constraints]

Acceptance criteria:
- [ ] [criterion 1]
- [ ] [criterion 2]

Return:
- Ordered implementation plan
- Risks/dependencies
- Definition of Done checklist
- **Next Step with mode, model, skill, and ready-to-paste prompt**
