---
title: RL Integration System Documentation
tags: [godot, game-engine, rl, reinforcement-learning, ai]
related: [[training_system/training_system.md]], [[player_system/player_system.md]]
search_terms: [reinforcement-learning, rl, ai, training, sync, godot-rl-agents, control-modes, training-environment]
---

# RL Integration System Documentation

## Overview
The RL Integration System provides the infrastructure for integrating reinforcement learning capabilities into the game using the Godot RL Agents addon. This system manages communication between the Godot game engine and external Python training environments, enabling training of AI agents within the game environment.

Key search terms and concepts for RAG retrieval: reinforcement-learning, rl, ai, training, sync, godot-rl-agents, control-modes, training-environment
System relationships and dependencies: This system integrates with the training system components, player system for agent behavior, and uses Godot's networking capabilities for communication.

## Script Components (`*.gd`)

### `signal_bus.gd`
- **Purpose**: Centralized signal hub for communication between different systems in the game
- **Key properties**:
  - No specific properties defined
- **Main methods**:
  - None (signals only)
- **Signals**:
  - `player_started_run(player)`: Emitted when a player starts a run
  - `player_restarted_run(player)`: Emitted when a player restarts a run
  - `player_finished_run(player)`: Emitted when a player finishes a run
  - `new_run_attempt(level_name)`: Emitted for new run attempts
  - `new_time_submission(level_name, time)`: Emitted when a new time is submitted
  - `new_leaderboard_submission(player_name: String, level_name:String, time:float)`: Emitted when a new leaderboard score is submitted
  - `leaderboard_scores_updated(leaderboad_name)`: Emitted when leaderboard scores are updated
- **Integration points with other systems**:
  - Used by multiple systems for communication
  - Connected to various game events and player actions
- **RAG metadata**: Performance considerations include efficient signal handling, optimization hints involve using signals for decoupled communication

### `sync.gd` (from godot_rl_agents addon)
- **Purpose**: Main synchronization node that manages the connection between Godot and Python RL training environments
- **Key properties**:
  - `control_mode`: Enum controlling whether the environment is in HUMAN, TRAINING, or ONNX_INFERENCE mode
  - `action_repeat`: Number of frames to repeat actions (default: 8)
  - `speed_up`: Physics speed multiplier for faster training (default: 1.0)
  - `onnx_model_path`: Path to pretrained .onnx model file for inference
  - `deterministic_inference`: Whether inference is deterministic
  - `onnx_models`: Dictionary storing loaded ONNX models
  - `stream`: TCP connection stream to Python server
  - `connected`: Boolean indicating connection status
  - `message_center`: Message handling center
  - `all_agents`, `agents_training`, `agents_inference`, `agents_heuristic`: Arrays of different agent types
- **Main methods**:
  - `_ready()`: Initializes the synchronization system and sets up physics parameters
  - `_initialize()`: Sets up agents, physics settings, and connects to training server
  - `_initialize_training_agents()`: Initializes training agents and connects to Python server
  - `_initialize_inference_agents()`: Initializes inference agents with ONNX models
  - `_physics_process(_delta)`: Main physics processing loop for handling agent actions
  - `_training_process()`: Handles communication with Python training server
  - `_inference_process()`: Processes inference actions from ONNX models
  - `connect_to_server()`: Establishes connection to Python training server
  - `handle_message()`: Processes messages from the Python server
- **Integration points with other systems**:
  - Connects to AI agents in the game environment
  - Communicates with Python RL training environments via TCP
  - Uses Godot's physics engine for simulation
- **RAG metadata**: Performance considerations include efficient network communication, optimization hints involve using appropriate action repeat values and speed multipliers

## Scene Components (`*.tscn`)
### `sync.tscn` (from godot_rl_agents addon)
- **Scene hierarchy and organization**: Node-based scene with Sync class as the main node
- **Key connections between elements**:
  - Connects to agents in the game world via groups
  - Establishes TCP connection to Python server
- **Visual layout considerations**: 
  - No visual UI elements, purely functional
- **RAG metadata**: Visual design patterns include node-based architecture for system integration

## System Integration
- How the system interacts with other components: The RL system connects to agents in the game world, communicates with Python training environments via TCP, and integrates with the main game loop through physics processing
- Signal-based communication patterns: Uses SignalBus for communication between different systems
- Data flow and control flow: Agent actions → Sync node → Python server → Sync node → Agent actions
- Cross-system relationships for RAG linking: Related to training system (agent management), player system (agent behavior), and game loop (physics processing)

## Design Patterns
- Architecture patterns used: Singleton pattern for sync node, Observer pattern for signal communication, Factory pattern for agent initialization
- Code organization principles: Separation of concerns between training, inference, and heuristic modes
- Reusability considerations: Sync node can be reused across different RL environments with minimal configuration changes
- Pattern-specific RAG tags and categorization: singleton, observer-pattern, factory-pattern, rl-system

## Implementation Details
- Key code examples:
  - `var stream = StreamPeerTCP.new()` - Creating TCP connection for communication
  - `connect_to_server()` - Establishing connection to Python training server
  - `control_mode == ControlModes.TRAINING` - Setting control mode for agent behavior
- Important algorithms or logic: 
  - TCP message handling and parsing
  - Agent action repetition and physics speed adjustment
  - ONNX model loading and inference processing
- Performance considerations: Efficient network communication, appropriate action repeat values, and physics speed multipliers

## See Also
- [[training_system/training_system.md]]
- [[player_system/player_system.md]]