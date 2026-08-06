# UI Revamp Checklist

## Phase 1: Cleanup — Delete stale files

- [ ] Delete `src/ui/components/time_container.tscn` (stale, unused)
- [ ] Delete `assets/fonts/PixeloidSans.ttf`
- [ ] Delete `assets/fonts/PixeloidSans.ttf.import`
- [ ] Delete `assets/fonts/mago2.ttf`
- [ ] Delete `assets/fonts/mago2.ttf.import`
- [ ] Delete `src/ui/components/themes/main_theme.tres`
- [ ] Delete `src/ui/components/themes/level_select_theme.tres`

---

## Phase 2: Strip all scenes of theme cruft

### Remove `theme = ExtResource(...)` assignments

- [ ] `src/ui/menus/menu_button.tscn:10`
- [ ] `src/ui/menus/pause_screen.tscn:30`
- [ ] `src/ui/menus/end_screen.tscn:30`
- [ ] `src/ui/menus/tag_screen.tscn:26`
- [ ] `src/ui/menus/arcade_game_over_screen.tscn:27`
- [ ] `src/ui/menus/stats_screen.tscn:27`
- [ ] `src/ui/menus/settings_menu.tscn:29`
- [ ] `src/scenes/powerups/card_scene.tscn:132`
- [ ] `src/scenes/powerups/card_scene.tscn:155`
- [ ] `src/ui/components/time_container.tscn:14` (file being deleted anyway)
- [ ] `src/ui/components/bonus_popup.tscn:7`
- [ ] `src/ui/menus/level_select.tscn:72`
- [ ] `src/ui/menus/level_select.tscn:99`
- [ ] `src/ui/menus/level_select.tscn:128`
- [ ] `src/ui/menus/level_select.tscn:263`
- [ ] `src/ui/menus/level_button.tscn:14`
- [ ] `src/ui/components/arcade_rank_hud.tscn:31`
- [ ] `src/ui/components/arcade_rank_hud.tscn:55`
- [ ] `src/ui/components/arcade_rank_hud.tscn:71`
- [ ] `src/ui/components/arcade_rank_hud.tscn:114`
- [ ] `src/ui/components/arcade_rank_hud.tscn:122`

### Remove `theme = SubResource(...)` assignments

- [ ] `main.tscn:69` — inline `Theme_cegan` on SubViewportContainer

### Remove `theme = null` hacks

- [ ] `src/ui/menus/level_select.tscn:447` — MapInfoButton
- [ ] `src/ui/menus/level_select.tscn:481` — StartButton
- [ ] `src/ui/menus/level_select.tscn:489` — BackButton

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
- [ ] `src/ui/components/arcade_rank_hud.tscn:38` — TimeLabel (16)
- [ ] `src/ui/components/arcade_rank_hud.tscn:75` — BandLabel (12)

### Remove `theme_override_styles/panel` + inline SubResource StyleBox blocks

- [ ] `src/ui/menus/main_menu.tscn:88` — Panel + StyleBoxTexture_jmap8
- [ ] `src/ui/menus/main_menu.tscn:133` — Panel2 + StyleBoxTexture_jmap8
- [ ] `src/ui/menus/stats_screen.tscn:34` — Panel + StyleBoxTexture_abc12
- [ ] `src/ui/menus/tag_screen.tscn:32` — Panel + StyleBoxTexture_8g23b
- [ ] `src/ui/menus/pause_screen.tscn:39` — Panel + StyleBoxTexture_b38vx
- [ ] `src/ui/menus/arcade_game_over_screen.tscn:34` — Panel + StyleBoxTexture_8g23b
- [ ] `src/ui/menus/end_screen.tscn:37` — Panel + StyleBoxTexture_kvx7a
- [ ] `src/ui/menus/settings_menu.tscn:36` — Panel + StyleBoxTexture_a1b2c
- [ ] `src/ui/menus/level_select.tscn:124` — Panel + StyleBoxTexture_auso1
- [ ] `src/ui/menus/level_select.tscn:259` — Panel + StyleBoxTexture_auso1
- [ ] `src/ui/menus/level_select.tscn:296` — Panel + StyleBoxFlat_auso1
- [ ] `src/ui/menus/level_select.tscn:306` — Panel + StyleBoxFlat_5k7ll
- [ ] `src/ui/menus/level_select.tscn:461` — Panel2 + StyleBoxTexture_auso1

### Remove `theme_override_constants/*` (~90 lines)

- [ ] `src/ui/menus/main_menu.tscn` — 8 lines (margins, separation)
- [ ] `src/ui/menus/pause_screen.tscn` — 3 lines (separation)
- [ ] `src/ui/menus/end_screen.tscn` — 17 lines (margins, separation)
- [ ] `src/ui/menus/stats_screen.tscn` — 6 lines (margins, separation)
- [ ] `src/ui/menus/tag_screen.tscn` — 4 lines (margins, separation)
- [ ] `src/ui/menus/arcade_game_over_screen.tscn` — 8 lines (margins, separation)
- [ ] `src/ui/menus/settings_menu.tscn` — 12 lines (margins, separation)
- [ ] `src/ui/menus/level_button.tscn` — 2 lines (margins)
- [ ] `src/ui/menus/level_select.tscn` — ~40 lines (margins, separation)
- [ ] `src/ui/components/arcade_rank_hud.tscn` — 5 lines (separation, margins, shadow)
- [ ] `src/ui/components/bonus_popup.tscn` — 1 line (shadow_outline_size)
- [ ] `src/ui/components/leaderboard.tscn` — 6 lines (margins, separation)
- [ ] `src/scenes/powerups/card_scene.tscn` — 8 lines (margins, line_spacing, outline_size)

### Remove inline `Theme_cegan` SubResource block

- [ ] `main.tscn:22-23` — inline theme that only sets Label font to PressStart2P

### Remove runtime `add_theme_*` calls in GDScript

- [ ] `src/ui/components/arcade_rank_hud.gd:182` — multiplier_label font_color
- [ ] `src/ui/components/arcade_rank_hud.gd:206` — multiplier_label font_color (gold)
- [ ] `src/ui/components/arcade_rank_hud.gd:215` — multiplier_label font_color (red)
- [ ] `src/ui/components/arcade_rank_hud.gd:226` — multiplier_label font_color (white)
- [ ] `src/ui/components/arcade_rank_hud.gd:255` — band_label font_color (white)
- [ ] `src/ui/components/arcade_rank_hud.gd:360` — band_label font_color (white)
- [ ] `src/ui/components/bonus_popup.gd:40` — font_color
- [ ] `src/scenes/powerups/card_scene.gd:107` — margin constants loop

---

## Phase 3: Restructure folders

### Create new directories

- [ ] `mkdir -p src/ui/screens`
- [ ] `mkdir -p src/ui/hud`

### Move files: menus → screens

- [ ] `src/ui/menus/main_menu.tscn` → `src/ui/screens/main_menu.tscn`
- [ ] `src/ui/menus/main_menu.gd` → `src/ui/screens/main_menu.gd`
- [ ] `src/ui/menus/level_select.tscn` → `src/ui/screens/level_select.tscn`
- [ ] `src/ui/menus/level_select.gd` → `src/ui/screens/level_select.gd`
- [ ] `src/ui/menus/pause_screen.tscn` → `src/ui/screens/pause_screen.tscn`
- [ ] `src/ui/menus/pause_screen.gd` → `src/ui/screens/pause_screen.gd`
- [ ] `src/ui/menus/end_screen.tscn` → `src/ui/screens/end_screen.tscn`
- [ ] `src/ui/menus/end_screen.gd` → `src/ui/screens/end_screen.gd`
- [ ] `src/ui/menus/settings_menu.tscn` → `src/ui/screens/settings_menu.tscn`
- [ ] `src/ui/menus/settings_menu.gd` → `src/ui/screens/settings_menu.gd`
- [ ] `src/ui/menus/stats_screen.tscn` → `src/ui/screens/stats_screen.tscn`
- [ ] `src/ui/menus/stats_screen.gd` → `src/ui/screens/stats_screen.gd`
- [ ] `src/ui/menus/tag_screen.tscn` → `src/ui/screens/tag_screen.tscn`
- [ ] `src/ui/menus/tag_screen.gd` → `src/ui/screens/tag_screen.gd`
- [ ] `src/ui/menus/arcade_game_over_screen.tscn` → `src/ui/screens/arcade_game_over_screen.tscn`
- [ ] `src/ui/menus/arcade_game_over_screen.gd` → `src/ui/screens/arcade_game_over_screen.gd`

### Move files: menus → components

- [ ] `src/ui/menus/menu_button.tscn` → `src/ui/components/menu_button.tscn`
- [ ] `src/ui/menus/menu_button.gd` → `src/ui/components/menu_button.gd`
- [ ] `src/ui/menus/level_button.tscn` → `src/ui/components/level_button.tscn`
- [ ] `src/ui/menus/level_button.gd` → `src/ui/components/level_button.gd`
- [ ] `src/ui/menus/crt_screen_effect.tscn` → `src/ui/components/crt_screen_effect.tscn`
- [ ] `src/ui/menus/others_label.tscn` → `src/ui/components/others_label.tscn`
- [ ] `src/ui/menus/speed_slider_label.gd` → `src/ui/components/speed_slider_label.gd`

### Move files: components → hud

- [ ] `src/ui/components/arcade_rank_hud.tscn` → `src/ui/hud/arcade_rank_hud.tscn`
- [ ] `src/ui/components/arcade_rank_hud.gd` → `src/ui/hud/arcade_rank_hud.gd`
- [ ] `src/ui/components/bonus_popup.tscn` → `src/ui/hud/bonus_popup.tscn`
- [ ] `src/ui/components/bonus_popup.gd` → `src/ui/hud/bonus_popup.gd`

### Delete empty directory

- [ ] `rmdir src/ui/menus/`

---

## Phase 4: Update all path references

### `project.godot`

- [ ] Line 18: `main_menu.tscn` path → `res://src/ui/screens/main_menu.tscn`

### `main.gd`

- [ ] Line 15: `ArcadeRankHud` import (class_name, no path change needed)
- [ ] Line 20: `level_select.tscn` path → `res://src/ui/screens/level_select.tscn`

### `main.tscn`

- [ ] Line 13: `pause_screen.tscn` path → `res://src/ui/screens/pause_screen.tscn`
- [ ] Line 14: `crt_screen_effect.tscn` path → `res://src/ui/components/crt_screen_effect.tscn`
- [ ] Line 16: `end_screen.tscn` path → `res://src/ui/screens/end_screen.tscn`
- [ ] Line 19: `arcade_game_over_screen.tscn` path → `res://src/ui/screens/arcade_game_over_screen.tscn`
- [ ] Line 20: `arcade_rank_hud.tscn` path → `res://src/ui/hud/arcade_rank_hud.tscn`
- [ ] Line 49: `node_paths` — verify ArcadeRankHud node path still valid
- [ ] Line 61: `time_container` NodePath — verify still valid
- [ ] Line 63: `arcade_rank_hud` NodePath — verify still valid

### `src/tests/test_boot.gd`

- [ ] Line 7: `main_menu.tscn` path → `res://src/ui/screens/main_menu.tscn`

### `src/ui/screens/main_menu.gd`

- [ ] Line 6: `level_select.tscn` path → `res://src/ui/screens/level_select.tscn`
- [ ] Line 7: `stats_screen.tscn` path → `res://src/ui/screens/stats_screen.tscn`

### `src/ui/screens/main_menu.tscn`

- [ ] Line 4: `main_menu.gd` path → `res://src/ui/screens/main_menu.gd`
- [ ] Line 5: `tag_screen.tscn` path → `res://src/ui/screens/tag_screen.tscn`
- [ ] Line 6: `menu_button.tscn` path → `res://src/ui/components/menu_button.tscn`
- [ ] Line 8: `tag_screen.gd` path → `res://src/ui/screens/tag_screen.gd`
- [ ] Line 10: `crt_screen_effect.tscn` path → `res://src/ui/components/crt_screen_effect.tscn`
- [ ] Line 12: `settings_menu.tscn` path → `res://src/ui/screens/settings_menu.tscn`

### `src/ui/screens/level_select.gd`

- [ ] Line 17: `level_button.tscn` path → `res://src/ui/components/level_button.tscn`

### `src/ui/screens/level_select.tscn`

- [ ] Line 3: `level_select.gd` path → `res://src/ui/screens/level_select.gd`
- [ ] Line 5: `main_theme.tres` — remove (theme being deleted)
- [ ] Line 7: `level_button.tscn` path → `res://src/ui/components/level_button.tscn`
- [ ] Line 8: `main_menu.tscn` path → `res://src/ui/screens/main_menu.tscn`
- [ ] Line 9: `speed_slider_label.gd` path → `res://src/ui/components/speed_slider_label.gd`
- [ ] Line 12: `level_select_theme.tres` — remove (theme being deleted)
- [ ] Line 13: `menu_button.tscn` path → `res://src/ui/components/menu_button.tscn`
- [ ] Line 14: `leaderboard.tscn` path → `res://src/ui/components/leaderboard.tscn`
- [ ] Line 16: `crt_screen_effect.tscn` path → `res://src/ui/components/crt_screen_effect.tscn`

### `src/ui/screens/pause_screen.tscn`

- [ ] Line 3: `main_theme.tres` — remove (theme being deleted)
- [ ] Line 5: `menu_button.tscn` path → `res://src/ui/components/menu_button.tscn`
- [ ] Line 6: `pause_screen.gd` path → `res://src/ui/screens/pause_screen.gd`
- [ ] Line 7: `settings_menu.tscn` path → `res://src/ui/screens/settings_menu.tscn`

### `src/ui/screens/end_screen.tscn`

- [ ] Line 3: `main_theme.tres` — remove (theme being deleted)
- [ ] Line 5: `end_screen.gd` path → `res://src/ui/screens/end_screen.gd`
- [ ] Line 6: `menu_button.tscn` path → `res://src/ui/components/menu_button.tscn`
- [ ] Line 7: `leaderboard.tscn` path → `res://src/ui/components/leaderboard.tscn`

### `src/ui/screens/settings_menu.tscn`

- [ ] Line 3: `main_theme.tres` — remove (theme being deleted)
- [ ] Line 5: `menu_button.tscn` path → `res://src/ui/components/menu_button.tscn`
- [ ] Line 6: `settings_menu.gd` path → `res://src/ui/screens/settings_menu.gd`

### `src/ui/screens/stats_screen.tscn`

- [ ] Line 4: `main_theme.tres` — remove (theme being deleted)
- [ ] Line 5: `stats_screen.gd` path → `res://src/ui/screens/stats_screen.gd`
- [ ] Line 6: `menu_button.tscn` path → `res://src/ui/components/menu_button.tscn`

### `src/ui/screens/stats_screen.gd`

- [ ] Line 31: `main_menu.tscn` path → `res://src/ui/screens/main_menu.tscn`

### `src/ui/screens/tag_screen.tscn`

- [ ] Line 4: `main_theme.tres` — remove (theme being deleted)
- [ ] Line 5: `menu_button.tscn` path → `res://src/ui/components/menu_button.tscn`

### `src/ui/screens/arcade_game_over_screen.tscn`

- [ ] Line 4: `main_theme.tres` — remove (theme being deleted)
- [ ] Line 5: `menu_button.tscn` path → `res://src/ui/components/menu_button.tscn`
- [ ] Line 6: `arcade_game_over_screen.gd` path → `res://src/ui/screens/arcade_game_over_screen.gd`

### `src/ui/screens/arcade_game_over_screen.gd`

- [ ] Line 209: `main_menu.tscn` path → `res://src/ui/screens/main_menu.tscn`

### `src/ui/components/menu_button.tscn`

- [ ] Line 3: `main_theme.tres` — remove (theme being deleted)
- [ ] Line 4: `menu_button.gd` path → `res://src/ui/components/menu_button.gd`

### `src/ui/components/level_button.tscn`

- [ ] Line 3: `level_button.gd` path → `res://src/ui/components/level_button.gd`
- [ ] Line 4: `level_select_theme.tres` — remove (theme being deleted)

### `src/ui/components/leaderboard.gd`

- [ ] Line 9: `others_label.tscn` path → `res://src/ui/components/others_label.tscn`

### `src/ui/hud/bonus_popup.gd`

- [ ] Line 11: `bonus_popup.tscn` path → `res://src/ui/hud/bonus_popup.tscn`

### `src/ui/hud/bonus_popup.tscn`

- [ ] Line 3: `bonus_popup.gd` path → `res://src/ui/hud/bonus_popup.gd`
- [ ] Line 4: `level_select_theme.tres` — remove (theme being deleted)

### `src/ui/hud/arcade_rank_hud.tscn`

- [ ] Line 3: `level_select_theme.tres` — remove (theme being deleted)
- [ ] Line 4: `arcade_rank_hud.gd` path → `res://src/ui/hud/arcade_rank_hud.gd`
- [ ] Line 5: `single_time_container.gd` path — stays at `res://src/ui/components/single_time_container.gd` (no change)

### `src/scenes/powerups/card_scene.tscn`

- [ ] Line 6: `main_theme.tres` — remove (theme being deleted)

---

## Phase 5: Build unified theme

- [ ] Create `src/ui/themes/default_theme.tres`
- [ ] Set default font to `Awesome 9.ttf`
- [ ] Set default font size
- [ ] Define `Button` base style (silver texture buttons)
- [ ] Define `Button` type variation `"LevelButton"` (flat gray style)
- [ ] Define `Panel` style (silver_panel texture, defined once)
- [ ] Define `Label` base style
- [ ] Define `LineEdit` base style
- [ ] Define `ProgressBar` base style
- [ ] Set `gui/theme/custom` in `project.godot` to `res://src/ui/themes/default_theme.tres`
- [ ] Add `theme_type_variation` on nodes that need non-default styling
- [ ] Re-add genuinely dynamic runtime overrides (rank colors, death flash, bonus popup color)

---

## Phase 6: Verify

- [ ] Check no broken UID references remain
- [ ] Verify all scenes load without errors
- [ ] Test each screen:
  - [ ] Main menu
  - [ ] Level select
  - [ ] Pause screen
  - [ ] End screen
  - [ ] Settings menu
  - [ ] Stats screen
  - [ ] Tag screen
  - [ ] Arcade game over screen
  - [ ] Arcade rank HUD
  - [ ] Bonus popup
  - [ ] Leaderboard
  - [ ] CRT screen effect
  - [ ] Card scene (powerups)
