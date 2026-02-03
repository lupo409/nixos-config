# nixos-config

NixOS向けのflake構成リポジトリです。現在の対象ホストはCitrusのみです。

## 構成概要
- `flake.nix` / `flake.lock` で入力と出力を管理
- `vars/default.nix` にユーザー・ホスト情報を集約
- `hosts/<host>/` にホストごとの設定を分割
- `hosts/common/` に共有設定を集約
- `modules/nixos/` に再利用可能なNixOSモジュールを配置
- `home/<user>/` にHome Manager構成を配置

## 前提
- Nix (flakes有効)
- NixOSホストでは `nixos-rebuild` が使えること

## 使い始め
```bash
git clone https://github.com/lupo409/nixos-config.git
cd nixos-config
```

## NixOS適用 (Citrus)
### ハードウェア設定の生成
```bash
sudo nixos-generate-config --show-hardware-config > hosts/citrus/hardware-configuration.nix
```

### 適用
```bash
sudo nixos-rebuild switch --flake .#Citrus
```

## Secure Boot (初回のみ)
Secure Boot を使う場合は `hosts/citrus/default.nix` で
`modules/nixos/secure-boot.nix` を有効化してから以下を実行します。

```bash
sudo sbctl create-keys
sudo sbctl enroll-keys --microsoft
sudo sbctl verify
```

## メンテナンス
```bash
nix fmt
nix flake check
```

## CI
Push時に GitHub Actions が `nix flake check` とVMテストを実行します。
