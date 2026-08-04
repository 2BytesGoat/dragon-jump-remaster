#!/usr/bin/env bash
set -euo pipefail

# CI / local headless test runner for Dragon Jump Remaster.
# Runs the centralized TestRunner scene, which executes every registered test.

GODOT="${GODOT:-godot}"

echo "Dragon Jump Remaster — Phase 2.6 Full Test Suite"

echo ""
echo "==> Running src/tests/test_runner.tscn"
"$GODOT" --headless --path . "src/tests/test_runner.tscn"

echo ""
echo "All tests passed."
