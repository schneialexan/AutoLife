---
name: debug
description: Diagnose failures quickly, apply minimal safe fixes, and verify no regressions.
---

# /debug

Use this skill when builds, tests, runtime behavior, or CI checks fail.

## When to use
- Build/test/lint failures
- Runtime exceptions
- Regressions after recent changes
- Flaky behavior requiring root-cause analysis

## Mode + model
- Default: **Debug + Auto**
- Escalate: **Debug + Opus 4.6** if root cause is unclear after first pass

## Required inputs
- Error output/logs
- Failing command or scenario
- Expected behavior
- Recent related changes (if known)

If missing, ask for the smallest missing artifact first (usually exact error output).

## Debug workflow

### 1) Reproduce
- Confirm failure path and conditions
- Separate deterministic failures from flaky ones

### 2) Isolate
- Narrow to smallest failing component
- Identify probable root cause(s), rank by likelihood

### 3) Fix minimally
- Apply the smallest safe change that resolves root cause
- Avoid unrelated refactors during incident fix

### 4) Verify
- Re-run failing checks
- Run nearby regression checks

### 5) Report
- Root cause
- Fix applied
- Validation results
- Residual risk and follow-up hardening

## Guardrails
- Do not change scope beyond failure fix unless requested
- Prefer reversible, low-risk changes
- If multiple viable fixes exist, pick least disruptive and explain why

## Output format (always)
- Failure summary
- Root cause
- Minimal fix
- Verification checklist/results
- Residual risks/follow-ups
- **Next Step** (see mandatory section below)

---

## Next Step (MANDATORY — always include at end of output)

Every debug output MUST end with a `## Next Step` block containing all fields below. Choose values by matching the situation to the guidance table.

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

| Situation after debugging | Mode | Model | Skill |
|---|---|---|---|
| Fix applied and verified, resume implementation | Agent | Auto | `implement` |
| Fix applied, but related areas need hardening/refactor | Plan | Opus 4.6 | `plan` |
| Root cause found but fix is complex/risky — needs design | Plan | Opus 4.6 | `plan` |
| Root cause unclear, need deeper investigation | Debug | Opus 4.6 | `debug` |
| Fix introduced new failures | Debug | Auto | `debug` |
| Issue is an architecture/design question, not a bug | Ask | Opus 4.6 | none |
| All issues resolved, nothing left | — | — | none (say "Done!") |

### Model selection reference

| Model | When to pick |
|---|---|
| **Auto** | Default; choose if no strong reason to override |
| **Premium** | Default “best available” tier when quality matters and latency/cost are acceptable |
| **Sonnet** | Fast iteration, quick repro loops, simple fixes |
| **Opus 4.6** | Complex reasoning, architecture decisions, ambiguous failures |
| **GPT-5** | Strong at systematic debugging + refactor-safe fixes; pick for multi-symptom failures |
| **Gemini 3.1 Pro** | Strong at long-context log + code correlation; pick for big logs/CI output + multi-file traces |
| **DeepSeek R1** | Strong at deep reasoning and hypothesis testing; pick for tricky, non-obvious root causes |
| **Local** | Offline/private contexts; pick when logs/code cannot leave machine |

### Prompt rules
- The prompt must be self-contained (no "see above" references).
- Include the error context, root cause summary, and what to do next.
- If a skill applies, start the prompt with the skill's trigger phrase (e.g. "Implement:" for `/implement`, "Debug this issue end-to-end." for `/debug`, "Plan this work only:" for `/plan`).
- Reference specific files/modules and error messages.

## Prompt template

Debug this issue end-to-end.

Failure:
- [error/log snippet]
- [failing command or runtime path]

Expected:
- [expected behavior]

Please return:
1) probable root cause
2) minimal fix
3) verification steps/results
4) regression risks
5) **Next Step with mode, model, skill, and ready-to-paste prompt**
