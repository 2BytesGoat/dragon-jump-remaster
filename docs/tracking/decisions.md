---
title: Decision Log
tags: [godot, game-engine, project-management, decision-log]
related:
  - "[[direction/product_identity]]"
  - "[[direction/release_plan]]"
  - "[[tracking/current_sprint]]"
search_terms: [decisions, decision-log, scope, identity, agreed-upon]
---

# Decision Log

This document captures high-level decisions as the project evolves.

## 2026-07-17

- **Created this decision log** to capture the current state and prevent findings from being lost.
- **Refined product identity** to:

  > Dragon Jump Remaster is an arcade-style single-button speedrun platformer. The Steam version adds a hidden AI training mode for players who want to tinker with reinforcement learning.

  Details: `[[direction/product_identity]]`.

- **Decided V1.0 scope** is the polished 16-level speedrun campaign, with AI training as a hidden/tinkerer value-add. Multiplayer, crown/tag, editor, and chicken-horse are shelved.

- **Identified the upcoming ML workshop competition** as the immediate external deadline. Sprint plan: `[[tracking/sprints/sprint_2026_07_25]]`.

  > **Status update:** The `1-17` level and distinct-tiles-touched tracking are **not yet implemented** in code, despite an earlier note claiming they were added. They remain the top priority for the current sprint.

## Open decisions

- Should the RL training mode remain a first-class feature or become a separate build target?
- Should the crown/progress bar/tag-mode code be removed, hidden, or fully implemented?
- What is the target platform and release channel (itch.io, Steam, internal research demo)?
- Is the AI training mode a hidden menu, a separate launch flag, or excluded from the arcade build?
- What is the exact release deadline for V1.0?
- What is the desired level count for a first public build?