# Level Design Rules — Template

This document provides a process for extracting level-design rules from a set of existing levels and tracking whether those rules still hold as each new level is analyzed.

## Legend

Define the tile/symbol legend used to describe levels.

| Symbol | Meaning |
|---|---|
| `W` / `#` | Wall |
| `E` / `.` | Empty |
| `P` / `p` | Player start |
| `Q` / `q` | Exit |
| `Y` / `^` | Spike / hazard |
| `O` / `o` | Dissolve block |
| `B` / `b` | Bounce pad |
| `J` / `j` | Double-jump powerup |
| `C` / `S` / `R` / `G` | Multiplayer collectibles / hazards |
| `M` | Multiplayer wall material |

> Update the legend above to match the symbols used by your level parser or editor.

## Workflow

1. **Read this template.**
2. **Check if `docs/level_design_rules.md` already exists.**
   - If it does not, create it from this template.
   - If it does, continue from its current state.
3. **Identify the levels to analyze.** Read `src/scripts/singletons/constants.gd` to discover the currently implemented levels.
4. **For each level, in order:**
   - Check whether it has already been analyzed in `docs/level_design_rules.md`.
   - If it has, skip to the next level.
   - If it has not:
     - Validate every existing rule against that level.
     - Mark each rule as **Yes**, **Partially**, or **No**.
     - If a rule does not fully apply, generalize it so it still covers all previously analyzed levels (e.g., change "all rooms are square" to "all rooms are rectangles" when a rectangular room appears).
     - Identify any new rules introduced by the current level (new mechanics, hazards, shapes, etc.) and add them to the rule tracking table.
     - Update the rule tracking table's **Notes so far** column.
5. **Prompt the user to double-check the updated `docs/level_design_rules.md`.**
6. **Re-read `docs/level_design_rules.md` after user review** to capture any changes they made.
7. **Proceed to the next unanalyzed level.**

## Rule tracking table

As each level is analyzed, record the rules that appear to govern level design.

| # | Rule | Source level | Notes so far |
|---|---|---|---|
| 1 | **[Rule name]** — [concise description]. | [level] | [yes/no/partial observations across analyzed levels] |
| 2 | ... | ... | ... |

Guidelines for filling this table:

- Add a new row only when a candidate rule is observed in at least one level.
- Mark a rule as **candidate** until it has been checked against several levels.
- Update **Notes so far** every time a new level is analyzed, noting counter-examples.
- Generalize a rule instead of dropping it when a single level contradicts the narrower version.
- Retire or refine a rule if too many levels contradict even its generalized form.

## Per-level validation

For each analyzed level, create a subsection and check every current rule against the level's layout.

### Level [ID] — [Name] ([width] × [height])

| Rule | Holds? | Notes |
|---|---|---|
| 1. [Rule name] | Yes / No / Partially | [observation] |
| 2. ... | ... | ... |

**Layout summary:** [short description of the level's structure, key hazards, and intended path]

After filling this out:

- Update the rule tracking table with the results.
- Identify new candidate rules.
- Generalize existing rules if needed.
- Add a note at the bottom indicating the document is pending user review before proceeding to the next level.

## How to generalize a rule

When a rule is contradicted by a new level, broaden it just enough to include both cases:

- "All levels have a solid border" → "Boundary walls are gameplay walls" when one side is open but still used as a shaft wall.
- "All rooms are square" → "All rooms are rectangular" when a non-square rectangle appears.
- "Exit is in the upper half" → "Exit is at or above mid-height" when an exit sits exactly at the middle.

Always keep the generalized rule descriptive enough to be useful for validation or generation.

## Checklist before moving to the next level

Before continuing to the next level, ensure:

- [ ] The current level has a per-level validation section.
- [ ] Every existing rule was checked against the current level.
- [ ] Rule statuses are recorded as **Yes**, **Partially**, or **No**.
- [ ] Any rule that did not fully apply has been generalized to cover all analyzed levels.
- [ ] Any new mechanics or patterns discovered in this level were added as candidate rules.
- [ ] The rule tracking table's **Notes so far** column is up to date.
- [ ] The user has been prompted to review the updated document.
- [ ] The document includes a pending-review notice before the next level.