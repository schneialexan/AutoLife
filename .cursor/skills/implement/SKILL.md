---
name: implement
description: Plan and execute a milestone with the right Cursor mode/model, then verify and report.
---

# /implement

Use this skill when the user wants to build a feature/milestone end-to-end with minimal back-and-forth.

## Inputs to collect first
- Goal (what should exist when done)
- Scope (files/modules in, files/modules out)
- Constraints (stack, performance, security, deadlines)
- Acceptance criteria (tests, lint, behavior checks)

If any of the above is missing, ask 1-2 focused questions.

## Mode + model routing

1. **Plan + Opus 4.6**
   - Use first for ambiguous, large, or multi-module work.
   - Produce a short step-by-step implementation plan with risks/dependencies.

2. **Agent + Auto**
   - Use for most implementation steps.
   - Make incremental edits, run validations, and keep changes scoped.

3. **Multitask + Auto**
   - Use only when work is parallelizable with low file overlap.
   - Split into isolated tracks and report merge/conflict risks.

4. **Debug + Auto (escalate to Opus 4.6 if stuck)**
   - Use for failing builds/tests/runtime issues.
   - Return root cause, minimal fix, and verification.

5. **Ask + Opus 4.6**
   - Use for architecture/tradeoff questions without editing.

## Execution workflow

### Phase 1 - Align
- Restate goal and scope in 3-6 bullets.
- Confirm exclusions explicitly.

### Phase 2 - Plan
- List ordered steps with checkpoints.
- Note dependencies and risk items.
- Define Definition of Done (DoD).

### Phase 3 - Implement
- Execute one checkpoint at a time.
- Prefer small, reviewable changes.
- Do not expand scope without confirmation.

### Phase 4 - Verify
- Run lint/tests/build checks relevant to changed areas.
- Validate acceptance criteria explicitly.

### Phase 5 - Report
- Summarize:
  - What changed
  - Why
  - Validation results
  - Remaining risks/follow-ups

## Output contract (always)
- Scope completed: [yes/no]
- Acceptance criteria: checklist
- Files touched: short list
- Validation: commands + outcomes
- **Next Step** (see mandatory section below)

---

## Next Step (MANDATORY — always include at end of output)

Every implementation output MUST end with a `## Next Step` block containing all fields below. Choose values by matching the situation to the guidance table.

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

| Situation after implementation | Mode | Model | Skill |
|---|---|---|---|
| More steps remain in the plan | Agent | Auto | `implement` |
| Remaining steps are parallelisable, low file overlap | Multitask | Auto | `implement` |
| Build/test/lint failures appeared | Debug | Auto (escalate to Opus 4.6 if stuck) | `debug` |
| Milestone done, next milestone needs planning | Plan | Opus 4.6 | `plan` |
| Milestone done, architecture question before next work | Ask | Opus 4.6 | none |
| All milestones done, nothing left | — | — | none (say "Done!") |

### Model selection reference

| Model | When to pick |
|---|---|
| **Auto** | Default; choose if no strong reason to override |
| **Premium** | Default “best available” tier when quality matters and latency/cost are acceptable |
| **Sonnet** | Fast iteration, simple edits, well-scoped changes |
| **Opus 4.6** | Complex reasoning, architecture decisions, ambiguous requirements |
| **GPT-5** | Strong at structured changes across many files and reliable code generation; pick for refactors/features |
| **Gemini 3.1 Pro** | Strong at long-context codebases; pick when many files/spec docs must be kept consistent |
| **DeepSeek R1** | Strong at careful reasoning and edge cases; pick for tricky logic and correctness-heavy changes |
| **Local** | Offline/private contexts; pick when external model use is constrained |

### Prompt rules
- The prompt must be self-contained (no "see above" references).
- Include the remaining goal, scope, and acceptance criteria.
- If a skill applies, start the prompt with the skill's trigger phrase (e.g. "Implement:" for `/implement`, "Debug this issue end-to-end." for `/debug`, "Plan this work only:" for `/plan`).
- Reference specific files/modules touched or to-be-touched.

## Prompt template (reuse)

Implement: [milestone/feature name]

Scope:
- [included]
- [included]
- Exclude: [excluded]

Requirements:
- [functional]
- [non-functional]

Acceptance criteria:
- [ ] tests updated/passing
- [ ] lint passes
- [ ] no regressions in [area]
- [ ] concise change summary

If uncertain, ask before coding.
Return a **Next Step with mode, model, skill, and ready-to-paste prompt** at the end.
