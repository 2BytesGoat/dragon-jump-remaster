@echo off
setlocal enabledelayedexpansion

REM CI / local headless test runner for Dragon Jump Remaster (Windows).
REM Runs the combined TestRunner scene and each focused test scene.

if "%GODOT%"=="" set GODOT=godot

echo Dragon Jump Remaster - Phase 1.7 Performance and Architecture Smoke Tests

call :run_scene "src/tests/test_runner.tscn"
call :run_scene "src/tests/test_boot.tscn"
call :run_scene "src/tests/test_level_load.tscn"
call :run_scene "src/tests/test_save_score.tscn"
call :run_scene "src/tests/test_frame_time.tscn"
call :run_scene "src/tests/smoke_test.tscn"

echo.
echo All smoke tests passed.
goto :eof

:run_scene
echo.
echo ==^> Running %~1
%GODOT% --headless --path . %~1
if errorlevel 1 exit /b 1
goto :eof
