---
title: Documentation Process Guidelines
tags: [godot, game-engine, documentation, process, standards]
related:
  - "[[meta/compliance-checklist]]"
  - "[[meta/tracking]]"
  - "[[index]]"
search_terms: [documentation-process, standards, workflow, sprint, folder-structure, RAG]
---

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
- **Review `docs/meta/tracking.md` to identify files marked as [ ] (not documented)** - this file serves as the authoritative list of what needs documentation
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
- **Documentation should always result in an `.md` file located in `docs/technical/`**
- **Single-file systems use `docs/technical/system-name.md`; multi-file systems use a subfolder with `index.md` (e.g., `docs/technical/level-system/index.md`)**
- **Each documentation file should be linked from its corresponding tracking entry in `docs/meta/tracking.md`**
- **When creating documentation, link to both original scripts and other relevant documentation files for quick navigation**
- **Include metadata headers for searchability and indexing**

## Sprint Workflow

This project runs **2-week sprints** that feed into release milestones. The cadence is capacity-aware: a sprint's deliverables must fit a realistic hours budget, not a fixed task count. Low-output weeks are normal and expected — unfinished items roll back to the backlog without guilt.

### Sprint start

1. Copy `docs/project/sprints/_template.md` to `docs/project/sprints/sprint-YYYY-MM-DD.md` (use the sprint end date).
2. Fill in the **Milestone** line — which phase of [[design/release-plan]] § Release milestones this sprint feeds.
3. Fill in the **Capacity** section honestly: estimate hours available this sprint given IRL load. A 1–2h sprint is valid.
4. Pull 1–6 rows from [[project/active-backlog]] into **Deliverables** by their `#`. Estimate each in hours so the total fits the capacity budget. Leave the rest in the backlog.
5. Write **Definition of done** as concrete checkboxes.
6. Update [[project/current-sprint]] to link the new sprint file and reflect the new goal.

### During the sprint

- Tick backlog rows `[x]` in [[project/active-backlog]] as they complete, not just the sprint file. The backlog is the single source of truth.
- If something blocks you, note it in the sprint file under a `## Blockers` heading.

### Sprint end

1. Fill in the **Retrospective** section (3 lines: Done / Carried over / Note).
2. Any unfinished deliverables stay `[ ]` in [[project/active-backlog]] — they are not "failed", just re-pickable next sprint.
3. If the milestone's target date slipped, update it in [[design/release-plan]] § Release milestones and add a one-line note to [[project/decisions]].
4. Start the next sprint from step 1.

### One-milestone focus

Each sprint targets exactly one release milestone. If a sprint can't finish its milestone, the milestone date slips (noted in [[project/decisions]]) — the sprint is still successful if the retro shows honest capacity use.

## Documentation Folder Structure Guidelines (RAG-Optimized)
Documentation files are organized into a hierarchical structure under `docs/` that mirrors the project's component organization:
- Game design documents: `/docs/design/` — vision, product identity, core loop, release plan, arcade mode, AI training mode
- Technical reference: `/docs/technical/` — one file per code system, multi-file systems get a subfolder with an `index.md`
  - Level system (multi-file): `/docs/technical/level-system/`
  - Save system (multi-file): `/docs/technical/save-system/`
  - UI (multi-file): `/docs/technical/ui/`
  - Single-file systems: `/docs/technical/main-system.md`, `/docs/technical/player-system.md`, etc.
- Level design: `/docs/level-design/` — design rules, templates, editor notes
- Project management: `/docs/project/` — backlog, sprints, decisions, checklists, code review
- Future ideas: `/docs/future/` — shelved features, research ideas, game juice
- Meta: `/docs/meta/` — documentation process, compliance, tracking
- Archive: `/docs/archive/` — legacy redirect pages

Each system documentation file uses kebab-case naming (e.g., `player-system.md`, `signal-bus.md`). Multi-file systems use a subfolder with an `index.md` as the entry point.

## Folder Creation Guidelines (RAG-Optimized)
When documenting new files that don't fit into existing component folders:
1. Create a new file in the appropriate `docs/technical/` subfolder (or a new subfolder if it's a multi-file system)
2. Name the file using kebab-case (e.g., `/docs/technical/new-system.md`)
3. For multi-file systems, create a subfolder with an `index.md` entry point (e.g., `/docs/technical/new-system/index.md`)
4. Update `docs/meta/tracking.md` to add the new component
5. Include RAG metadata tags for the new file

## Implementation Example (RAG-Optimized)
For main system files:
- Create `/docs/technical/main-system.md`
- Document both `main.gd` and `main.tscn`
- Update tracking to show: `main.gd — documented in [[technical/main-system]]` and `sample.tscn — (Skipped because there is no complex logic)`
- Include metadata headers for RAG indexing

## Documentation Review Process (RAG-Focused)
When reviewing the documentation tracking:
1. Identify files marked as [ ] (not documented)
2. **First, check `docs/meta/tracking.md` to understand which files are not yet documented** - this file serves as the authoritative list of what needs documentation
3. For each undocumented file, determine if it needs documentation:
   - If complex logic exists: Create documentation file and update tracking
   - If simple/empty: Mark as "Skipped - No complex logic found"
4. Update tracking with appropriate resolution notes
5. **Documentation files should be located in `docs/technical/`**, organized into subfolders for multi-file systems
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
  - "[[technical/player-system]]"
  - "[[technical/level-system/index]]"
  - "[[technical/save-system/index]]"
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
