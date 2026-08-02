#!/usr/bin/env python3
"""
Procedural level spike for Dragon Jump Remaster.

Reads levels 1-1 through 1-17, strips the exterior wall padding, slices the
authored interiors into N×N chunks, and stitches a new level by matching chunk
edge sockets. The stitched interior is validated against the constraint catalog
in constraints.md (see jump_graph.py and validator.py). The result is written
into resources/level_data/tmp.tres so it can be loaded in Godot for manual
evaluation.

Run from the project root:
    python3 tools/proc_gen/spike.py

Optional flags:
    --seed N          RNG seed (default 1)
    --size WxH        Interior dimensions in cells (default 42x24)
    --chunk N         Chunk size (default 6)
    --max-retries N   Number of seeds to try if generation fails (default 20)
    --dry-run         Analyze and generate but do not overwrite tmp.tres
    --check-coverage  Only run constraints.md -> constraints.py coverage check
    --validate CODE   Validate a level code string against the catalog
"""

import argparse
import random
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path
from typing import Dict, List, Optional, Tuple

PROJECT_ROOT = Path(__file__).resolve().parents[2]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from tools.proc_gen import check_coverage, constraints, jump_graph, path_skeleton, validator


LEVEL_DATA_DIR = PROJECT_ROOT / "resources" / "level_data"
TMP_LEVEL_PATH = LEVEL_DATA_DIR / "tmp.tres"

SYMBOLS_RE = re.compile(r'([A-Za-z]+)(\d*)')


class Chunk:
    """A square slice of a level with edge socket metadata."""

    def __init__(self, grid: List[List[str]], source: str):
        self.size = len(grid)
        self.grid = [row[:] for row in grid]  # deep copy
        self.source = source
        self.top = tuple(is_solid(grid[0][x]) for x in range(self.size))
        self.bottom = tuple(is_solid(grid[self.size - 1][x]) for x in range(self.size))
        self.left = tuple(is_solid(grid[y][0]) for y in range(self.size))
        self.right = tuple(is_solid(grid[y][self.size - 1]) for y in range(self.size))
        self.has_player = any(cell == "P" for row in grid for cell in row)
        self.has_exit = any(cell == "Q" for row in grid for cell in row)

    def key(self) -> Tuple[Tuple[str, ...], ...]:
        """Hashable representation for deduplication."""
        return tuple(tuple(row) for row in self.grid)

    def __repr__(self) -> str:
        return f"Chunk({self.size}x{self.size} from {self.source})"


def is_solid(cell: str) -> bool:
    """True if the cell stack blocks movement (contains a wall)."""
    return jump_graph.is_blocking(cell)


def parse_level_code(code: str) -> Tuple[List[List[str]], int, int]:
    """Parse a level code string into a 2D grid of cell symbol stacks."""
    rows = code.split("|")
    grid: List[List[str]] = []
    width = 0

    for row_code in rows:
        cells: List[str] = []
        i = 0
        while i < len(row_code):
            # Accumulate letters (one or more tile symbols)
            symbols = ""
            while i < len(row_code) and row_code[i].isalpha():
                symbols += row_code[i]
                i += 1

            # Accumulate digits for the count
            count_str = ""
            while i < len(row_code) and row_code[i].isdigit():
                count_str += row_code[i]
                i += 1

            count = int(count_str) if count_str else 1
            cells.extend([symbols] * count)

        width = max(width, len(cells))
        grid.append(cells)

    height = len(grid)

    # Pad short rows with empty cells so the grid is rectangular
    for row in grid:
        while len(row) < width:
            row.append("E")

    return grid, width, height


def fill_walls(grid: List[List[str]], width: int) -> None:
    """Mirror Level._fill_rectangle_with_walls: leading/trailing E -> W per row."""
    for row in grid:
        for x in range(width):
            if row[x] != "E":
                break
            row[x] = "W"
        for x in range(width - 1, -1, -1):
            if row[x] != "E":
                break
            row[x] = "W"


def extract_interior(grid: List[List[str]], width: int, height: int,
                     chunk_size: int) -> Tuple[List[List[str]], int, int]:
    """
    Crop to the bounding box of non-wall cells, then expand right/down so the
    dimensions are multiples of chunk_size. This keeps non-overlapping chunks
    clean while preserving as much authored wall structure as possible.
    """
    min_x, max_x = width, -1
    min_y, max_y = height, -1

    for y in range(height):
        for x in range(width):
            if not is_solid(grid[y][x]):
                min_x = min(min_x, x)
                max_x = max(max_x, x)
                min_y = min(min_y, y)
                max_y = max(max_y, y)

    if max_x < 0:
        # Degenerate: all walls. Return a minimal empty interior.
        return [["E" for _ in range(chunk_size)] for _ in range(chunk_size)], chunk_size, chunk_size

    bbox_w = max_x - min_x + 1
    bbox_h = max_y - min_y + 1

    # Expand to multiple of chunk_size, clamped to original grid bounds
    new_w = ((bbox_w + chunk_size - 1) // chunk_size) * chunk_size
    new_h = ((bbox_h + chunk_size - 1) // chunk_size) * chunk_size

    extra_w = new_w - bbox_w
    extra_h = new_h - bbox_h

    start_x = min_x
    end_x = min(max_x + 1 + extra_w, width)
    # If expansion would exceed grid width, shift left instead
    if end_x > width:
        start_x = max(0, start_x - (end_x - width))
        end_x = width

    start_y = min_y
    end_y = min(max_y + 1 + extra_h, height)
    if end_y > height:
        start_y = max(0, start_y - (end_y - height))
        end_y = height

    interior = [row[start_x:end_x] for row in grid[start_y:end_y]]
    return interior, end_x - start_x, end_y - start_y


def slice_chunks(grid: List[List[str]], width: int, height: int,
                 chunk_size: int, source: str) -> List[Chunk]:
    """Slice a rectangular interior into non-overlapping N×N chunks."""
    chunks: List[Chunk] = []
    cols = width // chunk_size
    rows = height // chunk_size

    for cy in range(rows):
        for cx in range(cols):
            x0 = cx * chunk_size
            y0 = cy * chunk_size
            chunk_grid = [
                grid[y][x0:x0 + chunk_size]
                for y in range(y0, y0 + chunk_size)
            ]
            chunks.append(Chunk(chunk_grid, source))

    return chunks


def load_level(path: Path) -> Tuple[str, str]:
    """Return (level_id, code) from a .tres level resource."""
    text = path.read_text(encoding="utf-8")
    level_id = ""
    code = ""

    for line in text.splitlines():
        line = line.strip()
        if line.startswith("level_id ="):
            level_id = line.split("=", 1)[1].strip().strip('"')
        elif line.startswith("code ="):
            code = line.split("=", 1)[1].strip().strip('"')

    return level_id, code


def load_all_levels() -> List[Tuple[str, str, List[List[str]], int, int]]:
    """Load 1-1..1-17 and return parsed, wall-filled, but not-yet-cropped grids."""
    levels = []
    for path in sorted(LEVEL_DATA_DIR.glob("1-*.tres")):
        level_id, code = load_level(path)
        if not code:
            continue
        grid, width, height = parse_level_code(code)
        fill_walls(grid, width)
        levels.append((level_id, code, grid, width, height))
    return levels


def analyze(levels: List[Tuple[str, str, List[List[str]], int, int]],
            chunk_size: int) -> List[Chunk]:
    """Print analysis, return the deduplicated chunk library."""
    print(f"\n=== Analysis (chunk size = {chunk_size}) ===\n")

    symbol_counter: Counter = Counter()
    total_interior_cells = 0
    all_chunks: List[Chunk] = []

    for level_id, code, grid, width, height in levels:
        interior, iw, ih = extract_interior(grid, width, height, chunk_size)
        chunks = slice_chunks(interior, iw, ih, chunk_size, level_id)
        all_chunks.extend(chunks)

        # Count symbols in the interior
        for row in interior:
            for cell in row:
                for symbol in cell:
                    symbol_counter[symbol] += 1
                total_interior_cells += len(cell)  # count each stack once

        print(f"{level_id:6} full {width:3}x{height:3}  ->  interior {iw:3}x{ih:3}  ({len(chunks):3} chunks)")

    # Deduplicate chunks
    seen = set()
    unique_chunks: List[Chunk] = []
    for chunk in all_chunks:
        key = chunk.key()
        if key not in seen:
            seen.add(key)
            unique_chunks.append(chunk)

    # Socket analysis
    socket_pairs = Counter()
    for chunk in unique_chunks:
        socket_pairs[(chunk.left, chunk.right)] += 1
        socket_pairs[(chunk.top, chunk.bottom)] += 1

    print(f"\nAggregate:")
    print(f"  Raw chunks:        {len(all_chunks)}")
    print(f"  Unique chunks:     {len(unique_chunks)}")
    print(f"  Socket pair kinds: {len(socket_pairs)}")

    print(f"\nInterior symbol frequency (stacks counted once per cell):")
    for symbol, count in symbol_counter.most_common():
        pct = 100.0 * count / total_interior_cells if total_interior_cells else 0.0
        print(f"  {symbol:2} : {count:5}  ({pct:5.1f}%)")

    return unique_chunks


def build_chunk_library(chunks: List[Chunk]) -> Dict[Tuple[Tuple[bool, ...], Tuple[bool, ...]], List[Chunk]]:
    """
    Index chunks by their (left_socket, top_socket) pair. This lets the stitcher
    quickly find candidates that match both the left neighbour and the one above.
    """
    index: Dict[Tuple[Tuple[bool, ...], Tuple[bool, ...]], List[Chunk]] = defaultdict(list)
    for chunk in chunks:
        if chunk.has_player or chunk.has_exit:
            # We place P and Q manually, so exclude authored spawn/exit rooms
            continue
        index[(chunk.left, chunk.top)].append(chunk)
    return index


def pick_chunk(index: Dict[Tuple[Tuple[bool, ...], Tuple[bool, ...]], List[Chunk]],
               all_chunks: List[Chunk],
               left_required: Optional[Tuple[bool, ...]],
               top_required: Optional[Tuple[bool, ...]]) -> Chunk:
    """
    Pick a chunk that matches the required left and top sockets as closely as
    possible. Falls back from exact match -> partial match -> random.
    """
    rng = random

    # Exact: both left and top match
    if left_required is not None and top_required is not None:
        candidates = index.get((left_required, top_required), [])
        if candidates:
            return rng.choice(candidates)

    # Partial: match left socket, any top
    if left_required is not None:
        left_candidates = [c for c in all_chunks if c.left == left_required and not c.has_player and not c.has_exit]
        if left_candidates:
            return rng.choice(left_candidates)

    # Partial: match top socket, any left
    if top_required is not None:
        top_candidates = [c for c in all_chunks if c.top == top_required and not c.has_player and not c.has_exit]
        if top_candidates:
            return rng.choice(top_candidates)

    # Fallback: any non-spawn/exit chunk
    safe_chunks = [c for c in all_chunks if not c.has_player and not c.has_exit]
    return rng.choice(safe_chunks if safe_chunks else all_chunks)


def generate_interior(chunks: List[Chunk], target_w: int, target_h: int,
                      chunk_size: int) -> List[List[str]]:
    """Stitch chunks into an interior grid of the requested size."""
    if target_w % chunk_size != 0 or target_h % chunk_size != 0:
        raise ValueError(f"Target size {target_w}x{target_h} must be a multiple of chunk size {chunk_size}")

    cols = target_w // chunk_size
    rows = target_h // chunk_size

    index = build_chunk_library(chunks)
    all_safe = [c for c in chunks if not c.has_player and not c.has_exit]

    # Place grid of chunk references first
    placed: List[List[Optional[Chunk]]] = [[None for _ in range(cols)] for _ in range(rows)]

    for y in range(rows):
        for x in range(cols):
            left_required = placed[y][x - 1].right if x > 0 and placed[y][x - 1] else None
            top_required = placed[y - 1][x].bottom if y > 0 and placed[y - 1][x] else None

            chunk = pick_chunk(index, all_safe, left_required, top_required)
            placed[y][x] = chunk

    # Build the full interior grid from the placed chunks
    interior: List[List[str]] = [["E" for _ in range(target_w)] for _ in range(target_h)]
    for cy in range(rows):
        for cx in range(cols):
            chunk = placed[cy][cx]
            x0 = cx * chunk_size
            y0 = cy * chunk_size
            for dy in range(chunk_size):
                for dx in range(chunk_size):
                    interior[y0 + dy][x0 + dx] = chunk.grid[dy][dx]

    return interior


def find_main_standable_component(grid: List[List[str]], width: int, height: int) -> Tuple[Set[Tuple[int, int]], int]:
    """
    Return the largest connected component of standable cells (via jump graph)
    and its size.
    """
    graph = jump_graph.build_jump_graph(grid, width, height)
    if not graph:
        return set(), 0

    visited: Set[Tuple[int, int]] = set()
    best_component: Set[Tuple[int, int]] = set()
    best_size = 0

    for start in graph:
        if start in visited:
            continue
        component = set()
        stack = [start]
        while stack:
            cell = stack.pop()
            if cell in component:
                continue
            component.add(cell)
            visited.add(cell)
            for neighbor in graph[cell]:
                if neighbor not in component:
                    stack.append(neighbor)
        if len(component) > best_size:
            best_size = len(component)
            best_component = component

    return best_component, best_size


def cleanup_orphan_standable_cells(grid: List[List[str]], width: int, height: int,
                                   main_component: Set[Tuple[int, int]]) -> None:
    """Convert all standable cells outside the main component into walls."""
    for y in range(height):
        for x in range(width):
            if (x, y) in main_component:
                continue
            if (x, y) in jump_graph.standable_cells(grid, width, height):
                # This cell is standable but not in the main component; seal it.
                grid[y][x] = "W"


def place_player_and_exit(grid: List[List[str]], width: int, height: int,
                          allowed: Optional[Set[Tuple[int, int]]] = None) -> Tuple[bool, Tuple[int, int], Tuple[int, int]]:
    """
    Place exactly one P and one Q on standable cells. Returns (success, p_pos, q_pos).
    P is biased to lower-left; Q to upper-right to mimic typical level pacing.
    If `allowed` is given, restrict placement to that set.
    """
    rng = random

    # Clear any existing P/Q from the stitched grid (shouldn't be any, but be safe)
    for y in range(height):
        for x in range(width):
            if grid[y][x] in ("P", "Q"):
                grid[y][x] = "E"

    standable = set(jump_graph.standable_cells(grid, width, height))
    if allowed is not None:
        standable &= allowed
    if len(standable) < 2:
        return False, (-1, -1), (-1, -1)

    p_candidates = [s for s in standable if s[0] < width * 0.4 and s[1] > height * 0.5]
    q_candidates = [s for s in standable if s[0] > width * 0.5 and s[1] < height * 0.4]

    if not p_candidates:
        p_candidates = list(standable)
    if not q_candidates:
        q_candidates = list(standable)

    p_pos = rng.choice(p_candidates)
    q_pool = [c for c in q_candidates if c != p_pos]
    if not q_pool:
        q_pool = [c for c in standable if c != p_pos]
    if not q_pool:
        return False, p_pos, (-1, -1)

    q_pos = rng.choice(q_pool)

    grid[p_pos[1]][p_pos[0]] = "P"
    grid[q_pos[1]][q_pos[0]] = "Q"

    return True, p_pos, q_pos


def add_wall_border(grid: List[List[str]], width: int, height: int) -> Tuple[List[List[str]], int, int]:
    """Wrap the interior in a 1-cell wall border on all four sides."""
    new_w = width + 2
    new_h = height + 2
    bordered = [["W" for _ in range(new_w)] for _ in range(new_h)]
    for y in range(height):
        for x in range(width):
            bordered[y + 1][x + 1] = grid[y][x]
    return bordered, new_w, new_h


def encode_level_code(grid: List[List[str]], width: int, height: int) -> str:
    """Convert a grid back into the RLE level code string."""
    rows = []
    for y in range(height):
        row_code = ""
        current = grid[y][0]
        count = 1
        for x in range(1, width):
            cell = grid[y][x]
            if cell == current:
                count += 1
            else:
                row_code += f"{current}{count}"
                current = cell
                count = 1
        row_code += f"{current}{count}"
        rows.append(row_code)
    return "|".join(rows)


def write_tmp_level(code: str) -> None:
    """Replace only the code line in tmp.tres, preserving UID and metadata."""
    text = TMP_LEVEL_PATH.read_text(encoding="utf-8")
    new_text = re.sub(r'^(code = ")(.*)(")$', lambda m: f'{m.group(1)}{code}{m.group(3)}',
                      text, flags=re.MULTILINE)
    TMP_LEVEL_PATH.write_text(new_text, encoding="utf-8")


def generate_level(chunks: List[Chunk], args) -> Optional[Tuple[str, List[List[str]], int, int]]:
    """Generate a level by stitching chunks and carving a guaranteed path."""
    target_w, target_h = args.size

    for attempt in range(args.max_retries):
        seed = args.seed + attempt
        random.seed(seed)

        try:
            interior = generate_interior(chunks, target_w, target_h, args.chunk)
        except ValueError as e:
            print(f"  seed {seed}: invalid target size ({e})")
            continue

        # Choose P in the lower-left and Q in the far upper-right. This satisfies
        # P01 (distance) and P04 (vertical span) by construction.
        p_pos = path_skeleton.choose_player(interior, target_w, target_h, random)
        q_pos = path_skeleton.choose_exit(interior, target_w, target_h, p_pos, random)
        if q_pos is None:
            print(f"  seed {seed}: could not choose exit satisfying P01/P04")
            continue

        # Carve the critical path through the chunk grid. Every hop is verified
        # against the physics model, so R01/J01/J02/J03 are satisfied by
        # construction.
        path = path_skeleton.carve_path(
            interior, target_w, target_h, p_pos, q_pos, random
        )
        if path is None:
            print(f"  seed {seed}: failed to carve a feasible path")
            continue

        p_pos, q_pos = path_skeleton.ensure_player_and_exit(
            interior, target_w, target_h, path
        )

        bordered, full_w, full_h = add_wall_border(interior, target_w, target_h)

        # Validate once. The critical path is already known, so the expensive
        # reachability search is skipped and the graph is built a single time.
        final_params = {
            "player": (p_pos[0] + 1, p_pos[1] + 1),
            "exit": (q_pos[0] + 1, q_pos[1] + 1),
            "critical_path": [(x + 1, y + 1) for x, y in path],
        }
        passes, failures = validator.passes_hard(
            bordered, full_w, full_h, final_params, implemented_only=True
        )
        if not passes:
            for cid, reason in failures:
                print(f"  seed {seed}: HARD fail {cid}: {reason}")
            continue

        code = encode_level_code(bordered, full_w, full_h)

        print(f"\nGenerated level with seed {seed}: interior {target_w}x{target_h}, full {full_w}x{full_h}")
        print(f"  Player at {p_pos}, Exit at {q_pos}")
        print(f"  Critical path length: {len(path)}")
        return code, bordered, full_w, full_h

    return None


def run_coverage_check() -> int:
    """Run the coverage checker and forward its exit code."""
    return check_coverage.main()


def run_validate_code(code: str) -> int:
    """Validate a level code string against the full constraint catalog."""
    grid, width, height = parse_level_code(code)
    fill_walls(grid, width)

    p_cells = [(x, y) for y in range(height) for x in range(width) if grid[y][x] == "P"]
    q_cells = [(x, y) for y in range(height) for x in range(width) if grid[y][x] == "Q"]

    if len(p_cells) != 1 or len(q_cells) != 1:
        print(f"Invalid input: {len(p_cells)} P cells, {len(q_cells)} Q cells")
        return 1

    params = {"player": p_cells[0], "exit": q_cells[0]}
    results = validator.validate(grid, width, height, params, implemented_only=False)

    print(f"\nValidation results for {len(code)} char code:\n")
    all_pass = True
    for cid, severity, passed, details in results:
        status = "PASS" if passed else "FAIL"
        print(f"  [{severity}] {cid}: {status}" + (f" — {details}" if details else ""))
        if severity == "HARD" and not passed:
            all_pass = False

    print("\n" + ("All HARD constraints passed." if all_pass else "Some HARD constraints failed."))
    return 0 if all_pass else 1


def main() -> int:
    parser = argparse.ArgumentParser(description="Procedural level spike for Dragon Jump Remaster")
    parser.add_argument("--seed", type=int, default=1, help="RNG seed (default 1)")
    parser.add_argument("--size", type=str, default="42x24",
                        help="Interior dimensions in cells, must be multiple of chunk size (default 42x24)")
    parser.add_argument("--chunk", type=int, default=6, help="Chunk size (default 6)")
    parser.add_argument("--max-retries", type=int, default=20, help="Seeds to try before giving up (default 20)")
    parser.add_argument("--dry-run", action="store_true", help="Do not overwrite tmp.tres")
    parser.add_argument("--check-coverage", action="store_true", help="Run constraints.md coverage check and exit")
    parser.add_argument("--validate", type=str, default=None, help="Validate a level code string and exit")
    args = parser.parse_args()

    if args.check_coverage:
        return run_coverage_check()

    if args.validate:
        return run_validate_code(args.validate)

    # Parse size
    try:
        w_str, h_str = args.size.lower().split("x")
        args.size = (int(w_str), int(h_str))
    except ValueError:
        parser.error("--size must be in the form WxH, e.g. 42x24")

    print("Loading levels...")
    levels = load_all_levels()
    print(f"Loaded {len(levels)} levels from {LEVEL_DATA_DIR}")

    chunks = analyze(levels, args.chunk)

    print("\n=== Generating level ===\n")
    result = generate_level(chunks, args)

    if result is None:
        print("\nFailed to generate a valid level after all retries. tmp.tres was not modified.")
        return 1

    code, _, _, _ = result

    print("\nSymbol counts in generated code:")
    symbol_counts = Counter(code)
    for sym in sorted(set(re.sub(r'\d|\|', '', code))):
        print(f"  {sym}: {symbol_counts[sym]}")

    print(f"\nGenerated code length: {len(code)} chars")

    if args.dry_run:
        print("\nDry run: not writing tmp.tres")
        print("Code preview:")
        print(code[:200] + "..." if len(code) > 200 else code)
    else:
        write_tmp_level(code)
        print(f"\nWrote generated level to {TMP_LEVEL_PATH}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
