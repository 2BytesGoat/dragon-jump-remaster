"""Run the constraint catalog against a generated level grid."""

from typing import Dict, List, Optional, Set, Tuple

from . import constraints, jump_graph


# Constraints that do not need a physics graph to run. Evaluating these first
# lets us short-circuit cheap failures before paying for build_jump_graph.
_NO_GRAPH_IDS: Set[str] = {"O04", "P01", "S01"}


def _constraint_sort_key(cid: str) -> Tuple[int, str]:
    """Sort cheap no-graph constraints first, then alphabetically."""
    return (0 if cid in _NO_GRAPH_IDS else 1, cid)


def _maybe_build_graph(grid: List[List[str]], width: int, height: int,
                       params: Dict) -> Dict[Tuple[int, int], List[Tuple[int, int]]]:
    """Return an existing graph from params or build and cache one."""
    graph = params.get("jump_graph")
    if graph is None:
        graph = jump_graph.build_jump_graph(grid, width, height)
        params["jump_graph"] = graph
    return graph


def validate(grid: List[List[str]], width: int, height: int,
             params: Dict, implemented_only: bool = False) -> List[Tuple[str, str, bool, str]]:
    """
    Run all registered constraints. Returns a list of
    (id, severity, passed, details).

    If implemented_only=True, skip constraints whose registry entry is marked
    implemented=False. This lets the generator ignore stubs while still allowing
    check_coverage.py to see them.
    """
    results = []
    registry = constraints.get_registry()

    # Run cheap no-graph constraints first, then build the graph once for any
    # remaining constraints that need it.
    cids = sorted(registry.keys(), key=_constraint_sort_key)
    graph_built = False

    for cid in cids:
        info = registry[cid]
        if implemented_only and not info.get("implemented", True):
            continue
        if cid not in _NO_GRAPH_IDS and not graph_built:
            _maybe_build_graph(grid, width, height, params)
            graph_built = True
        passed, details = info["fn"](grid, width, height, params)
        results.append((cid, info["severity"], passed, details))

    return results


def _ensure_critical_path(grid: List[List[str]], width: int, height: int,
                          params: Dict) -> None:
    """Precompute the critical path so downstream constraints can read it."""
    if "critical_path" in params:
        return
    player = params.get("player")
    exit = params.get("exit")
    if player is None or exit is None:
        params["critical_path"] = None
        return
    graph = _maybe_build_graph(grid, width, height, params)
    params["critical_path"] = jump_graph.find_path(grid, width, height, player, exit, graph=graph)


def passes_hard(grid: List[List[str]], width: int, height: int,
                params: Dict, implemented_only: bool = False,
                skip_ids: Optional[List[str]] = None) -> Tuple[bool, List[str]]:
    """Return (all_hard_passed, list_of_failed_hard_constraint_ids).

    skip_ids lets callers exclude specific constraints (e.g. the generator
    skips S01 until after the wall border is added).
    """
    failures = []
    registry = constraints.get_registry()
    skip = set(skip_ids or [])

    cids = sorted(registry.keys(), key=_constraint_sort_key)
    graph_built = False

    for cid in cids:
        info = registry[cid]
        if info["severity"] != "HARD":
            continue
        if implemented_only and not info.get("implemented", True):
            continue
        if cid in skip:
            continue

        # Build the graph the first time we hit a constraint that needs it.
        if cid not in _NO_GRAPH_IDS and not graph_built:
            _ensure_critical_path(grid, width, height, params)
            graph_built = True

        passed, details = info["fn"](grid, width, height, params)
        if not passed:
            failures.append((cid, details))

    return len(failures) == 0, failures
