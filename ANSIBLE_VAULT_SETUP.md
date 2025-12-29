# Ansible Vault Setup Guide

This project uses Ansible Vault to securely encrypt sensitive variables like passwords and API keys.

## Files Structure

- `group_vars/all.yml` - Contains non-sensitive configuration variables and references to vault variables
- `group_vars/vault.yml` - Contains sensitive variables (should be encrypted)

## Initial Setup

### 1. Encrypt the vault file

Before pushing to GitHub, encrypt the `group_vars/vault.yml` file:

```bash
ansible-vault encrypt group_vars/vault.yml
```

You'll be prompted to create a vault password. **Remember this password** - you'll need it to run playbooks.

### 2. Create a vault password file (Optional but recommended)

For easier automation, create a password file:

```bash
echo "your-vault-password" > .vault_pass
chmod 600 .vault_pass
```

**Important:** The `.vault_pass` file is already in `.gitignore` and should NEVER be committed to git.

## Using Ansible Vault

### Encrypt a file
```bash
ansible-vault encrypt group_vars/vault.yml
```

### Decrypt a file (temporarily)
```bash
ansible-vault decrypt group_vars/vault.yml
```

### Edit an encrypted file
```bash
ansible-vault edit group_vars/vault.yml
```

### View an encrypted file
```bash
ansible-vault view group_vars/vault.yml
```

### Change vault password
```bash
ansible-vault rekey group_vars/vault.yml
```

## Running Playbooks with Vault

### Option 1: Prompt for password
```bash
ansible-playbook -i inventory.ini site.yml --ask-vault-pass
```

### Option 2: Use password file
```bash
ansible-playbook -i inventory.ini site.yml --vault-password-file .vault_pass
```

### Option 3: Use environment variable
```bash
export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass
ansible-playbook -i inventory.ini site.yml
```

## Best Practices

1. **Never commit unencrypted secrets** to version control
2. **Keep vault password secure** - store it in a password manager
3. **Use different vault passwords** for different environments (dev, staging, prod)
4. **Rotate secrets regularly** and update the vault file
5. **Backup vault password** - losing it means losing access to encrypted data

## Updating Secrets

To update a secret value:

```bash
# Edit the encrypted file
ansible-vault edit group_vars/vault.yml

# Make your changes and save
# The file will remain encrypted after saving
```

## Troubleshooting

### "Decryption failed" error
- Verify you're using the correct vault password
- Check if the file is actually encrypted: `head group_vars/vault.yml` (should show `$ANSIBLE_VAULT;1.1;AES256`)

### Forgot vault password
- If you have an unencrypted backup, you can re-encrypt with a new password
- Otherwise, you'll need to recreate the vault file with new credentials

## Security Notes

- The vault file is encrypted using AES256
- Encryption happens locally before committing to git
- GitHub will not be able to read the encrypted content
- Only users with the vault password can decrypt and use the secrets
