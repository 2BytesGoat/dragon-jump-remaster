# Documentation Process Guidelines

This document outlines the standardized process for documenting Godot game systems in the Dragon Jump Remaster project, optimized for creating a high-quality light RAG (Retrieval-Augmented Generation) knowledge base.

## Documentation Workflow

### 1. File Analysis
- Examine both `.gd` script and `.tscn` scene files
- Identify core functionality and system integration points
- Understand signal connections and data flow
- Document key properties, methods, and events
- **Identify RAG-relevant concepts for searchability**

### 2. Documentation Structure (RAG-Optimized)
Each system documentation should include:

#### Overview
- High-level description of the system's purpose
- Role within the overall architecture
- **Key search terms and concepts for RAG retrieval**
- **System relationships and dependencies**

#### Script Components (`*.gd`)
- Key properties and their purposes  
- Main methods and their functionality  
- Signals and connections
- Integration points with other systems
- **RAG metadata: performance considerations, optimization hints**

#### Scene Components (`*.tscn`)
- Scene hierarchy and organization
- Key connections between elements
- Visual layout considerations
- **RAG metadata: visual design patterns, UI flow**

#### System Integration
- How the system interacts with other components
- Signal-based communication patterns
- Data flow and control flow
- **Cross-system relationships for RAG linking**

#### Design Patterns
- Architecture patterns used
- Code organization principles
- Reusability considerations
- **Pattern-specific RAG tags and categorization**

### 3. Documentation Standards (RAG-Focused)
- Use consistent formatting (tables for properties, lists for steps)
- Include code examples where relevant
- Document both public and internal functionality
- Reference related systems and components
- **Use backlinks similar to Obsidian (e.g., [[file_name.md]])**
- **Do not wrap Obsidian backlinks in backticks** — `` `[[file_name.md]]` `` breaks rendering/parsing in this vault. Use plain `[[file_name.md]]` instead.
- **Add links between original scripts and documentation files for quick navigation**
- **Include metadata headers for RAG indexing**
- **Add search tags and cross-references for better retrieval**

### 4. File Selection Process
- **Review `docs/documentation_tracking.md` to identify files marked as [ ] (not documented)** - this file serves as the authoritative list of what needs documentation
- **For each undocumented file, determine if it needs documentation:**
  - If complex logic exists: Create documentation file and update tracking
  - If simple/empty: Mark as "Skipped - No complex logic found"
- **Update tracking with appropriate resolution notes**
- **Maintain consistency in documentation style across all files**

## Quality Assurance Guidelines (RAG-Enhanced)
When determining if a file needs documentation, consider these criteria for "complex logic":
- Files with more than 50 lines of code
- Systems with multiple interconnected components or systems
- Scripts that handle complex state management
- Files with custom signal connections and event handling
- Systems that implement design patterns like State Machine, Factory, or Observer
- Scripts with significant mathematical calculations or physics implementations
- Files that manage data persistence or save/load functionality
- Components that have complex initialization or setup processes
- Systems that integrate with multiple other components
- Files that contain custom algorithms or unique game mechanics

### 5. Documentation Location and Organization (RAG-Friendly)
- **Documentation should always result in an `.md` file located in the `docs` folder**
- **Preferably split by component subfolders under `docs/systems/` (e.g., `/docs/systems/player_system/`, `/docs/systems/level_system/`)**
- **Each documentation file should be linked from its corresponding tracking entry**
- **When creating documentation, link to both original scripts and other relevant documentation files for quick navigation**
- **Include metadata headers for searchability and indexing**

## Sprint Workflow

This project runs **2-week sprints** that feed into release milestones. The cadence is capacity-aware: a sprint's deliverables must fit a realistic hours budget, not a fixed task count. Low-output weeks are normal and expected — unfinished items roll back to the backlog without guilt.

### Sprint start

1. Copy `docs/tracking/sprints/_template.md` to `docs/tracking/sprints/sprint_YYYY_MM_DD.md` (use the sprint end date).
2. Fill in the **Milestone** line — which phase of [[direction/release_plan]] § Release milestones this sprint feeds.
3. Fill in the **Capacity** section honestly: estimate hours available this sprint given IRL load. A 1–2h sprint is valid.
4. Pull 1–6 rows from [[tracking/backlog]] into **Deliverables** by their `#`. Estimate each in hours so the total fits the capacity budget. Leave the rest in the backlog.
5. Write **Definition of done** as concrete checkboxes.
6. Update [[tracking/current_sprint]] to link the new sprint file and reflect the new goal.

### During the sprint

- Tick backlog rows `[x]` in [[tracking/backlog]] as they complete, not just the sprint file. The backlog is the single source of truth.
- If something blocks you, note it in the sprint file under a `## Blockers` heading.

### Sprint end

1. Fill in the **Retrospective** section (3 lines: Done / Carried over / Note).
2. Any unfinished deliverables stay `[ ]` in [[tracking/backlog]] — they are not "failed", just re-pickable next sprint.
3. If the milestone's target date slipped, update it in [[direction/release_plan]] § Release milestones and add a one-line note to [[tracking/decisions]].
4. Start the next sprint from step 1.

### One-milestone focus

Each sprint targets exactly one release milestone. If a sprint can't finish its milestone, the milestone date slips (noted in [[tracking/decisions]]) — the sprint is still successful if the retro shows honest capacity use.

## Documentation Folder Structure Guidelines (RAG-Optimized)
Documentation files should be organized in a hierarchical structure under `docs/systems/` that mirrors the project's component organization:
- Main system documentation: `/docs/systems/main_system/`
- Player-related systems: `/docs/systems/player_system/`
- Level-related systems: `/docs/systems/level_system/`
- Save and data management: `/docs/systems/save_system/`
- UI components: `/docs/systems/ui_components/`
- Effects and visual elements: `/docs/systems/effects/`
- Training and RL integration: `/docs/systems/training_system/`
- Leaderboard functionality: `/docs/systems/leaderboard_system/`

Each subfolder should contain a single documentation file for that specific system, named appropriately (e.g., `player_system.md`, `level_system.md`).

## Folder Creation Guidelines (RAG-Optimized)
When documenting new files that don't fit into existing component folders:
1. Create a new subfolder in the `docs` directory for the new system/component
2. Name the folder following the project's naming convention (e.g., `/docs/new_component_system/`)
3. Document the new system in a file named appropriately within that folder
4. Update this documentation process document to reflect any changes to the folder structure
5. Add the new component to the documentation tracking file (`docs/documentation_tracking.md`)
6. **Include RAG metadata tags for the new folder structure**

## Implementation Example (RAG-Optimized)
For main system files:
- Create `/docs/systems/main_system/main_system.md` 
- Document both `main.gd` and `main.tscn`
- Update tracking to show: `main.gd - (Added documentation to /docs/systems/main_system/main_system.md)` and `sample.tscn - (Skipped because there is no complex logic)`
- **Include metadata headers for RAG indexing**

## Documentation Review Process (RAG-Focused)
When reviewing the documentation tracking:
1. Identify files marked as [ ] (not documented)
2. **First, check `docs/documentation_tracking.md` to understand which files are not yet documented** - this file serves as the authoritative list of what needs documentation
3. For each undocumented file, determine if it needs documentation:
   - If complex logic exists: Create documentation file and update tracking
   - If simple/empty: Mark as "Skipped - No complex logic found"
4. Update tracking with appropriate resolution notes
5. **Documentation files should be located in the `docs` folder, preferably organized into component subfolders under `docs/systems/`** (e.g., `/docs/systems/player_system/`, `/docs/systems/level_system/`, etc.)
6. **When creating documentation, link to both original scripts and other relevant documentation files for quick navigation**
7. **Remember: Documentation is only required when there's complex logic or system integration that needs explanation - simple UI components without complex behavior don't require extensive documentation**
8. **Maintain consistency in documentation style across all files**
9. **Ensure all documentation includes RAG-friendly metadata and cross-references**

## RAG Knowledge Base Optimization Recommendations

### Metadata Headers
Each documentation file should include a metadata header at the top:
```markdown
---
title: [System Name] Documentation
tags: [tag1, tag2, tag3]
related: [[file_name]]
search_terms: [term1, term2, term3]
---
```

**Example of a complete metadata header:**
```markdown
---
title: Main System Documentation
tags: [godot, game-engine, architecture, main-system]
related:
  - "[[player_system]]"
  - "[[level_system]]"
  - "[[save_system]]"
search_terms: [main loop, game flow, level loading, player management, signal communication]
---
```

### Searchability Enhancements
- Include **search_terms** in metadata for better RAG retrieval
- Use **related** links to create a web of interconnected knowledge
- Add **cross-references** between related systems
- Include **performance considerations** and **optimization hints**

### Cross-Linking Strategy
- Use Obsidian-style backlinks: `[[file_name.md]]`
- Create links from scripts to documentation files
- Link between related system documentation
- Include a "See Also" section at the end of each document

### Content Structure for RAG
1. **Clear headings with descriptive names**
2. **Bullet points and numbered lists for easy parsing**
3. **Tables for structured data (properties, methods, signals)**
4. **Code examples with clear context**
5. **Metadata sections for searchability**

### Indexing Best Practices
- Use consistent naming conventions across all documentation files
- Include system relationships in each document's overview
- Add cross-references to related components

### Complete Documentation Template
Here is a complete template that should be followed for all documentation files:

```markdown
---
title: [System Name] Documentation
tags: [tag1, tag2, tag3]
related: [[file_name]]
search_terms: [term1, term2, term3]
---

# [System Name] Documentation

## Overview
- High-level description of the system's purpose
- Role within the overall architecture
- Key search terms and concepts for RAG retrieval
- System relationships and dependencies

## Script Components (`*.gd`)
- Key properties and their purposes  
- Main methods and their functionality  
- Signals and connections
- Integration points with other systems
- RAG metadata: performance considerations, optimization hints

## Scene Components (`*.tscn`)
- Scene hierarchy and organization
- Key connections between elements
- Visual layout considerations
- RAG metadata: visual design patterns, UI flow

## System Integration
- How the system interacts with other components
- Signal-based communication patterns
- Data flow and control flow
- Cross-system relationships for RAG linking

## Design Patterns
- Architecture patterns used
- Code organization principles
- Reusability considerations
- Pattern-specific RAG tags and categorization

## Implementation Details
- Key code examples
- Important algorithms or logic
- Performance considerations

## See Also
- [[related_system_1.md]]
- [[related_system_2.md]]
```
