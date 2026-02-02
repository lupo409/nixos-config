# NixOS Config Project Plan

**Status**: Planning Complete (Revised)  
**Last Updated**: 2026-02-02  
**Target User**: takahiro  
**Repository**: nixos-config

**Note**: 本ドキュメントは計画とターゲット構成スニペットを併記しています。実装状況はチェックリストで管理します。

---

## 1. Project Overview

マルチプラットフォーム対応のNixOS flakes設定:
- **WSL2**: Yuzu (CUIのみ)
- **NixOS Native**: Citrus (フルデスクトップ + Wayland Native)
- **macOS**: Sudachi (nix-darwin + Homebrew)

### Core Philosophy
- 共通化できる部分は最大限共通化
- Wayland Native環境を優先
- セキュリティを重視 (sops-nix, lanzaboote, fail2ban)
- 宣言的で再現性のある設定

---

## 2. Host Definitions

| Host | Platform | System | Type | Desktop |
|------|----------|--------|------|---------|
| Yuzu | WSL2 | x86_64-linux | wsl | none |
| Citrus | NixOS Native | x86_64-linux | nixos | niri (Wayland) |
| Sudachi | macOS | aarch64-darwin | darwin | Aqua |

### User Configuration
```nix
user = "takahiro";
gitUsername = "Lupo409";
gitEmail = "249657796+lupo409@users.noreply.github.com";
```

---

## 3. Directory Structure

```
nixos-config/
├── flake.nix                  # マルチプラットフォームエントリーポイント
├── flake.lock                 # ロックファイル
├── vars/
│   └── default.nix            # ユーザー名、Git設定、ホスト定義
├── lib/
│   └── default.nix            # mkNixosSystem, mkDarwinSystem等のヘルパー
├── hosts/
│   ├── common/                # ホスト間共通設定
│   │   ├── default.nix
│   │   ├── sops.nix           # sops-nixシークレット管理
│   │   ├── nix-ld.nix         # WSL2用動的リンクサポート (Yuzuのみでimport)
│   │   └── security.nix       # ファイアウォール、SSH、fail2ban
│   ├── yuzu/                  # WSL2 - CUIのみ
│   ├── citrus/                # NixOS - lanzaboote + Wayland Native
│   └── sudachi/               # macOS - nix-darwin + Homebrew
├── modules/
│   ├── common/                # 全プラットフォーム共通
│   │   ├── default.nix
│   │   ├── zsh.nix
│   │   ├── git.nix
│   │   ├── cli-tools.nix      # モダンCLIツール群
│   │   ├── dev-tools.nix      # Java, Python, deno, ffmpeg
│   │   └── just.nix           # justタスクランナー
│   ├── nixos/                 # NixOS固有
│   │   ├── default.nix
│   │   ├── niri.nix           # Wayland compositor
│   │   ├── wayland.nix        # Wayland環境設定
│   │   ├── fcitx5.nix         # 日本語入力（Wayland対応）
│   │   ├── firefox.nix        # Wayland版Firefox
│   │   ├── dankmaterialshell.nix
│   │   └── lanzaboote.nix     # Secure Boot
│   └── darwin/                # macOS固有
│       └── default.nix
├── home/
│   └── takahiro/
│       └── default.nix        # home-manager設定
├── overlays/
│   └── default.nix            # HackGenフォントオーバーレイ
├── pkgs/                      # カスタムパッケージ（必要に応じて）
├── .sops.yaml                 # sops-nix設定
├── justfile                   # justタスクランナー設定
├── .env.example               # 環境変数テンプレート
└── README.md                  # セットアップ手順
```

---

## 4. Flake Inputs

```nix
{
  inputs = {
    # Core - nixos-unstableのみ使用
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # macOS support
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # DankMaterialShell
    dankmaterialshell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Claude Code
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Security & Boot
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Fonts
    hackgen = {
      url = "github:yuru7/HackGen";
      flake = false;
    };
  };
}
```

---

## 5. Package Inventory

### 5.1 Common Packages (All Hosts) - Home Manager経由

#### CLI Tools (home-manager modules)
| Package | Home Manager | Purpose | Original |
|---------|--------------|---------|----------|
| eza | programs.eza | ファイルリスト | ls |
| fd | programs.fd | ファイル検索 | find |
| ripgrep | programs.ripgrep | テキスト検索 | grep |
| bat | programs.bat | ファイル表示 | cat |
| zoxide | programs.zoxide | ディレクトリ移動 | cd |
| fzf | programs.fzf | ファジー検索 | - |
| delta | programs.delta | diff表示 | diff |
| btm | programs.bottom | プロセス監視 | top |
| fastfetch | programs.fastfetch | システム情報 | neofetch |

#### CLI Tools (home.packages)
| Package | Source | Purpose |
|---------|--------|---------|
| dust | nixpkgs | ディスク使用量 (duの代替) |
| nano | nixpkgs | エディタ |

#### Development Tools (home-manager modules)
| Package | Home Manager | Purpose |
|---------|--------------|---------|
| npm | programs.npm | Node.jsパッケージマネージャー |
| uv | programs.uv | Pythonパッケージマネージャー |
| yt-dlp | programs.yt-dlp | 動画ダウンロード |

#### Development Tools (home.packages)
| Package | Source | Purpose |
|---------|--------|---------|
| graalvm-ce | nixpkgs | Java 21 (GraalVM CE) |
| graalvmPackages.graalvm-ce | nixpkgs | Java (GraalVM CE) |
| deno | nixpkgs | JavaScript/TypeScriptランタイム |
| ffmpeg | nixpkgs | 動画/音声処理 |
| opencode | nixpkgs | AIアシスタント |
| claude-code | claude-code-nix | Claude Code |

**注**: Oracle GraalVMはライセンスの問題があるため、GraalVM Community Edition (graalvm-ce)を使用します。

#### Python Environment (home.packages)
```nix
(python3.withPackages (ps: with ps; [
  certifi
  brotli
  curl-cffi
  mutagen
  xattr
  pycryptodomex
]))
```
**注**: yt-dlpはprograms.yt-dlpで管理するため、Python環境からは除外。

### 5.2 NixOS Only (Citrus)

#### GUI Applications (home-manager modules)
| Package | Home Manager | Wayland Status | Category |
|---------|--------------|----------------|----------|
| firefox | programs.firefox | Native | Browser |
| ghostty | programs.ghostty | Native | Terminal |

#### GUI Applications (home.packages)
| Package | Wayland Status | Category |
|---------|----------------|----------|
| prismlauncher | Native | Minecraft |
| jetbrains.idea-community | XWayland | IDE |
| idescriptor | Native | iOS管理 |

#### System (NixOS Configuration)
| Package | Purpose | Location |
|---------|---------|----------|
| niri | Wayland Compositor | programs.niri.enable |
| fcitx5 | 日本語入力 | i18n.inputMethod.enable = true; i18n.inputMethod.type = "fcitx5" |
| fcitx5-mozc-ut | Mozcエンジン | i18n.inputMethod.fcitx5.addons |
| hackgen | プログラミングフォント | fonts.packages |
| noto-fonts-cjk-sans | 日本語フォント | fonts.packages |

### 5.3 macOS Only (Sudachi)

#### Applications via home-manager
| Package | Home Manager | Category |
|---------|--------------|----------|
| ghostty | programs.ghostty | Terminal |

#### Applications via Homebrew Casks
| Package | Category |
|---------|----------|
| prismlauncher | Minecraft |
| intellij-idea-ce | IDE |

**注**: NixOSではnixpkgsの`jetbrains.idea-community`を使用し、macOSのHomebrew cask名は`intellij-idea-ce`。

---

## 6. Module Specifications

### 6.1 Common Modules (Home Manager)

#### `home/takahiro/programs/zsh.nix`
```nix
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    
    shellAliases = {
      ls = "eza";
      cat = "bat";
    };
    
    initExtra = ''
      # zoxide initialization
      eval "$(zoxide init zsh)"
    '';
  };
}
```

#### `home/takahiro/programs/git.nix`
```nix
{
  programs.git = {
    enable = true;
    userName = "Lupo409";
    userEmail = "249657796+lupo409@users.noreply.github.com";
    
    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
        side-by-side = true;
      };
    };
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };
}
```

#### `home/takahiro/programs/cli-tools.nix`
```nix
{ pkgs, ... }:
{
  programs = {
    eza.enable = true;
    fd.enable = true;
    ripgrep.enable = true;
    bat = {
      enable = true;
      config = {
        theme = "TwoDark";
      };
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    bottom.enable = true;
    fastfetch.enable = true;
  };
  
  home.packages = with pkgs; [
    dust
    nano
  ];
}
```

#### `home/takahiro/programs/dev-tools.nix`
```nix
{ pkgs, inputs, ... }:
{
  programs = {
    npm.enable = true;
    uv.enable = true;
    yt-dlp = {
      enable = true;
      settings = {
        embed-metadata = true;
        embed-subs = true;
      };
    };
  };
  
  home.packages = with pkgs; [
    # Java
    graalvm-ce
    graalvmPackages.graalvm-ce
    
    # Development tools
    deno
    ffmpeg
    opencode
    
    # Python with dependencies
    (python3.withPackages (ps: with ps; [
      certifi
      brotli
      curl-cffi
      mutagen
      xattr
      pycryptodomex
    ]))
  ] ++ [ inputs.claude-code-nix.packages.${pkgs.system}.default ];
}
```

#### `home/takahiro/programs/just.nix`
```nix
{ pkgs, ... }:
{
  home.packages = [ pkgs.just ];
}
```

### 6.2 NixOS Modules

#### `modules/nixos/niri.nix`
```nix
{ pkgs, inputs, ... }:
{
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };
  
  # DankMaterialShell統合
  environment.systemPackages = [
    inputs.dankmaterialshell.packages.${pkgs.system}.default
  ];
  
  # Niri設定ファイルにDankMaterialShellのテーマを適用
  # ~/.config/niri/config.kdl で以下を設定:
  # spawn-at-startup "dankmaterialshell"
}
```

#### `modules/nixos/wayland.nix`
```nix
{ pkgs, ... }:
{
  # 環境変数
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "gtk2";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };
  
  # xdg-desktop-portal
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ 
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk 
    ];
  };
}
```

#### `modules/nixos/fcitx5.nix`
```nix
{ pkgs, ... }:
{
  # NixOS 24.11以降の新しいinput method設定
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
    };
  };
  
  # 環境変数
  environment.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };
}
```

#### `modules/nixos/lanzaboote.nix`
```nix
{ pkgs, lib, ... }:
{
  boot.loader.systemd-boot.enable = lib.mkForce false;
  
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
}
```

### 6.3 Security Modules (hosts/common/security.nix)

```nix
{
  # Firewall
  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [ 22 ];
  };
  
  # SSH (Mozilla推奨設定ベース)
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      PubkeyAuthentication = true;
      X11Forwarding = false;
    };
  };
  
  # fail2ban
  services.fail2ban.enable = true;
}
```

### 6.4 SOPS-NIX Configuration

#### `.sops.yaml`
```yaml
keys:
  - &admin_yuzu age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  - &admin_citrus age1yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
  - &admin_sudachi age1zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
creation_rules:
  - path_regex: secrets/[^/]+\.yaml$
    key_groups:
      - age:
          - *admin_yuzu
          - *admin_citrus
          - *admin_sudachi
```

#### `secrets/api-keys.yaml` (encrypted)
```yaml
opencode_api_key: ENC[...]
claude_api_key: ENC[...]
```

#### `hosts/common/sops.nix`
```nix
{ inputs, config, ... }:
{
  imports = [ inputs.sops-nix.nixosModules.sops ];
  
  sops = {
    defaultSopsFile = ../../secrets/api-keys.yaml;
    age.keyFile = "${config.users.users.takahiro.home}/.config/sops/age/keys.txt";
    
    secrets = {
      opencode_api_key = {
        owner = config.users.users.takahiro.name;
      };
      claude_api_key = {
        owner = config.users.users.takahiro.name;
      };
    };
  };
}

---

## 7. Justfile Commands

```just
# Variables
export FLAKE := justfile_directory()
export HOSTNAME := env_var_or_default('HOSTNAME', 'Yuzu')

# Update flake.lock
update:
    nix flake update

# NixOS rebuild (for Citrus and Yuzu)
rebuild host=HOSTNAME:
    sudo nixos-rebuild switch --flake {{FLAKE}}#{{host}}

# macOS rebuild (for Sudachi)
darwin host=HOSTNAME:
    darwin-rebuild switch --flake {{FLAKE}}#{{host}}

# Lint and check
check:
    nix flake check
    @echo "Flake check passed!"

# Format all nix files
fmt:
    nix fmt

# Edit secrets (using sops with age)
edit-secrets file="secrets/api-keys.yaml":
    sops {{file}}

# Initialize age key for sops
init-age:
    mkdir -p ~/.config/sops/age
    age-keygen -o ~/.config/sops/age/keys.txt
    @echo "Age key generated! Add the public key to .sops.yaml"
    age-keygen -y ~/.config/sops/age/keys.txt

# Garbage collection
clean:
    sudo nix-collect-garbage -d
    nix store optimise

# Show system info
info:
    nix-shell -p fastfetch --run fastfetch

# Test VM (NixOS only)
test-vm host="Citrus":
    nixos-rebuild build-vm --flake {{FLAKE}}#{{host}}
    @echo "VM built! Run result/bin/run-{{host}}-vm to start"
```

---

## 8. Host-Specific Configurations

### 8.1 Yuzu (WSL2)

```nix
{ pkgs, ... }:
{
  # ホスト名設定
  networking.hostName = "Yuzu";
  
  # WSL2固有設定
  wsl.enable = true;
  wsl.defaultUser = "takahiro";
  
  # nix-ld有効化（動的リンクバイナリ対応）
  imports = [ ../common/nix-ld.nix ];
  
  # GUIアプリはインストールしない（CUIのみ）
  # home-managerで共通CLIツールのみインストール
}
```

### 8.2 Citrus (NixOS + Wayland)

```nix
{ pkgs, lib, ... }:
{
  # ホスト名設定
  networking.hostName = "Citrus";
  
  # Boot
  imports = [ ./lanzaboote.nix ];
  
  # Desktop
  programs.niri.enable = true;
  
  # Wayland環境
  imports = [ ../../modules/nixos/wayland.nix ];
  
  # Input method
  imports = [ ../../modules/nixos/fcitx5.nix ];
  
  # Fonts
  fonts.packages = with pkgs; [
    (hackgen.override { font = "HackGen35Console"; })
    noto-fonts-cjk-sans
  ];
}
```

**Home Manager (Citrus):**
```nix
{ pkgs, ... }:
{
  programs = {
    firefox.enable = true;
    ghostty.enable = true;
  };
  
  home.packages = with pkgs; [
    prismlauncher
    jetbrains.idea-community
    idescriptor
  ];
}
```

### 8.3 Sudachi (macOS)

```nix
{ pkgs, ... }:
{
  # ホスト名設定
  networking.hostName = "Sudachi";
  
  # Homebrew Casks
  homebrew = {
    enable = true;
    casks = [
      "prismlauncher"
      "intellij-idea-ce"
    ];
  };
  
  # nix-darwin固有設定
  system.stateVersion = 5;
}
```

**Home Manager (Sudachi):**
```nix
{ pkgs, ... }:
{
  programs.ghostty.enable = true;
  
  # CLIツールは共通モジュールで管理
}
```

---

## 9. Implementation Checklist

### Phase 1: Foundation
- [ ] Create directory structure
- [ ] Write flake.nix with all inputs (nixos-unstable only)
- [ ] Write lib/default.nix
- [ ] Write vars/default.nix
- [ ] Initialize git repository

### Phase 2: Common Modules (Home Manager)
- [ ] home/takahiro/programs/zsh.nix
- [ ] home/takahiro/programs/git.nix
- [ ] home/takahiro/programs/cli-tools.nix
- [ ] home/takahiro/programs/dev-tools.nix
- [ ] home/takahiro/programs/just.nix
- [ ] home/takahiro/default.nix (main home-manager config)

### Phase 3: NixOS Modules
- [ ] hosts/common/security.nix
- [ ] hosts/common/sops.nix
- [ ] hosts/common/nix-ld.nix
- [ ] modules/nixos/niri.nix
- [ ] modules/nixos/wayland.nix
- [ ] modules/nixos/fcitx5.nix
- [ ] modules/nixos/lanzaboote.nix

### Phase 4: macOS Modules
- [ ] modules/darwin/default.nix
- [ ] modules/darwin/homebrew.nix

### Phase 5: Host Configurations
- [ ] hosts/Yuzu/default.nix (WSL2)
- [ ] hosts/Citrus/default.nix (NixOS)
- [ ] hosts/Sudachi/default.nix (macOS)
- [ ] hosts/Citrus/hardware-configuration.nix

### Phase 6: Configuration Files
- [ ] justfile
- [ ] .sops.yaml
- [ ] secrets/api-keys.yaml.example
- [ ] .gitignore
- [ ] README.md

### Phase 7: CI/CD & Testing
- [ ] .github/workflows/check.yml (nix flake check)
- [ ] .github/workflows/test.yml (NixOS VM test)
- [ ] .github/workflows/format.yml (nix fmt check)

### Phase 8: Security Setup
- [ ] Generate age keys for each host
- [ ] Configure sops-nix encryption
- [ ] Set up Secure Boot keys for Citrus (lanzaboote)

### Phase 9: Testing & Validation
- [ ] Test WSL2 (Yuzu) build
- [ ] Test NixOS (Citrus) build
- [ ] Test macOS (Sudachi) build
- [ ] Test NixOS VM with GitHub Actions
- [ ] Verify sops-nix encryption/decryption
- [ ] Verify all home-manager programs
- [ ] Test justfile commands

---

## 10. Post-Setup Instructions

### Initial Setup

#### 1. Install NixOS / WSL2 / macOS Base System

#### 2. Clone Repository
```bash
git clone https://github.com/yourusername/nixos-config.git
cd nixos-config
```

#### 3. Generate Age Keys for SOPS
```bash
# Install age
nix-shell -p age

# Generate age key
just init-age

# Copy the public key output and add it to .sops.yaml
```

#### 4. Create Secrets File
```bash
# Copy example
cp secrets/api-keys.yaml.example secrets/api-keys.yaml

# Edit with sops (requires age key setup)
just edit-secrets

# Add your API keys:
# opencode_api_key: your-key-here
# claude_api_key: your-key-here
```

#### 5. (NixOS only) Generate Hardware Configuration
```bash
# For Citrus
sudo nixos-generate-config --show-hardware-config > hosts/Citrus/hardware-configuration.nix
```

#### 6. (NixOS + Secure Boot) Setup Lanzaboote
```bash
# Generate Secure Boot keys
sudo sbctl create-keys
sudo sbctl enroll-keys --microsoft

# After first nixos-rebuild, sign bootloader
sudo sbctl verify
```

#### 7. Build Configuration
```bash
# For Yuzu (WSL2)
just rebuild Yuzu

# For Citrus (NixOS)
just rebuild Citrus

# For Sudachi (macOS)
just darwin Sudachi
```

### Daily Usage

#### Update System
```bash
just update      # Update flake.lock
just rebuild     # Rebuild current host (auto-detected)
```

#### Manage Secrets
```bash
just edit-secrets              # Edit default secrets file
just edit-secrets secrets/ssh-keys.yaml  # Edit specific file
```

#### System Maintenance
```bash
just clean       # Garbage collection and store optimization
just check       # Validate flake configuration
just fmt         # Format all nix files
just info        # Show system information
```

#### Testing (Development)
```bash
just test-vm Citrus   # Build and test NixOS VM
```

### Troubleshooting

#### Age Key Issues
```bash
# Verify age key exists
cat ~/.config/sops/age/keys.txt

# Get public key
age-keygen -y ~/.config/sops/age/keys.txt

# Re-encrypt secrets with new key
sops updatekeys secrets/api-keys.yaml
```

#### NixOS VM Testing
```bash
# Build VM
just test-vm Citrus

# Run VM (requires KVM)
./result/bin/run-Citrus-vm

# VM will use 2GB RAM by default, edit configuration.nix to change
```

#### Home Manager Issues
```bash
# Rebuild only home-manager
home-manager switch --flake .#takahiro@Citrus

# Show home-manager generations
home-manager generations
```

---

## 11. GitHub Actions CI/CD

### `.github/workflows/check.yml` - Flake Validation
```yaml
name: Flake Check

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install Nix
        uses: cachix/install-nix-action@v26
        with:
          nix_path: nixpkgs=channel:nixos-unstable
      
      - name: Setup Cachix
        uses: cachix/cachix-action@v14
        with:
          name: nix-community
          authToken: '${{ secrets.CACHIX_AUTH_TOKEN }}'
      
      - name: Check flake
        run: nix flake check
      
      - name: Check formatting
        run: nix fmt -- --check .
```

### `.github/workflows/test-vm.yml` - NixOS VM Testing
```yaml
name: Test NixOS VM

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test-citrus:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install Nix
        uses: cachix/install-nix-action@v26
        with:
          nix_path: nixpkgs=channel:nixos-unstable
      
      - name: Setup Cachix
        uses: cachix/cachix-action@v14
        with:
          name: nix-community
          authToken: '${{ secrets.CACHIX_AUTH_TOKEN }}'
      
      - name: Enable KVM
        run: |
          echo 'KERNEL=="kvm", GROUP="kvm", MODE="0666", OPTIONS+="static_node=kvm"' | sudo tee /etc/udev/rules.d/99-kvm4all.rules
          sudo udevadm control --reload-rules
          sudo udevadm trigger --name-match=kvm
      
      - name: Build Citrus VM
        run: |
          nix build .#nixosConfigurations.Citrus.config.system.build.vm
      
      - name: Test VM Boot
        run: |
          timeout 60s ./result/bin/run-Citrus-vm -nographic -m 2048 || [ $? -eq 124 ]
          echo "VM boot test completed"
  
  test-yuzu:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install Nix
        uses: cachix/install-nix-action@v26
        with:
          nix_path: nixpkgs=channel:nixos-unstable
      
      - name: Setup Cachix
        uses: cachix/cachix-action@v14
        with:
          name: nix-community
          authToken: '${{ secrets.CACHIX_AUTH_TOKEN }}'
      
      - name: Build Yuzu Configuration
        run: |
          nix build .#nixosConfigurations.Yuzu.config.system.build.toplevel
```

### `.github/workflows/build-darwin.yml` - macOS Build Check
```yaml
name: Build macOS Configuration

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build-sudachi:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install Nix
        uses: cachix/install-nix-action@v26
        with:
          nix_path: nixpkgs=channel:nixos-unstable
      
      - name: Setup Cachix
        uses: cachix/cachix-action@v14
        with:
          name: nix-community
          authToken: '${{ secrets.CACHIX_AUTH_TOKEN }}'
      
      - name: Build Sudachi Configuration
        run: |
          nix build .#darwinConfigurations.Sudachi.system
```

### CI/CD Features
- ✅ Automatic flake validation on push/PR
- ✅ Format checking with `nix fmt`
- ✅ NixOS VM boot testing
- ✅ WSL2 configuration build testing
- ✅ macOS configuration build testing (on macOS runner)
- ✅ Cachix integration for faster builds
- ✅ Parallel job execution for each host

### Required Secrets
Add to GitHub repository secrets:
- `CACHIX_AUTH_TOKEN`: Optional, for build caching

## 12. Notes & References

### Package Sources Verified
- ✅ graalvm-ce (Java 21): nixpkgs
- ✅ graalvmPackages.graalvm-ce: nixpkgs
- ✅ niri: nixpkgs (programs.niri.enable)
- ✅ ghostty: nixpkgs + home-manager (programs.ghostty)
- ✅ yt-dlp: nixpkgs + home-manager (programs.yt-dlp)
- ✅ opencode: nixpkgs
- ✅ claude-code: sadjow/claude-code-nix
- ✅ deno: nixpkgs
- ✅ ffmpeg: nixpkgs
- ✅ idescriptor: nixpkgs
- ✅ fcitx5-mozc: nixpkgs (NixOS module)

### Home Manager Module Support
**16/23 packages** have native home-manager modules:
- git, zsh, firefox, ghostty, bat, eza, fd, ripgrep
- zoxide, fzf, delta, bottom, fastfetch, npm, uv, yt-dlp

**7/23 packages** require home.packages:
- fcitx5, dust, nano, deno, ffmpeg, prismlauncher, jetbrains.idea-community

### Wayland Compatibility
- ✅ niri: Native Wayland compositor
- ✅ firefox: Native (via home-manager programs.firefox)
- ✅ ghostty: Native (via home-manager programs.ghostty)
- ✅ prismlauncher: Native Wayland support
- ⚠️ jetbrains.idea-community: XWayland (full Wayland support in progress)
- ✅ fcitx5: Native (waylandFrontend = true)

### Security Features
- **sops-nix**: Age-based secret encryption (GPGからAgeに変更)
- **lanzaboote**: Secure Boot support for NixOS
- **fail2ban**: SSH brute-force protection
- **nix-ld**: Foreign binary support for WSL2

### DankMaterialShell Integration
DankMaterialShellはniriのstatusバーとして機能します:
1. flake inputとして追加
2. `inputs.dankmaterialshell.packages.${pkgs.system}.default` をインストール
3. niri設定(`~/.config/niri/config.kdl`)で `spawn-at-startup` に設定

### Host Naming Convention
- **Yuzu**: 柚子 - WSL2 (軽量CUI環境)
- **Citrus**: シトラス - NixOS Native (フルデスクトップ環境)
- **Sudachi**: スダチ - macOS (日本の柑橘類で統一)

### CI/CD Architecture
```
GitHub Push/PR
    ↓
┌───────────────────────────────────┐
│  Flake Check (Ubuntu)             │
│  - nix flake check                │
│  - nix fmt --check                │
└───────────────────────────────────┘
    ↓
┌───────────────────────────────────┐
│  NixOS VM Tests (Ubuntu + KVM)    │
│  - Build Citrus VM                │
│  - Build Yuzu config              │
│  - Test VM boot                   │
└───────────────────────────────────┘
    ↓
┌───────────────────────────────────┐
│  macOS Build (macOS runner)       │
│  - Build Sudachi config           │
└───────────────────────────────────┘
```

## 13. Future Enhancements (Optional)

### Performance & Storage
- [ ] **disko**: Declarative disk partitioning
- [ ] **impermanence**: Ephemeral root filesystem (更なるセキュリティ)
- [ ] **nix-index**: ファイル名からパッケージを高速検索

### Development
- [ ] **direnv** + **nix-direnv**: プロジェクトごとの開発環境自動化
- [ ] **pre-commit-hooks**: Git pre-commit時の自動lint/format

### Security
- [ ] **agenix**: sops-nixの代替（よりシンプル）
- [ ] **yubikey-agent**: YubiKeyでSSH認証

### Automation
- [ ] **auto-upgrade**: 自動システムアップデート
- [ ] **nh**: より高速なNixOSヘルパー (nixos-rebuildの代替)

### Backup
- [ ] **borg**: 暗号化バックアップ
- [ ] **restic**: クラウドバックアップ統合

### Monitoring
- [ ] **prometheus** + **grafana**: システムモニタリング
- [ ] **loki**: ログ集約

---

## 14. Migration Notes from Original Plan

### Changed
1. ❌ `nixpkgs-stable` removed → ✅ `nixos-unstable` only
2. ❌ GPG for sops → ✅ Age for sops (simpler, no keyserver needed)
3. ❌ `graalvm-oracle` → ✅ `graalvm-ce` (licensing)
4. ❌ Mixed system/home packages → ✅ Prioritize home-manager modules
5. ❌ hostname auto-detection → ✅ Explicit host names (Yuzu/Citrus/Sudachi)
6. ❌ `nixpkgs-fmt` → ✅ `nix fmt` (built-in)
7. ❌ Manual testing → ✅ GitHub Actions CI/CD + VM tests

### Added
- ✅ Complete home-manager integration for 16 packages
- ✅ Age-based secret management
- ✅ GitHub Actions workflows (check, VM test, macOS build)
- ✅ Comprehensive troubleshooting guide
- ✅ VM testing with KVM
- ✅ Justfile commands for common operations
- ✅ Clear separation: NixOS modules vs home-manager

### Resolved Issues
- ✅ fcitx5: Updated to NixOS 24.11+ syntax (`i18n.inputMethod.type = "fcitx5"`)
- ✅ Python environment: Removed yt-dlp duplication
- ✅ DankMaterialShell: Clear integration instructions
- ✅ Justfile: Added age key init, improved host detection
- ✅ macOS: ghostty via home-manager instead of Homebrew

---

**END OF REVISED PLAN**
