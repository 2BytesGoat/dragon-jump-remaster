"""Constraint registry for procedural level generation.

Each constraint is a decorated function keyed by the ID used in constraints.md.
Every function has the signature:

    (grid, width, height, params) -> (bool, str)

where params carries precomputed values such as player/exit positions and the
critical path from jump_graph.py.
"""

from typing import Callable, Dict, List, Optional, Tuple

from . import jump_graph


_REGISTRY: Dict[str, Dict] = {}


def constraint(id: str, severity: str, implemented: bool = True):
    """Decorator that registers a constraint under its ID, severity, and implementation status."""
    def deco(fn: Callable) -> Callable:
        _REGISTRY[id] = {
            "id": id,
            "severity": severity,
            "implemented": implemented,
            "fn": fn,
            "doc": fn.__doc__,
        }
        return fn
    return deco


def get_registry() -> Dict[str, Dict]:
    return _REGISTRY


def _symbol_positions(grid: List[List[str]], width: int, height: int,
                      symbol: str) -> List[Tuple[int, int]]:
    """Return all cell coordinates whose stack contains the given symbol."""
    positions = []
    for y in range(height):
        for x in range(width):
            if symbol in grid[y][x]:
                positions.append((x, y))
    return positions


# ---------------------------------------------------------------------------
# Implemented HARD constraints
# ---------------------------------------------------------------------------

@constraint("R01", "HARD")
def r01_exit_reachable(grid: List[List[str]], width: int, height: int,
                       params: Dict) -> Tuple[bool, str]:
    """Exit reachable from player via the jump graph."""
    player = params.get("player")
    exit = params.get("exit")
    if not player or not exit:
        return False, "missing player or exit position"

    # Reuse a pre-computed critical path if the validator already produced one.
    cached_path: Optional[List[Tuple[int, int]]] = params.get("critical_path")
    if cached_path is not None:
        return True, ""

    # Reuse a pre-built graph if available, otherwise build it here.
    graph: Optional[Dict[Tuple[int, int], List[Tuple[int, int]]]] = params.get("jump_graph")
    ok, reason, path = jump_graph.validate_reachability(
        grid, width, height, player, exit, graph=graph
    )
    params["critical_path"] = path  # stash for other constraints
    return ok, reason


@constraint("J01", "HARD")
def j01_jump_gaps_feasible(grid: List[List[str]], width: int, height: int,
                           params: Dict) -> Tuple[bool, str]:
    """Every jump on the critical path is within the physics-derived range."""
    path: Optional[List[Tuple[int, int]]] = params.get("critical_path")
    if not path:
        # R01 will report the reachability failure; this constraint is moot.
        return True, ""
    if len(path) < 2:
        return False, "critical path too short to check jump gaps"

    for i in range(len(path) - 1):
        a, b = path[i], path[i + 1]
        if not jump_graph.feasible_jump(grid, width, height, a, b):
            return False, f"jump from {a} to {b} exceeds physics range"

    return True, ""


@constraint("J02", "HARD")
def j02_max_jump_up(grid: List[List[str]], width: int, height: int,
                    params: Dict) -> Tuple[bool, str]:
    """No jump on the critical path goes up more than 4 tiles."""
    max_up_tiles = 4
    path: Optional[List[Tuple[int, int]]] = params.get("critical_path")
    if not path:
        return True, ""
    if len(path) < 2:
        return False, "critical path too short to check vertical jumps"

    for a, b in zip(path, path[1:]):
        dy = a[1] - b[1]  # positive = up
        if dy > max_up_tiles:
            return False, f"jump from {a} to {b} goes up {dy} tiles (max {max_up_tiles})"

    return True, ""


@constraint("P01", "HARD")
def p01_min_distance(grid: List[List[str]], width: int, height: int,
                     params: Dict) -> Tuple[bool, str]:
    """Player and exit must be at least 20 cells apart (Manhattan)."""
    min_distance = 20
    player = params.get("player")
    exit = params.get("exit")
    if not player or not exit:
        return False, "missing player or exit position"

    distance = abs(player[0] - exit[0]) + abs(player[1] - exit[1])
    if distance < min_distance:
        return False, f"player↔exit distance {distance} < {min_distance}"

    return True, ""


@constraint("P04", "HARD")
def p04_vertical_span(grid: List[List[str]], width: int, height: int,
                      params: Dict) -> Tuple[bool, str]:
    """Critical path must span at least 8 tiles vertically."""
    min_span = 8
    path: Optional[List[Tuple[int, int]]] = params.get("critical_path")
    if not path:
        return True, ""
    ys = [p[1] for p in path]
    span = max(ys) - min(ys)
    if span < min_span:
        return False, f"critical path vertical span {span} < {min_span}"
    return True, ""


@constraint("O04", "HARD")
def o04_single_player_and_exit(grid: List[List[str]], width: int, height: int,
                               params: Dict) -> Tuple[bool, str]:
    """Exactly one P and exactly one Q."""
    p_cells = _symbol_positions(grid, width, height, "P")
    q_cells = _symbol_positions(grid, width, height, "Q")

    if len(p_cells) != 1:
        return False, f"found {len(p_cells)} P cells (expected exactly 1)"
    if len(q_cells) != 1:
        return False, f"found {len(q_cells)} Q cells (expected exactly 1)"

    return True, ""


@constraint("S01", "HARD")
def s01_fully_enclosed(grid: List[List[str]], width: int, height: int,
                       params: Dict) -> Tuple[bool, str]:
    """Level is fully surrounded by wall cells."""
    # Top and bottom rows must be all walls
    for x in range(width):
        if not jump_graph.is_blocking(grid[0][x]):
            return False, f"top border cell ({x},0) is not a wall"
        if not jump_graph.is_blocking(grid[height - 1][x]):
            return False, f"bottom border cell ({x},{height-1}) is not a wall"

    # Left and right columns must be all walls
    for y in range(height):
        if not jump_graph.is_blocking(grid[y][0]):
            return False, f"left border cell (0,{y}) is not a wall"
        if not jump_graph.is_blocking(grid[y][width - 1]):
            return False, f"right border cell ({width-1},{y}) is not a wall"

    return True, ""


# ---------------------------------------------------------------------------
# Planned constraints (stubs for the coverage checker / future agent work)
# ---------------------------------------------------------------------------

@constraint("R02", "SOFT", implemented=False)
def r02_no_orphan_platforms(grid: List[List[str]], width: int, height: int,
                            params: Dict) -> Tuple[bool, str]:
    """All standable cells reachable from player (planned)."""
    return False, "R02 not yet implemented"


@constraint("R03", "HARD", implemented=False)
def r03_spike_free_path(grid: List[List[str]], width: int, height: int,
                        params: Dict) -> Tuple[bool, str]:
    """Critical path has a spike-free variant (planned)."""
    return False, "R03 not yet implemented"


@constraint("J03", "HARD")
def j03_landing_width(grid: List[List[str]], width: int, height: int,
                      params: Dict) -> Tuple[bool, str]:
    """Every critical-path landing surface must be at least 2 tiles wide."""
    min_width = 2
    path: Optional[List[Tuple[int, int]]] = params.get("critical_path")
    if not path:
        return True, ""

    def _is_standable(x: int, y: int) -> bool:
        if not (0 <= x < width and 0 <= y < height - 1):
            return False
        return jump_graph.is_open(grid[y][x]) and jump_graph.is_surface(grid[y + 1][x])

    for x, y in path:
        # Measure the maximal continuous standable run at this y that includes (x, y).
        left = x
        while left > 0 and _is_standable(left - 1, y):
            left -= 1
        right = x
        while right < width - 1 and _is_standable(right + 1, y):
            right += 1
        run_width = right - left + 1
        if run_width < min_width:
            return False, f"landing at ({x},{y}) width {run_width} < {min_width}"

    return True, ""


@constraint("P02", "SOFT", implemented=False)
def p02_min_rooms(grid: List[List[str]], width: int, height: int,
                  params: Dict) -> Tuple[bool, str]:
    """≥ 3 distinct rooms (planned)."""
    return False, "P02 not yet implemented"


@constraint("P03", "SOFT", implemented=False)
def p03_no_flat_corridor(grid: List[List[str]], width: int, height: int,
                         params: Dict) -> Tuple[bool, str]:
    """No flat corridor ≥ 12 tiles without a feature (planned)."""
    return False, "P03 not yet implemented"


@constraint("H01", "HARD", implemented=False)
def h01_spikes_jumpable(grid: List[List[str]], width: int, height: int,
                        params: Dict) -> Tuple[bool, str]:
    """Spikes on critical path must be jumpable over (planned)."""
    return False, "H01 not yet implemented"


@constraint("H02", "SOFT", implemented=False)
def h02_spike_density(grid: List[List[str]], width: int, height: int,
                      params: Dict) -> Tuple[bool, str]:
    """Spike density ≤ 5% of open cells (planned)."""
    return False, "H02 not yet implemented"


@constraint("O01", "HARD", implemented=False)
def o01_bounce_clearance(grid: List[List[str]], width: int, height: int,
                         params: Dict) -> Tuple[bool, str]:
    """Bounce pads have ≥ 5 tiles clear above (planned)."""
    return False, "O01 not yet implemented"


@constraint("O02", "SOFT", implemented=False)
def o02_powerups_off_path(grid: List[List[str]], width: int, height: int,
                          params: Dict) -> Tuple[bool, str]:
    """Powerups on reachable non-critical cells (planned)."""
    return False, "O02 not yet implemented"


@constraint("O03", "HARD", implemented=False)
def o03_dissolve_fallback(grid: List[List[str]], width: int, height: int,
                          params: Dict) -> Tuple[bool, str]:
    """Dissolve blocks on critical path have a fallback path (planned)."""
    return False, "O03 not yet implemented"
