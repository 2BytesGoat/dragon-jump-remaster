# Procedural Level Constraints

Edit this file to change what the generator enforces. Each constraint has a
stable ID and a severity. Run

```
python3 tools/proc_gen/check_coverage.py
```

to see which constraints still need a code implementation.

## Severity legend

- **HARD** — a generated level *must* pass this or it is rejected and retried.
- **SOFT** — a generated level reports a warning if it fails, but is still saved.

## Physics facts

Values are taken from `src/scripts/resources/physics_params.gd` and
`src/scenes/player/states/jump_state.gd`.

| Constant | Value | Meaning |
|----------|-------|---------|
| Tile size | 16 px | Godot TileMap cell size |
| `max_speed` | 220 px/s | Max horizontal speed |
| `acceleration` | 250 px/s² | Horizontal acceleration |
| `jump_height` | 72 px | 4.5 tiles |
| `jump_time_to_peak` | 0.37 s | Rise time |
| `jump_time_to_descent` | 0.23 s | Fall time from peak to ground |
| Bounce pad upward | 1.2× | Multiplies jump velocity |
| Bounce pad horizontal | 2.0× | Multiplies horizontal velocity |

Derived jump limits (assuming the player reaches `max_speed` before jumping):

| Vertical delta | Airtime | Max horizontal gap |
|----------------|---------|--------------------|
| Level (0 tiles) | 0.60 s | ~8.3 tiles |
| Up 1 tile | 0.57 s | ~7.9 tiles |
| Up 2 tiles | 0.55 s | ~7.6 tiles |
| Up 3 tiles | 0.51 s | ~7.0 tiles |
| Up 4 tiles | 0.45 s | ~6.1 tiles |
| Down 4 tiles | 0.69 s | ~9.4 tiles |
| Down 8 tiles | 0.83 s | ~11.4 tiles |

Standing jumps from rest are much shorter (~3 tiles) because the player cannot
reach `max_speed` instantly. The base model assumes a short runway is available.
A planned SOFT constraint (`J04`) will prefer shorter critical-path gaps so
levels still feel fair without a long run-up.

## Constraint summary

| ID  | Severity | Title | Status |
|-----|----------|-------|--------|
| R01 | HARD | Exit reachable from player via jump graph | implemented |
| R02 | SOFT | All standable cells reachable from player (no orphan platforms) | planned |
| R03 | HARD | Critical path has a spike-free variant | planned |
| J01 | HARD | Jump gaps on critical path within physics range | implemented |
| J02 | HARD | Vertical jump up ≤ 4 tiles on critical path | implemented |
| J03 | HARD | Landing surfaces on critical path ≥ 2 tiles wide | implemented |
| P01 | HARD | Player↔exit Manhattan distance ≥ 20 tiles | implemented |
| P02 | SOFT | ≥ 3 distinct rooms (open areas split by walls/chokepoints) | planned |
| P03 | SOFT | No flat corridor ≥ 12 tiles wide without a feature | planned |
| P04 | HARD | Critical path spans ≥ 8 tiles vertically | implemented |
| H01 | HARD | Spikes on critical path must be jumpable over | planned |
| H02 | SOFT | Spike density ≤ 5% of open cells | planned |
| O01 | HARD | Bounce pads have ≥ 5 tiles clear above (no ceiling) | planned |
| O02 | SOFT | Powerups on reachable non-critical cells (optional reward) | planned |
| O03 | HARD | Dissolve blocks on critical path have a fallback path | planned |
| O04 | HARD | Exactly one P and one Q | implemented |
| S01 | HARD | Level fully wall-enclosed (no leak to void) | implemented |

---

### R01 — Exit reachable from player via jump graph

**Severity:** HARD  
**Status:** implemented  
**Description:** The exit cell must be reachable from the player start cell
using a graph where nodes are standable cells and edges are physically feasible
jumps. This replaces the naive grid BFS that treated every empty cell as
walkable.  
**Parameters:** none  
**Notes:** See `jump_graph.py` for the kinematic model.

---

### R02 — All standable cells reachable from player

**Severity:** SOFT  
**Status:** planned  
**Description:** Every standable cell in the level should be reachable from
the player. This prevents decorative orphan platforms that look like secrets but
lead nowhere.  
**Parameters:** none  
**Notes:** May be too strict for levels that intentionally have decorative
ledges. Can be relaxed to "all cells within N tiles of the critical path" later.

---

### R03 — Critical path has a spike-free variant

**Severity:** HARD  
**Status:** planned  
**Description:** The player must be able to complete the level without ever
walking *on* a spike tile. Jumping *over* spikes is allowed.  
**Parameters:** none  
**Notes:** This depends on R01's critical path. The validator checks that the
shortest/critical path never steps onto a `Y` cell.

---

### J01 — Jump gaps on critical path within physics range

**Severity:** HARD  
**Status:** implemented  
**Description:** Every consecutive pair of standable cells on the critical path
must be within the horizontal range allowed by the jump arc for their vertical
delta.  
**Parameters:** none (physics constants are hard-coded from the game)  
**Notes:** Uses the kinematic solver in `jump_graph.py`. Assumes the player can
reach `max_speed` before the jump; a runway should be provided by J03.

---

### J02 — Vertical jump up ≤ 4 tiles on critical path

**Severity:** HARD  
**Status:** implemented  
**Description:** No jump on the critical path goes up more than 4 tiles. The
player's max jump height is 72 px = 4.5 tiles, so 4 is the safe integer cap.  
**Parameters:** max_up_tiles = 4  
**Notes:** This is a simpler bound than J01's full arc check, useful as a fast
early rejection.

---

### J03 — Landing surfaces on critical path ≥ 2 tiles wide

**Severity:** HARD  
**Status:** implemented  
**Description:** Every platform the player must land on during the critical
path must be at least 2 tiles wide. One-tile landings are precise and unfair.  
**Parameters:** min_width = 2  
**Notes:** Implemented by measuring the maximal horizontal run of standable cells
at each critical-path waypoint. The path carver stamps 2-wide platforms by
construction, so this is normally a confirmation check.

---

### P01 — Player↔exit Manhattan distance ≥ 20 tiles

**Severity:** HARD  
**Status:** implemented  
**Description:** The player start and exit must be far enough apart that the
level is non-trivial.  
**Parameters:** min_distance = 20  
**Notes:** Measured on the interior grid, before the wall border is added.

---

### P02 — ≥ 3 distinct rooms

**Severity:** SOFT  
**Status:** planned  
**Description:** The level should contain at least three visually separate open
areas connected by chokepoints, to avoid a single long corridor.  
**Parameters:** min_rooms = 3  
**Notes:** Can be approximated by flood-filling open space and counting connected
components after removing narrow corridors.

---

### P03 — No flat corridor ≥ 12 tiles without a feature

**Severity:** SOFT  
**Status:** planned  
**Description:** A long flat floor should be broken up by walls, drops, hazards,
or objects so the level does not feel like a straight hallway.  
**Parameters:** max_flat_run = 12  
**Notes:** Check horizontal runs of standable cells at the same height.

---

### P04 — Critical path spans ≥ 8 tiles vertically

**Severity:** HARD  
**Status:** implemented  
**Description:** The critical path must not be a flat corridor. Its highest
and lowest standable cells must be at least 8 tiles apart vertically.  
**Parameters:** min_vertical_span = 8  
**Notes:** Satisfied by construction in the path carver: the exit is chosen with
a vertical span ≥ 8 relative to the player, and the carved path connects them.

---

### H01 — Spikes on critical path must be jumpable over

**Severity:** HARD  
**Status:** planned  
**Description:** Any spike tile that intersects the critical path must be
passable by jumping over it from a safe standable cell to another safe standable
cell. The player must never be forced to walk through a spike.  
**Parameters:** none  
**Notes:** Related to R03 but more specific: validates the geometry around each
spike, not just the path tiles.

---

### H02 — Spike density ≤ 5% of open cells

**Severity:** SOFT  
**Status:** planned  
**Description:** Spikes should be used sparingly so the level does not feel
punishing.  
**Parameters:** max_density = 0.05  
**Notes:** Counts `Y` cells against all non-solid cells.

---

### O01 — Bounce pads have clear space above

**Severity:** HARD  
**Status:** planned  
**Description:** A bounce pad (`B`) must have at least 5 tiles of clear vertical
space above it so the bounce is not immediately cancelled by a ceiling.  
**Parameters:** min_clear_tiles = 5  
**Notes:** The bounce pad multiplies jump velocity by 1.2×, so it sends the
player higher than a normal jump.

---

### O02 — Powerups on reachable non-critical cells

**Severity:** SOFT  
**Status:** planned  
**Description:** Powerups (`J`, `S`, `D`, `G`) should be placed on reachable
cells that are slightly off the critical path, acting as optional rewards or
secret routes rather than mandatory progression gates.  
**Parameters:** none  
**Notes:** For a campaign level, powerup gating may be intentional. For procedural
levels, optional placement is safer.

---

### O03 — Dissolve blocks on critical path have a fallback path

**Severity:** HARD  
**Status:** planned  
**Description:** If a `O` (dissolve block) is required to progress, there must
be an alternative route that does not depend on the block's timing.  
**Parameters:** none  
**Notes:** This prevents generator-created "soft-locks" if the player mistimes a
dissolve-block jump.

---

### O04 — Exactly one P and one Q

**Severity:** HARD  
**Status:** implemented  
**Description:** Every generated level must contain exactly one player start
(`P`) and exactly one exit (`Q`).  
**Parameters:** none  
**Notes:** The generator strips P/Q from stitched chunks and places them
manually.

---

### S01 — Level fully wall-enclosed

**Severity:** HARD  
**Status:** implemented  
**Description:** The final level must be completely surrounded by wall cells so
the player cannot walk out of the level bounds.  
**Parameters:** none  
**Notes:** The generator already wraps the stitched interior in a 1-cell wall
border before encoding.
