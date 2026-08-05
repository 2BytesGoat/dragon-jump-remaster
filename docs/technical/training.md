---
title: Training System Documentation
tags: [godot, game-engine, rl, reinforcement-learning, training, system-integration]
related:
  - "[[technical/rl-integration]]"
  - "[[technical/player-system]]"
search_terms: [training-system, rl-training, ai-training, agent-management, environment-communication, physics-simulation, agent-communication, reinforcement-learning-environment, synchronizer]
---

# Training System Documentation

## Overview
The Training System provides the infrastructure for running reinforcement learning training sessions within the game environment. For V1.0 only `synchronizer.gd` remains: it coordinates agents with an external Python training server via the Godot RL Agents protocol. The older `main_multiplayer.gd`/`multiplayer_world.gd` orchestration scenes were removed when multiplayer split-screen training was cut from V1.0.

Key search terms and concepts for RAG retrieval: training-system, rl-training, ai-training, agent-management, environment-communication, physics-simulation, synchronizer
System relationships and dependencies: This system integrates with RL Integration System for communication, player system for agent behavior, and main system for game flow control.

## Script Components (`*.gd`)

### `main_multiplayer.gd` *(removed)*
The old multiplayer training orchestration script was deleted as part of the V1.0 scope cleanup. `synchronizer.gd` now owns the communication layer, and the training scene itself handles any remaining setup via command-line arguments.

### `synchronizer.gd`
- **Purpose**: Manages communication between Godot game engine and external Python RL training environments
- **Key properties**:
  - `MAJOR_VERSION`, `MINOR_VERSION`: Protocol version reported during the Python handshake
  - `DEFAULT_PORT` (`"11008"`), `DEFAULT_SEED` (`"1"`): Defaults used when no CLI args are supplied
  - `stream`: TCP stream to the Python training server
  - `connected`: Whether the TCP handshake succeeded
  - `action_repeat`: Number of physics frames to repeat actions (default: 8)
  - `agents_training`: Array of training agents
  - `_obs_space_training`, `_action_space_training`: Cached observation/action space dictionaries
  - `initialized`: Becomes true after `initialize()` completes
- **Main methods**:
  - `initialize()`: Initializes training agents, connects to the Python server, and unpauses the tree
  - `_physics_process(_delta)`: Drives the training loop every `action_repeat` frames
  - `_initialize_training_agents()`: Collects agents in the `"AGENT"` group and establishes the TCP connection
  - `connect_to_server()`: Opens the TCP connection and polls until connected
  - `send_env_info()`: Sends observation/action spaces and agent count to the Python server
  - `training_process()`: Sends observations and handles incoming actions/reset/close messages
  - `handle_message()`: Dispatches `reset`, `action`, and `close` messages from the Python server
  - `_set_agent_actions(actions, agents)`: Applies an action array to the agents
  - `_reset_agents(agents)`: Resets agents after a `reset` message
- **Signals and connections**:
  - Communicates with Python server through TCP `StreamPeerTCP`
  - Operates on agents found via `get_tree().get_nodes_in_group("AGENT")`
- **Integration points with other systems**:
  - Connects to RL Integration System for protocol handling
  - Uses Godot's physics engine for simulation stepping
  - Communicates with agent nodes in the game world (player system)
- **RAG metadata**: Performance considerations include efficient network communication; optimization hints involve using appropriate action repeat values and proper message handling.

## Scene Components (`*.tscn`)
### `main_multiplayer.tscn` *(removed)*
The old training orchestration scene was deleted along with `main_multiplayer.gd`. The training scene is now a hidden, minimal scene that owns the `synchronizer.gd` script directly.

### `synchronizer.tscn` *(removed)*
There is no dedicated `synchronizer.tscn` file. `synchronizer.gd` is attached directly to a node in the hidden training scene.

## System Integration
- How the system interacts with other components: Training system connects to RL Integration System for communication, player system for agent behavior, and main system for game flow control
- Signal-based communication patterns: Uses direct agent method calls (`get_obs`, `get_reward`, `get_done`, `set_action`, `reset`) rather than Godot signals; the Python server is the external controller
- Data flow and control flow:
  1. The hidden training scene starts and `initialize()` is called
  2. `synchronizer.gd` discovers agents via the `"AGENT"` group
  3. TCP connection to the Python RL server is established
  4. Environment info (obs/action spaces, agent count) is sent to Python
  5. Python sends `reset`/`action`/`close` messages
  6. Godot applies actions, advances physics, and returns observations/rewards/done flags
  7. Loop continues for training iterations
- Cross-system relationships for RAG linking: Related to RL Integration System (communication), player system (agent behavior), main system (game flow)

## Design Patterns
- Architecture patterns used: Command-loop pattern for the Godot ↔ Python RL protocol
- Code organization principles: Separation of concerns between environment setup (training scene), communication (synchronizer), and agent behavior (player controllers)
- Reusability considerations: Synchronizer can be reused across different RL environments with minimal configuration changes
- Pattern-specific RAG tags and categorization: rl-training-system, tcp-communication, physics-stepping

## Implementation Details
- Key code examples:
  - `stream.connect_to_host(ip, port)` - Establishing TCP connection for communication
  - `get_tree().get_nodes_in_group("AGENT")` - Getting agent nodes from groups
  - `stream.put_string(JSON.stringify(dict, "", false))` - Sending JSON messages to Python
- Important algorithms or logic:
  - Agent discovery via groups
  - TCP message handling and parsing
  - Physics step repetition for training efficiency
  - Agent action setting and observation sending
- Performance considerations: Efficient agent instantiation, proper network communication, appropriate physics step repetition
- Optimization hints:
  - Use preloaded scenes to reduce instantiation time
  - Configure appropriate action repeat values for training efficiency
  - Implement proper message handling to avoid network bottlenecks

## See Also
- [[technical/rl-integration]]
- [[technical/player-system]]
- [[technical/main-system]]
