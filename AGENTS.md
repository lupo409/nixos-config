# AI Agents Guide

**Last Updated**: 2026-02-02  
**Project**: nixos-config (multi-platform Nix flake)  
**Purpose**: Guidance for OpenCode/Claude Code usage in this repo

---

## 1. Repository Overview

This repo manages three hosts with a single flake:

- **Citrus** (NixOS)
- **Sudachi** (macOS, nix-darwin)

Key paths:

- `flake.nix`: flake inputs + outputs
- `vars/default.nix`: host metadata and user info
- `lib/default.nix`: helper constructors for NixOS/Darwin
- `hosts/<host>/default.nix`: host-specific config
- `home/takahiro/*`: Home Manager modules
- `modules/nixos/*`: NixOS modules (wayland, fcitx5, niri, secure-boot)
- `modules/darwin/default.nix`: Darwin base settings
- `overlays/default.nix`: custom overlays (HackGen font)
- `.github/workflows/*`: CI workflows

---

## 2. AI Agent Usage Policy

Agents should:

- Follow existing structure (`hosts/`, `modules/`, `home/` split).
- Prefer Home Manager for user packages/config.
- Keep Nix formatting consistent with `nix fmt`.
- Avoid committing secrets or encrypted files.

Agents should not:

- Commit `secrets/*.yaml` or any secret files.
- Introduce host-specific changes in shared modules unless scoped.

---

## 3. OpenCode and Claude Code

### 3.1 OpenCode

Installed via Home Manager in `home/takahiro/programs/dev-tools.nix`:

```nix
home.packages = with pkgs; [
  opencode
  # ...
];
```

### 3.2 Claude Code

Provisioned via `claude-code-nix` flake input in `home/takahiro/programs/dev-tools.nix`.

---

## 4. Secrets Management

Secrets are managed with `sops-nix`.

Paths:

- Encrypted secrets: `secrets/api-keys.yaml`
- Example: `secrets/api-keys.yaml.example`
- Age key: `~/.config/sops/age/keys.txt`
- Rules: `.sops.yaml`

Setup (local):

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt
cp secrets/api-keys.yaml.example secrets/api-keys.yaml
sops secrets/api-keys.yaml
```

---

## 5. Common Tasks (Agent Prompts)

### 5.1 Add a package

```bash
opencode "Add ripgrep via home-manager in cli-tools.nix and rebuild Citrus"
```

### 5.2 Add a host

```bash
opencode "Add a new NixOS host 'Mikan' based on Citrus and update flake outputs"
```

### 5.3 Debug build errors

```bash
opencode "Nix build failed with: <error>. Find the cause and fix it."
```

---

## 6. CI Workflows

Workflows:

- `check.yml`: `nix flake check` + `nix fmt -- --check .`
- `test-vm.yml`: Citrus VM build
- `build-darwin.yml`: macOS build for Sudachi
- `flake-maintenance.yml`: weekly lock + home.stateVersion update

Manual triggers are enabled via `workflow_dispatch`.

---

## 7. Conventions and Testing

Formatting:

- Always run `nix fmt` before committing Nix changes.

Validation:

- `nix flake check` for general verification.
- Use `sudo nixos-rebuild switch --flake .#<host>` or `darwin-rebuild switch --flake .#<host>` for host builds.

---

**Maintainer**: takahiro  
**Status**: Living document
