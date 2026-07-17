# Dragon Jump


## Release plan
Demo
- map where you can race a friend (co-op) / bot
- 20 practices maps
- can load maps from friends

Full Game
- leaderboard for maps
- online multiplayer
- map editor
- more maps 
- custom game modes 

## Multiplayer 

Powerup Ideas
- start later but get increased movements speed

Map Modifiers
- all powerups are random

Game Modes
- tag-mode -> get crown and race back to the end
- chicken-horse -> can edit map between levels to break AI / beat friends

## Graphify + Godot bridge

Graphify does not natively AST-parse `.gd` and `.tscn`, so this repo includes a deterministic bridge that converts them into Python sidecars Graphify can parse for rule-based links.

Generate bridge files:

```bash
python3 tools/graphify_godot_bridge.py
```

This writes generated files to `graphify-bridge/`.

Run Graphify on the bridge output:

```bash
graphify extract graphify-bridge --backend ollama
```

Optional: point to a custom output path:

```bash
python3 tools/graphify_godot_bridge.py --out graphify-input/godot
graphify extract graphify-input/godot --backend ollama
```

graphify . --backend ollama --model qwen3.5:35b-mlx