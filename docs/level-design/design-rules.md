# Level Design Rules (World 1)

This document extracts level-design rules from existing levels `1-1` through `1-17` and tracks whether those rules still hold as each new level is analyzed.

## Legend

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

## Player capabilities

Document the movement limits that constrain level design.

| Capability | Description |
|---|---|
| Max speed | 220 px/s |
| Acceleration | 250 px/s² |
| Friction | 100 |
| Jump height | 72 px |
| Time to jump peak | 0.37 s |
| Time to jump descent | 0.23 s |
| Max jump duration | The jump state lasts until the jump timer expires (0.37 s by default) or the player releases jump. |
| Wall jump | Yes. Pressing jump while walled launches the player at 75% speed (`set_speedup_progress(0.75)`). |
| Wall slide | Yes. Slide speed ramps from 0.0 to 0.8 over 1.2 s using a curve. |
| Ceiling stick | Holding the jump button while touching a ceiling applies a "spiderman" modifier that sticks the player to it. |
| Facing direction | Player starts facing right (`starting_facing_direction = Vector2i.RIGHT.x`), determined by placement in the level code. |
| Powerup limit | Max 3 powerups stored. |
| Powerup consumption | LIFO — last picked powerup is consumed first (`powerups.pop_back()`). |
| Powerup casting | Powerups can only be cast while falling and pressing jump (`FallState.physics_update`). |

## Environment interactions

Document how objects and mechanics behave so rules can be validated against them.

| Object / mechanic | Interaction |
|---|---|
| `Y` Spike / hazard | Resets the player to the initial spawn location. |
| `O` Dissolve block | Starts dissolving on contact. Collision disables after 0.7 s. Full dissolve animation is 1.2 s. A timer waits 3.0 s, then the 0.5 s "Repair" animation restores the block. |
| `B` Bounce pad | Transitions the player to the `Bounce` state with a push direction defined by the pad. |
| `J` Double-jump powerup | Adds one extra mid-air jump when consumed. |
| Static layer | Sets a new respawn point and facing direction when touched. |
| Powerup limit | Player can hold a maximum of 3 powerups at once. |
| Powerup consumption | LIFO — last picked powerup is consumed first (`powerups.pop_back()`). |
| Powerup casting | Powerups can only be cast while falling and pressing jump (`FallState.physics_update`). |
| Powerup respawn | Powerups respawn after being used. |
| [New mechanic] | [Description when discovered in a level] |

## Rule tracking table

| # | Rule | Source level | Status |
|---|---|---|---|
| 1 | **Boundary walls are gameplay walls** — the level's outer walls are always usable as walls, floors, or shafts, even if one side is open. | 1-1 | Holds for 1-1–1-17 |
| 2 | **Player starts near the left side** — `P` is placed on the left half of the level so the player initially moves toward the right. | 1-1 | Holds for 1-1–1-17 |
| 3 | **Exit is at or above mid-height** — `Q` is at or above the vertical middle. | 1-1 | Holds for 1-1–1-17 |
| 4 | **Traversal emphasis** — the level is built around a primary movement challenge (vertical climbing, horizontal chaining, wall-jumping, etc.). | 1-1 | Holds for 1-1–1-17 |
| 5 | **Safe starting area** — player begins in a stable, non-hazardous area. | 1-1 | Holds for 1-1–1-17 |
| 6 | **Multiple valid routes** — levels are designed so there are at least two distinct ways to reach the exit, or significant flexibility in timing/approach. | 1-1 | Holds for 1-1–1-17 |
| 7 | **Exit sits on a wall or platform** — `Q` is always adjacent to a wall or floor, never floating in open space. | 1-1 | Holds for 1-1–1-17 |
| 8 | **Maximum horizontal gap from a single jump** — platforms reachable without wall jumps or powerups should be no farther apart than the player can cover in one jump (`max_speed * time_to_peak ≈ 81 px`). | 1-1 | Holds for 1-1, 1-2, 1-4, 1-5, 1-7, 1-10, 1-15; N/A for 1-3, 1-6, 1-8, 1-9, 1-11–1-14, 1-16–1-17 because powerups, wall jumps, or other mechanics extend reach. |
| 9 | **Maximum vertical step** — a platform directly above another should be within the player's jump height (72 px) unless a wall jump or powerup extends reach. | 1-1 | Holds for 1-1–1-17 |
| 10 | **Wall-jump horizontal coverage** — walls placed for wall-jumping should be within the rebound jump's horizontal reach (`max_speed * 0.75 * time_to_peak ≈ 61 px`). | 1-3 | Holds for 1-3, 1-4; N/A for 1-1, 1-2, 1-5, 1-6, 1-8–1-17 |
| 11 | **Safe landing width** — platforms intended as landing spots should be wide enough for the player to stop on; use at least 1 tile (16 px) and prefer 2+ tiles for challenging jumps. | 1-1 | Holds for 1-1–1-17 |
| 12 | **Dissolve-block traversal window** — a path that requires crossing dissolve blocks (`O`) must be completable within 0.7 s before collision disables. | 1-6 | Holds for 1-6, 1-7, 1-12, 1-15; N/A for levels without `O` |
| 13 | **Powerup placement before obstacle** — a powerup (`J`) must be reachable and positioned before the obstacle that requires it. | 1-8 | Holds for 1-8–1-13, 1-15–1-17; N/A for levels without `J` |
| 14 | **Bounce-pad aim** — bounce pads (`B`) must launch the player toward a reachable landing zone. | 1-14 | Holds for 1-14–1-17; N/A for levels without `B` |
| 15 | **Hazard-free start-to-exit path exists** — there is always at least one intended route from start to exit that avoids hazards, even if it requires skill. | 1-4 | Holds for 1-1–1-17 |

## Rule changelog

A chronological log of how rules were added, refined, or retired as new levels were analyzed.

- **1-1**: Initial rules extracted. Rules 1–11 added.
- **1-2**:
  - Rule 3 generalized from "Exit is above mid-height" to "Exit is at or above mid-height" because the exit is exactly at mid-height.
  - Rule 5 generalized from "Safe starting alcove" to "Safe starting area" because 1-2's start is an open but safe space.
- **1-3**:
  - Rule 1 generalized from "Solid border" to "Boundary walls are gameplay walls" because the left edge is open but used as a wall-jump shaft.
  - Rule 10 activated (wall-jump horizontal coverage) because 1-3 introduces required wall jumps.
- **1-4**:
  - First level to use spikes (`Y`) as hazards.
  - Rule 10 applies again: the right-side wall structure is used for climbing/sticking.
- **1-5**:
  - Level uses wide horizontal gaps that rely on running momentum ("BUNNY_HOP").
  - Rule 8 still holds, but the standing-jump bound may need refinement for running jumps.
- **1-6**:
  - First level with dissolve blocks (`O`).
  - Rule 12 added: dissolve-block traversal window.
- **1-7**:
  - Heavy use of dissolve blocks and spikes; confirms rule 12 in dense layouts.
- **1-8**:
  - First level where double-jump powerup (`J`) is required for the intended route.
  - Rule 13 added: powerup placement before obstacle.
- **1-9**:
  - Multiple `J` powerups in sequence; confirms rule 13.
- **1-10**:
  - Short level with one double-jump; confirms rule 13 in compact spaces.
- **1-11**:
  - Mixed mechanics (`J`, `O`, `Y`) in a large layout.
- **1-12**:
  - Very tall level mixing dissolve blocks, spikes, and powerups.
- **1-13**:
  - Vertical drop sections; rule 4 (traversal emphasis) covers drop-based traversal.
- **1-14**:
  - First level with bounce pads (`B`).
  - Rule 14 added: bounce-pad aim.
- **1-15**:
  - Mix of dissolve blocks, bounce pads, spikes, and powerups.
- **1-16**:
  - Dense hazard and bounce-pad layout.
- **1-17**:
  - Final level; consolidates all mechanics (`J`, `O`, `B`, `Y`).

## Per-level validation

### Level 1-1 — YOUR_TURN (26 × 16)

| Rule | Holds? | Notes |
|---|---|---|
| 1. Solid border | Yes | Full wall border on all four sides. |
| 2. Player starts near the left side | Yes | Player sits in bottom-left alcove. |
| 3. Exit at or above mid-height | Yes | Exit is on a top-middle platform. |
| 4. Traversal emphasis | Yes | Route requires climbing the left column. |
| 5. Safe starting area | Yes | Player is enclosed by walls on three sides. |
| 6. Multiple valid routes | Yes | Intended climbing route plus an alternative wall-jump sequence. |
| 7. Exit sits on a wall or platform | Yes | Exit rests on a top-middle platform. |
| 8. Maximum horizontal gap from a single jump | Yes | All intended jumps fit within ~81 px. |
| 9. Maximum vertical step | Yes | Climbable column steps are within 72 px. |
| 10. Wall-jump horizontal coverage | N/A | No required wall jumps. |
| 11. Safe landing width | Yes | All landing platforms are at least 1 tile wide. |
| 12. Dissolve-block traversal window | N/A | No dissolve blocks. |
| 13. Powerup placement before obstacle | N/A | No powerups. |
| 14. Bounce-pad aim | N/A | No bounce pads. |
| 15. Hazard-free start-to-exit path exists | Yes | No hazards. |

**Layout summary:** rectangular box; left side has a climbable column; exit sits on a top-middle platform above a pit. No hazards.

### Level 1-2 — JUMP (31 × 24)

| Rule | Holds? | Notes |
|---|---|---|
| 1. Solid border | Yes | Full wall border, including two solid ceiling rows. |
| 2. Player starts near the left side | Yes | Player is at the bottom-left of the map. |
| 3. Exit at or above mid-height | Yes | Exit is at row 12 of 24, exactly mid-height. |
| 4. Traversal emphasis | Yes | Forces climbing over floating platforms. |
| 5. Safe starting area | Yes | Open start area, but safe and hazard-free. |
| 6. Multiple valid routes | Yes | Alternating platform layout allows different timing/routes. |
| 7. Exit sits on a wall or platform | Yes | Exit rests on the top-middle platform. |
| 8. Maximum horizontal gap from a single jump | Yes | Platform spacing fits within ~81 px. |
| 9. Maximum vertical step | Yes | Each vertical step is within 72 px. |
| 10. Wall-jump horizontal coverage | N/A | No required wall jumps. |
| 11. Safe landing width | Yes | Floating platforms are at least 1 tile wide. |
| 12. Dissolve-block traversal window | N/A | No dissolve blocks. |
| 13. Powerup placement before obstacle | N/A | No powerups. |
| 14. Bounce-pad aim | N/A | No bounce pads. |
| 15. Hazard-free start-to-exit path exists | Yes | No hazards. |

**Layout summary:** larger rectangular box; player starts under a low ceiling; alternating floating platforms create a zig-zag climb toward the center exit. Contains one double-jump powerup (`J`) and no spikes.

### Level 1-3 — WALL_JUMP (25 × 28)

| Rule | Holds? | Notes |
|---|---|---|
| 1. Boundary walls are gameplay walls | Yes | Left edge is open for a 6-column shaft used as a wall-jump surface. |
| 2. Player starts near the left side | Yes | Player is at the bottom-left of the map. |
| 3. Exit at or above mid-height | Yes | Exit is high on the dividing wall (row 11 of 28). |
| 4. Traversal emphasis | Yes | Route requires wall-jumping up a tall shaft. |
| 5. Safe starting area | Yes | Open pit start, free of hazards. |
| 6. Multiple valid routes | Yes | Wall-jump shaft allows different timing/angles. |
| 7. Exit sits on a wall or platform | Yes | Exit is embedded in the right-side wall structure. |
| 8. Maximum horizontal gap from a single jump | N/A | Designed around wall jumps, not single jumps. |
| 9. Maximum vertical step | Yes | Large vertical sections covered by wall jumps. |
| 10. Wall-jump horizontal coverage | Yes | Shaft and dividing wall are within rebound range. |
| 11. Safe landing width | Yes | Ledge and platforms are at least 1 tile wide. |
| 12. Dissolve-block traversal window | N/A | No dissolve blocks. |
| 13. Powerup placement before obstacle | N/A | No powerups. |
| 14. Bounce-pad aim | N/A | No bounce pads. |
| 15. Hazard-free start-to-exit path exists | Yes | No hazards. |

**Layout summary:** narrow vertical shaft on the left, a central dividing wall, and a right chamber; the player must wall-jump up the shaft to reach the exit.

### Level 1-4 — STICK (38 × 25)

| Rule | Holds? | Notes |
|---|---|---|
| 1. Boundary walls are gameplay walls | Yes | Left side is open, right side is a tall climbable wall. |
| 2. Player starts near the left side | Yes | Player is in the lower-left area. |
| 3. Exit at or above mid-height | Yes | Exit is high on the right-side wall (row 7 of 25). |
| 4. Traversal emphasis | Yes | Route requires climbing the right-side wall. |
| 5. Safe starting area | Yes | Open ledge start, free of immediate hazards. |
| 6. Multiple valid routes | Yes | Open left shaft plus wall-climbing sections. |
| 7. Exit sits on a wall or platform | Yes | Exit embedded in the right-side wall. |
| 8. Maximum horizontal gap from a single jump | Yes | Crossings fit within ~81 px. |
| 9. Maximum vertical step | Yes | Climbs covered by wall jumps/sticking. |
| 10. Wall-jump horizontal coverage | Yes | Right wall and platforms are within rebound range. |
| 11. Safe landing width | Yes | Ledges are at least 1 tile wide. |
| 12. Dissolve-block traversal window | N/A | No dissolve blocks. |
| 13. Powerup placement before obstacle | N/A | Powerup is optional for alternate route. |
| 14. Bounce-pad aim | N/A | No bounce pads. |
| 15. Hazard-free start-to-exit path exists | Yes | Spikes can be avoided on the intended route. |

**Layout summary:** wide level with an open left half and a dense right-side wall; player climbs the right wall while avoiding spikes. Contains a double-jump powerup (`J`).

### Level 1-5 — BUNNY_HOP (31 × 18)

| Rule | Holds? | Notes |
|---|---|---|
| 1. Boundary walls are gameplay walls | Yes | Top-left open, right and bottom walls solid. |
| 2. Player starts near the left side | Yes | Player is in the lower-left quadrant. |
| 3. Exit at or above mid-height | Yes | Exit is near the top (row 6 of 18). |
| 4. Traversal emphasis | Yes | Climbing to the top via hops. |
| 5. Safe starting area | Yes | Start ledge is safe. |
| 6. Multiple valid routes | Yes | Alternating platforms allow different jump sequences. |
| 7. Exit sits on a wall or platform | Yes | Exit rests on a top platform. |
| 8. Maximum horizontal gap from a single jump | Yes | Gaps fit within running-jump reach. |
| 9. Maximum vertical step | Yes | Short steps within 72 px. |
| 10. Wall-jump horizontal coverage | N/A | No required wall jumps. |
| 11. Safe landing width | Yes | Landing platforms are at least 1 tile wide. |
| 12. Dissolve-block traversal window | N/A | No dissolve blocks. |
| 13. Powerup placement before obstacle | N/A | No powerups. |
| 14. Bounce-pad aim | N/A | No bounce pads. |
| 15. Hazard-free start-to-exit path exists | Yes | Spikes can be avoided. |

**Layout summary:** medium-height level with a lower spike floor and a central climb; player hops across platforms to the top exit. No powerups.

### Level 1-6 — DISSOLVE (39 × 22)

| Rule | Holds? | Notes |
|---|---|---|
| 1. Boundary walls are gameplay walls | Yes | Full bottom/right/top borders; left side is mostly open but bounded. |
| 2. Player starts near the left side | Yes | Player is at the lower-left. |
| 3. Exit at or above mid-height | Yes | Exit is near the top-right (row 14 of 22). |
| 4. Traversal emphasis | Yes | Route crosses dissolve-block bridges upward. |
| 5. Safe starting area | Yes | Start area is hazard-free. |
| 6. Multiple valid routes | Yes | Different dissolve-block crossing timings possible. |
| 7. Exit sits on a wall or platform | Yes | Exit sits on a wall/platform near the top. |
| 8. Maximum horizontal gap from a single jump | N/A | Gaps require dissolve blocks or powerups. |
| 9. Maximum vertical step | Yes | Steps fit within 72 px or use dissolve blocks. |
| 10. Wall-jump horizontal coverage | N/A | No required wall jumps. |
| 11. Safe landing width | Yes | Platforms are at least 1 tile wide. |
| 12. Dissolve-block traversal window | Yes | Dissolve-block bridges are short enough to cross before 0.7 s disable. |
| 13. Powerup placement before obstacle | N/A | No powerups. |
| 14. Bounce-pad aim | N/A | No bounce pads. |
| 15. Hazard-free start-to-exit path exists | Yes | No spikes; only dissolve-block timing. |

**Layout summary:** rectangular level with dissolve-block bridges forming the main path; player must time movement across dissolving surfaces to reach the top-right exit. No spikes.

### Level 1-7 — UNDER (34 × 20)

| Rule | Holds? | Notes |
|---|---|---|
| 1. Boundary walls are gameplay walls | Yes | Full border; walls are used as floors/ceilings. |
| 2. Player starts near the left side | Yes | Player is on the left side, mid-height. |
| 3. Exit at or above mid-height | Yes | Exit is near the top (row 7 of 20). |
| 4. Traversal emphasis | Yes | Route weaves under dissolve-block barriers and over spikes. |
| 5. Safe starting area | Yes | Start platform is safe. |
| 6. Multiple valid routes | Yes | Several timing choices for passing dissolve blocks. |
| 7. Exit sits on a wall or platform | Yes | Exit is on a top platform. |
| 8. Maximum horizontal gap from a single jump | Yes | Basic jumps fit within ~81 px; larger gaps use dissolve blocks. |
| 9. Maximum vertical step | Yes | Steps within 72 px or use short climbs. |
| 10. Wall-jump horizontal coverage | N/A | No required wall jumps. |
| 11. Safe landing width | Yes | Landing spots are at least 1 tile wide. |
| 12. Dissolve-block traversal window | Yes | Dissolve barriers are crossed quickly; timing windows respected. |
| 13. Powerup placement before obstacle | N/A | No powerups. |
| 14. Bounce-pad aim | N/A | No bounce pads. |
| 15. Hazard-free start-to-exit path exists | Yes | Spikes can be avoided on the intended route. |

**Layout summary:** compact level where the player must move under dissolve-block ceilings and over spike floors to reach a top exit. Heavy use of `O` and `Y`.

### Level 1-8 — DOUBLE_JUMP (35 × 24)

| Rule | Holds? | Notes |
|---|---|---|
| 1. Boundary walls are gameplay walls | Yes | Full border and internal walls are gameplay surfaces. |
| 2. Player starts near the left side | Yes | Player is at the lower-left. |
| 3. Exit at or above mid-height | Yes | Exit is near the top (row 5 of 24). |
| 4. Traversal emphasis | Yes | Vertical climb requiring double-jumps. |
| 5. Safe starting area | Yes | Start area is safe. |
| 6. Multiple valid routes | Yes | Several platform sequences can be used. |
| 7. Exit sits on a wall or platform | Yes | Exit rests on a top platform. |
| 8. Maximum horizontal gap from a single jump | N/A | Double-jump powerups extend reach; basic jumps still fit ~81 px. |
| 9. Maximum vertical step | Yes | Large vertical steps use double-jump; small steps fit 72 px. |
| 10. Wall-jump horizontal coverage | N/A | No required wall jumps. |
| 11. Safe landing width | Yes | Platforms are at least 1 tile wide. |
| 12. Dissolve-block traversal window | N/A | No dissolve blocks. |
| 13. Powerup placement before obstacle | Yes | Double-jump pickups appear before the wide gaps/high steps that need them. |
| 14. Bounce-pad aim | N/A | No bounce pads. |
| 15. Hazard-free start-to-exit path exists | Yes | Spikes can be avoided. |

**Layout summary:** tall level where double-jump powerups (`J`) are required to clear wide horizontal gaps and high vertical steps to reach the top exit.

### Level 1-9 — CHAIN_JUMPS (40 × 20)

| Rule | Holds? | Notes |
|---|---|---|
| 1. Boundary walls are gameplay walls | Yes | Full border used as walls/floors. |
| 2. Player starts near the left side | Yes | Player is on the left side, mid-height. |
| 3. Exit at or above mid-height | Yes | Exit is on the right side at mid-height (row 13 of 20). |
| 4. Traversal emphasis | Yes | Horizontal chain of double-jumps across the level. |
| 5. Safe starting area | Yes | Start platform is safe. |
| 6. Multiple valid routes | Yes | Timing of double-jump casts allows flexibility. |
| 7. Exit sits on a wall or platform | Yes | Exit sits on a right-side platform. |
| 8. Maximum horizontal gap from a single jump | N/A | Chain of double-jumps covers the gaps. |
| 9. Maximum vertical step | Yes | Steps fit within 72 px or use double-jump. |
| 10. Wall-jump horizontal coverage | N/A | No required wall jumps. |
| 11. Safe landing width | Yes | Platforms are at least 1 tile wide. |
| 12. Dissolve-block traversal window | N/A | No dissolve blocks. |
| 13. Powerup placement before obstacle | Yes | Three `J` pickups are placed before the gaps they cover. |
| 14. Bounce-pad aim | N/A | No bounce pads. |
| 15. Hazard-free start-to-exit path exists | Yes | No spikes. |

**Layout summary:** wide, low level where the player must chain double-jumps across a series of platforms to reach the right-side exit.

### Level 1-10 — DOUBLE_SHORT (29 × 28)

| Rule | Holds? | Notes |
|---|---|---|
| 1. Boundary walls are gameplay walls | Yes | Border and internal walls used as surfaces. |
| 2. Player starts near the left side | Yes | Player is at the lower-left. |
| 3. Exit at or above mid-height | Yes | Exit is high on the right (row 4 of 28). |
| 4. Traversal emphasis | Yes | Short but dense vertical climb using double-jumps. |
| 5. Safe starting area | Yes | Start area is safe. |
| 6. Multiple valid routes | Yes | Multiple platform choices in the climb. |
| 7. Exit sits on a wall or platform | Yes | Exit sits on a top platform. |
| 8. Maximum horizontal gap from a single jump | N/A | Double-jump extends reach. |
| 9. Maximum vertical step | Yes | Steps within 72 px or use double-jump. |
| 10. Wall-jump horizontal coverage | N/A | No required wall jumps. |
| 11. Safe landing width | Yes | Platforms are at least 1 tile wide. |
| 12. Dissolve-block traversal window | N/A | No dissolve blocks. |
| 13. Powerup placement before obstacle | Yes | `J` appears before the high climb sections. |
| 14. Bounce-pad aim | N/A | No bounce pads. |
| 15. Hazard-free start-to-exit path exists | Yes | No spikes. |

**Layout summary:** compact vertical level requiring double-jumps to climb a tight series of platforms to the top-right exit.

### Level 1-11 — ORIGINS (41 × 30)

| Rule | Holds? | Notes |
|---|---|---|
| 1. Boundary walls are gameplay walls | Yes | Open sections are bounded by gameplay walls. |
| 2. Player starts near the left side | Yes | Player is in the lower-left area. |
| 3. Exit at or above mid-height | Yes | Exit is near the top-left area (row 5 of 30). |
| 4. Traversal emphasis | Yes | Large vertical and horizontal traversal using multiple mechanics. |
| 5. Safe starting area | Yes | Start platform is safe. |
| 6. Multiple valid routes | Yes | Multiple paths through the large layout. |
| 7. Exit sits on a wall or platform | Yes | Exit rests on a top platform. |
| 8. Maximum horizontal gap from a single jump | N/A | Double-jumps and wall sections extend reach. |
| 9. Maximum vertical step | Yes | Steps use double-jump/wall jumps where needed. |
| 10. Wall-jump horizontal coverage | Yes | Some wall sections are within rebound range. |
| 11. Safe landing width | Yes | Platforms are at least 1 tile wide. |
| 12. Dissolve-block traversal window | Yes | Dissolve blocks are crossed within 0.7 s. |
| 13. Powerup placement before obstacle | Yes | `J` pickups are placed before gaps/climbs that need them. |
| 14. Bounce-pad aim | N/A | No bounce pads. |
| 15. Hazard-free start-to-exit path exists | Yes | Spikes can be avoided. |

**Layout summary:** large level combining double-jumps, dissolve blocks, and spikes across a sprawling vertical/horizontal layout.

### Level 1-12 — DARE (38 × 35)

| Rule | Holds? | Notes |
|---|---|---|
| 1. Boundary walls are gameplay walls | Yes | Border and internal walls are gameplay surfaces. |
| 2. Player starts near the left side | Yes | Player is in the lower-left area. |
| 3. Exit at or above mid-height | Yes | Exit is high on the right (row 10 of 35). |
| 4. Traversal emphasis | Yes | Tall climb with dissolve blocks and spikes. |
| 5. Safe starting area | Yes | Start area is safe. |
| 6. Multiple valid routes | Yes | Several platform/dissolve timing choices. |
| 7. Exit sits on a wall or platform | Yes | Exit embedded in the upper wall structure. |
| 8. Maximum horizontal gap from a single jump | N/A | Powerups and dissolve blocks extend reach. |
| 9. Maximum vertical step | Yes | Steps fit within 72 px or use powerups. |
| 10. Wall-jump horizontal coverage | N/A | No required wall jumps. |
| 11. Safe landing width | Yes | Landing spots are at least 1 tile wide. |
| 12. Dissolve-block traversal window | Yes | Dissolve-block paths are short enough to cross in time. |
| 13. Powerup placement before obstacle | Yes | `J` placed before large gaps. |
| 14. Bounce-pad aim | N/A | No bounce pads. |
| 15. Hazard-free start-to-exit path exists | Yes | Spikes can be avoided on the intended route. |

**Layout summary:** very tall level mixing dissolve blocks, spikes, and double-jumps in a dense vertical climb.

### Level 1-13 — DROP (43 × 34)

| Rule | Holds? | Notes |
|---|---|---|
| 1. Boundary walls are gameplay walls | Yes | Full border and central walls used as surfaces. |
| 2. Player starts near the left side | Yes | Player is in the lower-left area. |
| 3. Exit at or above mid-height | Yes | Exit is near the top-right (row 9 of 34). |
| 4. Traversal emphasis | Yes | Vertical drop-and-climb traversal. |
| 5. Safe starting area | Yes | Start ledge is safe. |
| 6. Multiple valid routes | Yes | Multiple paths around the central structure. |
| 7. Exit sits on a wall or platform | Yes | Exit rests on a top platform. |
| 8. Maximum horizontal gap from a single jump | N/A | Double-jumps and wall sections extend reach. |
| 9. Maximum vertical step | Yes | Large vertical drops are controlled by platforms. |
| 10. Wall-jump horizontal coverage | Yes | Central wall sections allow wall jumps. |
| 11. Safe landing width | Yes | Platforms are at least 1 tile wide. |
| 12. Dissolve-block traversal window | Yes | Dissolve blocks crossed within timing window. |
| 13. Powerup placement before obstacle | Yes | `J` placed before needed gaps. |
| 14. Bounce-pad aim | N/A | No bounce pads. |
| 15. Hazard-free start-to-exit path exists | Yes | Spikes can be avoided. |

**Layout summary:** tall level with a central dividing wall and side chambers; player drops down and climbs back up using wall jumps, dissolve blocks, and double-jumps.

### Level 1-14 — BOUNCE (33 × 36)

| Rule | Holds? | Notes |
|---|---|---|
| 1. Boundary walls are gameplay walls | Yes | Border and internal walls are surfaces. |
| 2. Player starts near the left side | Yes | Player is in the lower-left area. |
| 3. Exit at or above mid-height | Yes | Exit is near the top (row 10 of 36). |
| 4. Traversal emphasis | Yes | Vertical climb using bounce pads and double-jumps. |
| 5. Safe starting area | Yes | Start area is safe. |
| 6. Multiple valid routes | Yes | Bounce-pad angles allow different trajectories. |
| 7. Exit sits on a wall or platform | Yes | Exit rests on a top platform. |
| 8. Maximum horizontal gap from a single jump | N/A | Bounce pads and double-jumps extend reach. |
| 9. Maximum vertical step | Yes | Steps use bounce pads or double-jumps. |
| 10. Wall-jump horizontal coverage | N/A | Bounce pads replace wall jumps. |
| 11. Safe landing width | Yes | Landing zones are at least 1 tile wide. |
| 12. Dissolve-block traversal window | Yes | One dissolve-block section is crossable in time. |
| 13. Powerup placement before obstacle | Yes | `J` placed before high climbs. |
| 14. Bounce-pad aim | Yes | Bounce pads launch the player toward reachable platforms. |
| 15. Hazard-free start-to-exit path exists | Yes | Spikes can be avoided. |

**Layout summary:** tall level introducing bounce pads (`B`); player uses pad-launched arcs and double-jumps to climb to the top exit.

### Level 1-15 — TRAP (46 × 25)

| Rule | Holds? | Notes |
|---|---|---|
| 1. Boundary walls are gameplay walls | Yes | Border and internal walls are surfaces. |
| 2. Player starts near the left side | Yes | Player is in the lower-left area. |
| 3. Exit at or above mid-height | Yes | Exit is high on the right (row 7 of 25). |
| 4. Traversal emphasis | Yes | Dense mixed-mechanic traversal. |
| 5. Safe starting area | Yes | Start platform is safe. |
| 6. Multiple valid routes | Yes | Several paths through the trap layout. |
| 7. Exit sits on a wall or platform | Yes | Exit rests on a top platform. |
| 8. Maximum horizontal gap from a single jump | N/A | Bounce pads and powerups extend reach. |
| 9. Maximum vertical step | Yes | Steps use bounce pads or powerups. |
| 10. Wall-jump horizontal coverage | N/A | Bounce pads and powerups replace wall jumps. |
| 11. Safe landing width | Yes | Landing spots are at least 1 tile wide. |
| 12. Dissolve-block traversal window | Yes | Dissolve blocks placed with adequate timing windows. |
| 13. Powerup placement before obstacle | Yes | `J` placed before needed climbs/gaps. |
| 14. Bounce-pad aim | Yes | Bounce pads launch toward safe landing zones. |
| 15. Hazard-free start-to-exit path exists | Yes | Spikes can be avoided on the intended route. |

**Layout summary:** wide level mixing dissolve blocks, bounce pads, spikes, and double-jumps in a dense trap-filled layout.

### Level 1-16 — CONTROL (42 × 27)

| Rule | Holds? | Notes |
|---|---|---|
| 1. Boundary walls are gameplay walls | Yes | Border and internal walls are surfaces. |
| 2. Player starts near the left side | Yes | Player is in the lower-left area. |
| 3. Exit at or above mid-height | Yes | Exit is near the top (row 9 of 27). |
| 4. Traversal emphasis | Yes | Tight control challenge using bounce pads and hazards. |
| 5. Safe starting area | Yes | Start area is safe. |
| 6. Multiple valid routes | Yes | Different bounce-pad and platform sequences. |
| 7. Exit sits on a wall or platform | Yes | Exit rests on a top platform. |
| 8. Maximum horizontal gap from a single jump | N/A | Bounce pads and powerups extend reach. |
| 9. Maximum vertical step | Yes | Steps use bounce pads or double-jumps. |
| 10. Wall-jump horizontal coverage | N/A | Bounce pads replace wall jumps. |
| 11. Safe landing width | Yes | Landing zones are at least 1 tile wide. |
| 12. Dissolve-block traversal window | N/A | No dissolve blocks. |
| 13. Powerup placement before obstacle | Yes | `J` placed before high sections. |
| 14. Bounce-pad aim | Yes | Pads launch toward reachable targets. |
| 15. Hazard-free start-to-exit path exists | Yes | Hazards can be avoided with control. |

**Layout summary:** dense level emphasizing precise bounce-pad control and hazard avoidance to reach the top exit.


### Level 1-17 — MANDATORY (42 × 23)

| Rule | Holds? | Notes |
|---|---|---|
| 1. Boundary walls are gameplay walls | Yes | Full border and internal dividing walls are gameplay surfaces. |
| 2. Player starts near the left side | Yes | Player is at the bottom-left. |
| 3. Exit at or above mid-height | Yes | Exit is on the top-right platform (row 2 of 23). |
| 4. Traversal emphasis | Yes | Multi-stage challenge combining wall-jump shaft, dissolve bridge, spike pit, bounce pads, and double-jumps. |
| 5. Safe starting area | Yes | Start alcove is safe and hazard-free. |
| 6. Multiple valid routes | Yes | Several sequencing choices for using powerups, bounce pads, and wall jumps. |
| 7. Exit sits on a wall or platform | Yes | Exit rests on the top-right platform. |
| 8. Maximum horizontal gap from a single jump | N/A | Powerups, bounce pads, and wall jumps extend reach. |
| 9. Maximum vertical step | Yes | Steps use powerups, bounce pads, or wall jumps where needed. |
| 10. Wall-jump horizontal coverage | Yes | The left shaft and central wall are within rebound range. |
| 11. Safe landing width | Yes | Landing zones are at least 1 tile wide. |
| 12. Dissolve-block traversal window | Yes | The dissolve-block bridge in the upper-left is short enough to cross before 0.7 s. |
| 13. Powerup placement before obstacle | Yes | `J` pickups are placed before the wide gaps and high climbs that require them. |
| 14. Bounce-pad aim | Yes | Bounce pads launch the player toward reachable platforms and over spike pits. |
| 15. Hazard-free start-to-exit path exists | Yes | Spikes can be avoided on the intended route. |

**Layout summary:** redesigned challenging finale. The player starts bottom-left in a safe alcove, wall-jumps up a left shaft, crosses a dissolve-block bridge over a spike pit, uses bounce pads to clear gaps, and chains double-jumps to reach the top-right exit.

---

*Level 1-17 redesigned. Pending final user review.*

---

*All levels 1-1 through 1-17 have been analyzed. Pending final user review.*