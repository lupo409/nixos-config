{ config, lib, pkgs, ... }:
{
  services.tailscale.enable = true;
  networking.firewall.allowedUDPPorts = [ 41641 ];

  systemd.services.tailscale-autoconnect =
    lib.mkIf (config.sops.secrets ? "tailscale/authkey") {
      description = "Authenticate Tailscale using SOPS-managed key";
      after = [ "network-online.target" "tailscaled.service" "sops-nix.service" ];
      wants = [ "network-online.target" "tailscaled.service" "sops-nix.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [ config.services.tailscale.package pkgs.coreutils ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        tailscale up --authkey="$(cat ${config.sops.secrets."tailscale/authkey".path})"
      '';
    };
}
