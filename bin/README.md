# Dotfiles Utility Scripts

Utility scripts for managing and maintaining your dotfiles.

## reconcile-dotfiles.sh

**Detects packages installed locally that are NOT in your chezmoi configuration** and lets you selectively add them to your dotfiles repo.

### What It Does

Scans your local system for installed packages and compares them against `.chezmoidata.yaml`. Shows you **only the packages that exist locally but are missing from your chezmoi config**, then lets you choose which ones to add.

### Prerequisites

```bash
# Required
brew install yq          # YAML processor

# Optional (better UX)
brew install fzf         # Interactive fuzzy selection
```

### Usage

```bash
# Normal mode - interactive reconciliation
./bin/reconcile-dotfiles.sh

# Debug mode - see detected packages without making changes
./bin/reconcile-dotfiles.sh --debug

# Help
./bin/reconcile-dotfiles.sh --help
```

**Debug Mode**: Shows what packages are detected and what's in your config without making any changes. Useful for troubleshooting or understanding what the script sees.

### Workflow

1. **Scans** installed packages (Homebrew, mise, cargo, npm, apt)
2. **Compares** against `.chezmoidata.yaml`
3. **Shows** only packages NOT in config
4. **Interactive selection** (fzf or numbered list)
5. **Updates** `.chezmoidata.yaml` automatically
6. **Commits** and optionally pushes to git

### Example Output

```
╔════════════════════════════════════════════════════════╗
║      Dotfiles Reconciliation Tool                     ║
║  Sync your local packages with chezmoi config         ║
╚════════════════════════════════════════════════════════╝

═══ Detecting installed packages on your system ═══

ℹ️  Scanning Homebrew formulae...
ℹ️  Scanning mise-managed tools...
✅ Found 127 installed packages/tools

═══ Parsing chezmoi configuration ═══

ℹ️  Parsing .chezmoidata.yaml...
✅ Found 89 configured packages in chezmoi

═══ Finding differences ═══

⚠️  Found 38 packages installed locally but NOT in chezmoi config

Installed but not in config:

Homebrew Formulae:
  • awscli
  • jq
  • k9s
  • terraform

Homebrew Casks:
  • slack
  • postman

═══ Select packages to add to chezmoi config ═══

[Interactive fzf selection appears]

✅ Selected 4 packages to add

═══ Updating .chezmoidata.yaml ═══

ℹ️  Backup created: .chezmoidata.yaml.backup

Adding Homebrew formulae:
  • awscli
  • jq

Adding Homebrew casks:
  • slack

✅ Updated .chezmoidata.yaml

═══ Committing changes to git ═══

[Shows git diff]

Commit these changes? [y/N] y
✅ Changes committed

Push to remote? [y/N] y
✅ Changes pushed to remote

✅ 🎉 Reconciliation complete!
```

### Supported Package Managers

**The script shows ONLY top-level packages (explicitly installed), not dependencies.**

| Manager      | Platform | Detection Method                               | Filters Dependencies? |
| ------------ | -------- | ---------------------------------------------- | --------------------- |
| **Homebrew** | macOS    | `brew leaves` (formulae), `brew list --cask`   | ✅ Yes                |
| **mise**     | All      | `mise ls --installed`                          | ✅ Yes (by nature)    |
| **cargo**    | All      | `~/.cargo/.crates.toml`                        | ✅ Yes (by nature)    |
| **npm**      | All      | `npm list -g --depth=0`                        | ✅ Yes                |
| **apt**      | Linux    | `apt-mark showmanual`                          | ✅ Yes                |

**Key:**
- `brew leaves` shows only formulae you installed, not their dependencies
- `--depth=0` ensures npm only shows top-level global packages
- `apt-mark showmanual` shows only manually installed packages
- cargo and mise inherently only track what you explicitly installed

### Smart Categorization

When adding packages, they're automatically placed in the right section:

- **Development tools** (git, docker, neovim) → `platform_packages.darwin.development`
- **Shell tools** (bash, zsh, fish) → `platform_packages.darwin.shell`
- **System utilities** → `platform_packages.darwin.system`
- **Applications/Casks** → `platform_packages.darwin.applications`

### Safety Features

- ✅ Creates `.chezmoidata.yaml.backup` before any changes
- ✅ Shows git diff before committing
- ✅ Requires confirmation for commit and push
- ✅ Restores backup if you cancel
- ✅ Only shows packages NOT already in config (no duplicates)

### Common Use Cases

#### Scenario 1: After installing work tools
```bash
# You installed some tools for a new project
brew install awscli terraform kubectl

# Add them to your dotfiles
./bin/reconcile-dotfiles.sh
# Select those 3 packages → commit → push
```

#### Scenario 2: Periodic maintenance
```bash
# Run monthly to catch any ad-hoc installations
./bin/reconcile-dotfiles.sh

# Review what you've installed since last sync
# Add the keepers, ignore the experimental ones
```

#### Scenario 3: New machine setup verification
```bash
# After setting up a new machine and installing extras
./bin/reconcile-dotfiles.sh

# See what tools you added that aren't in your dotfiles yet
```

### How It Works

The script uses `comm -23` to find the set difference:

```bash
# Packages in INSTALLED but NOT in CONFIGURED
comm -23 <(sort installed.txt) <(sort configured.txt)
```

This ensures you **only see packages that need to be added**, not ones already tracked.

### Important: cli_tools vs platform_packages

The script **only considers `platform_packages.*` sections** when checking what's configured for Homebrew:

- ✅ **Checked**: `platform_packages.darwin.system/development/shell/applications`
- ❌ **Not checked**: `cli_tools.*` (these are just installation method definitions)

**Why?** The `cli_tools` section defines *how* tools *can* be installed (brew/cargo/npm), not what's actually configured to be installed via Homebrew.

**Example scenario:**
- You have `ripgrep` installed via **cargo** (from mise or direct install)
- `ripgrep` is also available via **Homebrew** (listed in `cli_tools.ripgrep.brew`)
- Homebrew installed it as a dependency of something else
- **Result**: Script shows `ripgrep` as "installed via brew but not in config"

**This is intentional** - it helps you identify:
1. Tools installed via multiple package managers (duplication)
2. Dependencies that became top-level installs
3. Packages you manually installed that should be tracked

### Troubleshooting

**Q: Script shows packages I already have in config**
A: This shouldn't happen due to `comm -23`. If it does, check that the package name format matches exactly (e.g., `brew:formula:git` vs `brew:cask:git`)

**Q: Some installed packages don't appear**
A: Make sure the package manager is in your PATH and the tool is properly installed. Check individual detection commands:
```bash
brew list --formula
mise ls --installed
cargo install --list
```

**Q: Wrong category chosen**
A: Edit `.chezmoidata.yaml` manually after to move packages to the right section

### Related Files

- [../.chezmoidata.yaml](../.chezmoidata.yaml) - Package configuration
- [../run_once_02-install-platform-packages.sh.tmpl](../run_once_02-install-platform-packages.sh.tmpl) - Installation script
