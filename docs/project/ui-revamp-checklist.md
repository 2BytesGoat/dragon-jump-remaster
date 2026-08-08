# UI Revamp Checklist

## Phase 1: Cleanup — Delete stale files

- [x] Delete `src/ui/components/time_container.tscn` (stale, unused — file never existed on disk)
- [x] Delete `assets/fonts/PixeloidSans.ttf` (already removed)
- [x] Delete `assets/fonts/PixeloidSans.ttf.import` (already removed)
- [x] Delete `assets/fonts/mago2.ttf` (already removed)
- [x] Delete `assets/fonts/mago2.ttf.import` (already removed)
- [x] Delete `src/ui/components/themes/main_theme.tres` (already removed)
- [x] Delete `src/ui/components/themes/level_select_theme.tres` (already removed)
- [x] Delete `src/ui/menus/main_menu_old.tscn` + `.gd` (replaced by main_screen.tscn)
- [x] Delete `src/ui/menus/level_select.tscn` + `.gd` (replaced by practice_menu.tscn)
- [x] Delete `src/ui/screens/tag_screen.tscn` + `.gd` (tag/crown mode cut for V1.0)
- [x] Delete `src/ui/screens/custom_levels_menu.tscn` + `.gd` (orphaned; CREATE button disabled)
- [x] Delete `src/ui/screens/stats_screen.tscn` + `.gd` (completely unreferenced)
- [x] Delete `src/scripts/resources/custom_level_store.gd` (only used by custom_levels_menu)
- [x] Delete 9 unreferenced UI assets (medal_bar_track, medal_bar_fill, progress_bar_bg, progress_bar_fill, palette, arrow-doodle, rock-doodle, container, frame_container)

---

## Phase 2: Strip all scenes of theme cruft

### Remove `theme = ExtResource(...)` assignments

- [ ] `src/ui/menus/menu_button.tscn:10`
- [ ] `src/ui/menus/pause_screen.tscn:30`
- [ ] `src/ui/menus/end_screen.tscn:30`
- [ ] `src/ui/menus/arcade_game_over_screen.tscn:27`
- [ ] `src/ui/menus/settings_menu.tscn:29`
- [ ] `src/scenes/powerups/card_scene.tscn:132`
- [ ] `src/scenes/powerups/card_scene.tscn:155`
- [ ] `src/ui/components/bonus_popup.tscn:7`
- [ ] `src/ui/menus/level_button.tscn:14`
- [ ] `src/ui/components/arcade_rank_hud.tscn:31`
- [ ] `src/ui/components/arcade_rank_hud.tscn:55`
- [ ] `src/ui/components/arcade_rank_hud.tscn:71`
- [ ] `src/ui/components/arcade_rank_hud.tscn:114`
- [ ] `src/ui/components/arcade_rank_hud.tscn:122`

### Remove `theme = SubResource(...)` assignments

- [ ] `main.tscn:69` — inline `Theme_cegan` on SubViewportContainer

### Remove `theme = null` hacks

*(No remaining `theme = null` hacks — all were in deleted files)*

### Remove `theme_override_colors/*`

- [ ] `src/ui/menus/arcade_game_over_screen.tscn:83` — NewHighScoreLabel font_color
- [ ] `src/ui/menus/arcade_game_over_screen.tscn:93` — BestStreakLabel font_color
- [ ] `src/ui/menus/arcade_game_over_screen.tscn:150` — SaveHintLabel font_color
- [ ] `src/ui/components/bonus_popup.tscn:8` — BonusPopup font_outline_color
- [ ] `src/ui/components/arcade_rank_hud.tscn:72` — BandLabel font_shadow_color
- [ ] `src/scenes/powerups/card_scene.tscn:133` — CardLabel_TopLeft font_color
- [ ] `src/scenes/powerups/card_scene.tscn:134` — CardLabel_TopLeft font_outline_color
- [ ] `src/scenes/powerups/card_scene.tscn:156` — CardLabel_BottomRight font_color
- [ ] `src/scenes/powerups/card_scene.tscn:157` — CardLabel_BottomRight font_outline_color

### Remove `theme_override_font_sizes/*`

- [ ] `main.tscn:127` — ResumeButton (8)
- [ ] `main.tscn:130` — RestartButton (8)
- [ ] `main.tscn:133` — SettingsButton (8)
- [ ] `main.tscn:136` — ExitButton (8)
- [ ] `main.tscn:145` — RestartButton EndScreen (8)
- [ ] `main.tscn:148` — NextButton (8)
- [ ] `main.tscn:151` — ExitButton EndScreen (8)
- [ ] `main.tscn:157` — TryAgainButton (8)
- [ ] `main.tscn:160` — QuitButton (8)
- [ ] `src/ui/menus/main_menu.tscn:188` — ConfirmButton (8)
- [ ] `src/ui/menus/main_menu.tscn:191` — SkipButton (8)

### Remove `theme_override_styles/panel` + inline SubResource StyleBox blocks

- [ ] `src/ui/menus/main_menu.tscn:88` — Panel + StyleBoxTexture_jmap8
- [ ] `src/ui/menus/main_menu.tscn:133` — Panel2 + StyleBoxTexture_jmap8
- [ ] `src/ui/menus/pause_screen.tscn:39` — Panel + StyleBoxTexture_b38vx
- [ ] `src/ui/menus/arcade_game_over_screen.tscn:34` — Panel + StyleBoxTexture_8g23b
- [ ] `src/ui/menus/end_screen.tscn:37` — Panel + StyleBoxTexture_kvx7a
- [ ] `src/ui/menus/settings_menu.tscn:36` — Panel + StyleBoxTexture_a1b2c

### Remove `theme_override_constants/*` (~90 lines)

- [ ] `src/ui/menus/main_menu.tscn` — 8 lines (margins, separation)
- [ ] `src/ui/menus/pause_screen.tscn` — 3 lines (separation)
- [ ] `src/ui/menus/end_screen.tscn` — 17 lines (margins, separation)
- [ ] `src/ui/menus/arcade_game_over_screen.tscn` — 8 lines (margins, separation)
- [ ] `src/ui/menus/settings_menu.tscn` — 12 lines (margins, separation)
- [ ] `src/ui/menus/level_button.tscn` — 2 lines (margins)
- [ ] `src/ui/components/arcade_rank_hud.tscn` — 5 lines (separation, margins, shadow)
- [ ] `src/ui/components/bonus_popup.tscn` — 1 line (shadow_outline_size)
- [ ] `src/ui/components/leaderboard.tscn` — 6 lines (margins, separation)
- [ ] `src/scenes/powerups/card_scene.tscn` — 8 lines (margins, line_spacing, outline_size)

### Remove inline `Theme_cegan` SubResource block

- [ ] `main.tscn:22-23` — inline theme that only sets Label font to PressStart2P

### Remove runtime `add_theme_*` calls in GDScript

- [ ] `src/ui/hud/arcade_rank_hud.gd:182` — multiplier_label font_color
- [ ] `src/ui/hud/arcade_rank_hud.gd:206` — multiplier_label font_color (gold)
- [ ] `src/ui/hud/arcade_rank_hud.gd:215` — multiplier_label font_color (red)
- [ ] `src/ui/hud/arcade_rank_hud.gd:226` — multiplier_label font_color (white)
- [ ] `src/ui/hud/arcade_rank_hud.gd:255` — band_label font_color (white)
- [ ] `src/ui/hud/arcade_rank_hud.gd:360` — band_label font_color (white)
- [ ] `src/ui/hud/bonus_popup.gd:40` — font_color
- [ ] `src/scenes/powerups/card_scene.gd:107` — margin constants loop

---

## Phase 3: Restructure folders

> **DONE** — All files are already in their correct locations:
> - `src/ui/menus/` — main_menu, main_screen, practice_menu, credits_screen
> - `src/ui/screens/` — pause_screen, end_screen, arcade_game_over_screen, settings_menu
> - `src/ui/hud/` — arcade_rank_hud, bonus_popup
> - `src/ui/components/` — menu_button, level_button, leaderboard, leaderboard_entry, time_display, speed_slider_label, others_label, crt_screen_effect

---

## Phase 4: Update all path references

> **MOSTLY DONE** — Files are already in their correct locations. Remaining items:

### `main.gd`

- [ ] Line 20: `level_select.tscn` path → remove (level_select deleted; exit now goes to `main_screen.tscn`)

### `src/tests/test_boot.gd`

- [ ] Line 7: `main_menu.tscn` path → verify still valid (`res://src/ui/menus/main_menu.tscn`)

### `src/ui/hud/arcade_rank_hud.tscn`

- [ ] Line 5: `single_time_container.gd` → `time_display.gd` path — was `res://src/ui/components/single_time_container.gd`, now `res://src/ui/components/time_display.gd`

---

## Phase 5: Build unified theme

> **DONE** — `default_theme.tres`, `gameplay_theme.tres`, and `practice_theme.tres` already exist in `src/ui/themes/`. `project.godot` already points `gui/theme/custom` to `default_theme.tres`.

---

## Phase 6: Verify

- [ ] Check no broken UID references remain
- [ ] Verify all scenes load without errors
- [ ] Test each screen:
  - [ ] Main menu
  - [ ] Practice menu
  - [ ] Pause screen
  - [ ] End screen
  - [ ] Settings menu
  - [ ] Arcade game over screen
  - [ ] Arcade rank HUD
  - [ ] Bonus popup
  - [ ] Leaderboard
  - [ ] CRT screen effect
  - [ ] Card scene (powerups)
