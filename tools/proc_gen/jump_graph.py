"""Physics-based jump feasibility graph for platformer levels.

Models the player as a point/tile moving under the jump constants from
`src/scripts/resources/physics_params.gd` and checks whether one standable
cell can reach another in a single jump, including parabola-wall collisions.
"""

import math
from collections import deque
from typing import Dict, List, Optional, Set, Tuple

TILE = 16.0                     # px, Godot TileMap cell size
MAX_SPEED = 220.0               # px/s
JUMP_HEIGHT = 72.0              # px
TIME_TO_PEAK = 0.37             # s
TIME_TO_DESCENT = 0.23          # s
GRAVITY_ASCENT = 2.0 * JUMP_HEIGHT / (TIME_TO_PEAK ** 2)
GRAVITY_DESCENT = 2.0 * JUMP_HEIGHT / (TIME_TO_DESCENT ** 2)
JUMP_VELOCITY = GRAVITY_ASCENT * TIME_TO_PEAK
ARC_SAMPLES = 20                # collision sample points per jump


def is_blocking(cell: str) -> bool:
    """Cells the player cannot pass through mid-air.

    Walls (`W`), spikes (`Y`), reset blocks (`R`) and secret blocks (`M`)
    are all solid. Secret blocks are hidden terrain; they are not standable
    surfaces and should block arcs.
    """
    return "W" in cell or "Y" in cell or "R" in cell or "M" in cell


def is_surface(cell: str) -> bool:
    """Cells the player can stand on (wall, ice, bounce pad, dissolve)."""
    return any(s in cell for s in "WBOI")


def is_open(cell: str) -> bool:
    """Cells the player can occupy."""
    return not is_blocking(cell)


def standable_cells(grid: List[List[str]], width: int, height: int) -> List[Tuple[int, int]]:
    """Return all cells that are open and have a surface directly below them."""
    result = []
    for y in range(height - 1):
        for x in range(width):
            if is_open(grid[y][x]) and is_surface(grid[y + 1][x]):
                result.append((x, y))
    return result


def _height_at_time(t: float, kind: str = "normal") -> float:
    """Vertical displacement (px) above the take-off floor at time t.

    kind can be "normal", "double" (two consecutive jumps), or "bounce"
    (up-facing bounce pad: 1.2x jump velocity, same gravity).
    """
    if kind == "normal":
        if t <= TIME_TO_PEAK:
            return JUMP_VELOCITY * t - 0.5 * GRAVITY_ASCENT * t * t
        dt = t - TIME_TO_PEAK
        return JUMP_HEIGHT - 0.5 * GRAVITY_DESCENT * dt * dt

    if kind == "bounce":
        # Up-facing pad: initial velocity = 1.2 * JUMP_VELOCITY, same ascent gravity.
        peak_t = 1.2 * TIME_TO_PEAK
        peak_h = 1.44 * JUMP_HEIGHT
        if t <= peak_t:
            return 1.2 * JUMP_VELOCITY * t - 0.5 * GRAVITY_ASCENT * t * t
        dt = t - peak_t
        return peak_h - 0.5 * GRAVITY_DESCENT * dt * dt

    if kind == "double":
        # Two consecutive full jumps. First jump peaks at TIME_TO_PEAK; second jump
        # starts immediately at the apex and peaks again at 2*TIME_TO_PEAK.
        if t <= TIME_TO_PEAK:
            return JUMP_VELOCITY * t - 0.5 * GRAVITY_ASCENT * t * t
        if t <= 2.0 * TIME_TO_PEAK:
            dt = t - TIME_TO_PEAK
            return JUMP_HEIGHT + JUMP_VELOCITY * dt - 0.5 * GRAVITY_ASCENT * dt * dt
        dt = t - 2.0 * TIME_TO_PEAK
        return 2.0 * JUMP_HEIGHT - 0.5 * GRAVITY_DESCENT * dt * dt

    raise ValueError(f"unknown arc kind: {kind}")


def _airtime_for_vertical_delta(dy_px: float, kind: str = "normal") -> Optional[float]:
    """Total airtime for a jump of the given kind landing dy_px above take-off."""
    if kind == "normal":
        max_height = JUMP_HEIGHT
        extra_ascent_time = 0.0
    elif kind == "bounce":
        max_height = 1.44 * JUMP_HEIGHT
        extra_ascent_time = 0.2 * TIME_TO_PEAK  # ascent takes 1.2*TIME_TO_PEAK
    elif kind == "double":
        max_height = 2.0 * JUMP_HEIGHT
        extra_ascent_time = TIME_TO_PEAK
    else:
        raise ValueError(f"unknown arc kind: {kind}")

    if dy_px > max_height:
        return None

    if dy_px >= 0:
        fall_distance = max_height - dy_px
        fall_time = math.sqrt(2.0 * fall_distance / GRAVITY_DESCENT)
        return TIME_TO_PEAK + extra_ascent_time + fall_time
    else:
        fall_distance = max_height + abs(dy_px)
        fall_time = math.sqrt(2.0 * fall_distance / GRAVITY_DESCENT)
        return TIME_TO_PEAK + extra_ascent_time + fall_time


def _arc_collision(grid: List[List[str]], width: int, height: int,
                   ax: int, ay: int, bx: int, by: int, airtime: float,
                   kind: str = "normal", speed: float = MAX_SPEED) -> bool:
    """
    Sample the jump arc and return True if any blocking cell is hit.
    The player is approximated as a 16x16 tile centered on the parabola.

    kind selects the arc shape (normal, double, bounce). ``speed`` is the
    horizontal speed used for the arc; using the exact speed needed to reach
    ``b`` avoids the old assumption that every jump is taken at ``MAX_SPEED``,
    which made tiny hops overshoot and hit walls.
    """
    if airtime <= 0:
        return False

    direction = 0 if bx == ax else (1 if bx > ax else -1)
    start_feet_px = (ay + 1) * TILE  # feet stand on top of surface below
    horizontal_gap_px = abs(bx - ax) * TILE

    # The player needs to cover the horizontal gap within ``airtime`` seconds.
    # If the destination is level or below, the jump ends once that distance is
    # covered, so there is no need to sample past that moment.
    t_horizontal = horizontal_gap_px / speed if speed > 0 else airtime
    dy_px = (ay - by) * TILE
    if dy_px <= 0:
        t_max = min(airtime, t_horizontal)
    else:
        t_max = airtime

    for i in range(1, ARC_SAMPLES):
        t = t_max * i / ARC_SAMPLES
        height_px = _height_at_time(t, kind=kind)
        dx_px = speed * t

        center_x_px = ax * TILE + TILE / 2.0 + direction * dx_px
        center_y_px = start_feet_px - height_px - TILE / 2.0

        # The player is a 16x16 tile: box spans center +/- 8 px.
        x0 = int(math.floor((center_x_px - TILE / 2.0) / TILE))
        x1 = int(math.floor((center_x_px + TILE / 2.0) / TILE))
        y0 = int(math.floor((center_y_px - TILE / 2.0) / TILE))
        y1 = int(math.floor((center_y_px + TILE / 2.0) / TILE))

        for gx in range(x0, x1 + 1):
            for gy in range(y0, y1 + 1):
                if not (0 <= gx < width and 0 <= gy < height):
                    continue
                if is_blocking(grid[gy][gx]):
                    # Allow the start/end standable cells and their floors.
                    if (gx, gy) in ((ax, ay), (bx, by),
                                    (ax, ay + 1), (bx, by + 1)):
                        continue
                    return True

    return False


def feasible_jump(grid: List[List[str]], width: int, height: int,
                  a: Tuple[int, int], b: Tuple[int, int],
                  kind: str = "normal") -> bool:
    """
    True if the player can jump from standable cell a to standable cell b.
    Models horizontal range, max jump height, and wall collisions along the arc.
    kind selects "normal", "double" (double jump), or "bounce" (up-facing pad).
    """
    ax, ay = a
    bx, by = b

    # Walking adjacency is always feasible (no jump needed)
    if abs(bx - ax) <= 1 and abs(by - ay) <= 1 and (bx, by) != (ax, ay):
        if abs(bx - ax) + abs(by - ay) == 1:
            return True

    if kind == "normal":
        max_dy = JUMP_HEIGHT
        max_speed = MAX_SPEED
    elif kind == "bounce":
        max_dy = 1.44 * JUMP_HEIGHT
        max_speed = MAX_SPEED
    elif kind == "double":
        max_dy = 2.0 * JUMP_HEIGHT
        max_speed = MAX_SPEED
    else:
        raise ValueError(f"unknown jump kind: {kind}")

    dy_px = (ay - by) * TILE  # positive = b is above a
    if dy_px > max_dy:
        return False

    airtime = _airtime_for_vertical_delta(dy_px, kind=kind)
    if airtime is None:
        return False

    horizontal_gap_px = abs(bx - ax) * TILE
    max_horizontal_px = max_speed * airtime
    if horizontal_gap_px > max_horizontal_px:
        return False

    # Use the exact horizontal speed needed to reach ``b`` in ``airtime``
    # seconds. This makes tiny hops nearly vertical and avoids false collisions
    # with walls that only block the high-speed trajectory.
    required_speed = horizontal_gap_px / airtime if airtime > 0 else max_speed
    return not _arc_collision(grid, width, height, ax, ay, bx, by, airtime,
                             kind=kind, speed=required_speed)


def physics_possible(a: Tuple[int, int], b: Tuple[int, int],
                     kind: str = "normal") -> bool:
    """True if the raw jump physics (height + horizontal range) allow a→b.

    This ignores wall collisions along the arc. Useful for the path carver, which
    can clear walls but cannot change the jump height/speed constants.
    """
    ax, ay = a
    bx, by = b

    # Walking adjacency is always feasible (handled by feasible_jump as well)
    if abs(bx - ax) <= 1 and abs(by - ay) <= 1 and (bx, by) != (ax, ay):
        if abs(bx - ax) + abs(by - ay) == 1:
            return True

    if kind == "normal":
        max_dy = JUMP_HEIGHT
        max_speed = MAX_SPEED
    elif kind == "bounce":
        max_dy = 1.44 * JUMP_HEIGHT
        max_speed = MAX_SPEED
    elif kind == "double":
        max_dy = 2.0 * JUMP_HEIGHT
        max_speed = MAX_SPEED
    else:
        raise ValueError(f"unknown jump kind: {kind}")

    dy_px = (ay - by) * TILE
    if dy_px > max_dy:
        return False

    airtime = _airtime_for_vertical_delta(dy_px, kind=kind)
    if airtime is None:
        return False

    horizontal_gap_px = abs(bx - ax) * TILE
    return horizontal_gap_px <= max_speed * airtime


def carve_arc(grid: List[List[str]], width: int, height: int,
              a: Tuple[int, int], b: Tuple[int, int],
              protected: Optional[Set[Tuple[int, int]]] = None,
              kind: str = "normal") -> int:
    """Clear blocking cells in the jump arc from a to b. Returns cells changed.

    kind selects normal, double, or bounce arc shapes. Cells listed in
    `protected` (e.g. platform floors) are left untouched. Start/end standable
    cells are always protected.
    """
    ax, ay = a
    bx, by = b
    protected = protected or set()

    dy_px = (ay - by) * TILE
    airtime = _airtime_for_vertical_delta(dy_px, kind=kind)
    if airtime is None:
        return 0

    direction = 0 if bx == ax else (1 if bx > ax else -1)
    start_feet_px = (ay + 1) * TILE
    horizontal_gap_px = abs(bx - ax) * TILE
    # Carve the actual trajectory needed to reach b, not the fastest possible one.
    speed = horizontal_gap_px / airtime if airtime > 0 else MAX_SPEED
    changed = 0

    for i in range(1, ARC_SAMPLES):
        t = airtime * i / ARC_SAMPLES
        height_px = _height_at_time(t, kind=kind)
        dx_px = speed * t

        center_x_px = ax * TILE + TILE / 2.0 + direction * dx_px
        center_y_px = start_feet_px - height_px - TILE / 2.0

        # The player is a 16x16 tile: box spans center +/- 8 px.
        x0 = int(math.floor((center_x_px - TILE / 2.0) / TILE))
        x1 = int(math.floor((center_x_px + TILE / 2.0) / TILE))
        y0 = int(math.floor((center_y_px - TILE / 2.0) / TILE))
        y1 = int(math.floor((center_y_px + TILE / 2.0) / TILE))

        for gx in range(x0, x1 + 1):
            for gy in range(y0, y1 + 1):
                if not (0 <= gx < width and 0 <= gy < height):
                    continue
                # Never carve the start/end standable cells or their floors.
                if (gx, gy) in (a, b, (a[0], a[1] + 1), (b[0], b[1] + 1)):
                    continue
                if (gx, gy) in protected:
                    continue
                if is_blocking(grid[gy][gx]):
                    grid[gy][gx] = "E"
                    changed += 1

    return changed


def build_jump_graph(grid: List[List[str]], width: int, height: int,
                     kind: str = "normal") -> Dict[Tuple[int, int], List[Tuple[int, int]]]:
    """Build a directed graph of feasible jumps between standable cells.

    Edges are one-way because a fall that is easy downward is not a jump upward.
    kind selects the jump mode ("normal", "double", or "bounce").
    """
    standables = standable_cells(grid, width, height)
    graph: Dict[Tuple[int, int], List[Tuple[int, int]]] = {s: [] for s in standables}

    if kind == "normal":
        max_height = JUMP_HEIGHT
    elif kind == "bounce":
        max_height = 1.44 * JUMP_HEIGHT
    elif kind == "double":
        max_height = 2.0 * JUMP_HEIGHT
    else:
        raise ValueError(f"unknown jump kind: {kind}")

    max_speed = MAX_SPEED

    for a in standables:
        ax, ay = a
        # Only consider b within a reasonable bounding box; the physics check
        # will reject anything outside the real range.
        max_dx = int(math.ceil((max_speed * (TIME_TO_PEAK + TIME_TO_DESCENT + (max_height - JUMP_HEIGHT) / JUMP_VELOCITY)) / TILE)) + 2
        max_dy_up = int(math.ceil(max_height / TILE)) + 2
        max_dy_down = 12  # generous, falls can be long

        for b in standables:
            if a == b:
                continue
            bx, by = b
            if abs(bx - ax) > max_dx:
                continue
            if by < ay - max_dy_up or by > ay + max_dy_down:
                continue

            if feasible_jump(grid, width, height, a, b, kind=kind):
                graph[a].append(b)

    return graph


def _powerup_positions(grid: List[List[str]], width: int, height: int) -> Tuple[List[Tuple[int, int]], List[Tuple[int, int]]]:
    """Return (double_jump_pickups, bounce_pad_surfaces) as standable cells.

    A double-jump pickup `J` is effective when the player is at the same cell.
    A bounce pad `B` is effective when the player stands on it (surface below is B).
    """
    double_pickups: List[Tuple[int, int]] = []
    bounce_pads: List[Tuple[int, int]] = []
    for y in range(height - 1):
        for x in range(width):
            if is_open(grid[y][x]) and is_surface(grid[y + 1][x]):
                if "J" in grid[y][x]:
                    double_pickups.append((x, y))
                if "B" in grid[y + 1][x]:
                    bounce_pads.append((x, y))
    return double_pickups, bounce_pads


def build_jump_graph_with_powerups(grid: List[List[str]], width: int, height: int,
                                   max_charges: int = 3) -> Dict[Tuple[Tuple[int, int], int], List[Tuple[Tuple[int, int], int]]]:
    """Build a directed state graph supporting double-jump and bounce-pad edges.

    State = (standable_cell, double_jump_charges). Walking edges keep the current
    charge count. Bounce-pad take-offs use kind="bounce". Double-jump take-offs
    spend one charge and use kind="double". Charges refill to max when stepping
    onto a cell containing a `J` pickup, up to a cap of `max_charges`.
    """
    standables = standable_cells(grid, width, height)
    double_pickups, bounce_pads = _powerup_positions(grid, width, height)
    pickup_set = set(double_pickups)
    bounce_set = set(bounce_pads)

    states: List[Tuple[Tuple[int, int], int]] = []
    for cell in standables:
        for charges in range(max_charges + 1):
            states.append((cell, charges))

    graph: Dict[Tuple[Tuple[int, int], int], List[Tuple[Tuple[int, int], int]]] = {s: [] for s in states}

    for a, charges in states:
        ax, ay = a

        # Bounding box covers both normal and double-jump arcs.
        max_dx = int(math.ceil((MAX_SPEED * (TIME_TO_PEAK + TIME_TO_DESCENT + (2.0 * JUMP_HEIGHT - JUMP_HEIGHT) / JUMP_VELOCITY)) / TILE)) + 2
        max_dy_up = int(math.ceil(2.0 * JUMP_HEIGHT / TILE)) + 2
        max_dy_down = 12

        for b in standables:
            if a == b:
                continue
            bx, by = b
            if abs(bx - ax) > max_dx:
                continue
            if by < ay - max_dy_up or by > ay + max_dy_down:
                continue

            # Choose the best available jump kind for this edge.
            is_bounce = a in bounce_set
            if is_bounce and feasible_jump(grid, width, height, a, b, kind="bounce"):
                new_charges = min(max_charges, charges + (1 if b in pickup_set else 0))
                graph[(a, charges)].append((b, new_charges))
                continue

            if charges > 0 and feasible_jump(grid, width, height, a, b, kind="double"):
                new_charges = min(max_charges, charges - 1 + (1 if b in pickup_set else 0))
                graph[(a, charges)].append((b, new_charges))
                continue

            if feasible_jump(grid, width, height, a, b, kind="normal"):
                new_charges = min(max_charges, charges + (1 if b in pickup_set else 0))
                graph[(a, charges)].append((b, new_charges))

    return graph


def find_path_with_powerups(grid: List[List[str]], width: int, height: int,
                            start: Tuple[int, int], end: Tuple[int, int],
                            graph: Optional[Dict[Tuple[Tuple[int, int], int], List[Tuple[Tuple[int, int], int]]]] = None,
                            max_charges: int = 3) -> Optional[List[Tuple[Tuple[int, int], int]]]:
    """Return a shortest path of (cell, charge) states, or None."""
    if graph is None:
        graph = build_jump_graph_with_powerups(grid, width, height, max_charges=max_charges)

    start_states = [(start, c) for c in range(max_charges + 1) if (start, c) in graph]
    end_states = [(end, c) for c in range(max_charges + 1) if (end, c) in graph]
    if not start_states or not end_states:
        return None

    queue: deque[Tuple[Tuple[int, int], int, List[Tuple[Tuple[int, int], int]]]] = deque(
        [(cell, c, [(cell, c)]) for cell, c in start_states]
    )
    visited: Set[Tuple[Tuple[int, int], int]] = set(start_states)

    while queue:
        cell, charges, path = queue.popleft()
        if cell == end:
            return path

        for neighbor, new_charges in graph[(cell, charges)]:
            state = (neighbor, new_charges)
            if state not in visited:
                visited.add(state)
                queue.append((neighbor, new_charges, path + [state]))

    return None


def find_path(grid: List[List[str]], width: int, height: int,
              start: Tuple[int, int], end: Tuple[int, int],
              graph: Optional[Dict[Tuple[int, int], List[Tuple[int, int]]]] = None,
              with_powerups: bool = False,
              powerup_graph: Optional[Dict[Tuple[Tuple[int, int], int], List[Tuple[Tuple[int, int], int]]]] = None,
              max_charges: int = 3) -> Optional[List[Tuple[int, int]]]:
    """Return a shortest path of standable cells from start to end, or None.

    If with_powerups=True, uses the powerup-aware state graph. The returned path
    only includes the cell sequence; charge information is discarded.
    """
    if with_powerups:
        ppath = find_path_with_powerups(grid, width, height, start, end, graph=powerup_graph, max_charges=max_charges)
        if ppath is None:
            return None
        return [cell for cell, _charges in ppath]

    if graph is None:
        graph = build_jump_graph(grid, width, height)

    if start not in graph or end not in graph:
        return None

    queue: deque[Tuple[Tuple[int, int], List[Tuple[int, int]]]] = deque([(start, [start])])
    visited: Set[Tuple[int, int]] = {start}

    while queue:
        current, path = queue.popleft()
        if current == end:
            return path

        for neighbor in graph[current]:
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append((neighbor, path + [neighbor]))

    return None


def validate_reachability(grid: List[List[str]], width: int, height: int,
                          start: Tuple[int, int], end: Tuple[int, int],
                          graph: Optional[Dict[Tuple[int, int], List[Tuple[int, int]]]] = None,
                          with_powerups: bool = False,
                          powerup_graph: Optional[Dict[Tuple[Tuple[int, int], int], List[Tuple[Tuple[int, int], int]]]] = None,
                          max_charges: int = 3) -> Tuple[bool, str, Optional[List[Tuple[int, int]]]]:
    """
    Wrapper for the validator. Returns (ok, reason, critical_path).
    If ok is False, reason explains why; critical_path is None in that case.
    """
    path = find_path(grid, width, height, start, end,
                     graph=graph, with_powerups=with_powerups,
                     powerup_graph=powerup_graph, max_charges=max_charges)
    if path is None:
        # Build a concise diagnostic if start/end are not standable.
        standables = standable_cells(grid, width, height)
        if start not in standables:
            return False, f"player cell {start} is not standable", None
        if end not in standables:
            return False, f"exit cell {end} is not standable", None
        return False, f"exit {end} not reachable from player {start} via jump graph", None

    return True, "", path
