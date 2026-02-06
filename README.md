# nixos-config

## 構成概要
- `flake/` 出力の分割 (nixosConfigurations, packages, formatter)
- `vars/default.nix` ユーザー/ホスト情報
- `hosts/<host>/` ホスト別設定 (system/desktop)
- `hosts/common/` 共有設定 (security, overlays, nix-ld)
- `modules/nixos/` 再利用可能なモジュール
- `home-manager/` Home Manager 構成 (home, packages, programs)
- `secrets/` 秘密情報
## 前提
- NixOS (flakes 有効)

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
SOPS の秘密情報は secrets/secrets.yaml` に保存し、Git には `secrets/secrets.yaml.example` のみを置きます。

### 初期セットアップ
```bash
sudo mkdir -p /etc/sops/age
sudo age-keygen -o /etc/sops/age/keys.txt
export SOPS_AGE_KEY_FILE=/etc/sops/age/keys.txt

sudo cp secrets/secrets.yaml.example secrets/secrets.yaml
sudo sops --encrypt --in-place secrets/secrets.yaml
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
   sudo cp secrets/secrets.yaml.example secrets/secrets.yaml
   sudo sops --encrypt --in-place secrets/secrets.yaml
   ```

3. **必要項目を入力**
   ```bash
   sops secrets/secrets.yaml
   ```

4. **ユーザーパスワード**
    `user.hashedPassword` にパスワードハッシュを設定します。
    ```bash
    mkpasswd -m sha-512
    ```
    ```yaml
    user:
      hashedPassword: "<your-hashed-password>"
    ```

### 使い方
```bash
# 復号して確認
sops --decrypt secrets/secrets.yaml

# 編集
sops edit secrets/secrets.yaml

## CI
Push 時に GitHub Actions が `nix flake check` と VM テストを実行します。


