# nixos-config

Multi-platform Nix flake configuration for:

- Citrus (NixOS)
- Sudachi (macOS, nix-darwin)

## Requirements

- Nix with flakes enabled

## Quick Start

```bash
git clone https://github.com/lupo409/nixos-config.git
cd nixos-config
```

## Secrets setup (SOPS)

This repo uses `sops-nix` for secrets. You need an Age key and an encrypted
`secrets/api-keys.yaml` file.

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt
cp secrets/api-keys.yaml.example secrets/api-keys.yaml
sops secrets/api-keys.yaml
```

Then add your Age public key to `.sops.yaml` and re-encrypt if needed.

## Host builds

### Citrus (NixOS)

Generate a hardware configuration first:

```bash
sudo nixos-generate-config --show-hardware-config > hosts/citrus/hardware-configuration.nix
```

Then build:

```bash
sudo nixos-rebuild switch --flake .#Citrus

# Secure Boot (once)
sudo sbctl create-keys
sudo sbctl enroll-keys --microsoft
sudo sbctl verify
```

### Sudachi (macOS)

```bash
darwin-rebuild switch --flake .#Sudachi
```

## Common maintenance

```bash
nix fmt
nix flake check
```

## GitHub Actions

Manual runs (via gh):

```bash
gh workflow run "Flake Check"
gh workflow run "Test NixOS VM"
gh workflow run "Build macOS Configuration"
gh workflow run "Flake Maintenance"
```
