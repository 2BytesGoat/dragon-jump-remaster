---
title: Current Sprint
tags: [godot, game-engine, project-management, sprint]
related:
  - "[[project/sprints/sprint-2026-08-17]]"
  - "[[project/sprints/sprint-2026-08-31]]"
  - "[[project/sprints/sprint-2026-09-30]]"
  - "[[project/sprints/sprint-2026-10-31]]"
  - "[[project/sprints/sprint-2026-11-30]]"
  - "[[project/sprints/sprint-2026-12-15]]"
  - "[[project/active-backlog]]"
  - "[[project/decisions]]"
search_terms: [sprint, current-sprint, tasks, focus, now, goal, epic]
---

# Current Sprint

> **Role of this file:** the goal-level entry point for the current sprint — epic-level only. Task status, deliverables, capacity, definition of done, and retrospective all live in the linked sprint file. Do not duplicate the task list here.

## Sprint goal

Make the arcade loop minimally playable (not stuck, exitable) and verify the CI web export produces a working HTML5 build. This is Sprint 1 of 2 toward the **Aug 31 reproducible pipeline milestone** — a documented Godot → web → Emulation Station → Switch pipeline that October jam participants can replicate. Ends **August 17, 2026**.

The game only needs to be *playable enough* to prove the pipeline works. Polish (hearts, hidden areas, HUD, leaderboard, juice) is deferred to Phase 3.

> **Roadmap change (2026-08-05):** After the Aug 31 pipeline milestone, the project pivots to an **editor-first Early Access build** — editor + Workshop + 25–30 levels launching Dec 2026 at $9.99, with 1.0 (world arcade, daily/weekly challenges, full polish) in Aug 2027 at $12.99. See [[project/decisions]] and [[design/release-plan]].

## Active sprint

[[project/sprints/sprint-2026-08-17]] — full plan, deliverables, status, definition of done, retrospective. See [[project/sprints/sprint-2026-08-31]] for Sprint 2 (the finish line).

## Upcoming sprints (post-pipeline)

| Sprint | Window | Focus |
|--------|--------|-------|
| [[project/sprints/sprint-2026-09-30]] | Sep | Editor foundation + world reorganization |
| [[project/sprints/sprint-2026-10-31]] | Oct | Workshop + arcade + boss levels |
| [[project/sprints/sprint-2026-11-30]] | Nov | EA build complete + store prep |
| [[project/sprints/sprint-2026-12-15]] | Dec | **Early Access launch at $9.99** |

## Previous sprint

[[project/sprints/sprint-2026-07-25]] (ML workshop competition) — closed. See its retrospective. ~8 days of untracked polish work after that sprint (arcade 3-lives logic skeleton, secret areas, powerup cards, parallax, grass) has been reconciled into [[project/active-backlog]].

## Where to find related planning

- Full backlog and phases: [[project/active-backlog]]
- Release plan and milestones: [[design/release-plan]] § Release milestones
- Arcade design reference: [[design/arcade-mode]]
- Sprint workflow and template: [[meta/process]] § Sprint workflow, [[project/sprints/_template]]
- Past decisions: [[project/decisions]]