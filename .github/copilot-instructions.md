# Polylith Workspace - AI Coding Instructions

## Architecture Overview

This is a **Polylith** workspace implementing the `poly` CLI tool - a build tool for Clojure that uses "service level building blocks" to compose services and systems like LEGO bricks.

### Core Concepts
- **Components** (`components/`): Reusable functional units with `interface.clj` as public API
- **Bases** (`bases/`): Entry points that wire together components (e.g., `poly-cli` main entry point)
- **Projects** (`projects/`): Deployable artifacts composed of bases + components
- **Top Namespace**: `polylith.clj.core` (defined in `workspace.edn`)
- **Interface Namespace**: `interface` (all public APIs are in `*/interface.clj`)

## Project Structure Patterns

### Component Architecture
```
components/[name]/
├── deps.edn              # Dependencies for this component
├── src/polylith/clj/core/[name]/
│   ├── interface.clj     # PUBLIC API (only interface consumers use)
│   └── core.clj         # Implementation (internal)
└── test/                # Tests mirror src structure
```

**Critical**: Components only expose functionality through `interface.clj`. Never depend directly on `core.clj` files.

### Project Composition
Projects in `projects/` define deployable artifacts by listing their component dependencies in `deps.edn`:
```clojure
{:deps {polylith/api      {:local/root "../../components/api"}
        polylith/command  {:local/root "../../components/command"}
        polylith/poly-cli {:local/root "../../bases/poly-cli"}
        ;; ... other components
        }}
```

## Development Workflow

### Essential Commands
```bash
# REPL development (use :dev alias for all components)
clojure -M:dev

# Run poly tool itself
clojure -M:poly [command]

# Build and test
clojure -T:build jar :project poly
clojure -M:test

# Component-based testing
clojure -M:poly test :project poly    # Test specific project
clojure -M:poly test since:stable     # Incremental testing
```

### Key Aliases in `deps.edn`
- `:dev` - Development with all components on classpath
- `:poly` - Run the poly tool itself
- `:test` - All test paths
- `:build` - Build tools and deployment

## Testing Architecture

### Test Runner System
- Default: Built-in `clojure-test-test-runner` component
- Configurable per-project in `workspace.edn`:
```clojure
:projects {"myproject" {:test {:create-test-runner [my.runner/create]}}}
```
- Setup/teardown functions: `:setup-fn` and `:teardown-fn`
- Tests organized by component boundaries, not arbitrary directories

### Test Execution
Tests run in isolated classloaders per project. Key patterns:
- Component tests in `components/*/test/polylith/clj/core/*/interface_test.clj`
- Project integration tests in `projects/*/test/`
- Cross-component testing via interface dependencies only

## File Organization Rules

### Namespace Conventions
```
polylith.clj.core.[component-name].interface  ;; Public API
polylith.clj.core.[component-name].core       ;; Implementation
polylith.clj.core.[component-name].[other]    ;; Other implementation files
```

### Dependency Management
- Components declare own deps in their `deps.edn`
- Projects inherit dependencies from included components
- Use `:local/root` for intra-workspace dependencies
- External deps go in component's `deps.edn`, not workspace root

## Build System

### Using tools.build (`build.clj`)
```bash
# Create library JAR
clojure -T:build jar :project poly

# Create deployable uberjar
clojure -T:build uberjar :project poly

# Deploy to Clojars
clojure -T:build deploy
```

### Key Build Patterns
- **Lifted Dependencies**: Source deps have external deps promoted to avoid conflicts
- **AOT Compilation**: Uberjars compile main namespace for startup performance
- **Artifact Creation**: Includes homebrew scripts and checksums

## Integration Points

### Git Integration
- Workspace tracks changes via git to determine what to test/build
- Tag patterns in `workspace.edn`: `stable-*` and `v[0-9]*`
- Incremental testing based on `since:stable` or `since:release`

### API Module (`components/api`)
Public API for using poly functionality programmatically:
```clojure
(require '[polylith.clj.core.api.interface :as poly])
(poly/workspace nil)           ;; Get workspace data
(poly/projects-to-deploy nil)  ;; Changed projects
(poly/test :all)              ;; Run tests
```

## Common Patterns

### Creating Components
```bash
clojure -M:poly create component [name]
# Creates: components/[name] with proper structure
```

### Cross-Component Communication
Always use interfaces:
```clojure
;; GOOD
(require '[polylith.clj.core.git.interface :as git])
(git/current-branch)

;; BAD - never do this
(require '[polylith.clj.core.git.core :as git-core])
```

### Configuration
- `workspace.edn`: Workspace-level config (profiles, validation, projects)
- `deps.edn`: Development dependencies and aliases
- Component `deps.edn`: Component-specific dependencies

## Development Scripts

Located in `scripts/` - Babashka scripts for common tasks:
- `help.clj`: Generate documentation
- `shell.clj`: Command execution utilities
- `clean.clj`: Workspace cleanup

## Testing Specific Components

To modify a specific component:
1. Tests are in `components/[name]/test/`
2. Run tests: `clojure -M:poly test :project [project-containing-component]`
3. Check dependencies: `clojure -M:poly deps :component [name]`
4. Validate workspace: `clojure -M:poly check`

Always validate workspace integrity with `poly check` after structural changes.