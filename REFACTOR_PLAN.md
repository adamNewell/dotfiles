# Dotfiles Refactoring Plan

## Overview
This plan addresses critical security vulnerabilities, technical debt, and architectural issues identified in the dotfiles repository. The refactoring is organized into 5 phases, prioritized by security impact and user experience.

## Current State Summary
- **Security vulnerabilities**: Unquoted variables, no checksum verification, deprecated modules
- **Technical debt**: 10+ package managers, hardcoded paths, no error handling
- **Maintenance issues**: Poor documentation, no tests, organic growth complexity

## Phase 1: Critical Security Fixes (Week 1)
**Goal**: Eliminate security vulnerabilities and unsafe practices

### Tasks:
1. **Shell Script Security Audit**
   - Fix all unquoted variable expansions
   - Add proper input validation
   - Implement safe error handling with trap
   - Add shellcheck linting to all scripts

2. **External Downloads Security**
   - Add SHA256 checksums to `.chezmoiexternal.yaml`
   - Implement checksum verification
   - Use HTTPS for all downloads
   - Add signature verification where available

3. **Python 2 Deprecation**
   - Replace `SimpleHTTPServer` with `http.server`
   - Update all Python scripts to Python 3
   - Add Python version checking

4. **Secrets Management**
   - Implement chezmoi encryption for sensitive files
   - Create `.chezmoiignore` for private data
   - Document secrets handling process
   - Add example encrypted files

## Phase 2: Repository Cleanup (Week 2)
**Goal**: Clean up repository structure and establish conventions

### Tasks:
1. **Directory Structure**
   - Remove anomalous `~/` directory
   - Fix or remove empty `.chezmoiroot`
   - Organize files by purpose
   - Create clear directory hierarchy

2. **Naming Conventions**
   - Document zsh config numbering (00-09: core, 10-19: env, 20-29: tools, etc.)
   - Standardize file naming (kebab-case)
   - Create naming convention guide

3. **Git Hygiene**
   - Merge dev branch to main
   - Establish branch protection rules
   - Create `.gitattributes` for line endings
   - Add comprehensive `.gitignore`

## Phase 3: Simplify Package Management (Week 3-4)
**Goal**: Reduce complexity and improve reliability

### New Architecture:
```
Primary: mise (for language versions)
Secondary: OS package manager (brew/apt/dnf)
Fallback: Direct downloads via chezmoi
```

### Tasks:
1. **Consolidate Package Definitions**
   - Keep only mise + OS package manager + chezmoi
   - Remove cargo, npm, pip, go as installers
   - Create clear dependency graph
   - Document installation order

2. **Dependency Management**
   - Define tool categories (essential, development, optional)
   - Implement staged installation
   - Add dependency checking
   - Create minimal install option

3. **Version Management**
   - Pin all critical tool versions
   - Add version constraints
   - Implement update mechanism
   - Create version lock file

## Phase 4: Cross-Platform Support (Week 5-6)
**Goal**: True cross-platform compatibility

### Platform Strategy:
- **macOS**: Primary platform (brew + mise)
- **Linux**: Full support (apt/dnf/pacman + mise)
- **Windows**: Basic support (winget/scoop + mise)
- **WSL**: Treat as Linux

### Tasks:
1. **Remove Hardcoded Paths**
   - Use command detection instead of paths
   - Implement proper PATH management
   - Create platform-specific configs
   - Add path resolution functions

2. **Platform Detection**
   - Create robust OS/distro detection
   - Implement feature detection
   - Add capability checking
   - Create platform test matrix

3. **Conditional Installation**
   - Platform-specific package lists
   - Conditional script execution
   - Graceful degradation
   - Clear platform requirements

## Phase 5: Quality & Maintenance (Week 7-8)
**Goal**: Ensure long-term maintainability

### Tasks:
1. **Testing Infrastructure**
   - Add GitHub Actions CI/CD
   - Create installation tests
   - Add shellcheck automation
   - Implement change validation

2. **Error Handling**
   - Comprehensive error messages
   - Rollback mechanisms
   - Recovery procedures
   - Debug mode

3. **Documentation**
   - Installation guide per platform
   - Troubleshooting guide
   - Architecture documentation
   - Contributing guidelines

4. **Monitoring**
   - Installation success metrics
   - Performance benchmarks
   - Compatibility matrix
   - User feedback mechanism

## Success Criteria
- [ ] Zero shellcheck warnings
- [ ] All downloads verified
- [ ] 3 or fewer package managers
- [ ] Successful install on macOS/Ubuntu/Fedora
- [ ] Complete documentation
- [ ] Automated testing

## Migration Path for Users
1. Backup existing configuration
2. Run cleanup script (to be created)
3. Fresh install with new system
4. Restore personal configurations
5. Validate setup

## Maintenance Schedule
- Weekly: Security updates
- Monthly: Tool version updates
- Quarterly: Feature additions
- Yearly: Major refactoring

## Risk Mitigation
- Keep backup of working state
- Test changes in VM first
- Gradual rollout to users
- Clear rollback procedures
- Maintain compatibility branch

---
*This plan prioritizes security and simplicity while maintaining functionality. Each phase builds on the previous, allowing for incremental improvements and testing.*