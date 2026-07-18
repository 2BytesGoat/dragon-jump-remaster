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

  Details: [[direction/product_identity]].

- **Decided V1.0 scope** is the polished 16-level speedrun campaign, with AI training as a hidden/tinkerer value-add. Multiplayer, crown/tag, editor, and chicken-horse are shelved.

- **Identified the upcoming ML workshop competition** as the immediate external deadline. Sprint plan: [[tracking/sprints/sprint_2026_07_25]].

  > **Status update:** The `1-17` level and distinct-tiles-touched tracking are **not yet implemented** in code, despite an earlier note claiming they were added. They remain the top priority for the current sprint.

- **Recorded playtesting feedback:**
  - Most common request: **more levels**. This becomes the strongest signal for the first post-ship feature.
  - Mobile was suggested repeatedly, but the author explicitly does not want to pursue it now; it stays shelved.
  - "Too fast" feedback was addressed by adding a speed slider.
  - **No tutorial / unclear inputs** was flagged as a barrier, especially for casual players. This needs to be fixed before shipping.
  - Nobody asked for multiplayer, ghost race, editor, or other fancy features. The author's excitement is not player demand; those stay shelved.
  - **Nuance on "more levels":** players kept going because short levels feel low-commitment, but some were discouraged when the top leaderboard gap was large. The request for "more" may partly be a request for more *substance* per session, not just more count.

- **Decided to keep short levels as the core format.** FunRun-style long levels with random powerups would change the product identity. The short-level format supports low-commitment retries, clear leaderboards, and fast AI playtesting. Post-ship level design can explore a few slightly longer or mixed-length curated levels, but the core stays short and hand-authored.

- **Clarified the core hook:** the game is a collection of short, interesting speedrun problems that players can hop on and off of. The hook is not one long adventure or random powerup chaos; it is the low-commitment retry loop, the hand-authored level design, and the chase for a better time.

- **Decided source/IP strategy:** the main Dragon Jump repo will be made private before commercial release to protect the full game, levels, and assets. After release, the author may publish a separate educational repo with core architecture and systems (no assets, no levels, no branding) under a permissive license, similar to the Aseprite model. The commercial value is the official build, updates, leaderboards, and community — not code secrecy. Technical or legal protection alone cannot stop a determined bad actor; the defense is being the trusted official version.

## Open decisions

- Should the RL training mode remain a first-class feature or become a separate build target?
- Should the crown/progress bar/tag-mode code be removed, hidden, or fully implemented?
- What is the target platform and release channel (itch.io, Steam, internal research demo)?
- Is the AI training mode a hidden menu, a separate launch flag, or excluded from the arcade build?
- What is the exact release deadline for V1.0?
- What is the desired level count for a first public build?
- When exactly should the repo transition from public to private relative to the arcade/Steam builds?