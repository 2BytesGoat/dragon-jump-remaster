---
title: Current Sprint
tags: [godot, game-engine, project-management, sprint]
related:
  - "[[project/decisions]]"
  - "[[project/active-backlog]]"
  - "[[design/release-plan]]"
search_terms: [sprint, current-sprint, tasks, focus, now]
---

# Current Sprint

## Sprint goal

Make the arcade loop minimally playable (not stuck, exitable) and verify the CI web export produces a working HTML5 build. This is Sprint 1 of 2 toward the **Aug 31 reproducible pipeline milestone** — a documented Godot → web → Emulation Station → Switch pipeline that October jam participants can replicate. Ends **August 17, 2026**.

The game only needs to be *playable enough* to prove the pipeline works. Polish (hearts, hidden areas, HUD, leaderboard, juice) is deferred to Phase 5 — post-deadline.

## Active sprint

See [[project/sprints/sprint-2026-08-17]] for the full sprint plan and definition of done. See [[project/sprints/sprint-2026-08-31]] for Sprint 2 (the finish line).

## Status

- [ ] Fix arcade exit bug — mode-aware routing (#52)
- [ ] Fix arcade "stuck at end" — wire `_show_arcade_game_over()` (#53)
- [ ] Wire arcade game-over to reuse existing end_screen (#54)
- [ ] Verify CI web export produces playable HTML5 build (#67)
- [ ] Research: can ES on the modded Switch run an HTML5 web build at all? (#68) — research only, ~1.5h; the scraper (#82) is Sprint 2's job
- [ ] No regression in practice mode

> Capacity: ~10–15h (crunch mode — hard Aug 31 deadline, September away). Slack built in for CI surprises and ES research unknowns.

## Milestone context

- **Primary goal (Aug 31):** Reproducible Godot → web → Emulation Station → Switch pipeline for the Oct game jam. You're hosting the jam; others need to port their games using your pipeline.
- **Game polish is deferred** to Phase 5 (September/October TBD) — hearts, hidden areas in 11 levels, HUD, top-10 leaderboard, victory screen, juice, transitions.
- **Steam integration** is Phase 4, deferred until after the pipeline + post-September.

## Previous sprint

[[project/sprints/sprint-2026-07-25]] (ML workshop competition) is closed. See its retrospective. ~8 days of untracked polish work after that sprint (arcade 3-lives logic skeleton, secret areas, powerup cards, parallax, grass) has been reconciled into [[project/active-backlog]].

## Where to find related planning

- Full backlog and phases: [[project/active-backlog]]
- Release plan and milestones: [[design/release-plan]] § Release milestones
- Arcade design reference: [[design/arcade-mode]]
- Sprint workflow and template: [[meta/process]] § Sprint workflow, [[project/sprints/_template]]
- Previous sprint: [[project/sprints/sprint-2026-07-25]] and [[project/decisions]]
