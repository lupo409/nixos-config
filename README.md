# nixos-config

Multi-platform Nix flake configuration for:

- Yuzu (WSL2)
- Citrus (NixOS)
- Sudachi (macOS)

## Quick Start

```bash
git clone https://github.com/yourusername/nixos-config.git
cd nixos-config
```

### Secrets setup

```bash
just init-age
cp secrets/api-keys.yaml.example secrets/api-keys.yaml
just edit-secrets
```

### Build

```bash
just rebuild Yuzu
just rebuild Citrus
just darwin Sudachi
```
Multi-platform Nix flake configuration for:

- Yuzu (WSL2)
- Citrus (NixOS)
- Sudachi (macOS)

## Quick Start

```bash
git clone https://github.com/yourusername/nixos-config.git
cd nixos-config
```

### Secrets setup

```bash
just init-age
cp secrets/api-keys.yaml.example secrets/api-keys.yaml
just edit-secrets
```

### Build

```bash
just rebuild Yuzu
just rebuild Citrus
just darwin Sudachi
```
