export FLAKE := justfile_directory()
export HOSTNAME := env_var_or_default('HOSTNAME', 'Yuzu')

update:
    nix flake update

rebuild host=HOSTNAME:
    sudo nixos-rebuild switch --flake {{FLAKE}}#{{host}}

darwin host=HOSTNAME:
    darwin-rebuild switch --flake {{FLAKE}}#{{host}}

check:
    nix flake check
    @echo "Flake check passed!"

fmt:
    nix fmt

edit-secrets file="secrets/api-keys.yaml":
    sops {{file}}

init-age:
    mkdir -p ~/.config/sops/age
    age-keygen -o ~/.config/sops/age/keys.txt
    @echo "Age key generated! Add the public key to .sops.yaml"
    age-keygen -y ~/.config/sops/age/keys.txt

clean:
    sudo nix-collect-garbage -d
    nix store optimise

info:
    nix-shell -p fastfetch --run fastfetch

test-vm host="Citrus":
    nixos-rebuild build-vm --flake {{FLAKE}}#{{host}}
    @echo "VM built! Run result/bin/run-{{host}}-vm to start"
