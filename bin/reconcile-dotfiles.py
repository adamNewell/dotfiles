#!/usr/bin/env python3
"""
Reconcile dotfiles - Sync locally installed packages with chezmoi configuration.

Detects packages installed on your system but not tracked in .chezmoidata.yaml,
allowing you to selectively add them to your dotfiles repo.
"""

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Set, Tuple

try:
    import yaml
except ImportError:
    print("Error: pyyaml is required. Install with: pip install pyyaml")
    sys.exit(1)


class Colors:
    """ANSI color codes for terminal output."""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    CYAN = '\033[0;36m'
    MAGENTA = '\033[0;35m'
    NC = '\033[0m'  # No Color


class PackageDetector:
    """Detect installed packages from various package managers."""

    # Mapping of mise short names to config full names
    MISE_NAME_MAP = {
        'go': 'golang',
        'node': 'nodejs',
        # python and rust stay the same
    }

    @staticmethod
    def run_command(cmd: List[str]) -> str:
        """Run a shell command and return output."""
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=False
            )
            return result.stdout.strip()
        except Exception:
            return ""

    def detect_homebrew(self) -> Set[str]:
        """Detect Homebrew packages (top-level only)."""
        packages = set()

        # Formulae (using 'brew leaves' for top-level only)
        formulae = self.run_command(['brew', 'leaves'])
        for pkg in formulae.split('\n'):
            if pkg:
                packages.add(f"brew:formula:{pkg}")

        # Casks (all are top-level)
        casks = self.run_command(['brew', 'list', '--cask'])
        for pkg in casks.split('\n'):
            if pkg:
                packages.add(f"brew:cask:{pkg}")

        return packages

    def detect_mise(self, chezmoi_config: Dict) -> Set[str]:
        """Detect mise-managed tools with proper name mapping."""
        packages = set()

        # Get configured language names for matching
        config_langs = chezmoi_config.get('languages', {}).keys()

        output = self.run_command(['mise', 'ls', '--installed'])
        for line in output.split('\n'):
            if line:
                parts = line.split()
                if len(parts) >= 2:
                    tool_short = parts[0]
                    version = parts[1]

                    # Map short name to full name
                    tool_full = self.MISE_NAME_MAP.get(tool_short, tool_short)

                    # If it's in config, use config name; otherwise use short name
                    for config_name in config_langs:
                        if tool_short in config_name or config_name in tool_short:
                            tool_full = config_name
                            break

                    packages.add(f"mise:{tool_full}:{version}")

        return packages

    def detect_cargo(self) -> Set[str]:
        """Detect cargo-installed crates."""
        packages = set()
        crates_toml = Path.home() / ".cargo" / ".crates.toml"

        if crates_toml.exists():
            content = crates_toml.read_text()
            # Match crate names from .crates.toml
            for match in re.finditer(r'^"?([^"]+)(?=" =)', content, re.MULTILINE):
                packages.add(f"cargo:{match.group(1)}")

        return packages

    def detect_npm(self) -> Set[str]:
        """Detect npm global packages (top-level only)."""
        packages = set()

        output = self.run_command(['npm', 'list', '-g', '--depth=0', '--json'])
        if output:
            try:
                data = json.loads(output)
                deps = data.get('dependencies', {})
                for pkg in deps.keys():
                    packages.add(f"npm:{pkg}")
            except json.JSONDecodeError:
                pass

        return packages

    def detect_all(self, chezmoi_config: Dict) -> Set[str]:
        """Detect all installed packages."""
        all_packages = set()

        if subprocess.run(['which', 'brew'], capture_output=True).returncode == 0:
            print(f"{Colors.BLUE}ℹ️  Scanning Homebrew packages (top-level only)...{Colors.NC}")
            all_packages.update(self.detect_homebrew())

        if subprocess.run(['which', 'mise'], capture_output=True).returncode == 0:
            print(f"{Colors.BLUE}ℹ️  Scanning mise-managed tools...{Colors.NC}")
            all_packages.update(self.detect_mise(chezmoi_config))

        if subprocess.run(['which', 'cargo'], capture_output=True).returncode == 0:
            print(f"{Colors.BLUE}ℹ️  Scanning cargo-installed crates...{Colors.NC}")
            all_packages.update(self.detect_cargo())

        if subprocess.run(['which', 'npm'], capture_output=True).returncode == 0:
            print(f"{Colors.BLUE}ℹ️  Scanning npm global packages...{Colors.NC}")
            all_packages.update(self.detect_npm())

        return all_packages


class ConfigParser:
    """Parse .chezmoidata.yaml to find configured packages."""

    @staticmethod
    def parse_chezmoi_config(config_path: Path) -> Tuple[Set[str], Dict]:
        """Parse .chezmoidata.yaml and return configured packages and full config."""
        packages = set()

        with open(config_path, 'r', encoding='utf-8') as f:
            config = yaml.safe_load(f)

        # Parse platform packages (Homebrew)
        platform_pkgs = config.get('platform_packages', {}).get('darwin', {})
        for section in ['system', 'development', 'shell']:
            for pkg in platform_pkgs.get(section, []):
                packages.add(f"brew:formula:{pkg}")

        for pkg in platform_pkgs.get('applications', []):
            packages.add(f"brew:cask:{pkg}")

        for pkg in platform_pkgs.get('fonts', []):
            packages.add(f"brew:cask:{pkg}")

        # Parse mise languages
        for lang, version in config.get('languages', {}).items():
            packages.add(f"mise:{lang}:{version}")

        # Parse CLI tools
        for tool, methods in config.get('cli_tools', {}).items():
            if 'brew' in methods:
                packages.add(f"brew:formula:{methods['brew']}")
            if 'cargo' in methods:
                packages.add(f"cargo:{methods['cargo']}")
            if 'npm' in methods:
                packages.add(f"npm:{methods['npm']}")

        return packages, config


class Reconciler:
    """Main reconciliation logic."""

    def __init__(self, debug: bool = False):
        self.debug = debug
        self.detector = PackageDetector()
        self.chezmoi_source = self.get_chezmoi_source()
        self.config_path = self.chezmoi_source / ".chezmoidata.yaml"

    @staticmethod
    def get_chezmoi_source() -> Path:
        """Get chezmoi source directory."""
        try:
            result = subprocess.run(
                ['chezmoi', 'source-path'],
                capture_output=True,
                text=True,
                check=True
            )
            return Path(result.stdout.strip())
        except subprocess.CalledProcessError:
            print(f"{Colors.RED}❌ Could not determine chezmoi source path{Colors.NC}")
            sys.exit(1)

    def normalize_mise_packages(
        self,
        installed: Set[str],
        configured: Set[str]
    ) -> Set[str]:
        """Normalize mise packages to match configured versions."""
        normalized = installed.copy()

        # For each configured mise tool, normalize the installed version
        configured_mise = {p for p in configured if p.startswith('mise:')}

        for config_pkg in configured_mise:
            parts = config_pkg.split(':')
            if len(parts) == 3:
                _, tool_name, config_version = parts

                # Find matching installed package and normalize
                for installed_pkg in list(normalized):
                    if installed_pkg.startswith(f'mise:{tool_name}:'):
                        normalized.discard(installed_pkg)
                        normalized.add(f'mise:{tool_name}:{config_version}')

        return normalized

    def find_mise_version_updates(
        self,
        installed: Set[str],
        configured: Set[str]
    ) -> Dict[str, Tuple[str, str]]:
        """Find mise tools where versions differ."""
        updates = {}

        configured_mise = {p for p in configured if p.startswith('mise:')}
        installed_mise = {p for p in installed if p.startswith('mise:')}

        # Create lookup dicts
        configured_dict = {}
        for pkg in configured_mise:
            parts = pkg.split(':')
            if len(parts) == 3:
                configured_dict[parts[1]] = parts[2]

        installed_dict = {}
        for pkg in installed_mise:
            parts = pkg.split(':')
            if len(parts) == 3:
                installed_dict[parts[1]] = parts[2]

        # Find version differences
        for tool, config_version in configured_dict.items():
            if tool in installed_dict:
                installed_version = installed_dict[tool]
                if installed_version != config_version:
                    updates[tool] = (config_version, installed_version)

        return updates

    def format_items_for_selection(
        self,
        packages: Set[str],
        mise_updates: Dict
    ) -> Tuple[List[str], Dict[str, str]]:
        """Format items for fzf selection and create mapping."""
        display_items = []
        item_map = {}  # Maps display string to original package string

        # Group packages
        groups = {
            'brew:formula:': ('Homebrew Formulae', []),
            'brew:cask:': ('Homebrew Casks', []),
            'mise:': ('Mise Tools', []),
            'cargo:': ('Cargo Crates', []),
            'npm:': ('NPM Packages', []),
        }

        for pkg in sorted(packages):
            for prefix, (_, items) in groups.items():
                if pkg.startswith(prefix):
                    item_name = pkg.replace(prefix, '', 1)
                    items.append((item_name, pkg))

        # Add mise version updates
        update_items = []
        for tool, (old, new) in sorted(mise_updates.items()):
            display_name = f"📌 {tool}:{old}→{new} (version update)"
            full_pkg = f"mise:{tool}:{old}→{new}"
            update_items.append((display_name, full_pkg))

        # Format for display with section headers
        for prefix, (title, items) in groups.items():
            if prefix == 'mise:':
                # Add version updates first
                if update_items:
                    display_items.append(f"═══ {title} - Version Updates ═══")
                    for display_name, full_pkg in update_items:
                        display_items.append(display_name)
                        item_map[display_name] = full_pkg

                    # Then regular mise packages (excluding ones with updates)
                    regular_items = [
                        (name, pkg) for name, pkg in items
                        if pkg.split(':')[1] not in mise_updates
                    ]
                    if regular_items:
                        display_items.append(f"═══ {title} - New Packages ═══")
                        for item_name, full_pkg in regular_items:
                            display_str = f"• {item_name}"
                            display_items.append(display_str)
                            item_map[display_str] = full_pkg
            elif items:
                display_items.append(f"═══ {title} ═══")
                for item_name, full_pkg in items:
                    display_str = f"• {item_name}"
                    display_items.append(display_str)
                    item_map[display_str] = full_pkg

        return display_items, item_map

    def select_with_fzf(self, items: List[str]) -> List[str]:
        """Use fzf for interactive selection."""
        if not items:
            return []

        try:
            # Check if fzf is available
            if subprocess.run(['which', 'fzf'], capture_output=True).returncode != 0:
                print(f"{Colors.RED}❌ fzf is required for interactive selection{Colors.NC}")
                print(f"{Colors.BLUE}ℹ️  Install with: brew install fzf{Colors.NC}")
                sys.exit(1)

            # Run fzf
            process = subprocess.Popen(
                [
                    'fzf',
                    '--multi',
                    '--height=80%',
                    '--border',
                    '--prompt=Select packages to add/update > ',
                    '--header=Use TAB to select multiple, ENTER to confirm, ESC to cancel',
                    '--preview-window=hidden',
                    '--ansi'
                ],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )

            stdout, _ = process.communicate(input='\n'.join(items))

            if process.returncode == 0:
                # Filter out section headers from results
                selected = [
                    line.strip() for line in stdout.strip().split('\n')
                    if line.strip() and not line.startswith('═══')
                ]
                return selected
            else:
                return []

        except Exception as e:
            print(f"{Colors.RED}❌ Error running fzf: {e}{Colors.NC}")
            return []

    def update_config_file(
        self,
        selections: List[str],
        item_map: Dict[str, str],
        config: Dict
    ) -> Dict:
        """Update .chezmoidata.yaml with selected packages. Returns changes dict."""
        if not selections:
            print(f"{Colors.YELLOW}⚠️  No selections made{Colors.NC}")
            return {}

        # Convert selections back to package format
        selected_packages = [item_map[sel] for sel in selections if sel in item_map]

        print(f"\n{Colors.CYAN}═══ Updating configuration ═══{Colors.NC}\n")

        # Track changes
        changes = {
            'brew_formulae': [],
            'brew_casks': [],
            'cargo_crates': [],
            'npm_packages': [],
            'mise_versions': {}
        }

        # Categorize selections
        for pkg in selected_packages:
            if pkg.startswith('brew:formula:'):
                changes['brew_formulae'].append(pkg.replace('brew:formula:', ''))
            elif pkg.startswith('brew:cask:'):
                changes['brew_casks'].append(pkg.replace('brew:cask:', ''))
            elif pkg.startswith('cargo:'):
                changes['cargo_crates'].append(pkg.replace('cargo:', ''))
            elif pkg.startswith('npm:'):
                changes['npm_packages'].append(pkg.replace('npm:', ''))
            elif pkg.startswith('mise:') and '→' in pkg:
                # Version update
                parts = pkg.replace('mise:', '').split(':')
                if len(parts) == 2:
                    tool = parts[0]
                    versions = parts[1].split('→')
                    if len(versions) == 2:
                        changes['mise_versions'][tool] = versions[1]

        # Update mise language versions
        if changes['mise_versions']:
            print(f"{Colors.BLUE}ℹ️  Updating mise language versions...{Colors.NC}")
            for tool, new_version in changes['mise_versions'].items():
                config['languages'][tool] = new_version
                print(f"  📌 {tool}: {new_version}")

        # Update Homebrew packages
        if changes['brew_formulae']:
            print(f"\n{Colors.BLUE}ℹ️  Adding Homebrew formulae...{Colors.NC}")
            if 'platform_packages' not in config:
                config['platform_packages'] = {}
            if 'darwin' not in config['platform_packages']:
                config['platform_packages']['darwin'] = {}
            if 'system' not in config['platform_packages']['darwin']:
                config['platform_packages']['darwin']['system'] = []

            for pkg in changes['brew_formulae']:
                if pkg not in config['platform_packages']['darwin']['system']:
                    config['platform_packages']['darwin']['system'].append(pkg)
                    print(f"  • {pkg}")

        if changes['brew_casks']:
            print(f"\n{Colors.BLUE}ℹ️  Adding Homebrew casks...{Colors.NC}")
            if 'applications' not in config['platform_packages']['darwin']:
                config['platform_packages']['darwin']['applications'] = []

            for pkg in changes['brew_casks']:
                if pkg not in config['platform_packages']['darwin']['applications']:
                    config['platform_packages']['darwin']['applications'].append(pkg)
                    print(f"  • {pkg}")

        # Update cargo/npm through cli_tools
        if changes['cargo_crates']:
            print(f"\n{Colors.BLUE}ℹ️  Adding cargo crates to cli_tools...{Colors.NC}")
            if 'cli_tools' not in config:
                config['cli_tools'] = {}

            for pkg in changes['cargo_crates']:
                if pkg not in config['cli_tools']:
                    config['cli_tools'][pkg] = {
                        'cargo': pkg,
                        'description': 'Added via reconcile-dotfiles'
                    }
                    print(f"  • {pkg}")

        if changes['npm_packages']:
            print(f"\n{Colors.BLUE}ℹ️  Adding npm packages to cli_tools...{Colors.NC}")
            if 'cli_tools' not in config:
                config['cli_tools'] = {}

            for pkg in changes['npm_packages']:
                if pkg not in config['cli_tools']:
                    config['cli_tools'][pkg] = {
                        'npm': pkg,
                        'description': 'Added via reconcile-dotfiles'
                    }
                    print(f"  • {pkg}")

        # Write updated config
        print(f"\n{Colors.BLUE}ℹ️  Writing changes to {self.config_path.name}...{Colors.NC}")

        with open(self.config_path, 'w', encoding='utf-8') as f:
            yaml.dump(config, f, default_flow_style=False, allow_unicode=True, sort_keys=False)

        print(f"{Colors.GREEN}✅ Configuration updated successfully{Colors.NC}\n")

        return changes

    def run(self):
        """Main reconciliation workflow."""
        print(f"{Colors.MAGENTA}")
        print("╔════════════════════════════════════════════════════════╗")
        print("║      Dotfiles Reconciliation Tool (Python)            ║")
        if self.debug:
            print("║  🐛 DEBUG MODE - No changes will be made              ║")
        else:
            print("║  Sync your local packages with chezmoi config         ║")
        print("╚════════════════════════════════════════════════════════╝")
        print(f"{Colors.NC}\n")

        # Change to chezmoi source directory
        os.chdir(self.chezmoi_source)

        # Detect installed packages
        print(f"{Colors.CYAN}═══ Detecting installed packages ═══{Colors.NC}\n")
        configured, config = ConfigParser.parse_chezmoi_config(self.config_path)
        installed = self.detector.detect_all(config)

        print(f"{Colors.GREEN}✅ Found {len(installed)} installed packages{Colors.NC}")
        print(f"{Colors.GREEN}✅ Found {len(configured)} configured packages{Colors.NC}\n")

        if self.debug:
            print(f"{Colors.CYAN}═══ Debug: Installed Packages ═══{Colors.NC}")
            for pkg in sorted(installed):
                print(pkg)

            print(f"\n{Colors.CYAN}═══ Debug: Configured Packages ═══{Colors.NC}")
            for pkg in sorted(configured):
                print(pkg)

            print(f"\n{Colors.BLUE}ℹ️  Debug mode complete. No changes made.{Colors.NC}")
            return

        # Normalize and find differences
        print(f"{Colors.CYAN}═══ Finding differences ═══{Colors.NC}\n")

        normalized = self.normalize_mise_packages(installed, configured)
        missing = normalized - configured
        mise_updates = self.find_mise_version_updates(installed, configured)

        total = len(missing) + len(mise_updates)

        if total == 0:
            print(f"{Colors.GREEN}✅ No differences found - your system matches the config!{Colors.NC}")
            return

        print(f"{Colors.YELLOW}⚠️  Found {total} packages/updates to review{Colors.NC}")

        # Remove mise tools that have updates from the missing list
        # (they'll be shown as updates instead)
        missing_no_updates = {
            p for p in missing
            if not (p.startswith('mise:') and p.split(':')[1] in mise_updates)
        }

        # Format items for selection
        display_items, item_map = self.format_items_for_selection(
            missing_no_updates,
            mise_updates
        )

        # Interactive selection
        print(f"\n{Colors.BLUE}ℹ️  Opening interactive selection (fzf)...{Colors.NC}")
        selections = self.select_with_fzf(display_items)

        if not selections:
            print(f"{Colors.YELLOW}⚠️  No selections made - exiting{Colors.NC}")
            return

        print(f"{Colors.GREEN}✅ Selected {len(selections)} items{Colors.NC}")

        # Update configuration
        changes = self.update_config_file(selections, item_map, config)

        # Offer to commit changes
        print(f"{Colors.CYAN}═══ Git Integration ═══{Colors.NC}\n")
        print(f"{Colors.BLUE}ℹ️  Changes have been made to .chezmoidata.yaml{Colors.NC}")

        # Check if in git repo
        try:
            subprocess.run(
                ['git', 'status'],
                cwd=self.chezmoi_source,
                capture_output=True,
                check=True
            )

            response = input(f"{Colors.YELLOW}❓ Commit and apply changes? (y/N): {Colors.NC}").strip().lower()

            if response == 'y':
                print(f"\n{Colors.BLUE}ℹ️  Committing changes...{Colors.NC}")

                # Add the file
                subprocess.run(
                    ['git', 'add', '.chezmoidata.yaml'],
                    cwd=self.chezmoi_source,
                    check=True
                )

                # Create commit message
                commit_msg = "Update package configuration via reconcile-dotfiles\n\n"
                if changes['mise_versions']:
                    commit_msg += "Mise version updates:\n"
                    for tool, version in changes['mise_versions'].items():
                        commit_msg += f"  - {tool}: {version}\n"
                if changes['brew_formulae'] or changes['brew_casks']:
                    commit_msg += "\nHomebrew packages:\n"
                    for pkg in changes['brew_formulae']:
                        commit_msg += f"  - {pkg}\n"
                    for pkg in changes['brew_casks']:
                        commit_msg += f"  - {pkg} (cask)\n"
                if changes['cargo_crates']:
                    commit_msg += "\nCargo crates:\n"
                    for pkg in changes['cargo_crates']:
                        commit_msg += f"  - {pkg}\n"
                if changes['npm_packages']:
                    commit_msg += "\nNPM packages:\n"
                    for pkg in changes['npm_packages']:
                        commit_msg += f"  - {pkg}\n"

                subprocess.run(
                    ['git', 'commit', '-m', commit_msg],
                    cwd=self.chezmoi_source,
                    check=True
                )

                print(f"{Colors.GREEN}✅ Changes committed{Colors.NC}")

                # Ask about applying with chezmoi
                response = input(f"{Colors.YELLOW}❓ Apply changes with 'chezmoi apply'? (y/N): {Colors.NC}").strip().lower()

                if response == 'y':
                    print(f"\n{Colors.BLUE}ℹ️  Running 'chezmoi apply'...{Colors.NC}")
                    result = subprocess.run(['chezmoi', 'apply'], capture_output=False)

                    if result.returncode == 0:
                        print(f"{Colors.GREEN}✅ Dotfiles applied successfully{Colors.NC}")
                    else:
                        print(f"{Colors.YELLOW}⚠️  chezmoi apply returned non-zero exit code{Colors.NC}")
                else:
                    print(f"{Colors.BLUE}ℹ️  Skipping chezmoi apply - run manually when ready{Colors.NC}")
            else:
                print(f"{Colors.BLUE}ℹ️  Changes saved but not committed{Colors.NC}")
                print(f"{Colors.BLUE}ℹ️  Run 'git add .chezmoidata.yaml && git commit' to commit manually{Colors.NC}")

        except subprocess.CalledProcessError:
            print(f"{Colors.YELLOW}⚠️  Not in a git repository - changes saved to .chezmoidata.yaml{Colors.NC}")

        print(f"\n{Colors.GREEN}✅ Reconciliation complete!{Colors.NC}")


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description='Reconcile locally installed packages with chezmoi dotfiles'
    )
    parser.add_argument(
        '-d', '--debug',
        action='store_true',
        help='Debug mode - show detected packages without making changes'
    )

    args = parser.parse_args()

    try:
        reconciler = Reconciler(debug=args.debug)
        reconciler.run()
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}⚠️  Interrupted by user{Colors.NC}")
        sys.exit(0)
    except Exception as e:
        print(f"{Colors.RED}❌ Error: {e}{Colors.NC}")
        if args.debug:
            raise
        sys.exit(1)


if __name__ == '__main__':
    main()
