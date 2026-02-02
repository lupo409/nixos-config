# NixOS Config - AI Agents Guide

**Last Updated**: 2026-02-02  
**Project**: nixos-config (Multi-platform Nix Configuration)  
**Purpose**: OpenCode等のAIエージェントを活用した開発ワークフロー

---

## 1. Overview

このドキュメントは、nixos-configプロジェクトの開発において、OpenCodeやClaude Code等のAIエージェントを効果的に活用するためのガイドです。

### Available AI Tools
- **OpenCode**: CLI統合型コーディングエージェント（本プロジェクトで利用中）
- **Claude Code**: Claude APIを使用したコードアシスタント

---

## 2. OpenCode Integration

### 2.1 Installation Status

OpenCodeはnixos-configの全ホストで利用可能です:

| Host | Platform | OpenCode Status | Installation Method |
|------|----------|-----------------|---------------------|
| Yuzu | WSL2 | ✅ Available | home-manager (home.packages) |
| Citrus | NixOS | ✅ Available | home-manager (home.packages) |
| Sudachi | macOS | ✅ Available | home-manager (home.packages) |

**Configuration**: `home/takahiro/programs/dev-tools.nix`
```nix
home.packages = with pkgs; [
  opencode
  # ...
];
```

### 2.2 API Key Management

API keyはsops-nixで安全に管理されています:

```bash
# APIキーの編集
just edit-secrets

# secrets/api-keys.yaml (暗号化)
opencode_api_key: ENC[...]
claude_api_key: ENC[...]
```

**Setup Flow**:
1. `just init-age` - Age鍵ペア生成
2. 公開鍵を `.sops.yaml` に追加
3. `just edit-secrets` - APIキーを入力
4. システムリビルド時に自動的に復号化され、環境変数として利用可能

**Secrets Location**:
- 暗号化ファイル: `secrets/api-keys.yaml`
- Age秘密鍵: `~/.config/sops/age/keys.txt`
- NixOS設定: `hosts/common/sops.nix`

---

## 3. Common Workflows with OpenCode

### 3.1 Initial Setup & Configuration

#### プロジェクト構造の理解
```bash
# OpenCodeにプロジェクト構造を説明させる
opencode "nixos-configのディレクトリ構造を説明して"

# 特定のモジュールの役割を確認
opencode "modules/nixos/niri.nixの役割を説明して"
```

#### 新しいホストの追加
```bash
opencode "新しいWSL2ホスト 'Mikan' を追加したい。Yuzuをベースに必要なファイルを作成して"
```

**Expected Output**:
- `hosts/Mikan/default.nix`
- `flake.nix` の `nixosConfigurations` に追加
- `vars/default.nix` のホスト定義更新

### 3.2 Package Management

#### パッケージの追加
```bash
# 特定のパッケージをインストール
opencode "ripgrepをhome-managerで管理したい。適切なモジュールがあるか確認して、最適な方法で追加して"

# 開発ツールの追加
opencode "Rustの開発環境を追加したい。rustup、cargo、rust-analyzerをインストールして"
```

**OpenCode will**:
1. nixpkgsでパッケージの存在確認
2. home-managerモジュールの有無チェック
3. 適切な設定ファイルを更新（`dev-tools.nix` または `cli-tools.nix`）
4. 必要に応じてflake inputsを追加

#### パッケージの検索
```bash
opencode "nixpkgsにあるMarkdownエディタを検索して、Wayland対応のものを推奨して"
```

### 3.3 Module Development

#### 新しいモジュールの作成
```bash
opencode "home-manager用にtmux設定モジュールを作成して。vim風キーバインドと256色対応を含めて"
```

**Expected Structure**:
```nix
# home/takahiro/programs/tmux.nix
{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    keyMode = "vi";
    # ...
  };
}
```

#### 既存モジュールの改善
```bash
opencode "zsh.nixにstarship promptを統合して。設定はhome-managerのprograms.starshipを使って"
```

### 3.4 Debugging & Troubleshooting

#### ビルドエラーの解決
```bash
# エラーメッセージを渡して解決策を提案
opencode "nixos-rebuild時に以下のエラーが出た: [エラーメッセージをペースト]。原因と解決方法を教えて"

# 特定のモジュールの問題診断
opencode "fcitx5が起動しない。modules/nixos/fcitx5.nixをチェックして、環境変数とsystemd設定を確認して"
```

#### 依存関係の確認
```bash
opencode "niriが必要とする全てのWayland依存パッケージをリストアップして"
```

### 3.5 Security & Secrets Management

#### SOPS設定の更新
```bash
opencode "新しいホストSudachiのAge公開鍵を.sops.yamlに追加して"

# 新しいシークレットの追加
opencode "GitHub tokenを安全に管理したい。sops-nixを使ってsecrets/github.yamlを作成して"
```

#### セキュリティ設定の強化
```bash
opencode "security.nixにSSH接続のrate limitingを追加して。fail2banと連携させて"
```

### 3.6 Testing & Validation

#### テストスクリプトの生成
```bash
opencode "全ホストのビルドをテストするシェルスクリプトを作成して。エラーログを保存する機能も含めて"
```

#### CI/CDワークフローの改善
```bash
opencode "GitHub Actionsで、flake.lockが更新されたら自動的にPRを作成するworkflowを追加して"
```

---

## 4. Advanced Patterns

### 4.1 Flake Input Updates

```bash
# 特定のinputを最新版に更新
opencode "home-managerのinputを最新のmainブランチに更新して、flake.lockも更新して"

# 新しいflake inputの追加
opencode "nixpkgsからneovim-nightlyを使いたい。neovim/neovim flakeをinputに追加して"
```

### 4.2 Cross-Platform Configuration

```bash
# macOS特有の設定追加
opencode "Sudachi(macOS)でyabai(tiling WM)を追加したい。nix-darwin経由でインストールして"

# WSL2特有の問題解決
opencode "YuzuでVSCodeのnix-ld統合を有効化したい。nix-ld.nixを更新して"
```

### 4.3 Home Manager Generations

```bash
# 世代管理の自動化
opencode "home-managerの古い世代を自動削除するjustfileコマンドを追加して。最新5世代のみ保持"
```

### 4.4 Documentation Generation

```bash
# モジュール一覧の自動生成
opencode "全てのhome-managerモジュールを一覧化したREADME.mdを生成して。各モジュールの説明とオプションを含めて"

# 設定変更履歴の記録
opencode "git logから今週の設定変更をまとめたCHANGELOG.mdエントリを作成して"
```

---

## 5. Best Practices

### 5.1 Context Provision

OpenCodeに十分なコンテキストを提供するため:

```bash
# ❌ Bad: 曖昧な指示
opencode "firefoxを追加して"

# ✅ Good: 明確な指示
opencode "CitrusホストのみにFirefoxを追加して。home-managerのprograms.firefoxを使用し、Wayland対応を有効化して"
```

### 5.2 Incremental Changes

大きな変更は段階的に:

```bash
# Step 1: 構造確認
opencode "現在のhome-manager設定構造を説明して"

# Step 2: 計画
opencode "全てのCLIツールをprograms/cli-tools.nixに統合する計画を立てて"

# Step 3: 実装
opencode "計画に従ってcli-tools.nixを作成し、既存設定をマイグレーションして"

# Step 4: 検証
opencode "変更をテストするための手順を教えて"
```

### 5.3 Validation Requests

変更後は必ず検証を依頼:

```bash
opencode "今の変更でnix flake checkが通るか確認して。エラーがあれば修正して"

opencode "追加したRust設定が全ホストで正しくビルドされるか、dry-runで確認して"
```

### 5.4 Learning & Exploration

OpenCodeを使った学習:

```bash
# Nixの概念理解
opencode "flake inputsのfollows指定が何をしているか、具体例で説明して"

# ベストプラクティス確認
opencode "home-manager設定でsystemパッケージとhome.packagesを使い分ける基準を教えて"

# 代替案の検討
opencode "sops-nixの代わりにagenixを使う場合の移行手順を教えて"
```

---

## 6. Project-Specific Prompts

### 6.1 Common Tasks Cheatsheet

#### システム更新
```bash
opencode "flake inputsを全て最新に更新し、変更されたパッケージのリストを生成して"
```

#### 新機能追加
```bash
opencode "CitrusにHyprland(Wayland compositor)のサポートを追加したい。niriと共存できるように設定して"
```

#### パフォーマンス最適化
```bash
opencode "ビルド時間を短縮したい。不要な依存関係や重複インポートを検出して"
```

#### ドキュメント更新
```bash
opencode "PLANS.mdとREADME.mdを現在の実装状態に合わせて更新して"
```

### 6.2 Host-Specific Tasks

#### Yuzu (WSL2)
```bash
opencode "YuzuでDocker環境を追加したい。virtualisation.dockerを有効化して"
```

#### Citrus (NixOS)
```bash
opencode "Citrusのlanzaboote設定をチェックして、Secure Boot keyの状態も確認して"
```

#### Sudachi (macOS)
```bash
opencode "Sudachiでhomebrewのcaskをnixpkgsに移行できるものをリストアップして"
```

---

## 7. Integration with Tools

### 7.1 Just + OpenCode

Justfileコマンドをベースにした自動化:

```bash
# Justfile生成
opencode "よく使うnix操作をjustfileコマンドに追加して: フォーマット、チェック、差分表示"

# エラーハンドリング追加
opencode "just rebuildが失敗したら、エラーをログに保存し、OpenCodeを起動して解決策を提案するようにして"
```

### 7.2 Git Hooks + OpenCode

自動コードレビュー:

```bash
opencode "pre-commit hookで、変更されたnixファイルにnix fmtとnix flake checkを実行するスクリプトを作成して"
```

### 7.3 GitHub Actions + OpenCode

CI/CDの強化:

```bash
opencode "GitHub ActionsでPR時に設定の差分を自動コメントするworkflowを作成して"
```

---

## 8. Troubleshooting with OpenCode

### 8.1 Common Issues

#### ビルドエラー
```bash
# Flake evaluation error
opencode "error: attribute 'package' missing と出た。関連するflake.nixとモジュールを確認して"

# Dependency conflict
opencode "package 'foo-1.0' conflicts with 'foo-2.0' エラー。overlayの問題か確認して"
```

#### Runtime問題
```bash
# Wayland関連
opencode "NiriでFirefoxがXWaylandで起動してしまう。環境変数を確認して"

# Input method問題
opencode "fcitx5が起動しているが日本語入力ができない。Mozc設定とIM環境変数をチェックして"
```

#### Secrets問題
```bash
# SOPS復号化エラー
opencode "sops decryption failed: no key in keyring エラー。Age key設定を確認して"

# Permission問題
opencode "secret fileが読めない。ownerとpermissionを確認して"
```

### 8.2 Debugging Workflow

```bash
# 1. 現状確認
opencode "現在のシステム状態を診断して: nix-info -m, flake check, hardware情報"

# 2. ログ収集
opencode "systemd journalから関連エラーを抽出して、整形して表示して"

# 3. 修正提案
opencode "収集した情報から原因を特定し、修正案を3つ提示して"

# 4. テスト
opencode "修正をdry-runでテストするコマンドを実行して"
```

---

## 9. Future Enhancements

### 9.1 OpenCode Custom Commands

カスタムスラッシュコマンドの追加可能性:

```bash
# /nix-add-package <package-name>
# 自動的にnixpkgs検索 → 最適な設定場所に追加

# /nix-update-module <module-path>
# モジュールの依存関係を更新し、ベストプラクティスに準拠

# /nix-diagnose
# システム全体の健全性チェック
```

### 9.2 AI-Assisted Configuration

```bash
# 自動最適化
opencode "使用頻度の低いパッケージを検出し、オンデマンドロードに変更して"

# パーソナライズ
opencode "git logから私の開発パターンを分析して、最適なCLIエイリアスを提案して"
```

---

## 10. Resources

### Official Documentation
- [OpenCode Docs](https://opencode.ai/docs)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)

### Project Files
- `PLANS.md` - 完全なプロジェクト計画
- `README.md` - セットアップ手順
- `justfile` - タスクランナー定義

### AI Tools
- **OpenCode**: `opencode <prompt>`
- **Claude Code**: `claude-code <prompt>`

---

## 11. Contributing Guidelines for AI Agents

OpenCodeで設定変更を行う際のガイドライン:

### 11.1 Code Style
- Nixファイルは常に `nix fmt` でフォーマット
- インデントは2スペース
- コメントは日本語でも英語でもOK（文脈に応じて）

### 11.2 Commit Messages
```bash
# 推奨フォーマット
opencode "git commitメッセージを生成して。conventionalcommits形式で、変更内容を簡潔に"

# 例:
# feat(nixos): add Hyprland compositor support
# fix(home): resolve fcitx5 startup issue
# docs(agents): add troubleshooting section
```

### 11.3 Testing Requirements
変更前に必ず実行:
```bash
nix flake check
nix fmt
just rebuild <host>  # または darwin <host>
```

OpenCodeに依頼する場合:
```bash
opencode "今の変更を全ホストでテストして。問題があれば修正して"
```

---

**Last Updated**: 2026-02-02  
**Maintained by**: takahiro (with OpenCode assistance)  
**Status**: Living Document - 継続的に更新中

---

## Appendix A: Quick Reference

### Essential Commands
```bash
# システムビルド
just rebuild        # 現在のホスト
just rebuild Citrus # 特定のホスト

# OpenCode起動
opencode
opencode "<prompt>"

# secrets管理
just edit-secrets
just init-age

# システム情報
just info
nix flake show
```

### Useful Prompts
```bash
# 説明
"<file>の役割を説明して"
"<package>がどこで定義されているか見つけて"

# 追加
"<package>をhome-managerで管理したい"
"<host>に<feature>を追加して"

# 修正
"<error>を解決して"
"<module>を最適化して"

# 検証
"変更が正しくビルドされるか確認して"
"全ホストで<package>が動作するかテストして"
```

---

**END OF AGENTS GUIDE**
