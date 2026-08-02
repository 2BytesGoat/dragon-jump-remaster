"""Constructive critical-path carving for procedural levels.

This module builds a guaranteed-traversable path from the player start to the
exit by walking the grid cell-by-cell, stamping landing platforms and carving
jump corridors as it goes. Because every hop is verified with the same physics
model the validator uses, reachability (R01), jump range (J01), max jump up
(J02), and landing width (J03) are satisfied by construction.
"""

import math
import random
from typing import Dict, List, Optional, Set, Tuple

from . import jump_graph


# Maximum jump offsets we will consider when searching for the next waypoint.
# These are intentionally much tighter than the absolute physics limits so the
# carver produces a winding, dense path across the level rather than a few
# huge leaps.
_MAX_DX = 6
_MAX_DY_UP = 4          # matches J02
_MAX_DY_DOWN = 6


def _platform_cells(x: int, y: int, width: int = 2) -> List[Tuple[int, int]]:
    """Return the cells that make up a platform centered/starting at (x,y)."""
    return [(x + dx, y) for dx in range(width)] + [(x + dx, y + 1) for dx in range(width)]


def _is_safe_surface(cell: str) -> bool:
    """A surface the player can stand on without being killed by a hazard."""
    # Contains a surface symbol and no hazard/reset blocking symbols.
    return (
        any(s in cell for s in "WBOMI")
        and not any(s in cell for s in "YR")
    )


def _ensure_landing(grid: List[List[str]], width: int, height: int,
                    x: int, y: int, platform_width: int = 2) -> bool:
    """Make (x, y) a standable cell with at least platform_width surface below it.

    The platform is centered/anchored around (x, y) so that the path cell is
    never the rightmost tile of a 1-wide edge. This guarantees J03 landing width
    even when the path lands on the edge of an existing chunk platform.
    """
    if not (0 <= x < width and 0 <= y < height):
        return False

    # Use platform_width tiles starting at x - (platform_width // 2) so the
    # landing cell is roughly centered. For width=2 this means cells x-1 and x.
    start_x = x - (platform_width // 2)
    ok = True
    for dx in range(platform_width):
        cx = start_x + dx
        cy = y
        if not (0 <= cx < width) or cy >= height:
            ok = False
            continue
        # Clear anything blocking/hazardous from the air cell.
        if jump_graph.is_blocking(grid[cy][cx]):
            grid[cy][cx] = "E"
        floor_cy = cy + 1
        if floor_cy >= height:
            ok = False
            continue
        # Force a safe floor; plain W if the existing cell is not safe.
        if not _is_safe_surface(grid[floor_cy][cx]):
            grid[floor_cy][cx] = "W"
    return ok


def _protected_from_path(path: List[Tuple[int, int]], platform_width: int = 2) -> Set[Tuple[int, int]]:
    """Cells that support the existing path; never carve them."""
    protected: Set[Tuple[int, int]] = set()
    for x, y in path:
        protected.update(_platform_cells(x, y, platform_width))
    return protected


def _protected_floors_from_path(path: List[Tuple[int, int]], platform_width: int = 2) -> Set[Tuple[int, int]]:
    """Only the floor cells of path platforms — used for the final arc repair."""
    protected: Set[Tuple[int, int]] = set()
    for x, y in path:
        for dx in range(platform_width):
            protected.add((x + dx, y + 1))
    return protected


def choose_player(grid: List[List[str]], width: int, height: int,
                  rng: random.Random,
                  margin: int = 2) -> Tuple[int, int]:
    """Choose a lower-left standable cell, or stamp one if necessary."""
    # Prefer an existing standable surface in the lower-left quadrant.
    candidates = [
        (x, y)
        for y in range(margin, height - margin - 1)
        for x in range(margin, max(margin + 1, width // 3))
        if jump_graph.is_open(grid[y][x]) and jump_graph.is_surface(grid[y + 1][x])
    ]
    if candidates:
        return rng.choice(candidates)

    # Fallback: stamp a small platform near the lower-left corner.
    x = max(margin, width // 8)
    y = height - margin - 2
    _ensure_landing(grid, width, height, x, y, 2)
    return (x, y)


def choose_exit(grid: List[List[str]], width: int, height: int,
                player: Tuple[int, int],
                rng: random.Random,
                main_component: Optional[Set[Tuple[int, int]]] = None,
                min_distance: int = 20,
                min_vertical_span: int = 8) -> Optional[Tuple[int, int]]:
    """Pick an exit cell far from the player with enough vertical span.

    P01 (Manhattan distance) and P04 (vertical span) are satisfied by this
    choice rather than validated later.
    """
    px, py = player
    margin = 2
    candidates: List[Tuple[int, int, int, int]] = []  # x, y, dist, span

    pool = main_component if main_component else (
        ((x, y) for y in range(margin, height - margin)
         for x in range(margin, width - margin))
    )

    for x, y in pool:
        if x == px and y == py:
            continue
        # The exit must itself be able to become standable (need floor below).
        if y + 1 >= height:
            continue
        dist = abs(x - px) + abs(y - py)
        span = abs(y - py)
        if dist >= min_distance and span >= min_vertical_span:
            candidates.append((x, y, dist, span))

    if not candidates:
        return None

    # Prefer a cell visually upper-right of the player (x larger, y smaller).
    upper_right = [c for c in candidates if c[0] > px and c[1] < py]
    if upper_right:
        candidates = upper_right

    # Among the best distance+span cells, keep some randomness.
    candidates.sort(key=lambda c: (c[2], c[3]), reverse=True)
    top_n = max(1, len(candidates) // 4)
    return rng.choice(candidates[:top_n])[:2]


def _compute_target_y(player: Tuple[int, int], exit: Tuple[int, int],
                      width: int, height: int, rng: random.Random) -> List[Optional[int]]:
    """Compute a winding target height profile from the player's x to the exit's x.

    The profile is a biased random walk that ends at the exit's y, forcing the
    path to traverse a variety of vertical levels instead of hugging one floor.
    """
    px, py = player
    qx, qy = exit
    margin = 2
    target: List[Optional[int]] = [None] * width
    target[px] = py

    # Walk from player x to exit x.
    for x in range(px + 1, min(qx + 1, width)):
        prev_y = target[x - 1]
        assert prev_y is not None
        remaining = qx - x + 1
        # Bias toward the exit's y so we end near it in time.
        bias = (qy - prev_y) / remaining if remaining > 0 else 0.0
        delta = rng.choice([-3, -2, -1, 0, 1, 2, 3]) + int(round(bias))
        delta = max(-4, min(4, delta))
        y = max(margin, min(height - margin - 1, prev_y + delta))
        target[x] = y

    return target


def _score_step(current: Tuple[int, int], candidate: Tuple[int, int],
                exit: Tuple[int, int], target_y: List[Optional[int]],
                visited: Set[Tuple[int, int]]) -> Tuple[int, int, int]:
    """Lower is better: (target-y deviation, jump length, distance to exit).

    Following the precomputed winding target-y profile produces a long, varied
    path across the level. Short jumps keep the path dense and playable.
    """
    cx, cy = current
    nx, ny = candidate
    ex, ey = exit
    desired = target_y[nx]
    # If we somehow left the target range, fall back to exit distance.
    target_dev = abs(ny - desired) if desired is not None else 0
    jump_len = abs(nx - cx) + abs(ny - cy)
    dist = abs(nx - ex) + abs(ny - ey)
    visited_penalty = 2 if (nx, ny) in visited else 0
    return (target_dev, jump_len + visited_penalty, dist)


def _progress_candidates(current: Tuple[int, int], exit: Tuple[int, int],
                         grid: List[List[str]], width: int, height: int,
                         rng: random.Random,
                         dead_ends: Set[Tuple[int, int]],
                         visited: Set[Tuple[int, int]],
                         target_y: List[Optional[int]]) -> List[Tuple[int, int]]:
    """Generate standable cells that move right and follow the target profile."""
    cx, cy = current
    ex, ey = exit
    old_dist = abs(cx - ex) + abs(cy - ey)

    raw: List[Tuple[int, int, Tuple[int, int, int]]] = []  # x, y, score
    for dx in range(1, _MAX_DX + 1):  # monotonic right progress only
        for dy in range(-_MAX_DY_DOWN, _MAX_DY_UP + 1):
            nx, ny = cx + dx, cy - dy  # positive dy => candidate is above current
            if not (2 <= nx <= width - 3 and 2 <= ny <= height - 3):
                continue
            if (nx, ny) in dead_ends:
                continue
            if not jump_graph.physics_possible(current, (nx, ny)):
                continue
            new_dist = abs(nx - ex) + abs(ny - ey)
            # Allow equal-distance detours so the path can wind without getting stuck.
            if new_dist > old_dist + 4:
                continue
            score = _score_step(current, (nx, ny), exit, target_y, visited)
            raw.append((nx, ny, score))

    raw.sort(key=lambda t: t[2])
    banded: List[Tuple[int, int]] = []
    i = 0
    while i < len(raw):
        key = raw[i][2]
        band = []
        while i < len(raw) and raw[i][2] == key:
            band.append(raw[i][:2])
            i += 1
        rng.shuffle(band)
        banded.extend(band)

    return banded[:150]


def _fallback_candidates(current: Tuple[int, int], exit: Tuple[int, int],
                         grid: List[List[str]], width: int, height: int,
                         rng: random.Random,
                         dead_ends: Set[Tuple[int, int]],
                         visited: Set[Tuple[int, int]],
                         target_y: List[Optional[int]]) -> List[Tuple[int, int]]:
    """Lateral or slightly backward cells used when progress candidates fail."""
    cx, cy = current
    ex, ey = exit
    raw: List[Tuple[int, int, Tuple[int, int, int]]] = []
    for dx in range(-_MAX_DX, _MAX_DX + 1):
        for dy in range(-_MAX_DY_DOWN, _MAX_DY_UP + 1):
            if dx == 0 and dy == 0:
                continue
            nx, ny = cx + dx, cy - dy
            if not (2 <= nx <= width - 3 and 2 <= ny <= height - 3):
                continue
            if (nx, ny) in dead_ends:
                continue
            if not jump_graph.physics_possible(current, (nx, ny)):
                continue
            score = _score_step(current, (nx, ny), exit, target_y, visited)
            raw.append((nx, ny, score))

    raw.sort(key=lambda t: t[2])
    banded: List[Tuple[int, int]] = []
    i = 0
    while i < len(raw):
        key = raw[i][2]
        band = []
        while i < len(raw) and raw[i][2] == key:
            band.append(raw[i][:2])
            i += 1
        rng.shuffle(band)
        banded.extend(band)

    return banded[:80]


def _build_snake_path(grid: List[List[str]], width: int, height: int,
                      player: Tuple[int, int], exit: Tuple[int, int],
                      rng: random.Random,
                      platform_width: int = 3) -> Optional[List[Tuple[int, int]]]:
    """Build a deterministic, winding platform path from player to exit.

    The level is traversed as a series of short platforms. Consecutive platforms
    are adjacent horizontally (a 1-tile gap or overlap) with at most a 1-tile
    vertical change, so every hop is a tiny walk/jump that is almost never
    blocked by chunk walls. The vertical position meanders, spreading the path
    across the whole map.
    """
    px, py = player
    qx, qy = exit
    margin = 2

    if px >= qx:
        return None

    # Adjacent platforms: center spacing equals platform width so the rightmost
    # tile of platform i touches the leftmost tile of platform i+1.
    step = platform_width
    n_steps = max(1, (qx - px + step - 1) // step)

    # Precompute a winding y profile with at most 1-tile vertical change per step.
    profile: List[Tuple[int, int]] = []
    prev_y = py
    for i in range(n_steps + 1):
        x = min(px + i * step, qx)
        if i == 0:
            y = py
        elif i == n_steps:
            y = qy
        else:
            # Meander up/down by 1 tile, with a gentle bias toward the exit.
            t = i / n_steps
            bias = int(round((qy - prev_y) * t * 0.5))
            dy = rng.choice([-1, 0, 1]) + bias
            dy = max(-1, min(1, dy))
            y = prev_y + dy
            y = max(margin, min(height - margin - 1, y))
        profile.append((x, y))
        prev_y = y

    # Stamp platforms and collect waypoints.
    path: List[Tuple[int, int]] = [player]
    half = platform_width // 2
    for i, (cx, cy) in enumerate(profile):
        # _ensure_landing centers the platform on (cx, cy).
        _ensure_landing(grid, width, height, cx, cy, platform_width)
        for dx in range(-half, half + 1):
            wx = cx + dx
            if (wx, cy) != player and (wx, cy) != exit:
                path.append((wx, cy))
        if i == len(profile) - 1 and exit not in path:
            path.append(exit)

    if path[-1] != exit:
        _ensure_landing(grid, width, height, exit[0], exit[1], platform_width)
        path.append(exit)

    # Ensure every hop is feasible, carving if necessary.
    if not repair_path(grid, width, height, path, platform_width):
        return None

    # Repair may have damaged unrelated landings; re-anchor everything.
    for x, y in path:
        _ensure_landing(grid, width, height, x, y, 2)

    return path


def carve_path(grid: List[List[str]], width: int, height: int,
               player: Tuple[int, int], exit: Tuple[int, int],
               rng: random.Random,
               max_steps: int = 500,
               platform_width: int = 2) -> Optional[List[Tuple[int, int]]]:
    """Carve a feasible-jump path from player to exit, mutating the grid."""
    # Prefer the deterministic snake path; it is fast and guaranteed to wind.
    snake = _build_snake_path(grid, width, height, player, exit, rng,
                              platform_width=3)
    if snake is not None:
        return snake

    # Fall back to the old greedy walker if the snake fails for some reason.
    return _greedy_carve_path(grid, width, height, player, exit, rng,
                              max_steps=max_steps, platform_width=platform_width)


def _try_step(grid: List[List[str]], width: int, height: int,
              current: Tuple[int, int], next_cell: Tuple[int, int],
              protected: Set[Tuple[int, int]], platform_width: int) -> bool:
    """Stamp a landing for next_cell, carve the arc, and verify the jump."""
    if not jump_graph.physics_possible(current, next_cell):
        return False

    _ensure_landing(grid, width, height, next_cell[0], next_cell[1], platform_width)

    # Protect both the take-off and landing platforms before carving.
    step_protected = (
        protected
        | set(_platform_cells(*current, platform_width))
        | set(_platform_cells(*next_cell, platform_width))
    )

    # Physics possible, but walls might block the arc. Carve and re-check.
    if not jump_graph.feasible_jump(grid, width, height, current, next_cell):
        jump_graph.carve_arc(grid, width, height, current, next_cell, step_protected)

    return jump_graph.feasible_jump(grid, width, height, current, next_cell)


def repair_path(grid: List[List[str]], width: int, height: int,
                path: List[Tuple[int, int]], platform_width: int = 2) -> bool:
    """Ensure every hop on the carved path is feasible.

    If a hop was blocked by a wall that was protected during forward carving,
    this pass re-carves with only the two endpoints protected, then re-ensures
    those two landings so they stay standable.
    """
    for i in range(len(path) - 1):
        a, b = path[i], path[i + 1]
        if jump_graph.feasible_jump(grid, width, height, a, b):
            continue
        # Anchor both endpoints before carving the arc between them.
        _ensure_landing(grid, width, height, a[0], a[1], platform_width)
        _ensure_landing(grid, width, height, b[0], b[1], platform_width)
        protected = set(_platform_cells(*a, platform_width)) | set(_platform_cells(*b, platform_width))
        jump_graph.carve_arc(grid, width, height, a, b, protected)
        if not jump_graph.feasible_jump(grid, width, height, a, b):
            return False
    return True


def _all_hops_feasible(grid: List[List[str]], width: int, height: int,
                       path: List[Tuple[int, int]]) -> bool:
    """True if every consecutive pair of path cells is a feasible jump."""
    for i in range(len(path) - 1):
        if not jump_graph.feasible_jump(grid, width, height, path[i], path[i + 1]):
            return False
    return True


def _greedy_carve_path(grid: List[List[str]], width: int, height: int,
                       player: Tuple[int, int], exit: Tuple[int, int],
                       rng: random.Random,
                       max_steps: int = 500,
                       platform_width: int = 2) -> Optional[List[Tuple[int, int]]]:
    """Deprecated greedy path carver kept as a fallback."""
    path: List[Tuple[int, int]] = [player]
    current = player
    dead_ends: Set[Tuple[int, int]] = set()

    _ensure_landing(grid, width, height, player[0], player[1], platform_width)
    visited: Set[Tuple[int, int]] = {player}
    target_y = _compute_target_y(player, exit, width, height, rng)

    for _ in range(max_steps):
        if current == exit:
            break

        protected = _protected_from_path(path, platform_width)
        candidates = _progress_candidates(current, exit, grid, width, height,
                                          rng, dead_ends, visited, target_y)

        found = False
        for cand in candidates:
            if _try_step(grid, width, height, current, cand, protected, platform_width):
                path.append(cand)
                current = cand
                visited.add(cand)
                found = True
                break

        if not found:
            candidates = _fallback_candidates(current, exit, grid, width, height,
                                              rng, dead_ends, visited, target_y)
            for cand in candidates:
                if _try_step(grid, width, height, current, cand, protected, platform_width):
                    path.append(cand)
                    current = cand
                    visited.add(cand)
                    found = True
                    break

        if not found:
            if len(path) > 1:
                dead_ends.add(current)
                path.pop()
                current = path[-1]
            else:
                return None

    if current != exit:
        return None

    _ensure_landing(grid, width, height, exit[0], exit[1], platform_width)
    if not repair_path(grid, width, height, path, platform_width):
        return None
    for x, y in path:
        _ensure_landing(grid, width, height, x, y, platform_width)
    return path


def ensure_player_and_exit(grid: List[List[str]], width: int, height: int,
                           path: List[Tuple[int, int]]) -> Tuple[Tuple[int, int], Tuple[int, int]]:
    """Place P and Q at the endpoints of a carved path.

    Returns (player_pos, exit_pos) in the same coordinate system as the grid.
    """
    for y in range(height):
        for x in range(width):
            if grid[y][x] in ("P", "Q"):
                grid[y][x] = "E"

    p_pos = path[0]
    q_pos = path[-1]
    grid[p_pos[1]][p_pos[0]] = "P"
    grid[q_pos[1]][q_pos[0]] = "Q"
    return p_pos, q_pos
