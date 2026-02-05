# nixos-config

NixOS (Citrus) を前提とした flake 構成リポジトリです。実行・検証は NixOS 上で行います。

## 構成概要
- `flake/` 出力の分割 (nixosConfigurations, packages, formatter)
- `vars/default.nix` ユーザー/ホスト情報
- `hosts/<host>/` ホスト別設定 (system/desktop)
- `hosts/common/` 共有設定 (security, overlays, nix-ld)
- `modules/nixos/` 再利用可能なモジュール
- `home-manager/` Home Manager 構成 (home, packages, programs)
- `secrets/` 秘密情報の例 (実データは置かない)

## 前提
- NixOS (flakes 有効)
- `nixos-rebuild` が使えること

## 運用フロー (必須)
Nix ファイルを書き換えたあとは毎回、以下を実行して確認します。

```bash
nix fmt
nix flake check
```

編集を終わらせる前に、エラーがないかどうかの確認として以下を実行します。
`nix flake update` は `flake.lock` を更新するため、変更が出た場合は内容を確認してください。

```bash
nix flake update
sudo nixos-rebuild switch --flake .#Citrus
```

エラーが出た場合は修正し、同じ手順を再実行します。

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

## ユーザーをimmutableにしてパスワード設定
ユーザーを宣言的に管理する場合は `users.mutableUsers = false;` を有効化し、
`users.users.<name>.hashedPassword` にハッシュを指定します。

```bash
mkpasswd -m sha-512
```

```nix
users.mutableUsers = false;
users.users.<name>.hashedPassword = "<hash>";
```

`mkpasswd` が使えない場合は `openssl passwd -6` でも生成できます。

## Secure Boot (初回のみ)
Secure Boot を使う場合は `hosts/citrus/default.nix` で
`modules/nixos/secure-boot.nix` を有効化してから以下を実行します。

```bash
sudo sbctl create-keys
sudo sbctl enroll-keys --microsoft
sudo sbctl verify
```

## Secrets (sops)
SOPS の秘密情報は `/etc/nixos/secrets.yaml` に保存し、Git には `secrets/secrets.yaml.example` のみを置きます。

### 初期セットアップ
```bash
sudo mkdir -p /etc/sops/age
sudo age-keygen -o /etc/sops/age/keys.txt
export SOPS_AGE_KEY_FILE=/etc/sops/age/keys.txt

sudo cp secrets/secrets.yaml.example /etc/nixos/secrets.yaml
sudo sops --encrypt --in-place /etc/nixos/secrets.yaml
```

### 新規マシンのセットアップ手順
1. **鍵の作成**
   ```bash
   sudo mkdir -p /etc/sops/age
   sudo age-keygen -o /etc/sops/age/keys.txt
   export SOPS_AGE_KEY_FILE=/etc/sops/age/keys.txt
   ```

2. **例ファイルの配置 → 暗号化**
   ```bash
   sudo cp secrets/secrets.yaml.example /etc/nixos/secrets.yaml
   sudo sops --encrypt --in-place /etc/nixos/secrets.yaml
   ```

3. **必要項目を入力**
   ```bash
   sops /etc/nixos/secrets.yaml
   ```

4. **DMS の天気ロケーション（緯度経度）**
   `dms.weather_coordinates` に `lat,lon` 形式で設定します。
   ```yaml
   dms:
     weather_coordinates: "35.681236,139.767125"
   ```
   例: 東京駅付近

5. **適用**
   ```bash
   sudo nixos-rebuild switch --flake .#Citrus
   ```

既に `/etc/nixos/secrets.yaml` が平文の場合は、いったん削除して作り直してください。

### 使い方
```bash
# 復号して確認
sops --decrypt /etc/nixos/secrets.yaml

# 編集
sops /etc/nixos/secrets.yaml

# 初回: exampleから複製して暗号化
sudo cp secrets/secrets.yaml.example /etc/nixos/secrets.yaml
sudo sops --encrypt --in-place /etc/nixos/secrets.yaml

# 必要な値だけ上書き
sops --decrypt /etc/nixos/secrets.yaml | \
  jq '.github.token="<token>" | .tailscale.authkey="<authkey>"' | \
  sudo sops --encrypt --output /etc/nixos/secrets.yaml /dev/stdin
```

#### DMS 天気の座標を更新する
```bash
sops --decrypt /etc/nixos/secrets.yaml | \
  jq '.dms.weather_coordinates="35.681236,139.767125"' | \
  sudo sops --encrypt --output /etc/nixos/secrets.yaml /dev/stdin
```

### Tailscale 自動認証
`modules/nixos/tailscale.nix` で `tailscale up --authkey=...` を SOPS の secret から実行します。

## CI
Push 時に GitHub Actions が `nix flake check` と VM テストを実行します。


