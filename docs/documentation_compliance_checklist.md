# Documentation Compliance Checklist

This checklist ensures all documentation files in the Dragon Jump Remaster project meet the standards outlined in the documentation_process.md guidelines.

## Metadata Header Requirements
- [ ] Title properly set (e.g., "System Name Documentation")
- [ ] Tags included with relevant categories (godot, game-engine, system-type, etc.)
- [ ] Related systems properly linked using Obsidian-style syntax ([[file_name]])
- [ ] Search terms included for RAG retrieval optimization
- [ ] Metadata header formatted correctly with YAML frontmatter

## Documentation Structure Compliance

### Overview Section
- [ ] High-level description of the system's purpose
- [ ] Role within the overall architecture  
- [ ] Key search terms and concepts for RAG retrieval
- [ ] System relationships and dependencies properly documented

### Script Components (`*.gd`)
- [ ] Key properties and their purposes documented
- [ ] Main methods and their functionality described
- [ ] Signals and connections properly listed
- [ ] Integration points with other systems explained
- [ ] RAG metadata included: performance considerations, optimization hints

### Scene Components (`*.tscn`)
- [ ] Scene hierarchy and organization described
- [ ] Key connections between elements documented
- [ ] Visual layout considerations explained
- [ ] RAG metadata included: visual design patterns, UI flow

### System Integration
- [ ] How the system interacts with other components explained
- [ ] Signal-based communication patterns documented
- [ ] Data flow and control flow clearly outlined (with numbered steps)
- [ ] Cross-system relationships for RAG linking established

### Design Patterns
- [ ] Architecture patterns used properly identified
- [ ] Code organization principles explained
- [ ] Reusability considerations documented
- [ ] Pattern-specific RAG tags and categorization included

### Implementation Details
- [ ] Key code examples provided with clear context
- [ ] Important algorithms or logic explained
- [ ] Performance considerations detailed
- [ ] Optimization hints included

## Formatting Standards
- [ ] Consistent formatting (tables for properties, lists for steps)
- [ ] Code examples included where relevant
- [ ] Both public and internal functionality documented
- [ ] References to related systems and components included
- [ ] Obsidian-style backlinks used throughout
- [ ] Clear headings with descriptive names
- [ ] Bullet points and numbered lists for easy parsing
- [ ] Tables for structured data (properties, methods, signals)

## RAG Optimization Elements
- [ ] Search terms included in metadata for better retrieval
- [ ] Related links to create web of interconnected knowledge
- [ ] Cross-references between related systems
- [ ] Performance considerations and optimization hints included
- [ ] All sections include RAG-relevant concepts for searchability

## File Location & Organization
- [ ] Documentation file located in the `docs` folder
- [ ] Properly organized into component subfolders (e.g., `/docs/player_system/`, `/docs/level_system/`)
- [ ] Each documentation file linked from its corresponding tracking entry
- [ ] Links between original scripts and documentation files for quick navigation
- [ ] Metadata headers included for searchability and indexing

## Quality Assurance
- [ ] Documentation only created when complex logic or system integration exists
- [ ] Consistent style maintained across all documentation files
- [ ] All documentation includes RAG-friendly metadata and cross-references
- [ ] Files properly linked in documentation_tracking.md
- [ ] No simple UI components without complex behavior documented extensively

## Final Verification
- [ ] All required sections present from the complete documentation template
- [ ] Content follows the exact structure specified in documentation_process.md
- [ ] All RAG optimization recommendations implemented
- [ ] Cross-linking strategy properly executed
- [ ] Content is ready for integration into the knowledge base