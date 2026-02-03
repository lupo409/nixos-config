# Agents Guide

## Scope

This document provides guidelines for AI agents and automated tools working with this NixOS configuration repository.

## Project Layout

| Path | Description |
|------|-------------|
| `flake.nix` | Flake definition with inputs and outputs |
| `flake.lock` | Locked flake dependencies |
| `vars/default.nix` | User and host metadata (username, git config) |
| `lib/default.nix` | System constructors (`mkNixosSystem` helper) |
| `hosts/<host>/default.nix` | Host-specific configuration |
| `hosts/common/*.nix` | Shared host-level configuration |
| `hosts/<host>/*.nix` | Host-specific slices (boot, locale, users, etc.) |
| `modules/nixos/*.nix` | Reusable NixOS modules |
| `home/<user>/default.nix` | Home Manager entry point |
| `home/<user>/programs/*.nix` | Home Manager modules organized by responsibility |
| `overlays/default.nix` | Package overlays |
| `secrets/` | Secret examples (never commit `*.yaml`, only `*.example`) |

## Rules

- **One file = one responsibility**: Keep modules focused and cohesive.
- **Prefer Home Manager**: Use Home Manager for user-level packages and configuration.
- **Nix formatting**: Align code with `nix fmt` (uses `nixpkgs-fmt`).
- **No secrets in git**: Never commit `secrets/*.yaml` files.
- **Avoid host-specific code in shared modules**: Keep `hosts/common/` and `modules/` generic.
- **Keep host slices small**: Split `hosts/<host>/` by responsibility (boot, users, locale, desktop, nix, packages).

## CI/CD Pipeline

### Important: Local Tools Are Not Available

**`nix fmt` and similar Nix commands cannot be run locally in this environment.** All formatting and validation is performed automatically by GitHub Actions when changes are pushed.

### GitHub Actions Workflows

| Workflow | Trigger | Duration | Purpose |
|----------|---------|----------|---------|
| `check.yml` | Push to `main`/`develop`, PRs | ~2-5 min | Runs `nix flake check` and formatting validation |
| `test-vm.yml` | Push to `main`/`develop`, PRs | **10+ min** | Builds and boots Citrus VM for integration testing |
| `flake-maintenance.yml` | Weekly (Monday 3:00 UTC) | ~5 min | Auto-updates `flake.lock` |

### Workflow for Agents

1. **Make changes** to the configuration files.
2. **Push commits** to the repository.
3. **Wait for CI completion**: Allow sufficient time for GitHub Actions to complete:
   - For formatting/check: Wait at least 5 minutes
   - For VM tests: Wait at least 15 minutes
4. **Verify results**: Check the workflow run status on GitHub.
5. **Resolve all errors**: If CI fails, analyze the error output and fix all issues before considering the task complete.

> **Critical**: Do not leave unresolved errors. All CI checks must pass before concluding your work.

## Key Commands (for reference)

```bash
# Apply NixOS configuration (run on NixOS host)
sudo nixos-rebuild switch --flake .#Citrus

# Format code (runs nixpkgs-fmt)
nix fmt

# Validate flake
nix flake check

# Update flake inputs
nix flake update

```

## Common Agent Tasks

### Adding a CLI tool via Home Manager

Edit `home/takahiro/programs/cli-tools.nix` and add the package to the appropriate list.

### Adding a new NixOS module

1. Create `modules/nixos/<module-name>.nix`
2. Import it in the appropriate host's `default.nix`

### Editing Citrus host config

Prefer adding or editing host slices in `hosts/citrus/` rather than growing `hosts/citrus/default.nix`.

### Adding a new host

1. Create `hosts/<hostname>/default.nix` and `hardware-configuration.nix`
2. Add the host to `vars/default.nix`
3. Add the nixosConfiguration output in `flake.nix`

## Example Prompts

```bash
opencode "Add ripgrep via home-manager in cli-tools.nix and rebuild Citrus"
opencode "Add a new NixOS host 'Mikan' based on Citrus and update flake outputs"
opencode "Nix build failed with: <error>. Find the cause and fix it."
```

## Error Resolution Protocol

When errors occur in GitHub Actions:

1. **Read the full error message** from the workflow logs.
2. **Identify the root cause**: syntax errors, missing imports, incorrect attribute paths, etc.
3. **Fix all issues**: Do not stop at partial fixes.
4. **Commit and push** the corrections.
5. **Wait and verify** that CI passes before finishing.

Remember: A task is not complete until all CI checks are green.
