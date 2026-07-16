---
title: Training System Documentation
tags: [godot, game-engine, rl, reinforcement-learning, training]
related: [[rl_integration_system/rl_integration_system.md]], [[player_system/player_system.md]]
search_terms: [training-system, rl-training, ai-training, multiplayer-training, agent-management, environment-communication, physics-simulation]
---

# Training System Documentation

## Overview
The Training System provides the infrastructure for running reinforcement learning training sessions within the game environment. It manages multiple agents, coordinates with external Python training servers, and handles the communication between Godot and RL environments.

Key search terms and concepts for RAG retrieval: training-system, rl-training, ai-training, multiplayer-training, agent-management, environment-communication, physics-simulation
System relationships and dependencies: This system integrates with RL Integration System for communication, player system for agent behavior, and main system for game flow control.

## Script Components (`*.gd`)

### `main_multiplayer.gd`
- **Purpose**: Main node that manages multiplayer training environments with multiple agents
- **Key properties**:
  - `multiplayer_world_scene`: Preloaded scene for multiplayer worlds
  - `ghost_scene`: Preloaded ghost scene for agent visualization
  - `worlds`: Container for training worlds
  - `ghosts`: Container for ghost representations
  - `sync`: Synchronizer node for communication
  - `DEFAULT_LEVEL_NAME`: Default level to load for training
  - `DEFAULT_NB_AGENTS`: Default number of agents for training
  - `main_world`: Reference to the main world being displayed
  - `player_mapping`: Dictionary mapping player names to ghost representations
- **Main methods**:
  - `_ready()`: Initializes training worlds and agents based on command line arguments
  - `_process(_delta: float)`: Updates agent positions and tracking in real-time
- **Integration points with other systems**:
  - Uses EnvironmentVariables for command-line arguments
  - Connects to Constants for level definitions
  - Integrates with RL Integration System through Sync node
  - Uses SceneManger for scene navigation
  - Connects to player system for agent behavior
- **RAG metadata**: Performance considerations include efficient agent instantiation and real-time position updates, optimization hints involve using preloaded scenes and deferred calls

### `synchronizer.gd`
- **Purpose**: Manages communication between Godot game engine and external Python RL training environments
- **Key properties**:
  - `action_repeat`: Number of frames to repeat actions (default: 8)
  - `args`: Command-line arguments for configuration
  - `agents_training`: Array of training agents
  - `_action_space_training`: Action space definitions for training agents
  - `_obs_space_training`: Observation space definitions for training agents
  - `initialized`: Boolean flag indicating initialization status
  - `n_action_steps`: Counter for action steps
  - `just_reset`: Boolean flag for reset state
  - `need_to_send_obs`: Boolean flag for observation sending
- **Main methods**:
  - `initialize()`: Initializes training agents and connects to Python server
  - `_physics_process(_delta)`: Main physics processing loop for handling agent actions
  - `_initialize_training_agents()`: Initializes training agents and establishes connection
  - `connect_to_server()`: Establishes TCP connection to Python training server
  - `send_env_info()`: Sends environment information to Python server
  - `training_process()`: Handles communication with Python training server
  - `handle_message()`: Processes messages from the Python server
  - `_get_obs_from_agents()`, `_get_reward_from_agents()`, `_get_info_from_agents()`, `_get_done_from_agents()`: Helper methods for data extraction
  - `_set_agent_actions()`, `_reset_agents()`: Helper methods for agent control
- **Integration points with other systems**:
  - Connects to RL Integration System for communication
  - Uses Godot's physics engine for simulation
  - Communicates with Python RL training environments via TCP
  - Integrates with agent nodes in the game world
- **RAG metadata**: Performance considerations include efficient network communication, optimization hints involve using appropriate action repeat values and proper message handling

## Scene Components (`*.tscn`)
### `main_multiplayer.tscn`
- **Scene hierarchy and organization**: Node containing Worlds container, PlayerMirrors container, and Synchronizer node
- **Key connections between elements**:
  - Connects to agent nodes via groups
  - Uses preloaded scenes for worlds and ghosts
  - Integrates with Sync node for communication
- **Visual layout considerations**: 
  - Container-based organization for multiple training worlds
  - No direct visual UI elements, purely functional
- **RAG metadata**: Visual design patterns include node-based architecture for system integration

### `synchronizer.tscn`
- **Scene hierarchy and organization**: Node-based scene with no visible UI elements
- **Key connections between elements**:
  - Connects to agent nodes via groups
  - Establishes TCP connection to Python server
- **Visual layout considerations**:
  - No visual UI elements, purely functional
- **RAG metadata**: Visual design patterns include node-based architecture for system integration

## System Integration
- How the system interacts with other components: Training system connects to RL Integration System for communication, player system for agent behavior, and main system for game flow control
- Signal-based communication patterns: Uses signals from agents and Sync node for coordination
- Data flow and control flow: Command-line arguments → Agent initialization → Environment setup → Communication with Python server → Agent actions → Observation feedback
- Cross-system relationships for RAG linking: Related to RL Integration System (communication), player system (agent behavior), main system (game flow)

## Design Patterns
- Architecture patterns used: Singleton pattern for synchronizer, Factory pattern for agent instantiation, Observer pattern for event handling
- Code organization principles: Separation of concerns between training environment setup and communication
- Reusability considerations: Synchronizer can be reused across different RL environments with minimal configuration changes
- Pattern-specific RAG tags and categorization: singleton-pattern, factory-pattern, observer-pattern, rl-training-system

## Implementation Details
- Key code examples:
  - `stream.connect_to_host(ip, port)` - Establishing TCP connection for communication
  - `get_tree().get_nodes_in_group("AGENT")` - Getting agent nodes from groups
  - `create_tween()` - Animation creation for smooth UI transitions
- Important algorithms or logic: 
  - Agent instantiation and configuration based on command-line arguments
  - TCP message handling and parsing
  - Physics step repetition for training efficiency
  - Agent action setting and observation sending
- Performance considerations: Efficient agent instantiation, proper network communication, appropriate physics step repetition

## See Also
- [[rl_integration_system/rl_integration_system.md]]
- [[player_system/player_system.md]]