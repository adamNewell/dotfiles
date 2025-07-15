# Chezmoi Encryption Guide

This guide explains how to securely handle sensitive files in your dotfiles using chezmoi's built-in encryption with age.

## Overview

Chezmoi supports encrypting sensitive files using the `age` encryption tool. This allows you to store secrets, API keys, SSH configurations, and other sensitive data in your dotfiles repository safely.

## Setup

### 1. Install age

Age should be installed automatically via the package definitions, but you can install it manually:

```bash
# macOS
brew install age

# Linux
# Will be installed via .chezmoiexternal.yaml if not available in package manager
```

### 2. Generate an age key

```bash
# Generate a new age key
age-keygen -o ~/.config/chezmoi/key.txt

# The public key will be displayed, save it for the next step
```

### 3. Configure chezmoi

Add your age recipient to chezmoi's configuration:

```bash
# Edit chezmoi config
chezmoi edit-config
```

Add the following to your `~/.config/chezmoi/chezmoi.toml`:

```toml
encryption = "age"
[age]
    identity = "~/.config/chezmoi/key.txt"
    recipient = "age1your-public-key-here"
```

## Usage

### Encrypting Files

To encrypt a file with chezmoi, use the `private_encrypted_` prefix:

```bash
# Original file: ~/.ssh/config
# Chezmoi file: private_encrypted_dot_ssh/config.age

# Add an encrypted file
chezmoi add --encrypt ~/.ssh/config

# This creates: .local/share/chezmoi/private_encrypted_dot_ssh/config.age
```

### File Naming Convention

| Original Path | Chezmoi Path | Description |
|---------------|--------------|-------------|
| `~/.ssh/config` | `private_encrypted_dot_ssh/config.age` | SSH configuration |
| `~/.aws/credentials` | `private_encrypted_dot_aws/credentials.age` | AWS credentials |
| `~/.env` | `private_encrypted_env.age` | Environment variables |
| `~/.gitconfig` | `private_encrypted_dot_gitconfig.age` | Git configuration with tokens |

### Editing Encrypted Files

```bash
# Edit an encrypted file
chezmoi edit ~/.ssh/config

# View an encrypted file without applying
chezmoi cat ~/.ssh/config

# Apply a specific encrypted file
chezmoi apply ~/.ssh/config
```

### Managing Secrets

#### Environment Variables
Create `private_encrypted_env.age` for sensitive environment variables:

```bash
chezmoi add --encrypt ~/.env
```

#### SSH Configuration
```bash
# Add SSH config with sensitive hosts/keys
chezmoi add --encrypt ~/.ssh/config

# Add SSH private keys
chezmoi add --encrypt ~/.ssh/id_ed25519
chezmoi add --encrypt ~/.ssh/id_rsa
```

#### Git Configuration
```bash
# If your .gitconfig contains tokens or sensitive info
chezmoi add --encrypt ~/.gitconfig
```

## Security Best Practices

### 1. Key Management
- **Never commit your private key** (`~/.config/chezmoi/key.txt`) to the repository
- Store your private key securely (password manager, secure backup)
- Consider using multiple keys for different security levels

### 2. File Permissions
Encrypted files automatically get appropriate permissions when decrypted:
- `private_` prefix sets files to mode 600 (owner read/write only)
- `private_encrypted_` combines both encryption and restricted permissions

### 3. Backup Strategy
- Keep a secure backup of your age private key
- Test decryption regularly to ensure key integrity
- Document key recovery procedures

### 4. What to Encrypt
**Always encrypt:**
- SSH private keys and configs with sensitive hosts
- API keys and tokens
- Database credentials
- Cloud provider credentials
- VPN configurations
- Email/chat application tokens

**Consider encrypting:**
- Git configuration (if it contains tokens)
- Application-specific configs with secrets
- Browser bookmarks (if they contain sensitive URLs)

**Don't encrypt:**
- Public configurations
- Shell aliases and functions
- Editor configurations (unless they contain tokens)
- Package lists

## Troubleshooting

### Key Issues
```bash
# Verify age key
age-keygen -y ~/.config/chezmoi/key.txt

# Test encryption/decryption
echo "test" | age -r age1your-public-key-here | age -d -i ~/.config/chezmoi/key.txt
```

### File Issues
```bash
# Check if file is properly encrypted
file .local/share/chezmoi/private_encrypted_dot_ssh/config.age

# Verify chezmoi can decrypt
chezmoi execute-template "{{ include \"private_encrypted_dot_ssh/config.age\" | decrypt }}"
```

### Permission Issues
If decrypted files have wrong permissions:
```bash
# Force re-apply with correct permissions
chezmoi apply --force ~/.ssh/config
```

## Migration from Unencrypted

To migrate existing unencrypted sensitive files:

```bash
# 1. Remove from chezmoi (but keep original)
chezmoi remove ~/.ssh/config

# 2. Add back with encryption
chezmoi add --encrypt ~/.ssh/config

# 3. Verify
chezmoi diff
```

## Integration with CI/CD

For automated deployments, you can:

1. Store the age key as a secret in your CI system
2. Use chezmoi's `--source` flag to specify the dotfiles location
3. Apply only non-encrypted files in CI environments

```bash
# Apply only public configurations
chezmoi apply --exclude encrypted
```

---

**Remember**: Encryption is only as strong as your key management. Keep your age private key secure and never commit it to version control.