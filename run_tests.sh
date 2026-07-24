#!/usr/bin/env bash
set -euo pipefail

# CI / local headless test runner for Dragon Jump Remaster.
# Runs the combined TestRunner scene and each focused test scene.

GODOT="${GODOT:-godot}"

run_scene() {
	local scene_path="$1"
	echo ""
	echo "==> Running $scene_path"
	"$GODOT" --headless --quit --path . "$scene_path"
}

echo "Dragon Jump Remaster — Phase 1.5 Smoke Tests"

run_scene "src/tests/test_runner.tscn"
run_scene "src/tests/test_boot.tscn"
run_scene "src/tests/test_level_load.tscn"
run_scene "src/tests/test_save_score.tscn"
run_scene "src/tests/smoke_test.tscn"

echo ""
echo "All smoke tests passed."